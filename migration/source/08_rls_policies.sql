-- Row Level Security: tablas con RLS activo y sus políticas
-- Origen: Supabase GES (wfzdrqfurwnakrfdnbgf), esquemas public, archive, private, timeclock.
-- Extraído del catálogo el 2026-09-29 (solo lectura). Referencia: NO ejecutar en Azure.
-- Credenciales redactadas como <SUPABASE_*>.

ALTER TABLE archive.magaya_charges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public._cartera_ecu_20260908 ENABLE ROW LEVEL SECURITY;
ALTER TABLE public._legacy_agent_rates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public._marcia_retardos_20260904 ENABLE ROW LEVEL SECURITY;
ALTER TABLE public._q ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.agent_files ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.agent_office_mapping ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.agents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.air_carriers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.air_rates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ar_ap_sync_queue ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.arap_live_open ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.arap_live_snapshot ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bank_account ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bank_transaction ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.birthday_emails_sent ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bodega_tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.brief_assets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.call_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.carrier_advisories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.carrier_email_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.carrier_transit_times ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.carriers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cash_movement ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.christmas_audit_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.christmas_bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.christmas_destinations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.christmas_fee_overrides ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.christmas_global_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.christmas_pallet_presets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.christmas_products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.christmas_tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.christmas_user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cierres_liquidacion ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cl_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cl_audit_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cl_container_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cl_scan_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cl_warehouses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.client_notify_contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.client_visits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.closings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cmm_chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cmm_client_aliases ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cmm_commission_policies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cmm_context_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cmm_dismissed_actions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cmm_insights ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cmm_pending ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cmm_sellers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cmm_targets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cmm_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cmm_uploads ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.commodities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.consignee_aliases ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.consolidado_aereo_prefs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.consolidado_agente_exclusiones ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.consolidado_agente_overrides ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.consolidado_agentes_destino ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.consolidado_agrupacion_memoria ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.consolidado_avisos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.consolidado_capacidades ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.consolidado_contenedores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.consolidado_email_bitacora ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.consolidado_fcl_prefs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.consolidado_grupos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.consolidado_linea_hazmat ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.consolidado_linea_movimientos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.consolidado_linea_piezas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.consolidado_lineas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.consolidado_servicios ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.consolidados ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.container_files ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.container_load_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.container_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contract_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contract_update_lines ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contract_updates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contracts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.coordination_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.credit_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.credit_notify_finance ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.credit_notify_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.credit_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cs_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cs_cuentas_habilitadas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cxc_send_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dashboard_agents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dashboard_clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dashboard_countries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dashboard_monthly_client ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dashboard_pnl_flow ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dashboard_pnl_monthly ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.deal_quotes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.deals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dispatches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.drayage_rates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ec_fcl_local_charges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ec_fcl_local_charges_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.email_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.equipment_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.external_containers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fact_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fcl_semanal ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.finanzas_access ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.finanzas_bank_match ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.finanzas_config_recurrente ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.finanzas_deuda_externa ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.finanzas_eeff_pl ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.finanzas_forecast_recurrente ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.finanzas_fx_rate ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.finanzas_presupuesto ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.finanzas_rc_por_zarpar ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.finanzas_sync_state ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.freight_carrier_aliases ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.freight_port_aliases ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.freight_routes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fx_rates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gloval_assets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.impersonation_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inhouse_dashboards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inhouse_despachos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inhouse_documentos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inhouse_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inland_addons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inland_carrier_area_rates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inland_carrier_rates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inland_carrier_zips ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inland_carriers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inland_quotes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.job_applicants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lcl_admin_emails ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lcl_lanes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lcl_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lcl_surcharges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.liq_agent_invoice_lines ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.liq_agent_invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.liq_charge_catalog ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.liq_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.liq_settlement_lines ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.liq_settlements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.liq_shipments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.liq_tariffs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.loading_exceptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.loading_materials ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.loading_task_materials ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.loading_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.login_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.magaya_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.magaya_balance_override ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.magaya_bills ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.magaya_cargo_releases ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.magaya_charge_definitions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.magaya_charges_extracted ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.magaya_clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.magaya_companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.magaya_cr_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.magaya_currencies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.magaya_entities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.magaya_entity_balance ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.magaya_event_definitions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.magaya_inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.magaya_invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.magaya_journal_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.magaya_journal_entry_lines ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.magaya_payment_application ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.magaya_pickup_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.magaya_shipments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.magaya_status_overrides ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.magaya_sync_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.magaya_sync_state ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.magaya_transaction_charges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.magaya_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.magaya_usa_shipments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.magaya_vendor_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.magaya_warehouse_receipts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.magaya_wr_attachments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.magaya_wr_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.manifest_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.manifest_sources ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.market_indices_daily ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mi_actor_alias ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mi_canonical_actor ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mi_courier_shipment ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mi_etl_run ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mi_match_review_queue ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mi_shipment_intel ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.monday_containers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.nomina_live ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.offices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ops_capture_mailboxes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ops_client_notices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ops_devolucion_vacios ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ops_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ops_hbl ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ops_hbl_sequence ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ops_inbound_emails ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ops_master ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ops_release ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ops_transfers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pagos_recurrentes_live ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_commitment ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pba_authorized_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pba_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.phone_numbers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.picking_exceptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.picking_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.points_of_receipt ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ports_master ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pricing_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.prospect_enrichment_ec ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quote_amendments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quote_charges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quote_emails ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quote_followups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quote_pba ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quotes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rate_charges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rate_components ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rate_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reception_hosts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recurring_movement ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reminders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rfq_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.role_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.routes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sales_activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sales_doc_counters ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sales_goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sales_live_monthly ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sales_quote_lines ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scheduled_payment ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shipco_destinations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shipco_rates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shipco_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shipment_action_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shipment_agents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shipment_containers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shipment_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shipment_shippers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shipments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shipping_instructions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shipping_lines ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.staging_check_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.staging_exceptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.surcharge_adjustments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.surcharges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tariff_sheets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.time_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transit_times ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.unplanned_additions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_delegations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_permission_overrides ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vendor_flexibility ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vendor_profile ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ventas_alertas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ventas_congelado ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.visitor_badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.visitors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.visits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.warehouse_cogs_manual ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.warehouse_cogs_monthly ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.warehouse_containers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.warehouse_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.warehouse_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wh_carga_no_identificada ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wh_client_pallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wh_container_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wh_containers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wh_containers_external ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wh_country_map ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wh_doc_7512 ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wh_import_clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wh_internal_people ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wh_loading_rates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wh_notices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wh_report_clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wh_report_movement_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wh_report_movements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wh_report_product_mappings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wh_report_products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wh_report_sync_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wh_stations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wh_storage_terms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wh_unloading_rates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wh_warehouse_costs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wh_whr_backfill_universo ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wr_att_backfill_queue ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wr_backfill_queue ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wr_match_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wr_saldo_queue ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow all access" ON archive.magaya_charges AS PERMISSIVE FOR ALL TO public
  USING (true)
  WITH CHECK (true);

CREATE POLICY legacy_agent_rates_select ON public._legacy_agent_rates AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY activities_delete ON public.activities AS PERMISSIVE FOR DELETE TO authenticated
  USING ((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.auth_user_id = ( SELECT auth.uid() AS uid)) AND ((users.role = ANY (ARRAY['Admin'::text, 'Administration'::text])) OR (EXISTS ( SELECT 1
           FROM (routes
             JOIN clients ON ((clients.id = routes.client_id)))
          WHERE ((routes.id = activities.route_id) AND ((clients.assigned_to = users.id) OR ((users.role = 'Manager'::text) AND (users.office = clients.office)))))))))));

CREATE POLICY activities_insert ON public.activities AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK ((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.auth_user_id = ( SELECT auth.uid() AS uid)) AND ((users.role = ANY (ARRAY['Admin'::text, 'Administration'::text])) OR (EXISTS ( SELECT 1
           FROM (routes
             JOIN clients ON ((clients.id = routes.client_id)))
          WHERE ((routes.id = activities.route_id) AND ((clients.assigned_to = users.id) OR ((users.role = 'Manager'::text) AND (users.office = clients.office)))))))))));

CREATE POLICY activities_insert_delegate ON public.activities AS PERMISSIVE FOR INSERT TO public
  WITH CHECK ((EXISTS ( SELECT 1
   FROM clients c
  WHERE ((c.id = activities.client_id) AND (c.deleted_at IS NULL) AND has_delegation_to(c.assigned_to)))));

CREATE POLICY activities_select ON public.activities AS PERMISSIVE FOR SELECT TO public
  USING (((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.auth_user_id = ( SELECT auth.uid() AS uid)) AND ((users.role = ANY (ARRAY['Admin'::text, 'Administration'::text])) OR (EXISTS ( SELECT 1
           FROM (routes
             JOIN clients ON ((clients.id = routes.client_id)))
          WHERE ((routes.id = activities.route_id) AND ((clients.assigned_to = users.id) OR ((users.role = 'Manager'::text) AND (users.office = clients.office)))))))))) OR (EXISTS ( SELECT 1
   FROM clients c
  WHERE ((c.id = activities.client_id) AND user_can_see_office(c.office))))));

CREATE POLICY activities_select_delegate ON public.activities AS PERMISSIVE FOR SELECT TO public
  USING ((EXISTS ( SELECT 1
   FROM clients c
  WHERE ((c.id = activities.client_id) AND (c.deleted_at IS NULL) AND has_delegation_to(c.assigned_to)))));

CREATE POLICY activities_update ON public.activities AS PERMISSIVE FOR UPDATE TO authenticated
  USING ((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.auth_user_id = ( SELECT auth.uid() AS uid)) AND ((users.role = ANY (ARRAY['Admin'::text, 'Administration'::text])) OR (EXISTS ( SELECT 1
           FROM (routes
             JOIN clients ON ((clients.id = routes.client_id)))
          WHERE ((routes.id = activities.route_id) AND ((clients.assigned_to = users.id) OR ((users.role = 'Manager'::text) AND (users.office = clients.office)))))))))))
  WITH CHECK ((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.auth_user_id = ( SELECT auth.uid() AS uid)) AND ((users.role = ANY (ARRAY['Admin'::text, 'Administration'::text])) OR (EXISTS ( SELECT 1
           FROM (routes
             JOIN clients ON ((clients.id = routes.client_id)))
          WHERE ((routes.id = activities.route_id) AND ((clients.assigned_to = users.id) OR ((users.role = 'Manager'::text) AND (users.office = clients.office)))))))))));

CREATE POLICY activities_update_delegate ON public.activities AS PERMISSIVE FOR UPDATE TO public
  USING ((EXISTS ( SELECT 1
   FROM clients c
  WHERE ((c.id = activities.client_id) AND (c.deleted_at IS NULL) AND has_delegation_to(c.assigned_to)))))
  WITH CHECK ((EXISTS ( SELECT 1
   FROM clients c
  WHERE ((c.id = activities.client_id) AND (c.deleted_at IS NULL) AND has_delegation_to(c.assigned_to)))));

CREATE POLICY "Create own activity logs policy" ON public.activity_logs AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK ((( SELECT auth.uid() AS uid) = ( SELECT users.auth_user_id
   FROM users
  WHERE (users.id = activity_logs.user_id))));

CREATE POLICY "View activity logs policy" ON public.activity_logs AS PERMISSIVE FOR SELECT TO authenticated
  USING (((( SELECT auth.uid() AS uid) = ( SELECT users.auth_user_id
   FROM users
  WHERE (users.id = activity_logs.user_id))) OR (EXISTS ( SELECT 1
   FROM users
  WHERE ((users.auth_user_id = ( SELECT auth.uid() AS uid)) AND (users.role = ANY (ARRAY['Admin'::text, 'Administration'::text]))))) OR (EXISTS ( SELECT 1
   FROM (users acting_user
     JOIN users log_user ON ((log_user.id = activity_logs.user_id)))
  WHERE ((acting_user.auth_user_id = ( SELECT auth.uid() AS uid)) AND (acting_user.role = 'Manager'::text) AND (acting_user.office = log_user.office))))));

CREATE POLICY "Admin and Manager can delete files" ON public.agent_files AS PERMISSIVE FOR DELETE TO authenticated
  USING ((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.id = ( SELECT auth.uid() AS uid)) AND (users.role = ANY (ARRAY['Admin'::text, 'Manager'::text]))))));

CREATE POLICY "Admin and Manager can update files" ON public.agent_files AS PERMISSIVE FOR UPDATE TO authenticated
  USING ((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.id = ( SELECT auth.uid() AS uid)) AND (users.role = ANY (ARRAY['Admin'::text, 'Manager'::text]))))))
  WITH CHECK ((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.id = ( SELECT auth.uid() AS uid)) AND (users.role = ANY (ARRAY['Admin'::text, 'Manager'::text]))))));

CREATE POLICY "Admin, Manager, and Administration can upload files" ON public.agent_files AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK ((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.id = ( SELECT auth.uid() AS uid)) AND (users.role = ANY (ARRAY['Admin'::text, 'Manager'::text, 'Administration'::text]))))));

CREATE POLICY "Users can view files for agents they can access" ON public.agent_files AS PERMISSIVE FOR SELECT TO authenticated
  USING ((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.id = ( SELECT auth.uid() AS uid)) AND ((users.role = ANY (ARRAY['Admin'::text, 'Manager'::text, 'Administration'::text])) OR (users.id = agent_files.agent_id))))));

CREATE POLICY agent_office_modify ON public.agent_office_mapping AS PERMISSIVE FOR ALL TO public
  USING ((app_user_is_admin() OR app_user_is_manager()));

CREATE POLICY agent_office_select ON public.agent_office_mapping AS PERMISSIVE FOR SELECT TO authenticated
  USING ((( SELECT auth.uid() AS uid) IS NOT NULL));

CREATE POLICY "Admins can delete agents" ON public.agents AS PERMISSIVE FOR DELETE TO authenticated
  USING ((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.id = ( SELECT auth.uid() AS uid)) AND (users.role = ANY (ARRAY['Admin'::text, 'Administration'::text]))))));

CREATE POLICY "Admins can insert agents" ON public.agents AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK ((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.id = ( SELECT auth.uid() AS uid)) AND (users.role = ANY (ARRAY['Admin'::text, 'Administration'::text]))))));

CREATE POLICY "Admins can update agents" ON public.agents AS PERMISSIVE FOR UPDATE TO authenticated
  USING ((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.id = ( SELECT auth.uid() AS uid)) AND (users.role = ANY (ARRAY['Admin'::text, 'Administration'::text]))))))
  WITH CHECK ((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.id = ( SELECT auth.uid() AS uid)) AND (users.role = ANY (ARRAY['Admin'::text, 'Administration'::text]))))));

