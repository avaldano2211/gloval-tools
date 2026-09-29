-- Vistas materializadas
-- Origen: Supabase GES (wfzdrqfurwnakrfdnbgf), esquemas public, archive, private, timeclock.
-- Extraído del catálogo el 2026-09-29 (solo lectura). Referencia: NO ejecutar en Azure.
-- Credenciales redactadas como <SUPABASE_*>.

CREATE MATERIALIZED VIEW public.mi_mv_carrier_share AS
SELECT i.period_year,
    i.period_quarter,
    i.modality,
    cc.id AS carrier_canonical_id,
    cc.canonical_name AS carrier_name,
    i.country_arrival_dep AS origin_country,
    i.country_origin_destination AS final_origin_country,
    count(*) AS bls,
    sum(COALESCE(i.teus_fcl, 0::numeric)) AS teus_fcl,
    sum(COALESCE(i.kilos_brutos, 0::numeric)) AS kilos
   FROM mi_shipment_intel i
     LEFT JOIN mi_canonical_actor cc ON cc.id = i.carrier_canonical_id
  WHERE cc.id IS NOT NULL AND mi_is_real_cargo(i.producto_pmc)
  GROUP BY i.period_year, i.period_quarter, i.modality, cc.id, cc.canonical_name, i.country_arrival_dep, i.country_origin_destination
WITH NO DATA;

CREATE MATERIALIZED VIEW public.mi_mv_client_period_summary AS
SELECT i.period_year,
    i.period_month,
    i.modality,
    i.port_ec,
    i.incoterm,
    i.client_id,
    COALESCE(i.ec_company_id, ''::text) AS ec_company_id,
    i.forwarder_canonical_id,
    fc.canonical_name AS forwarder_name,
    fc.is_gloval AS forwarder_is_gloval,
    fc.is_direct_bucket AS forwarder_is_direct_bucket,
    count(*) AS bls,
    sum(COALESCE(i.teus_fcl, 0::numeric)) AS teus_fcl,
    sum(COALESCE(i.teus_lcl, 0::numeric)) AS teus_lcl,
    sum(COALESCE(i.kilos_brutos, 0::numeric)) AS kilos,
    sum(COALESCE(i.num_bultos, 0::numeric)) AS bultos,
    sum(COALESCE(i.valor_comercial, 0::numeric)) AS valor_comercial
   FROM mi_shipment_intel i
     LEFT JOIN mi_canonical_actor fc ON fc.id = i.forwarder_canonical_id
  WHERE mi_is_real_cargo(i.producto_pmc)
  GROUP BY i.period_year, i.period_month, i.modality, i.port_ec, i.incoterm, i.client_id, (COALESCE(i.ec_company_id, ''::text)), i.forwarder_canonical_id, fc.canonical_name, fc.is_gloval, fc.is_direct_bucket
WITH NO DATA;

CREATE MATERIALIZED VIEW public.mi_mv_company_profile AS
SELECT COALESCE(i.client_id::text, i.ec_company_id) AS counter_id,
    max(i.ec_company_id) AS ec_company_id,
    bool_or(i.client_id IS NOT NULL) AS in_crm,
    max(cl.assigned_to::text) AS assigned_to,
    max(COALESCE(cl.company_name, i.ec_company_name)) AS name,
    mode() WITHIN GROUP (ORDER BY i.ec_vertical) AS vertical,
    max(i.ec_provincia) AS provincia,
    max(i.ec_canton) AS canton,
    array_agg(DISTINCT i.foreign_country) FILTER (WHERE i.foreign_country IS NOT NULL) AS countries,
    array_agg(DISTINCT i.producto_generico) FILTER (WHERE i.producto_generico IS NOT NULL) AS products,
    count(*) AS bls,
    sum(COALESCE(i.teus_fcl, 0::numeric) + COALESCE(i.teus_lcl, 0::numeric)) AS teus,
    sum(COALESCE(i.kilos_brutos, 0::numeric)) AS kilos,
    sum(COALESCE(i.valor_comercial, 0::numeric)) AS valor,
    count(*) FILTER (WHERE i.modality = ANY (ARRAY['SI'::mi_modality_t, 'AI'::mi_modality_t])) AS bls_import,
    count(*) FILTER (WHERE i.modality = ANY (ARRAY['SE'::mi_modality_t, 'AE'::mi_modality_t])) AS bls_export
   FROM mi_shipment_intel i
     LEFT JOIN clients cl ON cl.id = i.client_id
  WHERE i.ec_company_id IS NOT NULL AND mi_is_real_cargo(i.producto_pmc)
  GROUP BY (COALESCE(i.client_id::text, i.ec_company_id))
WITH NO DATA;

CREATE MATERIALIZED VIEW public.mi_mv_courier_company AS
SELECT period_year,
    period_month,
    modality,
    port_ec,
    country_arrival_dep AS country,
    liberador_raw_norm,
    min(liberador_raw) AS liberador_name,
    min(ec_company_id) AS ec_company_id,
    ec_company_id_norm,
    min(ec_company_name) AS ec_company_name,
    min(ec_provincia) AS ec_provincia,
    count(*) AS shipments,
    sum(COALESCE(kilos_brutos, 0::numeric)) AS kilos,
    sum(COALESCE(valor_comercial, 0::numeric)) AS valor
   FROM mi_courier_shipment
  WHERE ec_company_id_norm IS NOT NULL
  GROUP BY period_year, period_month, modality, port_ec, country_arrival_dep, liberador_raw_norm, ec_company_id_norm
WITH NO DATA;

CREATE MATERIALIZED VIEW public.mi_mv_courier_country AS
SELECT period_year,
    period_month,
    modality,
    port_ec,
    country_arrival_dep AS country,
    count(*) AS shipments,
    sum(COALESCE(kilos_brutos, 0::numeric)) AS kilos,
    sum(COALESCE(valor_comercial, 0::numeric)) AS valor,
    count(DISTINCT liberador_raw_norm) AS liberadores
   FROM mi_courier_shipment
  WHERE country_arrival_dep IS NOT NULL
  GROUP BY period_year, period_month, modality, port_ec, country_arrival_dep
WITH NO DATA;

CREATE MATERIALIZED VIEW public.mi_mv_courier_liberador AS
SELECT period_year,
    period_month,
    modality,
    port_ec,
    country_arrival_dep AS country,
    liberador_raw AS liberador_name,
    liberador_raw_norm,
    count(*) AS shipments,
    sum(COALESCE(kilos_brutos, 0::numeric)) AS kilos,
    sum(COALESCE(valor_comercial, 0::numeric)) AS valor,
    count(DISTINCT ec_company_id_norm) FILTER (WHERE ec_company_id_norm IS NOT NULL) AS empresas
   FROM mi_courier_shipment
  WHERE liberador_raw_norm IS NOT NULL
  GROUP BY period_year, period_month, modality, port_ec, country_arrival_dep, liberador_raw, liberador_raw_norm
