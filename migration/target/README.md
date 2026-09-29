# migration/target: DDL T-SQL para Azure SQL (Gloval One)

> Generado por `migration/tools/to_tsql.mjs`. No editar a mano; cambiar el generador y correr `npm run gen:tsql` en `migration/`.

## Qué incluye

- **274 tablas** (319 en origen menos 45 excluidas), con columnas, defaults, PK, UNIQUE, CHECK y columnas calculadas.
- **Índices** btree, **foreign keys** y **16 secuencias**.
- Los esquemas se mapean así: `public` → `dbo`, y `private`, `archive` y `timeclock` conservan su nombre.
- Todo es **idempotente** (`IF OBJECT_ID(...) IS NULL`, `IF NOT EXISTS`). Si una tabla ya existe no se vuelve a crear, pero tampoco se altera.

**No incluye:** funciones/RPC, vistas, vistas materializadas, triggers, políticas RLS ni cron jobs. Siguen en `migration/source/` y se reescriben módulo por módulo.

## Cómo aplicarlo

1. **Collation.** La BD debe tener `Latin1_General_100_CI_AI_SC_UTF8`. La collation se fija al crear la BD, y `000_database.sql` se detiene si no coincide. Para ver la actual:
   `SELECT DATABASEPROPERTYEX(DB_NAME(), 'Collation')`.
   Si no coincide y la BD está vacía, lo simple es recrearla con esa collation (portal: *Additional settings → Collation*; o `az sql db create ... --collation Latin1_General_100_CI_AI_SC_UTF8`).
2. **Red.** Agregar la IP del equipo que ejecuta en el firewall del servidor.
3. **Credenciales.** Van en `migration/.env` (ignorado por git) o en variables de entorno: `AZURE_SQL_SERVER`, `AZURE_SQL_DB`, `AZURE_SQL_USER`, `AZURE_SQL_PASSWORD`.
4. En `migration/`: `npm install`, luego `npm run db:plan` (no se conecta) y `npm run db:apply`. Para aplicar solo algunos archivos: `npm run db:apply -- 000 001`.

Orden: `000_database.sql` → `001_seguridad.sql` → `002_catalogos.sql` → `010_crm.sql` → `020_tarifas.sql` → `030_operaciones.sql` → `040_bodega.sql` → `050_consolidados.sql` → `060_finanzas.sql` → `070_magaya.sql` → `080_market_intelligence.sql` → `085_comisiones.sql` → `087_reportes.sql` → `090_christmas.sql` → `095_otros.sql` → `100_private.sql` → `101_archive.sql` → `102_timeclock.sql` → `900_foreign_keys.sql`.

## Decisiones de conversión

| Postgres | SQL Server | Nota |
|---|---|---|
| `text` | `NVARCHAR(MAX)`, o `NVARCHAR(n)` si es clave | `n` = largo máximo real medido en Supabase ×2 (×3 si fue muestreado), en escalones de 50/100/255/450 |
| `uuid` + `gen_random_uuid()` | `UNIQUEIDENTIFIER` + `NEWSEQUENTIALID()` en PK, `NEWID()` en el resto | |
| `timestamptz` / `now()` | `DATETIMEOFFSET` / `SYSDATETIMEOFFSET()` | |
| `numeric` sin precisión | `DECIMAL(38,10)` | 236 columnas. Revisar si alguna necesita más de 10 decimales |
| `jsonb` | `NVARCHAR(MAX)` + `CHECK (ISJSON(col) = 1)` | |
| arrays (`text[]`, etc.) | `NVARCHAR(MAX)` con un array JSON | 22 columnas. La carga debe convertir `{a,b}` → `["a","b"]` |
| enums | `NVARCHAR(n)` + `CHECK (col IN (...))` | |
| `interval` | `BIGINT` (segundos) | public.ar_ap_sync_queue.recheck_interval |
| `nextval(seq)` | `SEQUENCE` + `DEFAULT (NEXT VALUE FOR ...)` | Tras la carga: `ALTER SEQUENCE ... RESTART WITH máx+1` |
| `GENERATED ALWAYS AS IDENTITY` | `IDENTITY(1,1)` | Carga con `SET IDENTITY_INSERT ON` y luego `DBCC CHECKIDENT` |
| UNIQUE sobre columnas que admiten NULL | índice único filtrado `WHERE col IS NOT NULL` | En Postgres varios NULL no chocan; en SQL Server un UNIQUE solo admite un NULL |
| `UNIQUE NULLS NOT DISTINCT`, `COALESCE(col,'')` en índices únicos | índice único normal / columna calculada `col__nn` | Mismo comportamiento que en Postgres |
| `lower(col)` en índices | `col` | La collation CI ya ignora mayúsculas |
| `ON DELETE RESTRICT` | `NO ACTION` | |