CREATE POLICY "Authenticated users can view agents" ON public.agents AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can view air_carriers" ON public.air_carriers AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "Managers can delete air_carriers" ON public.air_carriers AS PERMISSIVE FOR DELETE TO authenticated
  USING (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY "Managers can insert air_carriers" ON public.air_carriers AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY "Managers can update air_carriers" ON public.air_carriers AS PERMISSIVE FOR UPDATE TO authenticated
  USING (( SELECT can_modify_reference_data() AS can_modify_reference_data))
  WITH CHECK (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY "Authenticated users can view air_rates" ON public.air_rates AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "Managers can delete air_rates" ON public.air_rates AS PERMISSIVE FOR DELETE TO authenticated
  USING (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY "Managers can insert air_rates" ON public.air_rates AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY "Managers can update air_rates" ON public.air_rates AS PERMISSIVE FOR UPDATE TO authenticated
  USING (( SELECT can_modify_reference_data() AS can_modify_reference_data))
  WITH CHECK (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY finanzas_wall_select ON public.ar_ap_sync_queue AS PERMISSIVE FOR SELECT TO authenticated
  USING ((COALESCE(array_length(( SELECT app_finanzas_offices() AS app_finanzas_offices), 1), 0) > 0));

CREATE POLICY service_all ON public.ar_ap_sync_queue AS PERMISSIVE FOR ALL TO service_role
  USING (true)
  WITH CHECK (true);

CREATE POLICY finanzas_wall_select ON public.arap_live_open AS PERMISSIVE FOR SELECT TO authenticated
  USING ((finanzas_office_code(office) IN ( SELECT unnest(app_finanzas_offices()) AS unnest)));

CREATE POLICY "Admins can view all audit logs" ON public.audit_log AS PERMISSIVE FOR SELECT TO authenticated
  USING ((_user_role() = 'Admin'::text));

CREATE POLICY "Service role can insert audit logs" ON public.audit_log AS PERMISSIVE FOR INSERT TO service_role
  WITH CHECK (true);

CREATE POLICY finanzas_wall_select ON public.bank_account AS PERMISSIVE FOR SELECT TO authenticated
  USING ((finanzas_office_code_for_office(office_id) IN ( SELECT unnest(app_finanzas_offices()) AS unnest)));

CREATE POLICY service_all ON public.bank_account AS PERMISSIVE FOR ALL TO service_role
  USING (true)
  WITH CHECK (true);

CREATE POLICY finanzas_wall_select ON public.bank_transaction AS PERMISSIVE FOR SELECT TO authenticated
  USING ((EXISTS ( SELECT 1
   FROM bank_account ba
  WHERE ((ba.id = bank_transaction.bank_account_id) AND (finanzas_office_code_for_office(ba.office_id) IN ( SELECT unnest(app_finanzas_offices()) AS unnest))))));

CREATE POLICY service_all ON public.bank_transaction AS PERMISSIVE FOR ALL TO service_role
  USING (true)
  WITH CHECK (true);

CREATE POLICY birthday_emails_select ON public.birthday_emails_sent AS PERMISSIVE FOR SELECT TO authenticated
  USING ((EXISTS ( SELECT 1
   FROM users
  WHERE (users.auth_user_id = ( SELECT auth.uid() AS uid)))));

CREATE POLICY bodega_tenants_all ON public.bodega_tenants AS PERMISSIVE FOR ALL TO public
  USING (true)
  WITH CHECK (true);

CREATE POLICY brief_assets_auth_all ON public.brief_assets AS PERMISSIVE FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY call_logs_delete ON public.call_logs AS PERMISSIVE FOR DELETE TO authenticated
  USING ((_user_role() = ANY (ARRAY['Admin'::text, 'Manager'::text])));

CREATE POLICY call_logs_insert ON public.call_logs AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK (true);

CREATE POLICY call_logs_select ON public.call_logs AS PERMISSIVE FOR SELECT TO authenticated
  USING (((_user_role() = ANY (ARRAY['Admin'::text, 'VP'::text])) OR ((_user_role() = ANY (ARRAY['Manager'::text, 'Administration'::text])) AND (office = ( SELECT users.office
   FROM users
  WHERE (users.auth_user_id = ( SELECT auth.uid() AS uid))))) OR (office = ( SELECT users.office
   FROM users
  WHERE (users.auth_user_id = ( SELECT auth.uid() AS uid))))));

CREATE POLICY call_logs_update ON public.call_logs AS PERMISSIVE FOR UPDATE TO authenticated
  USING ((_user_role() = ANY (ARRAY['Admin'::text, 'Manager'::text, 'Administration'::text])));

CREATE POLICY carrier_advisories_lectura ON public.carrier_advisories AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY carrier_email_modify ON public.carrier_email_log AS PERMISSIVE FOR ALL TO public
  USING (true);

CREATE POLICY carrier_email_select ON public.carrier_email_log AS PERMISSIVE FOR SELECT TO public
  USING ((app_user_is_admin() OR ((matched_shipment_id IS NOT NULL) AND (EXISTS ( SELECT 1
   FROM shipments s
  WHERE ((s.id = carrier_email_log.matched_shipment_id) AND app_can_see_shipment_row(s.sales_executive_id, s.office, s.cs_assigned_to)))))));

CREATE POLICY "Managers can delete carrier_transit_times" ON public.carrier_transit_times AS PERMISSIVE FOR DELETE TO authenticated
  USING (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY "Managers can insert carrier_transit_times" ON public.carrier_transit_times AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY "Managers can update carrier_transit_times" ON public.carrier_transit_times AS PERMISSIVE FOR UPDATE TO authenticated
  USING (( SELECT can_modify_reference_data() AS can_modify_reference_data))
  WITH CHECK (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY "Users can view" ON public.carrier_transit_times AS PERMISSIVE FOR SELECT TO public
  USING (true);

CREATE POLICY "Authenticated users can view carriers" ON public.carriers AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "Managers can delete carriers" ON public.carriers AS PERMISSIVE FOR DELETE TO authenticated
  USING (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY "Managers can insert carriers" ON public.carriers AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY "Managers can update carriers" ON public.carriers AS PERMISSIVE FOR UPDATE TO authenticated
  USING (( SELECT can_modify_reference_data() AS can_modify_reference_data))
  WITH CHECK (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY finanzas_wall_select ON public.cash_movement AS PERMISSIVE FOR SELECT TO authenticated
  USING ((finanzas_office_code_for_office(office_id) IN ( SELECT unnest(app_finanzas_offices()) AS unnest)));

CREATE POLICY service_all ON public.cash_movement AS PERMISSIVE FOR ALL TO service_role
  USING (true)
  WITH CHECK (true);

CREATE POLICY christmas_audit_read ON public.christmas_audit_log AS PERMISSIVE FOR SELECT TO authenticated
  USING ((christmas_current_role() = ANY (ARRAY['admin'::text, 'manager'::text])));

CREATE POLICY christmas_bookings_insert ON public.christmas_bookings AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK (((tenant_id = christmas_current_tenant()) OR (christmas_current_role() = ANY (ARRAY['admin'::text, 'manager'::text]))));

CREATE POLICY christmas_bookings_read ON public.christmas_bookings AS PERMISSIVE FOR SELECT TO authenticated
  USING (((tenant_id = christmas_current_tenant()) OR (christmas_current_role() = ANY (ARRAY['admin'::text, 'manager'::text]))));

CREATE POLICY christmas_bookings_rep_edit ON public.christmas_bookings AS PERMISSIVE FOR UPDATE TO authenticated
  USING (((rep_id = auth.uid()) AND (status = ANY (ARRAY['pending'::text, 'confirmed'::text]))))
  WITH CHECK (((rep_id = auth.uid()) AND (status = ANY (ARRAY['pending'::text, 'confirmed'::text]))));

CREATE POLICY christmas_bookings_update ON public.christmas_bookings AS PERMISSIVE FOR UPDATE TO authenticated
  USING ((christmas_current_role() = ANY (ARRAY['admin'::text, 'manager'::text])))
  WITH CHECK ((christmas_current_role() = ANY (ARRAY['admin'::text, 'manager'::text])));

CREATE POLICY christmas_destinations_read ON public.christmas_destinations AS PERMISSIVE FOR SELECT TO authenticated
  USING (((tenant_id = christmas_current_tenant()) OR (christmas_current_role() = ANY (ARRAY['admin'::text, 'manager'::text]))));

CREATE POLICY christmas_destinations_write ON public.christmas_destinations AS PERMISSIVE FOR ALL TO authenticated
  USING ((christmas_current_role() = ANY (ARRAY['admin'::text, 'manager'::text])))
  WITH CHECK ((christmas_current_role() = ANY (ARRAY['admin'::text, 'manager'::text])));

CREATE POLICY christmas_fee_overrides_read ON public.christmas_fee_overrides AS PERMISSIVE FOR SELECT TO authenticated
  USING (((tenant_id = christmas_current_tenant()) OR (christmas_current_role() = ANY (ARRAY['admin'::text, 'manager'::text]))));

CREATE POLICY christmas_fee_overrides_write ON public.christmas_fee_overrides AS PERMISSIVE FOR ALL TO authenticated
  USING ((christmas_current_role() = ANY (ARRAY['admin'::text, 'manager'::text])))
  WITH CHECK ((christmas_current_role() = ANY (ARRAY['admin'::text, 'manager'::text])));

CREATE POLICY christmas_global_settings_read ON public.christmas_global_settings AS PERMISSIVE FOR SELECT TO authenticated
  USING (((tenant_id = christmas_current_tenant()) OR (christmas_current_role() = ANY (ARRAY['admin'::text, 'manager'::text]))));

CREATE POLICY christmas_global_settings_write ON public.christmas_global_settings AS PERMISSIVE FOR ALL TO authenticated
  USING ((christmas_current_role() = ANY (ARRAY['admin'::text, 'manager'::text])))
  WITH CHECK ((christmas_current_role() = ANY (ARRAY['admin'::text, 'manager'::text])));

CREATE POLICY christmas_pallet_presets_read ON public.christmas_pallet_presets AS PERMISSIVE FOR SELECT TO authenticated
  USING (((tenant_id = christmas_current_tenant()) OR (christmas_current_role() = ANY (ARRAY['admin'::text, 'manager'::text]))));

CREATE POLICY christmas_pallet_presets_write ON public.christmas_pallet_presets AS PERMISSIVE FOR ALL TO authenticated
  USING ((christmas_current_role() = ANY (ARRAY['admin'::text, 'manager'::text])))
  WITH CHECK ((christmas_current_role() = ANY (ARRAY['admin'::text, 'manager'::text])));

CREATE POLICY christmas_products_read ON public.christmas_products AS PERMISSIVE FOR SELECT TO authenticated
  USING (((tenant_id = christmas_current_tenant()) OR (christmas_current_role() = ANY (ARRAY['admin'::text, 'manager'::text]))));

CREATE POLICY christmas_products_write ON public.christmas_products AS PERMISSIVE FOR ALL TO authenticated
  USING ((christmas_current_role() = ANY (ARRAY['admin'::text, 'manager'::text])))
  WITH CHECK ((christmas_current_role() = ANY (ARRAY['admin'::text, 'manager'::text])));

CREATE POLICY christmas_tenants_read ON public.christmas_tenants AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY christmas_tenants_write ON public.christmas_tenants AS PERMISSIVE FOR ALL TO authenticated
  USING ((christmas_current_role() = 'admin'::text))
  WITH CHECK ((christmas_current_role() = 'admin'::text));

CREATE POLICY christmas_profiles_read ON public.christmas_user_profiles AS PERMISSIVE FOR SELECT TO authenticated
  USING (((user_id = auth.uid()) OR (christmas_current_role() = ANY (ARRAY['admin'::text, 'manager'::text]))));

CREATE POLICY christmas_profiles_write ON public.christmas_user_profiles AS PERMISSIVE FOR ALL TO authenticated
  USING ((christmas_current_role() = 'admin'::text))
  WITH CHECK ((christmas_current_role() = 'admin'::text));

CREATE POLICY "Alerts ack" ON public.cl_alerts AS PERMISSIVE FOR UPDATE TO authenticated
  USING (((recipient_user_id = cl_warehouse_user_id()) OR ((recipient_user_id IS NULL) AND (warehouse_id = cl_user_warehouse()) AND cl_is_supervisor_or_manager())));

CREATE POLICY "Alerts insert" ON public.cl_alerts AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK (((warehouse_id = cl_user_warehouse()) OR (warehouse_id IS NULL) OR cl_is_supervisor_or_manager()));

CREATE POLICY "Alerts read recipient" ON public.cl_alerts AS PERMISSIVE FOR SELECT TO authenticated
  USING (((recipient_user_id = cl_warehouse_user_id()) OR ((recipient_user_id IS NULL) AND (warehouse_id = cl_user_warehouse()) AND cl_is_supervisor_or_manager())));

CREATE POLICY "Audit log insert self" ON public.cl_audit_log AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK ((performed_by = cl_warehouse_user_id()));

CREATE POLICY "Audit log read supervisor" ON public.cl_audit_log AS PERMISSIVE FOR SELECT TO authenticated
  USING (cl_is_supervisor_or_manager());

CREATE POLICY "Scan events insert self" ON public.cl_scan_events AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK ((scanned_by = cl_warehouse_user_id()));

CREATE POLICY "Scan events read" ON public.cl_scan_events AS PERMISSIVE FOR SELECT TO authenticated
  USING (((scanned_by = cl_warehouse_user_id()) OR cl_is_supervisor_or_manager()));

CREATE POLICY "Authenticated read warehouses" ON public.cl_warehouses AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "Warehouses bootstrap insert" ON public.cl_warehouses AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK (true);

CREATE POLICY cnc_all ON public.client_notify_contacts AS PERMISSIVE FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY client_visits_delete ON public.client_visits AS PERMISSIVE FOR DELETE TO public
  USING (((( SELECT u.role
   FROM users u
  WHERE (u.auth_user_id = auth.uid())) = ANY (ARRAY['Admin'::text])) OR ((( SELECT u.role
   FROM users u
  WHERE (u.auth_user_id = auth.uid())) = 'Manager'::text) AND (office = ( SELECT u.office
   FROM users u
  WHERE (u.auth_user_id = auth.uid())))) OR ((executive_id = ( SELECT u.id
   FROM users u
  WHERE (u.auth_user_id = auth.uid()))) AND (status = 'scheduled'::text))));

CREATE POLICY client_visits_insert ON public.client_visits AS PERMISSIVE FOR INSERT TO public
  WITH CHECK (((( SELECT u.role
   FROM users u
  WHERE (u.auth_user_id = auth.uid())) = ANY (ARRAY['Admin'::text, 'VP'::text, 'Manager'::text, 'Administration'::text])) OR (executive_id = ( SELECT u.id
   FROM users u
  WHERE (u.auth_user_id = auth.uid())))));

CREATE POLICY client_visits_insert_delegate ON public.client_visits AS PERMISSIVE FOR INSERT TO public
  WITH CHECK ((EXISTS ( SELECT 1
   FROM clients c
  WHERE ((c.id = client_visits.client_id) AND (c.deleted_at IS NULL) AND has_delegation_to(c.assigned_to)))));

CREATE POLICY client_visits_select ON public.client_visits AS PERMISSIVE FOR SELECT TO public
  USING (((( SELECT u.role
   FROM users u
  WHERE (u.auth_user_id = auth.uid())) = ANY (ARRAY['Admin'::text, 'VP'::text])) OR ((( SELECT u.role
   FROM users u
  WHERE (u.auth_user_id = auth.uid())) = ANY (ARRAY['Manager'::text, 'Administration'::text])) AND (office = ( SELECT u.office
   FROM users u
  WHERE (u.auth_user_id = auth.uid())))) OR (executive_id = ( SELECT u.id
   FROM users u
  WHERE (u.auth_user_id = auth.uid())))));

CREATE POLICY client_visits_select_delegate ON public.client_visits AS PERMISSIVE FOR SELECT TO public
  USING ((EXISTS ( SELECT 1
   FROM clients c
  WHERE ((c.id = client_visits.client_id) AND (c.deleted_at IS NULL) AND has_delegation_to(c.assigned_to)))));

CREATE POLICY client_visits_update ON public.client_visits AS PERMISSIVE FOR UPDATE TO public
  USING (((( SELECT u.role
   FROM users u
  WHERE (u.auth_user_id = auth.uid())) = ANY (ARRAY['Admin'::text, 'VP'::text])) OR ((( SELECT u.role
   FROM users u
  WHERE (u.auth_user_id = auth.uid())) = ANY (ARRAY['Manager'::text, 'Administration'::text])) AND (office = ( SELECT u.office
   FROM users u
  WHERE (u.auth_user_id = auth.uid())))) OR (executive_id = ( SELECT u.id
   FROM users u
  WHERE (u.auth_user_id = auth.uid())))));

CREATE POLICY client_visits_update_delegate ON public.client_visits AS PERMISSIVE FOR UPDATE TO public
  USING ((EXISTS ( SELECT 1
   FROM clients c
  WHERE ((c.id = client_visits.client_id) AND (c.deleted_at IS NULL) AND has_delegation_to(c.assigned_to)))))
  WITH CHECK ((EXISTS ( SELECT 1
   FROM clients c
  WHERE ((c.id = client_visits.client_id) AND (c.deleted_at IS NULL) AND has_delegation_to(c.assigned_to)))));

CREATE POLICY clients_delete_policy ON public.clients AS PERMISSIVE FOR DELETE TO authenticated
  USING (((( SELECT users.role
   FROM users
  WHERE (users.auth_user_id = ( SELECT auth.uid() AS uid))) = ANY (ARRAY['Admin'::text, 'Administration'::text])) OR ((assigned_to = ( SELECT users.id
   FROM users
  WHERE (users.auth_user_id = ( SELECT auth.uid() AS uid)))) AND (( SELECT users.role
   FROM users
  WHERE (users.auth_user_id = ( SELECT auth.uid() AS uid))) = ANY (ARRAY['Manager'::text, 'VP'::text])) AND (office = ( SELECT users.office
   FROM users
  WHERE (users.auth_user_id = ( SELECT auth.uid() AS uid)))))));

CREATE POLICY clients_insert_policy ON public.clients AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK (((office = ( SELECT users.office
   FROM users
  WHERE (users.auth_user_id = ( SELECT auth.uid() AS uid)))) OR (( SELECT users.role
   FROM users
  WHERE (users.auth_user_id = ( SELECT auth.uid() AS uid))) = 'Admin'::text)));

CREATE POLICY clients_select_policy ON public.clients AS PERMISSIVE FOR SELECT TO public
  USING (((deleted_at IS NULL) AND ((( SELECT u.role
   FROM users u
  WHERE (u.auth_user_id = auth.uid())) = ANY (ARRAY['Admin'::text, 'VP'::text])) OR ((( SELECT u.role
   FROM users u
  WHERE (u.auth_user_id = auth.uid())) = ANY (ARRAY['Manager'::text, 'Administration'::text])) AND (office = ( SELECT u.office
   FROM users u
  WHERE (u.auth_user_id = auth.uid())))) OR (assigned_to = ( SELECT u.id
   FROM users u
  WHERE (u.auth_user_id = auth.uid()))) OR (account_manager_id = ( SELECT u.id
   FROM users u
  WHERE (u.auth_user_id = auth.uid()))) OR (office = ( SELECT u.office
   FROM users u
  WHERE (u.auth_user_id = auth.uid()))) OR has_delegation_to(assigned_to) OR has_delegation_to(account_manager_id) OR user_can_see_office(office))));

CREATE POLICY clients_select_recycle_bin_policy ON public.clients AS PERMISSIVE FOR SELECT TO public
  USING (((deleted_at IS NOT NULL) AND (( SELECT u.role
   FROM users u
  WHERE (u.auth_user_id = auth.uid())) = ANY (ARRAY['Admin'::text, 'Administration'::text]))));

CREATE POLICY clients_update_policy ON public.clients AS PERMISSIVE FOR UPDATE TO public
  USING (((_user_role() = ANY (ARRAY['Admin'::text, 'VP'::text])) OR ((_user_role() = ANY (ARRAY['Manager'::text, 'Administration'::text])) AND (office = ( SELECT u.office
   FROM users u
  WHERE (u.auth_user_id = auth.uid())))) OR ((assigned_to = ( SELECT u.id
   FROM users u
  WHERE (u.auth_user_id = auth.uid()))) AND (_user_role() = 'Sales Executive'::text) AND (is_direct = false)) OR (account_manager_id = ( SELECT u.id
   FROM users u
  WHERE (u.auth_user_id = auth.uid()))) OR has_delegation_to(assigned_to) OR has_delegation_to(account_manager_id) OR user_can_see_office(office)));

CREATE POLICY "Closings delete own or elevated role" ON public.closings AS PERMISSIVE FOR DELETE TO authenticated
  USING (((created_by = ( SELECT u.auth_user_id
   FROM users u
  WHERE (u.auth_user_id = ( SELECT auth.uid() AS uid)))) OR (( SELECT u.role
   FROM users u
  WHERE (u.auth_user_id = ( SELECT auth.uid() AS uid))) = ANY (ARRAY['Admin'::text, 'Manager'::text, 'VP'::text]))));

CREATE POLICY "Closings insert own records" ON public.closings AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK ((created_by = ( SELECT auth.uid() AS uid)));

CREATE POLICY "Closings select by office or elevated role" ON public.closings AS PERMISSIVE FOR SELECT TO public
  USING (((( SELECT u.role
   FROM users u
  WHERE (u.auth_user_id = ( SELECT auth.uid() AS uid))) = ANY (ARRAY['Admin'::text, 'Manager'::text, 'VP'::text])) OR (office = ( SELECT u.office
   FROM users u
  WHERE (u.auth_user_id = ( SELECT auth.uid() AS uid)))) OR user_can_see_office(office)));

CREATE POLICY "Closings update own or elevated role" ON public.closings AS PERMISSIVE FOR UPDATE TO authenticated
  USING (((created_by = ( SELECT u.auth_user_id
   FROM users u
  WHERE (u.auth_user_id = ( SELECT auth.uid() AS uid)))) OR (( SELECT u.role
   FROM users u
  WHERE (u.auth_user_id = ( SELECT auth.uid() AS uid))) = ANY (ARRAY['Admin'::text, 'Manager'::text, 'VP'::text]))));

CREATE POLICY owner_all ON public.cmm_chat_messages AS PERMISSIVE FOR ALL TO authenticated
  USING (cmm_is_owner())
  WITH CHECK (cmm_is_owner());

CREATE POLICY owner_all ON public.cmm_client_aliases AS PERMISSIVE FOR ALL TO authenticated
  USING (cmm_is_owner())
  WITH CHECK (cmm_is_owner());

CREATE POLICY owner_all ON public.cmm_commission_policies AS PERMISSIVE FOR ALL TO authenticated
  USING (cmm_is_owner())
  WITH CHECK (cmm_is_owner());

CREATE POLICY owner_all ON public.cmm_context_notes AS PERMISSIVE FOR ALL TO authenticated
  USING (cmm_is_owner())
  WITH CHECK (cmm_is_owner());

CREATE POLICY owner_all ON public.cmm_dismissed_actions AS PERMISSIVE FOR ALL TO authenticated
  USING (cmm_is_owner())
  WITH CHECK (cmm_is_owner());

CREATE POLICY owner_all ON public.cmm_insights AS PERMISSIVE FOR ALL TO authenticated
  USING (cmm_is_owner())
  WITH CHECK (cmm_is_owner());

CREATE POLICY owner_all ON public.cmm_pending AS PERMISSIVE FOR ALL TO authenticated
  USING (cmm_is_owner())
  WITH CHECK (cmm_is_owner());

CREATE POLICY owner_all ON public.cmm_sellers AS PERMISSIVE FOR ALL TO authenticated
  USING (cmm_is_owner())
  WITH CHECK (cmm_is_owner());

CREATE POLICY owner_all ON public.cmm_targets AS PERMISSIVE FOR ALL TO authenticated
  USING (cmm_is_owner())
  WITH CHECK (cmm_is_owner());

CREATE POLICY owner_all ON public.cmm_transactions AS PERMISSIVE FOR ALL TO authenticated
  USING (cmm_is_owner())
  WITH CHECK (cmm_is_owner());

CREATE POLICY owner_all ON public.cmm_uploads AS PERMISSIVE FOR ALL TO authenticated
  USING (cmm_is_owner())
  WITH CHECK (cmm_is_owner());

CREATE POLICY "Authenticated users can view commodities" ON public.commodities AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "Managers can delete commodities" ON public.commodities AS PERMISSIVE FOR DELETE TO authenticated
  USING (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY "Managers can insert commodities" ON public.commodities AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY "Managers can update commodities" ON public.commodities AS PERMISSIVE FOR UPDATE TO authenticated
  USING (( SELECT can_modify_reference_data() AS can_modify_reference_data))
  WITH CHECK (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY alias_insert ON public.consignee_aliases AS PERMISSIVE FOR INSERT TO public
  WITH CHECK ((app_user_is_admin() OR (EXISTS ( SELECT 1
   FROM clients c
  WHERE ((c.id = consignee_aliases.client_id) AND app_can_see_shipment(c.assigned_to, c.office))))));

CREATE POLICY alias_select ON public.consignee_aliases AS PERMISSIVE FOR SELECT TO authenticated
  USING ((( SELECT auth.uid() AS uid) IS NOT NULL));

CREATE POLICY cons_aereo_prefs_all ON public.consolidado_aereo_prefs AS PERMISSIVE FOR ALL TO public
  USING (true)
  WITH CHECK (true);

CREATE POLICY cons_agente_excl_all ON public.consolidado_agente_exclusiones AS PERMISSIVE FOR ALL TO public
  USING (true)
  WITH CHECK (true);

CREATE POLICY cao_all ON public.consolidado_agente_overrides AS PERMISSIVE FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY cad_all ON public.consolidado_agentes_destino AS PERMISSIVE FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY cons_agrup_mem_all ON public.consolidado_agrupacion_memoria AS PERMISSIVE FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY consolidado_avisos_select ON public.consolidado_avisos AS PERMISSIVE FOR SELECT TO authenticated
  USING (((lower(cs_email) = lower(( SELECT u.email
   FROM users u
  WHERE (u.id = auth.uid())))) OR (EXISTS ( SELECT 1
   FROM users u
  WHERE ((u.id = auth.uid()) AND (u.role = ANY (ARRAY['Admin'::text, 'Manager'::text, 'VP'::text])))))));

CREATE POLICY consolidado_avisos_update ON public.consolidado_avisos AS PERMISSIVE FOR UPDATE TO authenticated
  USING (((lower(cs_email) = lower(( SELECT u.email
   FROM users u
  WHERE (u.id = auth.uid())))) OR (EXISTS ( SELECT 1
   FROM users u
  WHERE ((u.id = auth.uid()) AND (u.role = ANY (ARRAY['Admin'::text, 'Manager'::text, 'VP'::text])))))));

CREATE POLICY cap_read ON public.consolidado_capacidades AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY cons_cont_all ON public.consolidado_contenedores AS PERMISSIVE FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY cons_email_bitacora_all ON public.consolidado_email_bitacora AS PERMISSIVE FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY fcl_prefs_all ON public.consolidado_fcl_prefs AS PERMISSIVE FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY cons_grupos_all ON public.consolidado_grupos AS PERMISSIVE FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY clh_all ON public.consolidado_linea_hazmat AS PERMISSIVE FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY cons_linea_mov_all ON public.consolidado_linea_movimientos AS PERMISSIVE FOR ALL TO public
  USING (true)
  WITH CHECK (true);

CREATE POLICY cons_lin_piezas_all ON public.consolidado_linea_piezas AS PERMISSIVE FOR ALL TO public
  USING (true)
  WITH CHECK (true);

CREATE POLICY cons_lin_all ON public.consolidado_lineas AS PERMISSIVE FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY cons_servicios_select ON public.consolidado_servicios AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY cons_all ON public.consolidados AS PERMISSIVE FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY contacts_delete ON public.contacts AS PERMISSIVE FOR DELETE TO authenticated
  USING (((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.auth_user_id = ( SELECT auth.uid() AS uid)) AND ((users.role = ANY (ARRAY['Admin'::text, 'Administration'::text])) OR (EXISTS ( SELECT 1
           FROM clients
          WHERE ((clients.id = contacts.client_id) AND ((clients.assigned_to = users.id) OR ((users.role = 'Manager'::text) AND (users.office = clients.office)))))))))) OR (EXISTS ( SELECT 1
   FROM clients c
  WHERE ((c.id = contacts.client_id) AND user_can_see_office(c.office))))));

CREATE POLICY contacts_insert ON public.contacts AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK (((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.auth_user_id = ( SELECT auth.uid() AS uid)) AND ((users.role = ANY (ARRAY['Admin'::text, 'Administration'::text])) OR (EXISTS ( SELECT 1
           FROM clients
          WHERE ((clients.id = contacts.client_id) AND ((clients.assigned_to = users.id) OR ((users.role = 'Manager'::text) AND (users.office = clients.office)))))))))) OR (EXISTS ( SELECT 1
   FROM clients c
  WHERE ((c.id = contacts.client_id) AND user_can_see_office(c.office))))));

CREATE POLICY contacts_select ON public.contacts AS PERMISSIVE FOR SELECT TO public
  USING (((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.auth_user_id = ( SELECT auth.uid() AS uid)) AND ((users.role = ANY (ARRAY['Admin'::text, 'Administration'::text])) OR (EXISTS ( SELECT 1
           FROM clients
          WHERE ((clients.id = contacts.client_id) AND ((clients.assigned_to = users.id) OR ((users.role = 'Manager'::text) AND (users.office = clients.office)))))))))) OR (EXISTS ( SELECT 1
   FROM clients c
  WHERE ((c.id = contacts.client_id) AND user_can_see_office(c.office))))));

CREATE POLICY contacts_update ON public.contacts AS PERMISSIVE FOR UPDATE TO authenticated
  USING (((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.auth_user_id = ( SELECT auth.uid() AS uid)) AND ((users.role = ANY (ARRAY['Admin'::text, 'Administration'::text])) OR (EXISTS ( SELECT 1
           FROM clients
          WHERE ((clients.id = contacts.client_id) AND ((clients.assigned_to = users.id) OR ((users.role = 'Manager'::text) AND (users.office = clients.office)))))))))) OR (EXISTS ( SELECT 1
   FROM clients c
  WHERE ((c.id = contacts.client_id) AND user_can_see_office(c.office))))))
  WITH CHECK ((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.auth_user_id = ( SELECT auth.uid() AS uid)) AND ((users.role = ANY (ARRAY['Admin'::text, 'Administration'::text])) OR (EXISTS ( SELECT 1
           FROM clients
          WHERE ((clients.id = contacts.client_id) AND ((clients.assigned_to = users.id) OR ((users.role = 'Manager'::text) AND (users.office = clients.office)))))))))));