WITH NO DATA;

CREATE MATERIALIZED VIEW public.mi_mv_courier_summary AS
SELECT period_year,
    period_month,
    modality,
    port_ec,
    country_arrival_dep AS country,
    count(*) AS shipments,
    sum(COALESCE(kilos_brutos, 0::numeric)) AS total_kilos,
    sum(COALESCE(num_bultos, 0::numeric)) AS total_bultos,
    sum(COALESCE(valor_comercial, 0::numeric)) AS total_valor,
    count(DISTINCT liberador_raw) AS distinct_liberadores,
    count(DISTINCT ec_company_id_norm) FILTER (WHERE ec_company_id_norm IS NOT NULL) AS distinct_empresas
   FROM mi_courier_shipment
  GROUP BY period_year, period_month, modality, port_ec, country_arrival_dep
WITH NO DATA;

CREATE MATERIALIZED VIEW public.mi_mv_direct_cargo_prospects AS
SELECT i.period_year,
    i.period_month,
    i.modality,
    i.ec_company_id,
    cc.id AS carrier_canonical_id,
    max(i.ec_company_name) AS ec_company_name,
    max(i.ec_provincia) AS ec_provincia,
    max(i.ec_canton) AS ec_canton,
    max(i.ec_vertical) AS ec_vertical,
    max(i.ec_ciiu) AS ec_ciiu,
    max(i.country_arrival_dep) AS origin_country,
    max(cc.canonical_name) AS carrier_name,
    bool_or(i.client_id IS NOT NULL) AS is_in_crm,
    (array_agg(i.client_id) FILTER (WHERE i.client_id IS NOT NULL))[1] AS client_id,
    count(*) AS bls,
    sum(COALESCE(i.teus_fcl, 0::numeric)) AS teus_fcl,
    sum(COALESCE(i.teus_lcl, 0::numeric)) AS teus_lcl,
    sum(COALESCE(i.kilos_brutos, 0::numeric)) AS kilos,
    sum(COALESCE(i.valor_comercial, 0::numeric)) AS valor_comercial
   FROM mi_shipment_intel i
     LEFT JOIN mi_canonical_actor cc ON cc.id = i.carrier_canonical_id
  WHERE i.is_direct_no_forwarder = true AND i.ec_company_id IS NOT NULL AND mi_is_real_cargo(i.producto_pmc)
  GROUP BY i.period_year, i.period_month, i.modality, i.ec_company_id, cc.id
WITH NO DATA;

CREATE MATERIALIZED VIEW public.mi_mv_foreign_agents AS
WITH base AS (
         SELECT i.partner_canonical_id,
            i.foreign_country,
            i.origin_partner_type,
            i.origin_partner_office,
            i.client_id,
            i.ec_company_id,
            i.forwarder_canonical_id,
            i.port_ec,
            i.teus_fcl,
            i.teus_lcl,
            i.kilos_brutos,
            pac.canonical_name AS partner_name,
            COALESCE(fcc.is_gloval, false) AS forwarder_is_gloval
           FROM mi_shipment_intel i
             LEFT JOIN mi_canonical_actor pac ON pac.id = i.partner_canonical_id
             LEFT JOIN mi_canonical_actor fcc ON fcc.id = i.forwarder_canonical_id
          WHERE i.partner_canonical_id IS NOT NULL AND mi_is_real_cargo(i.producto_pmc)
        )
 SELECT partner_canonical_id,
    max(partner_name) AS partner_name,
    mode() WITHIN GROUP (ORDER BY foreign_country) AS origin_country,
    mode() WITHIN GROUP (ORDER BY b.origin_partner_type) AS origin_partner_type,
    mode() WITHIN GROUP (ORDER BY b.origin_partner_office) AS origin_partner_office,
    count(*) AS bls,
    sum(COALESCE(teus_fcl, 0::numeric)) AS teus_fcl,
    sum(COALESCE(teus_lcl, 0::numeric)) AS teus_lcl,
    sum(COALESCE(kilos_brutos, 0::numeric)) AS kilos,
    count(DISTINCT COALESCE(client_id::text, ec_company_id)) FILTER (WHERE COALESCE(client_id::text, ec_company_id) IS NOT NULL) AS ec_counterparts_count,
    count(DISTINCT client_id) FILTER (WHERE client_id IS NOT NULL) AS crm_clients_count,
    count(DISTINCT ec_company_id) FILTER (WHERE client_id IS NULL AND ec_company_id IS NOT NULL) AS prospects_count,
    count(DISTINCT forwarder_canonical_id) FILTER (WHERE forwarder_canonical_id IS NOT NULL) AS ec_forwarders_count,
    count(*) FILTER (WHERE forwarder_is_gloval) AS bls_via_gloval,
    array_agg(DISTINCT port_ec) FILTER (WHERE port_ec IS NOT NULL) AS ec_ports
   FROM base b
  GROUP BY partner_canonical_id
WITH NO DATA;

CREATE MATERIALIZED VIEW public.mi_mv_forwarder_commodity AS
SELECT i.period_year,
    i.period_quarter,
    i.modality,
    i.forwarder_canonical_id,
    fc.canonical_name AS forwarder_name,
    fc.is_gloval,
    i.producto_pmc,
    count(*) AS bls,
    sum(COALESCE(i.teus_fcl, 0::numeric)) AS teus_fcl,
    sum(COALESCE(i.kilos_brutos, 0::numeric)) AS kilos
   FROM mi_shipment_intel i
     JOIN mi_canonical_actor fc ON fc.id = i.forwarder_canonical_id
  WHERE COALESCE(fc.is_direct_bucket, false) = false AND mi_is_real_cargo(i.producto_pmc) AND i.producto_pmc IS NOT NULL AND btrim(i.producto_pmc) <> ''::text
  GROUP BY i.period_year, i.period_quarter, i.modality, i.forwarder_canonical_id, fc.canonical_name, fc.is_gloval, i.producto_pmc
WITH NO DATA;

CREATE MATERIALIZED VIEW public.mi_mv_forwarder_detail AS
SELECT s.forwarder_canonical_id,
    s.period_year,
    s.period_quarter,
    s.period_month,
    s.modality::text AS modality,
    s.country_arrival_dep AS country,
    s.port_origin_destination AS port,
    ca.canonical_name AS carrier_name,
    pa.canonical_name AS partner_name,
    s.ec_company_id,
    s.client_id,
    max(s.ec_company_name) AS ec_company_name,
    max(s.ec_provincia) AS ec_provincia,
    max(s.ec_vertical) AS ec_vertical,
    count(*)::integer AS bls,
    sum(COALESCE(s.teus_fcl, 0::numeric)) AS teus,
    sum(COALESCE(s.kilos_brutos, 0::numeric)) AS kilos,
    sum(COALESCE(s.valor_comercial, 0::numeric)) AS valor
   FROM mi_shipment_intel s
     LEFT JOIN mi_canonical_actor ca ON ca.id = s.carrier_canonical_id
     LEFT JOIN mi_canonical_actor pa ON pa.id = s.partner_canonical_id
  WHERE s.forwarder_canonical_id IS NOT NULL
  GROUP BY s.forwarder_canonical_id, s.period_year, s.period_quarter, s.period_month, (s.modality::text), s.country_arrival_dep, s.port_origin_destination, ca.canonical_name, pa.canonical_name, s.ec_company_id, s.client_id
  ORDER BY s.forwarder_canonical_id, s.period_year, s.period_month
