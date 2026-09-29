# Inventario de GES (Supabase → Azure SQL)

> Generado el 2026-09-29 desde el catálogo de `wfzdrqfurwnakrfdnbgf` (solo SELECT). Filas = máx(n_live_tup, reltuples), **aproximadas**; para las tablas que las estadísticas daban en 0 se usó count(*) exacto (`source/catalog/exact_counts_2026-09-29.json`). El módulo se asigna por prefijo (CLAUDE.md §3.3) y **hay que validarlo**. "¿Migra?" aplica la decisión del 29-sep: fuera las tablas vacías y las temporales.

## Resumen

| Objeto | Cantidad |
|---|---|
| Tablas `public` | 301 |
| Tablas `archive` | 1 |
| Tablas `private` | 13 |
| Tablas `timeclock` | 4 |
| Vistas (public: 88, archive: 1, private: 2, timeclock: 0) | 91 |
| Vistas materializadas | 33 |
| Funciones/procedimientos propios | 330 (más 7 que vienen de extensiones y no se exportan) |
| Triggers | 102 |
| Políticas RLS | 564 |
| Enums propios | 35 |
| Índices (sin PK/UNIQUE) | 624 |
| Cron jobs | 49 (48 activos) |
| Tamaño total de las tablas (con índices y TOAST) | 10.02 GB |

**Diferencias con CLAUDE.md §3.1:** hay 330 funciones propias más 7 de extensiones, que suman las 337 del documento. Políticas: 564 (el documento dice 563; no verifiqué la causa de la diferencia). Hay 35 enums propios; el catálogo tiene 48 en total contando `auth`, `storage`, etc.

## Por módulo

| Módulo | Tablas | Vacías | Filas aprox. | Tamaño |
|---|---|---|---|---|
| Market intelligence | 6 | 0 | 5,099,019 | 7.40 GB |
| Integración Magaya | 35 | 3 | 2,180,535 | 2.14 GB |
| Esquema archive | 1 | 0 | 185,502 | 155.1 MB |
| Operaciones | 34 | 4 | 89,944 | 90.5 MB |
| Finanzas | 27 | 3 | 171,791 | 85.5 MB |
| Bodega Miami | 44 | 4 | 29,171 | 47.3 MB |
| Seguridad y usuarios | 10 | 0 | 125,898 | 44.0 MB |
| Tarifas | 32 | 3 | 51,315 | 14.1 MB |
| Consolidados | 17 | 1 | 15,530 | 13.8 MB |
| Esquema private | 2 | 0 | 4,520 | 12.0 MB |
| CRM y ventas | 34 | 6 | 26,287 | 11.7 MB |
| Christmas Palace | 9 | 2 | 4,082 | 4.2 MB |
| Catálogos | 20 | 1 | 2,502 | 4.0 MB |
| Comisiones | 11 | 1 | 9,642 | 3.4 MB |
| Dashboards y reportes | 7 | 0 | 23,632 | 2.5 MB |
| Temporal / respaldo | 16 | 0 | 9,242 | 2.1 MB |
| Otros | 10 | 1 | 280 | 1.3 MB |
| Esquema timeclock | 4 | 0 | 310 | 384 KB |

## Alertas para la migración

- **Tablas en `public` sin RLS** (2), expuestas a la anon key: `brief_emitido`, `caja_eod`.
- **RLS activo pero sin políticas** (15); solo las ve service_role: `public._cartera_ecu_20260908`, `public._marcia_retardos_20260904`, `public._q`, `public.arap_live_snapshot`, `public.cierres_liquidacion`, `public.cl_container_types`, `public.market_indices_daily`, `public.pba_authorized_users`, `public.sales_doc_counters`, `public.shipco_settings`, `public.ventas_alertas`, `public.ventas_congelado`, `public.wh_containers_external`, `public.wh_whr_backfill_universo`, `public.wr_backfill_queue`.
- **Tablas sin PK** (18). Hay que definir la clave antes de cargarlas a SQL Server: `private._audit_billing_ec_2026q1`, `private._audit_billing_ruc`, `private._audit_clients_ec`, `private._audit_clients_ec_ruc`, `private.cifras_sem31`, `private.client_merge_survivor_snapshot`, `private.closings_bak_peru_janfeb_20260804`, `private.consolidado_avisos_bak_27jul`, `private.respaldo_estiba_sem31`, `private.tmp_excel2_diff`, `public._cartera_ecu_20260908`, `public._marcia_retardos_20260904`, `public._q`, `public.dashboard_agents`, `public.dashboard_clients`, `public.dashboard_countries`, `public.dashboard_monthly_client`, `public.dashboard_pnl_flow`.
- **Tablas vacías** (29, count exacto). No se migran.
- **La anon key está escrita en 23 cron jobs y en 1 función** (`trg_credit_request_approved_notify`). En Azure debe ir en Key Vault o en app settings.

## Tipos de columna usados (para mapear a T-SQL)

| Tipo Postgres | Columnas | Destino sugerido (§5) |
|---|---|---|
| `text` | 1803 | NVARCHAR(MAX) / NVARCHAR(n) |
| `uuid` | 716 | UNIQUEIDENTIFIER |
| `timestamp with time zone` | 522 | DATETIMEOFFSET |
| `numeric` | 430 | DECIMAL(p,s) |
| `integer` | 274 | INT |
| `boolean` | 208 | BIT |
| `date` | 158 | DATE |
| `jsonb` | 67 | NVARCHAR(MAX) + ISJSON |
| `character varying` | 50 | NVARCHAR(n) |
| `bigint` | 24 | BIGINT |
| `text[]` | 21 | tabla hija o JSON |
| `double precision` | 9 | FLOAT |
| `smallint` | 2 | SMALLINT |
| `mi_modality_t` | 2 | CHECK o tabla catálogo (enum) |
| `mi_match_method_t` | 2 | CHECK o tabla catálogo (enum) |
| `pba_status_t` | 2 | CHECK o tabla catálogo (enum) |
| `cl_task_status` | 2 | CHECK o tabla catálogo (enum) |
| `interval` | 1 | (sin equivalente: segundos en INT/BIGINT) |
| `cl_alert_kind` | 1 | CHECK o tabla catálogo (enum) |
| `cl_alert_status` | 1 | CHECK o tabla catálogo (enum) |
| `scan_result` | 1 | CHECK o tabla catálogo (enum) |
| `loading_exception_type` | 1 | CHECK o tabla catálogo (enum) |
| `loading_task_status` | 1 | CHECK o tabla catálogo (enum) |
| `cl_item_type` | 1 | CHECK o tabla catálogo (enum) |
| `pick_item_status` | 1 | CHECK o tabla catálogo (enum) |
| `staging_item_status` | 1 | CHECK o tabla catálogo (enum) |
| `load_item_status` | 1 | CHECK o tabla catálogo (enum) |
| `manifest_source_type` | 1 | CHECK o tabla catálogo (enum) |
| `mi_actor_type_t` | 1 | CHECK o tabla catálogo (enum) |
| `mi_etl_status_t` | 1 | CHECK o tabla catálogo (enum) |
| `mi_match_status_t` | 1 | CHECK o tabla catálogo (enum) |
| `mi_origin_partner_t` | 1 | CHECK o tabla catálogo (enum) |
| `ops_doc_type_t` | 1 | CHECK o tabla catálogo (enum) |
| `ops_doc_status_t` | 1 | CHECK o tabla catálogo (enum) |
| `ops_status_t` | 1 | CHECK o tabla catálogo (enum) |
| `picking_exception_type` | 1 | CHECK o tabla catálogo (enum) |
| `picking_task_type` | 1 | CHECK o tabla catálogo (enum) |
| `equipment_type` | 1 | CHECK o tabla catálogo (enum) |
| `event_source_t` | 1 | CHECK o tabla catálogo (enum) |
| `shipment_mode_t` | 1 | CHECK o tabla catálogo (enum) |
| `shipment_direction_t` | 1 | CHECK o tabla catálogo (enum) |
| `shipment_status_t` | 1 | CHECK o tabla catálogo (enum) |
| `ops_via_origen_t` | 1 | CHECK o tabla catálogo (enum) |
| `ops_equipment_t` | 1 | CHECK o tabla catálogo (enum) |
| `ops_destino_t` | 1 | CHECK o tabla catálogo (enum) |
| `staging_exception_type` | 1 | CHECK o tabla catálogo (enum) |
| `warehouse_role[]` | 1 | **revisar** |
| `warehouse_cert[]` | 1 | **revisar** |
| `wr_match_status_t` | 1 | CHECK o tabla catálogo (enum) |