CREATE POLICY "Users can manage container files" ON public.container_files AS PERMISSIVE FOR ALL TO authenticated
  USING ((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.id = ( SELECT auth.uid() AS uid)) AND ((users.office = 'Miami'::text) OR (users.role = ANY (ARRAY['Admin'::text, 'Manager'::text])))))));

CREATE POLICY "CLR insert" ON public.container_load_reports AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK (((generated_by = cl_warehouse_user_id()) OR cl_is_supervisor_or_manager()));

CREATE POLICY "CLR read" ON public.container_load_reports AS PERMISSIVE FOR SELECT TO authenticated
  USING ((EXISTS ( SELECT 1
   FROM manifest_sources s
  WHERE ((s.id = container_load_reports.manifest_source_id) AND ((s.warehouse_id = cl_user_warehouse()) OR cl_is_supervisor_or_manager())))));

CREATE POLICY "Authenticated users can add container types" ON public.container_types AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK (((( SELECT auth.uid() AS uid) IS NOT NULL) AND (created_by = ( SELECT auth.uid() AS uid))));

CREATE POLICY "Authenticated users can view container types" ON public.container_types AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "Managers can delete contract documents" ON public.contract_documents AS PERMISSIVE FOR DELETE TO authenticated
  USING (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY "Managers can insert contract documents" ON public.contract_documents AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY "Managers can update contract documents" ON public.contract_documents AS PERMISSIVE FOR UPDATE TO authenticated
  USING (( SELECT can_modify_reference_data() AS can_modify_reference_data))
  WITH CHECK (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY "Users can view contract documents" ON public.contract_documents AS PERMISSIVE FOR SELECT TO public
  USING (true);

CREATE POLICY "Authenticated users can view update lines" ON public.contract_update_lines AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY contract_update_lines_insert_policy ON public.contract_update_lines AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK ((( SELECT auth.uid() AS uid) IS NOT NULL));

CREATE POLICY contract_update_lines_update_policy ON public.contract_update_lines AS PERMISSIVE FOR UPDATE TO authenticated
  USING ((( SELECT auth.uid() AS uid) IS NOT NULL))
  WITH CHECK ((( SELECT auth.uid() AS uid) IS NOT NULL));

CREATE POLICY "Authenticated users can view contract updates" ON public.contract_updates AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY contract_updates_insert_policy ON public.contract_updates AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK ((( SELECT auth.uid() AS uid) IS NOT NULL));

CREATE POLICY contract_updates_update_policy ON public.contract_updates AS PERMISSIVE FOR UPDATE TO authenticated
  USING ((( SELECT auth.uid() AS uid) IS NOT NULL))
  WITH CHECK ((( SELECT auth.uid() AS uid) IS NOT NULL));

CREATE POLICY "Authenticated users can view contracts" ON public.contracts AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "Managers can delete contracts" ON public.contracts AS PERMISSIVE FOR DELETE TO authenticated
  USING (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY "Managers can insert contracts" ON public.contracts AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY "Managers can update contracts" ON public.contracts AS PERMISSIVE FOR UPDATE TO authenticated
  USING (( SELECT can_modify_reference_data() AS can_modify_reference_data))
  WITH CHECK (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY coord_modify ON public.coordination_tasks AS PERMISSIVE FOR ALL TO public
  USING ((app_user_is_admin() OR ((client_id IS NOT NULL) AND ((client_id IN ( SELECT app_cs_client_ids() AS app_cs_client_ids)) OR (EXISTS ( SELECT 1
   FROM clients c
  WHERE ((c.id = coordination_tasks.client_id) AND app_can_see_shipment(c.assigned_to, c.office)))))) OR ((client_id IS NULL) AND (shipment_id IS NOT NULL) AND (EXISTS ( SELECT 1
   FROM shipments s
  WHERE ((s.id = coordination_tasks.shipment_id) AND (app_can_see_shipment(s.sales_executive_id, s.office) OR (s.cs_assigned_to = app_current_user_id()) OR (s.client_id IN ( SELECT app_cs_client_ids() AS app_cs_client_ids))))))) OR ((client_id IS NULL) AND (shipment_id IS NULL) AND (cs_assigned_to = app_current_user_id()))));

CREATE POLICY coord_select ON public.coordination_tasks AS PERMISSIVE FOR SELECT TO public
  USING ((app_user_is_admin() OR ((client_id IS NOT NULL) AND ((client_id IN ( SELECT app_cs_client_ids() AS app_cs_client_ids)) OR (EXISTS ( SELECT 1
   FROM clients c
  WHERE ((c.id = coordination_tasks.client_id) AND app_can_see_shipment(c.assigned_to, c.office)))))) OR ((client_id IS NULL) AND (shipment_id IS NOT NULL) AND (EXISTS ( SELECT 1
   FROM shipments s
  WHERE ((s.id = coordination_tasks.shipment_id) AND (app_can_see_shipment(s.sales_executive_id, s.office) OR (s.cs_assigned_to = app_current_user_id()) OR (s.client_id IN ( SELECT app_cs_client_ids() AS app_cs_client_ids))))))) OR ((client_id IS NULL) AND (shipment_id IS NULL) AND (cs_assigned_to = app_current_user_id()))));

CREATE POLICY credit_documents_delete_policy ON public.credit_documents AS PERMISSIVE FOR DELETE TO authenticated
  USING ((( SELECT users.role
   FROM users
  WHERE (users.id = ( SELECT auth.uid() AS uid))) = 'Admin'::text));

CREATE POLICY credit_documents_insert_policy ON public.credit_documents AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK ((( SELECT auth.uid() AS uid) IS NOT NULL));

CREATE POLICY credit_documents_select_policy ON public.credit_documents AS PERMISSIVE FOR SELECT TO public
  USING (((get_current_user_role() = ANY (ARRAY['Admin'::text, 'Administration'::text, 'Manager'::text])) OR (EXISTS ( SELECT 1
   FROM credit_requests cr
  WHERE ((cr.id = credit_documents.credit_request_id) AND ((cr.office = get_current_user_office()) OR (cr.requested_by = get_current_user_id()))))) OR (EXISTS ( SELECT 1
   FROM (credit_requests cr
     JOIN clients c ON ((c.id = cr.client_id)))
  WHERE ((cr.id = credit_documents.credit_request_id) AND user_can_see_office(c.office))))));

CREATE POLICY credit_notify_finance_select ON public.credit_notify_finance AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY credit_notify_log_select ON public.credit_notify_log AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY credit_requests_delete_policy ON public.credit_requests AS PERMISSIVE FOR DELETE TO authenticated
  USING ((( SELECT u.role
   FROM users u
  WHERE (u.auth_user_id = ( SELECT auth.uid() AS uid))) = 'Admin'::text));

CREATE POLICY credit_requests_insert_policy ON public.credit_requests AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK ((( SELECT auth.uid() AS uid) IS NOT NULL));

CREATE POLICY credit_requests_select_policy ON public.credit_requests AS PERMISSIVE FOR SELECT TO public
  USING (((( SELECT u.role
   FROM users u
  WHERE (u.auth_user_id = ( SELECT auth.uid() AS uid))) = ANY (ARRAY['Admin'::text, 'Administration'::text])) OR (office = ( SELECT u.office
   FROM users u
  WHERE (u.auth_user_id = ( SELECT auth.uid() AS uid)))) OR user_can_see_office(( SELECT c.office
   FROM clients c
  WHERE (c.id = credit_requests.client_id)))));

CREATE POLICY credit_requests_update_policy ON public.credit_requests AS PERMISSIVE FOR UPDATE TO authenticated
  USING ((( SELECT u.role
   FROM users u
  WHERE (u.auth_user_id = ( SELECT auth.uid() AS uid))) = ANY (ARRAY['Admin'::text, 'Administration'::text, 'Manager'::text])));

CREATE POLICY cs_assign_modify ON public.cs_assignments AS PERMISSIVE FOR ALL TO public
  USING ((app_user_is_admin() OR app_user_is_manager()));

CREATE POLICY cs_assign_select ON public.cs_assignments AS PERMISSIVE FOR SELECT TO public
  USING ((app_user_is_admin() OR app_user_is_manager() OR (cs_user_id = app_current_user_id()) OR (sales_executive_id = app_current_user_id())));

CREATE POLICY cs_cuentas_habilitadas_admin ON public.cs_cuentas_habilitadas AS PERMISSIVE FOR ALL TO authenticated
  USING (app_user_is_admin())
  WITH CHECK (app_user_is_admin());

CREATE POLICY cs_cuentas_habilitadas_select ON public.cs_cuentas_habilitadas AS PERMISSIVE FOR SELECT TO authenticated
  USING (((cs_user_id = app_current_user_id()) OR app_user_is_admin()));

CREATE POLICY api_insert ON public.cxc_send_log AS PERMISSIVE FOR INSERT TO anon
  WITH CHECK (true);

CREATE POLICY auth_select ON public.cxc_send_log AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY dashboard_agents_select ON public.dashboard_agents AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY dashboard_clients_select ON public.dashboard_clients AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY dashboard_countries_select ON public.dashboard_countries AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY dashboard_monthly_client_select ON public.dashboard_monthly_client AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY dashboard_pnl_flow_select ON public.dashboard_pnl_flow AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY dashboard_pnl_monthly_select ON public.dashboard_pnl_monthly AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "Managers can delete deal quotes" ON public.deal_quotes AS PERMISSIVE FOR DELETE TO authenticated
  USING ((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.id = ( SELECT auth.uid() AS uid)) AND (users.role = ANY (ARRAY['Admin'::text, 'Manager'::text]))))));

CREATE POLICY "Users can create quotes for their deals or all if admin/manager" ON public.deal_quotes AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK ((EXISTS ( SELECT 1
   FROM deals
  WHERE ((deals.id = deal_quotes.deal_id) AND ((deals.assigned_to = ( SELECT auth.uid() AS uid)) OR (EXISTS ( SELECT 1
           FROM users
          WHERE ((users.id = ( SELECT auth.uid() AS uid)) AND (users.role = ANY (ARRAY['Admin'::text, 'Manager'::text]))))))))));

CREATE POLICY "Users can update quotes for their deals or all if admin/manager" ON public.deal_quotes AS PERMISSIVE FOR UPDATE TO authenticated
  USING ((EXISTS ( SELECT 1
   FROM deals
  WHERE ((deals.id = deal_quotes.deal_id) AND ((deals.assigned_to = ( SELECT auth.uid() AS uid)) OR (EXISTS ( SELECT 1
           FROM users
          WHERE ((users.id = ( SELECT auth.uid() AS uid)) AND (users.role = ANY (ARRAY['Admin'::text, 'Manager'::text]))))))))));

CREATE POLICY "Users can view quotes for their deals or all if admin/manager" ON public.deal_quotes AS PERMISSIVE FOR SELECT TO authenticated
  USING ((EXISTS ( SELECT 1
   FROM deals
  WHERE ((deals.id = deal_quotes.deal_id) AND ((deals.assigned_to = ( SELECT auth.uid() AS uid)) OR (EXISTS ( SELECT 1
           FROM users
          WHERE ((users.id = ( SELECT auth.uid() AS uid)) AND (users.role = ANY (ARRAY['Admin'::text, 'Manager'::text]))))))))));

CREATE POLICY "Admins and Managers can delete deals" ON public.deals AS PERMISSIVE FOR DELETE TO authenticated
  USING ((_user_role() = ANY (ARRAY['Admin'::text, 'Manager'::text, 'Administration'::text])));

CREATE POLICY "Users can create deals in their office" ON public.deals AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK ((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.id = ( SELECT auth.uid() AS uid)) AND ((users.role = 'Admin'::text) OR (users.office = deals.office))))));

