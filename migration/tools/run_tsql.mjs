// Ejecuta los scripts de migration/target contra Azure SQL, en orden y lote por lote (separador GO).
// Se detiene en el primer error. Los scripts son idempotentes, así que se puede volver a correr.
//
// Credenciales (nunca en código): AZURE_SQL_SERVER, AZURE_SQL_DB, AZURE_SQL_USER, AZURE_SQL_PASSWORD.
// Se leen del entorno o de migration/.env (ignorado por git).
//
// Uso:
//   npm run db:plan                      # lista lo que se ejecutaría, sin conectarse
//   npm run db:apply                     # ejecuta todos los archivos
//   npm run db:apply -- 000 001          # solo archivos cuyo nombre empieza con 000 o 001
import fs from 'node:fs';
import path from 'node:path';

const ROOT = path.join(path.dirname(new URL(import.meta.url).pathname), '..');
const TARGET = path.join(ROOT, 'target');
const args = process.argv.slice(2);
const dryRun = args.includes('--dry-run');
const only = args.filter((a) => !a.startsWith('--'));

const envFile = path.join(ROOT, '.env');
if (fs.existsSync(envFile)) {
  for (const line of fs.readFileSync(envFile, 'utf8').split('\n')) {
    const m = line.match(/^\s*([A-Z_][A-Z0-9_]*)\s*=\s*(.*?)\s*$/);
    if (m && !(m[1] in process.env)) process.env[m[1]] = m[2].replace(/^["']|["']$/g, '');
  }
}

export function splitBatches(sql) {
  return sql.split(/^\s*GO\s*$/im).map((b) => b.trim()).filter((b) => b && !/^(--[^\n]*\n?)+$/.test(b));
}

const files = fs.readdirSync(TARGET).filter((f) => /^\d{3}_.*\.sql$/.test(f)).sort()
  .filter((f) => !only.length || only.some((o) => f.startsWith(o)));
const plan = files.map((f) => ({ f, batches: splitBatches(fs.readFileSync(path.join(TARGET, f), 'utf8')) }));

if (dryRun) {
  for (const { f, batches } of plan) console.log(`${f}: ${batches.length} lotes`);
  console.log(`Total: ${plan.reduce((a, p) => a + p.batches.length, 0)} lotes en ${plan.length} archivos (no se ejecutó nada).`);
  process.exit(0);
}

const need = ['AZURE_SQL_SERVER', 'AZURE_SQL_DB', 'AZURE_SQL_USER', 'AZURE_SQL_PASSWORD'].filter((k) => !process.env[k]);
if (need.length) {
  console.error(`Faltan variables de entorno: ${need.join(', ')}`);
  process.exit(1);
}

const sql = (await import('mssql')).default;
const pool = await sql.connect({
  server: process.env.AZURE_SQL_SERVER,
  database: process.env.AZURE_SQL_DB,
  user: process.env.AZURE_SQL_USER,
  password: process.env.AZURE_SQL_PASSWORD,
  options: { encrypt: true, trustServerCertificate: false },
  requestTimeout: 300000,
  connectionTimeout: 30000,
});
const who = await pool.request().query(
  "SELECT DB_NAME() AS db, CONVERT(sysname, DATABASEPROPERTYEX(DB_NAME(), 'Collation')) AS collation, @@VERSION AS version");
console.log(`Conectado a ${who.recordset[0].db} (${who.recordset[0].collation})`);

let n = 0;
try {
  for (const { f, batches } of plan) {
    process.stdout.write(`${f} (${batches.length} lotes) ... `);
    for (const [ix, b] of batches.entries()) {
      try {
        await pool.request().batch(b);
        n++;
      } catch (e) {
        console.error(`\nERROR en ${f}, lote ${ix + 1}:\n${b.slice(0, 600)}\n\n${e.message}`);
        process.exitCode = 1;
        throw e;
      }
    }
    console.log('ok');
  }
  console.log(`Listo: ${n} lotes ejecutados.`);
} catch {
  console.error(`Se detuvo después de ${n} lotes correctos. Corrige y vuelve a correr (los scripts son idempotentes).`);
} finally {
  await pool.close();
}