WITH NO DATA;

CREATE MATERIALIZED VIEW public.mi_mv_forwarder_share AS
SELECT i.period_year,
    i.period_quarter,
    i.modality,
    fc.id AS forwarder_canonical_id,
    fc.canonical_name AS forwarder_name,
    fc.is_gloval,
    count(*) AS bls,
    sum(COALESCE(i.teus_fcl, 0::numeric)) AS teus_fcl,
    sum(COALESCE(i.teus_lcl, 0::numeric)) AS teus_lcl,
    sum(COALESCE(i.kilos_brutos, 0::numeric)) AS kilos
   FROM mi_shipment_intel i
     JOIN mi_canonical_actor fc ON fc.id = i.forwarder_canonical_id
  WHERE COALESCE(fc.is_direct_bucket, false) = false AND mi_is_real_cargo(i.producto_pmc)
  GROUP BY i.period_year, i.period_quarter, i.modality, fc.id, fc.canonical_name, fc.is_gloval
WITH NO DATA;

CREATE MATERIALIZED VIEW public.mi_mv_forwarder_share_geo AS
SELECT i.period_year,
    i.period_quarter,
    i.modality,
    i.country_arrival_dep AS origin_country,
    i.region_arrival_dep AS origin_region,
    fc.id AS forwarder_canonical_id,
    fc.canonical_name AS forwarder_name,
    fc.is_gloval,
    count(*) AS bls,
    sum(COALESCE(i.teus_fcl, 0::numeric)) AS teus_fcl,
    sum(COALESCE(i.teus_lcl, 0::numeric)) AS teus_lcl,
    sum(COALESCE(i.kilos_brutos, 0::numeric)) AS kilos
   FROM mi_shipment_intel i
     JOIN mi_canonical_actor fc ON fc.id = i.forwarder_canonical_id
  WHERE COALESCE(fc.is_direct_bucket, false) = false AND mi_is_real_cargo(i.producto_pmc) AND i.country_arrival_dep IS NOT NULL
  GROUP BY i.period_year, i.period_quarter, i.modality, i.country_arrival_dep, i.region_arrival_dep, fc.id, fc.canonical_name, fc.is_gloval
WITH NO DATA;

CREATE MATERIALIZED VIEW public.mi_mv_import_base AS
SELECT period_year AS y,
    period_month AS m,
        CASE
            WHEN modality = 'AI'::mi_modality_t THEN 'AEREO'::text
            ELSE upper(COALESCE(tipo_despacho, '(s/d)'::text))
        END AS oper,
    COALESCE(NULLIF(incoterm, ''::text), '(s/d)'::text) AS incoterm,
    COALESCE(NULLIF(region_origin_destination, ''::text), '(s/d)'::text) AS region,
    ec_company_id,
    COALESCE(NULLIF(ec_company_name, ''::text), '(sin nombre)'::text) AS ec_company_name,
    COALESCE(NULLIF(producto_generico, ''::text), '(sin producto)'::text) AS producto,
    COALESCE(NULLIF(liberador_doc_transporte, ''::text), NULLIF(forwarder_raw_liberador, ''::text), '(s/d)'::text) AS liberador,
    COALESCE(NULLIF(carrier_raw, ''::text), '(s/d)'::text) AS carrier,
    COALESCE(NULLIF(country_origin_destination, ''::text), '(s/d)'::text) AS pais,
    ec_provincia AS provincia,
    ec_canton AS canton,
    port_ec,
    port_origin_destination AS port_embarque,
    is_direct_no_forwarder AS is_direct,
    COALESCE(teus_fcl, 0::numeric) + COALESCE(teus_lcl, 0::numeric) AS teus,
    COALESCE(kilos_brutos, 0::numeric) AS kilos,
    COALESCE(cont_20, 0::numeric) AS c20,
    COALESCE(cont_40, 0::numeric) AS c40
   FROM mi_shipment_intel
  WHERE (modality = ANY (ARRAY['SI'::mi_modality_t, 'AI'::mi_modality_t])) AND (COALESCE(producto_pmc, ''::text) <> ALL (ARRAY['ZZ CONTENEDORES VACIOS'::text, 'CONTENEDORES VACIOS'::text, 'ZZ DE USO NAVIERO'::text]))
WITH NO DATA;

CREATE MATERIALIZED VIEW public.mi_mv_market_top_players AS
SELECT i.period_year,
    i.period_quarter,
    i.modality,
    i.ec_company_id,
    max(i.ec_company_name) AS ec_company_name,
    max(i.ec_provincia) AS ec_provincia,
    max(i.ec_vertical) AS ec_vertical,
    bool_or(i.client_id IS NOT NULL) AS is_in_crm,
    (array_agg(c.assigned_to) FILTER (WHERE c.assigned_to IS NOT NULL))[1] AS sales_executive_id,
    count(*) AS bls,
    sum(COALESCE(i.teus_fcl, 0::numeric)) AS teus_fcl,
    sum(COALESCE(i.teus_lcl, 0::numeric)) AS teus_lcl,
    sum(COALESCE(i.kilos_brutos, 0::numeric)) AS kilos,
    count(*) FILTER (WHERE i.is_direct_no_forwarder) AS bls_direct,
    count(*) FILTER (WHERE COALESCE(fc.is_gloval, false)) AS bls_with_gloval
   FROM mi_shipment_intel i
     LEFT JOIN clients c ON c.id = i.client_id
     LEFT JOIN mi_canonical_actor fc ON fc.id = i.forwarder_canonical_id
  WHERE i.ec_company_id IS NOT NULL AND mi_is_real_cargo(i.producto_pmc)
  GROUP BY i.period_year, i.period_quarter, i.modality, i.ec_company_id
WITH NO DATA;

CREATE MATERIALIZED VIEW public.mi_mv_partner_network AS
SELECT i.period_year,
    i.period_quarter,
    i.modality,
    i.country_arrival_dep AS origin_country,
    pc.id AS partner_canonical_id,
    pc.canonical_name AS partner_name,
    i.origin_partner_type,
    i.origin_partner_office,
    count(*) AS bls,
    sum(COALESCE(i.teus_fcl, 0::numeric)) AS teus_fcl,
    sum(COALESCE(i.kilos_brutos, 0::numeric)) AS kilos
   FROM mi_shipment_intel i
     JOIN mi_canonical_actor fc ON fc.id = i.forwarder_canonical_id AND fc.is_gloval
     LEFT JOIN mi_canonical_actor pc ON pc.id = i.partner_canonical_id
  WHERE mi_is_real_cargo(i.producto_pmc)
  GROUP BY i.period_year, i.period_quarter, i.modality, i.country_arrival_dep, pc.id, pc.canonical_name, i.origin_partner_type, i.origin_partner_office
