-- 070 · Integración Magaya: tablas e índices
-- Generado por migration/tools/to_tsql.mjs desde el catálogo de Supabase (2026-09-29). No editar a mano:
-- cambiar el generador y volver a correrlo. Idempotente: se puede ejecutar varias veces.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- public.ar_ap_sync_queue | ~630 filas
IF OBJECT_ID(N'[dbo].[ar_ap_sync_queue]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[ar_ap_sync_queue] (
  [id] BIGINT IDENTITY(1,1) NOT NULL,
  [scope] NVARCHAR(50) NOT NULL,
  [start_date] DATE NOT NULL,
  [end_date] DATE NOT NULL,
  [recheck_interval] BIGINT NOT NULL CONSTRAINT [DF_ar_ap_sync_queue_recheck_interval] DEFAULT (86400),
  [status] NVARCHAR(50) NOT NULL CONSTRAINT [DF_ar_ap_sync_queue_status] DEFAULT (N'idle'),
  [request_id] BIGINT NULL,
  [attempts] INT NOT NULL CONSTRAINT [DF_ar_ap_sync_queue_attempts] DEFAULT (0),
  [last_run_at] DATETIMEOFFSET NULL,
  [last_ok_at] DATETIMEOFFSET NULL,
  [last_response] NVARCHAR(MAX) NULL,
  CONSTRAINT [ar_ap_sync_queue_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [ar_ap_sync_queue_scope_start_date_end_date_key] UNIQUE ([scope], [start_date], [end_date]),
  CONSTRAINT [CK_ar_ap_sync_queue_last_response_json] CHECK (ISJSON([last_response]) = 1)
);
END
GO

-- public.magaya_accounts | ~278 filas
IF OBJECT_ID(N'[dbo].[magaya_accounts]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[magaya_accounts] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_magaya_accounts_id] DEFAULT (NEWSEQUENTIALID()),
  [company_id] UNIQUEIDENTIFIER NOT NULL,
  [account_number] NVARCHAR(50) NULL,
  [name] NVARCHAR(MAX) NOT NULL,
  [account_type] NVARCHAR(50) NOT NULL,
  [currency_code] NVARCHAR(50) NULL CONSTRAINT [DF_magaya_accounts_currency_code] DEFAULT (N'USD'),
  [parent_account_number] NVARCHAR(MAX) NULL,
  [parent_account_name] NVARCHAR(MAX) NULL,
  [magaya_guid] NVARCHAR(MAX) NULL,
  [is_active] BIT NULL CONSTRAINT [DF_magaya_accounts_is_active] DEFAULT (1),
  [raw_xml] NVARCHAR(MAX) NULL,
  [synced_at] DATETIMEOFFSET NULL CONSTRAINT [DF_magaya_accounts_synced_at] DEFAULT (SYSDATETIMEOFFSET()),
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_magaya_accounts_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_magaya_accounts_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [magaya_accounts_pkey] PRIMARY KEY ([id])
);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'magaya_accounts_company_id_account_number_currency_code_key' AND object_id = OBJECT_ID(N'[dbo].[magaya_accounts]'))
CREATE UNIQUE INDEX [magaya_accounts_company_id_account_number_currency_code_key] ON [dbo].[magaya_accounts] ([company_id], [account_number], [currency_code]) WHERE [account_number] IS NOT NULL AND [currency_code] IS NOT NULL;
GO

-- public.magaya_balance_override | ~239 filas
IF OBJECT_ID(N'[dbo].[magaya_balance_override]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[magaya_balance_override] (
  [office_id] UNIQUEIDENTIFIER NOT NULL,
  [entity_name_clean] NVARCHAR(255) NOT NULL,
  [source] NVARCHAR(MAX) NOT NULL,
  [manual_balance] DECIMAL(15,2) NULL,
  [reason] NVARCHAR(MAX) NULL,
  [set_by] NVARCHAR(MAX) NULL CONSTRAINT [DF_magaya_balance_override_set_by] DEFAULT (N'system'),
  [set_at] DATETIMEOFFSET NULL CONSTRAINT [DF_magaya_balance_override_set_at] DEFAULT (SYSDATETIMEOFFSET()),
  [kind] NVARCHAR(MAX) NULL,
  CONSTRAINT [magaya_balance_override_pkey] PRIMARY KEY ([office_id], [entity_name_clean])
);
END
GO