CREATE POLICY "Users can update their deals or all if admin/manager" ON public.deals AS PERMISSIVE FOR UPDATE TO authenticated
  USING (((assigned_to = ( SELECT users.id
   FROM users
  WHERE (users.auth_user_id = ( SELECT auth.uid() AS uid)))) OR (_user_role() = ANY (ARRAY['Admin'::text, 'Manager'::text])) OR has_delegation_to(assigned_to)));

CREATE POLICY "Users can view their deals or all if admin/manager" ON public.deals AS PERMISSIVE FOR SELECT TO authenticated
  USING (((assigned_to = ( SELECT users.id
   FROM users
  WHERE (users.auth_user_id = ( SELECT auth.uid() AS uid)))) OR (_user_role() = ANY (ARRAY['Admin'::text, 'Manager'::text])) OR has_delegation_to(assigned_to)));

CREATE POLICY "Users can manage dispatches" ON public.dispatches AS PERMISSIVE FOR ALL TO authenticated
  USING ((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.id = ( SELECT auth.uid() AS uid)) AND ((users.office = 'Miami'::text) OR (users.role = ANY (ARRAY['Admin'::text, 'Manager'::text])))))));

CREATE POLICY drayage_rates_read ON public.drayage_rates AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY ec_flc_delete ON public.ec_fcl_local_charges AS PERMISSIVE FOR DELETE TO authenticated
  USING (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY ec_flc_insert ON public.ec_fcl_local_charges AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK (true);

CREATE POLICY ec_flc_select ON public.ec_fcl_local_charges AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY ec_flc_update ON public.ec_fcl_local_charges AS PERMISSIVE FOR UPDATE TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY ec_flch_select ON public.ec_fcl_local_charges_history AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "Anyone can read email templates" ON public.email_templates AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "Only admins can delete email templates" ON public.email_templates AS PERMISSIVE FOR DELETE TO authenticated
  USING ((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.auth_user_id = ( SELECT auth.uid() AS uid)) AND (users.role = ANY (ARRAY['Admin'::text, 'Administration'::text]))))));

CREATE POLICY "Only admins can insert email templates" ON public.email_templates AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK ((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.auth_user_id = ( SELECT auth.uid() AS uid)) AND (users.role = ANY (ARRAY['Admin'::text, 'Administration'::text]))))));

CREATE POLICY "Only admins can update email templates" ON public.email_templates AS PERMISSIVE FOR UPDATE TO authenticated
  USING ((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.auth_user_id = ( SELECT auth.uid() AS uid)) AND (users.role = ANY (ARRAY['Admin'::text, 'Administration'::text]))))))
  WITH CHECK ((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.auth_user_id = ( SELECT auth.uid() AS uid)) AND (users.role = ANY (ARRAY['Admin'::text, 'Administration'::text]))))));

CREATE POLICY "Authenticated users can view equipment_types" ON public.equipment_types AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "Managers can delete equipment_types" ON public.equipment_types AS PERMISSIVE FOR DELETE TO authenticated
  USING (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY "Managers can insert equipment_types" ON public.equipment_types AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY "Managers can update equipment_types" ON public.equipment_types AS PERMISSIVE FOR UPDATE TO authenticated
  USING (( SELECT can_modify_reference_data() AS can_modify_reference_data))
  WITH CHECK (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY "Users can manage external containers" ON public.external_containers AS PERMISSIVE FOR ALL TO authenticated
  USING ((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.id = ( SELECT auth.uid() AS uid)) AND ((users.office = 'Miami'::text) OR (users.role = ANY (ARRAY['Admin'::text, 'Manager'::text])))))));

CREATE POLICY fact_orders_select ON public.fact_orders AS PERMISSIVE FOR SELECT TO public
  USING ((EXISTS ( SELECT 1
   FROM shipments s
  WHERE (s.id = fact_orders.shipment_id))));

CREATE POLICY fact_orders_update ON public.fact_orders AS PERMISSIVE FOR UPDATE TO public
  USING ((EXISTS ( SELECT 1
   FROM shipments s
  WHERE (s.id = fact_orders.shipment_id))));

CREATE POLICY fcl_semanal_select ON public.fcl_semanal AS PERMISSIVE FOR SELECT TO authenticated
  USING ((app_can('operaciones'::text, 'view'::text) OR app_can('cs'::text, 'view'::text)));

CREATE POLICY fcl_semanal_write ON public.fcl_semanal AS PERMISSIVE FOR ALL TO authenticated
  USING (app_can('operaciones'::text, 'edit'::text))
  WITH CHECK (app_can('operaciones'::text, 'edit'::text));

CREATE POLICY fa_select ON public.finanzas_access AS PERMISSIVE FOR SELECT TO authenticated
  USING (((user_id = ( SELECT u.id
   FROM users u
  WHERE (u.auth_user_id = auth.uid()))) OR app_finanzas_can_grant()));

CREATE POLICY fa_service_all ON public.finanzas_access AS PERMISSIVE FOR ALL TO service_role
  USING (true)
  WITH CHECK (true);

CREATE POLICY fbm_insert ON public.finanzas_bank_match AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK (((match_type = 'manual'::text) AND (office_id IN ( SELECT o.id
   FROM (offices o
     JOIN unnest(app_finanzas_offices()) c(c) ON ((o.code = c.c)))))));

CREATE POLICY fbm_select ON public.finanzas_bank_match AS PERMISSIVE FOR SELECT TO authenticated
  USING ((office_id IN ( SELECT o.id
   FROM (offices o
     JOIN unnest(app_finanzas_offices()) c(c) ON ((o.code = c.c))))));

CREATE POLICY fbm_update ON public.finanzas_bank_match AS PERMISSIVE FOR UPDATE TO authenticated
  USING ((office_id IN ( SELECT o.id
   FROM (offices o
     JOIN unnest(app_finanzas_offices()) c(c) ON ((o.code = c.c))))))
  WITH CHECK ((office_id IN ( SELECT o.id
   FROM (offices o
     JOIN unnest(app_finanzas_offices()) c(c) ON ((o.code = c.c))))));

CREATE POLICY fcr_select ON public.finanzas_config_recurrente AS PERMISSIVE FOR SELECT TO authenticated
  USING ((office_id IN ( SELECT o.id
   FROM (offices o
     JOIN unnest(app_finanzas_offices()) c(c) ON ((o.code = c.c))))));

CREATE POLICY deuda_externa_read ON public.finanzas_deuda_externa AS PERMISSIVE FOR SELECT TO authenticated
  USING ((office_id IN ( SELECT o.id
   FROM (offices o
     JOIN unnest(app_finanzas_offices()) c(c) ON ((o.code = c.c))))));

CREATE POLICY fe_select ON public.finanzas_eeff_pl AS PERMISSIVE FOR SELECT TO authenticated
  USING ((office_id IN ( SELECT o.id
   FROM (offices o
     JOIN unnest(app_finanzas_offices()) c(c) ON ((o.code = c.c))))));

CREATE POLICY ffr_select ON public.finanzas_forecast_recurrente AS PERMISSIVE FOR SELECT TO authenticated
  USING ((office_id IN ( SELECT o.id
   FROM (offices o
     JOIN unnest(app_finanzas_offices()) c(c) ON ((o.code = c.c))))));

CREATE POLICY finanzas_wall_select ON public.finanzas_fx_rate AS PERMISSIVE FOR SELECT TO authenticated
  USING ((COALESCE(array_length(( SELECT app_finanzas_offices() AS app_finanzas_offices), 1), 0) > 0));

CREATE POLICY service_all ON public.finanzas_fx_rate AS PERMISSIVE FOR ALL TO service_role
  USING (true)
  WITH CHECK (true);

CREATE POLICY fp_select ON public.finanzas_presupuesto AS PERMISSIVE FOR SELECT TO authenticated
  USING ((office_id IN ( SELECT o.id
   FROM (offices o
     JOIN unnest(app_finanzas_offices()) c(c) ON ((o.code = c.c))))));

CREATE POLICY frz_select ON public.finanzas_rc_por_zarpar AS PERMISSIVE FOR SELECT TO authenticated
  USING ((office_id IN ( SELECT o.id
   FROM (offices o
     JOIN unnest(app_finanzas_offices()) c(c) ON ((o.code = c.c))))));

CREATE POLICY frz_write ON public.finanzas_rc_por_zarpar AS PERMISSIVE FOR ALL TO authenticated
  USING ((office_id IN ( SELECT o.id
   FROM (offices o
     JOIN unnest(app_finanzas_offices()) c(c) ON ((o.code = c.c))))))
  WITH CHECK ((office_id IN ( SELECT o.id
   FROM (offices o
     JOIN unnest(app_finanzas_offices()) c(c) ON ((o.code = c.c))))));

CREATE POLICY finanzas_read ON public.finanzas_sync_state AS PERMISSIVE FOR SELECT TO authenticated
  USING ((COALESCE(array_length(( SELECT app_finanzas_offices() AS app_finanzas_offices), 1), 0) > 0));

CREATE POLICY service_all ON public.finanzas_sync_state AS PERMISSIVE FOR ALL TO service_role
  USING (true)
  WITH CHECK (true);

CREATE POLICY carrier_alias_lectura ON public.freight_carrier_aliases AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY port_alias_lectura ON public.freight_port_aliases AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can view freight_routes" ON public.freight_routes AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "Managers can delete freight_routes" ON public.freight_routes AS PERMISSIVE FOR DELETE TO authenticated
  USING (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY "Managers can insert freight_routes" ON public.freight_routes AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY "Managers can update freight_routes" ON public.freight_routes AS PERMISSIVE FOR UPDATE TO authenticated
  USING (( SELECT can_modify_reference_data() AS can_modify_reference_data))
  WITH CHECK (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY fx_rates_read ON public.fx_rates AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY gloval_assets_admin_write ON public.gloval_assets AS PERMISSIVE FOR ALL TO authenticated
  USING ((_user_role() = 'Admin'::text))
  WITH CHECK ((_user_role() = 'Admin'::text));

CREATE POLICY gloval_assets_select ON public.gloval_assets AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY impersonation_log_admin_read ON public.impersonation_log AS PERMISSIVE FOR SELECT TO public
  USING ((EXISTS ( SELECT 1
   FROM users u
  WHERE ((u.auth_user_id = auth.uid()) AND (u.role = ANY (ARRAY['Admin'::text, 'VP'::text]))))));

CREATE POLICY impersonation_log_no_write ON public.impersonation_log AS PERMISSIVE FOR ALL TO authenticated
  USING (false)
  WITH CHECK (false);

CREATE POLICY "inhouse_dashboards insert" ON public.inhouse_dashboards AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK (inhouse_can_touch_client(client_id));

CREATE POLICY "inhouse_dashboards select" ON public.inhouse_dashboards AS PERMISSIVE FOR SELECT TO authenticated
  USING (inhouse_can_touch_client(client_id));

CREATE POLICY "inhouse_dashboards update" ON public.inhouse_dashboards AS PERMISSIVE FOR UPDATE TO authenticated
  USING (inhouse_can_touch_client(client_id))
  WITH CHECK (inhouse_can_touch_client(client_id));

CREATE POLICY "inhouse_despachos delete" ON public.inhouse_despachos AS PERMISSIVE FOR DELETE TO authenticated
  USING (inhouse_is_supervisor());

CREATE POLICY "inhouse_despachos insert" ON public.inhouse_despachos AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK (inhouse_can_touch_client(client_id));

CREATE POLICY "inhouse_despachos select" ON public.inhouse_despachos AS PERMISSIVE FOR SELECT TO authenticated
  USING (inhouse_can_touch_client(client_id));

CREATE POLICY "inhouse_despachos update" ON public.inhouse_despachos AS PERMISSIVE FOR UPDATE TO authenticated
  USING (inhouse_can_touch_client(client_id))
  WITH CHECK (inhouse_can_touch_client(client_id));

CREATE POLICY "inhouse_documentos insert" ON public.inhouse_documentos AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK ((EXISTS ( SELECT 1
   FROM inhouse_despachos d
  WHERE ((d.id = inhouse_documentos.despacho_id) AND inhouse_can_touch_client(d.client_id)))));

CREATE POLICY "inhouse_documentos select" ON public.inhouse_documentos AS PERMISSIVE FOR SELECT TO authenticated
  USING ((EXISTS ( SELECT 1
   FROM inhouse_despachos d
  WHERE ((d.id = inhouse_documentos.despacho_id) AND inhouse_can_touch_client(d.client_id)))));

CREATE POLICY "inhouse_profiles insert" ON public.inhouse_profiles AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK (inhouse_is_supervisor());

CREATE POLICY "inhouse_profiles select" ON public.inhouse_profiles AS PERMISSIVE FOR SELECT TO authenticated
  USING (inhouse_can_touch_client(client_id));

CREATE POLICY "inhouse_profiles update" ON public.inhouse_profiles AS PERMISSIVE FOR UPDATE TO authenticated
  USING (inhouse_is_supervisor())
  WITH CHECK (inhouse_is_supervisor());

CREATE POLICY inland_addons_read ON public.inland_addons AS PERMISSIVE FOR SELECT TO anon, authenticated
  USING (true);

CREATE POLICY manage_area_rates_admin ON public.inland_carrier_area_rates AS PERMISSIVE FOR ALL TO authenticated
  USING ((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.id = auth.uid()) AND (users.role = ANY (ARRAY['Admin'::text, 'Manager'::text]))))))
  WITH CHECK ((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.id = auth.uid()) AND (users.role = ANY (ARRAY['Admin'::text, 'Manager'::text]))))));

CREATE POLICY read_authenticated ON public.inland_carrier_area_rates AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY manage_rates_admin ON public.inland_carrier_rates AS PERMISSIVE FOR ALL TO authenticated
  USING ((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.id = auth.uid()) AND (users.role = ANY (ARRAY['Admin'::text, 'Manager'::text]))))))
  WITH CHECK ((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.id = auth.uid()) AND (users.role = ANY (ARRAY['Admin'::text, 'Manager'::text]))))));

CREATE POLICY read_authenticated ON public.inland_carrier_rates AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY manage_zips_admin ON public.inland_carrier_zips AS PERMISSIVE FOR ALL TO authenticated
  USING ((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.id = auth.uid()) AND (users.role = ANY (ARRAY['Admin'::text, 'Manager'::text]))))))
  WITH CHECK ((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.id = auth.uid()) AND (users.role = ANY (ARRAY['Admin'::text, 'Manager'::text]))))));

CREATE POLICY read_authenticated ON public.inland_carrier_zips AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY manage_carriers_admin ON public.inland_carriers AS PERMISSIVE FOR ALL TO authenticated
  USING ((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.id = auth.uid()) AND (users.role = ANY (ARRAY['Admin'::text, 'Manager'::text]))))))
  WITH CHECK ((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.id = auth.uid()) AND (users.role = ANY (ARRAY['Admin'::text, 'Manager'::text]))))));

CREATE POLICY read_authenticated ON public.inland_carriers AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY quotes_insert_own ON public.inland_quotes AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK ((created_by = auth.uid()));

CREATE POLICY quotes_select_own_or_manager ON public.inland_quotes AS PERMISSIVE FOR SELECT TO authenticated
  USING (((created_by = auth.uid()) OR (EXISTS ( SELECT 1
   FROM users
  WHERE ((users.id = auth.uid()) AND (users.role = ANY (ARRAY['Admin'::text, 'Manager'::text])))))));

CREATE POLICY job_applicants_rw_staff ON public.job_applicants AS PERMISSIVE FOR ALL TO authenticated
  USING ((app_user_is_admin() OR (app_current_user_office() = 'USA'::text)))
  WITH CHECK ((app_user_is_admin() OR (app_current_user_office() = 'USA'::text)));

CREATE POLICY lcl_admin_emails_read ON public.lcl_admin_emails AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY lcl_lanes_read ON public.lcl_lanes AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY lcl_lanes_write ON public.lcl_lanes AS PERMISSIVE FOR ALL TO authenticated
  USING (is_lcl_admin())
  WITH CHECK (is_lcl_admin());

CREATE POLICY lcl_settings_read ON public.lcl_settings AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY lcl_settings_write ON public.lcl_settings AS PERMISSIVE FOR ALL TO authenticated
  USING (is_lcl_admin())
  WITH CHECK (is_lcl_admin());

CREATE POLICY lcl_surcharges_read ON public.lcl_surcharges AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY lcl_surcharges_write ON public.lcl_surcharges AS PERMISSIVE FOR ALL TO authenticated
  USING (is_lcl_admin())
  WITH CHECK (is_lcl_admin());

CREATE POLICY "liq allowed users" ON public.liq_agent_invoice_lines AS PERMISSIVE FOR ALL TO authenticated
  USING ((_user_email() = ANY (ARRAY['avaldano@glovalgroup.com'::text, 'janeth@glovalecuador.com'::text, 'contable2@glovalecuador.com'::text])))
  WITH CHECK ((_user_email() = ANY (ARRAY['avaldano@glovalgroup.com'::text, 'janeth@glovalecuador.com'::text, 'contable2@glovalecuador.com'::text])));

CREATE POLICY "liq allowed users" ON public.liq_agent_invoices AS PERMISSIVE FOR ALL TO authenticated
  USING ((_user_email() = ANY (ARRAY['avaldano@glovalgroup.com'::text, 'janeth@glovalecuador.com'::text, 'contable2@glovalecuador.com'::text])))
  WITH CHECK ((_user_email() = ANY (ARRAY['avaldano@glovalgroup.com'::text, 'janeth@glovalecuador.com'::text, 'contable2@glovalecuador.com'::text])));

CREATE POLICY "liq allowed users" ON public.liq_charge_catalog AS PERMISSIVE FOR ALL TO authenticated
  USING ((_user_email() = ANY (ARRAY['avaldano@glovalgroup.com'::text, 'janeth@glovalecuador.com'::text, 'contable2@glovalecuador.com'::text])))
  WITH CHECK ((_user_email() = ANY (ARRAY['avaldano@glovalgroup.com'::text, 'janeth@glovalecuador.com'::text, 'contable2@glovalecuador.com'::text])));

CREATE POLICY "liq allowed users" ON public.liq_documents AS PERMISSIVE FOR ALL TO authenticated
  USING ((_user_email() = ANY (ARRAY['avaldano@glovalgroup.com'::text, 'janeth@glovalecuador.com'::text, 'contable2@glovalecuador.com'::text])))
  WITH CHECK ((_user_email() = ANY (ARRAY['avaldano@glovalgroup.com'::text, 'janeth@glovalecuador.com'::text, 'contable2@glovalecuador.com'::text])));

CREATE POLICY "liq allowed users" ON public.liq_settlement_lines AS PERMISSIVE FOR ALL TO authenticated
  USING ((_user_email() = ANY (ARRAY['avaldano@glovalgroup.com'::text, 'janeth@glovalecuador.com'::text, 'contable2@glovalecuador.com'::text])))
  WITH CHECK ((_user_email() = ANY (ARRAY['avaldano@glovalgroup.com'::text, 'janeth@glovalecuador.com'::text, 'contable2@glovalecuador.com'::text])));

