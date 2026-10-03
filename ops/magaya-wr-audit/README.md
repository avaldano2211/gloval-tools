# Auditoría diaria Magaya — Agente de destino en WRs

Revisa los Warehouse Receipts de Magaya Miami (últimos `lookbackDays` días) y alerta por
Outlook cuando un WR cuyo consignee coincide con una regla **no** tiene el agente de destino
correcto (por eso Magaya Ecuador no lo ve).

Reglas actuales (`rules.json`):

| Regla | Si el consignee contiene… | Debe cumplir |
|---|---|---|
| ILGUECORP | `ILGUECORP` | Agente destino contiene `GLOVAL ECUADOR` |
| ANGLO | `ANGLO` | Agente destino contiene `GLOVAL ECUADOR` |
| Sigman | `JUAN VAYAS` o `MARIA BEATRIZ` | Consignee contiene `SIGMAN` |

Cada regla tiene `match` (cuándo aplica) y `expect` (qué debe tener). Campos disponibles:
`consignee`, `destinationAgent`, `shipper`. La comparación ignora mayúsculas y tildes.

## Alerta de storage (30 días libres)

Además de las reglas, el reporte incluye los WRs que siguen en bodega (`OnHand`, `InProcess`) y:
- **Por vencer**: les faltan 5 días o menos para cumplir los 30 días libres.
- **Generando storage**: pasaron el día 30, con los meses de storage acumulados.

Se cuentan los días desde la fecha del WR (`CreatedOn`) y se revisan hasta 400 días atrás.
Se configura en `rules.json` → `storage`. No calcula montos porque la tarifa varía por cliente.

## Ejecutar

```bash
node ops/magaya-wr-audit/audit.mjs --file ops/magaya-wr-audit/sample.xml   # prueba local, sin API
node ops/magaya-wr-audit/audit.mjs --dry-run                               # API real, sin email
node ops/magaya-wr-audit/audit.mjs                                         # API real + email
```

Programado en `.github/workflows/magaya-wr-audit.yml` (lun–vie 07:45 hora Ecuador).
Si falla (API caída, formato XML distinto), el job queda en rojo — no falla en silencio.

## Variables / secrets

| Variable | Descripción |
|---|---|
| `MAGAYA_API_URL` | Endpoint SOAP, ej. `http://<host>:<puerto>/CSSoapService` |
| `MAGAYA_USER` / `MAGAYA_PASS` | Usuario de Magaya con acceso de lectura a WRs |
| `MAGAYA_FLAGS` | Opcional, flags de `GetTransRangeByDate` (default `0`) |
| `GRAPH_TENANT_ID` / `GRAPH_CLIENT_ID` / `GRAPH_CLIENT_SECRET` | App de Azure con permiso de aplicación `Mail.Send` |
| `ALERT_FROM` | Buzón que envía (ej. `alertas@...`) |
| `ALERT_TO` | Destinatarios separados por coma |

## Pendiente de validar con el servidor real

- Nombres de método/parámetros SOAP (`StartSession`, `GetTransRangeByDate`, `trans_list_xml`) contra el WSDL del servidor.
- Nombres de campos en el XML del WR (`ConsigneeName`/`Consignee/Name`, `DestinationAgentName`/`DestinationAgent/Name`, `Status`). Ajustar en `parseReceipts()` si difieren.
- Que `CreatedOn` sea la fecha de ingreso a bodega y que los status de bodega se llamen `OnHand`/`InProcess` en el XML.
- Que el servidor Magaya sea accesible desde internet (GitHub Actions). Si está detrás de firewall, correr el script en un PC/servidor de la oficina con el Programador de tareas.
