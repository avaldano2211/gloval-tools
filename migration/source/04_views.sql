-- Vistas
-- Origen: Supabase GES (wfzdrqfurwnakrfdnbgf), esquemas public, archive, private, timeclock.
-- Extraído del catálogo el 2026-09-29 (solo lectura). Referencia: NO ejecutar en Azure.
-- Credenciales redactadas como <SUPABASE_*>.

CREATE OR REPLACE VIEW archive.v_charges_classified AS
WITH tx AS (
         SELECT DISTINCT ON (magaya_transactions.magaya_guid) magaya_transactions.magaya_guid,
            magaya_transactions.transaction_type,
            magaya_transactions.issued_date,
            magaya_transactions.created_on,
            magaya_transactions.billing_client_name,
            magaya_transactions.consignee_name,
            magaya_transactions.shipper_name
           FROM magaya_transactions
          WHERE magaya_transactions.magaya_guid IS NOT NULL AND magaya_transactions.magaya_guid <> ''::text
          ORDER BY magaya_transactions.magaya_guid, magaya_transactions.version DESC NULLS LAST, magaya_transactions.synced_at DESC NULLS LAST
        ), charge_dates AS (
         SELECT mc.id,
            mc.charge_guid,
            mc.shipment_number,
            mc.shipment_guid,
            mc.charge_type,
            mc.entity_name,
            mc.entity_guid,
            mc.quantity,
            mc.price,
            mc.amount,
            mc.currency,
            mc.charge_description,
            mc.charge_code,
            mc.charge_category,
            mc.account_type,
            mc.account_name,
            mc.status,
            mc.is_prepaid,
            mc.is_credit,
            mc.is_third_party,
            mc.synced_at,
            mc.created_at,
            COALESCE(wr.created_on, cr.created_on, pk.created_on, t.issued_date, t.created_on::date, mc.created_at::date) AS op_date,
                CASE
                    WHEN wr.wr_number IS NOT NULL THEN 'WR'::text
                    WHEN cr.cr_number IS NOT NULL THEN 'CR'::text
                    WHEN pk.pk_number IS NOT NULL THEN 'PK'::text
                    WHEN t.transaction_type = 'WH'::text THEN 'WR'::text
                    WHEN t.transaction_type IS NOT NULL THEN t.transaction_type
                    ELSE 'UNKNOWN'::text
                END AS doc_type,
            COALESCE(t.billing_client_name, t.consignee_name, t.shipper_name, mc.entity_name) AS counterparty
           FROM archive.magaya_charges mc
             LEFT JOIN magaya_warehouse_receipts wr ON mc.shipment_number = wr.wr_number
             LEFT JOIN magaya_cargo_releases cr ON mc.shipment_number = cr.cr_number
             LEFT JOIN magaya_pickup_orders pk ON mc.shipment_number = pk.pk_number
             LEFT JOIN tx t ON t.magaya_guid = mc.shipment_guid
          WHERE mc.amount <> 0::numeric
        )
 SELECT id,
    charge_guid,
    shipment_number,
    shipment_guid,
    charge_type,
    entity_name,
    entity_guid,
    quantity,
    price,
    amount,
    currency,
    charge_description,
    charge_code,
    charge_category,
    account_type,
    account_name,
    status,
    is_prepaid,
    is_credit,
    is_third_party,
    synced_at,
    created_at,
    op_date,
    doc_type,
    counterparty,
        CASE
            WHEN charge_description ~~* '%ocean%'::text OR charge_description ~~* '%terminal handling%'::text OR charge_description ~~* '%destination charge%'::text OR charge_description ~~* '%forwarding fee%ocean%'::text OR charge_description ~~* '%bill of lading%'::text OR charge_description ~~* '%allowance%'::text THEN 'Ocean Freight'::text
            WHEN charge_description ~~* '%air freight%'::text OR charge_description ~~* '%air waybill%'::text OR charge_description ~~* '%fuel surcharge%'::text OR charge_description ~~* '%airline%'::text THEN 'Air Freight'::text
            WHEN charge_description ~~* '%local drayage%'::text OR charge_description ~~* '%inland%'::text OR charge_description ~~* '%delivery%'::text OR charge_description ~~* '%ground freight%'::text OR charge_description ~~* '%haz-mat ground%'::text THEN 'Ground / In-Land'::text
            WHEN charge_description ~~* '%pickup%'::text OR charge_description ~~* '%pick up%'::text OR charge_description ~~* '%pick-up%'::text THEN 'Pick-Up'::text
            WHEN charge_description ~~* '%loading%'::text OR charge_description ~~* '%unloading%'::text OR charge_description ~~* '%storage fee%'::text OR charge_description ~~* '%handling%'::text OR charge_description ~~* '%warehouse%'::text OR charge_description ~~* '%in and out%'::text OR charge_description ~~* '%repacking%'::text OR charge_description ~~* '%palletiz%'::text OR charge_description ~~* '%crating%'::text OR charge_description ~~* '%bonded%'::text OR charge_description ~~* '%receiving fee%'::text THEN 'Warehouse'::text
            WHEN charge_description ~~* '%custom%'::text OR charge_description ~~* '%documentation%'::text THEN 'Documentation / Customs'::text
            WHEN charge_description ~~* '%insurance%'::text THEN 'Insurance'::text
            WHEN charge_description ~~* '%sotfware%'::text OR charge_description ~~* '%software%'::text THEN 'Technology'::text
            WHEN charge_description ~~* '%storage%cost%'::text THEN 'Storage (Naviera)'::text
            ELSE 'Other'::text
        END AS business_line,
        CASE
            WHEN account_type = 'Income'::text THEN 'Revenue'::text
            WHEN account_type = ANY (ARRAY['Expense'::text, 'Cost of Sales'::text]) THEN 'COGS'::text
            WHEN charge_description ~~* '%cost%'::text THEN 'COGS'::text
            ELSE 'Revenue'::text
        END AS line_type
   FROM charge_dates cd;

CREATE OR REPLACE VIEW private._audit_billing_view AS
WITH vendor_map AS (
         SELECT v.vendedor_billing,
            v.expected_user_id,
            v.category
           FROM ( VALUES ('ASTUDILLO ANCHUNDIA JULIA GRACIELA'::text,'5d49777d-7e2c-4350-98a8-9eec6dd8f91c'::uuid,'sales'::text), ('CAICE ROJAS ILIANA'::text,'1309ae1c-d67f-4fbd-858f-adeb79de92d3'::uuid,'sales'::text), ('CALLE DELGADO LISBETH MERCEDES'::text,'46fc31be-4618-4cbd-9dd2-e845ba2881d4'::uuid,'sales'::text), ('CISNEROS ZAVALA CAROLINA'::text,'991eeb75-f01e-4806-bdd6-fbbe81f70e3c'::uuid,'sales'::text), ('JUAN PINO'::text,'c11fa5c2-8082-4642-9552-5a14a1cb0abe'::uuid,'sales'::text), ('LEON COELLO VALERIA'::text,'817b96a1-5ab9-4c68-92e9-7ffc781a6104'::uuid,'sales'::text), ('LORENA MORENO'::text,'05c1137e-1f86-4ebe-aea9-b70c1b19bcb6'::uuid,'sales'::text), ('MORENO BURGOS LORENA'::text,'05c1137e-1f86-4ebe-aea9-b70c1b19bcb6'::uuid,'sales'::text), ('OBANDO BOZZA MIGUEL EDUARDO'::text,'4aaacb1d-4cd5-4e2d-9761-efe6ae943c1c'::uuid,'sales'::text), ('RIVERA SOLIS PAMELA ALEXANDRA'::text,'79870655-a4ea-4ea2-be69-0f1f41733f3c'::uuid,'sales'::text), ('RONQUILLO FRANCO AMALIA'::text,'281c5ffd-02d8-4361-ac81-0871b7419504'::uuid,'sales'::text), ('SALCEDO CHACON PAOLA ELIZABETH'::text,'ad437a76-61db-4abe-98e6-4a2082d33ed6'::uuid,'sales'::text), ('SILVA ALAVA ANA MERCEDES'::text,'3306f06a-7e75-4abf-9ce7-207717b96d9e'::uuid,'sales'::text), ('DIRECTO'::text,NULL::uuid,'house'::text), ('DIRECTO/GNEC'::text,NULL::uuid,'house'::text), ('AGENTE DE CARGA'::text,NULL::uuid,'agent'::text), ('HARO RODRIGUEZ GABRIEL FERNANDO'::text,NULL::uuid,'unknown_vendor'::text), ('CORDOVA KATYA'::text,'170e0888-e56f-472c-a379-b9e83d3a732f'::uuid,'admin'::text), ('MORALES SHIRLEY'::text,'e0dc8943-9991-4403-a18f-16feb779a2fe'::uuid,'cs'::text)) v(vendedor_billing, expected_user_id, category)
        ), matched AS (
         SELECT DISTINCT ON (a.client_name_billing) a.client_name_billing,
            a.vendedor_billing,
            a.client_name_norm,
            a.total_ytd,
            c.id AS crm_client_id,
            c.company_name AS crm_company_name,
            c.assigned_to AS crm_assigned_to,
            c.is_house_account,
            c.office AS crm_office
           FROM private._audit_billing_ec_2026q1 a
             LEFT JOIN private._audit_clients_ec c ON c.norm = a.client_name_norm OR c.norm_no_parens = a.client_name_norm
          ORDER BY a.client_name_billing, (
                CASE
                    WHEN c.norm = a.client_name_norm THEN 1
                    ELSE 2
                END)
        )
 SELECT m.client_name_billing,
    m.vendedor_billing,
    vm.expected_user_id,
    vm.category AS billing_category,
    m.total_ytd,
    m.crm_client_id,
    m.crm_company_name,
    m.crm_assigned_to,
    u.name AS crm_assigned_name,
    m.is_house_account,
    m.crm_office,
        CASE
            WHEN m.crm_client_id IS NULL THEN 'NOT_IN_CRM'::text
            WHEN vm.category = 'house'::text AND NOT COALESCE(m.is_house_account, false) THEN 'SHOULD_BE_HOUSE'::text
            WHEN vm.category = 'sales'::text AND m.crm_assigned_to IS DISTINCT FROM vm.expected_user_id THEN 'WRONG_VENDOR'::text
            WHEN vm.category = 'unknown_vendor'::text THEN 'UNKNOWN_BILLING_VENDOR'::text
            WHEN m.vendedor_billing IS NULL AND m.crm_assigned_to IS NOT NULL THEN 'BILLING_BLANK_BUT_ASSIGNED'::text
            ELSE 'OK'::text
        END AS status
   FROM matched m
     LEFT JOIN vendor_map vm ON vm.vendedor_billing = m.vendedor_billing
     LEFT JOIN users u ON u.id = m.crm_assigned_to;

CREATE OR REPLACE VIEW private._audit_billing_view_v2 AS
WITH vendor_map AS (
         SELECT v.vendedor_billing,
            v.expected_user_id,
            v.category
           FROM ( VALUES ('ASTUDILLO ANCHUNDIA JULIA GRACIELA'::text,'5d49777d-7e2c-4350-98a8-9eec6dd8f91c'::uuid,'sales'::text), ('CAICE ROJAS ILIANA'::text,'1309ae1c-d67f-4fbd-858f-adeb79de92d3'::uuid,'sales'::text), ('CALLE DELGADO LISBETH MERCEDES'::text,'46fc31be-4618-4cbd-9dd2-e845ba2881d4'::uuid,'sales'::text), ('CISNEROS ZAVALA CAROLINA'::text,'991eeb75-f01e-4806-bdd6-fbbe81f70e3c'::uuid,'sales'::text), ('JUAN PINO'::text,'c11fa5c2-8082-4642-9552-5a14a1cb0abe'::uuid,'sales'::text), ('LEON COELLO VALERIA'::text,'817b96a1-5ab9-4c68-92e9-7ffc781a6104'::uuid,'sales'::text), ('LORENA MORENO'::text,'05c1137e-1f86-4ebe-aea9-b70c1b19bcb6'::uuid,'sales'::text), ('MORENO BURGOS LORENA'::text,'05c1137e-1f86-4ebe-aea9-b70c1b19bcb6'::uuid,'sales'::text), ('OBANDO BOZZA MIGUEL EDUARDO'::text,'4aaacb1d-4cd5-4e2d-9761-efe6ae943c1c'::uuid,'sales'::text), ('RIVERA SOLIS PAMELA ALEXANDRA'::text,'79870655-a4ea-4ea2-be69-0f1f41733f3c'::uuid,'sales'::text), ('RONQUILLO FRANCO AMALIA'::text,'281c5ffd-02d8-4361-ac81-0871b7419504'::uuid,'sales'::text), ('SALCEDO CHACON PAOLA ELIZABETH'::text,'ad437a76-61db-4abe-98e6-4a2082d33ed6'::uuid,'sales'::text), ('SILVA ALAVA ANA MERCEDES'::text,'3306f06a-7e75-4abf-9ce7-207717b96d9e'::uuid,'sales'::text), ('DIRECTO'::text,NULL::uuid,'house'::text), ('DIRECTO/GNEC'::text,NULL::uuid,'house'::text), ('AGENTE DE CARGA'::text,NULL::uuid,'agent'::text), ('HARO RODRIGUEZ GABRIEL FERNANDO'::text,NULL::uuid,'unknown_vendor'::text), ('CORDOVA KATYA'::text,'170e0888-e56f-472c-a379-b9e83d3a732f'::uuid,'admin'::text), ('MORALES SHIRLEY'::text,'e0dc8943-9991-4403-a18f-16feb779a2fe'::uuid,'cs'::text)) v(vendedor_billing, expected_user_id, category)
        ), matched AS (
         SELECT b.client_name_billing,
            b.vendedor_billing,
            b.total_ytd,
            b.magaya_tax_id,
            b.magaya_name,
            COALESCE(c_ruc.id, c_name.id) AS crm_client_id,
            COALESCE(c_ruc.company_name, c_name.company_name) AS crm_company_name,
            COALESCE(c_ruc.assigned_to, c_name.assigned_to) AS crm_assigned_to,
            COALESCE(c_ruc.is_house_account, c_name.is_house_account) AS is_house_account,
                CASE
                    WHEN c_ruc.id IS NOT NULL THEN 'ruc'::text
                    WHEN c_name.id IS NOT NULL THEN 'name'::text
                    ELSE 'none'::text
                END AS match_method
           FROM private._audit_billing_ruc b
             LEFT JOIN private._audit_clients_ec_ruc c_ruc ON c_ruc.ruc_clean = regexp_replace(COALESCE(b.magaya_tax_id, ''::text), '\D'::text, ''::text, 'g'::text) AND c_ruc.ruc_clean <> ''::text
             LEFT JOIN LATERAL ( SELECT _audit_clients_ec.id,
                    _audit_clients_ec.company_name,
                    _audit_clients_ec.norm,
                    _audit_clients_ec.norm_no_parens,
                    _audit_clients_ec.assigned_to,
                    _audit_clients_ec.is_house_account,
                    _audit_clients_ec.office
                   FROM private._audit_clients_ec
                  WHERE _audit_clients_ec.norm = b.client_name_norm OR _audit_clients_ec.norm_no_parens = b.client_name_norm
                 LIMIT 1) c_name ON c_ruc.id IS NULL
        )
 SELECT m.client_name_billing,
    m.vendedor_billing,
    vm.expected_user_id,
    vm.category AS billing_category,
    m.total_ytd,
    m.magaya_tax_id,
    m.match_method,
    m.crm_client_id,
    m.crm_company_name,
    m.crm_assigned_to,
    u.name AS crm_assigned_name,
    m.is_house_account,
        CASE
            WHEN m.crm_client_id IS NULL THEN 'NOT_IN_CRM'::text
            WHEN vm.category = 'house'::text AND NOT COALESCE(m.is_house_account, false) THEN 'SHOULD_BE_HOUSE'::text
            WHEN vm.category = 'sales'::text AND m.crm_assigned_to IS DISTINCT FROM vm.expected_user_id THEN 'WRONG_VENDOR'::text
            WHEN vm.category = 'unknown_vendor'::text THEN 'UNKNOWN_BILLING_VENDOR'::text
            WHEN m.vendedor_billing IS NULL AND m.crm_assigned_to IS NOT NULL THEN 'BILLING_BLANK_BUT_ASSIGNED'::text
            ELSE 'OK'::text
        END AS status
   FROM matched m
     LEFT JOIN vendor_map vm ON vm.vendedor_billing = m.vendedor_billing
     LEFT JOIN users u ON u.id = m.crm_assigned_to;

CREATE OR REPLACE VIEW public.agent_rates AS
SELECT id,
    agent,
    pol,
    pod,
    carrier,
    rate_20gp,
    rate_40st,
    rate_40hq,
    rate_40nor,
    free_days,
    nor_free_days,
    validity,
    notes,
    trade_lane,
    created_at
   FROM _legacy_agent_rates;

CREATE OR REPLACE VIEW public.cash_movement_effective AS
SELECT id,
    tenant_id,
    office_id,
    bank_account_id,
    direction,
    category,
    source_type,
    source_id,
    party_id,
    amount,
    currency,
    amount_in_usd,
    expected_date,
    actual_date,
    status,
    confidence,
    linked_bank_transaction_id,
    linked_scenario_id,
    notes,
    created_by,
    approved_by,
    approved_at,
    created_at,
    updated_at,
    counterparty_name,
    external_reference,
    external_guid
   FROM cash_movement cm
  WHERE ((finanzas_office_code_for_office(office_id) IN ( SELECT unnest(app_finanzas_offices()) AS unnest)) OR ( SELECT COALESCE(auth.role(), ''::text) <> ALL (ARRAY['authenticated'::text, 'anon'::text]))) AND (status <> 'forecast'::text OR NOT (EXISTS ( SELECT 1
           FROM cash_movement cm2
          WHERE cm2.tenant_id = cm.tenant_id AND NOT cm2.counterparty_name IS DISTINCT FROM cm.counterparty_name AND cm2.status <> 'forecast'::text AND abs(cm2.expected_date - cm.expected_date) <= 7)));

CREATE OR REPLACE VIEW public.cl_next_priority_per_shipment AS
SELECT manifest_source_id,
    min(loading_priority) AS next_priority,
    count(*) FILTER (WHERE load_status = 'pending'::load_item_status) AS pending_priority_items,
    count(*) AS total_priority_items
   FROM manifest_items
  WHERE loading_priority IS NOT NULL AND (load_status = ANY (ARRAY['pending'::load_item_status, 'loaded'::load_item_status]))
  GROUP BY manifest_source_id;

CREATE OR REPLACE VIEW public.cl_supervisor_pending_exceptions AS
SELECT 'picking'::text AS phase,
    pe.id,
    pe.exception_type::text AS type,
    pe.reason,
    pe.raised_by,
    pe.raised_at,
    pt.manifest_source_id,
    ms.external_number,
    mi.barcode AS item_barcode
   FROM picking_exceptions pe
     JOIN picking_tasks pt ON pt.id = pe.picking_task_id
     JOIN manifest_sources ms ON ms.id = pt.manifest_source_id
     LEFT JOIN manifest_items mi ON mi.id = pe.manifest_item_id
  WHERE pe.resolved = false
UNION ALL
 SELECT 'staging'::text AS phase,
    se.id,
    se.exception_type::text AS type,
    se.reason,
    se.raised_by,
    se.raised_at,
    sct.manifest_source_id,
    ms.external_number,
    'multiple'::text AS item_barcode
   FROM staging_exceptions se
     JOIN staging_check_tasks sct ON sct.id = se.staging_task_id
     JOIN manifest_sources ms ON ms.id = sct.manifest_source_id
  WHERE se.resolved = false
UNION ALL
 SELECT 'loading'::text AS phase,
    le.id,
    le.exception_type::text AS type,
    le.reason,
    le.raised_by,
    le.raised_at,
    lt.manifest_source_id,
    ms.external_number,
    mi.barcode AS item_barcode
   FROM loading_exceptions le
     JOIN loading_tasks lt ON lt.id = le.loading_task_id
     JOIN manifest_sources ms ON ms.id = lt.manifest_source_id
     LEFT JOIN manifest_items mi ON mi.id = le.manifest_item_id
  WHERE le.authorized_at IS NULL;

CREATE OR REPLACE VIEW public.cl_supervisor_shipment_queue AS
SELECT id,
    external_number,
    source_type,
    customer_name,
    destination,
    container_number,
    container_type,
    workflow_status,
    warehouse_id,
    ( SELECT count(*) AS count
           FROM manifest_items
          WHERE manifest_items.manifest_source_id = ms.id) AS total_items,
    ( SELECT count(*) AS count
           FROM manifest_items
          WHERE manifest_items.manifest_source_id = ms.id AND manifest_items.pick_status = 'picked'::pick_item_status) AS picked_items,
    ( SELECT count(*) AS count
           FROM manifest_items
          WHERE manifest_items.manifest_source_id = ms.id AND manifest_items.staging_status = 'verified'::staging_item_status) AS verified_items,
    ( SELECT count(*) AS count
           FROM manifest_items
          WHERE manifest_items.manifest_source_id = ms.id AND manifest_items.load_status = 'loaded'::load_item_status) AS loaded_items,
    ( SELECT sum(manifest_items.weight_kg) AS sum
           FROM manifest_items
          WHERE manifest_items.manifest_source_id = ms.id) AS expected_weight_kg,
    ( SELECT sum(manifest_items.volume_m3) AS sum
           FROM manifest_items
          WHERE manifest_items.manifest_source_id = ms.id) AS expected_volume_m3
   FROM manifest_sources ms;

CREATE OR REPLACE VIEW public.cl_warehouse_kpis AS
SELECT id AS warehouse_id,
    code,
    ( SELECT count(*) AS count
           FROM picking_tasks pt
             JOIN manifest_sources ms ON ms.id = pt.manifest_source_id
          WHERE ms.warehouse_id = w.id AND (pt.status = ANY (ARRAY['pending'::cl_task_status, 'in_progress'::cl_task_status]))) AS active_picking,
    ( SELECT count(*) AS count
           FROM manifest_sources
          WHERE manifest_sources.warehouse_id = w.id AND manifest_sources.workflow_status = 'ready_for_staging'::text) AS ready_for_staging,
    ( SELECT count(*) AS count
           FROM staging_check_tasks sct
             JOIN manifest_sources ms ON ms.id = sct.manifest_source_id
          WHERE ms.warehouse_id = w.id AND (sct.status = ANY (ARRAY['pending'::cl_task_status, 'in_progress'::cl_task_status]))) AS active_staging,
    ( SELECT count(*) AS count
           FROM loading_tasks lt
             JOIN manifest_sources ms ON ms.id = lt.manifest_source_id
          WHERE ms.warehouse_id = w.id AND (lt.status = ANY (ARRAY['pending'::loading_task_status, 'pre_load'::loading_task_status, 'in_progress'::loading_task_status]))) AS active_loading
   FROM cl_warehouses w;

