-- 050 · Consolidados: tablas e índices
-- Generado por migration/tools/to_tsql.mjs desde el catálogo de Supabase (2026-09-29). No editar a mano:
-- cambiar el generador y volver a correrlo. Idempotente: se puede ejecutar varias veces.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- public.consolidado_aereo_prefs | ~1 filas
IF OBJECT_ID(N'[dbo].[consolidado_aereo_prefs]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[consolidado_aereo_prefs] (
  [cliente_key] NVARCHAR(100) NOT NULL,
  [es_aereo] BIT NOT NULL CONSTRAINT [DF_consolidado_aereo_prefs_es_aereo] DEFAULT (1),
  [updated_by] UNIQUEIDENTIFIER NULL,
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_consolidado_aereo_prefs_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [consolidado_aereo_prefs_pkey] PRIMARY KEY ([cliente_key])
);
END
GO

-- public.consolidado_agente_exclusiones | ~10 filas
IF OBJECT_ID(N'[dbo].[consolidado_agente_exclusiones]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[consolidado_agente_exclusiones] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_consolidado_agente_exclusiones_id] DEFAULT (NEWSEQUENTIALID()),
  [agente] NVARCHAR(100) NOT NULL,
  [destino] NVARCHAR(50) NOT NULL,
  [consolidado_id] UNIQUEIDENTIFIER NULL,
  [motivo] NVARCHAR(MAX) NULL,
  [creado_por] UNIQUEIDENTIFIER NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_consolidado_agente_exclusiones_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [consolidado_agente_exclusiones_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.consolidado_agentes_destino | ~5 filas
IF OBJECT_ID(N'[dbo].[consolidado_agentes_destino]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[consolidado_agentes_destino] (
  [agente] NVARCHAR(100) NOT NULL,
  [pais] NVARCHAR(MAX) NOT NULL,
  [incluir] BIT NOT NULL CONSTRAINT [DF_consolidado_agentes_destino_incluir] DEFAULT (1),
  CONSTRAINT [consolidado_agentes_destino_pkey] PRIMARY KEY ([agente])
);
END
GO

-- public.consolidado_agrupacion_memoria | ~7 filas
IF OBJECT_ID(N'[dbo].[consolidado_agrupacion_memoria]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[consolidado_agrupacion_memoria] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_consolidado_agrupacion_memoria_id] DEFAULT (NEWSEQUENTIALID()),
  [grupo_nombre] NVARCHAR(MAX) NOT NULL,
  [miembro] NVARCHAR(100) NOT NULL,
  [creado_por] UNIQUEIDENTIFIER NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_consolidado_agrupacion_memoria_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [consolidado_agrupacion_memoria_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [consolidado_agrupacion_memoria_miembro_key] UNIQUE ([miembro])
);
END
GO

-- public.consolidado_avisos | ~494 filas
IF OBJECT_ID(N'[dbo].[consolidado_avisos]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[consolidado_avisos] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_consolidado_avisos_id] DEFAULT (NEWSEQUENTIALID()),
  [consolidado_id] UNIQUEIDENTIFIER NOT NULL,
  [cliente_key] NVARCHAR(255) NOT NULL,
  [es_agente] BIT NOT NULL CONSTRAINT [DF_consolidado_avisos_es_agente] DEFAULT (0),
  [cs_email] NVARCHAR(100) NULL,
  [subject] NVARCHAR(MAX) NULL,
  [body_html] NVARCHAR(MAX) NULL,
  [recipients] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_consolidado_avisos_recipients] DEFAULT (N'{"cc": [], "to": []}'),
  [wr_numbers] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_consolidado_avisos_wr_numbers] DEFAULT (N'[]'),
  [total_piezas] INT NULL,
  [total_peso_lb] DECIMAL(38,10) NULL,
  [total_cbm] DECIMAL(38,10) NULL,
  [status] NVARCHAR(50) NOT NULL CONSTRAINT [DF_consolidado_avisos_status] DEFAULT (N'DRAFT'),
  [sent_at] DATETIMEOFFSET NULL,
  [sent_by] UNIQUEIDENTIFIER NULL,
  [error] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_consolidado_avisos_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_consolidado_avisos_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  [es_fcl] BIT NOT NULL CONSTRAINT [DF_consolidado_avisos_es_fcl] DEFAULT (0),
  [es_aereo] BIT NOT NULL CONSTRAINT [DF_consolidado_avisos_es_aereo] DEFAULT (0),
  CONSTRAINT [consolidado_avisos_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [consolidado_avisos_consolidado_id_cliente_key_key] UNIQUE ([consolidado_id], [cliente_key]),
  CONSTRAINT [consolidado_avisos_status_check] CHECK (([status]  IN (N'DRAFT', N'SENT', N'SKIPPED', N'ERROR'))),
  CONSTRAINT [CK_consolidado_avisos_recipients_json] CHECK (ISJSON([recipients]) = 1),
  CONSTRAINT [CK_consolidado_avisos_wr_numbers_json] CHECK (ISJSON([wr_numbers]) = 1)
);
END
GO

-- public.consolidado_capacidades | ~3 filas
IF OBJECT_ID(N'[dbo].[consolidado_capacidades]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[consolidado_capacidades] (
  [tipo] NVARCHAR(50) NOT NULL,
  [max_cbm] DECIMAL(38,10) NOT NULL,
  [objetivo_cbm] DECIMAL(38,10) NULL,
  CONSTRAINT [consolidado_capacidades_pkey] PRIMARY KEY ([tipo])
);
END
GO

-- public.consolidado_contenedores | ~52 filas
IF OBJECT_ID(N'[dbo].[consolidado_contenedores]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[consolidado_contenedores] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_consolidado_contenedores_id] DEFAULT (NEWSEQUENTIALID()),
  [consolidado_id] UNIQUEIDENTIFIER NOT NULL,
  [tipo] NVARCHAR(MAX) NOT NULL,
  [posicion] INT NOT NULL CONSTRAINT [DF_consolidado_contenedores_posicion] DEFAULT (1),
  [numero] NVARCHAR(MAX) NULL,
  [sello] NVARCHAR(MAX) NULL,
  [notas] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_consolidado_contenedores_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [consolidado_contenedores_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [consolidado_contenedores_tipo_check] CHECK (([tipo]  IN (N'40HC', N'40NOR', N'20ST')))
);
END
GO

-- public.consolidado_email_bitacora | ~5,190 filas
IF OBJECT_ID(N'[dbo].[consolidado_email_bitacora]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[consolidado_email_bitacora] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_consolidado_email_bitacora_id] DEFAULT (NEWSEQUENTIALID()),
  [internet_message_id] NVARCHAR(450) NOT NULL,
  [asunto] NVARCHAR(MAX) NULL,
  [remitente] NVARCHAR(MAX) NULL,
  [recibido_at] DATETIMEOFFSET NULL,
  [consolidado_id] UNIQUEIDENTIFIER NULL,
  [resultado] NVARCHAR(MAX) NULL,
  [procesado_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_consolidado_email_bitacora_procesado_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [consolidado_email_bitacora_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [consolidado_email_bitacora_internet_message_id_key] UNIQUE ([internet_message_id])
);
END
GO

-- public.consolidado_fcl_prefs | ~1 filas
IF OBJECT_ID(N'[dbo].[consolidado_fcl_prefs]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[consolidado_fcl_prefs] (
  [cliente_key] NVARCHAR(100) NOT NULL,
  [es_fcl] BIT NOT NULL CONSTRAINT [DF_consolidado_fcl_prefs_es_fcl] DEFAULT (1),
  [updated_by] UNIQUEIDENTIFIER NULL,
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_consolidado_fcl_prefs_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [consolidado_fcl_prefs_pkey] PRIMARY KEY ([cliente_key])
);
END
GO

-- public.consolidado_grupos | ~46 filas
IF OBJECT_ID(N'[dbo].[consolidado_grupos]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[consolidado_grupos] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_consolidado_grupos_id] DEFAULT (NEWSEQUENTIALID()),
  [consolidado_id] UNIQUEIDENTIFIER NOT NULL,
  [nombre] NVARCHAR(MAX) NOT NULL,
  [notas] NVARCHAR(MAX) NULL,
  [creado_por] UNIQUEIDENTIFIER NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_consolidado_grupos_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [consolidado_grupos_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.consolidado_linea_hazmat | ~13 filas
IF OBJECT_ID(N'[dbo].[consolidado_linea_hazmat]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[consolidado_linea_hazmat] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_consolidado_linea_hazmat_id] DEFAULT (NEWSEQUENTIALID()),
  [linea_id] UNIQUEIDENTIFIER NOT NULL,
  [consolidado_id] UNIQUEIDENTIFIER NOT NULL,
  [un_number] NVARCHAR(MAX) NULL,
  [imo_class] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_consolidado_linea_hazmat_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [doc_recibido] BIT NOT NULL CONSTRAINT [DF_consolidado_linea_hazmat_doc_recibido] DEFAULT (0),
  CONSTRAINT [consolidado_linea_hazmat_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.consolidado_linea_movimientos | ~1,244 filas
IF OBJECT_ID(N'[dbo].[consolidado_linea_movimientos]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[consolidado_linea_movimientos] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_consolidado_linea_movimientos_id] DEFAULT (NEWSEQUENTIALID()),
  [linea_id] UNIQUEIDENTIFIER NOT NULL,
  [consolidado_id] UNIQUEIDENTIFIER NOT NULL,
  [wr_number] NVARCHAR(MAX) NULL,
  [accion] NVARCHAR(MAX) NOT NULL,
  [contenedor_id] UNIQUEIDENTIFIER NULL,
  [contenedor] NVARCHAR(MAX) NULL,
  [motivo] NVARCHAR(MAX) NULL,
  [hecho_por] UNIQUEIDENTIFIER NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_consolidado_linea_movimientos_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [consolidado_linea_movimientos_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [consolidado_linea_movimientos_accion_check] CHECK (([accion]  IN (N'CARGA', N'SACA', N'CONFIRMA', N'DESCONFIRMA', N'NO_SE_CARGA', N'SALIO')))
);
END
GO

-- public.consolidado_linea_piezas | ~323 filas
IF OBJECT_ID(N'[dbo].[consolidado_linea_piezas]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[consolidado_linea_piezas] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_consolidado_linea_piezas_id] DEFAULT (NEWSEQUENTIALID()),
  [linea_id] UNIQUEIDENTIFIER NOT NULL,
  [consolidado_id] UNIQUEIDENTIFIER NOT NULL,
  [wr_number] NVARCHAR(50) NOT NULL,
  [wr_item_id] UNIQUEIDENTIFIER NULL,
  [whr_item_id] NVARCHAR(50) NOT NULL,
  [piezas] INT NOT NULL CONSTRAINT [DF_consolidado_linea_piezas_piezas] DEFAULT (1),
  [peso_lb] DECIMAL(38,10) NULL,
  [vol_cft] DECIMAL(38,10) NULL,
  [location_code] NVARCHAR(MAX) NULL,
  [package_name] NVARCHAR(MAX) NULL,
  [creado_por] UNIQUEIDENTIFIER NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_consolidado_linea_piezas_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [consolidado_linea_piezas_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [consolidado_linea_piezas_piezas_check] CHECK (([piezas] > 0))
);
END
GO

-- public.consolidado_lineas | ~8,116 filas
IF OBJECT_ID(N'[dbo].[consolidado_lineas]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[consolidado_lineas] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_consolidado_lineas_id] DEFAULT (NEWSEQUENTIALID()),
  [consolidado_id] UNIQUEIDENTIFIER NOT NULL,
  [wr_number] NVARCHAR(100) NOT NULL,
  [consignee] NVARCHAR(MAX) NULL,
  [shipper] NVARCHAR(MAX) NULL,
  [client_id] UNIQUEIDENTIFIER NULL,
  [cs_email] NVARCHAR(100) NULL,
  [piezas] INT NULL,
  [peso_lb] DECIMAL(38,10) NULL,
  [volumen_cft] DECIMAL(38,10) NULL,
  [estado] NVARCHAR(50) NOT NULL CONSTRAINT [DF_consolidado_lineas_estado] DEFAULT (N'DISPONIBLE'),
  [hazmat] BIT NOT NULL CONSTRAINT [DF_consolidado_lineas_hazmat] DEFAULT (0),
  [factura_ok] BIT NOT NULL CONSTRAINT [DF_consolidado_lineas_factura_ok] DEFAULT (0),
  [tarifa_venta] DECIMAL(38,10) NULL,
  [tarifa_moneda] NVARCHAR(MAX) NULL CONSTRAINT [DF_consolidado_lineas_tarifa_moneda] DEFAULT (N'USD'),
  [instruido_at] DATETIMEOFFSET NULL,
  [instruido_por] UNIQUEIDENTIFIER NULL,
  [instruccion_nota] NVARCHAR(MAX) NULL,
  [contenedor] NVARCHAR(MAX) NULL,
  [sello] NVARCHAR(MAX) NULL,
  [hbl] NVARCHAR(MAX) NULL,
  [piezas_embarcadas] INT NULL,
  [rodado_desde] UNIQUEIDENTIFIER NULL,
  [notas] NVARCHAR(MAX) NULL,
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_consolidado_lineas_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  [agente_destino] NVARCHAR(MAX) NULL,
  [origen_oficina] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_consolidado_lineas_origen_oficina] DEFAULT (N'EC'),
  [grupo_id] UNIQUEIDENTIFIER NULL,
  [contenedor_id] UNIQUEIDENTIFIER NULL,
  [un_number] NVARCHAR(MAX) NULL,
  [imo_class] NVARCHAR(MAX) NULL,
  [apilable] BIT NOT NULL CONSTRAINT [DF_consolidado_lineas_apilable] DEFAULT (1),
  [regimen] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_consolidado_lineas_regimen] DEFAULT (N'NORMAL'),
  [doc_7512] NVARCHAR(MAX) NULL,
  [doc_7512_at] DATETIMEOFFSET NULL,
  [nota_bodega] NVARCHAR(MAX) NULL,
  [regimen_fuente] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_consolidado_lineas_regimen_fuente] DEFAULT (N'AUTO'),
  [regimen_numero] NVARCHAR(MAX) NULL,
  [regimen_fecha] DATE NULL,
  [shipment_id] UNIQUEIDENTIFIER NULL,
  [cfs_dias_extra] INT NOT NULL CONSTRAINT [DF_consolidado_lineas_cfs_dias_extra] DEFAULT (0),
  [cfs_extra_motivo] NVARCHAR(MAX) NULL,
  [cfs_extra_por] UNIQUEIDENTIFIER NULL,
  [cfs_extra_at] DATETIMEOFFSET NULL,
  [piezas_recibo] INT NULL,
  [es_parcial] BIT NOT NULL CONSTRAINT [DF_consolidado_lineas_es_parcial] DEFAULT (0),
  [cargado_confirmado_at] DATETIMEOFFSET NULL,
  [cargado_confirmado_por] UNIQUEIDENTIFIER NULL,
  [hazmat_fuente] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_consolidado_lineas_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [por_llegar] BIT NOT NULL CONSTRAINT [DF_consolidado_lineas_por_llegar] DEFAULT (0),
  [llega_eta] DATE NULL,
  CONSTRAINT [consolidado_lineas_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [consolidado_lineas_cfs_extra_chk] CHECK ((([cfs_dias_extra] >= 0) AND ([cfs_dias_extra] <= 180))),
  CONSTRAINT [consolidado_lineas_estado_check] CHECK (([estado]  IN (N'DISPONIBLE', N'AVISADO', N'INSTRUIDO', N'NO_EMBARCA', N'APROBADO', N'EMBARCADO', N'RODADO', N'EXCLUIDO', N'SALIO_BODEGA'))),
  CONSTRAINT [consolidado_lineas_hazmat_fuente_check] CHECK (([hazmat_fuente]  IN (N'AUTO', N'MANUAL'))),
  CONSTRAINT [consolidado_lineas_origen_oficina_check] CHECK (([origen_oficina]  IN (N'EC', N'MIAMI'))),
  CONSTRAINT [consolidado_lineas_regimen_check] CHECK (([regimen]  IN (N'NORMAL', N'BONDED', N'CFS'))),
  CONSTRAINT [consolidado_lineas_regimen_fuente_chk] CHECK (([regimen_fuente]  IN (N'AUTO', N'MANUAL')))
);
END
GO

-- public.consolidado_servicios | ~5 filas
IF OBJECT_ID(N'[dbo].[consolidado_servicios]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[consolidado_servicios] (
  [codigo] NVARCHAR(50) NOT NULL,
  [nombre] NVARCHAR(MAX) NOT NULL,
  [origen] NVARCHAR(MAX) NOT NULL,
  [destino] NVARCHAR(MAX) NOT NULL,
  [modo] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_consolidado_servicios_modo] DEFAULT (N'MARITIMO'),
  [coordinadora_email] NVARCHAR(MAX) NULL,
  [oficina] NVARCHAR(MAX) NULL,
  [cadencia] NVARCHAR(MAX) NULL CONSTRAINT [DF_consolidado_servicios_cadencia] DEFAULT (N'SEMANAL'),
  [fuente_lineas] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_consolidado_servicios_fuente_lineas] DEFAULT (N'CORREO'),
  [metrica] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_consolidado_servicios_metrica] DEFAULT (N'M3'),
  [timezone_origen] NVARCHAR(MAX) NULL CONSTRAINT [DF_consolidado_servicios_timezone_origen] DEFAULT (N'America/New_York'),
  [patrones_asunto] NVARCHAR(MAX) NULL CONSTRAINT [DF_consolidado_servicios_patrones_asunto] DEFAULT (N'[]'),
  [activo] BIT NOT NULL CONSTRAINT [DF_consolidado_servicios_activo] DEFAULT (1),
  [notas] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_consolidado_servicios_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [consolidado_servicios_pkey] PRIMARY KEY ([codigo]),
  CONSTRAINT [consolidado_servicios_fuente_lineas_check] CHECK (([fuente_lineas]  IN (N'MAGAYA_WR', N'CORREO', N'MANUAL'))),
  CONSTRAINT [CK_consolidado_servicios_patrones_asunto_json] CHECK (ISJSON([patrones_asunto]) = 1)
);
END
GO

-- public.consolidados | ~20 filas
IF OBJECT_ID(N'[dbo].[consolidados]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[consolidados] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_consolidados_id] DEFAULT (NEWSEQUENTIALID()),
  [modo] NVARCHAR(50) NOT NULL CONSTRAINT [DF_consolidados_modo] DEFAULT (N'MARITIMO'),
  [anio] INT NOT NULL,
  [semana] INT NOT NULL,
  [booking] NVARCHAR(50) NULL,
  [transportista] NVARCHAR(MAX) NULL,
  [motonave] NVARCHAR(MAX) NULL,
  [viaje] NVARCHAR(MAX) NULL,
  [origen] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_consolidados_origen] DEFAULT (N'MIAMI'),
  [destino] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_consolidados_destino] DEFAULT (N'GUAYAQUIL'),
  [etd] DATE NULL,
  [eta] DATE NULL,
  [cutoff_regular] DATETIMEOFFSET NULL,
  [cutoff_hazmat] DATETIMEOFFSET NULL,
  [cutoff_instrucciones] DATETIMEOFFSET NULL,
  [estado] NVARCHAR(50) NOT NULL CONSTRAINT [DF_consolidados_estado] DEFAULT (N'ABIERTO'),
  [notas] NVARCHAR(MAX) NULL,
  [creado_por] UNIQUEIDENTIFIER NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_consolidados_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [cerrado_at] DATETIMEOFFSET NULL,
  [servicio] NVARCHAR(50) NULL,
  [avisos_firma] NVARCHAR(MAX) NULL,
  [avisos_regen_pedido_at] DATETIMEOFFSET NULL,
  CONSTRAINT [consolidados_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [consolidados_estado_check] CHECK (([estado]  IN (N'ABIERTO', N'CERRADO', N'ZARPADO', N'CANCELADO'))),
  CONSTRAINT [consolidados_modo_check] CHECK (([modo]  IN (N'MARITIMO', N'AEREO')))
);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'consolidado_agente_excl_semana_uq' AND object_id = OBJECT_ID(N'[dbo].[consolidado_agente_exclusiones]'))
CREATE UNIQUE INDEX [consolidado_agente_excl_semana_uq] ON [dbo].[consolidado_agente_exclusiones] ([agente], [destino], [consolidado_id]) WHERE ([consolidado_id] IS NOT NULL) AND [consolidado_id] IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'consolidado_agente_excl_siempre_uq' AND object_id = OBJECT_ID(N'[dbo].[consolidado_agente_exclusiones]'))
CREATE UNIQUE INDEX [consolidado_agente_excl_siempre_uq] ON [dbo].[consolidado_agente_exclusiones] ([agente], [destino]) WHERE ([consolidado_id] IS NULL);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_consolidado_avisos_cs' AND object_id = OBJECT_ID(N'[dbo].[consolidado_avisos]'))
CREATE INDEX [idx_consolidado_avisos_cs] ON [dbo].[consolidado_avisos] ([consolidado_id], [cs_email], [status]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_clh_consolidado' AND object_id = OBJECT_ID(N'[dbo].[consolidado_linea_hazmat]'))
CREATE INDEX [idx_clh_consolidado] ON [dbo].[consolidado_linea_hazmat] ([consolidado_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_clh_linea' AND object_id = OBJECT_ID(N'[dbo].[consolidado_linea_hazmat]'))
CREATE INDEX [idx_clh_linea] ON [dbo].[consolidado_linea_hazmat] ([linea_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'consolidado_linea_mov_cons_idx' AND object_id = OBJECT_ID(N'[dbo].[consolidado_linea_movimientos]'))
CREATE INDEX [consolidado_linea_mov_cons_idx] ON [dbo].[consolidado_linea_movimientos] ([consolidado_id], [created_at] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'consolidado_linea_mov_linea_idx' AND object_id = OBJECT_ID(N'[dbo].[consolidado_linea_movimientos]'))
CREATE INDEX [consolidado_linea_mov_linea_idx] ON [dbo].[consolidado_linea_movimientos] ([linea_id], [created_at] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'consolidado_linea_piezas_linea_idx' AND object_id = OBJECT_ID(N'[dbo].[consolidado_linea_piezas]'))
CREATE INDEX [consolidado_linea_piezas_linea_idx] ON [dbo].[consolidado_linea_piezas] ([linea_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'consolidado_linea_piezas_uq' AND object_id = OBJECT_ID(N'[dbo].[consolidado_linea_piezas]'))
CREATE UNIQUE INDEX [consolidado_linea_piezas_uq] ON [dbo].[consolidado_linea_piezas] ([linea_id], [wr_item_id]) WHERE ([wr_item_id] IS NOT NULL) AND [wr_item_id] IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'consolidado_linea_piezas_wr_idx' AND object_id = OBJECT_ID(N'[dbo].[consolidado_linea_piezas]'))
CREATE INDEX [consolidado_linea_piezas_wr_idx] ON [dbo].[consolidado_linea_piezas] ([wr_number], [whr_item_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'consolidado_lineas_cons_idx' AND object_id = OBJECT_ID(N'[dbo].[consolidado_lineas]'))
CREATE INDEX [consolidado_lineas_cons_idx] ON [dbo].[consolidado_lineas] ([consolidado_id], [estado]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'consolidado_lineas_cs_idx' AND object_id = OBJECT_ID(N'[dbo].[consolidado_lineas]'))
CREATE INDEX [consolidado_lineas_cs_idx] ON [dbo].[consolidado_lineas] ([cs_email], [estado]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'consolidado_lineas_shipment_idx' AND object_id = OBJECT_ID(N'[dbo].[consolidado_lineas]'))
CREATE INDEX [consolidado_lineas_shipment_idx] ON [dbo].[consolidado_lineas] ([shipment_id]) WHERE ([shipment_id] IS NOT NULL);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'consolidado_lineas_wr_cont_uq' AND object_id = OBJECT_ID(N'[dbo].[consolidado_lineas]'))
CREATE UNIQUE INDEX [consolidado_lineas_wr_cont_uq] ON [dbo].[consolidado_lineas] ([consolidado_id], [wr_number], [contenedor_id]) WHERE ([contenedor_id] IS NOT NULL) AND [contenedor_id] IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'consolidado_lineas_wr_sin_cont_uq' AND object_id = OBJECT_ID(N'[dbo].[consolidado_lineas]'))
CREATE UNIQUE INDEX [consolidado_lineas_wr_sin_cont_uq] ON [dbo].[consolidado_lineas] ([consolidado_id], [wr_number]) WHERE ([contenedor_id] IS NULL);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'consolidados_estado_idx' AND object_id = OBJECT_ID(N'[dbo].[consolidados]'))
CREATE INDEX [consolidados_estado_idx] ON [dbo].[consolidados] ([estado], [etd] DESC);
GO

IF COL_LENGTH(N'[dbo].[consolidados]', N'booking__nn') IS NULL
ALTER TABLE [dbo].[consolidados] ADD [booking__nn] AS COALESCE([booking], N'') PERSISTED;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'consolidados_semana_uq' AND object_id = OBJECT_ID(N'[dbo].[consolidados]'))
CREATE UNIQUE INDEX [consolidados_semana_uq] ON [dbo].[consolidados] ([modo], [anio], [semana], [booking__nn]);
GO
