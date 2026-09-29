-- 001 · Seguridad y usuarios: tablas e índices
-- Generado por migration/tools/to_tsql.mjs desde el catálogo de Supabase (2026-09-29). No editar a mano:
-- cambiar el generador y volver a correrlo. Idempotente: se puede ejecutar varias veces.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- public.audit_log | ~1,818 filas
IF OBJECT_ID(N'[dbo].[audit_log]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[audit_log] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_audit_log_id] DEFAULT (NEWSEQUENTIALID()),
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_audit_log_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [table_name] NVARCHAR(MAX) NOT NULL,
  [record_id] UNIQUEIDENTIFIER NULL,
  [action] NVARCHAR(MAX) NOT NULL,
  [old_values] NVARCHAR(MAX) NULL,
  [new_values] NVARCHAR(MAX) NULL,
  [changes_summary] NVARCHAR(MAX) NULL,
  [user_id] UNIQUEIDENTIFIER NULL,
  [user_name] NVARCHAR(MAX) NULL,
  CONSTRAINT [audit_log_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [CK_audit_log_old_values_json] CHECK (ISJSON([old_values]) = 1),
  CONSTRAINT [CK_audit_log_new_values_json] CHECK (ISJSON([new_values]) = 1)
);
END
GO

-- public.finanzas_access | ~2 filas
IF OBJECT_ID(N'[dbo].[finanzas_access]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[finanzas_access] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_finanzas_access_id] DEFAULT (NEWSEQUENTIALID()),
  [user_id] UNIQUEIDENTIFIER NOT NULL,
  [office_code] NVARCHAR(50) NOT NULL,
  [can_grant] BIT NOT NULL CONSTRAINT [DF_finanzas_access_can_grant] DEFAULT (0),
  [granted_by] UNIQUEIDENTIFIER NULL,
  [granted_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_finanzas_access_granted_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [finanzas_access_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [finanzas_access_user_id_office_code_key] UNIQUE ([user_id], [office_code]),
  CONSTRAINT [finanzas_access_office_code_check] CHECK (([office_code]  IN (N'USA', N'ECU', N'PAN', N'PER', N'HOLDING', N'ALL')))
);
END
GO

-- public.impersonation_log | ~10 filas
IF OBJECT_ID(N'[dbo].[impersonation_log]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[impersonation_log] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_impersonation_log_id] DEFAULT (NEWSEQUENTIALID()),
  [admin_user_id] UNIQUEIDENTIFIER NOT NULL,
  [target_user_id] UNIQUEIDENTIFIER NOT NULL,
  [started_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_impersonation_log_started_at] DEFAULT (SYSDATETIMEOFFSET()),
  [ended_at] DATETIMEOFFSET NULL,
  [ip] NVARCHAR(MAX) NULL,
  [user_agent] NVARCHAR(MAX) NULL,
  [reason] NVARCHAR(MAX) NULL,
  [via_master_password] BIT NOT NULL CONSTRAINT [DF_impersonation_log_via_master_password] DEFAULT (0),
  CONSTRAINT [impersonation_log_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [no_self_impersonation] CHECK (([admin_user_id] <> [target_user_id]))
);
END
GO

-- public.login_history | ~123,582 filas
IF OBJECT_ID(N'[dbo].[login_history]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[login_history] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_login_history_id] DEFAULT (NEWSEQUENTIALID()),
  [user_id] UNIQUEIDENTIFIER NULL,
  [email] NVARCHAR(MAX) NULL,
  [login_at] DATETIMEOFFSET NULL CONSTRAINT [DF_login_history_login_at] DEFAULT (SYSDATETIMEOFFSET()),
  [ip_address] NVARCHAR(MAX) NULL,
  [user_agent] NVARCHAR(MAX) NULL,
  [device_type] NVARCHAR(MAX) NULL,
  [status] NVARCHAR(MAX) NULL CONSTRAINT [DF_login_history_status] DEFAULT (N'success'),
  [office] NVARCHAR(MAX) NULL,
  [logout_at] DATETIMEOFFSET NULL,
  [session_duration_minutes] INT NULL,
  [is_active] BIT NULL CONSTRAINT [DF_login_history_is_active] DEFAULT (1),
  CONSTRAINT [login_history_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.pba_authorized_users | ~3 filas
IF OBJECT_ID(N'[dbo].[pba_authorized_users]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[pba_authorized_users] (
  [email] NVARCHAR(50) NOT NULL,
  [note] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_pba_authorized_users_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [pba_authorized_users_pkey] PRIMARY KEY ([email])
);
END
GO

-- public.role_permissions | ~277 filas
IF OBJECT_ID(N'[dbo].[role_permissions]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[role_permissions] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_role_permissions_id] DEFAULT (NEWSEQUENTIALID()),
  [role_id] UNIQUEIDENTIFIER NOT NULL,
  [page] NVARCHAR(100) NOT NULL,
  [can_view] BIT NULL CONSTRAINT [DF_role_permissions_can_view] DEFAULT (0),
  [can_create] BIT NULL CONSTRAINT [DF_role_permissions_can_create] DEFAULT (0),
  [can_edit] BIT NULL CONSTRAINT [DF_role_permissions_can_edit] DEFAULT (0),
  [can_delete] BIT NULL CONSTRAINT [DF_role_permissions_can_delete] DEFAULT (0),
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_role_permissions_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [role_permissions_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [role_permissions_role_id_page_key] UNIQUE ([role_id], [page])
);
END
GO

-- public.roles | ~7 filas
IF OBJECT_ID(N'[dbo].[roles]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[roles] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_roles_id] DEFAULT (NEWSEQUENTIALID()),
  [name] NVARCHAR(50) NOT NULL,
  [description] NVARCHAR(MAX) NULL,
  [is_system] BIT NULL CONSTRAINT [DF_roles_is_system] DEFAULT (0),
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_roles_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [roles_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [roles_name_key] UNIQUE ([name])
);
END
GO

-- public.user_delegations | ~1 filas
IF OBJECT_ID(N'[dbo].[user_delegations]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[user_delegations] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_user_delegations_id] DEFAULT (NEWSEQUENTIALID()),
  [viewer_user_id] UNIQUEIDENTIFIER NOT NULL,
  [owner_user_id] UNIQUEIDENTIFIER NOT NULL,
  [scope] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_user_delegations_scope] DEFAULT (N'all'),
  [notes] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_user_delegations_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [created_by] UNIQUEIDENTIFIER NULL,
  CONSTRAINT [user_delegations_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [user_delegations_viewer_user_id_owner_user_id_key] UNIQUE ([viewer_user_id], [owner_user_id]),
  CONSTRAINT [user_delegations_check] CHECK (([viewer_user_id] <> [owner_user_id])),
  CONSTRAINT [user_delegations_scope_check] CHECK (([scope]  IN (N'all', N'read_only')))
);
END
GO

-- public.user_permission_overrides | ~106 filas
IF OBJECT_ID(N'[dbo].[user_permission_overrides]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[user_permission_overrides] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_user_permission_overrides_id] DEFAULT (NEWSEQUENTIALID()),
  [user_id] UNIQUEIDENTIFIER NOT NULL,
  [page] NVARCHAR(100) NOT NULL,
  [can_view] BIT NULL,
  [can_create] BIT NULL,
  [can_edit] BIT NULL,
  [can_delete] BIT NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_user_permission_overrides_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_user_permission_overrides_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [user_permission_overrides_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [user_permission_overrides_user_id_page_key] UNIQUE ([user_id], [page])
);
END
GO

-- public.users | ~92 filas
IF OBJECT_ID(N'[dbo].[users]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[users] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_users_id] DEFAULT (NEWSEQUENTIALID()),
  [name] NVARCHAR(MAX) NOT NULL,
  [email] NVARCHAR(100) NOT NULL,
  [office] NVARCHAR(MAX) NOT NULL,
  [role] NVARCHAR(MAX) NOT NULL,
  [language] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_users_language] DEFAULT (N'en'),
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_users_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [auth_user_id] UNIQUEIDENTIFIER NULL,
  [birthday] DATE NULL,
  [phone] NVARCHAR(MAX) NULL,
  [extension_number] NVARCHAR(MAX) NULL,
  [hire_date] DATE NULL,
  [status] NVARCHAR(MAX) NULL CONSTRAINT [DF_users_status] DEFAULT (N'Active'),
  [invited_at] DATETIMEOFFSET NULL,
  [invited_by] UNIQUEIDENTIFIER NULL,
  [last_login] DATETIMEOFFSET NULL,
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_users_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  [department] NVARCHAR(MAX) NULL,
  [role_id] UNIQUEIDENTIFIER NULL,
  [can_update_contracts] BIT NULL CONSTRAINT [DF_users_can_update_contracts] DEFAULT (0),
  [can_access_billing] BIT NULL CONSTRAINT [DF_users_can_access_billing] DEFAULT (0),
  [report_visibility] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_users_report_visibility] DEFAULT (N'own'),
  [can_adjust_surcharges] BIT NOT NULL CONSTRAINT [DF_users_can_adjust_surcharges] DEFAULT (0),
  [is_junior_exec] BIT NOT NULL CONSTRAINT [DF_users_is_junior_exec] DEFAULT (0),
  [gender] NVARCHAR(MAX) NULL,
  [cs_all_execs] BIT NOT NULL CONSTRAINT [DF_users_cs_all_execs] DEFAULT (0),
  CONSTRAINT [users_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [users_email_key] UNIQUE ([email]),
  CONSTRAINT [users_gender_check] CHECK (([gender]  IN (N'M', N'F'))),
  CONSTRAINT [users_language_check] CHECK (([language]  IN (N'en', N'es'))),
  CONSTRAINT [users_office_check] CHECK (([office]  IN (N'USA', N'Panama', N'Ecuador', N'Peru'))),
  CONSTRAINT [users_report_visibility_check] CHECK (([report_visibility]  IN (N'own', N'office', N'all'))),
  CONSTRAINT [users_role_check] CHECK (([role]  IN (N'Admin', N'Manager', N'Sales Executive', N'Support', N'Customer Service', N'VP', N'Administration', N'Sales', N'Operations', N'Accounting')))
);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_audit_log_date' AND object_id = OBJECT_ID(N'[dbo].[audit_log]'))
CREATE INDEX [idx_audit_log_date] ON [dbo].[audit_log] ([created_at]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_audit_log_user' AND object_id = OBJECT_ID(N'[dbo].[audit_log]'))
CREATE INDEX [idx_audit_log_user] ON [dbo].[audit_log] ([user_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'impersonation_log_active_idx' AND object_id = OBJECT_ID(N'[dbo].[impersonation_log]'))
CREATE INDEX [impersonation_log_active_idx] ON [dbo].[impersonation_log] ([id]) WHERE ([ended_at] IS NULL);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'impersonation_log_admin_idx' AND object_id = OBJECT_ID(N'[dbo].[impersonation_log]'))
CREATE INDEX [impersonation_log_admin_idx] ON [dbo].[impersonation_log] ([admin_user_id], [started_at] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'impersonation_log_target_idx' AND object_id = OBJECT_ID(N'[dbo].[impersonation_log]'))
CREATE INDEX [impersonation_log_target_idx] ON [dbo].[impersonation_log] ([target_user_id], [started_at] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_login_history_date' AND object_id = OBJECT_ID(N'[dbo].[login_history]'))
CREATE INDEX [idx_login_history_date] ON [dbo].[login_history] ([login_at]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_login_history_is_active' AND object_id = OBJECT_ID(N'[dbo].[login_history]'))
CREATE INDEX [idx_login_history_is_active] ON [dbo].[login_history] ([is_active]) WHERE ([is_active] = 1);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_login_history_user' AND object_id = OBJECT_ID(N'[dbo].[login_history]'))
CREATE INDEX [idx_login_history_user] ON [dbo].[login_history] ([user_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_role_permissions_page' AND object_id = OBJECT_ID(N'[dbo].[role_permissions]'))
CREATE INDEX [idx_role_permissions_page] ON [dbo].[role_permissions] ([page]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_role_permissions_role_id' AND object_id = OBJECT_ID(N'[dbo].[role_permissions]'))
CREATE INDEX [idx_role_permissions_role_id] ON [dbo].[role_permissions] ([role_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_user_delegations_created_by' AND object_id = OBJECT_ID(N'[dbo].[user_delegations]'))
CREATE INDEX [idx_user_delegations_created_by] ON [dbo].[user_delegations] ([created_by]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_user_delegations_owner_user_id' AND object_id = OBJECT_ID(N'[dbo].[user_delegations]'))
CREATE INDEX [idx_user_delegations_owner_user_id] ON [dbo].[user_delegations] ([owner_user_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'user_delegations_viewer_owner_idx' AND object_id = OBJECT_ID(N'[dbo].[user_delegations]'))
CREATE INDEX [user_delegations_viewer_owner_idx] ON [dbo].[user_delegations] ([viewer_user_id], [owner_user_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_user_permission_overrides_page' AND object_id = OBJECT_ID(N'[dbo].[user_permission_overrides]'))
CREATE INDEX [idx_user_permission_overrides_page] ON [dbo].[user_permission_overrides] ([page]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_user_permission_overrides_user_id' AND object_id = OBJECT_ID(N'[dbo].[user_permission_overrides]'))
CREATE INDEX [idx_user_permission_overrides_user_id] ON [dbo].[user_permission_overrides] ([user_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_users_auth_user_id' AND object_id = OBJECT_ID(N'[dbo].[users]'))
CREATE UNIQUE INDEX [idx_users_auth_user_id] ON [dbo].[users] ([auth_user_id]) WHERE [auth_user_id] IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_users_invited_by' AND object_id = OBJECT_ID(N'[dbo].[users]'))
CREATE INDEX [idx_users_invited_by] ON [dbo].[users] ([invited_by]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_users_role_id' AND object_id = OBJECT_ID(N'[dbo].[users]'))
CREATE INDEX [idx_users_role_id] ON [dbo].[users] ([role_id]);
GO