WITH NO DATA;

CREATE MATERIALIZED VIEW public.mi_mv_product_client_fwd AS
SELECT i.period_year,
    i.modality,
    i.producto_generico,
    COALESCE(i.client_id::text, i.ec_company_id) AS counter_id,
        CASE
            WHEN i.is_direct_no_forwarder THEN 'DIRECT'::text
            ELSE COALESCE(fc.canonical_name, '(sin clasificar)'::text)
        END AS forwarder_label,
    max(i.ec_company_id) AS ec_company_id,
    bool_or(i.client_id IS NOT NULL) AS in_crm,
    max(COALESCE(cl.company_name, i.ec_company_name)) AS counter_name,
    max(cl.assigned_to::text) AS crm_assigned_to,
    max(cl.office) AS crm_office,
    bool_or(COALESCE(fc.is_gloval, false)) AS fwd_is_gloval,
    count(*) AS bls,
    sum(COALESCE(i.teus_fcl, 0::numeric)) AS teus_fcl,
    sum(COALESCE(i.kilos_brutos, 0::numeric)) AS kilos,
    sum(COALESCE(i.valor_comercial, 0::numeric)) AS valor_comercial
   FROM mi_shipment_intel i
     LEFT JOIN clients cl ON cl.id = i.client_id
     LEFT JOIN mi_canonical_actor fc ON fc.id = i.forwarder_canonical_id
  WHERE i.producto_generico IS NOT NULL AND i.ec_company_id IS NOT NULL AND mi_is_real_cargo(i.producto_pmc)
  GROUP BY i.period_year, i.modality, i.producto_generico, (COALESCE(i.client_id::text, i.ec_company_id)), (
        CASE
            WHEN i.is_direct_no_forwarder THEN 'DIRECT'::text
            ELSE COALESCE(fc.canonical_name, '(sin clasificar)'::text)
        END)
WITH NO DATA;

CREATE MATERIALIZED VIEW public.mi_mv_product_month AS
SELECT producto_generico,
    period_year,
    period_month,
    modality,
    COALESCE(mode() WITHIN GROUP (ORDER BY mi_shipment_intel.tipo_producto), 'SIN CLASIFICAR'::text) AS tipo_producto,
    count(*) AS bls,
    sum(COALESCE(teus_fcl, 0::numeric)) AS teus_fcl,
    sum(COALESCE(kilos_brutos, 0::numeric)) AS kilos,
    sum(COALESCE(valor_comercial, 0::numeric)) AS valor
   FROM mi_shipment_intel
  WHERE producto_generico IS NOT NULL AND mi_is_real_cargo(producto_pmc)
  GROUP BY producto_generico, period_year, period_month, modality
WITH NO DATA;

CREATE MATERIALIZED VIEW public.mi_mv_product_summary AS
SELECT period_year,
    modality,
    producto_generico,
    COALESCE(mode() WITHIN GROUP (ORDER BY mi_shipment_intel.tipo_producto), 'SIN CLASIFICAR'::text) AS tipo_producto,
    count(*) AS bls,
    sum(COALESCE(teus_fcl, 0::numeric)) AS teus_fcl,
    sum(COALESCE(teus_lcl, 0::numeric)) AS teus_lcl,
    sum(COALESCE(kilos_brutos, 0::numeric)) AS kilos,
    sum(COALESCE(valor_comercial, 0::numeric)) AS valor_comercial,
    count(DISTINCT ec_company_id) FILTER (WHERE ec_company_id IS NOT NULL) AS ec_companies_count,
    count(DISTINCT client_id) FILTER (WHERE client_id IS NOT NULL) AS crm_clients_count,
    count(DISTINCT ec_company_id) FILTER (WHERE client_id IS NULL AND ec_company_id IS NOT NULL) AS prospects_count,
    count(*) FILTER (WHERE is_direct_no_forwarder) AS bls_direct_no_forwarder
   FROM mi_shipment_intel
  WHERE producto_generico IS NOT NULL AND mi_is_real_cargo(producto_pmc)
  GROUP BY period_year, modality, producto_generico
WITH NO DATA;

CREATE MATERIALIZED VIEW public.mi_mv_route_ec_zones AS
SELECT DISTINCT period_year,
    ec_provincia AS provincia,
    ec_canton AS canton
   FROM mi_shipment_intel
  WHERE ec_provincia IS NOT NULL
WITH NO DATA;

CREATE MATERIALIZED VIEW public.mi_mv_route_origin_ports AS
SELECT period_year,
        CASE
            WHEN modality = ANY (ARRAY['SI'::mi_modality_t, 'AI'::mi_modality_t]) THEN 'import'::text
            ELSE 'export'::text
        END AS flow,
    port_origin_destination AS port,
    max(country_origin_destination) AS country,
    count(*) AS bls
   FROM mi_shipment_intel
  WHERE port_origin_destination IS NOT NULL AND (COALESCE(producto_pmc, ''::text) <> ALL (ARRAY['ZZ CONTENEDORES VACIOS'::text, 'CONTENEDORES VACIOS'::text, 'ZZ DE USO NAVIERO'::text]))
  GROUP BY period_year, (
        CASE
            WHEN modality = ANY (ARRAY['SI'::mi_modality_t, 'AI'::mi_modality_t]) THEN 'import'::text
            ELSE 'export'::text
        END), port_origin_destination
WITH NO DATA;

CREATE MATERIALIZED VIEW public.mi_mv_route_port_options AS
SELECT mi_shipment_intel.period_year,
    mi_shipment_intel.port_ec AS port,
    'EC'::text AS kind,
    count(*) AS bls
   FROM mi_shipment_intel
  WHERE mi_shipment_intel.port_ec IS NOT NULL
  GROUP BY mi_shipment_intel.period_year, mi_shipment_intel.port_ec
UNION ALL
 SELECT mi_shipment_intel.period_year,
    mi_shipment_intel.port_origin_destination AS port,
    'FGN'::text AS kind,
    count(*) AS bls
   FROM mi_shipment_intel
  WHERE mi_shipment_intel.port_origin_destination IS NOT NULL
  GROUP BY mi_shipment_intel.period_year, mi_shipment_intel.port_origin_destination
WITH NO DATA;