## Cron jobs (a reemplazar por Azure Functions Timer)

| # | Nombre | Schedule | Activo | Tipo | Runs 7d | Fallos 7d |
|---|---|---|---|---|---|---|
| 2 | `expire-agent-rates-daily` | `0 0 * * *` | sí | HTTP → edge fn `expire-agent-rates` | 7 | 0 |
| 4 | `magaya-sync-cargo-releases` | `0 8,18 * * *` | sí | HTTP → edge fn `magaya-incremental-sync` | 14 | 0 |
| 5 | `magaya-sync-warehouse-receipts` | `*/5 * * * *` | sí | HTTP → edge fn `magaya-incremental-sync` | 2000 | 0 |
| 6 | `send-birthday-emails-daily` | `0 9 * * *` | sí | HTTP → edge fn `send-birthday-emails` | 7 | 0 |
| 9 | `mi-match-and-refresh-daily` | `0 9 * * *` | sí | SQL | 7 | 0 |
| 10 | `mi-refresh-mvs-afternoon` | `15 23 * * *` | sí | SQL | 7 | 0 |
| 11 | `smoke-test-sales-exec-create-client` | `55 7 * * *` | sí | SQL | 7 | 0 |
| 13 | `refresh-wh-metrics-am` | `45 8 * * *` | sí | SQL | 7 | 0 |
| 14 | `refresh-wh-metrics-pm` | `0 23 * * *` | sí | SQL | 7 | 0 |
| 16 | `weekly-wh-report` | `0 9 * * 1` | sí | HTTP → edge fn `wh-report` | 1 | 0 |
| 17 | `monday-containers-sync-daily` | `30 9 * * *` | sí | HTTP → edge fn `monday-containers-sync` | 7 | 0 |
| 20 | `monthly-wh-report` | `0 10 1 * *` | sí | HTTP → edge fn `wh-report` | 0 | 0 |
| 21 | `weekly-stations-report` | `15 9 * * 1` | sí | HTTP → edge fn `wh-stations-report` | 1 | 0 |
| 22 | `magaya-usa-ec-daily` | `0 8 * * *` | sí | HTTP → edge fn `magaya-usa-sync` | 7 | 0 |
| 23 | `monday-external-containers-sync-daily` | `35 9 * * *` | sí | HTTP → edge fn `monday-external-containers-sync` | 7 | 0 |
| 24 | `sales-quotes-expire` | `5 10 * * *` | sí | SQL | 7 | 0 |
| 25 | `magaya-wr-rescan-daily` | `45 9 * * *` | sí | HTTP → edge fn `magaya-incremental-sync` | 7 | 0 |
| 26 | `sales-quote-followups-daily` | `15 13 * * *` | sí | HTTP → edge fn `sales-quote-followups` | 7 | 0 |
| 27 | `fx-rates-banco-pacifico` | `30 12,15 * * *` | sí | HTTP → edge fn `fx-rates-sync` | 14 | 0 |
| 28 | `sync-health-alert-daily` | `0 13 * * *` | sí | HTTP → edge fn `sync-health-alert` | 7 | 0 |
| 29 | `ops-eta-notify-daily` | `30 13 * * *` | no | HTTP → edge fn `ops-eta-notify` | 0 | 0 |
| 30 | `wh-notice-builder-scan` | `*/4 * * * *` | sí | HTTP → edge fn `wh-notice-scan-worker` | 2492 | 0 |
| 32 | `wh-storage-alert-daily` | `30 13 * * 1-5` | sí | HTTP → edge fn `wh-storage-alert` | 5 | 0 |
| 33 | `wh-onhand-verify-critico` | `*/3 * * * *` | sí | HTTP → edge fn `wh-onhand-verify` | 3330 | 0 |
| 34 | `wh-onhand-verify-resto` | `7,22,37,52 * * * *` | sí | HTTP → edge fn `wh-onhand-verify` | 665 | 0 |
| 35 | `ops-email-capture-loop` | `*/20 * * * *` | sí | HTTP → edge fn `ops-email-capture` | 497 | 0 |
| 36 | `wr-enrich-frescos` | `1-59/5 * * * *` | sí | HTTP → edge fn `wh-onhand-verify` | 1995 | 0 |
| 37 | `consolidado-refresh-abierto` | `9,24,39,54 * * * *` | sí | SQL | 665 | 0 |
| 38 | `wr-refetch-recien-creados` | `3-59/10 * * * *` | sí | HTTP → edge fn `wh-onhand-verify` | 1001 | 0 |
| 39 | `wh-no-identificada-registro` | `13,43 * * * *` | sí | SQL | 336 | 0 |
| 40 | `wr-att-backfill-drain` | `*/2 * * * *` | sí | HTTP → edge fn `wr-att-backfill-worker` | 4989 | 0 |
| 41 | `wh-notice-refresh-attachments` | `*/5 * * * *` | sí | HTTP → edge fn `wh-notice-builder` | 2000 | 0 |
| 42 | `wh-saldo-backfill` | `*/2 * * * *` | sí | HTTP → edge fn `wh-saldo-backfill-worker` | 4989 | 0 |
| 44 | `seaboard-advisory-watch` | `15 8 * * *` | sí | HTTP → edge fn `seaboard-advisory-watch` | 7 | 0 |
| 45 | `wh-saldo-reencolar` | `20 7 * * *` | sí | SQL | 7 | 0 |
| 46 | `wh-notice-refresh-cola-larga` | `15,45 * * * *` | sí | HTTP → edge fn `wh-notice-builder` | 336 | 0 |
| 47 | `wh-notice-rebody` | `*/10 * * * *` | sí | HTTP → edge fn `wh-notice-builder` | 999 | 0 |
| 49 | `purge-cron-history` | `10 6 * * 0` | sí | SQL | 1 | 0 |
| 51 | `wh-recientes-refresco-completo` | `3,33 * * * *` | sí | SQL | 336 | 0 |
| 52 | `finanzas-refresh-mv-unified` | `*/10 5-23 * * *` | sí | SQL | 789 | 0 |
| 53 | `finanzas-refresh-mv-arap` | `*/10 * * * *` | sí | SQL | 999 | 0 |
| 54 | `finanzas-matching-diario` | `30 11 * * *` | sí | SQL | 7 | 0 |
| 57 | `finanzas-refresh-mv-docs` | `5-59/10 * * * *` | sí | SQL | 1001 | 0 |
| 59 | `consolidado-refresco-magaya-instruidas` | `*/15 * * * *` | sí | SQL | 670 | 0 |
| 62 | `magaya-wr-rellenar-huecos` | `7,27,47 * * * *` | sí | SQL | 497 | 0 |
| 63 | `magaya-wr-rescan-daily-b` | `55 9 * * *` | sí | HTTP → edge fn `magaya-incremental-sync` | 7 | 0 |
| 65 | `consolidado-avisos-autoregenerar` | `12,27,42,57 * * * *` | sí | SQL | 665 | 0 |
| 66 | `consolidado-sync-magaya-confirmadas` | `7,22,37,52 * * * *` | sí | SQL | 665 | 0 |
| 67 | `mi-refresh-forwarder-detail` | `45 23 * * *` | sí | SQL | 1 | 0 |