CREATE OR REPLACE VIEW public.picker_manifest_view AS
SELECT mi.id,
    mi.manifest_source_id,
    mi.barcode,
    mi.item_type,
    mi.description,
    mi.weight_kg,
    mi.volume_m3,
    mi.is_hazmat,
    mi.hazmat_un,
    mi.is_heavy,
    mi.is_fragile,
    mi.pick_status,
    mi.assigned_picking_task_id,
    mi.picked_at,
    mi.picked_by,
    mi.staging_status,
    mi.verified_at,
    mi.verified_by,
    mi.load_status,
    mi.loaded_at,
    mi.loaded_by,
    mi.load_scan_order,
    mi.load_photo_url,
    mi.created_at,
    mi.updated_at,
    mi.wr_number,
    mi.location,
    mi.dimensions,
    mi.is_bonded,
    mi.is_fumigated,
    mi.package_descriptor,
    mi.shipper_name,
    mi.consignee_name,
    mi.reference_photo_url,
    ms.external_number,
    ms.container_number,
    ms.warehouse_id
   FROM manifest_items mi
     JOIN manifest_sources ms ON ms.id = mi.manifest_source_id;

CREATE OR REPLACE VIEW public.unified_rates AS
SELECT min(r.id::text) AS id,
        CASE
            WHEN r.agent_id IS NOT NULL THEN 'agente'::text
            ELSE 'naviera'::text
        END AS source,
    a.company_name AS agent,
    c.code::text AS carrier,
    po.name::text AS pol,
    pd.name::text AS pod,
        CASE
            WHEN po.code::text ~~ 'CN%'::text AND pd.code::text ~~ 'PE%'::text THEN 'CHINA-PERU'::text
            WHEN po.code::text ~~ 'CN%'::text AND pd.code::text ~~ 'EC%'::text THEN 'CHINA-ECUADOR'::text
            WHEN po.code::text ~~ 'CN%'::text AND pd.code::text ~~ 'PA%'::text THEN 'CHINA-PANAMA'::text
            ELSE con.source_region::text
        END AS trade_lane,
    max(
        CASE
            WHEN et.code::text = '20GP'::text THEN r.base_rate
            ELSE NULL::numeric
        END) AS rate_20gp,
    max(
        CASE
            WHEN et.code::text = ANY (ARRAY['40GP'::text, '40ST'::text]) THEN r.base_rate
            ELSE NULL::numeric
        END) AS rate_40st,
    max(
        CASE
            WHEN et.code::text = ANY (ARRAY['40HC'::text, '40HQ'::text]) THEN r.base_rate
            ELSE NULL::numeric
        END) AS rate_40hq,
    max(
        CASE
            WHEN et.code::text = '40NOR'::text THEN r.base_rate
            ELSE NULL::numeric
        END) AS rate_40nor,
    max(r.transit_time) FILTER (WHERE et.code::text <> '40NOR'::text) AS free_days,
    max(r.transit_time) FILTER (WHERE et.code::text = '40NOR'::text) AS nor_free_days,
    (to_char(min(r.effective_date)::timestamp with time zone, 'MM/DD'::text) || ' - '::text) || to_char(max(r.expiry_date)::timestamp with time zone, 'MM/DD'::text) AS validity,
    min(r.effective_date) AS effective_date,
    max(r.expiry_date) AS expiry_date,
    min(r.notes) AS notes,
    min(r.created_at) AS created_at
   FROM rates r
     LEFT JOIN contracts con ON r.contract_id = con.id
     LEFT JOIN carriers c ON con.carrier_id = c.id
     LEFT JOIN agents a ON r.agent_id = a.id
     LEFT JOIN equipment_types et ON r.equipment_type_id = et.id
     LEFT JOIN freight_routes fr ON r.route_id = fr.id
     LEFT JOIN ports po ON fr.origin_port_id = po.id
     LEFT JOIN ports pd ON fr.destination_port_id = pd.id
  WHERE r.active = true OR r.active IS NULL
  GROUP BY (
        CASE
            WHEN r.agent_id IS NOT NULL THEN 'agente'::text
            ELSE 'naviera'::text
        END), a.company_name, c.code, po.name, pd.name, po.code, pd.code, con.source_region, fr.id, con.id, r.agent_id;

CREATE OR REPLACE VIEW public.v_air_rates_por_confirmar AS
SELECT ac.id AS air_carrier_id,
    ac.name AS aerolinea,
    count(*) AS tarifas,
    min(COALESCE(ar.last_confirmed_at, ar.effective_date)) AS ultima_novedad,
    CURRENT_DATE - min(COALESCE(ar.last_confirmed_at, ar.effective_date)) AS dias,
    max(ar.effective_date) AS ultimo_cambio_de_precio
   FROM air_rates ar
     JOIN air_carriers ac ON ac.id = ar.air_carrier_id
  WHERE ar.active
  GROUP BY ac.id, ac.name
 HAVING (CURRENT_DATE - min(COALESCE(ar.last_confirmed_at, ar.effective_date))) > 30
  ORDER BY (CURRENT_DATE - min(COALESCE(ar.last_confirmed_at, ar.effective_date))) DESC;

CREATE OR REPLACE VIEW public.v_analytics_master AS
SELECT c.id,
    c.charge_guid,
    c.shipment_number,
    c.amount,
    c.charge_description,
    c.account_type,
    c.account_name,
    c.entity_name,
    c.op_date,
    c.business_line,
    c.line_type,
    c.doc_type,
    COALESCE(inv.client_name, b.vendor_name, c.counterparty) AS client_name,
    COALESCE(inv.created_by, b.created_by) AS agent_name,
        CASE
            WHEN COALESCE(inv.client_name, b.vendor_name, c.counterparty) ~~* '%Ecuador%'::text THEN 'Ecuador'::text
            WHEN COALESCE(inv.client_name, b.vendor_name, c.counterparty) ~~* '%Panama%'::text THEN 'Panama'::text
            WHEN COALESCE(inv.client_name, b.vendor_name, c.counterparty) ~~* '%Peru%'::text THEN 'Peru'::text
            WHEN COALESCE(inv.client_name, b.vendor_name, c.counterparty) ~~* '%Colombia%'::text THEN 'Colombia'::text
            WHEN COALESCE(inv.client_name, b.vendor_name, c.counterparty) ~~* '%Chile%'::text OR COALESCE(inv.client_name, b.vendor_name, c.counterparty) ~~* '%IFS%'::text THEN 'Chile'::text
            WHEN COALESCE(inv.client_name, b.vendor_name, c.counterparty) ~~* '%M3 CARGO%'::text THEN 'Colombia'::text
            WHEN COALESCE(inv.client_name, b.vendor_name, c.counterparty) ~~* '%Gloval%'::text THEN 'Inter-company'::text
            ELSE 'USA (Direct Client)'::text
        END AS country,
        CASE
            WHEN cr.cr_number IS NOT NULL THEN 'Pasa por Bodega'::text
            WHEN wr.wr_number IS NOT NULL THEN 'Pasa por Bodega'::text
            WHEN c.business_line = 'Warehouse'::text THEN 'Pasa por Bodega'::text
            ELSE 'Foreign-to-Foreign'::text
        END AS flow_type,
    EXTRACT(year FROM c.op_date)::integer AS year,
    EXTRACT(month FROM c.op_date)::integer AS month,
    EXTRACT(quarter FROM c.op_date)::integer AS quarter,
    EXTRACT(week FROM c.op_date)::integer AS week,
    inv.status AS invoice_status,
    inv.total_amount AS invoice_total,
    inv.amount_paid AS invoice_paid,
    b.total_amount AS bill_total,
    b.amount_paid AS bill_paid,
    b.status AS bill_status
   FROM archive.v_charges_classified c
     LEFT JOIN magaya_invoices inv ON c.shipment_number = inv.invoice_number
     LEFT JOIN magaya_bills b ON c.shipment_number = b.bill_number
     LEFT JOIN ( SELECT DISTINCT magaya_cargo_releases.cr_number
           FROM magaya_cargo_releases) cr ON c.shipment_number = cr.cr_number
     LEFT JOIN ( SELECT DISTINCT magaya_warehouse_receipts.wr_number
           FROM magaya_warehouse_receipts) wr ON c.shipment_number = wr.wr_number
  WHERE c.op_date IS NOT NULL;

CREATE OR REPLACE VIEW public.v_bank_match_candidates AS
WITH bank_sig AS (
         SELECT bt.id AS bank_id,
            bt.bank_account_id,
            ba.office_id,
            bt.transaction_date AS bd,
            bt.amount AS bamount,
            bt.description AS bdesc,
            bt.counterparty_name_raw AS bcp,
                CASE
                    WHEN bt.amount > 0::numeric THEN 'inflow'::text
                    ELSE 'outflow'::text
                END AS dir,
            round(abs(bt.amount), 2) AS amt
           FROM bank_transaction bt
             JOIN bank_account ba ON ba.id = bt.bank_account_id
          WHERE bt.matched_payment_id IS NULL AND ba.active = true AND ((finanzas_office_code_for_office(ba.office_id) IN ( SELECT unnest(app_finanzas_offices()) AS unnest)) OR ( SELECT COALESCE(auth.role(), ''::text) <> ALL (ARRAY['authenticated'::text, 'anon'::text])))
        ), cash_sig AS (
         SELECT cm.id AS cash_id,
            cm.office_id,
            cm.expected_date AS cd,
            cm.amount_in_usd AS camount,
            cm.counterparty_name AS cname,
            cm.external_reference AS cref,
            cm.direction AS dir,
            round(cm.amount_in_usd::numeric, 2) AS amt,
            first_significant_word(cm.counterparty_name) AS cname_key
           FROM cash_movement cm
          WHERE cm.status = 'committed'::text AND cm.amount_in_usd IS NOT NULL
        ), joined AS (
         SELECT b.bank_id,
            b.bank_account_id,
            b.bd,
            b.bamount,
            b.bdesc,
            b.bcp,
            c.cash_id,
            c.cd,
            c.camount,
            c.cname,
            c.cref,
            b.dir,
            b.amt,
            abs(b.bd - c.cd) AS day_gap,
                CASE
                    WHEN c.cname_key IS NULL THEN 0
                    WHEN upper(b.bdesc) ~ (('\m'::text || c.cname_key) || '\M'::text) THEN 1
                    ELSE 0
                END AS cp_word_match,
            similarity(upper((COALESCE(b.bcp, ''::text) || ' '::text) || COALESCE(b.bdesc, ''::text)), upper(COALESCE(c.cname, ''::text))) AS sim
           FROM bank_sig b
             JOIN cash_sig c ON c.office_id = b.office_id AND c.dir = b.dir AND c.amt = b.amt
          WHERE abs(b.bd - c.cd) <= 60
        )
 SELECT bank_id,
    bank_account_id,
    bd,
    bamount,
    bdesc,
    bcp,
    cash_id,
    cd,
    camount,
    cname,
    cref,
    dir,
    amt,
    day_gap,
    cp_word_match,
    sim,
    LEAST(100, 60 + cp_word_match * 25 +
        CASE
            WHEN sim > 0.5::double precision THEN 10
            WHEN sim > 0.3::double precision THEN 7
            WHEN sim > 0.15::double precision THEN 4
            ELSE 0
        END +
        CASE
            WHEN day_gap = 0 THEN 10
            WHEN day_gap <= 3 THEN 7
            WHEN day_gap <= 7 THEN 5
            WHEN day_gap <= 30 THEN 2
            ELSE 0
        END +
        CASE
            WHEN amt >= 10000::numeric THEN 5
            WHEN amt >= 5000::numeric THEN 3
            WHEN amt >= 1000::numeric THEN 1
            ELSE 0
        END) AS score
   FROM joined;

CREATE OR REPLACE VIEW public.v_carrier_advisories_pendientes AS
SELECT carrier_code,
    published_on,
    effective_on,
    kind,
    title,
    url,
    first_seen_at
   FROM carrier_advisories
  WHERE notified_at IS NULL
  ORDER BY published_on DESC NULLS LAST, first_seen_at DESC;

CREATE OR REPLACE VIEW public.v_charges_by_flow_type AS
WITH cr_nums AS (
         SELECT DISTINCT magaya_cargo_releases.cr_number
           FROM magaya_cargo_releases
        ), wr_nums AS (
         SELECT DISTINCT magaya_warehouse_receipts.wr_number
           FROM magaya_warehouse_receipts
        )
 SELECT c.id,
    c.charge_guid,
    c.shipment_number,
    c.shipment_guid,
    c.charge_type,
    c.entity_name,
    c.entity_guid,
    c.quantity,
    c.price,
    c.amount,
    c.currency,
    c.charge_description,
    c.charge_code,
    c.charge_category,
    c.account_type,
    c.account_name,
    c.status,
    c.is_prepaid,
    c.is_credit,
    c.is_third_party,
    c.synced_at,
    c.created_at,
    c.op_date,
    c.doc_type,
    c.counterparty,
    c.business_line,
    c.line_type,
        CASE
            WHEN cr.cr_number IS NOT NULL THEN 'Pasa por Bodega'::text
            WHEN wr.wr_number IS NOT NULL THEN 'Pasa por Bodega'::text
            WHEN c.business_line = 'Warehouse'::text THEN 'Pasa por Bodega'::text
            ELSE 'Foreign-to-Foreign'::text
        END AS flow_type
   FROM archive.v_charges_classified c
     LEFT JOIN cr_nums cr ON c.shipment_number = cr.cr_number
     LEFT JOIN wr_nums wr ON c.shipment_number = wr.wr_number;

CREATE OR REPLACE VIEW public.v_churn_radar AS
WITH last_invoice AS (
         SELECT u.office_id,
            u.counterparty_name,
            max(u.invoice_date) AS last_invoice_date,
            sum(
                CASE
                    WHEN u.invoice_date >= (CURRENT_DATE - '1 year'::interval) THEN u.amount_in_usd
                    ELSE 0::numeric
                END) AS revenue_12m,
            sum(
                CASE
                    WHEN u.invoice_date >= (CURRENT_DATE - '6 mons'::interval) THEN u.amount_in_usd
                    ELSE 0::numeric
                END) AS revenue_6m,
            sum(
                CASE
                    WHEN u.invoice_date < (CURRENT_DATE - '6 mons'::interval) AND u.invoice_date >= (CURRENT_DATE - '1 year 6 mons'::interval) THEN u.amount_in_usd
                    ELSE 0::numeric
                END) AS revenue_prior_12m
           FROM v_magaya_invoices_unified u
          WHERE u.direction = 'inflow'::text AND u.invoice_date <= CURRENT_DATE AND NOT is_intercompany_name(u.counterparty_name)
          GROUP BY u.office_id, u.counterparty_name
        )
 SELECT li.office_id,
    o.code AS office_code,
    li.counterparty_name,
    li.last_invoice_date,
    CURRENT_DATE - li.last_invoice_date AS days_since_last_invoice,
    li.revenue_prior_12m::numeric(15,2) AS revenue_prior_12m,
    li.revenue_6m::numeric(15,2) AS revenue_6m,
    li.revenue_12m::numeric(15,2) AS revenue_12m
   FROM last_invoice li
     JOIN offices o ON o.id = li.office_id::text
  WHERE li.revenue_prior_12m > 1000::numeric AND li.revenue_6m = 0::numeric AND (CURRENT_DATE - li.last_invoice_date) >= 90 AND (CURRENT_DATE - li.last_invoice_date) <= 540 AND ((o.code IN ( SELECT unnest(app_finanzas_offices()) AS unnest)) OR ( SELECT COALESCE(auth.role(), ''::text) <> ALL (ARRAY['authenticated'::text, 'anon'::text])))
  ORDER BY li.revenue_prior_12m DESC;

CREATE OR REPLACE VIEW public.v_client_ar AS
SELECT meb.office_id,
    o.code AS office_code,
    clean_entity_name(meb.entity_name) AS client_name,
    sum(meb.balance_usd)::numeric(15,2) AS ar_open_usd,
    max(meb.fetched_at) AS fetched_at
   FROM magaya_entity_balance meb
     JOIN offices o ON o.id = meb.office_id::text
  WHERE meb.kind = 'AR'::text AND meb.balance_usd > 0::numeric AND ((o.code IN ( SELECT unnest(app_finanzas_offices()) AS unnest)) OR ( SELECT COALESCE(auth.role(), ''::text) <> ALL (ARRAY['authenticated'::text, 'anon'::text])))
  GROUP BY meb.office_id, o.code, (clean_entity_name(meb.entity_name));

CREATE OR REPLACE VIEW public.v_client_monthly AS
SELECT u.office_id,
    o.code AS office_code,
    u.counterparty_name AS client_name,
    is_intercompany_name(u.counterparty_name) AS is_intercompany,
    date_trunc('month'::text, u.invoice_date::timestamp with time zone)::date AS month,
    count(*) AS invoice_count,
    sum(u.amount_in_usd)::numeric(15,2) AS revenue_usd
   FROM v_magaya_invoices_unified u
     JOIN offices o ON o.id = u.office_id::text
  WHERE u.direction = 'inflow'::text AND u.invoice_date >= (CURRENT_DATE - '2 years'::interval) AND u.invoice_date <= CURRENT_DATE AND ((o.code IN ( SELECT unnest(app_finanzas_offices()) AS unnest)) OR ( SELECT COALESCE(auth.role(), ''::text) <> ALL (ARRAY['authenticated'::text, 'anon'::text])))
  GROUP BY u.office_id, o.code, u.counterparty_name, (date_trunc('month'::text, u.invoice_date::timestamp with time zone));

CREATE OR REPLACE VIEW public.v_client_payment_behavior AS
WITH executed AS (
         SELECT cash_movement.counterparty_name,
            lower(regexp_replace(COALESCE(cash_movement.counterparty_name, ''::text), '\s+'::text, ' '::text, 'g'::text)) AS counterparty_key,
            cash_movement.office_id,
            cash_movement.actual_date - cash_movement.expected_date AS days_late,
            cash_movement.actual_date,
            cash_movement.amount_in_usd
           FROM cash_movement
          WHERE cash_movement.direction = 'inflow'::text AND cash_movement.status = 'executed'::text AND cash_movement.actual_date IS NOT NULL AND cash_movement.expected_date IS NOT NULL AND cash_movement.counterparty_name IS NOT NULL AND ((finanzas_office_code_for_office(cash_movement.office_id) IN ( SELECT unnest(app_finanzas_offices()) AS unnest)) OR ( SELECT COALESCE(auth.role(), ''::text) <> ALL (ARRAY['authenticated'::text, 'anon'::text])))
        )
 SELECT counterparty_name,
    counterparty_key,
    office_id,
    count(*) AS sample_size,
    round(avg(days_late), 1) AS mean_days_late,
    percentile_cont(0.25::double precision) WITHIN GROUP (ORDER BY (days_late::double precision)) AS p25_days_late,
    percentile_cont(0.50::double precision) WITHIN GROUP (ORDER BY (days_late::double precision)) AS median_days_late,
    percentile_cont(0.75::double precision) WITHIN GROUP (ORDER BY (days_late::double precision)) AS p75_days_late,
    max(actual_date) AS last_payment_date,
    round(avg(amount_in_usd), 2) AS avg_payment_amount
   FROM executed
  GROUP BY counterparty_name, counterparty_key, office_id;

CREATE OR REPLACE VIEW public.v_client_summary AS
WITH monthly AS (
         SELECT v_client_monthly.office_id,
            v_client_monthly.office_code,
            v_client_monthly.client_name,
            v_client_monthly.is_intercompany,
            v_client_monthly.month,
            v_client_monthly.invoice_count,
            v_client_monthly.revenue_usd
           FROM v_client_monthly
        ), agg AS (
         SELECT monthly.office_id,
            monthly.office_code,
            monthly.client_name,
            monthly.is_intercompany,
            sum(monthly.revenue_usd) FILTER (WHERE monthly.month >= (CURRENT_DATE - '1 year'::interval)) AS revenue_12m,
            sum(monthly.revenue_usd) FILTER (WHERE monthly.month >= (CURRENT_DATE - '2 years'::interval) AND monthly.month < (CURRENT_DATE - '1 year'::interval)) AS revenue_prior_12m,
            sum(monthly.revenue_usd) FILTER (WHERE monthly.month >= (CURRENT_DATE - '3 mons'::interval)) AS revenue_3m,
            sum(monthly.revenue_usd) FILTER (WHERE monthly.month >= (CURRENT_DATE - '6 mons'::interval) AND monthly.month < (CURRENT_DATE - '3 mons'::interval)) AS revenue_prior_3m,
            sum(monthly.invoice_count) FILTER (WHERE monthly.month >= (CURRENT_DATE - '1 year'::interval)) AS invoices_12m,
            count(DISTINCT monthly.month) FILTER (WHERE monthly.month >= (CURRENT_DATE - '1 year'::interval)) AS active_months_12m,
            max(monthly.month) AS last_active_month,
            ARRAY( SELECT COALESCE(sum(m.revenue_usd) FILTER (WHERE m.month = date_trunc('month'::text, d.d)::date), 0::numeric) AS "coalesce"
                   FROM generate_series(date_trunc('month'::text, CURRENT_DATE - '11 mons'::interval)::timestamp with time zone, date_trunc('month'::text, CURRENT_DATE::timestamp with time zone), '1 mon'::interval) d(d)
                     LEFT JOIN monthly m ON m.office_id = monthly.office_id AND m.client_name = monthly.client_name AND m.month = date_trunc('month'::text, d.d)::date) AS spark_12m
           FROM monthly
          GROUP BY monthly.office_id, monthly.office_code, monthly.client_name, monthly.is_intercompany
        )
 SELECT office_id,
    office_code,
    client_name,
    is_intercompany,
    revenue_12m,
    revenue_prior_12m,
    revenue_3m,
    revenue_prior_3m,
    invoices_12m,
    active_months_12m,
    last_active_month,
    spark_12m,
        CASE
            WHEN COALESCE(revenue_prior_12m, 0::numeric) = 0::numeric AND revenue_12m > 0::numeric THEN 'new'::text
            WHEN COALESCE(revenue_3m, 0::numeric) = 0::numeric AND COALESCE(revenue_prior_3m, 0::numeric) > 1000::numeric THEN 'churning'::text
            WHEN revenue_3m > (revenue_prior_3m * 1.2) THEN 'growing'::text
            WHEN revenue_3m < (revenue_prior_3m * 0.8) THEN 'declining'::text
            ELSE 'stable'::text
        END AS trend,
        CASE
            WHEN COALESCE(revenue_prior_12m, 0::numeric) > 0::numeric THEN round((revenue_12m - revenue_prior_12m) / revenue_prior_12m * 100::numeric, 1)
            ELSE NULL::numeric
        END AS yoy_growth_pct,
        CASE
            WHEN COALESCE(revenue_prior_3m, 0::numeric) > 0::numeric THEN round((revenue_3m - revenue_prior_3m) / revenue_prior_3m * 100::numeric, 1)
            ELSE NULL::numeric
        END AS qoq_growth_pct
   FROM agg
  WHERE COALESCE(revenue_12m, 0::numeric) > 0::numeric OR COALESCE(revenue_prior_12m, 0::numeric) > 0::numeric;

