-- 030 · Operaciones: tablas e índices
-- Generado por migration/tools/to_tsql.mjs desde el catálogo de Supabase (2026-09-29). No editar a mano:
-- cambiar el generador y volver a correrlo. Idempotente: se puede ejecutar varias veces.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- public.carrier_email_log | ~2 filas
IF OBJECT_ID(N'[dbo].[carrier_email_log]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[carrier_email_log] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_carrier_email_log_id] DEFAULT (NEWSEQUENTIALID()),
  [message_id] NVARCHAR(50) NULL,
  [from_address] NVARCHAR(MAX) NULL,
  [to_address] NVARCHAR(MAX) NULL,
  [subject] NVARCHAR(MAX) NULL,
  [received_at] DATETIMEOFFSET NULL,
  [body_excerpt] NVARCHAR(MAX) NULL,
  [raw_text] NVARCHAR(MAX) NULL,
  [carrier_detected] NVARCHAR(50) NULL,
  [parse_status] NVARCHAR(50) NULL CONSTRAINT [DF_carrier_email_log_parse_status] DEFAULT (N'PENDING'),
  [extracted] NVARCHAR(MAX) NULL,
  [matched_shipment_id] UNIQUEIDENTIFIER NULL,
  [applied_changes] NVARCHAR(MAX) NULL,
  [error_message] NVARCHAR(MAX) NULL,
  [llm_provider] NVARCHAR(MAX) NULL,
  [llm_tokens_used] INT NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_carrier_email_log_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [processed_at] DATETIMEOFFSET NULL,
  CONSTRAINT [carrier_email_log_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [CK_carrier_email_log_extracted_json] CHECK (ISJSON([extracted]) = 1),
  CONSTRAINT [CK_carrier_email_log_applied_changes_json] CHECK (ISJSON([applied_changes]) = 1)
);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'carrier_email_log_message_id_key' AND object_id = OBJECT_ID(N'[dbo].[carrier_email_log]'))
CREATE UNIQUE INDEX [carrier_email_log_message_id_key] ON [dbo].[carrier_email_log] ([message_id]) WHERE [message_id] IS NOT NULL;
GO

-- public.cierres_liquidacion | ~13 filas
IF OBJECT_ID(N'[dbo].[cierres_liquidacion]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[cierres_liquidacion] (
  [mes] NVARCHAR(50) NOT NULL,
  [office] NVARCHAR(50) NOT NULL,
  [cerrado] DECIMAL(38,10) NULL,
  [facturado] DECIMAL(38,10) NULL,
  [carryover] DECIMAL(38,10) NULL,
  [conv_pct] DECIMAL(38,10) NULL,
  [estado] NVARCHAR(MAX) NULL,
  [nota] NVARCHAR(MAX) NULL,
  [computed_at] DATETIMEOFFSET NULL CONSTRAINT [DF_cierres_liquidacion_computed_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [cierres_liquidacion_pkey] PRIMARY KEY ([mes], [office])
);
END
GO

-- public.container_load_reports | ~2 filas
IF OBJECT_ID(N'[dbo].[container_load_reports]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[container_load_reports] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_container_load_reports_id] DEFAULT (NEWSEQUENTIALID()),
  [loading_task_id] UNIQUEIDENTIFIER NOT NULL,
  [manifest_source_id] UNIQUEIDENTIFIER NOT NULL,
  [clr_number] NVARCHAR(50) NOT NULL,
  [pdf_url] NVARCHAR(MAX) NOT NULL,
  [pdf_size_bytes] BIGINT NULL,
  [qr_code_url] NVARCHAR(MAX) NULL,
  [content_hash] NVARCHAR(MAX) NOT NULL,
  [items_loaded] INT NOT NULL,
  [total_weight_kg] DECIMAL(10,3) NOT NULL,
  [total_volume_m3] DECIMAL(10,3) NULL,
  [exceptions_count] INT NOT NULL CONSTRAINT [DF_container_load_reports_exceptions_count] DEFAULT (0),
  [unplanned_count] INT NOT NULL CONSTRAINT [DF_container_load_reports_unplanned_count] DEFAULT (0),
  [has_red_flag] BIT NOT NULL CONSTRAINT [DF_container_load_reports_has_red_flag] DEFAULT (0),
  [red_flag_reason] NVARCHAR(MAX) NULL,
  [language] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_container_load_reports_language] DEFAULT (N'es'),
  [magaya_attached] BIT NOT NULL CONSTRAINT [DF_container_load_reports_magaya_attached] DEFAULT (0),
  [magaya_attached_at] DATETIMEOFFSET NULL,
  [magaya_attachment_id] NVARCHAR(MAX) NULL,
  [generated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_container_load_reports_generated_at] DEFAULT (SYSDATETIMEOFFSET()),
  [generated_by] UNIQUEIDENTIFIER NULL,
  CONSTRAINT [container_load_reports_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [container_load_reports_clr_number_key] UNIQUE ([clr_number]),
  CONSTRAINT [container_load_reports_loading_task_id_key] UNIQUE ([loading_task_id])
);
END
GO

-- public.coordination_tasks | ~81 filas
IF OBJECT_ID(N'[dbo].[coordination_tasks]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[coordination_tasks] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_coordination_tasks_id] DEFAULT (NEWSEQUENTIALID()),
  [task_type] NVARCHAR(MAX) NOT NULL,
  [reference_code] NVARCHAR(MAX) NULL,
  [reference_type] NVARCHAR(MAX) NULL,
  [description] NVARCHAR(MAX) NULL,
  [origin] NVARCHAR(MAX) NULL,
  [destination] NVARCHAR(MAX) NULL,
  [scheduled_date] DATE NULL,
  [completed_date] DATE NULL,
  [status] NVARCHAR(50) NOT NULL CONSTRAINT [DF_coordination_tasks_status] DEFAULT (N'OPEN'),
  [shipment_id] UNIQUEIDENTIFIER NULL,
  [client_id] UNIQUEIDENTIFIER NULL,
  [office] NVARCHAR(MAX) NOT NULL,
  [sales_executive_id] UNIQUEIDENTIFIER NULL,
  [cs_assigned_to] UNIQUEIDENTIFIER NULL,
  [carrier_name] NVARCHAR(MAX) NULL,
  [driver_info] NVARCHAR(MAX) NULL,
  [notes] NVARCHAR(MAX) NULL,
  [archived_at] DATETIMEOFFSET NULL,
  [archived_by] UNIQUEIDENTIFIER NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_coordination_tasks_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [created_by] UNIQUEIDENTIFIER NULL,
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_coordination_tasks_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  [po_reference] NVARCHAR(MAX) NULL,
  [pickup_number] NVARCHAR(MAX) NULL,
  [order_number] NVARCHAR(MAX) NULL,
  [supplier_name] NVARCHAR(MAX) NULL,
  [origin_port] NVARCHAR(MAX) NULL,
  [destination_port] NVARCHAR(MAX) NULL,
  [extra_fields] NVARCHAR(MAX) NULL,
  CONSTRAINT [coordination_tasks_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [coordination_tasks_reference_type_check] CHECK ((([reference_type]  IN (N'FIRMS_CODE', N'BOOKING', N'BL', N'PO', N'OTHER')) OR ([reference_type] IS NULL))),
  CONSTRAINT [coordination_tasks_status_check] CHECK (([status]  IN (N'OPEN', N'IN_PROGRESS', N'COMPLETED', N'CANCELLED'))),
  CONSTRAINT [coordination_tasks_task_type_check] CHECK (([task_type]  IN (N'PICKUP', N'INLAND', N'BONDED', N'OTHER'))),
  CONSTRAINT [CK_coordination_tasks_extra_fields_json] CHECK (ISJSON([extra_fields]) = 1)
);
END
GO

-- public.fact_orders | ~2 filas
IF OBJECT_ID(N'[dbo].[fact_orders]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[fact_orders] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_fact_orders_id] DEFAULT (NEWSEQUENTIALID()),
  [shipment_id] UNIQUEIDENTIFIER NOT NULL,
  [si_id] UNIQUEIDENTIFIER NULL,
  [client_id] UNIQUEIDENTIFIER NULL,
  [kind] NVARCHAR(50) NOT NULL,
  [lines] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_fact_orders_lines] DEFAULT (N'[]'),
  [total] DECIMAL(38,10) NULL,
  [currency] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_fact_orders_currency] DEFAULT (N'USD'),
  [status] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_fact_orders_status] DEFAULT (N'PENDIENTE'),
  [created_by] UNIQUEIDENTIFIER NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_fact_orders_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [fact_orders_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [CK_fact_orders_lines_json] CHECK (ISJSON([lines]) = 1)
);
END
GO

