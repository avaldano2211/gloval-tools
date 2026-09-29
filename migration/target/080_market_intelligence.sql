-- 080 · Market intelligence: tablas e índices
-- Generado por migration/tools/to_tsql.mjs desde el catálogo de Supabase (2026-09-29). No editar a mano:
-- cambiar el generador y volver a correrlo. Idempotente: se puede ejecutar varias veces.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- public.mi_actor_alias | ~13,583 filas
IF OBJECT_ID(N'[dbo].[mi_actor_alias]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[mi_actor_alias] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_mi_actor_alias_id] DEFAULT (NEWSEQUENTIALID()),
  [canonical_id] UNIQUEIDENTIFIER NOT NULL,
  [alias_normalized] NVARCHAR(450) NOT NULL,
  [alias_raw] NVARCHAR(MAX) NOT NULL,
  [source_field] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_mi_actor_alias_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [mi_actor_alias_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [mi_actor_alias_canonical_id_alias_normalized_key] UNIQUE ([canonical_id], [alias_normalized])
);
END
GO

-- public.mi_canonical_actor | ~12,400 filas
IF OBJECT_ID(N'[dbo].[mi_canonical_actor]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[mi_canonical_actor] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_mi_canonical_actor_id] DEFAULT (NEWSEQUENTIALID()),
  [actor_type] NVARCHAR(50) NOT NULL,
  [canonical_name] NVARCHAR(450) NOT NULL,
  [is_gloval] BIT NOT NULL CONSTRAINT [DF_mi_canonical_actor_is_gloval] DEFAULT (0),
  [gloval_office] NVARCHAR(MAX) NULL,
  [country] NVARCHAR(MAX) NULL,
  [is_direct_bucket] BIT NOT NULL CONSTRAINT [DF_mi_canonical_actor_is_direct_bucket] DEFAULT (0),
  [auto_created] BIT NOT NULL CONSTRAINT [DF_mi_canonical_actor_auto_created] DEFAULT (0),
  [metadata] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_mi_canonical_actor_metadata] DEFAULT (N'{}'),
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_mi_canonical_actor_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_mi_canonical_actor_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [mi_canonical_actor_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [mi_canonical_actor_actor_type_canonical_name_key] UNIQUE ([actor_type], [canonical_name]),
  CONSTRAINT [CK_mi_canonical_actor_actor_type_enum] CHECK ([actor_type] IN (N'FORWARDER', N'CARRIER', N'PARTNER')),
  CONSTRAINT [CK_mi_canonical_actor_metadata_json] CHECK (ISJSON([metadata]) = 1)
);
END
GO

-- public.mi_courier_shipment | ~2,217,241 filas
IF OBJECT_ID(N'[dbo].[mi_courier_shipment]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[mi_courier_shipment] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_mi_courier_shipment_id] DEFAULT (NEWSEQUENTIALID()),
  [modality] NVARCHAR(50) NOT NULL,
  [period_year] INT NOT NULL,
  [period_month] INT NOT NULL,
  [period_quarter] AS CAST((((([period_month] - 1) / 3) + 1)) AS INT) PERSISTED,
  [operation_date] DATE NULL,
  [shipment_date] DATE NULL,
  [nombre_operacion] NVARCHAR(MAX) NULL,
  [codigo_dual] NVARCHAR(MAX) NULL,
  [doc_transporte_master] NVARCHAR(MAX) NULL,
  [doc_transporte_final] NVARCHAR(MAX) NULL,
  [doc_transporte_final_norm] NVARCHAR(100) NULL,
  [manifiesto] NVARCHAR(MAX) NULL,
  [refrendo] NVARCHAR(MAX) NULL,
  [ec_company_id] NVARCHAR(MAX) NULL,
  [ec_company_id_norm] NVARCHAR(50) NULL,
  [ec_company_id_type] NVARCHAR(MAX) NULL,
  [ec_company_name] NVARCHAR(MAX) NULL,
  [ec_company_name_norm] NVARCHAR(MAX) NULL,
  [ec_provincia] NVARCHAR(MAX) NULL,
  [ec_canton] NVARCHAR(MAX) NULL,
  [ec_parroquia] NVARCHAR(MAX) NULL,
  [ec_ciiu] NVARCHAR(MAX) NULL,
  [ec_vertical] NVARCHAR(MAX) NULL,
  [foreign_company] NVARCHAR(MAX) NULL,
  [foreign_company_norm] NVARCHAR(MAX) NULL,
  [foreign_country] NVARCHAR(MAX) NULL,
  [port_ec] NVARCHAR(MAX) NULL,
  [port_ec_arrival_dep] NVARCHAR(MAX) NULL,
  [country_arrival_dep] NVARCHAR(100) NULL,
  [region_arrival_dep] NVARCHAR(MAX) NULL,
  [port_origin_destination] NVARCHAR(MAX) NULL,
  [locality_origin_destination] NVARCHAR(MAX) NULL,
  [country_origin_destination] NVARCHAR(MAX) NULL,
  [region_origin_destination] NVARCHAR(MAX) NULL,
  [kilos_brutos] DECIMAL(14,3) NULL,
  [num_bultos] DECIMAL(12,2) NULL,
  [tipo_bulto] NVARCHAR(MAX) NULL,
  [producto_pmc] NVARCHAR(MAX) NULL,
  [producto_generico] NVARCHAR(MAX) NULL,
  [tipo_producto] NVARCHAR(MAX) NULL,
  [descripcion_unidad] NVARCHAR(MAX) NULL,
  [carrier_raw] NVARCHAR(MAX) NULL,
  [agencia_naviera_raw] NVARCHAR(MAX) NULL,
  [partner_raw] NVARCHAR(MAX) NULL,
  [liberador_raw] NVARCHAR(MAX) NULL,
  [liberador_raw_norm] NVARCHAR(255) NULL,
  [tipo_despacho] NVARCHAR(MAX) NULL,
  [forma_despacho] NVARCHAR(MAX) NULL,
  [responsable_despacho] NVARCHAR(MAX) NULL,
  [almacen] NVARCHAR(MAX) NULL,
  [termino_negociacion] NVARCHAR(MAX) NULL,
  [incoterm] NVARCHAR(MAX) NULL,
  [agente_aduana] NVARCHAR(MAX) NULL,
  [valor_comercial] DECIMAL(14,2) NULL,
  [buque_placa] NVARCHAR(MAX) NULL,
  [viaje] NVARCHAR(MAX) NULL,
  [notificador] NVARCHAR(MAX) NULL,
  [ingested_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_mi_courier_shipment_ingested_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_mi_courier_shipment_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [mi_courier_shipment_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [mi_courier_shipment_modality_check] CHECK (([modality]  IN (N'CI', N'CE'))),
  CONSTRAINT [mi_courier_shipment_period_month_check] CHECK ((([period_month] >= 1) AND ([period_month] <= 12)))
);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'mi_courier_shipment_uniq' AND object_id = OBJECT_ID(N'[dbo].[mi_courier_shipment]'))
CREATE UNIQUE INDEX [mi_courier_shipment_uniq] ON [dbo].[mi_courier_shipment] ([modality], [doc_transporte_final_norm], [period_year], [period_month]) WHERE [doc_transporte_final_norm] IS NOT NULL;
GO

-- public.mi_etl_run | ~4 filas
IF OBJECT_ID(N'[dbo].[mi_etl_run]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[mi_etl_run] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_mi_etl_run_id] DEFAULT (NEWSEQUENTIALID()),
  [modality] NVARCHAR(50) NOT NULL,
  [period_year] INT NOT NULL,
  [period_month_from] INT NULL,
  [period_month_to] INT NULL,
  [source_file_name] NVARCHAR(MAX) NULL,
  [source_file_hash] NVARCHAR(255) NULL,
  [rows_total] INT NOT NULL CONSTRAINT [DF_mi_etl_run_rows_total] DEFAULT (0),
  [rows_inserted] INT NOT NULL CONSTRAINT [DF_mi_etl_run_rows_inserted] DEFAULT (0),
  [rows_updated] INT NOT NULL CONSTRAINT [DF_mi_etl_run_rows_updated] DEFAULT (0),
  [rows_failed] INT NOT NULL CONSTRAINT [DF_mi_etl_run_rows_failed] DEFAULT (0),
  [status] NVARCHAR(50) NOT NULL CONSTRAINT [DF_mi_etl_run_status] DEFAULT (N'RUNNING'),
  [error_message] NVARCHAR(MAX) NULL,
  [triggered_by] UNIQUEIDENTIFIER NULL,
  [started_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_mi_etl_run_started_at] DEFAULT (SYSDATETIMEOFFSET()),
  [completed_at] DATETIMEOFFSET NULL,
  CONSTRAINT [mi_etl_run_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [CK_mi_etl_run_modality_enum] CHECK ([modality] IN (N'SI', N'SE', N'AI', N'AE')),
  CONSTRAINT [CK_mi_etl_run_status_enum] CHECK ([status] IN (N'RUNNING', N'COMPLETED', N'FAILED', N'PARTIAL'))
);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'mi_etl_run_file_hash_key' AND object_id = OBJECT_ID(N'[dbo].[mi_etl_run]'))
CREATE UNIQUE INDEX [mi_etl_run_file_hash_key] ON [dbo].[mi_etl_run] ([source_file_hash]) WHERE [source_file_hash] IS NOT NULL;
GO

-- public.mi_match_review_queue | ~261 filas
IF OBJECT_ID(N'[dbo].[mi_match_review_queue]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[mi_match_review_queue] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_mi_match_review_queue_id] DEFAULT (NEWSEQUENTIALID()),
  [ec_company_id] NVARCHAR(50) NULL,
  [ec_company_name] NVARCHAR(MAX) NULL,
  [ec_company_name_norm] NVARCHAR(MAX) NULL,
  [suggested_client_id] UNIQUEIDENTIFIER NULL,
  [match_method] NVARCHAR(50) NOT NULL,
  [match_confidence] DECIMAL(4,3) NOT NULL,
  [occurrences] INT NOT NULL CONSTRAINT [DF_mi_match_review_queue_occurrences] DEFAULT (1),
  [total_teus_fcl] DECIMAL(12,3) NOT NULL CONSTRAINT [DF_mi_match_review_queue_total_teus_fcl] DEFAULT (0),
  [total_kilos] DECIMAL(14,3) NOT NULL CONSTRAINT [DF_mi_match_review_queue_total_kilos] DEFAULT (0),
  [status] NVARCHAR(50) NOT NULL CONSTRAINT [DF_mi_match_review_queue_status] DEFAULT (N'PENDING'),
  [reviewed_by] UNIQUEIDENTIFIER NULL,
  [reviewed_at] DATETIMEOFFSET NULL,
  [notes] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_mi_match_review_queue_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_mi_match_review_queue_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [mi_match_review_queue_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [CK_mi_match_review_queue_match_method_enum] CHECK ([match_method] IN (N'RUC_EXACT', N'NAME_FUZZY', N'MANUAL')),
  CONSTRAINT [CK_mi_match_review_queue_status_enum] CHECK ([status] IN (N'PENDING', N'APPROVED', N'REJECTED', N'AUTO_ACCEPTED'))
);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'mi_match_review_queue_ec_company_id_suggested_client_id_mat_key' AND object_id = OBJECT_ID(N'[dbo].[mi_match_review_queue]'))
CREATE UNIQUE INDEX [mi_match_review_queue_ec_company_id_suggested_client_id_mat_key] ON [dbo].[mi_match_review_queue] ([ec_company_id], [suggested_client_id], [match_method]) WHERE [ec_company_id] IS NOT NULL AND [suggested_client_id] IS NOT NULL;
GO

-- public.mi_shipment_intel | ~2,855,530 filas
IF OBJECT_ID(N'[dbo].[mi_shipment_intel]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[mi_shipment_intel] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_mi_shipment_intel_id] DEFAULT (NEWSEQUENTIALID()),
  [modality] NVARCHAR(50) NOT NULL,
  [period_year] INT NOT NULL,
  [period_month] INT NOT NULL,
  [period_quarter] AS CAST((((([period_month] - 1) / 3) + 1)) AS INT) PERSISTED,
  [operation_date] DATE NULL,
  [shipment_date] DATE NULL,
  [nombre_operacion] NVARCHAR(MAX) NULL,
  [codigo_dual] NVARCHAR(MAX) NULL,
  [doc_transporte_master] NVARCHAR(MAX) NULL,
  [doc_transporte_final] NVARCHAR(MAX) NULL,
  [doc_transporte_final_norm] NVARCHAR(100) NULL,
  [manifiesto] NVARCHAR(MAX) NULL,
  [refrendo] NVARCHAR(MAX) NULL,
  [ec_company_id] NVARCHAR(MAX) NULL,
  [ec_company_id_norm] NVARCHAR(50) NULL,
  [ec_company_id_type] NVARCHAR(MAX) NULL,
  [ec_company_name] NVARCHAR(MAX) NULL,
  [ec_company_name_norm] NVARCHAR(450) NULL,
  [ec_provincia] NVARCHAR(MAX) NULL,
  [ec_canton] NVARCHAR(MAX) NULL,
  [ec_parroquia] NVARCHAR(MAX) NULL,
  [ec_ciiu] NVARCHAR(MAX) NULL,
  [ec_vertical] NVARCHAR(255) NULL,
  [client_id] UNIQUEIDENTIFIER NULL,
  [match_method] NVARCHAR(50) NULL,
  [match_confidence] DECIMAL(4,3) NULL,
  [matched_at] DATETIMEOFFSET NULL,
  [foreign_company] NVARCHAR(MAX) NULL,
  [foreign_company_norm] NVARCHAR(MAX) NULL,
  [foreign_country] NVARCHAR(MAX) NULL,
  [port_ec] NVARCHAR(50) NULL,
  [port_ec_arrival_dep] NVARCHAR(MAX) NULL,
  [country_arrival_dep] NVARCHAR(100) NULL,
  [region_arrival_dep] NVARCHAR(MAX) NULL,
  [port_origin_destination] NVARCHAR(255) NULL,
  [locality_origin_destination] NVARCHAR(MAX) NULL,
  [country_origin_destination] NVARCHAR(MAX) NULL,
  [region_origin_destination] NVARCHAR(MAX) NULL,
  [cont_count] DECIMAL(10,2) NULL,
  [cont_20] DECIMAL(10,2) NULL,
  [cont_40] DECIMAL(10,2) NULL,
  [teus_fcl] DECIMAL(12,3) NULL,
  [teus_lcl] DECIMAL(12,3) NULL,
  [kilos_brutos] DECIMAL(14,3) NULL,
  [num_bultos] DECIMAL(12,2) NULL,
  [tipo_bulto] NVARCHAR(MAX) NULL,
  [producto_pmc] NVARCHAR(MAX) NULL,
  [producto_generico] NVARCHAR(MAX) NULL,
  [tipo_producto] NVARCHAR(MAX) NULL,
  [descripcion_unidad] NVARCHAR(MAX) NULL,
  [incoterm] NVARCHAR(MAX) NULL,
  [termino_negociacion] NVARCHAR(MAX) NULL,
  [valor_comercial] DECIMAL(14,2) NULL,
  [carrier_raw] NVARCHAR(MAX) NULL,
  [carrier_canonical_id] UNIQUEIDENTIFIER NULL,
  [forwarder_raw_receptor] NVARCHAR(MAX) NULL,
  [forwarder_raw_liberador] NVARCHAR(MAX) NULL,
  [forwarder_canonical_id] UNIQUEIDENTIFIER NULL,
  [forwarder_roles_split] BIT NOT NULL CONSTRAINT [DF_mi_shipment_intel_forwarder_roles_split] DEFAULT (0),
  [is_direct_no_forwarder] BIT NOT NULL CONSTRAINT [DF_mi_shipment_intel_is_direct_no_forwarder] DEFAULT (0),
  [partner_raw] NVARCHAR(MAX) NULL,
  [partner_canonical_id] UNIQUEIDENTIFIER NULL,
  [origin_partner_type] NVARCHAR(50) NOT NULL CONSTRAINT [DF_mi_shipment_intel_origin_partner_type] DEFAULT (N'UNKNOWN'),
  [origin_partner_office] NVARCHAR(50) NULL,
  [agente_aduana] NVARCHAR(MAX) NULL,
  [agencia_naviera_raw] NVARCHAR(MAX) NULL,
  [liberador_doc_transporte] NVARCHAR(MAX) NULL,
  [receptor_doc_transporte] NVARCHAR(MAX) NULL,
  [almacen] NVARCHAR(MAX) NULL,
  [tipo_despacho] NVARCHAR(MAX) NULL,
  [forma_despacho] NVARCHAR(MAX) NULL,
  [responsable_despacho] NVARCHAR(MAX) NULL,
  [etl_run_id] UNIQUEIDENTIFIER NULL,
  [raw_payload] NVARCHAR(MAX) NULL,
  [ingested_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_mi_shipment_intel_ingested_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_mi_shipment_intel_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  [match_attempted_at] DATETIMEOFFSET NULL,
  CONSTRAINT [mi_shipment_intel_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [mi_shipment_intel_period_month_check] CHECK ((([period_month] >= 1) AND ([period_month] <= 12))),
  CONSTRAINT [CK_mi_shipment_intel_modality_enum] CHECK ([modality] IN (N'SI', N'SE', N'AI', N'AE')),
  CONSTRAINT [CK_mi_shipment_intel_match_method_enum] CHECK ([match_method] IN (N'RUC_EXACT', N'NAME_FUZZY', N'MANUAL')),
  CONSTRAINT [CK_mi_shipment_intel_origin_partner_type_enum] CHECK ([origin_partner_type] IN (N'GLOVAL_NETWORK', N'THIRD_PARTY', N'DIRECT_NO_AGENT', N'UNKNOWN')),
  CONSTRAINT [CK_mi_shipment_intel_raw_payload_json] CHECK (ISJSON([raw_payload]) = 1)
);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'mi_shipment_intel_modality_doc_transporte_final_norm_period_key' AND object_id = OBJECT_ID(N'[dbo].[mi_shipment_intel]'))
CREATE UNIQUE INDEX [mi_shipment_intel_modality_doc_transporte_final_norm_period_key] ON [dbo].[mi_shipment_intel] ([modality], [doc_transporte_final_norm], [period_year], [period_month]) WHERE [doc_transporte_final_norm] IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'mi_actor_alias_canonical_idx' AND object_id = OBJECT_ID(N'[dbo].[mi_actor_alias]'))
CREATE INDEX [mi_actor_alias_canonical_idx] ON [dbo].[mi_actor_alias] ([canonical_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'mi_actor_alias_normalized_idx' AND object_id = OBJECT_ID(N'[dbo].[mi_actor_alias]'))
CREATE INDEX [mi_actor_alias_normalized_idx] ON [dbo].[mi_actor_alias] ([alias_normalized]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'mi_canonical_actor_auto_idx' AND object_id = OBJECT_ID(N'[dbo].[mi_canonical_actor]'))
CREATE INDEX [mi_canonical_actor_auto_idx] ON [dbo].[mi_canonical_actor] ([auto_created]) WHERE ([auto_created] = 1);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'mi_canonical_actor_gloval_idx' AND object_id = OBJECT_ID(N'[dbo].[mi_canonical_actor]'))
CREATE INDEX [mi_canonical_actor_gloval_idx] ON [dbo].[mi_canonical_actor] ([is_gloval]) WHERE ([is_gloval] = 1);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'mi_canonical_actor_type_idx' AND object_id = OBJECT_ID(N'[dbo].[mi_canonical_actor]'))
CREATE INDEX [mi_canonical_actor_type_idx] ON [dbo].[mi_canonical_actor] ([actor_type]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'mi_courier_shipment_country_idx' AND object_id = OBJECT_ID(N'[dbo].[mi_courier_shipment]'))
CREATE INDEX [mi_courier_shipment_country_idx] ON [dbo].[mi_courier_shipment] ([country_arrival_dep]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'mi_courier_shipment_ec_company_idx' AND object_id = OBJECT_ID(N'[dbo].[mi_courier_shipment]'))
CREATE INDEX [mi_courier_shipment_ec_company_idx] ON [dbo].[mi_courier_shipment] ([ec_company_id_norm]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'mi_courier_shipment_liberador_idx' AND object_id = OBJECT_ID(N'[dbo].[mi_courier_shipment]'))
CREATE INDEX [mi_courier_shipment_liberador_idx] ON [dbo].[mi_courier_shipment] ([liberador_raw_norm]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'mi_courier_shipment_period_idx' AND object_id = OBJECT_ID(N'[dbo].[mi_courier_shipment]'))
CREATE INDEX [mi_courier_shipment_period_idx] ON [dbo].[mi_courier_shipment] ([period_year], [period_month], [modality]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_mi_etl_run_triggered_by' AND object_id = OBJECT_ID(N'[dbo].[mi_etl_run]'))
CREATE INDEX [idx_mi_etl_run_triggered_by] ON [dbo].[mi_etl_run] ([triggered_by]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'mi_etl_run_period_idx' AND object_id = OBJECT_ID(N'[dbo].[mi_etl_run]'))
CREATE INDEX [mi_etl_run_period_idx] ON [dbo].[mi_etl_run] ([period_year], [period_month_from], [modality]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'mi_etl_run_status_idx' AND object_id = OBJECT_ID(N'[dbo].[mi_etl_run]'))
CREATE INDEX [mi_etl_run_status_idx] ON [dbo].[mi_etl_run] ([status]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_mi_match_review_queue_reviewed_by' AND object_id = OBJECT_ID(N'[dbo].[mi_match_review_queue]'))
CREATE INDEX [idx_mi_match_review_queue_reviewed_by] ON [dbo].[mi_match_review_queue] ([reviewed_by]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_mi_match_review_queue_suggested_client_id' AND object_id = OBJECT_ID(N'[dbo].[mi_match_review_queue]'))
CREATE INDEX [idx_mi_match_review_queue_suggested_client_id] ON [dbo].[mi_match_review_queue] ([suggested_client_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'mi_match_review_company_id_idx' AND object_id = OBJECT_ID(N'[dbo].[mi_match_review_queue]'))
CREATE INDEX [mi_match_review_company_id_idx] ON [dbo].[mi_match_review_queue] ([ec_company_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'mi_match_review_status_idx' AND object_id = OBJECT_ID(N'[dbo].[mi_match_review_queue]'))
CREATE INDEX [mi_match_review_status_idx] ON [dbo].[mi_match_review_queue] ([status], [total_teus_fcl] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_mi_intel_match_pending' AND object_id = OBJECT_ID(N'[dbo].[mi_shipment_intel]'))
CREATE INDEX [idx_mi_intel_match_pending] ON [dbo].[mi_shipment_intel] ([match_attempted_at]) WHERE (([client_id] IS NULL) AND ([ec_company_id] IS NOT NULL));
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_mi_shipment_intel_etl_run_id' AND object_id = OBJECT_ID(N'[dbo].[mi_shipment_intel]'))
CREATE INDEX [idx_mi_shipment_intel_etl_run_id] ON [dbo].[mi_shipment_intel] ([etl_run_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_mi_shipment_intel_partner_canonical_id' AND object_id = OBJECT_ID(N'[dbo].[mi_shipment_intel]'))
CREATE INDEX [idx_mi_shipment_intel_partner_canonical_id] ON [dbo].[mi_shipment_intel] ([partner_canonical_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'mi_intel_carrier_idx' AND object_id = OBJECT_ID(N'[dbo].[mi_shipment_intel]'))
CREATE INDEX [mi_intel_carrier_idx] ON [dbo].[mi_shipment_intel] ([carrier_canonical_id]) WHERE ([carrier_canonical_id] IS NOT NULL);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'mi_intel_client_idx' AND object_id = OBJECT_ID(N'[dbo].[mi_shipment_intel]'))
CREATE INDEX [mi_intel_client_idx] ON [dbo].[mi_shipment_intel] ([client_id]) WHERE ([client_id] IS NOT NULL);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'mi_intel_country_origin_idx' AND object_id = OBJECT_ID(N'[dbo].[mi_shipment_intel]'))
CREATE INDEX [mi_intel_country_origin_idx] ON [dbo].[mi_shipment_intel] ([country_arrival_dep]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'mi_intel_direct_idx' AND object_id = OBJECT_ID(N'[dbo].[mi_shipment_intel]'))
CREATE INDEX [mi_intel_direct_idx] ON [dbo].[mi_shipment_intel] ([is_direct_no_forwarder]) WHERE ([is_direct_no_forwarder] = 1);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'mi_intel_ec_company_id_idx' AND object_id = OBJECT_ID(N'[dbo].[mi_shipment_intel]'))
CREATE INDEX [mi_intel_ec_company_id_idx] ON [dbo].[mi_shipment_intel] ([ec_company_id_norm]) WHERE ([ec_company_id_norm] IS NOT NULL);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'mi_intel_ec_company_name_norm_btree' AND object_id = OBJECT_ID(N'[dbo].[mi_shipment_intel]'))
CREATE INDEX [mi_intel_ec_company_name_norm_btree] ON [dbo].[mi_shipment_intel] ([ec_company_name_norm]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'mi_intel_ec_norm_date_btree' AND object_id = OBJECT_ID(N'[dbo].[mi_shipment_intel]'))
CREATE INDEX [mi_intel_ec_norm_date_btree] ON [dbo].[mi_shipment_intel] ([ec_company_name_norm], [operation_date] DESC) WHERE ([ec_company_name_norm] IS NOT NULL);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'mi_intel_forwarder_idx' AND object_id = OBJECT_ID(N'[dbo].[mi_shipment_intel]'))
CREATE INDEX [mi_intel_forwarder_idx] ON [dbo].[mi_shipment_intel] ([forwarder_canonical_id]) WHERE ([forwarder_canonical_id] IS NOT NULL);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'mi_intel_origin_partner_idx' AND object_id = OBJECT_ID(N'[dbo].[mi_shipment_intel]'))
CREATE INDEX [mi_intel_origin_partner_idx] ON [dbo].[mi_shipment_intel] ([origin_partner_type], [origin_partner_office]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'mi_intel_period_idx' AND object_id = OBJECT_ID(N'[dbo].[mi_shipment_intel]'))
CREATE INDEX [mi_intel_period_idx] ON [dbo].[mi_shipment_intel] ([period_year], [period_month], [modality]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'mi_intel_unmatched_idx' AND object_id = OBJECT_ID(N'[dbo].[mi_shipment_intel]'))
CREATE INDEX [mi_intel_unmatched_idx] ON [dbo].[mi_shipment_intel] ([period_year], [period_month], [modality]) WHERE ([client_id] IS NULL);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'mi_intel_vertical_idx' AND object_id = OBJECT_ID(N'[dbo].[mi_shipment_intel]'))
CREATE INDEX [mi_intel_vertical_idx] ON [dbo].[mi_shipment_intel] ([ec_vertical]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'mi_shipment_intel_route_idx' AND object_id = OBJECT_ID(N'[dbo].[mi_shipment_intel]'))
CREATE INDEX [mi_shipment_intel_route_idx] ON [dbo].[mi_shipment_intel] ([period_year], [modality], [port_origin_destination]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'mi_si_port_ec_idx' AND object_id = OBJECT_ID(N'[dbo].[mi_shipment_intel]'))
CREATE INDEX [mi_si_port_ec_idx] ON [dbo].[mi_shipment_intel] ([port_ec]) WHERE ([port_ec] IS NOT NULL);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'mi_si_port_fgn_idx' AND object_id = OBJECT_ID(N'[dbo].[mi_shipment_intel]'))
CREATE INDEX [mi_si_port_fgn_idx] ON [dbo].[mi_shipment_intel] ([port_origin_destination]) WHERE ([port_origin_destination] IS NOT NULL);
GO
