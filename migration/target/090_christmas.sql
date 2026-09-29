-- 090 · Christmas Palace: tablas e índices
-- Generado por migration/tools/to_tsql.mjs desde el catálogo de Supabase (2026-09-29). No editar a mano:
-- cambiar el generador y volver a correrlo. Idempotente: se puede ejecutar varias veces.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- public.christmas_audit_log | ~51 filas
IF OBJECT_ID(N'[dbo].[christmas_audit_log]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[christmas_audit_log] (
  [id] BIGINT IDENTITY(1,1) NOT NULL,
  [occurred_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_christmas_audit_log_occurred_at] DEFAULT (SYSDATETIMEOFFSET()),
  [actor_id] UNIQUEIDENTIFIER NULL,
  [actor_email] NVARCHAR(MAX) NULL,
  [actor_role] NVARCHAR(MAX) NULL,
  [table_name] NVARCHAR(50) NOT NULL,
  [operation] NVARCHAR(MAX) NOT NULL,
  [record_id] NVARCHAR(MAX) NULL,
  [old_data] NVARCHAR(MAX) NULL,
  [new_data] NVARCHAR(MAX) NULL,
  [changed_cols] NVARCHAR(MAX) NULL,
  CONSTRAINT [christmas_audit_log_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [christmas_audit_log_operation_check] CHECK (([operation]  IN (N'INSERT', N'UPDATE', N'DELETE', N'LOGIN'))),
  CONSTRAINT [CK_christmas_audit_log_old_data_json] CHECK (ISJSON([old_data]) = 1),
  CONSTRAINT [CK_christmas_audit_log_new_data_json] CHECK (ISJSON([new_data]) = 1),
  CONSTRAINT [CK_christmas_audit_log_changed_cols_json] CHECK (ISJSON([changed_cols]) = 1)
);
END
GO

-- public.christmas_destinations | ~307 filas
IF OBJECT_ID(N'[dbo].[christmas_destinations]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[christmas_destinations] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_christmas_destinations_id] DEFAULT (NEWSEQUENTIALID()),
  [tenant_id] UNIQUEIDENTIFIER NOT NULL,
  [port_code] NVARCHAR(50) NOT NULL,
  [port_label] NVARCHAR(MAX) NOT NULL,
  [country_iso2] NVARCHAR(MAX) NOT NULL,
  [transit_days] INT NULL,
  [is_quick] BIT NOT NULL CONSTRAINT [DF_christmas_destinations_is_quick] DEFAULT (0),
  [active] BIT NOT NULL CONSTRAINT [DF_christmas_destinations_active] DEFAULT (1),
  [display_order] INT NOT NULL CONSTRAINT [DF_christmas_destinations_display_order] DEFAULT (0),
  [is_custom] BIT NOT NULL CONSTRAINT [DF_christmas_destinations_is_custom] DEFAULT (0),
  [region] NVARCHAR(MAX) NULL,
  [created_by] UNIQUEIDENTIFIER NULL,
  CONSTRAINT [destinations_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [destinations_tenant_id_port_code_key] UNIQUE ([tenant_id], [port_code])
);
END
GO

-- public.christmas_global_settings | ~1 filas
IF OBJECT_ID(N'[dbo].[christmas_global_settings]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[christmas_global_settings] (
  [tenant_id] UNIQUEIDENTIFIER NOT NULL,
  [key] NVARCHAR(50) NOT NULL,
  [value] NVARCHAR(MAX) NOT NULL,
  [updated_by] UNIQUEIDENTIFIER NULL,
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_christmas_global_settings_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [global_settings_pkey] PRIMARY KEY ([tenant_id], [key]),
  CONSTRAINT [CK_christmas_global_settings_value_json] CHECK (ISJSON([value]) = 1)
);
END
GO

-- public.christmas_pallet_presets | ~8 filas
IF OBJECT_ID(N'[dbo].[christmas_pallet_presets]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[christmas_pallet_presets] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_christmas_pallet_presets_id] DEFAULT (NEWSEQUENTIALID()),
  [tenant_id] UNIQUEIDENTIFIER NOT NULL,
  [label] NVARCHAR(MAX) NOT NULL,
  [length_cm] DECIMAL(38,10) NOT NULL,
  [width_cm] DECIMAL(38,10) NOT NULL,
  [height_cm] DECIMAL(38,10) NOT NULL,
  [capacity_kg] DECIMAL(38,10) NULL,
  [show_weight] BIT NOT NULL CONSTRAINT [DF_christmas_pallet_presets_show_weight] DEFAULT (0),
  [display_order] INT NOT NULL CONSTRAINT [DF_christmas_pallet_presets_display_order] DEFAULT (0),
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_christmas_pallet_presets_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [pallet_presets_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.christmas_products | ~3,695 filas
IF OBJECT_ID(N'[dbo].[christmas_products]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[christmas_products] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_christmas_products_id] DEFAULT (NEWSEQUENTIALID()),
  [tenant_id] UNIQUEIDENTIFIER NOT NULL,
  [sku] NVARCHAR(100) NULL,
  [name] NVARCHAR(MAX) NOT NULL,
  [icon_variant] NVARCHAR(MAX) NULL,
  [length_cm] DECIMAL(38,10) NOT NULL,
  [width_cm] DECIMAL(38,10) NOT NULL,
  [height_cm] DECIMAL(38,10) NOT NULL,
  [weight_kg] DECIMAL(38,10) NULL,
  [price_from_usd] DECIMAL(38,10) NULL,
  [is_popular] BIT NOT NULL CONSTRAINT [DF_christmas_products_is_popular] DEFAULT (0),
  [image_url] NVARCHAR(MAX) NULL,
  [display_order] INT NOT NULL CONSTRAINT [DF_christmas_products_display_order] DEFAULT (0),
  [metadata] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_christmas_products_metadata] DEFAULT (N'{}'),
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_christmas_products_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [handle] NVARCHAR(255) NULL,
  [body_html] NVARCHAR(MAX) NULL,
  [vendor] NVARCHAR(MAX) NULL,
  [product_type] NVARCHAR(MAX) NULL,
  [tags] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_christmas_products_tags] DEFAULT (N'[]'),
  [style_key] NVARCHAR(MAX) NULL,
  [weight_from_shopify] BIT NOT NULL CONSTRAINT [DF_christmas_products_weight_from_shopify] DEFAULT (0),
  [dims_estimated] BIT NOT NULL CONSTRAINT [DF_christmas_products_dims_estimated] DEFAULT (1),
  [all_image_urls] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_christmas_products_all_image_urls] DEFAULT (N'[]'),
  [all_variant_skus] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_christmas_products_all_variant_skus] DEFAULT (N'[]'),
  [variant_count] INT NULL,
  [shopify_id] BIGINT NULL,
  [source] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_christmas_products_source] DEFAULT (N'manual'),
  [active] BIT NOT NULL CONSTRAINT [DF_christmas_products_active] DEFAULT (1),
  CONSTRAINT [products_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [products_source_check] CHECK (([source]  IN (N'manual', N'scraped'))),
  CONSTRAINT [CK_christmas_products_metadata_json] CHECK (ISJSON([metadata]) = 1),
  CONSTRAINT [CK_christmas_products_tags_json] CHECK (ISJSON([tags]) = 1),
  CONSTRAINT [CK_christmas_products_all_image_urls_json] CHECK (ISJSON([all_image_urls]) = 1),
  CONSTRAINT [CK_christmas_products_all_variant_skus_json] CHECK (ISJSON([all_variant_skus]) = 1)
);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'products_tenant_id_sku_key' AND object_id = OBJECT_ID(N'[dbo].[christmas_products]'))
CREATE UNIQUE INDEX [products_tenant_id_sku_key] ON [dbo].[christmas_products] ([tenant_id], [sku]) WHERE [sku] IS NOT NULL;
GO