-- public.fcl_semanal | ~1 filas
IF OBJECT_ID(N'[dbo].[fcl_semanal]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[fcl_semanal] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_fcl_semanal_id] DEFAULT (NEWSEQUENTIALID()),
  [office] NVARCHAR(50) NOT NULL CONSTRAINT [DF_fcl_semanal_office] DEFAULT (N'USA'),
  [semana] INT NOT NULL,
  [anio] INT NOT NULL,
  [cliente] NVARCHAR(50) NOT NULL,
  [client_id] UNIQUEIDENTIFIER NULL,
  [naviera] NVARCHAR(MAX) NULL,
  [booking] NVARCHAR(MAX) NULL,
  [contenedor] NVARCHAR(MAX) NULL,
  [tipo] NVARCHAR(MAX) NULL,
  [sello] NVARCHAR(MAX) NULL,
  [origen_carga] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_fcl_semanal_origen_carga] DEFAULT (N'BODEGA'),
  [lugar_carga] NVARCHAR(MAX) NULL,
  [fecha_carga] DATE NULL,
  [cutoff] DATE NULL,
  [estado] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_fcl_semanal_estado] DEFAULT (N'PROGRAMADO'),
  [destino] NVARCHAR(MAX) NULL,
  [shipment_id] UNIQUEIDENTIFIER NULL,
  [wr_numbers] NVARCHAR(MAX) NULL CONSTRAINT [DF_fcl_semanal_wr_numbers] DEFAULT (N'[]'),
  [notas] NVARCHAR(MAX) NULL,
  [created_by] UNIQUEIDENTIFIER NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_fcl_semanal_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_fcl_semanal_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [fcl_semanal_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [fcl_semanal_estado_check] CHECK (([estado]  IN (N'PROGRAMADO', N'CARGADO', N'ZARPADO', N'CANCELADO'))),
  CONSTRAINT [fcl_semanal_origen_carga_check] CHECK (([origen_carga]  IN (N'BODEGA', N'FUERA'))),
  CONSTRAINT [CK_fcl_semanal_wr_numbers_json] CHECK (ISJSON([wr_numbers]) = 1)
);
END
GO

-- public.liq_agent_invoice_lines | ~9 filas
IF OBJECT_ID(N'[dbo].[liq_agent_invoice_lines]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[liq_agent_invoice_lines] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_liq_agent_invoice_lines_id] DEFAULT (NEWSEQUENTIALID()),
  [invoice_id] UNIQUEIDENTIFIER NOT NULL,
  [charge_code] NVARCHAR(MAX) NOT NULL,
  [custom_name] NVARCHAR(MAX) NULL,
  [amount] DECIMAL(38,10) NOT NULL CONSTRAINT [DF_liq_agent_invoice_lines_amount] DEFAULT (0),
  [prorate_by] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_liq_agent_invoice_lines_prorate_by] DEFAULT (N'equal'),
  [sort_order] INT NOT NULL CONSTRAINT [DF_liq_agent_invoice_lines_sort_order] DEFAULT (100),
  CONSTRAINT [liq_agent_invoice_lines_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [liq_agent_invoice_lines_prorate_by_check] CHECK (([prorate_by]  IN (N'equal', N'cbm', N'lb', N'wm', N'container')))
);
END
GO

-- public.liq_agent_invoices | ~4 filas
IF OBJECT_ID(N'[dbo].[liq_agent_invoices]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[liq_agent_invoices] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_liq_agent_invoices_id] DEFAULT (NEWSEQUENTIALID()),
  [master_number] NVARCHAR(50) NOT NULL,
  [week_of] DATE NULL,
  [agent] NVARCHAR(MAX) NULL,
  [invoice_number] NVARCHAR(MAX) NULL,
  [invoice_date] DATE NULL,
  [total] DECIMAL(38,10) NOT NULL CONSTRAINT [DF_liq_agent_invoices_total] DEFAULT (0),
  [notes] NVARCHAR(MAX) NULL,
  [applied_at] DATETIMEOFFSET NULL,
  [created_by] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_liq_agent_invoices_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [liq_agent_invoices_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.liq_charge_catalog | ~40 filas
IF OBJECT_ID(N'[dbo].[liq_charge_catalog]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[liq_charge_catalog] (
  [code] NVARCHAR(50) NOT NULL,
  [name] NVARCHAR(MAX) NOT NULL,
  [section] NVARCHAR(MAX) NOT NULL,
  [modes] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_liq_charge_catalog_modes] DEFAULT (N'["air"]'),
  [default_basis] NVARCHAR(MAX) NOT NULL,
  [taxable_iva] BIT NOT NULL CONSTRAINT [DF_liq_charge_catalog_taxable_iva] DEFAULT (0),
  [sort_order] INT NOT NULL CONSTRAINT [DF_liq_charge_catalog_sort_order] DEFAULT (100),
  [active] BIT NOT NULL CONSTRAINT [DF_liq_charge_catalog_active] DEFAULT (1),
  CONSTRAINT [liq_charge_catalog_pkey] PRIMARY KEY ([code]),
  CONSTRAINT [liq_charge_catalog_default_basis_check] CHECK (([default_basis]  IN (N'per_kg_chargeable', N'per_lb', N'fixed', N'pct_invoice', N'per_wm', N'per_cbm', N'per_container', N'manual'))),
  CONSTRAINT [liq_charge_catalog_section_check] CHECK (([section]  IN (N'freight', N'local_ec'))),
  CONSTRAINT [CK_liq_charge_catalog_modes_json] CHECK (ISJSON([modes]) = 1)
);
END
GO

-- public.liq_settlement_lines | ~1,058 filas
IF OBJECT_ID(N'[dbo].[liq_settlement_lines]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[liq_settlement_lines] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_liq_settlement_lines_id] DEFAULT (NEWSEQUENTIALID()),
  [settlement_id] UNIQUEIDENTIFIER NOT NULL,
  [charge_code] NVARCHAR(50) NOT NULL,
  [section] NVARCHAR(MAX) NOT NULL,
  [basis] NVARCHAR(MAX) NOT NULL,
  [applies] BIT NOT NULL CONSTRAINT [DF_liq_settlement_lines_applies] DEFAULT (1),
  [cost_rate] DECIMAL(38,10) NULL CONSTRAINT [DF_liq_settlement_lines_cost_rate] DEFAULT (0),
  [cost_amount] DECIMAL(38,10) NOT NULL CONSTRAINT [DF_liq_settlement_lines_cost_amount] DEFAULT (0),
  [sale_rate] DECIMAL(38,10) NULL CONSTRAINT [DF_liq_settlement_lines_sale_rate] DEFAULT (0),
  [sale_amount] DECIMAL(38,10) NOT NULL CONSTRAINT [DF_liq_settlement_lines_sale_amount] DEFAULT (0),
  [currency] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_liq_settlement_lines_currency] DEFAULT (N'USD'),
  [notes] NVARCHAR(MAX) NULL,
  [sort_order] INT NOT NULL CONSTRAINT [DF_liq_settlement_lines_sort_order] DEFAULT (100),
  [custom_name] NVARCHAR(MAX) NULL,
  CONSTRAINT [liq_settlement_lines_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [liq_settlement_lines_section_check] CHECK (([section]  IN (N'freight', N'local_ec')))
);
END
GO

-- public.liq_settlements | ~100 filas
IF OBJECT_ID(N'[dbo].[liq_settlements]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[liq_settlements] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_liq_settlements_id] DEFAULT (NEWSEQUENTIALID()),
  [shipment_id] UNIQUEIDENTIFIER NOT NULL,
  [week_of] DATE NULL,
  [status] NVARCHAR(50) NOT NULL CONSTRAINT [DF_liq_settlements_status] DEFAULT (N'draft'),
  [freight_cost_total] DECIMAL(38,10) NOT NULL CONSTRAINT [DF_liq_settlements_freight_cost_total] DEFAULT (0),
  [freight_sale_total] DECIMAL(38,10) NOT NULL CONSTRAINT [DF_liq_settlements_freight_sale_total] DEFAULT (0),
  [local_cost_total] DECIMAL(38,10) NOT NULL CONSTRAINT [DF_liq_settlements_local_cost_total] DEFAULT (0),
  [local_sale_total] DECIMAL(38,10) NOT NULL CONSTRAINT [DF_liq_settlements_local_sale_total] DEFAULT (0),
  [freight_profit] AS CAST((([freight_sale_total] - [freight_cost_total])) AS DECIMAL(38,10)) PERSISTED,
  [local_profit] AS CAST((([local_sale_total] - [local_cost_total])) AS DECIMAL(38,10)) PERSISTED,
  [profit_total] AS CAST(((([freight_sale_total] - [freight_cost_total]) + ([local_sale_total] - [local_cost_total]))) AS DECIMAL(38,10)) PERSISTED,
  [commission_pct] DECIMAL(38,10) NOT NULL CONSTRAINT [DF_liq_settlements_commission_pct] DEFAULT (15),
  [commission_amount] AS CAST(((((([freight_sale_total] - [freight_cost_total]) + ([local_sale_total] - [local_cost_total])) * [commission_pct]) / 100)) AS DECIMAL(38,10)) PERSISTED,
  [profit_net] AS CAST((((([freight_sale_total] - [freight_cost_total]) + ([local_sale_total] - [local_cost_total])) * (1 - ([commission_pct] / 100)))) AS DECIMAL(38,10)) PERSISTED,
  [split_usa_pct] DECIMAL(38,10) NOT NULL CONSTRAINT [DF_liq_settlements_split_usa_pct] DEFAULT (0),
  [elaborated_by] NVARCHAR(MAX) NULL,
  [invoiced_by] NVARCHAR(MAX) NULL,
  [accepted_by_seller_at] DATETIMEOFFSET NULL,
  [notes] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_liq_settlements_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_liq_settlements_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  [split_base] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_liq_settlements_split_base] DEFAULT (N'freight'),
  [commission_borne] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_liq_settlements_commission_borne] DEFAULT (N'ec'),
  [profit_usa] AS CAST((((
CASE
    WHEN ([split_base] = N'freight') THEN ([freight_sale_total] - [freight_cost_total])
    ELSE (([freight_sale_total] - [freight_cost_total]) + ([local_sale_total] - [local_cost_total]))
END * ([split_usa_pct] / 100)) *
CASE
    WHEN ([commission_borne] = N'shared') THEN (1 - ([commission_pct] / 100))
    ELSE 1
END)) AS DECIMAL(38,10)) PERSISTED,
  [profit_ec] AS CAST(((((([freight_sale_total] - [freight_cost_total]) + ([local_sale_total] - [local_cost_total])) * (1 - ([commission_pct] / 100))) - ((
CASE
    WHEN ([split_base] = N'freight') THEN ([freight_sale_total] - [freight_cost_total])
    ELSE (([freight_sale_total] - [freight_cost_total]) + ([local_sale_total] - [local_cost_total]))
END * ([split_usa_pct] / 100)) *
CASE
    WHEN ([commission_borne] = N'shared') THEN (1 - ([commission_pct] / 100))
    ELSE 1
END))) AS DECIMAL(38,10)) PERSISTED,
  [invoice_usa_amount] AS CAST((([freight_cost_total] + ((
CASE
    WHEN ([split_base] = N'freight') THEN ([freight_sale_total] - [freight_cost_total])
    ELSE (([freight_sale_total] - [freight_cost_total]) + ([local_sale_total] - [local_cost_total]))
END * ([split_usa_pct] / 100)) *
CASE
    WHEN ([commission_borne] = N'shared') THEN (1 - ([commission_pct] / 100))
    ELSE 1
END))) AS DECIMAL(38,10)) PERSISTED,
  CONSTRAINT [liq_settlements_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [liq_settlements_shipment_id_key] UNIQUE ([shipment_id]),
  CONSTRAINT [liq_settlements_commission_borne_check] CHECK (([commission_borne]  IN (N'ec', N'shared'))),
  CONSTRAINT [liq_settlements_split_base_check] CHECK (([split_base]  IN (N'freight', N'total'))),
  CONSTRAINT [liq_settlements_status_check] CHECK (([status]  IN (N'draft', N'ready', N'accepted', N'invoiced', N'closed', N'void')))
);
END
GO