## Vistas materializadas (33)

En SQL Server no existen. Opciones: indexed view (con restricciones) o una tabla de resumen que refresque un job.

`public.mi_mv_carrier_share`, `public.mi_mv_client_period_summary`, `public.mi_mv_company_profile`, `public.mi_mv_courier_company`, `public.mi_mv_courier_country`, `public.mi_mv_courier_liberador`, `public.mi_mv_courier_summary`, `public.mi_mv_direct_cargo_prospects`, `public.mi_mv_foreign_agents`, `public.mi_mv_forwarder_commodity`, `public.mi_mv_forwarder_detail`, `public.mi_mv_forwarder_share`, `public.mi_mv_forwarder_share_geo`, `public.mi_mv_import_base`, `public.mi_mv_market_top_players`, `public.mi_mv_partner_network`, `public.mi_mv_product_client_fwd`, `public.mi_mv_product_month`, `public.mi_mv_product_summary`, `public.mi_mv_route_ec_zones`, `public.mi_mv_route_origin_ports`, `public.mi_mv_route_port_options`, `public.mi_mv_unassigned_prospects`, `public.mi_v_client_wallet_share`, `public.mi_v_executive_scorecard`, `public.mi_v_lost_cargo`, `public.mv_consignee_top_agent`, `public.mv_entity_ar_ap`, `public.mv_finanzas_docs_abiertos`, `public.mv_shipper_top_consignee`, `public.mv_wh_container_metrics`, `public.mv_wh_metrics`, `public.v_magaya_invoices_unified`

## Detalle por tabla

FK→ = tablas a las que apunta. ←FK = número de tablas que la referencian.

### Market intelligence

| Tabla | Filas aprox. | Tamaño | PK | RLS / pol. | Trg | FK→ | ←FK | ¿Migra? |
|---|---|---|---|---|---|---|---|---|
| `mi_shipment_intel` | 2,855,530 | 5.59 GB | sí | sí / 2 | 3 | mi_canonical_actor, clients, mi_etl_run | 0 | Sí |
| `mi_courier_shipment` | 2,217,241 | 1.79 GB | sí | sí / 1 | 0 |  | 0 | Sí |
| `mi_actor_alias` | 13,583 | 9.0 MB | sí | sí / 2 | 0 | mi_canonical_actor | 0 | Sí |
| `mi_canonical_actor` | 12,400 | 3.9 MB | sí | sí / 2 | 1 |  | 2 | Sí |
| `mi_match_review_queue` | 261 | 792 KB | sí | sí / 2 | 1 | users, clients | 0 | Sí |
| `mi_etl_run` | 4 | 96 KB | sí | sí / 2 | 0 | users | 1 | Sí |

### Integración Magaya

| Tabla | Filas aprox. | Tamaño | PK | RLS / pol. | Trg | FK→ | ←FK | ¿Migra? |
|---|---|---|---|---|---|---|---|---|
| `magaya_transactions` | 689,562 | 1.42 GB | sí | sí / 3 | 2 | magaya_companies | 1 | Sí |
| `magaya_warehouse_receipts` | 220,104 | 253.1 MB | sí | sí / 1 | 4 | magaya_companies | 4 | Sí |
| `magaya_transaction_charges` | 688,543 | 177.2 MB | sí | sí / 3 | 0 | magaya_companies, magaya_transactions | 0 | Sí |
| `magaya_payment_application` | 207,321 | 59.2 MB | sí | sí / 2 | 0 |  | 0 | Sí |
| `wr_match_results` | 28,730 | 56.8 MB | sí | sí / 2 | 1 | clients, shipments, users, magaya_warehouse_receipts | 0 | Sí |
| `magaya_wr_items` | 74,672 | 37.4 MB | sí | sí / 1 | 4 | magaya_companies, magaya_warehouse_receipts | 1 | Sí |
| `magaya_entities` | 28,405 | 31.7 MB | sí | sí / 1 | 1 | magaya_companies | 0 | Sí |
| `magaya_bills` | 43,950 | 27.3 MB | sí | sí / 1 | 0 | magaya_companies | 0 | Sí |
| `magaya_invoices` | 28,472 | 22.6 MB | sí | sí / 1 | 0 | magaya_companies | 0 | Sí |
| `magaya_wr_attachments` | 35,350 | 13.0 MB | sí | sí / 2 | 0 | users, magaya_warehouse_receipts | 0 | Sí |
| `magaya_charges_extracted` | 19,551 | 10.3 MB | sí | sí / 2 | 0 |  | 0 | Sí |
| `magaya_journal_entry_lines` | 17,596 | 8.7 MB | sí | sí / 1 | 0 | magaya_companies, magaya_journal_entries | 0 | Sí |
| `magaya_clients` | 12,937 | 7.8 MB | sí | sí / 1 | 0 | magaya_companies | 0 | Sí |
| `magaya_cargo_releases` | 15,442 | 7.1 MB | sí | sí / 1 | 0 | magaya_companies | 2 | Sí |
| `magaya_shipments` | 6,696 | 5.7 MB | sí | sí / 1 | 0 | magaya_companies | 1 | Sí |
| `magaya_vendor_payments` | 4,716 | 5.5 MB | sí | sí / 1 | 0 | magaya_companies | 0 | Sí |
| `magaya_pickup_orders` | 6,872 | 4.1 MB | sí | sí / 1 | 0 | magaya_companies | 0 | Sí |
| `magaya_status_overrides` | 17,916 | 4.0 MB | sí | sí / 2 | 0 |  | 0 | Sí |
| `wr_saldo_queue` | 19,182 | 3.8 MB | sí | sí / 1 | 0 |  | 0 | Sí |
| `magaya_journal_entries` | 4,895 | 2.6 MB | sí | sí / 1 | 0 | magaya_companies | 1 | Sí |
| `wr_att_backfill_queue` | 6,033 | 2.0 MB | sí | sí / 1 | 0 |  | 0 | Sí |
| `magaya_entity_balance` | 737 | 496 KB | sí | sí / 2 | 0 |  | 0 | Sí |
| `magaya_sync_log` | 565 | 496 KB | sí | sí / 1 | 0 | magaya_companies | 0 | Sí |
| `magaya_usa_shipments` | 623 | 440 KB | sí | sí / 1 | 0 | magaya_usa_shipments | 1 | Sí |
| `ar_ap_sync_queue` | 630 | 432 KB | sí | sí / 2 | 0 |  | 0 | Sí |
| `magaya_accounts` | 278 | 192 KB | sí | sí / 1 | 1 | magaya_companies | 0 | Sí |
| `magaya_balance_override` | 239 | 144 KB | sí | sí / 2 | 0 |  | 0 | Sí |
| `magaya_charge_definitions` | 168 | 104 KB | sí | sí / 1 | 1 | magaya_companies | 0 | Sí |
| `wr_backfill_queue` | 338 | 88 KB | sí | sí / 0 | 0 |  | 0 | Sí |
| `magaya_sync_state` | 6 | 80 KB | sí | sí / 1 | 0 | magaya_companies | 0 | Sí |
| `magaya_cr_items` | 0 | 64 KB | sí | sí / 1 | 1 | magaya_companies, magaya_cargo_releases | 0 | No (vacía) |
| `magaya_companies` | 4 | 48 KB | sí | sí / 1 | 1 |  | 23 | Sí |
| `magaya_currencies` | 2 | 48 KB | sí | sí / 1 | 1 | magaya_companies | 0 | Sí |
| `magaya_inventory` | 0 | 40 KB | sí | sí / 1 | 0 | magaya_companies | 0 | No (vacía) |
| `magaya_event_definitions` | 0 | 24 KB | sí | sí / 1 | 0 | magaya_companies | 0 | No (vacía) |

