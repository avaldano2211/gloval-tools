// Extrae el array JSON de un resultado guardado del MCP de Supabase.
// Uso: node parse.mjs <archivo> > salida.json
import fs from 'node:fs';
const raw = JSON.parse(fs.readFileSync(process.argv[2], 'utf8')).result;
const m = raw.match(/<untrusted-data-[\w-]+>\n([\s\S]*)\n<\/untrusted-data-[\w-]+>/);
if (!m) throw new Error('formato inesperado');
process.stdout.write(JSON.stringify(JSON.parse(m[1])));