## Pendientes (revisar antes de dar por buena la estructura)

### Foreign keys con cascada rebajada a NO ACTION (22)
SQL Server no permite ciclos ni varias rutas de cascada hacia una misma tabla. En estas FKs, borrar el padre ahora falla si tiene hijos, en lugar de borrarlos o ponerlos en NULL. Esa lógica pasa a la API o a un trigger.
- public.clients.clients_customer_service_id_fkey -> public.users: ON DELETE SET NULL pasa a NO ACTION (SQL Server no permite ciclos ni rutas múltiples de cascada)
- public.clients.clients_deleted_by_fkey -> public.users: ON DELETE SET NULL pasa a NO ACTION (SQL Server no permite ciclos ni rutas múltiples de cascada)
- public.clients.clients_parent_ff_id_fkey -> public.clients: ON DELETE SET NULL pasa a NO ACTION (SQL Server no permite ciclos ni rutas múltiples de cascada)
- public.consolidado_lineas.consolidado_lineas_consolidado_id_fkey -> public.consolidados: ON DELETE CASCADE pasa a NO ACTION (SQL Server no permite ciclos ni rutas múltiples de cascada)
- public.consolidado_lineas.consolidado_lineas_contenedor_id_fkey -> public.consolidado_contenedores: ON DELETE SET NULL pasa a NO ACTION (SQL Server no permite ciclos ni rutas múltiples de cascada)
- public.consolidado_lineas.consolidado_lineas_grupo_id_fkey -> public.consolidado_grupos: ON DELETE SET NULL pasa a NO ACTION (SQL Server no permite ciclos ni rutas múltiples de cascada)
- public.consolidado_lineas.consolidado_lineas_rodado_desde_fkey -> public.consolidado_lineas: ON DELETE SET NULL pasa a NO ACTION (SQL Server no permite ciclos ni rutas múltiples de cascada)
- public.cs_assignments.cs_assignments_sales_executive_id_fkey -> public.users: ON DELETE CASCADE pasa a NO ACTION (SQL Server no permite ciclos ni rutas múltiples de cascada)
- public.cs_cuentas_habilitadas.cs_cuentas_habilitadas_cs_user_id_fkey -> public.users: ON DELETE CASCADE pasa a NO ACTION (SQL Server no permite ciclos ni rutas múltiples de cascada)
- public.magaya_transactions.magaya_transactions_company_id_fkey -> public.magaya_companies: ON DELETE CASCADE pasa a NO ACTION (SQL Server no permite ciclos ni rutas múltiples de cascada)
- public.magaya_usa_shipments.magaya_usa_shipments_manual_master_id_fkey -> public.magaya_usa_shipments: ON DELETE SET NULL pasa a NO ACTION (SQL Server no permite ciclos ni rutas múltiples de cascada)
- public.mi_shipment_intel.mi_shipment_intel_forwarder_canonical_id_fkey -> public.mi_canonical_actor: ON DELETE SET NULL pasa a NO ACTION (SQL Server no permite ciclos ni rutas múltiples de cascada)
- public.mi_shipment_intel.mi_shipment_intel_partner_canonical_id_fkey -> public.mi_canonical_actor: ON DELETE SET NULL pasa a NO ACTION (SQL Server no permite ciclos ni rutas múltiples de cascada)
- public.picking_tasks.picking_tasks_manifest_source_id_fkey -> public.manifest_sources: ON DELETE CASCADE pasa a NO ACTION (SQL Server no permite ciclos ni rutas múltiples de cascada)
- public.routes.routes_protected_by_ff_id_fkey -> public.clients: ON DELETE SET NULL pasa a NO ACTION (SQL Server no permite ciclos ni rutas múltiples de cascada)
- public.shipment_containers.shipment_containers_shipment_id_fkey -> public.shipments: ON DELETE CASCADE pasa a NO ACTION (SQL Server no permite ciclos ni rutas múltiples de cascada)
- public.shipments.shipments_master_shipment_id_fkey -> public.shipments: ON DELETE SET NULL pasa a NO ACTION (SQL Server no permite ciclos ni rutas múltiples de cascada)
- public.shipping_instructions.shipping_instructions_quote_id_fkey -> public.quotes: ON DELETE SET NULL pasa a NO ACTION (SQL Server no permite ciclos ni rutas múltiples de cascada)
- public.staging_check_tasks.staging_check_tasks_manifest_source_id_fkey -> public.manifest_sources: ON DELETE CASCADE pasa a NO ACTION (SQL Server no permite ciclos ni rutas múltiples de cascada)
- public.tariff_sheets.tariff_sheets_agent_id_fkey -> public.agents: ON DELETE SET NULL pasa a NO ACTION (SQL Server no permite ciclos ni rutas múltiples de cascada)
- public.tariff_sheets.tariff_sheets_office_id_fkey -> public.offices: ON DELETE SET NULL pasa a NO ACTION (SQL Server no permite ciclos ni rutas múltiples de cascada)
- public.user_delegations.user_delegations_viewer_user_id_fkey -> public.users: ON DELETE CASCADE pasa a NO ACTION (SQL Server no permite ciclos ni rutas múltiples de cascada)

