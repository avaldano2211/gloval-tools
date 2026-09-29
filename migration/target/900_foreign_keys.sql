-- 900 · Foreign keys (todas al final para no depender del orden)
-- Generado por migration/tools/to_tsql.mjs desde el catálogo de Supabase (2026-09-29). No editar a mano:
-- cambiar el generador y volver a correrlo. Idempotente: se puede ejecutar varias veces.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID(N'[archive].[magaya_charges_company_id_fkey]', N'F') IS NULL
ALTER TABLE [archive].[magaya_charges] ADD CONSTRAINT [magaya_charges_company_id_fkey] FOREIGN KEY ([company_id]) REFERENCES [dbo].[magaya_companies] ([id]);
GO
IF OBJECT_ID(N'[dbo].[activity_logs_time_entry_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[activity_logs] ADD CONSTRAINT [activity_logs_time_entry_id_fkey] FOREIGN KEY ([time_entry_id]) REFERENCES [dbo].[time_entries] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[agent_office_mapping_created_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[agent_office_mapping] ADD CONSTRAINT [agent_office_mapping_created_by_fkey] FOREIGN KEY ([created_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[air_rates_agent_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[air_rates] ADD CONSTRAINT [air_rates_agent_id_fkey] FOREIGN KEY ([agent_id]) REFERENCES [dbo].[agents] ([id]);
GO
IF OBJECT_ID(N'[dbo].[air_rates_air_carrier_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[air_rates] ADD CONSTRAINT [air_rates_air_carrier_id_fkey] FOREIGN KEY ([air_carrier_id]) REFERENCES [dbo].[air_carriers] ([id]);
GO
IF OBJECT_ID(N'[dbo].[bodega_tenants_creado_por_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[bodega_tenants] ADD CONSTRAINT [bodega_tenants_creado_por_fkey] FOREIGN KEY ([creado_por]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[carrier_email_log_matched_shipment_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[carrier_email_log] ADD CONSTRAINT [carrier_email_log_matched_shipment_id_fkey] FOREIGN KEY ([matched_shipment_id]) REFERENCES [dbo].[shipments] ([id]);
GO
IF OBJECT_ID(N'[dbo].[carrier_transit_times_carrier_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[carrier_transit_times] ADD CONSTRAINT [carrier_transit_times_carrier_id_fkey] FOREIGN KEY ([carrier_id]) REFERENCES [dbo].[carriers] ([id]);
GO
IF OBJECT_ID(N'[dbo].[carrier_transit_times_route_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[carrier_transit_times] ADD CONSTRAINT [carrier_transit_times_route_id_fkey] FOREIGN KEY ([route_id]) REFERENCES [dbo].[freight_routes] ([id]);
GO
IF OBJECT_ID(N'[dbo].[carrier_transit_times_transshipment_port_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[carrier_transit_times] ADD CONSTRAINT [carrier_transit_times_transshipment_port_id_fkey] FOREIGN KEY ([transshipment_port_id]) REFERENCES [dbo].[ports] ([id]);
GO
IF OBJECT_ID(N'[dbo].[carrier_transit_times_verified_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[carrier_transit_times] ADD CONSTRAINT [carrier_transit_times_verified_by_fkey] FOREIGN KEY ([verified_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[destinations_tenant_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[christmas_destinations] ADD CONSTRAINT [destinations_tenant_id_fkey] FOREIGN KEY ([tenant_id]) REFERENCES [dbo].[christmas_tenants] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[global_settings_tenant_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[christmas_global_settings] ADD CONSTRAINT [global_settings_tenant_id_fkey] FOREIGN KEY ([tenant_id]) REFERENCES [dbo].[christmas_tenants] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[pallet_presets_tenant_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[christmas_pallet_presets] ADD CONSTRAINT [pallet_presets_tenant_id_fkey] FOREIGN KEY ([tenant_id]) REFERENCES [dbo].[christmas_tenants] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[products_tenant_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[christmas_products] ADD CONSTRAINT [products_tenant_id_fkey] FOREIGN KEY ([tenant_id]) REFERENCES [dbo].[christmas_tenants] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[user_profiles_tenant_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[christmas_user_profiles] ADD CONSTRAINT [user_profiles_tenant_id_fkey] FOREIGN KEY ([tenant_id]) REFERENCES [dbo].[christmas_tenants] ([id]) ON DELETE SET NULL;
GO
IF OBJECT_ID(N'[dbo].[cl_alerts_acknowledged_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[cl_alerts] ADD CONSTRAINT [cl_alerts_acknowledged_by_fkey] FOREIGN KEY ([acknowledged_by]) REFERENCES [dbo].[warehouse_users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[cl_alerts_loading_task_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[cl_alerts] ADD CONSTRAINT [cl_alerts_loading_task_id_fkey] FOREIGN KEY ([loading_task_id]) REFERENCES [dbo].[loading_tasks] ([id]);
GO
IF OBJECT_ID(N'[dbo].[cl_alerts_manifest_source_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[cl_alerts] ADD CONSTRAINT [cl_alerts_manifest_source_id_fkey] FOREIGN KEY ([manifest_source_id]) REFERENCES [dbo].[manifest_sources] ([id]);
GO
IF OBJECT_ID(N'[dbo].[cl_alerts_picking_task_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[cl_alerts] ADD CONSTRAINT [cl_alerts_picking_task_id_fkey] FOREIGN KEY ([picking_task_id]) REFERENCES [dbo].[picking_tasks] ([id]);
GO
IF OBJECT_ID(N'[dbo].[cl_alerts_recipient_user_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[cl_alerts] ADD CONSTRAINT [cl_alerts_recipient_user_id_fkey] FOREIGN KEY ([recipient_user_id]) REFERENCES [dbo].[warehouse_users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[cl_alerts_staging_task_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[cl_alerts] ADD CONSTRAINT [cl_alerts_staging_task_id_fkey] FOREIGN KEY ([staging_task_id]) REFERENCES [dbo].[staging_check_tasks] ([id]);
GO
IF OBJECT_ID(N'[dbo].[cl_alerts_warehouse_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[cl_alerts] ADD CONSTRAINT [cl_alerts_warehouse_id_fkey] FOREIGN KEY ([warehouse_id]) REFERENCES [dbo].[cl_warehouses] ([id]);
GO
IF OBJECT_ID(N'[dbo].[cl_audit_log_performed_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[cl_audit_log] ADD CONSTRAINT [cl_audit_log_performed_by_fkey] FOREIGN KEY ([performed_by]) REFERENCES [dbo].[warehouse_users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[cl_scan_events_loading_task_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[cl_scan_events] ADD CONSTRAINT [cl_scan_events_loading_task_id_fkey] FOREIGN KEY ([loading_task_id]) REFERENCES [dbo].[loading_tasks] ([id]) ON DELETE SET NULL;
GO
IF OBJECT_ID(N'[dbo].[cl_scan_events_matched_item_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[cl_scan_events] ADD CONSTRAINT [cl_scan_events_matched_item_id_fkey] FOREIGN KEY ([matched_item_id]) REFERENCES [dbo].[manifest_items] ([id]);
GO
IF OBJECT_ID(N'[dbo].[cl_scan_events_picking_task_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[cl_scan_events] ADD CONSTRAINT [cl_scan_events_picking_task_id_fkey] FOREIGN KEY ([picking_task_id]) REFERENCES [dbo].[picking_tasks] ([id]) ON DELETE SET NULL;
GO
IF OBJECT_ID(N'[dbo].[cl_scan_events_scanned_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[cl_scan_events] ADD CONSTRAINT [cl_scan_events_scanned_by_fkey] FOREIGN KEY ([scanned_by]) REFERENCES [dbo].[warehouse_users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[cl_scan_events_staging_task_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[cl_scan_events] ADD CONSTRAINT [cl_scan_events_staging_task_id_fkey] FOREIGN KEY ([staging_task_id]) REFERENCES [dbo].[staging_check_tasks] ([id]) ON DELETE SET NULL;
GO
IF OBJECT_ID(N'[dbo].[client_notify_contacts_client_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[client_notify_contacts] ADD CONSTRAINT [client_notify_contacts_client_id_fkey] FOREIGN KEY ([client_id]) REFERENCES [dbo].[clients] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[client_visits_client_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[client_visits] ADD CONSTRAINT [client_visits_client_id_fkey] FOREIGN KEY ([client_id]) REFERENCES [dbo].[clients] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[client_visits_created_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[client_visits] ADD CONSTRAINT [client_visits_created_by_fkey] FOREIGN KEY ([created_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[client_visits_executive_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[client_visits] ADD CONSTRAINT [client_visits_executive_id_fkey] FOREIGN KEY ([executive_id]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[clients_account_manager_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[clients] ADD CONSTRAINT [clients_account_manager_id_fkey] FOREIGN KEY ([account_manager_id]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[clients_assigned_to_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[clients] ADD CONSTRAINT [clients_assigned_to_fkey] FOREIGN KEY ([assigned_to]) REFERENCES [dbo].[users] ([id]) ON DELETE SET NULL;
GO
IF OBJECT_ID(N'[dbo].[clients_customer_service_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[clients] ADD CONSTRAINT [clients_customer_service_id_fkey] FOREIGN KEY ([customer_service_id]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[clients_deleted_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[clients] ADD CONSTRAINT [clients_deleted_by_fkey] FOREIGN KEY ([deleted_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[clients_parent_ff_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[clients] ADD CONSTRAINT [clients_parent_ff_id_fkey] FOREIGN KEY ([parent_ff_id]) REFERENCES [dbo].[clients] ([id]);
GO
IF OBJECT_ID(N'[dbo].[closings_client_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[closings] ADD CONSTRAINT [closings_client_id_fkey] FOREIGN KEY ([client_id]) REFERENCES [dbo].[clients] ([id]);
GO
IF OBJECT_ID(N'[dbo].[closings_executive_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[closings] ADD CONSTRAINT [closings_executive_id_fkey] FOREIGN KEY ([executive_id]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[cmm_dismissed_actions_seller_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[cmm_dismissed_actions] ADD CONSTRAINT [cmm_dismissed_actions_seller_id_fkey] FOREIGN KEY ([seller_id]) REFERENCES [dbo].[cmm_sellers] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[cmm_pending_seller_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[cmm_pending] ADD CONSTRAINT [cmm_pending_seller_id_fkey] FOREIGN KEY ([seller_id]) REFERENCES [dbo].[cmm_sellers] ([id]);
GO
IF OBJECT_ID(N'[dbo].[cmm_pending_upload_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[cmm_pending] ADD CONSTRAINT [cmm_pending_upload_id_fkey] FOREIGN KEY ([upload_id]) REFERENCES [dbo].[cmm_uploads] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[cmm_targets_seller_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[cmm_targets] ADD CONSTRAINT [cmm_targets_seller_id_fkey] FOREIGN KEY ([seller_id]) REFERENCES [dbo].[cmm_sellers] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[cmm_transactions_seller_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[cmm_transactions] ADD CONSTRAINT [cmm_transactions_seller_id_fkey] FOREIGN KEY ([seller_id]) REFERENCES [dbo].[cmm_sellers] ([id]);
GO
IF OBJECT_ID(N'[dbo].[cmm_transactions_upload_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[cmm_transactions] ADD CONSTRAINT [cmm_transactions_upload_id_fkey] FOREIGN KEY ([upload_id]) REFERENCES [dbo].[cmm_uploads] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[consolidado_aereo_prefs_updated_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[consolidado_aereo_prefs] ADD CONSTRAINT [consolidado_aereo_prefs_updated_by_fkey] FOREIGN KEY ([updated_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[consolidado_agente_exclusiones_consolidado_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[consolidado_agente_exclusiones] ADD CONSTRAINT [consolidado_agente_exclusiones_consolidado_id_fkey] FOREIGN KEY ([consolidado_id]) REFERENCES [dbo].[consolidados] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[consolidado_agente_exclusiones_creado_por_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[consolidado_agente_exclusiones] ADD CONSTRAINT [consolidado_agente_exclusiones_creado_por_fkey] FOREIGN KEY ([creado_por]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[consolidado_avisos_consolidado_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[consolidado_avisos] ADD CONSTRAINT [consolidado_avisos_consolidado_id_fkey] FOREIGN KEY ([consolidado_id]) REFERENCES [dbo].[consolidados] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[consolidado_avisos_sent_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[consolidado_avisos] ADD CONSTRAINT [consolidado_avisos_sent_by_fkey] FOREIGN KEY ([sent_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[consolidado_contenedores_consolidado_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[consolidado_contenedores] ADD CONSTRAINT [consolidado_contenedores_consolidado_id_fkey] FOREIGN KEY ([consolidado_id]) REFERENCES [dbo].[consolidados] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[consolidado_email_bitacora_consolidado_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[consolidado_email_bitacora] ADD CONSTRAINT [consolidado_email_bitacora_consolidado_id_fkey] FOREIGN KEY ([consolidado_id]) REFERENCES [dbo].[consolidados] ([id]);
GO
IF OBJECT_ID(N'[dbo].[consolidado_grupos_consolidado_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[consolidado_grupos] ADD CONSTRAINT [consolidado_grupos_consolidado_id_fkey] FOREIGN KEY ([consolidado_id]) REFERENCES [dbo].[consolidados] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[consolidado_linea_hazmat_consolidado_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[consolidado_linea_hazmat] ADD CONSTRAINT [consolidado_linea_hazmat_consolidado_id_fkey] FOREIGN KEY ([consolidado_id]) REFERENCES [dbo].[consolidados] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[consolidado_linea_hazmat_linea_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[consolidado_linea_hazmat] ADD CONSTRAINT [consolidado_linea_hazmat_linea_id_fkey] FOREIGN KEY ([linea_id]) REFERENCES [dbo].[consolidado_lineas] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[consolidado_linea_movimientos_consolidado_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[consolidado_linea_movimientos] ADD CONSTRAINT [consolidado_linea_movimientos_consolidado_id_fkey] FOREIGN KEY ([consolidado_id]) REFERENCES [dbo].[consolidados] ([id]);
GO
IF OBJECT_ID(N'[dbo].[consolidado_linea_movimientos_contenedor_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[consolidado_linea_movimientos] ADD CONSTRAINT [consolidado_linea_movimientos_contenedor_id_fkey] FOREIGN KEY ([contenedor_id]) REFERENCES [dbo].[consolidado_contenedores] ([id]) ON DELETE SET NULL;
GO
IF OBJECT_ID(N'[dbo].[consolidado_linea_movimientos_hecho_por_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[consolidado_linea_movimientos] ADD CONSTRAINT [consolidado_linea_movimientos_hecho_por_fkey] FOREIGN KEY ([hecho_por]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[consolidado_linea_movimientos_linea_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[consolidado_linea_movimientos] ADD CONSTRAINT [consolidado_linea_movimientos_linea_id_fkey] FOREIGN KEY ([linea_id]) REFERENCES [dbo].[consolidado_lineas] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[consolidado_linea_piezas_consolidado_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[consolidado_linea_piezas] ADD CONSTRAINT [consolidado_linea_piezas_consolidado_id_fkey] FOREIGN KEY ([consolidado_id]) REFERENCES [dbo].[consolidados] ([id]);
GO
IF OBJECT_ID(N'[dbo].[consolidado_linea_piezas_creado_por_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[consolidado_linea_piezas] ADD CONSTRAINT [consolidado_linea_piezas_creado_por_fkey] FOREIGN KEY ([creado_por]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[consolidado_linea_piezas_linea_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[consolidado_linea_piezas] ADD CONSTRAINT [consolidado_linea_piezas_linea_id_fkey] FOREIGN KEY ([linea_id]) REFERENCES [dbo].[consolidado_lineas] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[consolidado_linea_piezas_wr_item_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[consolidado_linea_piezas] ADD CONSTRAINT [consolidado_linea_piezas_wr_item_id_fkey] FOREIGN KEY ([wr_item_id]) REFERENCES [dbo].[magaya_wr_items] ([id]) ON DELETE SET NULL;
GO
IF OBJECT_ID(N'[dbo].[consolidado_lineas_cargado_confirmado_por_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[consolidado_lineas] ADD CONSTRAINT [consolidado_lineas_cargado_confirmado_por_fkey] FOREIGN KEY ([cargado_confirmado_por]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[consolidado_lineas_cfs_extra_por_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[consolidado_lineas] ADD CONSTRAINT [consolidado_lineas_cfs_extra_por_fkey] FOREIGN KEY ([cfs_extra_por]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[consolidado_lineas_client_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[consolidado_lineas] ADD CONSTRAINT [consolidado_lineas_client_id_fkey] FOREIGN KEY ([client_id]) REFERENCES [dbo].[clients] ([id]);
GO
IF OBJECT_ID(N'[dbo].[consolidado_lineas_consolidado_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[consolidado_lineas] ADD CONSTRAINT [consolidado_lineas_consolidado_id_fkey] FOREIGN KEY ([consolidado_id]) REFERENCES [dbo].[consolidados] ([id]);
GO
IF OBJECT_ID(N'[dbo].[consolidado_lineas_contenedor_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[consolidado_lineas] ADD CONSTRAINT [consolidado_lineas_contenedor_id_fkey] FOREIGN KEY ([contenedor_id]) REFERENCES [dbo].[consolidado_contenedores] ([id]);
GO
IF OBJECT_ID(N'[dbo].[consolidado_lineas_grupo_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[consolidado_lineas] ADD CONSTRAINT [consolidado_lineas_grupo_id_fkey] FOREIGN KEY ([grupo_id]) REFERENCES [dbo].[consolidado_grupos] ([id]);
GO
IF OBJECT_ID(N'[dbo].[consolidado_lineas_instruido_por_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[consolidado_lineas] ADD CONSTRAINT [consolidado_lineas_instruido_por_fkey] FOREIGN KEY ([instruido_por]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[consolidado_lineas_rodado_desde_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[consolidado_lineas] ADD CONSTRAINT [consolidado_lineas_rodado_desde_fkey] FOREIGN KEY ([rodado_desde]) REFERENCES [dbo].[consolidado_lineas] ([id]);
GO
IF OBJECT_ID(N'[dbo].[consolidado_lineas_shipment_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[consolidado_lineas] ADD CONSTRAINT [consolidado_lineas_shipment_id_fkey] FOREIGN KEY ([shipment_id]) REFERENCES [dbo].[shipments] ([id]) ON DELETE SET NULL;
GO
IF OBJECT_ID(N'[dbo].[consolidados_creado_por_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[consolidados] ADD CONSTRAINT [consolidados_creado_por_fkey] FOREIGN KEY ([creado_por]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[consolidados_servicio_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[consolidados] ADD CONSTRAINT [consolidados_servicio_fkey] FOREIGN KEY ([servicio]) REFERENCES [dbo].[consolidado_servicios] ([codigo]);
GO
IF OBJECT_ID(N'[dbo].[contacts_client_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[contacts] ADD CONSTRAINT [contacts_client_id_fkey] FOREIGN KEY ([client_id]) REFERENCES [dbo].[clients] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[container_load_reports_generated_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[container_load_reports] ADD CONSTRAINT [container_load_reports_generated_by_fkey] FOREIGN KEY ([generated_by]) REFERENCES [dbo].[warehouse_users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[container_load_reports_loading_task_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[container_load_reports] ADD CONSTRAINT [container_load_reports_loading_task_id_fkey] FOREIGN KEY ([loading_task_id]) REFERENCES [dbo].[loading_tasks] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[container_load_reports_manifest_source_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[container_load_reports] ADD CONSTRAINT [container_load_reports_manifest_source_id_fkey] FOREIGN KEY ([manifest_source_id]) REFERENCES [dbo].[manifest_sources] ([id]);
GO
IF OBJECT_ID(N'[dbo].[contract_documents_contract_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[contract_documents] ADD CONSTRAINT [contract_documents_contract_id_fkey] FOREIGN KEY ([contract_id]) REFERENCES [dbo].[contracts] ([id]);
GO
IF OBJECT_ID(N'[dbo].[contract_documents_uploaded_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[contract_documents] ADD CONSTRAINT [contract_documents_uploaded_by_fkey] FOREIGN KEY ([uploaded_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[contract_updates_carrier_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[contract_updates] ADD CONSTRAINT [contract_updates_carrier_id_fkey] FOREIGN KEY ([carrier_id]) REFERENCES [dbo].[carriers] ([id]);
GO
IF OBJECT_ID(N'[dbo].[contract_updates_contract_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[contract_updates] ADD CONSTRAINT [contract_updates_contract_id_fkey] FOREIGN KEY ([contract_id]) REFERENCES [dbo].[contracts] ([id]);
GO
IF OBJECT_ID(N'[dbo].[contract_updates_uploaded_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[contract_updates] ADD CONSTRAINT [contract_updates_uploaded_by_fkey] FOREIGN KEY ([uploaded_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[contracts_agent_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[contracts] ADD CONSTRAINT [contracts_agent_id_fkey] FOREIGN KEY ([agent_id]) REFERENCES [dbo].[agents] ([id]);
GO
IF OBJECT_ID(N'[dbo].[contracts_carrier_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[contracts] ADD CONSTRAINT [contracts_carrier_id_fkey] FOREIGN KEY ([carrier_id]) REFERENCES [dbo].[carriers] ([id]);
GO
IF OBJECT_ID(N'[dbo].[contracts_parent_contract_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[contracts] ADD CONSTRAINT [contracts_parent_contract_id_fkey] FOREIGN KEY ([parent_contract_id]) REFERENCES [dbo].[contracts] ([id]);
GO
IF OBJECT_ID(N'[dbo].[coordination_tasks_archived_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[coordination_tasks] ADD CONSTRAINT [coordination_tasks_archived_by_fkey] FOREIGN KEY ([archived_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[coordination_tasks_client_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[coordination_tasks] ADD CONSTRAINT [coordination_tasks_client_id_fkey] FOREIGN KEY ([client_id]) REFERENCES [dbo].[clients] ([id]) ON DELETE SET NULL;
GO
IF OBJECT_ID(N'[dbo].[coordination_tasks_created_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[coordination_tasks] ADD CONSTRAINT [coordination_tasks_created_by_fkey] FOREIGN KEY ([created_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[coordination_tasks_cs_assigned_to_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[coordination_tasks] ADD CONSTRAINT [coordination_tasks_cs_assigned_to_fkey] FOREIGN KEY ([cs_assigned_to]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[coordination_tasks_sales_executive_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[coordination_tasks] ADD CONSTRAINT [coordination_tasks_sales_executive_id_fkey] FOREIGN KEY ([sales_executive_id]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[coordination_tasks_shipment_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[coordination_tasks] ADD CONSTRAINT [coordination_tasks_shipment_id_fkey] FOREIGN KEY ([shipment_id]) REFERENCES [dbo].[shipments] ([id]) ON DELETE SET NULL;
GO
IF OBJECT_ID(N'[dbo].[credit_documents_credit_request_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[credit_documents] ADD CONSTRAINT [credit_documents_credit_request_id_fkey] FOREIGN KEY ([credit_request_id]) REFERENCES [dbo].[credit_requests] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[credit_documents_uploaded_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[credit_documents] ADD CONSTRAINT [credit_documents_uploaded_by_fkey] FOREIGN KEY ([uploaded_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[credit_notify_log_credit_request_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[credit_notify_log] ADD CONSTRAINT [credit_notify_log_credit_request_id_fkey] FOREIGN KEY ([credit_request_id]) REFERENCES [dbo].[credit_requests] ([id]) ON DELETE SET NULL;
GO
IF OBJECT_ID(N'[dbo].[credit_requests_client_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[credit_requests] ADD CONSTRAINT [credit_requests_client_id_fkey] FOREIGN KEY ([client_id]) REFERENCES [dbo].[clients] ([id]);
GO
IF OBJECT_ID(N'[dbo].[credit_requests_requested_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[credit_requests] ADD CONSTRAINT [credit_requests_requested_by_fkey] FOREIGN KEY ([requested_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[credit_requests_reviewed_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[credit_requests] ADD CONSTRAINT [credit_requests_reviewed_by_fkey] FOREIGN KEY ([reviewed_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[cs_assignments_created_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[cs_assignments] ADD CONSTRAINT [cs_assignments_created_by_fkey] FOREIGN KEY ([created_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[cs_assignments_cs_user_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[cs_assignments] ADD CONSTRAINT [cs_assignments_cs_user_id_fkey] FOREIGN KEY ([cs_user_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[cs_assignments_sales_executive_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[cs_assignments] ADD CONSTRAINT [cs_assignments_sales_executive_id_fkey] FOREIGN KEY ([sales_executive_id]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[cs_cuentas_habilitadas_client_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[cs_cuentas_habilitadas] ADD CONSTRAINT [cs_cuentas_habilitadas_client_id_fkey] FOREIGN KEY ([client_id]) REFERENCES [dbo].[clients] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[cs_cuentas_habilitadas_created_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[cs_cuentas_habilitadas] ADD CONSTRAINT [cs_cuentas_habilitadas_created_by_fkey] FOREIGN KEY ([created_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[cs_cuentas_habilitadas_cs_user_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[cs_cuentas_habilitadas] ADD CONSTRAINT [cs_cuentas_habilitadas_cs_user_id_fkey] FOREIGN KEY ([cs_user_id]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[ec_fcl_local_charges_carrier_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[ec_fcl_local_charges] ADD CONSTRAINT [ec_fcl_local_charges_carrier_id_fkey] FOREIGN KEY ([carrier_id]) REFERENCES [dbo].[carriers] ([id]);
GO
IF OBJECT_ID(N'[dbo].[fact_orders_client_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[fact_orders] ADD CONSTRAINT [fact_orders_client_id_fkey] FOREIGN KEY ([client_id]) REFERENCES [dbo].[clients] ([id]);
GO
IF OBJECT_ID(N'[dbo].[fact_orders_created_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[fact_orders] ADD CONSTRAINT [fact_orders_created_by_fkey] FOREIGN KEY ([created_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[fact_orders_shipment_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[fact_orders] ADD CONSTRAINT [fact_orders_shipment_id_fkey] FOREIGN KEY ([shipment_id]) REFERENCES [dbo].[shipments] ([id]);
GO
IF OBJECT_ID(N'[dbo].[fact_orders_si_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[fact_orders] ADD CONSTRAINT [fact_orders_si_id_fkey] FOREIGN KEY ([si_id]) REFERENCES [dbo].[shipping_instructions] ([id]);
GO
IF OBJECT_ID(N'[dbo].[fcl_semanal_client_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[fcl_semanal] ADD CONSTRAINT [fcl_semanal_client_id_fkey] FOREIGN KEY ([client_id]) REFERENCES [dbo].[clients] ([id]);
GO
IF OBJECT_ID(N'[dbo].[fcl_semanal_shipment_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[fcl_semanal] ADD CONSTRAINT [fcl_semanal_shipment_id_fkey] FOREIGN KEY ([shipment_id]) REFERENCES [dbo].[shipments] ([id]) ON DELETE SET NULL;
GO
IF OBJECT_ID(N'[dbo].[finanzas_access_granted_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[finanzas_access] ADD CONSTRAINT [finanzas_access_granted_by_fkey] FOREIGN KEY ([granted_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[finanzas_access_user_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[finanzas_access] ADD CONSTRAINT [finanzas_access_user_id_fkey] FOREIGN KEY ([user_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[finanzas_bank_match_bank_transaction_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[finanzas_bank_match] ADD CONSTRAINT [finanzas_bank_match_bank_transaction_id_fkey] FOREIGN KEY ([bank_transaction_id]) REFERENCES [dbo].[bank_transaction] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[finanzas_bank_match_office_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[finanzas_bank_match] ADD CONSTRAINT [finanzas_bank_match_office_id_fkey] FOREIGN KEY ([office_id]) REFERENCES [dbo].[offices] ([id]);
GO
IF OBJECT_ID(N'[dbo].[finanzas_config_recurrente_office_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[finanzas_config_recurrente] ADD CONSTRAINT [finanzas_config_recurrente_office_id_fkey] FOREIGN KEY ([office_id]) REFERENCES [dbo].[offices] ([id]);
GO
IF OBJECT_ID(N'[dbo].[finanzas_eeff_pl_office_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[finanzas_eeff_pl] ADD CONSTRAINT [finanzas_eeff_pl_office_id_fkey] FOREIGN KEY ([office_id]) REFERENCES [dbo].[offices] ([id]);
GO
IF OBJECT_ID(N'[dbo].[finanzas_forecast_recurrente_office_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[finanzas_forecast_recurrente] ADD CONSTRAINT [finanzas_forecast_recurrente_office_id_fkey] FOREIGN KEY ([office_id]) REFERENCES [dbo].[offices] ([id]);
GO
IF OBJECT_ID(N'[dbo].[finanzas_presupuesto_office_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[finanzas_presupuesto] ADD CONSTRAINT [finanzas_presupuesto_office_id_fkey] FOREIGN KEY ([office_id]) REFERENCES [dbo].[offices] ([id]);
GO
IF OBJECT_ID(N'[dbo].[finanzas_rc_por_zarpar_office_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[finanzas_rc_por_zarpar] ADD CONSTRAINT [finanzas_rc_por_zarpar_office_id_fkey] FOREIGN KEY ([office_id]) REFERENCES [dbo].[offices] ([id]);
GO
IF OBJECT_ID(N'[dbo].[freight_routes_destination_port_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[freight_routes] ADD CONSTRAINT [freight_routes_destination_port_id_fkey] FOREIGN KEY ([destination_port_id]) REFERENCES [dbo].[ports] ([id]);
GO
IF OBJECT_ID(N'[dbo].[freight_routes_origin_port_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[freight_routes] ADD CONSTRAINT [freight_routes_origin_port_id_fkey] FOREIGN KEY ([origin_port_id]) REFERENCES [dbo].[ports] ([id]);
GO
IF OBJECT_ID(N'[dbo].[freight_routes_transit_verified_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[freight_routes] ADD CONSTRAINT [freight_routes_transit_verified_by_fkey] FOREIGN KEY ([transit_verified_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[freight_routes_transshipment_port_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[freight_routes] ADD CONSTRAINT [freight_routes_transshipment_port_id_fkey] FOREIGN KEY ([transshipment_port_id]) REFERENCES [dbo].[ports] ([id]);
GO
IF OBJECT_ID(N'[dbo].[impersonation_log_admin_user_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[impersonation_log] ADD CONSTRAINT [impersonation_log_admin_user_id_fkey] FOREIGN KEY ([admin_user_id]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[impersonation_log_target_user_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[impersonation_log] ADD CONSTRAINT [impersonation_log_target_user_id_fkey] FOREIGN KEY ([target_user_id]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[inhouse_dashboards_client_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[inhouse_dashboards] ADD CONSTRAINT [inhouse_dashboards_client_id_fkey] FOREIGN KEY ([client_id]) REFERENCES [dbo].[clients] ([id]);
GO
IF OBJECT_ID(N'[dbo].[inhouse_dashboards_uploaded_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[inhouse_dashboards] ADD CONSTRAINT [inhouse_dashboards_uploaded_by_fkey] FOREIGN KEY ([uploaded_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[inhouse_despachos_client_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[inhouse_despachos] ADD CONSTRAINT [inhouse_despachos_client_id_fkey] FOREIGN KEY ([client_id]) REFERENCES [dbo].[clients] ([id]);
GO
IF OBJECT_ID(N'[dbo].[inhouse_despachos_created_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[inhouse_despachos] ADD CONSTRAINT [inhouse_despachos_created_by_fkey] FOREIGN KEY ([created_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[inhouse_despachos_shipment_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[inhouse_despachos] ADD CONSTRAINT [inhouse_despachos_shipment_id_fkey] FOREIGN KEY ([shipment_id]) REFERENCES [dbo].[shipments] ([id]) ON DELETE SET NULL;
GO
IF OBJECT_ID(N'[dbo].[inhouse_documentos_despacho_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[inhouse_documentos] ADD CONSTRAINT [inhouse_documentos_despacho_id_fkey] FOREIGN KEY ([despacho_id]) REFERENCES [dbo].[inhouse_despachos] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[inhouse_documentos_subido_por_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[inhouse_documentos] ADD CONSTRAINT [inhouse_documentos_subido_por_fkey] FOREIGN KEY ([subido_por]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[inhouse_profiles_client_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[inhouse_profiles] ADD CONSTRAINT [inhouse_profiles_client_id_fkey] FOREIGN KEY ([client_id]) REFERENCES [dbo].[clients] ([id]);
GO
IF OBJECT_ID(N'[dbo].[inland_addons_carrier_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[inland_addons] ADD CONSTRAINT [inland_addons_carrier_id_fkey] FOREIGN KEY ([carrier_id]) REFERENCES [dbo].[carriers] ([id]);
GO
IF OBJECT_ID(N'[dbo].[inland_addons_pol_port_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[inland_addons] ADD CONSTRAINT [inland_addons_pol_port_id_fkey] FOREIGN KEY ([pol_port_id]) REFERENCES [dbo].[ports] ([id]);
GO
IF OBJECT_ID(N'[dbo].[inland_carrier_area_rates_carrier_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[inland_carrier_area_rates] ADD CONSTRAINT [inland_carrier_area_rates_carrier_id_fkey] FOREIGN KEY ([carrier_id]) REFERENCES [dbo].[inland_carriers] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[inland_carrier_rates_carrier_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[inland_carrier_rates] ADD CONSTRAINT [inland_carrier_rates_carrier_id_fkey] FOREIGN KEY ([carrier_id]) REFERENCES [dbo].[inland_carriers] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[inland_carrier_zips_carrier_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[inland_carrier_zips] ADD CONSTRAINT [inland_carrier_zips_carrier_id_fkey] FOREIGN KEY ([carrier_id]) REFERENCES [dbo].[inland_carriers] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[inland_quotes_carrier_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[inland_quotes] ADD CONSTRAINT [inland_quotes_carrier_id_fkey] FOREIGN KEY ([carrier_id]) REFERENCES [dbo].[inland_carriers] ([id]);
GO
IF OBJECT_ID(N'[dbo].[liq_agent_invoice_lines_invoice_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[liq_agent_invoice_lines] ADD CONSTRAINT [liq_agent_invoice_lines_invoice_id_fkey] FOREIGN KEY ([invoice_id]) REFERENCES [dbo].[liq_agent_invoices] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[liq_settlement_lines_charge_code_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[liq_settlement_lines] ADD CONSTRAINT [liq_settlement_lines_charge_code_fkey] FOREIGN KEY ([charge_code]) REFERENCES [dbo].[liq_charge_catalog] ([code]);
GO
IF OBJECT_ID(N'[dbo].[liq_settlement_lines_settlement_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[liq_settlement_lines] ADD CONSTRAINT [liq_settlement_lines_settlement_id_fkey] FOREIGN KEY ([settlement_id]) REFERENCES [dbo].[liq_settlements] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[liq_settlements_shipment_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[liq_settlements] ADD CONSTRAINT [liq_settlements_shipment_id_fkey] FOREIGN KEY ([shipment_id]) REFERENCES [dbo].[liq_shipments] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[liq_tariffs_charge_code_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[liq_tariffs] ADD CONSTRAINT [liq_tariffs_charge_code_fkey] FOREIGN KEY ([charge_code]) REFERENCES [dbo].[liq_charge_catalog] ([code]);
GO
IF OBJECT_ID(N'[dbo].[loading_exceptions_authorized_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[loading_exceptions] ADD CONSTRAINT [loading_exceptions_authorized_by_fkey] FOREIGN KEY ([authorized_by]) REFERENCES [dbo].[warehouse_users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[loading_exceptions_loading_task_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[loading_exceptions] ADD CONSTRAINT [loading_exceptions_loading_task_id_fkey] FOREIGN KEY ([loading_task_id]) REFERENCES [dbo].[loading_tasks] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[loading_exceptions_manifest_item_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[loading_exceptions] ADD CONSTRAINT [loading_exceptions_manifest_item_id_fkey] FOREIGN KEY ([manifest_item_id]) REFERENCES [dbo].[manifest_items] ([id]);
GO
IF OBJECT_ID(N'[dbo].[loading_exceptions_raised_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[loading_exceptions] ADD CONSTRAINT [loading_exceptions_raised_by_fkey] FOREIGN KEY ([raised_by]) REFERENCES [dbo].[warehouse_users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[loading_materials_warehouse_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[loading_materials] ADD CONSTRAINT [loading_materials_warehouse_id_fkey] FOREIGN KEY ([warehouse_id]) REFERENCES [dbo].[cl_warehouses] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[loading_task_materials_loading_task_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[loading_task_materials] ADD CONSTRAINT [loading_task_materials_loading_task_id_fkey] FOREIGN KEY ([loading_task_id]) REFERENCES [dbo].[loading_tasks] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[loading_task_materials_material_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[loading_task_materials] ADD CONSTRAINT [loading_task_materials_material_id_fkey] FOREIGN KEY ([material_id]) REFERENCES [dbo].[loading_materials] ([id]);
GO
IF OBJECT_ID(N'[dbo].[loading_task_materials_recorded_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[loading_task_materials] ADD CONSTRAINT [loading_task_materials_recorded_by_fkey] FOREIGN KEY ([recorded_by]) REFERENCES [dbo].[warehouse_users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[loading_tasks_assigned_to_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[loading_tasks] ADD CONSTRAINT [loading_tasks_assigned_to_fkey] FOREIGN KEY ([assigned_to]) REFERENCES [dbo].[warehouse_users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[loading_tasks_container_type_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[loading_tasks] ADD CONSTRAINT [loading_tasks_container_type_fkey] FOREIGN KEY ([container_type]) REFERENCES [dbo].[cl_container_types] ([code]);
GO
IF OBJECT_ID(N'[dbo].[loading_tasks_loader_signed_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[loading_tasks] ADD CONSTRAINT [loading_tasks_loader_signed_by_fkey] FOREIGN KEY ([loader_signed_by]) REFERENCES [dbo].[warehouse_users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[loading_tasks_manifest_source_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[loading_tasks] ADD CONSTRAINT [loading_tasks_manifest_source_id_fkey] FOREIGN KEY ([manifest_source_id]) REFERENCES [dbo].[manifest_sources] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[loading_tasks_override_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[loading_tasks] ADD CONSTRAINT [loading_tasks_override_by_fkey] FOREIGN KEY ([override_by]) REFERENCES [dbo].[warehouse_users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[loading_tasks_reopened_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[loading_tasks] ADD CONSTRAINT [loading_tasks_reopened_by_fkey] FOREIGN KEY ([reopened_by]) REFERENCES [dbo].[warehouse_users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[loading_tasks_supervisor_signed_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[loading_tasks] ADD CONSTRAINT [loading_tasks_supervisor_signed_by_fkey] FOREIGN KEY ([supervisor_signed_by]) REFERENCES [dbo].[warehouse_users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[magaya_accounts_company_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[magaya_accounts] ADD CONSTRAINT [magaya_accounts_company_id_fkey] FOREIGN KEY ([company_id]) REFERENCES [dbo].[magaya_companies] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[magaya_bills_company_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[magaya_bills] ADD CONSTRAINT [magaya_bills_company_id_fkey] FOREIGN KEY ([company_id]) REFERENCES [dbo].[magaya_companies] ([id]);
GO
IF OBJECT_ID(N'[dbo].[magaya_cargo_releases_company_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[magaya_cargo_releases] ADD CONSTRAINT [magaya_cargo_releases_company_id_fkey] FOREIGN KEY ([company_id]) REFERENCES [dbo].[magaya_companies] ([id]);
GO
IF OBJECT_ID(N'[dbo].[magaya_charge_definitions_company_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[magaya_charge_definitions] ADD CONSTRAINT [magaya_charge_definitions_company_id_fkey] FOREIGN KEY ([company_id]) REFERENCES [dbo].[magaya_companies] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[magaya_clients_company_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[magaya_clients] ADD CONSTRAINT [magaya_clients_company_id_fkey] FOREIGN KEY ([company_id]) REFERENCES [dbo].[magaya_companies] ([id]);
GO
IF OBJECT_ID(N'[dbo].[magaya_currencies_company_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[magaya_currencies] ADD CONSTRAINT [magaya_currencies_company_id_fkey] FOREIGN KEY ([company_id]) REFERENCES [dbo].[magaya_companies] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[magaya_entities_company_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[magaya_entities] ADD CONSTRAINT [magaya_entities_company_id_fkey] FOREIGN KEY ([company_id]) REFERENCES [dbo].[magaya_companies] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[magaya_invoices_company_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[magaya_invoices] ADD CONSTRAINT [magaya_invoices_company_id_fkey] FOREIGN KEY ([company_id]) REFERENCES [dbo].[magaya_companies] ([id]);
GO
IF OBJECT_ID(N'[dbo].[magaya_journal_entries_company_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[magaya_journal_entries] ADD CONSTRAINT [magaya_journal_entries_company_id_fkey] FOREIGN KEY ([company_id]) REFERENCES [dbo].[magaya_companies] ([id]);
GO
IF OBJECT_ID(N'[dbo].[magaya_journal_entry_lines_company_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[magaya_journal_entry_lines] ADD CONSTRAINT [magaya_journal_entry_lines_company_id_fkey] FOREIGN KEY ([company_id]) REFERENCES [dbo].[magaya_companies] ([id]);
GO
IF OBJECT_ID(N'[dbo].[magaya_journal_entry_lines_journal_entry_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[magaya_journal_entry_lines] ADD CONSTRAINT [magaya_journal_entry_lines_journal_entry_id_fkey] FOREIGN KEY ([journal_entry_id]) REFERENCES [dbo].[magaya_journal_entries] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[magaya_pickup_orders_company_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[magaya_pickup_orders] ADD CONSTRAINT [magaya_pickup_orders_company_id_fkey] FOREIGN KEY ([company_id]) REFERENCES [dbo].[magaya_companies] ([id]);
GO
IF OBJECT_ID(N'[dbo].[magaya_shipments_company_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[magaya_shipments] ADD CONSTRAINT [magaya_shipments_company_id_fkey] FOREIGN KEY ([company_id]) REFERENCES [dbo].[magaya_companies] ([id]);
GO
IF OBJECT_ID(N'[dbo].[magaya_sync_log_company_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[magaya_sync_log] ADD CONSTRAINT [magaya_sync_log_company_id_fkey] FOREIGN KEY ([company_id]) REFERENCES [dbo].[magaya_companies] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[magaya_sync_state_company_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[magaya_sync_state] ADD CONSTRAINT [magaya_sync_state_company_id_fkey] FOREIGN KEY ([company_id]) REFERENCES [dbo].[magaya_companies] ([id]);
GO
IF OBJECT_ID(N'[dbo].[fk_tx_charges_company]', N'F') IS NULL
ALTER TABLE [dbo].[magaya_transaction_charges] ADD CONSTRAINT [fk_tx_charges_company] FOREIGN KEY ([company_id]) REFERENCES [dbo].[magaya_companies] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[fk_tx_charges_transaction]', N'F') IS NULL
ALTER TABLE [dbo].[magaya_transaction_charges] ADD CONSTRAINT [fk_tx_charges_transaction] FOREIGN KEY ([transaction_id]) REFERENCES [dbo].[magaya_transactions] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[magaya_transactions_company_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[magaya_transactions] ADD CONSTRAINT [magaya_transactions_company_id_fkey] FOREIGN KEY ([company_id]) REFERENCES [dbo].[magaya_companies] ([id]);
GO
IF OBJECT_ID(N'[dbo].[magaya_usa_shipments_manual_master_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[magaya_usa_shipments] ADD CONSTRAINT [magaya_usa_shipments_manual_master_id_fkey] FOREIGN KEY ([manual_master_id]) REFERENCES [dbo].[magaya_usa_shipments] ([id]);
GO
IF OBJECT_ID(N'[dbo].[magaya_vendor_payments_company_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[magaya_vendor_payments] ADD CONSTRAINT [magaya_vendor_payments_company_id_fkey] FOREIGN KEY ([company_id]) REFERENCES [dbo].[magaya_companies] ([id]);
GO
IF OBJECT_ID(N'[dbo].[magaya_warehouse_receipts_company_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[magaya_warehouse_receipts] ADD CONSTRAINT [magaya_warehouse_receipts_company_id_fkey] FOREIGN KEY ([company_id]) REFERENCES [dbo].[magaya_companies] ([id]);
GO
IF OBJECT_ID(N'[dbo].[magaya_wr_attachments_uploaded_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[magaya_wr_attachments] ADD CONSTRAINT [magaya_wr_attachments_uploaded_by_fkey] FOREIGN KEY ([uploaded_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[magaya_wr_attachments_wr_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[magaya_wr_attachments] ADD CONSTRAINT [magaya_wr_attachments_wr_id_fkey] FOREIGN KEY ([wr_id]) REFERENCES [dbo].[magaya_warehouse_receipts] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[magaya_wr_items_company_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[magaya_wr_items] ADD CONSTRAINT [magaya_wr_items_company_id_fkey] FOREIGN KEY ([company_id]) REFERENCES [dbo].[magaya_companies] ([id]);
GO
IF OBJECT_ID(N'[dbo].[magaya_wr_items_wr_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[magaya_wr_items] ADD CONSTRAINT [magaya_wr_items_wr_id_fkey] FOREIGN KEY ([wr_id]) REFERENCES [dbo].[magaya_warehouse_receipts] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[fk_manifest_items_pick_task]', N'F') IS NULL
ALTER TABLE [dbo].[manifest_items] ADD CONSTRAINT [fk_manifest_items_pick_task] FOREIGN KEY ([assigned_picking_task_id]) REFERENCES [dbo].[picking_tasks] ([id]) ON DELETE SET NULL;
GO
IF OBJECT_ID(N'[dbo].[manifest_items_depalletized_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[manifest_items] ADD CONSTRAINT [manifest_items_depalletized_by_fkey] FOREIGN KEY ([depalletized_by]) REFERENCES [dbo].[warehouse_users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[manifest_items_depalletized_supervisor_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[manifest_items] ADD CONSTRAINT [manifest_items_depalletized_supervisor_id_fkey] FOREIGN KEY ([depalletized_supervisor_id]) REFERENCES [dbo].[warehouse_users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[manifest_items_loaded_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[manifest_items] ADD CONSTRAINT [manifest_items_loaded_by_fkey] FOREIGN KEY ([loaded_by]) REFERENCES [dbo].[warehouse_users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[manifest_items_manifest_source_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[manifest_items] ADD CONSTRAINT [manifest_items_manifest_source_id_fkey] FOREIGN KEY ([manifest_source_id]) REFERENCES [dbo].[manifest_sources] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[manifest_items_picked_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[manifest_items] ADD CONSTRAINT [manifest_items_picked_by_fkey] FOREIGN KEY ([picked_by]) REFERENCES [dbo].[warehouse_users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[manifest_items_verified_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[manifest_items] ADD CONSTRAINT [manifest_items_verified_by_fkey] FOREIGN KEY ([verified_by]) REFERENCES [dbo].[warehouse_users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[manifest_sources_container_type_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[manifest_sources] ADD CONSTRAINT [manifest_sources_container_type_fkey] FOREIGN KEY ([container_type]) REFERENCES [dbo].[cl_container_types] ([code]);
GO
IF OBJECT_ID(N'[dbo].[manifest_sources_warehouse_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[manifest_sources] ADD CONSTRAINT [manifest_sources_warehouse_id_fkey] FOREIGN KEY ([warehouse_id]) REFERENCES [dbo].[cl_warehouses] ([id]);
GO
IF OBJECT_ID(N'[dbo].[mi_actor_alias_canonical_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[mi_actor_alias] ADD CONSTRAINT [mi_actor_alias_canonical_id_fkey] FOREIGN KEY ([canonical_id]) REFERENCES [dbo].[mi_canonical_actor] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[mi_etl_run_triggered_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[mi_etl_run] ADD CONSTRAINT [mi_etl_run_triggered_by_fkey] FOREIGN KEY ([triggered_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[mi_match_review_queue_reviewed_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[mi_match_review_queue] ADD CONSTRAINT [mi_match_review_queue_reviewed_by_fkey] FOREIGN KEY ([reviewed_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[mi_match_review_queue_suggested_client_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[mi_match_review_queue] ADD CONSTRAINT [mi_match_review_queue_suggested_client_id_fkey] FOREIGN KEY ([suggested_client_id]) REFERENCES [dbo].[clients] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[mi_shipment_intel_carrier_canonical_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[mi_shipment_intel] ADD CONSTRAINT [mi_shipment_intel_carrier_canonical_id_fkey] FOREIGN KEY ([carrier_canonical_id]) REFERENCES [dbo].[mi_canonical_actor] ([id]) ON DELETE SET NULL;
GO
IF OBJECT_ID(N'[dbo].[mi_shipment_intel_client_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[mi_shipment_intel] ADD CONSTRAINT [mi_shipment_intel_client_id_fkey] FOREIGN KEY ([client_id]) REFERENCES [dbo].[clients] ([id]) ON DELETE SET NULL;
GO
IF OBJECT_ID(N'[dbo].[mi_shipment_intel_etl_run_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[mi_shipment_intel] ADD CONSTRAINT [mi_shipment_intel_etl_run_id_fkey] FOREIGN KEY ([etl_run_id]) REFERENCES [dbo].[mi_etl_run] ([id]) ON DELETE SET NULL;
GO
IF OBJECT_ID(N'[dbo].[mi_shipment_intel_forwarder_canonical_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[mi_shipment_intel] ADD CONSTRAINT [mi_shipment_intel_forwarder_canonical_id_fkey] FOREIGN KEY ([forwarder_canonical_id]) REFERENCES [dbo].[mi_canonical_actor] ([id]);
GO
IF OBJECT_ID(N'[dbo].[mi_shipment_intel_partner_canonical_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[mi_shipment_intel] ADD CONSTRAINT [mi_shipment_intel_partner_canonical_id_fkey] FOREIGN KEY ([partner_canonical_id]) REFERENCES [dbo].[mi_canonical_actor] ([id]);
GO
IF OBJECT_ID(N'[dbo].[ops_client_notices_shipment_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[ops_client_notices] ADD CONSTRAINT [ops_client_notices_shipment_id_fkey] FOREIGN KEY ([shipment_id]) REFERENCES [dbo].[shipments] ([id]);
GO
IF OBJECT_ID(N'[dbo].[ops_devolucion_vacios_shipment_container_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[ops_devolucion_vacios] ADD CONSTRAINT [ops_devolucion_vacios_shipment_container_id_fkey] FOREIGN KEY ([shipment_container_id]) REFERENCES [dbo].[shipment_containers] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[ops_devolucion_vacios_shipment_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[ops_devolucion_vacios] ADD CONSTRAINT [ops_devolucion_vacios_shipment_id_fkey] FOREIGN KEY ([shipment_id]) REFERENCES [dbo].[shipments] ([id]) ON DELETE SET NULL;
GO
IF OBJECT_ID(N'[dbo].[ops_documents_applied_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[ops_documents] ADD CONSTRAINT [ops_documents_applied_by_fkey] FOREIGN KEY ([applied_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[ops_documents_shipment_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[ops_documents] ADD CONSTRAINT [ops_documents_shipment_id_fkey] FOREIGN KEY ([shipment_id]) REFERENCES [dbo].[shipments] ([id]);
GO
IF OBJECT_ID(N'[dbo].[ops_documents_uploaded_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[ops_documents] ADD CONSTRAINT [ops_documents_uploaded_by_fkey] FOREIGN KEY ([uploaded_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[ops_hbl_created_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[ops_hbl] ADD CONSTRAINT [ops_hbl_created_by_fkey] FOREIGN KEY ([created_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[ops_hbl_issued_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[ops_hbl] ADD CONSTRAINT [ops_hbl_issued_by_fkey] FOREIGN KEY ([issued_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[ops_hbl_master_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[ops_hbl] ADD CONSTRAINT [ops_hbl_master_id_fkey] FOREIGN KEY ([master_id]) REFERENCES [dbo].[ops_master] ([id]);
GO
IF OBJECT_ID(N'[dbo].[ops_hbl_shipment_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[ops_hbl] ADD CONSTRAINT [ops_hbl_shipment_id_fkey] FOREIGN KEY ([shipment_id]) REFERENCES [dbo].[shipments] ([id]);
GO
IF OBJECT_ID(N'[dbo].[ops_inbound_emails_shipment_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[ops_inbound_emails] ADD CONSTRAINT [ops_inbound_emails_shipment_id_fkey] FOREIGN KEY ([shipment_id]) REFERENCES [dbo].[shipments] ([id]) ON DELETE SET NULL;
GO
IF OBJECT_ID(N'[dbo].[ops_inbound_emails_si_resuelta_por_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[ops_inbound_emails] ADD CONSTRAINT [ops_inbound_emails_si_resuelta_por_fkey] FOREIGN KEY ([si_resuelta_por]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[ops_master_created_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[ops_master] ADD CONSTRAINT [ops_master_created_by_fkey] FOREIGN KEY ([created_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[ops_release_authorized_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[ops_release] ADD CONSTRAINT [ops_release_authorized_by_fkey] FOREIGN KEY ([authorized_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[ops_release_cas_document_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[ops_release] ADD CONSTRAINT [ops_release_cas_document_id_fkey] FOREIGN KEY ([cas_document_id]) REFERENCES [dbo].[ops_documents] ([id]);
GO
IF OBJECT_ID(N'[dbo].[ops_release_shipment_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[ops_release] ADD CONSTRAINT [ops_release_shipment_id_fkey] FOREIGN KEY ([shipment_id]) REFERENCES [dbo].[shipments] ([id]);
GO
IF OBJECT_ID(N'[dbo].[ops_transfers_received_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[ops_transfers] ADD CONSTRAINT [ops_transfers_received_by_fkey] FOREIGN KEY ([received_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[ops_transfers_returned_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[ops_transfers] ADD CONSTRAINT [ops_transfers_returned_by_fkey] FOREIGN KEY ([returned_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[ops_transfers_shipment_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[ops_transfers] ADD CONSTRAINT [ops_transfers_shipment_id_fkey] FOREIGN KEY ([shipment_id]) REFERENCES [dbo].[shipments] ([id]);
GO
IF OBJECT_ID(N'[dbo].[ops_transfers_transferred_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[ops_transfers] ADD CONSTRAINT [ops_transfers_transferred_by_fkey] FOREIGN KEY ([transferred_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[pba_payments_client_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[pba_payments] ADD CONSTRAINT [pba_payments_client_id_fkey] FOREIGN KEY ([client_id]) REFERENCES [dbo].[clients] ([id]);
GO
IF OBJECT_ID(N'[dbo].[pba_payments_shipment_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[pba_payments] ADD CONSTRAINT [pba_payments_shipment_id_fkey] FOREIGN KEY ([shipment_id]) REFERENCES [dbo].[shipments] ([id]) ON DELETE SET NULL;
GO
IF OBJECT_ID(N'[dbo].[phone_numbers_contact_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[phone_numbers] ADD CONSTRAINT [phone_numbers_contact_id_fkey] FOREIGN KEY ([contact_id]) REFERENCES [dbo].[contacts] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[picking_exceptions_manifest_item_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[picking_exceptions] ADD CONSTRAINT [picking_exceptions_manifest_item_id_fkey] FOREIGN KEY ([manifest_item_id]) REFERENCES [dbo].[manifest_items] ([id]);
GO
IF OBJECT_ID(N'[dbo].[picking_exceptions_picking_task_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[picking_exceptions] ADD CONSTRAINT [picking_exceptions_picking_task_id_fkey] FOREIGN KEY ([picking_task_id]) REFERENCES [dbo].[picking_tasks] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[picking_exceptions_raised_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[picking_exceptions] ADD CONSTRAINT [picking_exceptions_raised_by_fkey] FOREIGN KEY ([raised_by]) REFERENCES [dbo].[warehouse_users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[picking_exceptions_resolved_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[picking_exceptions] ADD CONSTRAINT [picking_exceptions_resolved_by_fkey] FOREIGN KEY ([resolved_by]) REFERENCES [dbo].[warehouse_users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[picking_tasks_assigned_to_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[picking_tasks] ADD CONSTRAINT [picking_tasks_assigned_to_fkey] FOREIGN KEY ([assigned_to]) REFERENCES [dbo].[warehouse_users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[picking_tasks_manifest_source_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[picking_tasks] ADD CONSTRAINT [picking_tasks_manifest_source_id_fkey] FOREIGN KEY ([manifest_source_id]) REFERENCES [dbo].[manifest_sources] ([id]);
GO
IF OBJECT_ID(N'[dbo].[picking_tasks_parent_split_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[picking_tasks] ADD CONSTRAINT [picking_tasks_parent_split_id_fkey] FOREIGN KEY ([parent_split_id]) REFERENCES [dbo].[picking_tasks] ([id]);
GO
IF OBJECT_ID(N'[dbo].[points_of_receipt_port_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[points_of_receipt] ADD CONSTRAINT [points_of_receipt_port_id_fkey] FOREIGN KEY ([port_id]) REFERENCES [dbo].[ports] ([id]);
GO
IF OBJECT_ID(N'[dbo].[pricing_rules_agent_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[pricing_rules] ADD CONSTRAINT [pricing_rules_agent_id_fkey] FOREIGN KEY ([agent_id]) REFERENCES [dbo].[agents] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[pricing_rules_carrier_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[pricing_rules] ADD CONSTRAINT [pricing_rules_carrier_id_fkey] FOREIGN KEY ([carrier_id]) REFERENCES [dbo].[carriers] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[pricing_rules_client_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[pricing_rules] ADD CONSTRAINT [pricing_rules_client_id_fkey] FOREIGN KEY ([client_id]) REFERENCES [dbo].[clients] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[pricing_rules_commodity_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[pricing_rules] ADD CONSTRAINT [pricing_rules_commodity_id_fkey] FOREIGN KEY ([commodity_id]) REFERENCES [dbo].[commodities] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[pricing_rules_equipment_type_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[pricing_rules] ADD CONSTRAINT [pricing_rules_equipment_type_id_fkey] FOREIGN KEY ([equipment_type_id]) REFERENCES [dbo].[equipment_types] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[pricing_rules_office_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[pricing_rules] ADD CONSTRAINT [pricing_rules_office_id_fkey] FOREIGN KEY ([office_id]) REFERENCES [dbo].[offices] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[quote_amendments_created_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[quote_amendments] ADD CONSTRAINT [quote_amendments_created_by_fkey] FOREIGN KEY ([created_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[quote_amendments_decided_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[quote_amendments] ADD CONSTRAINT [quote_amendments_decided_by_fkey] FOREIGN KEY ([decided_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[quote_amendments_quote_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[quote_amendments] ADD CONSTRAINT [quote_amendments_quote_id_fkey] FOREIGN KEY ([quote_id]) REFERENCES [dbo].[quotes] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[quote_emails_quote_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[quote_emails] ADD CONSTRAINT [quote_emails_quote_id_fkey] FOREIGN KEY ([quote_id]) REFERENCES [dbo].[quotes] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[quote_followups_quote_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[quote_followups] ADD CONSTRAINT [quote_followups_quote_id_fkey] FOREIGN KEY ([quote_id]) REFERENCES [dbo].[quotes] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[quote_pba_quote_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[quote_pba] ADD CONSTRAINT [quote_pba_quote_id_fkey] FOREIGN KEY ([quote_id]) REFERENCES [dbo].[quotes] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[quotes_air_carrier_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[quotes] ADD CONSTRAINT [quotes_air_carrier_id_fkey] FOREIGN KEY ([air_carrier_id]) REFERENCES [dbo].[air_carriers] ([id]);
GO
IF OBJECT_ID(N'[dbo].[quotes_carrier_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[quotes] ADD CONSTRAINT [quotes_carrier_id_fkey] FOREIGN KEY ([carrier_id]) REFERENCES [dbo].[carriers] ([id]);
GO
IF OBJECT_ID(N'[dbo].[quotes_client_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[quotes] ADD CONSTRAINT [quotes_client_id_fkey] FOREIGN KEY ([client_id]) REFERENCES [dbo].[clients] ([id]);
GO
IF OBJECT_ID(N'[dbo].[quotes_commodity_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[quotes] ADD CONSTRAINT [quotes_commodity_id_fkey] FOREIGN KEY ([commodity_id]) REFERENCES [dbo].[commodities] ([id]);
GO
IF OBJECT_ID(N'[dbo].[quotes_created_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[quotes] ADD CONSTRAINT [quotes_created_by_fkey] FOREIGN KEY ([created_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[quotes_deal_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[quotes] ADD CONSTRAINT [quotes_deal_id_fkey] FOREIGN KEY ([deal_id]) REFERENCES [dbo].[deals] ([id]);
GO
IF OBJECT_ID(N'[dbo].[quotes_destination_port_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[quotes] ADD CONSTRAINT [quotes_destination_port_id_fkey] FOREIGN KEY ([destination_port_id]) REFERENCES [dbo].[ports] ([id]);
GO
IF OBJECT_ID(N'[dbo].[quotes_equipment_type_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[quotes] ADD CONSTRAINT [quotes_equipment_type_id_fkey] FOREIGN KEY ([equipment_type_id]) REFERENCES [dbo].[equipment_types] ([id]);
GO
IF OBJECT_ID(N'[dbo].[quotes_origin_port_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[quotes] ADD CONSTRAINT [quotes_origin_port_id_fkey] FOREIGN KEY ([origin_port_id]) REFERENCES [dbo].[ports] ([id]);
GO
IF OBJECT_ID(N'[dbo].[quotes_prepared_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[quotes] ADD CONSTRAINT [quotes_prepared_by_fkey] FOREIGN KEY ([prepared_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[quotes_selected_air_rate_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[quotes] ADD CONSTRAINT [quotes_selected_air_rate_id_fkey] FOREIGN KEY ([selected_air_rate_id]) REFERENCES [dbo].[air_rates] ([id]);
GO
IF OBJECT_ID(N'[dbo].[quotes_selected_rate_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[quotes] ADD CONSTRAINT [quotes_selected_rate_id_fkey] FOREIGN KEY ([selected_rate_id]) REFERENCES [dbo].[rates] ([id]);
GO
IF OBJECT_ID(N'[dbo].[rate_charges_rate_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[rate_charges] ADD CONSTRAINT [rate_charges_rate_id_fkey] FOREIGN KEY ([rate_id]) REFERENCES [dbo].[rates] ([id]);
GO
IF OBJECT_ID(N'[dbo].[rate_notes_rate_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[rate_notes] ADD CONSTRAINT [rate_notes_rate_id_fkey] FOREIGN KEY ([rate_id]) REFERENCES [dbo].[rates] ([id]);
GO
IF OBJECT_ID(N'[dbo].[rates_agent_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[rates] ADD CONSTRAINT [rates_agent_id_fkey] FOREIGN KEY ([agent_id]) REFERENCES [dbo].[agents] ([id]) ON DELETE SET NULL;
GO
IF OBJECT_ID(N'[dbo].[rates_commodity_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[rates] ADD CONSTRAINT [rates_commodity_id_fkey] FOREIGN KEY ([commodity_id]) REFERENCES [dbo].[commodities] ([id]);
GO
IF OBJECT_ID(N'[dbo].[rates_contract_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[rates] ADD CONSTRAINT [rates_contract_id_fkey] FOREIGN KEY ([contract_id]) REFERENCES [dbo].[contracts] ([id]);
GO
IF OBJECT_ID(N'[dbo].[rates_equipment_type_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[rates] ADD CONSTRAINT [rates_equipment_type_id_fkey] FOREIGN KEY ([equipment_type_id]) REFERENCES [dbo].[equipment_types] ([id]);
GO
IF OBJECT_ID(N'[dbo].[rates_office_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[rates] ADD CONSTRAINT [rates_office_id_fkey] FOREIGN KEY ([office_id]) REFERENCES [dbo].[offices] ([id]) ON DELETE SET NULL;
GO
IF OBJECT_ID(N'[dbo].[rates_route_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[rates] ADD CONSTRAINT [rates_route_id_fkey] FOREIGN KEY ([route_id]) REFERENCES [dbo].[freight_routes] ([id]);
GO
IF OBJECT_ID(N'[dbo].[rates_tariff_sheet_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[rates] ADD CONSTRAINT [rates_tariff_sheet_id_fkey] FOREIGN KEY ([tariff_sheet_id]) REFERENCES [dbo].[tariff_sheets] ([id]) ON DELETE SET NULL;
GO
IF OBJECT_ID(N'[dbo].[reminders_shipment_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[reminders] ADD CONSTRAINT [reminders_shipment_id_fkey] FOREIGN KEY ([shipment_id]) REFERENCES [dbo].[shipments] ([id]) ON DELETE SET NULL;
GO
IF OBJECT_ID(N'[dbo].[reminders_user_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[reminders] ADD CONSTRAINT [reminders_user_id_fkey] FOREIGN KEY ([user_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[role_permissions_role_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[role_permissions] ADD CONSTRAINT [role_permissions_role_id_fkey] FOREIGN KEY ([role_id]) REFERENCES [dbo].[roles] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[routes_client_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[routes] ADD CONSTRAINT [routes_client_id_fkey] FOREIGN KEY ([client_id]) REFERENCES [dbo].[clients] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[routes_destination_port_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[routes] ADD CONSTRAINT [routes_destination_port_id_fkey] FOREIGN KEY ([destination_port_id]) REFERENCES [dbo].[ports] ([id]);
GO
IF OBJECT_ID(N'[dbo].[routes_origin_port_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[routes] ADD CONSTRAINT [routes_origin_port_id_fkey] FOREIGN KEY ([origin_port_id]) REFERENCES [dbo].[ports] ([id]);
GO
IF OBJECT_ID(N'[dbo].[routes_protected_by_ff_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[routes] ADD CONSTRAINT [routes_protected_by_ff_id_fkey] FOREIGN KEY ([protected_by_ff_id]) REFERENCES [dbo].[clients] ([id]);
GO
IF OBJECT_ID(N'[dbo].[sales_quote_lines_quote_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[sales_quote_lines] ADD CONSTRAINT [sales_quote_lines_quote_id_fkey] FOREIGN KEY ([quote_id]) REFERENCES [dbo].[quotes] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[sales_quote_lines_si_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[sales_quote_lines] ADD CONSTRAINT [sales_quote_lines_si_id_fkey] FOREIGN KEY ([si_id]) REFERENCES [dbo].[shipping_instructions] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[shipment_action_items_assigned_to_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[shipment_action_items] ADD CONSTRAINT [shipment_action_items_assigned_to_fkey] FOREIGN KEY ([assigned_to]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[shipment_action_items_completed_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[shipment_action_items] ADD CONSTRAINT [shipment_action_items_completed_by_fkey] FOREIGN KEY ([completed_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[shipment_action_items_shipment_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[shipment_action_items] ADD CONSTRAINT [shipment_action_items_shipment_id_fkey] FOREIGN KEY ([shipment_id]) REFERENCES [dbo].[shipments] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[shipment_agents_created_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[shipment_agents] ADD CONSTRAINT [shipment_agents_created_by_fkey] FOREIGN KEY ([created_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[shipment_agents_shipment_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[shipment_agents] ADD CONSTRAINT [shipment_agents_shipment_id_fkey] FOREIGN KEY ([shipment_id]) REFERENCES [dbo].[shipments] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[shipment_containers_created_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[shipment_containers] ADD CONSTRAINT [shipment_containers_created_by_fkey] FOREIGN KEY ([created_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[shipment_containers_shipment_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[shipment_containers] ADD CONSTRAINT [shipment_containers_shipment_id_fkey] FOREIGN KEY ([shipment_id]) REFERENCES [dbo].[shipments] ([id]);
GO
IF OBJECT_ID(N'[dbo].[shipment_containers_temperature_validated_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[shipment_containers] ADD CONSTRAINT [shipment_containers_temperature_validated_by_fkey] FOREIGN KEY ([temperature_validated_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[shipment_events_created_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[shipment_events] ADD CONSTRAINT [shipment_events_created_by_fkey] FOREIGN KEY ([created_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[shipment_events_shipment_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[shipment_events] ADD CONSTRAINT [shipment_events_shipment_id_fkey] FOREIGN KEY ([shipment_id]) REFERENCES [dbo].[shipments] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[shipment_shippers_created_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[shipment_shippers] ADD CONSTRAINT [shipment_shippers_created_by_fkey] FOREIGN KEY ([created_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[shipment_shippers_shipment_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[shipment_shippers] ADD CONSTRAINT [shipment_shippers_shipment_id_fkey] FOREIGN KEY ([shipment_id]) REFERENCES [dbo].[shipments] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[shipments_archived_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[shipments] ADD CONSTRAINT [shipments_archived_by_fkey] FOREIGN KEY ([archived_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[shipments_client_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[shipments] ADD CONSTRAINT [shipments_client_id_fkey] FOREIGN KEY ([client_id]) REFERENCES [dbo].[clients] ([id]);
GO
IF OBJECT_ID(N'[dbo].[shipments_consolidado_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[shipments] ADD CONSTRAINT [shipments_consolidado_id_fkey] FOREIGN KEY ([consolidado_id]) REFERENCES [dbo].[consolidados] ([id]);
GO
IF OBJECT_ID(N'[dbo].[shipments_created_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[shipments] ADD CONSTRAINT [shipments_created_by_fkey] FOREIGN KEY ([created_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[shipments_cs_assigned_to_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[shipments] ADD CONSTRAINT [shipments_cs_assigned_to_fkey] FOREIGN KEY ([cs_assigned_to]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[shipments_magaya_shipment_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[shipments] ADD CONSTRAINT [shipments_magaya_shipment_id_fkey] FOREIGN KEY ([magaya_shipment_id]) REFERENCES [dbo].[magaya_shipments] ([id]) ON DELETE SET NULL;
GO
IF OBJECT_ID(N'[dbo].[shipments_master_shipment_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[shipments] ADD CONSTRAINT [shipments_master_shipment_id_fkey] FOREIGN KEY ([master_shipment_id]) REFERENCES [dbo].[shipments] ([id]);
GO
IF OBJECT_ID(N'[dbo].[shipments_sales_executive_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[shipments] ADD CONSTRAINT [shipments_sales_executive_id_fkey] FOREIGN KEY ([sales_executive_id]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[shipping_instructions_client_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[shipping_instructions] ADD CONSTRAINT [shipping_instructions_client_id_fkey] FOREIGN KEY ([client_id]) REFERENCES [dbo].[clients] ([id]);
GO
IF OBJECT_ID(N'[dbo].[shipping_instructions_confirmed_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[shipping_instructions] ADD CONSTRAINT [shipping_instructions_confirmed_by_fkey] FOREIGN KEY ([confirmed_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[shipping_instructions_created_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[shipping_instructions] ADD CONSTRAINT [shipping_instructions_created_by_fkey] FOREIGN KEY ([created_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[shipping_instructions_quote_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[shipping_instructions] ADD CONSTRAINT [shipping_instructions_quote_id_fkey] FOREIGN KEY ([quote_id]) REFERENCES [dbo].[quotes] ([id]);
GO
IF OBJECT_ID(N'[dbo].[shipping_instructions_sales_executive_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[shipping_instructions] ADD CONSTRAINT [shipping_instructions_sales_executive_id_fkey] FOREIGN KEY ([sales_executive_id]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[shipping_instructions_shipment_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[shipping_instructions] ADD CONSTRAINT [shipping_instructions_shipment_id_fkey] FOREIGN KEY ([shipment_id]) REFERENCES [dbo].[shipments] ([id]);
GO
IF OBJECT_ID(N'[dbo].[staging_check_tasks_assigned_to_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[staging_check_tasks] ADD CONSTRAINT [staging_check_tasks_assigned_to_fkey] FOREIGN KEY ([assigned_to]) REFERENCES [dbo].[warehouse_users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[staging_check_tasks_created_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[staging_check_tasks] ADD CONSTRAINT [staging_check_tasks_created_by_fkey] FOREIGN KEY ([created_by]) REFERENCES [dbo].[warehouse_users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[staging_check_tasks_manifest_source_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[staging_check_tasks] ADD CONSTRAINT [staging_check_tasks_manifest_source_id_fkey] FOREIGN KEY ([manifest_source_id]) REFERENCES [dbo].[manifest_sources] ([id]);
GO
IF OBJECT_ID(N'[dbo].[staging_exceptions_raised_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[staging_exceptions] ADD CONSTRAINT [staging_exceptions_raised_by_fkey] FOREIGN KEY ([raised_by]) REFERENCES [dbo].[warehouse_users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[staging_exceptions_resolved_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[staging_exceptions] ADD CONSTRAINT [staging_exceptions_resolved_by_fkey] FOREIGN KEY ([resolved_by]) REFERENCES [dbo].[warehouse_users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[staging_exceptions_staging_task_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[staging_exceptions] ADD CONSTRAINT [staging_exceptions_staging_task_id_fkey] FOREIGN KEY ([staging_task_id]) REFERENCES [dbo].[staging_check_tasks] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[surcharges_carrier_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[surcharges] ADD CONSTRAINT [surcharges_carrier_id_fkey] FOREIGN KEY ([carrier_id]) REFERENCES [dbo].[carriers] ([id]);
GO
IF OBJECT_ID(N'[dbo].[surcharges_equipment_type_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[surcharges] ADD CONSTRAINT [surcharges_equipment_type_id_fkey] FOREIGN KEY ([equipment_type_id]) REFERENCES [dbo].[equipment_types] ([id]);
GO
IF OBJECT_ID(N'[dbo].[tariff_sheets_agent_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[tariff_sheets] ADD CONSTRAINT [tariff_sheets_agent_id_fkey] FOREIGN KEY ([agent_id]) REFERENCES [dbo].[agents] ([id]);
GO
IF OBJECT_ID(N'[dbo].[tariff_sheets_carrier_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[tariff_sheets] ADD CONSTRAINT [tariff_sheets_carrier_id_fkey] FOREIGN KEY ([carrier_id]) REFERENCES [dbo].[carriers] ([id]) ON DELETE SET NULL;
GO
IF OBJECT_ID(N'[dbo].[tariff_sheets_contract_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[tariff_sheets] ADD CONSTRAINT [tariff_sheets_contract_id_fkey] FOREIGN KEY ([contract_id]) REFERENCES [dbo].[contracts] ([id]) ON DELETE SET NULL;
GO
IF OBJECT_ID(N'[dbo].[tariff_sheets_office_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[tariff_sheets] ADD CONSTRAINT [tariff_sheets_office_id_fkey] FOREIGN KEY ([office_id]) REFERENCES [dbo].[offices] ([id]);
GO
IF OBJECT_ID(N'[dbo].[transit_times_carrier_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[transit_times] ADD CONSTRAINT [transit_times_carrier_id_fkey] FOREIGN KEY ([carrier_id]) REFERENCES [dbo].[carriers] ([id]);
GO
IF OBJECT_ID(N'[dbo].[transit_times_destination_port_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[transit_times] ADD CONSTRAINT [transit_times_destination_port_id_fkey] FOREIGN KEY ([destination_port_id]) REFERENCES [dbo].[ports] ([id]);
GO
IF OBJECT_ID(N'[dbo].[transit_times_origin_port_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[transit_times] ADD CONSTRAINT [transit_times_origin_port_id_fkey] FOREIGN KEY ([origin_port_id]) REFERENCES [dbo].[ports] ([id]);
GO
IF OBJECT_ID(N'[dbo].[unplanned_additions_authorized_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[unplanned_additions] ADD CONSTRAINT [unplanned_additions_authorized_by_fkey] FOREIGN KEY ([authorized_by]) REFERENCES [dbo].[warehouse_users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[unplanned_additions_loading_task_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[unplanned_additions] ADD CONSTRAINT [unplanned_additions_loading_task_id_fkey] FOREIGN KEY ([loading_task_id]) REFERENCES [dbo].[loading_tasks] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[unplanned_additions_raised_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[unplanned_additions] ADD CONSTRAINT [unplanned_additions_raised_by_fkey] FOREIGN KEY ([raised_by]) REFERENCES [dbo].[warehouse_users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[user_delegations_created_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[user_delegations] ADD CONSTRAINT [user_delegations_created_by_fkey] FOREIGN KEY ([created_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[user_delegations_owner_user_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[user_delegations] ADD CONSTRAINT [user_delegations_owner_user_id_fkey] FOREIGN KEY ([owner_user_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[user_delegations_viewer_user_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[user_delegations] ADD CONSTRAINT [user_delegations_viewer_user_id_fkey] FOREIGN KEY ([viewer_user_id]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[users_role_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[users] ADD CONSTRAINT [users_role_id_fkey] FOREIGN KEY ([role_id]) REFERENCES [dbo].[roles] ([id]);
GO
IF OBJECT_ID(N'[dbo].[visits_badge_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[visits] ADD CONSTRAINT [visits_badge_id_fkey] FOREIGN KEY ([badge_id]) REFERENCES [dbo].[visitor_badges] ([id]) ON DELETE SET NULL;
GO
IF OBJECT_ID(N'[dbo].[visits_host_user_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[visits] ADD CONSTRAINT [visits_host_user_id_fkey] FOREIGN KEY ([host_user_id]) REFERENCES [dbo].[users] ([id]) ON DELETE SET NULL;
GO
IF OBJECT_ID(N'[dbo].[visits_visitor_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[visits] ADD CONSTRAINT [visits_visitor_id_fkey] FOREIGN KEY ([visitor_id]) REFERENCES [dbo].[visitors] ([id]) ON DELETE SET NULL;
GO
IF OBJECT_ID(N'[dbo].[warehouse_containers_owner_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[warehouse_containers] ADD CONSTRAINT [warehouse_containers_owner_id_fkey] FOREIGN KEY ([owner_id]) REFERENCES [dbo].[clients] ([id]) ON DELETE SET NULL;
GO
IF OBJECT_ID(N'[dbo].[warehouse_users_user_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[warehouse_users] ADD CONSTRAINT [warehouse_users_user_id_fkey] FOREIGN KEY ([user_id]) REFERENCES [dbo].[users] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[warehouse_users_warehouse_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[warehouse_users] ADD CONSTRAINT [warehouse_users_warehouse_id_fkey] FOREIGN KEY ([warehouse_id]) REFERENCES [dbo].[cl_warehouses] ([id]);
GO
IF OBJECT_ID(N'[dbo].[wh_notices_client_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[wh_notices] ADD CONSTRAINT [wh_notices_client_id_fkey] FOREIGN KEY ([client_id]) REFERENCES [dbo].[clients] ([id]);
GO
IF OBJECT_ID(N'[dbo].[wh_notices_sent_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[wh_notices] ADD CONSTRAINT [wh_notices_sent_by_fkey] FOREIGN KEY ([sent_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[wh_report_movement_items_movement_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[wh_report_movement_items] ADD CONSTRAINT [wh_report_movement_items_movement_id_fkey] FOREIGN KEY ([movement_id]) REFERENCES [dbo].[wh_report_movements] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[wh_report_movement_items_product_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[wh_report_movement_items] ADD CONSTRAINT [wh_report_movement_items_product_id_fkey] FOREIGN KEY ([product_id]) REFERENCES [dbo].[wh_report_products] ([id]);
GO
IF OBJECT_ID(N'[dbo].[wh_report_movements_client_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[wh_report_movements] ADD CONSTRAINT [wh_report_movements_client_id_fkey] FOREIGN KEY ([client_id]) REFERENCES [dbo].[wh_report_clients] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[wh_report_movements_magaya_cr_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[wh_report_movements] ADD CONSTRAINT [wh_report_movements_magaya_cr_id_fkey] FOREIGN KEY ([magaya_cr_id]) REFERENCES [dbo].[magaya_cargo_releases] ([id]);
GO
IF OBJECT_ID(N'[dbo].[wh_report_movements_magaya_wr_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[wh_report_movements] ADD CONSTRAINT [wh_report_movements_magaya_wr_id_fkey] FOREIGN KEY ([magaya_wr_id]) REFERENCES [dbo].[magaya_warehouse_receipts] ([id]);
GO
IF OBJECT_ID(N'[dbo].[wh_report_product_mappings_client_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[wh_report_product_mappings] ADD CONSTRAINT [wh_report_product_mappings_client_id_fkey] FOREIGN KEY ([client_id]) REFERENCES [dbo].[wh_report_clients] ([id]);
GO
IF OBJECT_ID(N'[dbo].[wh_report_product_mappings_product_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[wh_report_product_mappings] ADD CONSTRAINT [wh_report_product_mappings_product_id_fkey] FOREIGN KEY ([product_id]) REFERENCES [dbo].[wh_report_products] ([id]);
GO
IF OBJECT_ID(N'[dbo].[wh_report_products_client_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[wh_report_products] ADD CONSTRAINT [wh_report_products_client_id_fkey] FOREIGN KEY ([client_id]) REFERENCES [dbo].[wh_report_clients] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[dbo].[wh_report_sync_log_client_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[wh_report_sync_log] ADD CONSTRAINT [wh_report_sync_log_client_id_fkey] FOREIGN KEY ([client_id]) REFERENCES [dbo].[wh_report_clients] ([id]);
GO
IF OBJECT_ID(N'[dbo].[wr_match_results_matched_client_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[wr_match_results] ADD CONSTRAINT [wr_match_results_matched_client_id_fkey] FOREIGN KEY ([matched_client_id]) REFERENCES [dbo].[clients] ([id]) ON DELETE SET NULL;
GO
IF OBJECT_ID(N'[dbo].[wr_match_results_matched_shipment_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[wr_match_results] ADD CONSTRAINT [wr_match_results_matched_shipment_id_fkey] FOREIGN KEY ([matched_shipment_id]) REFERENCES [dbo].[shipments] ([id]);
GO
IF OBJECT_ID(N'[dbo].[wr_match_results_resolved_by_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[wr_match_results] ADD CONSTRAINT [wr_match_results_resolved_by_fkey] FOREIGN KEY ([resolved_by]) REFERENCES [dbo].[users] ([id]);
GO
IF OBJECT_ID(N'[dbo].[wr_match_results_wr_id_fkey]', N'F') IS NULL
ALTER TABLE [dbo].[wr_match_results] ADD CONSTRAINT [wr_match_results_wr_id_fkey] FOREIGN KEY ([wr_id]) REFERENCES [dbo].[magaya_warehouse_receipts] ([id]) ON DELETE CASCADE;
GO
IF OBJECT_ID(N'[timeclock].[employees_site_id_fkey]', N'F') IS NULL
ALTER TABLE [timeclock].[employees] ADD CONSTRAINT [employees_site_id_fkey] FOREIGN KEY ([site_id]) REFERENCES [timeclock].[sites] ([id]);
GO
IF OBJECT_ID(N'[timeclock].[punches_emp_id_fkey]', N'F') IS NULL
ALTER TABLE [timeclock].[punches] ADD CONSTRAINT [punches_emp_id_fkey] FOREIGN KEY ([emp_id]) REFERENCES [timeclock].[employees] ([id]);
GO