-- public.christmas_tenants | ~1 filas
IF OBJECT_ID(N'[dbo].[christmas_tenants]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[christmas_tenants] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_christmas_tenants_id] DEFAULT (NEWSEQUENTIALID()),
  [slug] NVARCHAR(50) NOT NULL,
  [name] NVARCHAR(MAX) NOT NULL,
  [origin_port_code] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_christmas_tenants_origin_port_code] DEFAULT (N'USMIA'),
  [margin_kind] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_christmas_tenants_margin_kind] DEFAULT (N'percent'),
  [margin_value] DECIMAL(38,10) NOT NULL CONSTRAINT [DF_christmas_tenants_margin_value] DEFAULT (25),
  [active] BIT NOT NULL CONSTRAINT [DF_christmas_tenants_active] DEFAULT (1),
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_christmas_tenants_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [tenants_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [tenants_slug_key] UNIQUE ([slug]),
  CONSTRAINT [tenants_margin_kind_check] CHECK (([margin_kind]  IN (N'percent', N'flat_usd')))
);
END
GO

-- public.christmas_user_profiles | ~19 filas
IF OBJECT_ID(N'[dbo].[christmas_user_profiles]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[christmas_user_profiles] (
  [user_id] UNIQUEIDENTIFIER NOT NULL,
  [email] NVARCHAR(MAX) NULL,
  [full_name] NVARCHAR(MAX) NULL,
  [role] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_christmas_user_profiles_role] DEFAULT (N'rep'),
  [tenant_id] UNIQUEIDENTIFIER NULL,
  [active] BIT NOT NULL CONSTRAINT [DF_christmas_user_profiles_active] DEFAULT (1),
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_christmas_user_profiles_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_christmas_user_profiles_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  [username] NVARCHAR(50) NULL,
  CONSTRAINT [user_profiles_pkey] PRIMARY KEY ([user_id]),
  CONSTRAINT [user_profiles_role_check] CHECK (([role]  IN (N'rep', N'manager', N'admin')))
);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'christmas_audit_log_actor_idx' AND object_id = OBJECT_ID(N'[dbo].[christmas_audit_log]'))
CREATE INDEX [christmas_audit_log_actor_idx] ON [dbo].[christmas_audit_log] ([actor_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'christmas_audit_log_occurred_idx' AND object_id = OBJECT_ID(N'[dbo].[christmas_audit_log]'))
CREATE INDEX [christmas_audit_log_occurred_idx] ON [dbo].[christmas_audit_log] ([occurred_at] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'christmas_audit_log_table_idx' AND object_id = OBJECT_ID(N'[dbo].[christmas_audit_log]'))
CREATE INDEX [christmas_audit_log_table_idx] ON [dbo].[christmas_audit_log] ([table_name], [occurred_at] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'products_active_idx' AND object_id = OBJECT_ID(N'[dbo].[christmas_products]'))
CREATE INDEX [products_active_idx] ON [dbo].[christmas_products] ([tenant_id], [active]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'products_tenant_handle_uidx' AND object_id = OBJECT_ID(N'[dbo].[christmas_products]'))
CREATE UNIQUE INDEX [products_tenant_handle_uidx] ON [dbo].[christmas_products] ([tenant_id], [handle]) WHERE ([handle] IS NOT NULL) AND [handle] IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'products_tenant_popular_idx' AND object_id = OBJECT_ID(N'[dbo].[christmas_products]'))
CREATE INDEX [products_tenant_popular_idx] ON [dbo].[christmas_products] ([tenant_id], [is_popular], [display_order]) WHERE ([is_popular] = 1);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'christmas_user_profiles_username_uniq' AND object_id = OBJECT_ID(N'[dbo].[christmas_user_profiles]'))
CREATE UNIQUE INDEX [christmas_user_profiles_username_uniq] ON [dbo].[christmas_user_profiles] ([username]) WHERE ([username] IS NOT NULL) AND [username] IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'user_profiles_tenant_idx' AND object_id = OBJECT_ID(N'[dbo].[christmas_user_profiles]'))
CREATE INDEX [user_profiles_tenant_idx] ON [dbo].[christmas_user_profiles] ([tenant_id], [active]);
GO