CREATE OR REPLACE VIEW public.v_cmm_client_alerts AS
WITH params AS (
         SELECT 60 AS lag_days
        )
 SELECT c.seller_id,
    c.vendedor,
    c.canal,
    c.estado,
    c.office,
    c.cliente,
    c.ganancia,
    c.embarques,
    c.last_shipment_date,
    c.days_since_last,
    c.shipments_30d,
    c.shipments_60d,
    c.last_senae_date,
    c.days_since_senae,
    c.senae_shipments_30d,
    c.senae_shipments_60d,
    c.senae_shipments_90d,
        CASE
            WHEN c.days_since_last IS NULL THEN 'no_data'::text
            WHEN c.days_since_last <= p.lag_days THEN 'active'::text
            WHEN COALESCE(c.senae_shipments_60d, 0::bigint) > 0 THEN 'pending_liquidation'::text
            WHEN (c.days_since_last - p.lag_days) >= 90 THEN 'churned'::text
            WHEN (c.days_since_last - p.lag_days) >= 60 THEN 'at_risk'::text
            WHEN (c.days_since_last - p.lag_days) >= 30 THEN 'slowing'::text
            ELSE 'paused'::text
        END AS churn_status,
        CASE
            WHEN c.ganancia_prev30d > 0::numeric THEN (c.ganancia_30d - c.ganancia_prev30d) / c.ganancia_prev30d * 100::numeric
            ELSE NULL::numeric
        END AS trend_30d_pct,
    p.lag_days AS data_lag_days,
    GREATEST(0, c.days_since_last - p.lag_days) AS effective_days_silent
   FROM v_cmm_clients c
     CROSS JOIN params p;

CREATE OR REPLACE VIEW public.v_cmm_client_breakdown AS
SELECT s.id AS seller_id,
    s.nombre AS vendedor,
    s.canal,
    s.estado,
    s.office,
    t.period_year,
    t.period_month,
    t.cliente,
    sum(t.ingresos) AS ingresos,
    sum(t.ganancia) AS ganancia,
    count(*) AS embarques
   FROM cmm_sellers s
     JOIN cmm_transactions t ON t.seller_id = s.id
  WHERE t.cliente IS NOT NULL AND t.cliente <> ''::text
  GROUP BY s.id, s.nombre, s.canal, s.estado, s.office, t.period_year, t.period_month, t.cliente;

CREATE OR REPLACE VIEW public.v_cmm_clients AS
WITH base AS (
         SELECT t.seller_id,
            t.cliente,
            sum(t.ingresos) AS ingresos,
            sum(t.ganancia) AS ganancia,
            count(*) AS embarques,
            min(t.period_month) AS primer_mes,
            min(t.period_year) AS primer_year,
            max(t.fecha) AS last_shipment_date,
            count(*) FILTER (WHERE t.fecha >= (CURRENT_DATE - '30 days'::interval)) AS shipments_30d,
            count(*) FILTER (WHERE t.fecha >= (CURRENT_DATE - '60 days'::interval)) AS shipments_60d,
            count(*) FILTER (WHERE t.fecha >= (CURRENT_DATE - '90 days'::interval)) AS shipments_90d,
            COALESCE(sum(t.ganancia) FILTER (WHERE t.fecha >= (CURRENT_DATE - '30 days'::interval)), 0::numeric) AS ganancia_30d,
            COALESCE(sum(t.ganancia) FILTER (WHERE t.fecha >= (CURRENT_DATE - '60 days'::interval) AND t.fecha < (CURRENT_DATE - '30 days'::interval)), 0::numeric) AS ganancia_prev30d
           FROM cmm_transactions t
          WHERE t.cliente IS NOT NULL AND t.cliente <> ''::text
          GROUP BY t.seller_id, t.cliente
        ), senae_shipments AS (
         SELECT cmm_senae_recency.cliente,
            cmm_senae_recency.last_senae_date,
            cmm_senae_recency.senae_30d,
            cmm_senae_recency.senae_60d,
            cmm_senae_recency.senae_90d
           FROM cmm_senae_recency() cmm_senae_recency(cliente, last_senae_date, senae_30d, senae_60d, senae_90d)
        )
 SELECT s.id AS seller_id,
    s.nombre AS vendedor,
    s.canal,
    s.estado,
    s.office,
    b.cliente,
    b.ingresos,
    b.ganancia,
    b.embarques,
    b.primer_mes,
    b.primer_year,
    b.last_shipment_date,
        CASE
            WHEN b.last_shipment_date IS NULL THEN NULL::integer
            ELSE CURRENT_DATE - b.last_shipment_date
        END AS days_since_last,
    b.shipments_30d,
    b.shipments_60d,
    b.shipments_90d,
    b.ganancia_30d,
    b.ganancia_prev30d,
    ss.last_senae_date,
        CASE
            WHEN ss.last_senae_date IS NULL THEN NULL::integer
            ELSE CURRENT_DATE - ss.last_senae_date
        END AS days_since_senae,
    COALESCE(ss.senae_30d, 0::bigint) AS senae_shipments_30d,
    COALESCE(ss.senae_60d, 0::bigint) AS senae_shipments_60d,
    COALESCE(ss.senae_90d, 0::bigint) AS senae_shipments_90d
   FROM cmm_sellers s
     JOIN base b ON b.seller_id = s.id
     LEFT JOIN senae_shipments ss ON ss.cliente = b.cliente;

CREATE OR REPLACE VIEW public.v_cmm_mix AS
SELECT s.id AS seller_id,
    s.nombre AS vendedor,
    s.canal,
    s.estado,
    s.office,
    t.period_year,
    t.period_month,
    t.cont_categoria,
    sum(t.ganancia) AS ganancia,
    count(*) AS embarques
   FROM cmm_sellers s
     JOIN cmm_transactions t ON t.seller_id = s.id
  GROUP BY s.id, s.nombre, s.canal, s.estado, s.office, t.period_year, t.period_month, t.cont_categoria;

CREATE OR REPLACE VIEW public.v_cmm_monthly AS
SELECT s.id AS seller_id,
    s.nombre AS vendedor,
    s.canal,
    s.estado,
    s.office,
    t.period_year,
    t.period_month,
    sum(t.ingresos) AS ingresos,
    sum(t.ganancia) AS ganancia,
    sum(t.base_cmm) AS base_cmm,
    sum(t.cmm_pagar) AS cmm_pagar,
    count(*) AS embarques,
    count(DISTINCT t.cliente) AS clientes
   FROM cmm_sellers s
     JOIN cmm_transactions t ON t.seller_id = s.id
  GROUP BY s.id, s.nombre, s.canal, s.estado, s.office, t.period_year, t.period_month;

CREATE OR REPLACE VIEW public.v_cmm_pending_summary AS
WITH ranked AS (
         SELECT p.id,
            p.upload_id,
            p.seller_id,
            p.office,
            p.period_year,
            p.period_month,
            p.descripcion,
            p.fecha,
            p.base_cmm_pendiente,
            p.cmm_pendiente,
            p.created_at,
            row_number() OVER (PARTITION BY p.seller_id, p.descripcion ORDER BY p.period_year DESC, p.period_month DESC, p.created_at DESC) AS rn
           FROM cmm_pending p
        )
 SELECT s.id AS seller_id,
    s.nombre AS vendedor,
    s.canal,
    s.estado,
    s.office,
    count(*) AS items_pendientes,
    sum(r.base_cmm_pendiente) AS base_pendiente,
    sum(r.cmm_pendiente) AS cmm_pendiente
   FROM ranked r
     JOIN cmm_sellers s ON s.id = r.seller_id
  WHERE r.rn = 1
  GROUP BY s.id, s.nombre, s.canal, s.estado, s.office;

CREATE OR REPLACE VIEW public.v_cmm_seller_alerts AS
WITH latest AS (
         SELECT DISTINCT ON (v_cmm_seller_mom.seller_id) v_cmm_seller_mom.seller_id,
            v_cmm_seller_mom.vendedor,
            v_cmm_seller_mom.canal,
            v_cmm_seller_mom.estado,
            v_cmm_seller_mom.office,
            v_cmm_seller_mom.period_year,
            v_cmm_seller_mom.period_month,
            v_cmm_seller_mom.ingresos,
            v_cmm_seller_mom.ganancia,
            v_cmm_seller_mom.cmm_pagar,
            v_cmm_seller_mom.embarques,
            v_cmm_seller_mom.clientes,
            v_cmm_seller_mom.margen_pct,
            v_cmm_seller_mom.prev_ganancia,
            v_cmm_seller_mom.prev_margen_pct,
            v_cmm_seller_mom.prev_embarques,
            v_cmm_seller_mom.prev_clientes
           FROM v_cmm_seller_mom
          ORDER BY v_cmm_seller_mom.seller_id, v_cmm_seller_mom.period_year DESC, v_cmm_seller_mom.period_month DESC
        ), hhi AS (
         SELECT c.seller_id,
            sum(power(c.ganancia / NULLIF(t.total_g, 0::numeric) * 100::numeric, 2::numeric)) AS hhi
           FROM v_cmm_clients c
             JOIN ( SELECT v_cmm_clients.seller_id,
                    sum(v_cmm_clients.ganancia) AS total_g
                   FROM v_cmm_clients
                  GROUP BY v_cmm_clients.seller_id) t ON t.seller_id = c.seller_id
          WHERE c.ganancia > 0::numeric
          GROUP BY c.seller_id
        )
 SELECT l.seller_id,
    l.vendedor,
    l.canal,
    l.estado,
    l.office,
    l.period_year,
    l.period_month,
    l.ganancia,
    l.margen_pct,
    l.embarques,
    l.clientes,
        CASE
            WHEN l.prev_ganancia > 0::numeric THEN (l.ganancia - l.prev_ganancia) / l.prev_ganancia * 100::numeric
            ELSE NULL::numeric
        END AS ganancia_delta_pct,
    l.margen_pct - COALESCE(l.prev_margen_pct, l.margen_pct) AS margen_delta_pp,
    l.embarques - COALESCE(l.prev_embarques, l.embarques) AS embarques_delta,
    l.clientes - COALESCE(l.prev_clientes, l.clientes) AS clientes_delta,
    h.hhi,
    l.margen_pct < 15::numeric AS flag_low_margin,
    (l.margen_pct - COALESCE(l.prev_margen_pct, l.margen_pct)) <= '-3'::integer::numeric AS flag_margin_drop,
    l.prev_ganancia > 0::numeric AND ((l.ganancia - l.prev_ganancia) / l.prev_ganancia) <= '-0.30'::numeric AS flag_utility_drop,
    h.hhi >= 2500::numeric AS flag_high_concentration
   FROM latest l
     LEFT JOIN hhi h ON h.seller_id = l.seller_id;

CREATE OR REPLACE VIEW public.v_cmm_seller_mom AS
WITH m AS (
         SELECT s.id AS seller_id,
            s.nombre AS vendedor,
            s.canal,
            s.estado,
            s.office,
            t.period_year,
            t.period_month,
            sum(t.ingresos) AS ingresos,
            sum(t.ganancia) AS ganancia,
            sum(t.cmm_pagar) AS cmm_pagar,
            count(*) AS embarques,
            count(DISTINCT t.cliente) AS clientes,
                CASE
                    WHEN sum(t.ingresos) > 0::numeric THEN sum(t.ganancia) / sum(t.ingresos) * 100::numeric
                    ELSE 0::numeric
                END AS margen_pct
           FROM cmm_sellers s
             JOIN cmm_transactions t ON t.seller_id = s.id
          GROUP BY s.id, s.nombre, s.canal, s.estado, s.office, t.period_year, t.period_month
        )
 SELECT seller_id,
    vendedor,
    canal,
    estado,
    office,
    period_year,
    period_month,
    ingresos,
    ganancia,
    cmm_pagar,
    embarques,
    clientes,
    margen_pct,
    lag(ganancia) OVER (PARTITION BY seller_id ORDER BY period_year, period_month) AS prev_ganancia,
    lag(margen_pct) OVER (PARTITION BY seller_id ORDER BY period_year, period_month) AS prev_margen_pct,
    lag(embarques) OVER (PARTITION BY seller_id ORDER BY period_year, period_month) AS prev_embarques,
    lag(clientes) OVER (PARTITION BY seller_id ORDER BY period_year, period_month) AS prev_clientes
   FROM m;

CREATE OR REPLACE VIEW public.v_cmm_summary_by_seller AS
SELECT s.id AS seller_id,
    s.nombre AS vendedor,
    s.office,
    s.canal,
    s.estado,
    s.canal = 'Staff'::text AND s.estado <> 'Salio'::text AS en_ranking,
    COALESCE(sum(t.ingresos), 0::numeric) AS ingresos,
    COALESCE(sum(t.ganancia), 0::numeric) AS ganancia,
    COALESCE(sum(t.base_cmm), 0::numeric) AS base_cmm,
    COALESCE(sum(t.cmm_pagar), 0::numeric) AS cmm_pagar,
    count(t.id) AS embarques,
    count(DISTINCT t.cliente) AS clientes,
        CASE
            WHEN COALESCE(sum(t.ingresos), 0::numeric) > 0::numeric THEN COALESCE(sum(t.ganancia), 0::numeric) / sum(t.ingresos) * 100::numeric
            ELSE 0::numeric
        END AS margen_pct,
        CASE
            WHEN COALESCE(sum(t.ganancia), 0::numeric) > 0::numeric THEN COALESCE(sum(t.cmm_pagar), 0::numeric) / sum(t.ganancia) * 100::numeric
            ELSE 0::numeric
        END AS pct_cmm_sobre_ganancia,
        CASE
            WHEN count(t.id) > 0 THEN COALESCE(sum(t.ganancia), 0::numeric) / count(t.id)::numeric
            ELSE 0::numeric
        END AS ticket_ganancia,
        CASE
            WHEN count(t.id) > 0 THEN COALESCE(sum(t.ingresos), 0::numeric) / count(t.id)::numeric
            ELSE 0::numeric
        END AS ticket_ingreso,
    min(t.period_year) AS first_year,
    min(t.period_month) AS first_month,
    max(t.period_year) AS last_year,
    max(t.period_month) AS last_month
   FROM cmm_sellers s
     LEFT JOIN cmm_transactions t ON t.seller_id = s.id
  GROUP BY s.id, s.nombre, s.office, s.canal, s.estado;

CREATE OR REPLACE VIEW public.v_cmm_target_progress AS
SELECT t.id AS target_id,
    t.seller_id,
    s.nombre AS vendedor,
    s.canal,
    s.estado,
    t.office,
    t.period_year,
    t.period_month,
    t.target_ganancia,
    COALESCE(m.ganancia, 0::numeric) AS actual_ganancia,
        CASE
            WHEN t.target_ganancia > 0::numeric THEN COALESCE(m.ganancia, 0::numeric) / t.target_ganancia * 100::numeric
            ELSE 0::numeric
        END AS attainment_pct,
    COALESCE(m.embarques, 0::bigint) AS embarques,
    COALESCE(m.clientes, 0::bigint) AS clientes,
        CASE
            WHEN COALESCE(m.ingresos, 0::numeric) > 0::numeric THEN COALESCE(m.ganancia, 0::numeric) / m.ingresos * 100::numeric
            ELSE 0::numeric
        END AS margen_pct,
    t.notes
   FROM cmm_targets t
     JOIN cmm_sellers s ON s.id = t.seller_id
     LEFT JOIN v_cmm_monthly m ON m.seller_id = t.seller_id AND m.period_year = t.period_year AND m.period_month = t.period_month;

CREATE OR REPLACE VIEW public.v_consolidado_agentes_por_clasificar AS
SELECT consolidado_id,
    destino,
    agente,
    count(*) AS recibos,
    sum(piezas) AS piezas,
    round(sum(cft) / 35.3147, 2) AS cbm,
    min(created_on) AS primer_recibo,
    max(created_on) AS ultimo_recibo
   FROM ( SELECT c.id AS consolidado_id,
            c.destino,
            NULLIF(wh_decode_entities(w.destination_agent), ''::text) AS agente,
            d.piezas_en_bodega - d.piezas_comprometidas AS piezas,
            COALESCE(d.vol_onhand_cft, w.volume_cft * d.fraccion_en_bodega) AS cft,
            w.created_on
           FROM consolidados c
             JOIN magaya_warehouse_receipts w ON w.wr_number ~ '^[0-9]+$'::text AND w.created_on >= (CURRENT_DATE - 150)
             JOIN v_consolidado_wr_disponible d ON d.wr_number = w.wr_number
          WHERE c.estado = 'ABIERTO'::text AND (d.piezas_en_bodega - d.piezas_comprometidas) > 0 AND COALESCE(w.destination_port, ''::text) = ''::text AND COALESCE(w.destination_agent, ''::text) <> ''::text AND NOT es_carga_de_tenant(w.destination_agent, w.consignee) AND COALESCE(w.destination_agent, ''::text) !~* 'gloval\s+shipping\s+usa'::text AND NOT (EXISTS ( SELECT 1
                   FROM consolidado_agentes_destino a
                  WHERE upper(wh_decode_entities(a.agente)) = upper(wh_decode_entities(w.destination_agent)) AND a.incluir)) AND NOT consolidado_agente_excluido(w.destination_agent, c.destino, c.id)) x
  GROUP BY consolidado_id, destino, agente;

CREATE OR REPLACE VIEW public.v_consolidado_contenedor_espacio AS
SELECT ct.id AS contenedor_id,
    ct.consolidado_id,
    ct.posicion,
    ct.numero,
    ct.sello,
    ct.tipo,
    cap.max_cbm,
    cap.objetivo_cbm,
    COALESCE(sum(l.volumen_cft) / 35.3147, 0::numeric) AS cbm_cargado,
    COALESCE(sum(l.peso_lb), 0::numeric) AS peso_lb,
    COALESCE(sum(l.piezas), 0::bigint) AS piezas,
    count(l.id) AS cargas,
    count(l.id) FILTER (WHERE l.cargado_confirmado_at IS NOT NULL) AS cargas_confirmadas,
    round(cap.objetivo_cbm - COALESCE(sum(l.volumen_cft) / 35.3147, 0::numeric), 2) AS cbm_libre,
    round(cap.max_cbm - COALESCE(sum(l.volumen_cft) / 35.3147, 0::numeric), 2) AS cbm_libre_al_tope,
        CASE
            WHEN cap.objetivo_cbm > 0::numeric THEN round(100::numeric * COALESCE(sum(l.volumen_cft) / 35.3147, 0::numeric) / cap.objetivo_cbm, 1)
            ELSE NULL::numeric
        END AS pct_lleno
   FROM consolidado_contenedores ct
     LEFT JOIN consolidado_capacidades cap ON cap.tipo = ct.tipo
     LEFT JOIN consolidado_lineas l ON l.contenedor_id = ct.id AND (l.estado <> ALL (ARRAY['EXCLUIDO'::text, 'RODADO'::text, 'NO_EMBARCA'::text]))
  GROUP BY ct.id, ct.consolidado_id, ct.posicion, ct.numero, ct.sello, ct.tipo, cap.max_cbm, cap.objetivo_cbm;

CREATE OR REPLACE VIEW public.v_consolidado_linea_cifras AS
SELECT l.id AS linea_id,
    l.consolidado_id,
    l.wr_number,
    count(p.id) > 0 AS por_pieza,
    COALESCE(sum(p.piezas), l.piezas::bigint) AS piezas,
    COALESCE(sum(p.peso_lb), l.peso_lb) AS peso_lb,
    COALESCE(sum(p.vol_cft), l.volumen_cft) AS volumen_cft,
    string_agg(DISTINCT p.location_code, ', '::text ORDER BY p.location_code) FILTER (WHERE p.location_code IS NOT NULL) AS ubicaciones,
    string_agg(p.whr_item_id, ', '::text ORDER BY p.whr_item_id) AS piezas_asignadas
   FROM consolidado_lineas l
     LEFT JOIN consolidado_linea_piezas p ON p.linea_id = l.id
  GROUP BY l.id, l.consolidado_id, l.wr_number, l.piezas, l.peso_lb, l.volumen_cft;

CREATE OR REPLACE VIEW public.v_consolidado_lineas AS
SELECT l.id,
    l.consolidado_id,
    l.wr_number,
    l.consignee,
    l.shipper,
    l.client_id,
    l.cs_email,
    l.piezas,
    l.peso_lb,
    l.volumen_cft,
    l.estado,
    l.hazmat,
    l.factura_ok,
    l.tarifa_venta,
    l.tarifa_moneda,
    l.instruido_at,
    l.instruido_por,
    l.instruccion_nota,
    l.contenedor,
    l.sello,
    l.hbl,
    l.piezas_embarcadas,
    l.rodado_desde,
    l.notas,
    l.updated_at,
    round(COALESCE(l.peso_lb, 0::numeric) * 0.45359237, 2) AS peso_kg,
    round(COALESCE(l.volumen_cft, 0::numeric) * 0.0283168, 4) AS cbm,
    w.entry_date,
    CURRENT_DATE - COALESCE(w.entry_date, w.created_on) AS dias_en_bodega,
    c.semana,
    c.anio,
    c.modo,
    c.booking,
    c.etd,
    c.eta,
    c.estado AS estado_consolidado,
    c.cutoff_regular,
    c.cutoff_instrucciones
   FROM consolidado_lineas l
     JOIN consolidados c ON c.id = l.consolidado_id
     LEFT JOIN magaya_warehouse_receipts w ON w.wr_number = l.wr_number;

