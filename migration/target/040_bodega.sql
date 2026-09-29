-- 040 · Bodega Miami: tablas e índices
-- Generado por migration/tools/to_tsql.mjs desde el catálogo de Supabase (2026-09-29). No editar a mano:
-- cambiar el generador y volver a correrlo. Idempotente: se puede ejecutar varias veces.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- public.bodega_tenants | ~4 filas
IF OBJECT_ID(N'[dbo].[bodega_tenants]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[bodega_tenants] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_bodega_tenants_id] DEFAULT (NEWSEQUENTIALID()),
  [nombre] NVARCHAR(100) NOT NULL,
  [campo] NVARCHAR(50) NOT NULL CONSTRAINT [DF_bodega_tenants_campo] DEFAULT (N'agente'),
  [pais] NVARCHAR(MAX) NULL,
  [notas] NVARCHAR(MAX) NULL,
  [activo] BIT NOT NULL CONSTRAINT [DF_bodega_tenants_activo] DEFAULT (1),
  [creado_por] UNIQUEIDENTIFIER NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_bodega_tenants_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [bodega_tenants_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [bodega_tenants_campo_check] CHECK (([campo]  IN (N'agente', N'consignatario')))
);
END
GO

-- public.cl_alerts | ~38 filas
IF OBJECT_ID(N'[dbo].[cl_alerts]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[cl_alerts] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_cl_alerts_id] DEFAULT (NEWSEQUENTIALID()),
  [warehouse_id] UNIQUEIDENTIFIER NULL,
  [kind] NVARCHAR(50) NOT NULL,
  [severity] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_cl_alerts_severity] DEFAULT (N'info'),
  [title] NVARCHAR(MAX) NOT NULL,
  [body] NVARCHAR(MAX) NULL,
  [manifest_source_id] UNIQUEIDENTIFIER NULL,
  [picking_task_id] UNIQUEIDENTIFIER NULL,
  [staging_task_id] UNIQUEIDENTIFIER NULL,
  [loading_task_id] UNIQUEIDENTIFIER NULL,
  [recipient_user_id] UNIQUEIDENTIFIER NULL,
  [action_label] NVARCHAR(MAX) NULL,
  [action_url] NVARCHAR(MAX) NULL,
  [status] NVARCHAR(50) NOT NULL CONSTRAINT [DF_cl_alerts_status] DEFAULT (N'unread'),
  [acknowledged_by] UNIQUEIDENTIFIER NULL,
  [acknowledged_at] DATETIMEOFFSET NULL,
  [due_at] DATETIMEOFFSET NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_cl_alerts_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [cl_alerts_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [CK_cl_alerts_kind_enum] CHECK ([kind] IN (N'picking_complete', N'picking_exception', N'staging_assigned', N'staging_discrepancy', N'staging_verified', N'capacity_warning', N'loading_created', N'loading_exception', N'unplanned_addition', N'override', N'reopened', N'reminder_4h')),
  CONSTRAINT [CK_cl_alerts_status_enum] CHECK ([status] IN (N'unread', N'acknowledged', N'dismissed'))
);
END
GO

-- public.cl_audit_log | ~11 filas
IF OBJECT_ID(N'[dbo].[cl_audit_log]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[cl_audit_log] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_cl_audit_log_id] DEFAULT (NEWSEQUENTIALID()),
  [action] NVARCHAR(MAX) NOT NULL,
  [target_table] NVARCHAR(50) NOT NULL,
  [target_id] UNIQUEIDENTIFIER NOT NULL,
  [performed_by] UNIQUEIDENTIFIER NOT NULL,
  [reason] NVARCHAR(MAX) NOT NULL,
  [metadata] NVARCHAR(MAX) NULL CONSTRAINT [DF_cl_audit_log_metadata] DEFAULT (N'{}'),
  [performed_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_cl_audit_log_performed_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [cl_audit_log_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [CK_cl_audit_log_metadata_json] CHECK (ISJSON([metadata]) = 1)
);
END
GO

-- public.cl_container_types | ~4 filas
IF OBJECT_ID(N'[dbo].[cl_container_types]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[cl_container_types] (
  [code] NVARCHAR(50) NOT NULL,
  [description] NVARCHAR(MAX) NOT NULL,
  [max_payload_kg] DECIMAL(10,2) NOT NULL,
  [max_volume_m3] DECIMAL(10,2) NOT NULL,
  [tare_kg] DECIMAL(10,2) NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_cl_container_types_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [cl_container_types_pkey] PRIMARY KEY ([code])
);
END
GO

-- public.cl_scan_events | ~111 filas
IF OBJECT_ID(N'[dbo].[cl_scan_events]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[cl_scan_events] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_cl_scan_events_id] DEFAULT (NEWSEQUENTIALID()),
  [picking_task_id] UNIQUEIDENTIFIER NULL,
  [staging_task_id] UNIQUEIDENTIFIER NULL,
  [loading_task_id] UNIQUEIDENTIFIER NULL,
  [scanned_barcode] NVARCHAR(MAX) NOT NULL,
  [matched_item_id] UNIQUEIDENTIFIER NULL,
  [result] NVARCHAR(50) NOT NULL,
  [scanned_by] UNIQUEIDENTIFIER NOT NULL,
  [scanned_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_cl_scan_events_scanned_at] DEFAULT (SYSDATETIMEOFFSET()),
  [device_id] NVARCHAR(MAX) NULL,
  [metadata] NVARCHAR(MAX) NULL CONSTRAINT [DF_cl_scan_events_metadata] DEFAULT (N'{}'),
  CONSTRAINT [cl_scan_events_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [cl_scan_events_check] CHECK (((((CASE WHEN [picking_task_id] IS NOT NULL THEN 1 ELSE 0 END) + (CASE WHEN [staging_task_id] IS NOT NULL THEN 1 ELSE 0 END)) + (CASE WHEN [loading_task_id] IS NOT NULL THEN 1 ELSE 0 END)) = 1)),
  CONSTRAINT [CK_cl_scan_events_result_enum] CHECK ([result] IN (N'ok', N'wrong_task', N'not_in_manifest', N'duplicate', N'not_staged', N'illegible', N'unknown_barcode')),
  CONSTRAINT [CK_cl_scan_events_metadata_json] CHECK (ISJSON([metadata]) = 1)
);
END
GO

-- public.cl_warehouses | ~1 filas
IF OBJECT_ID(N'[dbo].[cl_warehouses]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[cl_warehouses] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_cl_warehouses_id] DEFAULT (NEWSEQUENTIALID()),
  [code] NVARCHAR(50) NOT NULL,
  [name] NVARCHAR(MAX) NOT NULL,
  [city] NVARCHAR(MAX) NULL,
  [country] NVARCHAR(MAX) NULL,
  [split_threshold] INT NOT NULL CONSTRAINT [DF_cl_warehouses_split_threshold] DEFAULT (20),
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_cl_warehouses_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [cl_warehouses_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [cl_warehouses_code_key] UNIQUE ([code])
);
END
GO

-- public.loading_exceptions | ~3 filas
IF OBJECT_ID(N'[dbo].[loading_exceptions]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[loading_exceptions] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_loading_exceptions_id] DEFAULT (NEWSEQUENTIALID()),
  [loading_task_id] UNIQUEIDENTIFIER NOT NULL,
  [manifest_item_id] UNIQUEIDENTIFIER NULL,
  [exception_type] NVARCHAR(50) NOT NULL,
  [reason] NVARCHAR(MAX) NOT NULL,
  [photo_url] NVARCHAR(MAX) NULL,
  [authorized_by] UNIQUEIDENTIFIER NULL,
  [authorized_at] DATETIMEOFFSET NULL,
  [raised_by] UNIQUEIDENTIFIER NOT NULL,
  [raised_at] DATETIMEOFFSET NULL CONSTRAINT [DF_loading_exceptions_raised_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [loading_exceptions_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [loading_exceptions_check] CHECK ((([exception_type] <> N'damage') OR ([photo_url] IS NOT NULL))),
  CONSTRAINT [loading_exceptions_check1] CHECK ((([exception_type] <> N'skip') OR ([authorized_by] IS NOT NULL))),
  CONSTRAINT [CK_loading_exceptions_exception_type_enum] CHECK ([exception_type] IN (N'damage', N'illegible', N'skip'))
);
END
GO

-- public.loading_materials | ~21 filas
IF OBJECT_ID(N'[dbo].[loading_materials]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[loading_materials] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_loading_materials_id] DEFAULT (NEWSEQUENTIALID()),
  [warehouse_id] UNIQUEIDENTIFIER NULL,
  [code] NVARCHAR(50) NOT NULL,
  [name_es] NVARCHAR(MAX) NOT NULL,
  [name_en] NVARCHAR(MAX) NOT NULL,
  [category] NVARCHAR(50) NOT NULL,
  [unit] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_loading_materials_unit] DEFAULT (N'unidad'),
  [sort_order] INT NOT NULL CONSTRAINT [DF_loading_materials_sort_order] DEFAULT (100),
  [active] BIT NOT NULL CONSTRAINT [DF_loading_materials_active] DEFAULT (1),
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_loading_materials_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_loading_materials_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [loading_materials_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [loading_materials_category_check] CHECK (([category]  IN (N'strap', N'airbag', N'lumber', N'plywood', N'corner', N'wrap', N'equipment', N'other')))
);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'loading_materials_code_scope_unique' AND object_id = OBJECT_ID(N'[dbo].[loading_materials]'))
CREATE UNIQUE INDEX [loading_materials_code_scope_unique] ON [dbo].[loading_materials] ([warehouse_id], [code]) WHERE [warehouse_id] IS NOT NULL;
GO

-- public.loading_task_materials | ~4 filas
IF OBJECT_ID(N'[dbo].[loading_task_materials]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[loading_task_materials] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_loading_task_materials_id] DEFAULT (NEWSEQUENTIALID()),
  [loading_task_id] UNIQUEIDENTIFIER NOT NULL,
  [material_id] UNIQUEIDENTIFIER NOT NULL,
  [quantity] DECIMAL(10,2) NOT NULL,
  [notes] NVARCHAR(MAX) NULL,
  [recorded_by] UNIQUEIDENTIFIER NULL,
  [recorded_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_loading_task_materials_recorded_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [loading_task_materials_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [loading_task_materials_quantity_check] CHECK (([quantity] > 0))
);
END
GO

-- public.loading_tasks | ~6 filas
IF OBJECT_ID(N'[dbo].[loading_tasks]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[loading_tasks] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_loading_tasks_id] DEFAULT (NEWSEQUENTIALID()),
  [manifest_source_id] UNIQUEIDENTIFIER NOT NULL,
  [assigned_to] UNIQUEIDENTIFIER NOT NULL,
  [container_number] NVARCHAR(MAX) NOT NULL,
  [container_type] NVARCHAR(50) NULL,
  [status] NVARCHAR(50) NOT NULL CONSTRAINT [DF_loading_tasks_status] DEFAULT (N'pending'),
  [preload_floor] NVARCHAR(MAX) NULL,
  [preload_walls] NVARCHAR(MAX) NULL,
  [preload_roof] NVARCHAR(MAX) NULL,
  [preload_doors] NVARCHAR(MAX) NULL,
  [preload_photo_url] NVARCHAR(MAX) NULL,
  [preload_completed_at] DATETIMEOFFSET NULL,
  [started_at] DATETIMEOFFSET NULL,
  [closed_at] DATETIMEOFFSET NULL,
  [loader_signature_at] DATETIMEOFFSET NULL,
  [loader_signed_by] UNIQUEIDENTIFIER NULL,
  [supervisor_signature_at] DATETIMEOFFSET NULL,
  [supervisor_signed_by] UNIQUEIDENTIFIER NULL,
  [reopened_at] DATETIMEOFFSET NULL,
  [reopened_by] UNIQUEIDENTIFIER NULL,
  [reopen_reason] NVARCHAR(MAX) NULL,
  [staging_was_overridden] BIT NOT NULL CONSTRAINT [DF_loading_tasks_staging_was_overridden] DEFAULT (0),
  [override_reason] NVARCHAR(MAX) NULL,
  [override_by] UNIQUEIDENTIFIER NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_loading_tasks_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_loading_tasks_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [loading_tasks_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [loading_tasks_manifest_source_id_key] UNIQUE ([manifest_source_id]),
  CONSTRAINT [CK_loading_tasks_status_enum] CHECK ([status] IN (N'pending', N'pre_load', N'in_progress', N'paused', N'closed', N'reopened', N'cancelled'))
);
END
GO

-- public.manifest_items | ~234 filas
IF OBJECT_ID(N'[dbo].[manifest_items]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[manifest_items] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_manifest_items_id] DEFAULT (NEWSEQUENTIALID()),
  [manifest_source_id] UNIQUEIDENTIFIER NOT NULL,
  [barcode] NVARCHAR(50) NOT NULL,
  [item_type] NVARCHAR(50) NOT NULL,
  [description] NVARCHAR(MAX) NULL,
  [weight_kg] DECIMAL(10,3) NOT NULL,
  [volume_m3] DECIMAL(10,3) NULL,
  [is_hazmat] BIT NULL CONSTRAINT [DF_manifest_items_is_hazmat] DEFAULT (0),
  [hazmat_un] NVARCHAR(MAX) NULL,
  [is_heavy] BIT NULL CONSTRAINT [DF_manifest_items_is_heavy] DEFAULT (0),
  [is_fragile] BIT NULL CONSTRAINT [DF_manifest_items_is_fragile] DEFAULT (0),
  [pick_status] NVARCHAR(50) NOT NULL CONSTRAINT [DF_manifest_items_pick_status] DEFAULT (N'in_rack'),
  [assigned_picking_task_id] UNIQUEIDENTIFIER NULL,
  [picked_at] DATETIMEOFFSET NULL,
  [picked_by] UNIQUEIDENTIFIER NULL,
  [staging_status] NVARCHAR(50) NOT NULL CONSTRAINT [DF_manifest_items_staging_status] DEFAULT (N'pending'),
  [verified_at] DATETIMEOFFSET NULL,
  [verified_by] UNIQUEIDENTIFIER NULL,
  [load_status] NVARCHAR(50) NOT NULL CONSTRAINT [DF_manifest_items_load_status] DEFAULT (N'pending'),
  [loaded_at] DATETIMEOFFSET NULL,
  [loaded_by] UNIQUEIDENTIFIER NULL,
  [load_scan_order] INT NULL,
  [load_photo_url] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_manifest_items_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_manifest_items_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  [wr_number] NVARCHAR(50) NULL,
  [location] NVARCHAR(50) NULL,
  [dimensions] NVARCHAR(MAX) NULL,
  [is_bonded] BIT NOT NULL CONSTRAINT [DF_manifest_items_is_bonded] DEFAULT (0),
  [is_fumigated] BIT NOT NULL CONSTRAINT [DF_manifest_items_is_fumigated] DEFAULT (0),
  [package_descriptor] NVARCHAR(MAX) NULL,
  [shipper_name] NVARCHAR(50) NULL,
  [consignee_name] NVARCHAR(MAX) NULL,
  [reference_photo_url] NVARCHAR(MAX) NULL,
  [destination_agent] NVARCHAR(MAX) NULL,
  [piece_index] INT NULL,
  [wr_total_pieces] INT NULL,
  [is_depalletized] BIT NOT NULL CONSTRAINT [DF_manifest_items_is_depalletized] DEFAULT (0),
  [depalletized_carton_count] INT NULL,
  [depalletized_at] DATETIMEOFFSET NULL,
  [depalletized_by] UNIQUEIDENTIFIER NULL,
  [depalletized_supervisor_id] UNIQUEIDENTIFIER NULL,
  [loading_priority] INT NULL,
  CONSTRAINT [manifest_items_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [manifest_items_manifest_source_id_barcode_key] UNIQUE ([manifest_source_id], [barcode]),
  CONSTRAINT [manifest_items_depalletized_count_chk] CHECK (((([is_depalletized] = 0) AND ([depalletized_carton_count] IS NULL)) OR (([is_depalletized] = 1) AND ([depalletized_carton_count] IS NOT NULL) AND (([depalletized_carton_count] >= 1) AND ([depalletized_carton_count] <= 10000))))),
  CONSTRAINT [manifest_items_loading_priority_check] CHECK ((([loading_priority] IS NULL) OR ([loading_priority] > 0))),
  CONSTRAINT [CK_manifest_items_item_type_enum] CHECK ([item_type] IN (N'pallet', N'box', N'bag', N'package', N'envelope')),
  CONSTRAINT [CK_manifest_items_pick_status_enum] CHECK ([pick_status] IN (N'in_rack', N'picked', N'exception')),
  CONSTRAINT [CK_manifest_items_staging_status_enum] CHECK ([staging_status] IN (N'pending', N'verified', N'missing', N'extra')),
  CONSTRAINT [CK_manifest_items_load_status_enum] CHECK ([load_status] IN (N'pending', N'loaded', N'exception'))
);
END
GO

-- public.manifest_sources | ~20 filas
IF OBJECT_ID(N'[dbo].[manifest_sources]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[manifest_sources] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_manifest_sources_id] DEFAULT (NEWSEQUENTIALID()),
  [source_type] NVARCHAR(50) NOT NULL,
  [magaya_guid] NVARCHAR(255) NULL,
  [external_number] NVARCHAR(50) NOT NULL,
  [container_number] NVARCHAR(MAX) NULL,
  [container_type] NVARCHAR(50) NULL,
  [customer_name] NVARCHAR(MAX) NULL,
  [destination] NVARCHAR(MAX) NULL,
  [eta] DATE NULL,
  [warehouse_id] UNIQUEIDENTIFIER NULL,
  [workflow_status] NVARCHAR(50) NOT NULL CONSTRAINT [DF_manifest_sources_workflow_status] DEFAULT (N'picking_pending'),
  [snapshot_taken_at] DATETIMEOFFSET NULL,
  [last_synced_at] DATETIMEOFFSET NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_manifest_sources_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_manifest_sources_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [manifest_sources_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [CK_manifest_sources_source_type_enum] CHECK ([source_type] IN (N'shipment', N'cargo_release'))
);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'manifest_sources_source_type_magaya_guid_key' AND object_id = OBJECT_ID(N'[dbo].[manifest_sources]'))
CREATE UNIQUE INDEX [manifest_sources_source_type_magaya_guid_key] ON [dbo].[manifest_sources] ([source_type], [magaya_guid]) WHERE [magaya_guid] IS NOT NULL;
GO

-- public.picking_exceptions | ~2 filas
IF OBJECT_ID(N'[dbo].[picking_exceptions]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[picking_exceptions] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_picking_exceptions_id] DEFAULT (NEWSEQUENTIALID()),
  [picking_task_id] UNIQUEIDENTIFIER NOT NULL,
  [manifest_item_id] UNIQUEIDENTIFIER NULL,
  [exception_type] NVARCHAR(50) NOT NULL,
  [reason] NVARCHAR(MAX) NOT NULL,
  [photo_url] NVARCHAR(MAX) NULL,
  [raised_by] UNIQUEIDENTIFIER NOT NULL,
  [raised_at] DATETIMEOFFSET NULL CONSTRAINT [DF_picking_exceptions_raised_at] DEFAULT (SYSDATETIMEOFFSET()),
  [resolved] BIT NOT NULL CONSTRAINT [DF_picking_exceptions_resolved] DEFAULT (0),
  [resolution] NVARCHAR(MAX) NULL,
  [resolved_by] UNIQUEIDENTIFIER NULL,
  [resolved_at] DATETIMEOFFSET NULL,
  CONSTRAINT [picking_exceptions_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [picking_exceptions_check] CHECK ((([exception_type] <> N'damage') OR ([photo_url] IS NOT NULL))),
  CONSTRAINT [CK_picking_exceptions_exception_type_enum] CHECK ([exception_type] IN (N'not_found_in_location', N'short_stock', N'damage'))
);
END
GO

-- public.picking_tasks | ~18 filas
IF OBJECT_ID(N'[dbo].[picking_tasks]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[picking_tasks] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_picking_tasks_id] DEFAULT (NEWSEQUENTIALID()),
  [manifest_source_id] UNIQUEIDENTIFIER NOT NULL,
  [task_type] NVARCHAR(50) NOT NULL,
  [equipment_required] NVARCHAR(50) NOT NULL CONSTRAINT [DF_picking_tasks_equipment_required] DEFAULT (N'NONE'),
  [assigned_to] UNIQUEIDENTIFIER NULL,
  [parent_split_id] UNIQUEIDENTIFIER NULL,
  [status] NVARCHAR(50) NOT NULL CONSTRAINT [DF_picking_tasks_status] DEFAULT (N'pending'),
  [started_at] DATETIMEOFFSET NULL,
  [closed_at] DATETIMEOFFSET NULL,
  [pick_count] INT NOT NULL CONSTRAINT [DF_picking_tasks_pick_count] DEFAULT (0),
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_picking_tasks_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_picking_tasks_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [picking_tasks_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [picking_tasks_check] CHECK (((([task_type] = N'PALLETS') AND ([equipment_required] = N'FORKLIFT')) OR (([task_type] = N'BOXES') AND ([equipment_required] = N'MANUAL')) OR ([task_type] = N'MIXED'))),
  CONSTRAINT [CK_picking_tasks_task_type_enum] CHECK ([task_type] IN (N'MIXED', N'PALLETS', N'BOXES')),
  CONSTRAINT [CK_picking_tasks_equipment_required_enum] CHECK ([equipment_required] IN (N'NONE', N'FORKLIFT', N'MANUAL')),
  CONSTRAINT [CK_picking_tasks_status_enum] CHECK ([status] IN (N'pending', N'in_progress', N'paused', N'closed', N'blocked_discrepancy', N'cancelled'))
);
END
GO

-- public.staging_check_tasks | ~11 filas
IF OBJECT_ID(N'[dbo].[staging_check_tasks]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[staging_check_tasks] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_staging_check_tasks_id] DEFAULT (NEWSEQUENTIALID()),
  [manifest_source_id] UNIQUEIDENTIFIER NOT NULL,
  [assigned_to] UNIQUEIDENTIFIER NULL,
  [created_by] UNIQUEIDENTIFIER NOT NULL,
  [status] NVARCHAR(50) NOT NULL CONSTRAINT [DF_staging_check_tasks_status] DEFAULT (N'pending'),
  [started_at] DATETIMEOFFSET NULL,
  [closed_at] DATETIMEOFFSET NULL,
  [verified_count] INT NOT NULL CONSTRAINT [DF_staging_check_tasks_verified_count] DEFAULT (0),
  [missing_count] INT NOT NULL CONSTRAINT [DF_staging_check_tasks_missing_count] DEFAULT (0),
  [extra_count] INT NOT NULL CONSTRAINT [DF_staging_check_tasks_extra_count] DEFAULT (0),
  [notes] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_staging_check_tasks_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_staging_check_tasks_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [staging_check_tasks_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [staging_check_tasks_manifest_source_id_key] UNIQUE ([manifest_source_id]),
  CONSTRAINT [CK_staging_check_tasks_status_enum] CHECK ([status] IN (N'pending', N'in_progress', N'paused', N'closed', N'blocked_discrepancy', N'cancelled'))
);
END
GO

-- public.staging_exceptions | ~1 filas
IF OBJECT_ID(N'[dbo].[staging_exceptions]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[staging_exceptions] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_staging_exceptions_id] DEFAULT (NEWSEQUENTIALID()),
  [staging_task_id] UNIQUEIDENTIFIER NOT NULL,
  [exception_type] NVARCHAR(50) NOT NULL,
  [missing_items] NVARCHAR(MAX) NULL CONSTRAINT [DF_staging_exceptions_missing_items] DEFAULT (N'[]'),
  [extra_items] NVARCHAR(MAX) NULL CONSTRAINT [DF_staging_exceptions_extra_items] DEFAULT (N'[]'),
  [reason] NVARCHAR(MAX) NULL,
  [raised_by] UNIQUEIDENTIFIER NOT NULL,
  [raised_at] DATETIMEOFFSET NULL CONSTRAINT [DF_staging_exceptions_raised_at] DEFAULT (SYSDATETIMEOFFSET()),
  [resolved] BIT NOT NULL CONSTRAINT [DF_staging_exceptions_resolved] DEFAULT (0),
  [resolution] NVARCHAR(MAX) NULL,
  [resolved_by] UNIQUEIDENTIFIER NULL,
  [resolved_at] DATETIMEOFFSET NULL,
  CONSTRAINT [staging_exceptions_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [CK_staging_exceptions_exception_type_enum] CHECK ([exception_type] IN (N'discrepancy', N'damaged')),
  CONSTRAINT [CK_staging_exceptions_missing_items_json] CHECK (ISJSON([missing_items]) = 1),
  CONSTRAINT [CK_staging_exceptions_extra_items_json] CHECK (ISJSON([extra_items]) = 1)
);
END
GO

-- public.unplanned_additions | ~3 filas
IF OBJECT_ID(N'[dbo].[unplanned_additions]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[unplanned_additions] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_unplanned_additions_id] DEFAULT (NEWSEQUENTIALID()),
  [loading_task_id] UNIQUEIDENTIFIER NOT NULL,
  [barcode] NVARCHAR(MAX) NOT NULL,
  [magaya_tracking] NVARCHAR(MAX) NULL,
  [weight_kg] DECIMAL(10,3) NULL,
  [volume_m3] DECIMAL(10,3) NULL,
  [reason] NVARCHAR(MAX) NOT NULL,
  [authorized_by] UNIQUEIDENTIFIER NOT NULL,
  [authorized_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_unplanned_additions_authorized_at] DEFAULT (SYSDATETIMEOFFSET()),
  [raised_by] UNIQUEIDENTIFIER NOT NULL,
  [raised_at] DATETIMEOFFSET NULL CONSTRAINT [DF_unplanned_additions_raised_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [unplanned_additions_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.warehouse_cogs_manual | ~4 filas
IF OBJECT_ID(N'[dbo].[warehouse_cogs_manual]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[warehouse_cogs_manual] (
  [id] INT NOT NULL CONSTRAINT [DF_warehouse_cogs_manual_id] DEFAULT (NEXT VALUE FOR [dbo].[warehouse_cogs_manual_id_seq]),
  [year] INT NOT NULL,
  [month] INT NULL,
  [category] NVARCHAR(MAX) NOT NULL,
  [amount] DECIMAL(15,2) NOT NULL,
  [source] NVARCHAR(MAX) NULL CONSTRAINT [DF_warehouse_cogs_manual_source] DEFAULT (N'manual'),
  [notes] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_warehouse_cogs_manual_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [warehouse_cogs_manual_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.warehouse_cogs_monthly | ~48 filas
IF OBJECT_ID(N'[dbo].[warehouse_cogs_monthly]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[warehouse_cogs_monthly] (
  [id] INT NOT NULL CONSTRAINT [DF_warehouse_cogs_monthly_id] DEFAULT (NEXT VALUE FOR [dbo].[warehouse_cogs_monthly_id_seq]),
  [year] INT NOT NULL,
  [month] INT NOT NULL,
  [category] NVARCHAR(50) NOT NULL,
  [source] NVARCHAR(MAX) NOT NULL,
  [entity_name] NVARCHAR(MAX) NULL,
  [amount] DECIMAL(14,2) NOT NULL,
  CONSTRAINT [warehouse_cogs_monthly_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [warehouse_cogs_monthly_year_month_category_key] UNIQUE ([year], [month], [category])
);
END
GO

-- public.warehouse_containers | ~144 filas
IF OBJECT_ID(N'[dbo].[warehouse_containers]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[warehouse_containers] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_warehouse_containers_id] DEFAULT (NEWSEQUENTIALID()),
  [name] NVARCHAR(MAX) NOT NULL,
  [week] NVARCHAR(50) NULL,
  [booking] NVARCHAR(MAX) NULL,
  [shipping_line] NVARCHAR(MAX) NULL,
  [owner_id] UNIQUEIDENTIFIER NULL,
  [container_type] NVARCHAR(MAX) NULL,
  [container_number] NVARCHAR(MAX) NULL,
  [hazmat_bonded] NVARCHAR(MAX) NULL,
  [cut_off_date] DATETIMEOFFSET NULL,
  [load_unload_datetime] DATETIMEOFFSET NULL,
  [status] NVARCHAR(MAX) NULL,
  [door] NVARCHAR(MAX) NULL,
  [loader] NVARCHAR(MAX) NULL,
  [lg_cr] NVARCHAR(MAX) NULL,
  [staging] NVARCHAR(MAX) NULL,
  [palos_2x4] INT NULL CONSTRAINT [DF_warehouse_containers_palos_2x4] DEFAULT (0),
  [straps_amarillos] INT NULL CONSTRAINT [DF_warehouse_containers_straps_amarillos] DEFAULT (0),
  [pallets_vacios] INT NULL CONSTRAINT [DF_warehouse_containers_pallets_vacios] DEFAULT (0),
  [bolsas_aire] INT NULL CONSTRAINT [DF_warehouse_containers_bolsas_aire] DEFAULT (0),
  [notes] NVARCHAR(MAX) NULL,
  [special_instructions] NVARCHAR(MAX) NULL,
  [office] NVARCHAR(50) NOT NULL,
  [created_by] UNIQUEIDENTIFIER NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_warehouse_containers_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_warehouse_containers_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  [employee] NVARCHAR(MAX) NULL,
  [created_by_user_id] UNIQUEIDENTIFIER NULL,
  CONSTRAINT [warehouse_containers_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [warehouse_containers_office_check] CHECK (([office]  IN (N'USA', N'Panama', N'Ecuador', N'Peru')))
);
END
GO

-- public.warehouse_users | ~1 filas
IF OBJECT_ID(N'[dbo].[warehouse_users]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[warehouse_users] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_warehouse_users_id] DEFAULT (NEWSEQUENTIALID()),
  [user_id] UNIQUEIDENTIFIER NOT NULL,
  [employee_code] NVARCHAR(50) NOT NULL,
  [warehouse_id] UNIQUEIDENTIFIER NULL,
  [roles] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_warehouse_users_roles] DEFAULT (N'[]'),
  [certs] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_warehouse_users_certs] DEFAULT (N'[]'),
  [pin_hash] NVARCHAR(MAX) NULL,
  [biometric_id] NVARCHAR(MAX) NULL,
  [active] BIT NOT NULL CONSTRAINT [DF_warehouse_users_active] DEFAULT (1),
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_warehouse_users_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_warehouse_users_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [warehouse_users_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [warehouse_users_employee_code_key] UNIQUE ([employee_code]),
  CONSTRAINT [warehouse_users_user_id_key] UNIQUE ([user_id]),
  CONSTRAINT [CK_warehouse_users_roles_json] CHECK (ISJSON([roles]) = 1),
  CONSTRAINT [CK_warehouse_users_certs_json] CHECK (ISJSON([certs]) = 1)
);
END
GO

-- public.wh_carga_no_identificada | ~409 filas
IF OBJECT_ID(N'[dbo].[wh_carga_no_identificada]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[wh_carga_no_identificada] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_wh_carga_no_identificada_id] DEFAULT (NEWSEQUENTIALID()),
  [wr_number] NVARCHAR(50) NOT NULL,
  [tipo] NVARCHAR(MAX) NOT NULL,
  [detectado_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_wh_carga_no_identificada_detectado_at] DEFAULT (SYSDATETIMEOFFSET()),
  [entry_date] DATE NULL,
  [consignee_inicial] NVARCHAR(MAX) NULL,
  [agente_inicial] NVARCHAR(MAX) NULL,
  [shipper] NVARCHAR(MAX) NULL,
  [piezas] INT NULL,
  [peso_lb] DECIMAL(38,10) NULL,
  [volumen_cft] DECIMAL(38,10) NULL,
  [recibido_por] NVARCHAR(MAX) NULL,
  [estado] NVARCHAR(50) NOT NULL CONSTRAINT [DF_wh_carga_no_identificada_estado] DEFAULT (N'SIN_IDENTIFICAR'),
  [identificado_at] DATETIMEOFFSET NULL,
  [consignee_final] NVARCHAR(MAX) NULL,
  [agente_final] NVARCHAR(MAX) NULL,
  [client_id] UNIQUEIDENTIFIER NULL,
  [dias_para_identificar] DECIMAL(38,10) NULL,
  [cobrable] BIT NOT NULL CONSTRAINT [DF_wh_carga_no_identificada_cobrable] DEFAULT (1),
  [cargo_usd] DECIMAL(38,10) NULL,
  [facturado] BIT NOT NULL CONSTRAINT [DF_wh_carga_no_identificada_facturado] DEFAULT (0),
  [nota] NVARCHAR(MAX) NULL,
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_wh_carga_no_identificada_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [wh_carga_no_identificada_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [wh_carga_no_identificada_wr_number_key] UNIQUE ([wr_number]),
  CONSTRAINT [wh_carga_no_identificada_estado_check] CHECK (([estado]  IN (N'SIN_IDENTIFICAR', N'IDENTIFICADA', N'IMPORTACION', N'DESCARTADA'))),
  CONSTRAINT [wh_carga_no_identificada_tipo_check] CHECK (([tipo]  IN (N'SIN_CONSIGNATARIO', N'SIN_AGENTE')))
);
END
GO

-- public.wh_container_types | ~9 filas
IF OBJECT_ID(N'[dbo].[wh_container_types]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[wh_container_types] (
  [id] INT NOT NULL CONSTRAINT [DF_wh_container_types_id] DEFAULT (NEXT VALUE FOR [dbo].[wh_container_types_id_seq]),
  [match_pattern] NVARCHAR(50) NOT NULL,
  [canonical] NVARCHAR(MAX) NOT NULL,
  [cbm_capacity] DECIMAL(38,10) NOT NULL,
  [priority] INT NOT NULL CONSTRAINT [DF_wh_container_types_priority] DEFAULT (100),
  CONSTRAINT [wh_container_types_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [wh_container_types_match_pattern_key] UNIQUE ([match_pattern])
);
END
GO

-- public.wh_containers | ~6,216 filas
IF OBJECT_ID(N'[dbo].[wh_containers]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[wh_containers] (
  [monday_item_id] BIGINT NOT NULL,
  [board_id] BIGINT NULL,
  [board_year] INT NULL,
  [week_label] NVARCHAR(MAX) NULL,
  [week_no] INT NULL,
  [name] NVARCHAR(MAX) NULL,
  [booking] NVARCHAR(MAX) NULL,
  [shipping_line] NVARCHAR(MAX) NULL,
  [owner] NVARCHAR(MAX) NULL,
  [status] NVARCHAR(100) NULL,
  [container_type_raw] NVARCHAR(MAX) NULL,
  [container_type] NVARCHAR(MAX) NULL,
  [cbm_capacity] DECIMAL(38,10) NULL,
  [container_number] NVARCHAR(MAX) NULL,
  [load_date] DATE NULL,
  [loader] NVARCHAR(100) NULL,
  [haz_bonded] NVARCHAR(MAX) NULL,
  [trade_dir] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_wh_containers_trade_dir] DEFAULT (N'EXPORT'),
  [item_created_at] DATETIMEOFFSET NULL,
  [synced_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_wh_containers_synced_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [wh_containers_pkey] PRIMARY KEY ([monday_item_id])
);
END
GO

-- public.wh_containers_external | ~2,323 filas
IF OBJECT_ID(N'[dbo].[wh_containers_external]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[wh_containers_external] (
  [monday_item_id] BIGINT NOT NULL,
  [board_id] BIGINT NULL,
  [board_year] INT NULL,
  [week_label] NVARCHAR(MAX) NULL,
  [week_no] INT NULL,
  [name] NVARCHAR(MAX) NULL,
  [booking] NVARCHAR(MAX) NULL,
  [shipping_line] NVARCHAR(MAX) NULL,
  [owner] NVARCHAR(MAX) NULL,
  [container_type] NVARCHAR(MAX) NULL,
  [container_number] NVARCHAR(MAX) NULL,
  [status] NVARCHAR(MAX) NULL,
  [port_of_loading] NVARCHAR(MAX) NULL,
  [destination] NVARCHAR(MAX) NULL,
  [destination_agent] NVARCHAR(MAX) NULL,
  [doc_cutoff] DATE NULL,
  [cargo_cutoff] DATE NULL,
  [etd] DATE NULL,
  [eta] DATE NULL,
  [item_created_at] DATETIMEOFFSET NULL,
  [synced_at] DATETIMEOFFSET NULL,
  CONSTRAINT [wh_containers_external_pkey] PRIMARY KEY ([monday_item_id])
);
END
GO

-- public.wh_country_map | ~26 filas
IF OBJECT_ID(N'[dbo].[wh_country_map]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[wh_country_map] (
  [id] INT NOT NULL CONSTRAINT [DF_wh_country_map_id] DEFAULT (NEXT VALUE FOR [dbo].[wh_country_map_id_seq]),
  [match_field] NVARCHAR(50) NOT NULL,
  [match_pattern] NVARCHAR(50) NOT NULL,
  [country] NVARCHAR(MAX) NOT NULL,
  [priority] INT NOT NULL CONSTRAINT [DF_wh_country_map_priority] DEFAULT (100),
  CONSTRAINT [wh_country_map_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [wh_country_map_match_field_match_pattern_key] UNIQUE ([match_field], [match_pattern]),
  CONSTRAINT [wh_country_map_match_field_check] CHECK (([match_field]  IN (N'destination_agent', N'consignee', N'destination_port')))
);
END
GO

-- public.wh_import_clients | ~15 filas
IF OBJECT_ID(N'[dbo].[wh_import_clients]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[wh_import_clients] (
  [id] INT NOT NULL CONSTRAINT [DF_wh_import_clients_id] DEFAULT (NEXT VALUE FOR [dbo].[wh_import_clients_id_seq]),
  [client_group] NVARCHAR(MAX) NOT NULL,
  [match_pattern] NVARCHAR(MAX) NOT NULL,
  [active] BIT NOT NULL CONSTRAINT [DF_wh_import_clients_active] DEFAULT (1),
  [notes] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_wh_import_clients_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [wh_import_clients_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.wh_internal_people | ~3 filas
IF OBJECT_ID(N'[dbo].[wh_internal_people]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[wh_internal_people] (
  [id] INT NOT NULL CONSTRAINT [DF_wh_internal_people_id] DEFAULT (NEXT VALUE FOR [dbo].[wh_internal_people_id_seq]),
  [name_pattern] NVARCHAR(50) NOT NULL,
  [office] NVARCHAR(MAX) NOT NULL,
  [suggested_agent] NVARCHAR(MAX) NULL,
  [notes] NVARCHAR(MAX) NULL,
  CONSTRAINT [wh_internal_people_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [wh_internal_people_name_pattern_key] UNIQUE ([name_pattern])
);
END
GO

-- public.wh_loading_rates | ~4 filas
IF OBJECT_ID(N'[dbo].[wh_loading_rates]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[wh_loading_rates] (
  [id] INT NOT NULL CONSTRAINT [DF_wh_loading_rates_id] DEFAULT (NEXT VALUE FOR [dbo].[wh_loading_rates_id_seq]),
  [container_type] NVARCHAR(50) NOT NULL,
  [client_group] NVARCHAR(50) NOT NULL CONSTRAINT [DF_wh_loading_rates_client_group] DEFAULT (N'ALL'),
  [rate_usd] DECIMAL(38,10) NOT NULL,
  [effective_from] DATE NOT NULL CONSTRAINT [DF_wh_loading_rates_effective_from] DEFAULT ('2026-01-01'),
  [notes] NVARCHAR(MAX) NULL,
  CONSTRAINT [wh_loading_rates_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [wh_loading_rates_container_type_client_group_effective_from_key] UNIQUE ([container_type], [client_group], [effective_from])
);
END
GO

-- public.wh_notices | ~8,099 filas
IF OBJECT_ID(N'[dbo].[wh_notices]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[wh_notices] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_wh_notices_id] DEFAULT (NEWSEQUENTIALID()),
  [wr_number] NVARCHAR(50) NOT NULL,
  [client_id] UNIQUEIDENTIFIER NULL,
  [consignee_name] NVARCHAR(MAX) NULL,
  [shipper_name] NVARCHAR(MAX) NULL,
  [tracking] NVARCHAR(MAX) NULL,
  [observaciones] NVARCHAR(MAX) NULL,
  [invoice_status] NVARCHAR(MAX) NULL,
  [subject] NVARCHAR(MAX) NULL,
  [body_html] NVARCHAR(MAX) NULL,
  [recipients] NVARCHAR(MAX) NULL,
  [attachments] NVARCHAR(MAX) NULL,
  [status] NVARCHAR(50) NOT NULL CONSTRAINT [DF_wh_notices_status] DEFAULT (N'DRAFT'),
  [error] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_wh_notices_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [sent_at] DATETIMEOFFSET NULL,
  [sent_by] UNIQUEIDENTIFIER NULL,
  [attachments_refreshed_at] DATETIMEOFFSET NULL,
  [invoice_status_manual] BIT NOT NULL CONSTRAINT [DF_wh_notices_invoice_status_manual] DEFAULT (0),
  CONSTRAINT [wh_notices_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [wh_notices_wr_number_key] UNIQUE ([wr_number]),
  CONSTRAINT [wh_notices_invoice_status_check] CHECK (([invoice_status]  IN (N'ADJUNTA', N'FALTANTE', N'SIN_PACKING'))),
  CONSTRAINT [wh_notices_status_check] CHECK (([status]  IN (N'DRAFT', N'READY', N'SENT', N'ERROR', N'SKIPPED'))),
  CONSTRAINT [CK_wh_notices_recipients_json] CHECK (ISJSON([recipients]) = 1),
  CONSTRAINT [CK_wh_notices_attachments_json] CHECK (ISJSON([attachments]) = 1)
);
END
GO

-- public.wh_report_clients | ~3 filas
IF OBJECT_ID(N'[dbo].[wh_report_clients]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[wh_report_clients] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_wh_report_clients_id] DEFAULT (NEWSEQUENTIALID()),
  [name] NVARCHAR(MAX) NOT NULL,
  [consignee_name] NVARCHAR(MAX) NULL,
  [active] BIT NULL CONSTRAINT [DF_wh_report_clients_active] DEFAULT (1),
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_wh_report_clients_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [wh_report_clients_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.wh_report_movement_items | ~1,170 filas
IF OBJECT_ID(N'[dbo].[wh_report_movement_items]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[wh_report_movement_items] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_wh_report_movement_items_id] DEFAULT (NEWSEQUENTIALID()),
  [movement_id] UNIQUEIDENTIFIER NULL,
  [product_id] UNIQUEIDENTIFIER NULL,
  [quantity] INT NOT NULL CONSTRAINT [DF_wh_report_movement_items_quantity] DEFAULT (0),
  [cartons_per_pallet] INT NULL,
  [is_incomplete] BIT NULL CONSTRAINT [DF_wh_report_movement_items_is_incomplete] DEFAULT (0),
  [notes] NVARCHAR(MAX) NULL,
  CONSTRAINT [wh_report_movement_items_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.wh_report_movements | ~1,162 filas
IF OBJECT_ID(N'[dbo].[wh_report_movements]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[wh_report_movements] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_wh_report_movements_id] DEFAULT (NEWSEQUENTIALID()),
  [client_id] UNIQUEIDENTIFIER NULL,
  [date] DATE NOT NULL,
  [movement_type] NVARCHAR(MAX) NOT NULL,
  [reference_number] NVARCHAR(MAX) NULL,
  [container_number] NVARCHAR(MAX) NULL,
  [product_name] NVARCHAR(MAX) NULL,
  [total_pallets] INT NULL CONSTRAINT [DF_wh_report_movements_total_pallets] DEFAULT (0),
  [packing_pallets] INT NULL CONSTRAINT [DF_wh_report_movements_packing_pallets] DEFAULT (0),
  [packing_loose] INT NULL CONSTRAINT [DF_wh_report_movements_packing_loose] DEFAULT (0),
  [packing_total] INT NULL CONSTRAINT [DF_wh_report_movements_packing_total] DEFAULT (0),
  [physical_pallets] INT NULL CONSTRAINT [DF_wh_report_movements_physical_pallets] DEFAULT (0),
  [physical_loose] INT NULL CONSTRAINT [DF_wh_report_movements_physical_loose] DEFAULT (0),
  [physical_total] INT NULL CONSTRAINT [DF_wh_report_movements_physical_total] DEFAULT (0),
  [extra_pallets] INT NULL CONSTRAINT [DF_wh_report_movements_extra_pallets] DEFAULT (0),
  [notes] NVARCHAR(MAX) NULL,
  [created_by] UNIQUEIDENTIFIER NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_wh_report_movements_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [magaya_wr_id] UNIQUEIDENTIFIER NULL,
  [magaya_cr_id] UNIQUEIDENTIFIER NULL,
  [source] NVARCHAR(MAX) NULL CONSTRAINT [DF_wh_report_movements_source] DEFAULT (N'manual'),
  CONSTRAINT [wh_report_movements_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [wh_report_movements_movement_type_check] CHECK (([movement_type]  IN (N'IN', N'OUT'))),
  CONSTRAINT [wh_report_movements_source_check] CHECK (([source]  IN (N'manual', N'magaya_auto', N'excel_import')))
);
END
GO

-- public.wh_report_product_mappings | ~46 filas
IF OBJECT_ID(N'[dbo].[wh_report_product_mappings]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[wh_report_product_mappings] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_wh_report_product_mappings_id] DEFAULT (NEWSEQUENTIALID()),
  [client_id] UNIQUEIDENTIFIER NOT NULL,
  [product_id] UNIQUEIDENTIFIER NOT NULL,
  [magaya_pattern] NVARCHAR(50) NOT NULL,
  [priority] INT NULL CONSTRAINT [DF_wh_report_product_mappings_priority] DEFAULT (0),
  [active] BIT NULL CONSTRAINT [DF_wh_report_product_mappings_active] DEFAULT (1),
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_wh_report_product_mappings_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [wh_report_product_mappings_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [wh_report_product_mappings_client_id_magaya_pattern_key] UNIQUE ([client_id], [magaya_pattern])
);
END
GO

-- public.wh_report_products | ~26 filas
IF OBJECT_ID(N'[dbo].[wh_report_products]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[wh_report_products] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_wh_report_products_id] DEFAULT (NEWSEQUENTIALID()),
  [client_id] UNIQUEIDENTIFIER NULL,
  [name] NVARCHAR(MAX) NOT NULL,
  [short_name] NVARCHAR(MAX) NULL,
  [display_order] INT NULL CONSTRAINT [DF_wh_report_products_display_order] DEFAULT (0),
  [active] BIT NULL CONSTRAINT [DF_wh_report_products_active] DEFAULT (1),
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_wh_report_products_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [standard_cartons_per_pallet] INT NULL,
  CONSTRAINT [wh_report_products_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.wh_report_sync_log | ~8,949 filas
IF OBJECT_ID(N'[dbo].[wh_report_sync_log]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[wh_report_sync_log] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_wh_report_sync_log_id] DEFAULT (NEWSEQUENTIALID()),
  [source_table] NVARCHAR(MAX) NOT NULL,
  [source_id] UNIQUEIDENTIFIER NULL,
  [client_id] UNIQUEIDENTIFIER NULL,
  [item_description] NVARCHAR(MAX) NULL,
  [status] NVARCHAR(50) NOT NULL,
  [message] NVARCHAR(MAX) NULL,
  [resolved_at] DATETIMEOFFSET NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_wh_report_sync_log_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [wh_report_sync_log_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [wh_report_sync_log_status_check] CHECK (([status]  IN (N'unmapped', N'error', N'resolved')))
);
END
GO

-- public.wh_stations | ~7 filas
IF OBJECT_ID(N'[dbo].[wh_stations]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[wh_stations] (
  [id] INT NOT NULL CONSTRAINT [DF_wh_stations_id] DEFAULT (NEXT VALUE FOR [dbo].[wh_stations_id_seq]),
  [person_pattern] NVARCHAR(50) NOT NULL,
  [station] NVARCHAR(MAX) NULL,
  [role] NVARCHAR(MAX) NOT NULL,
  [active] BIT NOT NULL CONSTRAINT [DF_wh_stations_active] DEFAULT (1),
  [notes] NVARCHAR(MAX) NULL,
  CONSTRAINT [wh_stations_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [wh_stations_person_pattern_key] UNIQUE ([person_pattern])
);
END
GO

-- public.wh_storage_terms | ~5 filas
IF OBJECT_ID(N'[dbo].[wh_storage_terms]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[wh_storage_terms] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_wh_storage_terms_id] DEFAULT (NEWSEQUENTIALID()),
  [patron] NVARCHAR(50) NOT NULL,
  [dias_libres] INT NOT NULL CONSTRAINT [DF_wh_storage_terms_dias_libres] DEFAULT (30),
  [activo] BIT NOT NULL CONSTRAINT [DF_wh_storage_terms_activo] DEFAULT (1),
  [nota] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_wh_storage_terms_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [wh_storage_terms_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [wh_storage_terms_patron_key] UNIQUE ([patron]),
  CONSTRAINT [wh_storage_terms_dias_libres_check] CHECK ((([dias_libres] >= 1) AND ([dias_libres] <= 365)))
);
END
GO

-- public.wh_unloading_rates | ~5 filas
IF OBJECT_ID(N'[dbo].[wh_unloading_rates]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[wh_unloading_rates] (
  [id] INT NOT NULL CONSTRAINT [DF_wh_unloading_rates_id] DEFAULT (NEXT VALUE FOR [dbo].[wh_unloading_rates_id_seq]),
  [client_group] NVARCHAR(50) NOT NULL,
  [rate_usd] DECIMAL(38,10) NOT NULL,
  [effective_from] DATE NOT NULL CONSTRAINT [DF_wh_unloading_rates_effective_from] DEFAULT ('2026-01-01'),
  [notes] NVARCHAR(MAX) NULL,
  [container_type] NVARCHAR(50) NOT NULL CONSTRAINT [DF_wh_unloading_rates_container_type] DEFAULT (N'ALL'),
  CONSTRAINT [wh_unloading_rates_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.wh_warehouse_costs | ~5 filas
IF OBJECT_ID(N'[dbo].[wh_warehouse_costs]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[wh_warehouse_costs] (
  [id] INT NOT NULL CONSTRAINT [DF_wh_warehouse_costs_id] DEFAULT (NEXT VALUE FOR [dbo].[wh_warehouse_costs_id_seq]),
  [month] DATE NOT NULL,
  [warehouse] NVARCHAR(50) NOT NULL,
  [cost_type] NVARCHAR(50) NOT NULL,
  [amount] DECIMAL(38,10) NOT NULL,
  [headcount] INT NULL,
  [notes] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_wh_warehouse_costs_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [wh_warehouse_costs_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [wh_warehouse_costs_month_warehouse_cost_type_key] UNIQUE ([month], [warehouse], [cost_type]),
  CONSTRAINT [wh_warehouse_costs_warehouse_check] CHECK (([warehouse]  IN (N'IMPORT', N'EXPORT', N'SHARED')))
);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'bodega_tenants_uq' AND object_id = OBJECT_ID(N'[dbo].[bodega_tenants]'))
CREATE UNIQUE INDEX [bodega_tenants_uq] ON [dbo].[bodega_tenants] ([nombre], [campo]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_cl_alerts_due' AND object_id = OBJECT_ID(N'[dbo].[cl_alerts]'))
CREATE INDEX [idx_cl_alerts_due] ON [dbo].[cl_alerts] ([due_at]) WHERE (([status] = N'unread') AND ([due_at] IS NOT NULL));
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_cl_alerts_recipient' AND object_id = OBJECT_ID(N'[dbo].[cl_alerts]'))
CREATE INDEX [idx_cl_alerts_recipient] ON [dbo].[cl_alerts] ([recipient_user_id], [created_at] DESC) WHERE ([status] = N'unread');
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_cl_alerts_warehouse_unread' AND object_id = OBJECT_ID(N'[dbo].[cl_alerts]'))
CREATE INDEX [idx_cl_alerts_warehouse_unread] ON [dbo].[cl_alerts] ([warehouse_id], [created_at] DESC) WHERE ([status] = N'unread');
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_cl_audit_actor' AND object_id = OBJECT_ID(N'[dbo].[cl_audit_log]'))
CREATE INDEX [idx_cl_audit_actor] ON [dbo].[cl_audit_log] ([performed_by], [performed_at] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_cl_audit_target' AND object_id = OBJECT_ID(N'[dbo].[cl_audit_log]'))
CREATE INDEX [idx_cl_audit_target] ON [dbo].[cl_audit_log] ([target_table], [target_id], [performed_at] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_scan_events_errors' AND object_id = OBJECT_ID(N'[dbo].[cl_scan_events]'))
CREATE INDEX [idx_scan_events_errors] ON [dbo].[cl_scan_events] ([result]) WHERE ([result] <> N'ok');
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_scan_events_loading' AND object_id = OBJECT_ID(N'[dbo].[cl_scan_events]'))
CREATE INDEX [idx_scan_events_loading] ON [dbo].[cl_scan_events] ([loading_task_id], [scanned_at] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_scan_events_picking' AND object_id = OBJECT_ID(N'[dbo].[cl_scan_events]'))
CREATE INDEX [idx_scan_events_picking] ON [dbo].[cl_scan_events] ([picking_task_id], [scanned_at] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_scan_events_staging' AND object_id = OBJECT_ID(N'[dbo].[cl_scan_events]'))
CREATE INDEX [idx_scan_events_staging] ON [dbo].[cl_scan_events] ([staging_task_id], [scanned_at] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_scan_events_user' AND object_id = OBJECT_ID(N'[dbo].[cl_scan_events]'))
CREATE INDEX [idx_scan_events_user] ON [dbo].[cl_scan_events] ([scanned_by], [scanned_at] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_loading_exc_task' AND object_id = OBJECT_ID(N'[dbo].[loading_exceptions]'))
CREATE INDEX [idx_loading_exc_task] ON [dbo].[loading_exceptions] ([loading_task_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_loading_materials_active' AND object_id = OBJECT_ID(N'[dbo].[loading_materials]'))
CREATE INDEX [idx_loading_materials_active] ON [dbo].[loading_materials] ([warehouse_id], [category], [sort_order]) WHERE ([active] = 1);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_loading_task_materials_task' AND object_id = OBJECT_ID(N'[dbo].[loading_task_materials]'))
CREATE INDEX [idx_loading_task_materials_task] ON [dbo].[loading_task_materials] ([loading_task_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_loading_tasks_assigned' AND object_id = OBJECT_ID(N'[dbo].[loading_tasks]'))
CREATE INDEX [idx_loading_tasks_assigned] ON [dbo].[loading_tasks] ([assigned_to]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_loading_tasks_status' AND object_id = OBJECT_ID(N'[dbo].[loading_tasks]'))
CREATE INDEX [idx_loading_tasks_status] ON [dbo].[loading_tasks] ([status]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_manifest_items_barcode' AND object_id = OBJECT_ID(N'[dbo].[manifest_items]'))
CREATE INDEX [idx_manifest_items_barcode] ON [dbo].[manifest_items] ([barcode]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_manifest_items_location' AND object_id = OBJECT_ID(N'[dbo].[manifest_items]'))
CREATE INDEX [idx_manifest_items_location] ON [dbo].[manifest_items] ([location]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_manifest_items_pick_task' AND object_id = OBJECT_ID(N'[dbo].[manifest_items]'))
CREATE INDEX [idx_manifest_items_pick_task] ON [dbo].[manifest_items] ([assigned_picking_task_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_manifest_items_priority' AND object_id = OBJECT_ID(N'[dbo].[manifest_items]'))
CREATE INDEX [idx_manifest_items_priority] ON [dbo].[manifest_items] ([manifest_source_id], [loading_priority]) WHERE ([loading_priority] IS NOT NULL);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_manifest_items_shipper' AND object_id = OBJECT_ID(N'[dbo].[manifest_items]'))
CREATE INDEX [idx_manifest_items_shipper] ON [dbo].[manifest_items] ([shipper_name]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_manifest_items_source' AND object_id = OBJECT_ID(N'[dbo].[manifest_items]'))
CREATE INDEX [idx_manifest_items_source] ON [dbo].[manifest_items] ([manifest_source_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_manifest_items_wr' AND object_id = OBJECT_ID(N'[dbo].[manifest_items]'))
CREATE INDEX [idx_manifest_items_wr] ON [dbo].[manifest_items] ([wr_number]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_manifest_items_wr_piece' AND object_id = OBJECT_ID(N'[dbo].[manifest_items]'))
CREATE INDEX [idx_manifest_items_wr_piece] ON [dbo].[manifest_items] ([wr_number], [piece_index]) WHERE ([wr_number] IS NOT NULL);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_manifest_sources_external' AND object_id = OBJECT_ID(N'[dbo].[manifest_sources]'))
CREATE INDEX [idx_manifest_sources_external] ON [dbo].[manifest_sources] ([external_number]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_manifest_sources_status' AND object_id = OBJECT_ID(N'[dbo].[manifest_sources]'))
CREATE INDEX [idx_manifest_sources_status] ON [dbo].[manifest_sources] ([workflow_status]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_manifest_sources_warehouse' AND object_id = OBJECT_ID(N'[dbo].[manifest_sources]'))
CREATE INDEX [idx_manifest_sources_warehouse] ON [dbo].[manifest_sources] ([warehouse_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_picking_exc_task' AND object_id = OBJECT_ID(N'[dbo].[picking_exceptions]'))
CREATE INDEX [idx_picking_exc_task] ON [dbo].[picking_exceptions] ([picking_task_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_picking_tasks_assigned' AND object_id = OBJECT_ID(N'[dbo].[picking_tasks]'))
CREATE INDEX [idx_picking_tasks_assigned] ON [dbo].[picking_tasks] ([assigned_to]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_picking_tasks_source' AND object_id = OBJECT_ID(N'[dbo].[picking_tasks]'))
CREATE INDEX [idx_picking_tasks_source] ON [dbo].[picking_tasks] ([manifest_source_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_picking_tasks_status' AND object_id = OBJECT_ID(N'[dbo].[picking_tasks]'))
CREATE INDEX [idx_picking_tasks_status] ON [dbo].[picking_tasks] ([status]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_staging_tasks_assigned' AND object_id = OBJECT_ID(N'[dbo].[staging_check_tasks]'))
CREATE INDEX [idx_staging_tasks_assigned] ON [dbo].[staging_check_tasks] ([assigned_to]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_staging_tasks_status' AND object_id = OBJECT_ID(N'[dbo].[staging_check_tasks]'))
CREATE INDEX [idx_staging_tasks_status] ON [dbo].[staging_check_tasks] ([status]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_staging_exc_task' AND object_id = OBJECT_ID(N'[dbo].[staging_exceptions]'))
CREATE INDEX [idx_staging_exc_task] ON [dbo].[staging_exceptions] ([staging_task_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_unplanned_task' AND object_id = OBJECT_ID(N'[dbo].[unplanned_additions]'))
CREATE INDEX [idx_unplanned_task] ON [dbo].[unplanned_additions] ([loading_task_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_warehouse_containers_created_at' AND object_id = OBJECT_ID(N'[dbo].[warehouse_containers]'))
CREATE INDEX [idx_warehouse_containers_created_at] ON [dbo].[warehouse_containers] ([created_at] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_warehouse_containers_created_by' AND object_id = OBJECT_ID(N'[dbo].[warehouse_containers]'))
CREATE INDEX [idx_warehouse_containers_created_by] ON [dbo].[warehouse_containers] ([created_by]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_warehouse_containers_created_by_user_id' AND object_id = OBJECT_ID(N'[dbo].[warehouse_containers]'))
CREATE INDEX [idx_warehouse_containers_created_by_user_id] ON [dbo].[warehouse_containers] ([created_by_user_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_warehouse_containers_office' AND object_id = OBJECT_ID(N'[dbo].[warehouse_containers]'))
CREATE INDEX [idx_warehouse_containers_office] ON [dbo].[warehouse_containers] ([office]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_warehouse_containers_owner_id' AND object_id = OBJECT_ID(N'[dbo].[warehouse_containers]'))
CREATE INDEX [idx_warehouse_containers_owner_id] ON [dbo].[warehouse_containers] ([owner_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_warehouse_containers_week' AND object_id = OBJECT_ID(N'[dbo].[warehouse_containers]'))
CREATE INDEX [idx_warehouse_containers_week] ON [dbo].[warehouse_containers] ([week]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_warehouse_users_user' AND object_id = OBJECT_ID(N'[dbo].[warehouse_users]'))
CREATE INDEX [idx_warehouse_users_user] ON [dbo].[warehouse_users] ([user_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_warehouse_users_warehouse' AND object_id = OBJECT_ID(N'[dbo].[warehouse_users]'))
CREATE INDEX [idx_warehouse_users_warehouse] ON [dbo].[warehouse_users] ([warehouse_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_wcni_entry' AND object_id = OBJECT_ID(N'[dbo].[wh_carga_no_identificada]'))
CREATE INDEX [idx_wcni_entry] ON [dbo].[wh_carga_no_identificada] ([entry_date] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_wcni_estado' AND object_id = OBJECT_ID(N'[dbo].[wh_carga_no_identificada]'))
CREATE INDEX [idx_wcni_estado] ON [dbo].[wh_carga_no_identificada] ([estado]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ix_wh_containers_loader' AND object_id = OBJECT_ID(N'[dbo].[wh_containers]'))
CREATE INDEX [ix_wh_containers_loader] ON [dbo].[wh_containers] ([loader]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ix_wh_containers_week' AND object_id = OBJECT_ID(N'[dbo].[wh_containers]'))
CREATE INDEX [ix_wh_containers_week] ON [dbo].[wh_containers] ([board_year], [week_no], [status]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_wh_ext_etd' AND object_id = OBJECT_ID(N'[dbo].[wh_containers_external]'))
CREATE INDEX [idx_wh_ext_etd] ON [dbo].[wh_containers_external] ([etd]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'wh_notices_refresh_idx' AND object_id = OBJECT_ID(N'[dbo].[wh_notices]'))
CREATE INDEX [wh_notices_refresh_idx] ON [dbo].[wh_notices] ([attachments_refreshed_at]) WHERE ([status]  IN (N'DRAFT', N'READY', N'ERROR'));
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'wh_notices_status_idx' AND object_id = OBJECT_ID(N'[dbo].[wh_notices]'))
CREATE INDEX [wh_notices_status_idx] ON [dbo].[wh_notices] ([status], [created_at] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_wh_movement_items_movement' AND object_id = OBJECT_ID(N'[dbo].[wh_report_movement_items]'))
CREATE INDEX [idx_wh_movement_items_movement] ON [dbo].[wh_report_movement_items] ([movement_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_wh_report_movement_items_product_id' AND object_id = OBJECT_ID(N'[dbo].[wh_report_movement_items]'))
CREATE INDEX [idx_wh_report_movement_items_product_id] ON [dbo].[wh_report_movement_items] ([product_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_wh_movements_client' AND object_id = OBJECT_ID(N'[dbo].[wh_report_movements]'))
CREATE INDEX [idx_wh_movements_client] ON [dbo].[wh_report_movements] ([client_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_wh_movements_date' AND object_id = OBJECT_ID(N'[dbo].[wh_report_movements]'))
CREATE INDEX [idx_wh_movements_date] ON [dbo].[wh_report_movements] ([date]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_wh_movements_magaya_cr' AND object_id = OBJECT_ID(N'[dbo].[wh_report_movements]'))
CREATE UNIQUE INDEX [idx_wh_movements_magaya_cr] ON [dbo].[wh_report_movements] ([magaya_cr_id]) WHERE ([magaya_cr_id] IS NOT NULL) AND [magaya_cr_id] IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_wh_movements_magaya_wr' AND object_id = OBJECT_ID(N'[dbo].[wh_report_movements]'))
CREATE UNIQUE INDEX [idx_wh_movements_magaya_wr] ON [dbo].[wh_report_movements] ([magaya_wr_id]) WHERE ([magaya_wr_id] IS NOT NULL) AND [magaya_wr_id] IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_wh_report_product_mappings_product_id' AND object_id = OBJECT_ID(N'[dbo].[wh_report_product_mappings]'))
CREATE INDEX [idx_wh_report_product_mappings_product_id] ON [dbo].[wh_report_product_mappings] ([product_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_wh_products_client' AND object_id = OBJECT_ID(N'[dbo].[wh_report_products]'))
CREATE INDEX [idx_wh_products_client] ON [dbo].[wh_report_products] ([client_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_sync_log_status' AND object_id = OBJECT_ID(N'[dbo].[wh_report_sync_log]'))
CREATE INDEX [idx_sync_log_status] ON [dbo].[wh_report_sync_log] ([status]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_wh_report_sync_log_client_id' AND object_id = OBJECT_ID(N'[dbo].[wh_report_sync_log]'))
CREATE INDEX [idx_wh_report_sync_log_client_id] ON [dbo].[wh_report_sync_log] ([client_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'ux_unloading_rates' AND object_id = OBJECT_ID(N'[dbo].[wh_unloading_rates]'))
CREATE UNIQUE INDEX [ux_unloading_rates] ON [dbo].[wh_unloading_rates] ([client_group], [container_type], [effective_from]);
GO