CREATE POLICY "liq allowed users" ON public.liq_settlements AS PERMISSIVE FOR ALL TO authenticated
  USING ((_user_email() = ANY (ARRAY['avaldano@glovalgroup.com'::text, 'janeth@glovalecuador.com'::text, 'contable2@glovalecuador.com'::text])))
  WITH CHECK ((_user_email() = ANY (ARRAY['avaldano@glovalgroup.com'::text, 'janeth@glovalecuador.com'::text, 'contable2@glovalecuador.com'::text])));

CREATE POLICY "liq allowed users" ON public.liq_shipments AS PERMISSIVE FOR ALL TO authenticated
  USING ((_user_email() = ANY (ARRAY['avaldano@glovalgroup.com'::text, 'janeth@glovalecuador.com'::text, 'contable2@glovalecuador.com'::text])))
  WITH CHECK ((_user_email() = ANY (ARRAY['avaldano@glovalgroup.com'::text, 'janeth@glovalecuador.com'::text, 'contable2@glovalecuador.com'::text])));

CREATE POLICY "liq allowed users" ON public.liq_tariffs AS PERMISSIVE FOR ALL TO authenticated
  USING ((_user_email() = ANY (ARRAY['avaldano@glovalgroup.com'::text, 'janeth@glovalecuador.com'::text, 'contable2@glovalecuador.com'::text])))
  WITH CHECK ((_user_email() = ANY (ARRAY['avaldano@glovalgroup.com'::text, 'janeth@glovalecuador.com'::text, 'contable2@glovalecuador.com'::text])));

CREATE POLICY "Loading exc insert" ON public.loading_exceptions AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK ((raised_by = cl_warehouse_user_id()));

CREATE POLICY "Loading exc read" ON public.loading_exceptions AS PERMISSIVE FOR SELECT TO authenticated
  USING (((raised_by = cl_warehouse_user_id()) OR cl_is_supervisor_or_manager()));

CREATE POLICY "Loading exc update" ON public.loading_exceptions AS PERMISSIVE FOR UPDATE TO authenticated
  USING (cl_is_supervisor_or_manager());

CREATE POLICY lm_modify ON public.loading_materials AS PERMISSIVE FOR ALL TO authenticated
  USING ((cl_is_supervisor_or_manager() AND ((warehouse_id IS NULL) OR (warehouse_id = cl_user_warehouse()))))
  WITH CHECK ((cl_is_supervisor_or_manager() AND ((warehouse_id IS NULL) OR (warehouse_id = cl_user_warehouse()))));

CREATE POLICY lm_select ON public.loading_materials AS PERMISSIVE FOR SELECT TO authenticated
  USING (((active = true) AND ((warehouse_id IS NULL) OR (warehouse_id = cl_user_warehouse()))));

CREATE POLICY ltm_modify ON public.loading_task_materials AS PERMISSIVE FOR ALL TO authenticated
  USING ((EXISTS ( SELECT 1
   FROM (loading_tasks lt
     JOIN manifest_sources ms ON ((ms.id = lt.manifest_source_id)))
  WHERE ((lt.id = loading_task_materials.loading_task_id) AND (ms.warehouse_id = cl_user_warehouse()) AND ((lt.assigned_to = cl_warehouse_user_id()) OR cl_is_supervisor_or_manager())))))
  WITH CHECK ((EXISTS ( SELECT 1
   FROM (loading_tasks lt
     JOIN manifest_sources ms ON ((ms.id = lt.manifest_source_id)))
  WHERE ((lt.id = loading_task_materials.loading_task_id) AND (ms.warehouse_id = cl_user_warehouse()) AND ((lt.assigned_to = cl_warehouse_user_id()) OR cl_is_supervisor_or_manager())))));

CREATE POLICY ltm_select ON public.loading_task_materials AS PERMISSIVE FOR SELECT TO authenticated
  USING ((EXISTS ( SELECT 1
   FROM (loading_tasks lt
     JOIN manifest_sources ms ON ((ms.id = lt.manifest_source_id)))
  WHERE ((lt.id = loading_task_materials.loading_task_id) AND (ms.warehouse_id = cl_user_warehouse())))));

CREATE POLICY "Loading tasks create supervisor" ON public.loading_tasks AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK (cl_is_supervisor_or_manager());

CREATE POLICY "Loading tasks read" ON public.loading_tasks AS PERMISSIVE FOR SELECT TO authenticated
  USING (((assigned_to = cl_warehouse_user_id()) OR cl_is_supervisor_or_manager()));

CREATE POLICY "Loading tasks update" ON public.loading_tasks AS PERMISSIVE FOR UPDATE TO authenticated
  USING (((assigned_to = cl_warehouse_user_id()) OR cl_is_supervisor_or_manager()));

CREATE POLICY "Admins can view all login history" ON public.login_history AS PERMISSIVE FOR SELECT TO authenticated
  USING ((_user_role() = 'Admin'::text));

CREATE POLICY "Authenticated users can insert login history" ON public.login_history AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK (((email IS NOT NULL) AND (login_at IS NOT NULL)));

CREATE POLICY "Service role can insert login history" ON public.login_history AS PERMISSIVE FOR INSERT TO service_role
  WITH CHECK (true);

CREATE POLICY "Service role full access" ON public.magaya_accounts AS PERMISSIVE FOR ALL TO public
  USING (true)
  WITH CHECK (true);

CREATE POLICY finanzas_wall_select ON public.magaya_balance_override AS PERMISSIVE FOR SELECT TO authenticated
  USING ((finanzas_office_code_for_office(office_id) IN ( SELECT unnest(app_finanzas_offices()) AS unnest)));

CREATE POLICY service_all ON public.magaya_balance_override AS PERMISSIVE FOR ALL TO service_role
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow all access" ON public.magaya_bills AS PERMISSIVE FOR ALL TO public
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow all access" ON public.magaya_cargo_releases AS PERMISSIVE FOR ALL TO public
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Service role full access" ON public.magaya_charge_definitions AS PERMISSIVE FOR ALL TO public
  USING (true)
  WITH CHECK (true);

CREATE POLICY finanzas_wall_select ON public.magaya_charges_extracted AS PERMISSIVE FOR SELECT TO authenticated
  USING ((finanzas_office_code_for_office(office_id) IN ( SELECT unnest(app_finanzas_offices()) AS unnest)));

CREATE POLICY service_all ON public.magaya_charges_extracted AS PERMISSIVE FOR ALL TO service_role
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can view magaya clients" ON public.magaya_clients AS PERMISSIVE FOR SELECT TO authenticated
  USING ((_user_role() = ANY (ARRAY['Admin'::text, 'Manager'::text, 'Administration'::text, 'Operations'::text, 'Customer Service'::text])));

CREATE POLICY "Service role full access" ON public.magaya_companies AS PERMISSIVE FOR ALL TO public
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow all access" ON public.magaya_cr_items AS PERMISSIVE FOR ALL TO public
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Service role full access" ON public.magaya_currencies AS PERMISSIVE FOR ALL TO public
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Service role full access" ON public.magaya_entities AS PERMISSIVE FOR ALL TO public
  USING (true)
  WITH CHECK (true);

CREATE POLICY finanzas_wall_select ON public.magaya_entity_balance AS PERMISSIVE FOR SELECT TO authenticated
  USING ((finanzas_office_code_for_office(office_id) IN ( SELECT unnest(app_finanzas_offices()) AS unnest)));

CREATE POLICY service_all ON public.magaya_entity_balance AS PERMISSIVE FOR ALL TO service_role
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Service role full access" ON public.magaya_event_definitions AS PERMISSIVE FOR ALL TO public
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can view magaya inventory" ON public.magaya_inventory AS PERMISSIVE FOR SELECT TO authenticated
  USING ((_user_role() = ANY (ARRAY['Admin'::text, 'Manager'::text, 'Administration'::text, 'Operations'::text, 'Customer Service'::text])));

CREATE POLICY "Authenticated users can view magaya invoices" ON public.magaya_invoices AS PERMISSIVE FOR SELECT TO authenticated
  USING ((_user_role() = ANY (ARRAY['Admin'::text, 'Manager'::text, 'Administration'::text, 'Operations'::text, 'Customer Service'::text])));

CREATE POLICY "Allow all for service role je" ON public.magaya_journal_entries AS PERMISSIVE FOR ALL TO public
  USING (true);

CREATE POLICY "Allow all for service role jel" ON public.magaya_journal_entry_lines AS PERMISSIVE FOR ALL TO public
  USING (true);

CREATE POLICY "Service role full access" ON public.magaya_payment_application AS PERMISSIVE FOR ALL TO service_role
  USING (true)
  WITH CHECK (true);

CREATE POLICY finanzas_wall_select ON public.magaya_payment_application AS PERMISSIVE FOR SELECT TO authenticated
  USING ((finanzas_office_code_for_company(company_id) IN ( SELECT unnest(app_finanzas_offices()) AS unnest)));

CREATE POLICY "Allow all access" ON public.magaya_pickup_orders AS PERMISSIVE FOR ALL TO public
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can view magaya shipments" ON public.magaya_shipments AS PERMISSIVE FOR SELECT TO authenticated
  USING ((_user_role() = ANY (ARRAY['Admin'::text, 'Manager'::text, 'Administration'::text, 'Operations'::text, 'Customer Service'::text])));

CREATE POLICY finanzas_wall_select ON public.magaya_status_overrides AS PERMISSIVE FOR SELECT TO authenticated
  USING ((COALESCE(array_length(( SELECT app_finanzas_offices() AS app_finanzas_offices), 1), 0) > 0));

CREATE POLICY service_all ON public.magaya_status_overrides AS PERMISSIVE FOR ALL TO service_role
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Service role full access" ON public.magaya_sync_log AS PERMISSIVE FOR ALL TO public
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow all access" ON public.magaya_sync_state AS PERMISSIVE FOR ALL TO public
  USING (true)
  WITH CHECK (true);

CREATE POLICY anon_sync_temp ON public.magaya_transaction_charges AS PERMISSIVE FOR ALL TO anon
  USING (true)
  WITH CHECK (true);

CREATE POLICY finanzas_wall_select ON public.magaya_transaction_charges AS PERMISSIVE FOR SELECT TO authenticated
  USING ((finanzas_office_code_for_company(company_id) IN ( SELECT unnest(app_finanzas_offices()) AS unnest)));

CREATE POLICY service_role_all ON public.magaya_transaction_charges AS PERMISSIVE FOR ALL TO service_role
  USING (true)
  WITH CHECK (true);

CREATE POLICY anon_sync_temp ON public.magaya_transactions AS PERMISSIVE FOR ALL TO anon
  USING (true)
  WITH CHECK (true);

CREATE POLICY finanzas_wall_select ON public.magaya_transactions AS PERMISSIVE FOR SELECT TO authenticated
  USING ((finanzas_office_code_for_company(company_id) IN ( SELECT unnest(app_finanzas_offices()) AS unnest)));

CREATE POLICY service_role_all ON public.magaya_transactions AS PERMISSIVE FOR ALL TO service_role
  USING (true)
  WITH CHECK (true);

CREATE POLICY "musa allowed users" ON public.magaya_usa_shipments AS PERMISSIVE FOR ALL TO authenticated
  USING ((_user_email() = ANY (ARRAY['avaldano@glovalgroup.com'::text, 'janeth@glovalecuador.com'::text, 'contable2@glovalecuador.com'::text])))
  WITH CHECK ((_user_email() = ANY (ARRAY['avaldano@glovalgroup.com'::text, 'janeth@glovalecuador.com'::text, 'contable2@glovalecuador.com'::text])));

CREATE POLICY "Allow all access" ON public.magaya_vendor_payments AS PERMISSIVE FOR ALL TO public
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow all access" ON public.magaya_warehouse_receipts AS PERMISSIVE FOR ALL TO public
  USING (true)
  WITH CHECK (true);

CREATE POLICY wr_attach_modify ON public.magaya_wr_attachments AS PERMISSIVE FOR ALL TO authenticated
  USING ((( SELECT auth.uid() AS uid) IS NOT NULL))
  WITH CHECK ((( SELECT auth.uid() AS uid) IS NOT NULL));

CREATE POLICY wr_attach_select ON public.magaya_wr_attachments AS PERMISSIVE FOR SELECT TO authenticated
  USING ((( SELECT auth.uid() AS uid) IS NOT NULL));

CREATE POLICY "Allow all access" ON public.magaya_wr_items AS PERMISSIVE FOR ALL TO public
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Manifest items insert supervisor" ON public.manifest_items AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK ((cl_is_supervisor_or_manager() OR cl_has_role('dispatcher'::warehouse_role)));

CREATE POLICY "Manifest items read" ON public.manifest_items AS PERMISSIVE FOR SELECT TO authenticated
  USING ((EXISTS ( SELECT 1
   FROM manifest_sources s
  WHERE ((s.id = manifest_items.manifest_source_id) AND ((s.warehouse_id = cl_user_warehouse()) OR cl_is_supervisor_or_manager())))));

CREATE POLICY "Manifest items update by loader" ON public.manifest_items AS PERMISSIVE FOR UPDATE TO authenticated
  USING ((manifest_source_id IN ( SELECT loading_tasks.manifest_source_id
   FROM loading_tasks
  WHERE (loading_tasks.assigned_to = cl_warehouse_user_id()))));

CREATE POLICY "Manifest items update by picker" ON public.manifest_items AS PERMISSIVE FOR UPDATE TO authenticated
  USING ((assigned_picking_task_id IN ( SELECT picking_tasks.id
   FROM picking_tasks
  WHERE (picking_tasks.assigned_to = cl_warehouse_user_id()))));

CREATE POLICY "Manifest items update by stager" ON public.manifest_items AS PERMISSIVE FOR UPDATE TO authenticated
  USING ((manifest_source_id IN ( SELECT staging_check_tasks.manifest_source_id
   FROM staging_check_tasks
  WHERE (staging_check_tasks.assigned_to = cl_warehouse_user_id()))));

CREATE POLICY "Manifest items update supervisor" ON public.manifest_items AS PERMISSIVE FOR UPDATE TO authenticated
  USING (cl_is_supervisor_or_manager());

CREATE POLICY "Manifest sources read warehouse" ON public.manifest_sources AS PERMISSIVE FOR SELECT TO authenticated
  USING (((warehouse_id = cl_user_warehouse()) OR cl_is_supervisor_or_manager()));

CREATE POLICY "Manifest sources write supervisor" ON public.manifest_sources AS PERMISSIVE FOR ALL TO authenticated
  USING (cl_is_supervisor_or_manager());

CREATE POLICY mi_actor_alias_select ON public.mi_actor_alias AS PERMISSIVE FOR SELECT TO authenticated
  USING ((( SELECT auth.uid() AS uid) IS NOT NULL));

CREATE POLICY mi_actor_alias_write ON public.mi_actor_alias AS PERMISSIVE FOR ALL TO authenticated
  USING ((_user_role() = ANY (ARRAY['Admin'::text, 'Manager'::text, 'VP'::text, 'Administration'::text])))
  WITH CHECK ((_user_role() = ANY (ARRAY['Admin'::text, 'Manager'::text, 'VP'::text, 'Administration'::text])));

CREATE POLICY mi_canonical_actor_select ON public.mi_canonical_actor AS PERMISSIVE FOR SELECT TO authenticated
  USING ((( SELECT auth.uid() AS uid) IS NOT NULL));

CREATE POLICY mi_canonical_actor_write ON public.mi_canonical_actor AS PERMISSIVE FOR ALL TO authenticated
  USING ((_user_role() = ANY (ARRAY['Admin'::text, 'Manager'::text, 'VP'::text, 'Administration'::text])))
  WITH CHECK ((_user_role() = ANY (ARRAY['Admin'::text, 'Manager'::text, 'VP'::text, 'Administration'::text])));

CREATE POLICY mi_courier_shipment_select_auth ON public.mi_courier_shipment AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY mi_etl_run_select ON public.mi_etl_run AS PERMISSIVE FOR SELECT TO authenticated
  USING ((_user_role() = ANY (ARRAY['Admin'::text, 'Manager'::text, 'VP'::text, 'Administration'::text])));

CREATE POLICY mi_etl_run_write ON public.mi_etl_run AS PERMISSIVE FOR ALL TO authenticated
  USING ((_user_role() = ANY (ARRAY['Admin'::text, 'VP'::text, 'Administration'::text])))
  WITH CHECK ((_user_role() = ANY (ARRAY['Admin'::text, 'VP'::text, 'Administration'::text])));

CREATE POLICY mi_match_review_select ON public.mi_match_review_queue AS PERMISSIVE FOR SELECT TO authenticated
  USING ((_user_role() = ANY (ARRAY['Admin'::text, 'Manager'::text, 'VP'::text, 'Administration'::text])));

CREATE POLICY mi_match_review_write ON public.mi_match_review_queue AS PERMISSIVE FOR ALL TO authenticated
  USING ((_user_role() = ANY (ARRAY['Admin'::text, 'Manager'::text, 'VP'::text, 'Administration'::text])))
  WITH CHECK ((_user_role() = ANY (ARRAY['Admin'::text, 'Manager'::text, 'VP'::text, 'Administration'::text])));

CREATE POLICY mi_intel_select ON public.mi_shipment_intel AS PERMISSIVE FOR SELECT TO authenticated
  USING ((EXISTS ( SELECT 1
   FROM (users u
     LEFT JOIN clients c ON ((c.id = mi_shipment_intel.client_id)))
  WHERE ((u.auth_user_id = ( SELECT auth.uid() AS uid)) AND ((u.role = ANY (ARRAY['Admin'::text, 'VP'::text, 'Administration'::text])) OR ((u.role = 'Manager'::text) AND (((mi_shipment_intel.client_id IS NOT NULL) AND (c.office = u.office)) OR ((mi_shipment_intel.client_id IS NULL) AND (u.office = 'Ecuador'::text)))) OR ((u.role = ANY (ARRAY['Sales Executive'::text, 'Support'::text])) AND (((mi_shipment_intel.client_id IS NOT NULL) AND (c.office = u.office) AND (c.assigned_to = u.id)) OR ((mi_shipment_intel.client_id IS NULL) AND (u.office = 'Ecuador'::text)))) OR ((u.role = 'Customer Service'::text) AND (((mi_shipment_intel.client_id IS NOT NULL) AND (c.office = u.office) AND (EXISTS ( SELECT 1
           FROM cs_assignments csa
          WHERE ((csa.cs_user_id = u.id) AND (csa.sales_executive_id = c.assigned_to) AND csa.active)))) OR ((mi_shipment_intel.client_id IS NULL) AND (u.office = 'Ecuador'::text)))))))));

CREATE POLICY mi_intel_write ON public.mi_shipment_intel AS PERMISSIVE FOR ALL TO authenticated
  USING ((_user_role() = ANY (ARRAY['Admin'::text, 'Manager'::text, 'VP'::text, 'Administration'::text])))
  WITH CHECK ((_user_role() = ANY (ARRAY['Admin'::text, 'Manager'::text, 'VP'::text, 'Administration'::text])));