CREATE OR REPLACE VIEW public.v_consolidado_sin_confirmar AS
SELECT l.id AS linea_id,
    l.consolidado_id,
    l.wr_number,
    l.consignee,
    l.agente_destino,
    l.cs_email,
    l.piezas,
    l.peso_lb,
    round(l.volumen_cft / 35.3147, 3) AS cbm,
    l.estado,
    l.es_parcial,
    l.hazmat,
    w.entry_date AS llego_a_bodega,
    c.cutoff_instrucciones,
    c.cutoff_regular,
    w.entry_date - COALESCE(c.cutoff_instrucciones, c.cutoff_regular)::date AS dias_despues_del_corte,
    w.entry_date IS NOT NULL AND w.entry_date > COALESCE(c.cutoff_instrucciones, c.cutoff_regular)::date AS llego_tarde
   FROM consolidado_lineas l
     JOIN consolidados c ON c.id = l.consolidado_id
     LEFT JOIN magaya_warehouse_receipts w ON w.wr_number = l.wr_number
  WHERE (c.estado = ANY (ARRAY['ABIERTO'::text, 'CERRADO'::text])) AND l.contenedor_id IS NULL AND (l.estado = ANY (ARRAY['DISPONIBLE'::text, 'AVISADO'::text]));

CREATE OR REPLACE VIEW public.v_consolidado_wr_disponible AS
SELECT w.wr_number,
    w.consignee,
    w.consignee_normalized,
    w.shipper,
    w.destination_agent,
    w.destination_port,
    w.entry_date,
    w.created_on,
    w.status AS status_cabecera,
    s.estado_saldo,
    s.items_con_estado > 0 AS tiene_detalle_por_pieza,
    COALESCE(w.pieces, 0) AS piezas_recibo,
        CASE
            WHEN s.items_con_estado > 0 THEN s.piezas_onhand::integer
            WHEN w.status = 'OnHand'::text THEN COALESCE(w.pieces, 0)
            ELSE 0
        END AS piezas_en_bodega,
    COALESCE(comp.piezas, 0) AS piezas_comprometidas,
        CASE
            WHEN s.items_con_estado > 0 AND COALESCE(w.pieces, 0) > 0 THEN s.piezas_onhand::numeric / w.pieces::numeric
            ELSE 1::numeric
        END AS fraccion_en_bodega,
    s.peso_onhand_lb,
    s.vol_onhand_cft,
    iv.cft AS vol_items_cft,
    iv.lb AS peso_items_lb
   FROM magaya_warehouse_receipts w
     LEFT JOIN v_wh_wr_saldo s ON s.wr_number = w.wr_number
     LEFT JOIN LATERAL ( SELECT sum(i.vol_cft) AS cft,
            sum(i.peso_lb) AS lb
           FROM magaya_wr_items i
          WHERE i.wr_number = w.wr_number AND i.vol_cft IS NOT NULL) iv ON true
     LEFT JOIN LATERAL ( SELECT sum(COALESCE(l.piezas_embarcadas, l.piezas))::integer AS piezas
           FROM consolidado_lineas l
             JOIN consolidados c ON c.id = l.consolidado_id
          WHERE l.wr_number = w.wr_number AND (l.estado = ANY (ARRAY['DISPONIBLE'::text, 'AVISADO'::text, 'INSTRUIDO'::text, 'EMBARCADO'::text])) AND c.estado <> 'ANULADO'::text) comp ON true;

CREATE OR REPLACE VIEW public.v_country_data_summary AS
SELECT code AS country_code,
    name AS company_name,
    country,
    ( SELECT count(*) AS count
           FROM magaya_entities me
          WHERE me.company_id = mc.id) AS entities,
    ( SELECT count(*) AS count
           FROM magaya_transactions mt
          WHERE mt.company_id = mc.id) AS transactions,
    ( SELECT count(*) AS count
           FROM magaya_transactions mt
          WHERE mt.company_id = mc.id AND mt.transaction_type = 'SH'::text) AS shipments,
    ( SELECT count(*) AS count
           FROM magaya_transactions mt
          WHERE mt.company_id = mc.id AND mt.transaction_type = 'IN'::text) AS invoices,
    ( SELECT count(*) AS count
           FROM magaya_transactions mt
          WHERE mt.company_id = mc.id AND mt.transaction_type = 'PM'::text) AS payments,
    ( SELECT count(*) AS count
           FROM magaya_transaction_charges mtc
          WHERE mtc.company_id = mc.id) AS charges,
    ( SELECT count(*) AS count
           FROM magaya_shipments ms
          WHERE ms.company_id = mc.id) AS legacy_shipments,
    ( SELECT count(*) AS count
           FROM magaya_warehouse_receipts wr
          WHERE wr.company_id = mc.id) AS warehouse_receipts,
    ( SELECT count(*) AS count
           FROM magaya_cargo_releases cr
          WHERE cr.company_id = mc.id) AS cargo_releases
   FROM magaya_companies mc
  WHERE is_active = true
  ORDER BY code;

CREATE OR REPLACE VIEW public.v_data_freshness AS
WITH fuentes AS (
         SELECT 'facturacion_magaya'::text AS source,
            finanzas_office_code_for_company(magaya_transactions.company_id) AS office_code,
            max(magaya_transactions.created_on) AS last_data_at,
            max(magaya_transactions.synced_at) AS last_sync_at,
            48 AS warn_hours,
            120 AS crit_hours
           FROM magaya_transactions
          WHERE finanzas_office_code_for_company(magaya_transactions.company_id) IS NOT NULL
          GROUP BY (finanzas_office_code_for_company(magaya_transactions.company_id))
        UNION ALL
         SELECT 'drift_ar_ap'::text,
                CASE q.scope
                    WHEN 'gloval-usa'::text THEN 'USA'::text
                    WHEN 'gloval-ecuador'::text THEN 'ECU'::text
                    WHEN 'gloval-panama'::text THEN 'PAN'::text
                    WHEN 'gloval-peru'::text THEN 'PER'::text
                    ELSE upper(q.scope)
                END AS upper,
            max(q.last_ok_at) AS max,
            max(q.last_ok_at) AS max,
            24,
            72
           FROM ar_ap_sync_queue q
          GROUP BY q.scope
        UNION ALL
         SELECT 'balances_entidades'::text,
            finanzas_office_code_for_office(b.office_id) AS finanzas_office_code_for_office,
            max(b.fetched_at) AS max,
            max(b.fetched_at) AS max,
            24,
            48
           FROM magaya_entity_balance b
          GROUP BY (finanzas_office_code_for_office(b.office_id))
        UNION ALL
         SELECT 'bancos'::text,
            finanzas_office_code_for_office(ba.office_id) AS finanzas_office_code_for_office,
            max(bt.transaction_date)::timestamp with time zone AS max,
            max(bt.created_at) AS max,
            240,
            720
           FROM bank_transaction bt
             JOIN bank_account ba ON ba.id = bt.bank_account_id
          GROUP BY (finanzas_office_code_for_office(ba.office_id))
        )
 SELECT source,
    office_code,
    last_data_at,
    last_sync_at,
    round(EXTRACT(epoch FROM now() - last_data_at) / 3600::numeric)::integer AS hours_stale,
        CASE
            WHEN last_data_at IS NULL THEN 'red'::text
            WHEN (now() - last_data_at) > make_interval(hours => crit_hours) THEN 'red'::text
            WHEN (now() - last_data_at) > make_interval(hours => warn_hours) THEN 'amber'::text
            ELSE 'green'::text
        END AS status
   FROM fuentes
  WHERE (office_code IN ( SELECT unnest(app_finanzas_offices()) AS unnest)) OR ( SELECT COALESCE(auth.role(), ''::text) <> ALL (ARRAY['authenticated'::text, 'anon'::text]));

CREATE OR REPLACE VIEW public.v_dominios_navieras AS
SELECT DISTINCT lower(btrim(d.d)) AS dominio
   FROM carriers c,
    LATERAL unnest(c.email_domains) d(d)
  WHERE COALESCE(c.active, true) AND btrim(d.d) <> ''::text;

CREATE OR REPLACE VIEW public.v_dso_dpo AS
WITH recent_revenue AS (
         SELECT cm.office_id,
            sum(cm.amount_in_usd) / 90.0 AS daily_revenue
           FROM cash_movement cm
          WHERE cm.direction = 'inflow'::text AND cm.source_type = 'invoice'::text AND (cm.status = ANY (ARRAY['committed'::text, 'executed'::text])) AND cm.counterparty_name IS NOT NULL AND NOT is_intercompany_name(cm.counterparty_name) AND cm.expected_date >= (CURRENT_DATE - '90 days'::interval) AND cm.expected_date <= CURRENT_DATE
          GROUP BY cm.office_id
        ), recent_spend AS (
         SELECT cm.office_id,
            sum(cm.amount_in_usd) / 90.0 AS daily_spend
           FROM cash_movement cm
          WHERE cm.direction = 'outflow'::text AND cm.source_type = 'bill'::text AND (cm.status = ANY (ARRAY['committed'::text, 'executed'::text])) AND cm.counterparty_name IS NOT NULL AND NOT is_intercompany_name(cm.counterparty_name) AND cm.expected_date >= (CURRENT_DATE - '90 days'::interval) AND cm.expected_date <= CURRENT_DATE
          GROUP BY cm.office_id
        ), ar_open AS (
         SELECT magaya_entity_balance.office_id,
            sum(magaya_entity_balance.balance_usd) AS ar
           FROM magaya_entity_balance
          WHERE magaya_entity_balance.kind = 'AR'::text AND NOT is_intercompany_name(magaya_entity_balance.entity_name)
          GROUP BY magaya_entity_balance.office_id
        ), ap_open AS (
         SELECT magaya_entity_balance.office_id,
            sum(magaya_entity_balance.balance_usd) AS ap
           FROM magaya_entity_balance
          WHERE magaya_entity_balance.kind = 'AP'::text AND NOT is_intercompany_name(magaya_entity_balance.entity_name)
          GROUP BY magaya_entity_balance.office_id
        )
 SELECT o.id::uuid AS office_id,
    o.code AS office_code,
    COALESCE(ar_open.ar, 0::numeric)::numeric(15,2) AS ar_open_usd,
    COALESCE(ap_open.ap, 0::numeric)::numeric(15,2) AS ap_open_usd,
    COALESCE(recent_revenue.daily_revenue, 0::numeric)::numeric(15,2) AS daily_revenue_90d,
    COALESCE(recent_spend.daily_spend, 0::numeric)::numeric(15,2) AS daily_spend_90d,
        CASE
            WHEN COALESCE(recent_revenue.daily_revenue, 0::numeric) > 0::numeric THEN round(COALESCE(ar_open.ar, 0::numeric) / recent_revenue.daily_revenue)
            ELSE NULL::numeric
        END AS dso_days,
        CASE
            WHEN COALESCE(recent_spend.daily_spend, 0::numeric) > 0::numeric THEN round(COALESCE(ap_open.ap, 0::numeric) / recent_spend.daily_spend)
            ELSE NULL::numeric
        END AS dpo_days
   FROM offices o
     LEFT JOIN ar_open ON ar_open.office_id::text = o.id
     LEFT JOIN ap_open ON ap_open.office_id::text = o.id
     LEFT JOIN recent_revenue ON recent_revenue.office_id::text = o.id
     LEFT JOIN recent_spend ON recent_spend.office_id::text = o.id
  WHERE o.active = true AND o.code IS NOT NULL AND o.code <> 'HOLDING'::text AND ((o.code IN ( SELECT unnest(app_finanzas_offices()) AS unnest)) OR ( SELECT COALESCE(auth.role(), ''::text) <> ALL (ARRAY['authenticated'::text, 'anon'::text])));

CREATE OR REPLACE VIEW public.v_embarques_sin_oficina AS
SELECT s.id,
    s.shipment_code,
    s.office,
    c.company_name AS cliente,
    u.name AS creado_por,
    u.office AS oficina_de_quien_creo,
    s.status::text AS status,
    s.created_at
   FROM shipments s
     LEFT JOIN clients c ON c.id = s.client_id
     LEFT JOIN users u ON u.id = s.created_by
  WHERE s.archived_at IS NULL AND COALESCE(btrim(s.office), ''::text) = ''::text;

CREATE OR REPLACE VIEW public.v_entity_ar_ap_correct AS
SELECT office_id,
    entity_name,
    kind,
    balance_usd,
    invoice_count,
    entity_guid,
    source_bill_number,
    source_bill_guid,
    fetched_at,
    tenant_id,
        CASE
            WHEN balance_usd > 0::numeric AND NOT sin_detalle THEN d1_30 + d31_60 + d61_90 + d90_mas
            ELSE NULL::numeric
        END AS vencido_usd,
        CASE
            WHEN balance_usd > 0::numeric AND NOT sin_detalle THEN n_vencidas
            ELSE NULL::bigint
        END AS n_vencidas,
        CASE
            WHEN balance_usd > 0::numeric AND (d1_30 + d31_60 + d61_90 + d90_mas) > 0.005 THEN dias_max_vencido
            ELSE NULL::integer
        END AS dias_max_vencido,
        CASE
            WHEN balance_usd > 0::numeric AND (d1_30 + d31_60 + d61_90 + d90_mas) > 0.005 THEN dias_prom_vencido
            ELSE NULL::numeric
        END AS dias_prom_vencido,
        CASE
            WHEN balance_usd > 0::numeric AND (d1_30 + d31_60 + d61_90 + d90_mas) > 0.005 THEN vence_mas_antigua
            ELSE NULL::date
        END AS vence_mas_antigua,
        CASE
            WHEN balance_usd > 0::numeric AND (d1_30 + d31_60 + d61_90 + d90_mas) > 0.005 THEN vence_estimado
            ELSE NULL::boolean
        END AS vence_estimado,
    actual,
    d1_30,
    d31_60,
    d61_90,
    d90_mas,
    saldo_ajustado
   FROM v_finanzas_arap_entidad e
  WHERE (finanzas_office_code_for_office(office_id) IN ( SELECT unnest(app_finanzas_offices()) AS unnest)) OR ( SELECT COALESCE(auth.role(), ''::text) <> ALL (ARRAY['authenticated'::text, 'anon'::text]));

CREATE OR REPLACE VIEW public.v_entity_ar_ap_correct_slow AS
WITH paid AS (
         SELECT magaya_payment_application.item_paid_guid::text AS guid,
            sum(magaya_payment_application.amount_paid)::numeric(15,2) AS paid_amt
           FROM magaya_payment_application
          GROUP BY magaya_payment_application.item_paid_guid
        ), fx AS (
         SELECT mt.id,
                CASE
                    WHEN mt.total_amount_usd IS NOT NULL AND mt.total_amount > 0::numeric THEN mt.total_amount_usd / mt.total_amount
                    WHEN mt.company_id = '9b807b51-5ee9-4a22-9e75-df90047ec12b'::uuid THEN 1.0 / 3.42
                    ELSE 1.0
                END AS rate_to_usd
           FROM magaya_transactions mt
        ), ar_calc AS (
         SELECT office_for_magaya_company(mt.company_id) AS office_id,
            clean_entity_name(mt.billing_client_name) AS entity_name,
            min(mt.billing_client_guid) AS entity_guid,
            'AR'::text AS kind,
            sum(
                CASE
                    WHEN mt.is_credit THEN '-1'::integer
                    ELSE 1
                END::numeric * (mt.total_amount - COALESCE(p.paid_amt, 0::numeric)) * fx.rate_to_usd)::numeric(15,2) AS balance_usd,
            count(*) AS invoice_count
           FROM magaya_transactions mt
             LEFT JOIN paid p ON p.guid = mt.magaya_guid
             LEFT JOIN magaya_status_overrides ovr ON ovr.txn_guid = mt.magaya_guid
             LEFT JOIN fx ON fx.id = mt.id
          WHERE mt.transaction_type = 'IN'::text AND (mt.status = ANY (ARRAY['Open'::text, 'Posted'::text])) AND mt.total_amount > 0::numeric AND mt.billing_client_name IS NOT NULL AND (COALESCE(ovr.status_from_soap, 'Open'::text) <> ALL (ARRAY['Paid'::text, 'Voided'::text, 'Closed'::text, 'Cancelled'::text]))
          GROUP BY (office_for_magaya_company(mt.company_id)), (clean_entity_name(mt.billing_client_name))
        ), ap_calc AS (
         SELECT office_for_magaya_company(mt.company_id) AS office_id,
            clean_entity_name(mt.billing_client_name) AS entity_name,
            min(mt.billing_client_guid) AS entity_guid,
            'AP'::text AS kind,
            sum(
                CASE
                    WHEN mt.is_credit THEN '-1'::integer
                    ELSE 1
                END::numeric * (mt.total_amount - COALESCE(p.paid_amt, 0::numeric)) * fx.rate_to_usd)::numeric(15,2) AS balance_usd,
            count(*) AS invoice_count
           FROM magaya_transactions mt
             LEFT JOIN paid p ON p.guid = mt.magaya_guid
             LEFT JOIN magaya_status_overrides ovr ON ovr.txn_guid = mt.magaya_guid
             LEFT JOIN fx ON fx.id = mt.id
          WHERE mt.transaction_type = 'BI'::text AND (mt.status = ANY (ARRAY['Open'::text, 'Posted'::text])) AND mt.total_amount > 0::numeric AND mt.billing_client_name IS NOT NULL AND (COALESCE(ovr.status_from_soap, 'Open'::text) <> ALL (ARRAY['Paid'::text, 'Voided'::text, 'Closed'::text, 'Cancelled'::text]))
          GROUP BY (office_for_magaya_company(mt.company_id)), (clean_entity_name(mt.billing_client_name))
        )
 SELECT ar_calc.office_id,
    ar_calc.entity_name,
    ar_calc.kind,
    ar_calc.balance_usd,
    ar_calc.invoice_count,
    ar_calc.entity_guid,
    NULL::text AS source_bill_number,
    NULL::uuid AS source_bill_guid,
    now() AS fetched_at,
    'a4e3e84c-7fca-4ce3-8889-1f31d8d1366f'::uuid AS tenant_id
   FROM ar_calc
  WHERE ar_calc.office_id IS NOT NULL AND abs(ar_calc.balance_usd) > 0.01
UNION ALL
 SELECT ap_calc.office_id,
    ap_calc.entity_name,
    ap_calc.kind,
    ap_calc.balance_usd,
    ap_calc.invoice_count,
    ap_calc.entity_guid,
    NULL::text AS source_bill_number,
    NULL::uuid AS source_bill_guid,
    now() AS fetched_at,
    'a4e3e84c-7fca-4ce3-8889-1f31d8d1366f'::uuid AS tenant_id
   FROM ap_calc
  WHERE ap_calc.office_id IS NOT NULL AND abs(ap_calc.balance_usd) > 0.01;

CREATE OR REPLACE VIEW public.v_eta_alerts AS
SELECT s.id AS shipment_id,
    s.shipment_code,
    s.mbl,
    s.eta,
    s.eta_text,
    s.status,
    s.office,
    s.sales_executive_id,
    s.cs_assigned_to,
    c.id AS client_id,
    c.company_name AS client_name,
    u_exec.name AS sales_executive_name,
    s.eta - CURRENT_DATE AS days_to_eta,
        CASE
            WHEN s.eta < CURRENT_DATE THEN 'OVERDUE'::text
            WHEN (s.eta - CURRENT_DATE) <= 2 THEN 'IMMINENT'::text
            WHEN (s.eta - CURRENT_DATE) <= 7 THEN 'SOON'::text
            ELSE 'OK'::text
        END AS eta_status
   FROM shipments s
     LEFT JOIN clients c ON c.id = s.client_id
     LEFT JOIN users u_exec ON u_exec.id = s.sales_executive_id
  WHERE s.archived_at IS NULL AND (s.status::text <> ALL (ARRAY['DELIVERED'::text, 'CANCELLED'::text, 'ARRIVED'::text, 'CUSTOMS'::text, 'RELEASED'::text])) AND s.eta IS NOT NULL AND s.eta < (CURRENT_DATE + '14 days'::interval);

CREATE OR REPLACE VIEW public.v_finanzas_aging AS
SELECT office_code,
    kind,
    n_facturas,
    total,
    al_dia,
    d1_30,
    d31_60,
    d61_90,
    d90_mas,
    dias_promedio,
    computed_at
   FROM v_finanzas_antiguedad_oficina
  WHERE (office_code IN ( SELECT unnest(app_finanzas_offices()) AS unnest)) OR ( SELECT COALESCE(auth.role(), ''::text) <> ALL (ARRAY['authenticated'::text, 'anon'::text]));

CREATE OR REPLACE VIEW public.v_finanzas_antiguedad_entidad AS
WITH hoy AS (
         SELECT (now() AT TIME ZONE 'America/New_York'::text)::date AS d
        ), agg AS (
         SELECT dd.office_id,
            dd.kind,
            dd.entity_name,
            count(*) AS n_docs,
            sum(dd.saldo_usd)::numeric(15,2) AS saldo_calc,
            COALESCE(round(sum(dd.saldo_usd) FILTER (WHERE (h.d - dd.vence) >= 1 AND (h.d - dd.vence) <= 30), 2), 0::numeric) AS d1_30,
            COALESCE(round(sum(dd.saldo_usd) FILTER (WHERE (h.d - dd.vence) >= 31 AND (h.d - dd.vence) <= 60), 2), 0::numeric) AS d31_60,
            COALESCE(round(sum(dd.saldo_usd) FILTER (WHERE (h.d - dd.vence) >= 61 AND (h.d - dd.vence) <= 90), 2), 0::numeric) AS d61_90,
            COALESCE(round(sum(dd.saldo_usd) FILTER (WHERE (h.d - dd.vence) > 90), 2), 0::numeric) AS d90_mas,
            count(*) FILTER (WHERE dd.saldo_usd > 0.005 AND dd.vence < h.d) AS n_vencidas,
            max(h.d - dd.vence) FILTER (WHERE dd.saldo_usd > 0.005 AND dd.vence < h.d) AS dias_max_vencido,
            round(sum((h.d - dd.vence)::numeric * dd.saldo_usd) FILTER (WHERE dd.saldo_usd > 0.005 AND dd.vence < h.d) / NULLIF(sum(dd.saldo_usd) FILTER (WHERE dd.saldo_usd > 0.005 AND dd.vence < h.d), 0::numeric)) AS dias_prom_vencido,
            min(dd.vence) FILTER (WHERE dd.saldo_usd > 0.005 AND dd.vence < h.d) AS vence_mas_antigua,
            COALESCE(bool_or(dd.vence_estimado) FILTER (WHERE dd.saldo_usd > 0.005 AND dd.vence < h.d), false) AS vence_estimado,
            sum(dd.saldo_usd * GREATEST(h.d - dd.vence, 0)::numeric) FILTER (WHERE dd.saldo_usd > 0::numeric) AS saldo_x_dias,
            sum(dd.saldo_usd) FILTER (WHERE dd.saldo_usd > 0::numeric) AS saldo_positivo
           FROM mv_finanzas_docs_abiertos dd
             CROSS JOIN hoy h
          GROUP BY dd.office_id, dd.kind, dd.entity_name
        )
 SELECT office_id,
    kind,
    entity_name,
    n_docs,
    saldo_calc,
    saldo_calc - d1_30 - d31_60 - d61_90 - d90_mas AS actual,
    d1_30,
    d31_60,
    d61_90,
    d90_mas,
    n_vencidas,
    dias_max_vencido,
    dias_prom_vencido,
    vence_mas_antigua,
    vence_estimado,
    saldo_x_dias,
    saldo_positivo
   FROM agg;