CREATE MATERIALIZED VIEW public.mi_mv_unassigned_prospects AS
SELECT i.ec_company_id,
    max(i.ec_company_name) AS ec_company_name,
    max(i.ec_provincia) AS ec_provincia,
    max(i.ec_canton) AS ec_canton,
    max(i.ec_vertical) AS ec_vertical,
    max(i.ec_ciiu) AS ec_ciiu,
    count(*) AS bls,
    count(*) FILTER (WHERE i.modality = 'SI'::mi_modality_t) AS bls_si,
    count(*) FILTER (WHERE i.modality = 'SE'::mi_modality_t) AS bls_se,
    count(*) FILTER (WHERE i.modality = 'AI'::mi_modality_t) AS bls_ai,
    count(*) FILTER (WHERE i.modality = 'AE'::mi_modality_t) AS bls_ae,
    sum(COALESCE(i.teus_fcl, 0::numeric)) AS teus_fcl,
    sum(COALESCE(i.teus_lcl, 0::numeric)) AS teus_lcl,
    sum(COALESCE(i.kilos_brutos, 0::numeric)) AS kilos,
    sum(COALESCE(i.valor_comercial, 0::numeric)) AS valor_comercial,
    count(*) FILTER (WHERE i.is_direct_no_forwarder) AS bls_direct_no_forwarder,
    array_agg(DISTINCT fc.canonical_name) FILTER (WHERE fc.canonical_name IS NOT NULL AND NOT COALESCE(fc.is_direct_bucket, false)) AS forwarders_used,
    array_agg(DISTINCT cc.canonical_name) FILTER (WHERE cc.canonical_name IS NOT NULL) AS carriers_used,
    array_agg(DISTINCT i.country_arrival_dep) FILTER (WHERE i.country_arrival_dep IS NOT NULL) AS origin_countries,
    array_agg(DISTINCT i.port_origin_destination) FILTER (WHERE i.port_origin_destination IS NOT NULL) AS origin_ports,
    array_agg(DISTINCT i.port_ec) FILTER (WHERE i.port_ec IS NOT NULL) AS ec_ports,
    min(i.operation_date) AS first_seen_date,
    max(i.operation_date) AS last_seen_date
   FROM mi_shipment_intel i
     LEFT JOIN mi_canonical_actor fc ON fc.id = i.forwarder_canonical_id
     LEFT JOIN mi_canonical_actor cc ON cc.id = i.carrier_canonical_id
  WHERE i.client_id IS NULL AND i.ec_company_id IS NOT NULL AND mi_is_real_cargo(i.producto_pmc)
  GROUP BY i.ec_company_id
WITH NO DATA;

CREATE MATERIALIZED VIEW public.mi_v_client_wallet_share AS
WITH cps AS (
         SELECT s.period_year,
            s.period_month,
            s.modality,
            s.port_ec,
            s.incoterm,
            s.client_id,
            sum(s.teus_fcl) AS total_teus_fcl,
            sum(s.teus_fcl) FILTER (WHERE s.forwarder_is_gloval) AS gloval_teus_fcl,
            sum(s.teus_fcl) FILTER (WHERE s.forwarder_is_direct_bucket) AS direct_teus_fcl,
            sum(s.teus_fcl) FILTER (WHERE COALESCE(s.forwarder_is_gloval, false) = false AND COALESCE(s.forwarder_is_direct_bucket, false) = false AND s.forwarder_canonical_id IS NOT NULL) AS competitor_teus_fcl,
            sum(s.teus_lcl) AS total_teus_lcl,
            sum(s.teus_lcl) FILTER (WHERE s.forwarder_is_gloval) AS gloval_teus_lcl,
            sum(s.kilos) AS total_kilos,
            sum(s.kilos) FILTER (WHERE s.forwarder_is_gloval) AS gloval_kilos,
            sum(s.kilos) FILTER (WHERE s.forwarder_is_direct_bucket) AS direct_kilos,
            sum(s.kilos) FILTER (WHERE COALESCE(s.forwarder_is_gloval, false) = false AND COALESCE(s.forwarder_is_direct_bucket, false) = false AND s.forwarder_canonical_id IS NOT NULL) AS competitor_kilos,
            sum(s.bls) AS total_bls,
            sum(s.bls) FILTER (WHERE s.forwarder_is_gloval) AS gloval_bls,
            sum(s.bls) FILTER (WHERE s.forwarder_is_direct_bucket) AS direct_bls,
            sum(s.bls) FILTER (WHERE COALESCE(s.forwarder_is_gloval, false) = false AND COALESCE(s.forwarder_is_direct_bucket, false) = false AND s.forwarder_canonical_id IS NOT NULL) AS competitor_bls
           FROM mi_mv_client_period_summary s
          WHERE s.client_id IS NOT NULL
          GROUP BY s.period_year, s.period_month, s.modality, s.port_ec, s.incoterm, s.client_id
        )
 SELECT c.id AS client_id,
    c.company_name,
    c.office,
    c.assigned_to AS sales_executive_id,
    u.name AS sales_executive_name,
    cps.period_year,
    cps.period_month,
    (cps.period_month - 1) / 3 + 1 AS period_quarter,
    cps.modality,
    cps.port_ec,
    cps.incoterm,
    cps.total_bls,
    cps.gloval_bls,
    cps.competitor_bls,
    cps.direct_bls,
    cps.total_teus_fcl,
    COALESCE(cps.gloval_teus_fcl, 0::numeric) AS gloval_teus_fcl,
    COALESCE(cps.competitor_teus_fcl, 0::numeric) AS competitor_teus_fcl,
    COALESCE(cps.direct_teus_fcl, 0::numeric) AS direct_teus_fcl,
    cps.total_teus_lcl,
    COALESCE(cps.gloval_teus_lcl, 0::numeric) AS gloval_teus_lcl,
    cps.total_kilos,
    COALESCE(cps.gloval_kilos, 0::numeric) AS gloval_kilos,
    COALESCE(cps.competitor_kilos, 0::numeric) AS competitor_kilos,
    COALESCE(cps.direct_kilos, 0::numeric) AS direct_kilos,
        CASE
            WHEN cps.total_teus_fcl > 0::numeric THEN round(COALESCE(cps.gloval_teus_fcl, 0::numeric) / cps.total_teus_fcl, 4)
            ELSE NULL::numeric
        END AS wallet_share_fcl,
        CASE
            WHEN (COALESCE(cps.gloval_teus_fcl, 0::numeric) + COALESCE(cps.competitor_teus_fcl, 0::numeric)) > 0::numeric THEN round(COALESCE(cps.gloval_teus_fcl, 0::numeric) / (COALESCE(cps.gloval_teus_fcl, 0::numeric) + COALESCE(cps.competitor_teus_fcl, 0::numeric)), 4)
            ELSE NULL::numeric
        END AS forwarder_share_fcl,
        CASE
            WHEN cps.total_kilos > 0::numeric THEN round(COALESCE(cps.gloval_kilos, 0::numeric) / cps.total_kilos, 4)
            ELSE NULL::numeric
        END AS wallet_share_kilos
   FROM cps
     JOIN clients c ON c.id = cps.client_id
     LEFT JOIN users u ON u.id = c.assigned_to
