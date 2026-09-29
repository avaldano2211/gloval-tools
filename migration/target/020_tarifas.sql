-- 020 · Tarifas: tablas e índices
-- Generado por migration/tools/to_tsql.mjs desde el catálogo de Supabase (2026-09-29). No editar a mano:
-- cambiar el generador y volver a correrlo. Idempotente: se puede ejecutar varias veces.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- public.air_rates | ~282 filas
IF OBJECT_ID(N'[dbo].[air_rates]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[air_rates] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_air_rates_id] DEFAULT (NEWSEQUENTIALID()),
  [air_carrier_id] UNIQUEIDENTIFIER NULL,
  [agent_id] UNIQUEIDENTIFIER NULL,
  [origin_code] NVARCHAR(50) NOT NULL,
  [origin_city] NVARCHAR(MAX) NULL,
  [origin_country] NVARCHAR(MAX) NULL,
  [destination_code] NVARCHAR(50) NOT NULL,
  [destination_city] NVARCHAR(MAX) NULL,
  [destination_country] NVARCHAR(MAX) NULL,
  [route_description] NVARCHAR(MAX) NULL,
  [frequency] NVARCHAR(MAX) NULL,
  [transit_time] NVARCHAR(MAX) NULL,
  [currency] NVARCHAR(MAX) NULL CONSTRAINT [DF_air_rates_currency] DEFAULT (N'USD'),
  [minimum_rate] DECIMAL(38,10) NULL CONSTRAINT [DF_air_rates_minimum_rate] DEFAULT (0),
  [rate_minus45] DECIMAL(38,10) NULL,
  [rate_45] DECIMAL(38,10) NULL,
  [rate_100] DECIMAL(38,10) NULL,
  [rate_300] DECIMAL(38,10) NULL,
  [rate_500] DECIMAL(38,10) NULL,
  [rate_1000] DECIMAL(38,10) NULL,
  [rate_2000] DECIMAL(38,10) NULL,
  [rate_3000] DECIMAL(38,10) NULL,
  [rate_4000] DECIMAL(38,10) NULL,
  [rate_5000] DECIMAL(38,10) NULL,
  [cha_fee] DECIMAL(38,10) NULL CONSTRAINT [DF_air_rates_cha_fee] DEFAULT (0),
  [soa_fee] DECIMAL(38,10) NULL CONSTRAINT [DF_air_rates_soa_fee] DEFAULT (0),
  [awa_fee] DECIMAL(38,10) NULL CONSTRAINT [DF_air_rates_awa_fee] DEFAULT (0),
  [airline_fees] NVARCHAR(MAX) NULL,
  [max_dimensions] NVARCHAR(MAX) NULL,
  [max_weight_per_piece] NVARCHAR(MAX) NULL,
  [source_region] NVARCHAR(MAX) NULL,
  [effective_date] DATE NULL,
  [expiry_date] DATE NULL,
  [active] BIT NULL CONSTRAINT [DF_air_rates_active] DEFAULT (1),
  [notes] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_air_rates_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_air_rates_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  [cargo_type] NVARCHAR(50) NULL CONSTRAINT [DF_air_rates_cargo_type] DEFAULT (N'GCR'),
  [scope] NVARCHAR(50) NOT NULL CONSTRAINT [DF_air_rates_scope] DEFAULT (N'global'),
  [updated_by] NVARCHAR(MAX) NULL,
  [service_level] NVARCHAR(50) NOT NULL CONSTRAINT [DF_air_rates_service_level] DEFAULT (N'STANDARD'),
  [last_confirmed_at] DATE NULL,
  [last_confirmed_by] NVARCHAR(MAX) NULL,
  CONSTRAINT [air_rates_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [air_rates_cargo_type_check] CHECK (([cargo_type]  IN (N'GCR', N'DGR', N'PHARMA', N'PERISHABLE'))),
  CONSTRAINT [air_rates_scope_check] CHECK (([scope]  IN (N'global', N'USA', N'PER', N'ECU', N'PAN'))),
  CONSTRAINT [air_rates_service_level_check] CHECK (([service_level]  IN (N'STANDARD', N'PRIORITY', N'RESERVED', N'SPOT', N'ACX', N'NON_STACK', N'NON_STACK_MAINDECK', N'EXPRESS_MAINDECK', N'COURIER_BAGS', N'COURIER_EXPRESS')))
);
END
GO

-- public.contract_documents | ~10 filas
IF OBJECT_ID(N'[dbo].[contract_documents]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[contract_documents] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_contract_documents_id] DEFAULT (NEWSEQUENTIALID()),
  [contract_id] UNIQUEIDENTIFIER NULL,
  [file_name] NVARCHAR(MAX) NOT NULL,
  [file_type] NVARCHAR(MAX) NULL,
  [file_size] INT NULL,
  [file_url] NVARCHAR(MAX) NULL,
  [document_type] NVARCHAR(MAX) NULL CONSTRAINT [DF_contract_documents_document_type] DEFAULT (N'CONTRACT'),
  [version] INT NULL CONSTRAINT [DF_contract_documents_version] DEFAULT (1),
  [amendment_number] NVARCHAR(MAX) NULL,
  [uploaded_by] UNIQUEIDENTIFIER NULL,
  [notes] NVARCHAR(MAX) NULL,
  [processing_status] NVARCHAR(MAX) NULL CONSTRAINT [DF_contract_documents_processing_status] DEFAULT (N'PENDING'),
  [parsed_data] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_contract_documents_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_contract_documents_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [contract_documents_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [CK_contract_documents_parsed_data_json] CHECK (ISJSON([parsed_data]) = 1)
);
END
GO

-- public.contract_updates | ~10 filas
IF OBJECT_ID(N'[dbo].[contract_updates]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[contract_updates] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_contract_updates_id] DEFAULT (NEWSEQUENTIALID()),
  [contract_id] UNIQUEIDENTIFIER NULL,
  [uploaded_by] UNIQUEIDENTIFIER NULL,
  [file_name] NVARCHAR(MAX) NOT NULL,
  [file_url] NVARCHAR(MAX) NULL,
  [file_type] NVARCHAR(MAX) NULL,
  [carrier_id] UNIQUEIDENTIFIER NULL,
  [status] NVARCHAR(MAX) NULL CONSTRAINT [DF_contract_updates_status] DEFAULT (N'pending'),
  [parsed_data] NVARCHAR(MAX) NULL,
  [diff_summary] NVARCHAR(MAX) NULL,
  [rates_added] INT NULL CONSTRAINT [DF_contract_updates_rates_added] DEFAULT (0),
  [rates_updated] INT NULL CONSTRAINT [DF_contract_updates_rates_updated] DEFAULT (0),
  [rates_deactivated] INT NULL CONSTRAINT [DF_contract_updates_rates_deactivated] DEFAULT (0),
  [charges_added] INT NULL CONSTRAINT [DF_contract_updates_charges_added] DEFAULT (0),
  [error_log] NVARCHAR(MAX) NULL,
  [applied_at] DATETIMEOFFSET NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_contract_updates_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_contract_updates_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  [new_contract_number] NVARCHAR(MAX) NULL,
  [new_effective_date] DATE NULL,
  [new_expiry_date] DATE NULL,
  CONSTRAINT [contract_updates_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [contract_updates_status_check] CHECK (([status]  IN (N'pending', N'parsing', N'parsed', N'previewing', N'approved', N'applied', N'failed', N'cancelled'))),
  CONSTRAINT [CK_contract_updates_parsed_data_json] CHECK (ISJSON([parsed_data]) = 1),
  CONSTRAINT [CK_contract_updates_diff_summary_json] CHECK (ISJSON([diff_summary]) = 1)
);
END
GO

-- public.contracts | ~60 filas
IF OBJECT_ID(N'[dbo].[contracts]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[contracts] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_contracts_id] DEFAULT (NEWSEQUENTIALID()),
  [carrier_id] UNIQUEIDENTIFIER NULL,
  [agent_id] UNIQUEIDENTIFIER NULL,
  [contract_number] NVARCHAR(MAX) NOT NULL,
  [effective_date] DATE NULL,
  [expiry_date] DATE NULL,
  [source_region] NVARCHAR(MAX) NULL,
  [managed_by] NVARCHAR(MAX) NULL,
  [notes] NVARCHAR(MAX) NULL,
  [active] BIT NULL CONSTRAINT [DF_contracts_active] DEFAULT (1),
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_contracts_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_contracts_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  [contract_name] NVARCHAR(MAX) NULL,
  [minimum_volume] INT NULL,
  [minimum_volume_unit] NVARCHAR(MAX) NULL,
  [version] INT NULL CONSTRAINT [DF_contracts_version] DEFAULT (1),
  [parent_contract_id] UNIQUEIDENTIFIER NULL,
  [amendment_number] NVARCHAR(MAX) NULL,
  [scope] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_contracts_scope] DEFAULT (N'global'),
  [card_note] NVARCHAR(MAX) NULL,
  CONSTRAINT [contracts_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [contracts_scope_check] CHECK (([scope]  IN (N'global', N'USA', N'PER', N'ECU', N'PAN')))
);
END
GO

-- public.ec_fcl_local_charges | ~71 filas
IF OBJECT_ID(N'[dbo].[ec_fcl_local_charges]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[ec_fcl_local_charges] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_ec_fcl_local_charges_id] DEFAULT (NEWSEQUENTIALID()),
  [carrier_id] UNIQUEIDENTIFIER NOT NULL,
  [concept] NVARCHAR(50) NOT NULL,
  [label] NVARCHAR(MAX) NOT NULL,
  [basis] NVARCHAR(MAX) NOT NULL,
  [amount] DECIMAL(38,10) NOT NULL CONSTRAINT [DF_ec_fcl_local_charges_amount] DEFAULT (0),
  [currency] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_ec_fcl_local_charges_currency] DEFAULT (N'USD'),
  [active] BIT NOT NULL CONSTRAINT [DF_ec_fcl_local_charges_active] DEFAULT (1),
  [effective_from] DATE NOT NULL CONSTRAINT [DF_ec_fcl_local_charges_effective_from] DEFAULT (CAST(SYSUTCDATETIME() AS DATE)),
  [notes] NVARCHAR(MAX) NULL,
  [updated_by] UNIQUEIDENTIFIER NULL,
  [updated_by_email] NVARCHAR(MAX) NULL,
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_ec_fcl_local_charges_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  [variant] NVARCHAR(50) NOT NULL CONSTRAINT [DF_ec_fcl_local_charges_variant] DEFAULT (N'GENERAL'),
  [origin] NVARCHAR(50) NULL,
  CONSTRAINT [ec_fcl_local_charges_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [ec_fcl_local_charges_amount_check] CHECK (([amount] >= 0)),
  CONSTRAINT [ec_fcl_local_charges_basis_check] CHECK (([basis]  IN (N'per_container', N'per_bl'))),
  CONSTRAINT [ec_fcl_local_charges_concept_check] CHECK (([concept]  IN (N'FEE_PP', N'FEE_CC', N'REEFER', N'LOCAL_BL', N'EMISION_BL', N'THC')))
);
END
GO

-- public.ec_fcl_local_charges_history | ~5 filas
IF OBJECT_ID(N'[dbo].[ec_fcl_local_charges_history]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[ec_fcl_local_charges_history] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_ec_fcl_local_charges_history_id] DEFAULT (NEWSEQUENTIALID()),
  [charge_id] UNIQUEIDENTIFIER NOT NULL,
  [carrier_id] UNIQUEIDENTIFIER NOT NULL,
  [concept] NVARCHAR(MAX) NOT NULL,
  [old_amount] DECIMAL(38,10) NULL,
  [new_amount] DECIMAL(38,10) NOT NULL,
  [old_effective_from] DATE NULL,
  [new_effective_from] DATE NULL,
  [changed_by] UNIQUEIDENTIFIER NULL,
  [changed_by_email] NVARCHAR(MAX) NULL,
  [changed_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_ec_fcl_local_charges_history_changed_at] DEFAULT (SYSDATETIMEOFFSET()),
  [variant] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_ec_fcl_local_charges_history_variant] DEFAULT (N'GENERAL'),
  [origin] NVARCHAR(MAX) NULL,
  CONSTRAINT [ec_fcl_local_charges_history_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.freight_carrier_aliases | ~2 filas
IF OBJECT_ID(N'[dbo].[freight_carrier_aliases]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[freight_carrier_aliases] (
  [alias] NVARCHAR(50) NOT NULL,
  [scac] NVARCHAR(MAX) NOT NULL,
  [nota] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_freight_carrier_aliases_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [freight_carrier_aliases_pkey] PRIMARY KEY ([alias])
);
END
GO

-- public.freight_port_aliases | ~12 filas
IF OBJECT_ID(N'[dbo].[freight_port_aliases]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[freight_port_aliases] (
  [alias] NVARCHAR(50) NOT NULL,
  [port_code] NVARCHAR(MAX) NOT NULL,
  [nota] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_freight_port_aliases_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [freight_port_aliases_pkey] PRIMARY KEY ([alias])
);
END
GO

-- public.freight_routes | ~1,009 filas
IF OBJECT_ID(N'[dbo].[freight_routes]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[freight_routes] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_freight_routes_id] DEFAULT (NEWSEQUENTIALID()),
  [origin_port_id] UNIQUEIDENTIFIER NULL,
  [destination_port_id] UNIQUEIDENTIFIER NULL,
  [transit_time_days] INT NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_freight_routes_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_freight_routes_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  [transshipment_port_id] UNIQUEIDENTIFIER NULL,
  [service_name] NVARCHAR(MAX) NULL,
  [service_frequency] NVARCHAR(MAX) NULL,
  [is_direct] BIT NULL,
  [active] BIT NULL CONSTRAINT [DF_freight_routes_active] DEFAULT (1),
  [notes] NVARCHAR(MAX) NULL,
  [transit_source] NVARCHAR(MAX) NULL CONSTRAINT [DF_freight_routes_transit_source] DEFAULT (N'MANUAL'),
  [transit_verified_at] DATETIMEOFFSET NULL,
  [transit_verified_by] UNIQUEIDENTIFIER NULL,
  CONSTRAINT [freight_routes_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.inland_addons | ~53 filas
IF OBJECT_ID(N'[dbo].[inland_addons]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[inland_addons] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_inland_addons_id] DEFAULT (NEWSEQUENTIALID()),
  [carrier_id] UNIQUEIDENTIFIER NULL,
  [contract_number] NVARCHAR(MAX) NULL,
  [origin_city] NVARCHAR(50) NOT NULL,
  [origin_state] NVARCHAR(MAX) NULL,
  [pol_city] NVARCHAR(100) NOT NULL,
  [pol_port_id] UNIQUEIDENTIFIER NULL,
  [mode] NVARCHAR(MAX) NULL,
  [rate_20] DECIMAL(38,10) NULL,
  [rate_40] DECIMAL(38,10) NULL,
  [rate_40h] DECIMAL(38,10) NULL,
  [currency] NVARCHAR(MAX) NULL CONSTRAINT [DF_inland_addons_currency] DEFAULT (N'USD'),
  [cargo_nature] NVARCHAR(MAX) NULL,
  [effective_date] DATE NULL,
  [expiry_date] DATE NULL,
  [active] BIT NOT NULL CONSTRAINT [DF_inland_addons_active] DEFAULT (1),
  [source_id] NVARCHAR(MAX) NULL,
  [notes] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_inland_addons_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [inland_addons_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.inland_carrier_area_rates | ~8 filas
IF OBJECT_ID(N'[dbo].[inland_carrier_area_rates]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[inland_carrier_area_rates] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_inland_carrier_area_rates_id] DEFAULT (NEWSEQUENTIALID()),
  [carrier_id] UNIQUEIDENTIFIER NOT NULL,
  [area] NVARCHAR(50) NOT NULL,
  [min_charge] DECIMAL(10,2) NOT NULL,
  [per_lb_rate] DECIMAL(8,4) NOT NULL,
  [sort] INT NOT NULL CONSTRAINT [DF_inland_carrier_area_rates_sort] DEFAULT (0),
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_inland_carrier_area_rates_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_inland_carrier_area_rates_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [inland_carrier_area_rates_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [inland_carrier_area_rates_carrier_id_area_key] UNIQUE ([carrier_id], [area]),
  CONSTRAINT [inland_carrier_area_rates_area_check] CHECK (([area]  IN (N'A', N'B', N'C', N'D', N'E', N'F', N'G', N'H')))
);
END
GO

-- public.inland_carrier_rates | ~1 filas
IF OBJECT_ID(N'[dbo].[inland_carrier_rates]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[inland_carrier_rates] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_inland_carrier_rates_id] DEFAULT (NEWSEQUENTIALID()),
  [carrier_id] UNIQUEIDENTIFIER NOT NULL,
  [ltl_base_charge] DECIMAL(10,2) NOT NULL CONSTRAINT [DF_inland_carrier_rates_ltl_base_charge] DEFAULT (55),
  [ltl_base_pallets_included] INT NOT NULL CONSTRAINT [DF_inland_carrier_rates_ltl_base_pallets_included] DEFAULT (3),
  [ltl_additional_pallet_price] DECIMAL(10,2) NOT NULL CONSTRAINT [DF_inland_carrier_rates_ltl_additional_pallet_price] DEFAULT (18),
  [ltl_weight_threshold_lbs] INT NOT NULL CONSTRAINT [DF_inland_carrier_rates_ltl_weight_threshold_lbs] DEFAULT (2000),
  [ltl_overweight_rate_per_lb] DECIMAL(10,4) NOT NULL CONSTRAINT [DF_inland_carrier_rates_ltl_overweight_rate_per_lb] DEFAULT (0.0350),
  [free_time_hours] DECIMAL(4,2) NOT NULL CONSTRAINT [DF_inland_carrier_rates_free_time_hours] DEFAULT (1),
  [additional_hour_price] DECIMAL(10,2) NOT NULL CONSTRAINT [DF_inland_carrier_rates_additional_hour_price] DEFAULT (40),
  [pickup_attempt_pct] DECIMAL(5,2) NOT NULL CONSTRAINT [DF_inland_carrier_rates_pickup_attempt_pct] DEFAULT (0.70),
  [lift_gate_price] DECIMAL(10,2) NOT NULL CONSTRAINT [DF_inland_carrier_rates_lift_gate_price] DEFAULT (45),
  [pickup_docs_price] DECIMAL(10,2) NOT NULL CONSTRAINT [DF_inland_carrier_rates_pickup_docs_price] DEFAULT (40),
  [haz_mat_price] DECIMAL(10,2) NOT NULL CONSTRAINT [DF_inland_carrier_rates_haz_mat_price] DEFAULT (35),
  [bonded_price] DECIMAL(10,2) NOT NULL CONSTRAINT [DF_inland_carrier_rates_bonded_price] DEFAULT (40),
  [truck_24ft_price] DECIMAL(10,2) NOT NULL CONSTRAINT [DF_inland_carrier_rates_truck_24ft_price] DEFAULT (210),
  [truck_24ft_max_weight_lbs] INT NOT NULL CONSTRAINT [DF_inland_carrier_rates_truck_24ft_max_weight_lbs] DEFAULT (10000),
  [truck_24ft_max_pallets] INT NOT NULL CONSTRAINT [DF_inland_carrier_rates_truck_24ft_max_pallets] DEFAULT (10),
  [truck_53ft_price] DECIMAL(10,2) NOT NULL CONSTRAINT [DF_inland_carrier_rates_truck_53ft_price] DEFAULT (290),
  [truck_53ft_max_weight_lbs] INT NOT NULL CONSTRAINT [DF_inland_carrier_rates_truck_53ft_max_weight_lbs] DEFAULT (44000),
  [truck_53ft_max_pallets] INT NOT NULL CONSTRAINT [DF_inland_carrier_rates_truck_53ft_max_pallets] DEFAULT (26),
  [effective_from] DATE NOT NULL CONSTRAINT [DF_inland_carrier_rates_effective_from] DEFAULT (CAST(SYSUTCDATETIME() AS DATE)),
  [effective_to] DATE NULL,
  [active] BIT NOT NULL CONSTRAINT [DF_inland_carrier_rates_active] DEFAULT (1),
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_inland_carrier_rates_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_inland_carrier_rates_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  [zone_b_surcharge] DECIMAL(10,2) NOT NULL CONSTRAINT [DF_inland_carrier_rates_zone_b_surcharge] DEFAULT (15),
  [zone_c_surcharge] DECIMAL(10,2) NOT NULL CONSTRAINT [DF_inland_carrier_rates_zone_c_surcharge] DEFAULT (80),
  [residential_pickup_price] DECIMAL(10,2) NOT NULL CONSTRAINT [DF_inland_carrier_rates_residential_pickup_price] DEFAULT (60),
  CONSTRAINT [inland_carrier_rates_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.inland_carrier_zips | ~179 filas
IF OBJECT_ID(N'[dbo].[inland_carrier_zips]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[inland_carrier_zips] (
  [carrier_id] UNIQUEIDENTIFIER NOT NULL,
  [zip_code] NVARCHAR(50) NOT NULL,
  [zone] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_inland_carrier_zips_zone] DEFAULT (N'A'),
  CONSTRAINT [inland_carrier_zips_pkey] PRIMARY KEY ([carrier_id], [zip_code]),
  CONSTRAINT [inland_carrier_zips_zone_check] CHECK (([zone]  IN (N'A', N'B', N'C', N'D', N'E', N'F', N'G', N'H')))
);
END
GO

-- public.inland_carriers | ~1 filas
IF OBJECT_ID(N'[dbo].[inland_carriers]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[inland_carriers] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_inland_carriers_id] DEFAULT (NEWSEQUENTIALID()),
  [name] NVARCHAR(MAX) NOT NULL,
  [region] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_inland_carriers_region] DEFAULT (N'Miami'),
  [active] BIT NOT NULL CONSTRAINT [DF_inland_carriers_active] DEFAULT (1),
  [notes] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_inland_carriers_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_inland_carriers_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [inland_carriers_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.inland_quotes | ~24 filas
IF OBJECT_ID(N'[dbo].[inland_quotes]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[inland_quotes] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_inland_quotes_id] DEFAULT (NEWSEQUENTIALID()),
  [carrier_id] UNIQUEIDENTIFIER NULL,
  [pickup_zip] NVARCHAR(MAX) NOT NULL,
  [pickup_address] NVARCHAR(MAX) NULL,
  [pallets] INT NOT NULL,
  [weight_lbs] DECIMAL(10,2) NOT NULL,
  [wait_hours] DECIMAL(4,2) NOT NULL CONSTRAINT [DF_inland_quotes_wait_hours] DEFAULT (1),
  [lift_gate] BIT NOT NULL CONSTRAINT [DF_inland_quotes_lift_gate] DEFAULT (0),
  [pickup_docs] BIT NOT NULL CONSTRAINT [DF_inland_quotes_pickup_docs] DEFAULT (0),
  [haz_mat] BIT NOT NULL CONSTRAINT [DF_inland_quotes_haz_mat] DEFAULT (0),
  [bonded] BIT NOT NULL CONSTRAINT [DF_inland_quotes_bonded] DEFAULT (0),
  [recommended_mode] NVARCHAR(MAX) NOT NULL,
  [recommended_total] DECIMAL(10,2) NOT NULL,
  [ltl_total] DECIMAL(10,2) NULL,
  [truck_24ft_total] DECIMAL(10,2) NULL,
  [truck_53ft_total] DECIMAL(10,2) NULL,
  [client_name] NVARCHAR(MAX) NULL,
  [notes] NVARCHAR(MAX) NULL,
  [created_by] UNIQUEIDENTIFIER NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_inland_quotes_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [delivery_zip] NVARCHAR(MAX) NOT NULL,
  [delivery_address] NVARCHAR(MAX) NULL,
  [pickup_zone] NVARCHAR(MAX) NULL,
  [delivery_zone] NVARCHAR(MAX) NULL,
  [zone_surcharge] DECIMAL(10,2) NULL,
  [client_email] NVARCHAR(MAX) NULL,
  [residential_pickup] BIT NOT NULL CONSTRAINT [DF_inland_quotes_residential_pickup] DEFAULT (0),
  CONSTRAINT [inland_quotes_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [inland_quotes_delivery_zone_check] CHECK (([delivery_zone]  IN (N'A', N'B', N'C', N'D', N'E', N'F', N'G', N'H'))),
  CONSTRAINT [inland_quotes_pallets_check] CHECK (([pallets] > 0)),
  CONSTRAINT [inland_quotes_pickup_zone_check] CHECK (([pickup_zone]  IN (N'A', N'B', N'C', N'D', N'E', N'F', N'G', N'H'))),
  CONSTRAINT [inland_quotes_recommended_mode_check] CHECK (([recommended_mode]  IN (N'LTL', N'TRUCK_24FT', N'TRUCK_53FT'))),
  CONSTRAINT [inland_quotes_weight_lbs_check] CHECK (([weight_lbs] > 0))
);
END
GO

-- public.lcl_admin_emails | ~1 filas
IF OBJECT_ID(N'[dbo].[lcl_admin_emails]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[lcl_admin_emails] (
  [email] NVARCHAR(50) NOT NULL,
  CONSTRAINT [lcl_admin_emails_pkey] PRIMARY KEY ([email])
);
END
GO

-- public.lcl_lanes | ~5 filas
IF OBJECT_ID(N'[dbo].[lcl_lanes]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[lcl_lanes] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_lcl_lanes_id] DEFAULT (NEWSEQUENTIALID()),
  [dest] NVARCHAR(50) NOT NULL,
  [rate_per_cbm] DECIMAL(38,10) NOT NULL CONSTRAINT [DF_lcl_lanes_rate_per_cbm] DEFAULT (0),
  [min_charge] DECIMAL(38,10) NOT NULL CONSTRAINT [DF_lcl_lanes_min_charge] DEFAULT (0),
  [bunker_per_cbm] DECIMAL(38,10) NOT NULL CONSTRAINT [DF_lcl_lanes_bunker_per_cbm] DEFAULT (0),
  [fuel_per_cbm] DECIMAL(38,10) NOT NULL CONSTRAINT [DF_lcl_lanes_fuel_per_cbm] DEFAULT (0),
  [margin] DECIMAL(38,10) NOT NULL CONSTRAINT [DF_lcl_lanes_margin] DEFAULT (0),
  [transit] NVARCHAR(MAX) NULL CONSTRAINT [DF_lcl_lanes_transit] DEFAULT (N''),
  [sort_order] INT NOT NULL CONSTRAINT [DF_lcl_lanes_sort_order] DEFAULT (0),
  [active] BIT NOT NULL CONSTRAINT [DF_lcl_lanes_active] DEFAULT (1),
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_lcl_lanes_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [lcl_lanes_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [lcl_lanes_dest_key] UNIQUE ([dest])
);
END
GO

-- public.lcl_settings | ~1 filas
IF OBJECT_ID(N'[dbo].[lcl_settings]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[lcl_settings] (
  [id] INT NOT NULL CONSTRAINT [DF_lcl_settings_id] DEFAULT (1),
  [margin_mode] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_lcl_settings_margin_mode] DEFAULT (N'pct'),
  [currency] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_lcl_settings_currency] DEFAULT (N'USD'),
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_lcl_settings_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [lcl_settings_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [lcl_settings_margin_mode_check] CHECK (([margin_mode]  IN (N'pct', N'cbm'))),
  CONSTRAINT [lcl_settings_singleton] CHECK (([id] = 1))
);
END
GO

-- public.lcl_surcharges | ~2 filas
IF OBJECT_ID(N'[dbo].[lcl_surcharges]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[lcl_surcharges] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_lcl_surcharges_id] DEFAULT (NEWSEQUENTIALID()),
  [name] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_lcl_surcharges_name] DEFAULT (N''),
  [mode] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_lcl_surcharges_mode] DEFAULT (N'fijo'),
  [value] DECIMAL(38,10) NOT NULL CONSTRAINT [DF_lcl_surcharges_value] DEFAULT (0),
  [enabled] BIT NOT NULL CONSTRAINT [DF_lcl_surcharges_enabled] DEFAULT (1),
  [sort_order] INT NOT NULL CONSTRAINT [DF_lcl_surcharges_sort_order] DEFAULT (0),
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_lcl_surcharges_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [lcl_surcharges_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [lcl_surcharges_mode_check] CHECK (([mode]  IN (N'fijo', N'cbm', N'pct')))
);
END
GO

-- public.pricing_rules | ~7 filas
IF OBJECT_ID(N'[dbo].[pricing_rules]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[pricing_rules] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_pricing_rules_id] DEFAULT (NEWSEQUENTIALID()),
  [name] NVARCHAR(MAX) NOT NULL,
  [description] NVARCHAR(MAX) NULL,
  [priority] INT NOT NULL CONSTRAINT [DF_pricing_rules_priority] DEFAULT (100),
  [is_active] BIT NOT NULL CONSTRAINT [DF_pricing_rules_is_active] DEFAULT (1),
  [client_id] UNIQUEIDENTIFIER NULL,
  [client_tier] NVARCHAR(MAX) NULL,
  [office_id] NVARCHAR(255) NULL,
  [sales_rep_id] UNIQUEIDENTIFIER NULL,
  [mode] NVARCHAR(MAX) NULL,
  [carrier_id] UNIQUEIDENTIFIER NULL,
  [agent_id] UNIQUEIDENTIFIER NULL,
  [origin_filter] NVARCHAR(MAX) NULL,
  [destination_filter] NVARCHAR(MAX) NULL,
  [trade_lane] NVARCHAR(MAX) NULL,
  [equipment_type_id] UNIQUEIDENTIFIER NULL,
  [commodity_id] UNIQUEIDENTIFIER NULL,
  [weight_min] DECIMAL(38,10) NULL,
  [weight_max] DECIMAL(38,10) NULL,
  [markup_type] NVARCHAR(MAX) NOT NULL,
  [markup_value] DECIMAL(38,10) NULL,
  [markup_floor] DECIMAL(38,10) NULL,
  [markup_ceiling] DECIMAL(38,10) NULL,
  [tiered_brackets] NVARCHAR(MAX) NULL,
  [effective_date] DATE NULL,
  [expiry_date] DATE NULL,
  [created_by] UNIQUEIDENTIFIER NULL,
  [approved_by] UNIQUEIDENTIFIER NULL,
  [approved_at] DATETIMEOFFSET NULL,
  [notes] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_pricing_rules_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_pricing_rules_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [pricing_rules_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [pricing_rules_markup_type_check] CHECK (([markup_type]  IN (N'percent', N'flat', N'tiered', N'min_margin', N'cost_plus'))),
  CONSTRAINT [pricing_rules_mode_check] CHECK ((([mode] IS NULL) OR ([mode]  IN (N'fcl', N'lcl', N'air', N'ltl')))),
  CONSTRAINT [CK_pricing_rules_origin_filter_json] CHECK (ISJSON([origin_filter]) = 1),
  CONSTRAINT [CK_pricing_rules_destination_filter_json] CHECK (ISJSON([destination_filter]) = 1),
  CONSTRAINT [CK_pricing_rules_tiered_brackets_json] CHECK (ISJSON([tiered_brackets]) = 1)
);
END
GO

-- public.rate_charges | ~32,056 filas
IF OBJECT_ID(N'[dbo].[rate_charges]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[rate_charges] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_rate_charges_id] DEFAULT (NEWSEQUENTIALID()),
  [rate_id] UNIQUEIDENTIFIER NOT NULL,
  [charge_code] NVARCHAR(MAX) NOT NULL,
  [charge_name] NVARCHAR(MAX) NOT NULL,
  [amount] DECIMAL(38,10) NOT NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_rate_charges_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [rate_charges_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.rate_components | ~38 filas
IF OBJECT_ID(N'[dbo].[rate_components]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[rate_components] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_rate_components_id] DEFAULT (NEWSEQUENTIALID()),
  [code] NVARCHAR(MAX) NOT NULL,
  [name] NVARCHAR(MAX) NOT NULL,
  [category] NVARCHAR(MAX) NOT NULL,
  [description] NVARCHAR(MAX) NULL,
  [calculation_type] NVARCHAR(MAX) NULL,
  [active] BIT NULL CONSTRAINT [DF_rate_components_active] DEFAULT (1),
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_rate_components_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [rate_components_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.rate_notes | ~14 filas
IF OBJECT_ID(N'[dbo].[rate_notes]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[rate_notes] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_rate_notes_id] DEFAULT (NEWSEQUENTIALID()),
  [rate_id] UNIQUEIDENTIFIER NOT NULL,
  [note_type] NVARCHAR(MAX) NOT NULL,
  [note_text] NVARCHAR(MAX) NOT NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_rate_notes_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [rate_notes_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.rates | ~12,894 filas
IF OBJECT_ID(N'[dbo].[rates]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[rates] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_rates_id] DEFAULT (NEWSEQUENTIALID()),
  [contract_id] UNIQUEIDENTIFIER NULL,
  [route_id] UNIQUEIDENTIFIER NULL,
  [commodity_id] UNIQUEIDENTIFIER NULL,
  [equipment_type_id] UNIQUEIDENTIFIER NULL,
  [rate_line_number] NVARCHAR(MAX) NULL,
  [effective_date] DATE NULL,
  [expiry_date] DATE NULL,
  [base_rate] DECIMAL(38,10) NOT NULL,
  [currency] NVARCHAR(MAX) NULL CONSTRAINT [DF_rates_currency] DEFAULT (N'USD'),
  [service_type] NVARCHAR(MAX) NULL,
  [transit_time] INT NULL,
  [notes] NVARCHAR(MAX) NULL,
  [deferred_discount] DECIMAL(38,10) NULL CONSTRAINT [DF_rates_deferred_discount] DEFAULT (0),
  [deferred_discount_conditions] NVARCHAR(MAX) NULL,
  [active] BIT NULL CONSTRAINT [DF_rates_active] DEFAULT (1),
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_rates_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_rates_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  [origin_city] NVARCHAR(MAX) NULL,
  [origin_door_city] NVARCHAR(MAX) NULL,
  [scope] NVARCHAR(50) NOT NULL CONSTRAINT [DF_rates_scope] DEFAULT (N'global'),
  [updated_by] NVARCHAR(MAX) NULL,
  [office_id] NVARCHAR(255) NULL,
  [agent_id] UNIQUEIDENTIFIER NULL,
  [sell_rate] DECIMAL(38,10) NULL,
  [tariff_sheet_id] UNIQUEIDENTIFIER NULL,
  [is_bullet] BIT NOT NULL CONSTRAINT [DF_rates_is_bullet] DEFAULT (0),
  [bullet_expires_at] DATETIMEOFFSET NULL,
  [bullet_priority] INT NULL,
  [inland_mode] NVARCHAR(50) NOT NULL CONSTRAINT [DF_rates_inland_mode] DEFAULT (N'PORT'),
  [ipi_construction] NVARCHAR(MAX) NULL,
  CONSTRAINT [rates_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [rates_inland_mode_check] CHECK (([inland_mode]  IN (N'PORT', N'RAMP', N'RAMP_TRUCK', N'DOOR'))),
  CONSTRAINT [rates_ipi_construction_check] CHECK ((([ipi_construction] IS NULL) OR ([ipi_construction]  IN (N'Y', N'N', N'E', N'I', N'B', N'X')))),
  CONSTRAINT [rates_scope_check] CHECK (([scope]  IN (N'global', N'USA', N'PER', N'ECU', N'PAN')))
);
END
GO

-- public.shipco_destinations | ~296 filas
IF OBJECT_ID(N'[dbo].[shipco_destinations]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[shipco_destinations] (
  [destination_code] NVARCHAR(50) NOT NULL,
  [origin_code] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_shipco_destinations_origin_code] DEFAULT (N'USMIA'),
  [destination_label] NVARCHAR(MAX) NOT NULL,
  [country_iso2] NVARCHAR(MAX) NULL,
  [region] NVARCHAR(MAX) NULL,
  [transit_days] INT NULL,
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_shipco_destinations_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [shipco_destinations_pkey] PRIMARY KEY ([destination_code])
);
END
GO

-- public.shipco_rates | ~4,218 filas
IF OBJECT_ID(N'[dbo].[shipco_rates]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[shipco_rates] (
  [id] BIGINT IDENTITY(1,1) NOT NULL,
  [origin_code] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_shipco_rates_origin_code] DEFAULT (N'USMIA'),
  [destination_code] NVARCHAR(50) NOT NULL,
  [type] NVARCHAR(MAX) NULL,
  [charge_code] NVARCHAR(50) NOT NULL,
  [currency] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_shipco_rates_currency] DEFAULT (N'USD'),
  [rate] DECIMAL(38,10) NOT NULL,
  [rate_basis] NVARCHAR(MAX) NOT NULL,
  [minimum] DECIMAL(38,10) NULL,
  [maximum] DECIMAL(38,10) NULL,
  [uom] NVARCHAR(MAX) NULL,
  [from_qty] DECIMAL(38,10) NULL,
  [to_qty] DECIMAL(38,10) NULL,
  [effective_date] DATE NOT NULL,
  [expiration_date] DATE NOT NULL,
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_shipco_rates_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [shipco_rates_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.shipco_settings | ~3 filas
IF OBJECT_ID(N'[dbo].[shipco_settings]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[shipco_settings] (
  [key] NVARCHAR(50) NOT NULL,
  [value] NVARCHAR(MAX) NOT NULL,
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_shipco_settings_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [shipco_settings_pkey] PRIMARY KEY ([key]),
  CONSTRAINT [CK_shipco_settings_value_json] CHECK (ISJSON([value]) = 1)
);
END
GO

-- public.surcharges | ~29 filas
IF OBJECT_ID(N'[dbo].[surcharges]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[surcharges] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_surcharges_id] DEFAULT (NEWSEQUENTIALID()),
  [name] NVARCHAR(MAX) NOT NULL,
  [code] NVARCHAR(MAX) NULL,
  [carrier_id] UNIQUEIDENTIFIER NULL,
  [origin_region] NVARCHAR(MAX) NULL,
  [destination_region] NVARCHAR(MAX) NULL,
  [equipment_type_id] UNIQUEIDENTIFIER NULL,
  [amount] DECIMAL(38,10) NOT NULL,
  [currency] NVARCHAR(MAX) NULL CONSTRAINT [DF_surcharges_currency] DEFAULT (N'USD'),
  [calculation_type] NVARCHAR(MAX) NULL,
  [effective_date] DATE NULL,
  [expiry_date] DATE NULL,
  [active] BIT NULL CONSTRAINT [DF_surcharges_active] DEFAULT (1),
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_surcharges_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_surcharges_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  [min_charge] DECIMAL(38,10) NULL,
  [volatile] BIT NOT NULL CONSTRAINT [DF_surcharges_volatile] DEFAULT (0),
  [revision_frequency] NVARCHAR(MAX) NULL,
  [last_confirmed_at] DATE NULL,
  [weight_basis] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_surcharges_weight_basis] DEFAULT (N'CHARGEABLE'),
  CONSTRAINT [surcharges_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [surcharges_weight_basis_check] CHECK (([weight_basis]  IN (N'CHARGEABLE', N'GROSS')))
);
END
GO

-- public.tariff_sheets | ~24 filas
IF OBJECT_ID(N'[dbo].[tariff_sheets]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[tariff_sheets] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_tariff_sheets_id] DEFAULT (NEWSEQUENTIALID()),
  [name] NVARCHAR(MAX) NOT NULL,
  [description] NVARCHAR(MAX) NULL,
  [source_type] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_tariff_sheets_source_type] DEFAULT (N'manual'),
  [source_file_url] NVARCHAR(MAX) NULL,
  [contract_id] UNIQUEIDENTIFIER NULL,
  [carrier_id] UNIQUEIDENTIFIER NULL,
  [agent_id] UNIQUEIDENTIFIER NULL,
  [office_id] NVARCHAR(255) NULL,
  [trade_lane] NVARCHAR(MAX) NULL,
  [effective_date] DATE NULL,
  [expiry_date] DATE NULL,
  [uploaded_by] UNIQUEIDENTIFIER NULL,
  [status] NVARCHAR(50) NOT NULL CONSTRAINT [DF_tariff_sheets_status] DEFAULT (N'active'),
  [notes] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_tariff_sheets_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_tariff_sheets_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [tariff_sheets_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [tariff_sheets_source_type_check] CHECK (([source_type]  IN (N'manual', N'excel_upload', N'api_import', N'contract_pdf'))),
  CONSTRAINT [tariff_sheets_status_check] CHECK (([status]  IN (N'draft', N'active', N'expired', N'superseded')))
);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'air_rates_activa_unica' AND object_id = OBJECT_ID(N'[dbo].[air_rates]'))
CREATE UNIQUE INDEX [air_rates_activa_unica] ON [dbo].[air_rates] ([air_carrier_id], [agent_id], [origin_code], [destination_code], [cargo_type], [service_level]) WHERE ([active] = 1);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_air_rates_agent_id' AND object_id = OBJECT_ID(N'[dbo].[air_rates]'))
CREATE INDEX [idx_air_rates_agent_id] ON [dbo].[air_rates] ([agent_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_air_rates_air_carrier_id' AND object_id = OBJECT_ID(N'[dbo].[air_rates]'))
CREATE INDEX [idx_air_rates_air_carrier_id] ON [dbo].[air_rates] ([air_carrier_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_air_rates_scope' AND object_id = OBJECT_ID(N'[dbo].[air_rates]'))
CREATE INDEX [idx_air_rates_scope] ON [dbo].[air_rates] ([scope], [active], [expiry_date]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_contract_docs_contract' AND object_id = OBJECT_ID(N'[dbo].[contract_documents]'))
CREATE INDEX [idx_contract_docs_contract] ON [dbo].[contract_documents] ([contract_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_contract_documents_uploaded_by' AND object_id = OBJECT_ID(N'[dbo].[contract_documents]'))
CREATE INDEX [idx_contract_documents_uploaded_by] ON [dbo].[contract_documents] ([uploaded_by]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_contract_updates_carrier_id' AND object_id = OBJECT_ID(N'[dbo].[contract_updates]'))
CREATE INDEX [idx_contract_updates_carrier_id] ON [dbo].[contract_updates] ([carrier_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_contract_updates_contract_id' AND object_id = OBJECT_ID(N'[dbo].[contract_updates]'))
CREATE INDEX [idx_contract_updates_contract_id] ON [dbo].[contract_updates] ([contract_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_contract_updates_uploaded_by' AND object_id = OBJECT_ID(N'[dbo].[contract_updates]'))
CREATE INDEX [idx_contract_updates_uploaded_by] ON [dbo].[contract_updates] ([uploaded_by]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_contracts_agent_id' AND object_id = OBJECT_ID(N'[dbo].[contracts]'))
CREATE INDEX [idx_contracts_agent_id] ON [dbo].[contracts] ([agent_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_contracts_carrier' AND object_id = OBJECT_ID(N'[dbo].[contracts]'))
CREATE INDEX [idx_contracts_carrier] ON [dbo].[contracts] ([carrier_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_contracts_parent_contract_id' AND object_id = OBJECT_ID(N'[dbo].[contracts]'))
CREATE INDEX [idx_contracts_parent_contract_id] ON [dbo].[contracts] ([parent_contract_id]);
GO

IF COL_LENGTH(N'[dbo].[ec_fcl_local_charges]', N'origin__nn') IS NULL
ALTER TABLE [dbo].[ec_fcl_local_charges] ADD [origin__nn] AS COALESCE([origin], N'') PERSISTED;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ec_fcl_charges_carrier_concept_variant_origin_key' AND object_id = OBJECT_ID(N'[dbo].[ec_fcl_local_charges]'))
CREATE UNIQUE INDEX [ec_fcl_charges_carrier_concept_variant_origin_key] ON [dbo].[ec_fcl_local_charges] ([carrier_id], [concept], [variant], [origin__nn]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ec_fcl_local_charges_history_charge_idx' AND object_id = OBJECT_ID(N'[dbo].[ec_fcl_local_charges_history]'))
CREATE INDEX [ec_fcl_local_charges_history_charge_idx] ON [dbo].[ec_fcl_local_charges_history] ([carrier_id], [changed_at] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_freight_routes_dest' AND object_id = OBJECT_ID(N'[dbo].[freight_routes]'))
CREATE INDEX [idx_freight_routes_dest] ON [dbo].[freight_routes] ([destination_port_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_freight_routes_origin' AND object_id = OBJECT_ID(N'[dbo].[freight_routes]'))
CREATE INDEX [idx_freight_routes_origin] ON [dbo].[freight_routes] ([origin_port_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_freight_routes_transit_verified_by' AND object_id = OBJECT_ID(N'[dbo].[freight_routes]'))
CREATE INDEX [idx_freight_routes_transit_verified_by] ON [dbo].[freight_routes] ([transit_verified_by]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_freight_routes_transshipment_port_id' AND object_id = OBJECT_ID(N'[dbo].[freight_routes]'))
CREATE INDEX [idx_freight_routes_transshipment_port_id] ON [dbo].[freight_routes] ([transshipment_port_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'inland_addons_origin_idx' AND object_id = OBJECT_ID(N'[dbo].[inland_addons]'))
CREATE INDEX [inland_addons_origin_idx] ON [dbo].[inland_addons] ([origin_city]) WHERE ([active] = 1);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'inland_addons_pol_idx' AND object_id = OBJECT_ID(N'[dbo].[inland_addons]'))
CREATE INDEX [inland_addons_pol_idx] ON [dbo].[inland_addons] ([pol_city]) WHERE ([active] = 1);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'inland_carrier_rates_active_idx' AND object_id = OBJECT_ID(N'[dbo].[inland_carrier_rates]'))
CREATE INDEX [inland_carrier_rates_active_idx] ON [dbo].[inland_carrier_rates] ([carrier_id], [active], [effective_from] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'inland_carrier_zips_zip_idx' AND object_id = OBJECT_ID(N'[dbo].[inland_carrier_zips]'))
CREATE INDEX [inland_carrier_zips_zip_idx] ON [dbo].[inland_carrier_zips] ([zip_code]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'inland_quotes_created_idx' AND object_id = OBJECT_ID(N'[dbo].[inland_quotes]'))
CREATE INDEX [inland_quotes_created_idx] ON [dbo].[inland_quotes] ([created_at] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'inland_quotes_user_idx' AND object_id = OBJECT_ID(N'[dbo].[inland_quotes]'))
CREATE INDEX [inland_quotes_user_idx] ON [dbo].[inland_quotes] ([created_by], [created_at] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_pricing_rules_active' AND object_id = OBJECT_ID(N'[dbo].[pricing_rules]'))
CREATE INDEX [idx_pricing_rules_active] ON [dbo].[pricing_rules] ([is_active], [priority] DESC) WHERE ([is_active] = 1);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_pricing_rules_agent' AND object_id = OBJECT_ID(N'[dbo].[pricing_rules]'))
CREATE INDEX [idx_pricing_rules_agent] ON [dbo].[pricing_rules] ([agent_id]) WHERE ([agent_id] IS NOT NULL);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_pricing_rules_approved_by' AND object_id = OBJECT_ID(N'[dbo].[pricing_rules]'))
CREATE INDEX [idx_pricing_rules_approved_by] ON [dbo].[pricing_rules] ([approved_by]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_pricing_rules_carrier' AND object_id = OBJECT_ID(N'[dbo].[pricing_rules]'))
CREATE INDEX [idx_pricing_rules_carrier] ON [dbo].[pricing_rules] ([carrier_id]) WHERE ([carrier_id] IS NOT NULL);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_pricing_rules_client' AND object_id = OBJECT_ID(N'[dbo].[pricing_rules]'))
CREATE INDEX [idx_pricing_rules_client] ON [dbo].[pricing_rules] ([client_id]) WHERE ([client_id] IS NOT NULL);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_pricing_rules_commodity_id' AND object_id = OBJECT_ID(N'[dbo].[pricing_rules]'))
CREATE INDEX [idx_pricing_rules_commodity_id] ON [dbo].[pricing_rules] ([commodity_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_pricing_rules_created_by' AND object_id = OBJECT_ID(N'[dbo].[pricing_rules]'))
CREATE INDEX [idx_pricing_rules_created_by] ON [dbo].[pricing_rules] ([created_by]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_pricing_rules_dates' AND object_id = OBJECT_ID(N'[dbo].[pricing_rules]'))
CREATE INDEX [idx_pricing_rules_dates] ON [dbo].[pricing_rules] ([effective_date], [expiry_date]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_pricing_rules_equipment_type_id' AND object_id = OBJECT_ID(N'[dbo].[pricing_rules]'))
CREATE INDEX [idx_pricing_rules_equipment_type_id] ON [dbo].[pricing_rules] ([equipment_type_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_pricing_rules_office' AND object_id = OBJECT_ID(N'[dbo].[pricing_rules]'))
CREATE INDEX [idx_pricing_rules_office] ON [dbo].[pricing_rules] ([office_id]) WHERE ([office_id] IS NOT NULL);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_pricing_rules_sales_rep_id' AND object_id = OBJECT_ID(N'[dbo].[pricing_rules]'))
CREATE INDEX [idx_pricing_rules_sales_rep_id] ON [dbo].[pricing_rules] ([sales_rep_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_rate_charges_rate' AND object_id = OBJECT_ID(N'[dbo].[rate_charges]'))
CREATE INDEX [idx_rate_charges_rate] ON [dbo].[rate_charges] ([rate_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_rate_notes_rate' AND object_id = OBJECT_ID(N'[dbo].[rate_notes]'))
CREATE INDEX [idx_rate_notes_rate] ON [dbo].[rate_notes] ([rate_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_rates_active' AND object_id = OBJECT_ID(N'[dbo].[rates]'))
CREATE INDEX [idx_rates_active] ON [dbo].[rates] ([active]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_rates_agent' AND object_id = OBJECT_ID(N'[dbo].[rates]'))
CREATE INDEX [idx_rates_agent] ON [dbo].[rates] ([agent_id]) WHERE ([agent_id] IS NOT NULL);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_rates_bullet' AND object_id = OBJECT_ID(N'[dbo].[rates]'))
CREATE INDEX [idx_rates_bullet] ON [dbo].[rates] ([is_bullet], [bullet_expires_at]) WHERE ([is_bullet] = 1);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_rates_commodity' AND object_id = OBJECT_ID(N'[dbo].[rates]'))
CREATE INDEX [idx_rates_commodity] ON [dbo].[rates] ([commodity_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_rates_contract' AND object_id = OBJECT_ID(N'[dbo].[rates]'))
CREATE INDEX [idx_rates_contract] ON [dbo].[rates] ([contract_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_rates_equipment' AND object_id = OBJECT_ID(N'[dbo].[rates]'))
CREATE INDEX [idx_rates_equipment] ON [dbo].[rates] ([equipment_type_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_rates_office' AND object_id = OBJECT_ID(N'[dbo].[rates]'))
CREATE INDEX [idx_rates_office] ON [dbo].[rates] ([office_id]) WHERE ([office_id] IS NOT NULL);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_rates_route' AND object_id = OBJECT_ID(N'[dbo].[rates]'))
CREATE INDEX [idx_rates_route] ON [dbo].[rates] ([route_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_rates_scope' AND object_id = OBJECT_ID(N'[dbo].[rates]'))
CREATE INDEX [idx_rates_scope] ON [dbo].[rates] ([scope], [active], [expiry_date]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_rates_tariff_sheet' AND object_id = OBJECT_ID(N'[dbo].[rates]'))
CREATE INDEX [idx_rates_tariff_sheet] ON [dbo].[rates] ([tariff_sheet_id]) WHERE ([tariff_sheet_id] IS NOT NULL);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'rates_inland_mode_idx' AND object_id = OBJECT_ID(N'[dbo].[rates]'))
CREATE INDEX [rates_inland_mode_idx] ON [dbo].[rates] ([inland_mode]) WHERE ([inland_mode] <> N'PORT');
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'shipco_rates_dest_idx' AND object_id = OBJECT_ID(N'[dbo].[shipco_rates]'))
CREATE INDEX [shipco_rates_dest_idx] ON [dbo].[shipco_rates] ([destination_code], [charge_code]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_surcharges_carrier_id' AND object_id = OBJECT_ID(N'[dbo].[surcharges]'))
CREATE INDEX [idx_surcharges_carrier_id] ON [dbo].[surcharges] ([carrier_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_surcharges_equipment_type_id' AND object_id = OBJECT_ID(N'[dbo].[surcharges]'))
CREATE INDEX [idx_surcharges_equipment_type_id] ON [dbo].[surcharges] ([equipment_type_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_tariff_sheets_agent' AND object_id = OBJECT_ID(N'[dbo].[tariff_sheets]'))
CREATE INDEX [idx_tariff_sheets_agent] ON [dbo].[tariff_sheets] ([agent_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_tariff_sheets_carrier' AND object_id = OBJECT_ID(N'[dbo].[tariff_sheets]'))
CREATE INDEX [idx_tariff_sheets_carrier] ON [dbo].[tariff_sheets] ([carrier_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_tariff_sheets_contract_id' AND object_id = OBJECT_ID(N'[dbo].[tariff_sheets]'))
CREATE INDEX [idx_tariff_sheets_contract_id] ON [dbo].[tariff_sheets] ([contract_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_tariff_sheets_dates' AND object_id = OBJECT_ID(N'[dbo].[tariff_sheets]'))
CREATE INDEX [idx_tariff_sheets_dates] ON [dbo].[tariff_sheets] ([effective_date], [expiry_date]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_tariff_sheets_office' AND object_id = OBJECT_ID(N'[dbo].[tariff_sheets]'))
CREATE INDEX [idx_tariff_sheets_office] ON [dbo].[tariff_sheets] ([office_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_tariff_sheets_status' AND object_id = OBJECT_ID(N'[dbo].[tariff_sheets]'))
CREATE INDEX [idx_tariff_sheets_status] ON [dbo].[tariff_sheets] ([status]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_tariff_sheets_uploaded_by' AND object_id = OBJECT_ID(N'[dbo].[tariff_sheets]'))
CREATE INDEX [idx_tariff_sheets_uploaded_by] ON [dbo].[tariff_sheets] ([uploaded_by]);
GO