### Foreign keys omitidas (16)
- public.christmas_destinations.destinations_created_by_fkey -> auth.users (Supabase Auth: se decide con el tema de autenticación)
- public.christmas_global_settings.global_settings_updated_by_fkey -> auth.users (Supabase Auth: se decide con el tema de autenticación)
- public.christmas_user_profiles.user_profiles_user_id_fkey -> auth.users (Supabase Auth: se decide con el tema de autenticación)
- public.cmm_chat_messages.cmm_chat_messages_created_by_fkey -> auth.users (Supabase Auth: se decide con el tema de autenticación)
- public.cmm_client_aliases.cmm_client_aliases_created_by_fkey -> auth.users (Supabase Auth: se decide con el tema de autenticación)
- public.cmm_commission_policies.cmm_commission_policies_created_by_fkey -> auth.users (Supabase Auth: se decide con el tema de autenticación)
- public.cmm_context_notes.cmm_context_notes_created_by_fkey -> auth.users (Supabase Auth: se decide con el tema de autenticación)
- public.cmm_dismissed_actions.cmm_dismissed_actions_created_by_fkey -> auth.users (Supabase Auth: se decide con el tema de autenticación)
- public.cmm_uploads.cmm_uploads_uploaded_by_fkey -> auth.users (Supabase Auth: se decide con el tema de autenticación)
- public.inland_quotes.inland_quotes_created_by_fkey -> auth.users (Supabase Auth: se decide con el tema de autenticación)
- public.pricing_rules.pricing_rules_approved_by_fkey -> auth.users (Supabase Auth: se decide con el tema de autenticación)
- public.pricing_rules.pricing_rules_created_by_fkey -> auth.users (Supabase Auth: se decide con el tema de autenticación)
- public.pricing_rules.pricing_rules_sales_rep_id_fkey -> auth.users (Supabase Auth: se decide con el tema de autenticación)
- public.tariff_sheets.tariff_sheets_uploaded_by_fkey -> auth.users (Supabase Auth: se decide con el tema de autenticación)
- public.users.users_auth_user_id_fkey -> auth.users (Supabase Auth: se decide con el tema de autenticación)
- public.visits.visits_host_tenant_id_fkey -> public.reception_hosts (tabla destino excluida)

### Columnas generadas que pasan a columnas normales (12)
Usan `normalize_company_name()` o `regexp_replace`, que no se pueden usar en una columna calculada. Las debe llenar la carga de datos y después la API.
- public.clients.company_name_normalized = normalize_company_name(company_name)
- public.magaya_entities.name_normalized = normalize_company_name(name)
- public.magaya_warehouse_receipts.consignee_normalized = normalize_company_name(consignee)
- public.mi_courier_shipment.doc_transporte_final_norm = NULLIF(regexp_replace(upper(COALESCE(doc_transporte_final, ''::text)), '[^A-Z0-9]'::text, ''::text, 'g'::text), ''::text)
- public.mi_courier_shipment.ec_company_id_norm = NULLIF(regexp_replace(COALESCE(ec_company_id, ''::text), '\D'::text, ''::text, 'g'::text), ''::text)
- public.mi_courier_shipment.ec_company_name_norm = normalize_company_name(ec_company_name)
- public.mi_courier_shipment.foreign_company_norm = normalize_company_name(foreign_company)
- public.mi_courier_shipment.liberador_raw_norm = normalize_company_name(liberador_raw)
- public.mi_shipment_intel.doc_transporte_final_norm = NULLIF(regexp_replace(upper(COALESCE(doc_transporte_final, ''::text)), '[^A-Z0-9]'::text, ''::text, 'g'::text), ''::text)
- public.mi_shipment_intel.ec_company_id_norm = NULLIF(regexp_replace(COALESCE(ec_company_id, ''::text), '\D'::text, ''::text, 'g'::text), ''::text)
- public.mi_shipment_intel.ec_company_name_norm = normalize_company_name(ec_company_name)
- public.mi_shipment_intel.foreign_company_norm = normalize_company_name(foreign_company)