CREATE OR REPLACE VIEW public.v_finanzas_antiguedad_oficina AS
SELECT finanzas_office_code_for_office(office_id) AS office_code,
    kind,
    sum(COALESCE(n_docs, 0::bigint))::bigint AS n_facturas,
    sum(balance_usd) AS total,
    sum(actual) AS al_dia,
    sum(d1_30) AS d1_30,
    sum(d31_60) AS d31_60,
    sum(d61_90) AS d61_90,
    sum(d90_mas) AS d90_mas,
    round(COALESCE(sum(saldo_x_dias) / NULLIF(sum(saldo_positivo), 0::numeric), 0::numeric)) AS dias_promedio,
    now() AS computed_at
   FROM v_finanzas_arap_entidad e
  WHERE upper(entity_name) !~~ '%GLOVAL%'::text
  GROUP BY (finanzas_office_code_for_office(office_id)), kind;

CREATE OR REPLACE VIEW public.v_finanzas_arap_entidad AS
SELECT m.office_id,
    m.entity_name,
    m.kind,
    m.balance_usd,
    m.invoice_count,
    m.entity_guid,
    m.source_bill_number,
    m.source_bill_guid,
    m.fetched_at,
    m.tenant_id,
    a.n_docs,
    a.saldo_calc,
    a.n_vencidas,
    a.dias_max_vencido,
    a.dias_prom_vencido,
    a.vence_mas_antigua,
    a.vence_estimado,
    a.saldo_x_dias,
    a.saldo_positivo,
    a.entity_name IS NULL AS sin_detalle,
    abs(m.balance_usd - COALESCE(a.saldo_calc, 0::numeric)) > 0.005 AS saldo_ajustado,
    b.actual - s1.r + x.agregar - (x.reducir - s5.r - s4.r - s3.r - s2.r - s1.r) AS actual,
    b.d1_30 - s2.r AS d1_30,
    b.d31_60 - s3.r AS d31_60,
    b.d61_90 - s4.r AS d61_90,
    b.d90_mas - s5.r AS d90_mas
   FROM mv_entity_ar_ap m
     LEFT JOIN v_finanzas_antiguedad_entidad a ON a.office_id = m.office_id AND a.kind = m.kind AND a.entity_name = m.entity_name
     CROSS JOIN LATERAL ( SELECT COALESCE(a.actual, 0::numeric) AS actual,
            COALESCE(a.d1_30, 0::numeric) AS d1_30,
            COALESCE(a.d31_60, 0::numeric) AS d31_60,
            COALESCE(a.d61_90, 0::numeric) AS d61_90,
            COALESCE(a.d90_mas, 0::numeric) AS d90_mas) b
     CROSS JOIN LATERAL ( SELECT GREATEST(COALESCE(a.saldo_calc, 0::numeric) - m.balance_usd, 0::numeric) AS reducir,
            GREATEST(m.balance_usd - COALESCE(a.saldo_calc, 0::numeric), 0::numeric) AS agregar) x
     CROSS JOIN LATERAL ( SELECT LEAST(GREATEST(b.d90_mas, 0::numeric), x.reducir) AS r) s5
     CROSS JOIN LATERAL ( SELECT LEAST(GREATEST(b.d61_90, 0::numeric), x.reducir - s5.r) AS r) s4
     CROSS JOIN LATERAL ( SELECT LEAST(GREATEST(b.d31_60, 0::numeric), x.reducir - s5.r - s4.r) AS r) s3
     CROSS JOIN LATERAL ( SELECT LEAST(GREATEST(b.d1_30, 0::numeric), x.reducir - s5.r - s4.r - s3.r) AS r) s2
     CROSS JOIN LATERAL ( SELECT LEAST(GREATEST(b.actual, 0::numeric), x.reducir - s5.r - s4.r - s3.r - s2.r) AS r) s1;

CREATE OR REPLACE VIEW public.v_finanzas_conciliacion AS
SELECT bt.id,
    ba.office_id::text AS office_id,
    o.code AS office_code,
    ba.bank_name,
    ba.account_nickname,
    bt.transaction_date,
    bt.amount,
    bt.description,
    bt.reference,
    COALESCE(m.estado, 'pendiente'::text) AS estado,
    m.id AS match_id,
    m.match_type,
    m.matched_docs,
    m.entity_name,
    m.category,
    m.confidence,
    m.decided_by,
    m.decided_at
   FROM bank_transaction bt
     JOIN bank_account ba ON ba.id = bt.bank_account_id
     JOIN offices o ON o.id = ba.office_id::text
     LEFT JOIN finanzas_bank_match m ON m.bank_transaction_id = bt.id
  WHERE (o.code IN ( SELECT unnest(app_finanzas_offices()) AS unnest)) OR ( SELECT COALESCE(auth.role(), ''::text) <> ALL (ARRAY['authenticated'::text, 'anon'::text]));

CREATE OR REPLACE VIEW public.v_finanzas_factoring_rc AS
WITH eventos AS (
         SELECT m.m[1]::bigint AS rc_num,
            bt.transaction_date AS fecha,
                CASE
                    WHEN bt.amount > 0::numeric THEN 'anticipo'::text
                    ELSE 'recompra'::text
                END AS evento
           FROM bank_transaction bt
             CROSS JOIN LATERAL regexp_matches(upper(bt.description), 'RC\s*0*([0-9]{5,6})'::text, 'g'::text) m(m)
          WHERE bt.description ~~* '%GESTOMATIC%'::text AND (bt.amount > 0::numeric AND (bt.description ~~* '%PROPUESTA%'::text OR upper(bt.description) ~ 'NEG\.?\s'::text) OR bt.amount < 0::numeric AND bt.description ~~* '%GESTOMATIC PAGO%'::text)
        ), estado AS (
         SELECT eventos.rc_num,
            max(eventos.fecha) FILTER (WHERE eventos.evento = 'anticipo'::text) AS ult_anticipo,
            max(eventos.fecha) FILTER (WHERE eventos.evento = 'recompra'::text) AS ult_recompra
           FROM eventos
          GROUP BY eventos.rc_num
         HAVING max(eventos.fecha) FILTER (WHERE eventos.evento = 'anticipo'::text) IS NOT NULL AND (max(eventos.fecha) FILTER (WHERE eventos.evento = 'recompra'::text) IS NULL OR max(eventos.fecha) FILTER (WHERE eventos.evento = 'recompra'::text) < max(eventos.fecha) FILTER (WHERE eventos.evento = 'anticipo'::text))
        ), pa AS (
         SELECT magaya_payment_application.item_paid_guid::text AS g,
            sum(magaya_payment_application.amount_paid) AS applied
           FROM magaya_payment_application
          WHERE magaya_payment_application.company_id = 'd8b762a6-f66f-44de-bc44-2486ec1e2ae5'::uuid
          GROUP BY (magaya_payment_application.item_paid_guid::text)
        )
 SELECT 'cc987069-ac9a-41f2-85f0-0337f6b99980'::text AS office_id,
    t.billing_client_name AS entity_name,
    t.transaction_number,
    regexp_replace(t.transaction_number, '\D'::text, ''::text, 'g'::text)::bigint AS rc_num,
    e.ult_anticipo,
    round(magaya_amount_to_usd(t.company_id, t.total_amount, t.total_amount_usd) - COALESCE(pa.applied, 0::numeric), 2) AS saldo_usd
   FROM magaya_transactions t
     JOIN estado e ON e.rc_num = regexp_replace(t.transaction_number, '\D'::text, ''::text, 'g'::text)::bigint
     LEFT JOIN pa ON pa.g = t.magaya_guid
     LEFT JOIN magaya_status_overrides so ON so.txn_guid = t.magaya_guid
  WHERE t.company_id = 'd8b762a6-f66f-44de-bc44-2486ec1e2ae5'::uuid AND t.transaction_type = 'IN'::text AND (t.status = ANY (ARRAY['Open'::text, 'Partial'::text, 'Pending'::text])) AND t.transaction_number ~~* 'RC%'::text AND (so.txn_guid IS NULL OR so.status_from_soap <> 'Paid'::text) AND (magaya_amount_to_usd(t.company_id, t.total_amount, t.total_amount_usd) - COALESCE(pa.applied, 0::numeric)) > 0.005 AND (('ECU'::text IN ( SELECT unnest(app_finanzas_offices()) AS unnest)) OR ( SELECT COALESCE(auth.role(), ''::text) <> ALL (ARRAY['authenticated'::text, 'anon'::text])));

CREATE OR REPLACE VIEW public.v_finanzas_factoring_resumen AS
SELECT office_id,
    count(*) AS n_facturas,
    round(sum(saldo_usd), 2) AS total_factorizado_usd
   FROM v_finanzas_factoring_rc
  GROUP BY office_id;

CREATE OR REPLACE VIEW public.v_finanzas_liquidez AS
WITH ag AS MATERIALIZED (
         SELECT v_finanzas_antiguedad_oficina.office_code,
            v_finanzas_antiguedad_oficina.kind,
            v_finanzas_antiguedad_oficina.n_facturas,
            v_finanzas_antiguedad_oficina.total,
            v_finanzas_antiguedad_oficina.al_dia,
            v_finanzas_antiguedad_oficina.d1_30,
            v_finanzas_antiguedad_oficina.d31_60,
            v_finanzas_antiguedad_oficina.d61_90,
            v_finanzas_antiguedad_oficina.d90_mas,
            v_finanzas_antiguedad_oficina.dias_promedio,
            v_finanzas_antiguedad_oficina.computed_at
           FROM v_finanzas_antiguedad_oficina
        ), caja AS (
         SELECT ba.office_id::text AS office_id,
            sum(ba.current_balance) AS caja
           FROM bank_account ba
          WHERE ba.active
          GROUP BY (ba.office_id::text)
        ), ar AS (
         SELECT ag.office_code,
            ag.kind,
            ag.n_facturas,
            ag.total,
            ag.al_dia,
            ag.d1_30,
            ag.d31_60,
            ag.d61_90,
            ag.d90_mas,
            ag.dias_promedio,
            ag.computed_at
           FROM ag
          WHERE ag.kind = 'AR'::text
        ), ap AS (
         SELECT ag.office_code,
            ag.kind,
            ag.n_facturas,
            ag.total,
            ag.al_dia,
            ag.d1_30,
            ag.d31_60,
            ag.d61_90,
            ag.d90_mas,
            ag.dias_promedio,
            ag.computed_at
           FROM ag
          WHERE ag.kind = 'AP'::text
        )
 SELECT o.code AS office_code,
    round(COALESCE(c.caja, 0::numeric), 2) AS caja,
    COALESCE(ar.total, 0::numeric) AS ar_com,
    COALESCE(ap.total, 0::numeric) AS ap_com,
    COALESCE(r.monto_mes, 0::numeric) AS recurrente_mes,
    round(COALESCE(c.caja, 0::numeric) + 0.7 * (COALESCE(ar.al_dia, 0::numeric) + COALESCE(ar.d1_30, 0::numeric)) - (COALESCE(ap.al_dia, 0::numeric) + COALESCE(ap.d1_30, 0::numeric)) - COALESCE(r.monto_mes, 0::numeric), 2) AS margen_30d,
    round((COALESCE(c.caja, 0::numeric) + COALESCE(ar.total, 0::numeric)) / NULLIF(COALESCE(ap.total, 0::numeric) + COALESCE(r.monto_mes, 0::numeric), 0::numeric), 2) AS acida
   FROM offices o
     LEFT JOIN caja c ON c.office_id = o.id
     LEFT JOIN ar ON ar.office_code = o.code
     LEFT JOIN ap ON ap.office_code = o.code
     LEFT JOIN finanzas_config_recurrente r ON r.office_id = o.id
  WHERE (o.code = ANY (ARRAY['USA'::text, 'ECU'::text, 'PAN'::text, 'PER'::text])) AND ((o.code IN ( SELECT unnest(app_finanzas_offices()) AS unnest)) OR ( SELECT COALESCE(auth.role(), ''::text) <> ALL (ARRAY['authenticated'::text, 'anon'::text])));

CREATE OR REPLACE VIEW public.v_finanzas_ppto AS
WITH hoy AS (
         SELECT (now() AT TIME ZONE 'America/New_York'::text)::date AS d
        )
 SELECT o.code AS office_code,
    p.anio,
    p.monto_anual,
    p.h1,
    p.mensual_2h,
    round(
        CASE
            WHEN EXTRACT(year FROM h.d) <> p.anio::numeric THEN p.monto_anual
            WHEN EXTRACT(month FROM h.d) <= 6::numeric THEN p.h1 * (h.d - make_date(p.anio, 1, 1) + 1)::numeric / (make_date(p.anio, 6, 30) - make_date(p.anio, 1, 1) + 1)::numeric
            ELSE p.h1 + p.mensual_2h * (EXTRACT(month FROM h.d) - 7::numeric) + p.mensual_2h * EXTRACT(day FROM h.d) / EXTRACT(day FROM date_trunc('month'::text, h.d::timestamp with time zone) + '1 mon -1 days'::interval)
        END, 0) AS ppto_ytd
   FROM finanzas_presupuesto p
     CROSS JOIN hoy h
     JOIN offices o ON o.id = p.office_id
  WHERE p.anio::numeric = EXTRACT(year FROM h.d) AND ((o.code IN ( SELECT unnest(app_finanzas_offices()) AS unnest)) OR ( SELECT COALESCE(auth.role(), ''::text) <> ALL (ARRAY['authenticated'::text, 'anon'::text])));

CREATE OR REPLACE VIEW public.v_finanzas_rc_por_zarpar AS
SELECT r.office_id,
    o.code AS office_code,
    count(*) FILTER (WHERE r.zarpo_at IS NULL) AS n_abiertos,
    round(sum(r.monto) FILTER (WHERE r.zarpo_at IS NULL), 2) AS total_abierto
   FROM finanzas_rc_por_zarpar r
     JOIN offices o ON o.id = r.office_id
  WHERE (o.code IN ( SELECT unnest(app_finanzas_offices()) AS unnest)) OR ( SELECT COALESCE(auth.role(), ''::text) <> ALL (ARRAY['authenticated'::text, 'anon'::text]))
  GROUP BY r.office_id, o.code;

CREATE OR REPLACE VIEW public.v_inflows_smart_forecast AS
WITH global_stats AS (
         SELECT percentile_cont(0.50::double precision) WITHIN GROUP (ORDER BY ((cash_movement.actual_date - cash_movement.expected_date)::double precision)) AS global_median
           FROM cash_movement
          WHERE cash_movement.direction = 'inflow'::text AND cash_movement.status = 'executed'::text AND cash_movement.actual_date IS NOT NULL AND cash_movement.expected_date IS NOT NULL
        )
 SELECT cm.id,
    cm.office_id,
    cm.bank_account_id,
    cm.counterparty_name,
    cm.amount_in_usd,
    cm.expected_date AS magaya_due_date,
    cm.expected_date +
        CASE
            WHEN pb.sample_size >= 3 THEN pb.median_days_late::integer
            ELSE COALESCE(g.global_median::integer, 9)
        END AS projected_date,
    COALESCE(pb.sample_size, 0::bigint) AS sample_size,
        CASE
            WHEN pb.sample_size >= 5 THEN 'high'::text
            WHEN pb.sample_size >= 3 THEN 'medium'::text
            WHEN pb.sample_size >= 1 THEN 'low'::text
            ELSE 'none'::text
        END AS confidence,
    COALESCE(pb.median_days_late, g.global_median, 9::double precision) AS applied_lag_days
   FROM cash_movement cm
     LEFT JOIN v_client_payment_behavior pb ON pb.office_id = cm.office_id AND pb.counterparty_key = lower(regexp_replace(COALESCE(cm.counterparty_name, ''::text), '\s+'::text, ' '::text, 'g'::text))
     CROSS JOIN global_stats g
  WHERE cm.direction = 'inflow'::text AND cm.status = 'committed'::text AND cm.amount_in_usd IS NOT NULL AND ((finanzas_office_code_for_office(cm.office_id) IN ( SELECT unnest(app_finanzas_offices()) AS unnest)) OR ( SELECT COALESCE(auth.role(), ''::text) <> ALL (ARRAY['authenticated'::text, 'anon'::text])));

CREATE OR REPLACE VIEW public.v_intercompany_matrix AS
SELECT meb.office_id AS from_office_id,
    o.code AS from_office_code,
    meb.entity_name AS to_entity,
    meb.kind,
    meb.balance_usd::numeric(15,2) AS balance_usd,
    meb.fetched_at
   FROM magaya_entity_balance meb
     JOIN offices o ON o.id = meb.office_id::text
  WHERE is_intercompany_name(meb.entity_name) AND ((o.code IN ( SELECT unnest(app_finanzas_offices()) AS unnest)) OR ( SELECT COALESCE(auth.role(), ''::text) <> ALL (ARRAY['authenticated'::text, 'anon'::text])))
  ORDER BY o.code, meb.balance_usd DESC;

CREATE OR REPLACE VIEW public.v_my_action_items AS
SELECT ai.id,
    ai.title,
    ai.details,
    ai.priority,
    ai.status,
    ai.due_date,
    ai.created_at,
    ai.completed_at,
    ai.assigned_to,
    s.id AS shipment_id,
    s.shipment_code,
    s.mbl,
    s.hbl,
    s.booking_ref,
    s.origin_port,
    s.destination_port,
    s.etd,
    s.eta,
    s.status AS shipment_status,
    s.office,
    s.sales_executive_id,
    c.id AS client_id,
    c.company_name AS client_name,
    u_exec.name AS sales_executive_name,
    u_assignee.name AS assigned_to_name,
        CASE
            WHEN ai.due_date IS NULL THEN NULL::integer
            ELSE ai.due_date - CURRENT_DATE
        END AS days_to_due,
        CASE
            WHEN ai.due_date IS NULL THEN false
            ELSE ai.due_date < CURRENT_DATE
        END AS is_overdue,
        CASE ai.priority
            WHEN 'CRITICAL'::text THEN 100
            WHEN 'HIGH'::text THEN 75
            WHEN 'NORMAL'::text THEN 50
            ELSE 10
        END +
        CASE
            WHEN ai.due_date IS NOT NULL AND ai.due_date < CURRENT_DATE THEN 50
            ELSE 0
        END +
        CASE
            WHEN ai.due_date IS NOT NULL THEN GREATEST(0, 30 - GREATEST(0, ai.due_date - CURRENT_DATE))
            ELSE 0
        END AS urgency_score
   FROM shipment_action_items ai
     LEFT JOIN shipments s ON s.id = ai.shipment_id
     LEFT JOIN clients c ON c.id = s.client_id
     LEFT JOIN users u_exec ON u_exec.id = s.sales_executive_id
     LEFT JOIN users u_assignee ON u_assignee.id = ai.assigned_to
  WHERE ai.status = 'OPEN'::text;

CREATE OR REPLACE VIEW public.v_office_margin_monthly AS
WITH charge_fx AS (
         SELECT ce.office_id,
            ce.txn_guid,
            ce.txn_type,
            ce.txn_date,
            ce.account_type,
            ce.charge_amount *
                CASE
                    WHEN ce.charge_currency = 'PEN'::text THEN COALESCE(mt.total_amount_usd / NULLIF(mt.total_amount, 0::numeric), 1.0 / 3.42)
                    ELSE 1::numeric
                END AS charge_amount_usd
           FROM magaya_charges_extracted ce
             LEFT JOIN magaya_transactions mt ON mt.magaya_guid = ce.txn_guid
          WHERE ce.txn_date >= '2025-01-01'::date
        ), revenue_m AS (
         SELECT v_revenue_monthly.office_id,
            v_revenue_monthly.office_code,
            v_revenue_monthly.month,
            sum(v_revenue_monthly.revenue_usd) AS revenue
           FROM v_revenue_monthly
          GROUP BY v_revenue_monthly.office_id, v_revenue_monthly.office_code, v_revenue_monthly.month
        ), cogs_m AS (
         SELECT cf.office_id,
            date_trunc('month'::text, cf.txn_date::timestamp with time zone)::date AS month,
            sum(cf.charge_amount_usd) FILTER (WHERE cf.account_type = 'CostOfGoodsSold'::text) AS cogs,
            sum(cf.charge_amount_usd) FILTER (WHERE cf.account_type = 'Expense'::text) AS expense,
            count(DISTINCT cf.txn_guid) FILTER (WHERE cf.txn_type = 'BI'::text) AS bills_with_data
           FROM charge_fx cf
          GROUP BY cf.office_id, (date_trunc('month'::text, cf.txn_date::timestamp with time zone))
        ), bills_total AS (
         SELECT office_for_magaya_company(mt.company_id) AS office_id,
            date_trunc('month'::text, COALESCE(mt.due_date, mt.created_on::date)::timestamp with time zone)::date AS month,
            count(*) AS bills_total,
            sum(magaya_amount_to_usd(mt.company_id, mt.total_amount, mt.total_amount_usd)) AS bills_total_amount
           FROM magaya_transactions mt
          WHERE mt.transaction_type = 'BI'::text AND mt.total_amount > 0::numeric AND mt.created_on >= '2025-01-01 00:00:00+00'::timestamp with time zone
          GROUP BY (office_for_magaya_company(mt.company_id)), (date_trunc('month'::text, COALESCE(mt.due_date, mt.created_on::date)::timestamp with time zone))
        )
 SELECT r.office_id,
    r.office_code,
    r.month,
    r.revenue::numeric(15,2) AS revenue,
    COALESCE(c.cogs, 0::numeric)::numeric(15,2) AS cogs_extracted,
    COALESCE(c.expense, 0::numeric)::numeric(15,2) AS expense_extracted,
    COALESCE(bt.bills_total_amount, 0::numeric)::numeric(15,2) AS bills_total,
    COALESCE(c.bills_with_data, 0::bigint) AS bills_with_xml,
    COALESCE(bt.bills_total, 0::bigint) AS bills_count_total,
        CASE
            WHEN bt.bills_total > 0 THEN round(c.bills_with_data::numeric / bt.bills_total::numeric * 100::numeric, 1)
            ELSE 0::numeric
        END AS bills_xml_coverage_pct,
        CASE
            WHEN bt.bills_total > 0 AND c.bills_with_data > 0 THEN round(c.cogs * bt.bills_total::numeric / c.bills_with_data::numeric, 2)
            ELSE 0::numeric
        END AS cogs_estimated_100pct,
        CASE
            WHEN bt.bills_total > 0 AND c.bills_with_data > 0 THEN round(r.revenue - c.cogs * bt.bills_total::numeric / c.bills_with_data::numeric, 2)
            ELSE r.revenue
        END AS gross_margin_estimated,
        CASE
            WHEN bt.bills_total > 0 AND c.bills_with_data > 0 AND r.revenue > 0::numeric THEN round((r.revenue - c.cogs * bt.bills_total::numeric / c.bills_with_data::numeric) / r.revenue * 100::numeric, 1)
            ELSE NULL::numeric
        END AS margin_pct_estimated
   FROM revenue_m r
     LEFT JOIN cogs_m c ON c.office_id = r.office_id AND c.month = r.month
     LEFT JOIN bills_total bt ON bt.office_id = r.office_id AND bt.month = r.month
  ORDER BY r.month DESC, r.office_code;

