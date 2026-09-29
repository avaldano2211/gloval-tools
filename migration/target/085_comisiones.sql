-- 085 · Comisiones: tablas e índices
-- Generado por migration/tools/to_tsql.mjs desde el catálogo de Supabase (2026-09-29). No editar a mano:
-- cambiar el generador y volver a correrlo. Idempotente: se puede ejecutar varias veces.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- public.cmm_chat_messages | ~5 filas
IF OBJECT_ID(N'[dbo].[cmm_chat_messages]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[cmm_chat_messages] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_cmm_chat_messages_id] DEFAULT (NEWSEQUENTIALID()),
  [conversation_id] UNIQUEIDENTIFIER NOT NULL,
  [office] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_cmm_chat_messages_office] DEFAULT (N'Ecuador'),
  [role] NVARCHAR(MAX) NOT NULL,
  [content] NVARCHAR(MAX) NOT NULL,
  [citations] NVARCHAR(MAX) NULL,
  [model] NVARCHAR(MAX) NULL,
  [input_tokens] INT NULL,
  [output_tokens] INT NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_cmm_chat_messages_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [created_by] UNIQUEIDENTIFIER NULL,
  CONSTRAINT [cmm_chat_messages_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [cmm_chat_messages_role_check] CHECK (([role]  IN (N'user', N'assistant', N'system'))),
  CONSTRAINT [CK_cmm_chat_messages_citations_json] CHECK (ISJSON([citations]) = 1)
);
END
GO

