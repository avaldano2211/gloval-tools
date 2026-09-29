-- 102 · Esquema timeclock: tablas e índices
-- Generado por migration/tools/to_tsql.mjs desde el catálogo de Supabase (2026-09-29). No editar a mano:
-- cambiar el generador y volver a correrlo. Idempotente: se puede ejecutar varias veces.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- timeclock.corrections | ~1 filas
IF OBJECT_ID(N'[timeclock].[corrections]', N'U') IS NULL
BEGIN
CREATE TABLE [timeclock].[corrections] (
  [id] INT IDENTITY(1,1) NOT NULL,
  [emp_id] INT NOT NULL,
  [kind] NVARCHAR(MAX) NOT NULL,
  [ref_date] NVARCHAR(MAX) NULL,
  [added_punch_id] INT NULL,
  [reason] NVARCHAR(MAX) NULL,
  [by_user] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_corrections_by_user] DEFAULT (N'supervisor'),
  [at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_corrections_at] DEFAULT (SYSDATETIMEOFFSET()),
  [old_value] NVARCHAR(MAX) NULL,
  [new_value] NVARCHAR(MAX) NULL,
  CONSTRAINT [corrections_pkey] PRIMARY KEY ([id])
);
END
GO

-- timeclock.employees | ~18 filas
IF OBJECT_ID(N'[timeclock].[employees]', N'U') IS NULL
BEGIN
CREATE TABLE [timeclock].[employees] (
  [id] INT IDENTITY(1,1) NOT NULL,
  [badge] NVARCHAR(50) NOT NULL,
  [name] NVARCHAR(MAX) NOT NULL,
  [pin] NVARCHAR(MAX) NOT NULL,
  [shift_start] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_employees_shift_start] DEFAULT (N'08:30'),
  [shift_end] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_employees_shift_end] DEFAULT (N'17:00'),
  [site_id] NVARCHAR(50) NOT NULL CONSTRAINT [DF_employees_site_id] DEFAULT (N'MIA'),
  [hourly_rate] FLOAT NOT NULL CONSTRAINT [DF_employees_hourly_rate] DEFAULT (15.0),
  [active] INT NOT NULL CONSTRAINT [DF_employees_active] DEFAULT (1),
  CONSTRAINT [employees_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [employees_badge_key] UNIQUE ([badge])
);
END
GO

-- timeclock.punches | ~290 filas
IF OBJECT_ID(N'[timeclock].[punches]', N'U') IS NULL
BEGIN
CREATE TABLE [timeclock].[punches] (
  [id] INT IDENTITY(1,1) NOT NULL,
  [emp_id] INT NOT NULL,
  [ts] NVARCHAR(50) NOT NULL,
  [source] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_punches_source] DEFAULT (N'legacy'),
  [lat] FLOAT NULL,
  [lng] FLOAT NULL,
  [dist_m] FLOAT NULL,
  [in_fence] INT NULL,
  [token_ok] INT NULL,
  [selfie] NVARCHAR(MAX) NULL,
  [deleted] INT NOT NULL CONSTRAINT [DF_punches_deleted] DEFAULT (0),
  [note] NVARCHAR(MAX) NULL,
  CONSTRAINT [punches_pkey] PRIMARY KEY ([id])
);
END
GO

-- timeclock.sites | ~1 filas
IF OBJECT_ID(N'[timeclock].[sites]', N'U') IS NULL
BEGIN
CREATE TABLE [timeclock].[sites] (
  [id] NVARCHAR(50) NOT NULL,
  [name] NVARCHAR(MAX) NOT NULL,
  [lat] FLOAT NULL,
  [lng] FLOAT NULL,
  [radius_m] INT NOT NULL CONSTRAINT [DF_sites_radius_m] DEFAULT (250),
  [secret] NVARCHAR(MAX) NOT NULL,
  [tz] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_sites_tz] DEFAULT (N'America/New_York'),
  [workweek_start] INT NOT NULL CONSTRAINT [DF_sites_workweek_start] DEFAULT (0),
  [max_shift_hours] FLOAT NOT NULL CONSTRAINT [DF_sites_max_shift_hours] DEFAULT (14.0),
  [ot_weekly_threshold] FLOAT NOT NULL CONSTRAINT [DF_sites_ot_weekly_threshold] DEFAULT (40.0),
  [ot_multiplier] FLOAT NOT NULL CONSTRAINT [DF_sites_ot_multiplier] DEFAULT (1.5),
  CONSTRAINT [sites_pkey] PRIMARY KEY ([id])
);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'punches_emp_ts' AND object_id = OBJECT_ID(N'[timeclock].[punches]'))
CREATE INDEX [punches_emp_ts] ON [timeclock].[punches] ([emp_id], [ts]);
GO