WITH NO DATA;

CREATE MATERIALIZED VIEW public.mi_v_executive_scorecard AS
WITH agg AS (
         SELECT c.assigned_to AS sales_executive_id,
            s.period_year,
            s.period_month,
            s.modality,
            s.port_ec,
            s.incoterm,
            count(DISTINCT c.id) FILTER (WHERE (EXISTS ( SELECT 1
                   FROM mi_mv_client_period_summary s2
                  WHERE s2.client_id = c.id AND s2.period_year = s.period_year AND s2.period_month = s.period_month AND s2.modality = s.modality AND NOT s2.port_ec IS DISTINCT FROM s.port_ec AND NOT s2.incoterm IS DISTINCT FROM s.incoterm))) AS active_clients,
            count(DISTINCT c.id) FILTER (WHERE (EXISTS ( SELECT 1
                   FROM mi_mv_client_period_summary s2
                  WHERE s2.client_id = c.id AND s2.period_year = s.period_year AND s2.period_month = s.period_month AND s2.modality = s.modality AND NOT s2.port_ec IS DISTINCT FROM s.port_ec AND NOT s2.incoterm IS DISTINCT FROM s.incoterm AND s2.forwarder_is_gloval))) AS clients_with_gloval,
            sum(s.teus_fcl) AS total_teus_fcl,
            sum(s.teus_fcl) FILTER (WHERE s.forwarder_is_gloval) AS gloval_teus_fcl,
            sum(s.teus_fcl) FILTER (WHERE s.forwarder_is_direct_bucket) AS direct_teus_fcl,
            sum(s.teus_fcl) FILTER (WHERE COALESCE(s.forwarder_is_gloval, false) = false AND COALESCE(s.forwarder_is_direct_bucket, false) = false AND s.forwarder_canonical_id IS NOT NULL) AS competitor_teus_fcl,
            sum(s.kilos) AS total_kilos,
            sum(s.kilos) FILTER (WHERE s.forwarder_is_gloval) AS gloval_kilos,
            sum(s.kilos) FILTER (WHERE s.forwarder_is_direct_bucket) AS direct_kilos,
            sum(s.kilos) FILTER (WHERE COALESCE(s.forwarder_is_gloval, false) = false AND COALESCE(s.forwarder_is_direct_bucket, false) = false AND s.forwarder_canonical_id IS NOT NULL) AS competitor_kilos,
            sum(s.bls) AS total_bls,
            sum(s.bls) FILTER (WHERE s.forwarder_is_gloval) AS gloval_bls,
            sum(s.bls) FILTER (WHERE s.forwarder_is_direct_bucket) AS direct_bls,
            sum(s.bls) FILTER (WHERE COALESCE(s.forwarder_is_gloval, false) = false AND COALESCE(s.forwarder_is_direct_bucket, false) = false AND s.forwarder_canonical_id IS NOT NULL) AS competitor_bls
           FROM mi_mv_client_period_summary s
             JOIN clients c ON c.id = s.client_id
          WHERE c.assigned_to IS NOT NULL
          GROUP BY c.assigned_to, s.period_year, s.period_month, s.modality, s.port_ec, s.incoterm
        )
 SELECT agg.sales_executive_id,
    u.name AS sales_executive_name,
    u.office,
    agg.period_year,
    agg.period_month,
    (agg.period_month - 1) / 3 + 1 AS period_quarter,
    agg.modality,
    agg.port_ec,
    agg.incoterm,
    agg.active_clients,
    agg.clients_with_gloval,
    agg.active_clients - agg.clients_with_gloval AS inactive_with_us_clients,
    agg.total_bls,
    COALESCE(agg.gloval_bls, 0::numeric) AS gloval_bls,
    COALESCE(agg.competitor_bls, 0::numeric) AS competitor_bls,
    COALESCE(agg.direct_bls, 0::numeric) AS direct_bls,
    agg.total_teus_fcl,
    COALESCE(agg.gloval_teus_fcl, 0::numeric) AS gloval_teus_fcl,
    COALESCE(agg.competitor_teus_fcl, 0::numeric) AS competitor_teus_fcl,
    COALESCE(agg.direct_teus_fcl, 0::numeric) AS direct_teus_fcl,
    agg.total_kilos,
    COALESCE(agg.gloval_kilos, 0::numeric) AS gloval_kilos,
    COALESCE(agg.competitor_kilos, 0::numeric) AS competitor_kilos,
    COALESCE(agg.direct_kilos, 0::numeric) AS direct_kilos,
        CASE
            WHEN agg.total_teus_fcl > 0::numeric THEN round(COALESCE(agg.gloval_teus_fcl, 0::numeric) / agg.total_teus_fcl, 4)
            ELSE NULL::numeric
        END AS wallet_share_fcl,
        CASE
            WHEN (COALESCE(agg.gloval_teus_fcl, 0::numeric) + COALESCE(agg.competitor_teus_fcl, 0::numeric)) > 0::numeric THEN round(COALESCE(agg.gloval_teus_fcl, 0::numeric) / (COALESCE(agg.gloval_teus_fcl, 0::numeric) + COALESCE(agg.competitor_teus_fcl, 0::numeric)), 4)
            ELSE NULL::numeric
        END AS forwarder_share_fcl,
        CASE
            WHEN agg.total_kilos > 0::numeric THEN round(COALESCE(agg.gloval_kilos, 0::numeric) / agg.total_kilos, 4)
            ELSE NULL::numeric
        END AS wallet_share_kilos
   FROM agg
     JOIN users u ON u.id = agg.sales_executive_id
WITH NO DATA;

CREATE MATERIALIZED VIEW public.mi_v_lost_cargo AS
SELECT i.id AS intel_id,
    i.period_year,
    i.period_month,
    i.modality,
    i.operation_date,
    i.shipment_date,
    i.doc_transporte_master,
    i.doc_transporte_final,
    i.client_id,
    c.company_name AS client_name,
    c.assigned_to AS sales_executive_id,
    u.name AS sales_executive_name,
    i.foreign_company,
    i.foreign_country,
    i.country_arrival_dep,
    i.port_ec,
    i.port_origin_destination,
    i.teus_fcl,
    i.teus_lcl,
    i.kilos_brutos,
    i.valor_comercial,
    i.incoterm,
    fc.id AS competitor_forwarder_id,
    fc.canonical_name AS competitor_forwarder,
    cc.id AS carrier_canonical_id,
    cc.canonical_name AS carrier,
    pc.canonical_name AS partner_origin,
    i.origin_partner_type,
    i.origin_partner_office
   FROM mi_shipment_intel i
     JOIN clients c ON c.id = i.client_id
     LEFT JOIN users u ON u.id = c.assigned_to
     LEFT JOIN mi_canonical_actor fc ON fc.id = i.forwarder_canonical_id
     LEFT JOIN mi_canonical_actor cc ON cc.id = i.carrier_canonical_id
     LEFT JOIN mi_canonical_actor pc ON pc.id = i.partner_canonical_id
  WHERE i.client_id IS NOT NULL AND COALESCE(fc.is_gloval, false) = false AND COALESCE(i.is_direct_no_forwarder, false) = false AND mi_is_real_cargo(i.producto_pmc)