### Columnas calculadas creadas (18)
No se insertan en la carga; SQL Server las calcula.
- public.closings.profit
- public.closings.margin
- public.liq_settlements.freight_profit
- public.liq_settlements.local_profit
- public.liq_settlements.profit_total
- public.liq_settlements.commission_amount
- public.liq_settlements.profit_net
- public.liq_settlements.profit_usa
- public.liq_settlements.profit_ec
- public.liq_settlements.invoice_usa_amount
- public.magaya_warehouse_receipts.cbm
- public.mi_courier_shipment.period_quarter
- public.mi_shipment_intel.period_quarter
- public.ops_devolucion_vacios.fecha_limite
- public.shipments.search_text
- public.client_notify_contacts.consignee_hint__nn (para índice client_notify_contacts_uniq)
- public.consolidados.booking__nn (para índice consolidados_semana_uq)
- public.ec_fcl_local_charges.origin__nn (para índice ec_fcl_charges_carrier_concept_variant_origin_key)

### Índices no convertidos (15)
Los GIN (búsqueda por trigramas) se reemplazan con Full-Text Search. Los de expresión, con una columna calculada si hacen falta.
- public.bank_transaction: idx_bank_transaction_account_date_amount — expresión en la clave: round((amount)::numeric, 2)
- public.cash_movement: idx_cash_movement_match — expresión en la clave: round((amount_in_usd)::numeric, 2)
- public.clients: clients_company_name_norm_trgm_idx — método gin (usar Full-Text / índice JSON)
- public.clients: clients_ruc_idx — expresión en la clave: regexp_replace(COALESCE(ruc, ''::text), '\D'::text, ''::text, 'g'::text)
- public.consolidado_lineas: consolidado_lineas_shipper_trgm — método gin (usar Full-Text / índice JSON)
- public.coordination_tasks: coordination_tasks_search_idx — método gin (usar Full-Text / índice JSON)
- public.magaya_entities: magaya_entities_name_trgm_idx — método gin (usar Full-Text / índice JSON)
- public.magaya_entities: magaya_entities_tax_id_idx — expresión en la clave: regexp_replace(COALESCE(tax_id, ''::text), '\D'::text, ''::text, 'g'::text)
- public.magaya_warehouse_receipts: magaya_wr_shipper_trgm — método gin (usar Full-Text / índice JSON)
- public.mi_actor_alias: mi_actor_alias_normalized_trgm_idx — método gin (usar Full-Text / índice JSON)
- public.mi_shipment_intel: mi_intel_ec_name_trgm_idx — método gin (usar Full-Text / índice JSON)
- public.mi_shipment_intel: mi_shipment_intel_prodtext_trgm — método gin (usar Full-Text / índice JSON)
- public.ports_master: idx_ports_master_search — método gin (usar Full-Text / índice JSON)
- public.shipments: shipments_search_trgm_idx — método gin (usar Full-Text / índice JSON)
- public.warehouse_users: idx_warehouse_users_roles — método gin (usar Full-Text / índice JSON)

### Índices modificados (8)
- public.bodega_tenants: bodega_tenants_uq — lower()/upper() quitado (la collation CI ya ignora mayúsculas)
- public.christmas_user_profiles: christmas_user_profiles_username_uniq — lower()/upper() quitado (la collation CI ya ignora mayúsculas)
- public.client_notify_contacts: client_notify_contacts_uniq — lower()/upper() quitado (la collation CI ya ignora mayúsculas)
- public.cmm_client_aliases: cmm_client_aliases_unique — lower()/upper() quitado (la collation CI ya ignora mayúsculas)
- public.cmm_sellers: cmm_sellers_nombre_office_uk — lower()/upper() quitado (la collation CI ya ignora mayúsculas)
- public.consolidado_agente_exclusiones: consolidado_agente_excl_semana_uq — lower()/upper() quitado (la collation CI ya ignora mayúsculas)
- public.consolidado_agente_exclusiones: consolidado_agente_excl_siempre_uq — lower()/upper() quitado (la collation CI ya ignora mayúsculas)
- public.shipments: shipments_open_status_idx — se quitó el filtro WHERE (status <> ALL (ARRAY['DELIVERED'::shipment_status_t, 'CANCELLED'::shipment_status_t])) (no soportado); queda como índice completo

