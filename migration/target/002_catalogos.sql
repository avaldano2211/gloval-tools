-- 002 · Catálogos: tablas e índices
-- Generado por migration/tools/to_tsql.mjs desde el catálogo de Supabase (2026-09-29). No editar a mano:
-- cambiar el generador y volver a correrlo. Idempotente: se puede ejecutar varias veces.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- public.agent_office_mapping | ~8 filas
IF OBJECT_ID(N'[dbo].[agent_office_mapping]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[agent_office_mapping] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_agent_office_mapping_id] DEFAULT (NEWSEQUENTIALID()),
  [agent_pattern] NVARCHAR(MAX) NOT NULL,
  [office] NVARCHAR(MAX) NOT NULL,
  [notes] NVARCHAR(MAX) NULL,
  [active] BIT NULL CONSTRAINT [DF_agent_office_mapping_active] DEFAULT (1),
  [created_by] UNIQUEIDENTIFIER NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_agent_office_mapping_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_agent_office_mapping_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [agent_office_mapping_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.agents | ~74 filas
IF OBJECT_ID(N'[dbo].[agents]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[agents] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_agents_id] DEFAULT (NEWSEQUENTIALID()),
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_agents_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_agents_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  [company_name] NVARCHAR(100) NOT NULL,
  [country] NVARCHAR(MAX) NOT NULL,
  [city] NVARCHAR(MAX) NULL,
  [agent_type] NVARCHAR(MAX) NULL,
  [contact_name] NVARCHAR(MAX) NULL,
  [contact_email] NVARCHAR(MAX) NULL,
  [contact_phone] NVARCHAR(MAX) NULL,
  [contact_whatsapp] NVARCHAR(MAX) NULL,
  [services_offered] NVARCHAR(MAX) NULL,
  [trade_lanes] NVARCHAR(MAX) NULL,
  [provides_rates] BIT NULL CONSTRAINT [DF_agents_provides_rates] DEFAULT (0),
  [sends_freehand] BIT NULL CONSTRAINT [DF_agents_sends_freehand] DEFAULT (0),
  [credit_terms_with_us] NVARCHAR(MAX) NULL,
  [commission_percentage] DECIMAL(5,2) NULL,
  [status] NVARCHAR(MAX) NULL CONSTRAINT [DF_agents_status] DEFAULT (N'Active'),
  [notes] NVARCHAR(MAX) NULL,
  [rating] INT NULL,
  [created_by] UNIQUEIDENTIFIER NULL,
  [handling_fee] DECIMAL(10,2) NULL,
  [bl_fee] DECIMAL(10,2) NULL,
  [telex_release_fee] DECIMAL(10,2) NULL,
  [documentation_fee] DECIMAL(10,2) NULL,
  [customs_clearance_fee] DECIMAL(10,2) NULL,
  [delivery_20ft] DECIMAL(10,2) NULL,
  [delivery_40ft] DECIMAL(10,2) NULL,
  [delivery_40hc] DECIMAL(10,2) NULL,
  [storage_per_day] DECIMAL(10,2) NULL,
  [examination_fee] DECIMAL(10,2) NULL,
  [other_fees] NVARCHAR(MAX) NULL,
  [other_fees_amount] DECIMAL(10,2) NULL,
  [fee_notes] NVARCHAR(MAX) NULL,
  [fee_currency] NVARCHAR(MAX) NULL CONSTRAINT [DF_agents_fee_currency] DEFAULT (N'USD'),
  [fees_valid_until] DATE NULL,
  [agent_gives_credit] BIT NULL CONSTRAINT [DF_agents_agent_gives_credit] DEFAULT (0),
  [agent_credit_limit] DECIMAL(12,2) NULL,
  [agent_credit_terms] NVARCHAR(MAX) NULL,
  [agent_credit_status] NVARCHAR(MAX) NULL CONSTRAINT [DF_agents_agent_credit_status] DEFAULT (N'Active'),
  [we_give_credit] BIT NULL CONSTRAINT [DF_agents_we_give_credit] DEFAULT (0),
  [our_credit_limit] DECIMAL(12,2) NULL,
  [our_credit_terms] NVARCHAR(MAX) NULL,
  [our_credit_approved_date] DATE NULL,
  [our_credit_approved_by] NVARCHAR(MAX) NULL,
  [contact1_name] NVARCHAR(MAX) NULL,
  [contact1_title] NVARCHAR(MAX) NULL,
  [contact1_email] NVARCHAR(MAX) NULL,
  [contact1_phone] NVARCHAR(MAX) NULL,
  [contact1_mobile] NVARCHAR(MAX) NULL,
  [contact2_name] NVARCHAR(MAX) NULL,
  [contact2_title] NVARCHAR(MAX) NULL,
  [contact2_email] NVARCHAR(MAX) NULL,
  [contact2_phone] NVARCHAR(MAX) NULL,
  [contact2_mobile] NVARCHAR(MAX) NULL,
  [contact3_name] NVARCHAR(MAX) NULL,
  [contact3_title] NVARCHAR(MAX) NULL,
  [contact3_email] NVARCHAR(MAX) NULL,
  [contact3_phone] NVARCHAR(MAX) NULL,
  [contact3_mobile] NVARCHAR(MAX) NULL,
  [network] NVARCHAR(MAX) NULL,
  CONSTRAINT [agents_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [agents_rating_check] CHECK ((([rating] >= 1) AND ([rating] <= 5))),
  CONSTRAINT [CK_agents_agent_type_json] CHECK (ISJSON([agent_type]) = 1),
  CONSTRAINT [CK_agents_services_offered_json] CHECK (ISJSON([services_offered]) = 1),
  CONSTRAINT [CK_agents_trade_lanes_json] CHECK (ISJSON([trade_lanes]) = 1)
);
END
GO

-- public.air_carriers | ~11 filas
IF OBJECT_ID(N'[dbo].[air_carriers]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[air_carriers] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_air_carriers_id] DEFAULT (NEWSEQUENTIALID()),
  [name] NVARCHAR(MAX) NOT NULL,
  [code] NVARCHAR(MAX) NULL,
  [carrier_type] NVARCHAR(MAX) NULL CONSTRAINT [DF_air_carriers_carrier_type] DEFAULT (N'airline'),
  [active] BIT NULL CONSTRAINT [DF_air_carriers_active] DEFAULT (1),
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_air_carriers_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [air_carriers_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.brief_assets | ~10 filas
IF OBJECT_ID(N'[dbo].[brief_assets]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[brief_assets] (
  [key] NVARCHAR(100) NOT NULL,
  [value] NVARCHAR(MAX) NULL,
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_brief_assets_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [brief_assets_pkey] PRIMARY KEY ([key])
);
END
GO

-- public.carrier_transit_times | ~684 filas
IF OBJECT_ID(N'[dbo].[carrier_transit_times]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[carrier_transit_times] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_carrier_transit_times_id] DEFAULT (NEWSEQUENTIALID()),
  [carrier_id] UNIQUEIDENTIFIER NOT NULL,
  [route_id] UNIQUEIDENTIFIER NOT NULL,
  [transit_time_days] INT NOT NULL,
  [service_name] NVARCHAR(MAX) NULL,
  [service_frequency] NVARCHAR(MAX) NULL,
  [is_direct] BIT NULL CONSTRAINT [DF_carrier_transit_times_is_direct] DEFAULT (1),
  [transshipment_port_id] UNIQUEIDENTIFIER NULL,
  [transit_source] NVARCHAR(MAX) NULL CONSTRAINT [DF_carrier_transit_times_transit_source] DEFAULT (N'MANUAL'),
  [verified_at] DATETIMEOFFSET NULL,
  [verified_by] UNIQUEIDENTIFIER NULL,
  [notes] NVARCHAR(MAX) NULL,
  [active] BIT NULL CONSTRAINT [DF_carrier_transit_times_active] DEFAULT (1),
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_carrier_transit_times_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_carrier_transit_times_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  [vessel_name] NVARCHAR(MAX) NULL,
  CONSTRAINT [carrier_transit_times_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [carrier_transit_times_carrier_id_route_id_key] UNIQUE ([carrier_id], [route_id])
);
END
GO

-- public.carriers | ~17 filas
IF OBJECT_ID(N'[dbo].[carriers]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[carriers] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_carriers_id] DEFAULT (NEWSEQUENTIALID()),
  [name] NVARCHAR(MAX) NOT NULL,
  [code] NVARCHAR(50) NOT NULL,
  [active] BIT NULL CONSTRAINT [DF_carriers_active] DEFAULT (1),
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_carriers_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_carriers_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  [contact_email] NVARCHAR(MAX) NULL,
  [contact_phone] NVARCHAR(MAX) NULL,
  [logo_url] NVARCHAR(MAX) NULL,
  [email_domains] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_carriers_email_domains] DEFAULT (N'[]'),
  CONSTRAINT [carriers_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [carriers_code_key] UNIQUE ([code]),
  CONSTRAINT [CK_carriers_email_domains_json] CHECK (ISJSON([email_domains]) = 1)
);
END
GO

-- public.commodities | ~132 filas
IF OBJECT_ID(N'[dbo].[commodities]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[commodities] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_commodities_id] DEFAULT (NEWSEQUENTIALID()),
  [code] NVARCHAR(50) NOT NULL,
  [name] NVARCHAR(MAX) NOT NULL,
  [description] NVARCHAR(MAX) NULL,
  [active] BIT NULL CONSTRAINT [DF_commodities_active] DEFAULT (1),
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_commodities_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_commodities_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  [hazmat] BIT NULL,
  [requires_approval] BIT NULL,
  [category] NVARCHAR(MAX) NULL,
  [hs_code] NVARCHAR(MAX) NULL,
  [is_fak] BIT NOT NULL CONSTRAINT [DF_commodities_is_fak] DEFAULT (0),
  CONSTRAINT [commodities_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [commodities_code_key] UNIQUE ([code])
);
END
GO

-- public.container_types | ~7 filas
IF OBJECT_ID(N'[dbo].[container_types]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[container_types] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_container_types_id] DEFAULT (NEWSEQUENTIALID()),
  [name] NVARCHAR(50) NOT NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_container_types_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [created_by] UNIQUEIDENTIFIER NULL,
  CONSTRAINT [container_types_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [container_types_name_key] UNIQUE ([name])
);
END
GO

-- public.email_templates | ~4 filas
IF OBJECT_ID(N'[dbo].[email_templates]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[email_templates] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_email_templates_id] DEFAULT (NEWSEQUENTIALID()),
  [name] NVARCHAR(50) NOT NULL,
  [subject] NVARCHAR(MAX) NOT NULL,
  [html_content] NVARCHAR(MAX) NOT NULL,
  [language] NVARCHAR(MAX) NOT NULL,
  [recipient_type] NVARCHAR(MAX) NOT NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_email_templates_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_email_templates_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [email_templates_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [email_templates_name_key] UNIQUE ([name]),
  CONSTRAINT [email_templates_language_check] CHECK (([language]  IN (N'en', N'es'))),
  CONSTRAINT [email_templates_recipient_type_check] CHECK (([recipient_type]  IN (N'client', N'team')))
);
END
GO

-- public.equipment_types | ~11 filas
IF OBJECT_ID(N'[dbo].[equipment_types]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[equipment_types] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_equipment_types_id] DEFAULT (NEWSEQUENTIALID()),
  [code] NVARCHAR(50) NOT NULL,
  [name] NVARCHAR(MAX) NOT NULL,
  [size_feet] INT NOT NULL,
  [type] NVARCHAR(MAX) NULL,
  [teu_factor] DECIMAL(38,10) NULL,
  [is_reefer] BIT NULL CONSTRAINT [DF_equipment_types_is_reefer] DEFAULT (0),
  [requires_power] BIT NULL CONSTRAINT [DF_equipment_types_requires_power] DEFAULT (0),
  [has_temperature_control] BIT NULL CONSTRAINT [DF_equipment_types_has_temperature_control] DEFAULT (0),
  [active] BIT NULL CONSTRAINT [DF_equipment_types_active] DEFAULT (1),
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_equipment_types_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_equipment_types_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  [recommended_for] NVARCHAR(MAX) NULL,
  [notes] NVARCHAR(MAX) NULL,
  [internal_volume_cbm] DECIMAL(38,10) NULL,
  [internal_height_cm] INT NULL,
  [tare_weight_kg] INT NULL,
  [max_payload_kg] INT NULL,
  [temperature_range_min] INT NULL,
  [temperature_range_max] INT NULL,
  CONSTRAINT [equipment_types_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [equipment_types_code_key] UNIQUE ([code]),
  CONSTRAINT [CK_equipment_types_recommended_for_json] CHECK (ISJSON([recommended_for]) = 1)
);
END
GO

-- public.gloval_assets | ~1 filas
IF OBJECT_ID(N'[dbo].[gloval_assets]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[gloval_assets] (
  [id] NVARCHAR(50) NOT NULL,
  [content_type] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_gloval_assets_content_type] DEFAULT (N'image/jpeg'),
  [b64] NVARCHAR(MAX) NOT NULL,
  [description] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_gloval_assets_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [gloval_assets_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.offices | ~5 filas
IF OBJECT_ID(N'[dbo].[offices]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[offices] (
  [id] NVARCHAR(255) NOT NULL,
  [name] NVARCHAR(MAX) NOT NULL,
  [city] NVARCHAR(MAX) NULL,
  [country] NVARCHAR(MAX) NULL,
  [email] NVARCHAR(MAX) NULL,
  [active] BIT NULL CONSTRAINT [DF_offices_active] DEFAULT (0),
  [notes] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_offices_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [code] NVARCHAR(50) NULL,
  [legal_name] NVARCHAR(MAX) NULL,
  [display_name] NVARCHAR(MAX) NULL,
  [cash_floor_usd] DECIMAL(14,2) NULL CONSTRAINT [DF_offices_cash_floor_usd] DEFAULT (0),
  [base_currency] NVARCHAR(MAX) NULL CONSTRAINT [DF_offices_base_currency] DEFAULT (N'USD'),
  [is_holding] BIT NULL CONSTRAINT [DF_offices_is_holding] DEFAULT (0),
  [timezone] NVARCHAR(MAX) NULL,
  [country_code] NVARCHAR(MAX) NULL,
  [tenant_id] UNIQUEIDENTIFIER NULL,
  CONSTRAINT [offices_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.phone_numbers | ~635 filas
IF OBJECT_ID(N'[dbo].[phone_numbers]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[phone_numbers] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_phone_numbers_id] DEFAULT (NEWSEQUENTIALID()),
  [contact_id] UNIQUEIDENTIFIER NOT NULL,
  [phone_number] NVARCHAR(MAX) NOT NULL,
  [phone_type] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_phone_numbers_phone_type] DEFAULT (N'mobile'),
  [is_primary] BIT NULL CONSTRAINT [DF_phone_numbers_is_primary] DEFAULT (0),
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_phone_numbers_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [phone_numbers_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [phone_numbers_phone_type_check] CHECK (([phone_type]  IN (N'mobile', N'office', N'home', N'fax')))
);
END
GO

-- public.points_of_receipt | ~31 filas
IF OBJECT_ID(N'[dbo].[points_of_receipt]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[points_of_receipt] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_points_of_receipt_id] DEFAULT (NEWSEQUENTIALID()),
  [name] NVARCHAR(50) NOT NULL,
  [city] NVARCHAR(MAX) NOT NULL,
  [state] NVARCHAR(MAX) NULL,
  [country_code] NVARCHAR(50) NOT NULL CONSTRAINT [DF_points_of_receipt_country_code] DEFAULT (N'US'),
  [receipt_type] NVARCHAR(50) NOT NULL,
  [description] NVARCHAR(MAX) NULL,
  [transit_days_delta] INT NULL,
  [ramp_surcharge_applies] BIT NOT NULL CONSTRAINT [DF_points_of_receipt_ramp_surcharge_applies] DEFAULT (0),
  [efs_default] DECIMAL(38,10) NULL,
  [ihe_default] DECIMAL(38,10) NULL,
  [port_id] UNIQUEIDENTIFIER NULL,
  [catalog_code] NVARCHAR(50) NULL,
  [latitude] DECIMAL(38,10) NULL,
  [longitude] DECIMAL(38,10) NULL,
  [source] NVARCHAR(50) NOT NULL CONSTRAINT [DF_points_of_receipt_source] DEFAULT (N'MAERSK_AFLS'),
  [notes] NVARCHAR(MAX) NULL,
  [active] BIT NOT NULL CONSTRAINT [DF_points_of_receipt_active] DEFAULT (1),
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_points_of_receipt_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_points_of_receipt_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [points_of_receipt_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [points_of_receipt_source_name_key] UNIQUE ([source], [name]),
  CONSTRAINT [points_of_receipt_receipt_type_check] CHECK (([receipt_type]  IN (N'port', N'ramp')))
);
END
GO

-- public.ports | ~279 filas
IF OBJECT_ID(N'[dbo].[ports]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[ports] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_ports_id] DEFAULT (NEWSEQUENTIALID()),
  [name] NVARCHAR(MAX) NOT NULL,
  [code] NVARCHAR(50) NOT NULL,
  [city] NVARCHAR(MAX) NULL,
  [country_code] NVARCHAR(2) NULL,
  [country_name] NVARCHAR(MAX) NULL,
  [region] NVARCHAR(MAX) NULL,
  [active] BIT NULL CONSTRAINT [DF_ports_active] DEFAULT (1),
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_ports_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_ports_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  [latitude] DECIMAL(38,10) NULL,
  [longitude] DECIMAL(38,10) NULL,
  [port_type] NVARCHAR(MAX) NULL CONSTRAINT [DF_ports_port_type] DEFAULT (N'port'),
  CONSTRAINT [ports_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [ports_code_key] UNIQUE ([code])
);
END
GO

-- public.ports_master | ~570 filas
IF OBJECT_ID(N'[dbo].[ports_master]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[ports_master] (
  [id] BIGINT NOT NULL CONSTRAINT [DF_ports_master_id] DEFAULT (NEXT VALUE FOR [dbo].[ports_master_id_seq]),
  [code] NVARCHAR(50) NOT NULL,
  [name] NVARCHAR(MAX) NOT NULL,
  [city] NVARCHAR(MAX) NULL,
  [country] NVARCHAR(MAX) NULL,
  [type] NVARCHAR(50) NULL,
  [source] NVARCHAR(MAX) NULL,
  [search_text] NVARCHAR(MAX) NULL,
  CONSTRAINT [ports_master_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [ports_master_type_check] CHECK (([type]  IN (N'airport', N'port')))
);
END
GO

-- public.routes | ~2 filas
IF OBJECT_ID(N'[dbo].[routes]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[routes] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_routes_id] DEFAULT (NEWSEQUENTIALID()),
  [client_id] UNIQUEIDENTIFIER NOT NULL,
  [origin_port] NVARCHAR(MAX) NOT NULL,
  [destination_port] NVARCHAR(MAX) NOT NULL,
  [is_protected] BIT NULL CONSTRAINT [DF_routes_is_protected] DEFAULT (0),
  [protected_by_ff_id] UNIQUEIDENTIFIER NULL,
  [deal_value] DECIMAL(12,2) NULL,
  [monthly_volume] DECIMAL(12,2) NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_routes_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [origin_port_id] UNIQUEIDENTIFIER NULL,
  [destination_port_id] UNIQUEIDENTIFIER NULL,
  CONSTRAINT [routes_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.shipping_lines | ~10 filas
IF OBJECT_ID(N'[dbo].[shipping_lines]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[shipping_lines] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_shipping_lines_id] DEFAULT (NEWSEQUENTIALID()),
  [name] NVARCHAR(100) NOT NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_shipping_lines_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [created_by] UNIQUEIDENTIFIER NULL,
  CONSTRAINT [shipping_lines_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [shipping_lines_name_key] UNIQUE ([name])
);
END
GO

-- public.transit_times | ~11 filas
IF OBJECT_ID(N'[dbo].[transit_times]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[transit_times] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_transit_times_id] DEFAULT (NEWSEQUENTIALID()),
  [carrier_id] UNIQUEIDENTIFIER NULL,
  [origin_port_id] UNIQUEIDENTIFIER NULL,
  [destination_port_id] UNIQUEIDENTIFIER NULL,
  [transit_days] INT NULL,
  [service_name] NVARCHAR(MAX) NULL,
  [frequency] NVARCHAR(MAX) NULL,
  [notes] NVARCHAR(MAX) NULL,
  [active] BIT NULL CONSTRAINT [DF_transit_times_active] DEFAULT (1),
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_transit_times_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_transit_times_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [transit_times_pkey] PRIMARY KEY ([id])
);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'agent_office_active_idx' AND object_id = OBJECT_ID(N'[dbo].[agent_office_mapping]'))
CREATE INDEX [agent_office_active_idx] ON [dbo].[agent_office_mapping] ([active]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_agent_office_mapping_created_by' AND object_id = OBJECT_ID(N'[dbo].[agent_office_mapping]'))
CREATE INDEX [idx_agent_office_mapping_created_by] ON [dbo].[agent_office_mapping] ([created_by]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_agents_company_name' AND object_id = OBJECT_ID(N'[dbo].[agents]'))
CREATE INDEX [idx_agents_company_name] ON [dbo].[agents] ([company_name]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_agents_created_by' AND object_id = OBJECT_ID(N'[dbo].[agents]'))
CREATE INDEX [idx_agents_created_by] ON [dbo].[agents] ([created_by]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_carrier_transit_times_route_id' AND object_id = OBJECT_ID(N'[dbo].[carrier_transit_times]'))
CREATE INDEX [idx_carrier_transit_times_route_id] ON [dbo].[carrier_transit_times] ([route_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_carrier_transit_times_transshipment_port_id' AND object_id = OBJECT_ID(N'[dbo].[carrier_transit_times]'))
CREATE INDEX [idx_carrier_transit_times_transshipment_port_id] ON [dbo].[carrier_transit_times] ([transshipment_port_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_carrier_transit_times_verified_by' AND object_id = OBJECT_ID(N'[dbo].[carrier_transit_times]'))
CREATE INDEX [idx_carrier_transit_times_verified_by] ON [dbo].[carrier_transit_times] ([verified_by]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'offices_code_uq' AND object_id = OBJECT_ID(N'[dbo].[offices]'))
CREATE UNIQUE INDEX [offices_code_uq] ON [dbo].[offices] ([code]) WHERE ([code] IS NOT NULL) AND [code] IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_phone_numbers_contact_id' AND object_id = OBJECT_ID(N'[dbo].[phone_numbers]'))
CREATE INDEX [idx_phone_numbers_contact_id] ON [dbo].[phone_numbers] ([contact_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_por_catalog_code' AND object_id = OBJECT_ID(N'[dbo].[points_of_receipt]'))
CREATE INDEX [idx_por_catalog_code] ON [dbo].[points_of_receipt] ([catalog_code]) WHERE ([catalog_code] IS NOT NULL);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_por_country' AND object_id = OBJECT_ID(N'[dbo].[points_of_receipt]'))
CREATE INDEX [idx_por_country] ON [dbo].[points_of_receipt] ([country_code]) WHERE ([active] = 1);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_por_receipt_type' AND object_id = OBJECT_ID(N'[dbo].[points_of_receipt]'))
CREATE INDEX [idx_por_receipt_type] ON [dbo].[points_of_receipt] ([receipt_type]) WHERE ([active] = 1);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_ports_master_code' AND object_id = OBJECT_ID(N'[dbo].[ports_master]'))
CREATE INDEX [idx_ports_master_code] ON [dbo].[ports_master] ([code]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_ports_master_type' AND object_id = OBJECT_ID(N'[dbo].[ports_master]'))
CREATE INDEX [idx_ports_master_type] ON [dbo].[ports_master] ([type]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_routes_client_id' AND object_id = OBJECT_ID(N'[dbo].[routes]'))
CREATE INDEX [idx_routes_client_id] ON [dbo].[routes] ([client_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_routes_destination_port_id' AND object_id = OBJECT_ID(N'[dbo].[routes]'))
CREATE INDEX [idx_routes_destination_port_id] ON [dbo].[routes] ([destination_port_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_routes_origin_port_id' AND object_id = OBJECT_ID(N'[dbo].[routes]'))
CREATE INDEX [idx_routes_origin_port_id] ON [dbo].[routes] ([origin_port_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_routes_protected_by_ff_id' AND object_id = OBJECT_ID(N'[dbo].[routes]'))
CREATE INDEX [idx_routes_protected_by_ff_id] ON [dbo].[routes] ([protected_by_ff_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_transit_times_carrier_id' AND object_id = OBJECT_ID(N'[dbo].[transit_times]'))
CREATE INDEX [idx_transit_times_carrier_id] ON [dbo].[transit_times] ([carrier_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_transit_times_destination_port_id' AND object_id = OBJECT_ID(N'[dbo].[transit_times]'))
CREATE INDEX [idx_transit_times_destination_port_id] ON [dbo].[transit_times] ([destination_port_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_transit_times_origin_port_id' AND object_id = OBJECT_ID(N'[dbo].[transit_times]'))
CREATE INDEX [idx_transit_times_origin_port_id] ON [dbo].[transit_times] ([origin_port_id]);
GO
