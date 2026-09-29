-- 095 · Otros: tablas e índices
-- Generado por migration/tools/to_tsql.mjs desde el catálogo de Supabase (2026-09-29). No editar a mano:
-- cambiar el generador y volver a correrlo. Idempotente: se puede ejecutar varias veces.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- public.carrier_advisories | ~130 filas
IF OBJECT_ID(N'[dbo].[carrier_advisories]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[carrier_advisories] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_carrier_advisories_id] DEFAULT (NEWSEQUENTIALID()),
  [carrier_code] NVARCHAR(50) NOT NULL,
  [url] NVARCHAR(450) NOT NULL,
  [title] NVARCHAR(MAX) NOT NULL,
  [published_on] DATE NULL,
  [kind] NVARCHAR(MAX) NULL,
  [effective_on] DATE NULL,
  [affects_us] BIT NULL,
  [body_text] NVARCHAR(MAX) NULL,
  [first_seen_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_carrier_advisories_first_seen_at] DEFAULT (SYSDATETIMEOFFSET()),
  [notified_at] DATETIMEOFFSET NULL,
  CONSTRAINT [carrier_advisories_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [carrier_advisories_url_key] UNIQUE ([url])
);
END
GO

-- public.inhouse_dashboards | ~1 filas
IF OBJECT_ID(N'[dbo].[inhouse_dashboards]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[inhouse_dashboards] (
  [client_id] UNIQUEIDENTIFIER NOT NULL,
  [rows] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_inhouse_dashboards_rows] DEFAULT (N'[]'),
  [meta] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_inhouse_dashboards_meta] DEFAULT (N'{}'),
  [file_name] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_inhouse_dashboards_file_name] DEFAULT (N''),
  [uploaded_by] UNIQUEIDENTIFIER NULL,
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_inhouse_dashboards_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [inhouse_dashboards_pkey] PRIMARY KEY ([client_id]),
  CONSTRAINT [CK_inhouse_dashboards_rows_json] CHECK (ISJSON([rows]) = 1),
  CONSTRAINT [CK_inhouse_dashboards_meta_json] CHECK (ISJSON([meta]) = 1)
);
END
GO

-- public.inhouse_despachos | ~10 filas
IF OBJECT_ID(N'[dbo].[inhouse_despachos]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[inhouse_despachos] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_inhouse_despachos_id] DEFAULT (NEWSEQUENTIALID()),
  [client_id] UNIQUEIDENTIFIER NOT NULL,
  [referencia] NVARCHAR(MAX) NOT NULL,
  [contenedor] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_inhouse_despachos_contenedor] DEFAULT (N''),
  [booking] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_inhouse_despachos_booking] DEFAULT (N''),
  [consignatario] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_inhouse_despachos_consignatario] DEFAULT (N''),
  [estado] SMALLINT NOT NULL CONSTRAINT [DF_inhouse_despachos_estado] DEFAULT (1),
  [data] NVARCHAR(MAX) NULL,
  [shipment_id] UNIQUEIDENTIFIER NULL,
  [created_by] UNIQUEIDENTIFIER NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_inhouse_despachos_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_inhouse_despachos_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [inhouse_despachos_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [inhouse_despachos_estado_check] CHECK ((([estado] >= 1) AND ([estado] <= 8))),
  CONSTRAINT [CK_inhouse_despachos_data_json] CHECK (ISJSON([data]) = 1)
);
END
GO

-- public.inhouse_documentos | ~104 filas
IF OBJECT_ID(N'[dbo].[inhouse_documentos]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[inhouse_documentos] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_inhouse_documentos_id] DEFAULT (NEWSEQUENTIALID()),
  [despacho_id] UNIQUEIDENTIFIER NOT NULL,
  [tipo] NVARCHAR(MAX) NOT NULL,
  [nombre] NVARCHAR(MAX) NOT NULL,
  [sha256] NVARCHAR(MAX) NOT NULL,
  [file_url] NVARCHAR(MAX) NOT NULL,
  [file_size] INT NULL,
  [nro_tributario] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_inhouse_documentos_nro_tributario] DEFAULT (N''),
  [hash_fuente] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_inhouse_documentos_hash_fuente] DEFAULT (N''),
  [subido_por] UNIQUEIDENTIFIER NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_inhouse_documentos_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [inhouse_documentos_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [inhouse_documentos_tipo_check] CHECK (([tipo]  IN (N'fuente_packing', N'fuente_factura', N'lista_html', N'lista_xlsx', N'lista_snapshot', N'lista_pdf', N'factura_html', N'factura_xlsx', N'factura_snapshot', N'factura_pdf')))
);
END
GO