-- public.magaya_bills | ~43,950 filas
IF OBJECT_ID(N'[dbo].[magaya_bills]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[magaya_bills] (
  [id] BIGINT IDENTITY(1,1) NOT NULL,
  [bill_number] NVARCHAR(50) NOT NULL,
  [guid] NVARCHAR(MAX) NULL,
  [vendor_name] NVARCHAR(255) NULL,
  [vendor_guid] NVARCHAR(MAX) NULL,
  [status] NVARCHAR(50) NULL,
  [total_amount] DECIMAL(38,10) NULL CONSTRAINT [DF_magaya_bills_total_amount] DEFAULT (0),
  [amount_paid] DECIMAL(38,10) NULL CONSTRAINT [DF_magaya_bills_amount_paid] DEFAULT (0),
  [issue_date] DATE NULL,
  [due_date] DATE NULL,
  [currency] NVARCHAR(MAX) NULL CONSTRAINT [DF_magaya_bills_currency] DEFAULT (N'USD'),
  [created_by] NVARCHAR(MAX) NULL,
  [description] NVARCHAR(MAX) NULL,
  [payment_terms] NVARCHAR(MAX) NULL,
  [synced_at] DATETIMEOFFSET NULL CONSTRAINT [DF_magaya_bills_synced_at] DEFAULT (SYSDATETIMEOFFSET()),
  [company_id] UNIQUEIDENTIFIER NOT NULL,
  CONSTRAINT [magaya_bills_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [magaya_bills_company_number_key] UNIQUE ([company_id], [bill_number])
);
END
GO

-- public.magaya_cargo_releases | ~15,442 filas
IF OBJECT_ID(N'[dbo].[magaya_cargo_releases]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[magaya_cargo_releases] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_magaya_cargo_releases_id] DEFAULT (NEWSEQUENTIALID()),
  [cr_number] NVARCHAR(100) NOT NULL,
  [guid] NVARCHAR(MAX) NULL,
  [shipper] NVARCHAR(MAX) NULL,
  [consignee] NVARCHAR(MAX) NULL,
  [carrier] NVARCHAR(MAX) NULL,
  [tracking_number] NVARCHAR(MAX) NULL,
  [origin] NVARCHAR(MAX) NULL,
  [destination] NVARCHAR(MAX) NULL,
  [status] NVARCHAR(MAX) NULL,
  [pieces] INT NULL CONSTRAINT [DF_magaya_cargo_releases_pieces] DEFAULT (0),
  [weight] DECIMAL(38,10) NULL CONSTRAINT [DF_magaya_cargo_releases_weight] DEFAULT (0),
  [created_by] NVARCHAR(MAX) NULL,
  [issued_by] NVARCHAR(MAX) NULL,
  [created_on] DATE NULL,
  [synced_at] DATETIMEOFFSET NULL CONSTRAINT [DF_magaya_cargo_releases_synced_at] DEFAULT (SYSDATETIMEOFFSET()),
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_magaya_cargo_releases_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [company_id] UNIQUEIDENTIFIER NOT NULL,
  CONSTRAINT [magaya_cargo_releases_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [magaya_cargo_releases_company_number_key] UNIQUE ([company_id], [cr_number])
);
END
GO

-- public.magaya_charge_definitions | ~168 filas
IF OBJECT_ID(N'[dbo].[magaya_charge_definitions]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[magaya_charge_definitions] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_magaya_charge_definitions_id] DEFAULT (NEWSEQUENTIALID()),
  [company_id] UNIQUEIDENTIFIER NOT NULL,
  [code] NVARCHAR(50) NOT NULL,
  [description] NVARCHAR(MAX) NOT NULL,
  [charge_type] NVARCHAR(MAX) NULL,
  [account_name] NVARCHAR(MAX) NULL,
  [account_type] NVARCHAR(MAX) NULL,
  [currency_code] NVARCHAR(MAX) NULL CONSTRAINT [DF_magaya_charge_definitions_currency_code] DEFAULT (N'USD'),
  [default_amount] DECIMAL(18,2) NULL CONSTRAINT [DF_magaya_charge_definitions_default_amount] DEFAULT (0),
  [enforce_3rd_party_billing] BIT NULL CONSTRAINT [DF_magaya_charge_definitions_enforce_3rd_party_billing] DEFAULT (0),
  [raw_xml] NVARCHAR(MAX) NULL,
  [synced_at] DATETIMEOFFSET NULL CONSTRAINT [DF_magaya_charge_definitions_synced_at] DEFAULT (SYSDATETIMEOFFSET()),
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_magaya_charge_definitions_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_magaya_charge_definitions_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [magaya_charge_definitions_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [magaya_charge_definitions_company_id_code_key] UNIQUE ([company_id], [code])
);
END
GO

-- public.magaya_charges_extracted | ~19,551 filas
IF OBJECT_ID(N'[dbo].[magaya_charges_extracted]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[magaya_charges_extracted] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_magaya_charges_extracted_id] DEFAULT (NEWSEQUENTIALID()),
  [tenant_id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_magaya_charges_extracted_tenant_id] DEFAULT ('a4e3e84c-7fca-4ce3-8889-1f31d8d1366f'),
  [office_id] UNIQUEIDENTIFIER NOT NULL,
  [txn_guid] NVARCHAR(100) NOT NULL,
  [txn_number] NVARCHAR(MAX) NULL,
  [txn_type] NVARCHAR(50) NOT NULL,
  [txn_billing_client] NVARCHAR(255) NULL,
  [txn_date] DATE NULL,
  [charge_guid] NVARCHAR(100) NULL,
  [charge_amount] DECIMAL(14,2) NULL,
  [charge_currency] NVARCHAR(MAX) NULL,
  [charge_code] NVARCHAR(MAX) NULL,
  [charge_description] NVARCHAR(MAX) NULL,
  [account_type] NVARCHAR(50) NULL,
  [account_name] NVARCHAR(MAX) NULL,
  [entity_name] NVARCHAR(255) NULL,
  [entity_type] NVARCHAR(MAX) NULL,
  [is_prepaid] BIT NULL,
  [is_third_party] BIT NULL,
  [charge_status] NVARCHAR(MAX) NULL,
  [extracted_at] DATETIMEOFFSET NULL CONSTRAINT [DF_magaya_charges_extracted_extracted_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [magaya_charges_extracted_pkey] PRIMARY KEY ([id])
);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'magaya_charges_extracted_txn_guid_charge_guid_key' AND object_id = OBJECT_ID(N'[dbo].[magaya_charges_extracted]'))
CREATE UNIQUE INDEX [magaya_charges_extracted_txn_guid_charge_guid_key] ON [dbo].[magaya_charges_extracted] ([txn_guid], [charge_guid]) WHERE [charge_guid] IS NOT NULL;
GO

-- public.magaya_clients | ~12,937 filas
IF OBJECT_ID(N'[dbo].[magaya_clients]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[magaya_clients] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_magaya_clients_id] DEFAULT (NEWSEQUENTIALID()),
  [magaya_id] NVARCHAR(100) NOT NULL,
  [name] NVARCHAR(255) NULL CONSTRAINT [DF_magaya_clients_name] DEFAULT (N''),
  [address] NVARCHAR(MAX) NULL CONSTRAINT [DF_magaya_clients_address] DEFAULT (N''),
  [city] NVARCHAR(MAX) NULL CONSTRAINT [DF_magaya_clients_city] DEFAULT (N''),
  [country] NVARCHAR(MAX) NULL CONSTRAINT [DF_magaya_clients_country] DEFAULT (N''),
  [email] NVARCHAR(MAX) NULL CONSTRAINT [DF_magaya_clients_email] DEFAULT (N''),
  [phone] NVARCHAR(MAX) NULL CONSTRAINT [DF_magaya_clients_phone] DEFAULT (N''),
  [type] NVARCHAR(MAX) NULL CONSTRAINT [DF_magaya_clients_type] DEFAULT (N''),
  [synced_at] DATETIMEOFFSET NULL CONSTRAINT [DF_magaya_clients_synced_at] DEFAULT (SYSDATETIMEOFFSET()),
  [company_id] UNIQUEIDENTIFIER NOT NULL,
  CONSTRAINT [magaya_clients_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [magaya_clients_company_magaya_id_key] UNIQUE ([company_id], [magaya_id])
);
END
GO

-- public.magaya_companies | ~4 filas
IF OBJECT_ID(N'[dbo].[magaya_companies]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[magaya_companies] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_magaya_companies_id] DEFAULT (NEWSEQUENTIALID()),
  [code] NVARCHAR(50) NOT NULL,
  [name] NVARCHAR(MAX) NOT NULL,
  [country] NVARCHAR(MAX) NOT NULL,
  [magaya_server] NVARCHAR(MAX) NULL,
  [magaya_port] INT NULL CONSTRAINT [DF_magaya_companies_magaya_port] DEFAULT (3691),
  [magaya_api_user] NVARCHAR(MAX) NULL,
  [magaya_home_currency] NVARCHAR(MAX) NULL CONSTRAINT [DF_magaya_companies_magaya_home_currency] DEFAULT (N'USD'),
  [is_active] BIT NULL CONSTRAINT [DF_magaya_companies_is_active] DEFAULT (1),
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_magaya_companies_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_magaya_companies_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [magaya_companies_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [magaya_companies_code_key] UNIQUE ([code])
);
END
GO

-- public.magaya_currencies | ~2 filas
IF OBJECT_ID(N'[dbo].[magaya_currencies]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[magaya_currencies] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_magaya_currencies_id] DEFAULT (NEWSEQUENTIALID()),
  [company_id] UNIQUEIDENTIFIER NOT NULL,
  [currency_code] NVARCHAR(50) NOT NULL,
  [name] NVARCHAR(MAX) NOT NULL,
  [exchange_rate] DECIMAL(24,20) NULL,
  [decimal_places] INT NULL CONSTRAINT [DF_magaya_currencies_decimal_places] DEFAULT (2),
  [is_home_currency] BIT NULL CONSTRAINT [DF_magaya_currencies_is_home_currency] DEFAULT (0),
  [synced_at] DATETIMEOFFSET NULL CONSTRAINT [DF_magaya_currencies_synced_at] DEFAULT (SYSDATETIMEOFFSET()),
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_magaya_currencies_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_magaya_currencies_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [magaya_currencies_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [magaya_currencies_company_id_currency_code_key] UNIQUE ([company_id], [currency_code])
);
END
GO

-- public.magaya_entities | ~28,405 filas
IF OBJECT_ID(N'[dbo].[magaya_entities]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[magaya_entities] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_magaya_entities_id] DEFAULT (NEWSEQUENTIALID()),
  [company_id] UNIQUEIDENTIFIER NOT NULL,
  [magaya_guid] NVARCHAR(100) NULL,
  [entity_type] NVARCHAR(50) NULL,
  [name] NVARCHAR(450) NOT NULL,
  [code] NVARCHAR(MAX) NULL,
  [tax_id] NVARCHAR(MAX) NULL,
  [email] NVARCHAR(MAX) NULL,
  [phone] NVARCHAR(MAX) NULL,
  [address_line1] NVARCHAR(MAX) NULL,
  [address_line2] NVARCHAR(MAX) NULL,
  [city] NVARCHAR(MAX) NULL,
  [state] NVARCHAR(MAX) NULL,
  [country] NVARCHAR(MAX) NULL,
  [zip_code] NVARCHAR(MAX) NULL,
  [is_active] BIT NULL CONSTRAINT [DF_magaya_entities_is_active] DEFAULT (1),
  [raw_xml] NVARCHAR(MAX) NULL,
  [synced_at] DATETIMEOFFSET NULL CONSTRAINT [DF_magaya_entities_synced_at] DEFAULT (SYSDATETIMEOFFSET()),
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_magaya_entities_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_magaya_entities_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  [name_normalized] NVARCHAR(255) NULL,
  CONSTRAINT [magaya_entities_pkey] PRIMARY KEY ([id])
);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'magaya_entities_company_id_magaya_guid_key' AND object_id = OBJECT_ID(N'[dbo].[magaya_entities]'))
CREATE UNIQUE INDEX [magaya_entities_company_id_magaya_guid_key] ON [dbo].[magaya_entities] ([company_id], [magaya_guid]) WHERE [magaya_guid] IS NOT NULL;
GO

-- public.magaya_entity_balance | ~737 filas
IF OBJECT_ID(N'[dbo].[magaya_entity_balance]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[magaya_entity_balance] (
  [tenant_id] UNIQUEIDENTIFIER NOT NULL,
  [office_id] UNIQUEIDENTIFIER NOT NULL,
  [entity_guid] UNIQUEIDENTIFIER NOT NULL,
  [entity_name] NVARCHAR(MAX) NOT NULL,
  [kind] NVARCHAR(50) NOT NULL,
  [balance_usd] DECIMAL(38,10) NOT NULL,
  [source_bill_guid] UNIQUEIDENTIFIER NULL,
  [source_bill_number] NVARCHAR(MAX) NULL,
  [fetched_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_magaya_entity_balance_fetched_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [magaya_entity_balance_pkey] PRIMARY KEY ([tenant_id], [office_id], [entity_guid], [kind])
);
END
GO

-- public.magaya_invoices | ~28,472 filas
IF OBJECT_ID(N'[dbo].[magaya_invoices]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[magaya_invoices] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_magaya_invoices_id] DEFAULT (NEWSEQUENTIALID()),
  [invoice_number] NVARCHAR(50) NOT NULL,
  [client_id] NVARCHAR(MAX) NULL CONSTRAINT [DF_magaya_invoices_client_id] DEFAULT (N''),
  [amount] DECIMAL(15,2) NULL CONSTRAINT [DF_magaya_invoices_amount] DEFAULT (0),
  [currency] NVARCHAR(MAX) NULL CONSTRAINT [DF_magaya_invoices_currency] DEFAULT (N'USD'),
  [status] NVARCHAR(50) NULL CONSTRAINT [DF_magaya_invoices_status] DEFAULT (N''),
  [issue_date] DATE NULL,
  [due_date] DATE NULL,
  [synced_at] DATETIMEOFFSET NULL CONSTRAINT [DF_magaya_invoices_synced_at] DEFAULT (SYSDATETIMEOFFSET()),
  [guid] NVARCHAR(100) NULL,
  [client_name] NVARCHAR(MAX) NULL,
  [client_guid] NVARCHAR(MAX) NULL,
  [created_by] NVARCHAR(MAX) NULL,
  [total_amount] DECIMAL(38,10) NULL,
  [amount_paid] DECIMAL(38,10) NULL,
  [payment_terms] NVARCHAR(MAX) NULL,
  [description] NVARCHAR(MAX) NULL,
  [company_id] UNIQUEIDENTIFIER NOT NULL,
  CONSTRAINT [magaya_invoices_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [magaya_invoices_company_number_key] UNIQUE ([company_id], [invoice_number])
);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'magaya_invoices_company_guid_key' AND object_id = OBJECT_ID(N'[dbo].[magaya_invoices]'))
CREATE UNIQUE INDEX [magaya_invoices_company_guid_key] ON [dbo].[magaya_invoices] ([company_id], [guid]) WHERE [guid] IS NOT NULL;
GO

-- public.magaya_journal_entries | ~4,895 filas
IF OBJECT_ID(N'[dbo].[magaya_journal_entries]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[magaya_journal_entries] (
  [id] NVARCHAR(100) NOT NULL,
  [number] INT NOT NULL,
  [created_on] DATETIMEOFFSET NULL,
  [created_by] NVARCHAR(MAX) NULL,
  [notes] NVARCHAR(MAX) NULL,
  [total_debit] DECIMAL(12,2) NULL,
  [total_credit] DECIMAL(12,2) NULL,
  [currency] NVARCHAR(MAX) NULL CONSTRAINT [DF_magaya_journal_entries_currency] DEFAULT (N'USD'),
  [has_attachments] BIT NULL CONSTRAINT [DF_magaya_journal_entries_has_attachments] DEFAULT (0),
  [synced_at] DATETIMEOFFSET NULL CONSTRAINT [DF_magaya_journal_entries_synced_at] DEFAULT (SYSDATETIMEOFFSET()),
  [company_id] UNIQUEIDENTIFIER NOT NULL,
  CONSTRAINT [magaya_journal_entries_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [magaya_journal_entries_company_number_key] UNIQUE ([company_id], [number])
);
END
GO

-- public.magaya_journal_entry_lines | ~17,596 filas
IF OBJECT_ID(N'[dbo].[magaya_journal_entry_lines]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[magaya_journal_entry_lines] (
  [id] NVARCHAR(50) NOT NULL,
  [journal_entry_id] NVARCHAR(100) NOT NULL,
  [journal_entry_number] INT NOT NULL,
  [line_index] INT NOT NULL,
  [account_type] NVARCHAR(50) NULL,
  [account_name] NVARCHAR(100) NULL,
  [account_number] NVARCHAR(MAX) NULL,
  [debit_amount] DECIMAL(12,2) NULL CONSTRAINT [DF_magaya_journal_entry_lines_debit_amount] DEFAULT (0),
  [credit_amount] DECIMAL(12,2) NULL CONSTRAINT [DF_magaya_journal_entry_lines_credit_amount] DEFAULT (0),
  [description] NVARCHAR(MAX) NULL,
  [exchange_rate] DECIMAL(10,4) NULL CONSTRAINT [DF_magaya_journal_entry_lines_exchange_rate] DEFAULT (1.0),
  [currency] NVARCHAR(MAX) NULL CONSTRAINT [DF_magaya_journal_entry_lines_currency] DEFAULT (N'USD'),
  [company_id] UNIQUEIDENTIFIER NOT NULL,
  CONSTRAINT [magaya_journal_entry_lines_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [magaya_journal_entry_lines_company_key] UNIQUE ([company_id], [journal_entry_number], [line_index])
);
END
GO

-- public.magaya_payment_application | ~207,321 filas
IF OBJECT_ID(N'[dbo].[magaya_payment_application]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[magaya_payment_application] (
  [company_id] UNIQUEIDENTIFIER NOT NULL,
  [payment_guid] UNIQUEIDENTIFIER NOT NULL,
  [item_paid_guid] UNIQUEIDENTIFIER NOT NULL,
  [amount_paid] DECIMAL(38,10) NOT NULL,
  [payment_date] DATETIMEOFFSET NULL,
  CONSTRAINT [magaya_payment_application_pkey] PRIMARY KEY ([company_id], [payment_guid], [item_paid_guid])
);
END
GO

-- public.magaya_pickup_orders | ~6,872 filas
IF OBJECT_ID(N'[dbo].[magaya_pickup_orders]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[magaya_pickup_orders] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_magaya_pickup_orders_id] DEFAULT (NEWSEQUENTIALID()),
  [pk_number] NVARCHAR(50) NOT NULL,
  [guid] NVARCHAR(MAX) NULL,
  [vendor] NVARCHAR(MAX) NULL,
  [vendor_guid] NVARCHAR(MAX) NULL,
  [created_by] NVARCHAR(MAX) NULL,
  [total_amount] DECIMAL(38,10) NULL,
  [currency] NVARCHAR(MAX) NULL CONSTRAINT [DF_magaya_pickup_orders_currency] DEFAULT (N'USD'),
  [status] NVARCHAR(MAX) NULL,
  [created_on] DATE NULL,
  [due_date] DATE NULL,
  [description] NVARCHAR(MAX) NULL,
  [synced_at] DATETIMEOFFSET NULL CONSTRAINT [DF_magaya_pickup_orders_synced_at] DEFAULT (SYSDATETIMEOFFSET()),
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_magaya_pickup_orders_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [shipper] NVARCHAR(MAX) NULL,
  [consignee] NVARCHAR(MAX) NULL,
  [pieces] INT NULL CONSTRAINT [DF_magaya_pickup_orders_pieces] DEFAULT (0),
  [weight] DECIMAL(38,10) NULL CONSTRAINT [DF_magaya_pickup_orders_weight] DEFAULT (0),
  [company_id] UNIQUEIDENTIFIER NOT NULL,
  CONSTRAINT [magaya_purchase_orders_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [magaya_pickup_orders_company_number_key] UNIQUE ([company_id], [pk_number])
);
END
GO

-- public.magaya_shipments | ~6,696 filas
IF OBJECT_ID(N'[dbo].[magaya_shipments]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[magaya_shipments] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_magaya_shipments_id] DEFAULT (NEWSEQUENTIALID()),
  [shipment_number] NVARCHAR(255) NOT NULL,
  [shipper] NVARCHAR(MAX) NULL CONSTRAINT [DF_magaya_shipments_shipper] DEFAULT (N''),
  [consignee] NVARCHAR(MAX) NULL CONSTRAINT [DF_magaya_shipments_consignee] DEFAULT (N''),
  [origin] NVARCHAR(MAX) NULL CONSTRAINT [DF_magaya_shipments_origin] DEFAULT (N''),
  [destination] NVARCHAR(MAX) NULL CONSTRAINT [DF_magaya_shipments_destination] DEFAULT (N''),
  [status] NVARCHAR(50) NULL CONSTRAINT [DF_magaya_shipments_status] DEFAULT (N''),
  [etd] DATE NULL,
  [eta] DATE NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_magaya_shipments_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [synced_at] DATETIMEOFFSET NULL CONSTRAINT [DF_magaya_shipments_synced_at] DEFAULT (SYSDATETIMEOFFSET()),
  [type] NVARCHAR(50) NULL,
  [guid] NVARCHAR(MAX) NULL,
  [created_by] NVARCHAR(MAX) NULL,
  [carrier] NVARCHAR(MAX) NULL,
  [mode_of_transport] NVARCHAR(MAX) NULL,
  [pieces] INT NULL CONSTRAINT [DF_magaya_shipments_pieces] DEFAULT (0),
  [weight] DECIMAL(38,10) NULL CONSTRAINT [DF_magaya_shipments_weight] DEFAULT (0),
  [tracking_number] NVARCHAR(MAX) NULL,
  [issued_by] NVARCHAR(MAX) NULL,
  [total_revenue] DECIMAL(14,2) NULL CONSTRAINT [DF_magaya_shipments_total_revenue] DEFAULT (0),
  [total_charges] INT NULL CONSTRAINT [DF_magaya_shipments_total_charges] DEFAULT (0),
  [charges_synced_at] DATETIMEOFFSET NULL,
  [client_name] NVARCHAR(MAX) NULL,
  [client_guid] NVARCHAR(MAX) NULL,
  [billing_client_name] NVARCHAR(MAX) NULL,
  [description_of_goods] NVARCHAR(MAX) NULL,
  [container_numbers] NVARCHAR(MAX) NULL,
  [total_containers] INT NULL CONSTRAINT [DF_magaya_shipments_total_containers] DEFAULT (0),
  [service_type] NVARCHAR(MAX) NULL,
  [direction] NVARCHAR(MAX) NULL,
  [layout_type] NVARCHAR(MAX) NULL,
  [vessel_name] NVARCHAR(MAX) NULL,
  [voyage] NVARCHAR(MAX) NULL,
  [booking_number] NVARCHAR(MAX) NULL,
  [master_bill] NVARCHAR(MAX) NULL,
  [company_id] UNIQUEIDENTIFIER NOT NULL,
  CONSTRAINT [magaya_shipments_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [magaya_shipments_company_number_key] UNIQUE ([company_id], [shipment_number])
);
END
GO

-- public.magaya_status_overrides | ~17,916 filas
IF OBJECT_ID(N'[dbo].[magaya_status_overrides]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[magaya_status_overrides] (
  [txn_guid] NVARCHAR(100) NOT NULL,
  [txn_number] NVARCHAR(MAX) NOT NULL,
  [txn_type] NVARCHAR(50) NOT NULL,
  [status_from_soap] NVARCHAR(50) NOT NULL,
  [balance_from_soap] DECIMAL(15,2) NULL,
  [checked_at] DATETIMEOFFSET NULL CONSTRAINT [DF_magaya_status_overrides_checked_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [magaya_status_overrides_pkey] PRIMARY KEY ([txn_guid])
);
END
GO

-- public.magaya_sync_log | ~565 filas
IF OBJECT_ID(N'[dbo].[magaya_sync_log]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[magaya_sync_log] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_magaya_sync_log_id] DEFAULT (NEWSEQUENTIALID()),
  [company_id] UNIQUEIDENTIFIER NOT NULL,
  [sync_type] NVARCHAR(50) NOT NULL,
  [status] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_magaya_sync_log_status] DEFAULT (N'running'),
  [records_synced] INT NULL CONSTRAINT [DF_magaya_sync_log_records_synced] DEFAULT (0),
  [records_failed] INT NULL CONSTRAINT [DF_magaya_sync_log_records_failed] DEFAULT (0),
  [last_transaction_date] DATETIMEOFFSET NULL,
  [last_transaction_number] NVARCHAR(MAX) NULL,
  [error_message] NVARCHAR(MAX) NULL,
  [started_at] DATETIMEOFFSET NULL CONSTRAINT [DF_magaya_sync_log_started_at] DEFAULT (SYSDATETIMEOFFSET()),
  [completed_at] DATETIMEOFFSET NULL,
  [metadata] NVARCHAR(MAX) NULL,
  CONSTRAINT [magaya_sync_log_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [CK_magaya_sync_log_metadata_json] CHECK (ISJSON([metadata]) = 1)
);
END
GO

-- public.magaya_sync_state | ~6 filas
IF OBJECT_ID(N'[dbo].[magaya_sync_state]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[magaya_sync_state] (
  [sync_type] NVARCHAR(50) NOT NULL,
  [last_number] INT NOT NULL CONSTRAINT [DF_magaya_sync_state_last_number] DEFAULT (0),
  [last_synced_at] DATETIMEOFFSET NULL CONSTRAINT [DF_magaya_sync_state_last_synced_at] DEFAULT (SYSDATETIMEOFFSET()),
  [records_last_run] INT NULL CONSTRAINT [DF_magaya_sync_state_records_last_run] DEFAULT (0),
  [status] NVARCHAR(MAX) NULL CONSTRAINT [DF_magaya_sync_state_status] DEFAULT (N'idle'),
  [error_msg] NVARCHAR(MAX) NULL,
  [company_id] UNIQUEIDENTIFIER NOT NULL,
  CONSTRAINT [magaya_sync_state_pkey] PRIMARY KEY ([company_id], [sync_type])
);
END
GO

-- public.magaya_transaction_charges | ~688,543 filas
IF OBJECT_ID(N'[dbo].[magaya_transaction_charges]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[magaya_transaction_charges] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_magaya_transaction_charges_id] DEFAULT (NEWSEQUENTIALID()),
  [company_id] UNIQUEIDENTIFIER NOT NULL,
  [transaction_id] UNIQUEIDENTIFIER NOT NULL,
  [charge_code] NVARCHAR(MAX) NULL,
  [charge_description] NVARCHAR(MAX) NULL,
  [charge_type] NVARCHAR(MAX) NULL,
  [amount] DECIMAL(18,2) NULL,
  [currency_code] NVARCHAR(MAX) NULL CONSTRAINT [DF_magaya_transaction_charges_currency_code] DEFAULT (N'USD'),
  [exchange_rate] DECIMAL(24,20) NULL,
  [amount_in_home_currency] DECIMAL(18,2) NULL,
  [account_name] NVARCHAR(MAX) NULL,
  [account_number] NVARCHAR(MAX) NULL,
  [entity_name] NVARCHAR(MAX) NULL,
  [is_prepaid] BIT NULL CONSTRAINT [DF_magaya_transaction_charges_is_prepaid] DEFAULT (0),
  [raw_xml] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_magaya_transaction_charges_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [magaya_transaction_charges_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.magaya_transactions | ~689,562 filas
IF OBJECT_ID(N'[dbo].[magaya_transactions]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[magaya_transactions] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_magaya_transactions_id] DEFAULT (NEWSEQUENTIALID()),
  [company_id] UNIQUEIDENTIFIER NOT NULL,
  [magaya_guid] NVARCHAR(255) NULL,
  [transaction_type] NVARCHAR(50) NOT NULL,
  [transaction_number] NVARCHAR(450) NULL,
  [reference_number] NVARCHAR(255) NULL,
  [status] NVARCHAR(100) NULL,
  [direction] NVARCHAR(MAX) NULL,
  [created_on] DATETIMEOFFSET NULL,
  [issued_date] DATE NULL,
  [due_date] DATE NULL,
  [currency_code] NVARCHAR(MAX) NULL CONSTRAINT [DF_magaya_transactions_currency_code] DEFAULT (N'USD'),
  [total_amount] DECIMAL(18,2) NULL,
  [tax_amount] DECIMAL(18,2) NULL,
  [mode_of_transport] NVARCHAR(MAX) NULL,
  [origin_port] NVARCHAR(MAX) NULL,
  [destination_port] NVARCHAR(MAX) NULL,
  [shipper_name] NVARCHAR(MAX) NULL,
  [consignee_name] NVARCHAR(MAX) NULL,
  [carrier_name] NVARCHAR(MAX) NULL,
  [master_bl] NVARCHAR(MAX) NULL,
  [house_bl] NVARCHAR(MAX) NULL,
  [booking_number] NVARCHAR(MAX) NULL,
  [total_pieces] INT NULL,
  [total_weight] DECIMAL(18,6) NULL,
  [weight_unit] NVARCHAR(MAX) NULL CONSTRAINT [DF_magaya_transactions_weight_unit] DEFAULT (N'lb'),
  [total_volume] DECIMAL(18,6) NULL,
  [volume_unit] NVARCHAR(MAX) NULL CONSTRAINT [DF_magaya_transactions_volume_unit] DEFAULT (N'ft3'),
  [billing_client_name] NVARCHAR(450) NULL,
  [billing_client_guid] NVARCHAR(MAX) NULL,
  [account_number] NVARCHAR(MAX) NULL,
  [account_name] NVARCHAR(MAX) NULL,
  [version] INT NULL,
  [created_by_name] NVARCHAR(MAX) NULL,
  [has_attachments] BIT NULL CONSTRAINT [DF_magaya_transactions_has_attachments] DEFAULT (0),
  [raw_xml] NVARCHAR(MAX) NULL,
  [synced_at] DATETIMEOFFSET NULL CONSTRAINT [DF_magaya_transactions_synced_at] DEFAULT (SYSDATETIMEOFFSET()),
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_magaya_transactions_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_magaya_transactions_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  [amount_paid] DECIMAL(15,2) NULL CONSTRAINT [DF_magaya_transactions_amount_paid] DEFAULT (0),
  [is_credit] BIT NULL CONSTRAINT [DF_magaya_transactions_is_credit] DEFAULT (0),
  [document_subtype] NVARCHAR(MAX) NULL,
  [total_amount_usd] DECIMAL(38,10) NULL,
  CONSTRAINT [magaya_transactions_pkey] PRIMARY KEY ([id])
);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'magaya_transactions_company_id_magaya_guid_key' AND object_id = OBJECT_ID(N'[dbo].[magaya_transactions]'))
CREATE UNIQUE INDEX [magaya_transactions_company_id_magaya_guid_key] ON [dbo].[magaya_transactions] ([company_id], [magaya_guid]) WHERE [magaya_guid] IS NOT NULL;
GO

-- public.magaya_usa_shipments | ~623 filas
IF OBJECT_ID(N'[dbo].[magaya_usa_shipments]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[magaya_usa_shipments] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_magaya_usa_shipments_id] DEFAULT (NEWSEQUENTIALID()),
  [guid] NVARCHAR(100) NULL,
  [number] NVARCHAR(MAX) NULL,
  [mode] NVARCHAR(MAX) NULL,
  [is_master] BIT NULL CONSTRAINT [DF_magaya_usa_shipments_is_master] DEFAULT (0),
  [master_bill] NVARCHAR(50) NULL,
  [house_bill] NVARCHAR(MAX) NULL,
  [consignee] NVARCHAR(255) NULL,
  [shipper] NVARCHAR(MAX) NULL,
  [destination_agent] NVARCHAR(MAX) NULL,
  [carrier] NVARCHAR(MAX) NULL,
  [pieces] INT NULL,
  [weight_kg] DECIMAL(38,10) NULL,
  [volume_m3] DECIMAL(38,10) NULL,
  [origin] NVARCHAR(MAX) NULL,
  [destination] NVARCHAR(MAX) NULL,
  [etd] DATE NULL,
  [eta] DATE NULL,
  [status] NVARCHAR(MAX) NULL,
  [created_on] DATE NULL,
  [liquidated] BIT NULL CONSTRAINT [DF_magaya_usa_shipments_liquidated] DEFAULT (0),
  [synced_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_magaya_usa_shipments_synced_at] DEFAULT (SYSDATETIMEOFFSET()),
  [service_type] NVARCHAR(MAX) NULL,
  [manual_master_id] UNIQUEIDENTIFIER NULL,
  CONSTRAINT [magaya_usa_shipments_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [magaya_usa_shipments_service_type_check] CHECK ((([service_type] IS NULL) OR ([service_type]  IN (N'AIR', N'FCL', N'LCL'))))
);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'magaya_usa_shipments_guid_key' AND object_id = OBJECT_ID(N'[dbo].[magaya_usa_shipments]'))
CREATE UNIQUE INDEX [magaya_usa_shipments_guid_key] ON [dbo].[magaya_usa_shipments] ([guid]) WHERE [guid] IS NOT NULL;
GO

-- public.magaya_vendor_payments | ~4,716 filas
IF OBJECT_ID(N'[dbo].[magaya_vendor_payments]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[magaya_vendor_payments] (
  [id] NVARCHAR(100) NOT NULL,
  [number] NVARCHAR(50) NOT NULL,
  [payment_type] NVARCHAR(MAX) NULL,
  [entity_name] NVARCHAR(255) NULL,
  [entity_guid] NVARCHAR(MAX) NULL,
  [amount] DECIMAL(15,2) NULL,
  [payment_date] DATE NULL,
  [created_on] DATETIMEOFFSET NULL,
  [check_number] NVARCHAR(MAX) NULL,
  [bank_account] NVARCHAR(MAX) NULL,
  [memo] NVARCHAR(MAX) NULL,
  [bills_paid] NVARCHAR(MAX) NULL,
  [accounting_entries] NVARCHAR(MAX) NULL,
  [synced_at] DATETIMEOFFSET NULL CONSTRAINT [DF_magaya_vendor_payments_synced_at] DEFAULT (SYSDATETIMEOFFSET()),
  [company_id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_magaya_vendor_payments_company_id] DEFAULT ('aba24859-159c-424b-8ef3-d122fba41b7c'),
  CONSTRAINT [magaya_vendor_payments_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [CK_magaya_vendor_payments_bills_paid_json] CHECK (ISJSON([bills_paid]) = 1),
  CONSTRAINT [CK_magaya_vendor_payments_accounting_entries_json] CHECK (ISJSON([accounting_entries]) = 1)
);
END
GO

-- public.magaya_warehouse_receipts | ~220,104 filas
IF OBJECT_ID(N'[dbo].[magaya_warehouse_receipts]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[magaya_warehouse_receipts] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_magaya_warehouse_receipts_id] DEFAULT (NEWSEQUENTIALID()),
  [wr_number] NVARCHAR(50) NOT NULL,
  [guid] NVARCHAR(MAX) NULL,
  [shipper] NVARCHAR(MAX) NULL,
  [consignee] NVARCHAR(255) NULL,
  [carrier] NVARCHAR(MAX) NULL,
  [tracking_number] NVARCHAR(MAX) NULL,
  [origin] NVARCHAR(MAX) NULL,
  [destination] NVARCHAR(MAX) NULL,
  [status] NVARCHAR(50) NULL,
  [pieces] INT NULL CONSTRAINT [DF_magaya_warehouse_receipts_pieces] DEFAULT (0),
  [weight] DECIMAL(38,10) NULL CONSTRAINT [DF_magaya_warehouse_receipts_weight] DEFAULT (0),
  [created_by] NVARCHAR(MAX) NULL,
  [issued_by] NVARCHAR(MAX) NULL,
  [etd] DATE NULL,
  [eta] DATE NULL,
  [synced_at] DATETIMEOFFSET NULL CONSTRAINT [DF_magaya_warehouse_receipts_synced_at] DEFAULT (SYSDATETIMEOFFSET()),
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_magaya_warehouse_receipts_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [created_on] DATE NULL,
  [volume_cbm] DECIMAL(38,10) NULL,
  [volume_cft] DECIMAL(38,10) NULL,
  [destination_agent] NVARCHAR(MAX) NULL,
  [destination_port] NVARCHAR(MAX) NULL,
  [billing_client] NVARCHAR(MAX) NULL,
  [company_id] UNIQUEIDENTIFIER NOT NULL,
  [consignee_normalized] NVARCHAR(255) NULL,
  [notes] NVARCHAR(MAX) NULL,
  [entry_date] DATE NULL,
  [out_date] DATE NULL,
  [warehouse_zone] NVARCHAR(MAX) NULL,
  [location_code] NVARCHAR(MAX) NULL,
  [has_attachments] BIT NULL,
  [total_value] DECIMAL(38,10) NULL,
  [chargeable_weight] DECIMAL(38,10) NULL,
  [volume_weight] DECIMAL(38,10) NULL,
  [weight_unit] NVARCHAR(MAX) NULL,
  [volume_unit] NVARCHAR(MAX) NULL,
  [length_unit] NVARCHAR(MAX) NULL,
  [measurement_units] NVARCHAR(MAX) NULL,
  [carrier_pro_number] NVARCHAR(MAX) NULL,
  [scac_number] NVARCHAR(MAX) NULL,
  [out_shipment_guid] NVARCHAR(MAX) NULL,
  [cargo_release_number] NVARCHAR(MAX) NULL,
  [custom_fields] NVARCHAR(MAX) NULL,
  [last_full_fetch_at] DATETIMEOFFSET NULL,
  [cbm] AS CAST((round(([volume_cft] * 0.0283168), 4)) AS DECIMAL(38,10)) PERSISTED,
  [last_verify_attempt_at] DATETIMEOFFSET NULL,
  [bonded_entry] NVARCHAR(50) NULL,
  [bonded_entry_number] NVARCHAR(MAX) NULL,
  [bonded_entry_date] DATE NULL,
  [bonded_checked_at] DATETIMEOFFSET NULL,
  CONSTRAINT [magaya_warehouse_receipts_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [magaya_warehouse_receipts_company_number_key] UNIQUE ([company_id], [wr_number]),
  CONSTRAINT [CK_magaya_warehouse_receipts_custom_fields_json] CHECK (ISJSON([custom_fields]) = 1)
);
END
GO

-- public.magaya_wr_attachments | ~35,350 filas
IF OBJECT_ID(N'[dbo].[magaya_wr_attachments]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[magaya_wr_attachments] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_magaya_wr_attachments_id] DEFAULT (NEWSEQUENTIALID()),
  [wr_id] UNIQUEIDENTIFIER NOT NULL,
  [wr_number] NVARCHAR(MAX) NOT NULL,
  [source] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_magaya_wr_attachments_source] DEFAULT (N'magaya'),
  [magaya_doc_id] NVARCHAR(50) NULL,
  [filename] NVARCHAR(MAX) NOT NULL,
  [content_type] NVARCHAR(MAX) NULL,
  [size_bytes] INT NULL,
  [storage_path] NVARCHAR(MAX) NOT NULL,
  [is_photo] BIT NULL CONSTRAINT [DF_magaya_wr_attachments_is_photo] DEFAULT (0),
  [description] NVARCHAR(MAX) NULL,
  [uploaded_by] UNIQUEIDENTIFIER NULL,
  [synced_at] DATETIMEOFFSET NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_magaya_wr_attachments_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [magaya_wr_attachments_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.magaya_wr_items | ~74,672 filas
IF OBJECT_ID(N'[dbo].[magaya_wr_items]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[magaya_wr_items] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_magaya_wr_items_id] DEFAULT (NEWSEQUENTIALID()),
  [wr_id] UNIQUEIDENTIFIER NULL,
  [wr_number] NVARCHAR(50) NOT NULL,
  [item_description] NVARCHAR(MAX) NULL,
  [item_code] NVARCHAR(MAX) NULL,
  [pieces] INT NULL,
  [quantity] DECIMAL(38,10) NULL,
  [weight] DECIMAL(38,10) NULL,
  [volume_cbm] DECIMAL(38,10) NULL,
  [container_number] NVARCHAR(MAX) NULL,
  [synced_at] DATETIMEOFFSET NULL CONSTRAINT [DF_magaya_wr_items_synced_at] DEFAULT (SYSDATETIMEOFFSET()),
  [company_id] UNIQUEIDENTIFIER NOT NULL,
  [description] NVARCHAR(MAX) NULL,
  [part_number] NVARCHAR(MAX) NULL,
  [internal_name] NVARCHAR(MAX) NULL,
  [length] DECIMAL(38,10) NULL,
  [width] DECIMAL(38,10) NULL,
  [height] DECIMAL(38,10) NULL,
  [piece_volume] DECIMAL(38,10) NULL,
  [piece_weight] DECIMAL(38,10) NULL,
  [piece_quantity] DECIMAL(38,10) NULL,
  [package_name] NVARCHAR(MAX) NULL,
  [is_pallet] BIT NULL,
  [is_container] BIT NULL,
  [item_type] NVARCHAR(MAX) NULL,
  [supplier] NVARCHAR(MAX) NULL,
  [notes] NVARCHAR(MAX) NULL,
  [warehouse_zone] NVARCHAR(MAX) NULL,
  [last_full_fetch_at] DATETIMEOFFSET NULL,
  [item_guid] NVARCHAR(MAX) NULL,
  [status] NVARCHAR(50) NULL,
  [cargo_release_guid] NVARCHAR(MAX) NULL,
  [whr_item_id] NVARCHAR(MAX) NULL,
  [location_code] NVARCHAR(MAX) NULL,
  [supplier_invoice_number] NVARCHAR(MAX) NULL,
  [supplier_po_number] NVARCHAR(MAX) NULL,
  [weight_unit] NVARCHAR(MAX) NULL,
  [volume_unit] NVARCHAR(MAX) NULL,
  [peso_lb] DECIMAL(38,10) NULL,
  [vol_cft] DECIMAL(38,10) NULL,
  CONSTRAINT [magaya_wr_items_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.wr_att_backfill_queue | ~6,033 filas
IF OBJECT_ID(N'[dbo].[wr_att_backfill_queue]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[wr_att_backfill_queue] (
  [id] BIGINT NOT NULL CONSTRAINT [DF_wr_att_backfill_queue_id] DEFAULT (NEXT VALUE FOR [dbo].[wr_att_backfill_queue_id_seq]),
  [wr_id] UNIQUEIDENTIFIER NOT NULL,
  [wr_number] NVARCHAR(50) NOT NULL,
  [guid] NVARCHAR(MAX) NOT NULL,
  [status] NVARCHAR(50) NOT NULL CONSTRAINT [DF_wr_att_backfill_queue_status] DEFAULT (N'pending'),
  [files] INT NULL,
  [attempts] INT NOT NULL CONSTRAINT [DF_wr_att_backfill_queue_attempts] DEFAULT (0),
  [error_msg] NVARCHAR(MAX) NULL,
  [ran_at] DATETIMEOFFSET NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_wr_att_backfill_queue_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [wr_att_backfill_queue_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [wr_att_backfill_queue_wr_number_key] UNIQUE ([wr_number])
);
END
GO

-- public.wr_backfill_queue | ~338 filas
IF OBJECT_ID(N'[dbo].[wr_backfill_queue]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[wr_backfill_queue] (
  [id] INT NOT NULL CONSTRAINT [DF_wr_backfill_queue_id] DEFAULT (NEXT VALUE FOR [dbo].[wr_backfill_queue_id_seq]),
  [start_date] DATE NOT NULL,
  [end_date] DATE NOT NULL,
  [status] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_wr_backfill_queue_status] DEFAULT (N'pending'),
  [records] INT NULL,
  [error_msg] NVARCHAR(MAX) NULL,
  [ran_at] DATETIMEOFFSET NULL,
  CONSTRAINT [wr_backfill_queue_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [wr_backfill_queue_start_date_key] UNIQUE ([start_date])
);
END
GO

-- public.wr_match_results | ~28,730 filas
IF OBJECT_ID(N'[dbo].[wr_match_results]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[wr_match_results] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_wr_match_results_id] DEFAULT (NEWSEQUENTIALID()),
  [wr_id] UNIQUEIDENTIFIER NOT NULL,
  [status] NVARCHAR(50) NOT NULL,
  [matched_client_id] UNIQUEIDENTIFIER NULL,
  [matched_shipment_id] UNIQUEIDENTIFIER NULL,
  [match_score] DECIMAL(4,3) NULL,
  [match_reason] NVARCHAR(MAX) NULL,
  [candidates] NVARCHAR(MAX) NULL CONSTRAINT [DF_wr_match_results_candidates] DEFAULT (N'[]'),
  [resolved_by] UNIQUEIDENTIFIER NULL,
  [resolved_at] DATETIMEOFFSET NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_wr_match_results_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_wr_match_results_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  [office] NVARCHAR(50) NULL,
  CONSTRAINT [wr_match_results_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [wr_match_results_wr_id_key] UNIQUE ([wr_id]),
  CONSTRAINT [CK_wr_match_results_status_enum] CHECK ([status] IN (N'AUTO_MATCHED', N'SUGGESTED', N'ORPHAN', N'CONFIRMED', N'REJECTED', N'IGNORED')),
  CONSTRAINT [CK_wr_match_results_candidates_json] CHECK (ISJSON([candidates]) = 1)
);
END
GO

-- public.wr_saldo_queue | ~19,182 filas
IF OBJECT_ID(N'[dbo].[wr_saldo_queue]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[wr_saldo_queue] (
  [wr_number] NVARCHAR(100) NOT NULL,
  [prioridad] INT NOT NULL CONSTRAINT [DF_wr_saldo_queue_prioridad] DEFAULT (5),
  [intentos] INT NOT NULL CONSTRAINT [DF_wr_saldo_queue_intentos] DEFAULT (0),
  [ultimo_intento_at] DATETIMEOFFSET NULL,
  [resuelto_at] DATETIMEOFFSET NULL,
  [error] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_wr_saldo_queue_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [wr_saldo_queue_pkey] PRIMARY KEY ([wr_number])
);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ar_ap_sync_queue_dispatch_idx' AND object_id = OBJECT_ID(N'[dbo].[ar_ap_sync_queue]'))
CREATE INDEX [ar_ap_sync_queue_dispatch_idx] ON [dbo].[ar_ap_sync_queue] ([scope], [status], [last_run_at]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_magaya_accounts_company' AND object_id = OBJECT_ID(N'[dbo].[magaya_accounts]'))
CREATE INDEX [idx_magaya_accounts_company] ON [dbo].[magaya_accounts] ([company_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_magaya_accounts_number' AND object_id = OBJECT_ID(N'[dbo].[magaya_accounts]'))
CREATE INDEX [idx_magaya_accounts_number] ON [dbo].[magaya_accounts] ([account_number]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_magaya_accounts_type' AND object_id = OBJECT_ID(N'[dbo].[magaya_accounts]'))
CREATE INDEX [idx_magaya_accounts_type] ON [dbo].[magaya_accounts] ([company_id], [account_type]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_bills_company_id' AND object_id = OBJECT_ID(N'[dbo].[magaya_bills]'))
CREATE INDEX [idx_bills_company_id] ON [dbo].[magaya_bills] ([company_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_magaya_bills_issue_date' AND object_id = OBJECT_ID(N'[dbo].[magaya_bills]'))
CREATE INDEX [idx_magaya_bills_issue_date] ON [dbo].[magaya_bills] ([issue_date]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_magaya_bills_status' AND object_id = OBJECT_ID(N'[dbo].[magaya_bills]'))
CREATE INDEX [idx_magaya_bills_status] ON [dbo].[magaya_bills] ([status]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_magaya_bills_vendor' AND object_id = OBJECT_ID(N'[dbo].[magaya_bills]'))
CREATE INDEX [idx_magaya_bills_vendor] ON [dbo].[magaya_bills] ([vendor_name]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_cargo_releases_company_id' AND object_id = OBJECT_ID(N'[dbo].[magaya_cargo_releases]'))
CREATE INDEX [idx_cargo_releases_company_id] ON [dbo].[magaya_cargo_releases] ([company_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_magaya_charges_company' AND object_id = OBJECT_ID(N'[dbo].[magaya_charge_definitions]'))
CREATE INDEX [idx_magaya_charges_company] ON [dbo].[magaya_charge_definitions] ([company_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_ce_account_type' AND object_id = OBJECT_ID(N'[dbo].[magaya_charges_extracted]'))
CREATE INDEX [idx_ce_account_type] ON [dbo].[magaya_charges_extracted] ([account_type]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_ce_billing_client' AND object_id = OBJECT_ID(N'[dbo].[magaya_charges_extracted]'))
CREATE INDEX [idx_ce_billing_client] ON [dbo].[magaya_charges_extracted] ([txn_billing_client]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_ce_entity_name' AND object_id = OBJECT_ID(N'[dbo].[magaya_charges_extracted]'))
CREATE INDEX [idx_ce_entity_name] ON [dbo].[magaya_charges_extracted] ([entity_name]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_ce_office_date' AND object_id = OBJECT_ID(N'[dbo].[magaya_charges_extracted]'))
CREATE INDEX [idx_ce_office_date] ON [dbo].[magaya_charges_extracted] ([office_id], [txn_date]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_ce_txn_type' AND object_id = OBJECT_ID(N'[dbo].[magaya_charges_extracted]'))
CREATE INDEX [idx_ce_txn_type] ON [dbo].[magaya_charges_extracted] ([txn_type]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_clients_company_id' AND object_id = OBJECT_ID(N'[dbo].[magaya_clients]'))
CREATE INDEX [idx_clients_company_id] ON [dbo].[magaya_clients] ([company_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_magaya_clients_name' AND object_id = OBJECT_ID(N'[dbo].[magaya_clients]'))
CREATE INDEX [idx_magaya_clients_name] ON [dbo].[magaya_clients] ([name]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_magaya_clients_synced_at' AND object_id = OBJECT_ID(N'[dbo].[magaya_clients]'))
CREATE INDEX [idx_magaya_clients_synced_at] ON [dbo].[magaya_clients] ([synced_at] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_magaya_entities_company' AND object_id = OBJECT_ID(N'[dbo].[magaya_entities]'))
CREATE INDEX [idx_magaya_entities_company] ON [dbo].[magaya_entities] ([company_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_magaya_entities_name' AND object_id = OBJECT_ID(N'[dbo].[magaya_entities]'))
CREATE INDEX [idx_magaya_entities_name] ON [dbo].[magaya_entities] ([company_id], [name]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_magaya_entities_type' AND object_id = OBJECT_ID(N'[dbo].[magaya_entities]'))
CREATE INDEX [idx_magaya_entities_type] ON [dbo].[magaya_entities] ([company_id], [entity_type]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'magaya_entities_name_norm_idx' AND object_id = OBJECT_ID(N'[dbo].[magaya_entities]'))
CREATE INDEX [magaya_entities_name_norm_idx] ON [dbo].[magaya_entities] ([name_normalized]) WHERE ([tax_id] IS NOT NULL);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_meb_office_kind' AND object_id = OBJECT_ID(N'[dbo].[magaya_entity_balance]'))
CREATE INDEX [idx_meb_office_kind] ON [dbo].[magaya_entity_balance] ([tenant_id], [office_id], [kind]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_invoices_company_id' AND object_id = OBJECT_ID(N'[dbo].[magaya_invoices]'))
CREATE INDEX [idx_invoices_company_id] ON [dbo].[magaya_invoices] ([company_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_magaya_invoices_status' AND object_id = OBJECT_ID(N'[dbo].[magaya_invoices]'))
CREATE INDEX [idx_magaya_invoices_status] ON [dbo].[magaya_invoices] ([status]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_magaya_invoices_synced_at' AND object_id = OBJECT_ID(N'[dbo].[magaya_invoices]'))
CREATE INDEX [idx_magaya_invoices_synced_at] ON [dbo].[magaya_invoices] ([synced_at] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_je_created_on' AND object_id = OBJECT_ID(N'[dbo].[magaya_journal_entries]'))
CREATE INDEX [idx_je_created_on] ON [dbo].[magaya_journal_entries] ([created_on]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_journal_entries_company_id' AND object_id = OBJECT_ID(N'[dbo].[magaya_journal_entries]'))
CREATE INDEX [idx_journal_entries_company_id] ON [dbo].[magaya_journal_entries] ([company_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_jel_account_name' AND object_id = OBJECT_ID(N'[dbo].[magaya_journal_entry_lines]'))
CREATE INDEX [idx_jel_account_name] ON [dbo].[magaya_journal_entry_lines] ([account_name]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_jel_account_type' AND object_id = OBJECT_ID(N'[dbo].[magaya_journal_entry_lines]'))
CREATE INDEX [idx_jel_account_type] ON [dbo].[magaya_journal_entry_lines] ([account_type]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_jel_je_id' AND object_id = OBJECT_ID(N'[dbo].[magaya_journal_entry_lines]'))
CREATE INDEX [idx_jel_je_id] ON [dbo].[magaya_journal_entry_lines] ([journal_entry_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_journal_entry_lines_company_id' AND object_id = OBJECT_ID(N'[dbo].[magaya_journal_entry_lines]'))
CREATE INDEX [idx_journal_entry_lines_company_id] ON [dbo].[magaya_journal_entry_lines] ([company_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_mpa_date' AND object_id = OBJECT_ID(N'[dbo].[magaya_payment_application]'))
CREATE INDEX [idx_mpa_date] ON [dbo].[magaya_payment_application] ([company_id], [payment_date] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_mpa_item' AND object_id = OBJECT_ID(N'[dbo].[magaya_payment_application]'))
CREATE INDEX [idx_mpa_item] ON [dbo].[magaya_payment_application] ([company_id], [item_paid_guid]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_pickup_orders_company_id' AND object_id = OBJECT_ID(N'[dbo].[magaya_pickup_orders]'))
CREATE INDEX [idx_pickup_orders_company_id] ON [dbo].[magaya_pickup_orders] ([company_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_magaya_shipments_revenue' AND object_id = OBJECT_ID(N'[dbo].[magaya_shipments]'))
CREATE INDEX [idx_magaya_shipments_revenue] ON [dbo].[magaya_shipments] ([total_revenue]) WHERE ([total_revenue] > 0);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_magaya_shipments_status' AND object_id = OBJECT_ID(N'[dbo].[magaya_shipments]'))
CREATE INDEX [idx_magaya_shipments_status] ON [dbo].[magaya_shipments] ([status]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_magaya_shipments_synced_at' AND object_id = OBJECT_ID(N'[dbo].[magaya_shipments]'))
CREATE INDEX [idx_magaya_shipments_synced_at] ON [dbo].[magaya_shipments] ([synced_at] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_magaya_shipments_type_revenue' AND object_id = OBJECT_ID(N'[dbo].[magaya_shipments]'))
CREATE INDEX [idx_magaya_shipments_type_revenue] ON [dbo].[magaya_shipments] ([type], [total_revenue]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_shipments_company_id' AND object_id = OBJECT_ID(N'[dbo].[magaya_shipments]'))
CREATE INDEX [idx_shipments_company_id] ON [dbo].[magaya_shipments] ([company_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_overrides_type_status' AND object_id = OBJECT_ID(N'[dbo].[magaya_status_overrides]'))
CREATE INDEX [idx_overrides_type_status] ON [dbo].[magaya_status_overrides] ([txn_type], [status_from_soap]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_magaya_sync_company' AND object_id = OBJECT_ID(N'[dbo].[magaya_sync_log]'))
CREATE INDEX [idx_magaya_sync_company] ON [dbo].[magaya_sync_log] ([company_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_magaya_sync_type' AND object_id = OBJECT_ID(N'[dbo].[magaya_sync_log]'))
CREATE INDEX [idx_magaya_sync_type] ON [dbo].[magaya_sync_log] ([company_id], [sync_type]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_magaya_synclog_company_started' AND object_id = OBJECT_ID(N'[dbo].[magaya_sync_log]'))
CREATE INDEX [idx_magaya_synclog_company_started] ON [dbo].[magaya_sync_log] ([company_id], [started_at] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_sync_state_company_id' AND object_id = OBJECT_ID(N'[dbo].[magaya_sync_state]'))
CREATE INDEX [idx_sync_state_company_id] ON [dbo].[magaya_sync_state] ([company_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_magaya_tx_charges_company' AND object_id = OBJECT_ID(N'[dbo].[magaya_transaction_charges]'))
CREATE INDEX [idx_magaya_tx_charges_company] ON [dbo].[magaya_transaction_charges] ([company_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_magaya_tx_charges_trans' AND object_id = OBJECT_ID(N'[dbo].[magaya_transaction_charges]'))
CREATE INDEX [idx_magaya_tx_charges_trans] ON [dbo].[magaya_transaction_charges] ([transaction_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_magaya_trans_billing' AND object_id = OBJECT_ID(N'[dbo].[magaya_transactions]'))
CREATE INDEX [idx_magaya_trans_billing] ON [dbo].[magaya_transactions] ([company_id], [billing_client_name]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_magaya_trans_company' AND object_id = OBJECT_ID(N'[dbo].[magaya_transactions]'))
CREATE INDEX [idx_magaya_trans_company] ON [dbo].[magaya_transactions] ([company_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_magaya_trans_date' AND object_id = OBJECT_ID(N'[dbo].[magaya_transactions]'))
CREATE INDEX [idx_magaya_trans_date] ON [dbo].[magaya_transactions] ([company_id], [created_on]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_magaya_trans_number' AND object_id = OBJECT_ID(N'[dbo].[magaya_transactions]'))
CREATE INDEX [idx_magaya_trans_number] ON [dbo].[magaya_transactions] ([company_id], [transaction_number]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_magaya_trans_ref' AND object_id = OBJECT_ID(N'[dbo].[magaya_transactions]'))
CREATE INDEX [idx_magaya_trans_ref] ON [dbo].[magaya_transactions] ([company_id], [reference_number]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_magaya_trans_status' AND object_id = OBJECT_ID(N'[dbo].[magaya_transactions]'))
CREATE INDEX [idx_magaya_trans_status] ON [dbo].[magaya_transactions] ([company_id], [status]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_magaya_trans_type' AND object_id = OBJECT_ID(N'[dbo].[magaya_transactions]'))
CREATE INDEX [idx_magaya_trans_type] ON [dbo].[magaya_transactions] ([company_id], [transaction_type]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_magaya_tx_company_synced' AND object_id = OBJECT_ID(N'[dbo].[magaya_transactions]'))
CREATE INDEX [idx_magaya_tx_company_synced] ON [dbo].[magaya_transactions] ([company_id], [synced_at] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_magaya_tx_is_credit' AND object_id = OBJECT_ID(N'[dbo].[magaya_transactions]'))
CREATE INDEX [idx_magaya_tx_is_credit] ON [dbo].[magaya_transactions] ([company_id], [transaction_type], [is_credit]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_magaya_tx_status_type' AND object_id = OBJECT_ID(N'[dbo].[magaya_transactions]'))
CREATE INDEX [idx_magaya_tx_status_type] ON [dbo].[magaya_transactions] ([company_id], [transaction_type], [status]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_magaya_tx_total_amount_usd' AND object_id = OBJECT_ID(N'[dbo].[magaya_transactions]'))
CREATE INDEX [idx_magaya_tx_total_amount_usd] ON [dbo].[magaya_transactions] ([total_amount_usd]) WHERE ([total_amount_usd] IS NOT NULL);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_musa_consignee' AND object_id = OBJECT_ID(N'[dbo].[magaya_usa_shipments]'))
CREATE INDEX [idx_musa_consignee] ON [dbo].[magaya_usa_shipments] ([consignee]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_musa_etd' AND object_id = OBJECT_ID(N'[dbo].[magaya_usa_shipments]'))
CREATE INDEX [idx_musa_etd] ON [dbo].[magaya_usa_shipments] ([etd] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_musa_master' AND object_id = OBJECT_ID(N'[dbo].[magaya_usa_shipments]'))
CREATE INDEX [idx_musa_master] ON [dbo].[magaya_usa_shipments] ([master_bill]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'magaya_usa_shipments_manual_master_idx' AND object_id = OBJECT_ID(N'[dbo].[magaya_usa_shipments]'))
CREATE INDEX [magaya_usa_shipments_manual_master_idx] ON [dbo].[magaya_usa_shipments] ([manual_master_id]) WHERE ([manual_master_id] IS NOT NULL);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_vendor_payments_company_id' AND object_id = OBJECT_ID(N'[dbo].[magaya_vendor_payments]'))
CREATE INDEX [idx_vendor_payments_company_id] ON [dbo].[magaya_vendor_payments] ([company_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_vendor_payments_date' AND object_id = OBJECT_ID(N'[dbo].[magaya_vendor_payments]'))
CREATE INDEX [idx_vendor_payments_date] ON [dbo].[magaya_vendor_payments] ([payment_date]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_vendor_payments_entity' AND object_id = OBJECT_ID(N'[dbo].[magaya_vendor_payments]'))
CREATE INDEX [idx_vendor_payments_entity] ON [dbo].[magaya_vendor_payments] ([entity_name]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_vendor_payments_number' AND object_id = OBJECT_ID(N'[dbo].[magaya_vendor_payments]'))
CREATE INDEX [idx_vendor_payments_number] ON [dbo].[magaya_vendor_payments] ([number]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_mwr_bonded_entry' AND object_id = OBJECT_ID(N'[dbo].[magaya_warehouse_receipts]'))
CREATE INDEX [idx_mwr_bonded_entry] ON [dbo].[magaya_warehouse_receipts] ([bonded_entry]) WHERE (([bonded_entry] IS NOT NULL) AND ([bonded_entry] <> N'None'));
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_mwr_bonded_pendientes' AND object_id = OBJECT_ID(N'[dbo].[magaya_warehouse_receipts]'))
CREATE INDEX [idx_mwr_bonded_pendientes] ON [dbo].[magaya_warehouse_receipts] ([created_on] DESC) WHERE (([bonded_checked_at] IS NULL) AND ([out_date] IS NULL));
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_mwr_consignee' AND object_id = OBJECT_ID(N'[dbo].[magaya_warehouse_receipts]'))
CREATE INDEX [idx_mwr_consignee] ON [dbo].[magaya_warehouse_receipts] ([consignee]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_mwr_status' AND object_id = OBJECT_ID(N'[dbo].[magaya_warehouse_receipts]'))
CREATE INDEX [idx_mwr_status] ON [dbo].[magaya_warehouse_receipts] ([status]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_mwr_synced_at' AND object_id = OBJECT_ID(N'[dbo].[magaya_warehouse_receipts]'))
CREATE INDEX [idx_mwr_synced_at] ON [dbo].[magaya_warehouse_receipts] ([synced_at]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_mwr_wr_number' AND object_id = OBJECT_ID(N'[dbo].[magaya_warehouse_receipts]'))
CREATE INDEX [idx_mwr_wr_number] ON [dbo].[magaya_warehouse_receipts] ([wr_number]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_warehouse_receipts_company_id' AND object_id = OBJECT_ID(N'[dbo].[magaya_warehouse_receipts]'))
CREATE INDEX [idx_warehouse_receipts_company_id] ON [dbo].[magaya_warehouse_receipts] ([company_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'mwr_onhand_aging_idx' AND object_id = OBJECT_ID(N'[dbo].[magaya_warehouse_receipts]'))
CREATE INDEX [mwr_onhand_aging_idx] ON [dbo].[magaya_warehouse_receipts] ([last_full_fetch_at]) WHERE (([out_date] IS NULL) AND ([status] = N'OnHand'));
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'mwr_synced_consignee_idx' AND object_id = OBJECT_ID(N'[dbo].[magaya_warehouse_receipts]'))
CREATE INDEX [mwr_synced_consignee_idx] ON [dbo].[magaya_warehouse_receipts] ([synced_at] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'mwr_verify_queue_idx' AND object_id = OBJECT_ID(N'[dbo].[magaya_warehouse_receipts]'))
CREATE INDEX [mwr_verify_queue_idx] ON [dbo].[magaya_warehouse_receipts] ([status], [out_date], [last_verify_attempt_at]) WHERE (([status] = N'OnHand') AND ([out_date] IS NULL));
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'wr_consignee_norm_idx' AND object_id = OBJECT_ID(N'[dbo].[magaya_warehouse_receipts]'))
CREATE INDEX [wr_consignee_norm_idx] ON [dbo].[magaya_warehouse_receipts] ([consignee_normalized]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_magaya_wr_attachments_uploaded_by' AND object_id = OBJECT_ID(N'[dbo].[magaya_wr_attachments]'))
CREATE INDEX [idx_magaya_wr_attachments_uploaded_by] ON [dbo].[magaya_wr_attachments] ([uploaded_by]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'magaya_wr_attachments_wr_doc_uidx' AND object_id = OBJECT_ID(N'[dbo].[magaya_wr_attachments]'))
CREATE UNIQUE INDEX [magaya_wr_attachments_wr_doc_uidx] ON [dbo].[magaya_wr_attachments] ([wr_id], [magaya_doc_id]) WHERE [magaya_doc_id] IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'wr_attachments_photo_idx' AND object_id = OBJECT_ID(N'[dbo].[magaya_wr_attachments]'))
CREATE INDEX [wr_attachments_photo_idx] ON [dbo].[magaya_wr_attachments] ([is_photo]) WHERE ([is_photo] = 1);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'wr_attachments_wr_idx' AND object_id = OBJECT_ID(N'[dbo].[magaya_wr_attachments]'))
CREATE INDEX [wr_attachments_wr_idx] ON [dbo].[magaya_wr_attachments] ([wr_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_magaya_wr_items_wr_id' AND object_id = OBJECT_ID(N'[dbo].[magaya_wr_items]'))
CREATE INDEX [idx_magaya_wr_items_wr_id] ON [dbo].[magaya_wr_items] ([wr_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_magaya_wr_items_wr_number' AND object_id = OBJECT_ID(N'[dbo].[magaya_wr_items]'))
CREATE INDEX [idx_magaya_wr_items_wr_number] ON [dbo].[magaya_wr_items] ([wr_number]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_wr_items_company_id' AND object_id = OBJECT_ID(N'[dbo].[magaya_wr_items]'))
CREATE INDEX [idx_wr_items_company_id] ON [dbo].[magaya_wr_items] ([company_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'magaya_wr_items_wr_status_idx' AND object_id = OBJECT_ID(N'[dbo].[magaya_wr_items]'))
CREATE INDEX [magaya_wr_items_wr_status_idx] ON [dbo].[magaya_wr_items] ([wr_number], [status]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'wr_att_backfill_queue_status_idx' AND object_id = OBJECT_ID(N'[dbo].[wr_att_backfill_queue]'))
CREATE INDEX [wr_att_backfill_queue_status_idx] ON [dbo].[wr_att_backfill_queue] ([status], [id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_wr_match_results_matched_shipment_id' AND object_id = OBJECT_ID(N'[dbo].[wr_match_results]'))
CREATE INDEX [idx_wr_match_results_matched_shipment_id] ON [dbo].[wr_match_results] ([matched_shipment_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_wr_match_results_resolved_by' AND object_id = OBJECT_ID(N'[dbo].[wr_match_results]'))
CREATE INDEX [idx_wr_match_results_resolved_by] ON [dbo].[wr_match_results] ([resolved_by]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'wr_match_client_idx' AND object_id = OBJECT_ID(N'[dbo].[wr_match_results]'))
CREATE INDEX [wr_match_client_idx] ON [dbo].[wr_match_results] ([matched_client_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'wr_match_office_idx' AND object_id = OBJECT_ID(N'[dbo].[wr_match_results]'))
CREATE INDEX [wr_match_office_idx] ON [dbo].[wr_match_results] ([office]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'wr_match_status_idx' AND object_id = OBJECT_ID(N'[dbo].[wr_match_results]'))
CREATE INDEX [wr_match_status_idx] ON [dbo].[wr_match_results] ([status]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'wr_saldo_queue_pend_idx' AND object_id = OBJECT_ID(N'[dbo].[wr_saldo_queue]'))
CREATE INDEX [wr_saldo_queue_pend_idx] ON [dbo].[wr_saldo_queue] ([prioridad], [ultimo_intento_at]) WHERE ([resuelto_at] IS NULL);
GO