WITH NO DATA;

CREATE MATERIALIZED VIEW public.mv_consignee_top_agent AS
SELECT consignee,
    usual_agent,
    cnt
   FROM ( SELECT magaya_warehouse_receipts.consignee,
            magaya_warehouse_receipts.destination_agent AS usual_agent,
            count(*) AS cnt,
            row_number() OVER (PARTITION BY magaya_warehouse_receipts.consignee ORDER BY (count(*)) DESC) AS rn
           FROM magaya_warehouse_receipts
          WHERE magaya_warehouse_receipts.consignee IS NOT NULL AND btrim(magaya_warehouse_receipts.consignee) <> ''::text AND magaya_warehouse_receipts.destination_agent IS NOT NULL AND btrim(magaya_warehouse_receipts.destination_agent) <> ''::text AND magaya_warehouse_receipts.destination_agent !~~* '%as agent%'::text AND magaya_warehouse_receipts.destination_agent !~~* '%(inbound)%'::text
          GROUP BY magaya_warehouse_receipts.consignee, magaya_warehouse_receipts.destination_agent) t
  WHERE rn = 1
WITH NO DATA;

CREATE MATERIALIZED VIEW public.mv_entity_ar_ap AS
WITH calc_dedup AS (
         SELECT v_entity_ar_ap_correct_slow.office_id,
            v_entity_ar_ap_correct_slow.kind,
            v_entity_ar_ap_correct_slow.entity_name,
            min(v_entity_ar_ap_correct_slow.entity_guid) AS entity_guid,
            sum(v_entity_ar_ap_correct_slow.balance_usd) AS calc_balance,
            sum(v_entity_ar_ap_correct_slow.invoice_count) AS invoice_count
           FROM v_entity_ar_ap_correct_slow
          GROUP BY v_entity_ar_ap_correct_slow.office_id, v_entity_ar_ap_correct_slow.kind, v_entity_ar_ap_correct_slow.entity_name
        ), soap_dedup AS (
         SELECT magaya_entity_balance.office_id,
            magaya_entity_balance.kind,
            clean_entity_name(magaya_entity_balance.entity_name) AS clean_name,
            avg(magaya_entity_balance.balance_usd) AS soap_balance
           FROM magaya_entity_balance
          GROUP BY magaya_entity_balance.office_id, magaya_entity_balance.kind, (clean_entity_name(magaya_entity_balance.entity_name))
        ), joined AS (
         SELECT c.office_id,
            c.kind,
            c.entity_name,
            c.entity_guid,
            c.calc_balance,
            c.invoice_count,
            s.soap_balance,
            o.source AS override_source,
            o.manual_balance
           FROM calc_dedup c
             LEFT JOIN soap_dedup s ON s.office_id = c.office_id AND s.kind = c.kind AND s.clean_name = c.entity_name
             LEFT JOIN magaya_balance_override o ON o.office_id = c.office_id AND o.entity_name_clean = c.entity_name AND (o.kind IS NULL OR o.kind = c.kind)
        )
 SELECT joined.office_id,
    joined.entity_name,
    joined.entity_guid,
    joined.kind,
        CASE
            WHEN joined.override_source = 'manual'::text AND joined.manual_balance IS NOT NULL THEN joined.manual_balance
            WHEN joined.override_source = 'soap'::text THEN COALESCE(joined.soap_balance, joined.calc_balance)
            WHEN joined.override_source = 'calc'::text THEN joined.calc_balance
            ELSE joined.calc_balance
        END::numeric(15,2) AS balance_usd,
    COALESCE(joined.invoice_count, 0::numeric) AS invoice_count,
    NULL::text AS source_bill_number,
    NULL::uuid AS source_bill_guid,
    now() AS fetched_at,
    'a4e3e84c-7fca-4ce3-8889-1f31d8d1366f'::uuid AS tenant_id
   FROM joined
  WHERE abs(
        CASE
            WHEN joined.override_source = 'manual'::text AND joined.manual_balance IS NOT NULL THEN joined.manual_balance
            WHEN joined.override_source = 'soap'::text THEN COALESCE(joined.soap_balance, joined.calc_balance)
            ELSE joined.calc_balance
        END) > 0.01
UNION ALL
 SELECT o.office_id,
    o.entity_name_clean AS entity_name,
    NULL::text AS entity_guid,
    o.kind,
    o.manual_balance AS balance_usd,
    0::numeric AS invoice_count,
    NULL::text AS source_bill_number,
    NULL::uuid AS source_bill_guid,
    now() AS fetched_at,
    'a4e3e84c-7fca-4ce3-8889-1f31d8d1366f'::uuid AS tenant_id
   FROM magaya_balance_override o
  WHERE o.source = 'manual'::text AND o.manual_balance IS NOT NULL AND o.kind IS NOT NULL AND abs(o.manual_balance) > 0.01 AND NOT (EXISTS ( SELECT 1
           FROM v_entity_ar_ap_correct_slow c
          WHERE c.office_id = o.office_id AND c.kind = o.kind AND c.entity_name = o.entity_name_clean))
WITH NO DATA;