CREATE POLICY monday_containers_mgr_write ON public.monday_containers AS PERMISSIVE FOR ALL TO authenticated
  USING ((_user_role() = ANY (ARRAY['Admin'::text, 'Manager'::text, 'Administration'::text])))
  WITH CHECK ((_user_role() = ANY (ARRAY['Admin'::text, 'Manager'::text, 'Administration'::text])));

CREATE POLICY monday_containers_select ON public.monday_containers AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY finanzas_wall_select ON public.nomina_live AS PERMISSIVE FOR SELECT TO authenticated
  USING ((finanzas_office_code(office) IN ( SELECT unnest(app_finanzas_offices()) AS unnest)));

CREATE POLICY offices_admin_write ON public.offices AS PERMISSIVE FOR ALL TO authenticated
  USING ((_user_role() = 'Admin'::text))
  WITH CHECK ((_user_role() = 'Admin'::text));

CREATE POLICY offices_select ON public.offices AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY ocm_read ON public.ops_capture_mailboxes AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY ops_client_notices_select ON public.ops_client_notices AS PERMISSIVE FOR SELECT TO public
  USING ((EXISTS ( SELECT 1
   FROM shipments s
  WHERE (s.id = ops_client_notices.shipment_id))));

CREATE POLICY ops_vacios_select ON public.ops_devolucion_vacios AS PERMISSIVE FOR SELECT TO authenticated
  USING (app_can('operaciones'::text, 'view'::text));

CREATE POLICY ops_vacios_write ON public.ops_devolucion_vacios AS PERMISSIVE FOR ALL TO authenticated
  USING (app_can('operaciones'::text, 'edit'::text))
  WITH CHECK (app_can('operaciones'::text, 'edit'::text));

CREATE POLICY ops_documents_delete ON public.ops_documents AS PERMISSIVE FOR DELETE TO public
  USING ((app_can_operate_ops() AND (EXISTS ( SELECT 1
   FROM shipments s
  WHERE (s.id = ops_documents.shipment_id)))));

CREATE POLICY ops_documents_insert ON public.ops_documents AS PERMISSIVE FOR INSERT TO public
  WITH CHECK ((app_can_operate_ops() AND (EXISTS ( SELECT 1
   FROM shipments s
  WHERE (s.id = ops_documents.shipment_id)))));

CREATE POLICY ops_documents_select ON public.ops_documents AS PERMISSIVE FOR SELECT TO public
  USING ((EXISTS ( SELECT 1
   FROM shipments s
  WHERE (s.id = ops_documents.shipment_id))));

CREATE POLICY ops_documents_update ON public.ops_documents AS PERMISSIVE FOR UPDATE TO public
  USING ((app_can_operate_ops() AND (EXISTS ( SELECT 1
   FROM shipments s
  WHERE (s.id = ops_documents.shipment_id)))))
  WITH CHECK ((app_can_operate_ops() AND (EXISTS ( SELECT 1
   FROM shipments s
  WHERE (s.id = ops_documents.shipment_id)))));

CREATE POLICY ops_hbl_insert ON public.ops_hbl AS PERMISSIVE FOR INSERT TO public
  WITH CHECK ((app_can_operate_ops() AND (EXISTS ( SELECT 1
   FROM shipments s
  WHERE (s.id = ops_hbl.shipment_id)))));

CREATE POLICY ops_hbl_select ON public.ops_hbl AS PERMISSIVE FOR SELECT TO public
  USING ((EXISTS ( SELECT 1
   FROM shipments s
  WHERE (s.id = ops_hbl.shipment_id))));

CREATE POLICY ops_hbl_update ON public.ops_hbl AS PERMISSIVE FOR UPDATE TO public
  USING ((app_can_operate_ops() AND (EXISTS ( SELECT 1
   FROM shipments s
  WHERE (s.id = ops_hbl.shipment_id)))))
  WITH CHECK ((app_can_operate_ops() AND (EXISTS ( SELECT 1
   FROM shipments s
  WHERE (s.id = ops_hbl.shipment_id)))));

CREATE POLICY ops_hbl_sequence_select ON public.ops_hbl_sequence AS PERMISSIVE FOR SELECT TO public
  USING (true);

CREATE POLICY oie_all ON public.ops_inbound_emails AS PERMISSIVE FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY ops_master_insert ON public.ops_master AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK (app_can_operate_ops());

CREATE POLICY ops_master_select ON public.ops_master AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY ops_master_update ON public.ops_master AS PERMISSIVE FOR UPDATE TO authenticated
  USING (app_can_operate_ops())
  WITH CHECK (app_can_operate_ops());

CREATE POLICY ops_release_insert ON public.ops_release AS PERMISSIVE FOR INSERT TO public
  WITH CHECK ((app_can_operate_ops() AND (EXISTS ( SELECT 1
   FROM shipments s
  WHERE (s.id = ops_release.shipment_id)))));

CREATE POLICY ops_release_select ON public.ops_release AS PERMISSIVE FOR SELECT TO public
  USING ((EXISTS ( SELECT 1
   FROM shipments s
  WHERE (s.id = ops_release.shipment_id))));

CREATE POLICY ops_release_update ON public.ops_release AS PERMISSIVE FOR UPDATE TO public
  USING ((app_can_operate_ops() AND (EXISTS ( SELECT 1
   FROM shipments s
  WHERE (s.id = ops_release.shipment_id)))))
  WITH CHECK ((app_can_operate_ops() AND (EXISTS ( SELECT 1
   FROM shipments s
  WHERE (s.id = ops_release.shipment_id)))));

CREATE POLICY ops_transfers_select ON public.ops_transfers AS PERMISSIVE FOR SELECT TO public
  USING ((EXISTS ( SELECT 1
   FROM shipments s
  WHERE (s.id = ops_transfers.shipment_id))));

CREATE POLICY ops_transfers_update ON public.ops_transfers AS PERMISSIVE FOR UPDATE TO public
  USING ((app_can_operate_ops() AND (EXISTS ( SELECT 1
   FROM shipments s
  WHERE (s.id = ops_transfers.shipment_id)))))
  WITH CHECK ((app_can_operate_ops() AND (EXISTS ( SELECT 1
   FROM shipments s
  WHERE (s.id = ops_transfers.shipment_id)))));

CREATE POLICY finanzas_wall_select ON public.pagos_recurrentes_live AS PERMISSIVE FOR SELECT TO authenticated
  USING ((finanzas_office_code(office) IN ( SELECT unnest(app_finanzas_offices()) AS unnest)));

CREATE POLICY finanzas_wall_select ON public.payment_commitment AS PERMISSIVE FOR SELECT TO authenticated
  USING ((finanzas_office_code_for_office(office_id) IN ( SELECT unnest(app_finanzas_offices()) AS unnest)));

CREATE POLICY service_all ON public.payment_commitment AS PERMISSIVE FOR ALL TO service_role
  USING (true)
  WITH CHECK (true);

CREATE POLICY pba_modify ON public.pba_payments AS PERMISSIVE FOR ALL TO public
  USING ((app_can_see_pba() AND app_can_see_pba_row(client_id)))
  WITH CHECK ((app_can_see_pba() AND app_can_see_pba_row(client_id)));

CREATE POLICY pba_select ON public.pba_payments AS PERMISSIVE FOR SELECT TO public
  USING ((app_can_see_pba() AND app_can_see_pba_row(client_id)));

CREATE POLICY phone_numbers_delete ON public.phone_numbers AS PERMISSIVE FOR DELETE TO authenticated
  USING ((EXISTS ( SELECT 1
   FROM (contacts k
     JOIN clients c ON ((c.id = k.client_id)))
  WHERE ((k.id = phone_numbers.contact_id) AND (user_can_see_office(c.office) OR (EXISTS ( SELECT 1
           FROM users u
          WHERE ((u.auth_user_id = ( SELECT auth.uid() AS uid)) AND ((u.role = ANY (ARRAY['Admin'::text, 'Administration'::text])) OR (c.assigned_to = u.id) OR ((u.role = 'Manager'::text) AND (u.office = c.office)))))))))));

CREATE POLICY phone_numbers_insert ON public.phone_numbers AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK ((EXISTS ( SELECT 1
   FROM (contacts k
     JOIN clients c ON ((c.id = k.client_id)))
  WHERE ((k.id = phone_numbers.contact_id) AND (user_can_see_office(c.office) OR (EXISTS ( SELECT 1
           FROM users u
          WHERE ((u.auth_user_id = ( SELECT auth.uid() AS uid)) AND ((u.role = ANY (ARRAY['Admin'::text, 'Administration'::text])) OR (c.assigned_to = u.id) OR ((u.role = 'Manager'::text) AND (u.office = c.office)))))))))));

CREATE POLICY phone_numbers_select ON public.phone_numbers AS PERMISSIVE FOR SELECT TO authenticated
  USING ((EXISTS ( SELECT 1
   FROM (contacts k
     JOIN clients c ON ((c.id = k.client_id)))
  WHERE ((k.id = phone_numbers.contact_id) AND (user_can_see_office(c.office) OR (EXISTS ( SELECT 1
           FROM users u
          WHERE ((u.auth_user_id = ( SELECT auth.uid() AS uid)) AND ((u.role = ANY (ARRAY['Admin'::text, 'Administration'::text])) OR (c.assigned_to = u.id) OR ((u.role = 'Manager'::text) AND (u.office = c.office)))))))))));

CREATE POLICY phone_numbers_update ON public.phone_numbers AS PERMISSIVE FOR UPDATE TO authenticated
  USING ((EXISTS ( SELECT 1
   FROM (contacts k
     JOIN clients c ON ((c.id = k.client_id)))
  WHERE ((k.id = phone_numbers.contact_id) AND (user_can_see_office(c.office) OR (EXISTS ( SELECT 1
           FROM users u
          WHERE ((u.auth_user_id = ( SELECT auth.uid() AS uid)) AND ((u.role = ANY (ARRAY['Admin'::text, 'Administration'::text])) OR (c.assigned_to = u.id) OR ((u.role = 'Manager'::text) AND (u.office = c.office)))))))))))
  WITH CHECK ((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.auth_user_id = ( SELECT auth.uid() AS uid)) AND ((users.role = ANY (ARRAY['Admin'::text, 'Administration'::text])) OR (EXISTS ( SELECT 1
           FROM (contacts
             JOIN clients ON ((clients.id = contacts.client_id)))
          WHERE ((contacts.id = phone_numbers.contact_id) AND ((clients.assigned_to = users.id) OR ((users.role = 'Manager'::text) AND (users.office = clients.office)))))))))));

CREATE POLICY "Picking exc insert" ON public.picking_exceptions AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK ((raised_by = cl_warehouse_user_id()));

CREATE POLICY "Picking exc read" ON public.picking_exceptions AS PERMISSIVE FOR SELECT TO authenticated
  USING (((raised_by = cl_warehouse_user_id()) OR cl_is_supervisor_or_manager() OR cl_has_role('dispatcher'::warehouse_role)));

CREATE POLICY "Picking exc update" ON public.picking_exceptions AS PERMISSIVE FOR UPDATE TO authenticated
  USING ((cl_is_supervisor_or_manager() OR cl_has_role('dispatcher'::warehouse_role)));

CREATE POLICY "Picking tasks read" ON public.picking_tasks AS PERMISSIVE FOR SELECT TO authenticated
  USING (((assigned_to = cl_warehouse_user_id()) OR cl_is_supervisor_or_manager() OR cl_has_role('dispatcher'::warehouse_role)));

CREATE POLICY "Picking tasks update" ON public.picking_tasks AS PERMISSIVE FOR UPDATE TO authenticated
  USING (((assigned_to = cl_warehouse_user_id()) OR cl_is_supervisor_or_manager() OR cl_has_role('dispatcher'::warehouse_role)));

CREATE POLICY "Picking tasks write dispatcher" ON public.picking_tasks AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK ((cl_has_role('dispatcher'::warehouse_role) OR cl_is_supervisor_or_manager()));

CREATE POLICY points_of_receipt_read ON public.points_of_receipt AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can view ports" ON public.ports AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "Managers can delete ports" ON public.ports AS PERMISSIVE FOR DELETE TO authenticated
  USING (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY "Managers can insert ports" ON public.ports AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY "Managers can update ports" ON public.ports AS PERMISSIVE FOR UPDATE TO authenticated
  USING (( SELECT can_modify_reference_data() AS can_modify_reference_data))
  WITH CHECK (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY ports_master_admin_write ON public.ports_master AS PERMISSIVE FOR ALL TO authenticated
  USING ((_user_role() = 'Admin'::text))
  WITH CHECK ((_user_role() = 'Admin'::text));

CREATE POLICY ports_master_select ON public.ports_master AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY pricing_rules_modify_admin_manager ON public.pricing_rules AS PERMISSIVE FOR ALL TO authenticated
  USING ((_user_role() = ANY (ARRAY['Admin'::text, 'Manager'::text])))
  WITH CHECK ((_user_role() = ANY (ARRAY['Admin'::text, 'Manager'::text])));

CREATE POLICY pricing_rules_select_authenticated ON public.pricing_rules AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY prospect_enrichment_ec_read_authenticated ON public.prospect_enrichment_ec AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY qa_insert ON public.quote_amendments AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK (true);

CREATE POLICY qa_select ON public.quote_amendments AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY qa_update ON public.quote_amendments AS PERMISSIVE FOR UPDATE TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can insert quote_charges" ON public.quote_charges AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK ((( SELECT auth.uid() AS uid) IS NOT NULL));

CREATE POLICY "Authenticated users can update quote_charges" ON public.quote_charges AS PERMISSIVE FOR UPDATE TO authenticated
  USING (((( SELECT auth.uid() AS uid) IS NOT NULL) AND ((EXISTS ( SELECT 1
   FROM quotes
  WHERE ((quotes.id = quote_charges.quote_id) AND (quotes.created_by = ( SELECT users.id
           FROM users
          WHERE (users.auth_user_id = ( SELECT auth.uid() AS uid))
         LIMIT 1))))) OR ( SELECT can_modify_reference_data() AS can_modify_reference_data))))
  WITH CHECK (((( SELECT auth.uid() AS uid) IS NOT NULL) AND ((EXISTS ( SELECT 1
   FROM quotes
  WHERE ((quotes.id = quote_charges.quote_id) AND (quotes.created_by = ( SELECT users.id
           FROM users
          WHERE (users.auth_user_id = ( SELECT auth.uid() AS uid))
         LIMIT 1))))) OR ( SELECT can_modify_reference_data() AS can_modify_reference_data))));

CREATE POLICY "Authenticated users can view quote_charges" ON public.quote_charges AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "Users can delete own quote_charges or managers can delete all" ON public.quote_charges AS PERMISSIVE FOR DELETE TO authenticated
  USING (((( SELECT auth.uid() AS uid) IS NOT NULL) AND ((EXISTS ( SELECT 1
   FROM quotes
  WHERE ((quotes.id = quote_charges.quote_id) AND (quotes.created_by = ( SELECT users.id
           FROM users
          WHERE (users.auth_user_id = ( SELECT auth.uid() AS uid))
         LIMIT 1))))) OR ( SELECT can_modify_reference_data() AS can_modify_reference_data))));

CREATE POLICY quote_emails_rw ON public.quote_emails AS PERMISSIVE FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY quote_followups_rw ON public.quote_followups AS PERMISSIVE FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY quote_pba_all ON public.quote_pba AS PERMISSIVE FOR ALL TO public
  USING (app_can_see_pba())
  WITH CHECK (app_can_see_pba());

CREATE POLICY "Authenticated users can insert quotes" ON public.quotes AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK ((( SELECT auth.uid() AS uid) IS NOT NULL));

CREATE POLICY "Authenticated users can update quotes" ON public.quotes AS PERMISSIVE FOR UPDATE TO public
  USING (((( SELECT auth.uid() AS uid) IS NOT NULL) AND ((created_by = ( SELECT u.id
   FROM users u
  WHERE (u.auth_user_id = ( SELECT auth.uid() AS uid))
 LIMIT 1)) OR ( SELECT can_modify_reference_data() AS can_modify_reference_data) OR (created_by IN ( SELECT app_cs_ventas_executives() AS app_cs_ventas_executives)) OR has_delegation_to(created_by) OR ((client_id IN ( SELECT app_cs_clientes_habilitados() AS app_cs_clientes_habilitados)) AND (created_by = ( SELECT c.assigned_to
   FROM clients c
  WHERE (c.id = quotes.client_id)))))))
  WITH CHECK (((( SELECT auth.uid() AS uid) IS NOT NULL) AND ((created_by = ( SELECT u.id
   FROM users u
  WHERE (u.auth_user_id = ( SELECT auth.uid() AS uid))
 LIMIT 1)) OR ( SELECT can_modify_reference_data() AS can_modify_reference_data) OR (created_by IN ( SELECT app_cs_ventas_executives() AS app_cs_ventas_executives)) OR has_delegation_to(created_by) OR ((client_id IN ( SELECT app_cs_clientes_habilitados() AS app_cs_clientes_habilitados)) AND (created_by = ( SELECT c.assigned_to
   FROM clients c
  WHERE (c.id = quotes.client_id)))))));

CREATE POLICY "Authenticated users can view quotes" ON public.quotes AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "Users can delete own quotes or managers can delete all" ON public.quotes AS PERMISSIVE FOR DELETE TO authenticated
  USING (((( SELECT auth.uid() AS uid) IS NOT NULL) AND ((created_by = ( SELECT users.id
   FROM users
  WHERE (users.auth_user_id = ( SELECT auth.uid() AS uid))
 LIMIT 1)) OR ( SELECT can_modify_reference_data() AS can_modify_reference_data))));

CREATE POLICY "Authenticated users can view rate_charges" ON public.rate_charges AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "Managers can delete rate_charges" ON public.rate_charges AS PERMISSIVE FOR DELETE TO authenticated
  USING (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY "Managers can insert rate_charges" ON public.rate_charges AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY "Managers can update rate_charges" ON public.rate_charges AS PERMISSIVE FOR UPDATE TO authenticated
  USING (( SELECT can_modify_reference_data() AS can_modify_reference_data))
  WITH CHECK (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY "Authenticated users can view rate_components" ON public.rate_components AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "Managers can delete rate_components" ON public.rate_components AS PERMISSIVE FOR DELETE TO authenticated
  USING (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY "Managers can insert rate_components" ON public.rate_components AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY "Managers can update rate_components" ON public.rate_components AS PERMISSIVE FOR UPDATE TO authenticated
  USING (( SELECT can_modify_reference_data() AS can_modify_reference_data))
  WITH CHECK (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY "Authenticated users can view rate_notes" ON public.rate_notes AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "Managers can delete rate_notes" ON public.rate_notes AS PERMISSIVE FOR DELETE TO authenticated
  USING (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY "Managers can insert rate_notes" ON public.rate_notes AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY "Managers can update rate_notes" ON public.rate_notes AS PERMISSIVE FOR UPDATE TO authenticated
  USING (( SELECT can_modify_reference_data() AS can_modify_reference_data))
  WITH CHECK (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY "Authenticated users can view rates" ON public.rates AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "Managers can delete rates" ON public.rates AS PERMISSIVE FOR DELETE TO authenticated
  USING (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY "Managers can insert rates" ON public.rates AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY "Managers can update rates" ON public.rates AS PERMISSIVE FOR UPDATE TO authenticated
  USING (( SELECT can_modify_reference_data() AS can_modify_reference_data))
  WITH CHECK (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY reception_hosts_rw_staff ON public.reception_hosts AS PERMISSIVE FOR ALL TO authenticated
  USING ((app_user_is_admin() OR (app_current_user_office() = 'USA'::text)))
  WITH CHECK ((app_user_is_admin() OR (app_current_user_office() = 'USA'::text)));

CREATE POLICY finanzas_wall_select ON public.recurring_movement AS PERMISSIVE FOR SELECT TO authenticated
  USING ((finanzas_office_code_for_office(office_id) IN ( SELECT unnest(app_finanzas_offices()) AS unnest)));

CREATE POLICY service_all ON public.recurring_movement AS PERMISSIVE FOR ALL TO service_role
  USING (true)
  WITH CHECK (true);

CREATE POLICY reminders_insert ON public.reminders AS PERMISSIVE FOR INSERT TO public
  WITH CHECK (true);

CREATE POLICY reminders_select ON public.reminders AS PERMISSIVE FOR SELECT TO public
  USING (((user_id = app_current_user_id()) OR app_user_is_admin()));

CREATE POLICY reminders_update ON public.reminders AS PERMISSIVE FOR UPDATE TO public
  USING ((user_id = app_current_user_id()));

CREATE POLICY rfq_log_admin_write ON public.rfq_log AS PERMISSIVE FOR ALL TO authenticated
  USING ((_user_role() = ANY (ARRAY['Admin'::text, 'Manager'::text, 'Administration'::text])))
  WITH CHECK ((_user_role() = ANY (ARRAY['Admin'::text, 'Manager'::text, 'Administration'::text])));

CREATE POLICY rfq_log_select ON public.rfq_log AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY role_permissions_delete_policy ON public.role_permissions AS PERMISSIVE FOR DELETE TO authenticated
  USING ((( SELECT u.role
   FROM users u
  WHERE (u.auth_user_id = ( SELECT auth.uid() AS uid))) = 'Admin'::text));

CREATE POLICY role_permissions_insert_policy ON public.role_permissions AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK ((( SELECT u.role
   FROM users u
  WHERE (u.auth_user_id = ( SELECT auth.uid() AS uid))) = 'Admin'::text));

CREATE POLICY role_permissions_select_policy ON public.role_permissions AS PERMISSIVE FOR SELECT TO authenticated
  USING ((( SELECT auth.uid() AS uid) IS NOT NULL));

CREATE POLICY role_permissions_update_policy ON public.role_permissions AS PERMISSIVE FOR UPDATE TO authenticated
  USING ((( SELECT u.role
   FROM users u
  WHERE (u.auth_user_id = ( SELECT auth.uid() AS uid))) = 'Admin'::text))
  WITH CHECK ((( SELECT u.role
   FROM users u
  WHERE (u.auth_user_id = ( SELECT auth.uid() AS uid))) = 'Admin'::text));

CREATE POLICY "Admin can manage roles" ON public.roles AS PERMISSIVE FOR ALL TO authenticated
  USING ((EXISTS ( SELECT 1
   FROM users u
  WHERE ((u.auth_user_id = ( SELECT auth.uid() AS uid)) AND (u.role = 'Admin'::text)))));

CREATE POLICY roles_delete_policy ON public.roles AS PERMISSIVE FOR DELETE TO authenticated
  USING ((( SELECT users.role
   FROM users
  WHERE (users.id = ( SELECT auth.uid() AS uid))) = 'Admin'::text));

CREATE POLICY roles_insert_policy ON public.roles AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK ((( SELECT users.role
   FROM users
  WHERE (users.id = ( SELECT auth.uid() AS uid))) = 'Admin'::text));

CREATE POLICY roles_select_policy ON public.roles AS PERMISSIVE FOR SELECT TO authenticated
  USING ((( SELECT auth.uid() AS uid) IS NOT NULL));

CREATE POLICY roles_update_policy ON public.roles AS PERMISSIVE FOR UPDATE TO authenticated
  USING ((( SELECT users.role
   FROM users
  WHERE (users.id = ( SELECT auth.uid() AS uid))) = 'Admin'::text))
  WITH CHECK ((( SELECT users.role
   FROM users
  WHERE (users.id = ( SELECT auth.uid() AS uid))) = 'Admin'::text));

CREATE POLICY routes_delete ON public.routes AS PERMISSIVE FOR DELETE TO authenticated
  USING ((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.auth_user_id = ( SELECT auth.uid() AS uid)) AND ((users.role = ANY (ARRAY['Admin'::text, 'Administration'::text])) OR (EXISTS ( SELECT 1
           FROM clients
          WHERE ((clients.id = routes.client_id) AND ((clients.assigned_to = users.id) OR ((users.role = 'Manager'::text) AND (users.office = clients.office)))))))))));

CREATE POLICY routes_insert ON public.routes AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK ((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.auth_user_id = ( SELECT auth.uid() AS uid)) AND ((users.role = ANY (ARRAY['Admin'::text, 'Administration'::text])) OR (EXISTS ( SELECT 1
           FROM clients
          WHERE ((clients.id = routes.client_id) AND ((clients.assigned_to = users.id) OR ((users.role = 'Manager'::text) AND (users.office = clients.office)))))))))));

CREATE POLICY routes_select ON public.routes AS PERMISSIVE FOR SELECT TO authenticated
  USING ((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.auth_user_id = ( SELECT auth.uid() AS uid)) AND ((users.role = ANY (ARRAY['Admin'::text, 'Administration'::text])) OR (EXISTS ( SELECT 1
           FROM clients
          WHERE ((clients.id = routes.client_id) AND ((clients.assigned_to = users.id) OR ((users.role = 'Manager'::text) AND (users.office = clients.office)))))))))));

CREATE POLICY routes_update ON public.routes AS PERMISSIVE FOR UPDATE TO authenticated
  USING ((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.auth_user_id = ( SELECT auth.uid() AS uid)) AND ((users.role = ANY (ARRAY['Admin'::text, 'Administration'::text])) OR (EXISTS ( SELECT 1
           FROM clients
          WHERE ((clients.id = routes.client_id) AND ((clients.assigned_to = users.id) OR ((users.role = 'Manager'::text) AND (users.office = clients.office)))))))))))
  WITH CHECK ((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.auth_user_id = ( SELECT auth.uid() AS uid)) AND ((users.role = ANY (ARRAY['Admin'::text, 'Administration'::text])) OR (EXISTS ( SELECT 1
           FROM clients
          WHERE ((clients.id = routes.client_id) AND ((clients.assigned_to = users.id) OR ((users.role = 'Manager'::text) AND (users.office = clients.office)))))))))));