### Esquema archive

| Tabla | Filas aprox. | Tamaño | PK | RLS / pol. | Trg | FK→ | ←FK | ¿Migra? |
|---|---|---|---|---|---|---|---|---|
| `archive.magaya_charges` | 185,502 | 155.1 MB | sí | sí / 1 | 0 | magaya_companies | 0 | Sí |

### Operaciones

| Tabla | Filas aprox. | Tamaño | PK | RLS / pol. | Trg | FK→ | ←FK | ¿Migra? |
|---|---|---|---|---|---|---|---|---|
| `ops_inbound_emails` | 69,617 | 77.8 MB | sí | sí / 1 | 0 | shipments, users | 0 | Sí |
| `ops_documents` | 7,261 | 3.8 MB | sí | sí / 4 | 0 | users, shipments | 1 | Sí |
| `shipment_events` | 4,474 | 2.6 MB | sí | sí / 3 | 0 | users, shipments | 0 | Sí |
| `shipments` | 1,681 | 1.8 MB | sí | sí / 3 | 5 | users, clients, consolidados, magaya_shipments, shipments | 23 | Sí |
| `shipping_instructions` | 818 | 672 KB | sí | sí / 3 | 1 | clients, users, quotes, shipments | 2 | Sí |
| `shipment_action_items` | 2,129 | 664 KB | sí | sí / 4 | 0 | users, shipments | 0 | Sí |
| `ops_hbl` | 227 | 432 KB | sí | sí / 3 | 0 | users, ops_master, shipments | 0 | Sí |
| `liq_settlement_lines` | 1,058 | 368 KB | sí | sí / 1 | 1 | liq_charge_catalog, liq_settlements | 0 | Sí |
| `shipment_shippers` | 946 | 272 KB | sí | sí / 1 | 1 | users, shipments | 0 | Sí |
| `shipment_agents` | 776 | 248 KB | sí | sí / 1 | 1 | users, shipments | 0 | Sí |
| `liq_settlements` | 100 | 240 KB | sí | sí / 1 | 0 | liq_shipments | 1 | Sí |
| `coordination_tasks` | 81 | 216 KB | sí | sí / 2 | 1 | users, clients, shipments | 0 | Sí |
| `shipment_containers` | 562 | 216 KB | sí | sí / 1 | 4 | users, shipments | 1 | Sí |
| `liq_shipments` | 64 | 192 KB | sí | sí / 1 | 0 |  | 2 | Sí |
| `carrier_email_log` | 2 | 96 KB | sí | sí / 2 | 0 | shipments | 0 | Sí |
| `ops_master` | 5 | 96 KB | sí | sí / 3 | 0 | users | 1 | Sí |
| `container_load_reports` | 2 | 80 KB | sí | sí / 2 | 0 | warehouse_users, loading_tasks, manifest_sources | 0 | Sí |
| `dispatches` | 0 | 64 KB | sí | sí / 1 | 1 | clients | 0 | No (vacía) |
| `external_containers` | 0 | 64 KB | sí | sí / 1 | 1 | clients | 0 | No (vacía) |
| `fcl_semanal` | 1 | 64 KB | sí | sí / 2 | 1 | clients, shipments | 0 | Sí |
| `ops_devolucion_vacios` | 10 | 64 KB | sí | sí / 2 | 1 | shipment_containers, shipments | 0 | Sí |
| `ops_transfers` | 24 | 64 KB | sí | sí / 2 | 1 | users, shipments | 0 | Sí |
| `container_files` | 0 | 56 KB | sí | sí / 1 | 0 | warehouse_containers | 0 | No (vacía) |
| `fact_orders` | 2 | 48 KB | sí | sí / 2 | 0 | clients, users, shipments, shipping_instructions | 0 | Sí |
| `liq_agent_invoice_lines` | 9 | 48 KB | sí | sí / 1 | 0 | liq_agent_invoices | 0 | Sí |
| `liq_agent_invoices` | 4 | 48 KB | sí | sí / 1 | 0 |  | 1 | Sí |
| `liq_tariffs` | 19 | 48 KB | sí | sí / 1 | 0 | liq_charge_catalog | 0 | Sí |
| `ops_client_notices` | 2 | 48 KB | sí | sí / 1 | 0 | shipments | 0 | Sí |
| `ops_release` | 1 | 48 KB | sí | sí / 3 | 0 | users, ops_documents, shipments | 0 | Sí |
| `cierres_liquidacion` | 13 | 32 KB | sí | sí / 0 | 0 |  | 0 | Sí |
| `liq_charge_catalog` | 40 | 32 KB | sí | sí / 1 | 0 |  | 2 | Sí |
| `ops_capture_mailboxes` | 15 | 32 KB | sí | sí / 1 | 0 |  | 0 | Sí |
| `ops_hbl_sequence` | 1 | 32 KB | sí | sí / 1 | 0 |  | 0 | Sí |
| `liq_documents` | 0 | 16 KB | sí | sí / 1 | 0 | liq_shipments | 0 | No (vacía) |

### Finanzas

| Tabla | Filas aprox. | Tamaño | PK | RLS / pol. | Trg | FK→ | ←FK | ¿Migra? |
|---|---|---|---|---|---|---|---|---|
| `cash_movement` | 146,181 | 74.4 MB | sí | sí / 2 | 0 |  | 0 | Sí |
| `bank_transaction` | 8,120 | 3.8 MB | sí | sí / 2 | 0 |  | 1 | Sí |
| `finanzas_bank_match` | 7,813 | 2.7 MB | sí | sí / 3 | 0 | bank_transaction, offices | 0 | Sí |
| `arap_live_open` | 5,345 | 1.7 MB | sí | sí / 1 | 0 |  | 0 | Sí |
| `closings` | 2,943 | 1.2 MB | sí | sí / 4 | 0 | clients, users | 0 | Sí |
| `fx_rates` | 897 | 384 KB | sí | sí / 1 | 0 |  | 0 | Sí |
| `scheduled_payment` | 21 | 128 KB | sí | sí / 2 | 0 |  | 0 | Sí |
| `vendor_profile` | 37 | 120 KB | sí | sí / 2 | 0 |  | 0 | Sí |
| `nomina_live` | 88 | 112 KB | sí | sí / 1 | 0 |  | 0 | Sí |
| `pba_payments` | 65 | 112 KB | sí | sí / 2 | 1 | clients, shipments | 0 | Sí |
| `recurring_movement` | 51 | 112 KB | sí | sí / 2 | 0 |  | 0 | Sí |
| `finanzas_fx_rate` | 1 | 96 KB | sí | sí / 2 | 0 |  | 0 | Sí |
| `vendor_flexibility` | 41 | 88 KB | sí | sí / 2 | 0 |  | 0 | Sí |
| `bank_account` | 10 | 80 KB | sí | sí / 2 | 0 |  | 0 | Sí |
| `caja_eod` | 39 | 64 KB | sí | **no** / 0 | 0 |  | 0 | Sí |
| `finanzas_rc_por_zarpar` | 6 | 48 KB | sí | sí / 2 | 0 | offices | 0 | Sí |
| `payment_commitment` | 0 | 40 KB | sí | sí / 2 | 0 |  | 0 | No (vacía) |
| `arap_live_snapshot` | 73 | 32 KB | sí | sí / 0 | 0 |  | 0 | Sí |
| `finanzas_config_recurrente` | 4 | 32 KB | sí | sí / 1 | 0 | offices | 0 | Sí |
| `finanzas_eeff_pl` | 8 | 32 KB | sí | sí / 1 | 0 | offices | 0 | Sí |
| `finanzas_forecast_recurrente` | 5 | 32 KB | sí | sí / 1 | 0 | offices | 0 | Sí |
| `finanzas_presupuesto` | 4 | 32 KB | sí | sí / 1 | 0 | offices | 0 | Sí |
| `finanzas_sync_state` | 4 | 32 KB | sí | sí / 2 | 0 |  | 0 | Sí |
| `market_indices_daily` | 31 | 32 KB | sí | sí / 0 | 0 |  | 0 | Sí |
| `pagos_recurrentes_live` | 4 | 32 KB | sí | sí / 1 | 0 |  | 0 | Sí |
| `finanzas_deuda_externa` | 0 | 24 KB | sí | sí / 1 | 0 | offices | 0 | No (vacía) |
| `cxc_send_log` | 0 | 16 KB | sí | sí / 2 | 0 |  | 0 | No (vacía) |

