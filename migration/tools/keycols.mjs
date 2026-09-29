// Columnas de texto que son clave (PK, UNIQUE, FK o índice btree) y no pueden ser NVARCHAR(MAX) en SQL Server.
// Uso: node keycols.mjs  -> imprime la consulta SELECT (solo lectura) que mide su largo máximo en Supabase.
import fs from 'node:fs';
import path from 'node:path';

const CAT = path.join(path.dirname(new URL(import.meta.url).pathname), '..', 'source', 'catalog');
const load = (n) => JSON.parse(fs.readFileSync(path.join(CAT, n), 'utf8'));

export function splitCols(s) {
  const out = []; let depth = 0, cur = '';
  for (const ch of s) {
    if (ch === '(') depth++;
    if (ch === ')') depth--;
    if (ch === ',' && depth === 0) { out.push(cur.trim()); cur = ''; } else cur += ch;
  }
  if (cur.trim()) out.push(cur.trim());
  return out;
}
const unq = (c) => c.replace(/^"(.*)"$/, '$1').replace(/""/g, '"');

// Devuelve Set de "schema.tabla.columna" que son clave.
export function keyColumns() {
  const cons = load('constraints.json');
  const idx = load('indexes.json');
  const keys = new Set();
  const add = (s, t, list) => splitCols(list).forEach((c) => keys.add(`${s}.${t}.${unq(c.replace(/ (ASC|DESC).*$/, ''))}`));
  for (const c of cons) {
    const m = c.def.match(/^(?:PRIMARY KEY|UNIQUE|FOREIGN KEY) \(([^)]*)\)/);
    if (m) add(c.schema, c.tbl, m[1]);
  }
  for (const i of idx) {
    const m = i.def.match(/USING btree \((.*?)\)(?: INCLUDE| WHERE|$)/);
    if (!m) continue;
    const cols = splitCols(m[1]);
    if (cols.every((c) => /^("[^"]+"|[a-z_][a-z0-9_]*)( (ASC|DESC))?( NULLS (FIRST|LAST))?$/.test(c))) add(i.schema, i.tbl, m[1]);
  }
  return keys;
}

if (process.argv[1] === new URL(import.meta.url).pathname) {
  const cols = load('columns.json');
  const keys = keyColumns();
  const txt = cols.filter((c) => keys.has(`${c.schema}.${c.tbl}.${c.col}`) && /^(text|character varying)/.test(c.type));
  const rel = Object.fromEntries(load('relations.json').map((r) => [`${r.schema}.${r.tbl}`, r]));
  const byT = {};
  for (const c of txt) (byT[`${c.schema}.${c.tbl}`] ||= []).push(c.col);
  // Tablas > 1 GB: muestreo del 10% para no cargar producción (el largo resultante es aproximado).
  const parts = Object.entries(byT).map(([t, cs]) => {
    const [s, n] = t.split('.');
    const big = Number(rel[t]?.bytes) > 2 ** 30;
    const obj = cs.map((c) => `'${c}', max(length("${c}"))`).join(', ');
    return `select '${t}' t, ${big} sampled, json_build_object(${obj}) m from ${s}."${n}"${big ? ' tablesample system (10)' : ''}`;
  });
  console.log(parts.join(' union all '));
}
