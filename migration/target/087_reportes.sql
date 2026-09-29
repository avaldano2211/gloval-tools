-- 087 · Dashboards y reportes: tablas e índices
-- Generado por migration/tools/to_tsql.mjs desde el catálogo de Supabase (2026-09-29). No editar a mano:
-- cambiar el generador y volver a correrlo. Idempotente: se puede ejecutar varias veces.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- public.brief_emitido | ~11 filas
IF OBJECT_ID(N'[dbo].[brief_emitido]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[brief_emitido] (
  [fecha] DATE NOT NULL,
  [kind] NVARCHAR(50) NOT NULL CONSTRAINT [DF_brief_emitido_kind] DEFAULT (N'daily'),
  [hora] DATETIMEOFFSET NULL CONSTRAINT [DF_brief_emitido_hora] DEFAULT (SYSDATETIMEOFFSET()),
  [por] NVARCHAR(MAX) NULL,
  [nota] NVARCHAR(MAX) NULL,
  CONSTRAINT [brief_emitido_pkey] PRIMARY KEY ([fecha], [kind])
);
END
GO

-- public.dashboard_agents | ~960 filas | SIN PK en origen
IF OBJECT_ID(N'[dbo].[dashboard_agents]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[dashboard_agents] (
  [year] INT NULL,
  [month] INT NULL,
  [agent_name] NVARCHAR(MAX) NULL,
  [revenue] DECIMAL(38,10) NULL,
  [cogs] DECIMAL(38,10) NULL,
  [clients] BIGINT NULL,
  [operations] BIGINT NULL
);
END
GO

-- public.dashboard_clients | ~3,811 filas | SIN PK en origen
IF OBJECT_ID(N'[dbo].[dashboard_clients]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[dashboard_clients] (
  [year] INT NULL,
  [client_name] NVARCHAR(MAX) NULL,
  [agent_name] NVARCHAR(MAX) NULL,
  [country] NVARCHAR(MAX) NULL,
  [revenue] DECIMAL(38,10) NULL,
  [cogs] DECIMAL(38,10) NULL,
  [operations] BIGINT NULL
);
END
GO

-- public.dashboard_countries | ~452 filas | SIN PK en origen
IF OBJECT_ID(N'[dbo].[dashboard_countries]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[dashboard_countries] (
  [year] INT NULL,
  [month] INT NULL,
  [country] NVARCHAR(MAX) NULL,
  [revenue] DECIMAL(38,10) NULL,
  [cogs] DECIMAL(38,10) NULL,
  [operations] BIGINT NULL
);
END
GO

-- public.dashboard_monthly_client | ~16,393 filas | SIN PK en origen
IF OBJECT_ID(N'[dbo].[dashboard_monthly_client]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[dashboard_monthly_client] (
  [year] INT NULL,
  [month] INT NULL,
  [client_name] NVARCHAR(MAX) NULL,
  [business_line] NVARCHAR(MAX) NULL,
  [revenue] DECIMAL(38,10) NULL,
  [cogs] DECIMAL(38,10) NULL,
  [charges] BIGINT NULL
);
END
GO

-- public.dashboard_pnl_flow | ~1,223 filas | SIN PK en origen
IF OBJECT_ID(N'[dbo].[dashboard_pnl_flow]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[dashboard_pnl_flow] (
  [year] INT NULL,
  [month] INT NULL,
  [flow_type] NVARCHAR(MAX) NULL,
  [business_line] NVARCHAR(MAX) NULL,
  [revenue] DECIMAL(38,10) NULL,
  [cogs] DECIMAL(38,10) NULL,
  [gross_profit] DECIMAL(38,10) NULL,
  [charge_count] BIGINT NULL
);
END
GO

-- public.dashboard_pnl_monthly | ~782 filas
IF OBJECT_ID(N'[dbo].[dashboard_pnl_monthly]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[dashboard_pnl_monthly] (
  [year] INT NOT NULL,
  [month] INT NOT NULL,
  [business_line] NVARCHAR(50) NOT NULL,
  [revenue] DECIMAL(38,10) NULL,
  [direct_cogs] DECIMAL(38,10) NULL,
  [fixed_warehouse_cogs] DECIMAL(38,10) NULL,
  [gross_profit] DECIMAL(38,10) NULL,
  [margin_pct] DECIMAL(38,10) NULL,
  CONSTRAINT [dashboard_pnl_monthly_pkey] PRIMARY KEY ([year], [month], [business_line])
);
END
GO