### Bodega Miami

| Tabla | Filas aprox. | Tamaño | PK | RLS / pol. | Trg | FK→ | ←FK | ¿Migra? |
|---|---|---|---|---|---|---|---|---|
| `wh_notices` | 8,099 | 38.4 MB | sí | sí / 1 | 1 | clients, users | 0 | Sí |
| `wh_containers` | 6,216 | 2.4 MB | sí | sí / 1 | 0 |  | 0 | Sí |
| `wh_report_sync_log` | 8,949 | 2.2 MB | sí | sí / 1 | 0 | wh_report_clients | 0 | Sí |
| `wh_containers_external` | 2,323 | 776 KB | sí | sí / 0 | 0 |  | 0 | Sí |
| `wh_report_movements` | 1,162 | 496 KB | sí | sí / 1 | 0 | wh_report_clients, magaya_cargo_releases, magaya_warehouse_receipts | 1 | Sí |
| `manifest_items` | 234 | 288 KB | sí | sí / 6 | 1 | picking_tasks, warehouse_users, manifest_sources | 3 | Sí |
| `wh_report_movement_items` | 1,170 | 280 KB | sí | sí / 1 | 0 | wh_report_movements, wh_report_products | 0 | Sí |
| `wh_carga_no_identificada` | 409 | 256 KB | sí | sí / 1 | 0 |  | 0 | Sí |
| `cl_scan_events` | 111 | 216 KB | sí | sí / 2 | 0 | loading_tasks, manifest_items, picking_tasks, warehouse_users, staging_check_tasks | 0 | Sí |
| `warehouse_containers` | 144 | 200 KB | sí | sí / 1 | 1 | clients | 1 | Sí |
| `cl_alerts` | 38 | 120 KB | sí | sí / 3 | 0 | warehouse_users, loading_tasks, manifest_sources, picking_tasks, staging_check_tasks, cl_warehouses | 0 | Sí |
| `warehouse_users` | 1 | 120 KB | sí | sí / 4 | 1 | users, cl_warehouses | 13 | Sí |
| `manifest_sources` | 20 | 96 KB | sí | sí / 2 | 1 | cl_container_types, cl_warehouses | 6 | Sí |
| `loading_tasks` | 6 | 80 KB | sí | sí / 3 | 1 | warehouse_users, cl_container_types, manifest_sources | 6 | Sí |
| `staging_check_tasks` | 11 | 80 KB | sí | sí / 3 | 4 | warehouse_users, manifest_sources | 3 | Sí |
| `warehouse_tasks` | 0 | 80 KB | sí | sí / 1 | 1 | clients | 0 | No (vacía) |
| `picking_tasks` | 18 | 72 KB | sí | sí / 3 | 4 | warehouse_users, manifest_sources, picking_tasks | 5 | Sí |
| `cl_audit_log` | 11 | 64 KB | sí | sí / 2 | 0 | warehouse_users | 0 | Sí |
| `loading_materials` | 21 | 64 KB | sí | sí / 2 | 1 | cl_warehouses | 1 | Sí |
| `wh_report_product_mappings` | 46 | 64 KB | sí | sí / 2 | 0 | wh_report_clients, wh_report_products | 0 | Sí |
| `bodega_tenants` | 4 | 48 KB | sí | sí / 1 | 0 | users | 0 | Sí |
| `cl_warehouses` | 1 | 48 KB | sí | sí / 2 | 0 |  | 4 | Sí |
| `loading_exceptions` | 3 | 48 KB | sí | sí / 3 | 0 | warehouse_users, loading_tasks, manifest_items | 0 | Sí |
| `loading_task_materials` | 4 | 48 KB | sí | sí / 2 | 0 | loading_tasks, loading_materials, warehouse_users | 0 | Sí |
| `picking_exceptions` | 2 | 48 KB | sí | sí / 3 | 0 | manifest_items, picking_tasks, warehouse_users | 0 | Sí |
| `reception_hosts` | 0 | 48 KB | sí | sí / 1 | 1 |  | 1 | No (vacía) |
| `staging_exceptions` | 1 | 48 KB | sí | sí / 3 | 0 | warehouse_users, staging_check_tasks | 0 | Sí |
| `unplanned_additions` | 3 | 48 KB | sí | sí / 2 | 0 | warehouse_users, loading_tasks | 0 | Sí |
| `warehouse_cogs_monthly` | 48 | 48 KB | sí | sí / 1 | 0 |  | 0 | Sí |
| `wh_container_types` | 9 | 48 KB | sí | sí / 1 | 0 |  | 0 | Sí |
| `wh_country_map` | 26 | 48 KB | sí | sí / 1 | 0 |  | 0 | Sí |
| `wh_internal_people` | 3 | 48 KB | sí | sí / 1 | 0 |  | 0 | Sí |
| `wh_loading_rates` | 4 | 48 KB | sí | sí / 1 | 0 |  | 0 | Sí |
| `wh_report_products` | 26 | 48 KB | sí | sí / 1 | 0 | wh_report_clients | 2 | Sí |
| `wh_stations` | 7 | 48 KB | sí | sí / 1 | 0 |  | 0 | Sí |
| `wh_storage_terms` | 5 | 48 KB | sí | sí / 1 | 0 |  | 0 | Sí |
| `wh_unloading_rates` | 5 | 48 KB | sí | sí / 1 | 0 |  | 0 | Sí |
| `wh_warehouse_costs` | 5 | 48 KB | sí | sí / 1 | 0 |  | 0 | Sí |
| `cl_container_types` | 4 | 32 KB | sí | sí / 0 | 0 |  | 2 | Sí |
| `warehouse_cogs_manual` | 4 | 32 KB | sí | sí / 1 | 0 |  | 0 | Sí |
| `wh_doc_7512` | 0 | 32 KB | sí | sí / 1 | 0 | users | 0 | No (vacía) |
| `wh_import_clients` | 15 | 32 KB | sí | sí / 1 | 0 |  | 0 | Sí |
| `wh_report_clients` | 3 | 32 KB | sí | sí / 1 | 0 |  | 4 | Sí |
| `wh_client_pallets` | 0 | 24 KB | sí | sí / 1 | 0 |  | 0 | No (vacía) |

### Seguridad y usuarios

| Tabla | Filas aprox. | Tamaño | PK | RLS / pol. | Trg | FK→ | ←FK | ¿Migra? |
|---|---|---|---|---|---|---|---|---|
| `login_history` | 123,582 | 40.2 MB | sí | sí / 3 | 0 |  | 0 | Sí |
| `audit_log` | 1,818 | 2.9 MB | sí | sí / 2 | 0 |  | 0 | Sí |
| `role_permissions` | 277 | 208 KB | sí | sí / 4 | 0 | roles | 0 | Sí |
| `users` | 92 | 160 KB | sí | sí / 5 | 2 | auth.users, roles | 53 | Sí |
| `user_permission_overrides` | 106 | 136 KB | sí | sí / 4 | 0 |  | 0 | Sí |
| `impersonation_log` | 10 | 112 KB | sí | sí / 2 | 0 | users | 0 | Sí |
| `user_delegations` | 1 | 96 KB | sí | sí / 2 | 0 | users | 0 | Sí |
| `finanzas_access` | 2 | 48 KB | sí | sí / 2 | 0 | users | 0 | Sí |
| `roles` | 7 | 48 KB | sí | sí / 5 | 0 |  | 2 | Sí |
| `pba_authorized_users` | 3 | 32 KB | sí | sí / 0 | 0 |  | 0 | Sí |