CREATE POLICY sales_activities_delete_policy ON public.sales_activities AS PERMISSIVE FOR DELETE TO authenticated
  USING ((( SELECT users.role
   FROM users
  WHERE (users.auth_user_id = ( SELECT auth.uid() AS uid))) = ANY (ARRAY['Admin'::text, 'Manager'::text, 'Administration'::text])));

CREATE POLICY sales_activities_insert_policy ON public.sales_activities AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK ((sales_rep_id = ( SELECT users.id
   FROM users
  WHERE (users.auth_user_id = ( SELECT auth.uid() AS uid)))));

CREATE POLICY sales_activities_select_policy ON public.sales_activities AS PERMISSIVE FOR SELECT TO authenticated
  USING (((sales_rep_id = ( SELECT users.id
   FROM users
  WHERE (users.auth_user_id = ( SELECT auth.uid() AS uid)))) OR (( SELECT users.role
   FROM users
  WHERE (users.auth_user_id = ( SELECT auth.uid() AS uid))) = ANY (ARRAY['Admin'::text, 'Manager'::text, 'VP'::text, 'Administration'::text])) OR ((( SELECT users.role
   FROM users
  WHERE (users.auth_user_id = ( SELECT auth.uid() AS uid))) = 'Customer Service'::text) AND (sales_rep_id IN ( SELECT cs.sales_executive_id
   FROM cs_assignments cs
  WHERE ((cs.cs_user_id = ( SELECT users.id
           FROM users
          WHERE (users.auth_user_id = ( SELECT auth.uid() AS uid)))) AND (cs.active = true))))) OR (EXISTS ( SELECT 1
   FROM (user_delegations d
     JOIN users me ON ((me.id = d.viewer_user_id)))
  WHERE ((me.auth_user_id = ( SELECT auth.uid() AS uid)) AND (d.owner_user_id = sales_activities.sales_rep_id))))));

CREATE POLICY sales_activities_update_policy ON public.sales_activities AS PERMISSIVE FOR UPDATE TO authenticated
  USING (((sales_rep_id = ( SELECT users.id
   FROM users
  WHERE (users.auth_user_id = ( SELECT auth.uid() AS uid)))) OR (( SELECT users.role
   FROM users
  WHERE (users.auth_user_id = ( SELECT auth.uid() AS uid))) = ANY (ARRAY['Admin'::text, 'Manager'::text])) OR (EXISTS ( SELECT 1
   FROM (user_delegations d
     JOIN users me ON ((me.id = d.viewer_user_id)))
  WHERE ((me.auth_user_id = ( SELECT auth.uid() AS uid)) AND (d.owner_user_id = sales_activities.sales_rep_id))))));

CREATE POLICY "Only admins and managers can delete goals" ON public.sales_goals AS PERMISSIVE FOR DELETE TO authenticated
  USING ((EXISTS ( SELECT 1
   FROM users u
  WHERE ((u.auth_user_id = ( SELECT auth.uid() AS uid)) AND (u.role = ANY (ARRAY['Admin'::text, 'Manager'::text]))))));

CREATE POLICY "Only admins and managers can insert goals" ON public.sales_goals AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK ((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.id = ( SELECT auth.uid() AS uid)) AND (users.role = ANY (ARRAY['Admin'::text, 'Manager'::text]))))));

CREATE POLICY "Only admins and managers can update goals" ON public.sales_goals AS PERMISSIVE FOR UPDATE TO authenticated
  USING ((EXISTS ( SELECT 1
   FROM users u
  WHERE ((u.auth_user_id = ( SELECT auth.uid() AS uid)) AND (u.role = ANY (ARRAY['Admin'::text, 'Manager'::text]))))));

CREATE POLICY "Users can view their goals or all if admin/manager" ON public.sales_goals AS PERMISSIVE FOR SELECT TO authenticated
  USING (((sales_rep_id = ( SELECT u.id
   FROM users u
  WHERE (u.auth_user_id = ( SELECT auth.uid() AS uid)))) OR (EXISTS ( SELECT 1
   FROM users u
  WHERE ((u.auth_user_id = ( SELECT auth.uid() AS uid)) AND (u.role = ANY (ARRAY['Admin'::text, 'Manager'::text])))))));

CREATE POLICY finanzas_wall_select ON public.sales_live_monthly AS PERMISSIVE FOR SELECT TO authenticated
  USING ((finanzas_office_code(office) IN ( SELECT unnest(app_finanzas_offices()) AS unnest)));

CREATE POLICY sql_delete ON public.sales_quote_lines AS PERMISSIVE FOR DELETE TO authenticated
  USING (true);

CREATE POLICY sql_insert ON public.sales_quote_lines AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK (true);

CREATE POLICY sql_select ON public.sales_quote_lines AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY sql_update ON public.sales_quote_lines AS PERMISSIVE FOR UPDATE TO authenticated
  USING (true);

CREATE POLICY finanzas_wall_select ON public.scheduled_payment AS PERMISSIVE FOR SELECT TO authenticated
  USING ((finanzas_office_code_for_office(office_id) IN ( SELECT unnest(app_finanzas_offices()) AS unnest)));

CREATE POLICY service_all ON public.scheduled_payment AS PERMISSIVE FOR ALL TO service_role
  USING (true)
  WITH CHECK (true);

CREATE POLICY shipco_dest_read ON public.shipco_destinations AS PERMISSIVE FOR SELECT TO authenticated
  USING ((shipco_current_office() IS NOT NULL));

CREATE POLICY shipco_rates_usa_read ON public.shipco_rates AS PERMISSIVE FOR SELECT TO authenticated
  USING ((shipco_current_office() = 'USA'::text));

CREATE POLICY action_items_delete ON public.shipment_action_items AS PERMISSIVE FOR DELETE TO public
  USING ((( SELECT app_user_is_admin() AS app_user_is_admin) OR (assigned_to = ( SELECT app_current_user_id() AS app_current_user_id))));

CREATE POLICY action_items_insert ON public.shipment_action_items AS PERMISSIVE FOR INSERT TO public
  WITH CHECK ((EXISTS ( SELECT 1
   FROM shipments s
  WHERE (s.id = shipment_action_items.shipment_id))));

CREATE POLICY action_items_select ON public.shipment_action_items AS PERMISSIVE FOR SELECT TO public
  USING ((EXISTS ( SELECT 1
   FROM shipments s
  WHERE (s.id = shipment_action_items.shipment_id))));

CREATE POLICY action_items_update ON public.shipment_action_items AS PERMISSIVE FOR UPDATE TO public
  USING ((( SELECT app_user_is_admin() AS app_user_is_admin) OR (assigned_to = ( SELECT app_current_user_id() AS app_current_user_id)) OR (EXISTS ( SELECT 1
   FROM shipments s
  WHERE ((s.id = shipment_action_items.shipment_id) AND (s.cs_assigned_to = ( SELECT app_current_user_id() AS app_current_user_id)))))))
  WITH CHECK ((( SELECT app_user_is_admin() AS app_user_is_admin) OR (assigned_to = ( SELECT app_current_user_id() AS app_current_user_id)) OR (EXISTS ( SELECT 1
   FROM shipments s
  WHERE ((s.id = shipment_action_items.shipment_id) AND (s.cs_assigned_to = ( SELECT app_current_user_id() AS app_current_user_id)))))));

CREATE POLICY shipment_agents_all ON public.shipment_agents AS PERMISSIVE FOR ALL TO public
  USING ((EXISTS ( SELECT 1
   FROM shipments s
  WHERE (s.id = shipment_agents.shipment_id))))
  WITH CHECK ((EXISTS ( SELECT 1
   FROM shipments s
  WHERE (s.id = shipment_agents.shipment_id))));

CREATE POLICY shipment_containers_all ON public.shipment_containers AS PERMISSIVE FOR ALL TO public
  USING ((EXISTS ( SELECT 1
   FROM shipments s
  WHERE (s.id = shipment_containers.shipment_id))))
  WITH CHECK ((EXISTS ( SELECT 1
   FROM shipments s
  WHERE (s.id = shipment_containers.shipment_id))));

CREATE POLICY ship_events_insert ON public.shipment_events AS PERMISSIVE FOR INSERT TO public
  WITH CHECK ((EXISTS ( SELECT 1
   FROM shipments s
  WHERE (s.id = shipment_events.shipment_id))));

CREATE POLICY ship_events_select ON public.shipment_events AS PERMISSIVE FOR SELECT TO public
  USING ((EXISTS ( SELECT 1
   FROM shipments s
  WHERE (s.id = shipment_events.shipment_id))));

CREATE POLICY ship_events_update ON public.shipment_events AS PERMISSIVE FOR UPDATE TO public
  USING ((EXISTS ( SELECT 1
   FROM shipments s
  WHERE (s.id = shipment_events.shipment_id))));

CREATE POLICY shipment_shippers_all ON public.shipment_shippers AS PERMISSIVE FOR ALL TO public
  USING ((EXISTS ( SELECT 1
   FROM shipments s
  WHERE (s.id = shipment_shippers.shipment_id))))
  WITH CHECK ((EXISTS ( SELECT 1
   FROM shipments s
  WHERE (s.id = shipment_shippers.shipment_id))));

CREATE POLICY shipments_insert ON public.shipments AS PERMISSIVE FOR INSERT TO public
  WITH CHECK ((( SELECT app_user_is_admin() AS app_user_is_admin) OR (sales_executive_id = ( SELECT app_current_user_id() AS app_current_user_id)) OR (sales_executive_id IN ( SELECT app_cs_executives() AS app_cs_executives)) OR ((( SELECT app_current_user_role() AS app_current_user_role) = 'Customer Service'::text) AND (sales_executive_id IS NULL)) OR ((( SELECT app_current_user_role() AS app_current_user_role) = 'Customer Service'::text) AND (cs_assigned_to = ( SELECT app_current_user_id() AS app_current_user_id)))));

CREATE POLICY shipments_select ON public.shipments AS PERMISSIVE FOR SELECT TO public
  USING (COALESCE((( SELECT app_user_is_admin() AS app_user_is_admin) OR (( SELECT app_user_is_manager() AS app_user_is_manager) AND (office = ( SELECT app_current_user_office() AS app_current_user_office))) OR ( SELECT app_user_is_ops() AS app_user_is_ops) OR ((office IS NOT NULL) AND (office = ( SELECT app_current_user_office() AS app_current_user_office)) AND (pba_amount IS NULL) AND (( SELECT app_current_user_role() AS app_current_user_role) IS DISTINCT FROM 'Customer Service'::text) AND ( SELECT app_user_has_operaciones() AS app_user_has_operaciones)) OR (sales_executive_id = ( SELECT app_current_user_id() AS app_current_user_id)) OR ((pba_amount IS NULL) AND (sales_executive_id IN ( SELECT app_delegation_owners() AS app_delegation_owners))) OR ((cs_assigned_to IS NOT NULL) AND (cs_assigned_to = ( SELECT app_current_user_id() AS app_current_user_id))) OR (sales_executive_id IN ( SELECT app_cs_executives_full() AS app_cs_executives_full)) OR ((sales_executive_id IN ( SELECT app_cs_executives() AS app_cs_executives)) AND ((cs_assigned_to IS NULL) OR (cs_assigned_to = ( SELECT app_current_user_id() AS app_current_user_id)))) OR ((sales_executive_id IS NULL) AND (office = ( SELECT app_current_user_office() AS app_current_user_office)) AND ( SELECT app_cs_sees_directos() AS app_cs_sees_directos) AND ((cs_assigned_to IS NULL) OR (cs_assigned_to = ( SELECT app_current_user_id() AS app_current_user_id)))) OR ((pba_amount IS NULL) AND (client_id IN ( SELECT app_cs_client_ids() AS app_cs_client_ids)))), false));

