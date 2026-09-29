-- 101 · Esquema archive: tablas e índices
-- Generado por migration/tools/to_tsql.mjs desde el catálogo de Supabase (2026-09-29). No editar a mano:
-- cambiar el generador y volver a correrlo. Idempotente: se puede ejecutar varias veces.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- archive.magaya_charges | ~185,502 filas
IF OBJECT_ID(N'[archive].[magaya_charges]', N'U') IS NULL
BEGIN
CREATE TABLE [archive].[magaya_charges] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_magaya_charges_id] DEFAULT (NEWSEQUENTIALID()),
  [charge_guid] NVARCHAR(100) NOT NULL,
  [shipment_number] NVARCHAR(255) NOT NULL,
  [shipment_guid] NVARCHAR(MAX) NULL,
  [charge_type] NVARCHAR(MAX) NULL,
  [entity_name] NVARCHAR(255) NULL,
  [entity_guid] NVARCHAR(MAX) NULL,
  [quantity] DECIMAL(12,4) NULL CONSTRAINT [DF_magaya_charges_quantity] DEFAULT (1),
  [price] DECIMAL(14,4) NULL,
  [amount] DECIMAL(14,2) NULL,
  [currency] NVARCHAR(MAX) NULL CONSTRAINT [DF_magaya_charges_currency] DEFAULT (N'USD'),
  [charge_description] NVARCHAR(MAX) NULL,
  [charge_code] NVARCHAR(50) NULL,
  [charge_category] NVARCHAR(MAX) NULL,
  [account_type] NVARCHAR(MAX) NULL,
  [account_name] NVARCHAR(MAX) NULL,
  [status] NVARCHAR(MAX) NULL,
  [is_prepaid] BIT NULL CONSTRAINT [DF_magaya_charges_is_prepaid] DEFAULT (0),
  [is_credit] BIT NULL CONSTRAINT [DF_magaya_charges_is_credit] DEFAULT (0),
  [is_third_party] BIT NULL CONSTRAINT [DF_magaya_charges_is_third_party] DEFAULT (0),
  [synced_at] DATETIMEOFFSET NULL CONSTRAINT [DF_magaya_charges_synced_at] DEFAULT (SYSDATETIMEOFFSET()),
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_magaya_charges_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [company_id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_magaya_charges_company_id] DEFAULT ('aba24859-159c-424b-8ef3-d122fba41b7c'),
  CONSTRAINT [magaya_charges_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [magaya_charges_company_guid_key] UNIQUE ([company_id], [charge_guid])
);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_charges_company_id' AND object_id = OBJECT_ID(N'[archive].[magaya_charges]'))
CREATE INDEX [idx_charges_company_id] ON [archive].[magaya_charges] ([company_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_magaya_charges_code' AND object_id = OBJECT_ID(N'[archive].[magaya_charges]'))
CREATE INDEX [idx_magaya_charges_code] ON [archive].[magaya_charges] ([charge_code]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_magaya_charges_entity' AND object_id = OBJECT_ID(N'[archive].[magaya_charges]'))
CREATE INDEX [idx_magaya_charges_entity] ON [archive].[magaya_charges] ([entity_name]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_magaya_charges_shipment' AND object_id = OBJECT_ID(N'[archive].[magaya_charges]'))
CREATE INDEX [idx_magaya_charges_shipment] ON [archive].[magaya_charges] ([shipment_number]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ux_magaya_charges_charge_guid' AND object_id = OBJECT_ID(N'[archive].[magaya_charges]'))
CREATE UNIQUE INDEX [ux_magaya_charges_charge_guid] ON [archive].[magaya_charges] ([charge_guid]);
GO