### Tarifas

| Tabla | Filas aprox. | Tamaño | PK | RLS / pol. | Trg | FK→ | ←FK | ¿Migra? |
|---|---|---|---|---|---|---|---|---|
| `rate_charges` | 32,056 | 5.1 MB | sí | sí / 4 | 0 | rates | 0 | Sí |
| `rates` | 12,894 | 5.0 MB | sí | sí / 4 | 0 | agents, commodities, contracts, equipment_types, offices, freight_routes, tariff_sheets | 3 | Sí |
| `shipco_rates` | 4,218 | 1.5 MB | sí | sí / 1 | 0 |  | 0 | Sí |
| `air_rates` | 282 | 392 KB | sí | sí / 4 | 0 | agents, air_carriers | 1 | Sí |
| `freight_routes` | 1,009 | 368 KB | sí | sí / 4 | 0 | ports, users | 2 | Sí |
| `pricing_rules` | 7 | 184 KB | sí | sí / 2 | 1 | agents, auth.users, carriers, clients, commodities, equipment_types, offices | 0 | Sí |
| `tariff_sheets` | 24 | 176 KB | sí | sí / 2 | 1 | agents, carriers, contracts, offices, auth.users | 1 | Sí |
| `contracts` | 60 | 128 KB | sí | sí / 4 | 0 | agents, carriers, contracts | 5 | Sí |
| `contract_updates` | 10 | 112 KB | sí | sí / 3 | 0 | carriers, contracts, users | 1 | Sí |
| `shipco_destinations` | 296 | 112 KB | sí | sí / 1 | 0 |  | 0 | Sí |
| `contract_documents` | 10 | 96 KB | sí | sí / 4 | 0 | contracts, users | 0 | Sí |
| `inland_addons` | 53 | 96 KB | sí | sí / 1 | 0 | carriers, ports | 0 | Sí |
| `surcharges` | 29 | 96 KB | sí | sí / 4 | 0 | carriers, equipment_types | 0 | Sí |
| `ec_fcl_local_charges` | 71 | 80 KB | sí | sí / 4 | 1 | carriers | 0 | Sí |
| `inland_carrier_zips` | 179 | 80 KB | sí | sí / 2 | 0 | inland_carriers | 0 | Sí |
| `inland_quotes` | 24 | 64 KB | sí | sí / 2 | 0 | inland_carriers, auth.users | 0 | Sí |
| `ec_fcl_local_charges_history` | 5 | 48 KB | sí | sí / 1 | 0 |  | 0 | Sí |
| `inland_carrier_area_rates` | 8 | 48 KB | sí | sí / 2 | 0 | inland_carriers | 0 | Sí |
| `lcl_lanes` | 5 | 48 KB | sí | sí / 2 | 0 |  | 0 | Sí |
| `rate_notes` | 14 | 48 KB | sí | sí / 4 | 0 | rates | 0 | Sí |
| `drayage_rates` | 0 | 40 KB | sí | sí / 1 | 0 | points_of_receipt | 0 | No (vacía) |
| `inland_carrier_rates` | 1 | 40 KB | sí | sí / 2 | 0 | inland_carriers | 0 | Sí |
| `freight_carrier_aliases` | 2 | 32 KB | sí | sí / 1 | 0 |  | 0 | Sí |
| `freight_port_aliases` | 12 | 32 KB | sí | sí / 1 | 0 |  | 0 | Sí |
| `inland_carriers` | 1 | 32 KB | sí | sí / 2 | 0 |  | 4 | Sí |
| `lcl_admin_emails` | 1 | 32 KB | sí | sí / 1 | 0 |  | 0 | Sí |
| `lcl_settings` | 1 | 32 KB | sí | sí / 2 | 0 |  | 0 | Sí |
| `lcl_surcharges` | 2 | 32 KB | sí | sí / 2 | 0 |  | 0 | Sí |
| `rate_components` | 38 | 32 KB | sí | sí / 4 | 0 |  | 1 | Sí |
| `shipco_settings` | 3 | 32 KB | sí | sí / 0 | 0 |  | 0 | Sí |
| `contract_update_lines` | 0 | 24 KB | sí | sí / 3 | 0 | contract_updates | 0 | No (vacía) |
| `surcharge_adjustments` | 0 | 24 KB | sí | sí / 3 | 0 | carriers | 0 | No (vacía) |

### Consolidados

| Tabla | Filas aprox. | Tamaño | PK | RLS / pol. | Trg | FK→ | ←FK | ¿Migra? |
|---|---|---|---|---|---|---|---|---|
| `consolidado_lineas` | 8,116 | 5.8 MB | sí | sí / 1 | 1 | users, clients, consolidados, consolidado_contenedores, consolidado_grupos, consolidado_lineas, shipments | 4 | Sí |
| `consolidado_email_bitacora` | 5,190 | 4.1 MB | sí | sí / 1 | 0 | consolidados | 0 | Sí |
| `consolidado_avisos` | 494 | 2.5 MB | sí | sí / 2 | 1 | consolidados, users | 0 | Sí |
| `consolidado_linea_movimientos` | 1,244 | 552 KB | sí | sí / 1 | 0 | consolidados, consolidado_contenedores, users, consolidado_lineas | 0 | Sí |
| `consolidado_linea_piezas` | 323 | 272 KB | sí | sí / 1 | 1 | consolidados, users, consolidado_lineas, magaya_wr_items | 0 | Sí |
| `consolidados` | 20 | 120 KB | sí | sí / 1 | 1 | users, consolidado_servicios | 10 | Sí |
| `consolidado_agente_exclusiones` | 10 | 64 KB | sí | sí / 1 | 0 | consolidados, users | 0 | Sí |
| `consolidado_contenedores` | 52 | 64 KB | sí | sí / 1 | 0 | consolidados | 2 | Sí |
| `consolidado_linea_hazmat` | 13 | 64 KB | sí | sí / 1 | 0 | consolidados, consolidado_lineas | 0 | Sí |
| `consolidado_agrupacion_memoria` | 7 | 48 KB | sí | sí / 1 | 0 |  | 0 | Sí |
| `consolidado_aereo_prefs` | 1 | 32 KB | sí | sí / 1 | 0 | users | 0 | Sí |
| `consolidado_agentes_destino` | 5 | 32 KB | sí | sí / 1 | 0 |  | 0 | Sí |
| `consolidado_capacidades` | 3 | 32 KB | sí | sí / 1 | 0 |  | 0 | Sí |
| `consolidado_fcl_prefs` | 1 | 32 KB | sí | sí / 1 | 0 |  | 0 | Sí |
| `consolidado_grupos` | 46 | 32 KB | sí | sí / 1 | 0 | consolidados | 1 | Sí |
| `consolidado_servicios` | 5 | 32 KB | sí | sí / 1 | 0 |  | 1 | Sí |
| `consolidado_agente_overrides` | 0 | 24 KB | sí | sí / 1 | 0 |  | 0 | No (vacía) |

### Esquema private

| Tabla | Filas aprox. | Tamaño | PK | RLS / pol. | Trg | FK→ | ←FK | ¿Migra? |
|---|---|---|---|---|---|---|---|---|
| `private.client_merge_audit` | 4,498 | 12.0 MB | sí | **no** / 0 | 0 |  | 0 | Sí |
| `private.iva_backfill_audit` | 22 | 32 KB | sí | **no** / 0 | 0 |  | 0 | Sí |

