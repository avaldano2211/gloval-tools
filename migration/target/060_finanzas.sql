-- 060 · Finanzas: tablas e índices
-- Generado por migration/tools/to_tsql.mjs desde el catálogo de Supabase (2026-09-29). No editar a mano:
-- cambiar el generador y volver a correrlo. Idempotente: se puede ejecutar varias veces.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- public.arap_live_open | ~5,345 filas
IF OBJECT_ID(N'[dbo].[arap_live_open]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[arap_live_open] (
  [office] NVARCHAR(50) NOT NULL,
  [tipo] NVARCHAR(50) NOT NULL,
  [number] NVARCHAR(50) NOT NULL,
  [fecha] DATE NULL,
  [vence] DATE NULL,
  [entidad] NVARCHAR(MAX) NULL,
  [es_ic] BIT NULL CONSTRAINT [DF_arap_live_open_es_ic] DEFAULT (0),
  [saldo_usd] DECIMAL(38,10) NOT NULL,
  [dias_venc] INT NULL,
  [tramo] NVARCHAR(MAX) NULL,
  [computed_at] DATETIMEOFFSET NULL CONSTRAINT [DF_arap_live_open_computed_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [arap_live_open_pkey] PRIMARY KEY ([office], [tipo], [number])
);
END
GO

-- public.arap_live_snapshot | ~73 filas
IF OBJECT_ID(N'[dbo].[arap_live_snapshot]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[arap_live_snapshot] (
  [fecha] DATE NOT NULL,
  [office] NVARCHAR(50) NOT NULL,
  [tipo] NVARCHAR(50) NOT NULL,
  [docs] INT NULL,
  [total_usd] DECIMAL(38,10) NULL,
  [docs_90] INT NULL,
  [docs_180] INT NULL,
  [computed_at] DATETIMEOFFSET NULL CONSTRAINT [DF_arap_live_snapshot_computed_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [arap_live_snapshot_pkey] PRIMARY KEY ([fecha], [office], [tipo])
);
END
GO

-- public.bank_account | ~10 filas
IF OBJECT_ID(N'[dbo].[bank_account]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[bank_account] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_bank_account_id] DEFAULT (NEWSEQUENTIALID()),
  [tenant_id] UNIQUEIDENTIFIER NOT NULL,
  [office_id] UNIQUEIDENTIFIER NOT NULL,
  [bank_name] NVARCHAR(MAX) NOT NULL,
  [account_nickname] NVARCHAR(MAX) NULL,
  [account_number_last4] NVARCHAR(MAX) NULL,
  [account_number_encrypted] NVARCHAR(MAX) NULL,
  [iban] NVARCHAR(MAX) NULL,
  [swift] NVARCHAR(MAX) NULL,
  [account_type] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_bank_account_account_type] DEFAULT (N'checking'),
  [currency] NVARCHAR(MAX) NOT NULL,
  [current_balance] DECIMAL(18,2) NOT NULL CONSTRAINT [DF_bank_account_current_balance] DEFAULT (0),
  [available_balance] DECIMAL(18,2) NOT NULL CONSTRAINT [DF_bank_account_available_balance] DEFAULT (0),
  [credit_limit] DECIMAL(18,2) NULL,
  [min_balance_alert] DECIMAL(18,2) NULL,
  [reconciled_through_date] DATE NULL,
  [bank_feed_provider] NVARCHAR(MAX) NULL,
  [bank_feed_account_id] NVARCHAR(MAX) NULL,
  [active] BIT NOT NULL CONSTRAINT [DF_bank_account_active] DEFAULT (1),
  [notes] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_bank_account_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_bank_account_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [bank_account_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.bank_transaction | ~8,120 filas
IF OBJECT_ID(N'[dbo].[bank_transaction]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[bank_transaction] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_bank_transaction_id] DEFAULT (NEWSEQUENTIALID()),
  [tenant_id] UNIQUEIDENTIFIER NOT NULL,
  [bank_account_id] UNIQUEIDENTIFIER NOT NULL,
  [transaction_date] DATE NOT NULL,
  [value_date] DATE NULL,
  [amount] DECIMAL(18,2) NOT NULL,
  [currency] NVARCHAR(MAX) NOT NULL,
  [description] NVARCHAR(MAX) NULL,
  [memo] NVARCHAR(MAX) NULL,
  [reference] NVARCHAR(MAX) NULL,
  [counterparty_name_raw] NVARCHAR(MAX) NULL,
  [matched_party_id] UNIQUEIDENTIFIER NULL,
  [matched_invoice_id] UNIQUEIDENTIFIER NULL,
  [matched_payment_id] UNIQUEIDENTIFIER NULL,
  [category] NVARCHAR(MAX) NULL,
  [category_confidence] DECIMAL(3,2) NULL,
  [status] NVARCHAR(50) NOT NULL CONSTRAINT [DF_bank_transaction_status] DEFAULT (N'imported'),
  [source] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_bank_transaction_source] DEFAULT (N'manual_csv'),
  [reconciliation_batch_id] UNIQUEIDENTIFIER NULL,
  [raw_data] NVARCHAR(MAX) NULL CONSTRAINT [DF_bank_transaction_raw_data] DEFAULT (N'{}'),
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_bank_transaction_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_bank_transaction_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  [subcategory] NVARCHAR(50) NULL,
  [expense_purpose] NVARCHAR(MAX) NULL,
  CONSTRAINT [bank_transaction_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [CK_bank_transaction_raw_data_json] CHECK (ISJSON([raw_data]) = 1)
);
END
GO

-- public.caja_eod | ~39 filas
IF OBJECT_ID(N'[dbo].[caja_eod]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[caja_eod] (
  [fecha] DATE NOT NULL,
  [office] NVARCHAR(50) NOT NULL,
  [monto_usd] DECIMAL(38,10) NULL,
  [detalle] NVARCHAR(MAX) NULL,
  [fuente] NVARCHAR(MAX) NULL,
  [remitente] NVARCHAR(MAX) NULL,
  [hora_reporte] NVARCHAR(MAX) NULL,
  [computed_at] DATETIMEOFFSET NULL CONSTRAINT [DF_caja_eod_computed_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [caja_eod_pkey] PRIMARY KEY ([fecha], [office])
);
END
GO

-- public.cash_movement | ~146,181 filas
IF OBJECT_ID(N'[dbo].[cash_movement]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[cash_movement] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_cash_movement_id] DEFAULT (NEWSEQUENTIALID()),
  [tenant_id] UNIQUEIDENTIFIER NOT NULL,
  [office_id] UNIQUEIDENTIFIER NOT NULL,
  [bank_account_id] UNIQUEIDENTIFIER NULL,
  [direction] NVARCHAR(MAX) NOT NULL,
  [category] NVARCHAR(MAX) NOT NULL,
  [source_type] NVARCHAR(MAX) NULL,
  [source_id] UNIQUEIDENTIFIER NULL,
  [party_id] UNIQUEIDENTIFIER NULL,
  [amount] DECIMAL(18,2) NOT NULL,
  [currency] NVARCHAR(MAX) NOT NULL,
  [amount_in_usd] DECIMAL(18,2) NULL,
  [expected_date] DATE NOT NULL,
  [actual_date] DATE NULL,
  [status] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_cash_movement_status] DEFAULT (N'forecast'),
  [confidence] DECIMAL(3,2) NULL CONSTRAINT [DF_cash_movement_confidence] DEFAULT (0.85),
  [linked_bank_transaction_id] UNIQUEIDENTIFIER NULL,
  [linked_scenario_id] UNIQUEIDENTIFIER NULL,
  [notes] NVARCHAR(MAX) NULL,
  [created_by] UNIQUEIDENTIFIER NULL,
  [approved_by] UNIQUEIDENTIFIER NULL,
  [approved_at] DATETIMEOFFSET NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_cash_movement_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_cash_movement_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  [counterparty_name] NVARCHAR(255) NULL,
  [external_reference] NVARCHAR(MAX) NULL,
  [external_guid] NVARCHAR(255) NULL,
  CONSTRAINT [cash_movement_pkey] PRIMARY KEY ([id])
);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'cash_movement_external_guid_uq' AND object_id = OBJECT_ID(N'[dbo].[cash_movement]'))
CREATE UNIQUE INDEX [cash_movement_external_guid_uq] ON [dbo].[cash_movement] ([tenant_id], [external_guid]) WHERE [external_guid] IS NOT NULL;
GO

-- public.closings | ~2,943 filas
IF OBJECT_ID(N'[dbo].[closings]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[closings] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_closings_id] DEFAULT (NEWSEQUENTIALID()),
  [office] NVARCHAR(MAX) NOT NULL,
  [executive_id] UNIQUEIDENTIFIER NULL,
  [quote_id] NVARCHAR(MAX) NULL,
  [week] INT NOT NULL,
  [month] NVARCHAR(MAX) NOT NULL,
  [year] INT NOT NULL,
  [closing_date] DATE NOT NULL,
  [client_id] UNIQUEIDENTIFIER NULL,
  [client_name] NVARCHAR(MAX) NULL,
  [is_new_client] BIT NULL CONSTRAINT [DF_closings_is_new_client] DEFAULT (0),
  [service_type] NVARCHAR(MAX) NULL,
  [trade_type] NVARCHAR(MAX) NULL,
  [incoterm] NVARCHAR(MAX) NULL,
  [pol_aol] NVARCHAR(MAX) NULL,
  [pod_aod] NVARCHAR(MAX) NULL,
  [carrier] NVARCHAR(MAX) NULL,
  [payment_type] NVARCHAR(MAX) NULL,
  [containers_20st] INT NULL CONSTRAINT [DF_closings_containers_20st] DEFAULT (0),
  [containers_40hc] INT NULL CONSTRAINT [DF_closings_containers_40hc] DEFAULT (0),
  [teus] DECIMAL(38,10) NULL CONSTRAINT [DF_closings_teus] DEFAULT (0),
  [kg_vol] DECIMAL(38,10) NULL CONSTRAINT [DF_closings_kg_vol] DEFAULT (0),
  [cbm] DECIMAL(38,10) NULL CONSTRAINT [DF_closings_cbm] DEFAULT (0),
  [tons] DECIMAL(38,10) NULL CONSTRAINT [DF_closings_tons] DEFAULT (0),
  [furgon] INT NULL CONSTRAINT [DF_closings_furgon] DEFAULT (0),
  [revenue] DECIMAL(38,10) NOT NULL,
  [revenue_target] DECIMAL(38,10) NULL,
  [cost] DECIMAL(38,10) NOT NULL,
  [profit_target] DECIMAL(38,10) NULL,
  [profit] AS CAST((([revenue] - [cost])) AS DECIMAL(38,10)) PERSISTED,
  [margin] AS CAST((
CASE
    WHEN ([revenue] > 0) THEN (([revenue] - [cost]) / [revenue])
    ELSE 0
END) AS DECIMAL(38,10)) PERSISTED,
  [how_closed] NVARCHAR(MAX) NULL,
  [notes] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_closings_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_closings_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  [created_by] UNIQUEIDENTIFIER NULL,
  [margin_pct] DECIMAL(38,10) NULL CONSTRAINT [DF_closings_margin_pct] DEFAULT (0),
  [furgons] INT NULL CONSTRAINT [DF_closings_furgons] DEFAULT (0),
  [weekly_target_revenue] DECIMAL(38,10) NULL,
  [weekly_target_profit] DECIMAL(38,10) NULL,
  [agent_name] NVARCHAR(MAX) NULL,
  [containers_fr] INT NULL,
  [containers_ot] INT NULL,
  [cam_group] NVARCHAR(MAX) NULL,
  [cam_subgroup] NVARCHAR(MAX) NULL,
  CONSTRAINT [closings_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [closings_service_type_check] CHECK (([service_type]  IN (N'FCL', N'LCL', N'Air', N'Courier', N'Furgon', N'Logistics')))
);
END
GO

-- public.finanzas_bank_match | ~7,813 filas
IF OBJECT_ID(N'[dbo].[finanzas_bank_match]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[finanzas_bank_match] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_finanzas_bank_match_id] DEFAULT (NEWSEQUENTIALID()),
  [bank_transaction_id] UNIQUEIDENTIFIER NOT NULL,
  [office_id] NVARCHAR(255) NOT NULL,
  [match_type] NVARCHAR(MAX) NOT NULL,
  [matched_docs] NVARCHAR(MAX) NULL,
  [entity_name] NVARCHAR(MAX) NULL,
  [category] NVARCHAR(MAX) NULL,
  [confidence] DECIMAL(3,2) NOT NULL CONSTRAINT [DF_finanzas_bank_match_confidence] DEFAULT (0.5),
  [estado] NVARCHAR(50) NOT NULL CONSTRAINT [DF_finanzas_bank_match_estado] DEFAULT (N'sugerido'),
  [decided_by] NVARCHAR(MAX) NULL,
  [decided_at] DATETIMEOFFSET NULL,
  [notes] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_finanzas_bank_match_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_finanzas_bank_match_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [finanzas_bank_match_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [finanzas_bank_match_bank_transaction_id_key] UNIQUE ([bank_transaction_id]),
  CONSTRAINT [finanzas_bank_match_category_check] CHECK ((([category] IS NULL) OR ([category]  IN (N'client_payment', N'vendor_payment', N'payroll', N'rent', N'utility', N'tax', N'intercompany_in', N'intercompany_out', N'fx_swap', N'loan_disbursement', N'loan_payment', N'capex', N'dividend', N'bank_fee', N'interest', N'refund', N'other', N'uncategorized')))),
  CONSTRAINT [finanzas_bank_match_estado_check] CHECK (([estado]  IN (N'sugerido', N'confirmado', N'descartado'))),
  CONSTRAINT [finanzas_bank_match_match_type_check] CHECK (([match_type]  IN (N'refs', N'monto_pm', N'traspaso', N'categoria', N'manual'))),
  CONSTRAINT [CK_finanzas_bank_match_matched_docs_json] CHECK (ISJSON([matched_docs]) = 1)
);
END
GO

-- public.finanzas_config_recurrente | ~4 filas
IF OBJECT_ID(N'[dbo].[finanzas_config_recurrente]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[finanzas_config_recurrente] (
  [office_id] NVARCHAR(255) NOT NULL,
  [monto_mes] DECIMAL(14,2) NOT NULL,
  [detalle] NVARCHAR(MAX) NULL,
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_finanzas_config_recurrente_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [finanzas_config_recurrente_pkey] PRIMARY KEY ([office_id])
);
END
GO

-- public.finanzas_eeff_pl | ~8 filas
IF OBJECT_ID(N'[dbo].[finanzas_eeff_pl]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[finanzas_eeff_pl] (
  [office_id] NVARCHAR(255) NOT NULL,
  [periodo] NVARCHAR(50) NOT NULL,
  [ventas] DECIMAL(14,2) NOT NULL,
  [utilidad_bruta] DECIMAL(14,2) NULL,
  [utilidad_neta] DECIMAL(14,2) NULL,
  [fuente] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_finanzas_eeff_pl_fuente] DEFAULT (N'EEFF'),
  [notes] NVARCHAR(MAX) NULL,
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_finanzas_eeff_pl_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [finanzas_eeff_pl_pkey] PRIMARY KEY ([office_id], [periodo])
);
END
GO

-- public.finanzas_forecast_recurrente | ~5 filas
IF OBJECT_ID(N'[dbo].[finanzas_forecast_recurrente]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[finanzas_forecast_recurrente] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_finanzas_forecast_recurrente_id] DEFAULT (NEWSEQUENTIALID()),
  [office_id] NVARCHAR(255) NOT NULL,
  [concepto] NVARCHAR(MAX) NOT NULL,
  [monto_usd] DECIMAL(14,2) NOT NULL,
  [frecuencia] NVARCHAR(MAX) NOT NULL,
  [dia] INT NULL,
  [ancla] DATE NULL,
  [activo] BIT NOT NULL CONSTRAINT [DF_finanzas_forecast_recurrente_activo] DEFAULT (1),
  [fuente] NVARCHAR(MAX) NULL,
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_finanzas_forecast_recurrente_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [finanzas_forecast_recurrente_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [finanzas_forecast_recurrente_frecuencia_check] CHECK (([frecuencia]  IN (N'mensual', N'quincenal', N'bisemanal')))
);
END
GO

-- public.finanzas_fx_rate | ~1 filas
IF OBJECT_ID(N'[dbo].[finanzas_fx_rate]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[finanzas_fx_rate] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_finanzas_fx_rate_id] DEFAULT (NEWSEQUENTIALID()),
  [tenant_id] UNIQUEIDENTIFIER NOT NULL,
  [from_currency] NVARCHAR(50) NOT NULL,
  [to_currency] NVARCHAR(50) NOT NULL,
  [rate] DECIMAL(18,8) NOT NULL,
  [rate_date] DATE NOT NULL,
  [source] NVARCHAR(50) NOT NULL CONSTRAINT [DF_finanzas_fx_rate_source] DEFAULT (N'manual'),
  [is_official] BIT NOT NULL CONSTRAINT [DF_finanzas_fx_rate_is_official] DEFAULT (0),
  [notes] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_finanzas_fx_rate_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [finanzas_fx_rate_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [finanzas_fx_rate_dim_uq] UNIQUE ([tenant_id], [from_currency], [to_currency], [rate_date], [source])
);
END
GO

-- public.finanzas_presupuesto | ~4 filas
IF OBJECT_ID(N'[dbo].[finanzas_presupuesto]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[finanzas_presupuesto] (
  [office_id] NVARCHAR(255) NOT NULL,
  [anio] INT NOT NULL,
  [monto_anual] DECIMAL(14,2) NOT NULL,
  [notes] NVARCHAR(MAX) NULL,
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_finanzas_presupuesto_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  [h1] DECIMAL(14,2) NULL,
  [mensual_2h] DECIMAL(14,2) NULL,
  CONSTRAINT [finanzas_presupuesto_pkey] PRIMARY KEY ([office_id], [anio])
);
END
GO

-- public.finanzas_rc_por_zarpar | ~6 filas
IF OBJECT_ID(N'[dbo].[finanzas_rc_por_zarpar]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[finanzas_rc_por_zarpar] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_finanzas_rc_por_zarpar_id] DEFAULT (NEWSEQUENTIALID()),
  [office_id] NVARCHAR(255) NOT NULL,
  [numero] NVARCHAR(50) NOT NULL,
  [entidad] NVARCHAR(MAX) NULL,
  [monto] DECIMAL(14,2) NULL,
  [registrado_at] DATE NOT NULL CONSTRAINT [DF_finanzas_rc_por_zarpar_registrado_at] DEFAULT (CAST(SYSDATETIMEOFFSET() AT TIME ZONE N'Eastern Standard Time' AS DATE)),
  [zarpo_at] DATE NULL,
  [fuente] NVARCHAR(MAX) NOT NULL,
  [notes] NVARCHAR(MAX) NULL,
  CONSTRAINT [finanzas_rc_por_zarpar_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [finanzas_rc_por_zarpar_office_id_numero_key] UNIQUE ([office_id], [numero])
);
END
GO

-- public.finanzas_sync_state | ~4 filas
IF OBJECT_ID(N'[dbo].[finanzas_sync_state]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[finanzas_sync_state] (
  [scope] NVARCHAR(50) NOT NULL,
  [last_cursor] DATETIMEOFFSET NOT NULL,
  [last_run_at] DATETIMEOFFSET NULL,
  [rows_last_run] INT NULL CONSTRAINT [DF_finanzas_sync_state_rows_last_run] DEFAULT (0),
  CONSTRAINT [finanzas_sync_state_pkey] PRIMARY KEY ([scope])
);
END
GO

-- public.fx_rates | ~897 filas
IF OBJECT_ID(N'[dbo].[fx_rates]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[fx_rates] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_fx_rates_id] DEFAULT (NEWSEQUENTIALID()),
  [source] NVARCHAR(50) NOT NULL CONSTRAINT [DF_fx_rates_source] DEFAULT (N'BANCO_PACIFICO'),
  [currency] NVARCHAR(50) NOT NULL,
  [instrument] NVARCHAR(50) NOT NULL CONSTRAINT [DF_fx_rates_instrument] DEFAULT (N'Transferencia'),
  [rate_buy] DECIMAL(38,10) NULL,
  [rate_sell] DECIMAL(38,10) NOT NULL,
  [quote_style] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_fx_rates_quote_style] DEFAULT (N'USD_PER_UNIT'),
  [quoted_on] DATE NOT NULL,
  [fetched_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_fx_rates_fetched_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [fx_rates_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [fx_rates_source_currency_instrument_quoted_on_key] UNIQUE ([source], [currency], [instrument], [quoted_on]),
  CONSTRAINT [fx_rates_quote_style_check] CHECK (([quote_style]  IN (N'USD_PER_UNIT', N'UNITS_PER_USD')))
);
END
GO

-- public.market_indices_daily | ~31 filas
IF OBJECT_ID(N'[dbo].[market_indices_daily]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[market_indices_daily] (
  [fecha] DATE NOT NULL,
  [indice] NVARCHAR(50) NOT NULL,
  [valor] DECIMAL(38,10) NULL,
  [unidad] NVARCHAR(MAX) NULL,
  [variacion_pct] DECIMAL(38,10) NULL,
  [nota] NVARCHAR(MAX) NULL,
  [fuente] NVARCHAR(MAX) NULL,
  [capturado_at] DATETIMEOFFSET NULL CONSTRAINT [DF_market_indices_daily_capturado_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [market_indices_daily_pkey] PRIMARY KEY ([fecha], [indice])
);
END
GO

-- public.nomina_live | ~88 filas
IF OBJECT_ID(N'[dbo].[nomina_live]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[nomina_live] (
  [office] NVARCHAR(50) NOT NULL,
  [je_number] NVARCHAR(50) NOT NULL,
  [fecha] DATE NULL,
  [periodo] NVARCHAR(50) NULL,
  [clase] NVARCHAR(MAX) NULL,
  [concepto] NVARCHAR(MAX) NULL,
  [notas] NVARCHAR(MAX) NULL,
  [moneda] NVARCHAR(MAX) NULL,
  [total_local] DECIMAL(38,10) NULL,
  [total_usd] DECIMAL(38,10) NULL,
  [girado_usd] DECIMAL(38,10) NULL,
  [n_bancos] INT NULL,
  [bancos] NVARCHAR(MAX) NULL,
  [es_pago] BIT NULL,
  [fx] DECIMAL(38,10) NULL,
  [computed_at] DATETIMEOFFSET NULL CONSTRAINT [DF_nomina_live_computed_at] DEFAULT (SYSDATETIMEOFFSET()),
  [fuente] NVARCHAR(MAX) NULL CONSTRAINT [DF_nomina_live_fuente] DEFAULT (N'magaya'),
  CONSTRAINT [nomina_live_pkey] PRIMARY KEY ([office], [je_number])
);
END
GO

-- public.pagos_recurrentes_live | ~4 filas
IF OBJECT_ID(N'[dbo].[pagos_recurrentes_live]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[pagos_recurrentes_live] (
  [office] NVARCHAR(50) NOT NULL,
  [concepto] NVARCHAR(100) NOT NULL,
  [periodo] NVARCHAR(50) NOT NULL,
  [fecha_pago] DATE NULL,
  [monto] DECIMAL(38,10) NULL,
  [n_giros] INT NULL,
  [detalle] NVARCHAR(MAX) NULL,
  [metodo] NVARCHAR(MAX) NULL,
  [computed_at] DATETIMEOFFSET NULL CONSTRAINT [DF_pagos_recurrentes_live_computed_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [pagos_recurrentes_live_pkey] PRIMARY KEY ([office], [concepto], [periodo])
);
END
GO

-- public.pba_payments | ~65 filas
IF OBJECT_ID(N'[dbo].[pba_payments]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[pba_payments] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_pba_payments_id] DEFAULT (NEWSEQUENTIALID()),
  [shipment_id] UNIQUEIDENTIFIER NULL,
  [client_id] UNIQUEIDENTIFIER NULL,
  [amount] DECIMAL(12,2) NOT NULL,
  [currency] NVARCHAR(MAX) NULL CONSTRAINT [DF_pba_payments_currency] DEFAULT (N'USD'),
  [bl_ref] NVARCHAR(MAX) NULL,
  [guia_ref] NVARCHAR(MAX) NULL,
  [status] NVARCHAR(50) NOT NULL CONSTRAINT [DF_pba_payments_status] DEFAULT (N'PENDING'),
  [due_date] DATE NULL,
  [paid_at] DATETIMEOFFSET NULL,
  [reminder_count] INT NULL CONSTRAINT [DF_pba_payments_reminder_count] DEFAULT (0),
  [last_reminder_at] DATETIMEOFFSET NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_pba_payments_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_pba_payments_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [pba_payments_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [CK_pba_payments_status_enum] CHECK ([status] IN (N'PENDING', N'REMINDED', N'PAID', N'WRITTEN_OFF'))
);
END
GO

-- public.recurring_movement | ~51 filas
IF OBJECT_ID(N'[dbo].[recurring_movement]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[recurring_movement] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_recurring_movement_id] DEFAULT (NEWSEQUENTIALID()),
  [tenant_id] UNIQUEIDENTIFIER NOT NULL,
  [office_id] UNIQUEIDENTIFIER NOT NULL,
  [bank_account_id] UNIQUEIDENTIFIER NULL,
  [description] NVARCHAR(MAX) NOT NULL,
  [direction] NVARCHAR(MAX) NOT NULL,
  [category] NVARCHAR(MAX) NOT NULL,
  [party_id] UNIQUEIDENTIFIER NULL,
  [amount] DECIMAL(18,2) NOT NULL,
  [currency] NVARCHAR(MAX) NOT NULL,
  [frequency] NVARCHAR(MAX) NOT NULL,
  [day_of_month] INT NULL,
  [day_of_week] INT NULL,
  [next_occurrence_date] DATE NOT NULL,
  [last_generated_date] DATE NULL,
  [active_from] DATE NOT NULL CONSTRAINT [DF_recurring_movement_active_from] DEFAULT (CAST(SYSUTCDATETIME() AS DATE)),
  [active_to] DATE NULL,
  [auto_create] BIT NOT NULL CONSTRAINT [DF_recurring_movement_auto_create] DEFAULT (1),
  [reminder_days_before] INT NULL CONSTRAINT [DF_recurring_movement_reminder_days_before] DEFAULT (3),
  [active] BIT NOT NULL CONSTRAINT [DF_recurring_movement_active] DEFAULT (1),
  [notes] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_recurring_movement_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_recurring_movement_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [recurring_movement_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.scheduled_payment | ~21 filas
IF OBJECT_ID(N'[dbo].[scheduled_payment]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[scheduled_payment] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_scheduled_payment_id] DEFAULT (NEWSEQUENTIALID()),
  [tenant_id] UNIQUEIDENTIFIER NOT NULL,
  [office_id] UNIQUEIDENTIFIER NOT NULL,
  [external_guid] NVARCHAR(100) NOT NULL,
  [bill_number] NVARCHAR(MAX) NULL,
  [counterparty_name] NVARCHAR(MAX) NOT NULL,
  [direction] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_scheduled_payment_direction] DEFAULT (N'outflow'),
  [scheduled_date] DATE NOT NULL,
  [amount_usd] DECIMAL(14,2) NOT NULL,
  [bank_account_id] UNIQUEIDENTIFIER NULL,
  [notes] NVARCHAR(MAX) NULL,
  [status] NVARCHAR(50) NOT NULL CONSTRAINT [DF_scheduled_payment_status] DEFAULT (N'scheduled'),
  [created_by] UNIQUEIDENTIFIER NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_scheduled_payment_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_scheduled_payment_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  [executed_at] DATETIMEOFFSET NULL,
  [executed_by] UNIQUEIDENTIFIER NULL,
  [cancelled_at] DATETIMEOFFSET NULL,
  [cancelled_by] UNIQUEIDENTIFIER NULL,
  [cancel_reason] NVARCHAR(MAX) NULL,
  CONSTRAINT [scheduled_payment_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.vendor_flexibility | ~41 filas
IF OBJECT_ID(N'[dbo].[vendor_flexibility]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[vendor_flexibility] (
  [tenant_id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_vendor_flexibility_tenant_id] DEFAULT ('a4e3e84c-7fca-4ce3-8889-1f31d8d1366f'),
  [counterparty_key] NVARCHAR(100) NOT NULL,
  [tier] NVARCHAR(50) NOT NULL,
  [max_push_weeks] INT NOT NULL CONSTRAINT [DF_vendor_flexibility_max_push_weeks] DEFAULT (0),
  [notes] NVARCHAR(MAX) NULL,
  [set_by] UNIQUEIDENTIFIER NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_vendor_flexibility_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_vendor_flexibility_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [vendor_flexibility_pkey] PRIMARY KEY ([tenant_id], [counterparty_key])
);
END
GO

-- public.vendor_profile | ~37 filas
IF OBJECT_ID(N'[dbo].[vendor_profile]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[vendor_profile] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_vendor_profile_id] DEFAULT (NEWSEQUENTIALID()),
  [tenant_id] UNIQUEIDENTIFIER NOT NULL,
  [vendor_name] NVARCHAR(100) NOT NULL,
  [intensity_score_stars] SMALLINT NULL,
  [notes] NVARCHAR(MAX) NULL,
  [last_rated_at] DATETIMEOFFSET NULL,
  [rated_by] UNIQUEIDENTIFIER NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_vendor_profile_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_vendor_profile_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [vendor_profile_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [vendor_profile_tenant_id_vendor_name_key] UNIQUE ([tenant_id], [vendor_name])
);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'arap_live_open_idx' AND object_id = OBJECT_ID(N'[dbo].[arap_live_open]'))
CREATE INDEX [arap_live_open_idx] ON [dbo].[arap_live_open] ([office], [tipo]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_bank_account_tenant_office' AND object_id = OBJECT_ID(N'[dbo].[bank_account]'))
CREATE INDEX [idx_bank_account_tenant_office] ON [dbo].[bank_account] ([tenant_id], [office_id]) WHERE ([active] = 1);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'bank_transaction_subcategory_idx' AND object_id = OBJECT_ID(N'[dbo].[bank_transaction]'))
CREATE INDEX [bank_transaction_subcategory_idx] ON [dbo].[bank_transaction] ([tenant_id], [subcategory]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_bank_txn_account_date' AND object_id = OBJECT_ID(N'[dbo].[bank_transaction]'))
CREATE INDEX [idx_bank_txn_account_date] ON [dbo].[bank_transaction] ([bank_account_id], [transaction_date] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_bank_txn_status' AND object_id = OBJECT_ID(N'[dbo].[bank_transaction]'))
CREATE INDEX [idx_bank_txn_status] ON [dbo].[bank_transaction] ([tenant_id], [status]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_bank_txn_unreconciled' AND object_id = OBJECT_ID(N'[dbo].[bank_transaction]'))
CREATE INDEX [idx_bank_txn_unreconciled] ON [dbo].[bank_transaction] ([tenant_id], [transaction_date] DESC) WHERE ([status]  IN (N'imported', N'matched'));
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'cash_movement_counterparty_idx' AND object_id = OBJECT_ID(N'[dbo].[cash_movement]'))
CREATE INDEX [cash_movement_counterparty_idx] ON [dbo].[cash_movement] ([tenant_id], [counterparty_name]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_cash_movement_forecast' AND object_id = OBJECT_ID(N'[dbo].[cash_movement]'))
CREATE INDEX [idx_cash_movement_forecast] ON [dbo].[cash_movement] ([tenant_id], [expected_date]) WHERE ([status]  IN (N'forecast', N'committed', N'scheduled', N'overdue'));
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_cash_movement_office' AND object_id = OBJECT_ID(N'[dbo].[cash_movement]'))
CREATE INDEX [idx_cash_movement_office] ON [dbo].[cash_movement] ([office_id], [expected_date] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_cash_movement_party' AND object_id = OBJECT_ID(N'[dbo].[cash_movement]'))
CREATE INDEX [idx_cash_movement_party] ON [dbo].[cash_movement] ([party_id]) WHERE ([party_id] IS NOT NULL);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_closings_client_id' AND object_id = OBJECT_ID(N'[dbo].[closings]'))
CREATE INDEX [idx_closings_client_id] ON [dbo].[closings] ([client_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_closings_closing_date' AND object_id = OBJECT_ID(N'[dbo].[closings]'))
CREATE INDEX [idx_closings_closing_date] ON [dbo].[closings] ([closing_date]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_closings_executive_id' AND object_id = OBJECT_ID(N'[dbo].[closings]'))
CREATE INDEX [idx_closings_executive_id] ON [dbo].[closings] ([executive_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_closings_year_week' AND object_id = OBJECT_ID(N'[dbo].[closings]'))
CREATE INDEX [idx_closings_year_week] ON [dbo].[closings] ([year], [week]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_fbm_office_estado' AND object_id = OBJECT_ID(N'[dbo].[finanzas_bank_match]'))
CREATE INDEX [idx_fbm_office_estado] ON [dbo].[finanzas_bank_match] ([office_id], [estado]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_finanzas_fx_rate_lookup' AND object_id = OBJECT_ID(N'[dbo].[finanzas_fx_rate]'))
CREATE INDEX [idx_finanzas_fx_rate_lookup] ON [dbo].[finanzas_fx_rate] ([tenant_id], [from_currency], [to_currency], [rate_date] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'fx_rates_lookup_idx' AND object_id = OBJECT_ID(N'[dbo].[fx_rates]'))
CREATE INDEX [fx_rates_lookup_idx] ON [dbo].[fx_rates] ([currency], [quoted_on] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ix_nomina_live_per' AND object_id = OBJECT_ID(N'[dbo].[nomina_live]'))
CREATE INDEX [ix_nomina_live_per] ON [dbo].[nomina_live] ([office], [periodo]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'pba_client_idx' AND object_id = OBJECT_ID(N'[dbo].[pba_payments]'))
CREATE INDEX [pba_client_idx] ON [dbo].[pba_payments] ([client_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'pba_shipment_idx' AND object_id = OBJECT_ID(N'[dbo].[pba_payments]'))
CREATE INDEX [pba_shipment_idx] ON [dbo].[pba_payments] ([shipment_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'pba_status_idx' AND object_id = OBJECT_ID(N'[dbo].[pba_payments]'))
CREATE INDEX [pba_status_idx] ON [dbo].[pba_payments] ([status]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_recurring_active' AND object_id = OBJECT_ID(N'[dbo].[recurring_movement]'))
CREATE INDEX [idx_recurring_active] ON [dbo].[recurring_movement] ([tenant_id], [next_occurrence_date]) WHERE (([active] = 1) AND ([auto_create] = 1));
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'scheduled_payment_external_guid_idx' AND object_id = OBJECT_ID(N'[dbo].[scheduled_payment]'))
CREATE INDEX [scheduled_payment_external_guid_idx] ON [dbo].[scheduled_payment] ([tenant_id], [external_guid]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'scheduled_payment_office_status_idx' AND object_id = OBJECT_ID(N'[dbo].[scheduled_payment]'))
CREATE INDEX [scheduled_payment_office_status_idx] ON [dbo].[scheduled_payment] ([office_id], [status]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'scheduled_payment_tenant_date_idx' AND object_id = OBJECT_ID(N'[dbo].[scheduled_payment]'))
CREATE INDEX [scheduled_payment_tenant_date_idx] ON [dbo].[scheduled_payment] ([tenant_id], [scheduled_date]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_vendor_flexibility_tier' AND object_id = OBJECT_ID(N'[dbo].[vendor_flexibility]'))
CREATE INDEX [idx_vendor_flexibility_tier] ON [dbo].[vendor_flexibility] ([tenant_id], [tier]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'vendor_profile_intensity_idx' AND object_id = OBJECT_ID(N'[dbo].[vendor_profile]'))
CREATE INDEX [vendor_profile_intensity_idx] ON [dbo].[vendor_profile] ([tenant_id], [intensity_score_stars] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'vendor_profile_tenant_idx' AND object_id = OBJECT_ID(N'[dbo].[vendor_profile]'))
CREATE INDEX [vendor_profile_tenant_idx] ON [dbo].[vendor_profile] ([tenant_id]);
GO