CREATE POLICY shipments_update ON public.shipments AS PERMISSIVE FOR UPDATE TO public
  USING (COALESCE((( SELECT app_user_is_admin() AS app_user_is_admin) OR (( SELECT app_user_is_manager() AS app_user_is_manager) AND (office = ( SELECT app_current_user_office() AS app_current_user_office))) OR ( SELECT app_user_is_ops() AS app_user_is_ops) OR ((office IS NOT NULL) AND (office = ( SELECT app_current_user_office() AS app_current_user_office)) AND (pba_amount IS NULL) AND (( SELECT app_current_user_role() AS app_current_user_role) IS DISTINCT FROM 'Customer Service'::text) AND ( SELECT app_user_has_operaciones() AS app_user_has_operaciones)) OR (sales_executive_id = ( SELECT app_current_user_id() AS app_current_user_id)) OR ((pba_amount IS NULL) AND (sales_executive_id IN ( SELECT app_delegation_owners() AS app_delegation_owners))) OR ((cs_assigned_to IS NOT NULL) AND (cs_assigned_to = ( SELECT app_current_user_id() AS app_current_user_id))) OR (sales_executive_id IN ( SELECT app_cs_executives_full() AS app_cs_executives_full)) OR ((sales_executive_id IN ( SELECT app_cs_executives() AS app_cs_executives)) AND ((cs_assigned_to IS NULL) OR (cs_assigned_to = ( SELECT app_current_user_id() AS app_current_user_id)))) OR ((sales_executive_id IS NULL) AND (office = ( SELECT app_current_user_office() AS app_current_user_office)) AND ( SELECT app_cs_sees_directos() AS app_cs_sees_directos) AND ((cs_assigned_to IS NULL) OR (cs_assigned_to = ( SELECT app_current_user_id() AS app_current_user_id))))), false));

CREATE POLICY si_insert ON public.shipping_instructions AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK (true);

CREATE POLICY si_select ON public.shipping_instructions AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY si_update ON public.shipping_instructions AS PERMISSIVE FOR UPDATE TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can add shipping lines" ON public.shipping_lines AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK (((( SELECT auth.uid() AS uid) IS NOT NULL) AND (created_by = ( SELECT auth.uid() AS uid))));

CREATE POLICY "Authenticated users can view shipping lines" ON public.shipping_lines AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "Staging tasks create supervisor" ON public.staging_check_tasks AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK (cl_is_supervisor_or_manager());

CREATE POLICY "Staging tasks read" ON public.staging_check_tasks AS PERMISSIVE FOR SELECT TO authenticated
  USING (((assigned_to = cl_warehouse_user_id()) OR cl_is_supervisor_or_manager()));

CREATE POLICY "Staging tasks update" ON public.staging_check_tasks AS PERMISSIVE FOR UPDATE TO authenticated
  USING (((assigned_to = cl_warehouse_user_id()) OR cl_is_supervisor_or_manager()));

CREATE POLICY "Staging exc insert" ON public.staging_exceptions AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK ((raised_by = cl_warehouse_user_id()));

CREATE POLICY "Staging exc read" ON public.staging_exceptions AS PERMISSIVE FOR SELECT TO authenticated
  USING (((raised_by = cl_warehouse_user_id()) OR cl_is_supervisor_or_manager()));

CREATE POLICY "Staging exc update" ON public.staging_exceptions AS PERMISSIVE FOR UPDATE TO authenticated
  USING (cl_is_supervisor_or_manager());

CREATE POLICY surcharge_adjustments_insert ON public.surcharge_adjustments AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK (true);

CREATE POLICY surcharge_adjustments_select ON public.surcharge_adjustments AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY surcharge_adjustments_update ON public.surcharge_adjustments AS PERMISSIVE FOR UPDATE TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can view surcharges" ON public.surcharges AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "Managers can delete surcharges" ON public.surcharges AS PERMISSIVE FOR DELETE TO authenticated
  USING (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY "Managers can insert surcharges" ON public.surcharges AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY "Managers can update surcharges" ON public.surcharges AS PERMISSIVE FOR UPDATE TO authenticated
  USING (( SELECT can_modify_reference_data() AS can_modify_reference_data))
  WITH CHECK (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY tariff_sheets_modify_admin_manager ON public.tariff_sheets AS PERMISSIVE FOR ALL TO authenticated
  USING ((_user_role() = ANY (ARRAY['Admin'::text, 'Manager'::text])))
  WITH CHECK ((_user_role() = ANY (ARRAY['Admin'::text, 'Manager'::text])));

CREATE POLICY tariff_sheets_select_authenticated ON public.tariff_sheets AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "Create own time entries policy" ON public.time_entries AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK ((( SELECT auth.uid() AS uid) = ( SELECT users.auth_user_id
   FROM users
  WHERE (users.id = time_entries.user_id))));

CREATE POLICY "Delete time entries policy" ON public.time_entries AS PERMISSIVE FOR DELETE TO authenticated
  USING ((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.auth_user_id = ( SELECT auth.uid() AS uid)) AND (users.role = ANY (ARRAY['Admin'::text, 'Administration'::text]))))));

CREATE POLICY "Update time entries policy" ON public.time_entries AS PERMISSIVE FOR UPDATE TO authenticated
  USING (((( SELECT auth.uid() AS uid) = ( SELECT users.auth_user_id
   FROM users
  WHERE (users.id = time_entries.user_id))) OR (EXISTS ( SELECT 1
   FROM users
  WHERE ((users.auth_user_id = ( SELECT auth.uid() AS uid)) AND (users.role = ANY (ARRAY['Admin'::text, 'Administration'::text])))))))
  WITH CHECK (((( SELECT auth.uid() AS uid) = ( SELECT users.auth_user_id
   FROM users
  WHERE (users.id = time_entries.user_id))) OR (EXISTS ( SELECT 1
   FROM users
  WHERE ((users.auth_user_id = ( SELECT auth.uid() AS uid)) AND (users.role = ANY (ARRAY['Admin'::text, 'Administration'::text])))))));

CREATE POLICY "View time entries policy" ON public.time_entries AS PERMISSIVE FOR SELECT TO authenticated
  USING (((( SELECT auth.uid() AS uid) = ( SELECT users.auth_user_id
   FROM users
  WHERE (users.id = time_entries.user_id))) OR (EXISTS ( SELECT 1
   FROM users
  WHERE ((users.auth_user_id = ( SELECT auth.uid() AS uid)) AND (users.role = ANY (ARRAY['Admin'::text, 'Administration'::text]))))) OR (EXISTS ( SELECT 1
   FROM (users acting_user
     JOIN users entry_user ON ((entry_user.id = time_entries.user_id)))
  WHERE ((acting_user.auth_user_id = ( SELECT auth.uid() AS uid)) AND (acting_user.role = 'Manager'::text) AND (acting_user.office = entry_user.office))))));

CREATE POLICY "Authenticated users can view transit_times" ON public.transit_times AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "Managers can delete transit_times" ON public.transit_times AS PERMISSIVE FOR DELETE TO authenticated
  USING (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY "Managers can insert transit_times" ON public.transit_times AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY "Managers can update transit_times" ON public.transit_times AS PERMISSIVE FOR UPDATE TO authenticated
  USING (( SELECT can_modify_reference_data() AS can_modify_reference_data))
  WITH CHECK (( SELECT can_modify_reference_data() AS can_modify_reference_data));

CREATE POLICY "Unplanned insert" ON public.unplanned_additions AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK ((raised_by = cl_warehouse_user_id()));

CREATE POLICY "Unplanned read" ON public.unplanned_additions AS PERMISSIVE FOR SELECT TO authenticated
  USING (((raised_by = cl_warehouse_user_id()) OR cl_is_supervisor_or_manager()));

CREATE POLICY user_delegations_admin_write ON public.user_delegations AS PERMISSIVE FOR ALL TO authenticated
  USING ((_user_role() = ANY (ARRAY['Admin'::text, 'VP'::text])))
  WITH CHECK ((_user_role() = ANY (ARRAY['Admin'::text, 'VP'::text])));

CREATE POLICY user_delegations_select ON public.user_delegations AS PERMISSIVE FOR SELECT TO authenticated
  USING (((viewer_user_id = ( SELECT users.id
   FROM users
  WHERE (users.auth_user_id = ( SELECT auth.uid() AS uid)))) OR (owner_user_id = ( SELECT users.id
   FROM users
  WHERE (users.auth_user_id = ( SELECT auth.uid() AS uid)))) OR (_user_role() = ANY (ARRAY['Admin'::text, 'VP'::text]))));

CREATE POLICY user_permission_overrides_delete_policy ON public.user_permission_overrides AS PERMISSIVE FOR DELETE TO authenticated
  USING ((( SELECT u.role
   FROM users u
  WHERE (u.auth_user_id = ( SELECT auth.uid() AS uid))) = 'Admin'::text));

CREATE POLICY user_permission_overrides_insert_policy ON public.user_permission_overrides AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK ((( SELECT u.role
   FROM users u
  WHERE (u.auth_user_id = ( SELECT auth.uid() AS uid))) = 'Admin'::text));

CREATE POLICY user_permission_overrides_select_policy ON public.user_permission_overrides AS PERMISSIVE FOR SELECT TO authenticated
  USING (((user_id = ( SELECT u.id
   FROM users u
  WHERE (u.auth_user_id = ( SELECT auth.uid() AS uid)))) OR (( SELECT u.role
   FROM users u
  WHERE (u.auth_user_id = ( SELECT auth.uid() AS uid))) = 'Admin'::text)));

CREATE POLICY user_permission_overrides_update_policy ON public.user_permission_overrides AS PERMISSIVE FOR UPDATE TO authenticated
  USING ((( SELECT u.role
   FROM users u
  WHERE (u.auth_user_id = ( SELECT auth.uid() AS uid))) = 'Admin'::text))
  WITH CHECK ((( SELECT u.role
   FROM users u
  WHERE (u.auth_user_id = ( SELECT auth.uid() AS uid))) = 'Admin'::text));

CREATE POLICY users_delete ON public.users AS PERMISSIVE FOR DELETE TO authenticated
  USING ((EXISTS ( SELECT 1
   FROM users u
  WHERE ((u.auth_user_id = ( SELECT auth.uid() AS uid)) AND (u.role = ANY (ARRAY['Admin'::text, 'Administration'::text]))))));

CREATE POLICY users_insert ON public.users AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK (((EXISTS ( SELECT 1
   FROM users u
  WHERE ((u.auth_user_id = ( SELECT auth.uid() AS uid)) AND (u.role = ANY (ARRAY['Admin'::text, 'Administration'::text]))))) OR (NOT (EXISTS ( SELECT 1
   FROM users u
  WHERE (u.auth_user_id = ( SELECT auth.uid() AS uid)))))));

CREATE POLICY users_select_anon ON public.users AS PERMISSIVE FOR SELECT TO anon
  USING (true);

CREATE POLICY users_select_auth ON public.users AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY users_update ON public.users AS PERMISSIVE FOR UPDATE TO authenticated
  USING ((EXISTS ( SELECT 1
   FROM users u
  WHERE ((u.auth_user_id = ( SELECT auth.uid() AS uid)) AND ((u.role = ANY (ARRAY['Admin'::text, 'Administration'::text])) OR (u.id = users.id))))))
  WITH CHECK ((EXISTS ( SELECT 1
   FROM users u
  WHERE ((u.auth_user_id = ( SELECT auth.uid() AS uid)) AND ((u.role = ANY (ARRAY['Admin'::text, 'Administration'::text])) OR (u.id = users.id))))));

CREATE POLICY finanzas_wall_select ON public.vendor_flexibility AS PERMISSIVE FOR SELECT TO authenticated
  USING ((COALESCE(array_length(( SELECT app_finanzas_offices() AS app_finanzas_offices), 1), 0) > 0));

CREATE POLICY service_all ON public.vendor_flexibility AS PERMISSIVE FOR ALL TO service_role
  USING (true)
  WITH CHECK (true);

CREATE POLICY finanzas_wall_select ON public.vendor_profile AS PERMISSIVE FOR SELECT TO authenticated
  USING ((COALESCE(array_length(( SELECT app_finanzas_offices() AS app_finanzas_offices), 1), 0) > 0));

CREATE POLICY service_all ON public.vendor_profile AS PERMISSIVE FOR ALL TO service_role
  USING (true)
  WITH CHECK (true);

CREATE POLICY badges_select_all ON public.visitor_badges AS PERMISSIVE FOR SELECT TO public
  USING (true);

CREATE POLICY badges_write_staff ON public.visitor_badges AS PERMISSIVE FOR ALL TO authenticated
  USING ((app_user_is_admin() OR (app_current_user_office() = 'USA'::text)))
  WITH CHECK ((app_user_is_admin() OR (app_current_user_office() = 'USA'::text)));

CREATE POLICY visitors_rw_staff ON public.visitors AS PERMISSIVE FOR ALL TO authenticated
  USING ((app_user_is_admin() OR (app_current_user_office() = 'USA'::text)))
  WITH CHECK ((app_user_is_admin() OR (app_current_user_office() = 'USA'::text)));

CREATE POLICY visits_rw_staff ON public.visits AS PERMISSIVE FOR ALL TO authenticated
  USING ((app_user_is_admin() OR (app_current_user_office() = 'USA'::text)))
  WITH CHECK ((app_user_is_admin() OR (app_current_user_office() = 'USA'::text)));

CREATE POLICY whcm_admin_only ON public.warehouse_cogs_manual AS PERMISSIVE FOR ALL TO authenticated
  USING ((_user_role() = ANY (ARRAY['Admin'::text, 'Manager'::text, 'Administration'::text])))
  WITH CHECK ((_user_role() = ANY (ARRAY['Admin'::text, 'Manager'::text, 'Administration'::text])));

CREATE POLICY whcm_monthly_select ON public.warehouse_cogs_monthly AS PERMISSIVE FOR SELECT TO authenticated
  USING ((_user_role() = ANY (ARRAY['Admin'::text, 'Manager'::text, 'Administration'::text])));

CREATE POLICY "Users can manage warehouse containers" ON public.warehouse_containers AS PERMISSIVE FOR ALL TO authenticated
  USING ((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.id = ( SELECT auth.uid() AS uid)) AND ((users.office = 'Miami'::text) OR (users.role = ANY (ARRAY['Admin'::text, 'Manager'::text])))))));

CREATE POLICY "Users can manage warehouse tasks" ON public.warehouse_tasks AS PERMISSIVE FOR ALL TO authenticated
  USING ((EXISTS ( SELECT 1
   FROM users
  WHERE ((users.id = ( SELECT auth.uid() AS uid)) AND ((users.office = 'Miami'::text) OR (users.role = ANY (ARRAY['Admin'::text, 'Manager'::text])))))));

CREATE POLICY "Warehouse users delete by manager" ON public.warehouse_users AS PERMISSIVE FOR DELETE TO authenticated
  USING (cl_has_role('manager'::warehouse_role));

CREATE POLICY "Warehouse users self insert" ON public.warehouse_users AS PERMISSIVE FOR INSERT TO authenticated
  WITH CHECK (((user_id IN ( SELECT users.id
   FROM users
  WHERE (users.auth_user_id = auth.uid()))) OR cl_has_role('manager'::warehouse_role)));

CREATE POLICY "Warehouse users self read" ON public.warehouse_users AS PERMISSIVE FOR SELECT TO authenticated
  USING (((cl_warehouse_user_id() = id) OR cl_is_supervisor_or_manager()));

CREATE POLICY "Warehouse users update by manager" ON public.warehouse_users AS PERMISSIVE FOR UPDATE TO authenticated
  USING ((cl_has_role('manager'::warehouse_role) OR (cl_warehouse_user_id() = id)));

CREATE POLICY wcni_all ON public.wh_carga_no_identificada AS PERMISSIVE FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY wh_client_pallets_auth_all ON public.wh_client_pallets AS PERMISSIVE FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY wh_container_types_auth_all ON public.wh_container_types AS PERMISSIVE FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY wh_containers_auth_all ON public.wh_containers AS PERMISSIVE FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY wh_country_map_auth_all ON public.wh_country_map AS PERMISSIVE FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY wh_doc_7512_all ON public.wh_doc_7512 AS PERMISSIVE FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY wh_import_clients_auth_all ON public.wh_import_clients AS PERMISSIVE FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY wh_internal_people_auth_all ON public.wh_internal_people AS PERMISSIVE FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY wh_loading_rates_auth_all ON public.wh_loading_rates AS PERMISSIVE FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY whn_all ON public.wh_notices AS PERMISSIVE FOR ALL TO authenticated
  USING (app_can_see_wh_notice(wr_number, client_id))
  WITH CHECK (app_can_see_wh_notice(wr_number, client_id));

CREATE POLICY "Allow all for authenticated" ON public.wh_report_clients AS PERMISSIVE FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow all for authenticated" ON public.wh_report_movement_items AS PERMISSIVE FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow all for authenticated" ON public.wh_report_movements AS PERMISSIVE FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY whrpm_mgr_write ON public.wh_report_product_mappings AS PERMISSIVE FOR ALL TO authenticated
  USING ((_user_role() = ANY (ARRAY['Admin'::text, 'Manager'::text, 'Administration'::text])))
  WITH CHECK ((_user_role() = ANY (ARRAY['Admin'::text, 'Manager'::text, 'Administration'::text])));

CREATE POLICY whrpm_select ON public.wh_report_product_mappings AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "Allow all for authenticated" ON public.wh_report_products AS PERMISSIVE FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY whrsl_select ON public.wh_report_sync_log AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY wh_stations_auth_all ON public.wh_stations AS PERMISSIVE FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY wh_storage_terms_read ON public.wh_storage_terms AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

CREATE POLICY wh_unloading_rates_auth_all ON public.wh_unloading_rates AS PERMISSIVE FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY wh_warehouse_costs_auth_all ON public.wh_warehouse_costs AS PERMISSIVE FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "service role only" ON public.wr_att_backfill_queue AS PERMISSIVE FOR ALL TO service_role
  USING (true)
  WITH CHECK (true);

CREATE POLICY wr_match_modify ON public.wr_match_results AS PERMISSIVE FOR ALL TO public
  USING ((app_user_is_admin() OR (app_user_is_manager() AND (office = app_current_user_office())) OR ((app_current_user_role() = 'Customer Service'::text) AND ((office = app_current_user_office()) OR ((matched_client_id IS NOT NULL) AND (EXISTS ( SELECT 1
   FROM clients c
  WHERE ((c.id = wr_match_results.matched_client_id) AND (c.office = app_current_user_office())))))))));

CREATE POLICY wr_match_select ON public.wr_match_results AS PERMISSIVE FOR SELECT TO public
  USING ((app_user_is_admin() OR (app_user_is_manager() AND (office = app_current_user_office())) OR ((app_current_user_role() = 'Customer Service'::text) AND ((office = app_current_user_office()) OR ((matched_client_id IS NOT NULL) AND (EXISTS ( SELECT 1
   FROM clients c
  WHERE ((c.id = wr_match_results.matched_client_id) AND (c.office = app_current_user_office()))))))) OR ((matched_client_id IS NOT NULL) AND (EXISTS ( SELECT 1
   FROM clients c
  WHERE ((c.id = wr_match_results.matched_client_id) AND (c.assigned_to = app_current_user_id())))))));

CREATE POLICY wr_saldo_queue_read ON public.wr_saldo_queue AS PERMISSIVE FOR SELECT TO authenticated
  USING (true);