CREATE MATERIALIZED VIEW public.mv_finanzas_docs_abiertos AS
WITH paid AS (
         SELECT magaya_payment_application.item_paid_guid::text AS guid,
            sum(magaya_payment_application.amount_paid)::numeric(15,2) AS paid_amt
           FROM magaya_payment_application
          GROUP BY (magaya_payment_application.item_paid_guid::text)
        ), plazo AS (
         SELECT magaya_transactions.company_id,
            magaya_transactions.transaction_type,
            GREATEST(0, LEAST(120, percentile_disc(0.5::double precision) WITHIN GROUP (ORDER BY (magaya_transactions.due_date - magaya_transactions.created_on::date)))) AS dias
           FROM magaya_transactions
          WHERE (magaya_transactions.transaction_type = ANY (ARRAY['IN'::text, 'BI'::text])) AND magaya_transactions.due_date IS NOT NULL AND magaya_transactions.created_on IS NOT NULL AND magaya_transactions.created_on > (now() - '365 days'::interval)
          GROUP BY magaya_transactions.company_id, magaya_transactions.transaction_type
        )
 SELECT mt.company_id,
    office_for_magaya_company(mt.company_id) AS office_id,
        CASE mt.transaction_type
            WHEN 'IN'::text THEN 'AR'::text
            ELSE 'AP'::text
        END AS kind,
    clean_entity_name(mt.billing_client_name) AS entity_name,
    mt.magaya_guid AS doc_guid,
    mt.transaction_number AS numero,
    mt.created_on::date AS fecha_doc,
    COALESCE(mt.due_date, mt.created_on::date + COALESCE(pl.dias, 30)) AS vence,
    mt.due_date IS NULL AS vence_estimado,
        CASE
            WHEN mt.is_credit THEN '-1'::integer
            ELSE 1
        END::numeric * (mt.total_amount - COALESCE(p.paid_amt, 0::numeric)) *
        CASE
            WHEN mt.total_amount_usd IS NOT NULL AND mt.total_amount > 0::numeric THEN mt.total_amount_usd / mt.total_amount
            WHEN mt.company_id = '9b807b51-5ee9-4a22-9e75-df90047ec12b'::uuid THEN 1.0 / 3.42
            ELSE 1.0
        END AS saldo_usd
   FROM magaya_transactions mt
     LEFT JOIN paid p ON p.guid = mt.magaya_guid
     LEFT JOIN magaya_status_overrides ovr ON ovr.txn_guid = mt.magaya_guid
     LEFT JOIN plazo pl ON pl.company_id = mt.company_id AND pl.transaction_type = mt.transaction_type
  WHERE (mt.transaction_type = ANY (ARRAY['IN'::text, 'BI'::text])) AND (mt.status = ANY (ARRAY['Open'::text, 'Posted'::text])) AND mt.total_amount > 0::numeric AND mt.billing_client_name IS NOT NULL AND (COALESCE(ovr.status_from_soap, 'Open'::text) <> ALL (ARRAY['Paid'::text, 'Voided'::text, 'Closed'::text, 'Cancelled'::text])) AND office_for_magaya_company(mt.company_id) IS NOT NULL
WITH NO DATA;

CREATE MATERIALIZED VIEW public.mv_shipper_top_consignee AS
SELECT shipper,
    top_consignee,
    cnt
   FROM ( SELECT magaya_warehouse_receipts.shipper,
            magaya_warehouse_receipts.consignee AS top_consignee,
            count(*) AS cnt,
            row_number() OVER (PARTITION BY magaya_warehouse_receipts.shipper ORDER BY (count(*)) DESC) AS rn
           FROM magaya_warehouse_receipts
          WHERE magaya_warehouse_receipts.shipper IS NOT NULL AND btrim(magaya_warehouse_receipts.shipper) <> ''::text AND magaya_warehouse_receipts.shipper !~~* '%amazon%'::text AND magaya_warehouse_receipts.consignee IS NOT NULL AND btrim(magaya_warehouse_receipts.consignee) <> ''::text AND magaya_warehouse_receipts.consignee !~~* '%as agent%'::text AND magaya_warehouse_receipts.consignee !~~* '%(inbound)%'::text AND magaya_warehouse_receipts.consignee !~~* 'desconocido%'::text
          GROUP BY magaya_warehouse_receipts.shipper, magaya_warehouse_receipts.consignee) t
  WHERE rn = 1
WITH NO DATA;

CREATE MATERIALIZED VIEW public.mv_wh_container_metrics AS
SELECT gr.grain,
    gr.period,
    p.trade_dir,
    dm.dim_type,
    dm.dim_value,
    count(*) AS containers,
    round(sum(p.cbm_capacity), 1) AS cbm_cap,
    round(sum(p.revenue_usd), 2) AS revenue
   FROM v_wh_containers_priced p
     CROSS JOIN LATERAL ( VALUES ('week'::text,date_trunc('week'::text, p.wkd::timestamp with time zone)::date), ('month'::text,date_trunc('month'::text, p.wkd::timestamp with time zone)::date), ('year'::text,date_trunc('year'::text, p.wkd::timestamp with time zone)::date)) gr(grain, period)
     CROSS JOIN LATERAL ( VALUES ('TOTAL'::text,'TOTAL'::text), ('container_type'::text,p.container_type), ('loader'::text,COALESCE(p.loader, '(sin loader)'::text)), ('client'::text,COALESCE(p.import_client, '(n/a)'::text))) dm(dim_type, dim_value)
  WHERE p.trade_dir = 'EXPORT'::text AND p.is_loaded OR p.trade_dir = 'IMPORT'::text AND p.is_unloaded
  GROUP BY gr.grain, gr.period, p.trade_dir, dm.dim_type, dm.dim_value
WITH NO DATA;

CREATE MATERIALIZED VIEW public.mv_wh_metrics AS
SELECT gr.grain,
    gr.period,
    td.trade_dir,
    dm.dim_type,
    dm.dim_value,
    count(*) AS wrs,
    sum(b.pieces) AS pieces,
    round(sum(b.weight_lb), 1) AS weight_lb,
    round(sum(b.cbm), 2) AS cbm
   FROM v_wh_receipts b
     CROSS JOIN LATERAL ( VALUES ('week'::text,b.week_start), ('month'::text,b.month_start), ('year'::text,b.year_start)) gr(grain, period)
     CROSS JOIN LATERAL ( VALUES (b.trade_dir), ('ALL'::text)) td(trade_dir)
     CROSS JOIN LATERAL ( VALUES ('TOTAL'::text,'TOTAL'::text), ('destination_agent'::text,b.destination_agent), ('issued_by'::text,b.issued_by), ('consignee'::text,b.consignee), ('shipper'::text,b.shipper), ('import_client'::text,b.import_client)) dm(dim_type, dim_value)
  GROUP BY gr.grain, gr.period, td.trade_dir, dm.dim_type, dm.dim_value
WITH NO DATA;

CREATE MATERIALIZED VIEW public.v_magaya_invoices_unified AS
SELECT magaya_guid AS external_guid,
    transaction_number AS external_reference,
    office_for_magaya_company(company_id) AS office_id,
        CASE
            WHEN transaction_type = 'IN'::text THEN 'inflow'::text
            ELSE 'outflow'::text
        END AS direction,
        CASE
            WHEN transaction_type = 'IN'::text THEN 'invoice'::text
            ELSE 'bill'::text
        END AS source_type,
    clean_entity_name(billing_client_name) AS counterparty_name,
    total_amount AS amount,
    COALESCE(currency_code, 'USD'::text) AS currency,
    magaya_amount_to_usd(company_id, total_amount, total_amount_usd) AS amount_in_usd,
    created_on::date AS invoice_date,
    COALESCE(due_date, created_on::date) AS expected_date,
        CASE
            WHEN lower(status) = ANY (ARRAY['paid'::text, 'pagada'::text, 'pagado'::text]) THEN created_on::date
            ELSE NULL::date
        END AS actual_date,
        CASE
            WHEN lower(status) = ANY (ARRAY['paid'::text, 'pagada'::text, 'pagado'::text]) THEN 'executed'::text
            ELSE 'committed'::text
        END AS status,
    company_id AS magaya_company_id
   FROM magaya_transactions mt
  WHERE (transaction_type = ANY (ARRAY['BI'::text, 'IN'::text])) AND total_amount > 0::numeric AND billing_client_name IS NOT NULL
WITH NO DATA;