-- public.inhouse_profiles | ~1 filas
IF OBJECT_ID(N'[dbo].[inhouse_profiles]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[inhouse_profiles] (
  [client_id] UNIQUEIDENTIFIER NOT NULL,
  [direccion] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_inhouse_profiles_direccion] DEFAULT (N''),
  [logo] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_inhouse_profiles_logo] DEFAULT (N''),
  [pais] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_inhouse_profiles_pais] DEFAULT (N'Ecuador'),
  [formato_tributario] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_inhouse_profiles_formato_tributario] DEFAULT (N'RIDE SRI'),
  [formato_nro] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_inhouse_profiles_formato_nro] DEFAULT (N'^\d{3}-\d{3}-\d{9}$'),
  [placeholder_nro] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_inhouse_profiles_placeholder_nro] DEFAULT (N'001-001-000000000'),
  [col_map] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_inhouse_profiles_col_map] DEFAULT (N'{"desc": "B", "neto": "H", "bruto": "I", "cajas": "E", "codigo": "A", "header": "Código", "unxcaja": "F"}'),
  [regla_orden] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_inhouse_profiles_regla_orden] DEFAULT (N'factura'),
  [consignatarios] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_inhouse_profiles_consignatarios] DEFAULT (N'[]'),
  [firma] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_inhouse_profiles_firma] DEFAULT (N''),
  [activo] BIT NOT NULL CONSTRAINT [DF_inhouse_profiles_activo] DEFAULT (1),
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_inhouse_profiles_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_inhouse_profiles_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [inhouse_profiles_pkey] PRIMARY KEY ([client_id]),
  CONSTRAINT [CK_inhouse_profiles_col_map_json] CHECK (ISJSON([col_map]) = 1),
  CONSTRAINT [CK_inhouse_profiles_consignatarios_json] CHECK (ISJSON([consignatarios]) = 1)
);
END
GO

-- public.job_applicants | ~3 filas
IF OBJECT_ID(N'[dbo].[job_applicants]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[job_applicants] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_job_applicants_id] DEFAULT (NEWSEQUENTIALID()),
  [access_token] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_job_applicants_access_token] DEFAULT (NEWID()),
  [office] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_job_applicants_office] DEFAULT (N'USA'),
  [full_name] NVARCHAR(MAX) NOT NULL,
  [phone] NVARCHAR(MAX) NOT NULL,
  [email] NVARCHAR(MAX) NULL,
  [preferred_channel] NVARCHAR(MAX) NULL,
  [link_sent] BIT NOT NULL CONSTRAINT [DF_job_applicants_link_sent] DEFAULT (0),
  [link_sent_at] DATETIMEOFFSET NULL,
  [link_channel_used] NVARCHAR(MAX) NULL,
  [link_error] NVARCHAR(MAX) NULL,
  [status] NVARCHAR(50) NOT NULL CONSTRAINT [DF_job_applicants_status] DEFAULT (N'registered'),
  [application_data] NVARCHAR(MAX) NULL,
  [resume_url] NVARCHAR(MAX) NULL,
  [submitted_at] DATETIMEOFFSET NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_job_applicants_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_job_applicants_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [job_applicants_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [job_applicants_preferred_channel_check] CHECK (([preferred_channel]  IN (N'whatsapp', N'sms'))),
  CONSTRAINT [job_applicants_status_check] CHECK (([status]  IN (N'registered', N'submitted'))),
  CONSTRAINT [CK_job_applicants_application_data_json] CHECK (ISJSON([application_data]) = 1)
);
END
GO