### Índices únicos filtrados por NULL (19)
- public.carrier_email_log (message_id) -> índice único filtrado
- public.cash_movement (tenant_id, external_guid) -> índice único filtrado
- public.christmas_products (tenant_id, sku) -> índice único filtrado
- public.cs_assignments (cs_user_id, sales_executive_id) -> índice único filtrado
- public.liq_shipments (magaya_guid) -> índice único filtrado
- public.loading_materials (warehouse_id, code) -> índice único filtrado
- public.magaya_accounts (company_id, account_number, currency_code) -> índice único filtrado
- public.magaya_charges_extracted (txn_guid, charge_guid) -> índice único filtrado
- public.magaya_entities (company_id, magaya_guid) -> índice único filtrado
- public.magaya_invoices (company_id, guid) -> índice único filtrado
- public.magaya_transactions (company_id, magaya_guid) -> índice único filtrado
- public.magaya_usa_shipments (guid) -> índice único filtrado
- public.manifest_sources (source_type, magaya_guid) -> índice único filtrado
- public.mi_courier_shipment (modality, doc_transporte_final_norm, period_year, period_month) -> índice único filtrado
- public.mi_etl_run (source_file_hash) -> índice único filtrado
- public.mi_match_review_queue (ec_company_id, suggested_client_id, match_method) -> índice único filtrado
- public.mi_shipment_intel (modality, doc_transporte_final_norm, period_year, period_month) -> índice único filtrado
- public.ops_hbl (hbl_number) -> índice único filtrado
- public.shipments (shipment_code) -> índice único filtrado

### Datos que chocarían con la collation CI_AI
- `dbo.consolidado_avisos` UNIQUE (`consolidado_id`, `cliente_key`): hay 5 pares que solo difieren en mayúsculas (todos en DRAFT). Hay que depurarlos antes de cargar los datos. La estructura no se ve afectada.

### Tablas excluidas (45)
- private._audit_billing_aliases: temporal / respaldo (1 filas)
- private._audit_billing_ec_2026q1: temporal / respaldo (434 filas)
- private._audit_billing_ruc: temporal / respaldo (434 filas)
- private._audit_clients_ec: temporal / respaldo (734 filas)
- private._audit_clients_ec_ruc: temporal / respaldo (734 filas)
- private.cifras_sem31: temporal / respaldo (102 filas)
- private.client_merge_survivor_snapshot: temporal / respaldo (80 filas)
- private.closings_bak_peru_janfeb_20260804: temporal / respaldo (235 filas)
- private.consolidado_avisos_bak_27jul: temporal / respaldo (90 filas)
- private.respaldo_estiba_sem31: temporal / respaldo (100 filas)
- private.tmp_excel2_diff: temporal / respaldo (117 filas)
- public._cartera_ecu_20260908: temporal / respaldo (910 filas)
- public._legacy_agent_rates: temporal / respaldo (54 filas)
- public._marcia_retardos_20260904: temporal / respaldo (332 filas)
- public._q: temporal / respaldo (6 filas)
- public.activities: vacía (count exacto = 0)
- public.agent_files: vacía (count exacto = 0)
- public.birthday_emails_sent: vacía (count exacto = 0)
- public.christmas_bookings: vacía (count exacto = 0)
- public.christmas_fee_overrides: vacía (count exacto = 0)
- public.cmm_insights: vacía (count exacto = 0)
- public.consignee_aliases: vacía (count exacto = 0)
- public.consolidado_agente_overrides: vacía (count exacto = 0)
- public.container_files: vacía (count exacto = 0)
- public.contract_update_lines: vacía (count exacto = 0)
- public.cxc_send_log: vacía (count exacto = 0)
- public.deal_quotes: vacía (count exacto = 0)
- public.dispatches: vacía (count exacto = 0)
- public.drayage_rates: vacía (count exacto = 0)
- public.external_containers: vacía (count exacto = 0)
- public.finanzas_deuda_externa: vacía (count exacto = 0)
- public.liq_documents: vacía (count exacto = 0)
- public.magaya_cr_items: vacía (count exacto = 0)
- public.magaya_event_definitions: vacía (count exacto = 0)
- public.magaya_inventory: vacía (count exacto = 0)
- public.monday_containers: vacía (count exacto = 0)
- public.payment_commitment: vacía (count exacto = 0)
- public.quote_charges: vacía (count exacto = 0)
- public.reception_hosts: vacía (count exacto = 0)
- public.rfq_log: vacía (count exacto = 0)
- public.surcharge_adjustments: vacía (count exacto = 0)
- public.warehouse_tasks: vacía (count exacto = 0)
- public.wh_client_pallets: vacía (count exacto = 0)
- public.wh_doc_7512: vacía (count exacto = 0)
- public.wh_whr_backfill_universo: temporal / respaldo (4879 filas)