CREATE OR REPLACE VIEW public.v_ops_vacios AS
SELECT v.id,
    v.office,
    v.shipment_id,
    v.shipment_container_id,
    v.container_number,
    v.size_type,
    v.naviera,
    v.fecha_descarga,
    v.fecha_retiro,
    v.dias_libres,
    v.fecha_limite,
    v.fecha_devolucion,
    v.deposito,
    v.eir,
    v.notas,
    v.created_by,
    v.created_at,
    v.updated_at,
    s.mbl,
    s.shipment_code,
    COALESCE(s.consignee_name, c.company_name) AS cliente,
    s.status::text AS embarque_status,
    v.fecha_limite - CURRENT_DATE AS dias_restantes,
        CASE
            WHEN v.fecha_devolucion IS NOT NULL THEN 'DEVUELTO'::text
            WHEN v.fecha_limite IS NULL THEN 'SIN_FECHAS'::text
            WHEN v.fecha_limite < CURRENT_DATE THEN 'VENCIDO'::text
            WHEN (v.fecha_limite - CURRENT_DATE) <= 3 THEN 'POR_VENCER'::text
            ELSE 'EN_PLAZO'::text
        END AS estado
   FROM ops_devolucion_vacios v
     LEFT JOIN shipments s ON s.id = v.shipment_id
     LEFT JOIN clients c ON c.id = s.client_id;

CREATE OR REPLACE VIEW public.v_pnl_by_business_line AS
WITH operational AS (
         SELECT EXTRACT(year FROM v_charges_classified.op_date)::integer AS year,
            EXTRACT(month FROM v_charges_classified.op_date)::integer AS month,
            v_charges_classified.business_line,
            sum(
                CASE
                    WHEN v_charges_classified.line_type = 'Revenue'::text THEN v_charges_classified.amount
                    ELSE 0::numeric
                END) AS revenue,
            sum(
                CASE
                    WHEN v_charges_classified.line_type = 'COGS'::text THEN v_charges_classified.amount
                    ELSE 0::numeric
                END) AS direct_cogs
           FROM archive.v_charges_classified
          WHERE v_charges_classified.op_date IS NOT NULL
          GROUP BY (EXTRACT(year FROM v_charges_classified.op_date)::integer), (EXTRACT(month FROM v_charges_classified.op_date)::integer), v_charges_classified.business_line
        ), wh_fixed AS (
         SELECT warehouse_cogs_monthly.year,
            warehouse_cogs_monthly.month,
            sum(warehouse_cogs_monthly.amount) AS fixed_wh_cogs
           FROM warehouse_cogs_monthly
          GROUP BY warehouse_cogs_monthly.year, warehouse_cogs_monthly.month
        )
 SELECT o.year,
    o.month,
    o.business_line,
    o.revenue,
    o.direct_cogs,
        CASE
            WHEN o.business_line = 'Warehouse'::text THEN COALESCE(wh.fixed_wh_cogs, 0::numeric)
            ELSE 0::numeric
        END AS fixed_warehouse_cogs,
    o.revenue - o.direct_cogs -
        CASE
            WHEN o.business_line = 'Warehouse'::text THEN COALESCE(wh.fixed_wh_cogs, 0::numeric)
            ELSE 0::numeric
        END AS gross_profit,
        CASE
            WHEN o.revenue > 0::numeric THEN round((o.revenue - o.direct_cogs -
            CASE
                WHEN o.business_line = 'Warehouse'::text THEN COALESCE(wh.fixed_wh_cogs, 0::numeric)
                ELSE 0::numeric
            END) / o.revenue * 100::numeric, 1)
            ELSE NULL::numeric
        END AS margin_pct
   FROM operational o
     LEFT JOIN wh_fixed wh ON o.year = wh.year AND o.month = wh.month AND o.business_line = 'Warehouse'::text
  ORDER BY o.year, o.month, o.business_line;

CREATE OR REPLACE VIEW public.v_pnl_by_flow_type AS
SELECT EXTRACT(year FROM op_date)::integer AS year,
    EXTRACT(month FROM op_date)::integer AS month,
    flow_type,
    business_line,
    sum(
        CASE
            WHEN line_type = 'Revenue'::text THEN amount
            ELSE 0::numeric
        END) AS revenue,
    sum(
        CASE
            WHEN line_type = 'COGS'::text THEN amount
            ELSE 0::numeric
        END) AS cogs,
    sum(
        CASE
            WHEN line_type = 'Revenue'::text THEN amount
            ELSE 0::numeric
        END) - sum(
        CASE
            WHEN line_type = 'COGS'::text THEN amount
            ELSE 0::numeric
        END) AS gross_profit,
    count(*) AS charge_count
   FROM v_charges_by_flow_type
  WHERE op_date IS NOT NULL
  GROUP BY (EXTRACT(year FROM op_date)::integer), (EXTRACT(month FROM op_date)::integer), flow_type, business_line;

CREATE OR REPLACE VIEW public.v_reception_hosts AS
SELECT id,
    name,
    department,
    office
   FROM users
  WHERE office = 'USA'::text AND status = 'Active'::text;

CREATE OR REPLACE VIEW public.v_revenue_monthly AS
SELECT u.office_id,
    o.code AS office_code,
    o.display_name AS office_name,
    date_trunc('month'::text, u.invoice_date::timestamp with time zone)::date AS month,
    count(*) AS invoice_count,
    count(DISTINCT u.counterparty_name) AS unique_clients,
    sum(u.amount_in_usd)::numeric(15,2) AS revenue_usd,
    sum(
        CASE
            WHEN NOT is_intercompany_name(u.counterparty_name) THEN u.amount_in_usd
            ELSE 0::numeric
        END)::numeric(15,2) AS revenue_external_usd,
    sum(
        CASE
            WHEN is_intercompany_name(u.counterparty_name) THEN u.amount_in_usd
            ELSE 0::numeric
        END)::numeric(15,2) AS revenue_intercompany_usd,
    sum(
        CASE
            WHEN u.status = 'executed'::text THEN u.amount_in_usd
            ELSE 0::numeric
        END)::numeric(15,2) AS revenue_paid_usd,
    sum(
        CASE
            WHEN u.status = 'committed'::text THEN u.amount_in_usd
            ELSE 0::numeric
        END)::numeric(15,2) AS revenue_open_usd
   FROM v_magaya_invoices_unified u
     JOIN offices o ON o.id = u.office_id::text
  WHERE u.direction = 'inflow'::text AND u.invoice_date <= CURRENT_DATE AND ((o.code IN ( SELECT unnest(app_finanzas_offices()) AS unnest)) OR ( SELECT COALESCE(auth.role(), ''::text) <> ALL (ARRAY['authenticated'::text, 'anon'::text])))
  GROUP BY u.office_id, o.code, o.display_name, (date_trunc('month'::text, u.invoice_date::timestamp with time zone));

CREATE OR REPLACE VIEW public.v_revenue_mtd_pace AS
WITH params AS (
         SELECT CURRENT_DATE AS hoy,
            EXTRACT(day FROM CURRENT_DATE)::integer AS dom,
            date_trunc('month'::text, CURRENT_DATE::timestamp with time zone)::date AS mes_actual,
            (date_trunc('month'::text, CURRENT_DATE::timestamp with time zone) - '1 mon'::interval)::date AS mes_pasado,
            (date_trunc('month'::text, CURRENT_DATE::timestamp with time zone) - '1 year'::interval)::date AS mes_ano_pasado
        )
 SELECT o.code AS office_code,
    p.dom AS dias_transcurridos,
    COALESCE(sum(u.amount_in_usd) FILTER (WHERE u.invoice_date >= p.mes_actual AND u.invoice_date <= p.hoy), 0::numeric)::numeric(15,2) AS mtd_usd,
    COALESCE(count(*) FILTER (WHERE u.invoice_date >= p.mes_actual AND u.invoice_date <= p.hoy), 0::bigint) AS mtd_count,
    COALESCE(sum(u.amount_in_usd) FILTER (WHERE u.invoice_date >= p.mes_pasado AND u.invoice_date < p.mes_actual AND EXTRACT(day FROM u.invoice_date) <= p.dom::numeric), 0::numeric)::numeric(15,2) AS prev_month_window_usd,
    COALESCE(sum(u.amount_in_usd) FILTER (WHERE u.invoice_date >= p.mes_pasado AND u.invoice_date < p.mes_actual), 0::numeric)::numeric(15,2) AS prev_month_full_usd,
    COALESCE(sum(u.amount_in_usd) FILTER (WHERE u.invoice_date >= p.mes_ano_pasado AND u.invoice_date < (p.mes_ano_pasado + '1 mon'::interval) AND EXTRACT(day FROM u.invoice_date) <= p.dom::numeric), 0::numeric)::numeric(15,2) AS prev_year_window_usd,
    COALESCE(sum(u.amount_in_usd) FILTER (WHERE u.invoice_date >= p.mes_ano_pasado AND u.invoice_date < (p.mes_ano_pasado + '1 mon'::interval)), 0::numeric)::numeric(15,2) AS prev_year_month_full_usd
   FROM v_magaya_invoices_unified u
     CROSS JOIN params p
     JOIN offices o ON o.id = u.office_id::text
  WHERE u.direction = 'inflow'::text AND u.invoice_date >= p.mes_ano_pasado AND u.invoice_date <= p.hoy AND ((o.code IN ( SELECT unnest(app_finanzas_offices()) AS unnest)) OR ( SELECT COALESCE(auth.role(), ''::text) <> ALL (ARRAY['authenticated'::text, 'anon'::text])))
  GROUP BY o.code, p.dom;

CREATE OR REPLACE VIEW public.v_roles_desalineados AS
SELECT u.id,
    u.name,
    u.email,
    u.office,
    u.role AS rol_texto_manda_en_rls,
    r.name AS rol_id_manda_en_menus,
    u.role = ANY (ARRAY['Admin'::text, 'VP'::text]) AS hoy_es_admin_en_rls,
    u.role = 'Manager'::text AS hoy_ve_toda_su_oficina,
    r.name = ANY (ARRAY['Admin'::text, 'VP'::text]) AS quedaria_admin_si_sincronizamos,
    r.name = 'Manager'::text AS quedaria_viendo_toda_la_oficina
   FROM users u
     LEFT JOIN roles r ON r.id = u.role_id
  WHERE COALESCE(u.status, 'Active'::text) = 'Active'::text AND (u.role_id IS NULL OR r.name IS DISTINCT FROM u.role);

CREATE OR REPLACE VIEW public.v_shipments_active AS
SELECT NULL::uuid AS magaya_shipment_id,
    s.id AS shipment_id,
    true AS is_promoted,
    s.magaya_shipment_id IS NULL AS is_programming_only,
    s.archived_at,
    s.archived_at IS NOT NULL AS is_archived,
    s.shipment_code AS shipment_number,
    NULL::text AS guid,
        CASE s.status
            WHEN 'IN_WAREHOUSE'::shipment_status_t THEN 'OnHand'::text
            WHEN 'LOADED'::shipment_status_t THEN 'Loaded'::text
            WHEN 'IN_TRANSIT'::shipment_status_t THEN 'InTransit'::text
            WHEN 'ARRIVED'::shipment_status_t THEN 'Arrived'::text
            WHEN 'CUSTOMS'::shipment_status_t THEN 'Customs'::text
            WHEN 'RELEASED'::shipment_status_t THEN 'Released'::text
            WHEN 'DELIVERED'::shipment_status_t THEN 'Delivered'::text
            WHEN 'BOOKING'::shipment_status_t THEN 'Booking'::text
            WHEN 'CANCELLED'::shipment_status_t THEN 'Cancelled'::text
            ELSE s.status::text
        END AS magaya_status,
    s.status::text AS op_status,
    s.direction::text AS direction,
    s.mode::text AS mode,
    NULL::text AS service_type,
    s.carrier,
    COALESCE(c.company_name, s.consignee_name) AS consignee,
    COALESCE(( SELECT ss.name
           FROM shipment_shippers ss
          WHERE ss.shipment_id = s.id
          ORDER BY ss."position", ss.created_at
         LIMIT 1), s.supplier) AS shipper,
    c.company_name AS magaya_client_name,
    NULL::text AS billing_client_name,
    s.origin_port AS origin,
    s.destination_port AS destination,
    s.etd,
    s.eta,
    s.mbl,
    s.booking_ref AS booking_number,
    s.vessel_name,
    s.voyage,
    ( SELECT string_agg((sc.quantity::text || 'x'::text) || sc.size_type, ' + '::text ORDER BY sc."position", sc.created_at) AS string_agg
           FROM shipment_containers sc
          WHERE sc.shipment_id = s.id) AS container_numbers,
    ( SELECT sum(sc.quantity)::integer AS sum
           FROM shipment_containers sc
          WHERE sc.shipment_id = s.id) AS total_containers,
    NULL::integer AS pieces,
    NULL::numeric AS weight,
    NULL::numeric AS total_revenue,
    s.created_at,
    NULL::timestamp with time zone AS synced_at,
    c.id AS matched_client_id,
    c.company_name AS matched_client_name,
    c.office AS matched_client_office,
    s.sales_executive_id AS matched_sales_executive_id,
    u.name AS matched_sales_executive_name,
    s.office AS routed_office,
    s.cs_assigned_to,
    cs_user.name AS cs_assigned_name,
    s.incoterm,
    s.supplier,
    s.hbl,
    s.eta_text,
    s.client_id,
    ( SELECT count(*)::integer AS count
           FROM shipment_shippers ss
          WHERE ss.shipment_id = s.id) AS shippers_count,
    ( SELECT string_agg(ss.name || COALESCE((' ('::text || ss.incoterm) || ')'::text, ''::text), ', '::text ORDER BY ss."position", ss.created_at) AS string_agg
           FROM shipment_shippers ss
          WHERE ss.shipment_id = s.id) AS shippers_summary,
    ( SELECT string_agg((sc.quantity::text || 'x'::text) || sc.size_type, ' + '::text ORDER BY sc."position", sc.created_at) AS string_agg
           FROM shipment_containers sc
          WHERE sc.shipment_id = s.id) AS containers_summary,
    ( SELECT count(*)::integer AS count
           FROM shipment_containers sc
          WHERE sc.shipment_id = s.id) AS containers_rows,
    ( SELECT string_agg(((sa.name || ' ('::text) || sa.agent_role) || ')'::text, ', '::text ORDER BY sa."position", sa.created_at) AS string_agg
           FROM shipment_agents sa
          WHERE sa.shipment_id = s.id) AS agents_summary,
    ( SELECT count(*)::integer AS count
           FROM shipment_agents sa
          WHERE sa.shipment_id = s.id) AS agents_count,
    ( SELECT count(*) AS count
           FROM shipment_action_items ai
          WHERE ai.shipment_id = s.id AND ai.status = 'OPEN'::text) AS open_action_items,
    ( SELECT count(*) AS count
           FROM shipment_events e
          WHERE e.shipment_id = s.id) AS event_count,
    u.gender AS matched_sales_executive_gender,
    (EXISTS ( SELECT 1
           FROM shipment_events e
          WHERE e.shipment_id = s.id AND (e.event_type ~* '^import'::text OR e.description ~~* 'Importado%'::text))) AS is_imported
   FROM shipments s
     LEFT JOIN clients c ON c.id = s.client_id
     LEFT JOIN users u ON u.id = s.sales_executive_id
     LEFT JOIN users cs_user ON cs_user.id = s.cs_assigned_to;

CREATE OR REPLACE VIEW public.v_surcharges_por_confirmar AS
SELECT c.code AS carrier_code,
    c.name AS carrier_name,
    s.code,
    s.name,
    s.amount,
    s.revision_frequency,
    s.last_confirmed_at,
    CURRENT_DATE - s.last_confirmed_at AS dias_sin_confirmar,
        CASE s.revision_frequency
            WHEN 'WEEKLY'::text THEN 7
            WHEN 'BIWEEKLY'::text THEN 14
            WHEN 'MONTHLY'::text THEN 30
            ELSE 30
        END AS ciclo_dias
   FROM surcharges s
     JOIN carriers c ON c.id = s.carrier_id
  WHERE s.active AND s.volatile AND (s.last_confirmed_at IS NULL OR (CURRENT_DATE - s.last_confirmed_at) >
        CASE s.revision_frequency
            WHEN 'WEEKLY'::text THEN 7
            WHEN 'BIWEEKLY'::text THEN 14
            WHEN 'MONTHLY'::text THEN 30
            ELSE 30
        END);

CREATE OR REPLACE VIEW public.v_sync_health AS
WITH checks AS (
         SELECT 'transactions'::text AS source,
            'Movimientos y finanzas'::text AS label,
            magaya_transactions.company_id,
            max(magaya_transactions.synced_at) AS last_sync,
            2 AS threshold_days
           FROM magaya_transactions
          GROUP BY magaya_transactions.company_id
        UNION ALL
         SELECT 'charges'::text AS text,
            'Cargos / facturación'::text AS text,
            magaya_transaction_charges.company_id,
            max(magaya_transaction_charges.created_at) AS max,
            3
           FROM magaya_transaction_charges
          GROUP BY magaya_transaction_charges.company_id
        UNION ALL
         SELECT 'warehouse'::text AS text,
            'Bodega Miami (Warehouse Receipts)'::text AS text,
            magaya_warehouse_receipts.company_id,
            max(magaya_warehouse_receipts.synced_at) AS max,
            3
           FROM magaya_warehouse_receipts
          GROUP BY magaya_warehouse_receipts.company_id
        )
 SELECT co.name AS office,
    co.code AS office_code,
    c.source,
    c.label,
    c.last_sync,
    round(EXTRACT(epoch FROM now() - c.last_sync) / 86400::numeric, 1) AS days_ago,
    c.threshold_days,
        CASE
            WHEN c.last_sync IS NULL THEN 'SIN DATOS'::text
            WHEN (now() - c.last_sync) > make_interval(days => c.threshold_days) THEN 'ESTANCADA'::text
            ELSE 'OK'::text
        END AS status
   FROM checks c
     JOIN magaya_companies co ON co.id = c.company_id
  ORDER BY c.source, co.code;

CREATE OR REPLACE VIEW public.v_top_clients_12m AS
SELECT office_id,
    office_code,
    client_name AS counterparty_name,
    is_intercompany,
    revenue_12m,
    active_months_12m AS active_months,
    spark_12m AS spark_amounts,
    ARRAY[]::text[] AS spark_months,
    last_active_month,
    revenue_3m AS recent_3m,
    revenue_prior_3m AS old_3m,
    trend,
    yoy_growth_pct,
    qoq_growth_pct
   FROM v_client_summary;

CREATE OR REPLACE VIEW public.v_top_vendors_12m AS
SELECT u.office_id,
    o.code AS office_code,
    u.counterparty_name AS vendor_name,
    is_intercompany_name(u.counterparty_name) AS is_intercompany,
    sum(u.amount_in_usd)::numeric(15,2) AS spend_12m,
    count(*) AS bill_count,
    max(u.invoice_date) AS last_bill_date,
    min(u.invoice_date) AS first_bill_date
   FROM v_magaya_invoices_unified u
     JOIN offices o ON o.id = u.office_id::text
  WHERE u.direction = 'outflow'::text AND u.invoice_date >= (CURRENT_DATE - '1 year'::interval) AND u.invoice_date <= CURRENT_DATE AND ((o.code IN ( SELECT unnest(app_finanzas_offices()) AS unnest)) OR ( SELECT COALESCE(auth.role(), ''::text) <> ALL (ARRAY['authenticated'::text, 'anon'::text])))
  GROUP BY u.office_id, o.code, u.counterparty_name;

CREATE OR REPLACE VIEW public.v_wh_aduana_miami AS
SELECT DISTINCT ON (w.wr_number) w.wr_number,
    wh_regimen_desde_magaya(w.bonded_entry) AS regimen,
    w.bonded_entry AS regimen_magaya,
    w.bonded_entry_number AS entrada_aduanera,
    w.bonded_entry_date AS fecha_entrada,
    CURRENT_DATE - COALESCE(w.entry_date, w.created_on) AS dias_en_bodega,
    CURRENT_DATE - COALESCE(w.bonded_entry_date, w.entry_date, w.created_on) AS dias_desde_entrada,
    w.bonded_entry_date IS NULL AS fecha_estimada,
    w.consignee,
    w.shipper,
    w.destination_port,
    w.destination_agent,
    w.pieces,
    w.weight,
    w.cbm,
    w.location_code,
    w.warehouse_zone,
    w.entry_date,
    w.created_on,
    w.status,
    l.id AS linea_id,
    l.consolidado_id,
    l.estado AS estado_linea,
    COALESCE(d.numero, l.doc_7512) AS doc_7512,
    COALESCE(d.registrado_at, l.doc_7512_at) AS doc_7512_at,
    l.id IS NOT NULL AS en_consolidado,
    COALESCE(btrim(COALESCE(d.numero, l.doc_7512)), ''::text) = ''::text AS falta_7512
   FROM magaya_warehouse_receipts w
     LEFT JOIN wh_doc_7512 d ON d.wr_number = w.wr_number
     LEFT JOIN consolidado_lineas l ON l.wr_number = w.wr_number AND (l.estado <> ALL (ARRAY['EXCLUIDO'::text, 'RODADO'::text])) AND (l.consolidado_id IN ( SELECT consolidados.id
           FROM consolidados
          WHERE consolidados.estado = ANY (ARRAY['ABIERTO'::text, 'CERRADO'::text])))
     LEFT JOIN consolidados c ON c.id = l.consolidado_id
  WHERE w.bonded_entry IS NOT NULL AND lower(w.bonded_entry) <> 'none'::text AND w.out_date IS NULL
  ORDER BY w.wr_number, (COALESCE(btrim(l.doc_7512), ''::text) <> ''::text) DESC, c.etd;