-- public.visitor_badges | ~20 filas
IF OBJECT_ID(N'[dbo].[visitor_badges]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[visitor_badges] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_visitor_badges_id] DEFAULT (NEWSEQUENTIALID()),
  [office] NVARCHAR(50) NOT NULL CONSTRAINT [DF_visitor_badges_office] DEFAULT (N'USA'),
  [label] NVARCHAR(50) NOT NULL,
  [badge_number] INT NULL,
  [status] NVARCHAR(50) NOT NULL CONSTRAINT [DF_visitor_badges_status] DEFAULT (N'available'),
  [notes] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_visitor_badges_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_visitor_badges_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [visitor_badges_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [visitor_badges_office_label_key] UNIQUE ([office], [label]),
  CONSTRAINT [visitor_badges_status_check] CHECK (([status]  IN (N'available', N'in_use', N'retired')))
);
END
GO

-- public.visitors | ~3 filas
IF OBJECT_ID(N'[dbo].[visitors]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[visitors] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_visitors_id] DEFAULT (NEWSEQUENTIALID()),
  [full_name] NVARCHAR(MAX) NOT NULL,
  [company] NVARCHAR(MAX) NULL,
  [document_type] NVARCHAR(MAX) NULL,
  [document_number] NVARCHAR(255) NULL,
  [phone] NVARCHAR(MAX) NULL,
  [email] NVARCHAR(MAX) NULL,
  [photo_url] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_visitors_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_visitors_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [visitors_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.visits | ~8 filas
IF OBJECT_ID(N'[dbo].[visits]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[visits] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_visits_id] DEFAULT (NEWSEQUENTIALID()),
  [visitor_id] UNIQUEIDENTIFIER NULL,
  [office] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_visits_office] DEFAULT (N'USA'),
  [host_user_id] UNIQUEIDENTIFIER NULL,
  [host_name_snapshot] NVARCHAR(MAX) NULL,
  [purpose] NVARCHAR(MAX) NULL,
  [badge_id] UNIQUEIDENTIFIER NULL,
  [photo_url] NVARCHAR(MAX) NULL,
  [document_type] NVARCHAR(MAX) NULL,
  [document_number] NVARCHAR(MAX) NULL,
  [nda_signed] BIT NOT NULL CONSTRAINT [DF_visits_nda_signed] DEFAULT (0),
  [nda_signature_url] NVARCHAR(MAX) NULL,
  [nda_version] NVARCHAR(MAX) NULL,
  [safety_accepted] BIT NOT NULL CONSTRAINT [DF_visits_safety_accepted] DEFAULT (0),
  [status] NVARCHAR(50) NOT NULL CONSTRAINT [DF_visits_status] DEFAULT (N'checked_in'),
  [checked_in_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_visits_checked_in_at] DEFAULT (SYSDATETIMEOFFSET()),
  [checked_out_at] DATETIMEOFFSET NULL,
  [notified_email] BIT NOT NULL CONSTRAINT [DF_visits_notified_email] DEFAULT (0),
  [notified_whatsapp] BIT NOT NULL CONSTRAINT [DF_visits_notified_whatsapp] DEFAULT (0),
  [notify_error] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_visits_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_visits_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  [host_tenant_id] UNIQUEIDENTIFIER NULL,
  [host_type] NVARCHAR(MAX) NULL,
  CONSTRAINT [visits_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [visits_status_check] CHECK (([status]  IN (N'checked_in', N'checked_out')))
);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'carrier_advisories_pendientes' AND object_id = OBJECT_ID(N'[dbo].[carrier_advisories]'))
CREATE INDEX [carrier_advisories_pendientes] ON [dbo].[carrier_advisories] ([carrier_code], [published_on] DESC) WHERE ([notified_at] IS NULL);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'inhouse_despachos_client_idx' AND object_id = OBJECT_ID(N'[dbo].[inhouse_despachos]'))
CREATE INDEX [inhouse_despachos_client_idx] ON [dbo].[inhouse_despachos] ([client_id], [created_at] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'inhouse_documentos_despacho_idx' AND object_id = OBJECT_ID(N'[dbo].[inhouse_documentos]'))
CREATE INDEX [inhouse_documentos_despacho_idx] ON [dbo].[inhouse_documentos] ([despacho_id], [created_at] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_job_applicants_created' AND object_id = OBJECT_ID(N'[dbo].[job_applicants]'))
CREATE INDEX [idx_job_applicants_created] ON [dbo].[job_applicants] ([created_at] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_job_applicants_status' AND object_id = OBJECT_ID(N'[dbo].[job_applicants]'))
CREATE INDEX [idx_job_applicants_status] ON [dbo].[job_applicants] ([status]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_job_applicants_token' AND object_id = OBJECT_ID(N'[dbo].[job_applicants]'))
CREATE INDEX [idx_job_applicants_token] ON [dbo].[job_applicants] ([access_token]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_visitor_badges_status' AND object_id = OBJECT_ID(N'[dbo].[visitor_badges]'))
CREATE INDEX [idx_visitor_badges_status] ON [dbo].[visitor_badges] ([office], [status]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_visitors_document' AND object_id = OBJECT_ID(N'[dbo].[visitors]'))
CREATE INDEX [idx_visitors_document] ON [dbo].[visitors] ([document_number]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_visits_badge' AND object_id = OBJECT_ID(N'[dbo].[visits]'))
CREATE INDEX [idx_visits_badge] ON [dbo].[visits] ([badge_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_visits_checked_in' AND object_id = OBJECT_ID(N'[dbo].[visits]'))
CREATE INDEX [idx_visits_checked_in] ON [dbo].[visits] ([checked_in_at] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_visits_host' AND object_id = OBJECT_ID(N'[dbo].[visits]'))
CREATE INDEX [idx_visits_host] ON [dbo].[visits] ([host_user_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_visits_status' AND object_id = OBJECT_ID(N'[dbo].[visits]'))
CREATE INDEX [idx_visits_status] ON [dbo].[visits] ([status]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'uniq_visit_active_badge' AND object_id = OBJECT_ID(N'[dbo].[visits]'))
CREATE UNIQUE INDEX [uniq_visit_active_badge] ON [dbo].[visits] ([badge_id]) WHERE (([status] = N'checked_in') AND ([badge_id] IS NOT NULL)) AND [badge_id] IS NOT NULL;
GO
