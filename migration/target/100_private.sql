-- 100 · Esquema private: tablas e índices
-- Generado por migration/tools/to_tsql.mjs desde el catálogo de Supabase (2026-09-29). No editar a mano:
-- cambiar el generador y volver a correrlo. Idempotente: se puede ejecutar varias veces.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- private.client_merge_audit | ~4,498 filas
IF OBJECT_ID(N'[private].[client_merge_audit]', N'U') IS NULL
BEGIN
CREATE TABLE [private].[client_merge_audit] (
  [id] BIGINT NOT NULL CONSTRAINT [DF_client_merge_audit_id] DEFAULT (NEXT VALUE FOR [private].[client_merge_audit_id_seq]),
  [merged_at] DATETIMEOFFSET NULL CONSTRAINT [DF_client_merge_audit_merged_at] DEFAULT (SYSDATETIMEOFFSET()),
  [batch] NVARCHAR(MAX) NULL CONSTRAINT [DF_client_merge_audit_batch] DEFAULT (N'dedup-2026-07-23'),
  [table_name] NVARCHAR(MAX) NULL,
  [action] NVARCHAR(MAX) NULL,
  [old_client_id] UNIQUEIDENTIFIER NULL,
  [new_client_id] UNIQUEIDENTIFIER NULL,
  [row_json] NVARCHAR(MAX) NULL,
  CONSTRAINT [client_merge_audit_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [CK_client_merge_audit_row_json_json] CHECK (ISJSON([row_json]) = 1)
);
END
GO

-- private.iva_backfill_audit | ~22 filas
IF OBJECT_ID(N'[private].[iva_backfill_audit]', N'U') IS NULL
BEGIN
CREATE TABLE [private].[iva_backfill_audit] (
  [id] BIGINT NOT NULL CONSTRAINT [DF_iva_backfill_audit_id] DEFAULT (NEXT VALUE FOR [private].[iva_backfill_audit_id_seq]),
  [applied_at] DATETIMEOFFSET NULL CONSTRAINT [DF_iva_backfill_audit_applied_at] DEFAULT (SYSDATETIMEOFFSET()),
  [batch] NVARCHAR(MAX) NULL CONSTRAINT [DF_iva_backfill_audit_batch] DEFAULT (N'iva-backfill-2026-07-24'),
  [doc_type] NVARCHAR(MAX) NULL,
  [doc_id] UNIQUEIDENTIFIER NULL,
  [quote_number] NVARCHAR(MAX) NULL,
  [old_cost] DECIMAL(38,10) NULL,
  [old_sale] DECIMAL(38,10) NULL,
  [old_profit] DECIMAL(38,10) NULL,
  [iva_cost] DECIMAL(38,10) NULL,
  [iva_sale] DECIMAL(38,10) NULL,
  [iva_line_id] UNIQUEIDENTIFIER NULL,
  CONSTRAINT [iva_backfill_audit_pkey] PRIMARY KEY ([id])
);
END
GO