-- public.cmm_client_aliases | ~1 filas
IF OBJECT_ID(N'[dbo].[cmm_client_aliases]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[cmm_client_aliases] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_cmm_client_aliases_id] DEFAULT (NEWSEQUENTIALID()),
  [office] NVARCHAR(50) NOT NULL CONSTRAINT [DF_cmm_client_aliases_office] DEFAULT (N'Ecuador'),
  [canonical_name] NVARCHAR(50) NOT NULL,
  [alias_name] NVARCHAR(100) NOT NULL,
  [notes] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_cmm_client_aliases_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [created_by] UNIQUEIDENTIFIER NULL,
  CONSTRAINT [cmm_client_aliases_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [cmm_client_aliases_office_check] CHECK (([office]  IN (N'Ecuador', N'Peru', N'Panama', N'USA')))
);
END
GO

-- public.cmm_commission_policies | ~1 filas
IF OBJECT_ID(N'[dbo].[cmm_commission_policies]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[cmm_commission_policies] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_cmm_commission_policies_id] DEFAULT (NEWSEQUENTIALID()),
  [name] NVARCHAR(MAX) NOT NULL,
  [office] NVARCHAR(50) NOT NULL CONSTRAINT [DF_cmm_commission_policies_office] DEFAULT (N'Ecuador'),
  [active] BIT NOT NULL CONSTRAINT [DF_cmm_commission_policies_active] DEFAULT (0),
  [base_cmm_rate] DECIMAL(6,4) NOT NULL CONSTRAINT [DF_cmm_commission_policies_base_cmm_rate] DEFAULT (0.1500),
  [margin_floor_pct] DECIMAL(6,2) NOT NULL CONSTRAINT [DF_cmm_commission_policies_margin_floor_pct] DEFAULT (0.00),
  [tiers] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_cmm_commission_policies_tiers] DEFAULT (N'[]'),
  [cost1_lcl] DECIMAL(10,2) NOT NULL CONSTRAINT [DF_cmm_commission_policies_cost1_lcl] DEFAULT (10),
  [cost1_hawb] DECIMAL(10,2) NOT NULL CONSTRAINT [DF_cmm_commission_policies_cost1_hawb] DEFAULT (10),
  [cost1_wr] DECIMAL(10,2) NOT NULL CONSTRAINT [DF_cmm_commission_policies_cost1_wr] DEFAULT (0),
  [cost1_fcl] DECIMAL(10,2) NOT NULL CONSTRAINT [DF_cmm_commission_policies_cost1_fcl] DEFAULT (25),
  [cost1_default] DECIMAL(10,2) NOT NULL CONSTRAINT [DF_cmm_commission_policies_cost1_default] DEFAULT (10),
  [notes] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_cmm_commission_policies_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [created_by] UNIQUEIDENTIFIER NULL,
  CONSTRAINT [cmm_commission_policies_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [CK_cmm_commission_policies_tiers_json] CHECK (ISJSON([tiers]) = 1)
);
END
GO

-- public.cmm_context_notes | ~8 filas
IF OBJECT_ID(N'[dbo].[cmm_context_notes]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[cmm_context_notes] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_cmm_context_notes_id] DEFAULT (NEWSEQUENTIALID()),
  [office] NVARCHAR(50) NOT NULL CONSTRAINT [DF_cmm_context_notes_office] DEFAULT (N'Ecuador'),
  [category] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_cmm_context_notes_category] DEFAULT (N'general'),
  [content] NVARCHAR(MAX) NOT NULL,
  [active] BIT NOT NULL CONSTRAINT [DF_cmm_context_notes_active] DEFAULT (1),
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_cmm_context_notes_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_cmm_context_notes_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  [created_by] UNIQUEIDENTIFIER NULL,
  CONSTRAINT [cmm_context_notes_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [cmm_context_notes_category_check] CHECK (([category]  IN (N'cliente', N'vendedor', N'estrategia', N'mercado', N'operacion', N'general'))),
  CONSTRAINT [cmm_context_notes_office_check] CHECK (([office]  IN (N'Ecuador', N'Peru', N'Panama', N'USA')))
);
END
GO

-- public.cmm_dismissed_actions | ~6 filas
IF OBJECT_ID(N'[dbo].[cmm_dismissed_actions]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[cmm_dismissed_actions] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_cmm_dismissed_actions_id] DEFAULT (NEWSEQUENTIALID()),
  [office] NVARCHAR(50) NOT NULL CONSTRAINT [DF_cmm_dismissed_actions_office] DEFAULT (N'Ecuador'),
  [seller_id] UNIQUEIDENTIFIER NOT NULL,
  [action_id] NVARCHAR(255) NOT NULL,
  [reason] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_cmm_dismissed_actions_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [created_by] UNIQUEIDENTIFIER NULL,
  CONSTRAINT [cmm_dismissed_actions_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [cmm_dismissed_actions_office_check] CHECK (([office]  IN (N'Ecuador', N'Peru', N'Panama', N'USA')))
);
END
GO

-- public.cmm_pending | ~704 filas
IF OBJECT_ID(N'[dbo].[cmm_pending]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[cmm_pending] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_cmm_pending_id] DEFAULT (NEWSEQUENTIALID()),
  [upload_id] UNIQUEIDENTIFIER NOT NULL,
  [seller_id] UNIQUEIDENTIFIER NOT NULL,
  [office] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_cmm_pending_office] DEFAULT (N'Ecuador'),
  [period_year] INT NOT NULL,
  [period_month] INT NOT NULL,
  [descripcion] NVARCHAR(MAX) NOT NULL,
  [fecha] DATE NULL,
  [base_cmm_pendiente] DECIMAL(14,4) NOT NULL CONSTRAINT [DF_cmm_pending_base_cmm_pendiente] DEFAULT (0),
  [cmm_pendiente] DECIMAL(14,4) NOT NULL CONSTRAINT [DF_cmm_pending_cmm_pendiente] DEFAULT (0),
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_cmm_pending_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [cmm_pending_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.cmm_sellers | ~8 filas
IF OBJECT_ID(N'[dbo].[cmm_sellers]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[cmm_sellers] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_cmm_sellers_id] DEFAULT (NEWSEQUENTIALID()),
  [nombre] NVARCHAR(50) NOT NULL,
  [raw_names] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_cmm_sellers_raw_names] DEFAULT (N'[]'),
  [office] NVARCHAR(50) NOT NULL CONSTRAINT [DF_cmm_sellers_office] DEFAULT (N'Ecuador'),
  [canal] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_cmm_sellers_canal] DEFAULT (N'Staff'),
  [estado] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_cmm_sellers_estado] DEFAULT (N'Activo'),
  [notas] NVARCHAR(MAX) NULL,
  [active] BIT NOT NULL CONSTRAINT [DF_cmm_sellers_active] DEFAULT (1),
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_cmm_sellers_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_cmm_sellers_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [cmm_sellers_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [cmm_sellers_canal_check] CHECK (([canal]  IN (N'Staff', N'Freelance', N'Directos'))),
  CONSTRAINT [cmm_sellers_estado_check] CHECK (([estado]  IN (N'Activo', N'Onboarding', N'Salio'))),
  CONSTRAINT [cmm_sellers_office_check] CHECK (([office]  IN (N'Ecuador', N'Peru', N'Panama', N'USA'))),
  CONSTRAINT [CK_cmm_sellers_raw_names_json] CHECK (ISJSON([raw_names]) = 1)
);
END
GO

-- public.cmm_targets | ~9 filas
IF OBJECT_ID(N'[dbo].[cmm_targets]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[cmm_targets] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_cmm_targets_id] DEFAULT (NEWSEQUENTIALID()),
  [seller_id] UNIQUEIDENTIFIER NOT NULL,
  [office] NVARCHAR(50) NOT NULL CONSTRAINT [DF_cmm_targets_office] DEFAULT (N'Ecuador'),
  [period_year] INT NOT NULL,
  [period_month] INT NOT NULL,
  [target_ganancia] DECIMAL(14,2) NOT NULL CONSTRAINT [DF_cmm_targets_target_ganancia] DEFAULT (0),
  [notes] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_cmm_targets_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_cmm_targets_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [cmm_targets_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [cmm_targets_period_month_check] CHECK ((([period_month] >= 1) AND ([period_month] <= 12)))
);
END
GO

-- public.cmm_transactions | ~8,891 filas
IF OBJECT_ID(N'[dbo].[cmm_transactions]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[cmm_transactions] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_cmm_transactions_id] DEFAULT (NEWSEQUENTIALID()),
  [upload_id] UNIQUEIDENTIFIER NOT NULL,
  [seller_id] UNIQUEIDENTIFIER NOT NULL,
  [office] NVARCHAR(50) NOT NULL CONSTRAINT [DF_cmm_transactions_office] DEFAULT (N'Ecuador'),
  [period_year] INT NOT NULL,
  [period_month] INT NOT NULL,
  [fecha] DATE NULL,
  [cliente] NVARCHAR(255) NULL,
  [transaccion_text] NVARCHAR(MAX) NULL,
  [cont] NVARCHAR(MAX) NULL,
  [cont_categoria] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_cmm_transactions_cont_categoria] DEFAULT (N'Otros'),
  [ingresos] DECIMAL(14,4) NOT NULL CONSTRAINT [DF_cmm_transactions_ingresos] DEFAULT (0),
  [otros_gastos] DECIMAL(14,4) NOT NULL CONSTRAINT [DF_cmm_transactions_otros_gastos] DEFAULT (0),
  [ganancia] DECIMAL(14,4) NOT NULL CONSTRAINT [DF_cmm_transactions_ganancia] DEFAULT (0),
  [costo1] DECIMAL(14,4) NOT NULL CONSTRAINT [DF_cmm_transactions_costo1] DEFAULT (0),
  [base_cmm] DECIMAL(14,4) NOT NULL CONSTRAINT [DF_cmm_transactions_base_cmm] DEFAULT (0),
  [cmm_pagar] DECIMAL(14,4) NOT NULL CONSTRAINT [DF_cmm_transactions_cmm_pagar] DEFAULT (0),
  [formato] NVARCHAR(MAX) NOT NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_cmm_transactions_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [cmm_transactions_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [cmm_transactions_cont_categoria_check] CHECK (([cont_categoria]  IN (N'LCL', N'Aéreo', N'FCL', N'WR (Bodega)', N'Otros'))),
  CONSTRAINT [cmm_transactions_formato_check] CHECK (([formato]  IN (N'LIQUIDACION', N'DIRECTOS')))
);
END
GO

-- public.cmm_uploads | ~9 filas
IF OBJECT_ID(N'[dbo].[cmm_uploads]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[cmm_uploads] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_cmm_uploads_id] DEFAULT (NEWSEQUENTIALID()),
  [uploaded_by] UNIQUEIDENTIFIER NULL,
  [uploaded_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_cmm_uploads_uploaded_at] DEFAULT (SYSDATETIMEOFFSET()),
  [office] NVARCHAR(50) NOT NULL CONSTRAINT [DF_cmm_uploads_office] DEFAULT (N'Ecuador'),
  [period_year] INT NOT NULL,
  [period_month] INT NOT NULL,
  [files_count] INT NOT NULL CONSTRAINT [DF_cmm_uploads_files_count] DEFAULT (0),
  [txn_count] INT NOT NULL CONSTRAINT [DF_cmm_uploads_txn_count] DEFAULT (0),
  [pending_count] INT NOT NULL CONSTRAINT [DF_cmm_uploads_pending_count] DEFAULT (0),
  [notes] NVARCHAR(MAX) NULL,
  CONSTRAINT [cmm_uploads_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [cmm_uploads_office_check] CHECK (([office]  IN (N'Ecuador', N'Peru', N'Panama', N'USA'))),
  CONSTRAINT [cmm_uploads_period_month_check] CHECK ((([period_month] >= 1) AND ([period_month] <= 12)))
);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'cmm_chat_conv_idx' AND object_id = OBJECT_ID(N'[dbo].[cmm_chat_messages]'))
CREATE INDEX [cmm_chat_conv_idx] ON [dbo].[cmm_chat_messages] ([conversation_id], [created_at]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'cmm_client_aliases_unique' AND object_id = OBJECT_ID(N'[dbo].[cmm_client_aliases]'))
CREATE UNIQUE INDEX [cmm_client_aliases_unique] ON [dbo].[cmm_client_aliases] ([office], [canonical_name], [alias_name]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'cmm_policy_active_unique' AND object_id = OBJECT_ID(N'[dbo].[cmm_commission_policies]'))
CREATE UNIQUE INDEX [cmm_policy_active_unique] ON [dbo].[cmm_commission_policies] ([office]) WHERE ([active] = 1);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'cmm_context_notes_office_idx' AND object_id = OBJECT_ID(N'[dbo].[cmm_context_notes]'))
CREATE INDEX [cmm_context_notes_office_idx] ON [dbo].[cmm_context_notes] ([office], [active]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'cmm_dismissed_actions_uk' AND object_id = OBJECT_ID(N'[dbo].[cmm_dismissed_actions]'))
CREATE UNIQUE INDEX [cmm_dismissed_actions_uk] ON [dbo].[cmm_dismissed_actions] ([office], [seller_id], [action_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'cmm_pending_seller_idx' AND object_id = OBJECT_ID(N'[dbo].[cmm_pending]'))
CREATE INDEX [cmm_pending_seller_idx] ON [dbo].[cmm_pending] ([seller_id], [period_year], [period_month]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'cmm_sellers_nombre_office_uk' AND object_id = OBJECT_ID(N'[dbo].[cmm_sellers]'))
CREATE UNIQUE INDEX [cmm_sellers_nombre_office_uk] ON [dbo].[cmm_sellers] ([nombre], [office]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'cmm_targets_unique' AND object_id = OBJECT_ID(N'[dbo].[cmm_targets]'))
CREATE UNIQUE INDEX [cmm_targets_unique] ON [dbo].[cmm_targets] ([seller_id], [office], [period_year], [period_month]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'cmm_txn_cliente_idx' AND object_id = OBJECT_ID(N'[dbo].[cmm_transactions]'))
CREATE INDEX [cmm_txn_cliente_idx] ON [dbo].[cmm_transactions] ([cliente]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'cmm_txn_office_period_idx' AND object_id = OBJECT_ID(N'[dbo].[cmm_transactions]'))
CREATE INDEX [cmm_txn_office_period_idx] ON [dbo].[cmm_transactions] ([office], [period_year], [period_month]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'cmm_txn_seller_period_idx' AND object_id = OBJECT_ID(N'[dbo].[cmm_transactions]'))
CREATE INDEX [cmm_txn_seller_period_idx] ON [dbo].[cmm_transactions] ([seller_id], [period_year], [period_month]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'cmm_uploads_period_idx' AND object_id = OBJECT_ID(N'[dbo].[cmm_uploads]'))
CREATE INDEX [cmm_uploads_period_idx] ON [dbo].[cmm_uploads] ([office], [period_year], [period_month]);
GO