-- public.liq_shipments | ~64 filas
IF OBJECT_ID(N'[dbo].[liq_shipments]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[liq_shipments] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_liq_shipments_id] DEFAULT (NEWSEQUENTIALID()),
  [source] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_liq_shipments_source] DEFAULT (N'manual'),
  [magaya_guid] NVARCHAR(255) NULL,
  [mode] NVARCHAR(MAX) NOT NULL,
  [direction] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_liq_shipments_direction] DEFAULT (N'export'),
  [master_number] NVARCHAR(50) NULL,
  [house_number] NVARCHAR(MAX) NULL,
  [gateway] NVARCHAR(MAX) NULL,
  [pol] NVARCHAR(MAX) NULL,
  [pod] NVARCHAR(MAX) NULL,
  [carrier] NVARCHAR(MAX) NULL,
  [provider] NVARCHAR(MAX) NULL,
  [etd] DATE NULL,
  [eta] DATE NULL,
  [week_of] DATE NULL,
  [client_name] NVARCHAR(MAX) NULL,
  [client_ruc] NVARCHAR(MAX) NULL,
  [consignee_final] NVARCHAR(MAX) NULL,
  [asesor] NVARCHAR(MAX) NULL,
  [payment_terms] NVARCHAR(MAX) NULL,
  [chargeable_weight] DECIMAL(38,10) NULL,
  [gross_kg] DECIMAL(38,10) NULL,
  [gross_lb] DECIMAL(38,10) NULL,
  [pieces] INT NULL,
  [cbm] DECIMAL(38,10) NULL,
  [containers] NVARCHAR(MAX) NULL,
  [pu_number] NVARCHAR(MAX) NULL,
  [wr_number] NVARCHAR(MAX) NULL,
  [status] NVARCHAR(50) NOT NULL CONSTRAINT [DF_liq_shipments_status] DEFAULT (N'pending'),
  [notes] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_liq_shipments_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_liq_shipments_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  [gloval_usa_origin] BIT NOT NULL CONSTRAINT [DF_liq_shipments_gloval_usa_origin] DEFAULT (0),
  [origin_agent] NVARCHAR(MAX) NULL,
  CONSTRAINT [liq_shipments_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [liq_shipments_mode_check] CHECK (([mode]  IN (N'air', N'ocean_lcl', N'ocean_fcl', N'other'))),
  CONSTRAINT [liq_shipments_source_check] CHECK (([source]  IN (N'magaya_usa', N'manual', N'excel_import'))),
  CONSTRAINT [liq_shipments_status_check] CHECK (([status]  IN (N'pending', N'in_liquidation', N'liquidated', N'invoiced', N'closed', N'void'))),
  CONSTRAINT [CK_liq_shipments_containers_json] CHECK (ISJSON([containers]) = 1)
);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'liq_shipments_magaya_guid_key' AND object_id = OBJECT_ID(N'[dbo].[liq_shipments]'))
CREATE UNIQUE INDEX [liq_shipments_magaya_guid_key] ON [dbo].[liq_shipments] ([magaya_guid]) WHERE [magaya_guid] IS NOT NULL;
GO

-- public.liq_tariffs | ~19 filas
IF OBJECT_ID(N'[dbo].[liq_tariffs]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[liq_tariffs] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_liq_tariffs_id] DEFAULT (NEWSEQUENTIALID()),
  [charge_code] NVARCHAR(50) NOT NULL,
  [mode] NVARCHAR(50) NOT NULL CONSTRAINT [DF_liq_tariffs_mode] DEFAULT (N'air'),
  [gateway] NVARCHAR(MAX) NULL,
  [lane] NVARCHAR(MAX) NULL,
  [side] NVARCHAR(50) NOT NULL,
  [basis] NVARCHAR(MAX) NOT NULL,
  [rate] DECIMAL(38,10) NOT NULL CONSTRAINT [DF_liq_tariffs_rate] DEFAULT (0),
  [min_amount] DECIMAL(38,10) NULL,
  [currency] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_liq_tariffs_currency] DEFAULT (N'USD'),
  [valid_from] DATE NOT NULL CONSTRAINT [DF_liq_tariffs_valid_from] DEFAULT (CAST(SYSUTCDATETIME() AS DATE)),
  [valid_to] DATE NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_liq_tariffs_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [liq_tariffs_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [liq_tariffs_basis_check] CHECK (([basis]  IN (N'per_kg_chargeable', N'per_lb', N'fixed', N'pct_invoice', N'per_wm', N'per_container', N'manual'))),
  CONSTRAINT [liq_tariffs_side_check] CHECK (([side]  IN (N'cost', N'sale')))
);
END
GO

-- public.ops_capture_mailboxes | ~15 filas
IF OBJECT_ID(N'[dbo].[ops_capture_mailboxes]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[ops_capture_mailboxes] (
  [email] NVARCHAR(100) NOT NULL,
  [activo] BIT NOT NULL CONSTRAINT [DF_ops_capture_mailboxes_activo] DEFAULT (1),
  [nota] NVARCHAR(MAX) NULL,
  [oficina] NVARCHAR(MAX) NULL,
  [captura_sin_adjunto] BIT NOT NULL CONSTRAINT [DF_ops_capture_mailboxes_captura_sin_adjunto] DEFAULT (0),
  CONSTRAINT [ops_capture_mailboxes_pkey] PRIMARY KEY ([email])
);
END
GO

