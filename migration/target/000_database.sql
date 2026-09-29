-- 000 · Base de datos: collation, esquemas y secuencias
-- Generado por migration/tools/to_tsql.mjs desde el catálogo de Supabase (2026-09-29). No editar a mano:
-- cambiar el generador y volver a correrlo. Idempotente: se puede ejecutar varias veces.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- La collation de la BD solo se fija al crearla. Si no coincide, este script se detiene.
IF CONVERT(sysname, DATABASEPROPERTYEX(DB_NAME(), 'Collation')) <> N'Latin1_General_100_CI_AI_SC_UTF8'
    THROW 50001, N'La collation de la BD no es Latin1_General_100_CI_AI_SC_UTF8. Ver migration/target/README.md (paso 1).', 1;
GO

IF SCHEMA_ID(N'private') IS NULL EXEC(N'CREATE SCHEMA [private]');
GO
IF SCHEMA_ID(N'archive') IS NULL EXEC(N'CREATE SCHEMA [archive]');
GO
IF SCHEMA_ID(N'timeclock') IS NULL EXEC(N'CREATE SCHEMA [timeclock]');
GO

-- Secuencias (reemplazan nextval de Postgres). Tras cargar datos, reiniciar con ALTER SEQUENCE ... RESTART WITH (máx + 1).
IF OBJECT_ID(N'[private].[client_merge_audit_id_seq]', N'SO') IS NULL CREATE SEQUENCE [private].[client_merge_audit_id_seq] AS BIGINT START WITH 1 INCREMENT BY 1;
GO
IF OBJECT_ID(N'[private].[iva_backfill_audit_id_seq]', N'SO') IS NULL CREATE SEQUENCE [private].[iva_backfill_audit_id_seq] AS BIGINT START WITH 1 INCREMENT BY 1;
GO
IF OBJECT_ID(N'[dbo].[ports_master_id_seq]', N'SO') IS NULL CREATE SEQUENCE [dbo].[ports_master_id_seq] AS BIGINT START WITH 1 INCREMENT BY 1;
GO
IF OBJECT_ID(N'[dbo].[ventas_alertas_id_seq]', N'SO') IS NULL CREATE SEQUENCE [dbo].[ventas_alertas_id_seq] AS BIGINT START WITH 1 INCREMENT BY 1;
GO
IF OBJECT_ID(N'[dbo].[warehouse_cogs_manual_id_seq]', N'SO') IS NULL CREATE SEQUENCE [dbo].[warehouse_cogs_manual_id_seq] AS INT START WITH 1 INCREMENT BY 1;
GO
IF OBJECT_ID(N'[dbo].[warehouse_cogs_monthly_id_seq]', N'SO') IS NULL CREATE SEQUENCE [dbo].[warehouse_cogs_monthly_id_seq] AS INT START WITH 1 INCREMENT BY 1;
GO
IF OBJECT_ID(N'[dbo].[wh_container_types_id_seq]', N'SO') IS NULL CREATE SEQUENCE [dbo].[wh_container_types_id_seq] AS INT START WITH 1 INCREMENT BY 1;
GO
IF OBJECT_ID(N'[dbo].[wh_country_map_id_seq]', N'SO') IS NULL CREATE SEQUENCE [dbo].[wh_country_map_id_seq] AS INT START WITH 1 INCREMENT BY 1;
GO
IF OBJECT_ID(N'[dbo].[wh_import_clients_id_seq]', N'SO') IS NULL CREATE SEQUENCE [dbo].[wh_import_clients_id_seq] AS INT START WITH 1 INCREMENT BY 1;
GO
IF OBJECT_ID(N'[dbo].[wh_internal_people_id_seq]', N'SO') IS NULL CREATE SEQUENCE [dbo].[wh_internal_people_id_seq] AS INT START WITH 1 INCREMENT BY 1;
GO
IF OBJECT_ID(N'[dbo].[wh_loading_rates_id_seq]', N'SO') IS NULL CREATE SEQUENCE [dbo].[wh_loading_rates_id_seq] AS INT START WITH 1 INCREMENT BY 1;
GO
IF OBJECT_ID(N'[dbo].[wh_stations_id_seq]', N'SO') IS NULL CREATE SEQUENCE [dbo].[wh_stations_id_seq] AS INT START WITH 1 INCREMENT BY 1;
GO
IF OBJECT_ID(N'[dbo].[wh_unloading_rates_id_seq]', N'SO') IS NULL CREATE SEQUENCE [dbo].[wh_unloading_rates_id_seq] AS INT START WITH 1 INCREMENT BY 1;
GO
IF OBJECT_ID(N'[dbo].[wh_warehouse_costs_id_seq]', N'SO') IS NULL CREATE SEQUENCE [dbo].[wh_warehouse_costs_id_seq] AS INT START WITH 1 INCREMENT BY 1;
GO
IF OBJECT_ID(N'[dbo].[wr_att_backfill_queue_id_seq]', N'SO') IS NULL CREATE SEQUENCE [dbo].[wr_att_backfill_queue_id_seq] AS BIGINT START WITH 1 INCREMENT BY 1;
GO
IF OBJECT_ID(N'[dbo].[wr_backfill_queue_id_seq]', N'SO') IS NULL CREATE SEQUENCE [dbo].[wr_backfill_queue_id_seq] AS INT START WITH 1 INCREMENT BY 1;
GO
