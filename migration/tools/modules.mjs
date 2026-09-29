// Asignación de tablas a módulos (por nombre) y reglas de exclusión.
// Es una propuesta: validar con Andrés. Primer match gana.

export const MODULES = [
  // [clave, título, archivo destino, regex]
  ['temporal', 'Temporal / respaldo', null,
    /^(_|wh_whr_backfill_universo$|tmp_|.*_bak(_|$)|.*bak_|respaldo_|cifras_sem\d+$|client_merge_survivor_snapshot$)/],
  ['seguridad', 'Seguridad y usuarios', '001_seguridad.sql',
    /^(users?$|user_|roles?$|role_|impersonation_|login_|audit_|permissions?|pba_authorized_users$|finanzas_access$)/],
  ['catalogos', 'Catálogos', '002_catalogos.sql',
    /^(offices|carriers|air_carriers|ports|ports_master|commodities|container_types|equipment_types|shipping_lines|agents|agent_office_mapping|agent_files|points_of_receipt|routes|transit_times|carrier_transit_times|email_templates|gloval_assets|brief_assets|phone_numbers)$/],
  ['crm', 'CRM y ventas', '010_crm.sql',
    /^(clients?$|client_|contacts?$|contact_|deals?$|deal_|sales_|quotes?$|quote_|prospect|call_logs$|activities$|activity_logs$|reminders$|credit_|cs_assignments$|cs_cuentas_habilitadas$|consignee_aliases$|time_entries$|rfq_log$|ventas_|birthday_emails_sent$)/],
  ['tarifas', 'Tarifas', '020_tarifas.sql',
    /^(rates?$|rate_|air_rate|contracts?$|contract_|surcharge|freight_|shipco_|inland_|lcl_|drayage_|tariff_|agent_rate|pricing_rules$|ec_fcl_local_charges)/],
  ['operaciones', 'Operaciones', '030_operaciones.sql',
    /^(ops_|shipments?$|shipment_|liq_|cierres_liquidacion$|shipping_instructions$|coordination_tasks$|dispatches$|external_containers$|container_files$|container_load_reports$|fcl_semanal$|fact_orders$|carrier_email_log$)/],
  ['bodega', 'Bodega Miami', '040_bodega.sql',
    /^(wh_|cl_|picking_|loading_|staging_|manifest_|bodega_|warehouse_|unplanned_additions$|reception_hosts$)/],
  ['consolidados', 'Consolidados', '050_consolidados.sql', /^consolidado/],
  ['finanzas', 'Finanzas', '060_finanzas.sql',
    /^(finanzas_|cash_|bank_|scheduled_payment|vendor_|arap_|fx_|nomina_|caja_|closings$|pba_|recurring_movement$|payment_commitment$|pagos_recurrentes_live$|cxc_send_log$|market_indices_daily$)/],
  ['magaya', 'Integración Magaya', '070_magaya.sql', /^(magaya_|wr_|ar_ap_sync_queue$)/],
  ['mi', 'Market intelligence', '080_market_intelligence.sql', /^mi_/],
  ['comisiones', 'Comisiones', '085_comisiones.sql', /^cmm_/],
  ['reportes', 'Dashboards y reportes', '087_reportes.sql', /^(dashboard_|brief_)/],
  ['christmas', 'Christmas Palace', '090_christmas.sql', /^christmas_/],
  ['otros', 'Otros', '095_otros.sql', /^(visitors?|visits?|visitor_|job_applicant|inhouse_|monday_|carrier_advisor)/],
];

const SCHEMA_FILES = {
  private: ['private', 'Esquema private', '100_private.sql'],
  archive: ['archive', 'Esquema archive', '101_archive.sql'],
  timeclock: ['timeclock', 'Esquema timeclock', '102_timeclock.sql'],
};
const UNCLASSIFIED = ['sin_clasificar', 'Sin clasificar', '099_sin_clasificar.sql'];

export function moduleOf(schema, table) {
  const hit = MODULES.find(([, , , re]) => re.test(table));
  if (hit && hit[0] === 'temporal') return { key: hit[0], title: hit[1], file: null };
  if (schema !== 'public') {
    const [key, title, file] = SCHEMA_FILES[schema];
    return { key, title, file };
  }
  const [key, title, file] = hit || UNCLASSIFIED;
  return { key, title, file };
}
