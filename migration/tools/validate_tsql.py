# Validación sintáctica (no semántica) del DDL generado, con el parser T-SQL de sqlglot.
# Uso (desde la raíz del repo): pip install sqlglot && python3 migration/tools/validate_tsql.py
# Nota: sqlglot no reconoce THROW; ese fallo en 000_database.sql es esperado.
import glob, re, sys, sqlglot
from sqlglot.errors import ParseError
fails = 0; total = 0; kinds = {}
for f in sorted(glob.glob('migration/target/*.sql')):
    for b in re.split(r'^\s*GO\s*$', open(f).read(), flags=re.M):
        b = re.sub(r'^--.*$', '', b, flags=re.M).strip()
        if not b: continue
        total += 1
        try:
            sqlglot.parse(b, read='tsql', error_level=sqlglot.ErrorLevel.RAISE)
        except Exception as e:
            fails += 1
            msg = str(e).split('\n')[0][:120]
            kinds.setdefault(msg[:60], []).append((f, b[:160].replace('\n',' ')))
print('lotes:', total, 'fallos de parseo:', fails)
for k, v in sorted(kinds.items(), key=lambda x: -len(x[1])):
    print(f'\n[{len(v)}] {k}\n   ej: {v[0][0]}: {v[0][1]}')
