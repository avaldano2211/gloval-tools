// Convierte el catálogo de Postgres (migration/source/catalog) a DDL T-SQL idempotente en migration/target.
// Alcance: esquemas, secuencias, tablas (columnas, defaults, PK, UNIQUE, CHECK, columnas calculadas),
// índices y foreign keys. NO convierte funciones, vistas, triggers, políticas RLS ni vistas materializadas.
// Uso: node migration/tools/to_tsql.mjs
import fs from 'node:fs';
import path from 'node:path';
import { moduleOf } from './modules.mjs';

const ROOT = path.join(path.dirname(new URL(import.meta.url).pathname), '..');
const CAT = path.join(ROOT, 'source', 'catalog');
const OUT = path.join(ROOT, 'target');
const load = (n) => JSON.parse(fs.readFileSync(path.join(CAT, n), 'utf8'));

export const COLLATION = 'Latin1_General_100_CI_AI_SC_UTF8';
const SCHEMA_MAP = { public: 'dbo', private: 'private', archive: 'archive', timeclock: 'timeclock' };

const columns = load('columns.json');
const constraints = load('constraints.json');
const indexes = load('indexes.json');
const relations = load('relations.json');
const exact = load('exact_counts_2026-09-29.json');
const keyLens = Object.fromEntries(load('key_text_lengths.json').map((r) => [r.t, r]));
const enumDefs = Object.fromEntries(
  fs.readFileSync(path.join(ROOT, 'source', '01_enums.sql'), 'utf8').split('\n')
    .map((l) => l.match(/^CREATE TYPE (\w+)\.(\w+) AS ENUM \((.*)\);$/)).filter(Boolean)
    .map((m) => [m[2], [...m[3].matchAll(/'((?:[^']|'')*)'/g)].map((x) => x[1].replace(/''/g, "'"))]),
);

// ---------- utilidades ----------
const br = (id) => '[' + id.replace(/]/g, ']]') + ']';
const tgt = (s, t) => `${br(SCHEMA_MAP[s])}.${br(t)}`;
const nlit = (s) => "N'" + s.replace(/'/g, "''") + "'";
const unq = (c) => c.trim().replace(/^"(.*)"$/, '$1').replace(/""/g, '"');
function splitTop(s, sep = ',') {
  const out = []; let d = 0, q = false, cur = '';
  for (const ch of s) {
    if (ch === "'") q = !q;
    if (!q && ch === '(') d++;
    if (!q && ch === ')') d--;
    if (!q && d === 0 && ch === sep) { out.push(cur.trim()); cur = ''; } else cur += ch;
  }
  if (cur.trim()) out.push(cur.trim());
  return out;
}
const report = { excluded: [], fkDropped: [], fkDowngraded: [], idxSkipped: [], idxChanged: [], checkSkipped: [],
  generatedToPlain: [], computed: [], seqs: [], identities: [], keyGuess: [], wideKeys: [], uniqueNullable: [],
  numericUnbounded: 0, arrays: [], intervals: [], renamedConstraints: [] };

// ---------- 1. qué tablas entran ----------
const tables = relations.filter((r) => ['r', 'p'].includes(r.kind)).map((r) => {
  const k = `${r.schema}.${r.tbl}`;
  const rows = exact[k] ?? Math.max(Number(r.live_rows), Number(r.est_rows));
  const mod = moduleOf(r.schema, r.tbl);
  let reason = null;
  if (mod.key === 'temporal') reason = 'temporal / respaldo';
  else if (rows === 0) reason = 'vacía (count exacto = 0)';
  return { ...r, k, rows, mod, reason };
});
const included = new Map(tables.filter((t) => !t.reason).map((t) => [t.k, t]));
for (const t of tables.filter((t) => t.reason)) report.excluded.push({ table: t.k, reason: t.reason, rows: t.rows });

// ---------- 2. columnas clave de texto y su tamaño ----------
const colsBy = {};
for (const c of columns) (colsBy[`${c.schema}.${c.tbl}`] ||= []).push(c);
const colType = (k, col) => colsBy[k]?.find((c) => c.col === col)?.type;
const isText = (ty) => /^(text|character varying)$/.test(ty);
const keySize = {}; // "schema.tabla.col" -> n (NVARCHAR(n))
const bucket = (n) => [50, 100, 255, 450].find((b) => b >= n) ?? 450;
function markKey(k, col, why) {
  const ty = colType(k, col);
  if (!ty || !isText(ty)) return;
  const kl = keyLens[k];
  const measured = kl?.m?.[col];
  let n;
  if (measured == null) {
    n = 255;
    if (!kl || !(col in (kl.m || {}))) report.keyGuess.push(`${k}.${col} (${why})`);
  } else n = bucket(Math.max(measured * (kl.sampled ? 3 : 2), 20));
  keySize[`${k}.${col}`] = Math.max(keySize[`${k}.${col}`] || 0, n);
}
const pkUq = constraints.filter((c) => ['p', 'u'].includes(c.type));
const colList = (def) => splitTop(def.match(/\((.*?)\)/)[1]).map(unq);
for (const c of pkUq) colList(c.def).forEach((col) => markKey(`${c.schema}.${c.tbl}`, col, c.type === 'p' ? 'PK' : 'UNIQUE'));
const fks = constraints.filter((c) => c.type === 'f');
for (const c of fks) colList(c.def).forEach((col) => markKey(`${c.schema}.${c.tbl}`, col, 'FK'));

// índices: se parsean aquí para marcar claves (incluye lower()/upper() que con collation CI equivalen a la columna)
function parseIndex(i) {
  const h = i.def.match(/^CREATE (UNIQUE )?INDEX (\S+) ON (\S+) USING (\w+) \(/);
  if (!h) return { ok: false, why: 'no se pudo parsear' };
  const [, uniq, name, , method] = h;
  let d = 0, end = -1;
  for (let x = h[0].length - 1; x < i.def.length; x++) {
    if (i.def[x] === '(') d++;
    if (i.def[x] === ')' && --d === 0) { end = x; break; }
  }
  const keys = i.def.slice(h[0].length, end);
  const rest = i.def.slice(end + 1);
  const nnd = / NULLS NOT DISTINCT/.test(rest);
  const rm = rest.replace(' NULLS NOT DISTINCT', '').match(/^(?: INCLUDE \((.*?)\))?(?: WHERE (.*))?$/);
  if (!rm) return { ok: false, why: 'no se pudo parsear' };
  const [, incl, where] = rm;
  if (method !== 'btree') return { ok: false, why: `método ${method} (usar Full-Text / índice JSON)` };
  const cols = [];
  let changed = false;
  for (let part of splitTop(keys)) {
    part = part.replace(/ NULLS (FIRST|LAST)$/, '');
    const dir = / DESC$/.test(part) ? ' DESC' : '';
    part = part.replace(/ (ASC|DESC)$/, '');
    let mm = part.match(/^\(?(?:lower|upper)\(\(?("?[\w]+"?)\)?(?:::text)?\)\)?$/);
    if (mm) { cols.push({ col: unq(mm[1]), dir }); changed = true; continue; }
    mm = part.match(/^COALESCE\(\(?("?\w+"?)\)?(?:::text)?, ''::text\)$/);
    if (mm) { cols.push({ col: unq(mm[1]), dir, coalesce: true }); continue; }
    if (/^("[^"]+"|[a-z_][a-z0-9_]*)$/.test(part)) { cols.push({ col: unq(part), dir }); continue; }
    return { ok: false, why: `expresión en la clave: ${part}` };
  }
  return { ok: true, unique: !!uniq, nnd, name: unq(name), cols, include: incl ? splitTop(incl).map(unq) : [], where, changed };
}
const parsedIdx = indexes.map((i) => ({ i, p: parseIndex(i) }));
for (const { i, p } of parsedIdx) if (p.ok) p.cols.forEach((c) => markKey(`${i.schema}.${i.tbl}`, c.col, 'índice'));

// FK: igualar tamaños entre columna que referencia y referenciada
const fkPairs = [];
for (const c of fks) {
  const m = c.def.match(/^FOREIGN KEY \((.*?)\) REFERENCES (\S+?)\((.*?)\)/);
  const from = splitTop(m[1]).map(unq);
  const refT = m[2].includes('.') ? m[2].replace(/"/g, '') : `public.${m[2].replace(/"/g, '')}`;
  const to = splitTop(m[3]).map(unq);
  from.forEach((f, ix) => fkPairs.push([`${c.schema}.${c.tbl}.${f}`, `${refT}.${to[ix]}`]));
}
for (let changed = true; changed;) {
  changed = false;
  for (const [a, b] of fkPairs) {
    if (!(a in keySize) && !(b in keySize)) continue;
    const n = Math.max(keySize[a] || 0, keySize[b] || 0);
    for (const x of [a, b]) {
      const [s, t, col] = [x.split('.')[0], x.split('.')[1], x.split('.').slice(2).join('.')];
      if (isText(colType(`${s}.${t}`, col) || '') && keySize[x] !== n) { keySize[x] = n; changed = true; }
    }
  }
}

// ---------- 3. tipos ----------
function mapType(k, c) {
  const ty = c.type;
  const key = keySize[`${k}.${c.col}`];
  let m;
  if (ty === 'uuid') return { t: 'UNIQUEIDENTIFIER' };
  if (ty === 'text') return { t: key ? `NVARCHAR(${key})` : 'NVARCHAR(MAX)' };
  if ((m = ty.match(/^character varying(?:\((\d+)\))?$/))) {
    const n = m[1] ? Number(m[1]) : null;
    if (key) return { t: `NVARCHAR(${n ? Math.min(n, 450) : key})` };
    return { t: n && n <= 4000 ? `NVARCHAR(${n})` : 'NVARCHAR(MAX)' };
  }
  if ((m = ty.match(/^character\((\d+)\)$/))) return { t: `NCHAR(${m[1]})` };
  if (ty === 'timestamp with time zone') return { t: 'DATETIMEOFFSET' };
  if (ty === 'timestamp without time zone') return { t: 'DATETIME2' };
  if (ty === 'date') return { t: 'DATE' };
  if (ty === 'time without time zone') return { t: 'TIME' };
  if (ty === 'boolean') return { t: 'BIT' };
  if (ty === 'integer') return { t: 'INT' };
  if (ty === 'bigint') return { t: 'BIGINT' };
  if (ty === 'smallint') return { t: 'SMALLINT' };
  if (ty === 'double precision') return { t: 'FLOAT' };
  if (ty === 'real') return { t: 'REAL' };
  if (ty === 'bytea') return { t: 'VARBINARY(MAX)' };
  if ((m = ty.match(/^numeric\((\d+),(\d+)\)$/))) return { t: `DECIMAL(${m[1]},${m[2]})` };
  if (ty === 'numeric') { report.numericUnbounded++; return { t: 'DECIMAL(38,10)' }; }
  if (ty === 'jsonb' || ty === 'json') return { t: 'NVARCHAR(MAX)', check: (col) => `ISJSON(${col}) = 1` };
  if (ty.endsWith('[]')) {
    report.arrays.push(`${k}.${c.col} (${ty})`);
    return { t: 'NVARCHAR(MAX)', check: (col) => `ISJSON(${col}) = 1`, array: true };
  }
  if (ty === 'interval') { report.intervals.push(`${k}.${c.col}`); return { t: 'BIGINT', interval: true }; }
  if (enumDefs[ty]) {
    const labels = enumDefs[ty];
    const len = bucket(Math.max(...labels.map((l) => l.length)));
    return { t: `NVARCHAR(${key ? Math.max(key, len) : len})`, check: (col) => `${col} IN (${labels.map(nlit).join(', ')})`, enumName: ty };
  }
  throw new Error(`Tipo sin mapeo: ${k}.${c.col} ${ty}`);
}

// ---------- 4. defaults ----------
const pgArrayToJson = (lit) => {
  const inner = lit.replace(/^\{|\}$/g, '');
  if (!inner) return '[]';
  return JSON.stringify(splitTop(inner).map((x) => x.replace(/^"(.*)"$/, '$1')));
};
function mapDefault(k, c, mt, isSinglePk) {
  const d = c.def.trim();
  let m;
  if (/^now\(\)$|^CURRENT_TIMESTAMP$/.test(d)) return c.type === 'timestamp without time zone' ? 'SYSUTCDATETIME()' : 'SYSDATETIMEOFFSET()';
  if (/^(gen_random_uuid|uuid_generate_v4|extensions\.uuid_generate_v4)\(\)$/.test(d)) return isSinglePk ? 'NEWSEQUENTIALID()' : 'NEWID()';
  if (d === 'CURRENT_DATE') return 'CAST(SYSUTCDATETIME() AS DATE)';
  if ((m = d.match(/^\(\(now\(\) AT TIME ZONE '([^']+)'::text\)\)::date$/))) {
    const WIN = { 'America/New_York': 'Eastern Standard Time', 'America/Guayaquil': 'SA Pacific Standard Time', 'America/Lima': 'SA Pacific Standard Time', 'America/Panama': 'SA Pacific Standard Time' };
    if (!WIN[m[1]]) throw new Error('zona horaria sin mapeo ' + m[1]);
    return `CAST(SYSDATETIMEOFFSET() AT TIME ZONE ${nlit(WIN[m[1]])} AS DATE)`;
  }
  if (d === 'true') return '1';
  if (d === 'false') return '0';
  if ((m = d.match(/^\(?'?(-?\d+(?:\.\d+)?)'?\)?(?:::[\w ]+)?$/))) return m[1];
  if ((m = d.match(/^nextval\('([^']+)'::regclass\)$/))) {
    const [s, n] = m[1].includes('.') ? m[1].split('.') : ['public', m[1]];
    const seq = `${br(SCHEMA_MAP[s])}.${br(n)}`;
    report.seqs.push({ seq, table: k, col: c.col, type: mt.t });
    return `NEXT VALUE FOR ${seq}`;
  }
  if ((m = d.match(/^'((?:[^']|'')*)'::(.+)$/))) {
    const [val, ty] = [m[1].replace(/''/g, "'"), m[2]];
    if (ty.endsWith('[]')) return nlit(pgArrayToJson(val));
    if (ty === 'interval') {
      const iv = val.match(/^(\d+) (second|minute|hour|day)s?$/);
      if (!iv) throw new Error('intervalo sin mapeo ' + val);
      return String(Number(iv[1]) * { second: 1, minute: 60, hour: 3600, day: 86400 }[iv[2]]);
    }
    if (ty === 'uuid' || ty === 'date') return `'${val}'`;
    return nlit(val);
  }
  return null; // no traducible
}

// ---------- 5. expresiones (CHECK, WHERE de índices, columnas calculadas) ----------
function tx(expr, boolCols = [], colNames = []) {
  let e = expr;
  // (x IS NOT NULL)::integer  ->  CASE
  e = e.replace(/\(\(([^()]+ IS (?:NOT )?NULL)\)\)::integer/g, '(CASE WHEN $1 THEN 1 ELSE 0 END)');
  // x = ANY (ARRAY[...])  /  x <> ALL (ARRAY[...]); el ARRAY puede venir envuelto en un paréntesis extra
  const lhs = String.raw`\(([^()]+|\([^()]*\))\s*`;
  const arr = String.raw`ARRAY\[([^\]]*)\](?:::[\w ]+\[\])?`;
  for (const [op, sqlOp] of [['=\\s*ANY', 'IN'], ['<>\\s*ALL', 'NOT IN']]) {
    e = e.replace(new RegExp(lhs + op + String.raw`\s*\(\(` + arr + String.raw`\)\)\)`, 'g'), `($1 ${sqlOp} ($2))`);
    e = e.replace(new RegExp(lhs + op + String.raw`\s*\(` + arr + String.raw`\)\)`, 'g'), `($1 ${sqlOp} ($2))`);
  }
  // casts
  e = e.replace(/\((-?\d+(?:\.\d+)?)\)::(numeric|integer|bigint|double precision)/g, '$1');
  e = e.replace(/::(text|numeric|integer|bigint|character varying|date|timestamp with time zone|double precision|[a-z_]+_t|[a-z_]+_status|[a-z_]+_type|[a-z_]+_kind)\b(?!\[)/g, '');
  // literales
  e = e.replace(new RegExp(`::(${Object.keys(enumDefs).join('|')})\\b(?!\\[)`, 'g'), '');
  e = e.replace(/'((?:[^']|'')*)'/g, (all, s, off, str) => (str[off - 1] === 'N' ? all : nlit(s.replace(/''/g, "'"))));
  // booleanos
  e = e.replace(/=\s*true\b/g, '= 1').replace(/=\s*false\b/g, '= 0');
  // funciones
  e = e.replace(/\bchar_length\(|\blength\(/g, 'LEN(').replace(/\bbtrim\(/g, 'TRIM(').replace(/\bnow\(\)/g, 'SYSDATETIMEOFFSET()');
  for (const b of boolCols) {
    // columna booleana usada como predicado: "activo" -> (activo = 1), "NOT activo" -> (activo = 0)
    e = e.replace(new RegExp(`\\bNOT ${b}\\b(?!\\s*(=|<>|IS\\b))`, 'g'), `(${b} = 0)`);
    e = e.replace(new RegExp(`(^|[(\\s])${b}\\b(?!\\s*(=|<>|IS\\b| = ))`, 'g'), `$1(${b} = 1)`);
  }
  const bare = e.replace(/N'(?:[^']|'')*'/g, "N''");
  if (/::|~|\bARRAY\b|\bANY\b|\bALL\b|jsonb_|regexp_|\|\||\bILIKE\b|\bSIMILAR\b|array_length|cardinality/.test(bare)) return null;
  // corchetes en nombres de columna (fuera de literales)
  const names = new Set(colNames);
  e = e.split(/(N'(?:[^']|'')*')/).map((seg, ix) => (ix % 2 ? seg : seg.replace(/(\[[^\]]*\])|"([^"]+)"|\b([a-z_][a-z0-9_]*)\b(?!\s*\()/g,
    (all, b, q, w) => (b ? b : q && names.has(q) ? br(q) : w && names.has(w) ? br(w) : all)))).join('');
  return e;
}
function txComputed(k, c) {
  let e = c.def;
  if (/normalize_company_name|regexp_replace/.test(e)) return null;
  e = e.replace(/COALESCE\((\w+), (\w+)\) \+ (\w+)/, 'DATEADD(day, $3, COALESCE($1, $2))');
  if (/\|\|/.test(e)) {
    e = e.replace(/::text/g, '');
    e = 'CONCAT(' + e.replace(/[()]/g, (ch) => ch).split('||').map((p) => p.trim().replace(/^\(+|\)+$/g, (m) => m)).join(', ') + ')';
    // Se reconstruye de forma explícita (la expresión original es una cadena de COALESCE y ' ').
    const parts = [...c.def.matchAll(/COALESCE\((\w+), ''::text\)/g)].map((m) => `COALESCE(${m[1]}, N'')`);
    e = `CONCAT(${parts.join(", N' ', ")})`;
  }
  e = tx(e, [], colsBy[k].map((x) => x.col));
  return e;
}

// ---------- 6. nombres de constraints únicos por esquema ----------
const usedNames = {};
function uniqName(s, name, t) {
  const key = `${SCHEMA_MAP[s]}.${name}`;
  if (!usedNames[key]) { usedNames[key] = t; return name; }
  const alt = `${t}__${name}`.slice(0, 128);
  report.renamedConstraints.push(`${s}.${t}: ${name} -> ${alt}`);
  usedNames[`${SCHEMA_MAP[s]}.${alt}`] = t;
  return alt;
}

// ---------- 7. tablas ----------
const consBy = {};
for (const c of constraints) (consBy[`${c.schema}.${c.tbl}`] ||= []).push(c);
const files = {};
const addTo = (file, sql) => ((files[file] ||= []).push(sql));
const mapping = {};

for (const [k, t] of included) {
  const [s, n] = k.split('.');
  const cols = colsBy[k];
  const cons = consBy[k] || [];
  const pk = cons.find((c) => c.type === 'p');
  const pkCols = pk ? colList(pk.def) : [];
  const boolCols = cols.filter((c) => c.type === 'boolean').map((c) => c.col);
  const lines = [];
  const colChecks = [];
  mapping[k] = { target: `${SCHEMA_MAP[s]}.${n}`, module: t.mod.title, columns: {} };

  for (const c of cols) {
    const mt = mapType(k, c);
    let line = `  ${br(c.col)} `;
    const cm = { pgType: c.type, sqlType: mt.t };
    if (c.gen === 's') {
      const e = txComputed(k, c);
      if (e) {
        line += `AS CAST((${e}) AS ${mt.t}) PERSISTED`;
        report.computed.push(`${k}.${c.col}`);
        cm.computed = true;
        lines.push(line); mapping[k].columns[c.col] = cm; continue;
      }
      report.generatedToPlain.push(`${k}.${c.col} = ${c.def.replace(/\s+/g, ' ')}`);
      cm.wasGenerated = true;
    }
    line += mt.t;
    if (c.ident) {
      line += ' IDENTITY(1,1)';
      report.identities.push(`${k}.${c.col}`);
      cm.identity = true;
    }
    line += c.notnull ? ' NOT NULL' : ' NULL';
    if (c.def != null && c.gen !== 's' && !c.ident) {
      const d = mapDefault(k, c, mt, pkCols.length === 1 && pkCols[0] === c.col);
      if (d == null) throw new Error(`Default sin traducir: ${k}.${c.col} = ${c.def}`);
      line += ` CONSTRAINT ${br(uniqName(s, `DF_${n}_${c.col}`.slice(0, 128), n))} DEFAULT (${d})`;
      if (/^NEXT VALUE FOR/.test(d)) cm.sequence = d.replace('NEXT VALUE FOR ', '');
    }
    if (mt.check) colChecks.push({ name: `CK_${n}_${c.col}_${mt.enumName ? 'enum' : 'json'}`, expr: mt.check(br(c.col)) });
    if (mt.array) cm.note = 'array de Postgres guardado como JSON';
    if (mt.interval) cm.note = 'interval guardado en segundos';
    lines.push(line);
    mapping[k].columns[c.col] = cm;
  }

  // PK / UNIQUE / CHECK
  for (const c of cons) {
    if (c.type === 'p') {
      lines.push(`  CONSTRAINT ${br(uniqName(s, c.name, n))} PRIMARY KEY (${colList(c.def).map(br).join(', ')})`);
    } else if (c.type === 'u') {
      const ucols = colList(c.def);
      const nullable = ucols.filter((u) => !cols.find((x) => x.col === u).notnull);
      const referenced = fkPairs.some(([, b]) => ucols.some((u) => b === `${k}.${u}`));
      if (nullable.length && !referenced) {
        // Postgres permite varios NULL en UNIQUE; SQL Server no: índice único filtrado
        c._asIndex = { cols: ucols, where: nullable.map((u) => `${br(u)} IS NOT NULL`).join(' AND ') };
        report.uniqueNullable.push(`${k} (${ucols.join(', ')}) -> índice único filtrado`);
      } else {
        if (nullable.length) report.uniqueNullable.push(`${k} (${ucols.join(', ')}) -> UNIQUE normal (es referenciada por FK); SQL Server solo admite un NULL`);
        lines.push(`  CONSTRAINT ${br(uniqName(s, c.name, n))} UNIQUE (${ucols.map(br).join(', ')})`);
      }
    } else if (c.type === 'c') {
      const inner = c.def.replace(/^CHECK /, '').replace(/ NOT VALID$/, '');
      const e = tx(inner, boolCols, cols.map((x) => x.col));
      if (e) lines.push(`  CONSTRAINT ${br(uniqName(s, c.name, n))} CHECK ${e}`);
      else report.checkSkipped.push(`${k}: ${c.name} ${c.def}`);
    }
  }
  for (const ck of colChecks) lines.push(`  CONSTRAINT ${br(uniqName(s, ck.name.slice(0, 128), n))} CHECK (${ck.expr})`);

  const sql =
    `-- ${k} | ~${t.rows.toLocaleString('en-US')} filas${pk ? '' : ' | SIN PK en origen'}\n` +
    `IF OBJECT_ID(N'${tgt(s, n)}', N'U') IS NULL\nBEGIN\nCREATE TABLE ${tgt(s, n)} (\n${lines.join(',\n')}\n);\nEND\nGO\n`;
  addTo(t.mod.file, sql);

  for (const c of cons.filter((c) => c._asIndex)) {
    const nm = c.name;
    addTo(t.mod.file,
      `IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'${nm}' AND object_id = OBJECT_ID(N'${tgt(s, n)}'))\n` +
      `CREATE UNIQUE INDEX ${br(nm)} ON ${tgt(s, n)} (${c._asIndex.cols.map(br).join(', ')}) WHERE ${c._asIndex.where};\nGO\n`);
  }
}

// ---------- 8. índices ----------
const colSqlType = (k, col) => mapping[k]?.columns[col]?.sqlType;
const widthBytes = (ty) => {
  let m;
  if ((m = ty.match(/^NVARCHAR\((\d+)\)$/))) return Number(m[1]) * 2;
  if ((m = ty.match(/^NCHAR\((\d+)\)$/))) return Number(m[1]) * 2;
  return { UNIQUEIDENTIFIER: 16, DATETIMEOFFSET: 10, DATETIME2: 8, DATE: 3, BIT: 1, INT: 4, BIGINT: 8, SMALLINT: 2, FLOAT: 8, REAL: 4 }[ty] ?? (/^DECIMAL/.test(ty) ? 17 : 0);
};
for (const { i, p } of parsedIdx) {
  const k = `${i.schema}.${i.tbl}`;
  if (!included.has(k)) continue;
  const t = included.get(k);
  if (!p.ok) { report.idxSkipped.push(`${k}: ${i.name} — ${p.why}`); continue; }
  const cols = colsBy[k];
  const boolCols = cols.filter((c) => c.type === 'boolean').map((c) => c.col);
  if (p.cols.some((c) => colSqlType(k, c.col) === 'NVARCHAR(MAX)' || colSqlType(k, c.col) === 'VARBINARY(MAX)')) {
    report.idxSkipped.push(`${k}: ${i.name} — columna clave sin tamaño`); continue;
  }
  if (p.cols.some((c) => mapping[k].columns[c.col]?.computed === undefined && mapping[k].columns[c.col] == null)) {
    report.idxSkipped.push(`${k}: ${i.name} — columna inexistente`); continue;
  }
  let where = null;
  if (p.where) {
    where = tx(p.where, boolCols, cols.map((x) => x.col));
    if (where && /\bOR\b|\bNOT IN\b|\(SELECT|LEN\(|TRIM\(|SYSDATETIMEOFFSET/.test(where)) where = null;
    if (!where) {
      if (p.unique) { report.idxSkipped.push(`${k}: ${i.name} — UNIQUE parcial con predicado no soportado en índices filtrados: ${p.where}`); continue; }
      report.idxChanged.push(`${k}: ${i.name} — se quitó el filtro WHERE ${p.where} (no soportado); queda como índice completo`);
    }
  }
  if (p.unique) {
    const nullable = p.nnd ? [] : p.cols.filter((c) => !c.coalesce && !cols.find((x) => x.col === c.col).notnull).map((c) => `${br(c.col)} IS NOT NULL`);
    if (nullable.length) where = [where, ...nullable].filter(Boolean).join(' AND ');
  }
  if (p.changed) report.idxChanged.push(`${k}: ${i.name} — lower()/upper() quitado (la collation CI ya ignora mayúsculas)`);
  const w = p.cols.reduce((a, c) => a + widthBytes(colSqlType(k, c.col)), 0);
  if (w > 1700) report.wideKeys.push(`${k}: ${i.name} (${w} bytes > 1700)`);
  const keyCols = [];
  for (const c of p.cols) {
    if (!c.coalesce) { keyCols.push(br(c.col) + c.dir); continue; }
    const st = colSqlType(k, c.col);
    if (!/^N?VARCHAR|^NVARCHAR/.test(st)) { keyCols.push(br(c.col) + c.dir); continue; } // no-texto: SQL Server ya trata NULL = NULL
    const cc = `${c.col}__nn`;
    if (!mapping[k].columns[cc]) {
      mapping[k].columns[cc] = { sqlType: st, computed: true, note: `COALESCE(${c.col}, '') para el índice ${p.name}` };
      report.computed.push(`${k}.${cc} (para índice ${p.name})`);
      addTo(t.mod.file, `IF COL_LENGTH(N'${tgt(i.schema, i.tbl)}', N'${cc}') IS NULL\n` +
        `ALTER TABLE ${tgt(i.schema, i.tbl)} ADD ${br(cc)} AS COALESCE(${br(c.col)}, N'') PERSISTED;\nGO\n`);
    }
    keyCols.push(br(cc) + c.dir);
  }
  const include = p.include.filter((c) => mapping[k].columns[c] && !p.cols.some((x) => x.col === c));
  addTo(t.mod.file,
    `IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'${p.name}' AND object_id = OBJECT_ID(N'${tgt(i.schema, i.tbl)}'))\n` +
    `CREATE ${p.unique ? 'UNIQUE ' : ''}INDEX ${br(p.name)} ON ${tgt(i.schema, i.tbl)} (${keyCols.join(', ')})` +
    `${include.length ? ` INCLUDE (${include.map(br).join(', ')})` : ''}${where ? ` WHERE ${where}` : ''};\nGO\n`);
}
// PK anchas
for (const [k] of included) {
  const pk = (consBy[k] || []).find((c) => c.type === 'p');
  if (!pk) continue;
  const w = colList(pk.def).reduce((a, c) => a + widthBytes(colSqlType(k, c)), 0);
  if (w > 900) report.wideKeys.push(`${k}: PK ${pk.name} (${w} bytes > 900, clave clustered)`);
}

// ---------- 9. foreign keys (con detección de rutas de cascada múltiples) ----------
const cascEdges = {}; // padre -> Set(hijo)
const reach = (from) => {
  const seen = new Set([from]); const st = [from];
  while (st.length) for (const x of cascEdges[st.pop()] || []) if (!seen.has(x)) { seen.add(x); st.push(x); }
  return seen;
};
const ancestors = (node) => {
  const seen = new Set([node]); let grew = true;
  while (grew) { grew = false; for (const [p, ch] of Object.entries(cascEdges)) if (!seen.has(p) && [...ch].some((c) => seen.has(c))) { seen.add(p); grew = true; } }
  return seen;
};
let fkSql = '';
const fkChecks = [];
for (const c of [...fks].sort((a, b) => `${a.schema}.${a.tbl}.${a.name}`.localeCompare(`${b.schema}.${b.tbl}.${b.name}`))) {
  const k = `${c.schema}.${c.tbl}`;
  if (!included.has(k)) continue;
  const m = c.def.match(/^FOREIGN KEY \((.*?)\) REFERENCES (\S+?)\((.*?)\)(.*)$/);
  const refK = m[2].includes('.') ? m[2].replace(/"/g, '') : `public.${m[2].replace(/"/g, '')}`;
  if (!included.has(refK)) {
    report.fkDropped.push(`${k}.${c.name} -> ${refK} (${refK.startsWith('auth.') ? 'Supabase Auth: se decide con el tema de autenticación' : 'tabla destino excluida'})`);
    continue;
  }
  let rest = m[4].trim();
  let del = (rest.match(/ON DELETE (CASCADE|SET NULL|SET DEFAULT|RESTRICT|NO ACTION)/) || [])[1] || 'NO ACTION';
  const upd = (rest.match(/ON UPDATE (CASCADE|SET NULL|SET DEFAULT|RESTRICT|NO ACTION)/) || [])[1] || 'NO ACTION';
  if (del === 'RESTRICT') del = 'NO ACTION';
  const cascading = !['NO ACTION'].includes(del) || !['NO ACTION', 'RESTRICT'].includes(upd);
  if (cascading) {
    const bad = refK === k || reach(k).has(refK) || [...ancestors(refK)].some((a) => { const r = reach(a); return [...reach(k)].some((d) => r.has(d)); });
    if (bad) {
      report.fkDowngraded.push(`${k}.${c.name} -> ${refK}: ON DELETE ${del} pasa a NO ACTION (SQL Server no permite ciclos ni rutas múltiples de cascada)`);
      del = 'NO ACTION';
    } else (cascEdges[refK] ||= new Set()).add(k);
  }
  const [s, n] = k.split('.');
  const [rs, rn] = refK.split('.');
  const name = uniqName(s, c.name, n);
  fkChecks.push({ fk: `${k}.${c.name}`, k, refK, from: splitTop(m[1]).map(unq), to: splitTop(m[3]).map(unq) });
  fkSql += `IF OBJECT_ID(N'${br(SCHEMA_MAP[s])}.${br(name)}', N'F') IS NULL\n` +
    `ALTER TABLE ${tgt(s, n)} ADD CONSTRAINT ${br(name)} FOREIGN KEY (${splitTop(m[1]).map(unq).map(br).join(', ')}) ` +
    `REFERENCES ${tgt(rs, rn)} (${splitTop(m[3]).map(unq).map(br).join(', ')})` +
    `${del !== 'NO ACTION' ? ` ON DELETE ${del}` : ''}${upd !== 'NO ACTION' && upd !== 'RESTRICT' ? ` ON UPDATE ${upd}` : ''};\nGO\n`;
}

// ---------- 9b. verificaciones de FKs ----------
const uniqueSets = {}; // tabla -> [Set de columnas] con clave única no filtrada
const addU = (k, cols) => (uniqueSets[k] ||= []).push(cols.slice().sort().join(','));
for (const c of pkUq) if (included.has(`${c.schema}.${c.tbl}`) && !c._asIndex) addU(`${c.schema}.${c.tbl}`, colList(c.def));
for (const { i, p } of parsedIdx)
  if (p.ok && p.unique && !p.where && included.has(`${i.schema}.${i.tbl}`) && !p.cols.some((c) => c.coalesce)
      && (p.nnd || p.cols.every((c) => colsBy[`${i.schema}.${i.tbl}`].find((x) => x.col === c.col).notnull)))
    addU(`${i.schema}.${i.tbl}`, p.cols.map((c) => c.col));
report.fkProblems = [];
for (const f of fkChecks) {
  if (!(uniqueSets[f.refK] || []).includes(f.to.slice().sort().join(',')))
    report.fkProblems.push(`${f.fk}: ${f.refK}(${f.to}) no tiene PK/UNIQUE no filtrado en destino`);
  f.from.forEach((col, ix) => {
    const a = colSqlType(f.k, col), b = colSqlType(f.refK, f.to[ix]);
    if (a !== b) report.fkProblems.push(`${f.fk}: tipo ${f.k}.${col} ${a} ≠ ${f.refK}.${f.to[ix]} ${b}`);
  });
}

// ---------- 10. escribir ----------
fs.rmSync(OUT, { recursive: true, force: true });
fs.mkdirSync(OUT, { recursive: true });
const head = (title) =>
  `-- ${title}\n-- Generado por migration/tools/to_tsql.mjs desde el catálogo de Supabase (2026-09-29). No editar a mano:\n` +
  `-- cambiar el generador y volver a correrlo. Idempotente: se puede ejecutar varias veces.\n\n` +
  `SET ANSI_NULLS ON;\nSET QUOTED_IDENTIFIER ON;\nGO\n\n`;

let db = head('000 · Base de datos: collation, esquemas y secuencias');
db += `-- La collation de la BD solo se fija al crearla. Si no coincide, este script se detiene.\n`;
db += `IF CONVERT(sysname, DATABASEPROPERTYEX(DB_NAME(), 'Collation')) <> N'${COLLATION}'\n` +
  `    THROW 50001, N'La collation de la BD no es ${COLLATION}. Ver migration/target/README.md (paso 1).', 1;\nGO\n\n`;
for (const s of ['private', 'archive', 'timeclock']) db += `IF SCHEMA_ID(N'${s}') IS NULL EXEC(N'CREATE SCHEMA ${br(s)}');\nGO\n`;
db += '\n-- Secuencias (reemplazan nextval de Postgres). Tras cargar datos, reiniciar con ALTER SEQUENCE ... RESTART WITH (máx + 1).\n';
const seen = new Set();
for (const q of report.seqs) {
  if (seen.has(q.seq)) continue;
  seen.add(q.seq);
  const ty = q.type === 'INT' ? 'INT' : 'BIGINT';
  db += `IF OBJECT_ID(N'${q.seq}', N'SO') IS NULL CREATE SEQUENCE ${q.seq} AS ${ty} START WITH 1 INCREMENT BY 1;\nGO\n`;
}
fs.writeFileSync(path.join(OUT, '000_database.sql'), db);

const order = Object.keys(files).sort();
for (const f of order) {
  const mod = [...included.values()].find((t) => t.mod.file === f).mod.title;
  fs.writeFileSync(path.join(OUT, f), head(`${f.slice(0, 3)} · ${mod}: tablas e índices`) + files[f].join('\n'));
}
fs.writeFileSync(path.join(OUT, '900_foreign_keys.sql'), head('900 · Foreign keys (todas al final para no depender del orden)') + fkSql);
fs.writeFileSync(path.join(OUT, 'mapping.json'), JSON.stringify(mapping, null, 1) + '\n');
fs.writeFileSync(path.join(OUT, 'report.json'), JSON.stringify(report, null, 1) + '\n');

// ---------- README ----------
const li = (arr) => (arr.length ? arr.map((x) => `- ${typeof x === 'string' ? x : JSON.stringify(x)}`).join('\n') : '- (ninguno)');
const fileList = ['000_database.sql', ...Object.keys(files).sort(), '900_foreign_keys.sql'];
const readme = `# migration/target: DDL T-SQL para Azure SQL (Gloval One)

> Generado por \`migration/tools/to_tsql.mjs\`. No editar a mano; cambiar el generador y correr \`npm run gen:tsql\` en \`migration/\`.

## Qué incluye

- **${included.size} tablas** (${tables.length} en origen menos ${report.excluded.length} excluidas), con columnas, defaults, PK, UNIQUE, CHECK y columnas calculadas.
- **Índices** btree, **foreign keys** y **${seen.size} secuencias**.
- Los esquemas se mapean así: \`public\` → \`dbo\`, y \`private\`, \`archive\` y \`timeclock\` conservan su nombre.
- Todo es **idempotente** (\`IF OBJECT_ID(...) IS NULL\`, \`IF NOT EXISTS\`). Si una tabla ya existe no se vuelve a crear, pero tampoco se altera.

**No incluye:** funciones/RPC, vistas, vistas materializadas, triggers, políticas RLS ni cron jobs. Siguen en \`migration/source/\` y se reescriben módulo por módulo.

## Cómo aplicarlo

1. **Collation.** La BD debe tener \`${COLLATION}\`. La collation se fija al crear la BD, y \`000_database.sql\` se detiene si no coincide. Para ver la actual:
   \`SELECT DATABASEPROPERTYEX(DB_NAME(), 'Collation')\`.
   Si no coincide y la BD está vacía, lo simple es recrearla con esa collation (portal: *Additional settings → Collation*; o \`az sql db create ... --collation ${COLLATION}\`).
2. **Red.** Agregar la IP del equipo que ejecuta en el firewall del servidor.
3. **Credenciales.** Van en \`migration/.env\` (ignorado por git) o en variables de entorno: \`AZURE_SQL_SERVER\`, \`AZURE_SQL_DB\`, \`AZURE_SQL_USER\`, \`AZURE_SQL_PASSWORD\`.
4. En \`migration/\`: \`npm install\`, luego \`npm run db:plan\` (no se conecta) y \`npm run db:apply\`. Para aplicar solo algunos archivos: \`npm run db:apply -- 000 001\`.

Orden: ${fileList.map((f) => '`' + f + '`').join(' → ')}.

## Decisiones de conversión

| Postgres | SQL Server | Nota |
|---|---|---|
| \`text\` | \`NVARCHAR(MAX)\`, o \`NVARCHAR(n)\` si es clave | \`n\` = largo máximo real medido en Supabase ×2 (×3 si fue muestreado), en escalones de 50/100/255/450 |
| \`uuid\` + \`gen_random_uuid()\` | \`UNIQUEIDENTIFIER\` + \`NEWSEQUENTIALID()\` en PK, \`NEWID()\` en el resto | |
| \`timestamptz\` / \`now()\` | \`DATETIMEOFFSET\` / \`SYSDATETIMEOFFSET()\` | |
| \`numeric\` sin precisión | \`DECIMAL(38,10)\` | ${report.numericUnbounded} columnas. Revisar si alguna necesita más de 10 decimales |
| \`jsonb\` | \`NVARCHAR(MAX)\` + \`CHECK (ISJSON(col) = 1)\` | |
| arrays (\`text[]\`, etc.) | \`NVARCHAR(MAX)\` con un array JSON | ${report.arrays.length} columnas. La carga debe convertir \`{a,b}\` → \`["a","b"]\` |
| enums | \`NVARCHAR(n)\` + \`CHECK (col IN (...))\` | |
| \`interval\` | \`BIGINT\` (segundos) | ${report.intervals.join(', ')} |
| \`nextval(seq)\` | \`SEQUENCE\` + \`DEFAULT (NEXT VALUE FOR ...)\` | Tras la carga: \`ALTER SEQUENCE ... RESTART WITH máx+1\` |
| \`GENERATED ALWAYS AS IDENTITY\` | \`IDENTITY(1,1)\` | Carga con \`SET IDENTITY_INSERT ON\` y luego \`DBCC CHECKIDENT\` |
| UNIQUE sobre columnas que admiten NULL | índice único filtrado \`WHERE col IS NOT NULL\` | En Postgres varios NULL no chocan; en SQL Server un UNIQUE solo admite un NULL |
| \`UNIQUE NULLS NOT DISTINCT\`, \`COALESCE(col,'')\` en índices únicos | índice único normal / columna calculada \`col__nn\` | Mismo comportamiento que en Postgres |
| \`lower(col)\` en índices | \`col\` | La collation CI ya ignora mayúsculas |
| \`ON DELETE RESTRICT\` | \`NO ACTION\` | |

## Pendientes (revisar antes de dar por buena la estructura)

### Foreign keys con cascada rebajada a NO ACTION (${report.fkDowngraded.length})
SQL Server no permite ciclos ni varias rutas de cascada hacia una misma tabla. En estas FKs, borrar el padre ahora falla si tiene hijos, en lugar de borrarlos o ponerlos en NULL. Esa lógica pasa a la API o a un trigger.
${li(report.fkDowngraded)}

### Foreign keys omitidas (${report.fkDropped.length})
${li(report.fkDropped)}

### Columnas generadas que pasan a columnas normales (${report.generatedToPlain.length})
Usan \`normalize_company_name()\` o \`regexp_replace\`, que no se pueden usar en una columna calculada. Las debe llenar la carga de datos y después la API.
${li(report.generatedToPlain)}

### Columnas calculadas creadas (${report.computed.length})
No se insertan en la carga; SQL Server las calcula.
${li(report.computed)}

### Índices no convertidos (${report.idxSkipped.length})
Los GIN (búsqueda por trigramas) se reemplazan con Full-Text Search. Los de expresión, con una columna calculada si hacen falta.
${li(report.idxSkipped)}

### Índices modificados (${report.idxChanged.length})
${li(report.idxChanged)}

### Índices únicos filtrados por NULL (${report.uniqueNullable.length})
${li(report.uniqueNullable)}

### Datos que chocarían con la collation CI_AI
- \`dbo.consolidado_avisos\` UNIQUE (\`consolidado_id\`, \`cliente_key\`): hay 5 pares que solo difieren en mayúsculas (todos en DRAFT). Hay que depurarlos antes de cargar los datos. La estructura no se ve afectada.

### Tablas excluidas (${report.excluded.length})
${li(report.excluded.map((e) => `${e.table}: ${e.reason}${e.rows ? ` (${e.rows} filas)` : ''}`))}
`;
fs.writeFileSync(path.join(OUT, 'README.md'), readme);

const cnt = (re, f) => (fs.readFileSync(path.join(OUT, f), 'utf8').match(re) || []).length;
const all = ['000_database.sql', ...order, '900_foreign_keys.sql'];
console.log('archivos:', all.length);
console.log('tablas:', all.reduce((a, f) => a + cnt(/CREATE TABLE/g, f), 0), '| índices:', all.reduce((a, f) => a + cnt(/CREATE (UNIQUE )?INDEX/g, f), 0),
  '| FKs:', cnt(/ADD CONSTRAINT/g, '900_foreign_keys.sql'), '| secuencias:', seen.size);
for (const [k, v] of Object.entries(report)) console.log(k, Array.isArray(v) ? v.length : v);