### CRM y ventas

| Tabla | Filas aprox. | Tamaño | PK | RLS / pol. | Trg | FK→ | ←FK | ¿Migra? |
|---|---|---|---|---|---|---|---|---|
| `sales_quote_lines` | 17,708 | 4.6 MB | sí | sí / 4 | 0 | quotes, shipping_instructions | 0 | Sí |
| `clients` | 1,895 | 1.6 MB | sí | sí / 5 | 3 | users, clients | 31 | Sí |
| `quotes` | 1,231 | 1.3 MB | sí | sí / 4 | 1 | air_carriers, carriers, clients, commodities, users, deals, ports, equipment_types, air_rates, rates | 7 | Sí |
| `deals` | 1,255 | 680 KB | sí | sí / 4 | 2 |  | 1 | Sí |
| `prospect_enrichment_ec` | 103 | 440 KB | sí | sí / 1 | 1 |  | 0 | Sí |
| `contacts` | 1,308 | 360 KB | sí | sí / 4 | 0 | clients | 2 | Sí |
| `sales_activities` | 618 | 352 KB | sí | sí / 4 | 0 |  | 0 | Sí |
| `client_notify_contacts` | 777 | 328 KB | sí | sí / 1 | 0 | clients | 0 | Sí |
| `call_logs` | 206 | 288 KB | sí | sí / 4 | 0 |  | 0 | Sí |
| `client_visits` | 260 | 240 KB | sí | sí / 7 | 2 | clients, users | 0 | Sí |
| `credit_documents` | 296 | 208 KB | sí | sí / 3 | 0 | credit_requests, users | 0 | Sí |
| `credit_requests` | 112 | 152 KB | sí | sí / 4 | 4 | clients, users | 2 | Sí |
| `quote_emails` | 181 | 104 KB | sí | sí / 1 | 0 | quotes | 0 | Sí |
| `cs_assignments` | 11 | 88 KB | sí | sí / 2 | 0 | users | 0 | Sí |
| `quote_amendments` | 11 | 88 KB | sí | sí / 3 | 0 | users, quotes | 0 | Sí |
| `activities` | 0 | 80 KB | sí | sí / 7 | 0 | clients, routes | 0 | No (vacía) |
| `reminders` | 16 | 80 KB | sí | sí / 3 | 0 | shipments, users | 0 | Sí |
| `time_entries` | 6 | 80 KB | sí | sí / 4 | 2 |  | 1 | Sí |
| `quote_pba` | 146 | 72 KB | sí | sí / 1 | 0 | quotes | 0 | Sí |
| `activity_logs` | 18 | 64 KB | sí | sí / 2 | 1 | time_entries | 0 | Sí |
| `sales_doc_counters` | 2 | 64 KB | sí | sí / 0 | 0 |  | 0 | Sí |
| `sales_live_monthly` | 72 | 64 KB | sí | sí / 1 | 0 |  | 0 | Sí |
| `consignee_aliases` | 0 | 48 KB | sí | sí / 2 | 0 | clients, users | 0 | No (vacía) |
| `credit_notify_log` | 2 | 48 KB | sí | sí / 1 | 0 | credit_requests | 0 | Sí |
| `cs_cuentas_habilitadas` | 2 | 48 KB | sí | sí / 2 | 0 | clients, users | 0 | Sí |
| `quote_followups` | 4 | 48 KB | sí | sí / 1 | 0 | quotes | 0 | Sí |
| `rfq_log` | 0 | 48 KB | sí | sí / 2 | 0 | agents, offices | 0 | No (vacía) |
| `birthday_emails_sent` | 0 | 32 KB | sí | sí / 1 | 0 | contacts | 0 | No (vacía) |
| `credit_notify_finance` | 16 | 32 KB | sí | sí / 1 | 0 |  | 0 | Sí |
| `quote_charges` | 0 | 32 KB | sí | sí / 4 | 0 | quotes, rate_components | 0 | No (vacía) |
| `sales_goals` | 21 | 32 KB | sí | sí / 4 | 0 |  | 0 | Sí |
| `ventas_alertas` | 3 | 32 KB | sí | sí / 0 | 0 |  | 0 | Sí |
| `ventas_congelado` | 7 | 32 KB | sí | sí / 0 | 0 |  | 0 | Sí |
| `deal_quotes` | 0 | 24 KB | sí | sí / 4 | 0 |  | 0 | No (vacía) |

### Christmas Palace

| Tabla | Filas aprox. | Tamaño | PK | RLS / pol. | Trg | FK→ | ←FK | ¿Migra? |
|---|---|---|---|---|---|---|---|---|
| `christmas_products` | 3,695 | 3.6 MB | sí | sí / 2 | 1 | christmas_tenants | 0 | Sí |
| `christmas_audit_log` | 51 | 192 KB | sí | sí / 1 | 0 |  | 0 | Sí |
| `christmas_destinations` | 307 | 144 KB | sí | sí / 2 | 1 | auth.users, christmas_tenants | 0 | Sí |
| `christmas_bookings` | 0 | 64 KB | sí | sí / 4 | 2 | christmas_pallet_presets, auth.users, christmas_tenants | 0 | No (vacía) |
| `christmas_user_profiles` | 19 | 64 KB | sí | sí / 2 | 2 | christmas_tenants, auth.users | 0 | Sí |
| `christmas_tenants` | 1 | 48 KB | sí | sí / 2 | 1 |  | 7 | Sí |
| `christmas_global_settings` | 1 | 32 KB | sí | sí / 2 | 1 | christmas_tenants, auth.users | 0 | Sí |
| `christmas_pallet_presets` | 8 | 32 KB | sí | sí / 2 | 1 | christmas_tenants | 1 | Sí |
| `christmas_fee_overrides` | 0 | 16 KB | sí | sí / 2 | 1 | christmas_tenants, auth.users | 0 | No (vacía) |

### Catálogos

| Tabla | Filas aprox. | Tamaño | PK | RLS / pol. | Trg | FK→ | ←FK | ¿Migra? |
|---|---|---|---|---|---|---|---|---|
| `brief_assets` | 10 | 1.9 MB | sí | sí / 1 | 0 |  | 0 | Sí |
| `ports_master` | 570 | 392 KB | sí | sí / 2 | 0 |  | 0 | Sí |
| `carrier_transit_times` | 684 | 344 KB | sí | sí / 4 | 0 | carriers, freight_routes, ports, users | 0 | Sí |
| `phone_numbers` | 635 | 216 KB | sí | sí / 4 | 0 | contacts | 0 | Sí |
| `ports` | 279 | 152 KB | sí | sí / 4 | 0 |  | 7 | Sí |
| `agents` | 74 | 144 KB | sí | sí / 4 | 1 |  | 7 | Sí |
| `commodities` | 132 | 96 KB | sí | sí / 4 | 0 |  | 3 | Sí |
| `points_of_receipt` | 31 | 96 KB | sí | sí / 1 | 0 | ports | 1 | Sí |
| `routes` | 2 | 96 KB | sí | sí / 4 | 0 | clients, ports | 1 | Sí |
| `gloval_assets` | 1 | 88 KB | sí | sí / 2 | 0 |  | 0 | Sí |
| `email_templates` | 4 | 80 KB | sí | sí / 4 | 1 |  | 0 | Sí |
| `transit_times` | 11 | 80 KB | sí | sí / 4 | 0 | carriers, ports | 0 | Sí |
| `agent_office_mapping` | 8 | 64 KB | sí | sí / 2 | 1 | users | 0 | Sí |
| `agent_files` | 0 | 48 KB | sí | sí / 4 | 0 | agents | 0 | No (vacía) |
| `carriers` | 17 | 48 KB | sí | sí / 4 | 0 |  | 11 | Sí |
| `container_types` | 7 | 48 KB | sí | sí / 2 | 0 |  | 0 | Sí |
| `equipment_types` | 11 | 48 KB | sí | sí / 4 | 0 |  | 4 | Sí |
| `offices` | 5 | 48 KB | sí | sí / 2 | 0 |  | 11 | Sí |
| `shipping_lines` | 10 | 48 KB | sí | sí / 2 | 0 |  | 0 | Sí |
| `air_carriers` | 11 | 32 KB | sí | sí / 4 | 0 |  | 2 | Sí |