-- public.ops_client_notices | ~2 filas
IF OBJECT_ID(N'[dbo].[ops_client_notices]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[ops_client_notices] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_ops_client_notices_id] DEFAULT (NEWSEQUENTIALID()),
  [shipment_id] UNIQUEIDENTIFIER NOT NULL,
  [notice_type] NVARCHAR(50) NOT NULL,
  [sent_to] NVARCHAR(MAX) NOT NULL,
  [sent_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_ops_client_notices_sent_at] DEFAULT (SYSDATETIMEOFFSET()),
  [eta_at_send] DATE NULL,
  [payload] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_ops_client_notices_payload] DEFAULT (N'{}'),
  CONSTRAINT [ops_client_notices_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [CK_ops_client_notices_payload_json] CHECK (ISJSON([payload]) = 1)
);
END
GO

-- public.ops_devolucion_vacios | ~10 filas
IF OBJECT_ID(N'[dbo].[ops_devolucion_vacios]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[ops_devolucion_vacios] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_ops_devolucion_vacios_id] DEFAULT (NEWSEQUENTIALID()),
  [office] NVARCHAR(50) NOT NULL,
  [shipment_id] UNIQUEIDENTIFIER NULL,
  [shipment_container_id] UNIQUEIDENTIFIER NULL,
  [container_number] NVARCHAR(MAX) NOT NULL,
  [size_type] NVARCHAR(MAX) NULL,
  [naviera] NVARCHAR(MAX) NULL,
  [fecha_descarga] DATE NULL,
  [fecha_retiro] DATE NULL,
  [dias_libres] INT NOT NULL CONSTRAINT [DF_ops_devolucion_vacios_dias_libres] DEFAULT (15),
  [fecha_limite] AS CAST(((DATEADD(day, [dias_libres], COALESCE([fecha_retiro], [fecha_descarga])))) AS DATE) PERSISTED,
  [fecha_devolucion] DATE NULL,
  [deposito] NVARCHAR(MAX) NULL,
  [eir] NVARCHAR(MAX) NULL,
  [notas] NVARCHAR(MAX) NULL,
  [created_by] UNIQUEIDENTIFIER NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_ops_devolucion_vacios_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_ops_devolucion_vacios_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [ops_devolucion_vacios_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.ops_documents | ~7,261 filas
IF OBJECT_ID(N'[dbo].[ops_documents]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[ops_documents] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_ops_documents_id] DEFAULT (NEWSEQUENTIALID()),
  [shipment_id] UNIQUEIDENTIFIER NOT NULL,
  [file_name] NVARCHAR(MAX) NOT NULL,
  [file_type] NVARCHAR(MAX) NULL,
  [file_size] INT NULL,
  [file_url] NVARCHAR(MAX) NOT NULL,
  [document_type] NVARCHAR(50) NOT NULL CONSTRAINT [DF_ops_documents_document_type] DEFAULT (N'OTRO'),
  [version] INT NOT NULL CONSTRAINT [DF_ops_documents_version] DEFAULT (1),
  [source] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_ops_documents_source] DEFAULT (N'MANUAL'),
  [processing_status] NVARCHAR(50) NOT NULL CONSTRAINT [DF_ops_documents_processing_status] DEFAULT (N'PENDING'),
  [extracted_json] NVARCHAR(MAX) NULL,
  [error_detail] NVARCHAR(MAX) NULL,
  [applied_at] DATETIMEOFFSET NULL,
  [applied_by] UNIQUEIDENTIFIER NULL,
  [uploaded_by] UNIQUEIDENTIFIER NULL,
  [notes] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_ops_documents_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [ops_documents_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [CK_ops_documents_document_type_enum] CHECK ([document_type] IN (N'MBL', N'HBL', N'DRAFT_BL', N'AWB', N'PACKING', N'FACTURA_COMERCIAL', N'CERT_ORIGEN', N'AVISO_ZARPE', N'AVISO_LLEGADA', N'MANIFIESTO', N'CAS', N'OTRO', N'MBL_INSTRUCTION', N'SHIPPING_INSTRUCTION')),
  CONSTRAINT [CK_ops_documents_processing_status_enum] CHECK ([processing_status] IN (N'PENDING', N'PROCESSING', N'PARSED', N'IMPORTED', N'ERROR')),
  CONSTRAINT [CK_ops_documents_extracted_json_json] CHECK (ISJSON([extracted_json]) = 1)
);
END
GO

-- public.ops_hbl | ~227 filas
IF OBJECT_ID(N'[dbo].[ops_hbl]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[ops_hbl] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_ops_hbl_id] DEFAULT (NEWSEQUENTIALID()),
  [shipment_id] UNIQUEIDENTIFIER NOT NULL,
  [hbl_number] NVARCHAR(50) NULL,
  [status] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_ops_hbl_status] DEFAULT (N'DRAFT'),
  [data] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_ops_hbl_data] DEFAULT (N'{}'),
  [port_code] NVARCHAR(MAX) NULL,
  [issued_at] DATETIMEOFFSET NULL,
  [issued_by] UNIQUEIDENTIFIER NULL,
  [created_by] UNIQUEIDENTIFIER NULL,
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_ops_hbl_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  [originals_printed] INT NOT NULL CONSTRAINT [DF_ops_hbl_originals_printed] DEFAULT (0),
  [master_id] UNIQUEIDENTIFIER NULL,
  [non_negotiables_printed] INT NOT NULL CONSTRAINT [DF_ops_hbl_non_negotiables_printed] DEFAULT (0),
  CONSTRAINT [ops_hbl_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [ops_hbl_non_negotiables_printed_check] CHECK ((([non_negotiables_printed] >= 0) AND ([non_negotiables_printed] <= 4))),
  CONSTRAINT [ops_hbl_originals_printed_check] CHECK ((([originals_printed] >= 0) AND ([originals_printed] <= 3))),
  CONSTRAINT [CK_ops_hbl_data_json] CHECK (ISJSON([data]) = 1)
);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ops_hbl_hbl_number_key' AND object_id = OBJECT_ID(N'[dbo].[ops_hbl]'))
CREATE UNIQUE INDEX [ops_hbl_hbl_number_key] ON [dbo].[ops_hbl] ([hbl_number]) WHERE [hbl_number] IS NOT NULL;
GO

-- public.ops_hbl_sequence | ~1 filas
IF OBJECT_ID(N'[dbo].[ops_hbl_sequence]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[ops_hbl_sequence] (
  [office_code] NVARCHAR(50) NOT NULL,
  [year] INT NOT NULL,
  [last_number] INT NOT NULL CONSTRAINT [DF_ops_hbl_sequence_last_number] DEFAULT (0),
  CONSTRAINT [ops_hbl_sequence_pkey] PRIMARY KEY ([office_code], [year])
);
END
GO

-- public.ops_inbound_emails | ~69,617 filas
IF OBJECT_ID(N'[dbo].[ops_inbound_emails]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[ops_inbound_emails] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_ops_inbound_emails_id] DEFAULT (NEWSEQUENTIALID()),
  [mailbox] NVARCHAR(100) NOT NULL,
  [message_id] NVARCHAR(450) NOT NULL,
  [graph_id] NVARCHAR(MAX) NULL,
  [conversation_id] NVARCHAR(MAX) NULL,
  [subject] NVARCHAR(MAX) NULL,
  [sender] NVARCHAR(MAX) NULL,
  [received_at] DATETIMEOFFSET NULL,
  [has_attachments] BIT NOT NULL CONSTRAINT [DF_ops_inbound_emails_has_attachments] DEFAULT (0),
  [refs] NVARCHAR(MAX) NULL,
  [shipment_id] UNIQUEIDENTIFIER NULL,
  [match_by] NVARCHAR(MAX) NULL,
  [docs_creados] INT NOT NULL CONSTRAINT [DF_ops_inbound_emails_docs_creados] DEFAULT (0),
  [status] NVARCHAR(50) NOT NULL CONSTRAINT [DF_ops_inbound_emails_status] DEFAULT (N'PENDIENTE'),
  [error] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_ops_inbound_emails_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [body_preview] NVARCHAR(MAX) NULL,
  [si_estado] NVARCHAR(50) NULL,
  [si_resuelta_por] UNIQUEIDENTIFIER NULL,
  [si_resuelta_at] DATETIMEOFFSET NULL,
  CONSTRAINT [ops_inbound_emails_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [ops_inbound_emails_si_estado_check] CHECK ((([si_estado] IS NULL) OR ([si_estado]  IN (N'PENDIENTE', N'CONVERTIDA', N'DESCARTADA')))),
  CONSTRAINT [ops_inbound_emails_status_check] CHECK (([status]  IN (N'PENDIENTE', N'VINCULADO', N'SIN_MATCH', N'IGNORADO', N'ERROR', N'SI_CANDIDATA'))),
  CONSTRAINT [CK_ops_inbound_emails_refs_json] CHECK (ISJSON([refs]) = 1)
);
END
GO

-- public.ops_master | ~5 filas
IF OBJECT_ID(N'[dbo].[ops_master]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[ops_master] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_ops_master_id] DEFAULT (NEWSEQUENTIALID()),
  [mbl] NVARCHAR(50) NULL,
  [data] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_ops_master_data] DEFAULT (N'{}'),
  [created_by] UNIQUEIDENTIFIER NULL,
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_ops_master_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [ops_master_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [CK_ops_master_data_json] CHECK (ISJSON([data]) = 1)
);
END
GO

-- public.ops_release | ~1 filas
IF OBJECT_ID(N'[dbo].[ops_release]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[ops_release] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_ops_release_id] DEFAULT (NEWSEQUENTIALID()),
  [shipment_id] UNIQUEIDENTIFIER NOT NULL,
  [credit_ok] BIT NOT NULL CONSTRAINT [DF_ops_release_credit_ok] DEFAULT (0),
  [credit_checked_at] DATETIMEOFFSET NULL,
  [credit_note] NVARCHAR(MAX) NULL,
  [local_charges_paid] BIT NOT NULL CONSTRAINT [DF_ops_release_local_charges_paid] DEFAULT (0),
  [local_charges_paid_at] DATETIMEOFFSET NULL,
  [bl_liberado] BIT NOT NULL CONSTRAINT [DF_ops_release_bl_liberado] DEFAULT (0),
  [bl_liberado_at] DATETIMEOFFSET NULL,
  [salida_autorizada] BIT NOT NULL CONSTRAINT [DF_ops_release_salida_autorizada] DEFAULT (0),
  [salida_autorizada_at] DATETIMEOFFSET NULL,
  [cas_issued] BIT NOT NULL CONSTRAINT [DF_ops_release_cas_issued] DEFAULT (0),
  [cas_issued_at] DATETIMEOFFSET NULL,
  [cas_document_id] UNIQUEIDENTIFIER NULL,
  [authorized_by] UNIQUEIDENTIFIER NULL,
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_ops_release_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [ops_release_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [ops_release_shipment_id_key] UNIQUE ([shipment_id])
);
END
GO

-- public.ops_transfers | ~24 filas
IF OBJECT_ID(N'[dbo].[ops_transfers]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[ops_transfers] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_ops_transfers_id] DEFAULT (NEWSEQUENTIALID()),
  [shipment_id] UNIQUEIDENTIFIER NOT NULL,
  [transferred_by] UNIQUEIDENTIFIER NOT NULL,
  [transferred_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_ops_transfers_transferred_at] DEFAULT (SYSDATETIMEOFFSET()),
  [received_by] UNIQUEIDENTIFIER NULL,
  [ops_status] NVARCHAR(50) NOT NULL CONSTRAINT [DF_ops_transfers_ops_status] DEFAULT (N'RECIBIDO'),
  [next_milestone_due] DATE NULL,
  [notes] NVARCHAR(MAX) NULL,
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_ops_transfers_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  [handoff_estado] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_ops_transfers_handoff_estado] DEFAULT (N'PENDIENTE'),
  [received_at] DATETIMEOFFSET NULL,
  [returned_by] UNIQUEIDENTIFIER NULL,
  [returned_at] DATETIMEOFFSET NULL,
  [return_reason] NVARCHAR(MAX) NULL,
  CONSTRAINT [ops_transfers_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [ops_transfers_shipment_id_key] UNIQUE ([shipment_id]),
  CONSTRAINT [ops_transfers_handoff_estado_check] CHECK (([handoff_estado]  IN (N'PENDIENTE', N'ACEPTADO', N'DEVUELTO'))),
  CONSTRAINT [CK_ops_transfers_ops_status_enum] CHECK ([ops_status] IN (N'RECIBIDO', N'DOCUMENTACION', N'DECLARACION', N'BOOKING_CUTOFF', N'TRANSITO', N'PRE_ARRIBO', N'ADUANA', N'LIBERACION', N'ENTREGADO'))
);
END
GO

-- public.shipment_action_items | ~2,129 filas
IF OBJECT_ID(N'[dbo].[shipment_action_items]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[shipment_action_items] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_shipment_action_items_id] DEFAULT (NEWSEQUENTIALID()),
  [shipment_id] UNIQUEIDENTIFIER NOT NULL,
  [title] NVARCHAR(MAX) NOT NULL,
  [details] NVARCHAR(MAX) NULL,
  [due_date] DATE NULL,
  [assigned_to] UNIQUEIDENTIFIER NULL,
  [priority] NVARCHAR(MAX) NULL CONSTRAINT [DF_shipment_action_items_priority] DEFAULT (N'NORMAL'),
  [status] NVARCHAR(50) NULL CONSTRAINT [DF_shipment_action_items_status] DEFAULT (N'OPEN'),
  [source_agent] NVARCHAR(MAX) NULL,
  [completed_at] DATETIMEOFFSET NULL,
  [completed_by] UNIQUEIDENTIFIER NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_shipment_action_items_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [shipment_action_items_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.shipment_agents | ~776 filas
IF OBJECT_ID(N'[dbo].[shipment_agents]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[shipment_agents] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_shipment_agents_id] DEFAULT (NEWSEQUENTIALID()),
  [shipment_id] UNIQUEIDENTIFIER NOT NULL,
  [name] NVARCHAR(MAX) NOT NULL,
  [agent_role] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_shipment_agents_agent_role] DEFAULT (N'ORIGIN'),
  [contact_name] NVARCHAR(MAX) NULL,
  [contact_email] NVARCHAR(MAX) NULL,
  [contact_phone] NVARCHAR(MAX) NULL,
  [city] NVARCHAR(MAX) NULL,
  [country] NVARCHAR(MAX) NULL,
  [notes] NVARCHAR(MAX) NULL,
  [position] INT NOT NULL CONSTRAINT [DF_shipment_agents_position] DEFAULT (0),
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_shipment_agents_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [created_by] UNIQUEIDENTIFIER NULL,
  CONSTRAINT [shipment_agents_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [shipment_agents_agent_role_check] CHECK (([agent_role]  IN (N'ORIGIN', N'DESTINATION', N'CUSTOMS', N'FREIGHT_FORWARDER', N'NVOCC', N'OTHER')))
);
END
GO

-- public.shipment_containers | ~562 filas
IF OBJECT_ID(N'[dbo].[shipment_containers]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[shipment_containers] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_shipment_containers_id] DEFAULT (NEWSEQUENTIALID()),
  [shipment_id] UNIQUEIDENTIFIER NOT NULL,
  [container_number] NVARCHAR(50) NULL,
  [size_type] NVARCHAR(MAX) NULL,
  [seal] NVARCHAR(MAX) NULL,
  [is_reefer] BIT NULL CONSTRAINT [DF_shipment_containers_is_reefer] DEFAULT (0),
  [temperature_setting] NVARCHAR(MAX) NULL,
  [temperature_validated_at] DATETIMEOFFSET NULL,
  [temperature_validated_by] UNIQUEIDENTIFIER NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_shipment_containers_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [quantity] INT NOT NULL CONSTRAINT [DF_shipment_containers_quantity] DEFAULT (1),
  [position] INT NOT NULL CONSTRAINT [DF_shipment_containers_position] DEFAULT (0),
  [created_by] UNIQUEIDENTIFIER NULL,
  CONSTRAINT [shipment_containers_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [shipment_containers_quantity_check] CHECK (([quantity] > 0))
);
END
GO

-- public.shipment_events | ~4,474 filas
IF OBJECT_ID(N'[dbo].[shipment_events]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[shipment_events] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_shipment_events_id] DEFAULT (NEWSEQUENTIALID()),
  [shipment_id] UNIQUEIDENTIFIER NOT NULL,
  [event_type] NVARCHAR(255) NOT NULL,
  [occurred_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_shipment_events_occurred_at] DEFAULT (SYSDATETIMEOFFSET()),
  [description] NVARCHAR(MAX) NULL,
  [source] NVARCHAR(50) NOT NULL CONSTRAINT [DF_shipment_events_source] DEFAULT (N'MANUAL'),
  [created_by] UNIQUEIDENTIFIER NULL,
  [metadata] NVARCHAR(MAX) NULL CONSTRAINT [DF_shipment_events_metadata] DEFAULT (N'{}'),
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_shipment_events_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [shipment_events_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [CK_shipment_events_source_enum] CHECK ([source] IN (N'MANUAL', N'MAGAYA', N'EMAIL_AGENT', N'SLA_AGENT', N'SYSTEM')),
  CONSTRAINT [CK_shipment_events_metadata_json] CHECK (ISJSON([metadata]) = 1)
);
END
GO

-- public.shipment_shippers | ~946 filas
IF OBJECT_ID(N'[dbo].[shipment_shippers]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[shipment_shippers] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_shipment_shippers_id] DEFAULT (NEWSEQUENTIALID()),
  [shipment_id] UNIQUEIDENTIFIER NOT NULL,
  [name] NVARCHAR(MAX) NOT NULL,
  [incoterm] NVARCHAR(MAX) NULL,
  [origin_port] NVARCHAR(MAX) NULL,
  [po_number] NVARCHAR(MAX) NULL,
  [notes] NVARCHAR(MAX) NULL,
  [position] INT NOT NULL CONSTRAINT [DF_shipment_shippers_position] DEFAULT (0),
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_shipment_shippers_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [created_by] UNIQUEIDENTIFIER NULL,
  CONSTRAINT [shipment_shippers_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.shipments | ~1,681 filas
IF OBJECT_ID(N'[dbo].[shipments]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[shipments] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_shipments_id] DEFAULT (NEWSEQUENTIALID()),
  [shipment_code] NVARCHAR(50) NULL,
  [magaya_shipment_id] UNIQUEIDENTIFIER NULL,
  [client_id] UNIQUEIDENTIFIER NULL,
  [office] NVARCHAR(50) NOT NULL,
  [sales_executive_id] UNIQUEIDENTIFIER NULL,
  [cs_assigned_to] UNIQUEIDENTIFIER NULL,
  [mode] NVARCHAR(50) NOT NULL,
  [direction] NVARCHAR(50) NOT NULL,
  [status] NVARCHAR(50) NOT NULL CONSTRAINT [DF_shipments_status] DEFAULT (N'BOOKING'),
  [carrier] NVARCHAR(MAX) NULL,
  [origin_port] NVARCHAR(MAX) NULL,
  [destination_port] NVARCHAR(MAX) NULL,
  [etd] DATE NULL,
  [eta] DATE NULL,
  [eta_text] NVARCHAR(MAX) NULL,
  [incoterm] NVARCHAR(MAX) NULL,
  [supplier] NVARCHAR(MAX) NULL,
  [booking_ref] NVARCHAR(MAX) NULL,
  [mbl] NVARCHAR(MAX) NULL,
  [hbl] NVARCHAR(MAX) NULL,
  [pba_amount] DECIMAL(12,2) NULL,
  [pba_currency] NVARCHAR(MAX) NULL CONSTRAINT [DF_shipments_pba_currency] DEFAULT (N'USD'),
  [pba_status] NVARCHAR(50) NULL,
  [created_by] UNIQUEIDENTIFIER NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_shipments_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_shipments_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  [search_text] AS CAST((CONCAT(COALESCE([booking_ref], N''), N' ', COALESCE([mbl], N''), N' ', COALESCE([hbl], N''), N' ', COALESCE([carrier], N''), N' ', COALESCE([supplier], N''))) AS NVARCHAR(MAX)) PERSISTED,
  [archived_at] DATETIMEOFFSET NULL,
  [archived_by] UNIQUEIDENTIFIER NULL,
  [consignee_name] NVARCHAR(MAX) NULL,
  [vessel_name] NVARCHAR(MAX) NULL,
  [voyage] NVARCHAR(MAX) NULL,
  [via_origen] NVARCHAR(50) NULL,
  [equipment_type] NVARCHAR(50) NULL,
  [no_contenerizado] BIT NOT NULL CONSTRAINT [DF_shipments_no_contenerizado] DEFAULT (0),
  [destino_tipo] NVARCHAR(50) NULL,
  [destino_office] NVARCHAR(MAX) NULL,
  [destino_agent_id] UNIQUEIDENTIFIER NULL,
  [consolidado_id] UNIQUEIDENTIFIER NULL,
  [master_shipment_id] UNIQUEIDENTIFIER NULL,
  [is_master] BIT NOT NULL CONSTRAINT [DF_shipments_is_master] DEFAULT (0),
  CONSTRAINT [shipments_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [CK_shipments_mode_enum] CHECK ([mode] IN (N'FCL', N'LCL', N'AIR', N'COURIER', N'BREAKBULK', N'RORO')),
  CONSTRAINT [CK_shipments_direction_enum] CHECK ([direction] IN (N'IMPORT', N'EXPORT', N'CROSSTRADE')),
  CONSTRAINT [CK_shipments_status_enum] CHECK ([status] IN (N'BOOKING', N'IN_WAREHOUSE', N'LOADED', N'IN_TRANSIT', N'ARRIVED', N'CUSTOMS', N'RELEASED', N'DELIVERED', N'CANCELLED')),
  CONSTRAINT [CK_shipments_pba_status_enum] CHECK ([pba_status] IN (N'PENDING', N'REMINDED', N'PAID', N'WRITTEN_OFF')),
  CONSTRAINT [CK_shipments_via_origen_enum] CHECK ([via_origen] IN (N'BODEGA', N'FUERA_BODEGA', N'CONSOLIDADO')),
  CONSTRAINT [CK_shipments_equipment_type_enum] CHECK ([equipment_type] IN (N'DRY', N'REEFER', N'NOR', N'FLAT_RACK', N'OPEN_TOP', N'RORO', N'BREAK_BULK')),
  CONSTRAINT [CK_shipments_destino_tipo_enum] CHECK ([destino_tipo] IN (N'GLOVAL_OFFICE', N'EXTERNAL_AGENT'))
);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'shipments_shipment_code_key' AND object_id = OBJECT_ID(N'[dbo].[shipments]'))
CREATE UNIQUE INDEX [shipments_shipment_code_key] ON [dbo].[shipments] ([shipment_code]) WHERE [shipment_code] IS NOT NULL;
GO

-- public.shipping_instructions | ~818 filas
IF OBJECT_ID(N'[dbo].[shipping_instructions]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[shipping_instructions] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_shipping_instructions_id] DEFAULT (NEWSEQUENTIALID()),
  [si_number] NVARCHAR(50) NOT NULL,
  [quote_id] UNIQUEIDENTIFIER NULL,
  [status] NVARCHAR(50) NOT NULL CONSTRAINT [DF_shipping_instructions_status] DEFAULT (N'draft'),
  [office] NVARCHAR(MAX) NULL,
  [sales_executive_id] UNIQUEIDENTIFIER NULL,
  [client_id] UNIQUEIDENTIFIER NULL,
  [created_by] UNIQUEIDENTIFIER NULL,
  [mode] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_shipping_instructions_mode] DEFAULT (N'LCL'),
  [direction] NVARCHAR(MAX) NULL CONSTRAINT [DF_shipping_instructions_direction] DEFAULT (N'EXPORT'),
  [incoterm] NVARCHAR(MAX) NULL,
  [payment_terms] NVARCHAR(MAX) NULL,
  [origin_port] NVARCHAR(MAX) NULL,
  [destination_port] NVARCHAR(MAX) NULL,
  [etd] DATE NULL,
  [eta] DATE NULL,
  [carrier] NVARCHAR(MAX) NULL,
  [booking_ref] NVARCHAR(MAX) NULL,
  [mbl] NVARCHAR(MAX) NULL,
  [hbl] NVARCHAR(MAX) NULL,
  [shipper_name] NVARCHAR(MAX) NULL,
  [shipper_address] NVARCHAR(MAX) NULL,
  [consignee_name] NVARCHAR(MAX) NULL,
  [consignee_address] NVARCHAR(MAX) NULL,
  [consignee_ruc] NVARCHAR(MAX) NULL,
  [notify_name] NVARCHAR(MAX) NULL,
  [notify_address] NVARCHAR(MAX) NULL,
  [commodity] NVARCHAR(MAX) NULL,
  [hs_codes] NVARCHAR(MAX) NULL,
  [pieces] INT NULL,
  [gross_kg] DECIMAL(38,10) NULL,
  [gross_lb] DECIMAL(38,10) NULL,
  [chargeable_weight_kg] DECIMAL(38,10) NULL,
  [cbm] DECIMAL(38,10) NULL,
  [containers] NVARCHAR(MAX) NULL,
  [hazmat] BIT NULL CONSTRAINT [DF_shipping_instructions_hazmat] DEFAULT (0),
  [hazmat_detail] NVARCHAR(MAX) NULL,
  [special_instructions] NVARCHAR(MAX) NULL,
  [origin_agent] NVARCHAR(MAX) NULL,
  [origin_share_pct] DECIMAL(38,10) NULL,
  [shipment_id] UNIQUEIDENTIFIER NULL,
  [confirmed_at] DATETIMEOFFSET NULL,
  [confirmed_by] UNIQUEIDENTIFIER NULL,
  [liq_shipment_id] UNIQUEIDENTIFIER NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_shipping_instructions_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_shipping_instructions_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  [cost_total] DECIMAL(38,10) NULL,
  [sale_total] DECIMAL(38,10) NULL,
  [profit_total] DECIMAL(38,10) NULL,
  [cnee_final] NVARCHAR(MAX) NULL,
  [transit_time] NVARCHAR(MAX) NULL,
  [fx_rate] DECIMAL(38,10) NULL,
  [fx_currency] NVARCHAR(MAX) NULL,
  [fx_source] NVARCHAR(MAX) NULL,
  [fx_date] DATE NULL,
  [archived_at] DATETIMEOFFSET NULL,
  [archived_by] UNIQUEIDENTIFIER NULL,
  CONSTRAINT [shipping_instructions_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [shipping_instructions_si_number_key] UNIQUE ([si_number]),
  CONSTRAINT [shipping_instructions_mode_check] CHECK (([mode]  IN (N'FCL', N'LCL', N'AIR', N'COURIER', N'BREAKBULK', N'RORO'))),
  CONSTRAINT [shipping_instructions_status_check] CHECK (([status]  IN (N'draft', N'confirmed', N'cancelled'))),
  CONSTRAINT [CK_shipping_instructions_containers_json] CHECK (ISJSON([containers]) = 1)
);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'carrier_email_carrier_idx' AND object_id = OBJECT_ID(N'[dbo].[carrier_email_log]'))
CREATE INDEX [carrier_email_carrier_idx] ON [dbo].[carrier_email_log] ([carrier_detected]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'carrier_email_shipment_idx' AND object_id = OBJECT_ID(N'[dbo].[carrier_email_log]'))
CREATE INDEX [carrier_email_shipment_idx] ON [dbo].[carrier_email_log] ([matched_shipment_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'carrier_email_status_idx' AND object_id = OBJECT_ID(N'[dbo].[carrier_email_log]'))
CREATE INDEX [carrier_email_status_idx] ON [dbo].[carrier_email_log] ([parse_status]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_clr_source' AND object_id = OBJECT_ID(N'[dbo].[container_load_reports]'))
CREATE INDEX [idx_clr_source] ON [dbo].[container_load_reports] ([manifest_source_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'coordination_tasks_cs_idx' AND object_id = OBJECT_ID(N'[dbo].[coordination_tasks]'))
CREATE INDEX [coordination_tasks_cs_idx] ON [dbo].[coordination_tasks] ([cs_assigned_to]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'coordination_tasks_scheduled_idx' AND object_id = OBJECT_ID(N'[dbo].[coordination_tasks]'))
CREATE INDEX [coordination_tasks_scheduled_idx] ON [dbo].[coordination_tasks] ([scheduled_date]) WHERE ([status]  IN (N'OPEN', N'IN_PROGRESS'));
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'coordination_tasks_shipment_idx' AND object_id = OBJECT_ID(N'[dbo].[coordination_tasks]'))
CREATE INDEX [coordination_tasks_shipment_idx] ON [dbo].[coordination_tasks] ([shipment_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'coordination_tasks_status_idx' AND object_id = OBJECT_ID(N'[dbo].[coordination_tasks]'))
CREATE INDEX [coordination_tasks_status_idx] ON [dbo].[coordination_tasks] ([status]) WHERE ([archived_at] IS NULL);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'fact_orders_ship_idx' AND object_id = OBJECT_ID(N'[dbo].[fact_orders]'))
CREATE INDEX [fact_orders_ship_idx] ON [dbo].[fact_orders] ([shipment_id], [kind]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'fcl_semanal_cliente_idx' AND object_id = OBJECT_ID(N'[dbo].[fcl_semanal]'))
CREATE INDEX [fcl_semanal_cliente_idx] ON [dbo].[fcl_semanal] ([cliente]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'fcl_semanal_semana_idx' AND object_id = OBJECT_ID(N'[dbo].[fcl_semanal]'))
CREATE INDEX [fcl_semanal_semana_idx] ON [dbo].[fcl_semanal] ([anio], [semana], [office]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_liq_agent_inv_lines' AND object_id = OBJECT_ID(N'[dbo].[liq_agent_invoice_lines]'))
CREATE INDEX [idx_liq_agent_inv_lines] ON [dbo].[liq_agent_invoice_lines] ([invoice_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_liq_agent_inv_master' AND object_id = OBJECT_ID(N'[dbo].[liq_agent_invoices]'))
CREATE INDEX [idx_liq_agent_inv_master] ON [dbo].[liq_agent_invoices] ([master_number]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_liq_lines_settlement' AND object_id = OBJECT_ID(N'[dbo].[liq_settlement_lines]'))
CREATE INDEX [idx_liq_lines_settlement] ON [dbo].[liq_settlement_lines] ([settlement_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_liq_settlements_status' AND object_id = OBJECT_ID(N'[dbo].[liq_settlements]'))
CREATE INDEX [idx_liq_settlements_status] ON [dbo].[liq_settlements] ([status]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_liq_settlements_week' AND object_id = OBJECT_ID(N'[dbo].[liq_settlements]'))
CREATE INDEX [idx_liq_settlements_week] ON [dbo].[liq_settlements] ([week_of]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_liq_shipments_master' AND object_id = OBJECT_ID(N'[dbo].[liq_shipments]'))
CREATE INDEX [idx_liq_shipments_master] ON [dbo].[liq_shipments] ([master_number]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_liq_shipments_status' AND object_id = OBJECT_ID(N'[dbo].[liq_shipments]'))
CREATE INDEX [idx_liq_shipments_status] ON [dbo].[liq_shipments] ([status]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_liq_shipments_week' AND object_id = OBJECT_ID(N'[dbo].[liq_shipments]'))
CREATE INDEX [idx_liq_shipments_week] ON [dbo].[liq_shipments] ([week_of]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_liq_tariffs_lookup' AND object_id = OBJECT_ID(N'[dbo].[liq_tariffs]'))
CREATE INDEX [idx_liq_tariffs_lookup] ON [dbo].[liq_tariffs] ([charge_code], [mode], [side], [valid_from]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ops_client_notices_ship_idx' AND object_id = OBJECT_ID(N'[dbo].[ops_client_notices]'))
CREATE INDEX [ops_client_notices_ship_idx] ON [dbo].[ops_client_notices] ([shipment_id], [notice_type], [sent_at] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ops_vacios_container_uq' AND object_id = OBJECT_ID(N'[dbo].[ops_devolucion_vacios]'))
CREATE UNIQUE INDEX [ops_vacios_container_uq] ON [dbo].[ops_devolucion_vacios] ([shipment_container_id]) WHERE ([shipment_container_id] IS NOT NULL) AND [shipment_container_id] IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ops_vacios_office_limite_idx' AND object_id = OBJECT_ID(N'[dbo].[ops_devolucion_vacios]'))
CREATE INDEX [ops_vacios_office_limite_idx] ON [dbo].[ops_devolucion_vacios] ([office], [fecha_limite]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ops_documents_shipment_idx' AND object_id = OBJECT_ID(N'[dbo].[ops_documents]'))
CREATE INDEX [ops_documents_shipment_idx] ON [dbo].[ops_documents] ([shipment_id], [created_at] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ops_documents_status_idx' AND object_id = OBJECT_ID(N'[dbo].[ops_documents]'))
CREATE INDEX [ops_documents_status_idx] ON [dbo].[ops_documents] ([processing_status]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ops_hbl_master_idx' AND object_id = OBJECT_ID(N'[dbo].[ops_hbl]'))
CREATE INDEX [ops_hbl_master_idx] ON [dbo].[ops_hbl] ([master_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ops_hbl_shipment_idx' AND object_id = OBJECT_ID(N'[dbo].[ops_hbl]'))
CREATE INDEX [ops_hbl_shipment_idx] ON [dbo].[ops_hbl] ([shipment_id], [updated_at]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ops_inbound_emails_msg_uq' AND object_id = OBJECT_ID(N'[dbo].[ops_inbound_emails]'))
CREATE UNIQUE INDEX [ops_inbound_emails_msg_uq] ON [dbo].[ops_inbound_emails] ([mailbox], [message_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ops_inbound_emails_shipment_idx' AND object_id = OBJECT_ID(N'[dbo].[ops_inbound_emails]'))
CREATE INDEX [ops_inbound_emails_shipment_idx] ON [dbo].[ops_inbound_emails] ([shipment_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ops_inbound_emails_si_idx' AND object_id = OBJECT_ID(N'[dbo].[ops_inbound_emails]'))
CREATE INDEX [ops_inbound_emails_si_idx] ON [dbo].[ops_inbound_emails] ([si_estado], [received_at] DESC) WHERE ([si_estado] IS NOT NULL);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ops_inbound_emails_status_idx' AND object_id = OBJECT_ID(N'[dbo].[ops_inbound_emails]'))
CREATE INDEX [ops_inbound_emails_status_idx] ON [dbo].[ops_inbound_emails] ([status], [received_at] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ops_master_mbl_idx' AND object_id = OBJECT_ID(N'[dbo].[ops_master]'))
CREATE INDEX [ops_master_mbl_idx] ON [dbo].[ops_master] ([mbl]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ops_transfers_status_idx' AND object_id = OBJECT_ID(N'[dbo].[ops_transfers]'))
CREATE INDEX [ops_transfers_status_idx] ON [dbo].[ops_transfers] ([ops_status]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'action_items_assigned_idx' AND object_id = OBJECT_ID(N'[dbo].[shipment_action_items]'))
CREATE INDEX [action_items_assigned_idx] ON [dbo].[shipment_action_items] ([assigned_to], [status]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'action_items_due_idx' AND object_id = OBJECT_ID(N'[dbo].[shipment_action_items]'))
CREATE INDEX [action_items_due_idx] ON [dbo].[shipment_action_items] ([due_date]) WHERE ([status] = N'OPEN');
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'action_items_shipment_idx' AND object_id = OBJECT_ID(N'[dbo].[shipment_action_items]'))
CREATE INDEX [action_items_shipment_idx] ON [dbo].[shipment_action_items] ([shipment_id], [status]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_shipment_action_items_completed_by' AND object_id = OBJECT_ID(N'[dbo].[shipment_action_items]'))
CREATE INDEX [idx_shipment_action_items_completed_by] ON [dbo].[shipment_action_items] ([completed_by]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'shipment_agents_shipment_idx' AND object_id = OBJECT_ID(N'[dbo].[shipment_agents]'))
CREATE INDEX [shipment_agents_shipment_idx] ON [dbo].[shipment_agents] ([shipment_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'containers_number_idx' AND object_id = OBJECT_ID(N'[dbo].[shipment_containers]'))
CREATE INDEX [containers_number_idx] ON [dbo].[shipment_containers] ([container_number]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'containers_shipment_idx' AND object_id = OBJECT_ID(N'[dbo].[shipment_containers]'))
CREATE INDEX [containers_shipment_idx] ON [dbo].[shipment_containers] ([shipment_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_shipment_containers_temperature_validated_by' AND object_id = OBJECT_ID(N'[dbo].[shipment_containers]'))
CREATE INDEX [idx_shipment_containers_temperature_validated_by] ON [dbo].[shipment_containers] ([temperature_validated_by]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_shipment_events_created_by' AND object_id = OBJECT_ID(N'[dbo].[shipment_events]'))
CREATE INDEX [idx_shipment_events_created_by] ON [dbo].[shipment_events] ([created_by]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'shipment_events_shipment_idx' AND object_id = OBJECT_ID(N'[dbo].[shipment_events]'))
CREATE INDEX [shipment_events_shipment_idx] ON [dbo].[shipment_events] ([shipment_id], [occurred_at] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'shipment_events_type_idx' AND object_id = OBJECT_ID(N'[dbo].[shipment_events]'))
CREATE INDEX [shipment_events_type_idx] ON [dbo].[shipment_events] ([event_type]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'shipment_shippers_shipment_idx' AND object_id = OBJECT_ID(N'[dbo].[shipment_shippers]'))
CREATE INDEX [shipment_shippers_shipment_idx] ON [dbo].[shipment_shippers] ([shipment_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_shipments_created_by' AND object_id = OBJECT_ID(N'[dbo].[shipments]'))
CREATE INDEX [idx_shipments_created_by] ON [dbo].[shipments] ([created_by]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'shipments_archived_idx' AND object_id = OBJECT_ID(N'[dbo].[shipments]'))
CREATE INDEX [shipments_archived_idx] ON [dbo].[shipments] ([archived_at]) WHERE ([archived_at] IS NOT NULL);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'shipments_client_idx' AND object_id = OBJECT_ID(N'[dbo].[shipments]'))
CREATE INDEX [shipments_client_idx] ON [dbo].[shipments] ([client_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'shipments_consolidado_idx' AND object_id = OBJECT_ID(N'[dbo].[shipments]'))
CREATE INDEX [shipments_consolidado_idx] ON [dbo].[shipments] ([consolidado_id]) WHERE ([consolidado_id] IS NOT NULL);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'shipments_cs_assigned_idx' AND object_id = OBJECT_ID(N'[dbo].[shipments]'))
CREATE INDEX [shipments_cs_assigned_idx] ON [dbo].[shipments] ([cs_assigned_to]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'shipments_eta_idx' AND object_id = OBJECT_ID(N'[dbo].[shipments]'))
CREATE INDEX [shipments_eta_idx] ON [dbo].[shipments] ([eta]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'shipments_magaya_idx' AND object_id = OBJECT_ID(N'[dbo].[shipments]'))
CREATE INDEX [shipments_magaya_idx] ON [dbo].[shipments] ([magaya_shipment_id]) WHERE ([magaya_shipment_id] IS NOT NULL);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'shipments_master_idx' AND object_id = OBJECT_ID(N'[dbo].[shipments]'))
CREATE INDEX [shipments_master_idx] ON [dbo].[shipments] ([master_shipment_id]) WHERE ([master_shipment_id] IS NOT NULL);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'shipments_office_idx' AND object_id = OBJECT_ID(N'[dbo].[shipments]'))
CREATE INDEX [shipments_office_idx] ON [dbo].[shipments] ([office]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'shipments_open_status_idx' AND object_id = OBJECT_ID(N'[dbo].[shipments]'))
CREATE INDEX [shipments_open_status_idx] ON [dbo].[shipments] ([status]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'shipments_sales_exec_idx' AND object_id = OBJECT_ID(N'[dbo].[shipments]'))
CREATE INDEX [shipments_sales_exec_idx] ON [dbo].[shipments] ([sales_executive_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'shipments_un_master_por_consolidado' AND object_id = OBJECT_ID(N'[dbo].[shipments]'))
CREATE UNIQUE INDEX [shipments_un_master_por_consolidado] ON [dbo].[shipments] ([consolidado_id]) WHERE ([is_master] = 1) AND [consolidado_id] IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'shipments_via_origen_idx' AND object_id = OBJECT_ID(N'[dbo].[shipments]'))
CREATE INDEX [shipments_via_origen_idx] ON [dbo].[shipments] ([via_origen]) WHERE ([via_origen] IS NOT NULL);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_si_quote' AND object_id = OBJECT_ID(N'[dbo].[shipping_instructions]'))
CREATE INDEX [idx_si_quote] ON [dbo].[shipping_instructions] ([quote_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_si_status' AND object_id = OBJECT_ID(N'[dbo].[shipping_instructions]'))
CREATE INDEX [idx_si_status] ON [dbo].[shipping_instructions] ([status]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'shipping_instructions_archived_idx' AND object_id = OBJECT_ID(N'[dbo].[shipping_instructions]'))
CREATE INDEX [shipping_instructions_archived_idx] ON [dbo].[shipping_instructions] ([archived_at]) WHERE ([archived_at] IS NULL);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'si_shipment_viva_uq' AND object_id = OBJECT_ID(N'[dbo].[shipping_instructions]'))
CREATE UNIQUE INDEX [si_shipment_viva_uq] ON [dbo].[shipping_instructions] ([shipment_id]) WHERE (([shipment_id] IS NOT NULL) AND ([status] <> N'cancelled')) AND [shipment_id] IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'uq_si_quote_alive' AND object_id = OBJECT_ID(N'[dbo].[shipping_instructions]'))
CREATE UNIQUE INDEX [uq_si_quote_alive] ON [dbo].[shipping_instructions] ([quote_id]) WHERE (([quote_id] IS NOT NULL) AND ([status] <> N'cancelled')) AND [quote_id] IS NOT NULL;
GO