CREATE OR REPLACE VIEW public.v_wh_calidad_dato AS
WITH base AS (
         SELECT w.wr_number,
            w.consignee,
            w.shipper,
            w.destination_agent,
            w.destination_port,
            w.created_on,
            w.entry_date,
            w.status,
            w.location_code,
            w.pieces,
            w.weight,
            w.weight_unit,
            w.volume_cft,
            w.volume_unit,
            w.cbm,
                CASE
                    WHEN COALESCE(w.volume_cft, 0::numeric) > 0::numeric AND COALESCE(w.weight, 0::numeric) > 0::numeric THEN w.weight / w.volume_cft
                    ELSE NULL::numeric
                END AS lb_por_ft3,
            count(*) OVER (PARTITION BY w.consignee, w.pieces, w.weight, w.volume_cft) AS recibos_con_la_misma_medida
           FROM magaya_warehouse_receipts w
          WHERE w.out_date IS NULL AND w.created_on >= (CURRENT_DATE - 180)
        )
 SELECT wr_number,
    consignee,
    shipper,
    destination_agent,
    destination_port,
    created_on,
    entry_date,
    status,
    location_code,
    pieces,
    weight,
    weight_unit,
    volume_cft,
    volume_unit,
    cbm,
    lb_por_ft3,
    recibos_con_la_misma_medida,
    (EXISTS ( SELECT 1
           FROM consolidado_lineas l
             JOIN consolidados c ON c.id = l.consolidado_id
          WHERE l.wr_number = b.wr_number AND (c.estado = ANY (ARRAY['ABIERTO'::text, 'CERRADO'::text])))) AS en_consolidado_vigente,
        CASE
            WHEN volume_unit = 'm3'::text THEN round(volume_cft, 2)
            ELSE NULL::numeric
        END AS m3_reales_si_unidad_m3,
    array_remove(ARRAY[
        CASE
            WHEN volume_unit = 'm3'::text THEN 'VOLUMEN_EN_M3'::text
            ELSE NULL::text
        END,
        CASE
            WHEN weight_unit = 'kg'::text THEN 'PESO_EN_KG'::text
            ELSE NULL::text
        END,
        CASE
            WHEN COALESCE(volume_cft, 0::numeric) = 0::numeric THEN 'SIN_VOLUMEN'::text
            ELSE NULL::text
        END,
        CASE
            WHEN COALESCE(weight, 0::numeric) = 0::numeric THEN 'SIN_PESO'::text
            ELSE NULL::text
        END,
        CASE
            WHEN COALESCE(pieces, 0) = 0 THEN 'SIN_PIEZAS'::text
            ELSE NULL::text
        END,
        CASE
            WHEN lb_por_ft3 > 100::numeric THEN 'DEMASIADO_PESADO'::text
            ELSE NULL::text
        END,
        CASE
            WHEN lb_por_ft3 < 1::numeric THEN 'DEMASIADO_LIVIANO'::text
            ELSE NULL::text
        END,
        CASE
            WHEN volume_cft > 2400::numeric THEN 'VOLUMEN_MAYOR_A_UN_40'::text
            ELSE NULL::text
        END,
        CASE
            WHEN recibos_con_la_misma_medida > 1 AND COALESCE(volume_cft, 0::numeric) > 0::numeric THEN 'MEDIDA_REPETIDA'::text
            ELSE NULL::text
        END], NULL::text) AS motivos,
        CASE
            WHEN volume_unit = 'm3'::text OR weight_unit = 'kg'::text THEN 1
            WHEN COALESCE(volume_cft, 0::numeric) = 0::numeric OR COALESCE(weight, 0::numeric) = 0::numeric OR COALESCE(pieces, 0) = 0 THEN 2
            WHEN lb_por_ft3 > 100::numeric OR lb_por_ft3 < 1::numeric OR volume_cft > 2400::numeric THEN 3
            WHEN recibos_con_la_misma_medida > 1 AND COALESCE(volume_cft, 0::numeric) > 0::numeric THEN 4
            ELSE 9
        END AS severidad
   FROM base b
  WHERE volume_unit = 'm3'::text OR weight_unit = 'kg'::text OR COALESCE(volume_cft, 0::numeric) = 0::numeric OR COALESCE(weight, 0::numeric) = 0::numeric OR COALESCE(pieces, 0) = 0 OR lb_por_ft3 > 100::numeric OR lb_por_ft3 < 1::numeric OR volume_cft > 2400::numeric OR recibos_con_la_misma_medida > 1 AND COALESCE(volume_cft, 0::numeric) > 0::numeric;

CREATE OR REPLACE VIEW public.v_wh_client_behavior AS
WITH bounds AS (
         SELECT date_trunc('week'::text, CURRENT_DATE::timestamp with time zone)::date AS this_wk
        ), wk AS (
         SELECT m.trade_dir,
            m.dim_type,
            m.dim_value,
            m.period,
            m.cbm,
            m.wrs
           FROM mv_wh_metrics m,
            bounds b
          WHERE m.grain = 'week'::text AND m.period < b.this_wk
        ), agg AS (
         SELECT w.trade_dir,
            w.dim_type,
            w.dim_value,
            round(sum(w.cbm) FILTER (WHERE w.period >= (b.this_wk - 28)), 1) AS cbm_4w,
            round(sum(w.cbm) FILTER (WHERE w.period >= (b.this_wk - 56) AND w.period < (b.this_wk - 28)), 1) AS cbm_prev4w,
            sum(w.wrs) FILTER (WHERE w.period >= (b.this_wk - 28)) AS wrs_4w,
            count(*) FILTER (WHERE w.period >= (b.this_wk - 28) AND w.cbm > 0::numeric) AS sem_activas_4w,
            max(w.period) FILTER (WHERE w.cbm > 0::numeric) AS ult_sem_activa
           FROM wk w,
            bounds b
          GROUP BY w.trade_dir, w.dim_type, w.dim_value
        )
 SELECT trade_dir,
    dim_type,
    dim_value,
    cbm_4w,
    cbm_prev4w,
    wrs_4w,
    sem_activas_4w,
    ult_sem_activa,
    round((cbm_4w - cbm_prev4w) / NULLIF(cbm_prev4w, 0::numeric) * 100::numeric, 0) AS pct_4w_vs_prev,
        CASE
            WHEN COALESCE(cbm_4w, 0::numeric) = 0::numeric AND COALESCE(cbm_prev4w, 0::numeric) > 0::numeric THEN 'DORMIDO'::text
            WHEN COALESCE(cbm_prev4w, 0::numeric) = 0::numeric AND COALESCE(cbm_4w, 0::numeric) > 0::numeric THEN 'NUEVO'::text
            WHEN cbm_4w >= (cbm_prev4w * 1.2) THEN 'CRECIENDO'::text
            WHEN cbm_4w <= (cbm_prev4w * 0.8) THEN 'CAYENDO'::text
            ELSE 'ESTABLE'::text
        END AS estado
   FROM agg;

CREATE OR REPLACE VIEW public.v_wh_containers_monthly AS
SELECT date_trunc('month'::text, to_date(((board_year || '-'::text) || week_no) || '-1'::text, 'IYYY-IW-ID'::text)::timestamp with time zone)::date AS month,
    trade_dir,
        CASE
            WHEN name ~~* 'EKO%'::text OR name ~~* '%ekopack%'::text OR name ~~* '%ecopack%'::text OR name ~~* '%eko bags%'::text OR name ~~* '%ekobags%'::text OR name ~~* '%green prime pack%'::text THEN 'EKO PACKING'::text
            WHEN name ~~* 'terr%'::text THEN 'TERRABOX'::text
            WHEN name ~~* 'FISA%'::text THEN 'FISA'::text
            WHEN name ~~* 'DREAMPACK%'::text THEN 'DREAMPACK'::text
            WHEN name ~~* 'A3K%'::text THEN 'A3K SOURCING'::text
            WHEN name ~~* '%barnana%'::text THEN 'BARNANA'::text
            WHEN name ~~* '%air water%'::text THEN 'AIR WATER'::text
            WHEN name ~~* '%jd 2015%'::text OR name ~~* '%dmi%'::text THEN 'JD 2015'::text
            WHEN trade_dir = 'IMPORT'::text THEN 'OTRO IMPORT'::text
            ELSE NULL::text
        END AS import_client,
    container_type,
    cbm_capacity,
    status,
    board_year,
    week_no
   FROM wh_containers
  WHERE week_no IS NOT NULL;

CREATE OR REPLACE VIEW public.v_wh_containers_priced AS
WITH b AS (
         SELECT wh_containers.monday_item_id,
            wh_containers.trade_dir,
            NULLIF(btrim(wh_containers.loader), ''::text) AS loader,
            to_date(((wh_containers.board_year || '-'::text) || wh_containers.week_no) || '-1'::text, 'IYYY-IW-ID'::text) AS wkd,
            COALESCE(NULLIF(wh_containers.container_type, ''::text), '(otro)'::text) AS container_type,
            COALESCE(wh_containers.cbm_capacity, 0::numeric) AS cbm_capacity,
            upper(wh_containers.status) AS su,
                CASE
                    WHEN wh_containers.name ~~* 'EKO%'::text OR wh_containers.name ~~* '%ekopack%'::text OR wh_containers.name ~~* '%ecopack%'::text OR wh_containers.name ~~* '%eko bags%'::text OR wh_containers.name ~~* '%ekobags%'::text OR wh_containers.name ~~* '%green prime pack%'::text THEN 'EKO PACKING'::text
                    WHEN wh_containers.name ~~* 'terr%'::text THEN 'TERRABOX'::text
                    WHEN wh_containers.name ~~* 'FISA%'::text THEN 'FISA'::text
                    WHEN wh_containers.name ~~* 'DREAMPACK%'::text THEN 'DREAMPACK'::text
                    WHEN wh_containers.name ~~* 'A3K%'::text THEN 'A3K SOURCING'::text
                    WHEN wh_containers.name ~~* '%barnana%'::text THEN 'BARNANA'::text
                    WHEN wh_containers.name ~~* '%air water%'::text THEN 'AIR WATER'::text
                    WHEN wh_containers.name ~~* '%jd 2015%'::text OR wh_containers.name ~~* '%dmi%'::text THEN 'JD 2015'::text
                    WHEN wh_containers.trade_dir = 'IMPORT'::text THEN 'OTRO IMPORT'::text
                    ELSE NULL::text
                END AS import_client
           FROM wh_containers
          WHERE wh_containers.week_no IS NOT NULL
        )
 SELECT b.monday_item_id,
    b.trade_dir,
    b.loader,
    b.wkd,
    b.container_type,
    b.cbm_capacity,
    b.su,
    b.import_client,
    b.su ~~ 'LOADED%'::text AS is_loaded,
    b.su ~~ 'UNLOADED%'::text AS is_unloaded,
        CASE
            WHEN b.trade_dir = 'EXPORT'::text AND b.su ~~ 'LOADED%'::text THEN COALESCE(lr.rate_usd, 0::numeric)
            WHEN b.trade_dir = 'IMPORT'::text AND b.su ~~ 'UNLOADED%'::text THEN COALESCE(ur.rate_usd, 0::numeric)
            ELSE 0::numeric
        END AS revenue_usd
   FROM b
     LEFT JOIN wh_loading_rates lr ON lr.container_type = b.container_type AND lr.client_group = 'ALL'::text
     LEFT JOIN LATERAL ( SELECT u.rate_usd
           FROM wh_unloading_rates u
          WHERE u.client_group = b.import_client AND (u.container_type = b.container_type OR u.container_type = 'ALL'::text)
          ORDER BY (u.container_type = 'ALL'::text)
         LIMIT 1) ur ON true;

CREATE OR REPLACE VIEW public.v_wh_export_country_monthly AS
SELECT date_trunc('month'::text, wr.created_on::timestamp with time zone)::date AS month,
    COALESCE(pc.country, ac.country, '(sin país)'::text) AS country,
    count(*) AS wrs,
    round(sum(wr.cbm), 1) AS cbm
   FROM magaya_warehouse_receipts wr
     LEFT JOIN LATERAL ( SELECT m.country
           FROM wh_country_map m
          WHERE m.match_field = 'destination_port'::text AND wr.destination_port ~~* m.match_pattern
          ORDER BY m.priority
         LIMIT 1) pc ON true
     LEFT JOIN LATERAL ( SELECT m.country
           FROM wh_country_map m
          WHERE m.match_field = 'destination_agent'::text AND wr.destination_agent ~~* m.match_pattern
          ORDER BY m.priority
         LIMIT 1) ac ON true
  WHERE wr.created_on <= CURRENT_DATE AND wr.created_on IS NOT NULL AND wr.destination_agent <> 'GLOVAL SHIPPING USA (INBOUND)'::text AND NOT (EXISTS ( SELECT 1
           FROM wh_import_clients ic
          WHERE ic.active AND (wr.consignee ~~* ic.match_pattern OR wr.shipper ~~* ic.match_pattern)))
  GROUP BY (date_trunc('month'::text, wr.created_on::timestamp with time zone)::date), (COALESCE(pc.country, ac.country, '(sin país)'::text));

CREATE OR REPLACE VIEW public.v_wh_export_seasonal AS
WITH b AS (
         SELECT (date_trunc('month'::text, CURRENT_DATE::timestamp with time zone) - '1 mon'::interval)::date AS cur_m,
            (date_trunc('month'::text, CURRENT_DATE::timestamp with time zone) - '2 mons'::interval)::date AS prev_m,
            (date_trunc('month'::text, CURRENT_DATE::timestamp with time zone) - '1 year'::interval - '1 mon'::interval)::date AS ly_m
        ), agg AS (
         SELECT m.dim_value AS cliente,
            round(max(m.cbm) FILTER (WHERE m.period = b.cur_m), 1) AS cbm_cur,
            round(max(m.cbm) FILTER (WHERE m.period = b.prev_m), 1) AS cbm_prev,
            round(max(m.cbm) FILTER (WHERE m.period = b.ly_m), 1) AS cbm_ly
           FROM mv_wh_metrics m,
            b
          WHERE m.grain = 'month'::text AND m.trade_dir = 'EXPORT'::text AND m.dim_type = 'consignee'::text AND (m.period = b.cur_m OR m.period = b.prev_m OR m.period = b.ly_m) AND m.dim_value !~~* '%gloval%'::text AND m.dim_value !~~* '%as agent%'::text AND m.dim_value <> '(sin consignee)'::text
          GROUP BY m.dim_value
        )
 SELECT cliente,
    cbm_cur,
    cbm_prev,
    cbm_ly,
    round((cbm_cur - cbm_prev) / NULLIF(cbm_prev, 0::numeric) * 100::numeric, 0) AS mom_pct,
    round((cbm_cur - cbm_ly) / NULLIF(cbm_ly, 0::numeric) * 100::numeric, 0) AS yoy_pct,
        CASE
            WHEN COALESCE(cbm_cur, 0::numeric) = 0::numeric AND (COALESCE(cbm_prev, 0::numeric) > 0::numeric OR COALESCE(cbm_ly, 0::numeric) > 0::numeric) THEN 'DORMIDO'::text
            WHEN COALESCE(cbm_prev, 0::numeric) = 0::numeric AND COALESCE(cbm_ly, 0::numeric) = 0::numeric AND COALESCE(cbm_cur, 0::numeric) > 0::numeric THEN 'NUEVO'::text
            WHEN cbm_cur >= (COALESCE(cbm_prev, 0::numeric) * 1.2) AND cbm_cur >= COALESCE(cbm_ly, 0::numeric) THEN 'CRECIENDO'::text
            WHEN cbm_cur < (cbm_prev * 0.8) AND cbm_cur < (cbm_ly * 0.8) THEN 'ALERTA REAL'::text
            WHEN cbm_cur < (cbm_prev * 0.8) AND cbm_cur >= (cbm_ly * 0.8) THEN 'ESTACIONAL'::text
            ELSE 'ESTABLE'::text
        END AS estado
   FROM agg;

CREATE OR REPLACE VIEW public.v_wh_import_seasonal AS
WITH b AS (
         SELECT (date_trunc('month'::text, CURRENT_DATE::timestamp with time zone) - '1 mon'::interval)::date AS cur_m,
            (date_trunc('month'::text, CURRENT_DATE::timestamp with time zone) - '2 mons'::interval)::date AS prev_m,
            (date_trunc('month'::text, CURRENT_DATE::timestamp with time zone) - '1 year'::interval - '1 mon'::interval)::date AS ly_m
        ), agg AS (
         SELECT v.import_client AS cliente,
            count(*) FILTER (WHERE v.month = b.cur_m) AS cont_cur,
            count(*) FILTER (WHERE v.month = b.prev_m) AS cont_prev,
            count(*) FILTER (WHERE v.month = b.ly_m) AS cont_ly,
            ( SELECT b_1.cur_m
                   FROM b b_1) AS mes
           FROM v_wh_containers_monthly v,
            b
          WHERE v.trade_dir = 'IMPORT'::text AND upper(v.status) ~~ 'UNLOADED%'::text AND v.import_client IS NOT NULL
          GROUP BY v.import_client, b.cur_m, b.prev_m, b.ly_m
        )
 SELECT cliente,
    cont_cur,
    cont_prev,
    cont_ly,
    mes,
    round((cont_cur - cont_prev)::numeric / NULLIF(cont_prev, 0)::numeric * 100::numeric, 0) AS mom_pct,
    round((cont_cur - cont_ly)::numeric / NULLIF(cont_ly, 0)::numeric * 100::numeric, 0) AS yoy_pct,
        CASE
            WHEN cont_cur = 0 AND cont_prev = 0 AND cont_ly = 0 THEN 'SIN ACTIVIDAD'::text
            WHEN cont_cur = 0 AND (cont_prev > 0 OR cont_ly > 0) THEN 'DORMIDO'::text
            WHEN cont_prev = 0 AND cont_ly = 0 AND cont_cur > 0 THEN 'NUEVO'::text
            WHEN cont_cur::numeric >= (cont_prev::numeric * 1.2) AND cont_cur >= cont_ly THEN 'CRECIENDO'::text
            WHEN cont_cur::numeric < (cont_prev::numeric * 0.8) AND cont_cur::numeric < (cont_ly::numeric * 0.8) THEN 'ALERTA REAL'::text
            WHEN cont_cur::numeric < (cont_prev::numeric * 0.8) AND cont_cur::numeric >= (cont_ly::numeric * 0.8) THEN 'ESTACIONAL'::text
            ELSE 'ESTABLE'::text
        END AS estado
   FROM agg;

CREATE OR REPLACE VIEW public.v_wh_metrics AS
SELECT grain,
    period,
    trade_dir,
    dim_type,
    dim_value,
    wrs,
    pieces,
    weight_lb,
    cbm
   FROM mv_wh_metrics;

CREATE OR REPLACE VIEW public.v_wh_metrics_compare AS
SELECT m.grain,
    m.period,
    m.trade_dir,
    m.dim_type,
    m.dim_value,
    m.wrs,
    m.pieces,
    m.weight_lb,
    m.cbm,
    lag(m.wrs) OVER w AS wrs_prev,
    lag(m.weight_lb) OVER w AS weight_lb_prev,
    lag(m.cbm) OVER w AS cbm_prev,
    ly.wrs AS wrs_ly,
    ly.weight_lb AS weight_lb_ly,
    ly.cbm AS cbm_ly,
    round((m.cbm - ly.cbm) / NULLIF(ly.cbm, 0::numeric) * 100::numeric, 1) AS cbm_yoy_pct,
    round((m.wrs - ly.wrs)::numeric / NULLIF(ly.wrs, 0)::numeric * 100::numeric, 1) AS wrs_yoy_pct
   FROM mv_wh_metrics m
     LEFT JOIN mv_wh_metrics ly ON ly.grain = m.grain AND ly.trade_dir = m.trade_dir AND ly.dim_type = m.dim_type AND ly.dim_value = m.dim_value AND ly.period = (m.period - '1 year'::interval)::date
  WINDOW w AS (PARTITION BY m.grain, m.trade_dir, m.dim_type, m.dim_value ORDER BY m.period);

CREATE OR REPLACE VIEW public.v_wh_no_identificada_cobro AS
SELECT COALESCE(NULLIF(TRIM(BOTH FROM consignee_final), ''::text), NULLIF(TRIM(BOTH FROM consignee_inicial), ''::text), '(sin identificar)'::text) AS responsable,
    COALESCE(NULLIF(TRIM(BOTH FROM shipper), ''::text), '(sin shipper)'::text) AS shipper,
    tipo,
    count(*) AS veces,
    count(*) FILTER (WHERE estado = 'SIN_IDENTIFICAR'::text) AS aun_sin_identificar,
    count(*) FILTER (WHERE estado = 'IDENTIFICADA'::text) AS ya_identificadas,
    round(avg(dias_para_identificar) FILTER (WHERE estado = 'IDENTIFICADA'::text), 1) AS dias_promedio,
    round(max(dias_para_identificar), 1) AS dias_peor_caso,
    sum(piezas) AS piezas,
    round(sum(COALESCE(volumen_cft, 0::numeric) * 0.0283168), 2) AS cbm,
    count(*) FILTER (WHERE cobrable AND NOT facturado) AS pendientes_de_cobro,
    round(sum(cargo_usd) FILTER (WHERE cobrable AND NOT facturado), 2) AS usd_por_cobrar,
    min(entry_date) AS desde,
    max(entry_date) AS hasta
   FROM wh_carga_no_identificada r
  WHERE estado <> 'IMPORTACION'::text
  GROUP BY (COALESCE(NULLIF(TRIM(BOTH FROM consignee_final), ''::text), NULLIF(TRIM(BOTH FROM consignee_inicial), ''::text), '(sin identificar)'::text)), (COALESCE(NULLIF(TRIM(BOTH FROM shipper), ''::text), '(sin shipper)'::text)), tipo
  ORDER BY (count(*)) DESC, (sum(COALESCE(volumen_cft, 0::numeric))) DESC;