### Comisiones

| Tabla | Filas aprox. | Tamaño | PK | RLS / pol. | Trg | FK→ | ←FK | ¿Migra? |
|---|---|---|---|---|---|---|---|---|
| `cmm_transactions` | 8,891 | 2.8 MB | sí | sí / 1 | 0 | cmm_sellers, cmm_uploads | 0 | Sí |
| `cmm_pending` | 704 | 232 KB | sí | sí / 1 | 0 | cmm_sellers, cmm_uploads | 0 | Sí |
| `cmm_chat_messages` | 5 | 48 KB | sí | sí / 1 | 0 | auth.users | 0 | Sí |
| `cmm_client_aliases` | 1 | 48 KB | sí | sí / 1 | 0 | auth.users | 0 | Sí |
| `cmm_commission_policies` | 1 | 48 KB | sí | sí / 1 | 0 | auth.users | 0 | Sí |
| `cmm_context_notes` | 8 | 48 KB | sí | sí / 1 | 0 | auth.users | 0 | Sí |
| `cmm_dismissed_actions` | 6 | 48 KB | sí | sí / 1 | 0 | auth.users, cmm_sellers | 0 | Sí |
| `cmm_sellers` | 8 | 48 KB | sí | sí / 1 | 0 |  | 4 | Sí |
| `cmm_targets` | 9 | 48 KB | sí | sí / 1 | 0 | cmm_sellers | 0 | Sí |
| `cmm_uploads` | 9 | 48 KB | sí | sí / 1 | 0 | auth.users | 2 | Sí |
| `cmm_insights` | 0 | 24 KB | sí | sí / 1 | 0 | auth.users | 0 | No (vacía) |

### Dashboards y reportes

| Tabla | Filas aprox. | Tamaño | PK | RLS / pol. | Trg | FK→ | ←FK | ¿Migra? |
|---|---|---|---|---|---|---|---|---|
| `dashboard_monthly_client` | 16,393 | 1.5 MB | **no** | sí / 1 | 0 |  | 0 | Sí |
| `dashboard_clients` | 3,811 | 448 KB | **no** | sí / 1 | 0 |  | 0 | Sí |
| `dashboard_pnl_monthly` | 782 | 168 KB | sí | sí / 1 | 0 |  | 0 | Sí |
| `dashboard_pnl_flow` | 1,223 | 160 KB | **no** | sí / 1 | 0 |  | 0 | Sí |
| `dashboard_agents` | 960 | 136 KB | **no** | sí / 1 | 0 |  | 0 | Sí |
| `dashboard_countries` | 452 | 40 KB | **no** | sí / 1 | 0 |  | 0 | Sí |
| `brief_emitido` | 11 | 32 KB | sí | **no** / 0 | 0 |  | 0 | Sí |

### Temporal / respaldo

| Tabla | Filas aprox. | Tamaño | PK | RLS / pol. | Trg | FK→ | ←FK | ¿Migra? |
|---|---|---|---|---|---|---|---|---|
| `wh_whr_backfill_universo` | 4,879 | 632 KB | sí | sí / 0 | 0 |  | 0 | No (temporal) |
| `private.consolidado_avisos_bak_27jul` | 90 | 280 KB | **no** | **no** / 0 | 0 |  | 0 | No (temporal) |
| `private._audit_clients_ec` | 734 | 232 KB | **no** | **no** / 0 | 0 |  | 0 | No (temporal) |
| `private._audit_clients_ec_ruc` | 734 | 152 KB | **no** | **no** / 0 | 0 |  | 0 | No (temporal) |
| `_legacy_agent_rates` | 54 | 152 KB | sí | sí / 1 | 1 |  | 0 | No (temporal) |
| `private.client_merge_survivor_snapshot` | 80 | 144 KB | **no** | **no** / 0 | 0 |  | 0 | No (temporal) |
| `private._audit_billing_ruc` | 434 | 136 KB | **no** | **no** / 0 | 0 |  | 0 | No (temporal) |
| `_cartera_ecu_20260908` | 910 | 128 KB | **no** | sí / 0 | 0 |  | 0 | No (temporal) |
| `private._audit_billing_ec_2026q1` | 434 | 120 KB | **no** | **no** / 0 | 0 |  | 0 | No (temporal) |
| `_marcia_retardos_20260904` | 332 | 72 KB | **no** | sí / 0 | 0 |  | 0 | No (temporal) |
| `private.tmp_excel2_diff` | 117 | 48 KB | **no** | **no** / 0 | 0 |  | 0 | No (temporal) |
| `private._audit_billing_aliases` | 1 | 32 KB | sí | **no** / 0 | 0 | clients | 0 | No (temporal) |
| `private.respaldo_estiba_sem31` | 100 | 24 KB | **no** | **no** / 0 | 0 |  | 0 | No (temporal) |
| `private.cifras_sem31` | 102 | 16 KB | **no** | **no** / 0 | 0 |  | 0 | No (temporal) |
| `private.closings_bak_peru_janfeb_20260804` | 235 | 16 KB | **no** | **no** / 0 | 0 |  | 0 | No (temporal) |
| `_q` | 6 | 16 KB | **no** | sí / 0 | 0 |  | 0 | No (temporal) |

### Otros

| Tabla | Filas aprox. | Tamaño | PK | RLS / pol. | Trg | FK→ | ←FK | ¿Migra? |
|---|---|---|---|---|---|---|---|---|
| `inhouse_despachos` | 10 | 328 KB | sí | sí / 4 | 0 | clients, users, shipments | 1 | Sí |
| `carrier_advisories` | 130 | 304 KB | sí | sí / 1 | 0 |  | 0 | Sí |
| `monday_containers` | 0 | 136 KB | sí | sí / 2 | 0 |  | 0 | No (vacía) |
| `inhouse_profiles` | 1 | 128 KB | sí | sí / 3 | 0 | clients | 0 | Sí |
| `visits` | 8 | 112 KB | sí | sí / 1 | 1 | visitor_badges, reception_hosts, users, visitors | 0 | Sí |
| `inhouse_documentos` | 104 | 104 KB | sí | sí / 2 | 0 | inhouse_despachos, users | 0 | Sí |
| `job_applicants` | 3 | 80 KB | sí | sí / 1 | 1 |  | 0 | Sí |
| `visitor_badges` | 20 | 64 KB | sí | sí / 2 | 1 |  | 1 | Sí |
| `inhouse_dashboards` | 1 | 48 KB | sí | sí / 3 | 0 | clients, users | 0 | Sí |
| `visitors` | 3 | 48 KB | sí | sí / 1 | 1 |  | 1 | Sí |

### Esquema timeclock

| Tabla | Filas aprox. | Tamaño | PK | RLS / pol. | Trg | FK→ | ←FK | ¿Migra? |
|---|---|---|---|---|---|---|---|---|
| `timeclock.punches` | 290 | 272 KB | sí | **no** / 0 | 0 | timeclock.employees | 0 | Sí |
| `timeclock.employees` | 18 | 48 KB | sí | **no** / 0 | 0 | timeclock.sites | 1 | Sí |
| `timeclock.corrections` | 1 | 32 KB | sí | **no** / 0 | 0 |  | 0 | Sí |
| `timeclock.sites` | 1 | 32 KB | sí | **no** / 0 | 0 |  | 1 | Sí |