CREATE OR REPLACE VIEW public.v_wh_paqueteria_weekly AS
SELECT date_trunc('week'::text, wr.created_on::timestamp with time zone)::date AS week_start,
        CASE
            WHEN wr.created_by = 'Parcel_OCR'::text THEN 'OCR (auto)'::text
            ELSE wr.created_by
        END AS lane,
    count(*) AS wrs,
    sum(wr.pieces) AS piezas,
    count(DISTINCT wr.created_on) AS dias
   FROM magaya_warehouse_receipts wr
     JOIN wh_stations st ON wr.created_by ~~* st.person_pattern AND st.role = 'paqueteria'::text
  WHERE wr.created_on <= CURRENT_DATE AND EXTRACT(dow FROM wr.created_on) >= 1::numeric AND EXTRACT(dow FROM wr.created_on) <= 5::numeric
  GROUP BY (date_trunc('week'::text, wr.created_on::timestamp with time zone)::date), (
        CASE
            WHEN wr.created_by = 'Parcel_OCR'::text THEN 'OCR (auto)'::text
            ELSE wr.created_by
        END);

CREATE OR REPLACE VIEW public.v_wh_receipts AS
SELECT wr.wr_number,
    wr.created_on,
    date_trunc('week'::text, wr.created_on::timestamp with time zone)::date AS week_start,
    date_trunc('month'::text, wr.created_on::timestamp with time zone)::date AS month_start,
    date_trunc('year'::text, wr.created_on::timestamp with time zone)::date AS year_start,
    wr.status,
    COALESCE(NULLIF(btrim(wr.destination_agent), ''::text), '(sin agente)'::text) AS destination_agent,
    COALESCE(NULLIF(btrim(wr.issued_by), ''::text), '(sin issued_by)'::text) AS issued_by,
    COALESCE(NULLIF(btrim(wr.consignee), ''::text), '(sin consignee)'::text) AS consignee,
    COALESCE(NULLIF(btrim(wr.shipper), ''::text), '(sin shipper)'::text) AS shipper,
        CASE
            WHEN wr.destination_agent = 'GLOVAL SHIPPING USA (INBOUND)'::text OR ic.client_group IS NOT NULL THEN 'IMPORT'::text
            ELSE 'EXPORT'::text
        END AS trade_dir,
        CASE
            WHEN ic.client_group IS NOT NULL THEN ic.client_group
            WHEN wr.destination_agent = 'GLOVAL SHIPPING USA (INBOUND)'::text THEN '(consolidado / otro)'::text
            ELSE '(n/a)'::text
        END AS import_client,
    COALESCE(wr.pieces, 0) AS pieces,
    COALESCE(wr.weight, 0::numeric) AS weight_lb,
    COALESCE(wr.cbm, 0::numeric) AS cbm
   FROM magaya_warehouse_receipts wr
     LEFT JOIN LATERAL ( SELECT c.client_group
           FROM wh_import_clients c
          WHERE c.active AND (wr.consignee ~~* c.match_pattern OR wr.shipper ~~* c.match_pattern)
         LIMIT 1) ic ON true
  WHERE wr.created_on IS NOT NULL AND wr.created_on <= CURRENT_DATE;

CREATE OR REPLACE VIEW public.v_wh_station_daily AS
SELECT wr.created_on AS dia,
    st.station,
    st.person_pattern AS persona,
    count(*) AS wrs,
    sum(wr.pieces) AS piezas
   FROM magaya_warehouse_receipts wr
     JOIN wh_stations st ON wr.created_by ~~* st.person_pattern AND st.role = 'pallet_expo'::text
  WHERE wr.created_on <= CURRENT_DATE AND EXTRACT(dow FROM wr.created_on) >= 1::numeric AND EXTRACT(dow FROM wr.created_on) <= 5::numeric
  GROUP BY wr.created_on, st.station, st.person_pattern;

CREATE OR REPLACE VIEW public.v_wh_station_weekly AS
SELECT date_trunc('week'::text, wr.created_on::timestamp with time zone)::date AS week_start,
    st.station,
    st.person_pattern AS persona,
    count(*) AS wrs,
    sum(wr.pieces) AS piezas,
    count(DISTINCT wr.created_on) AS dias,
    round(sum(wr.pieces)::numeric / NULLIF(count(DISTINCT wr.created_on), 0)::numeric) AS piezas_x_dia
   FROM magaya_warehouse_receipts wr
     JOIN wh_stations st ON wr.created_by ~~* st.person_pattern AND st.role = 'pallet_expo'::text
  WHERE wr.created_on <= CURRENT_DATE AND EXTRACT(dow FROM wr.created_on) >= 1::numeric AND EXTRACT(dow FROM wr.created_on) <= 5::numeric
  GROUP BY (date_trunc('week'::text, wr.created_on::timestamp with time zone)::date), st.station, st.person_pattern;

CREATE OR REPLACE VIEW public.v_wh_storage_aging AS
WITH b AS (
         SELECT w.wr_number,
            w.consignee,
            w.shipper,
            COALESCE(w.entry_date, w.created_on) AS entrada,
            CURRENT_DATE - COALESCE(w.entry_date, w.created_on) AS dias,
            wh_dias_libres(w.consignee) AS dias_libres,
                CASE
                    WHEN COALESCE(s.items_con_estado, 0::bigint) > 0 THEN s.piezas_onhand::integer
                    ELSE w.pieces
                END AS pieces,
                CASE
                    WHEN COALESCE(s.items_con_estado, 0::bigint) > 0 THEN COALESCE(s.peso_onhand_lb, w.weight * s.piezas_onhand::numeric / NULLIF(w.pieces, 0)::numeric)
                    ELSE w.weight
                END AS weight,
            w.warehouse_zone,
            w.location_code,
            w.last_full_fetch_at,
            COALESCE(s.items_con_estado, 0::bigint) > 0 AND COALESCE(s.piezas_fuera, 0::bigint) > 0 AND COALESCE(s.piezas_onhand, 0::bigint) > 0 AS es_parcial,
            w.pieces AS piezas_recibo
           FROM magaya_warehouse_receipts w
             LEFT JOIN v_wh_wr_saldo s ON s.wr_number = w.wr_number
          WHERE
                CASE
                    WHEN COALESCE(s.items_con_estado, 0::bigint) > 0 THEN COALESCE(s.piezas_onhand, 0::bigint) > 0
                    ELSE w.out_date IS NULL AND w.status = 'OnHand'::text
                END AND w.last_full_fetch_at >= (now() - '7 days'::interval) AND COALESCE(w.entry_date, w.created_on) >= (CURRENT_DATE - 180) AND w.consignee !~~* '%gloval%'::text
        )
 SELECT wr_number,
    consignee,
    shipper,
    entrada,
    dias,
        CASE
            WHEN dias >= dias_libres THEN 'VENCIDO'::text
            WHEN dias >= (dias_libres - 7) THEN 'POR_VENCER'::text
            ELSE 'ATENCION'::text
        END AS nivel,
    pieces,
    weight,
    warehouse_zone,
    location_code,
    last_full_fetch_at,
    ( SELECT c.cs_email
           FROM client_notify_contacts c
          WHERE c.cs_email IS NOT NULL AND length(split_part(upper(c.consignee_hint), ' ('::text, 1)) >= 3 AND upper(b.consignee) ~~ (('%'::text || split_part(upper(c.consignee_hint), ' ('::text, 1)) || '%'::text)
         LIMIT 1) AS cs_email,
    es_parcial,
    piezas_recibo,
    dias_libres
   FROM b
  WHERE dias >= (dias_libres - 15);

CREATE OR REPLACE VIEW public.v_wh_unidentified_cargo AS
WITH u AS (
         SELECT wr.wr_number,
            wr.created_on,
            wr.created_by,
            wr.shipper,
            wr.consignee,
            wr.destination_port,
            wr.pieces,
            wr.tracking_number,
            wr.consignee IS NULL OR btrim(wr.consignee) = ''::text OR wr.consignee ~~* '%as agent%'::text OR wr.consignee ~~* '%(inbound)%'::text OR wr.consignee ~~* 'desconocido%'::text AS cons_blank
           FROM magaya_warehouse_receipts wr
          WHERE wr.destination_agent ~~* 'Gloval Shipping USA as Agent'::text AND wr.created_on <= CURRENT_DATE
        )
 SELECT u.wr_number,
    u.created_on,
    u.created_by AS recibido_por,
    u.shipper,
    u.consignee,
    NULLIF(btrim(u.destination_port), ''::text) AS destino_puerto,
    u.pieces,
    u.tracking_number,
    ip.office AS interno_office,
    COALESCE(ip.suggested_agent, ca.usual_agent) AS agente_sugerido,
        CASE
            WHEN NOT u.cons_blank THEN u.consignee
            ELSE sc.top_consignee
        END AS dueno_sugerido,
        CASE
            WHEN u.cons_blank AND sc.top_consignee IS NOT NULL THEN 'REVISAR DOCS · shipper suele ir a: '::text || sc.top_consignee
            WHEN u.cons_blank THEN 'REVISAR DOCS — sin pistas'::text
            WHEN ip.suggested_agent IS NOT NULL THEN 'CORREGIR AGENTE → '::text || ip.suggested_agent
            WHEN ip.office IS NOT NULL THEN ('MAL CONSIGNADO (interno '::text || ip.office) || ') — revisar docs'::text
            WHEN ca.usual_agent IS NOT NULL THEN 'CORREGIR AGENTE → '::text || ca.usual_agent
            WHEN u.created_by = 'Parcel_OCR'::text OR COALESCE(u.pieces, 0) <= 1 THEN 'CASILLERO — revisar consignee'::text
            ELSE 'REVISAR'::text
        END AS accion,
        CASE
            WHEN ip.suggested_agent IS NOT NULL OR NOT u.cons_blank AND ca.usual_agent IS NOT NULL THEN 'ALTA'::text
            WHEN u.cons_blank AND sc.top_consignee IS NULL THEN 'BAJA'::text
            ELSE 'MEDIA'::text
        END AS confianza
   FROM u
     LEFT JOIN LATERAL ( SELECT p.office,
            p.suggested_agent
           FROM wh_internal_people p
          WHERE u.consignee ~~* p.name_pattern
         LIMIT 1) ip ON true
     LEFT JOIN mv_consignee_top_agent ca ON ca.consignee = u.consignee AND NOT u.cons_blank
     LEFT JOIN mv_shipper_top_consignee sc ON sc.shipper = u.shipper;

CREATE OR REPLACE VIEW public.v_wh_wr_saldo AS
WITH agg AS (
         SELECT i.wr_number,
            count(*) AS items_total,
            count(*) FILTER (WHERE i.status IS NOT NULL) AS items_con_estado,
            COALESCE(sum(i.pieces) FILTER (WHERE i.status = 'OnHand'::text), 0::bigint) AS piezas_onhand,
            sum(i.peso_lb) FILTER (WHERE i.status = 'OnHand'::text) AS peso_onhand_lb,
            sum(i.vol_cft) FILTER (WHERE i.status = 'OnHand'::text) AS vol_onhand_cft,
            count(*) FILTER (WHERE i.status = 'OnHand'::text AND i.peso_lb IS NULL) AS onhand_sin_unidad,
            COALESCE(sum(i.pieces) FILTER (WHERE i.status = ANY (ARRAY['Loaded'::text, 'InTransit'::text, 'AtDestination'::text, 'Delivered'::text])), 0::bigint) AS piezas_fuera,
            COALESCE(sum(i.pieces) FILTER (WHERE i.status = ANY (ARRAY['Pending'::text, 'Arriving'::text])), 0::bigint) AS piezas_por_llegar,
            COALESCE(sum(i.pieces) FILTER (WHERE i.status IS NOT NULL AND (i.status <> ALL (ARRAY['OnHand'::text, 'Loaded'::text, 'InTransit'::text, 'AtDestination'::text, 'Delivered'::text, 'Pending'::text, 'Arriving'::text]))), 0::bigint) AS piezas_estado_raro,
            COALESCE(sum(i.pieces), 0::bigint) AS piezas_items,
            max(i.last_full_fetch_at) AS items_frescos_al
           FROM magaya_wr_items i
          GROUP BY i.wr_number
        )
 SELECT w.wr_number,
    w.guid,
    w.consignee,
    w.consignee_normalized,
    w.shipper,
    w.destination_agent,
    w.warehouse_zone,
    w.location_code,
    w.entry_date,
    w.created_on,
    w.out_date,
    w.cargo_release_number,
    w.status AS status_cabecera,
    w.pieces AS piezas_cabecera,
    w.weight AS peso_cabecera,
    w.volume_cft AS vol_cabecera,
    COALESCE(a.items_total, 0::bigint) AS items_total,
    COALESCE(a.items_con_estado, 0::bigint) AS items_con_estado,
    COALESCE(a.piezas_onhand, 0::bigint) AS piezas_onhand,
    a.peso_onhand_lb,
    a.vol_onhand_cft,
    COALESCE(a.piezas_fuera, 0::bigint) AS piezas_fuera,
    COALESCE(a.piezas_por_llegar, 0::bigint) AS piezas_por_llegar,
    COALESCE(a.piezas_estado_raro, 0::bigint) AS piezas_estado_raro,
    COALESCE(a.onhand_sin_unidad, 0::bigint) AS onhand_sin_unidad,
    a.items_frescos_al,
        CASE
            WHEN COALESCE(a.items_con_estado, 0::bigint) = 0 THEN 'SIN_DETALLE'::text
            WHEN COALESCE(a.piezas_onhand, 0::bigint) > 0 AND COALESCE(a.piezas_fuera, 0::bigint) > 0 THEN 'PARCIAL'::text
            WHEN COALESCE(a.piezas_onhand, 0::bigint) > 0 THEN 'EN_BODEGA'::text
            WHEN COALESCE(a.piezas_fuera, 0::bigint) > 0 THEN 'EMBARCADO'::text
            WHEN COALESCE(a.piezas_por_llegar, 0::bigint) > 0 THEN 'POR_LLEGAR'::text
            ELSE 'SIN_CLASIFICAR'::text
        END AS estado_saldo,
        CASE
            WHEN COALESCE(a.items_con_estado, 0::bigint) = 0 THEN NULL::boolean
            ELSE COALESCE(a.piezas_onhand, 0::bigint) > 0
        END AS tiene_saldo,
    COALESCE(a.piezas_items, 0::bigint) = COALESCE(w.pieces, 0) AND COALESCE(a.onhand_sin_unidad, 0::bigint) = 0 AND COALESCE(a.piezas_estado_raro, 0::bigint) = 0 AS cifras_confiables,
    COALESCE(a.piezas_items, 0::bigint) = COALESCE(w.pieces, 0) AS cuadra_piezas,
    CURRENT_DATE - COALESCE(w.entry_date, w.created_on) AS dias_en_bodega
   FROM magaya_warehouse_receipts w
     LEFT JOIN agg a ON a.wr_number = w.wr_number;

CREATE OR REPLACE VIEW public.v_wr_inbox AS
SELECT r.id AS match_id,
    r.status,
    w.status AS wr_status,
    w.issued_by,
    r.office AS wr_office,
    r.match_score,
    r.match_reason,
    r.candidates,
    r.matched_client_id,
    r.matched_shipment_id,
    w.id AS wr_id,
    w.wr_number,
    w.guid,
    w.consignee,
    w.shipper,
    w.carrier,
    w.tracking_number,
    w.origin,
    w.destination,
    w.destination_port,
    w.destination_agent,
    w.billing_client,
    w.pieces,
    w.weight,
    w.volume_cbm,
    w.volume_cft,
    w.etd,
    w.eta,
    w.created_on,
    w.created_by AS wr_created_by,
    w.synced_at,
    w.created_at AS wr_created_at,
    w.notes,
    w.entry_date,
    w.out_date,
    w.warehouse_zone,
    w.location_code,
    w.has_attachments,
    w.total_value,
    w.chargeable_weight,
    w.volume_weight,
    w.weight_unit,
    w.volume_unit,
    w.length_unit,
    w.measurement_units,
    w.carrier_pro_number,
    w.scac_number,
    w.cargo_release_number,
    w.custom_fields,
    w.last_full_fetch_at,
    c.company_name AS matched_client_name,
    c.office AS matched_client_office,
    c.assigned_to AS matched_client_assigned_to,
    c.ruc AS matched_client_ruc,
    u.name AS matched_sales_executive,
    u.email AS matched_sales_exec_email,
    ( SELECT jsonb_agg(jsonb_build_object('description', i.description, 'item_description', i.item_description, 'item_code', i.item_code, 'part_number', i.part_number, 'pieces', i.pieces, 'quantity', i.quantity, 'weight', i.weight, 'volume_cbm', i.volume_cbm, 'length', i.length, 'width', i.width, 'height', i.height, 'piece_volume', i.piece_volume, 'piece_weight', i.piece_weight, 'package_name', i.package_name, 'is_pallet', i.is_pallet, 'item_type', i.item_type, 'supplier', i.supplier, 'notes', i.notes, 'warehouse_zone', i.warehouse_zone, 'container_number', i.container_number, 'status', i.status, 'whr_item_id', i.whr_item_id, 'location_code', i.location_code) ORDER BY i.id) AS jsonb_agg
           FROM magaya_wr_items i
          WHERE i.wr_id = w.id) AS items,
    ( SELECT count(*) AS count
           FROM magaya_wr_attachments a
          WHERE a.wr_id = w.id) AS attachment_count,
    ( SELECT count(*) AS count
           FROM magaya_wr_attachments a
          WHERE a.wr_id = w.id AND a.is_photo) AS photo_count,
    r.created_at,
    r.updated_at,
    COALESCE(s.items_con_estado, 0::bigint) AS items_con_estado,
    COALESCE(s.piezas_onhand, 0::bigint) AS piezas_onhand,
    COALESCE(s.piezas_fuera, 0::bigint) AS piezas_fuera,
    s.peso_onhand_lb,
    s.vol_onhand_cft,
    COALESCE(s.onhand_sin_unidad, 0::bigint) AS onhand_sin_unidad,
        CASE
            WHEN COALESCE(s.items_con_estado, 0::bigint) = 0 THEN 'SIN_DETALLE'::text
            WHEN COALESCE(s.piezas_onhand, 0::bigint) > 0 AND COALESCE(s.piezas_fuera, 0::bigint) > 0 THEN 'PARCIAL'::text
            WHEN COALESCE(s.piezas_onhand, 0::bigint) > 0 THEN 'EN_BODEGA'::text
            WHEN COALESCE(s.piezas_fuera, 0::bigint) > 0 THEN 'EMBARCADO'::text
            WHEN COALESCE(s.piezas_por_llegar, 0::bigint) > 0 THEN 'POR_LLEGAR'::text
            ELSE 'SIN_CLASIFICAR'::text
        END AS estado_saldo,
        CASE
            WHEN COALESCE(s.items_con_estado, 0::bigint) = 0 THEN w.status = 'OnHand'::text
            ELSE COALESCE(s.piezas_onhand, 0::bigint) > 0
        END AS en_bodega,
    COALESCE(s.piezas_items, 0::bigint) = COALESCE(w.pieces, 0) AND COALESCE(s.onhand_sin_unidad, 0::bigint) = 0 AND COALESCE(s.piezas_estado_raro, 0::bigint) = 0 AS cifras_confiables
   FROM wr_match_results r
     JOIN magaya_warehouse_receipts w ON w.id = r.wr_id
     LEFT JOIN clients c ON c.id = r.matched_client_id
     LEFT JOIN users u ON u.id = c.assigned_to
     LEFT JOIN LATERAL ( SELECT count(*) FILTER (WHERE i.status IS NOT NULL) AS items_con_estado,
            COALESCE(sum(i.pieces) FILTER (WHERE i.status = 'OnHand'::text), 0::bigint) AS piezas_onhand,
            sum(i.peso_lb) FILTER (WHERE i.status = 'OnHand'::text) AS peso_onhand_lb,
            sum(i.vol_cft) FILTER (WHERE i.status = 'OnHand'::text) AS vol_onhand_cft,
            count(*) FILTER (WHERE i.status = 'OnHand'::text AND i.peso_lb IS NULL) AS onhand_sin_unidad,
            COALESCE(sum(i.pieces) FILTER (WHERE i.status = ANY (ARRAY['Loaded'::text, 'InTransit'::text, 'AtDestination'::text, 'Delivered'::text])), 0::bigint) AS piezas_fuera,
            COALESCE(sum(i.pieces) FILTER (WHERE i.status = ANY (ARRAY['Pending'::text, 'Arriving'::text])), 0::bigint) AS piezas_por_llegar,
            COALESCE(sum(i.pieces) FILTER (WHERE i.status IS NOT NULL AND (i.status <> ALL (ARRAY['OnHand'::text, 'Loaded'::text, 'InTransit'::text, 'AtDestination'::text, 'Delivered'::text, 'Pending'::text, 'Arriving'::text]))), 0::bigint) AS piezas_estado_raro,
            COALESCE(sum(i.pieces), 0::bigint) AS piezas_items
           FROM magaya_wr_items i
          WHERE i.wr_id = w.id) s ON true
  WHERE wr_is_gloval_usa(w.issued_by);

CREATE OR REPLACE VIEW public.v_wr_sync_huecos AS
WITH rango AS (
         SELECT min(magaya_warehouse_receipts.wr_number::integer) FILTER (WHERE magaya_warehouse_receipts.created_on >= (CURRENT_DATE - 60)) AS desde,
            max(magaya_warehouse_receipts.wr_number::integer) FILTER (WHERE magaya_warehouse_receipts.created_on >= (CURRENT_DATE - 120)) AS hasta
           FROM magaya_warehouse_receipts
          WHERE magaya_warehouse_receipts.wr_number ~ '^[0-9]{6,7}$'::text
        )
 SELECT g.g::text AS wr_number,
        CASE
            WHEN q.wr_number IS NULL THEN 'SIN_ENCOLAR'::text
            WHEN q.error ~~* '%not found%'::text AND q.intentos >= 3 THEN 'NO_EXISTE_EN_MAGAYA'::text
            WHEN q.intentos >= 3 THEN 'FALLANDO'::text
            ELSE 'EN_COLA'::text
        END AS estado,
    q.intentos,
    q.ultimo_intento_at,
    q.error
   FROM rango r
     CROSS JOIN LATERAL generate_series(r.desde, r.hasta - 2) g(g)
     LEFT JOIN wr_saldo_queue q ON q.wr_number = g.g::text
  WHERE NOT (EXISTS ( SELECT 1
           FROM magaya_warehouse_receipts w
          WHERE w.wr_number = g.g::text));
