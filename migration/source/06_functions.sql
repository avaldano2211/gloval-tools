-- Funciones y procedimientos (sin los de extensiones)
-- Origen: Supabase GES (wfzdrqfurwnakrfdnbgf), esquemas public, archive, private, timeclock.
-- Extraído del catálogo el 2026-09-29 (solo lectura). Referencia: NO ejecutar en Azure.
-- Credenciales redactadas como <SUPABASE_*>.

CREATE OR REPLACE FUNCTION public._audit_norm(p text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
 SET search_path TO 'public', 'extensions', 'pg_catalog'
AS $function$
  SELECT public.normalize_company_name(regexp_replace(coalesce(p,''), '\s*\([^)]*\)\s*', ' ', 'g'));
$function$;

CREATE OR REPLACE FUNCTION public._norm_ent(s text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$
  select regexp_replace(
    translate(
      replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
        upper(s),
        '&#X00D1;','N'),'&#X00F1;','N'),'&#X00CD;','I'),'&#X00ED;','I'),'&#X00D3;','O'),'&#X00F3;','O'),
        '&#X00C1;','A'),'&#X00E1;','A'),'&#X00C9;','E'),'&#X00E9;','E'),'&#X00DA;','U'),'&#X00FA;','U'),
      'ÁÉÍÓÚÑÀÈÌÒÙ','AEIOUNAEIOU'),
    '\s+',' ','g')
$function$;

CREATE OR REPLACE FUNCTION public._user_email()
 RETURNS text
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public', 'pg_catalog'
AS $function$
  select lower(email) from public.users where auth_user_id = auth.uid()
$function$;

CREATE OR REPLACE FUNCTION public._user_role()
 RETURNS text
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public', 'pg_catalog'
AS $function$
  SELECT role FROM public.users WHERE auth_user_id = auth.uid()
$function$;

CREATE OR REPLACE FUNCTION public.agent_rate_delete_group(p_rate_id uuid)
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_row rates%ROWTYPE;
  v_n   integer;
BEGIN
  SELECT * INTO v_row FROM rates WHERE id = p_rate_id;
  IF NOT FOUND THEN RETURN 0; END IF;

  DELETE FROM rates
   WHERE route_id = v_row.route_id
     AND contract_id IS NOT DISTINCT FROM v_row.contract_id
     AND agent_id    IS NOT DISTINCT FROM v_row.agent_id
     AND effective_date IS NOT DISTINCT FROM v_row.effective_date
     AND expiry_date    IS NOT DISTINCT FROM v_row.expiry_date;

  GET DIAGNOSTICS v_n = ROW_COUNT;
  RETURN v_n;
END $function$;

CREATE OR REPLACE FUNCTION public.agent_rate_norm(p text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$ SELECT upper(regexp_replace(coalesce(p, ''), '[^a-zA-Z0-9]', '', 'g')) $function$;

CREATE OR REPLACE FUNCTION public.agent_rate_parse_validity(p_validity text, OUT eff date, OUT exp date)
 RETURNS record
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_year text := to_char(current_date, 'YYYY');
BEGIN
  IF p_validity ~ '^\d{2}/\d{2}\s*-\s*\d{2}/\d{2}$' THEN
    eff := to_date(v_year || '/' || trim(split_part(p_validity, '-', 1)), 'YYYY/MM/DD');
    exp := to_date(v_year || '/' || trim(split_part(p_validity, '-', 2)), 'YYYY/MM/DD');
    -- vigencia que cruza fin de anio
    IF exp < eff THEN exp := exp + interval '1 year'; END IF;
  ELSIF p_validity ~ '^ETD\s+\d{2}/\d{2}$' THEN
    eff := to_date(v_year || '/' || trim(substring(p_validity from 4)), 'YYYY/MM/DD');
    exp := eff;
  ELSE
    eff := current_date;
    exp := current_date + 30;
  END IF;
END $function$;

CREATE OR REPLACE FUNCTION public.agent_rate_resolve_carrier(p_raw text)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_txt text := upper(trim(coalesce(p_raw, '')));
  v_id  uuid;
BEGIN
  IF v_txt = '' THEN RETURN NULL; END IF;

  SELECT id INTO v_id FROM carriers WHERE upper(code) = v_txt LIMIT 1;
  IF v_id IS NOT NULL THEN RETURN v_id; END IF;

  SELECT c.id INTO v_id FROM freight_carrier_aliases a
    JOIN carriers c ON upper(c.code) = upper(a.scac)
   WHERE a.alias = v_txt LIMIT 1;
  IF v_id IS NOT NULL THEN RETURN v_id; END IF;

  SELECT id INTO v_id FROM carriers WHERE upper(code) = (
    SELECT scac FROM (VALUES
      ('OOCL','OOLU'), ('COSCO','COSU'), ('COSCON','COSU'),
      ('PIL','PCIU'), ('YML','YMLU'), ('YANGMING','YMLU'),
      ('ONE','ONEY'), ('WHL','WHLC'), ('WANHAI','WHLC'),
      ('MSC','MSCU'), ('EMC','EMCU'), ('EVERGREEN','EMCU'),
      ('HMM','HDMU'), ('MSK','MAEU'), ('MAERSK','MAEU'),
      ('CMA','CMDU'), ('CMACGM','CMDU'), ('HPL','HLCU'), ('HAPAG','HLCU'),
      ('ZIM','ZIMU'), ('SEABOARD','SMLU')
    ) AS a(alias, scac) WHERE a.alias = v_txt) LIMIT 1;
  IF v_id IS NOT NULL THEN RETURN v_id; END IF;

  SELECT id INTO v_id FROM carriers WHERE upper(name) = v_txt LIMIT 1;
  IF v_id IS NOT NULL THEN RETURN v_id; END IF;

  SELECT id INTO v_id FROM carriers
   WHERE upper(name) LIKE '%'||v_txt||'%' AND length(v_txt) >= 3
   ORDER BY length(name) LIMIT 1;
  RETURN v_id;
END $function$;

CREATE OR REPLACE FUNCTION public.agent_rate_resolve_port(p_raw text)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_txt  text := upper(trim(coalesce(p_raw, '')));
  v_id   uuid;
  v_code text;
  v_name text;
BEGIN
  IF v_txt = '' THEN RETURN NULL; END IF;

  SELECT id INTO v_id FROM ports WHERE upper(code) = v_txt AND port_type='port'
   ORDER BY active DESC NULLS LAST LIMIT 1;
  IF v_id IS NOT NULL THEN RETURN v_id; END IF;

  -- alias curados (tabla, ya no hardcode)
  SELECT p.id INTO v_id
    FROM freight_port_aliases a JOIN ports p ON upper(p.code) = upper(a.port_code)
   WHERE a.alias = v_txt AND p.port_type='port'
   ORDER BY p.active DESC NULLS LAST LIMIT 1;
  IF v_id IS NOT NULL THEN RETURN v_id; END IF;

  SELECT id INTO v_id FROM ports WHERE upper(name) = v_txt AND port_type='port'
   ORDER BY active DESC NULLS LAST LIMIT 1;
  IF v_id IS NOT NULL THEN RETURN v_id; END IF;

  SELECT id INTO v_id FROM ports WHERE upper(city) = v_txt AND port_type='port'
   ORDER BY active DESC NULLS LAST LIMIT 1;
  IF v_id IS NOT NULL THEN RETURN v_id; END IF;

  SELECT id INTO v_id FROM ports WHERE upper(name) LIKE '%'||v_txt||'%' AND port_type='port'
   ORDER BY active DESC NULLS LAST, length(name) LIMIT 1;
  IF v_id IS NOT NULL THEN RETURN v_id; END IF;

  SELECT code, name INTO v_code, v_name FROM ports_master
   WHERE type='port' AND (upper(code)=v_txt OR upper(city)=v_txt OR upper(name)=v_txt)
   ORDER BY (upper(code)=v_txt) DESC LIMIT 1;
  IF v_code IS NULL THEN RETURN NULL; END IF;

  SELECT id INTO v_id FROM ports WHERE upper(code)=upper(v_code) LIMIT 1;
  IF v_id IS NULL THEN
    INSERT INTO ports (code, name, city, active, port_type)
    VALUES (v_code, v_name, initcap(v_txt), true, 'port') RETURNING id INTO v_id;
  END IF;
  RETURN v_id;
END $function$;

CREATE OR REPLACE FUNCTION public.agent_rate_upsert(p_agent text, p_carrier text, p_pol text, p_pod text, p_rate_20gp numeric DEFAULT NULL::numeric, p_rate_40st numeric DEFAULT NULL::numeric, p_rate_40hq numeric DEFAULT NULL::numeric, p_rate_40nor numeric DEFAULT NULL::numeric, p_free_days integer DEFAULT NULL::integer, p_nor_free_days integer DEFAULT NULL::integer, p_validity text DEFAULT NULL::text, p_notes text DEFAULT NULL::text, p_trade_lane text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_agent uuid; v_carrier uuid; v_opid uuid; v_dpid uuid;
  v_route uuid; v_contract uuid; v_sheet uuid; v_fak uuid;
  v_eff date; v_exp date; v_cnum text; v_sname text; v_first uuid;
  v_agent_name text; v_carrier_code text;
  v_removed integer := 0; v_inserted integer := 0;
BEGIN
  IF coalesce(trim(p_agent), '') = '' THEN
    RAISE EXCEPTION 'agent_rate_upsert: falta el agente';
  END IF;

  v_opid := agent_rate_resolve_port(p_pol);
  v_dpid := agent_rate_resolve_port(p_pod);
  IF v_opid IS NULL THEN RAISE EXCEPTION 'No se pudo resolver el POL "%"', p_pol; END IF;
  IF v_dpid IS NULL THEN RAISE EXCEPTION 'No se pudo resolver el POD "%"', p_pod; END IF;

  v_carrier := agent_rate_resolve_carrier(p_carrier);
  IF coalesce(trim(p_carrier), '') <> '' AND v_carrier IS NULL THEN
    RAISE EXCEPTION 'No se pudo resolver la naviera "%"', p_carrier;
  END IF;
  SELECT code INTO v_carrier_code FROM carriers WHERE id = v_carrier;

  SELECT eff, exp INTO v_eff, v_exp FROM agent_rate_parse_validity(p_validity);
  SELECT id INTO v_fak FROM commodities WHERE code = 'FAK';

  SELECT id, company_name INTO v_agent, v_agent_name
    FROM agents WHERE agent_rate_norm(company_name) = agent_rate_norm(p_agent) LIMIT 1;
  IF v_agent IS NULL THEN
    INSERT INTO agents (company_name, country, provides_rates, status, notes)
    VALUES (trim(p_agent), 'N/D', true, 'Active', 'Alta automatica desde el Tarifario de Compra')
    RETURNING id, company_name INTO v_agent, v_agent_name;
  END IF;

  SELECT id INTO v_route FROM freight_routes
   WHERE origin_port_id = v_opid AND destination_port_id = v_dpid LIMIT 1;
  IF v_route IS NULL THEN
    INSERT INTO freight_routes (origin_port_id, destination_port_id, active)
    VALUES (v_opid, v_dpid, true) RETURNING id INTO v_route;
  END IF;

  SELECT id INTO v_contract FROM contracts
   WHERE agent_id = v_agent
     AND carrier_id IS NOT DISTINCT FROM v_carrier
     AND date_trunc('month', effective_date) = date_trunc('month', v_eff)
   ORDER BY created_at LIMIT 1;
  IF v_contract IS NULL THEN
    v_cnum := 'AGT-' || agent_rate_norm(v_agent_name) || '-'
              || coalesce(v_carrier_code, 'NA') || '-' || to_char(v_eff, 'YYYY-MM');
    INSERT INTO contracts (contract_number, contract_name, agent_id, carrier_id,
                           effective_date, expiry_date, source_region, active)
    VALUES (v_cnum, v_agent_name || ' / ' || coalesce(v_carrier_code, 'N/D'),
            v_agent, v_carrier, v_eff, v_exp, p_trade_lane, true)
    RETURNING id INTO v_contract;
  END IF;

  v_sname := v_agent_name || ' — Tarifario de compra ' || to_char(v_eff, 'DD/MM')
             || ' - ' || to_char(v_exp, 'DD/MM/YYYY');
  SELECT id INTO v_sheet FROM tariff_sheets WHERE name = v_sname;
  IF v_sheet IS NULL THEN
    INSERT INTO tariff_sheets (name, source_type, agent_id, trade_lane,
                               effective_date, expiry_date, status)
    VALUES (v_sname, 'manual', v_agent, p_trade_lane, v_eff, v_exp,
            CASE WHEN v_exp >= current_date THEN 'active' ELSE 'expired' END)
    RETURNING id INTO v_sheet;
  END IF;

  DELETE FROM rates r
   USING contracts c
   WHERE r.contract_id = c.id
     AND r.agent_id = v_agent
     AND r.route_id = v_route
     AND r.effective_date = v_eff
     AND r.expiry_date = v_exp
     AND c.carrier_id IS NOT DISTINCT FROM v_carrier;
  GET DIAGNOSTICS v_removed = ROW_COUNT;

  INSERT INTO rates (contract_id, route_id, commodity_id, equipment_type_id,
                     base_rate, currency, service_type, transit_time,
                     effective_date, expiry_date, active, scope,
                     agent_id, tariff_sheet_id, notes)
  SELECT v_contract, v_route, v_fak, et.id, x.amount, 'USD', 'PORT_TO_PORT', x.days,
         v_eff, v_exp, true, 'global', v_agent, v_sheet, p_notes
  FROM (VALUES
          ('20GP',  p_rate_20gp,  p_free_days),
          ('40GP',  p_rate_40st,  p_free_days),
          ('40HC',  p_rate_40hq,  p_free_days),
          ('40NOR', p_rate_40nor, coalesce(p_nor_free_days, p_free_days))
       ) AS x(eq, amount, days)
  JOIN equipment_types et ON et.code = x.eq
  WHERE x.amount IS NOT NULL;
  GET DIAGNOSTICS v_inserted = ROW_COUNT;

  IF v_inserted = 0 THEN
    RAISE EXCEPTION 'La tarifa no trae ningun valor (20GP/40ST/40HQ/40NOR vacios)';
  END IF;

  SELECT id INTO v_first FROM rates
   WHERE agent_id = v_agent AND route_id = v_route AND contract_id = v_contract
     AND effective_date = v_eff AND expiry_date = v_exp
   ORDER BY id LIMIT 1;

  RETURN jsonb_build_object('id', v_first, 'replaced', v_removed > 0, 'rows', v_inserted,
                            'effective_date', v_eff, 'expiry_date', v_exp);
END $function$;

CREATE OR REPLACE FUNCTION public.air_rate_confirmar_vigencia(p_air_carrier_id uuid DEFAULT NULL::uuid, p_rate_ids uuid[] DEFAULT NULL::uuid[], p_quien text DEFAULT NULL::text)
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE v_n integer;
BEGIN
  IF p_air_carrier_id IS NULL AND (p_rate_ids IS NULL OR cardinality(p_rate_ids) = 0) THEN
    RAISE EXCEPTION 'air_rate_confirmar_vigencia: indica la aerolinea o los ids';
  END IF;

  UPDATE air_rates SET
    last_confirmed_at = current_date,
    last_confirmed_by = coalesce(p_quien, 'confirmacion mensual'),
    updated_at = now()
  WHERE active
    AND (p_air_carrier_id IS NULL OR air_carrier_id = p_air_carrier_id)
    AND (p_rate_ids IS NULL OR id = ANY(p_rate_ids));

  GET DIAGNOSTICS v_n = ROW_COUNT;
  RETURN v_n;
END $function$;

CREATE OR REPLACE FUNCTION public.app_can(p_page text, p_action text)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select coalesce(bool_or(
    case p_action
      when 'view'   then p.can_view
      when 'create' then p.can_create
      when 'edit'   then p.can_edit
      when 'delete' then p.can_delete
      else false
    end), false)
  from public.get_effective_permissions(public.app_current_user_id()) p
  where p.page = p_page;
$function$;

CREATE OR REPLACE FUNCTION public.app_can_operate_ops()
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select exists (
    select 1 from public.users u
    where u.auth_user_id = auth.uid()
      and ( lower(u.email) = any (array['ops@glovalecuador.com','ops1@glovalecuador.com','ops2@glovalecuador.com'])
            or u.role = any (array['Admin','VP','Manager']) )
  );
$function$;

CREATE OR REPLACE FUNCTION public.app_can_see_pba()
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select exists (
    select 1 from public.pba_authorized_users p
    where lower(p.email) = lower(coalesce(auth.jwt() ->> 'email', ''))
  );
$function$;

CREATE OR REPLACE FUNCTION public.app_can_see_pba_row(p_client_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select
    public.app_user_is_admin()
    or exists (
      select 1 from public.clients c
      where c.id = p_client_id
        and public.app_can_see_shipment_row(c.assigned_to, c.office, c.customer_service_id)
    );
$function$;

CREATE OR REPLACE FUNCTION public.app_can_see_shipment(p_sales_exec uuid, p_office text)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select
    public.app_user_is_admin()
    or (public.app_user_is_manager() and p_office = public.app_current_user_office())
    or p_sales_exec = public.app_current_user_id()
    or p_sales_exec in (select * from public.app_cs_executives())
    or (
      p_sales_exec is null
      and p_office = public.app_current_user_office()
      and public.app_cs_sees_directos()
    );
$function$;

CREATE OR REPLACE FUNCTION public.app_can_see_shipment_row(p_sales_exec uuid, p_office text, p_cs uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select coalesce(
    public.app_user_is_admin()
    or (public.app_user_is_manager() and p_office = public.app_current_user_office())
    or public.app_user_is_ops()
    -- Operaciones por oficina (RBAC). NO aplica a Customer Service: una CS ve por
    -- cartera, no toda la oficina (si no, ve los embarques de todas las ejecutivas).
    or (p_office is not null
        and p_office = public.app_current_user_office()
        and public.app_current_user_role() is distinct from 'Customer Service'
        and public.app_user_has_operaciones())
    or p_sales_exec = public.app_current_user_id()
    -- Ejecutivo delegado (co-seller): ve la cartera del principal al que delega
    or public.has_delegation_to(p_sales_exec)
    or (p_cs is not null and p_cs = public.app_current_user_id())
    or p_sales_exec in (select * from public.app_cs_executives_full())
    or (p_sales_exec in (select * from public.app_cs_executives())
        and (p_cs is null or p_cs = public.app_current_user_id()))
    or (p_sales_exec is null
        and p_office = public.app_current_user_office()
        and public.app_cs_sees_directos()
        and (p_cs is null or p_cs = public.app_current_user_id()))
  , false);
$function$;

CREATE OR REPLACE FUNCTION public.app_can_see_shipment_row(p_sales_exec uuid, p_office text, p_cs uuid, p_pba numeric)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select coalesce(
    public.app_user_is_admin()
    or (public.app_user_is_manager() and p_office = public.app_current_user_office())
    or public.app_user_is_ops()
    -- Operaciones por oficina (RBAC), nunca PBA y nunca para Customer Service
    or (p_office is not null
        and p_office = public.app_current_user_office()
        and p_pba is null
        and public.app_current_user_role() is distinct from 'Customer Service'
        and public.app_user_has_operaciones())
    or p_sales_exec = public.app_current_user_id()
    -- Delegado: ve la cartera del principal, pero NUNCA filas con PBA (confidencial)
    or (public.has_delegation_to(p_sales_exec) and p_pba is null)
    or (p_cs is not null and p_cs = public.app_current_user_id())
    or p_sales_exec in (select * from public.app_cs_executives_full())
    or (p_sales_exec in (select * from public.app_cs_executives())
        and (p_cs is null or p_cs = public.app_current_user_id()))
    or (p_sales_exec is null
        and p_office = public.app_current_user_office()
        and public.app_cs_sees_directos()
        and (p_cs is null or p_cs = public.app_current_user_id()))
  , false);
$function$;

CREATE OR REPLACE FUNCTION public.app_can_see_wh_notice(p_wr_number text, p_client_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  with me as (
    select u.id, u.role, u.office,
           coalesce(r.name = 'Inhouse', false) as es_inhouse
    from public.users u
    left join public.roles r on r.id = u.role_id
    where u.auth_user_id = auth.uid()
    limit 1
  ),
  wr as (
    select destination_agent, consignee_normalized
    from public.magaya_warehouse_receipts
    where wr_number = p_wr_number
    order by last_full_fetch_at desc nulls last
    limit 1
  ),
  mc as (
    select c.customer_service_id, c.assigned_to
    from public.clients c, wr
    where c.deleted_at is null
      and (
        (p_client_id is not null and c.id = p_client_id)
        or (
          c.company_name_normalized is not null
          and length(c.company_name_normalized) >= 5
          and wr.consignee_normalized is not null
          and (
            c.company_name_normalized = wr.consignee_normalized
            or wr.consignee_normalized like c.company_name_normalized || ' %'
            or c.company_name_normalized like wr.consignee_normalized || ' %'
          )
        )
      )
  )
  select
    coalesce((select role from me), '') in ('Admin', 'VP', 'Manager')
    or (
      -- CS por rol, o Administration que actua como CS (tiene cartera). NO cualquier rol.
      (
        coalesce((select role from me), '') = 'Customer Service'
        or (
          coalesce((select role from me), '') = 'Administration'
          and exists (
            select 1 from public.cs_assignments ca
            where ca.cs_user_id = (select id from me) and ca.active
          )
        )
      )
      and coalesce((select office from me), '') <> ''
      and coalesce((select destination_agent from wr), '')
          ~* ('gloval.*' || lower((select office from me)))
      and (
        -- Su cliente directo: siempre.
        exists (select 1 from mc where mc.customer_service_id = (select id from me))
        or (
          -- Las ramas amplias (cartera de ejecutivas + huérfanos sin dueño)
          -- NO aplican a la posición inhouse: en la oficina del cliente solo
          -- se ve lo de ESE cliente.
          not coalesce((select es_inhouse from me), false)
          and (
            exists (select 1 from mc where mc.assigned_to = (select id from me))
            or exists (select 1 from mc where mc.assigned_to in (select * from public.app_cs_executives()))
            or exists (select 1 from mc where mc.assigned_to in (select * from public.app_cs_executives_full()))
            or not exists (
              select 1 from mc
              where mc.customer_service_id is not null or mc.assigned_to is not null
            )
          )
        )
      )
    );
$function$;

CREATE OR REPLACE FUNCTION public.app_cs_client_ids()
 RETURNS SETOF uuid
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select c.id
    from public.clients c
   where c.deleted_at is null
     and c.customer_service_id = public.app_current_user_id();
$function$;

CREATE OR REPLACE FUNCTION public.app_cs_clientes_habilitados()
 RETURNS SETOF uuid
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select h.client_id
  from cs_cuentas_habilitadas h
  join clients c on c.id = h.client_id
  where h.cs_user_id = app_current_user_id()
    and h.active
    and c.deleted_at is null;
$function$;

CREATE OR REPLACE FUNCTION public.app_cs_executives()
 RETURNS SETOF uuid
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select sales_executive_id from public.cs_assignments ca
  join public.users u on u.id = ca.cs_user_id
  where u.auth_user_id = auth.uid() and ca.active;
$function$;

CREATE OR REPLACE FUNCTION public.app_cs_executives_full()
 RETURNS SETOF uuid
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select sales_executive_id from public.cs_assignments ca
  join public.users u on u.id = ca.cs_user_id
  where u.auth_user_id = auth.uid() and ca.active and ca.full_cartera;
$function$;

CREATE OR REPLACE FUNCTION public.app_cs_sees_directos()
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select exists (
    select 1
    from public.cs_assignments ca
    join public.users u on u.id = ca.cs_user_id
    where u.auth_user_id = auth.uid()
      and ca.is_directos = true
      and coalesce(ca.active, true) = true
  );
$function$;

CREATE OR REPLACE FUNCTION public.app_cs_ventas_executives()
 RETURNS SETOF uuid
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  with yo as (
    select u.id, u.office, coalesce(u.cs_all_execs, false) as todas
      from public.users u
     where u.auth_user_id = auth.uid()
     limit 1
  )
  -- Las asignaciones de siempre (incluye la fila DIRECTOS, cuyo
  -- sales_executive_id es NULL — se conserva el comportamiento anterior).
  select ca.sales_executive_id
    from public.cs_assignments ca
    join yo on ca.cs_user_id = yo.id
   where ca.active
  union
  -- Y, solo con el flag prendido, la misma lista que arma el desplegable:
  -- misma condición que `carteraAmpliada` en el frontend, para que la lista y
  -- la llave no puedan volver a separarse.
  select e.id
    from public.users e, yo
   where yo.todas
     and e.status = 'Active'
     and (yo.office is null or e.office = yo.office)
     and (e.role = 'Sales Executive' or e.is_junior_exec is true);
$function$;

CREATE OR REPLACE FUNCTION public.app_current_user_id()
 RETURNS uuid
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select id from public.users where auth_user_id = auth.uid() limit 1;
$function$;

CREATE OR REPLACE FUNCTION public.app_current_user_office()
 RETURNS text
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select office from public.users where auth_user_id = auth.uid() limit 1;
$function$;

CREATE OR REPLACE FUNCTION public.app_current_user_role()
 RETURNS text
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select role from public.users where auth_user_id = auth.uid() limit 1;
$function$;

CREATE OR REPLACE FUNCTION public.app_delegation_owners()
 RETURNS SETOF uuid
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select d.owner_user_id
    from public.user_delegations d
    join public.users me on me.id = d.viewer_user_id
   where me.auth_user_id = auth.uid()
     and d.owner_user_id is not null;
$function$;

CREATE OR REPLACE FUNCTION public.app_embarque_bloqueo_ops(p_shipment_id uuid)
 RETURNS text
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_rol text := app_current_user_role();
  v_nombre text;
  v_cuando timestamptz;
begin
  if auth.uid() is null or coalesce(v_rol, '') not in ('Customer Service', 'Sales Executive', 'Sales') then
    return null;
  end if;

  select u.name, t.received_at
    into v_nombre, v_cuando
    from ops_transfers t
    left join users u on u.id = t.received_by
   where t.shipment_id = p_shipment_id
     and t.handoff_estado = 'ACEPTADO';
  if not found then
    return null;
  end if;

  return 'Este embarque fue transferido a Operaciones y ya fue aceptado'
      || coalesce(' por ' || v_nombre, '')
      || coalesce(' el ' || to_char(v_cuando at time zone 'America/Guayaquil', 'DD/MM/YYYY'), '')
      || '. No puede ser modificado: cualquier cambio pídeselo a Operaciones.';
end $function$;

CREATE OR REPLACE FUNCTION public.app_finanzas_can_grant()
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
  select exists (
    select 1 from finanzas_access fa
    join users u on u.id = fa.user_id
    where u.auth_user_id = auth.uid() and fa.can_grant
  )
$function$;

CREATE OR REPLACE FUNCTION public.app_finanzas_offices()
 RETURNS text[]
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
  select case
    when exists (
      select 1 from finanzas_access fa join users u on u.id = fa.user_id
      where u.auth_user_id = auth.uid() and fa.office_code = 'ALL'
    ) then array['USA','ECU','PAN','PER','HOLDING']
    else coalesce((
      select array_agg(fa.office_code) from finanzas_access fa
      join users u on u.id = fa.user_id
      where u.auth_user_id = auth.uid()
    ), '{}')
  end
$function$;

CREATE OR REPLACE FUNCTION public.app_fix_wr_item_location()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  if new.description ~ '^[0-9]{1,3}-[0-9]{1,3}-[0-9]{1,3}$' then
    new.warehouse_zone := new.description;
    new.description := null;
    new.item_description := null;
  end if;
  return new;
end;
$function$;

CREATE OR REPLACE FUNCTION public.app_get_shipment_pba(p_shipment_id uuid)
 RETURNS TABLE(pba_amount numeric, pba_status text, pba_currency text)
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select s.pba_amount, s.pba_status::text, s.pba_currency
  from public.shipments s
  where s.id = p_shipment_id
    and public.app_can_see_pba();
$function$;

CREATE OR REPLACE FUNCTION public.app_protect_pba_fields()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  if not public.app_can_see_pba() then
    if tg_op = 'UPDATE' then
      new.pba_amount := old.pba_amount;
      new.pba_status := old.pba_status;
      new.pba_currency := old.pba_currency;
    else
      new.pba_amount := null;
      new.pba_status := null;
      new.pba_currency := null;
    end if;
  end if;
  return new;
end;
$function$;

CREATE OR REPLACE FUNCTION public.app_user_has_operaciones()
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select public.app_can('operaciones', 'view')
      or public.app_can('operaciones.export', 'view')
      or public.app_can('operaciones.import', 'view')
      or public.app_can('operaciones.air', 'view')
      or public.app_can('operaciones.warehouse', 'view');
$function$;

CREATE OR REPLACE FUNCTION public.app_user_is_admin()
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select exists (select 1 from public.users where auth_user_id = auth.uid() and role in ('Admin','VP'));
$function$;

CREATE OR REPLACE FUNCTION public.app_user_is_manager()
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select exists (select 1 from public.users where auth_user_id = auth.uid() and role = 'Manager');
$function$;

CREATE OR REPLACE FUNCTION public.app_user_is_ops()
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select exists (
    select 1 from public.users
    where auth_user_id = auth.uid()
      and lower(email) in ('ops@glovalecuador.com','ops1@glovalecuador.com','ops2@glovalecuador.com')
  );
$function$;

CREATE OR REPLACE FUNCTION public.app_wh_is_pool(p_wr_number text, p_client_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  with wr as (
    select consignee_normalized
    from public.magaya_warehouse_receipts
    where wr_number = p_wr_number
    order by last_full_fetch_at desc nulls last
    limit 1
  ),
  mc as (
    select c.customer_service_id, c.assigned_to
    from public.clients c, wr
    where c.deleted_at is null
      and (
        (p_client_id is not null and c.id = p_client_id)
        or (
          c.company_name_normalized is not null
          and length(c.company_name_normalized) >= 5
          and wr.consignee_normalized is not null
          and (
            c.company_name_normalized = wr.consignee_normalized
            or wr.consignee_normalized like c.company_name_normalized || ' %'
            or c.company_name_normalized like wr.consignee_normalized || ' %'
          )
        )
      )
  )
  select not exists (
    select 1 from mc where mc.customer_service_id is not null or mc.assigned_to is not null
  );
$function$;

CREATE OR REPLACE FUNCTION public.aria_log_rfq(p_office_id text, p_sender_email text, p_sender_name text DEFAULT NULL::text, p_origin text DEFAULT NULL::text, p_destination text DEFAULT NULL::text, p_service_type text DEFAULT NULL::text, p_cargo_description text DEFAULT NULL::text, p_weight_kg numeric DEFAULT NULL::numeric, p_volume_cbm numeric DEFAULT NULL::numeric, p_dimensions text DEFAULT NULL::text, p_pieces integer DEFAULT NULL::integer, p_status text DEFAULT 'pending'::text, p_notes text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_catalog'
AS $function$
DECLARE
  new_id uuid;
BEGIN
  INSERT INTO rfq_log (
    office_id, sender_email, sender_name,
    origin, destination, service_type,
    cargo_description, weight_kg, volume_cbm,
    dimensions, pieces, status, notes
  ) VALUES (
    p_office_id, p_sender_email, p_sender_name,
    p_origin, p_destination, p_service_type,
    p_cargo_description, p_weight_kg, p_volume_cbm,
    p_dimensions, p_pieces, p_status, p_notes
  )
  RETURNING id INTO new_id;

  RETURN jsonb_build_object('success', true, 'rfq_id', new_id::text);
EXCEPTION WHEN OTHERS THEN
  RETURN jsonb_build_object('success', false, 'error', SQLERRM);
END;
$function$;

CREATE OR REPLACE FUNCTION public.aria_search_agents(p_country text DEFAULT NULL::text, p_port text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_catalog'
AS $function$
BEGIN
  RETURN (
    SELECT COALESCE(jsonb_agg(row_to_json(q)::jsonb), '[]'::jsonb)
    FROM (
      SELECT
        company_name,
        contact_name,
        email,
        phone,
        country,
        port,
        notes
      FROM agents
      WHERE active = true
        AND (p_country IS NULL OR country ILIKE '%' || p_country || '%')
        AND (p_port IS NULL OR port ILIKE '%' || p_port || '%')
      ORDER BY company_name
    ) q
  );
END;
$function$;

CREATE OR REPLACE FUNCTION public.aria_search_air_rates(p_origin text, p_destination text, p_office text DEFAULT 'PER'::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_catalog'
AS $function$
BEGIN
  RETURN (
    SELECT COALESCE(jsonb_agg(row_to_json(q)::jsonb), '[]'::jsonb)
    FROM (
      SELECT
        ac.name AS carrier,
        ac.code AS carrier_code,
        ar.origin_code,
        ar.destination_code,
        ar.cargo_type,
        ar.minimum_rate,
        ar.rate_minus45,
        ar.rate_45,
        ar.rate_100,
        ar.rate_300,
        ar.rate_500,
        ar.rate_1000,
        ar.rate_2000,
        ar.rate_3000,
        ar.rate_4000,
        ar.rate_5000,
        ar.cha_fee,
        ar.soa_fee,
        ar.awa_fee,
        ar.airline_fees,
        ar.max_dimensions,
        ar.max_weight_per_piece,
        ar.effective_date,
        ar.expiry_date,
        ar.scope,
        ar.notes
      FROM air_rates ar
      JOIN air_carriers ac ON ac.id = ar.air_carrier_id
      WHERE ar.origin_code = p_origin
        AND ar.destination_code = p_destination
        AND (ar.expiry_date IS NULL OR ar.expiry_date >= current_date)
        AND ar.active = true
        AND (ar.scope = 'global' OR ar.scope = p_office)
      ORDER BY ar.expiry_date DESC NULLS LAST
    ) q
  );
END;
$function$;

CREATE OR REPLACE FUNCTION public.aria_search_ocean_rates(p_origin text, p_destination text, p_office text DEFAULT 'PER'::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'public', 'pg_catalog'
AS $function$
DECLARE
  v_rates jsonb;
  v_unified jsonb;
  v_origin_name text;
  v_dest_name text;
BEGIN

  -- Obtener nombres de puertos
  SELECT name INTO v_origin_name FROM ports WHERE code = p_origin LIMIT 1;
  SELECT name INTO v_dest_name FROM ports WHERE code = p_destination LIMIT 1;

  -- Fuente 1: tabla rates con transit_times
  SELECT COALESCE(jsonb_agg(jsonb_build_object(
    'carrier', c.name,
    'carrier_code', c.code,
    'equipment_type', et.code,
    'equipment_name', et.name,
    'base_rate', r.base_rate,
    'currency', r.currency,
    'service_type', r.service_type,
    'effective_date', r.effective_date,
    'expiry_date', r.expiry_date,
    'transit_days', tt.transit_days,
    'service_name', tt.service_name,
    'frequency', tt.frequency,
    'transit_notes', tt.notes,
    'origin_port', op.code,
    'origin_name', op.name,
    'destination_port', dp.code,
    'destination_name', dp.name,
    'source', 'rates'
  )), '[]'::jsonb)
  INTO v_rates
  FROM rates r
  JOIN freight_routes fr ON fr.id = r.route_id
  JOIN ports op ON op.id = fr.origin_port_id
  JOIN ports dp ON dp.id = fr.destination_port_id
  JOIN equipment_types et ON et.id = r.equipment_type_id
  JOIN contracts ct ON ct.id = r.contract_id
  JOIN carriers c ON c.id = ct.carrier_id
  LEFT JOIN transit_times tt ON tt.carrier_id = ct.carrier_id
    AND tt.origin_port_id = fr.origin_port_id
    AND tt.destination_port_id = fr.destination_port_id
    AND tt.active = true
  WHERE op.code = p_origin
    AND dp.code = p_destination
    AND (r.expiry_date IS NULL OR r.expiry_date >= current_date)
    AND r.active = true
    AND (r.scope = 'global' OR r.scope = p_office);

  -- Fuente 2: unified_rates con transit_times
  SELECT COALESCE(jsonb_agg(jsonb_build_object(
    'carrier', ur.carrier,
    'rate_20gp', ur.rate_20gp,
    'rate_40st', ur.rate_40st,
    'rate_40hq', ur.rate_40hq,
    'rate_40nor', ur.rate_40nor,
    'free_days', ur.free_days,
    'effective_date', ur.effective_date,
    'expiry_date', ur.expiry_date,
    'transit_days', tt.transit_days,
    'service_name', tt.service_name,
    'frequency', tt.frequency,
    'transit_notes', tt.notes,
    'origin_port', p_origin,
    'origin_name', ur.pol,
    'destination_port', p_destination,
    'destination_name', ur.pod,
    'agent', ur.agent,
    'notes', ur.notes,
    'source', 'unified_rates'
  )), '[]'::jsonb)
  INTO v_unified
  FROM unified_rates ur
  LEFT JOIN carriers c ON c.name ILIKE '%' || split_part(ur.carrier, ' ', 1) || '%'
  LEFT JOIN transit_times tt ON tt.carrier_id = c.id
    AND tt.origin_port_id = (SELECT id FROM ports WHERE code = p_origin LIMIT 1)
    AND tt.destination_port_id = (SELECT id FROM ports WHERE code = p_destination LIMIT 1)
    AND tt.active = true
  WHERE (
    ur.pol ILIKE '%' || p_origin || '%'
    OR ur.pol ILIKE '%' || COALESCE(v_origin_name, p_origin) || '%'
    OR COALESCE(v_origin_name, p_origin) ILIKE '%' || ur.pol || '%'
  )
  AND (
    ur.pod ILIKE '%' || p_destination || '%'
    OR ur.pod ILIKE '%' || COALESCE(v_dest_name, p_destination) || '%'
    OR COALESCE(v_dest_name, p_destination) ILIKE '%' || ur.pod || '%'
  )
  AND (ur.expiry_date IS NULL OR ur.expiry_date >= current_date);

  RETURN COALESCE(v_rates, '[]'::jsonb) || COALESCE(v_unified, '[]'::jsonb);

END;
$function$;

CREATE OR REPLACE FUNCTION public.assign_next_badge(p_office text)
 RETURNS TABLE(id uuid, label text)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_id uuid;
  v_label text;
begin
  select b.id, b.label into v_id, v_label
  from public.visitor_badges b
  where b.office = p_office and b.status = 'available'
  order by b.badge_number nulls last, b.label
  for update skip locked
  limit 1;

  if v_id is null then
    return;
  end if;

  update public.visitor_badges set status = 'in_use' where visitor_badges.id = v_id;
  return query select v_id, v_label;
end;
$function$;

CREATE OR REPLACE PROCEDURE public.backfill_wr_matches(IN p_batch_size integer DEFAULT 2000, IN p_max_batches integer DEFAULT 200)
 LANGUAGE plpgsql
 SET search_path TO 'public', 'pg_catalog'
AS $procedure$
declare
  v_processed int;
  v_total int := 0;
  v_batch int := 0;
begin
  loop
    v_batch := v_batch + 1;
    exit when v_batch > p_max_batches;

    with batch as (
      select wr.id from public.magaya_warehouse_receipts wr
      where wr.status = 'OnHand'
        and public.wr_is_gloval_usa(wr.issued_by)
        and wr.consignee is not null and wr.consignee <> ''
        and not exists (select 1 from public.wr_match_results r where r.wr_id = wr.id)
      limit p_batch_size
    )
    select count(*) into v_processed
    from (select public.match_wr(id) from batch) x;

    v_total := v_total + v_processed;
    commit;
    exit when v_processed = 0;
  end loop;
end $procedure$;

CREATE OR REPLACE FUNCTION public.bulk_sync_wr_items_to_wh_report(p_client_consignee text DEFAULT NULL::text)
 RETURNS TABLE(processed integer, movements_created integer, items_created integer, unmapped integer)
 LANGUAGE plpgsql
 SET search_path TO 'public', 'pg_catalog'
AS $function$
DECLARE
  v_processed int := 0;
  v_movements int := 0;
  v_items int := 0;
  v_unmapped int := 0;
  r RECORD;
  v_client_id uuid;
  v_movement_id uuid;
  v_product_id uuid;
BEGIN
  FOR r IN 
    SELECT wi.id, wi.wr_id, wi.wr_number, wi.item_description, wi.quantity, wi.container_number,
           wr.consignee, wr.created_on, wr.pieces, wr.tracking_number
    FROM magaya_wr_items wi
    JOIN magaya_warehouse_receipts wr ON wr.id = wi.wr_id
    WHERE (p_client_consignee IS NULL OR wr.consignee = p_client_consignee)
    ORDER BY wr.created_on, wi.wr_number
  LOOP
    v_processed := v_processed + 1;
    
    -- Find client
    SELECT id INTO v_client_id FROM wh_report_clients 
    WHERE active = true AND r.consignee ILIKE consignee_name LIMIT 1;
    
    IF v_client_id IS NULL THEN CONTINUE; END IF;
    
    -- Find or create movement
    SELECT id INTO v_movement_id FROM wh_report_movements WHERE magaya_wr_id = r.wr_id;
    IF v_movement_id IS NULL THEN
      INSERT INTO wh_report_movements (client_id, date, movement_type, reference_number, container_number, total_pallets, source, magaya_wr_id)
      VALUES (v_client_id, COALESCE(r.created_on, CURRENT_DATE), 'IN', r.wr_number, COALESCE(r.container_number, r.tracking_number), r.pieces, 'magaya_auto', r.wr_id)
      RETURNING id INTO v_movement_id;
      v_movements := v_movements + 1;
    END IF;
    
    -- Map product
    SELECT pm.product_id INTO v_product_id FROM wh_report_product_mappings pm
    WHERE pm.client_id = v_client_id AND pm.active = true AND r.item_description ILIKE pm.magaya_pattern
    ORDER BY pm.priority DESC LIMIT 1;
    
    IF v_product_id IS NOT NULL AND r.quantity > 0 THEN
      IF NOT EXISTS (SELECT 1 FROM wh_report_movement_items WHERE movement_id = v_movement_id AND product_id = v_product_id) THEN
        INSERT INTO wh_report_movement_items (movement_id, product_id, quantity) VALUES (v_movement_id, v_product_id, r.quantity::integer);
        v_items := v_items + 1;
      END IF;
    ELSIF r.item_description IS NOT NULL THEN
      v_unmapped := v_unmapped + 1;
    END IF;
  END LOOP;
  
  RETURN QUERY SELECT v_processed, v_movements, v_items, v_unmapped;
END;
$function$;

CREATE OR REPLACE FUNCTION public.bulk_upsert_charges(p_company_id uuid, p_data jsonb)
 RETURNS integer
 LANGUAGE plpgsql
 SET search_path TO 'public', 'pg_catalog'
AS $function$
DECLARE
  affected integer;
BEGIN
  -- Delete existing charges for transactions being updated, then re-insert
  DELETE FROM magaya_transaction_charges
  WHERE company_id = p_company_id
    AND transaction_id IN (
      SELECT DISTINCT t.id FROM magaya_transactions t
      WHERE t.company_id = p_company_id
        AND t.magaya_guid IN (SELECT DISTINCT elem->>'tx_guid' FROM jsonb_array_elements(p_data) elem)
    );

  INSERT INTO magaya_transaction_charges (
    id, company_id, transaction_id, charge_code, charge_description, charge_type,
    amount, currency_code, exchange_rate, amount_in_home_currency,
    account_name, account_number, entity_name, is_prepaid, created_at
  )
  SELECT
    gen_random_uuid(), p_company_id,
    t.id,
    elem->>'code',
    elem->>'description',
    elem->>'charge_type',
    COALESCE((elem->>'amount')::numeric, 0),
    COALESCE(elem->>'currency', 'USD'),
    CASE WHEN elem->>'exchange_rate' IS NOT NULL THEN (elem->>'exchange_rate')::numeric ELSE NULL END,
    CASE WHEN elem->>'home_amount' IS NOT NULL THEN (elem->>'home_amount')::numeric ELSE NULL END,
    elem->>'acct_name',
    elem->>'acct_number',
    elem->>'entity_name',
    COALESCE((elem->>'prepaid')::boolean, false),
    NOW()
  FROM jsonb_array_elements(p_data) AS elem
  JOIN magaya_transactions t ON t.company_id = p_company_id AND t.magaya_guid = elem->>'tx_guid';
  GET DIAGNOSTICS affected = ROW_COUNT;
  RETURN affected;
END;
$function$;

CREATE OR REPLACE FUNCTION public.bulk_upsert_entities(p_company_id uuid, p_data jsonb)
 RETURNS integer
 LANGUAGE plpgsql
 SET search_path TO 'public', 'pg_catalog'
AS $function$
DECLARE
  inserted_count integer;
BEGIN
  INSERT INTO magaya_entities (id, company_id, magaya_guid, entity_type, name, code, tax_id, email, phone, address_line1, is_active, synced_at, created_at, updated_at)
  SELECT DISTINCT ON (g)
    gen_random_uuid(), p_company_id, g, t, n, c, ti, e, p, a,
    true, NOW(), NOW(), NOW()
  FROM (
    SELECT
      elem->>'g' as g,
      elem->>'t' as t,
      elem->>'n' as n,
      elem->>'c' as c,
      elem->>'ti' as ti,
      elem->>'e' as e,
      elem->>'p' as p,
      elem->>'a' as a,
      ord
    FROM jsonb_array_elements(p_data) WITH ORDINALITY AS x(elem, ord)
  ) src
  ORDER BY g, ord
  ON CONFLICT (company_id, magaya_guid) DO UPDATE SET
    entity_type = EXCLUDED.entity_type,
    name = EXCLUDED.name,
    code = EXCLUDED.code,
    tax_id = EXCLUDED.tax_id,
    email = EXCLUDED.email,
    phone = EXCLUDED.phone,
    address_line1 = EXCLUDED.address_line1,
    synced_at = NOW(),
    updated_at = NOW();
  GET DIAGNOSTICS inserted_count = ROW_COUNT;
  RETURN inserted_count;
END;
$function$;

CREATE OR REPLACE FUNCTION public.bulk_upsert_transactions(p_company_id uuid, p_data jsonb)
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  affected integer;
BEGIN
  INSERT INTO magaya_transactions (
    id, company_id, magaya_guid, transaction_type, transaction_number, reference_number,
    status, direction, created_on, issued_date, due_date,
    currency_code, total_amount, total_amount_usd, tax_amount,
    mode_of_transport, origin_port, destination_port,
    shipper_name, consignee_name, carrier_name,
    master_bl, house_bl, booking_number,
    total_pieces, total_weight, weight_unit, total_volume, volume_unit,
    billing_client_name, billing_client_guid,
    account_number, account_name,
    version, created_by_name, raw_xml,
    synced_at, created_at, updated_at
  )
  SELECT DISTINCT ON (guid)
    gen_random_uuid(), p_company_id,
    guid, type, number, ref_number, status, direction,
    created_on_ts, issued_date_d, due_date_d,
    currency, total_amount_n, total_amount_usd_n, tax_amount_n,
    transport_mode, origin, destination,
    shipper, consignee, carrier,
    master_bl, house_bl, booking,
    pieces_i, weight_n, weight_unit, volume_n, volume_unit,
    client_name, client_guid, acct_number, acct_name,
    version_i, created_by, raw_xml,
    NOW(), NOW(), NOW()
  FROM (
    SELECT
      elem->>'guid'                 AS guid,
      elem->>'type'                 AS type,
      elem->>'number'               AS number,
      elem->>'ref_number'           AS ref_number,
      elem->>'status'               AS status,
      elem->>'direction'            AS direction,
      CASE WHEN elem->>'created_on'  IS NOT NULL THEN (elem->>'created_on')::timestamptz END  AS created_on_ts,
      CASE WHEN elem->>'issued_date' IS NOT NULL THEN (elem->>'issued_date')::date END        AS issued_date_d,
      CASE WHEN elem->>'due_date'    IS NOT NULL THEN (elem->>'due_date')::date END           AS due_date_d,
      COALESCE(elem->>'currency', 'USD')                          AS currency,
      COALESCE((elem->>'total_amount')::numeric, 0)               AS total_amount_n,
      CASE WHEN elem->>'total_amount_usd' IS NOT NULL THEN (elem->>'total_amount_usd')::numeric END AS total_amount_usd_n,
      CASE WHEN elem->>'tax_amount' IS NOT NULL THEN (elem->>'tax_amount')::numeric END       AS tax_amount_n,
      elem->>'transport_mode'       AS transport_mode,
      elem->>'origin'               AS origin,
      elem->>'destination'          AS destination,
      elem->>'shipper'              AS shipper,
      elem->>'consignee'            AS consignee,
      elem->>'carrier'              AS carrier,
      elem->>'master_bl'            AS master_bl,
      elem->>'house_bl'             AS house_bl,
      elem->>'booking'              AS booking,
      CASE WHEN elem->>'pieces' IS NOT NULL THEN (elem->>'pieces')::int END   AS pieces_i,
      CASE WHEN elem->>'weight' IS NOT NULL THEN (elem->>'weight')::numeric END AS weight_n,
      elem->>'weight_unit'          AS weight_unit,
      CASE WHEN elem->>'volume' IS NOT NULL THEN (elem->>'volume')::numeric END AS volume_n,
      elem->>'volume_unit'          AS volume_unit,
      elem->>'client_name'          AS client_name,
      elem->>'client_guid'          AS client_guid,
      elem->>'acct_number'          AS acct_number,
      elem->>'acct_name'            AS acct_name,
      CASE WHEN elem->>'version' IS NOT NULL THEN (elem->>'version')::int END AS version_i,
      elem->>'created_by'           AS created_by,
      elem->>'raw_xml'              AS raw_xml,
      ord
    FROM jsonb_array_elements(p_data) WITH ORDINALITY AS t(elem, ord)
  ) src
  ORDER BY guid, ord
  ON CONFLICT (company_id, magaya_guid) DO UPDATE SET
    transaction_number  = EXCLUDED.transaction_number,
    status              = EXCLUDED.status,
    created_on          = EXCLUDED.created_on,
    issued_date         = EXCLUDED.issued_date,
    due_date            = EXCLUDED.due_date,
    total_amount        = EXCLUDED.total_amount,
    total_amount_usd    = EXCLUDED.total_amount_usd,
    tax_amount          = EXCLUDED.tax_amount,
    currency_code       = EXCLUDED.currency_code,
    billing_client_name = EXCLUDED.billing_client_name,
    billing_client_guid = EXCLUDED.billing_client_guid,
    created_by_name     = EXCLUDED.created_by_name,
    shipper_name        = EXCLUDED.shipper_name,
    consignee_name      = EXCLUDED.consignee_name,
    carrier_name        = EXCLUDED.carrier_name,
    raw_xml             = COALESCE(EXCLUDED.raw_xml, magaya_transactions.raw_xml),
    synced_at           = NOW(),
    updated_at          = NOW();
  GET DIAGNOSTICS affected = ROW_COUNT;
  RETURN affected;
END;
$function$;

CREATE OR REPLACE FUNCTION public.calculate_total_hours()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
BEGIN
IF NEW.clock_out_time IS NOT NULL AND OLD.clock_out_time IS NULL THEN
NEW.total_hours := EXTRACT(EPOCH FROM (NEW.clock_out_time - NEW.clock_in_time)) / 3600;
NEW.updated_at := now();
END IF;
RETURN NEW;
END;
$function$;

CREATE OR REPLACE FUNCTION public.can_modify_reference_data()
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
SELECT EXISTS (
SELECT 1
FROM public.users
WHERE auth_user_id = (SELECT auth.uid())
AND role IN ('Admin', 'Manager', 'Administration')
);
$function$;

CREATE OR REPLACE FUNCTION public.check_sync_health(p_max_age_hours integer DEFAULT 26)
 RETURNS json
 LANGUAGE plpgsql
 SET search_path TO 'public', 'pg_catalog'
AS $function$
DECLARE
  result json;
BEGIN
  WITH companies AS (
    SELECT id, code, name FROM magaya_companies WHERE code IN ('EC','PA','PE','US')
  ),
  freshness AS (
    SELECT c.code, c.name,
      (SELECT MAX(t.synced_at) FROM magaya_transactions t WHERE t.company_id = c.id) AS last_data,
      (SELECT l.status FROM magaya_sync_log l WHERE l.company_id = c.id ORDER BY l.started_at DESC LIMIT 1) AS last_log_status,
      (SELECT l.started_at FROM magaya_sync_log l WHERE l.company_id = c.id ORDER BY l.started_at DESC LIMIT 1) AS last_log_at
    FROM companies c
  ),
  evaluated AS (
    SELECT code, name, last_data, last_log_status, last_log_at,
      CASE
        WHEN last_data IS NULL OR last_data < NOW() - (p_max_age_hours || ' hours')::interval THEN false
        WHEN last_log_status IS DISTINCT FROM 'success' THEN false
        ELSE true
      END AS healthy
    FROM freshness
  )
  SELECT json_build_object(
    'checked_at', NOW(),
    'max_age_hours', p_max_age_hours,
    'all_ok', bool_and(healthy),
    'countries', json_agg(json_build_object(
      'code', code, 'name', name, 'healthy', healthy,
      'last_data_synced_at', last_data,
      'last_log_status', last_log_status,
      'last_log_at', last_log_at
    ) ORDER BY code),
    'problems', COALESCE((SELECT json_agg(json_build_object('code', code, 'reason',
        CASE WHEN last_data IS NULL THEN 'sin datos nunca sincronizados'
             WHEN last_data < NOW() - (p_max_age_hours || ' hours')::interval THEN 'datos viejos (>' || p_max_age_hours || 'h sin sincronizar, ultimo: ' || to_char(last_data,'YYYY-MM-DD HH24:MI') || ' UTC)'
             WHEN last_log_status IS DISTINCT FROM 'success' THEN 'ultimo log con status: ' || COALESCE(last_log_status,'(ninguno)')
             ELSE 'ok' END
      )) FROM evaluated WHERE NOT healthy), '[]'::json)
  ) INTO result FROM evaluated;
  RETURN result;
END;
$function$;

CREATE OR REPLACE FUNCTION public.christmas_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_old jsonb := case when tg_op in ('UPDATE','DELETE') then to_jsonb(old) else null end;
  v_new jsonb := case when tg_op in ('INSERT','UPDATE') then to_jsonb(new) else null end;
  v_uid uuid := auth.uid();
  v_rec text;
  v_changed text[];
begin
  v_rec := coalesce(
    v_new->>'id',               v_old->>'id',
    v_new->>'user_id',          v_old->>'user_id',
    v_new->>'destination_code', v_old->>'destination_code',
    v_new->>'key',              v_old->>'key'
  );
  if tg_op = 'UPDATE' then
    select array_agg(k) into v_changed
      from jsonb_object_keys(v_new) as k
     where (v_new -> k) is distinct from (v_old -> k) and k <> 'updated_at';
  end if;
  insert into public.christmas_audit_log
    (actor_id, actor_email, actor_role, table_name, operation, record_id, old_data, new_data, changed_cols)
  values (
    v_uid,
    (select email from public.christmas_user_profiles where user_id = v_uid),
    public.christmas_current_role(),
    tg_table_name, tg_op, v_rec, v_old, v_new, v_changed
  );
  return coalesce(new, old);
end;
$function$;

CREATE OR REPLACE FUNCTION public.christmas_bookings_set_nra()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  if new.nra_number is null or new.nra_number = '' then
    new.nra_number := public.christmas_generate_nra();
  end if;
  return new;
end; $function$;

CREATE OR REPLACE FUNCTION public.christmas_current_role()
 RETURNS text
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select coalesce(
    (select role from public.christmas_user_profiles where user_id = auth.uid()),
    'anon'
  );
$function$;

CREATE OR REPLACE FUNCTION public.christmas_current_tenant()
 RETURNS uuid
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select tenant_id from public.christmas_user_profiles where user_id = auth.uid();
$function$;

CREATE OR REPLACE FUNCTION public.christmas_effective_fee(p_tenant_id uuid, p_destination_code text)
 RETURNS numeric
 LANGUAGE sql
 STABLE
AS $function$
  select coalesce(
    (select fee_pct from public.christmas_fee_overrides
       where tenant_id = p_tenant_id and destination_code = p_destination_code),
    (select (value)::text::numeric from public.christmas_global_settings
       where tenant_id = p_tenant_id and key = 'gloval_fee_pct'),
    20
  );
$function$;

CREATE OR REPLACE FUNCTION public.christmas_generate_nra()
 RETURNS text
 LANGUAGE plpgsql
AS $function$
declare n bigint; yyyy text;
begin
  n := nextval('public.christmas_nra_seq');
  yyyy := to_char(now(), 'YYYY');
  return 'NRA-' || yyyy || '-' || lpad(n::text, 5, '0');
end; $function$;

CREATE OR REPLACE FUNCTION public.christmas_log_signin()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare p record;
begin
  select email, role into p
  from public.christmas_user_profiles
  where user_id = new.user_id;
  if found then
    insert into public.christmas_audit_log
      (occurred_at, actor_id, actor_email, actor_role, table_name, operation, record_id, new_data)
    values
      (coalesce(new.created_at, now()), new.user_id, p.email, p.role, 'sign_in', 'LOGIN', new.id::text,
       jsonb_build_object('ip', new.ip::text, 'user_agent', new.user_agent));
  end if;
  return new;
exception when others then
  return new;
end $function$;

CREATE OR REPLACE FUNCTION public.christmas_set_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin new.updated_at = now(); return new; end;
$function$;

CREATE OR REPLACE FUNCTION public.cl_depalletize_manifest_item(p_item_id uuid, p_carton_count integer, p_supervisor_pin text)
 RETURNS manifest_items
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_actor uuid := cl_warehouse_user_id();
  v_supervisor uuid;
  v_item manifest_items%ROWTYPE;
  v_warehouse uuid := cl_user_warehouse();
BEGIN
  IF v_actor IS NULL THEN
    RAISE EXCEPTION 'No autenticado como warehouse_user';
  END IF;
  IF p_carton_count IS NULL OR p_carton_count < 1 OR p_carton_count > 10000 THEN
    RAISE EXCEPTION 'Cantidad de cartones inválida (1-10000)';
  END IF;

  v_supervisor := cl_verify_supervisor_pin(p_supervisor_pin);
  IF v_supervisor IS NULL THEN
    RAISE EXCEPTION 'PIN de supervisor inválido';
  END IF;

  SELECT * INTO v_item FROM manifest_items WHERE id = p_item_id FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Item no existe';
  END IF;

  -- Same-warehouse check
  IF NOT EXISTS (
    SELECT 1
    FROM manifest_sources ms
    WHERE ms.id = v_item.manifest_source_id
      AND ms.warehouse_id = v_warehouse
  ) THEN
    RAISE EXCEPTION 'Item fuera de tu bodega';
  END IF;

  IF v_item.is_depalletized THEN
    RAISE EXCEPTION 'Item ya fue despaletizado (% cartones)', v_item.depalletized_carton_count;
  END IF;
  IF v_item.load_status = 'loaded' THEN
    RAISE EXCEPTION 'Item ya está cargado, no se puede despaletizar';
  END IF;

  UPDATE manifest_items
     SET is_depalletized = true,
         depalletized_carton_count = p_carton_count,
         depalletized_at = now(),
         depalletized_by = v_actor,
         depalletized_supervisor_id = v_supervisor,
         updated_at = now()
   WHERE id = p_item_id
   RETURNING * INTO v_item;

  RETURN v_item;
END;
$function$;

CREATE OR REPLACE FUNCTION public.cl_has_role(target_role warehouse_role)
 RETURNS boolean
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  SELECT target_role = ANY(coalesce(
    (SELECT wu.roles FROM warehouse_users wu
       JOIN users u ON u.id = wu.user_id
      WHERE u.auth_user_id = auth.uid()),
    '{}'::warehouse_role[]
  ))
$function$;

CREATE OR REPLACE FUNCTION public.cl_is_supervisor_or_manager()
 RETURNS boolean
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  SELECT cl_has_role('supervisor') OR cl_has_role('manager')
$function$;

CREATE OR REPLACE FUNCTION public.cl_set_pin(p_pin text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
DECLARE
  v_user_id uuid := cl_warehouse_user_id();
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'No autenticado como warehouse_user';
  END IF;
  IF p_pin IS NULL OR length(p_pin) < 4 OR length(p_pin) > 12 OR p_pin !~ '^[0-9]+$' THEN
    RAISE EXCEPTION 'PIN debe ser 4-12 dígitos numéricos';
  END IF;
  UPDATE warehouse_users
     SET pin_hash = extensions.crypt(p_pin, extensions.gen_salt('bf', 8)),
         updated_at = now()
   WHERE id = v_user_id;
END;
$function$;

CREATE OR REPLACE FUNCTION public.cl_touch_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN NEW.updated_at = now(); RETURN NEW; END $function$;

CREATE OR REPLACE FUNCTION public.cl_user_warehouse()
 RETURNS uuid
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  SELECT wu.warehouse_id FROM warehouse_users wu
    JOIN users u ON u.id = wu.user_id
   WHERE u.auth_user_id = auth.uid()
   LIMIT 1
$function$;

CREATE OR REPLACE FUNCTION public.cl_verify_supervisor_pin(p_pin text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions'
AS $function$
DECLARE
  v_warehouse_id uuid := cl_user_warehouse();
  v_supervisor_id uuid;
BEGIN
  IF v_warehouse_id IS NULL THEN
    RAISE EXCEPTION 'Usuario sin bodega asignada';
  END IF;
  IF p_pin IS NULL OR length(p_pin) < 4 THEN
    RETURN NULL;
  END IF;

  SELECT id INTO v_supervisor_id
  FROM warehouse_users
  WHERE warehouse_id = v_warehouse_id
    AND active = true
    AND pin_hash IS NOT NULL
    AND ('supervisor'::warehouse_role = ANY(roles) OR 'manager'::warehouse_role = ANY(roles))
    AND pin_hash = extensions.crypt(p_pin, pin_hash)
  LIMIT 1;

  RETURN v_supervisor_id;
END;
$function$;

CREATE OR REPLACE FUNCTION public.cl_warehouse_user_id()
 RETURNS uuid
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  SELECT wu.id FROM warehouse_users wu
    JOIN users u ON u.id = wu.user_id
   WHERE u.auth_user_id = auth.uid()
   LIMIT 1
$function$;

CREATE OR REPLACE FUNCTION public.clean_entity_name(n text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$
  select trim(
    regexp_replace(
      replace(replace(replace(replace(replace(replace(
        replace(n, '�', ' '),
        '&amp;', '&'), '&lt;', '<'), '&gt;', '>'), '&quot;', '"'), '&#39;', ''''), '&apos;', ''''),
      '\s+', ' ', 'g'
    )
  )
$function$;

CREATE OR REPLACE FUNCTION public.client_visit_to_activity()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_company text;
  v_outcome text;
BEGIN
  -- Only fire when status transitions INTO 'completed'
  IF NEW.status = 'completed' AND (TG_OP = 'INSERT' OR OLD.status IS DISTINCT FROM 'completed') THEN
    SELECT company_name INTO v_company FROM public.clients WHERE id = NEW.client_id;
    v_outcome := CASE NEW.outcome
      WHEN 'positiva'  THEN 'positive_moving_forward'
      WHEN 'neutral'   THEN 'neutral_follow_up'
      WHEN 'negativa'  THEN 'negative'
      WHEN 'reagendar' THEN 'neutral_follow_up'
      ELSE NULL END;

    INSERT INTO public.sales_activities (
      activity_date, activity_type, client_id, company_name,
      notes, office, outcome, sales_rep_id,
      follow_up_required, follow_up_date
    ) VALUES (
      COALESCE(NEW.completed_at, now()),
      'visit',
      NEW.client_id,
      v_company,
      NEW.report_notes,
      NEW.office,
      v_outcome,
      NEW.executive_id,
      NEW.follow_up_required,
      NEW.follow_up_date
    );
  END IF;
  RETURN NEW;
END; $function$;

CREATE OR REPLACE FUNCTION public.cmm_is_owner()
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public', 'auth'
AS $function$
  SELECT COALESCE(
    (auth.jwt() ->> 'email') = 'avaldano@glovalgroup.com',
    false
  );
$function$;

CREATE OR REPLACE FUNCTION public.cmm_senae_recency()
 RETURNS TABLE(cliente text, last_senae_date date, senae_30d bigint, senae_60d bigint, senae_90d bigint)
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
  IF NOT cmm_is_owner() THEN RETURN; END IF;
  RETURN QUERY
  WITH senae_recent AS (
    SELECT i.ec_company_name_norm, i.operation_date
    FROM mi_shipment_intel i
    WHERE i.operation_date >= (CURRENT_DATE - interval '100 days')
      AND i.ec_company_name_norm IS NOT NULL
  ), senae AS (
    SELECT DISTINCT normalize_company_name(t.cliente) AS cliente_norm, t.cliente
    FROM cmm_transactions t
    WHERE t.cliente IS NOT NULL AND t.cliente <> ''
  )
  SELECT s.cliente,
    max(i.operation_date) AS last_senae_date,
    count(*) FILTER (WHERE i.operation_date >= CURRENT_DATE - interval '30 days') AS senae_30d,
    count(*) FILTER (WHERE i.operation_date >= CURRENT_DATE - interval '60 days') AS senae_60d,
    count(*) FILTER (WHERE i.operation_date >= CURRENT_DATE - interval '90 days') AS senae_90d
  FROM senae s
  JOIN senae_recent i ON i.ec_company_name_norm = s.cliente_norm
  GROUP BY s.cliente;
END $function$;

CREATE OR REPLACE FUNCTION public.confirm_wr_match(p_wr_id uuid, p_client_id uuid, p_save_alias boolean DEFAULT true, p_user_id uuid DEFAULT NULL::uuid)
 RETURNS wr_match_results
 LANGUAGE plpgsql
 SET search_path TO 'public', 'pg_catalog'
AS $function$
declare
  v_wr public.magaya_warehouse_receipts;
  v_norm text;
  v_result public.wr_match_results;
begin
  if not exists (select 1 from public.clients c where c.id = p_client_id and c.deleted_at is null) then
    raise exception 'El cliente seleccionado no existe o está en la papelera';
  end if;
  select * into v_wr from public.magaya_warehouse_receipts where id = p_wr_id;
  v_norm := public.normalize_company_name(v_wr.consignee);
  if p_save_alias and coalesce(v_norm,'') <> '' then
    insert into public.consignee_aliases (alias_normalized, client_id, created_by)
    values (v_norm, p_client_id, p_user_id)
    on conflict do nothing;
  end if;
  update public.wr_match_results
     set status = 'CONFIRMED',
         matched_client_id = p_client_id,
         resolved_by = p_user_id,
         resolved_at = now(),
         updated_at = now()
   where wr_id = p_wr_id
   returning * into v_result;
  return v_result;
end $function$;

CREATE OR REPLACE FUNCTION public.consolidado_agente_excluido(p_agente text, p_destino text, p_consolidado_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
  select exists (
    select 1 from consolidado_agente_exclusiones e
    where upper(wh_decode_entities(e.agente))
        = upper(wh_decode_entities(coalesce(p_agente, '')))
      and upper(e.destino) = upper(p_destino)
      and (e.consolidado_id is null or e.consolidado_id = p_consolidado_id)
  );
$function$;

CREATE OR REPLACE FUNCTION public.consolidado_agente_excluir(p_agente text, p_destino text, p_consolidado_id uuid DEFAULT NULL::uuid, p_motivo text DEFAULT NULL::text)
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_agente text := wh_decode_entities(trim(p_agente));
  v_sacadas int;
begin
  if coalesce(v_agente, '') = '' then
    raise exception 'Falta el nombre del agente.';
  end if;

  insert into consolidado_agente_exclusiones
    (agente, destino, consolidado_id, motivo, creado_por)
  values (v_agente, upper(p_destino), p_consolidado_id, p_motivo, app_current_user_id())
  on conflict do nothing;

  if p_consolidado_id is null then
    update consolidado_agentes_destino
    set incluir = false
    where upper(wh_decode_entities(agente)) = upper(v_agente);
  end if;

  update consolidado_lineas l
  set estado = 'EXCLUIDO',
      -- Se CONSERVA el prefijo 'auto' para que la línea siga siendo elegible
      -- para el sync si mañana se reactiva.
      notas = coalesce(l.notas || ' · ', '')
              || 'Fuera: ' || coalesce(nullif(trim(p_motivo), ''),
                                       'el agente no despacha a este consolidado') || '.',
      updated_at = now()
  from consolidados c
  where c.id = l.consolidado_id
    and c.estado = 'ABIERTO'
    and (p_consolidado_id is null or c.id = p_consolidado_id)
    and upper(c.destino) = upper(p_destino)
    and upper(wh_decode_entities(coalesce(l.agente_destino, ''))) = upper(v_agente)
    and l.estado in ('DISPONIBLE', 'AVISADO', 'INSTRUIDO')
    and l.contenedor_id is null;   -- lo ya cargado no se toca

  get diagnostics v_sacadas = row_count;

  -- Los borradores de aviso de ese agente se van con la carga. Los ya ENVIADOS
  -- no se tocan: son un hecho histórico, no un borrador.
  delete from consolidado_avisos a
  using consolidados c
  where c.id = a.consolidado_id
    and c.estado = 'ABIERTO'
    and a.status = 'DRAFT'
    and (p_consolidado_id is null or c.id = p_consolidado_id)
    and upper(c.destino) = upper(p_destino)
    and upper(wh_decode_entities(coalesce(a.cliente_key, ''))) = upper(v_agente);

  return v_sacadas;
end; $function$;

CREATE OR REPLACE FUNCTION public.consolidado_agente_incluir(p_agente text, p_destino text, p_pais text DEFAULT NULL::text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare v_agente text := wh_decode_entities(trim(p_agente));
begin
  if coalesce(v_agente, '') = '' then
    raise exception 'Falta el nombre del agente.';
  end if;

  insert into consolidado_agentes_destino (agente, pais, incluir)
  values (v_agente, coalesce(p_pais, 'EC'), true)
  on conflict (agente) do update set incluir = true,
    pais = coalesce(excluded.pais, consolidado_agentes_destino.pais);

  delete from consolidado_agente_exclusiones e
  where upper(wh_decode_entities(e.agente)) = upper(v_agente)
    and upper(e.destino) = upper(p_destino);
end; $function$;

CREATE OR REPLACE FUNCTION public.consolidado_agente_reactivar(p_agente text, p_destino text, p_consolidado_id uuid DEFAULT NULL::uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare v_agente text := wh_decode_entities(trim(p_agente));
begin
  delete from consolidado_agente_exclusiones e
  where upper(wh_decode_entities(e.agente)) = upper(v_agente)
    and upper(e.destino) = upper(p_destino)
    and (p_consolidado_id is null or e.consolidado_id is not distinct from p_consolidado_id);
end; $function$;

CREATE OR REPLACE FUNCTION public.consolidado_asignar_contenedor(p_linea_ids uuid[], p_contenedor_id uuid)
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_id uuid;
  n    int := 0;
begin
  if not (app_can('operaciones', 'edit')
       or coalesce(auth.role(), '') = 'service_role'
       or session_user in ('postgres', 'supabase_admin')) then
    raise exception 'no autorizado: hace falta permiso de editar en Operaciones';
  end if;

  foreach v_id in array coalesce(p_linea_ids, '{}'::uuid[]) loop
    -- Lo que ya está en ese destino (o se fundió con otra parte del mismo lote)
    -- se salta.
    if exists (select 1 from consolidado_lineas
                where id = v_id and contenedor_id is distinct from p_contenedor_id) then
      perform consolidado_mover_carga(v_id, p_contenedor_id, null, null);
      n := n + 1;
    end if;
  end loop;
  return n;
end;
$function$;

CREATE OR REPLACE FUNCTION public.consolidado_avisos_firma(p_consolidado uuid)
 RETURNS text
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select md5(
    coalesce((
      select string_agg(
               concat_ws('|', l.wr_number, l.estado, l.piezas, l.peso_lb, l.volumen_cft,
                         l.consignee, l.agente_destino, l.cs_email, l.hazmat, l.por_llegar,
                         l.origen_oficina),
               E'\n' order by l.wr_number, l.id)
      from consolidado_lineas l
      where l.consolidado_id = p_consolidado
        and l.estado not in ('EXCLUIDO', 'RODADO', 'SALIO_BODEGA')
    ), '')
    || '#' ||
    coalesce((
      select string_agg(concat_ws('|', h.linea_id, h.un_number, h.imo_class, h.doc_recibido),
                        E'\n' order by h.linea_id, h.un_number, h.imo_class)
      from consolidado_linea_hazmat h
      where h.consolidado_id = p_consolidado
    ), '')
  );
$function$;

CREATE OR REPLACE FUNCTION public.consolidado_avisos_touch()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin new.updated_at = now(); return new; end $function$;

CREATE OR REPLACE FUNCTION public.consolidado_cargar_disponibles(p_consolidado_id uuid)
 RETURNS TABLE(agregados integer, ya_estaban integer)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare v_agregados int := 0; v_previos int;
begin
  select count(*) into v_previos from consolidado_lineas where consolidado_id = p_consolidado_id;

  insert into consolidado_lineas (
    consolidado_id, wr_number, consignee, shipper, cs_email,
    piezas, peso_lb, volumen_cft, estado
  )
  select
    p_consolidado_id, w.wr_number, w.consignee, w.shipper,
    (select c.cs_email from client_notify_contacts c
      where c.cs_email is not null
        and length(split_part(upper(c.consignee_hint), ' (', 1)) >= 3
        and upper(w.consignee) like '%' || split_part(upper(c.consignee_hint), ' (', 1) || '%'
      limit 1),
    w.pieces, w.weight, w.volume_cft, 'DISPONIBLE'
  from magaya_warehouse_receipts w
  join consolidado_agentes_destino a
    on a.agente = w.destination_agent and a.incluir = true
  where w.status = 'OnHand'
    and w.out_date is null
    and w.last_full_fetch_at >= now() - interval '7 days'
    and w.consignee not ilike '%gloval%'
    and coalesce(w.entry_date, w.created_on) >= current_date - 180
    and not exists (
      select 1 from consolidado_lineas x
      where x.wr_number = w.wr_number and x.estado = 'EMBARCADO'
    )
  on conflict (consolidado_id, wr_number) where contenedor_id is null do nothing;

  get diagnostics v_agregados = row_count;
  return query select v_agregados, v_previos;
end;
$function$;

CREATE OR REPLACE FUNCTION public.consolidado_cargar_piezas(p_linea_id uuid, p_contenedor_id uuid, p_items uuid[])
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  l            consolidado_lineas%rowtype;
  v_cons       consolidados%rowtype;
  v_cont       consolidado_contenedores%rowtype;
  v_destino    uuid;
  v_nueva      boolean := false;
  v_fusion     boolean := false;
  n_sel        int;
  n_total      int;
  v_parcial    boolean;
  v_origen_det boolean;
  v_dest_det   boolean;
  v_mov_piezas int;
  v_mov_peso   numeric;
  v_mov_vol    numeric;
  v_quedan     int;
begin
  if not (app_can('operaciones', 'edit')
       or coalesce(auth.role(), '') = 'service_role'
       or session_user in ('postgres', 'supabase_admin')) then
    raise exception 'no autorizado: hace falta permiso de editar en Operaciones';
  end if;

  select * into l from consolidado_lineas where id = p_linea_id for update;
  if not found then raise exception 'La línea no existe.'; end if;

  select * into v_cons from consolidados where id = l.consolidado_id;
  if v_cons.estado not in ('ABIERTO', 'CERRADO') then
    raise exception 'La semana % ya está %: el cargado quedó sellado.', v_cons.semana, v_cons.estado;
  end if;

  select * into v_cont from consolidado_contenedores
   where id = p_contenedor_id and consolidado_id = l.consolidado_id;
  if not found then
    raise exception 'El contenedor no es de este consolidado.';
  end if;

  n_sel := coalesce(array_length(p_items, 1), 0);
  if n_sel = 0 then raise exception 'No se eligió ninguna pieza.'; end if;

  -- ¿Cuántas piezas tiene el recibo en total? Si se eligen todas, no hay que
  -- partir nada.
  select count(*) into n_total
  from magaya_wr_items i
  where i.wr_number = l.wr_number and i.whr_item_id is not null;

  v_parcial := n_sel < n_total;

  if l.contenedor_id = v_cont.id then
    -- Mismo contenedor: solo se ajusta cuáles piezas lleva la línea.
    v_destino := l.id;
  else
    -- Otra parte del WR que YA vive en ese contenedor: las piezas van ahí.
    -- Antes se movía la línea encima de ella y reventaba el índice único.
    select id into v_destino from consolidado_lineas
     where consolidado_id = l.consolidado_id and wr_number = l.wr_number
       and contenedor_id = v_cont.id;

    if v_destino is null and (not v_parcial or l.contenedor_id is null) then
      -- Caso normal: la línea misma va al contenedor.
      v_destino := l.id;
      update consolidado_lineas
      set contenedor_id = v_cont.id, contenedor = v_cont.numero, sello = v_cont.sello,
          cargado_confirmado_at = null, cargado_confirmado_por = null,
          updated_at = now()
      where id = l.id;
    elsif v_destino is null then
      -- La línea ya está en OTRO contenedor: hace falta una línea hermana.
      insert into consolidado_lineas
        (consolidado_id, wr_number, consignee, shipper, client_id, cs_email,
         piezas, peso_lb, volumen_cft, estado, hazmat, factura_ok, tarifa_venta, tarifa_moneda,
         instruido_at, instruido_por, instruccion_nota, contenedor, sello, hbl, rodado_desde, notas,
         agente_destino, origen_oficina, grupo_id, contenedor_id, un_number, imo_class, apilable,
         regimen, doc_7512, doc_7512_at, nota_bodega, regimen_fuente, regimen_numero, regimen_fecha,
         shipment_id, cfs_dias_extra, cfs_extra_motivo, cfs_extra_por, cfs_extra_at,
         piezas_recibo, es_parcial, hazmat_fuente, por_llegar, llega_eta)
      values
        (l.consolidado_id, l.wr_number, l.consignee, l.shipper, l.client_id, l.cs_email,
         0, 0, 0, l.estado, l.hazmat, l.factura_ok, l.tarifa_venta, l.tarifa_moneda,
         l.instruido_at, l.instruido_por, l.instruccion_nota, v_cont.numero, v_cont.sello, l.hbl, l.rodado_desde,
         'Parte del recibo ' || l.wr_number || ' cargada en ' || coalesce(v_cont.numero, 'contenedor ' || v_cont.posicion),
         l.agente_destino, l.origen_oficina, l.grupo_id, v_cont.id, l.un_number, l.imo_class, l.apilable,
         l.regimen, l.doc_7512, l.doc_7512_at, l.nota_bodega, l.regimen_fuente, l.regimen_numero, l.regimen_fecha,
         l.shipment_id, l.cfs_dias_extra, l.cfs_extra_motivo, l.cfs_extra_por, l.cfs_extra_at,
         l.piezas_recibo, true, l.hazmat_fuente, l.por_llegar, l.llega_eta)
      returning id into v_destino;
      v_nueva := true;

      insert into consolidado_linea_hazmat (linea_id, consolidado_id, un_number, imo_class, doc_recibido)
      select v_destino, h.consolidado_id, h.un_number, h.imo_class, h.doc_recibido
        from consolidado_linea_hazmat h
       where h.linea_id = l.id;
    end if;
  end if;

  -- Una pieza que vive en OTRA parte del WR se mueve desde esa línea: si no, esa
  -- parte quedaría con cifras que ya no tiene.
  if exists (select 1 from consolidado_linea_piezas p
              join consolidado_lineas x on x.id = p.linea_id
             where p.wr_item_id = any(p_items)
               and x.consolidado_id = l.consolidado_id
               and p.linea_id not in (l.id, v_destino)) then
    raise exception 'Alguna de esas piezas está en otra parte del WR %: muévela desde esa línea.', l.wr_number;
  end if;

  select exists (select 1 from consolidado_linea_piezas where linea_id = l.id) into v_origen_det;
  select exists (select 1 from consolidado_linea_piezas where linea_id = v_destino) into v_dest_det;

  -- Lo que de verdad cambia de línea: las elegidas que no estaban ya en el destino.
  select coalesce(sum(coalesce(i.pieces, 1)), 0), sum(i.peso_lb), sum(i.vol_cft)
    into v_mov_piezas, v_mov_peso, v_mov_vol
  from magaya_wr_items i
  where i.id = any(p_items)
    and not exists (select 1 from consolidado_linea_piezas p
                     where p.wr_item_id = i.id and p.linea_id = v_destino);

  -- Mover las piezas elegidas a la línea destino. El trigger
  -- consolidado_pieza_no_duplicada corta si una pieza ya está embarcada en otro
  -- lado, con mensaje en castellano.
  delete from consolidado_linea_piezas
   where wr_item_id = any(p_items)
     and linea_id in (select id from consolidado_lineas
                       where consolidado_id = l.consolidado_id and wr_number = l.wr_number);

  insert into consolidado_linea_piezas
    (linea_id, consolidado_id, wr_number, wr_item_id, whr_item_id, piezas,
     peso_lb, vol_cft, location_code, package_name, creado_por)
  select v_destino, l.consolidado_id, l.wr_number, i.id, i.whr_item_id,
         coalesce(i.pieces, 1), i.peso_lb, i.vol_cft, i.location_code,
         i.package_name, app_current_user_id()
  from magaya_wr_items i
  where i.id = any(p_items);

  -- Destino: desde sus piezas (nunca prorratear), salvo que sea una parte armada
  -- por CANTIDAD, sin detalle: a esa se le suma lo que llegó.
  if v_destino = l.id or v_nueva or v_dest_det then
    update consolidado_lineas x
    set piezas            = coalesce(t.piezas, x.piezas),
        piezas_embarcadas = t.piezas,
        peso_lb           = coalesce(round(t.peso_lb, 2), x.peso_lb),
        volumen_cft       = coalesce(round(t.vol_cft, 4), x.volumen_cft),
        es_parcial        = coalesce(x.piezas_recibo, 0) > coalesce(t.piezas, 0),
        cargado_confirmado_at  = case when x.id = l.id then x.cargado_confirmado_at end,
        cargado_confirmado_por = case when x.id = l.id then x.cargado_confirmado_por end,
        updated_at        = now()
    from (select sum(p.piezas)::int piezas, sum(p.peso_lb) peso_lb, sum(p.vol_cft) vol_cft
            from consolidado_linea_piezas p where p.linea_id = v_destino) t
    where x.id = v_destino;
  else
    update consolidado_lineas
    set piezas      = coalesce(piezas, 0) + v_mov_piezas,
        peso_lb     = case when peso_lb is null and v_mov_peso is null then null
                           else coalesce(peso_lb, 0) + coalesce(v_mov_peso, 0) end,
        volumen_cft = case when volumen_cft is null and v_mov_vol is null then null
                           else coalesce(volumen_cft, 0) + coalesce(v_mov_vol, 0) end,
        es_parcial  = case when piezas_recibo is not null
                           then piezas_recibo > coalesce(piezas, 0) + v_mov_piezas else es_parcial end,
        cargado_confirmado_at = null, cargado_confirmado_por = null,
        updated_at  = now()
    where id = v_destino;
  end if;

  -- Origen: lo que salió se descuenta. Antes, si la línea no tenía detalle por
  -- pieza, se quedaba con el recibo entero y la carga salía contada dos veces.
  if v_destino <> l.id then
    if v_origen_det then
      update consolidado_lineas x
      set piezas            = t.piezas,
          piezas_embarcadas = t.piezas,
          peso_lb           = round(coalesce(t.peso_lb, 0), 2),
          volumen_cft       = round(coalesce(t.vol_cft, 0), 4),
          es_parcial        = true,
          updated_at        = now()
      from (select coalesce(sum(p.piezas), 0)::int piezas, sum(p.peso_lb) peso_lb, sum(p.vol_cft) vol_cft
              from consolidado_linea_piezas p where p.linea_id = l.id) t
      where x.id = l.id;
    else
      update consolidado_lineas
      set piezas      = case when piezas is null then null else greatest(piezas - v_mov_piezas, 0) end,
          peso_lb     = case when peso_lb is null then null else greatest(peso_lb - coalesce(v_mov_peso, 0), 0) end,
          volumen_cft = case when volumen_cft is null then null else greatest(volumen_cft - coalesce(v_mov_vol, 0), 0) end,
          es_parcial  = true,
          updated_at  = now()
      where id = l.id;
    end if;

    select piezas into v_quedan from consolidado_lineas where id = l.id;
    if v_quedan is not null and v_quedan <= 0 then
      -- Se quedó sin nada: se funde en el destino con su historial.
      update consolidado_linea_movimientos set linea_id = v_destino where linea_id = l.id;
      update consolidado_linea_piezas      set linea_id = v_destino where linea_id = l.id;
      insert into consolidado_linea_hazmat (linea_id, consolidado_id, un_number, imo_class, doc_recibido)
      select v_destino, h.consolidado_id, h.un_number, h.imo_class, h.doc_recibido
        from consolidado_linea_hazmat h
       where h.linea_id = l.id
         and not exists (select 1 from consolidado_linea_hazmat x
                          where x.linea_id = v_destino
                            and x.un_number is not distinct from h.un_number
                            and x.imo_class is not distinct from h.imo_class);
      delete from consolidado_lineas where id = l.id;
      v_fusion := true;
    end if;
  end if;

  if l.contenedor_id is not null and l.contenedor_id <> v_cont.id then
    insert into consolidado_linea_movimientos
      (linea_id, consolidado_id, wr_number, accion, contenedor_id, contenedor, motivo, hecho_por)
    values
      (case when v_fusion then v_destino else l.id end, l.consolidado_id, l.wr_number, 'SACA',
       l.contenedor_id, l.contenedor,
       'Piezas: ' || n_sel || ' de ' || n_total || ' a ' || coalesce(v_cont.numero, 'contenedor ' || v_cont.posicion),
       app_current_user_id());
  end if;
  if l.contenedor_id is distinct from v_cont.id then
    insert into consolidado_linea_movimientos
      (linea_id, consolidado_id, wr_number, accion, contenedor_id, contenedor, motivo, hecho_por)
    values
      (v_destino, l.consolidado_id, l.wr_number, 'CARGA', v_cont.id, v_cont.numero,
       'Piezas elegidas: ' || n_sel || ' de ' || n_total, app_current_user_id());
  end if;

  return jsonb_build_object(
    'linea_destino',     v_destino,
    'parcial',           v_parcial,
    'fusion',            v_fusion,
    'piezas_cargadas',   n_sel,
    'piezas_del_recibo', n_total);
end;
$function$;

CREATE OR REPLACE FUNCTION public.consolidado_cargar_tardia(p_linea_id uuid, p_contenedor_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  l      consolidado_lineas%rowtype;
  v_cons consolidados%rowtype;
  v_cont consolidado_contenedores%rowtype;
begin
  if not (app_can('operaciones', 'edit')
       or coalesce(auth.role(), '') = 'service_role'
       or session_user in ('postgres', 'supabase_admin')) then
    raise exception 'no autorizado: hace falta permiso de editar en Operaciones';
  end if;

  select * into l from consolidado_lineas where id = p_linea_id;
  if not found then raise exception 'La línea no existe.'; end if;
  if l.contenedor_id is not null then
    raise exception 'La carga ya está en el contenedor %.', coalesce(l.contenedor, '?');
  end if;

  select * into v_cons from consolidados where id = l.consolidado_id;
  if v_cons.estado not in ('ABIERTO', 'CERRADO') then
    raise exception 'La semana % ya está %: el cargado quedó sellado.', v_cons.semana, v_cons.estado;
  end if;

  select * into v_cont from consolidado_contenedores
   where id = p_contenedor_id and consolidado_id = l.consolidado_id;
  if not found then
    raise exception 'El contenedor no es de este consolidado.';
  end if;

  update consolidado_lineas
  set contenedor_id = v_cont.id,
      contenedor    = v_cont.numero,
      sello         = v_cont.sello,
      -- Si todavía no estaba confirmada, cargarla la instruye.
      estado = case when estado in ('INSTRUIDO','APROBADO','EMBARCADO')
                    then estado else 'INSTRUIDO' end,
      instruido_at  = coalesce(instruido_at, now()),
      instruido_por = coalesce(instruido_por, app_current_user_id()),
      notas = coalesce(notas || ' · ', '') || 'Sin confirmar: cargada por Miami para llenar espacio.',
      updated_at = now()
  where id = l.id;

  insert into consolidado_linea_movimientos
    (linea_id, consolidado_id, wr_number, accion, contenedor_id, contenedor, motivo, hecho_por)
  values
    (l.id, l.consolidado_id, l.wr_number, 'CARGA', v_cont.id, v_cont.numero,
     'Sin confirmar: Miami la subió al contenedor para llenar espacio.',
     app_current_user_id());
end;
$function$;

CREATE OR REPLACE FUNCTION public.consolidado_cerrar(p_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare r jsonb;
begin
  update consolidados set estado = 'CERRADO', cerrado_at = now()
  where id = p_id and estado = 'ABIERTO';
  if not found then
    return jsonb_build_object('error', 'el consolidado no está ABIERTO');
  end if;
  select jsonb_build_object(
    'confirmadas', count(*) filter (where estado in ('INSTRUIDO','APROBADO')),
    'cbm_confirmado', round(sum(volumen_cft * 0.0283168) filter (where estado in ('INSTRUIDO','APROBADO'))::numeric, 1),
    'sin_confirmar', count(*) filter (where estado in ('DISPONIBLE','AVISADO')),
    'no_embarcan', count(*) filter (where estado = 'NO_EMBARCA')
  ) into r from consolidado_lineas where consolidado_id = p_id;
  return jsonb_build_object('ok', true, 'estado', 'CERRADO') || coalesce(r, '{}'::jsonb);
end;
$function$;

CREATE OR REPLACE FUNCTION public.consolidado_clave_house(p_agente text, p_consignee text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$
  select upper(btrim(coalesce(
    case
      when coalesce(btrim(p_agente), '') <> ''
       and p_agente !~* 'gloval\s+shipping\s+ecuador'
      then btrim(p_agente)
    end,
    btrim(coalesce(p_consignee, '')),
    ''
  )));
$function$;

CREATE OR REPLACE FUNCTION public.consolidado_confirmar_cargado(p_linea_ids uuid[], p_confirmado boolean DEFAULT true)
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare n int;
begin
  if p_confirmado then
    update consolidado_lineas
    set cargado_confirmado_at = now(), cargado_confirmado_por = app_current_user_id(),
        updated_at = now()
    where id = any(p_linea_ids) and contenedor_id is not null
      and cargado_confirmado_at is null;
  else
    update consolidado_lineas
    set cargado_confirmado_at = null, cargado_confirmado_por = null, updated_at = now()
    where id = any(p_linea_ids) and cargado_confirmado_at is not null;
  end if;
  get diagnostics n = row_count;

  insert into consolidado_linea_movimientos
    (linea_id, consolidado_id, wr_number, accion, contenedor_id, contenedor, hecho_por)
  select l.id, l.consolidado_id, l.wr_number,
         case when p_confirmado then 'CONFIRMA' else 'DESCONFIRMA' end,
         l.contenedor_id, l.contenedor, app_current_user_id()
  from consolidado_lineas l where l.id = any(p_linea_ids);

  return n;
end; $function$;

CREATE OR REPLACE FUNCTION public.consolidado_crear_semana(p_anio integer, p_semana integer, p_booking text, p_transportista text, p_motonave text, p_viaje text, p_origen text, p_destino text, p_etd date, p_eta date, p_cutoff_regular timestamp with time zone, p_cutoff_hazmat timestamp with time zone, p_cutoff_instrucciones timestamp with time zone, p_modo text DEFAULT 'MARITIMO'::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  nuevo_id uuid;
begin
  if exists (select 1 from consolidados where anio = p_anio and semana = p_semana
               and modo = p_modo and destino = p_destino) then
    return jsonb_build_object('error', 'ya existe un consolidado para esa semana y destino');
  end if;

  insert into consolidados (modo, anio, semana, booking, transportista, motonave, viaje,
    origen, destino, etd, eta, cutoff_regular, cutoff_hazmat, cutoff_instrucciones, estado)
  values (p_modo, p_anio, p_semana, p_booking, p_transportista, p_motonave, p_viaje,
    p_origen, p_destino, p_etd, p_eta, p_cutoff_regular, p_cutoff_hazmat,
    coalesce(p_cutoff_instrucciones, p_cutoff_regular), 'ABIERTO')
  returning id into nuevo_id;

  return jsonb_build_object('ok', true, 'id', nuevo_id,
    'nota', 'el refresco automático la llena en la próxima corrida (cada 15 min)');
end;
$function$;

CREATE OR REPLACE FUNCTION public.consolidado_depurar_avisos_huerfanos(p_consolidado_id uuid DEFAULT NULL::uuid)
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare v_n int := 0;
begin
  delete from consolidado_avisos a
  using consolidados c
  where c.id = a.consolidado_id
    and (case when p_consolidado_id is null
              then c.estado = 'ABIERTO'
              else c.id = p_consolidado_id end)
    -- SOLO borradores. Lo enviado (SENT/SKIPPED/ERROR) es historia: no se toca.
    and a.status = 'DRAFT'
    and coalesce(array_length(a.wr_numbers, 1), 0) > 0
    and not exists (
      select 1
        from consolidado_lineas l
        left join v_wh_wr_saldo s on s.wr_number = l.wr_number
       where l.consolidado_id = a.consolidado_id
         and l.wr_number = any (a.wr_numbers)
         and l.estado not in ('EXCLUIDO', 'RODADO', 'SALIO_BODEGA')
         and coalesce(s.estado_saldo, 'SIN_DETALLE') <> 'EMBARCADO'
    );

  get diagnostics v_n = row_count;
  return v_n;
end;
$function$;

CREATE OR REPLACE FUNCTION public.consolidado_depurar_salidas(p_consolidado_id uuid DEFAULT NULL::uuid)
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare v_n int := 0;
begin
  update consolidado_lineas l
  set estado     = 'SALIO_BODEGA',
      notas      = coalesce(nullif(l.notas, '') || ' · ', '')
                   || 'Salió de bodega el ' || to_char(w.out_date, 'DD-MM-YYYY')
                   || coalesce(' (CR ' || nullif(w.cargo_release_number, '') || ')', '')
                   || ' — se saca del tablero.',
      updated_at = now()
  from consolidados c,
       v_wh_wr_saldo s,
       magaya_warehouse_receipts w
  where c.id = l.consolidado_id
    and s.wr_number = l.wr_number
    and w.wr_number = l.wr_number
    -- Sin argumento depura todos los tableros abiertos; con argumento, ese
    -- consolidado aunque ya esté CERRADO (lo llama el zarpe antes de rodar).
    and (case when p_consolidado_id is null
              then c.estado = 'ABIERTO'
              else c.id = p_consolidado_id end)
    -- Solo lo que nadie trabajó: jamás se toca INSTRUIDO / APROBADO / EMBARCADO
    -- ni nada que ya tenga contenedor asignado.
    and l.estado in ('DISPONIBLE', 'AVISADO')
    and l.contenedor_id is null
    -- Evidencia dura: el detalle por pieza dice que no queda NADA en bodega,
    -- las piezas cuadran con la cabecera, y la cabecera confirma la salida.
    -- SIN_DETALLE y PARCIAL NO entran: donde no se sabe, no se toca.
    and s.estado_saldo = 'EMBARCADO'
    and s.cifras_confiables
    and w.out_date is not null
    and w.out_date < current_date
    -- Salida SIN cargo release en la semana de ESTE zarpe = se está cargando en
    -- nuestros contenedores (Miami la sube y el loading final la enlaza). Desde
    -- el cron no se toca: el 16-sep el 766306 se dio por salido y el monitor ya
    -- no pudo enlazarlo a su contenedor. El zarpe sí la depura.
    and not (p_consolidado_id is null
             and coalesce(w.cargo_release_number, '') = ''
             and c.etd is not null
             and w.out_date >= c.etd - 7);

  get diagnostics v_n = row_count;
  return v_n;
end;
$function$;

CREATE OR REPLACE FUNCTION public.consolidado_desvincular_linea(p_linea_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_ship uuid;
  v_quedan int;
begin
  if not (public.app_can('operaciones', 'edit')
       or public.app_can('operaciones.export', 'edit')) then
    raise exception 'no autorizado: hace falta permiso de editar en Operaciones (export)';
  end if;

  select shipment_id into v_ship from consolidado_lineas where id = p_linea_id;
  if v_ship is null then
    return jsonb_build_object('ok', true, 'nota', 'la linea no tenia House');
  end if;

  update consolidado_lineas set shipment_id = null where id = p_linea_id;

  select count(*) into v_quedan from consolidado_lineas where shipment_id = v_ship;
  if v_quedan = 0 and not exists (select 1 from ops_hbl h where h.shipment_id = v_ship) then
    delete from shipments where id = v_ship and consolidado_id is not null;
    return jsonb_build_object('ok', true, 'house_borrado', true);
  end if;

  return jsonb_build_object('ok', true, 'house_borrado', false, 'lineas_restantes', v_quedan);
end;
$function$;

CREATE OR REPLACE FUNCTION public.consolidado_estado_magaya(p_consolidado_id uuid)
 RETURNS TABLE(linea_id uuid, wr_number text, status_magaya text, estado_saldo text, piezas_onhand integer, piezas_fuera integer, out_date date, leido_at timestamp with time zone)
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select l.id, l.wr_number,
         coalesce(s.status_cabecera, w.status),
         s.estado_saldo,
         s.piezas_onhand::int,
         s.piezas_fuera::int,
         w.out_date::date,
         w.last_full_fetch_at
  from consolidado_lineas l
  left join magaya_warehouse_receipts w on w.wr_number = l.wr_number
  left join v_wh_wr_saldo s on s.wr_number = l.wr_number
  where l.consolidado_id = p_consolidado_id
    and l.estado in ('INSTRUIDO', 'APROBADO', 'EMBARCADO')
    and (auth.uid() is not null
         or coalesce(auth.role(), '') = 'service_role'
         or session_user in ('postgres', 'supabase_admin'));
$function$;

CREATE OR REPLACE FUNCTION public.consolidado_generar_embarques(p_consolidado_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  c            record;
  r            record;
  v_ship       uuid;
  v_creados    int := 0;
  v_reusados   int := 0;
  v_vinculadas int := 0;
  v_n          int;
  v_office     text;
  v_mode       shipment_mode_t;
  v_status     shipment_status_t;
  v_dest_office text;
begin
  if not (public.app_can('operaciones', 'create')
       or public.app_can('operaciones.export', 'create')) then
    raise exception 'no autorizado: hace falta permiso de crear en Operaciones (export)';
  end if;

  select * into c from consolidados where id = p_consolidado_id;
  if not found then
    return jsonb_build_object('error', 'el consolidado no existe');
  end if;

  v_office := case when c.origen ilike '%MIAMI%' then 'USA' else 'Ecuador' end;
  v_mode   := case when c.modo = 'AEREO' then 'AIR'::shipment_mode_t else 'LCL'::shipment_mode_t end;
  v_status := case when c.estado = 'ZARPADO' then 'IN_TRANSIT'::shipment_status_t
                   else 'BOOKING'::shipment_status_t end;
  v_dest_office := case
    when c.destino ilike '%GUAYAQUIL%' or c.destino ilike '%QUITO%' then 'Ecuador'
    when c.destino ilike '%PANAMA%'    or c.destino ilike '%COLON%' then 'Panama'
    when c.destino ilike '%LIMA%'      or c.destino ilike '%CALLAO%' then 'Peru'
  end;

  for r in
    select
      public.consolidado_clave_house(l.agente_destino, l.consignee) as clave,
      (array_agg(coalesce(nullif(btrim(l.agente_destino), ''), btrim(l.consignee))
                 order by l.updated_at desc))[1] as nombre,
      bool_or(coalesce(btrim(l.agente_destino), '') <> ''
              and l.agente_destino !~* 'gloval\s+shipping\s+ecuador') as es_agente,
      case when count(distinct l.client_id) = 1
           then (array_agg(l.client_id) filter (where l.client_id is not null))[1] end as client_id,
      min(l.cs_email) as cs_email
    from consolidado_lineas l
    where l.consolidado_id = p_consolidado_id
      and l.estado in ('INSTRUIDO', 'APROBADO', 'EMBARCADO')
      and public.consolidado_clave_house(l.agente_destino, l.consignee) <> ''
    group by 1
  loop
    select l.shipment_id into v_ship
    from consolidado_lineas l
    where l.consolidado_id = p_consolidado_id
      and l.shipment_id is not null
      and public.consolidado_clave_house(l.agente_destino, l.consignee) = r.clave
    limit 1;

    if v_ship is null then
      insert into shipments (
        office, mode, direction, status,
        client_id, cs_assigned_to, consignee_name,
        carrier, vessel_name, voyage, booking_ref,
        origin_port, destination_port, etd, eta,
        via_origen, destino_tipo, destino_office, destino_agent_id,
        consolidado_id, created_by
      ) values (
        v_office, v_mode, 'EXPORT'::shipment_direction_t, v_status,
        r.client_id,
        (select u.id from users u where lower(u.email) = lower(r.cs_email) limit 1),
        r.nombre,
        c.transportista, c.motonave, c.viaje, c.booking,
        c.origen, c.destino, c.etd, c.eta,
        'CONSOLIDADO'::ops_via_origen_t,
        case when r.es_agente then 'EXTERNAL_AGENT'::ops_destino_t
             when v_dest_office is not null then 'GLOVAL_OFFICE'::ops_destino_t end,
        case when not r.es_agente then v_dest_office end,
        case when r.es_agente then
          (select a.id from agents a where upper(btrim(a.company_name)) = r.clave limit 1)
        end,
        p_consolidado_id,
        public.app_current_user_id()
      )
      returning id into v_ship;
      v_creados := v_creados + 1;
    else
      v_reusados := v_reusados + 1;
    end if;

    update consolidado_lineas l
       set shipment_id = v_ship
     where l.consolidado_id = p_consolidado_id
       and l.shipment_id is null
       and l.estado in ('INSTRUIDO', 'APROBADO', 'EMBARCADO')
       and public.consolidado_clave_house(l.agente_destino, l.consignee) = r.clave;
    get diagnostics v_n = row_count;
    v_vinculadas := v_vinculadas + v_n;
  end loop;

  return jsonb_build_object(
    'ok', true,
    'houses_creados', v_creados,
    'houses_reusados', v_reusados,
    'lineas_vinculadas', v_vinculadas
  );
end;
$function$;

CREATE OR REPLACE FUNCTION public.consolidado_generar_embarques(p_consolidado_id uuid, p_oficina text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  c            record;
  r            record;
  v_ship       uuid;
  v_master     uuid;
  v_mret       jsonb;
  v_creados    int := 0;
  v_reusados   int := 0;
  v_vinculadas int := 0;
  v_n          int;
  v_office     text;
  v_mode       shipment_mode_t;
  v_status     shipment_status_t;
  v_dest_office text;
begin
  if not (public.app_can('operaciones', 'create')
       or public.app_can('operaciones.export', 'create')) then
    raise exception 'no autorizado: hace falta permiso de crear en Operaciones (export)';
  end if;

  select * into c from consolidados where id = p_consolidado_id;
  if not found then
    return jsonb_build_object('error', 'el consolidado no existe');
  end if;

  v_office := coalesce(
    nullif(btrim(coalesce(p_oficina, '')), ''),
    (select u.office from users u where u.id = public.app_current_user_id())
  );
  if v_office is null then
    return jsonb_build_object('error', 'falta decir de que oficina son los embarques');
  end if;

  -- EL MÁSTER PRIMERO. Todo el consolidado es un solo embarque máster; los
  -- houses van adentro.
  v_mret := public.consolidado_master(p_consolidado_id, v_office);
  if v_mret ? 'error' then return v_mret; end if;
  v_master := (v_mret->>'shipment_id')::uuid;

  v_mode   := case when c.modo = 'AEREO' then 'AIR'::shipment_mode_t else 'LCL'::shipment_mode_t end;
  v_status := case when c.estado = 'ZARPADO' then 'IN_TRANSIT'::shipment_status_t
                   else 'BOOKING'::shipment_status_t end;
  v_dest_office := case
    when c.destino ilike '%GUAYAQUIL%' or c.destino ilike '%QUITO%' then 'Ecuador'
    when c.destino ilike '%PANAMA%'    or c.destino ilike '%COLON%' then 'Panama'
    when c.destino ilike '%LIMA%'      or c.destino ilike '%CALLAO%' then 'Peru'
  end;

  for r in
    select
      public.consolidado_clave_house(l.agente_destino, l.consignee) as clave,
      (array_agg(coalesce(nullif(btrim(l.agente_destino), ''), btrim(l.consignee))
                 order by l.updated_at desc))[1] as nombre,
      bool_or(coalesce(btrim(l.agente_destino), '') <> ''
              and l.agente_destino !~* 'gloval\s+shipping\s+ecuador') as es_agente,
      case when count(distinct l.client_id) = 1
           then (array_agg(l.client_id) filter (where l.client_id is not null))[1] end as client_id,
      min(l.cs_email) as cs_email
    from consolidado_lineas l
    where l.consolidado_id = p_consolidado_id
      and l.estado in ('INSTRUIDO', 'APROBADO', 'EMBARCADO')
      and public.consolidado_clave_house(l.agente_destino, l.consignee) <> ''
    group by 1
  loop
    select l.shipment_id into v_ship
    from consolidado_lineas l
    where l.consolidado_id = p_consolidado_id
      and l.shipment_id is not null
      and public.consolidado_clave_house(l.agente_destino, l.consignee) = r.clave
    limit 1;

    if v_ship is null then
      insert into shipments (
        office, mode, direction, status, master_shipment_id,
        client_id, cs_assigned_to, consignee_name,
        carrier, vessel_name, voyage, booking_ref,
        origin_port, destination_port, etd, eta,
        via_origen, destino_tipo, destino_office, destino_agent_id,
        consolidado_id, created_by
      ) values (
        v_office, v_mode, 'EXPORT'::shipment_direction_t, v_status, v_master,
        r.client_id,
        (select u.id from users u where lower(u.email) = lower(r.cs_email) limit 1),
        r.nombre,
        c.transportista, c.motonave, c.viaje, c.booking,
        c.origen, c.destino, c.etd, c.eta,
        'CONSOLIDADO'::ops_via_origen_t,
        case when r.es_agente then 'EXTERNAL_AGENT'::ops_destino_t
             when v_dest_office is not null then 'GLOVAL_OFFICE'::ops_destino_t end,
        case when not r.es_agente then v_dest_office end,
        case when r.es_agente then
          (select a.id from agents a where upper(btrim(a.company_name)) = r.clave limit 1)
        end,
        p_consolidado_id,
        public.app_current_user_id()
      )
      returning id into v_ship;
      v_creados := v_creados + 1;
    else
      -- Ya existía: se le engancha el máster si le faltaba.
      update shipments set master_shipment_id = v_master
       where id = v_ship and master_shipment_id is distinct from v_master;
      v_reusados := v_reusados + 1;
    end if;

    update consolidado_lineas l
       set shipment_id = v_ship
     where l.consolidado_id = p_consolidado_id
       and l.shipment_id is null
       and l.estado in ('INSTRUIDO', 'APROBADO', 'EMBARCADO')
       and public.consolidado_clave_house(l.agente_destino, l.consignee) = r.clave;
    get diagnostics v_n = row_count;
    v_vinculadas := v_vinculadas + v_n;
  end loop;

  return jsonb_build_object('ok', true, 'oficina', v_office,
    'master_id', v_master, 'master_creado', coalesce((v_mret->>'creado')::boolean, false),
    'houses_creados', v_creados, 'houses_reusados', v_reusados,
    'lineas_vinculadas', v_vinculadas);
end;
$function$;

CREATE OR REPLACE FUNCTION public.consolidado_generar_hbl_drafts(p_consolidado_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  c record; s record;
  v_creados int := 0; v_ya_tenian int := 0;
  v_data jsonb;
begin
  if not (public.app_can('operaciones', 'create')
       or public.app_can('operaciones.export', 'create')) then
    raise exception 'no autorizado: hace falta permiso de crear en Operaciones';
  end if;

  select * into c from consolidados where id = p_consolidado_id;
  if not found then return jsonb_build_object('error', 'el consolidado no existe'); end if;

  for s in
    select sh.id, sh.consignee_name
    from shipments sh
    where sh.consolidado_id = p_consolidado_id
      and exists (select 1 from consolidado_lineas l
                   where l.shipment_id = sh.id
                     and l.estado in ('INSTRUIDO','APROBADO','EMBARCADO'))
  loop
    if exists (select 1 from ops_hbl h where h.shipment_id = s.id) then
      v_ya_tenian := v_ya_tenian + 1;
      continue;
    end if;

    select jsonb_build_object(
      'cargo', (
        select jsonb_agg(jsonb_build_object(
                 'marks', case when g.contenedor is null then 'CTR: POR ASIGNAR'
                               else g.contenedor || case when g.sello is not null then ' / SEAL ' || g.sello else '' end end,
                 'packages', g.pzs || ' PKGS',
                 'description', 'SAID TO CONTAIN - CONSOLIDATED CARGO',
                 'weight', g.kg || ' Kg',
                 'measurement', g.m3 || ' M3'
               ) order by g.contenedor nulls last)
        from (
          select l2.contenedor, l2.sello,
                 coalesce(sum(l2.piezas),0) as pzs,
                 round((sum(coalesce(l2.peso_lb,0))/2.20462)::numeric,2) as kg,
                 round((sum(coalesce(l2.volumen_cft,0))*0.0283168)::numeric,3) as m3
          from consolidado_lineas l2
          where l2.shipment_id = s.id and l2.estado in ('INSTRUIDO','APROBADO','EMBARCADO')
          group by l2.contenedor, l2.sello
        ) g
      ),
      'notify', 'SAME',
      'currency', 'USD',
      'exporter', (select left(string_agg(distinct nullif(btrim(l3.shipper),''), ' / '), 240)
                   from consolidado_lineas l3 where l3.shipment_id = s.id
                     and l3.estado in ('INSTRUIDO','APROBADO','EMBARCADO')),
      'terminal', '',
      'consignee', coalesce(s.consignee_name, ''),
      'agent_line', 'GLOVAL SHIPPING USA',
      'date_laden', to_char(c.etd, 'DD-Mon-YY'),
      'mbl_number', coalesce(c.booking, ''),
      'place_issue', 'Miami',
      'port_loading', 'MIAMI, FL - USA',
      'total_weight', (select round((sum(coalesce(l4.peso_lb,0))/2.20462)::numeric,2) || ' Kg'
                       from consolidado_lineas l4 where l4.shipment_id = s.id
                         and l4.estado in ('INSTRUIDO','APROBADO','EMBARCADO')),
      'type_of_move', 'CFS/CFS',
      'vessel_voyage', btrim(coalesce(c.motonave,'') || case when coalesce(c.viaje,'')<>'' and position(c.viaje in coalesce(c.motonave,''))=0 then ' '||c.viaje else '' end),
      'declared_value', '',
      'departure_date', to_char(c.etd, 'DD-Mon-YY'),
      'place_delivery', upper(c.destino) || case when c.destino ~* 'GUAYAQUIL' then ' - ECUADOR' else '' end,
      'port_discharge', upper(c.destino) || case when c.destino ~* 'GUAYAQUIL' then ' - ECUADOR' else '' end,
      'total_packages', (select coalesce(sum(l5.piezas),0) || ' PKGS'
                         from consolidado_lineas l5 where l5.shipment_id = s.id
                           and l5.estado in ('INSTRUIDO','APROBADO','EMBARCADO')),
      'forwarding_agent', case when c.servicio = 'MIA-GYE-LCL' then 'GLOVAL SHIPPING ECUADOR CIA. LTDA.'
                               when c.servicio = 'MIA-PTY-LCL' then 'GLOVAL SHIPPING PANAMA'
                               when c.servicio = 'MIA-CLL-LCL' then 'GLOVAL SHIPPING PERU'
                               else '' end,
      'total_measurement', (select round((sum(coalesce(l6.volumen_cft,0))*0.0283168)::numeric,3) || ' M3'
                            from consolidado_lineas l6 where l6.shipment_id = s.id
                              and l6.estado in ('INSTRUIDO','APROBADO','EMBARCADO'))
    ) into v_data;

    insert into ops_hbl (shipment_id, hbl_number, status, data, created_by)
    values (s.id, null, 'DRAFT', v_data, app_current_user_id());
    v_creados := v_creados + 1;
  end loop;

  return jsonb_build_object('ok', true, 'drafts_creados', v_creados, 'houses_con_hbl_previo', v_ya_tenian);
end;
$function$;

CREATE OR REPLACE FUNCTION public.consolidado_hereda_servicio()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  if new.servicio is null then
    select s.codigo into new.servicio from consolidado_servicios s
    where s.destino = new.destino and s.modo = new.modo::text limit 1;
  end if;
  return new;
end $function$;

CREATE OR REPLACE FUNCTION public.consolidado_houses(p_consolidado_id uuid)
 RETURNS TABLE(shipment_id uuid, shipment_code text, cliente text, status text, destino_tipo text, hbl_number text, hbl_status text, lineas bigint, direction text, mode text, mbl text, origin text, destination text, etd date, vessel_name text)
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  if not (public.app_can('operaciones', 'view')
       or public.app_can('operaciones.export', 'view')
       or public.app_can('operaciones.import', 'view')
       or public.app_can('operaciones.air', 'view')
       or public.app_can('operaciones.warehouse', 'view')) then
    raise exception 'no autorizado: hace falta permiso de ver Operaciones';
  end if;

  return query
  select s.id, s.shipment_code, s.consignee_name, s.status::text, s.destino_tipo::text,
         h.hbl_number, h.status, count(l.id),
         s.direction::text, s.mode::text, s.mbl, s.origin_port, s.destination_port,
         s.etd, s.vessel_name
  from shipments s
  left join ops_hbl h on h.shipment_id = s.id
  left join consolidado_lineas l on l.shipment_id = s.id
  where s.consolidado_id = p_consolidado_id
    and not s.is_master
  group by s.id, s.shipment_code, s.consignee_name, s.status, s.destino_tipo,
           h.hbl_number, h.status, s.direction, s.mode, s.mbl, s.origin_port,
           s.destination_port, s.etd, s.vessel_name
  order by s.consignee_name;
end;
$function$;

CREATE OR REPLACE FUNCTION public.consolidado_linea_no_tenant_impo()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
declare v_es_tenant boolean; v_es_impo boolean; v_servicio text;
begin
  if new.estado in ('EXCLUIDO','RODADO') then return new; end if;

  select servicio into v_servicio from consolidados where id = new.consolidado_id;
  if coalesce(v_servicio, 'MIA-GYE-LCL') <> 'MIA-GYE-LCL' then return new; end if;

  v_es_tenant := es_carga_de_tenant(new.agente_destino, new.consignee);
  v_es_impo   := coalesce(new.agente_destino, '') ~* 'gloval\s+shipping\s+usa';
  if not v_es_tenant and not v_es_impo then return new; end if;

  if tg_op = 'INSERT' then
    if v_es_tenant then
      raise exception
        'El WR % es carga de un TENANT de la bodega (%) — no entra al consolidado de Guayaquil: a los tenants se les hace cargo release.',
        new.wr_number, coalesce(new.agente_destino, new.consignee);
    end if;
    raise exception
      'El WR % es carga de IMPORTACIÓN (%) — no entra a un consolidado de exportación.',
      new.wr_number, new.agente_destino;
  end if;

  new.estado := 'EXCLUIDO';
  new.contenedor_id := null; new.contenedor := null; new.sello := null;
  new.notas := coalesce(new.notas || ' · ', '')
    || case when v_es_tenant
       then 'Auto-excluida: el recibo resultó ser de un tenant de la bodega (cargo release, otro flujo).'
       else 'Auto-excluida: el recibo resultó ser carga de importación (Gloval USA).' end;
  return new;
end; $function$;

CREATE OR REPLACE FUNCTION public.consolidado_master(p_consolidado_id uuid, p_oficina text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  c        record;
  v_id     uuid;
  v_office text;
begin
  if not (public.app_can('operaciones', 'create')
       or public.app_can('operaciones.export', 'create')
       or public.app_can('cs', 'edit')) then
    raise exception 'no autorizado para crear el embarque máster';
  end if;

  select * into c from consolidados where id = p_consolidado_id;
  if not found then
    return jsonb_build_object('error', 'el consolidado no existe');
  end if;

  select id into v_id from shipments
   where consolidado_id = p_consolidado_id and is_master limit 1;
  if v_id is not null then
    -- Ya existe: se refresca lo que la naviera pudo haber cambiado (nave,
    -- viaje, fechas) sin tocar el MBL, que lo escribe la persona.
    update shipments s set
      carrier          = coalesce(c.transportista, s.carrier),
      vessel_name      = coalesce(c.motonave, s.vessel_name),
      voyage           = coalesce(c.viaje, s.voyage),
      booking_ref      = coalesce(c.booking, s.booking_ref),
      origin_port      = coalesce(c.origen, s.origin_port),
      destination_port = coalesce(c.destino, s.destination_port),
      etd              = coalesce(c.etd, s.etd),
      eta              = coalesce(c.eta, s.eta),
      updated_at       = now()
    where s.id = v_id;
    return jsonb_build_object('ok', true, 'shipment_id', v_id, 'creado', false);
  end if;

  -- La oficina la dice el caller; si no, la de quien crea. NUNCA del puerto.
  v_office := coalesce(
    nullif(btrim(coalesce(p_oficina, '')), ''),
    (select u.office from users u where u.id = public.app_current_user_id())
  );
  if v_office is null then
    return jsonb_build_object('error', 'falta decir de qué oficina es el máster');
  end if;

  insert into shipments (
    office, mode, direction, status, is_master, consolidado_id,
    consignee_name, carrier, vessel_name, voyage, booking_ref,
    origin_port, destination_port, etd, eta, via_origen, created_by
  ) values (
    v_office,
    case when c.modo = 'AEREO' then 'AIR'::shipment_mode_t else 'LCL'::shipment_mode_t end,
    'EXPORT'::shipment_direction_t,
    case when c.estado = 'ZARPADO' then 'IN_TRANSIT'::shipment_status_t
         else 'BOOKING'::shipment_status_t end,
    true, p_consolidado_id,
    'MÁSTER · consolidado ' || c.origen || ' → ' || c.destino ||
      ' · sem ' || c.semana || '/' || c.anio,
    c.transportista, c.motonave, c.viaje, c.booking,
    c.origen, c.destino, c.etd, c.eta,
    'CONSOLIDADO'::ops_via_origen_t,
    public.app_current_user_id()
  )
  returning id into v_id;

  return jsonb_build_object('ok', true, 'shipment_id', v_id, 'creado', true);
end;
$function$;

CREATE OR REPLACE FUNCTION public.consolidado_mover_carga(p_linea_id uuid, p_contenedor_id uuid, p_piezas integer DEFAULT NULL::integer, p_motivo text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  l         consolidado_lineas%rowtype;
  d         consolidado_lineas%rowtype;
  v_cons    consolidados%rowtype;
  v_cont    consolidado_contenedores%rowtype;
  v_origen  consolidado_contenedores%rowtype;
  v_total   int;
  v_mover   int;
  v_parcial boolean;
  v_peso    numeric;
  v_vol     numeric;
  v_destino uuid;
  v_fusion  boolean := false;
  v_detalle text;
begin
  if not (app_can('operaciones', 'edit')
       or coalesce(auth.role(), '') = 'service_role'
       or session_user in ('postgres', 'supabase_admin')) then
    raise exception 'no autorizado: hace falta permiso de editar en Operaciones';
  end if;

  select * into l from consolidado_lineas where id = p_linea_id for update;
  if not found then raise exception 'La línea no existe.'; end if;

  select * into v_cons from consolidados where id = l.consolidado_id;
  if v_cons.estado not in ('ABIERTO', 'CERRADO') then
    raise exception 'La semana % ya está %: el cargado quedó sellado.', v_cons.semana, v_cons.estado;
  end if;
  if l.estado not in ('INSTRUIDO', 'APROBADO', 'EMBARCADO') then
    raise exception 'El WR % está %: solo se carga lo confirmado.', l.wr_number, l.estado;
  end if;

  if p_contenedor_id is not null then
    select * into v_cont from consolidado_contenedores
     where id = p_contenedor_id and consolidado_id = l.consolidado_id;
    if not found then
      raise exception 'El contenedor destino no es de este consolidado.';
    end if;
  end if;
  if l.contenedor_id is not distinct from p_contenedor_id then
    raise exception 'El WR % ya está ahí.', l.wr_number;
  end if;
  if l.contenedor_id is not null then
    select * into v_origen from consolidado_contenedores where id = l.contenedor_id;
  end if;

  -- ¿Completa o N piezas?
  v_total := coalesce(l.piezas, 0);
  if p_piezas is not null then
    if p_piezas <= 0 then
      raise exception 'La cantidad de piezas tiene que ser mayor que cero.';
    end if;
    if v_total = 0 then
      raise exception 'El WR % no tiene piezas registradas en esta línea: solo se puede mover completo.', l.wr_number;
    end if;
    if p_piezas > v_total then
      raise exception 'En esta línea del WR % hay % piezas: no se pueden mover %.', l.wr_number, v_total, p_piezas;
    end if;
  end if;
  v_parcial := p_piezas is not null and p_piezas < v_total;
  v_mover   := case when v_parcial then p_piezas else v_total end;

  -- Con piezas elegidas una por una, partir por cantidad no sabría cuáles se
  -- van: para eso está el selector de piezas.
  if v_parcial and exists (select 1 from consolidado_linea_piezas where linea_id = l.id) then
    raise exception 'El WR % tiene piezas elegidas una por una: usa el botón Piezas para escoger cuáles se mueven.', l.wr_number;
  end if;

  -- Peso y volumen en proporción a las piezas (se restan del origen más abajo).
  if v_parcial then
    v_peso := round(l.peso_lb * v_mover / v_total, 2);
    v_vol  := round(l.volumen_cft * v_mover / v_total, 4);
  else
    v_peso := l.peso_lb;
    v_vol  := l.volumen_cft;
  end if;

  v_detalle := case when v_parcial then v_mover || ' de ' || v_total || ' piezas' else 'completa' end
    || ' · de ' || coalesce('contenedor ' || v_origen.posicion || coalesce(' ' || v_origen.numero, ''), 'Por cargar')
    || ' a '    || coalesce('contenedor ' || v_cont.posicion   || coalesce(' ' || v_cont.numero, ''), 'Por cargar')
    || coalesce(' · ' || nullif(trim(p_motivo), ''), '');

  -- ¿Ya hay otra parte del mismo WR en el destino?
  select * into d from consolidado_lineas
   where consolidado_id = l.consolidado_id and wr_number = l.wr_number and id <> l.id
     and contenedor_id is not distinct from p_contenedor_id
   for update;
  if d.id is not null and d.estado not in ('INSTRUIDO', 'APROBADO', 'EMBARCADO') then
    raise exception 'En ese destino ya hay otra línea del WR % en estado %: revísala antes de mover.', l.wr_number, d.estado;
  end if;

  if d.id is null and not v_parcial then
    -- La línea entera cambia de lugar.
    update consolidado_lineas
       set contenedor_id = p_contenedor_id, contenedor = v_cont.numero, sello = v_cont.sello,
           -- Lo que cambió de contenedor bodega todavía no lo vio adentro.
           cargado_confirmado_at = null, cargado_confirmado_por = null,
           updated_at = now()
     where id = l.id;
    v_destino := l.id;

  elsif d.id is null then
    -- Parcial y el destino no tiene nada de este WR: nace la línea hermana,
    -- copia fiel de la original salvo cifras y contenedor.
    insert into consolidado_lineas
      (consolidado_id, wr_number, consignee, shipper, client_id, cs_email,
       piezas, peso_lb, volumen_cft, estado, hazmat, factura_ok, tarifa_venta, tarifa_moneda,
       instruido_at, instruido_por, instruccion_nota, contenedor, sello, hbl, rodado_desde, notas,
       agente_destino, origen_oficina, grupo_id, contenedor_id, un_number, imo_class, apilable,
       regimen, doc_7512, doc_7512_at, nota_bodega, regimen_fuente, regimen_numero, regimen_fecha,
       shipment_id, cfs_dias_extra, cfs_extra_motivo, cfs_extra_por, cfs_extra_at,
       piezas_recibo, es_parcial, hazmat_fuente, por_llegar, llega_eta)
    values
      (l.consolidado_id, l.wr_number, l.consignee, l.shipper, l.client_id, l.cs_email,
       v_mover, v_peso, v_vol, l.estado, l.hazmat, l.factura_ok, l.tarifa_venta, l.tarifa_moneda,
       l.instruido_at, l.instruido_por, l.instruccion_nota, v_cont.numero, v_cont.sello, l.hbl, l.rodado_desde,
       'Parte del recibo ' || l.wr_number || ' · ' || v_detalle,
       l.agente_destino, l.origen_oficina, l.grupo_id, p_contenedor_id, l.un_number, l.imo_class, l.apilable,
       l.regimen, l.doc_7512, l.doc_7512_at, l.nota_bodega, l.regimen_fuente, l.regimen_numero, l.regimen_fecha,
       l.shipment_id, l.cfs_dias_extra, l.cfs_extra_motivo, l.cfs_extra_por, l.cfs_extra_at,
       l.piezas_recibo, true, l.hazmat_fuente, l.por_llegar, l.llega_eta)
    returning id into v_destino;

    insert into consolidado_linea_hazmat (linea_id, consolidado_id, un_number, imo_class, doc_recibido)
    select v_destino, h.consolidado_id, h.un_number, h.imo_class, h.doc_recibido
      from consolidado_linea_hazmat h
     where h.linea_id = l.id;

  else
    -- En el destino ya hay otra parte del WR: lo que llega se suma a esa.
    update consolidado_lineas
       set piezas      = coalesce(piezas, 0) + v_mover,
           peso_lb     = case when peso_lb is null and v_peso is null then null
                              else coalesce(peso_lb, 0) + coalesce(v_peso, 0) end,
           volumen_cft = case when volumen_cft is null and v_vol is null then null
                              else coalesce(volumen_cft, 0) + coalesce(v_vol, 0) end,
           hazmat      = hazmat or l.hazmat,
           apilable    = apilable and l.apilable,
           cargado_confirmado_at = null, cargado_confirmado_por = null,
           updated_at  = now()
     where id = d.id;

    insert into consolidado_linea_hazmat (linea_id, consolidado_id, un_number, imo_class, doc_recibido)
    select d.id, h.consolidado_id, h.un_number, h.imo_class, h.doc_recibido
      from consolidado_linea_hazmat h
     where h.linea_id = l.id
       and not exists (select 1 from consolidado_linea_hazmat x
                        where x.linea_id = d.id
                          and x.un_number is not distinct from h.un_number
                          and x.imo_class is not distinct from h.imo_class);
    v_destino := d.id;
  end if;

  if v_parcial then
    -- El origen se queda con el resto.
    update consolidado_lineas
       set piezas      = v_total - v_mover,
           peso_lb     = case when peso_lb is null then null else greatest(peso_lb - coalesce(v_peso, 0), 0) end,
           volumen_cft = case when volumen_cft is null then null else greatest(volumen_cft - coalesce(v_vol, 0), 0) end,
           updated_at  = now()
     where id = l.id;
  elsif d.id is not null then
    -- Se fue completa a donde ya había otra parte: la línea vacía se funde en
    -- esa y le deja su historial y sus piezas elegidas.
    update consolidado_linea_movimientos set linea_id = d.id where linea_id = l.id;
    update consolidado_linea_piezas      set linea_id = d.id where linea_id = l.id;
    delete from consolidado_lineas where id = l.id;
    v_fusion := true;
  end if;

  update consolidado_lineas x
     set es_parcial = case
                        when x.piezas_recibo is not null and x.piezas is not null then x.piezas_recibo > x.piezas
                        when v_parcial then true
                        else x.es_parcial
                      end
   where x.id in (l.id, v_destino);

  if l.contenedor_id is not null then
    insert into consolidado_linea_movimientos
      (linea_id, consolidado_id, wr_number, accion, contenedor_id, contenedor, motivo, hecho_por)
    values
      (case when v_fusion then v_destino else l.id end, l.consolidado_id, l.wr_number, 'SACA',
       l.contenedor_id, coalesce(v_origen.numero, l.contenedor), 'Mover ' || v_detalle, app_current_user_id());
  end if;
  if p_contenedor_id is not null then
    insert into consolidado_linea_movimientos
      (linea_id, consolidado_id, wr_number, accion, contenedor_id, contenedor, motivo, hecho_por)
    values
      (v_destino, l.consolidado_id, l.wr_number, 'CARGA',
       v_cont.id, v_cont.numero, 'Mover ' || v_detalle, app_current_user_id());
  end if;

  return jsonb_build_object(
    'linea_origen',   case when v_fusion then null else l.id end,
    'linea_destino',  v_destino,
    'piezas_movidas', v_mover,
    'parcial',        v_parcial,
    'fusion',         v_fusion);
end;
$function$;

CREATE OR REPLACE FUNCTION public.consolidado_pieza_no_duplicada()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
declare
  otra record;
begin
  if new.wr_item_id is null then return new; end if;

  select l.wr_number, c.anio, c.semana, coalesce(l.contenedor, 'sin contenedor') as cont
  into otra
  from consolidado_linea_piezas p
  join consolidado_lineas l on l.id = p.linea_id
  join consolidados c       on c.id = l.consolidado_id
  where p.wr_item_id = new.wr_item_id
    and p.id is distinct from new.id
    and l.estado in ('DISPONIBLE','AVISADO','INSTRUIDO','APROBADO','EMBARCADO')
    and c.estado <> 'CANCELADO'
  limit 1;

  if found then
    raise exception
      'La pieza % del recibo % ya está asignada en la semana %/% (%). Una pieza no puede embarcarse dos veces.',
      new.whr_item_id, new.wr_number, otra.semana, otra.anio, otra.cont;
  end if;

  return new;
end;
$function$;

CREATE OR REPLACE FUNCTION public.consolidado_piezas_de_recibo(p_wr_number text, p_consolidado_id uuid)
 RETURNS TABLE(wr_item_id uuid, whr_item_id text, piezas integer, peso_lb numeric, vol_cft numeric, location_code text, package_name text, descripcion text, status_magaya text, asignada_a uuid, asignada_cont text)
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select i.id, i.whr_item_id, coalesce(i.pieces, 1), i.peso_lb, i.vol_cft,
         i.location_code, i.package_name,
         coalesce(nullif(i.item_description, ''), i.description),
         i.status,
         a.linea_id, a.donde
  from magaya_wr_items i
  -- Ocupada = en una línea VIVA (la misma regla del candado
  -- consolidado_pieza_no_duplicada). Antes bastaba con que la línea no fuera
  -- EXCLUIDO, y una línea rodada o salida de bodega dejaba la pieza bloqueada.
  left join lateral (
    select p.linea_id,
           case when x.consolidado_id = p_consolidado_id then x.contenedor
                else coalesce(x.contenedor || ' · ', '') || 'semana ' || c.semana
           end as donde
    from consolidado_linea_piezas p
    join consolidado_lineas x on x.id = p.linea_id
    join consolidados c       on c.id = x.consolidado_id
    where p.wr_item_id = i.id
      and x.estado in ('DISPONIBLE', 'AVISADO', 'INSTRUIDO', 'APROBADO', 'EMBARCADO')
      and c.estado <> 'CANCELADO'
    order by (x.consolidado_id = p_consolidado_id) desc, p.created_at desc
    limit 1
  ) a on true
  where i.wr_number = p_wr_number
    and i.whr_item_id is not null
  order by
    -- El número de pieza es texto en la base pero se lee como número: sin esto
    -- la "10 de 37" sale antes que la "2 de 37" y confunde a quien carga.
    case when i.whr_item_id ~ '^[0-9]+$' then lpad(i.whr_item_id, 10, '0')
         else i.whr_item_id end;
$function$;

CREATE OR REPLACE FUNCTION public.consolidado_piezas_reenlazar()
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  r      record;
  v_item uuid;
  v_n    int;
  n_ok   int := 0;
  n_amb  int := 0;
  n_sin  int := 0;
  n_rech int := 0;
begin
  for r in
    select p.id, p.wr_number, p.whr_item_id
    from consolidado_linea_piezas p
    where p.wr_item_id is null
  loop
    select count(*), (array_agg(i.id))[1] into v_n, v_item
    from magaya_wr_items i
    where i.wr_number = r.wr_number and i.whr_item_id = r.whr_item_id;

    if v_n = 1 then
      begin
        update consolidado_linea_piezas set wr_item_id = v_item where id = r.id;
        n_ok := n_ok + 1;
      exception when others then
        -- p. ej. consolidado_pieza_no_duplicada: la pieza ya está enlazada a
        -- otra línea viva. Se deja como está.
        n_rech := n_rech + 1;
      end;
    elsif v_n > 1 then
      n_amb := n_amb + 1;
    else
      n_sin := n_sin + 1;
    end if;
  end loop;

  return jsonb_build_object('reenlazadas', n_ok, 'ambiguas', n_amb, 'sin_pieza', n_sin, 'rechazadas', n_rech);
end;
$function$;

CREATE OR REPLACE FUNCTION public.consolidado_prorrogar_cfs(p_linea_id uuid, p_dias integer, p_motivo text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_reg text;
begin
  if not (public.app_can('cs', 'edit')
       or public.app_can('operaciones', 'edit')
       or public.app_can('operaciones.export', 'edit')
       or public.app_can('operaciones.warehouse', 'edit')) then
    raise exception 'no autorizado para registrar prórrogas';
  end if;

  if p_dias is null or p_dias < 0 or p_dias > 180 then
    return jsonb_build_object('error', 'la prórroga tiene que ir entre 0 y 180 días');
  end if;

  select regimen into v_reg from consolidado_lineas where id = p_linea_id;
  if v_reg is null then
    return jsonb_build_object('error', 'esa línea no existe');
  end if;
  if v_reg <> 'CFS' then
    return jsonb_build_object('error', 'la prórroga es del plazo de la CFS; esta línea es ' || v_reg);
  end if;

  update consolidado_lineas
     set cfs_dias_extra  = p_dias,
         cfs_extra_motivo = nullif(btrim(coalesce(p_motivo, '')), ''),
         cfs_extra_por    = case when p_dias > 0 then public.app_current_user_id() end,
         cfs_extra_at     = case when p_dias > 0 then now() end,
         updated_at       = now()
   where id = p_linea_id;

  return jsonb_build_object('ok', true, 'dias', p_dias);
end;
$function$;

CREATE OR REPLACE FUNCTION public.consolidado_refresh_abierto()
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  c        record;
  umbral   date;
  agentes  text[];
  ins      int;
  depurado int;
  huerfanos int;
  total    jsonb := '[]'::jsonb;
begin
  -- ANTES de agregar nada: sacar del tablero lo que ya dejó la bodega, y
  -- después barrer los borradores de aviso que quedaron sin carga.
  depurado  := consolidado_depurar_salidas();
  huerfanos := consolidado_depurar_avisos_huerfanos();

  for c in
    select c2.* from consolidados c2 join consolidado_servicios s on s.codigo = c2.servicio where c2.estado = 'ABIERTO' and c2.modo = 'MARITIMO' and s.fuente_lineas = 'MAGAYA_WR'
  loop
    select max(p.cutoff_regular)::date into umbral
    from consolidados p
    where p.destino = c.destino and p.modo = c.modo
      and p.id <> c.id and p.etd < c.etd;
    umbral := coalesce(umbral, c.created_at::date - 7);

    select array_agg(distinct upper(wh_decode_entities(a.agente)))
    into agentes
    from consolidado_agentes_destino a
    where a.incluir
      and not consolidado_agente_excluido(a.agente, c.destino, c.id);
    agentes := coalesce(agentes, '{}');

    insert into consolidado_lineas
      (consolidado_id, wr_number, consignee, shipper, agente_destino,
       cs_email, client_id, piezas, peso_lb, volumen_cft, estado, notas,
       piezas_recibo, es_parcial)
    select
      c.id,
      w.wr_number,
      nullif(wh_decode_entities(w.consignee), ''),
      nullif(wh_decode_entities(w.shipper), ''),
      nullif(wh_decode_entities(w.destination_agent), ''),
      case
        when w.destination_agent !~* 'gloval\s+shipping\s+ecuador' then
          (select l.cs_email from consolidado_lineas l
            where l.consolidado_id = c.id and l.cs_email is not null
              and upper(wh_decode_entities(l.agente_destino))
                  = upper(wh_decode_entities(w.destination_agent))
            group by l.cs_email order by count(*) desc limit 1)
        else
          (select u.email from clients cl join users u on u.id = cl.customer_service_id
            where cl.company_name_normalized = w.consignee_normalized
              and cl.deleted_at is null limit 1)
      end,
      (select cl.id from clients cl
        where cl.company_name_normalized = w.consignee_normalized
          and cl.deleted_at is null limit 1),
      d.piezas_en_bodega - d.piezas_comprometidas,
      coalesce(d.peso_onhand_lb, w.weight * d.fraccion_en_bodega),
      coalesce(d.vol_onhand_cft, w.volume_cft * d.fraccion_en_bodega),
      case when w.status = 'Loaded' then 'INSTRUIDO' else 'DISPONIBLE' end,
      case
        when d.piezas_recibo > d.piezas_en_bodega - d.piezas_comprometidas
          then 'auto · PARCIAL: ' || (d.piezas_en_bodega - d.piezas_comprometidas)
               || ' de ' || d.piezas_recibo || ' piezas del recibo'
        when w.status = 'Loaded' then 'auto · ya cargada por Miami'
        else 'auto'
      end,
      d.piezas_recibo,
      d.piezas_recibo > d.piezas_en_bodega - d.piezas_comprometidas
    from magaya_warehouse_receipts w
    join v_consolidado_wr_disponible d on d.wr_number = w.wr_number
    where w.wr_number ~ '^[0-9]+$'
      and w.created_on >= current_date - 150
      and d.piezas_en_bodega - d.piezas_comprometidas > 0
      and not es_carga_de_tenant(w.destination_agent, w.consignee)
      and coalesce(w.destination_agent, '') !~* 'gloval\s+shipping\s+usa'
      and not consolidado_agente_excluido(w.destination_agent, c.destino, c.id)
      and (coalesce(w.destination_port, '') = ''
           or w.destination_port ilike '%' || c.destino || '%')
      and (w.destination_port ilike '%' || c.destino || '%'
           or (coalesce(w.destination_port, '') = ''
               and upper(wh_decode_entities(w.destination_agent)) = any(agentes)))
      and not exists (select 1 from consolidado_lineas l2
                       where l2.consolidado_id = c.id and l2.wr_number = w.wr_number)
      and not exists (select 1 from consolidado_lineas l4
                       where l4.consolidado_id = c.id and l4.wr_number = w.wr_number
                         and l4.estado = 'EXCLUIDO')
      and (
        w.status = 'Loaded'
        or (w.entry_date >= umbral or (w.entry_date is null and w.created_on >= umbral))
        or (w.last_full_fetch_at >= now() - interval '7 days'
            and w.created_on >= current_date - 120)
      );

    get diagnostics ins = row_count;
    total := total || jsonb_build_object(
      'consolidado', coalesce(c.booking, c.anio || '-S' || c.semana),
      'insertadas', ins);
  end loop;

  return jsonb_build_object(
    'insertadas', total,
    'depuradas_salio_bodega', depurado,
    'avisos_huerfanos_borrados', huerfanos);
end;
$function$;

CREATE OR REPLACE FUNCTION public.consolidado_regenerar_avisos_si_cambio()
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  c record;
  v_firma text;
  v_bearer text;
  v_pedidos int := 0;
begin
  select substring(command from 'Bearer\s+([A-Za-z0-9._-]+)') into v_bearer
  from cron.job where jobname = 'wh-saldo-backfill' limit 1;
  if v_bearer is null then
    return jsonb_build_object('error', 'sin token para invocar el builder');
  end if;

  for c in
    select c2.id, c2.avisos_firma, c2.avisos_regen_pedido_at
    from consolidados c2
    where c2.estado = 'ABIERTO'
      and exists (select 1 from consolidado_avisos a where a.consolidado_id = c2.id)
  loop
    v_firma := consolidado_avisos_firma(c.id);
    if v_firma is distinct from c.avisos_firma
       and (c.avisos_regen_pedido_at is null or c.avisos_regen_pedido_at < now() - interval '10 minutes') then
      perform net.http_post(
        url := 'https://wfzdrqfurwnakrfdnbgf.supabase.co/functions/v1/consolidado-aviso-builder',
        headers := jsonb_build_object('Content-Type', 'application/json', 'Authorization', 'Bearer ' || v_bearer),
        body := jsonb_build_object('consolidado_id', c.id),
        timeout_milliseconds := 150000);
      update consolidados set avisos_regen_pedido_at = now() where id = c.id;
      v_pedidos := v_pedidos + 1;
    end if;
  end loop;

  return jsonb_build_object('regeneraciones_pedidas', v_pedidos);
end $function$;

CREATE OR REPLACE FUNCTION public.consolidado_regimen_desde_magaya(p_ids uuid[])
 RETURNS TABLE(id uuid, regimen text, regimen_numero text, regimen_fecha date)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
  RETURN QUERY
  UPDATE consolidado_lineas l
  SET regimen_fuente = 'AUTO',
      -- Si Magaya todavia no reviso ese WR, se cae a NORMAL: es lo unico
      -- honesto que se puede afirmar sin el dato, y el espejo lo corregira en
      -- cuanto el WR pase por el sync.
      regimen        = coalesce(wh_regimen_desde_magaya(w.bonded_entry), 'NORMAL'),
      regimen_numero = w.bonded_entry_number,
      regimen_fecha  = w.bonded_entry_date
  FROM magaya_warehouse_receipts w
  WHERE w.wr_number = l.wr_number
    AND l.id = ANY(p_ids)
  RETURNING l.id, l.regimen, l.regimen_numero, l.regimen_fecha;
END; $function$;

CREATE OR REPLACE FUNCTION public.consolidado_sacar_de_la_semana(p_linea_ids uuid[], p_accion text, p_motivo text DEFAULT NULL::text)
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_quien  text;
  v_fecha  text := to_char(now() at time zone 'America/New_York', 'DD-MM-YYYY');
  v_motivo text := nullif(trim(p_motivo), '');
  n        int;
begin
  if not (app_can('operaciones', 'edit')
       or coalesce(auth.role(), '') = 'service_role'
       or session_user in ('postgres', 'supabase_admin')) then
    raise exception 'no autorizado: hace falta permiso de editar en Operaciones';
  end if;
  if p_accion is null or p_accion not in ('NO_SE_CARGA', 'YA_SE_FUE') then
    raise exception 'Acción desconocida: %', p_accion;
  end if;

  select name into v_quien from users where id = app_current_user_id();
  v_quien := coalesce(v_quien, 'sistema');

  -- Rastro primero, con el contenedor en el que estaba (si estaba en uno).
  insert into consolidado_linea_movimientos
    (linea_id, consolidado_id, wr_number, accion, contenedor_id, contenedor, motivo, hecho_por)
  select l.id, l.consolidado_id, l.wr_number,
         case when p_accion = 'YA_SE_FUE' then 'SALIO' else 'NO_SE_CARGA' end,
         l.contenedor_id, l.contenedor, v_motivo, app_current_user_id()
  from consolidado_lineas l
  join consolidados c on c.id = l.consolidado_id
  where l.id = any(p_linea_ids)
    and c.estado in ('ABIERTO', 'CERRADO')
    and l.estado in ('DISPONIBLE', 'AVISADO', 'INSTRUIDO', 'APROBADO', 'NO_EMBARCA');

  if p_accion = 'NO_SE_CARGA' then
    -- Vuelve a Customer Service SIN instrucción: Operaciones solo ve lo que CS
    -- instruyó. CS ve por qué salió: el tooltip del estado es esta nota.
    update consolidado_lineas l
       set estado = 'DISPONIBLE',
           contenedor_id = null, contenedor = null, sello = null,
           cargado_confirmado_at = null, cargado_confirmado_por = null,
           instruido_at = null, instruido_por = null,
           instruccion_nota = 'No se carga esta semana — Operaciones (' || v_quien || ', ' || v_fecha || ')'
                              || coalesce(': ' || v_motivo, ''),
           updated_at = now()
      from consolidados c
     where c.id = l.consolidado_id
       and l.id = any(p_linea_ids)
       and c.estado in ('ABIERTO', 'CERRADO')
       and l.estado in ('DISPONIBLE', 'AVISADO', 'INSTRUIDO', 'APROBADO', 'NO_EMBARCA');
  else
    -- Ya se fue de bodega (cargo release, otro embarque, marcador que ya no
    -- existe): sale del tablero y el zarpe no la rueda.
    update consolidado_lineas l
       set estado = 'SALIO_BODEGA',
           contenedor_id = null, contenedor = null, sello = null,
           cargado_confirmado_at = null, cargado_confirmado_por = null,
           notas = coalesce(nullif(l.notas, '') || ' · ', '')
                   || 'Ya se fue de bodega — la sacó ' || v_quien || ' el ' || v_fecha
                   || coalesce(': ' || v_motivo, ''),
           updated_at = now()
      from consolidados c
     where c.id = l.consolidado_id
       and l.id = any(p_linea_ids)
       and c.estado in ('ABIERTO', 'CERRADO')
       and l.estado in ('DISPONIBLE', 'AVISADO', 'INSTRUIDO', 'APROBADO', 'NO_EMBARCA');
  end if;
  get diagnostics n = row_count;

  -- Las piezas elegidas una por una quedan libres.
  delete from consolidado_linea_piezas p
   using consolidado_lineas l, consolidados c
   where p.linea_id = l.id
     and c.id = l.consolidado_id
     and l.id = any(p_linea_ids)
     and c.estado in ('ABIERTO', 'CERRADO')
     and l.estado in ('DISPONIBLE', 'SALIO_BODEGA')
     and l.contenedor_id is null;

  return n;
end;
$function$;

CREATE OR REPLACE FUNCTION public.consolidado_sacar_del_contenedor(p_linea_ids uuid[], p_motivo text DEFAULT NULL::text)
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare n int;
begin
  insert into consolidado_linea_movimientos
    (linea_id, consolidado_id, wr_number, accion, contenedor_id, contenedor, motivo, hecho_por)
  select l.id, l.consolidado_id, l.wr_number, 'SACA', l.contenedor_id, l.contenedor,
         nullif(trim(p_motivo), ''), app_current_user_id()
  from consolidado_lineas l
  where l.id = any(p_linea_ids) and l.contenedor_id is not null;

  update consolidado_lineas
  set contenedor_id = null, contenedor = null, sello = null,
      -- Sacarla del contenedor deshace también la confirmación de bodega: lo
      -- que ya no está adentro no puede seguir marcado como cargado.
      cargado_confirmado_at = null, cargado_confirmado_por = null,
      updated_at = now()
  where id = any(p_linea_ids) and contenedor_id is not null;

  get diagnostics n = row_count;

  -- Las piezas asignadas vuelven a estar libres.
  delete from consolidado_linea_piezas where linea_id = any(p_linea_ids);

  return n;
end; $function$;

CREATE OR REPLACE FUNCTION public.consolidado_sync_7512()
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE n int;
BEGIN
  WITH cambios AS (
    UPDATE consolidado_lineas l
    SET doc_7512 = d.numero, doc_7512_at = d.registrado_at
    FROM wh_doc_7512 d, consolidados c
    WHERE d.wr_number = l.wr_number
      AND c.id = l.consolidado_id
      AND c.estado IN ('ABIERTO','CERRADO')
      AND coalesce(l.doc_7512, '') IS DISTINCT FROM d.numero
    RETURNING 1
  )
  SELECT count(*) INTO n FROM cambios;
  RETURN n;
END; $function$;

CREATE OR REPLACE FUNCTION public.consolidado_sync_hazmat_magaya()
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare n int := 0; r record; d record;
begin
  for r in
    select l.id, l.consolidado_id, l.wr_number
    from consolidado_lineas l
    join consolidados c on c.id = l.consolidado_id
    where c.estado in ('ABIERTO','CERRADO')
      and l.estado not in ('EXCLUIDO','RODADO')
      and coalesce(l.hazmat, false) = false
      and coalesce(l.hazmat_fuente, 'AUTO') <> 'MANUAL'
  loop
    select * into d from wh_hazmat_de_recibo(r.wr_number);
    if coalesce(d.es_hazmat, false) then
      update consolidado_lineas
      set hazmat = true,
          hazmat_fuente = 'AUTO',
          notas = coalesce(notas || ' · ', '') || 'HAZMAT leído del recibo de bodega.',
          updated_at = now()
      where id = r.id;
      n := n + 1;

      -- Los UN del texto entran como clasificación (sin clase: esa la pone la
      -- CS o Karla — el tablero ya avisa "haz sin clase").
      insert into consolidado_linea_hazmat (linea_id, consolidado_id, un_number, imo_class, doc_recibido)
      select r.id, r.consolidado_id, u, null, false
      from unnest(d.uns) as u
      where not exists (
        select 1 from consolidado_linea_hazmat x
        where x.linea_id = r.id and x.un_number = u
      );
    end if;
  end loop;
  return n;
end; $function$;

CREATE OR REPLACE FUNCTION public.consolidado_sync_lineas_magaya()
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE n int; m int; d int; h int;
BEGIN
  WITH cambios AS (
    UPDATE consolidado_lineas l
    SET consignee      = nullif(wh_decode_entities(w.consignee), ''),
        shipper        = nullif(wh_decode_entities(w.shipper), ''),
        agente_destino = nullif(wh_decode_entities(w.destination_agent), ''),
        piezas         = coalesce(nullif(disp.piezas_en_bodega, 0), l.piezas),
        peso_lb        = coalesce(disp.peso_onhand_lb,
                                  disp.peso_items_lb * disp.fraccion_en_bodega,
                                  nullif(w.weight, 0) * disp.fraccion_en_bodega,
                                  l.peso_lb),
        volumen_cft    = coalesce(disp.vol_onhand_cft,
                                  disp.vol_items_cft * disp.fraccion_en_bodega,
                                  nullif(w.volume_cft, 0) * disp.fraccion_en_bodega,
                                  l.volumen_cft),
        piezas_recibo  = disp.piezas_recibo,
        es_parcial     = disp.piezas_en_bodega > 0
                         and disp.piezas_recibo > disp.piezas_en_bodega,
        notas          = case when l.rodado_desde is not null
                              then 'roleada de la semana anterior · '
                              else 'auto · ' end
          || case
               when disp.piezas_en_bodega = 0
                 then 'SIN SALDO: de este recibo ya no queda nada en bodega'
               when disp.piezas_recibo > disp.piezas_en_bodega
                 then 'PARCIAL: ' || disp.piezas_en_bodega
                      || ' de ' || disp.piezas_recibo || ' piezas del recibo'
               else 'datos actualizados desde Magaya'
             end
    FROM magaya_warehouse_receipts w
    JOIN v_consolidado_wr_disponible disp ON disp.wr_number = w.wr_number,
         consolidados c
    WHERE w.wr_number = l.wr_number
      AND c.id = l.consolidado_id
      AND c.estado = 'ABIERTO'
      -- Lo que la máquina creó: nacida del refresh (notas 'auto…') o RODADA.
      -- Lo escrito a mano no se pisa.
      AND (coalesce(l.notas, '') LIKE 'auto%' OR l.rodado_desde IS NOT NULL)
      AND l.estado IN ('DISPONIBLE', 'AVISADO')
      AND l.origen_oficina = 'EC'
      AND l.grupo_id IS NULL
      AND l.contenedor_id IS NULL
      AND coalesce(w.consignee, '') <> ''
      AND (
        upper(coalesce(l.consignee, '')) IS DISTINCT FROM upper(wh_decode_entities(coalesce(w.consignee, '')))
        OR upper(coalesce(l.agente_destino, '')) IS DISTINCT FROM upper(wh_decode_entities(coalesce(w.destination_agent, '')))
        OR (coalesce(l.volumen_cft, 0) = 0 AND coalesce(w.volume_cft, 0) > 0)
        OR l.piezas IS DISTINCT FROM nullif(disp.piezas_en_bodega, 0)
        OR l.es_parcial IS DISTINCT FROM (disp.piezas_en_bodega > 0
                                          and disp.piezas_recibo > disp.piezas_en_bodega)
        OR abs(coalesce(l.volumen_cft,0) - coalesce(disp.vol_onhand_cft,
                 disp.vol_items_cft * disp.fraccion_en_bodega, l.volumen_cft, 0)) > 1
      )
    RETURNING 1
  )
  SELECT count(*) INTO n FROM cambios;

  m := consolidado_sync_regimen_magaya();
  d := consolidado_sync_7512();
  h := consolidado_sync_hazmat_magaya();
  RETURN n + m + d + h;
END; $function$;

CREATE OR REPLACE FUNCTION public.consolidado_sync_magaya_confirmadas()
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare n_cons int := 0; n_cif int := 0;
begin
  -- Consignatario: manda Magaya en los servicios que se arman desde Magaya. En
  -- los cuadros de loading la columna del nombre suele ser el SHIPPER (768991
  -- salía como "Farma International" y es INDUREC). Si Magaya trae a Gloval
  -- como consignatario no se toca: el cliente real lo pone el cuadro o CS.
  update consolidado_lineas l
     set consignee = nullif(wh_decode_entities(w.consignee), ''),
         notas = coalesce(nullif(l.notas, '') || ' · ', '')
                 || 'Consignatario corregido desde Magaya (antes: ' || coalesce(l.consignee, '—') || ')',
         updated_at = now()
    from consolidados c, consolidado_servicios sv, magaya_warehouse_receipts w
   where c.id = l.consolidado_id
     and c.estado in ('ABIERTO', 'CERRADO')
     and sv.codigo = c.servicio
     and sv.fuente_lineas = 'MAGAYA_WR'
     and w.wr_number = l.wr_number
     and l.estado in ('DISPONIBLE', 'AVISADO', 'INSTRUIDO', 'APROBADO', 'NO_EMBARCA')
     and coalesce(wh_decode_entities(w.consignee), '') !~ '^\s*$'
     and wh_decode_entities(w.consignee) !~* '^\s*([a-z]{1,2}[\s.]+)?gloval'
     and upper(trim(wh_decode_entities(w.consignee))) is distinct from upper(trim(coalesce(l.consignee, '')));
  get diagnostics n_cons = row_count;

  -- Cifras: una línea confirmada en 0 lb y 0 cft (el sync le pone cero a lo que
  -- se quedó sin saldo en bodega; lo que Miami carga sin instrucción llegaba así
  -- a los contenedores) toma las de la cabecera del recibo. Vale para todos los
  -- servicios.
  update consolidado_lineas l
     set peso_lb = w.weight,
         volumen_cft = w.volume_cft,
         notas = coalesce(nullif(l.notas, '') || ' · ', '') || 'Cifras de la cabecera de Magaya (la línea estaba en 0)',
         updated_at = now()
    from consolidados c, magaya_warehouse_receipts w
   where c.id = l.consolidado_id
     and c.estado in ('ABIERTO', 'CERRADO')
     and w.wr_number = l.wr_number
     and l.estado in ('INSTRUIDO', 'APROBADO')
     and not l.es_parcial
     and coalesce(l.peso_lb, 0) = 0 and coalesce(l.volumen_cft, 0) = 0
     and (coalesce(w.weight, 0) > 0 or coalesce(w.volume_cft, 0) > 0);
  get diagnostics n_cif = row_count;

  return jsonb_build_object('consignatarios', n_cons, 'cifras', n_cif);
end;
$function$;

CREATE OR REPLACE FUNCTION public.consolidado_sync_regimen_magaya()
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE n int;
BEGIN
  WITH cambios AS (
    UPDATE consolidado_lineas l
    SET regimen        = wh_regimen_desde_magaya(w.bonded_entry),
        regimen_numero = w.bonded_entry_number,
        regimen_fecha  = w.bonded_entry_date
    FROM magaya_warehouse_receipts w, consolidados c
    WHERE w.wr_number = l.wr_number
      AND c.id = l.consolidado_id
      AND c.estado IN ('ABIERTO', 'CERRADO')
      AND coalesce(l.regimen_fuente, 'AUTO') <> 'MANUAL'
      AND w.bonded_checked_at IS NOT NULL
      AND (
        l.regimen IS DISTINCT FROM wh_regimen_desde_magaya(w.bonded_entry)
        OR coalesce(l.regimen_numero, '') IS DISTINCT FROM coalesce(w.bonded_entry_number, '')
        OR l.regimen_fecha IS DISTINCT FROM w.bonded_entry_date
      )
    RETURNING 1
  )
  SELECT count(*) INTO n FROM cambios;
  RETURN n;
END; $function$;

CREATE OR REPLACE FUNCTION public.consolidado_zarpar(p_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  destino_id uuid;
  emb int := 0; rod int := 0; cop int := 0; enr int := 0; haz int := 0; dep int := 0;
  o consolidados%rowtype;
begin
  select * into o from consolidados where id = p_id and estado in ('ABIERTO','CERRADO');
  if not found then
    return jsonb_build_object('error', 'el consolidado ya zarpó o no existe');
  end if;

  -- Solo embarca lo que está EN un contenedor.
  update consolidado_lineas set estado = 'EMBARCADO'
  where consolidado_id = p_id and estado in ('INSTRUIDO','APROBADO')
    and contenedor_id is not null;
  get diagnostics emb = row_count;

  -- ANTES de rodar: lo que ya dejó la bodega no rueda. El rodaje decidía
  -- mirando solo el estado interno de la línea y arrastraba carga navegando
  -- semana tras semana hasta terminar en el aviso al cliente.
  dep := consolidado_depurar_salidas(p_id);

  -- La siguiente semana ABIERTA del mismo servicio, nunca una anterior: el texto
  -- de destino no es estable entre semanas ('CALLAO - PERU' vs 'CALLAO, PERU').
  select c2.id into destino_id
  from consolidados c2
  where c2.id <> p_id and c2.estado = 'ABIERTO' and c2.modo = o.modo
    and (case when o.servicio is not null then c2.servicio = o.servicio
              else c2.destino = o.destino end)
    and (c2.anio, c2.semana) > (o.anio, o.semana)
  order by c2.anio, c2.semana, c2.etd nulls last
  limit 1;

  if destino_id is not null then
    -- Copiar ANTES de aplanar: el estado de origen decide cómo nace en destino.
    -- Lo instruido que no se cargó nace DISPONIBLE (regla de Andrés, 15-sep-2026:
    -- Operaciones solo ve lo que CS instruyó ESTA semana). La instrucción vieja
    -- queda anotada para que CS la reconfirme con el cliente.
    insert into consolidado_lineas
      (consolidado_id, wr_number, consignee, shipper, client_id, cs_email, agente_destino,
       piezas, peso_lb, volumen_cft, hazmat, estado, origen_oficina, apilable,
       regimen, regimen_fuente, regimen_numero, regimen_fecha,
       doc_7512, doc_7512_at, nota_bodega, notas, instruccion_nota, rodado_desde)
    select destino_id, l.wr_number, l.consignee, l.shipper, l.client_id, l.cs_email, l.agente_destino,
           l.piezas, l.peso_lb, l.volumen_cft, l.hazmat,
           case when l.estado = 'NO_EMBARCA' then 'NO_EMBARCA' else 'DISPONIBLE' end,
           l.origen_oficina, l.apilable,
           l.regimen, coalesce(l.regimen_fuente, 'AUTO'), l.regimen_numero, l.regimen_fecha,
           l.doc_7512, l.doc_7512_at, l.nota_bodega,
           'roleada de la semana anterior',
           case when l.estado in ('INSTRUIDO','APROBADO')
                then 'Venía instruida de la semana ' || o.semana || ' y no se cargó — reconfirmar con el cliente'
                     || coalesce(' · antes: ' || nullif(l.instruccion_nota, ''), '')
                else l.instruccion_nota end,
           l.id
    from consolidado_lineas l
    where l.consolidado_id = p_id
      and l.estado in ('DISPONIBLE','AVISADO','NO_EMBARCA','INSTRUIDO','APROBADO')
      -- tenant/impo no rolea: no es carga de consolidado
      and not es_carga_de_tenant(l.agente_destino, l.consignee)
      and coalesce(l.agente_destino, '') !~* 'gloval\s+shipping\s+usa'
      and not exists (select 1 from consolidado_lineas d
                       where d.consolidado_id = destino_id and d.wr_number = l.wr_number)
    on conflict (consolidado_id, wr_number) where contenedor_id is null do nothing;
    get diagnostics cop = row_count;

    update consolidado_lineas d
    set regimen          = o2.regimen,
        regimen_fuente   = coalesce(o2.regimen_fuente, 'AUTO'),
        regimen_numero   = o2.regimen_numero,
        regimen_fecha    = o2.regimen_fecha,
        doc_7512         = o2.doc_7512,
        doc_7512_at      = o2.doc_7512_at,
        nota_bodega      = coalesce(o2.nota_bodega, d.nota_bodega),
        hazmat           = coalesce(o2.hazmat, d.hazmat),
        apilable         = o2.apilable,
        estado           = case when o2.estado = 'NO_EMBARCA' then 'NO_EMBARCA' else d.estado end,
        instruccion_nota = case when o2.estado in ('INSTRUIDO','APROBADO')
                                then 'Venía instruida de la semana ' || o.semana || ' y no se cargó — reconfirmar con el cliente'
                                     || coalesce(' · antes: ' || nullif(o2.instruccion_nota, ''), '')
                                else d.instruccion_nota end,
        rodado_desde     = o2.id,
        notas            = 'roleada de la semana anterior'
    from consolidado_lineas o2
    where o2.consolidado_id = p_id
      and o2.estado in ('DISPONIBLE','AVISADO','NO_EMBARCA','INSTRUIDO','APROBADO')
      and d.consolidado_id = destino_id
      and d.wr_number = o2.wr_number
      and d.id <> o2.id
      and d.rodado_desde is null
      and coalesce(d.doc_7512, '') = ''
      and coalesce(d.regimen_fuente, 'AUTO') <> 'MANUAL'
      and d.estado in ('DISPONIBLE','AVISADO');
    get diagnostics enr = row_count;

    insert into consolidado_linea_hazmat (linea_id, consolidado_id, un_number, imo_class, doc_recibido)
    select d.id, destino_id, h.un_number, h.imo_class, h.doc_recibido
    from consolidado_lineas d
    join consolidado_lineas o2 on o2.id = d.rodado_desde and o2.consolidado_id = p_id
    join consolidado_linea_hazmat h on h.linea_id = o2.id
    where d.consolidado_id = destino_id
      and not exists (
        select 1 from consolidado_linea_hazmat x
        where x.linea_id = d.id
          and coalesce(x.un_number, '') = coalesce(h.un_number, '')
          and coalesce(x.imo_class, '') = coalesce(h.imo_class, '')
      );
    get diagnostics haz = row_count;
  end if;

  -- Ahora sí: todo lo no embarcado queda RODADO en la semana que zarpó.
  update consolidado_lineas set estado = 'RODADO'
  where consolidado_id = p_id
    and estado in ('DISPONIBLE','AVISADO','NO_EMBARCA','INSTRUIDO','APROBADO');
  get diagnostics rod = row_count;

  update consolidados set estado = 'ZARPADO' where id = p_id;

  return jsonb_build_object('ok', true, 'embarcadas', emb, 'rodadas', rod,
    'copiadas_a_siguiente', cop, 'enriquecidas_en_destino', enr,
    'hazmat_copiado', haz, 'salio_bodega', dep, 'destino', destino_id);
end;
$function$;

CREATE OR REPLACE FUNCTION public.coordination_tasks_set_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$ begin new.updated_at := now(); return new; end $function$;

CREATE OR REPLACE FUNCTION public.create_manifest_from_pdf_import(p_header jsonb, p_items jsonb, p_warehouse_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
DECLARE
  v_user_id uuid;
  v_manifest_id uuid;
  v_external_number text;
  v_source_type manifest_source_type;
  v_items_created int := 0;
  v_items_skipped int := 0;
  v_picking_task_id uuid;
BEGIN
  v_user_id := cl_warehouse_user_id();
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'No warehouse access for current user';
  END IF;

  v_external_number := COALESCE(p_header->>'external_number', 'IMPORT-' || to_char(now(), 'YYYYMMDDHH24MISS'));
  v_source_type := COALESCE((p_header->>'source_type')::manifest_source_type, 'cargo_release');

  -- 1. Manifest source
  INSERT INTO manifest_sources (
    source_type, external_number, container_number, container_type,
    customer_name, destination, warehouse_id, workflow_status,
    snapshot_taken_at
  ) VALUES (
    v_source_type,
    v_external_number,
    p_header->>'container_number',
    p_header->>'container_type',
    p_header->>'customer_name',
    p_header->>'destination',
    p_warehouse_id,
    'picking_pending',
    now()
  )
  RETURNING id INTO v_manifest_id;

  -- 2. Picking task (sin asignar — supervisor decide)
  INSERT INTO picking_tasks (
    manifest_source_id, task_type, equipment_required, status
  ) VALUES (
    v_manifest_id, 'MIXED', 'NONE', 'pending'
  )
  RETURNING id INTO v_picking_task_id;

  -- 3. Manifest items desde el JSONB array
  WITH item_rows AS (
    SELECT
      (elem->>'barcode')::text                     AS barcode,
      (elem->>'wr_number')::text                   AS wr_number,
      (elem->>'location')::text                    AS location,
      (elem->>'item_type')::cl_item_type           AS item_type,
      (elem->>'dimensions')::text                  AS dimensions,
      (elem->>'weight_kg')::numeric                AS weight_kg,
      (elem->>'volume_m3')::numeric                AS volume_m3,
      (elem->>'description')::text                 AS description,
      (elem->>'package_descriptor')::text          AS package_descriptor,
      COALESCE((elem->>'is_hazmat')::boolean, false)    AS is_hazmat,
      (elem->>'hazmat_un')::text                   AS hazmat_un,
      COALESCE((elem->>'is_bonded')::boolean, false)    AS is_bonded,
      COALESCE((elem->>'is_fumigated')::boolean, false) AS is_fumigated,
      COALESCE((elem->>'is_fragile')::boolean, false)   AS is_fragile,
      COALESCE((elem->>'is_heavy')::boolean, false)     AS is_heavy,
      NULLIF((elem->>'piece_index'), '')::int      AS piece_index,
      NULLIF((elem->>'wr_total_pieces'), '')::int  AS wr_total_pieces
    FROM jsonb_array_elements(p_items) AS elem
  )
  INSERT INTO manifest_items (
    manifest_source_id, assigned_picking_task_id,
    barcode, wr_number, location, item_type, dimensions,
    weight_kg, volume_m3, description, package_descriptor,
    is_hazmat, hazmat_un, is_bonded, is_fumigated, is_fragile, is_heavy,
    piece_index, wr_total_pieces
  )
  SELECT
    v_manifest_id, v_picking_task_id,
    barcode, wr_number, location, item_type, dimensions,
    weight_kg, volume_m3, description, package_descriptor,
    is_hazmat, hazmat_un, is_bonded, is_fumigated, is_fragile, is_heavy,
    piece_index, wr_total_pieces
  FROM item_rows;

  GET DIAGNOSTICS v_items_created = ROW_COUNT;

  -- 4. Audit log
  INSERT INTO cl_audit_log (action, target_table, target_id, performed_by, reason, metadata)
  VALUES (
    'manifest_imported_from_pdf',
    'manifest_sources',
    v_manifest_id,
    v_user_id,
    'PDF import: ' || v_external_number,
    jsonb_build_object(
      'items_created', v_items_created,
      'source_type', v_source_type::text,
      'has_notes', (p_header->>'raw_notes') IS NOT NULL,
      'seal_number', p_header->>'seal_number',
      'carrier_name', p_header->>'carrier_name'
    )
  );

  RETURN jsonb_build_object(
    'manifest_source_id', v_manifest_id,
    'external_number', v_external_number,
    'items_created', v_items_created,
    'items_skipped', v_items_skipped,
    'picking_task_id', v_picking_task_id
  );
END;
$function$;

CREATE OR REPLACE FUNCTION public.cs_assign_client_default()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
declare v_first_exec uuid;
begin
  if new.assigned_to is null then
    select sales_executive_id into v_first_exec
      from public.cs_assignments ca
      join public.users u on u.id = ca.cs_user_id
      where u.auth_user_id = auth.uid() and ca.active
      order by is_primary desc nulls last
      limit 1;
    if v_first_exec is not null then new.assigned_to := v_first_exec; end if;
  end if;
  return new;
end $function$;

CREATE OR REPLACE FUNCTION public.delete_2025_modality(p_modality text)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET statement_timeout TO '30min'
 SET search_path TO 'public', 'pg_catalog'
AS $function$
declare
  v_count integer;
  v_t0 timestamptz := clock_timestamp();
begin
  delete from public.mi_shipment_intel
  where period_year = 2025 and modality = p_modality::mi_modality_t;
  GET DIAGNOSTICS v_count = ROW_COUNT;
  return format('deleted %s rows for %s in %ss', v_count, p_modality, extract(epoch from clock_timestamp() - v_t0)::int);
end $function$;

CREATE OR REPLACE FUNCTION public.ec_company_search(q text, lim integer DEFAULT 50)
 RETURNS TABLE(kind text, ec_company_id text, company_name text, status text, office text, assigned_to uuid, bls bigint, teus_fcl numeric, valor_comercial numeric, dup_in_crm boolean, client_id uuid)
 LANGUAGE plpgsql
 STABLE
AS $function$
DECLARE
  query_norm text := lower(regexp_replace(coalesce(q, ''), '\s+', ' ', 'g'));
  ruc_only   text := regexp_replace(coalesce(q, ''), '\D', '', 'g');
BEGIN
  IF length(query_norm) < 2 AND length(ruc_only) < 3 THEN
    RETURN;
  END IF;

  RETURN QUERY
  WITH crm_match AS (
    SELECT
      c.id                                                AS client_id,
      regexp_replace(c.ruc, '\D', '', 'g')                AS ec_company_id,
      c.company_name,
      c.status,
      c.office,
      c.assigned_to
    FROM clients c
    WHERE c.office = 'Ecuador'
      AND (
        (length(ruc_only) >= 3 AND regexp_replace(c.ruc, '\D', '', 'g') LIKE ruc_only || '%')
        OR (length(query_norm) >= 2 AND lower(c.company_name) LIKE '%' || query_norm || '%')
      )
    ORDER BY
      CASE WHEN regexp_replace(c.ruc, '\D', '', 'g') = ruc_only THEN 0 ELSE 1 END,
      CASE WHEN lower(c.company_name) LIKE query_norm || '%' THEN 0 ELSE 1 END,
      c.company_name
    LIMIT lim
  ),
  prospect_match AS (
    SELECT
      p.ec_company_id,
      p.ec_company_name AS company_name,
      p.bls, p.teus_fcl, p.valor_comercial
    FROM mi_mv_unassigned_prospects p
    WHERE (length(ruc_only) >= 3 AND p.ec_company_id LIKE ruc_only || '%')
       OR (length(query_norm) >= 2 AND lower(p.ec_company_name) LIKE '%' || query_norm || '%')
    ORDER BY
      CASE WHEN p.ec_company_id = ruc_only THEN 0 ELSE 1 END,
      CASE WHEN lower(p.ec_company_name) LIKE query_norm || '%' THEN 0 ELSE 1 END,
      p.teus_fcl DESC NULLS LAST
    LIMIT lim
  )
  -- CRM rows
  SELECT
    'crm'::text                                                  AS kind,
    cm.ec_company_id,
    cm.company_name,
    cm.status,
    cm.office,
    cm.assigned_to,
    NULL::bigint                                                 AS bls,
    NULL::numeric                                                AS teus_fcl,
    NULL::numeric                                                AS valor_comercial,
    EXISTS (SELECT 1 FROM mi_mv_unassigned_prospects p
            WHERE p.ec_company_id = cm.ec_company_id)            AS dup_in_crm,
    cm.client_id
  FROM crm_match cm

  UNION ALL

  -- Prospect rows (with dup detection)
  SELECT
    'prospect'::text                                             AS kind,
    pm.ec_company_id,
    pm.company_name,
    NULL::text                                                   AS status,
    NULL::text                                                   AS office,
    NULL::uuid                                                   AS assigned_to,
    pm.bls,
    pm.teus_fcl,
    pm.valor_comercial,
    EXISTS (SELECT 1 FROM clients c
            WHERE c.office = 'Ecuador'
              AND regexp_replace(c.ruc, '\D', '', 'g') = pm.ec_company_id)  AS dup_in_crm,
    (SELECT c.id FROM clients c
     WHERE c.office = 'Ecuador'
       AND regexp_replace(c.ruc, '\D', '', 'g') = pm.ec_company_id
     LIMIT 1)                                                                AS client_id
  FROM prospect_match pm
  ORDER BY kind, company_name;
END;
$function$;

CREATE OR REPLACE FUNCTION public.ec_fcl_local_charges_audit()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  new.updated_at := now();
  new.updated_by := auth.uid();
  new.updated_by_email := coalesce(auth.jwt()->>'email', new.updated_by_email);
  if tg_op = 'UPDATE'
     and (new.amount is distinct from old.amount
          or new.effective_from is distinct from old.effective_from) then
    insert into ec_fcl_local_charges_history
      (charge_id, carrier_id, concept, variant, origin, old_amount, new_amount,
       old_effective_from, new_effective_from, changed_by, changed_by_email)
    values
      (new.id, new.carrier_id, new.concept, new.variant, new.origin, old.amount, new.amount,
       old.effective_from, new.effective_from, auth.uid(), auth.jwt()->>'email');
  end if;
  return new;
end $function$;

CREATE OR REPLACE FUNCTION public.enforce_forklift_cert()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE has_cert boolean;
BEGIN
  IF NEW.task_type <> 'PALLETS' OR NEW.assigned_to IS NULL THEN RETURN NEW; END IF;
  SELECT 'forklift_certified' = ANY(certs) INTO has_cert FROM warehouse_users WHERE id = NEW.assigned_to;
  IF NOT has_cert THEN
    RAISE EXCEPTION 'User % is not forklift_certified — cannot assign PALLETS picking task', NEW.assigned_to;
  END IF;
  RETURN NEW;
END $function$;

CREATE OR REPLACE FUNCTION public.enforce_picking_task_split_limit()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE task_count int;
BEGIN
  SELECT count(*) INTO task_count FROM picking_tasks WHERE manifest_source_id = NEW.manifest_source_id;
  IF task_count >= 2 THEN
    RAISE EXCEPTION 'Manifest source % already has 2 picking tasks (split limit)', NEW.manifest_source_id;
  END IF;
  RETURN NEW;
END $function$;

CREATE OR REPLACE FUNCTION public.enforce_stager_not_picker()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE is_also_picker boolean;
BEGIN
  IF NEW.assigned_to IS NULL THEN RETURN NEW; END IF;
  SELECT EXISTS(
    SELECT 1 FROM picking_tasks
    WHERE manifest_source_id = NEW.manifest_source_id AND assigned_to = NEW.assigned_to
  ) INTO is_also_picker;
  IF is_also_picker THEN
    RAISE EXCEPTION 'Stager % was a Picker of this shipment — segregation of duties violation', NEW.assigned_to;
  END IF;
  RETURN NEW;
END $function$;

CREATE OR REPLACE FUNCTION public.enrich_consignee_from_magaya(p_consignee_name text)
 RETURNS text
 LANGUAGE sql
 STABLE
 SET search_path TO 'public', 'pg_catalog'
AS $function$
  select tax_id
  from public.magaya_entities
  where tax_id is not null
    and name_normalized = public.normalize_company_name(p_consignee_name)
  order by synced_at desc nulls last
  limit 1;
$function$;

CREATE OR REPLACE FUNCTION public.es_carga_de_tenant(p_agente text, p_consignatario text)
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
  select exists (
    select 1 from bodega_tenants t
    where t.activo
      and (
        (t.campo = 'agente'
         and upper(wh_decode_entities(coalesce(p_agente, ''))) = upper(t.nombre))
        or
        (t.campo = 'consignatario'
         and upper(wh_decode_entities(coalesce(p_consignatario, ''))) = upper(t.nombre))
      )
  );
$function$;

CREATE OR REPLACE FUNCTION public.es_pool(w wh_notices)
 RETURNS boolean
 LANGUAGE sql
 STABLE
AS $function$
  select public.app_wh_is_pool(w.wr_number, w.client_id);
$function$;

CREATE OR REPLACE FUNCTION public.estado_carga(n wh_notices)
 RETURNS text
 LANGUAGE sql
 STABLE
AS $function$
  with it as (
    select
      coalesce(sum(i.pieces) filter (where i.status = 'OnHand'), 0) as onhand,
      coalesce(sum(i.pieces) filter (where i.status in ('Loaded','InTransit','AtDestination','Delivered')), 0) as fuera,
      coalesce(sum(i.pieces) filter (where i.status in ('Pending','Arriving')), 0) as porllegar,
      count(*) filter (where i.status is not null) as con_estado
    from public.magaya_wr_items i
    where i.wr_number = n.wr_number
  ), w as (
    select out_date from public.magaya_warehouse_receipts where wr_number = n.wr_number
  )
  select case
    -- Sin estado por pieza: la fecha de salida de la cabecera es señal
    -- suficiente para AVISAR en pantalla (no se usa para facturar).
    when it.con_estado = 0 and (select out_date from w) is not null then 'EMBARCADO'
    when it.con_estado = 0                                          then 'SIN_DETALLE'
    when it.onhand > 0 and it.fuera > 0                             then 'PARCIAL'
    when it.onhand > 0                                              then 'EN_BODEGA'
    when it.fuera > 0                                               then 'EMBARCADO'
    when it.porllegar > 0                                           then 'POR_LLEGAR'
    else 'SIN_CLASIFICAR'
  end
  from it;
$function$;

CREATE OR REPLACE FUNCTION public.extract_magaya_payment_items()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  IF NEW.transaction_type IN ('PM','CK') AND NEW.raw_xml IS NOT NULL THEN
    -- Delete previous applications from this payment (in case of update)
    DELETE FROM magaya_payment_application
    WHERE company_id = NEW.company_id AND payment_guid = NEW.magaya_guid::uuid;
    
    -- Extract all PaymentItems
    INSERT INTO magaya_payment_application (company_id, payment_guid, item_paid_guid, amount_paid, payment_date)
    SELECT 
      NEW.company_id,
      NEW.magaya_guid::uuid,
      m[1]::uuid,
      m[2]::numeric,
      NEW.created_on
    FROM regexp_matches(
      NEW.raw_xml,
      '<ItemPaidGUID>([0-9a-f-]+)</ItemPaidGUID>(?:[^<]|<(?!ItemPaidGUID>))*?<AmountPaid[^>]*>([0-9.]+)</AmountPaid>',
      'g'
    ) AS m
    WHERE m[2]::numeric > 0
    ON CONFLICT (company_id, payment_guid, item_paid_guid) DO UPDATE SET
      amount_paid = EXCLUDED.amount_paid,
      payment_date = EXCLUDED.payment_date;
  END IF;
  RETURN NEW;
END;
$function$;

CREATE OR REPLACE FUNCTION public.finanzas_access_list()
 RETURNS TABLE(email text, nombre text, office_code text, can_grant boolean, granted_at timestamp with time zone)
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
  select u.email, u.name, fa.office_code, fa.can_grant, fa.granted_at
  from finanzas_access fa join users u on u.id = fa.user_id
  where app_finanzas_can_grant()
  order by u.email, fa.office_code
$function$;

CREATE OR REPLACE FUNCTION public.finanzas_flujo_13s(p_office text DEFAULT 'CONSOLIDADO'::text, p_escenario text DEFAULT 'base'::text, p_operacion_futura boolean DEFAULT true)
 RETURNS TABLE(office_code text, semana integer, inicio date, fin date, linea text, detalle text, monto numeric)
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
#variable_conflict use_column
declare
  v_hoy date := (now() at time zone 'America/New_York')::date;
  v_w1 date := date_trunc('week', (now() at time zone 'America/New_York'))::date;
  v_permitidas text[];
  v_offices text[];
begin
  if p_escenario not in ('base', 'optimista', 'pesimista') then
    raise exception 'escenario inválido: %', p_escenario;
  end if;

  if coalesce(auth.role(), '') in ('authenticated', 'anon') then
    v_permitidas := app_finanzas_offices();
  else
    v_permitidas := array['USA', 'ECU', 'PAN', 'PER'];
  end if;

  if p_office is null or p_office = 'CONSOLIDADO' then
    v_offices := array(select x from unnest(array['USA', 'ECU', 'PAN', 'PER']) x where x = any(v_permitidas));
  elsif p_office in ('USA', 'ECU', 'PAN', 'PER') and p_office = any(v_permitidas) then
    v_offices := array[p_office];
  else
    raise exception 'sin acceso a la oficina %', p_office;
  end if;

  if cardinality(v_offices) = 0 then
    return;
  end if;

  return query
  with params as (
    select
      case p_escenario when 'optimista' then -3 when 'pesimista' then 14 else 0 end as ar_extra_dias,
      case p_escenario when 'pesimista' then 3 else 2 end as ar130_desde,
      case p_escenario when 'optimista' then 1 when 'pesimista' then 3 else 2 end as ar130_n,
      case p_escenario when 'pesimista' then 5 else 3 end as ar3190_desde,
      case p_escenario when 'optimista' then 2 when 'pesimista' then 5 else 4 end as ar3190_n,
      case p_escenario when 'optimista' then 1.0 when 'pesimista' then 0.5 else 0.8 end as ar_pct_31_90,
      case p_escenario when 'pesimista' then 0.85 else 1.0 end as futura_ar_factor
  ), semanas as (
    select g as semana, v_w1 + (g - 1) * 7 as inicio, v_w1 + (g - 1) * 7 + 6 as fin
    from generate_series(1, 13) g
  ), atrasos as (
    select v.office_code, v.kind, v.dias
    from (values
      ('USA', 'AR', 4), ('ECU', 'AR', 3), ('PAN', 'AR', 4), ('PER', 'AR', 2),
      ('USA', 'AP', 8), ('ECU', 'AP', 1), ('PAN', 'AP', 4), ('PER', 'AP', 0)
    ) v(office_code, kind, dias)
    where v.office_code = any(v_offices)
  ), ent as (
    select finanzas_office_code_for_office(e.office_id) as office_code, e.office_id, e.kind, e.entity_name,
           e.balance_usd, coalesce(e.saldo_calc, 0) as saldo_calc,
           (upper(e.entity_name) like '%GLOVAL%') as es_ic
    from v_finanzas_arap_entidad e
    where finanzas_office_code_for_office(e.office_id) = any(v_offices)
  ), docs as (
    select ent.office_code, d.kind, d.entity_name, d.numero, d.doc_guid, d.vence, d.saldo_usd, ent.es_ic,
           greatest(ent.saldo_calc - ent.balance_usd, 0) as reducir
    from mv_finanzas_docs_abiertos d
    join ent on ent.office_id = d.office_id and ent.kind = d.kind and ent.entity_name = d.entity_name
  ), ord as (
    select docs.*,
           coalesce(sum(greatest(docs.saldo_usd, 0)) over (
             partition by docs.office_code, docs.kind, docs.entity_name
             order by docs.vence, docs.doc_guid
             rows between unbounded preceding and 1 preceding), 0) as pos_antes
    from docs
  ), adj as (
    select ord.office_code, ord.kind, ord.numero, ord.vence, ord.es_ic,
           ord.saldo_usd - least(greatest(ord.saldo_usd, 0), greatest(ord.reducir - ord.pos_antes, 0)) as saldo
    from ord
    union all
    select ent.office_code, ent.kind, null::text, v_hoy, ent.es_ic, ent.balance_usd - ent.saldo_calc
    from ent
    where ent.balance_usd - ent.saldo_calc > 0.005
  ), excl as (
    select x.office_code, x.numero, min(x.motivo) as motivo
    from (
      select 'ECU'::text as office_code, f.transaction_number as numero, 'anticipado'::text as motivo
      from v_finanzas_factoring_rc f
      union all
      select o.code, z.numero, 'por_zarpar'::text
      from finanzas_rc_por_zarpar z
      join offices o on o.id = z.office_id
      where z.zarpo_at is null
    ) x
    group by 1, 2
  ), clasif as (
    select a.office_code, a.kind, a.es_ic, a.saldo, a.vence, (v_hoy - a.vence) as dias_venc,
           case when a.kind = 'AR' then ex.motivo end as motivo
    from adj a
    left join excl ex on ex.office_code = a.office_code and ex.numero = a.numero
    where abs(a.saldo) > 0.005
  ), reglas as (
    select c.office_code, c.kind, c.es_ic, c.saldo,
           case
             when c.kind = 'AR' and c.dias_venc <= 0 then c.vence + greatest(0, atr.dias + p.ar_extra_dias)
             when c.kind = 'AR' and c.dias_venc <= 30 then v_w1 + 7 * (p.ar130_desde - 1) + 3
             when c.kind = 'AR' then v_w1 + 7 * (p.ar3190_desde - 1) + 3
             when c.dias_venc <= 0 then c.vence + atr.dias
             when c.dias_venc <= 30 then v_w1 + 7 + 3
             else v_w1 + 14 + 3
           end as fecha0,
           case
             when c.dias_venc <= 0 then 1
             when c.kind = 'AR' and c.dias_venc <= 30 then p.ar130_n
             when c.kind = 'AR' then p.ar3190_n
             when c.dias_venc <= 30 then 4
             else 8
           end as n_sem,
           (case when c.kind = 'AR' and c.dias_venc > 30 then p.ar_pct_31_90 else 1.0 end)
             * (case when c.kind = 'AR' then 1 else -1 end) as factor
    from clasif c
    cross join params p
    join atrasos atr on atr.office_code = c.office_code and atr.kind = c.kind
    where c.motivo is null and c.dias_venc <= 90
  ), flujos_doc as (
    select r.office_code,
           case
             when r.es_ic and r.kind = 'AR' then 'cobro_ic'
             when r.es_ic then 'pago_ic'
             when r.kind = 'AR' then 'cobro_cartera'
             else 'pago_cartera'
           end as linea,
           r.fecha0 + 7 * k as fecha,
           r.saldo * r.factor / r.n_sem as monto
    from reglas r
    cross join lateral generate_series(0, r.n_sem - 1) k
  ), meses as (
    select (date_trunc('month', v_w1) + make_interval(months => g))::date as mes
    from generate_series(0, 3) g
  ), recur as (
    select o.code as office_code, r.concepto,
           case extract(isodow from f.fecha) when 6 then f.fecha - 1 when 7 then f.fecha - 2 else f.fecha end as fecha,
           r.monto_usd
    from finanzas_forecast_recurrente r
    join offices o on o.id = r.office_id
    cross join meses m
    cross join lateral (
      select m.mes + 14 as fecha where r.frecuencia = 'quincenal'
      union all
      select (m.mes + interval '1 month - 1 day')::date where r.frecuencia = 'quincenal'
      union all
      select least(m.mes + (coalesce(r.dia, 1) - 1), (m.mes + interval '1 month - 1 day')::date) where r.frecuencia = 'mensual'
    ) f
    where r.activo and o.code = any(v_offices)
    union all
    select o.code, r.concepto, r.ancla + 14 * k, r.monto_usd
    from finanzas_forecast_recurrente r
    join offices o on o.id = r.office_id
    cross join generate_series(0, 30) k
    where r.activo and r.frecuencia = 'bisemanal' and r.ancla is not null and o.code = any(v_offices)
  ), prog as (
    select finanzas_office_code_for_office(sp.office_id) as office_code,
           coalesce(sp.counterparty_name, sp.bill_number, 'Pago programado') as concepto,
           sp.scheduled_date as fecha,
           case sp.direction when 'inflow' then sp.amount_usd else -sp.amount_usd end as monto
    from scheduled_payment sp
    where sp.status = 'scheduled' and sp.scheduled_date >= v_w1
      and finanzas_office_code_for_office(sp.office_id) = any(v_offices)
  ), runrate as (
    select finanzas_office_code_for_company(t.company_id) as office_code,
           case t.transaction_type when 'IN' then 'AR' else 'AP' end as kind,
           (upper(t.billing_client_name) like '%GLOVAL%') as es_ic,
           sum((case when t.is_credit then -1 else 1 end) * magaya_amount_to_usd(t.company_id, t.total_amount, t.total_amount_usd)) / 8.0 as semanal
    from magaya_transactions t
    where p_operacion_futura
      and t.transaction_type in ('IN', 'BI')
      and t.created_on >= (v_w1 - 56) and t.created_on < v_w1
      and t.billing_client_name is not null
      and finanzas_office_code_for_company(t.company_id) = any(v_offices)
    group by 1, 2, 3
  ), plazo as (
    select finanzas_office_code_for_company(t.company_id) as office_code,
           case t.transaction_type when 'IN' then 'AR' else 'AP' end as kind,
           greatest(0, least(120, percentile_disc(0.5) within group (order by t.due_date::date - t.created_on::date))) as dias
    from magaya_transactions t
    where p_operacion_futura
      and t.transaction_type in ('IN', 'BI') and t.due_date is not null and t.created_on is not null
      and t.created_on > now() - interval '365 days'
      and finanzas_office_code_for_company(t.company_id) = any(v_offices)
    group by 1, 2
  ), futura as (
    select r.office_code,
           case
             when r.es_ic and r.kind = 'AR' then 'cobro_ic'
             when r.es_ic then 'pago_ic'
             when r.kind = 'AR' then 'cobro_futuro'
             else 'pago_futuro'
           end as linea,
           s.inicio + 2 + coalesce(pl.dias, 30)
             + case r.kind when 'AR' then greatest(0, atr.dias + p.ar_extra_dias) else atr.dias end as fecha,
           (case r.kind when 'AR' then r.semanal * (case when r.es_ic then 1.0 else p.futura_ar_factor end) else -r.semanal end)
             * (case when s.semana = 1 then (s.fin - v_hoy + 1) / 7.0 else 1 end) as monto
    from runrate r
    cross join params p
    cross join semanas s
    join atrasos atr on atr.office_code = r.office_code and atr.kind = r.kind
    left join plazo pl on pl.office_code = r.office_code and pl.kind = r.kind
  ), todos as (
    select fd.office_code, fd.linea, null::text as detalle, fd.fecha, fd.monto from flujos_doc fd
    union all
    select rc.office_code, 'pago_recurrente'::text, rc.concepto, rc.fecha, -rc.monto_usd from recur rc where rc.fecha >= v_w1
    union all
    select pg.office_code, 'pago_programado'::text, pg.concepto, pg.fecha, pg.monto from prog pg
    union all
    select fu.office_code, fu.linea, null::text, fu.fecha, fu.monto from futura fu
  ), en_semana as (
    select td.office_code, td.linea, td.detalle, greatest(1, (td.fecha - v_w1) / 7 + 1) as semana, td.monto
    from todos td
    where td.fecha <= v_w1 + 90 and td.monto <> 0
  ), info as (
    select c.office_code,
           case
             when c.motivo = 'anticipado' then 'info_anticipado'
             when c.motivo = 'por_zarpar' then 'info_por_zarpar'
             when c.kind = 'AR' then 'info_ar_mas_90'
             else 'info_ap_mas_90'
           end as linea,
           c.saldo
    from clasif c
    where not c.es_ic and (c.motivo is not null or c.dias_venc > 90)
  ), caja as (
    select finanzas_office_code_for_office(ba.office_id) as office_code,
           sum(ba.current_balance) as monto, max(ba.reconciled_through_date) as corte
    from bank_account ba
    where ba.active and finanzas_office_code_for_office(ba.office_id) = any(v_offices)
    group by 1
  )
  select es.office_code, es.semana::int, v_w1 + (es.semana - 1) * 7, v_w1 + (es.semana - 1) * 7 + 6,
         es.linea, es.detalle, round(sum(es.monto), 2)
  from en_semana es
  group by es.office_code, es.semana, es.linea, es.detalle
  union all
  select cj.office_code, 0, cj.corte, cj.corte, 'caja_inicial'::text, null::text, round(cj.monto, 2)
  from caja cj
  union all
  select i.office_code, 0, null::date, null::date, i.linea, null::text, round(sum(i.saldo), 2)
  from info i
  group by i.office_code, i.linea
  union all
  select atr.office_code, 0, null::date, null::date,
         case atr.kind when 'AR' then 'param_atraso_cobro' else 'param_atraso_pago' end, null::text, atr.dias::numeric
  from atrasos atr;
end $function$;

CREATE OR REPLACE FUNCTION public.finanzas_grant(p_email text, p_office text, p_can_grant boolean DEFAULT false)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare
  v_target users%rowtype;
  v_grantor uuid;
  v_office text;
begin
  if not app_finanzas_can_grant() then
    raise exception 'Solo un administrador de Finanzas puede otorgar accesos';
  end if;
  select * into v_target from users where lower(email) = lower(p_email) limit 1;
  if v_target.id is null then
    raise exception 'No existe usuario con email %', p_email;
  end if;
  v_office := finanzas_office_code(p_office);
  if v_office is null or v_office not in ('USA','ECU','PAN','PER','HOLDING','ALL') then
    raise exception 'Oficina inválida: % (usa USA, ECU, PAN, PER, HOLDING o ALL)', p_office;
  end if;
  select u.id into v_grantor from users u where u.auth_user_id = auth.uid();
  insert into finanzas_access (user_id, office_code, can_grant, granted_by)
  values (v_target.id, v_office, p_can_grant, v_grantor)
  on conflict (user_id, office_code)
  do update set can_grant = excluded.can_grant, granted_by = excluded.granted_by, granted_at = now();
  return jsonb_build_object('ok', true, 'email', v_target.email, 'office', v_office, 'can_grant', p_can_grant);
end $function$;

CREATE OR REPLACE FUNCTION public.finanzas_office_code(p text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$
  select case
    when p is null then null
    when upper(p) in ('USA','US','ESTADOS UNIDOS','MIAMI') then 'USA'
    when upper(p) in ('ECU','EC','ECUADOR','GUAYAQUIL') then 'ECU'
    when upper(p) in ('PAN','PA','PANAMA','PANAMÁ') then 'PAN'
    when upper(p) in ('PER','PE','PERU','PERÚ','LIMA') then 'PER'
    when upper(p) in ('HOLDING','HOL','GROUP') then 'HOLDING'
    else upper(p)
  end
$function$;

CREATE OR REPLACE FUNCTION public.finanzas_office_code_for_company(p uuid)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$
  select case p
    when 'aba24859-159c-424b-8ef3-d122fba41b7c'::uuid then 'USA'
    when 'd8b762a6-f66f-44de-bc44-2486ec1e2ae5'::uuid then 'ECU'
    when '20e7448c-4b80-443b-9903-6feaaf29cb1e'::uuid then 'PAN'
    when '9b807b51-5ee9-4a22-9e75-df90047ec12b'::uuid then 'PER'
    else null
  end
$function$;

CREATE OR REPLACE FUNCTION public.finanzas_office_code_for_office(p uuid)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$
  select case p
    when 'b70721f4-6f96-440c-9ff5-2ff98231d29a'::uuid then 'USA'
    when 'cc987069-ac9a-41f2-85f0-0337f6b99980'::uuid then 'ECU'
    when '94dc11de-9354-4f13-928f-4f21314cebdd'::uuid then 'PAN'
    when '7e15cec2-eeb3-4fa6-b8b4-4df5d912fa14'::uuid then 'PER'
    when '5359ebc4-90d9-4f96-b156-a669ef09f004'::uuid then 'HOLDING'
    else null
  end
$function$;

CREATE OR REPLACE FUNCTION public.finanzas_refresh_mv_arap()
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
begin
  refresh materialized view concurrently mv_entity_ar_ap;
end $function$;

CREATE OR REPLACE FUNCTION public.finanzas_refresh_mv_unified()
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
begin
  refresh materialized view concurrently v_magaya_invoices_unified;
end $function$;

CREATE OR REPLACE FUNCTION public.finanzas_revoke(p_email text, p_office text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare
  v_target users%rowtype;
  v_office text;
  v_borradas int;
begin
  if not app_finanzas_can_grant() then
    raise exception 'Solo un administrador de Finanzas puede revocar accesos';
  end if;
  select * into v_target from users where lower(email) = lower(p_email) limit 1;
  if v_target.id is null then
    raise exception 'No existe usuario con email %', p_email;
  end if;
  if exists (select 1 from finanzas_access where user_id = v_target.id and can_grant)
     and (select count(*) from finanzas_access where can_grant) <= 1 then
    raise exception 'No puedes eliminar al último administrador de Finanzas';
  end if;
  if p_office is null then
    delete from finanzas_access where user_id = v_target.id;
  else
    v_office := finanzas_office_code(p_office);
    delete from finanzas_access where user_id = v_target.id and office_code = v_office;
  end if;
  get diagnostics v_borradas = row_count;
  return jsonb_build_object('ok', true, 'email', v_target.email, 'filas_revocadas', v_borradas);
end $function$;

CREATE OR REPLACE FUNCTION public.finanzas_run_bank_matching(p_office_code text DEFAULT 'ECU'::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_office_id text;
  v_company_id uuid;
  v_refs int := 0; v_traspasos int := 0; v_categorias int := 0;
begin
  if coalesce(auth.role(), '') in ('authenticated', 'anon') then
    if not (p_office_code = any(app_finanzas_offices()) or 'ALL' = any(app_finanzas_offices())) then
      raise exception 'sin acceso a la oficina %', p_office_code;
    end if;
  end if;

  select o.id into v_office_id from offices o where o.code = p_office_code;
  select id into v_company_id from magaya_companies
   where code = case p_office_code when 'ECU' then 'EC' when 'PAN' then 'PA' when 'PER' then 'PE' when 'USA' then 'US' end;
  if v_office_id is null then raise exception 'oficina desconocida %', p_office_code; end if;

  -- 1) ENTRADAS con referencias de documentos (F/R/RC/guías) resueltas contra facturas IN
  with objetivo as (
    select bt.id, bt.amount, bt.description
    from bank_transaction bt join bank_account ba on ba.id = bt.bank_account_id
    where ba.office_id::text = v_office_id and bt.amount > 0
      and not exists (select 1 from finanzas_bank_match m where m.bank_transaction_id = bt.id)
  ), tokens as (
    select o.id, o.amount, tok
    from objetivo o, lateral unnest(
      array(select distinct 'RC:' || ltrim(n, '0')
            from regexp_matches(o.description, 'RC?\s?\.?\s?0*([0-9][0-9\- ]{4,40})', 'gi') m,
                 lateral unnest(string_to_array(regexp_replace(m[1], '\s', '', 'g'), '-')) n
            where length(ltrim(n, '0')) = 5)
      || array(select distinct 'F:' || ltrim(n, '0')
            from regexp_matches(o.description, '(^|[^A-Z])F\s?\.?\s?0*([0-9][0-9\- ]{4,40})', 'gi') m,
                 lateral unnest(string_to_array(regexp_replace(m[2], '\s', '', 'g'), '-')) n
            where length(ltrim(n, '0')) = 5)
      || array(select distinct 'DOC:' || m[1]
            from regexp_matches(o.description, '\y(G[A-Z]{3,6}\d{4,8}|\d{3}GA\d{5})\y', 'g') m)
    ) tok
  ), inv as (
    select case
             when transaction_number like 'RC %' then 'RC:' || ltrim(regexp_replace(transaction_number, '\D', '', 'g'), '0')
             when transaction_number ~ '^\d{3}-\d{3}-' then 'F:' || ltrim(right(regexp_replace(transaction_number, '\D', '', 'g'), 9), '0')
             else 'DOC:' || transaction_number
           end as key,
           magaya_guid, transaction_number, billing_client_name,
           magaya_amount_to_usd(company_id, total_amount, total_amount_usd) as monto
    from magaya_transactions
    where company_id = v_company_id and transaction_type = 'IN'
  ), hits as (
    select distinct t.id, t.amount, i.magaya_guid, i.transaction_number, i.billing_client_name, round(i.monto, 2) as monto
    from tokens t join inv i on i.key = t.tok
  ), agg as (
    select id, max(amount) as amount,
           jsonb_agg(jsonb_build_object('guid', magaya_guid, 'num', transaction_number, 'monto', monto, 'entidad', billing_client_name)) as docs,
           sum(monto) as suma_docs,
           max(billing_client_name) as entidad
    from hits group by id
  ), ins as (
    insert into finanzas_bank_match (bank_transaction_id, office_id, match_type, matched_docs, entity_name, category, confidence)
    select id, v_office_id, 'refs', docs, entidad, 'client_payment',
           case when abs(suma_docs - amount) <= greatest(1, amount * 0.01) then 0.97 else 0.85 end
    from agg
    returning 1
  ) select count(*) into v_refs from ins;

  -- 2) TRASPASOS entre cuentas propias (entradas y salidas)
  with ins as (
    insert into finanzas_bank_match (bank_transaction_id, office_id, match_type, entity_name, category, confidence)
    select bt.id, v_office_id, 'traspaso', 'TRASPASO ENTRE CUENTAS', 'other', 0.95
    from bank_transaction bt join bank_account ba on ba.id = bt.bank_account_id
    where ba.office_id::text = v_office_id
      and not exists (select 1 from finanzas_bank_match m where m.bank_transaction_id = bt.id)
      and bt.description ~* 'TRANSFERENCIA INTERBANCARIA|A BCO MANABI CTA'
    returning 1
  ) select count(*) into v_traspasos from ins;

  -- 3) CATEGORÍAS por patrón (salidas y entradas residuales); primera regla que aplique
  with restantes as (
    select bt.id, bt.amount, bt.description
    from bank_transaction bt join bank_account ba on ba.id = bt.bank_account_id
    where ba.office_id::text = v_office_id
      and not exists (select 1 from finanzas_bank_match m where m.bank_transaction_id = bt.id)
  ), clasif as (
    select id, amount, description,
      case
        when description ~* 'KITANZA' then 'intercompany_out'
        when description ~* 'GESTOMATIC PAGO' then 'other'
        when description ~* 'IESS|INSTITUTO ECUATORIANO|SUELDOS|QUINCENA' then 'payroll'
        when description ~* 'SERVICIO DE RENTAS|IMPUESTO|F\.103|MATRICULA G0' then 'tax'
        when description ~* 'SERVICIOS BANCARIOS|N/?D BANCARIA|COMISION|CERTIFICACION BANCARIA' then 'bank_fee'
        when description ~* 'VISA|TARJETA|DINERS' then 'loan_payment'
        when description ~* 'CNT EP|INTERAGUA|CNEL|MEGADATOS|AMAGUA' then 'utility'
        when description ~* 'CATACAOS|ARRENDAMIENTO|ALICUOTA|PARQUEO' then 'rent'
        when amount < 0 then 'vendor_payment'
        else 'uncategorized'
      end as cat
    from restantes
  ), ins as (
    insert into finanzas_bank_match (bank_transaction_id, office_id, match_type, entity_name, category, confidence)
    select id, v_office_id, 'categoria', nullif(trim(split_part(description, ' — ', 1)), ''), cat,
           case when cat = 'uncategorized' then 0.30 when cat = 'vendor_payment' then 0.50 else 0.90 end
    from clasif
    returning 1
  ) select count(*) into v_categorias from ins;

  return jsonb_build_object('office', p_office_code, 'refs', v_refs, 'traspasos', v_traspasos, 'categorias', v_categorias, 'at', now());
end $function$;

CREATE OR REPLACE FUNCTION public.finanzas_sync_cash_movement()
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare
  cfg record;
  v_cursor timestamptz;
  v_max timestamptz;
  v_ins int; v_upd int; v_total_ins int := 0; v_total_upd int := 0;
  c_tenant constant uuid := 'a4e3e84c-7fca-4ce3-8889-1f31d8d1366f';
begin
  for cfg in
    select * from (values
      ('gloval-usa',     'aba24859-159c-424b-8ef3-d122fba41b7c'::uuid, 'b70721f4-6f96-440c-9ff5-2ff98231d29a'::uuid, '2f9c5d40-d1b7-43fe-8faf-0c574022f944'::uuid, true,  'USD'),
      ('gloval-ecuador', 'd8b762a6-f66f-44de-bc44-2486ec1e2ae5'::uuid, 'cc987069-ac9a-41f2-85f0-0337f6b99980'::uuid, 'af0c3348-2f37-4291-ab9d-b782aa780a30'::uuid, false, 'USD'),
      ('gloval-panama',  '20e7448c-4b80-443b-9903-6feaaf29cb1e'::uuid, '94dc11de-9354-4f13-928f-4f21314cebdd'::uuid, '7ea020be-ba6b-4f60-964f-f8e5f5191c7b'::uuid, false, 'USD'),
      ('gloval-peru',    '9b807b51-5ee9-4a22-9e75-df90047ec12b'::uuid, '7e15cec2-eeb3-4fa6-b8b4-4df5d912fa14'::uuid, '0acbc85d-33d1-4571-a32f-8c6aa0766c71'::uuid, false, 'PEN')
    ) as t(scope, company_id, office_id, default_bank, parse_payroll, home_currency)
  loop
    v_cursor := coalesce((select last_cursor from finanzas_sync_state where scope = cfg.scope), '2026-05-01'::timestamptz);
    v_max := v_cursor;

    -- Invoices (IN) y Bills (BI) nuevos. FX canónico (regla validada al centavo).
    insert into cash_movement (tenant_id, office_id, bank_account_id, direction, category, source_type,
      amount, currency, amount_in_usd, expected_date, actual_date, status, counterparty_name,
      external_reference, external_guid, notes)
    select c_tenant, cfg.office_id,
      case when lower(mt.status) in ('paid','pagada','pagado') then null else cfg.default_bank end,
      case when mt.transaction_type = 'IN' then 'inflow' else 'outflow' end,
      case when mt.transaction_type = 'IN' then 'client_payment' else 'vendor_payment' end,
      case when mt.transaction_type = 'IN' then 'invoice' else 'bill' end,
      mt.total_amount,
      case when cfg.home_currency = 'PEN' and mt.total_amount_usd is null then 'PEN'
           else coalesce(mt.currency_code, 'USD') end,
      round(magaya_amount_to_usd(mt.company_id, mt.total_amount, mt.total_amount_usd), 2),
      coalesce(mt.due_date, mt.created_on::date),
      case when lower(mt.status) in ('paid','pagada','pagado') then mt.created_on::date end,
      case when lower(mt.status) in ('paid','pagada','pagado') then 'executed' else 'committed' end,
      mt.billing_client_name, mt.transaction_number, mt.magaya_guid, 'Synced from Magaya (GES)'
    from magaya_transactions mt
    where mt.company_id = cfg.company_id and mt.transaction_type in ('BI','IN')
      and mt.total_amount > 0 and mt.billing_client_name is not null
      and mt.created_on > v_cursor
    on conflict (tenant_id, external_guid) do nothing;
    get diagnostics v_ins = row_count;
    v_total_ins := v_total_ins + v_ins;

    select greatest(v_max, coalesce(max(created_on), v_max)) into v_max
    from magaya_transactions where company_id = cfg.company_id and transaction_type in ('BI','IN') and created_on > v_cursor;

    -- Payroll (JE) solo USA: Salaries + Payroll Tax del XML
    if cfg.parse_payroll then
      insert into cash_movement (tenant_id, office_id, bank_account_id, direction, category, source_type,
        amount, currency, amount_in_usd, expected_date, actual_date, status, counterparty_name,
        external_reference, external_guid, notes)
      select c_tenant, cfg.office_id, cfg.default_bank, 'outflow', 'payroll', 'recurring',
        amt, 'USD', amt, je.created_on::date, je.created_on::date, 'executed', 'Payroll (quincenal)',
        je.transaction_number, 'magaya-je:' || je.magaya_guid, substring(je.raw_xml from '<Notes>([^<]+)</Notes>')
      from (
        select mt.*,
          coalesce(substring(mt.raw_xml from '<Account><Type>Expense</Type><Name>Salaries Expense</Name>.*?<DebitAmount[^>]*>([0-9.]+)</DebitAmount>')::numeric, 0)
          + coalesce(substring(mt.raw_xml from '<Account><Type>Expense</Type><Name>Payroll Tax Expense</Name>.*?<DebitAmount[^>]*>([0-9.]+)</DebitAmount>')::numeric, 0) as amt
        from magaya_transactions mt
        where mt.company_id = cfg.company_id and mt.transaction_type = 'JE'
          and mt.raw_xml ilike '%payroll%' and mt.created_on > v_cursor
      ) je
      where je.amt > 0
      on conflict (tenant_id, external_guid) do nothing;
      get diagnostics v_ins = row_count;
      v_total_ins := v_total_ins + v_ins;
      select greatest(v_max, coalesce(max(created_on), v_max)) into v_max
      from magaya_transactions where company_id = cfg.company_id and transaction_type = 'JE' and created_on > v_cursor;
    end if;

    -- Marcar pagados (raw status de Magaya)
    update cash_movement cm
    set status = 'executed', actual_date = coalesce(cm.actual_date, mt.created_on::date),
        bank_account_id = null, updated_at = now()
    from magaya_transactions mt
    where mt.magaya_guid = cm.external_guid and cm.office_id = cfg.office_id
      and cm.status = 'committed' and lower(mt.status) in ('paid','pagada','pagado');
    get diagnostics v_upd = row_count;
    v_total_upd := v_total_upd + v_upd;

    update finanzas_sync_state
    set last_cursor = v_max, last_run_at = now(), rows_last_run = v_total_ins
    where scope = cfg.scope;
  end loop;

  return jsonb_build_object('insertados', v_total_ins, 'marcados_pagados', v_total_upd, 'at', now());
end $function$;

CREATE OR REPLACE FUNCTION public.first_significant_word(cname text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$
  select (
    select w from unnest(
      regexp_split_to_array(
        upper(regexp_replace(coalesce(cname, ''),
          '\s+(S\.?A\.?C?|LLC|INC|CIA|LTDA?|SAC|S\.?A\.?S?|EIRL|CORP|GROUP|LTD|CO\.?|CO\s|FINANCIAL\s+SERVICES?|SERVICES?|SHIPPING)\.?\s*.*$|^GLOVAL\s+', '', 'i')),
        '\s+'
      )
    ) as w(w)
    where length(w) >= 4 and w not in ('THE','AND','FOR','LOS','LAS','SAN','SUR','MAR','DEL','POR')
    limit 1
  )
$function$;

CREATE OR REPLACE FUNCTION public.fx_latest(p_currency text DEFAULT 'EUR'::text)
 RETURNS TABLE(currency text, rate_sell numeric, rate_buy numeric, quoted_on date, stale_days integer)
 LANGUAGE sql
 STABLE
AS $function$
  select f.currency,
         case when f.quote_style = 'UNITS_PER_USD' and coalesce(f.rate_sell,0) > 0
              then round(1.0 / f.rate_sell, 6) else f.rate_sell end as rate_sell,
         case when f.quote_style = 'UNITS_PER_USD' and coalesce(f.rate_buy,0) > 0
              then round(1.0 / f.rate_buy, 6) else f.rate_buy end as rate_buy,
         f.quoted_on,
         (current_date - f.quoted_on)::int as stale_days
  from public.fx_rates f
  where f.currency = upper(p_currency)
    and f.source = 'BANCO_PACIFICO'
  order by f.quoted_on desc,
           case f.instrument
             when 'Transferencia'  then 1
             when 'Transferencias' then 2
             when 'Cheques'        then 3
             when 'General'        then 4
             else 5
           end
  limit 1;
$function$;

CREATE OR REPLACE FUNCTION public.generate_pba_reminders()
 RETURNS integer
 LANGUAGE plpgsql
 SET search_path TO 'public', 'pg_catalog'
AS $function$
declare v_count int;
begin
  with candidates as (
    select p.id, p.amount, p.guia_ref, p.bl_ref, p.client_id, p.shipment_id,
           c.company_name as client_name, c.assigned_to as exec_id
    from public.pba_payments p
    left join public.clients c on c.id = p.client_id
    where p.status = 'PENDING'
      and (p.last_reminder_at is null or p.last_reminder_at < now() - interval '15 days')
      and c.assigned_to is not null
  ),
  ins as (
    insert into public.reminders (user_id, source_type, source_id, shipment_id, title, body, metadata)
    select exec_id, 'pba_payment', id, shipment_id,
      '💵 PBA pendiente de cobro',
      'USD ' || amount::text || coalesce(' · ' || client_name, '') || coalesce(' · ' || guia_ref, ''),
      jsonb_build_object('amount', amount, 'guia', guia_ref, 'client', client_name)
    from candidates
    returning id
  )
  select count(*) into v_count from ins;
  return v_count;
end $function$;

CREATE OR REPLACE FUNCTION public.generate_task_reminders()
 RETURNS integer
 LANGUAGE plpgsql
 SET search_path TO 'public', 'pg_catalog'
AS $function$
declare v_count int;
begin
  with candidates as (
    select ai.id, ai.title, ai.assigned_to, ai.shipment_id, ai.due_date, ai.priority,
           c.company_name as client_name, s.shipment_code, s.mbl
    from public.shipment_action_items ai
    left join public.shipments s on s.id = ai.shipment_id
    left join public.clients c on c.id = s.client_id
    where ai.status = 'OPEN'
      and ai.assigned_to is not null
      and (ai.priority = 'CRITICAL'
           or (ai.due_date is not null and ai.due_date <= current_date))
      -- No spamear: no crear si ya hay reminder pending o sent en últimas 6h
      and not exists (
        select 1 from public.reminders r
        where r.source_type = 'action_item' and r.source_id = ai.id
          and r.created_at > now() - interval '6 hours'
      )
  ),
  ins as (
    insert into public.reminders (user_id, source_type, source_id, shipment_id, title, body, metadata)
    select assigned_to, 'action_item', id, shipment_id,
      case
        when priority = 'CRITICAL' and due_date is not null and due_date < current_date then '🔴 Tarea crítica VENCIDA'
        when priority = 'CRITICAL' then '⚠️ Tarea crítica'
        when due_date < current_date then '⏰ Tarea vencida'
        else 'Tarea pendiente'
      end,
      title || coalesce(' · ' || client_name, '') || coalesce(' · ' || shipment_code, ''),
      jsonb_build_object('client', client_name, 'shipment_code', shipment_code, 'mbl', mbl,
                         'priority', priority, 'due_date', due_date)
    from candidates
    returning id
  )
  select count(*) into v_count from ins;
  return v_count;
end $function$;

CREATE OR REPLACE FUNCTION public.get_current_user_id()
 RETURNS uuid
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
SELECT id FROM users WHERE auth_user_id = auth.uid() LIMIT 1;
$function$;

CREATE OR REPLACE FUNCTION public.get_current_user_office()
 RETURNS text
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
SELECT office FROM users WHERE auth_user_id = auth.uid() LIMIT 1;
$function$;

CREATE OR REPLACE FUNCTION public.get_current_user_role()
 RETURNS text
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
SELECT role FROM users WHERE auth_user_id = auth.uid() LIMIT 1;
$function$;

CREATE OR REPLACE FUNCTION public.get_effective_permissions(target_user_id uuid)
 RETURNS TABLE(page text, can_view boolean, can_create boolean, can_edit boolean, can_delete boolean, is_override boolean)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
resolved_role_id UUID;
BEGIN
-- Resolve role_id: prefer explicit role_id, fall back to matching by role name
SELECT
COALESCE(u.role_id, r.id) INTO resolved_role_id
FROM users u
LEFT JOIN roles r ON r.name = u.role
WHERE u.id = target_user_id;

-- Return effective permissions (user overrides take precedence over role defaults)
RETURN QUERY
SELECT
COALESCE(rp.page, upo.page) AS page,
COALESCE(upo.can_view,   rp.can_view,   false) AS can_view,
COALESCE(upo.can_create, rp.can_create, false) AS can_create,
COALESCE(upo.can_edit,   rp.can_edit,   false) AS can_edit,
COALESCE(upo.can_delete, rp.can_delete, false) AS can_delete,
(upo.id IS NOT NULL) AS is_override
FROM role_permissions rp
FULL OUTER JOIN user_permission_overrides upo
ON upo.page = rp.page AND upo.user_id = target_user_id
WHERE rp.role_id = resolved_role_id
OR upo.user_id = target_user_id;
END;
$function$;

CREATE OR REPLACE FUNCTION public.get_incomplete_pallets(p_client_id uuid)
 RETURNS TABLE(product_name text, standard_cartons integer, wr_number text, movement_date date, pieces integer, actual_cartons integer)
 LANGUAGE plpgsql
 SET search_path TO 'public', 'pg_catalog'
AS $function$
BEGIN
  RETURN QUERY
  SELECT COALESCE(p.short_name, 'Sin mapear'), p.standard_cartons_per_pallet,
    wi.wr_number, COALESCE(wr.created_on, m.date),
    wi.pieces::integer,
    (regexp_match(wi.item_description, '\(\s*(\d+)\s*Box\s*\)', 'i'))[1]::integer
  FROM magaya_wr_items wi
  JOIN magaya_warehouse_receipts wr ON wr.id = wi.wr_id
  JOIN wh_report_clients c ON c.id = p_client_id AND wr.consignee ILIKE c.consignee_name
  LEFT JOIN LATERAL (SELECT pm.product_id FROM wh_report_product_mappings pm
    WHERE pm.client_id = p_client_id AND pm.active = true AND wi.item_description ILIKE pm.magaya_pattern
    ORDER BY pm.priority DESC LIMIT 1) mapping ON true
  LEFT JOIN wh_report_products p ON p.id = mapping.product_id
  LEFT JOIN wh_report_movements m ON m.magaya_wr_id = wr.id
  WHERE p.id IS NOT NULL AND p.standard_cartons_per_pallet IS NOT NULL
    AND (regexp_match(wi.item_description, '\(\s*(\d+)\s*Box\s*\)', 'i'))[1]::integer < p.standard_cartons_per_pallet
    AND COALESCE(wr.created_on, '2020-01-01') >= CURRENT_DATE - interval '1 year'
  ORDER BY p.display_order, wr.created_on DESC;
END; $function$;

CREATE OR REPLACE FUNCTION public.get_inventory_balance(p_client_id uuid)
 RETURNS TABLE(product_id uuid, product_name text, short_name text, display_order integer, total_in bigint, total_out bigint, balance bigint)
 LANGUAGE plpgsql
 SET search_path TO 'public', 'pg_catalog'
AS $function$
BEGIN
  RETURN QUERY
  SELECT p.id, p.name, p.short_name, p.display_order,
    COALESCE(SUM(CASE WHEN mi.quantity > 0 THEN mi.quantity ELSE 0 END), 0)::bigint as total_in,
    COALESCE(SUM(CASE WHEN mi.quantity < 0 THEN ABS(mi.quantity) ELSE 0 END), 0)::bigint as total_out,
    COALESCE(SUM(mi.quantity), 0)::bigint as balance
  FROM wh_report_products p
  LEFT JOIN wh_report_movement_items mi ON mi.product_id = p.id
  WHERE p.client_id = p_client_id
  GROUP BY p.id, p.name, p.short_name, p.display_order
  HAVING COALESCE(SUM(mi.quantity), 0) != 0
  ORDER BY p.display_order;
END;
$function$;

CREATE OR REPLACE FUNCTION public.get_loose_pallets_summary(p_client_id uuid)
 RETURNS TABLE(total_containers bigint, total_packing_pallets bigint, total_packing_loose bigint, total_physical_pallets bigint, total_physical_loose bigint, total_extra_pallets bigint, containers_with_extra bigint)
 LANGUAGE plpgsql
 SET search_path TO 'public', 'pg_catalog'
AS $function$
BEGIN
  RETURN QUERY
  SELECT 
    COUNT(*)::bigint,
    COALESCE(SUM(m.packing_pallets), 0)::bigint,
    COALESCE(SUM(m.packing_loose), 0)::bigint,
    COALESCE(SUM(m.physical_pallets), 0)::bigint,
    COALESCE(SUM(m.physical_loose), 0)::bigint,
    COALESCE(SUM(m.extra_pallets), 0)::bigint,
    COUNT(CASE WHEN m.extra_pallets > 0 THEN 1 END)::bigint
  FROM wh_report_movements m
  WHERE m.client_id = p_client_id
    AND m.movement_type = 'IN'
    AND (m.packing_loose > 0 OR m.physical_loose > 0);
END;
$function$;

CREATE OR REPLACE FUNCTION public.get_max_numeric(p_table text, p_col text)
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_catalog'
AS $function$
DECLARE
  result integer;
BEGIN
  EXECUTE format(
    'SELECT MAX(%I::int) FROM %I WHERE %I ~ %L',
    p_col, p_table, p_col, '^\d+$'
  ) INTO result;
  RETURN COALESCE(result, 0);
END;
$function$;

CREATE OR REPLACE FUNCTION public.get_movements_with_products(p_client_id uuid, p_limit integer DEFAULT 50, p_offset integer DEFAULT 0)
 RETURNS TABLE(movement_id uuid, date date, movement_type text, reference_number text, container_number text, total_pallets integer, packing_pallets integer, packing_loose integer, packing_total integer, physical_pallets integer, physical_loose integer, physical_total integer, extra_pallets integer, source text, created_at timestamp with time zone, products jsonb)
 LANGUAGE plpgsql
 SET search_path TO 'public', 'pg_catalog'
AS $function$
BEGIN
  RETURN QUERY
  SELECT m.id, m.date, m.movement_type, m.reference_number, m.container_number, m.total_pallets,
    m.packing_pallets, m.packing_loose, m.packing_total,
    m.physical_pallets, m.physical_loose, m.physical_total,
    m.extra_pallets, m.source,
    m.created_at,
    COALESCE((SELECT jsonb_agg(jsonb_build_object(
      'product_name', p.short_name, 'quantity', mi.quantity,
      'cartons_per_pallet', mi.cartons_per_pallet, 'is_incomplete', mi.is_incomplete, 'notes', mi.notes
    ) ORDER BY p.display_order)
    FROM wh_report_movement_items mi JOIN wh_report_products p ON p.id = mi.product_id
    WHERE mi.movement_id = m.id), '[]'::jsonb) as products
  FROM wh_report_movements m
  WHERE m.client_id = p_client_id
  ORDER BY m.date DESC, m.created_at DESC
  LIMIT p_limit OFFSET p_offset;
END;
$function$;

CREATE OR REPLACE FUNCTION public.get_shipper_stats(start_date date DEFAULT '2026-01-01'::date, end_date date DEFAULT CURRENT_DATE, group_by text DEFAULT 'shipper'::text)
 RETURNS TABLE(name text, total_wrs bigint, total_pieces bigint, total_weight numeric, total_cbm numeric, avg_lbs_per_wr numeric, avg_pcs_per_wr numeric, first_wr date, last_wr date, active_weeks bigint)
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public', 'pg_catalog'
AS $function$
BEGIN
  IF group_by = 'consignee' THEN
    RETURN QUERY
    SELECT
      consignee                                       AS name,
      COUNT(*)                                        AS total_wrs,
      COALESCE(SUM(pieces), 0)::bigint                AS total_pieces,
      COALESCE(SUM(weight::numeric), 0)               AS total_weight,
      COALESCE(SUM(
        CASE WHEN volume_cbm::numeric <= 150 THEN volume_cbm::numeric ELSE NULL END
      ), 0)                                           AS total_cbm,
      ROUND(COALESCE(SUM(weight::numeric), 0) / NULLIF(COUNT(*), 0), 1) AS avg_lbs_per_wr,
      ROUND(COALESCE(SUM(pieces), 0)::numeric / NULLIF(COUNT(*), 0), 1) AS avg_pcs_per_wr,
      MIN(created_on::date)                           AS first_wr,
      MAX(created_on::date)                           AS last_wr,
      COUNT(DISTINCT DATE_TRUNC('week', created_on::date)) AS active_weeks
    FROM magaya_warehouse_receipts
    WHERE created_on::date BETWEEN start_date AND end_date
      AND consignee IS NOT NULL AND consignee != ''
    GROUP BY consignee
    ORDER BY total_wrs DESC
    LIMIT 100;
  ELSE
    RETURN QUERY
    SELECT
      shipper                                         AS name,
      COUNT(*)                                        AS total_wrs,
      COALESCE(SUM(pieces), 0)::bigint                AS total_pieces,
      COALESCE(SUM(weight::numeric), 0)               AS total_weight,
      COALESCE(SUM(
        CASE WHEN volume_cbm::numeric <= 150 THEN volume_cbm::numeric ELSE NULL END
      ), 0)                                           AS total_cbm,
      ROUND(COALESCE(SUM(weight::numeric), 0) / NULLIF(COUNT(*), 0), 1) AS avg_lbs_per_wr,
      ROUND(COALESCE(SUM(pieces), 0)::numeric / NULLIF(COUNT(*), 0), 1) AS avg_pcs_per_wr,
      MIN(created_on::date)                           AS first_wr,
      MAX(created_on::date)                           AS last_wr,
      COUNT(DISTINCT DATE_TRUNC('week', created_on::date)) AS active_weeks
    FROM magaya_warehouse_receipts
    WHERE created_on::date BETWEEN start_date AND end_date
      AND shipper IS NOT NULL AND shipper != ''
    GROUP BY shipper
    ORDER BY total_wrs DESC
    LIMIT 100;
  END IF;
END;
$function$;

CREATE OR REPLACE FUNCTION public.get_user_id_from_auth()
 RETURNS uuid
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
SELECT id FROM users WHERE auth_user_id = auth.uid() LIMIT 1;
$function$;

CREATE OR REPLACE FUNCTION public.get_user_role()
 RETURNS text
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
SELECT role
FROM public.users
WHERE auth_user_id = auth.uid()
LIMIT 1;
$function$;

CREATE OR REPLACE FUNCTION public.get_weekly_container_stats(p_year integer)
 RETURNS TABLE(week_start date, iso_week integer, container_type text, destination text, destination_agent text, shipping_line text, status text, containers bigint)
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
SELECT
date_trunc('week', load_unload_datetime::date)::date  AS week_start,
EXTRACT(week FROM load_unload_datetime::date)::int    AS iso_week,
container_type,
destination,
destination_agent,
shipping_line,
status,
COUNT(*)                                              AS containers
FROM monday_containers
WHERE year = p_year
AND status IN ('LOADED', 'SAILED', 'IN GATED')
AND load_unload_datetime IS NOT NULL
GROUP BY 1, 2, 3, 4, 5, 6, 7
ORDER BY 1;
$function$;

CREATE OR REPLACE FUNCTION public.get_weekly_cr_stats(start_date date, end_date date)
 RETURNS TABLE(week_start date, iso_year integer, iso_week integer, dow integer, crs bigint, pieces bigint, weight_lbs numeric, is_parcel boolean)
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
SELECT
date_trunc('week', created_on::date)::date          AS week_start,
EXTRACT(isoyear FROM created_on::date)::int         AS iso_year,
EXTRACT(week    FROM created_on::date)::int         AS iso_week,
EXTRACT(dow     FROM created_on::date)::int         AS dow,
COUNT(*)                                            AS crs,
COALESCE(SUM(pieces), 0)                            AS pieces,
COALESCE(SUM(weight), 0)                            AS weight_lbs,
CASE
WHEN COALESCE(pieces, 0) = 0 THEN false
WHEN (COALESCE(weight, 0) / NULLIF(pieces, 0)) < 150 THEN true
ELSE false
END                                                 AS is_parcel
FROM magaya_cargo_releases
WHERE created_on >= start_date
AND created_on <= end_date
GROUP BY 1, 2, 3, 4,
CASE
WHEN COALESCE(pieces, 0) = 0 THEN false
WHEN (COALESCE(weight, 0) / NULLIF(pieces, 0)) < 150 THEN true
ELSE false
END
ORDER BY 1, 4;
$function$;

CREATE OR REPLACE FUNCTION public.get_weekly_wr_stats(start_date date DEFAULT '2026-01-01'::date, end_date date DEFAULT CURRENT_DATE)
 RETURNS TABLE(week_start date, iso_year integer, iso_week integer, dow integer, wrs bigint, pieces bigint, weight_lbs numeric, volume_cbm numeric)
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public', 'pg_catalog'
AS $function$
  SELECT
    DATE_TRUNC('week', created_on::date)::date  AS week_start,
    EXTRACT(ISOYEAR FROM created_on::date)::int AS iso_year,
    EXTRACT(WEEK    FROM created_on::date)::int AS iso_week,
    EXTRACT(DOW     FROM created_on::date)::int AS dow,
    COUNT(*)                                    AS wrs,
    COALESCE(SUM(pieces), 0)::bigint            AS pieces,
    COALESCE(SUM(weight::numeric), 0)           AS weight_lbs,
    -- Cap CBM per WR at 150 m³ to exclude corrupt Magaya conversion values
    COALESCE(SUM(
      CASE WHEN volume_cbm::numeric <= 150 THEN volume_cbm::numeric ELSE NULL END
    ), 0)                                       AS volume_cbm
  FROM magaya_warehouse_receipts
  WHERE created_on::date BETWEEN start_date AND end_date
  GROUP BY week_start, iso_year, iso_week, dow
  ORDER BY week_start DESC, dow;
$function$;

CREATE OR REPLACE FUNCTION public.get_wh_sync_status()
 RETURNS TABLE(client_name text, total_wr_items bigint, total_cr_items bigint, auto_movements bigint, manual_movements bigint, unmapped_log_entries bigint)
 LANGUAGE plpgsql
 SET search_path TO 'public', 'pg_catalog'
AS $function$
BEGIN
  RETURN QUERY
  SELECT 
    c.name,
    (SELECT COUNT(*) FROM magaya_wr_items wi 
     JOIN magaya_warehouse_receipts wr ON wr.id = wi.wr_id 
     WHERE wr.consignee ILIKE c.consignee_name),
    (SELECT COUNT(*) FROM magaya_cr_items ci 
     JOIN magaya_cargo_releases cr ON cr.id = ci.cr_id 
     JOIN magaya_warehouse_receipts wr ON wr.wr_number = SPLIT_PART(cr.tracking_number, '-', 2)
     WHERE wr.consignee ILIKE c.consignee_name),
    (SELECT COUNT(*) FROM wh_report_movements m WHERE m.client_id = c.id AND m.source = 'magaya_auto'),
    (SELECT COUNT(*) FROM wh_report_movements m WHERE m.client_id = c.id AND m.source != 'magaya_auto'),
    (SELECT COUNT(*) FROM wh_report_sync_log sl WHERE sl.client_id = c.id AND sl.status = 'unmapped')
  FROM wh_report_clients c
  WHERE c.active = true
  ORDER BY c.name;
END;
$function$;

CREATE OR REPLACE FUNCTION public.gloval_ai_sql(p_sql text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare
  v jsonb;
  q text := regexp_replace(coalesce(p_sql, ''), ';\s*$', '');
begin
  if q !~* '^\s*(select|with)\M' then
    raise exception 'Gloval AI solo puede LEER (la consulta debe empezar con SELECT o WITH)';
  end if;
  if q ~* '\m(insert|update|delete|drop|alter|create|grant|revoke|truncate|copy|vacuum|analyze|call|do|set|reset|listen|notify|refresh|comment|security|import)\M' then
    raise exception 'Gloval AI solo puede LEER (verbo de escritura detectado)';
  end if;
  if q like '%;%' then
    raise exception 'una sola consulta a la vez';
  end if;

  perform set_config('transaction_read_only', 'on', true);
  perform set_config('statement_timeout', '8000', true);

  execute 'select coalesce(jsonb_agg(t), ''[]''::jsonb) from (select * from (' || q || ') consulta limit 200) t'
  into v;
  return v;
end;
$function$;

CREATE OR REPLACE FUNCTION public.has_delegation_to(target_owner_user_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
  SELECT target_owner_user_id IS NOT NULL AND EXISTS (
    SELECT 1
    FROM public.user_delegations d
    JOIN public.users me ON me.id = d.viewer_user_id
    WHERE me.auth_user_id = auth.uid()
      AND d.owner_user_id = target_owner_user_id
  );
$function$;

CREATE OR REPLACE FUNCTION public.inhouse_can_touch_client(p_client uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select exists (
    select 1 from users u
    where u.auth_user_id = auth.uid()
      and u.status = 'Active'
      and (
        u.role in ('Admin','VP','Manager')
        or exists (
          select 1 from clients c
          where c.id = p_client
            and c.deleted_at is null
            and c.customer_service_id = u.id
        )
      )
  );
$function$;

CREATE OR REPLACE FUNCTION public.inhouse_emitir(p_despacho uuid, p_tipo text, p_data jsonb, p_docs jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_despacho record;
  v_perfil record;
  v_user uuid;
  v_errores text[] := '{}';
  v_cont text;
  v_f jsonb;
  v_nro text;
  v_suma numeric;
  v_fob numeric; v_flete numeric; v_seguro numeric; v_cif_pdf numeric;
  v_sin_precio text;
  v_hash_fuente text := '';
  v_doc jsonb;
  v_ids jsonb := '[]'::jsonb;
  v_id uuid;
  v_tipos_ok text[];
  v_tp text;
  v_url text;
begin
  select u.id into v_user from users u where u.auth_user_id = auth.uid() and u.status = 'Active';
  select * into v_despacho from inhouse_despachos where id = p_despacho;
  if v_despacho.id is null or not inhouse_can_touch_client(v_despacho.client_id) then
    return jsonb_build_object('ok', false, 'errores', jsonb_build_array('sin acceso a este despacho'));
  end if;
  if p_tipo not in ('lista','factura') then
    return jsonb_build_object('ok', false, 'errores', jsonb_build_array('tipo inválido'));
  end if;
  select * into v_perfil from inhouse_profiles where client_id = v_despacho.client_id;

  v_cont := upper(regexp_replace(coalesce(p_data->>'contenedor',''), '[^A-Za-z0-9]', '', 'g'));
  if v_cont !~ '^[A-Z]{4}[0-9]{7}$' then
    v_errores := v_errores || ('Contenedor "' || coalesce(nullif(v_cont,''),'(vacío)') || '" no cumple ISO 6346 (4 letras + 7 dígitos)');
  end if;

  if p_tipo = 'factura' then
    v_f := coalesce(p_data->'factura', '{}'::jsonb);
    v_nro := trim(coalesce(v_f->>'nro',''));
    if v_nro !~ coalesce(v_perfil.formato_nro, '^\d{3}-\d{3}-\d{9}$') then
      v_errores := v_errores || ('No. de documento tributario "' || coalesce(nullif(v_nro,''),'(vacío)') || '" no cumple el formato (' || coalesce(v_perfil.formato_tributario,'—') || ')');
    end if;
    if coalesce(trim(v_f->>'fecha'),'') = '' then
      v_errores := v_errores || 'Falta la fecha de emisión del documento tributario';
    end if;
    if coalesce(trim(v_f->>'incoterm'),'') !~* '^(EXW|FCA|FAS|FOB|CFR|CIF|CPT|CIP|DAP|DPU|DDP)\y' then
      v_errores := v_errores || 'Falta el término de negociación (incoterm) o no es válido';
    end if;
    if coalesce(trim(v_f->>'rut'),'') = '' then
      v_errores := v_errores || 'Falta el ID fiscal del cliente/consignatario';
    end if;
    select string_agg(it->>'codigo', ', ') into v_sin_precio
      from jsonb_array_elements(coalesce(p_data->'items','[]'::jsonb)) it
      where coalesce((it->>'precio')::numeric, 0) <= 0;
    if v_sin_precio is not null then
      v_errores := v_errores || ('Ítems sin precio: ' || v_sin_precio);
    end if;
    select coalesce(sum(coalesce((it->>'cajas')::numeric,0) * coalesce((it->>'precio')::numeric,0)),0)
      into v_suma from jsonb_array_elements(coalesce(p_data->'items','[]'::jsonb)) it;
    v_fob := coalesce((v_f->>'fob')::numeric, 0);
    v_flete := coalesce((v_f->>'flete')::numeric, 0);
    v_seguro := coalesce((v_f->>'seguro')::numeric, 0);
    if not (v_fob > 0) then
      v_errores := v_errores || 'Falta totalizar: ingresar el FOB (y flete/seguro si el incoterm los incluye)';
    elsif abs(v_suma - (v_fob + v_flete + v_seguro)) >= 0.02 then
      v_errores := v_errores || format('NO está totalizada: ítems suman %s pero FOB+Flete+Seguro = %s',
        to_char(v_suma,'FM999,999,990.00'), to_char(v_fob+v_flete+v_seguro,'FM999,999,990.00'));
    end if;
    v_cif_pdf := (v_f->>'cifPdf')::numeric;
    if v_cif_pdf is not null and v_cif_pdf > 0 and abs(v_suma - v_cif_pdf) >= 0.02 then
      v_errores := v_errores || format('No cuadra contra el CIF del documento tributario: ítems %s vs PDF %s',
        to_char(v_suma,'FM999,999,990.00'), to_char(v_cif_pdf,'FM999,999,990.00'));
    end if;
  end if;

  if array_length(v_errores, 1) > 0 then
    return jsonb_build_object('ok', false, 'errores', to_jsonb(v_errores));
  end if;

  select sha256 into v_hash_fuente from inhouse_documentos
    where despacho_id = p_despacho and tipo = 'fuente_factura'
    order by created_at desc limit 1;
  v_hash_fuente := coalesce(v_hash_fuente, '');
  v_nro := coalesce(trim(coalesce(p_data->'factura'->>'nro','')), '');

  v_tipos_ok := array[p_tipo||'_html', p_tipo||'_xlsx', p_tipo||'_snapshot', p_tipo||'_pdf'];
  for v_doc in select * from jsonb_array_elements(coalesce(p_docs, '[]'::jsonb)) loop
    v_tp := v_doc->>'tipo';
    v_url := v_doc->>'file_url';
    if v_tp is null or not (v_tp = any(v_tipos_ok)) then
      return jsonb_build_object('ok', false, 'errores',
        jsonb_build_array('documento con tipo no permitido para la emisión: ' || coalesce(v_tp,'(nulo)')));
    end if;
    if v_url is null or v_url !~ ('^' || p_despacho::text || '/') then
      return jsonb_build_object('ok', false, 'errores',
        jsonb_build_array('documento con ruta fuera del despacho: ' || coalesce(v_url,'(nula)')));
    end if;
    insert into inhouse_documentos (despacho_id, tipo, nombre, sha256, file_url, file_size,
                                    nro_tributario, hash_fuente, subido_por)
    values (p_despacho, v_tp, v_doc->>'nombre', v_doc->>'sha256', v_url,
            (v_doc->>'file_size')::integer, v_nro, v_hash_fuente, v_user)
    returning id into v_id;
    v_ids := v_ids || jsonb_build_object('tipo', v_tp, 'id', v_id);
  end loop;

  update inhouse_despachos
     set data = p_data,
         contenedor = coalesce(nullif(v_cont,''), contenedor),
         consignatario = coalesce(nullif(p_data->>'consignatario',''), consignatario),
         updated_at = now()
   where id = p_despacho;

  return jsonb_build_object('ok', true, 'documentos', v_ids, 'hash_fuente', v_hash_fuente);
end;
$function$;

CREATE OR REPLACE FUNCTION public.inhouse_is_supervisor()
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select exists (
    select 1 from users u
    where u.auth_user_id = auth.uid()
      and u.status = 'Active'
      and u.role in ('Admin','VP','Manager')
  );
$function$;

CREATE OR REPLACE FUNCTION public.inhouse_lista_clientes()
 RETURNS TABLE(client_id uuid, company_name text, ruc text, pais text, formato_tributario text, activo boolean, despachos bigint, activos bigint)
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select p.client_id, c.company_name, c.ruc, p.pais, p.formato_tributario, p.activo,
         (select count(*) from inhouse_despachos d where d.client_id = p.client_id),
         (select count(*) from inhouse_despachos d where d.client_id = p.client_id and d.estado < 8)
  from inhouse_profiles p
  join clients c on c.id = p.client_id
  where p.activo
    and c.deleted_at is null
    and inhouse_can_touch_client(p.client_id)
  order by c.company_name;
$function$;

CREATE OR REPLACE FUNCTION public.inhouse_perfil(p_client uuid)
 RETURNS jsonb
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select case when not inhouse_can_touch_client(p_client) then null
    else jsonb_build_object(
      'client_id', p.client_id,
      'company_name', c.company_name,
      'ruc', c.ruc,
      'direccion', p.direccion, 'logo', p.logo, 'pais', p.pais,
      'formato_tributario', p.formato_tributario, 'formato_nro', p.formato_nro,
      'placeholder_nro', p.placeholder_nro, 'col_map', p.col_map,
      'regla_orden', p.regla_orden, 'consignatarios', p.consignatarios, 'firma', p.firma)
  end
  from inhouse_profiles p
  join clients c on c.id = p.client_id
  where p.client_id = p_client;
$function$;

CREATE OR REPLACE FUNCTION public.is_intercompany_name(n text)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
AS $function$
  select n ilike 'GLOVAL %' or n ilike 'GLOVAL SHIPPING%' or n ilike 'GLOVAL HOLDING%'
$function$;

CREATE OR REPLACE FUNCTION public.is_lcl_admin()
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select exists (
    select 1 from public.lcl_admin_emails
    where lower(email) = lower(auth.jwt() ->> 'email')
  );
$function$;

CREATE OR REPLACE FUNCTION public.job_application_get(p_token uuid)
 RETURNS TABLE(full_name text, phone text, email text, status text)
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select full_name, phone, email, status
  from public.job_applicants
  where access_token = p_token
  limit 1;
$function$;

CREATE OR REPLACE FUNCTION public.liq_accept_settlement(p_settlement_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_catalog'
AS $function$
begin
  if _user_email() not in ('avaldano@glovalgroup.com','janeth@glovalecuador.com','contable2@glovalecuador.com') then
    raise exception 'No autorizado';
  end if;
  update liq_settlements
     set status = 'accepted', accepted_by_seller_at = now(), updated_at = now()
   where id = p_settlement_id and status = 'ready';
  if not found then
    raise exception 'La liquidación no está en estado "ready"';
  end if;
end $function$;

CREATE OR REPLACE FUNCTION public.liq_apply_agent_invoice(p_invoice jsonb, p_lines jsonb, p_apps jsonb)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
declare
  v_id uuid;
  l jsonb;
  a jsonb;
  v_line_id uuid;
begin
  insert into liq_agent_invoices (master_number, week_of, agent, invoice_number, invoice_date, total, created_by, applied_at)
  values (
    p_invoice->>'master_number',
    nullif(p_invoice->>'week_of','')::date,
    nullif(p_invoice->>'agent',''),
    nullif(p_invoice->>'invoice_number',''),
    nullif(p_invoice->>'invoice_date','')::date,
    coalesce((p_invoice->>'total')::numeric, 0),
    nullif(p_invoice->>'created_by',''),
    now()
  ) returning id into v_id;

  for l in select * from jsonb_array_elements(p_lines) loop
    insert into liq_agent_invoice_lines (invoice_id, charge_code, custom_name, amount, prorate_by, sort_order)
    values (v_id, l->>'charge_code', nullif(l->>'custom_name',''),
            (l->>'amount')::numeric, l->>'prorate_by', coalesce((l->>'sort_order')::int, 100));
  end loop;

  -- p_apps: [{settlement_id, charge_code, custom_name, cost_amount}] ya agregados
  -- por concepto+hija (los duplicados se sumaron en el cliente).
  for a in select * from jsonb_array_elements(p_apps) loop
    -- una sola fila destino, elegida determinísticamente
    select id into v_line_id
    from liq_settlement_lines
    where settlement_id = (a->>'settlement_id')::uuid
      and case
        when (a->>'charge_code') like 'OTRO%' then
          charge_code like 'OTRO%' and coalesce(custom_name,'') = coalesce(a->>'custom_name','')
        else charge_code = a->>'charge_code'
      end
    order by id limit 1;

    if v_line_id is not null then
      update liq_settlement_lines
         set cost_amount = (a->>'cost_amount')::numeric, applies = true
       where id = v_line_id;
    else
      insert into liq_settlement_lines (settlement_id, charge_code, section, basis, applies,
        cost_rate, cost_amount, sale_rate, sale_amount, currency, custom_name, sort_order)
      values (
        (a->>'settlement_id')::uuid,
        case when (a->>'charge_code') like 'OTRO%' then 'OTRO' else a->>'charge_code' end,
        'freight', 'manual', true, 0, (a->>'cost_amount')::numeric, 0, 0, 'USD',
        case when (a->>'charge_code') like 'OTRO%' then coalesce(a->>'custom_name','') else null end,
        95
      );
    end if;
    v_line_id := null;
  end loop;

  return v_id;
end $function$;

CREATE OR REPLACE FUNCTION public.liq_apply_agent_invoice(p_invoice jsonb, p_lines jsonb, p_apps jsonb, p_cleanup_settlements jsonb DEFAULT '[]'::jsonb)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
declare
  v_id uuid;
  l jsonb;
  a jsonb;
  v_line_id uuid;
begin
  insert into liq_agent_invoices (master_number, week_of, agent, invoice_number, invoice_date, total, created_by, applied_at)
  values (
    p_invoice->>'master_number',
    nullif(p_invoice->>'week_of','')::date,
    nullif(p_invoice->>'agent',''),
    nullif(p_invoice->>'invoice_number',''),
    nullif(p_invoice->>'invoice_date','')::date,
    coalesce((p_invoice->>'total')::numeric, 0),
    nullif(p_invoice->>'created_by',''),
    now()
  ) returning id into v_id;

  for l in select * from jsonb_array_elements(p_lines) loop
    insert into liq_agent_invoice_lines (invoice_id, charge_code, custom_name, amount, prorate_by, sort_order)
    values (v_id, l->>'charge_code', nullif(l->>'custom_name',''),
            (l->>'amount')::numeric, l->>'prorate_by', coalesce((l->>'sort_order')::int, 100));
  end loop;

  for a in select * from jsonb_array_elements(p_apps) loop
    select id into v_line_id
    from liq_settlement_lines
    where settlement_id = (a->>'settlement_id')::uuid
      and case
        when (a->>'charge_code') like 'OTRO%' then
          charge_code like 'OTRO%' and coalesce(custom_name,'') = coalesce(a->>'custom_name','')
        else charge_code = a->>'charge_code'
      end
    order by id limit 1;

    if v_line_id is not null then
      update liq_settlement_lines
         set cost_amount = (a->>'cost_amount')::numeric, applies = true
       where id = v_line_id;
    else
      insert into liq_settlement_lines (settlement_id, charge_code, section, basis, applies,
        cost_rate, cost_amount, sale_rate, sale_amount, currency, custom_name, sort_order)
      values (
        (a->>'settlement_id')::uuid,
        case when (a->>'charge_code') like 'OTRO%' then 'OTRO' else a->>'charge_code' end,
        'freight', 'manual', true, 0, (a->>'cost_amount')::numeric, 0, 0, 'USD',
        case when (a->>'charge_code') like 'OTRO%' then coalesce(a->>'custom_name','') else null end,
        95
      );
    end if;
    v_line_id := null;
  end loop;

  -- Limpieza: fuera las líneas totalmente vacías (sin montos NI tarifas) de las
  -- liquidaciones del master. No toca pct_invoice ni conceptos libres con nombre.
  delete from liq_settlement_lines
  where settlement_id in (select (jsonb_array_elements_text(p_cleanup_settlements))::uuid)
    and coalesce(cost_amount, 0) = 0
    and coalesce(sale_amount, 0) = 0
    and coalesce(cost_rate, 0) = 0
    and coalesce(sale_rate, 0) = 0
    and basis <> 'pct_invoice'
    and coalesce(nullif(trim(custom_name), ''), '') = '';

  return v_id;
end $function$;

CREATE OR REPLACE FUNCTION public.liq_lines_recalc_trigger()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  perform liq_recalc_settlement(coalesce(new.settlement_id, old.settlement_id));
  return coalesce(new, old);
end $function$;

CREATE OR REPLACE FUNCTION public.liq_recalc_settlement(p_settlement_id uuid)
 RETURNS void
 LANGUAGE sql
AS $function$
  update liq_settlements s set
    freight_cost_total = coalesce((select sum(cost_amount) from liq_settlement_lines l where l.settlement_id = s.id and l.section = 'freight' and l.applies), 0),
    freight_sale_total = coalesce((select sum(sale_amount) from liq_settlement_lines l where l.settlement_id = s.id and l.section = 'freight' and l.applies), 0),
    local_cost_total   = coalesce((select sum(cost_amount) from liq_settlement_lines l where l.settlement_id = s.id and l.section = 'local_ec' and l.applies), 0),
    local_sale_total   = coalesce((select sum(sale_amount) from liq_settlement_lines l where l.settlement_id = s.id and l.section = 'local_ec' and l.applies), 0),
    updated_at = now()
  where s.id = p_settlement_id;
$function$;

CREATE OR REPLACE FUNCTION public.log_audit_entry(p_user_id uuid, p_action text, p_table_name text, p_record_id text, p_changes jsonb)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
  INSERT INTO audit_log (
    user_id,
    action,
    table_name,
    record_id,
    old_values,
    new_values,
    changes_summary,
    user_name,
    created_at
  )
  VALUES (
    p_user_id,
    p_action,
    p_table_name,
    CASE 
      WHEN p_record_id IS NULL OR p_record_id = '' THEN NULL 
      ELSE p_record_id::uuid 
    END,
    p_changes->'old_values',
    p_changes->'new_values',
    p_changes->>'changes_summary',
    p_changes->>'user_name',
    NOW()
  );
END;
$function$;

CREATE OR REPLACE FUNCTION public.log_login_history(p_user_id uuid, p_ip_address text, p_user_agent text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
v_email text;
v_device_type text;
v_is_mobile boolean;
BEGIN
-- Get user email
SELECT email INTO v_email
FROM auth.users
WHERE id = p_user_id;

-- Determine device type from user agent
v_is_mobile := p_user_agent ~ '(?i)(Mobile|Android|iPhone|iPad|iPod)';
v_device_type := CASE WHEN v_is_mobile THEN 'Mobile' ELSE 'Desktop' END;

-- Insert login history record
INSERT INTO login_history (
user_id,
email,
login_at,
ip_address,
user_agent,
device_type,
status
)
VALUES (
p_user_id,
v_email,
NOW(),
p_ip_address,
p_user_agent,
v_device_type,
'success'
);
END;
$function$;

CREATE OR REPLACE FUNCTION public.log_sync(p_company_id uuid, p_sync_type text, p_status text, p_details jsonb)
 RETURNS json
 LANGUAGE plpgsql
 SET search_path TO 'public', 'pg_catalog'
AS $function$
DECLARE
  new_id uuid;
  v_count int;
  v_errors int;
BEGIN
  v_count := COALESCE(
    (p_details->>'count')::int,
    COALESCE((p_details->'transactions'->>'IN')::int,0) +
    COALESCE((p_details->'transactions'->>'BL')::int,0) +
    COALESCE((p_details->'transactions'->>'PM')::int,0) +
    COALESCE((p_details->'transactions'->>'CR')::int,0) +
    COALESCE((p_details->'transactions'->>'SH')::int,0) +
    COALESCE((p_details->>'entities')::int,0),
    0
  );

  v_errors := CASE
    WHEN jsonb_typeof(p_details->'errors') = 'array' THEN jsonb_array_length(p_details->'errors')
    WHEN p_details->>'errors' IS NOT NULL AND p_details->>'errors' != '' THEN (p_details->>'errors')::int
    ELSE 0
  END;

  INSERT INTO magaya_sync_log (
    id, company_id, sync_type, status,
    records_synced, records_failed, error_message,
    metadata, started_at, completed_at
  )
  VALUES (
    gen_random_uuid(), p_company_id, p_sync_type, p_status,
    v_count, v_errors,
    p_details->>'error',
    p_details,
    COALESCE((p_details->>'started_at')::timestamptz, NOW()),
    NOW()
  )
  RETURNING id INTO new_id;

  RETURN json_build_object('id', new_id, 'records_synced', v_count, 'records_failed', v_errors);
END;
$function$;

CREATE OR REPLACE FUNCTION public.magaya_amount_to_usd(p_company_id uuid, p_amount numeric, p_amount_usd numeric)
 RETURNS numeric
 LANGUAGE sql
 IMMUTABLE
AS $function$
  select case
    when p_amount_usd is not null and p_amount > 0 then p_amount_usd
    when p_company_id = '9b807b51-5ee9-4a22-9e75-df90047ec12b'::uuid then p_amount / 3.42
    else p_amount
  end
$function$;

CREATE OR REPLACE FUNCTION public.magaya_wr_encolar_huecos(p_dias integer DEFAULT 60, p_limite integer DEFAULT 500)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_desde int;
  v_hasta int;
  v_huecos int := 0;
  v_transitorios int := 0;
  v_no_encontrados int := 0;
begin
  select min(wr_number::int) filter (where created_on >= current_date - p_dias),
         max(wr_number::int) filter (where created_on >= current_date - 120)
    into v_desde, v_hasta
  from magaya_warehouse_receipts
  where wr_number ~ '^[0-9]{6,7}$';

  if v_desde is null or v_hasta is null then
    return jsonb_build_object('huecos_encolados', 0, 'motivo', 'sin rango');
  end if;

  insert into wr_saldo_queue (wr_number, prioridad)
  select g::text, 1
  from generate_series(v_desde, v_hasta - 2) g
  where not exists (select 1 from magaya_warehouse_receipts w where w.wr_number = g::text)
    and not exists (select 1 from wr_saldo_queue q where q.wr_number = g::text)
  order by g desc
  limit p_limite
  on conflict (wr_number) do nothing;
  get diagnostics v_huecos = row_count;

  update wr_saldo_queue q
     set intentos = 0
   where q.resuelto_at is null
     and q.intentos >= 3
     and q.ultimo_intento_at < now() - interval '1 hour'
     and (q.error ilike '%auth failed%'
          or q.error ilike '%timed out%'
          or q.error ilike '%timeout%'
          or q.error ilike '%abort%'
          or q.error ~ 'fetch-full 5[0-9]{2}')
     and (case when q.wr_number ~ '^[0-9]{6,7}$' then q.wr_number::int end) >= v_desde;
  get diagnostics v_transitorios = row_count;

  update wr_saldo_queue q
     set intentos = 0
   where q.resuelto_at is null
     and q.intentos >= 3
     and q.error ilike '%not found%'
     and q.created_at >= now() - interval '3 days'
     and q.ultimo_intento_at < now() - interval '12 hours';
  get diagnostics v_no_encontrados = row_count;

  return jsonb_build_object(
    'desde', v_desde, 'hasta', v_hasta,
    'huecos_encolados', v_huecos,
    'reintentos_transitorios', v_transitorios,
    'reintentos_no_encontrados', v_no_encontrados);
end $function$;

CREATE OR REPLACE FUNCTION public.magaya_wr_force_company()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
begin
  new.company_id := 'aba24859-159c-424b-8ef3-d122fba41b7c';  -- GLOVAL USA
  return new;
end;
$function$;

CREATE OR REPLACE FUNCTION public.magaya_wr_items_guarda()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  if tg_op = 'UPDATE' then
    -- La identidad de la pieza no vuelve a NULL: ni un parser viejo ni un
    -- UPDATE a mano borran el número de pieza o su GUID.
    new.whr_item_id := coalesce(new.whr_item_id, old.whr_item_id);
    new.item_guid   := coalesce(new.item_guid, old.item_guid);
    return new;
  end if;

  -- INSERT / DELETE: solo magaya_wr_items_reemplazar (marca local de su
  -- transacción) o el borrado en cascada del WR (corre dentro de un trigger).
  -- Mantenimiento a mano: SET LOCAL gloval.wr_items_escritor = 'mantenimiento'.
  if coalesce(current_setting('gloval.wr_items_escritor', true), '') in ('reemplazar', 'mantenimiento')
     or pg_trigger_depth() > 1 then
    return case when tg_op = 'DELETE' then old else new end;
  end if;

  raise exception using
    errcode = 'P0001',
    message = format(
      'magaya_wr_items: %s directo bloqueado (WR %s). Los ítems se escriben solo con magaya_wr_items_reemplazar().',
      tg_op, case when tg_op = 'DELETE' then old.wr_number else new.wr_number end),
    hint = 'Un DELETE + INSERT suelto borró los números de pieza del 28-ago al 14-sep-2026.';
end;
$function$;

CREATE OR REPLACE FUNCTION public.magaya_wr_items_reemplazar(p_wr_id uuid, p_items jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_wr         record;
  v_ids_antes  int;
  v_ids_nuevos int;
  v_pares_id   uuid[];
  v_pares_ord  bigint[];
  v_huella_id  uuid[];
  v_huella_ord bigint[];
  n_upd        int := 0;
  n_ins        int := 0;
  n_del        int := 0;
begin
  if p_items is null or jsonb_typeof(p_items) <> 'array' then
    raise exception 'magaya_wr_items_reemplazar: p_items debe ser un arreglo JSON';
  end if;

  select id, wr_number, company_id into v_wr
  from magaya_warehouse_receipts where id = p_wr_id;
  if not found then
    raise exception 'magaya_wr_items_reemplazar: el WR % no existe en el espejo', p_wr_id;
  end if;

  -- Un escritor por WR a la vez: wh-onhand-verify llama con concurrencia y dos
  -- DELETE + INSERT cruzados duplicaban ítems (y doble-contaban piezas).
  perform pg_advisory_xact_lock(hashtextextended('magaya_wr_items:' || p_wr_id::text, 0));

  select count(*) filter (where whr_item_id is not null)
    into v_ids_antes
  from magaya_wr_items where wr_id = p_wr_id;

  select count(*) into v_ids_nuevos
  from jsonb_array_elements(p_items) e
  where nullif(btrim(e ->> 'whr_item_id'), '') is not null;

  if v_ids_antes > 0 and v_ids_nuevos = 0 then
    raise exception using
      errcode = 'P0001',
      message = format(
        'WR %s: la base tiene %s ítems con número de pieza y esta lectura de Magaya no trae ninguno; se conservan los ítems (no se pisa con NULL).',
        v_wr.wr_number, v_ids_antes),
      hint = 'Revisar que la magaya-wr-fetch-full desplegada parsee <WHRItemID> (regresión del 28-ago-2026).';
  end if;

  perform set_config('gloval.wr_items_escritor', 'reemplazar', true);

  -- 1) Emparejar por item_guid. El número de orden cubre un GUID repetido.
  with nuevos as (
    select o.ord, o.e ->> 'item_guid' as item_guid,
           row_number() over (partition by o.e ->> 'item_guid' order by o.ord) as rn
    from jsonb_array_elements(p_items) with ordinality as o(e, ord)
    where nullif(o.e ->> 'item_guid', '') is not null
  ), viejos as (
    select i.id, i.item_guid,
           row_number() over (partition by i.item_guid order by i.synced_at, i.id) as rn
    from magaya_wr_items i
    where i.wr_id = p_wr_id and i.item_guid is not null
  )
  select coalesce(array_agg(v.id), '{}'), coalesce(array_agg(n.ord), '{}')
    into v_pares_id, v_pares_ord
  from nuevos n
  join viejos v on v.item_guid = n.item_guid and v.rn = n.rn;

  -- 2) Lo que sobra, contra las filas SIN guid ni número, por su huella cruda.
  --    La descripción con forma de ubicación ('12-34-56') la mueve
  --    app_fix_wr_item_location a warehouse_zone: se compara igual que ella.
  with nuevos as (
    select o.ord,
           case when x.description ~ '^[0-9]{1,3}-[0-9]{1,3}-[0-9]{1,3}$' then ''
                else coalesce(x.description, '') end as d,
           coalesce(x.pieces, -1)  as p,
           round(x.weight, 4)      as w,
           round(x.volume_cbm, 4)  as v
    from jsonb_array_elements(p_items) with ordinality as o(e, ord)
    cross join lateral jsonb_populate_record(null::magaya_wr_items, o.e) as x
    where o.ord <> all (v_pares_ord)
  ), nuevos_k as (
    select n.*, row_number() over (partition by n.d, n.p, n.w, n.v order by n.ord) as rn
    from nuevos n
  ), viejos as (
    select i.id, i.synced_at,
           coalesce(i.description, '') as d,
           coalesce(i.pieces, -1)      as p,
           round(i.weight, 4)          as w,
           round(i.volume_cbm, 4)      as v
    from magaya_wr_items i
    where i.wr_id = p_wr_id and i.item_guid is null and i.whr_item_id is null
  ), viejos_k as (
    select x.*, row_number() over (partition by x.d, x.p, x.w, x.v order by x.synced_at, x.id) as rn
    from viejos x
  )
  select coalesce(array_agg(v.id), '{}'), coalesce(array_agg(n.ord), '{}')
    into v_huella_id, v_huella_ord
  from nuevos_k n
  join viejos_k v on v.d = n.d and v.p = n.p
                 and v.w is not distinct from n.w
                 and v.v is not distinct from n.v
                 and v.rn = n.rn;

  v_pares_id  := v_pares_id  || v_huella_id;
  v_pares_ord := v_pares_ord || v_huella_ord;

  -- a) Lo que Magaya ya no trae.
  delete from magaya_wr_items i
  where i.wr_id = p_wr_id
    and i.id <> all (v_pares_id);
  get diagnostics n_del = row_count;

  -- b) Lo emparejado se actualiza EN SITIO: el id se conserva,
  --    consolidado_linea_piezas.wr_item_id sigue apuntando a su pieza y
  --    trg_sync_wr_items (AFTER INSERT) no vuelve a sumar cantidades.
  update magaya_wr_items t
  set description             = x.description,
      item_description        = x.item_description,
      part_number             = x.part_number,
      internal_name           = x.internal_name,
      item_code               = x.item_code,
      pieces                  = x.pieces,
      quantity                = x.quantity,
      weight                  = x.weight,
      volume_cbm              = x.volume_cbm,
      weight_unit             = x.weight_unit,
      volume_unit             = x.volume_unit,
      peso_lb                 = x.peso_lb,
      vol_cft                 = x.vol_cft,
      length                  = x.length,
      width                   = x.width,
      height                  = x.height,
      piece_volume            = x.piece_volume,
      piece_weight            = x.piece_weight,
      piece_quantity          = x.piece_quantity,
      package_name            = x.package_name,
      is_pallet               = x.is_pallet,
      is_container            = x.is_container,
      item_type               = x.item_type,
      supplier                = x.supplier,
      notes                   = x.notes,
      warehouse_zone          = x.warehouse_zone,
      container_number        = x.container_number,
      item_guid               = x.item_guid,
      status                  = x.status,
      cargo_release_guid      = x.cargo_release_guid,
      whr_item_id             = x.whr_item_id,
      location_code           = x.location_code,
      supplier_invoice_number = x.supplier_invoice_number,
      supplier_po_number      = x.supplier_po_number,
      synced_at               = coalesce(x.synced_at, now()),
      last_full_fetch_at      = coalesce(x.last_full_fetch_at, now())
  from unnest(v_pares_id, v_pares_ord) as p(id, ord)
  join jsonb_array_elements(p_items) with ordinality as o(e, ord) on o.ord = p.ord
  cross join lateral jsonb_populate_record(null::magaya_wr_items, o.e) as x
  where t.id = p.id;
  get diagnostics n_upd = row_count;

  -- c) Lo nuevo.
  insert into magaya_wr_items (
    wr_id, wr_number, company_id,
    description, item_description, part_number, internal_name, item_code,
    pieces, quantity, weight, volume_cbm, weight_unit, volume_unit, peso_lb, vol_cft,
    length, width, height, piece_volume, piece_weight, piece_quantity,
    package_name, is_pallet, is_container, item_type, supplier, notes,
    warehouse_zone, container_number, item_guid, status, cargo_release_guid,
    whr_item_id, location_code, supplier_invoice_number, supplier_po_number,
    synced_at, last_full_fetch_at)
  select
    p_wr_id, v_wr.wr_number, v_wr.company_id,
    x.description, x.item_description, x.part_number, x.internal_name, x.item_code,
    x.pieces, x.quantity, x.weight, x.volume_cbm, x.weight_unit, x.volume_unit, x.peso_lb, x.vol_cft,
    x.length, x.width, x.height, x.piece_volume, x.piece_weight, x.piece_quantity,
    x.package_name, x.is_pallet, x.is_container, x.item_type, x.supplier, x.notes,
    x.warehouse_zone, x.container_number, x.item_guid, x.status, x.cargo_release_guid,
    x.whr_item_id, x.location_code, x.supplier_invoice_number, x.supplier_po_number,
    coalesce(x.synced_at, now()), coalesce(x.last_full_fetch_at, now())
  from jsonb_array_elements(p_items) with ordinality as o(e, ord)
  cross join lateral jsonb_populate_record(null::magaya_wr_items, o.e) as x
  where o.ord <> all (v_pares_ord)
  order by o.ord;
  get diagnostics n_ins = row_count;

  return jsonb_build_object(
    'wr_number',              v_wr.wr_number,
    'actualizados',           n_upd,
    'emparejados_por_huella', coalesce(array_length(v_huella_id, 1), 0),
    'insertados',             n_ins,
    'borrados',               n_del,
    'con_whr_item_id',        v_ids_nuevos,
    'tenia_whr_item_id',      v_ids_antes);
end;
$function$;

CREATE OR REPLACE FUNCTION public.match_consignee_fuzzy(p_query_name text, p_query_tax_id text DEFAULT NULL::text, p_limit integer DEFAULT 5, p_threshold numeric DEFAULT 0.4)
 RETURNS TABLE(client_id uuid, company_name text, office text, assigned_to uuid, similarity_score numeric, tax_id_match boolean)
 LANGUAGE sql
 STABLE
 SET search_path TO 'public', 'pg_catalog'
AS $function$
  with q as (
    select public.normalize_company_name(p_query_name) as qnorm,
           regexp_replace(coalesce(p_query_tax_id,''),'\D','','g') as qruc
  )
  select
    c.id,
    c.company_name,
    c.office,
    c.assigned_to,
    round(extensions.similarity(c.company_name_normalized, q.qnorm)::numeric, 3) as sim,
    (q.qruc <> '' and q.qruc = regexp_replace(coalesce(c.ruc,''),'\D','','g')) as tax_match
  from public.clients c, q
  where c.deleted_at is null
    and (
      (c.company_name_normalized operator(extensions.%) q.qnorm)
      or (q.qruc <> '' and q.qruc = regexp_replace(coalesce(c.ruc,''),'\D','','g'))
    )
  order by tax_match desc, sim desc
  limit p_limit;
$function$;

CREATE OR REPLACE FUNCTION public.match_wr(p_wr_id uuid)
 RETURNS wr_match_results
 LANGUAGE plpgsql
 SET search_path TO 'public', 'pg_catalog'
AS $function$
declare
  v_wr            public.magaya_warehouse_receipts;
  v_consignee_norm text;
  v_tax_id        text;
  v_alias         public.consignee_aliases;
  v_top           record;
  v_count         int;
  v_status        wr_match_status_t;
  v_client        uuid;
  v_score         numeric;
  v_reason        text;
  v_candidates    jsonb;
  v_existing_shipment uuid;
  v_office        text;
  v_result        public.wr_match_results;
begin
  select * into v_wr from public.magaya_warehouse_receipts where id = p_wr_id;
  if v_wr.id is null then raise exception 'WR % not found', p_wr_id; end if;

  v_consignee_norm := v_wr.consignee_normalized;  -- usar columna stored
  v_tax_id := public.enrich_consignee_from_magaya(v_wr.consignee);
  v_office := public.wr_destination_to_office(v_wr.destination_port, v_wr.destination_agent);

  select coalesce(jsonb_agg(to_jsonb(t)), '[]'::jsonb) into v_candidates
    from (select * from public.match_consignee_fuzzy(v_wr.consignee, v_tax_id, 5, 0.3)) t;

  if v_tax_id is not null and length(regexp_replace(v_tax_id,'\D','','g')) > 0 then
    select c.id into v_client
      from public.clients c
     where c.deleted_at is null
       and regexp_replace(coalesce(c.ruc,''),'\D','','g') = regexp_replace(v_tax_id,'\D','','g')
     order by case when v_office is not null and c.office = v_office then 0 else 1 end
     limit 1;
    if v_client is not null then
      v_status := 'AUTO_MATCHED'; v_score := 1.0; v_reason := 'tax_id';
    end if;
  end if;

  if v_status is null then
    select a.* into v_alias from public.consignee_aliases a
      join public.clients c on c.id = a.client_id and c.deleted_at is null
     where a.alias_normalized = v_consignee_norm
     order by case when v_office is not null and c.office = v_office then 0 else 1 end
     limit 1;
    if v_alias.id is not null then
      v_status := 'AUTO_MATCHED'; v_client := v_alias.client_id;
      v_score := 1.0; v_reason := 'alias';
    end if;
  end if;

  if v_status is null then
    select count(*) into v_count from public.clients c
      where c.deleted_at is null
        and c.company_name_normalized = v_consignee_norm;
    if v_count = 1 then
      select c.id into v_client from public.clients c
        where c.deleted_at is null
          and c.company_name_normalized = v_consignee_norm;
      v_status := 'AUTO_MATCHED'; v_score := 1.0; v_reason := 'exact_name';
    elsif v_count > 1 and v_office is not null then
      select c.id into v_client from public.clients c
        where c.deleted_at is null
          and c.company_name_normalized = v_consignee_norm
          and c.office = v_office
        limit 1;
      if v_client is not null then
        v_status := 'AUTO_MATCHED'; v_score := 1.0; v_reason := 'exact_name_office';
      end if;
    end if;
  end if;

  if v_status is null then
    select * into v_top from public.match_consignee_fuzzy(v_wr.consignee, v_tax_id, 1, 0.4);
    if v_top.client_id is null then
      v_status := 'ORPHAN'; v_reason := 'no_candidate';
    elsif v_top.similarity_score >= 0.85 then
      v_status := 'AUTO_MATCHED'; v_client := v_top.client_id;
      v_score := v_top.similarity_score; v_reason := 'fuzzy_high';
    elsif v_top.similarity_score >= 0.6 then
      v_status := 'SUGGESTED'; v_client := v_top.client_id;
      v_score := v_top.similarity_score; v_reason := 'fuzzy_med';
    else
      v_status := 'ORPHAN'; v_score := v_top.similarity_score; v_reason := 'low_confidence';
    end if;
  end if;

  if v_status = 'AUTO_MATCHED' and v_client is not null then
    select s.id into v_existing_shipment
      from public.shipments s
      where s.client_id = v_client
        and s.status in ('BOOKING','LOADED','IN_TRANSIT','IN_WAREHOUSE')
        and (
          (v_wr.tracking_number is not null and (
            s.mbl ilike '%'||v_wr.tracking_number||'%' or
            s.hbl ilike '%'||v_wr.tracking_number||'%' or
            s.booking_ref ilike '%'||v_wr.tracking_number||'%'
          ))
          or s.created_at >= now() - interval '90 days'
        )
      order by s.created_at desc
      limit 1;
  end if;

  insert into public.wr_match_results
    (wr_id, status, matched_client_id, matched_shipment_id, match_score, match_reason, candidates, office)
  values
    (p_wr_id, v_status, v_client, v_existing_shipment, v_score, v_reason, v_candidates, v_office)
  on conflict (wr_id) do update set
    status = excluded.status,
    matched_client_id = excluded.matched_client_id,
    matched_shipment_id = excluded.matched_shipment_id,
    match_score = excluded.match_score,
    match_reason = excluded.match_reason,
    candidates = excluded.candidates,
    office = excluded.office,
    updated_at = now()
  returning * into v_result;

  return v_result;
end $function$;

CREATE OR REPLACE FUNCTION public.mi_apply_review_decision(p_review_id uuid, p_decision mi_match_status_t, p_reviewer uuid, p_notes text DEFAULT NULL::text)
 RETURNS integer
 LANGUAGE plpgsql
 SET statement_timeout TO '5min'
 SET search_path TO 'public', 'extensions', 'pg_catalog'
AS $function$
declare
  v_review record;
  v_count int := 0;
  v_ruc_norm text;
begin
  if p_decision not in ('APPROVED','REJECTED') then
    raise exception 'mi_apply_review_decision: decision must be APPROVED or REJECTED';
  end if;

  select * into v_review from public.mi_match_review_queue
   where id = p_review_id and status = 'PENDING' for update;
  if not found then
    raise exception 'review entry % not found or not pending', p_review_id;
  end if;

  v_ruc_norm := nullif(regexp_replace(coalesce(v_review.ec_company_id,''),'\D','','g'),'');

  if p_decision = 'APPROVED' and v_ruc_norm is not null then
    -- Use indexed generated column ec_company_id_norm (mi_intel_ec_company_id_idx)
    update public.mi_shipment_intel i
       set client_id        = v_review.suggested_client_id,
           match_method     = v_review.match_method,
           match_confidence = v_review.match_confidence,
           matched_at       = now()
     where i.client_id is null
       and i.ec_company_id_norm = v_ruc_norm;
    get diagnostics v_count = row_count;
  end if;

  update public.mi_match_review_queue
     set status      = p_decision,
         reviewed_by = p_reviewer,
         reviewed_at = now(),
         notes       = p_notes,
         updated_at  = now()
   where id = p_review_id;

  return v_count;
end $function$;

CREATE OR REPLACE FUNCTION public.mi_backfill_classifications(p_modality mi_modality_t DEFAULT NULL::mi_modality_t)
 RETURNS TABLE(carriers integer, forwarders integer, partners integer, origin integer)
 LANGUAGE plpgsql
 SET statement_timeout TO '15min'
 SET search_path TO 'public', 'extensions', 'pg_catalog'
AS $function$
declare
  v_carriers int := 0; v_forwarders int := 0; v_partners int := 0; v_origin int := 0;
begin
  -- 1. Carrier
  with upd as (
    update public.mi_shipment_intel i
       set carrier_canonical_id = aa.canonical_id
      from public.mi_actor_alias aa
      join public.mi_canonical_actor ca on ca.id = aa.canonical_id and ca.actor_type='CARRIER'
     where (p_modality is null or i.modality = p_modality)
       and i.carrier_canonical_id is null
       and i.carrier_raw is not null
       and aa.alias_normalized = public.normalize_company_name(i.carrier_raw)
    returning 1
  ) select count(*) into v_carriers from upd;

  -- 2. Forwarder + flags (LIBERADOR > RECEPTOR)
  with upd as (
    update public.mi_shipment_intel i
       set forwarder_canonical_id    = aa.canonical_id,
           is_direct_no_forwarder    = coalesce(ca.is_direct_bucket, false),
           forwarder_roles_split     = (
             i.forwarder_raw_receptor is not null and btrim(i.forwarder_raw_receptor) <> '' and
             i.forwarder_raw_liberador is not null and btrim(i.forwarder_raw_liberador) <> '' and
             public.normalize_company_name(i.forwarder_raw_receptor)
               is distinct from public.normalize_company_name(i.forwarder_raw_liberador)
           )
      from public.mi_actor_alias aa
      join public.mi_canonical_actor ca on ca.id = aa.canonical_id and ca.actor_type='FORWARDER'
     where (p_modality is null or i.modality = p_modality)
       and i.forwarder_canonical_id is null
       and (i.forwarder_raw_liberador is not null or i.forwarder_raw_receptor is not null)
       and aa.alias_normalized = public.normalize_company_name(coalesce(i.forwarder_raw_liberador, i.forwarder_raw_receptor))
    returning 1
  ) select count(*) into v_forwarders from upd;

  -- 3. Partner exterior
  with upd as (
    update public.mi_shipment_intel i
       set partner_canonical_id = aa.canonical_id
      from public.mi_actor_alias aa
      join public.mi_canonical_actor ca on ca.id = aa.canonical_id and ca.actor_type='PARTNER'
     where (p_modality is null or i.modality = p_modality)
       and i.partner_canonical_id is null
       and i.partner_raw is not null
       and aa.alias_normalized = public.normalize_company_name(i.partner_raw)
    returning 1
  ) select count(*) into v_partners from upd;

  -- 4. origin_partner_type + origin_partner_office (deriva de los canonicals)
  with upd as (
    update public.mi_shipment_intel i
       set origin_partner_type = case
             when coalesce(i.is_direct_no_forwarder,false) then 'DIRECT_NO_AGENT'::mi_origin_partner_t
             when pc.is_gloval                              then 'GLOVAL_NETWORK'::mi_origin_partner_t
             when i.partner_canonical_id is not null         then 'THIRD_PARTY'::mi_origin_partner_t
             else 'UNKNOWN'::mi_origin_partner_t end,
           origin_partner_office = case when pc.is_gloval then pc.gloval_office else null end
      from (select 1) dummy
      left join public.mi_canonical_actor pc on pc.id = i.partner_canonical_id
     where (p_modality is null or i.modality = p_modality)
       and (
         i.origin_partner_type = 'UNKNOWN'
         or (coalesce(i.is_direct_no_forwarder,false) and i.origin_partner_type <> 'DIRECT_NO_AGENT')
       )
    returning 1
  ) select count(*) into v_origin from upd;

  carriers := v_carriers;
  forwarders := v_forwarders;
  partners := v_partners;
  origin := v_origin;
  return next;
end $function$;

CREATE OR REPLACE FUNCTION public.mi_classify_origin_partner(p_forwarder_canonical_id uuid, p_partner_canonical_id uuid, p_is_direct_no_forwarder boolean)
 RETURNS TABLE(origin_partner_type mi_origin_partner_t, origin_partner_office text)
 LANGUAGE plpgsql
 SET search_path TO 'public', 'extensions', 'pg_catalog'
AS $function$
declare
  v_partner_is_gloval boolean := false;
  v_partner_office    text;
begin
  if coalesce(p_is_direct_no_forwarder, false) then
    origin_partner_type := 'DIRECT_NO_AGENT'; origin_partner_office := null;
    return next; return;
  end if;
  if p_partner_canonical_id is not null then
    select ca.is_gloval, ca.gloval_office into v_partner_is_gloval, v_partner_office
      from public.mi_canonical_actor ca where ca.id = p_partner_canonical_id;
  end if;
  if v_partner_is_gloval then
    origin_partner_type := 'GLOVAL_NETWORK'; origin_partner_office := v_partner_office;
  elsif p_partner_canonical_id is not null then
    origin_partner_type := 'THIRD_PARTY'; origin_partner_office := null;
  else
    origin_partner_type := 'UNKNOWN'; origin_partner_office := null;
  end if;
  return next;
end $function$;

CREATE OR REPLACE FUNCTION public.mi_client_by_ruc(p_ruc text)
 RETURNS TABLE(id uuid, company_name text, office text, formatted_address text, address_line1 text)
 LANGUAGE sql
 STABLE
AS $function$
  SELECT c.id, c.company_name, c.office, c.formatted_address, c.address_line1
  FROM clients c
  WHERE c.deleted_at IS NULL
    AND regexp_replace(COALESCE(p_ruc,''), '\D', '', 'g') <> ''
    AND regexp_replace(COALESCE(c.ruc,''), '\D', '', 'g')
        = regexp_replace(COALESCE(p_ruc,''), '\D', '', 'g')
  LIMIT 1;
$function$;

CREATE OR REPLACE FUNCTION public.mi_dedup_canonical_actors(p_actor_type mi_actor_type_t)
 RETURNS TABLE(merged_count integer, kept_count integer)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET statement_timeout TO '5min'
 SET search_path TO 'public', 'extensions', 'pg_catalog'
AS $function$
declare
  v_merged int := 0;
  v_kept   int := 0;
  r record;
begin
  -- Group canonicals by normalized name; pick primary per group
  for r in
    with grouped as (
      select id, canonical_name,
             public.normalize_company_name(canonical_name) as norm,
             auto_created, is_gloval, created_at,
             row_number() over (
               partition by public.normalize_company_name(canonical_name)
               order by
                 (auto_created)::int asc,            -- prefer manually-seeded
                 (is_gloval)::int desc,              -- prefer Gloval canonicals
                 length(canonical_name) asc,         -- prefer shorter name
                 created_at asc                      -- oldest first
             ) as rn
        from public.mi_canonical_actor
       where actor_type = p_actor_type
    ),
    primaries as (select id from grouped where rn = 1),
    secondaries as (
      select g.id as secondary_id, p.id as primary_id
        from grouped g
        join grouped p on p.rn = 1 and p.norm = g.norm
       where g.rn > 1
    )
    select * from secondaries
  loop
    -- 1. Update mi_shipment_intel rows pointing to secondary
    case p_actor_type
      when 'PARTNER' then
        update public.mi_shipment_intel
           set partner_canonical_id = r.primary_id
         where partner_canonical_id = r.secondary_id;
      when 'FORWARDER' then
        update public.mi_shipment_intel
           set forwarder_canonical_id = r.primary_id
         where forwarder_canonical_id = r.secondary_id;
      when 'CARRIER' then
        update public.mi_shipment_intel
           set carrier_canonical_id = r.primary_id
         where carrier_canonical_id = r.secondary_id;
    end case;

    -- 2. Move aliases (avoid unique conflict)
    insert into public.mi_actor_alias(canonical_id, alias_normalized, alias_raw, source_field)
    select r.primary_id, alias_normalized, alias_raw, source_field
      from public.mi_actor_alias
     where canonical_id = r.secondary_id
    on conflict (canonical_id, alias_normalized) do nothing;

    -- 3. Delete secondary canonical (cascade clears its aliases)
    delete from public.mi_canonical_actor where id = r.secondary_id;

    v_merged := v_merged + 1;
  end loop;

  select count(*) into v_kept from public.mi_canonical_actor where actor_type = p_actor_type;
  merged_count := v_merged;
  kept_count := v_kept;
  return next;
end $function$;

CREATE OR REPLACE FUNCTION public.mi_foreign_agent_detail(partner_id uuid, lim integer DEFAULT 50)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE
AS $function$
DECLARE
  result jsonb;
BEGIN
  WITH base AS (
    SELECT
      i.client_id, i.ec_company_id, i.ec_company_name,
      i.forwarder_canonical_id, i.port_ec,
      i.teus_fcl, i.kilos_brutos,
      fcc.canonical_name AS forwarder_name,
      COALESCE(fcc.is_gloval, false) AS forwarder_is_gloval,
      cl.company_name AS crm_client_name,
      cl.assigned_to  AS crm_assigned_to,
      cl.office       AS crm_office
    FROM mi_shipment_intel i
    LEFT JOIN mi_canonical_actor fcc ON fcc.id = i.forwarder_canonical_id
    LEFT JOIN clients cl             ON cl.id = i.client_id
    WHERE i.partner_canonical_id = partner_id
      AND mi_is_real_cargo(i.producto_pmc)
  ),
  clients_top AS (
    SELECT
      COALESCE(client_id::text, ec_company_id) AS counter_id,
      max(ec_company_id) AS ec_company_id,
      max(coalesce(crm_client_name, ec_company_name)) AS counter_name,
      bool_or(client_id IS NOT NULL) AS in_crm,
      max(crm_assigned_to::text)     AS crm_assigned_to,
      max(crm_office)                AS crm_office,
      count(*) AS bls,
      sum(COALESCE(teus_fcl, 0)) AS teus_fcl
    FROM base
    WHERE COALESCE(client_id::text, ec_company_id) IS NOT NULL
    GROUP BY COALESCE(client_id::text, ec_company_id)
    ORDER BY teus_fcl DESC NULLS LAST, bls DESC
    LIMIT lim
  ),
  forwarders_top AS (
    SELECT
      forwarder_canonical_id,
      max(forwarder_name) AS name,
      bool_or(forwarder_is_gloval) AS is_gloval,
      count(*) AS bls,
      sum(COALESCE(teus_fcl, 0)) AS teus_fcl
    FROM base
    WHERE forwarder_canonical_id IS NOT NULL
    GROUP BY forwarder_canonical_id
    ORDER BY teus_fcl DESC NULLS LAST, bls DESC
    LIMIT lim
  )
  SELECT jsonb_build_object(
    'clients',    (SELECT coalesce(jsonb_agg(to_jsonb(c)), '[]'::jsonb) FROM clients_top c),
    'forwarders', (SELECT coalesce(jsonb_agg(to_jsonb(f)), '[]'::jsonb) FROM forwarders_top f)
  ) INTO result;

  RETURN result;
END;
$function$;

CREATE OR REPLACE FUNCTION public.mi_forwarder_detail(p_forwarder uuid, p_year integer, p_quarter integer DEFAULT NULL::integer, p_modality text DEFAULT NULL::text, p_countries text[] DEFAULT NULL::text[], p_ports text[] DEFAULT NULL::text[], p_carrier text DEFAULT NULL::text, p_partner text DEFAULT NULL::text, p_metric text DEFAULT 'teus'::text, p_lim integer DEFAULT 100)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  result jsonb;
  kilos_metric boolean := (p_metric = 'kilos');
  me_id uuid; me_role text; me_office text;
  v_all boolean;
  v_unassigned boolean;
  v_clients uuid[];
  nil constant uuid := '00000000-0000-0000-0000-000000000000';
BEGIN
  -- Visibilidad = la EFECTIVA de mi_shipment_intel (OR de sus 2 políticas permisivas).
  SELECT u.id, u.role, u.office INTO me_id, me_role, me_office
  FROM users u WHERE u.auth_user_id = auth.uid() LIMIT 1;
  IF me_id IS NULL THEN
    RETURN jsonb_build_object('error', 'no autorizado');
  END IF;
  v_all        := me_role IN ('Admin', 'Manager', 'VP', 'Administration');
  v_unassigned := me_role IN ('Sales Executive', 'Support', 'Customer Service') AND me_office = 'Ecuador';
  IF NOT v_all THEN
    -- deleted_at: dentro de mi_intel_select rige la RLS de clients (clientes en la
    -- Papelera no se ven), así que sus embarques tampoco.
    SELECT array_agg(c.id) INTO v_clients
    FROM clients c
    WHERE c.deleted_at IS NULL AND c.office = me_office AND (
         (me_role IN ('Sales Executive', 'Support') AND c.assigned_to = me_id)
      OR (me_role = 'Customer Service' AND EXISTS (
            SELECT 1 FROM cs_assignments csa
            WHERE csa.cs_user_id = me_id AND csa.sales_executive_id = c.assigned_to AND csa.active))
    );
  END IF;

  WITH raw AS MATERIALIZED (
    SELECT * FROM mi_mv_forwarder_detail m
    WHERE m.forwarder_canonical_id = p_forwarder
      AND m.period_year = p_year
      AND (p_quarter  IS NULL OR m.period_quarter = p_quarter)
      AND (p_modality IS NULL OR m.modality = p_modality)
  ),
  -- Cliente EFECTIVO de cada (empresa, client_id del MV), resuelto en vivo: el MV se
  -- refresca 1 vez por día, pero mi_shipment_intel.client_id cambia al instante:
  --  * tg_clients_backfill_intel_matches asigna las filas sin cliente al crear un
  --    cliente con ese RUC (normalizado, >= 10 dígitos) → se emula por RUC;
  --  * el FK ON DELETE SET NULL las libera si el cliente se borra físicamente.
  -- Solo hace falta para quien no tiene visibilidad total.
  pairs AS (
    SELECT DISTINCT ec_company_id, client_id FROM raw WHERE NOT v_all
  ),
  cl_by_ruc AS (
    SELECT DISTINCT ON (ruc_norm) ruc_norm, id FROM (
      SELECT c.id, c.created_at, nullif(regexp_replace(coalesce(c.ruc, ''), '\D', '', 'g'), '') AS ruc_norm
      FROM clients c WHERE NOT v_all
    ) x
    WHERE length(ruc_norm) >= 10
    ORDER BY ruc_norm, created_at, id
  ),
  eff AS (
    SELECT p.ec_company_id, p.client_id AS mv_client_id,
           CASE WHEN p.client_id IS NOT NULL THEN live.id ELSE byruc.id END AS client_id
    FROM pairs p
    LEFT JOIN clients live ON live.id = p.client_id
    LEFT JOIN cl_by_ruc byruc
           ON p.client_id IS NULL
          AND byruc.ruc_norm = nullif(regexp_replace(coalesce(p.ec_company_id, ''), '\D', '', 'g'), '')
  ),
  base AS MATERIALIZED (
    SELECT r.* FROM raw r WHERE v_all
    UNION ALL
    SELECT r.* FROM raw r
    JOIN eff e ON coalesce(e.ec_company_id, '') = coalesce(r.ec_company_id, '')
              AND coalesce(e.mv_client_id, nil) = coalesce(r.client_id, nil)
    WHERE NOT v_all
      AND ((e.client_id IS NULL AND v_unassigned) OR e.client_id = ANY(v_clients))
  ),
  f AS MATERIALIZED (
    SELECT * FROM base
    WHERE (p_countries IS NULL OR country = ANY(p_countries))
      AND (p_ports     IS NULL OR port    = ANY(p_ports))
      AND (p_carrier   IS NULL OR carrier_name = p_carrier)
      AND (p_partner   IS NULL OR partner_name = p_partner)
  ),
  -- Opciones facetadas: cada lista ignora SU propio filtro pero respeta los demás
  country_opts AS (
    SELECT country, sum(bls) AS bls FROM base
    WHERE country IS NOT NULL
      AND (p_ports   IS NULL OR port = ANY(p_ports))
      AND (p_carrier IS NULL OR carrier_name = p_carrier)
      AND (p_partner IS NULL OR partner_name = p_partner)
    GROUP BY country
  ),
  -- Un mismo puerto puede figurar con varios países (AMSTERDAM aparece con 6):
  -- se devuelven todos, del más al menos frecuente.
  port_country AS (
    SELECT port, country, sum(bls) AS bls FROM base
    WHERE port IS NOT NULL
      AND (p_countries IS NULL OR country = ANY(p_countries))
      AND (p_carrier   IS NULL OR carrier_name = p_carrier)
      AND (p_partner   IS NULL OR partner_name = p_partner)
    GROUP BY port, country
  ),
  port_opts AS (
    SELECT port,
           COALESCE(array_agg(country ORDER BY bls DESC, country) FILTER (WHERE country IS NOT NULL), '{}') AS countries,
           sum(bls) AS bls
    FROM port_country GROUP BY port
  ),
  cli AS (
    SELECT ec_company_id,
           max(ec_company_name) AS ec_company_name,
           max(ec_provincia)    AS ec_provincia,
           max(ec_vertical)     AS ec_vertical,
           sum(bls) AS bls, sum(teus) AS teus, sum(kilos) AS kilos
    FROM f WHERE ec_company_id IS NOT NULL
    GROUP BY ec_company_id
  ),
  top_cli AS (
    SELECT * FROM cli
    ORDER BY CASE WHEN kilos_metric THEN kilos ELSE teus END DESC, bls DESC
    LIMIT p_lim
  ),
  cli_country AS (
    SELECT DISTINCT ON (f.ec_company_id) f.ec_company_id, f.country
    FROM f JOIN top_cli t USING (ec_company_id)
    WHERE f.country IS NOT NULL
    GROUP BY f.ec_company_id, f.country
    ORDER BY f.ec_company_id, sum(f.bls) DESC, f.country
  ),
  cli_carrier AS (
    SELECT DISTINCT ON (f.ec_company_id) f.ec_company_id, f.carrier_name
    FROM f JOIN top_cli t USING (ec_company_id)
    WHERE f.carrier_name IS NOT NULL
    GROUP BY f.ec_company_id, f.carrier_name
    ORDER BY f.ec_company_id, sum(f.bls) DESC, f.carrier_name
  ),
  cli_port AS (
    SELECT DISTINCT ON (f.ec_company_id) f.ec_company_id, f.port
    FROM f JOIN top_cli t USING (ec_company_id)
    WHERE f.port IS NOT NULL
    GROUP BY f.ec_company_id, f.port
    ORDER BY f.ec_company_id, sum(f.bls) DESC, f.port
  )
  SELECT jsonb_build_object(
    'forwarder', (SELECT jsonb_build_object('canonical_name', a.canonical_name, 'is_gloval', COALESCE(a.is_gloval, false))
                  FROM mi_canonical_actor a WHERE a.id = p_forwarder),
    'totals', (SELECT jsonb_build_object(
                 'bls', COALESCE(sum(bls),0), 'teus', COALESCE(sum(teus),0), 'kilos', COALESCE(sum(kilos),0),
                 'valor', COALESCE(sum(valor),0),
                 'clients',   count(DISTINCT ec_company_id),
                 'countries', count(DISTINCT country),
                 'carriers',  count(DISTINCT carrier_name))
               FROM f),
    'by_month', COALESCE((SELECT jsonb_agg(jsonb_build_object('month', period_month, 'teus', teus, 'kilos', kilos) ORDER BY period_month)
                 FROM (SELECT period_month, sum(teus) teus, sum(kilos) kilos FROM f GROUP BY period_month) m), '[]'::jsonb),
    'top_clients', COALESCE((SELECT jsonb_agg(jsonb_build_object(
                     'ec_company_id', t.ec_company_id, 'ec_company_name', t.ec_company_name,
                     'ec_provincia', t.ec_provincia, 'ec_vertical', t.ec_vertical,
                     'bls', t.bls, 'teus', t.teus, 'kilos', t.kilos,
                     'top_country', cc.country, 'top_carrier', cr.carrier_name, 'top_port', cp.port)
                     ORDER BY CASE WHEN kilos_metric THEN t.kilos ELSE t.teus END DESC, t.bls DESC)
                   FROM top_cli t
                   LEFT JOIN cli_country cc USING (ec_company_id)
                   LEFT JOIN cli_carrier cr USING (ec_company_id)
                   LEFT JOIN cli_port    cp USING (ec_company_id)), '[]'::jsonb),
    'by_country', COALESCE((SELECT jsonb_agg(to_jsonb(x) ORDER BY CASE WHEN kilos_metric THEN x.kilos ELSE x.teus END DESC, x.bls DESC) FROM (
                    SELECT country AS key, sum(bls) bls, sum(teus) teus, sum(kilos) kilos, count(DISTINCT ec_company_id) clients
                    FROM f WHERE country IS NOT NULL GROUP BY country
                    ORDER BY CASE WHEN kilos_metric THEN sum(kilos) ELSE sum(teus) END DESC, sum(bls) DESC LIMIT 20) x), '[]'::jsonb),
    'by_port', COALESCE((SELECT jsonb_agg(to_jsonb(x) ORDER BY CASE WHEN kilos_metric THEN x.kilos ELSE x.teus END DESC, x.bls DESC) FROM (
                    SELECT port AS key, sum(bls) bls, sum(teus) teus, sum(kilos) kilos, count(DISTINCT ec_company_id) clients
                    FROM f WHERE port IS NOT NULL GROUP BY port
                    ORDER BY CASE WHEN kilos_metric THEN sum(kilos) ELSE sum(teus) END DESC, sum(bls) DESC LIMIT 20) x), '[]'::jsonb),
    'by_carrier', COALESCE((SELECT jsonb_agg(to_jsonb(x) ORDER BY CASE WHEN kilos_metric THEN x.kilos ELSE x.teus END DESC, x.bls DESC) FROM (
                    SELECT carrier_name AS key, sum(bls) bls, sum(teus) teus, sum(kilos) kilos, count(DISTINCT ec_company_id) clients
                    FROM f WHERE carrier_name IS NOT NULL GROUP BY carrier_name
                    ORDER BY CASE WHEN kilos_metric THEN sum(kilos) ELSE sum(teus) END DESC, sum(bls) DESC LIMIT 20) x), '[]'::jsonb),
    'by_partner', COALESCE((SELECT jsonb_agg(to_jsonb(x) ORDER BY CASE WHEN kilos_metric THEN x.kilos ELSE x.teus END DESC, x.bls DESC) FROM (
                    SELECT partner_name AS key, sum(bls) bls, sum(teus) teus, sum(kilos) kilos, count(DISTINCT ec_company_id) clients
                    FROM f WHERE partner_name IS NOT NULL GROUP BY partner_name
                    ORDER BY CASE WHEN kilos_metric THEN sum(kilos) ELSE sum(teus) END DESC, sum(bls) DESC LIMIT 20) x), '[]'::jsonb),
    'by_modality', COALESCE((SELECT jsonb_agg(to_jsonb(x) ORDER BY CASE WHEN kilos_metric THEN x.kilos ELSE x.teus END DESC, x.bls DESC) FROM (
                    SELECT modality AS key, sum(bls) bls, sum(teus) teus, sum(kilos) kilos, count(DISTINCT ec_company_id) clients
                    FROM f GROUP BY modality) x), '[]'::jsonb),
    'country_options', COALESCE((SELECT jsonb_agg(jsonb_build_object('country', country, 'bls', bls) ORDER BY bls DESC) FROM country_opts), '[]'::jsonb),
    'port_options',    COALESCE((SELECT jsonb_agg(jsonb_build_object('port', port, 'countries', to_jsonb(countries), 'bls', bls) ORDER BY bls DESC) FROM port_opts), '[]'::jsonb)
  ) INTO result;
  RETURN result;
END;
$function$;

CREATE OR REPLACE FUNCTION public.mi_forwarder_geo_options(p_year integer)
 RETURNS jsonb
 LANGUAGE sql
 STABLE
AS $function$
  SELECT jsonb_build_object(
    'countries', (
      SELECT coalesce(jsonb_agg(jsonb_build_object('country', c, 'region', r) ORDER BY c), '[]'::jsonb)
      FROM (
        SELECT origin_country AS c, mode() WITHIN GROUP (ORDER BY origin_region) AS r
        FROM mi_mv_forwarder_share_geo
        WHERE period_year = p_year AND origin_country IS NOT NULL
        GROUP BY origin_country
      ) t
    ),
    'regions', (
      SELECT coalesce(jsonb_agg(DISTINCT origin_region ORDER BY origin_region), '[]'::jsonb)
      FROM mi_mv_forwarder_share_geo
      WHERE period_year = p_year AND origin_region IS NOT NULL
    )
  );
$function$;

CREATE OR REPLACE FUNCTION public.mi_import_bi(p_year integer, p_filters jsonb DEFAULT '{}'::jsonb, p_lim integer DEFAULT 100)
 RETURNS jsonb
 LANGUAGE sql
 STABLE
AS $function$
WITH f AS (
  SELECT
    coalesce(p_filters->>'importador','')   AS importador,
    coalesce(p_filters->>'producto','')     AS producto,
    coalesce(p_filters->>'despacho','')      AS despacho,
    coalesce(p_filters->>'liberador','')     AS liberador,
    coalesce(p_filters->>'carrier','')       AS carrier,
    coalesce(p_filters->>'provincia','')     AS provincia,
    coalesce(p_filters->>'canton','')        AS canton,
    coalesce(p_filters->>'port_ec','')       AS port_ec,
    coalesce(p_filters->>'port_embarque','') AS port_embarque,
    coalesce(p_filters->>'pais_region','')   AS pais_region,
    coalesce(p_filters->>'responsable','')   AS responsable,
    CASE WHEN p_filters ? 'months' AND jsonb_array_length(p_filters->'months') > 0
         THEN ARRAY(SELECT jsonb_array_elements_text(p_filters->'months'))::int[] END AS months
),
b AS MATERIALIZED (
  SELECT v.y, v.oper, v.incoterm, v.region, v.ec_company_id, v.ec_company_name,
    v.producto, v.liberador, v.carrier, v.pais, v.teus, v.kilos, v.c20, v.c40
  FROM mi_mv_import_base v, f
  WHERE v.y IN (p_year, p_year-1)
    AND (f.importador='' OR v.ec_company_id = f.importador)
    AND (f.producto='' OR v.producto = f.producto)
    AND (f.despacho='' OR v.oper = f.despacho)
    AND (f.liberador='' OR v.liberador = f.liberador)
    AND (f.carrier='' OR v.carrier = f.carrier)
    AND (f.provincia='' OR v.provincia = f.provincia)
    AND (f.canton='' OR v.canton = f.canton)
    AND (f.port_ec='' OR v.port_ec = f.port_ec)
    AND (f.port_embarque='' OR v.port_embarque = f.port_embarque)
    AND (f.pais_region='' OR v.pais = f.pais_region OR v.region = f.pais_region)
    AND (f.responsable='' OR (f.responsable='DIRECTO' AND v.is_direct) OR (f.responsable='AGENCIA' AND NOT v.is_direct))
    AND (f.months IS NULL OR v.m = ANY(f.months))
),
tot AS (
  SELECT jsonb_build_object(
    'cur', jsonb_build_object('shpt',count(*) FILTER (WHERE y=p_year),'teus',round(sum(teus) FILTER (WHERE y=p_year))::int,'ton',round(sum(kilos) FILTER (WHERE y=p_year)/1000)::numeric(14,1),'cont20',round(sum(c20) FILTER (WHERE y=p_year))::int,'cont40',round(sum(c40) FILTER (WHERE y=p_year))::int),
    'prev',jsonb_build_object('shpt',count(*) FILTER (WHERE y=p_year-1),'teus',round(sum(teus) FILTER (WHERE y=p_year-1))::int,'ton',round(sum(kilos) FILTER (WHERE y=p_year-1)/1000)::numeric(14,1),'cont20',round(sum(c20) FILTER (WHERE y=p_year-1))::int,'cont40',round(sum(c40) FILTER (WHERE y=p_year-1))::int)
  ) j FROM b
),
g_imp AS (
  SELECT ec_company_id id, max(ec_company_name) nm,
    count(*) FILTER(WHERE y=p_year) sc, count(*) FILTER(WHERE y=p_year-1) sp,
    round(sum(teus) FILTER(WHERE y=p_year))::int tc, round(sum(teus) FILTER(WHERE y=p_year-1))::int tp,
    round(sum(kilos) FILTER(WHERE y=p_year)/1000)::numeric(14,2) nc, round(sum(kilos) FILTER(WHERE y=p_year-1)/1000)::numeric(14,2) np
  FROM b GROUP BY ec_company_id
),
g_prod AS (SELECT producto k, count(*) FILTER(WHERE y=p_year) sc, count(*) FILTER(WHERE y=p_year-1) sp, round(sum(teus) FILTER(WHERE y=p_year))::int tc, round(sum(teus) FILTER(WHERE y=p_year-1))::int tp, round(sum(kilos) FILTER(WHERE y=p_year)/1000)::numeric(14,2) nc, round(sum(kilos) FILTER(WHERE y=p_year-1)/1000)::numeric(14,2) np FROM b GROUP BY producto),
g_lib  AS (SELECT liberador k, count(*) FILTER(WHERE y=p_year) sc, count(*) FILTER(WHERE y=p_year-1) sp, round(sum(teus) FILTER(WHERE y=p_year))::int tc, round(sum(teus) FILTER(WHERE y=p_year-1))::int tp, round(sum(kilos) FILTER(WHERE y=p_year)/1000)::numeric(14,2) nc, round(sum(kilos) FILTER(WHERE y=p_year-1)/1000)::numeric(14,2) np FROM b GROUP BY liberador),
g_car  AS (SELECT carrier k, count(*) FILTER(WHERE y=p_year) sc, count(*) FILTER(WHERE y=p_year-1) sp, round(sum(teus) FILTER(WHERE y=p_year))::int tc, round(sum(teus) FILTER(WHERE y=p_year-1))::int tp, round(sum(kilos) FILTER(WHERE y=p_year)/1000)::numeric(14,2) nc, round(sum(kilos) FILTER(WHERE y=p_year-1)/1000)::numeric(14,2) np FROM b GROUP BY carrier),
g_pais AS (SELECT pais k, count(*) FILTER(WHERE y=p_year) sc, count(*) FILTER(WHERE y=p_year-1) sp, round(sum(teus) FILTER(WHERE y=p_year))::int tc, round(sum(teus) FILTER(WHERE y=p_year-1))::int tp, round(sum(kilos) FILTER(WHERE y=p_year)/1000)::numeric(14,2) nc, round(sum(kilos) FILTER(WHERE y=p_year-1)/1000)::numeric(14,2) np FROM b GROUP BY pais)
SELECT jsonb_build_object(
  'year', p_year,
  'totals', (SELECT j FROM tot),
  'operacion', (SELECT coalesce(jsonb_agg(x ORDER BY (x->>'shpt_c')::int DESC),'[]') FROM (
     SELECT jsonb_build_object('k',oper,'shpt_c',count(*) FILTER(WHERE y=p_year),'shpt_p',count(*) FILTER(WHERE y=p_year-1),
       'teus_c',round(sum(teus) FILTER(WHERE y=p_year))::int,'teus_p',round(sum(teus) FILTER(WHERE y=p_year-1))::int,
       'ton_c',round(sum(kilos) FILTER(WHERE y=p_year)/1000)::numeric(14,2),'ton_p',round(sum(kilos) FILTER(WHERE y=p_year-1)/1000)::numeric(14,2)) x
     FROM b GROUP BY oper) q),
  'incoterm', (SELECT coalesce(jsonb_agg(x ORDER BY (x->>'shpt_c')::int DESC),'[]') FROM (
     SELECT jsonb_build_object('k',incoterm,'shpt_c',count(*) FILTER(WHERE y=p_year),'shpt_p',count(*) FILTER(WHERE y=p_year-1)) x
     FROM b GROUP BY incoterm) q),
  'region', (SELECT coalesce(jsonb_agg(x ORDER BY (x->>'teus_c')::int DESC),'[]') FROM (
     SELECT jsonb_build_object('k',region,'teus_c',round(sum(teus) FILTER(WHERE y=p_year))::int,'teus_p',round(sum(teus) FILTER(WHERE y=p_year-1))::int) x
     FROM b GROUP BY region) q),
  'importador', (SELECT coalesce(jsonb_agg(jsonb_build_object('id',id,'name',nm,'shpt_c',sc,'shpt_p',sp,'teus_c',tc,'teus_p',tp,'ton_c',nc,'ton_p',np) ORDER BY sc DESC, sp DESC),'[]')
     FROM (SELECT *, row_number() OVER (ORDER BY sc DESC NULLS LAST) rs, row_number() OVER (ORDER BY tc DESC NULLS LAST) rt, row_number() OVER (ORDER BY nc DESC NULLS LAST) rn FROM g_imp) z
     WHERE rs <= p_lim OR rt <= p_lim OR rn <= p_lim),
  'producto', (SELECT coalesce(jsonb_agg(jsonb_build_object('k',k,'shpt_c',sc,'shpt_p',sp,'teus_c',tc,'teus_p',tp,'ton_c',nc,'ton_p',np) ORDER BY sc DESC),'[]')
     FROM (SELECT *, row_number() OVER (ORDER BY sc DESC NULLS LAST) rs, row_number() OVER (ORDER BY tc DESC NULLS LAST) rt, row_number() OVER (ORDER BY nc DESC NULLS LAST) rn FROM g_prod) z
     WHERE rs <= p_lim OR rt <= p_lim OR rn <= p_lim),
  'liberador', (SELECT coalesce(jsonb_agg(jsonb_build_object('k',k,'shpt_c',sc,'shpt_p',sp,'teus_c',tc,'teus_p',tp,'ton_c',nc,'ton_p',np) ORDER BY sc DESC),'[]')
     FROM (SELECT *, row_number() OVER (ORDER BY sc DESC NULLS LAST) rs, row_number() OVER (ORDER BY tc DESC NULLS LAST) rt, row_number() OVER (ORDER BY nc DESC NULLS LAST) rn FROM g_lib) z
     WHERE rs <= p_lim OR rt <= p_lim OR rn <= p_lim),
  'carrier', (SELECT coalesce(jsonb_agg(jsonb_build_object('k',k,'shpt_c',sc,'shpt_p',sp,'teus_c',tc,'teus_p',tp,'ton_c',nc,'ton_p',np) ORDER BY sc DESC),'[]')
     FROM (SELECT *, row_number() OVER (ORDER BY sc DESC NULLS LAST) rs, row_number() OVER (ORDER BY tc DESC NULLS LAST) rt, row_number() OVER (ORDER BY nc DESC NULLS LAST) rn FROM g_car) z
     WHERE rs <= p_lim OR rt <= p_lim OR rn <= p_lim),
  'origin', (SELECT coalesce(jsonb_agg(jsonb_build_object('k',k,'shpt_c',sc,'shpt_p',sp,'teus_c',tc,'teus_p',tp,'ton_c',nc,'ton_p',np) ORDER BY sc DESC),'[]')
     FROM (SELECT *, row_number() OVER (ORDER BY sc DESC NULLS LAST) rs, row_number() OVER (ORDER BY tc DESC NULLS LAST) rt, row_number() OVER (ORDER BY nc DESC NULLS LAST) rn FROM g_pais) z
     WHERE rs <= p_lim OR rt <= p_lim OR rn <= p_lim)
);
$function$;

CREATE OR REPLACE FUNCTION public.mi_import_bi_filters(p_year integer)
 RETURNS jsonb
 LANGUAGE sql
 STABLE
AS $function$
WITH b AS (SELECT * FROM mi_mv_import_base WHERE y IN (p_year, p_year-1))
SELECT jsonb_build_object(
  'anios', (SELECT coalesce(jsonb_agg(DISTINCT y ORDER BY y DESC),'[]') FROM mi_mv_import_base),
  'meses', (SELECT coalesce(jsonb_agg(DISTINCT m ORDER BY m),'[]') FROM b WHERE y=p_year),
  'despachos', (SELECT coalesce(jsonb_agg(DISTINCT oper ORDER BY oper),'[]') FROM b),
  'productos', (SELECT coalesce(jsonb_agg(k ORDER BY k),'[]') FROM (SELECT DISTINCT producto k FROM b WHERE producto<>'(sin producto)') q),
  'provincias', (SELECT coalesce(jsonb_agg(DISTINCT provincia ORDER BY provincia),'[]') FROM b WHERE provincia IS NOT NULL),
  'cantones', (SELECT coalesce(jsonb_agg(jsonb_build_object('provincia',provincia,'canton',canton)),'[]') FROM (SELECT DISTINCT provincia, canton FROM b WHERE canton IS NOT NULL ORDER BY provincia, canton) q),
  'puertos_ec', (SELECT coalesce(jsonb_agg(DISTINCT port_ec ORDER BY port_ec),'[]') FROM b WHERE port_ec IS NOT NULL),
  'regiones', (SELECT coalesce(jsonb_agg(k ORDER BY k),'[]') FROM (SELECT DISTINCT region k FROM b WHERE region<>'(s/d)') q),
  'paises', (SELECT coalesce(jsonb_agg(k ORDER BY k),'[]') FROM (SELECT DISTINCT pais k FROM b WHERE pais<>'(s/d)') q),
  'puertos_embarque', (SELECT coalesce(jsonb_agg(k ORDER BY c DESC),'[]') FROM (SELECT port_embarque k, count(*) c FROM b WHERE port_embarque IS NOT NULL GROUP BY port_embarque ORDER BY count(*) DESC LIMIT 400) q),
  'liberadores', (SELECT coalesce(jsonb_agg(k ORDER BY c DESC),'[]') FROM (SELECT liberador k, count(*) c FROM b WHERE liberador<>'(s/d)' GROUP BY liberador ORDER BY count(*) DESC LIMIT 500) q),
  'transportes', (SELECT coalesce(jsonb_agg(k ORDER BY c DESC),'[]') FROM (SELECT carrier k, count(*) c FROM b WHERE carrier<>'(s/d)' GROUP BY carrier ORDER BY count(*) DESC LIMIT 400) q),
  'importadores', (SELECT coalesce(jsonb_agg(jsonb_build_object('id',ec_company_id,'name',nm) ORDER BY c DESC),'[]') FROM (
      SELECT ec_company_id, max(ec_company_name) nm, count(*) c FROM b
      WHERE ec_company_id IS NOT NULL AND ec_company_name NOT ILIKE 'ZZ %'
      GROUP BY ec_company_id ORDER BY count(*) DESC LIMIT 1500) q)
);
$function$;

CREATE OR REPLACE FUNCTION public.mi_lookalike_execs()
 RETURNS TABLE(exec_id uuid, client_n integer, teus integer)
 LANGUAGE sql
 STABLE
AS $function$
  SELECT assigned_to::uuid, count(*)::int, COALESCE(sum(teus),0)::int
  FROM mi_mv_company_profile
  WHERE in_crm AND assigned_to IS NOT NULL
    AND assigned_to ~ '^[0-9a-f-]{36}$'
  GROUP BY assigned_to
  HAVING count(*) >= 3
  ORDER BY count(*) DESC;
$function$;

CREATE OR REPLACE FUNCTION public.mi_lookalike_prospects(p_exec uuid, p_lim integer DEFAULT 60)
 RETURNS jsonb
 LANGUAGE sql
 STABLE
AS $function$
WITH mkt AS MATERIALIZED (
  SELECT counter_id, in_crm, assigned_to, vertical, countries, products, teus,
         name, ec_company_id, provincia, canton, bls, valor, bls_import, bls_export
  FROM mi_mv_company_profile
  WHERE teus > 0
    AND COALESCE(name,'') NOT ILIKE 'ZZ %'   -- placeholders (p.ej. "ZZ PERSONAS NATURALES")
),
docs AS (SELECT count(*)::numeric AS n FROM mkt),
-- verticales ZZ (sin categorizar) fuera del idf/peso, pero la empresa sigue siendo prospecto vía país/producto
vdf AS (SELECT vertical AS k, count(*)::numeric AS df FROM mkt WHERE vertical IS NOT NULL AND vertical NOT ILIKE 'ZZ%' GROUP BY vertical),
cdf AS (SELECT k, count(*)::numeric AS df FROM (SELECT DISTINCT counter_id, unnest(countries) k FROM mkt) x GROUP BY k),
pdf AS (SELECT k, count(*)::numeric AS df FROM (SELECT DISTINCT counter_id, unnest(products) k FROM mkt) x GROUP BY k),
ec AS MATERIALIZED (SELECT counter_id, vertical, countries, products, teus FROM mkt WHERE in_crm AND assigned_to = p_exec::text),
stat AS MATERIALIZED (SELECT count(*)::numeric AS n, COALESCE(percentile_cont(0.5) WITHIN GROUP (ORDER BY teus),0) AS med FROM ec),
vwi AS MATERIALIZED (
  SELECT v.vertical AS k, (count(*)::numeric/(SELECT n FROM stat)) * ln((SELECT n FROM docs)/GREATEST(d.df,1)) AS w
  FROM ec v JOIN vdf d ON d.k = v.vertical WHERE v.vertical IS NOT NULL GROUP BY v.vertical, d.df
),
cwi AS MATERIALIZED (
  SELECT s.k, (count(*)::numeric/(SELECT n FROM stat)) * ln((SELECT n FROM docs)/GREATEST(d.df,1)) AS w
  FROM (SELECT DISTINCT counter_id, unnest(countries) k FROM ec) s JOIN cdf d USING(k)
  WHERE s.k IS NOT NULL GROUP BY s.k, d.df
),
pwi AS MATERIALIZED (
  SELECT s.k, (count(*)::numeric/(SELECT n FROM stat)) * ln((SELECT n FROM docs)/GREATEST(d.df,1)) AS w
  FROM (SELECT DISTINCT counter_id, unnest(products) k FROM ec) s JOIN pdf d USING(k)
  WHERE s.k IS NOT NULL GROUP BY s.k, d.df
),
ck AS (SELECT COALESCE(array_agg(k),'{}') AS arr FROM cwi),
pk AS (SELECT COALESCE(array_agg(k),'{}') AS arr FROM pwi),
cand AS MATERIALIZED (
  SELECT
    cp.counter_id, cp.ec_company_id, cp.name, cp.vertical, cp.provincia, cp.canton,
    cp.teus, cp.bls, cp.valor, cp.bls_import, cp.bls_export,
    COALESCE((SELECT w FROM vwi v WHERE v.k = cp.vertical), 0)            AS vscore,
    COALESCE((SELECT sum(w) FROM cwi c WHERE c.k = ANY(cp.countries)), 0) AS cscore,
    COALESCE((SELECT sum(w) FROM pwi p WHERE p.k = ANY(cp.products)), 0)  AS pscore,
    (SELECT array_agg(c.k ORDER BY c.w DESC) FROM cwi c WHERE c.k = ANY(cp.countries)) AS mc,
    (SELECT array_agg(p.k ORDER BY p.w DESC) FROM pwi p WHERE p.k = ANY(cp.products))  AS mp
  FROM mkt cp
  WHERE NOT cp.in_crm
    AND (cp.vertical IN (SELECT k FROM vwi)
         OR cp.countries && (SELECT arr FROM ck)
         OR cp.products  && (SELECT arr FROM pk))
),
raw AS (
  SELECT *,
    (1.5*vscore + cscore + pscore)
    * CASE
        WHEN (SELECT med FROM stat) > 0
          THEN exp( -0.5 * power( ln(teus / (SELECT med FROM stat)) / ln(3), 2) )
        ELSE 1 END  AS rawsf
  FROM cand
  WHERE vscore > 0 OR cscore > 0 OR pscore > 0
),
mx AS (SELECT COALESCE(max(rawsf),0) AS m FROM raw),
scored AS (
  SELECT
    counter_id, ec_company_id, name, vertical, provincia, canton,
    teus, bls, valor, bls_import, bls_export,
    (vscore > 0) AS m_vertical,
    (mc)[1:4] AS match_countries,
    (mp)[1:4] AS match_products,
    CASE WHEN (SELECT m FROM mx) > 0 THEN round(100 * rawsf / (SELECT m FROM mx))::int ELSE 0 END AS score
  FROM raw
),
top AS (SELECT * FROM scored ORDER BY score DESC, teus DESC NULLS LAST LIMIT p_lim)
SELECT jsonb_build_object(
  'clients', COALESCE((SELECT jsonb_agg(to_jsonb(t) ORDER BY t.score DESC, t.teus DESC NULLS LAST) FROM top t), '[]'::jsonb),
  'fingerprint', jsonb_build_object(
    'client_n', (SELECT n FROM stat)::int,
    'teus_med', round((SELECT med FROM stat))::int,
    'verticals', COALESCE((SELECT jsonb_agg(k ORDER BY w DESC) FROM vwi), '[]'::jsonb),
    'countries', COALESCE((SELECT jsonb_agg(k ORDER BY w DESC) FROM cwi), '[]'::jsonb),
    'products',  COALESCE((SELECT jsonb_agg(k ORDER BY w DESC) FROM pwi), '[]'::jsonb),
    'top_verticals', COALESCE((SELECT jsonb_agg(k ORDER BY w DESC) FROM (SELECT k,w FROM vwi ORDER BY w DESC LIMIT 5) q), '[]'::jsonb),
    'top_countries', COALESCE((SELECT jsonb_agg(k ORDER BY w DESC) FROM (SELECT k,w FROM cwi ORDER BY w DESC LIMIT 5) q), '[]'::jsonb),
    'top_products',  COALESCE((SELECT jsonb_agg(k ORDER BY w DESC) FROM (SELECT k,w FROM pwi ORDER BY w DESC LIMIT 5) q), '[]'::jsonb)
  )
);
$function$;

CREATE OR REPLACE FUNCTION public.mi_match_clients_to_intel(p_period_year integer DEFAULT NULL::integer, p_period_month integer DEFAULT NULL::integer, p_modality mi_modality_t DEFAULT NULL::mi_modality_t, p_office text DEFAULT 'Ecuador'::text, p_auto_cutoff numeric DEFAULT 0.85)
 RETURNS TABLE(rows_processed integer, rows_matched_ruc integer, rows_matched_fuzzy_auto integer, rows_pushed_to_review integer, rows_unmatched integer)
 LANGUAGE plpgsql
 SET search_path TO 'public', 'extensions', 'pg_catalog'
 SET statement_timeout TO '15min'
AS $function$
declare
  v_total int := 0; v_ruc int := 0; v_fuzzy_auto int := 0;
  v_review int := 0; v_unmatched int := 0;
  r record; m record;
  v_batch  constant int := 50000;   -- lote acotado por corrida
  v_offices text[];
  v_off text;
  v_done boolean;
begin
  -- p_office NULL => probar las 4 oficinas por fila (para poder marcar la fila
  -- como intentada sin perder oportunidades de match)
  if p_office is null then
    v_offices := array['Ecuador','USA','Panama','Peru'];
  else
    v_offices := array[p_office];
  end if;

  for r in
    select i.id, i.ec_company_id, i.ec_company_name, i.teus_fcl, i.kilos_brutos
      from public.mi_shipment_intel i
     where i.client_id is null
       and (i.match_attempted_at is null
            or i.match_attempted_at < now() - interval '30 days')
       and (p_period_year  is null or i.period_year  = p_period_year)
       and (p_period_month is null or i.period_month = p_period_month)
       and (p_modality     is null or i.modality     = p_modality)
       and i.ec_company_id is not null
     order by i.match_attempted_at nulls first
     limit v_batch
  loop
    v_total := v_total + 1;
    v_done := false;

    foreach v_off in array v_offices loop
      select * into m from public.mi_match_client(r.ec_company_id, r.ec_company_name, v_off);
      if m.client_id is null then
        continue;
      end if;

      if m.method = 'RUC_EXACT' or m.confidence >= p_auto_cutoff then
        update public.mi_shipment_intel
           set client_id = m.client_id, match_method = m.method,
               match_confidence = m.confidence, matched_at = now()
         where id = r.id;
        if m.method = 'RUC_EXACT' then v_ruc := v_ruc + 1;
        else v_fuzzy_auto := v_fuzzy_auto + 1; end if;
      else
        insert into public.mi_match_review_queue(
          ec_company_id, ec_company_name, ec_company_name_norm,
          suggested_client_id, match_method, match_confidence,
          occurrences, total_teus_fcl, total_kilos
        ) values (
          r.ec_company_id, r.ec_company_name,
          public.normalize_company_name(r.ec_company_name),
          m.client_id, m.method, m.confidence,
          1, coalesce(r.teus_fcl,0), coalesce(r.kilos_brutos,0)
        )
        on conflict (ec_company_id, suggested_client_id, match_method) do update set
          occurrences = public.mi_match_review_queue.occurrences + 1,
          total_teus_fcl = public.mi_match_review_queue.total_teus_fcl + coalesce(r.teus_fcl,0),
          total_kilos = public.mi_match_review_queue.total_kilos + coalesce(r.kilos_brutos,0),
          match_confidence = greatest(public.mi_match_review_queue.match_confidence, m.confidence),
          updated_at = now();
        v_review := v_review + 1;
      end if;

      v_done := true;
      exit;  -- ya resuelta: no probar mas oficinas
    end loop;

    if not v_done then
      v_unmatched := v_unmatched + 1;
    end if;

    -- marcar intento SIEMPRE (matcheada o no) para no reprocesarla manana
    update public.mi_shipment_intel
       set match_attempted_at = now()
     where id = r.id;
  end loop;

  rows_processed := v_total;
  rows_matched_ruc := v_ruc;
  rows_matched_fuzzy_auto := v_fuzzy_auto;
  rows_pushed_to_review := v_review;
  rows_unmatched := v_unmatched;
  return next;
end $function$;

CREATE OR REPLACE FUNCTION public.mi_product_clients(p_producto text, p_year integer DEFAULT NULL::integer, p_modality text DEFAULT NULL::text, p_flow text DEFAULT NULL::text, p_in_crm boolean DEFAULT NULL::boolean, p_lim integer DEFAULT 100)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE
AS $function$
DECLARE
  result jsonb;
BEGIN
  WITH filtered AS (
    SELECT *
    FROM mi_mv_product_client_fwd
    WHERE producto_generico = p_producto
      AND (p_year     IS NULL OR period_year = p_year)
      AND (p_modality IS NULL OR modality::text = p_modality)
      AND (p_flow     IS NULL
           OR (p_flow = 'import' AND modality IN ('SI','AI'))
           OR (p_flow = 'export' AND modality IN ('SE','AE')))
  ),
  client_tot AS (
    SELECT
      counter_id,
      max(ec_company_id)   AS ec_company_id,
      max(counter_name)    AS counter_name,
      bool_or(in_crm)      AS in_crm,
      max(crm_assigned_to) AS crm_assigned_to,
      max(crm_office)      AS crm_office,
      sum(bls)             AS bls,
      sum(teus_fcl)        AS teus_fcl,
      sum(kilos)           AS kilos,
      sum(valor_comercial) AS valor_comercial,
      sum(bls)      FILTER (WHERE forwarder_label = 'DIRECT') AS bls_direct,
      sum(teus_fcl) FILTER (WHERE forwarder_label = 'DIRECT') AS teus_direct,
      array_agg(DISTINCT modality::text ORDER BY modality::text) AS modalities
    FROM filtered
    GROUP BY counter_id
  ),
  fwd_agg AS (   -- re-suma por (cliente, forwarder) a través de modalidades
    SELECT counter_id, forwarder_label,
           bool_or(fwd_is_gloval) AS is_gloval,
           sum(bls)      AS fwd_bls,
           sum(teus_fcl) AS fwd_teus
    FROM filtered
    WHERE forwarder_label <> 'DIRECT'
    GROUP BY counter_id, forwarder_label
  ),
  top_fwd AS (   -- top forwarder no-directo por cliente
    SELECT DISTINCT ON (counter_id)
      counter_id,
      forwarder_label AS top_forwarder,
      is_gloval       AS top_forwarder_is_gloval,
      fwd_bls         AS top_forwarder_bls,
      fwd_teus        AS top_forwarder_teus
    FROM fwd_agg
    ORDER BY counter_id, fwd_bls DESC, fwd_teus DESC
  ),
  joined AS (
    SELECT
      ct.counter_id,
      ct.ec_company_id,
      ct.counter_name,
      ct.in_crm,
      ct.crm_assigned_to,
      ct.crm_office,
      ct.bls,
      ct.teus_fcl,
      ct.kilos,
      ct.valor_comercial,
      COALESCE(ct.bls_direct, 0)  AS bls_direct,
      COALESCE(ct.teus_direct, 0) AS teus_direct,
      CASE WHEN ct.bls > 0
           THEN round(COALESCE(ct.bls_direct,0)::numeric / ct.bls, 4)
           ELSE NULL END          AS direct_pct,
      tf.top_forwarder,
      tf.top_forwarder_is_gloval,
      tf.top_forwarder_bls,
      tf.top_forwarder_teus,
      ct.modalities
    FROM client_tot ct
    LEFT JOIN top_fwd tf USING (counter_id)
    WHERE (p_in_crm IS NULL
           OR (p_in_crm = TRUE  AND ct.in_crm = TRUE)
           OR (p_in_crm = FALSE AND ct.in_crm = FALSE))
    ORDER BY ct.teus_fcl DESC NULLS LAST, ct.bls DESC
    LIMIT p_lim
  )
  SELECT coalesce(jsonb_agg(to_jsonb(j)), '[]'::jsonb) INTO result FROM joined j;
  RETURN result;
END;
$function$;

CREATE OR REPLACE FUNCTION public.mi_product_keyword_clients(p_keyword text, p_year integer DEFAULT NULL::integer, p_modality text DEFAULT NULL::text, p_flow text DEFAULT NULL::text, p_in_crm boolean DEFAULT NULL::boolean, p_lim integer DEFAULT 100)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE
AS $function$
DECLARE
  kw     text := lower(trim(coalesce(p_keyword, '')));
  result jsonb;
BEGIN
  IF length(kw) < 3 THEN
    RETURN jsonb_build_object('clients','[]'::jsonb,'matched_products','[]'::jsonb,
                              'total_bls',0,'total_teus',0);
  END IF;

  WITH matched AS (
    SELECT
      COALESCE(i.client_id::text, i.ec_company_id) AS counter_id,
      i.ec_company_id, i.client_id, i.ec_company_name,
      i.modality, i.is_direct_no_forwarder,
      i.producto_generico, i.producto_pmc,
      i.teus_fcl, i.kilos_brutos, i.valor_comercial,
      cl.company_name AS crm_client_name, cl.assigned_to, cl.office,
      CASE WHEN i.is_direct_no_forwarder THEN 'DIRECT'
           ELSE COALESCE(fc.canonical_name,'(sin clasificar)') END AS forwarder_label,
      COALESCE(fc.is_gloval,false) AS fwd_is_gloval
    FROM mi_shipment_intel i
    LEFT JOIN clients cl            ON cl.id = i.client_id
    LEFT JOIN mi_canonical_actor fc ON fc.id = i.forwarder_canonical_id
    WHERE i.ec_company_id IS NOT NULL
      AND mi_is_real_cargo(i.producto_pmc)
      AND lower(coalesce(i.producto_pmc,'') || ' ' ||
                coalesce(i.producto_generico,'') || ' ' ||
                coalesce(i.descripcion_unidad,'') || ' ' ||
                coalesce(i.nombre_operacion,'')) LIKE '%'||kw||'%'
      AND (p_year     IS NULL OR i.period_year = p_year)
      AND (p_modality IS NULL OR i.modality::text = p_modality)
      AND (p_flow     IS NULL
           OR (p_flow='import' AND i.modality IN ('SI','AI'))
           OR (p_flow='export' AND i.modality IN ('SE','AE')))
  ),
  client_tot AS (
    SELECT counter_id,
      max(ec_company_id) AS ec_company_id,
      max(COALESCE(crm_client_name, ec_company_name)) AS counter_name,
      bool_or(client_id IS NOT NULL) AS in_crm,
      max(assigned_to::text) AS crm_assigned_to,
      max(office) AS crm_office,
      count(*) AS bls,
      sum(COALESCE(teus_fcl,0)) AS teus_fcl,
      sum(COALESCE(kilos_brutos,0)) AS kilos,
      sum(COALESCE(valor_comercial,0)) AS valor_comercial,
      count(*) FILTER (WHERE is_direct_no_forwarder) AS bls_direct,
      sum(COALESCE(teus_fcl,0)) FILTER (WHERE is_direct_no_forwarder) AS teus_direct,
      array_agg(DISTINCT modality::text ORDER BY modality::text) AS modalities
    FROM matched
    GROUP BY counter_id
  ),
  fwd_agg AS (
    SELECT counter_id, forwarder_label, bool_or(fwd_is_gloval) AS is_gloval,
           count(*) AS fwd_bls, sum(COALESCE(teus_fcl,0)) AS fwd_teus
    FROM matched
    WHERE forwarder_label <> 'DIRECT'
    GROUP BY counter_id, forwarder_label
  ),
  top_fwd AS (
    SELECT DISTINCT ON (counter_id) counter_id,
      forwarder_label AS top_forwarder, is_gloval AS top_forwarder_is_gloval,
      fwd_bls AS top_forwarder_bls, fwd_teus AS top_forwarder_teus
    FROM fwd_agg
    ORDER BY counter_id, fwd_bls DESC, fwd_teus DESC
  ),
  clients_json AS (
    SELECT jsonb_agg(to_jsonb(j) ORDER BY j.teus_fcl DESC NULLS LAST, j.bls DESC) AS arr
    FROM (
      SELECT ct.counter_id, ct.ec_company_id, ct.counter_name, ct.in_crm,
        ct.crm_assigned_to, ct.crm_office,
        ct.bls, ct.teus_fcl, ct.kilos, ct.valor_comercial,
        COALESCE(ct.bls_direct,0) AS bls_direct, COALESCE(ct.teus_direct,0) AS teus_direct,
        CASE WHEN ct.bls>0 THEN round(COALESCE(ct.bls_direct,0)::numeric/ct.bls,4) ELSE NULL END AS direct_pct,
        tf.top_forwarder, tf.top_forwarder_is_gloval, tf.top_forwarder_bls, tf.top_forwarder_teus,
        ct.modalities
      FROM client_tot ct
      LEFT JOIN top_fwd tf USING (counter_id)
      WHERE (p_in_crm IS NULL
             OR (p_in_crm=TRUE  AND ct.in_crm=TRUE)
             OR (p_in_crm=FALSE AND ct.in_crm=FALSE))
      ORDER BY ct.teus_fcl DESC NULLS LAST, ct.bls DESC
      LIMIT p_lim
    ) j
  ),
  prod_json AS (
    SELECT jsonb_agg(to_jsonb(p) ORDER BY p.bls DESC) AS arr
    FROM (
      SELECT COALESCE(producto_generico,'(sin clasificar)') AS producto_generico,
             producto_pmc, count(*) AS bls
      FROM matched
      GROUP BY 1, producto_pmc
      ORDER BY count(*) DESC
      LIMIT 15
    ) p
  ),
  meta AS (
    SELECT count(*) AS total_bls, sum(COALESCE(teus_fcl,0)) AS total_teus FROM matched
  )
  SELECT jsonb_build_object(
    'clients',          COALESCE((SELECT arr FROM clients_json), '[]'::jsonb),
    'matched_products', COALESCE((SELECT arr FROM prod_json), '[]'::jsonb),
    'total_bls',        (SELECT total_bls FROM meta),
    'total_teus',       (SELECT total_teus FROM meta)
  ) INTO result;
  RETURN result;
END;
$function$;

CREATE OR REPLACE FUNCTION public.mi_product_yoy(p_cur integer, p_prev integer DEFAULT NULL::integer, p_modality text DEFAULT NULL::text, p_flow text DEFAULT NULL::text, p_tipo text DEFAULT NULL::text, p_search text DEFAULT NULL::text, p_lim integer DEFAULT 500)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE
AS $function$
DECLARE
  prev int := COALESCE(p_prev, p_cur - 1);
  common_months int[];
  result jsonb;
BEGIN
  -- meses presentes en AMBOS años (dentro del scope de modalidad/flow)
  SELECT array_agg(m) INTO common_months FROM (
    SELECT period_month AS m FROM mi_mv_product_month
     WHERE period_year = p_cur
       AND (p_modality IS NULL OR modality::text = p_modality)
       AND (p_flow IS NULL OR (p_flow='import' AND modality IN ('SI','AI'))
                          OR (p_flow='export' AND modality IN ('SE','AE')))
    INTERSECT
    SELECT period_month FROM mi_mv_product_month
     WHERE period_year = prev
       AND (p_modality IS NULL OR modality::text = p_modality)
       AND (p_flow IS NULL OR (p_flow='import' AND modality IN ('SI','AI'))
                          OR (p_flow='export' AND modality IN ('SE','AE')))
  ) x;

  IF common_months IS NULL THEN
    RETURN jsonb_build_object('rows','[]'::jsonb,'common_months','[]'::jsonb,
                              'cur_year',p_cur,'prev_year',prev);
  END IF;

  WITH scoped AS (
    SELECT producto_generico, tipo_producto, period_year, bls, teus_fcl, kilos, valor
    FROM mi_mv_product_month
    WHERE period_month = ANY(common_months)
      AND period_year IN (p_cur, prev)
      AND (p_modality IS NULL OR modality::text = p_modality)
      AND (p_flow IS NULL OR (p_flow='import' AND modality IN ('SI','AI'))
                         OR (p_flow='export' AND modality IN ('SE','AE')))
  ),
  agg AS (
    SELECT producto_generico,
      COALESCE(mode() WITHIN GROUP (ORDER BY tipo_producto),'SIN CLASIFICAR') AS tipo_producto,
      sum(bls)      FILTER (WHERE period_year=p_cur)  AS bls_cur,
      sum(bls)      FILTER (WHERE period_year=prev)   AS bls_prev,
      sum(teus_fcl) FILTER (WHERE period_year=p_cur)  AS teus_cur,
      sum(teus_fcl) FILTER (WHERE period_year=prev)   AS teus_prev,
      sum(kilos)    FILTER (WHERE period_year=p_cur)  AS kilos_cur,
      sum(kilos)    FILTER (WHERE period_year=prev)   AS kilos_prev,
      sum(valor)    FILTER (WHERE period_year=p_cur)  AS valor_cur,
      sum(valor)    FILTER (WHERE period_year=prev)   AS valor_prev
    FROM scoped
    GROUP BY producto_generico
  )
  SELECT jsonb_build_object(
    'cur_year', p_cur, 'prev_year', prev,
    'common_months', to_jsonb(common_months),
    'rows', COALESCE((
      SELECT jsonb_agg(to_jsonb(r) ORDER BY r.teus_cur DESC NULLS LAST, r.bls_cur DESC NULLS LAST)
      FROM (
        SELECT producto_generico, tipo_producto,
          COALESCE(bls_cur,0) AS bls_cur, COALESCE(bls_prev,0) AS bls_prev,
          COALESCE(teus_cur,0) AS teus_cur, COALESCE(teus_prev,0) AS teus_prev,
          COALESCE(kilos_cur,0) AS kilos_cur, COALESCE(kilos_prev,0) AS kilos_prev,
          COALESCE(valor_cur,0) AS valor_cur, COALESCE(valor_prev,0) AS valor_prev,
          CASE WHEN COALESCE(teus_prev,0) > 0
               THEN round((COALESCE(teus_cur,0)-teus_prev)/teus_prev, 4) ELSE NULL END AS teus_dif_pct,
          CASE WHEN COALESCE(bls_prev,0) > 0
               THEN round((COALESCE(bls_cur,0)::numeric-bls_prev)/bls_prev, 4) ELSE NULL END AS bls_dif_pct
        FROM agg
        WHERE (p_tipo IS NULL OR tipo_producto = p_tipo)
          AND (p_search IS NULL OR producto_generico ILIKE '%'||p_search||'%')
          AND (COALESCE(teus_cur,0) > 0 OR COALESCE(teus_prev,0) > 0 OR COALESCE(bls_cur,0) > 0 OR COALESCE(bls_prev,0) > 0)
        ORDER BY teus_cur DESC NULLS LAST, bls_cur DESC NULLS LAST
        LIMIT p_lim
      ) r
    ), '[]'::jsonb)
  ) INTO result;
  RETURN result;
END;
$function$;

CREATE OR REPLACE FUNCTION public.mi_rebuild_mv(p_name text, p_def text)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET statement_timeout TO '15min'
 SET search_path TO 'public', 'extensions', 'pg_catalog'
AS $function$
begin
  execute format('drop materialized view if exists public.%I cascade', p_name);
  execute p_def;
  return 'ok: ' || p_name;
end $function$;

CREATE OR REPLACE FUNCTION public.mi_refresh_all_mvs()
 RETURNS void
 LANGUAGE plpgsql
 SET search_path TO 'public', 'extensions', 'pg_catalog'
 SET statement_timeout TO '15min'
AS $function$
declare mv_name text;
begin
  for mv_name in
    select n.nspname || '.' || c.relname
      from pg_class c join pg_namespace n on n.oid = c.relnamespace
     where c.relkind = 'm' and n.nspname = 'public' 
       and (c.relname like 'mi_mv_%' or c.relname like 'mi_v_%')
       and c.relname <> 'mi_mv_forwarder_detail'   -- refresco propio: mi_refresh_forwarder_detail()
     -- mi_mv_client_period_summary first (others depend on it via JOIN)
     order by case when c.relname='mi_mv_client_period_summary' then 0 else 1 end, c.relname
  loop
    begin
      execute format('refresh materialized view concurrently %s', mv_name);
    exception when others then
      execute format('refresh materialized view %s', mv_name);
    end;
  end loop;
end $function$;

CREATE OR REPLACE FUNCTION public.mi_refresh_forwarder_detail()
 RETURNS void
 LANGUAGE plpgsql
 SET search_path TO 'public', 'pg_catalog'
 SET statement_timeout TO '20min'
AS $function$
begin
  refresh materialized view concurrently public.mi_mv_forwarder_detail;
end $function$;

CREATE OR REPLACE FUNCTION public.mi_refresh_main_mv_extended()
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET statement_timeout TO '60min'
 SET search_path TO 'public', 'extensions', 'pg_catalog'
AS $function$
declare v_t0 timestamptz := clock_timestamp();
begin
  refresh materialized view concurrently public.mi_mv_client_period_summary;
  return 'ok-concurrent: ' || extract(epoch from clock_timestamp() - v_t0)::int || 's';
exception when others then
  refresh materialized view public.mi_mv_client_period_summary;
  return 'ok-non-concurrent: ' || extract(epoch from clock_timestamp() - v_t0)::int || 's';
end $function$;

CREATE OR REPLACE FUNCTION public.mi_refresh_one(p_mv text)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
  EXECUTE format('REFRESH MATERIALIZED VIEW %s', p_mv::regclass);
  RETURN 'ok:'||p_mv;
END $function$;

CREATE OR REPLACE FUNCTION public.mi_refresh_one_mv_extended(p_name text)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET statement_timeout TO '30min'
 SET search_path TO 'public', 'pg_catalog'
AS $function$
declare
  v_t0 timestamptz := clock_timestamp();
begin
  execute format('refresh materialized view public.%I', p_name);
  return 'ok: ' || p_name || ' in ' || extract(epoch from clock_timestamp() - v_t0)::int || 's';
end $function$;

CREATE OR REPLACE FUNCTION public.mi_resolve_actor(p_actor_type mi_actor_type_t, p_raw_name text, p_source_field text DEFAULT NULL::text)
 RETURNS uuid
 LANGUAGE plpgsql
 SET search_path TO 'public', 'extensions', 'pg_catalog'
AS $function$
declare
  v_norm  text;
  v_canon uuid;
begin
  if p_raw_name is null or btrim(p_raw_name) = '' then return null; end if;
  v_norm := public.normalize_company_name(p_raw_name);
  if v_norm is null or length(v_norm) = 0 then return null; end if;

  select aa.canonical_id into v_canon
    from public.mi_actor_alias aa
    join public.mi_canonical_actor ca on ca.id = aa.canonical_id
   where aa.alias_normalized = v_norm and ca.actor_type = p_actor_type
   order by ca.is_gloval desc nulls last, ca.created_at asc
   limit 1;
  if v_canon is not null then return v_canon; end if;

  insert into public.mi_canonical_actor(actor_type, canonical_name, auto_created)
  values (p_actor_type, btrim(p_raw_name), true)
  on conflict (actor_type, canonical_name) do update set updated_at = now()
  returning id into v_canon;

  insert into public.mi_actor_alias(canonical_id, alias_normalized, alias_raw, source_field)
  values (v_canon, v_norm, btrim(p_raw_name), p_source_field)
  on conflict (canonical_id, alias_normalized) do nothing;

  return v_canon;
end $function$;

CREATE OR REPLACE FUNCTION public.mi_resolve_forwarder(p_receptor text, p_liberador text)
 RETURNS TABLE(canonical_id uuid, roles_split boolean, is_direct boolean)
 LANGUAGE plpgsql
 SET search_path TO 'public', 'extensions', 'pg_catalog'
AS $function$
declare
  v_recep_norm text;
  v_liber_norm text;
  v_chosen     text;
  v_id         uuid;
  v_is_direct  boolean := false;
begin
  v_recep_norm := public.normalize_company_name(p_receptor);
  v_liber_norm := public.normalize_company_name(p_liberador);
  v_chosen := coalesce(nullif(btrim(p_liberador),''), nullif(btrim(p_receptor),''));
  if v_chosen is null then
    canonical_id := null; roles_split := false; is_direct := false;
    return next; return;
  end if;
  v_id := public.mi_resolve_actor('FORWARDER', v_chosen, 'POSIBLE_LIBERADOR_DOCUMENTO_DE_TRANSPORTE');
  if v_id is not null then
    select ca.is_direct_bucket into v_is_direct from public.mi_canonical_actor ca where ca.id = v_id;
  end if;
  canonical_id := v_id;
  roles_split  := (
    p_receptor  is not null and btrim(p_receptor)  <> '' and
    p_liberador is not null and btrim(p_liberador) <> '' and
    v_recep_norm is distinct from v_liber_norm
  );
  is_direct := coalesce(v_is_direct, false);
  return next;
end $function$;

CREATE OR REPLACE FUNCTION public.mi_route_cargo(p_origen text, p_destino text, p_year integer DEFAULT NULL::integer, p_modality text DEFAULT NULL::text, p_flow text DEFAULT NULL::text, p_lim integer DEFAULT 50, p_origin_ports text[] DEFAULT NULL::text[], p_container text DEFAULT NULL::text, p_provincia text DEFAULT NULL::text, p_canton text DEFAULT NULL::text, p_origenes text[] DEFAULT NULL::text[], p_destinos text[] DEFAULT NULL::text[])
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE
AS $function$
DECLARE
  o text := nullif(upper(trim(coalesce(p_origen,''))), '');
  d text := nullif(upper(trim(coalesce(p_destino,''))), '');
  oarr text[];
  darr text[];
  result jsonb;
BEGIN
  oarr := CASE
    WHEN p_origenes IS NOT NULL THEN
      (SELECT array_agg(u) FROM (SELECT DISTINCT nullif(upper(trim(x)),'') u FROM unnest(p_origenes) x) s WHERE u IS NOT NULL)
    WHEN o IS NOT NULL THEN ARRAY[o]
    ELSE NULL END;
  darr := CASE
    WHEN p_destinos IS NOT NULL THEN
      (SELECT array_agg(u) FROM (SELECT DISTINCT nullif(upper(trim(x)),'') u FROM unnest(p_destinos) x) s WHERE u IS NOT NULL)
    WHEN d IS NOT NULL THEN ARRAY[d]
    ELSE NULL END;

  IF oarr IS NULL AND darr IS NULL AND p_origin_ports IS NULL AND p_provincia IS NULL AND p_canton IS NULL THEN
    RETURN jsonb_build_object('error','indica al menos un puerto, provincia o cantón');
  END IF;

  WITH matched AS (
    SELECT
      COALESCE(i.client_id::text, i.ec_company_id) AS counter_id,
      i.ec_company_id, i.client_id, i.ec_company_name,
      i.ec_provincia, i.ec_canton,
      i.modality, i.is_direct_no_forwarder, i.producto_generico,
      i.teus_fcl, i.teus_lcl, i.kilos_brutos, i.valor_comercial,
      i.port_origin_destination,
      cl.company_name AS crm_client_name, cl.assigned_to, cl.office,
      fc.canonical_name AS fwd_name, COALESCE(fc.is_gloval,false) AS fwd_is_gloval,
      cc.canonical_name AS carrier_name
    FROM mi_shipment_intel i
    LEFT JOIN clients cl            ON cl.id = i.client_id
    LEFT JOIN mi_canonical_actor fc ON fc.id = i.forwarder_canonical_id
    LEFT JOIN mi_canonical_actor cc ON cc.id = i.carrier_canonical_id
    WHERE i.ec_company_id IS NOT NULL AND mi_is_real_cargo(i.producto_pmc)
      AND (p_year IS NULL OR i.period_year = p_year)
      AND (p_modality IS NULL OR i.modality::text = p_modality)
      AND (p_flow IS NULL OR (p_flow='import' AND i.modality IN ('SI','AI')) OR (p_flow='export' AND i.modality IN ('SE','AE')))
      AND (
        (i.modality IN ('SI','AI') AND (oarr IS NULL OR i.port_origin_destination = ANY(oarr)) AND (darr IS NULL OR i.port_ec = ANY(darr)))
        OR
        (i.modality IN ('SE','AE') AND (oarr IS NULL OR i.port_ec = ANY(oarr)) AND (darr IS NULL OR i.port_origin_destination = ANY(darr)))
      )
      AND (p_origin_ports IS NULL OR i.port_origin_destination = ANY(p_origin_ports))
      AND (p_provincia IS NULL OR i.ec_provincia = p_provincia)
      AND (p_canton    IS NULL OR i.ec_canton = p_canton)
      AND (p_container IS NULL
           OR (p_container='fcl' AND COALESCE(i.teus_fcl,0) > 0)
           OR (p_container='lcl' AND COALESCE(i.teus_lcl,0) > 0))
  ),
  totals AS (
    SELECT count(*) AS bls, sum(COALESCE(teus_fcl,0)) AS teus_fcl,
      sum(COALESCE(kilos_brutos,0)) AS kilos, sum(COALESCE(valor_comercial,0)) AS valor,
      count(DISTINCT counter_id) AS empresas,
      count(*) FILTER (WHERE fwd_is_gloval) AS bls_gloval,
      count(*) FILTER (WHERE is_direct_no_forwarder) AS bls_direct,
      count(*) FILTER (WHERE NOT fwd_is_gloval AND NOT is_direct_no_forwarder AND fwd_name IS NOT NULL) AS bls_competidor
    FROM matched
  ),
  per_fwd AS (
    SELECT counter_id,
      CASE WHEN is_direct_no_forwarder THEN '[Directo con naviera]'
           ELSE COALESCE(fwd_name, '(sin clasificar)') END AS fname,
      bool_or(COALESCE(fwd_is_gloval,false)) AS is_gloval,
      bool_or(is_direct_no_forwarder)        AS is_direct,
      count(*) AS bls
    FROM matched
    GROUP BY counter_id, 2
  ),
  client_fwd AS (
    SELECT counter_id,
      jsonb_agg(jsonb_build_object('name',fname,'is_gloval',is_gloval,'is_direct',is_direct,'bls',bls) ORDER BY bls DESC) AS forwarders
    FROM per_fwd
    GROUP BY counter_id
  ),
  client_tot AS (
    SELECT counter_id, max(ec_company_id) AS ec_company_id,
      max(COALESCE(crm_client_name, ec_company_name)) AS counter_name,
      bool_or(client_id IS NOT NULL) AS in_crm,
      max(assigned_to::text) AS crm_assigned_to, max(office) AS crm_office,
      max(ec_provincia) AS ec_provincia, max(ec_canton) AS ec_canton,
      count(*) AS bls,
      count(*) FILTER (WHERE COALESCE(teus_fcl,0)>0) AS bls_fcl,
      count(*) FILTER (WHERE COALESCE(teus_lcl,0)>0) AS bls_lcl,
      sum(COALESCE(teus_fcl,0)) AS teus_fcl, sum(COALESCE(teus_lcl,0)) AS teus_lcl,
      sum(COALESCE(kilos_brutos,0)) AS kilos, sum(COALESCE(valor_comercial,0)) AS valor_comercial,
      count(*) FILTER (WHERE is_direct_no_forwarder) AS bls_direct,
      count(*) FILTER (WHERE fwd_is_gloval) AS bls_gloval,
      array_agg(DISTINCT modality::text ORDER BY modality::text) AS modalities,
      (array_agg(DISTINCT port_origin_destination) FILTER (WHERE port_origin_destination IS NOT NULL))[1:5] AS origin_ports
    FROM matched GROUP BY counter_id
  ),
  clients_json AS (
    SELECT jsonb_agg(to_jsonb(j) ORDER BY (j.teus_fcl + j.teus_lcl) DESC NULLS LAST, j.bls DESC) AS arr FROM (
      SELECT ct.counter_id, ct.ec_company_id, ct.counter_name, ct.in_crm,
        ct.crm_assigned_to, ct.crm_office, ct.ec_provincia, ct.ec_canton,
        ct.bls, ct.bls_fcl, ct.bls_lcl, ct.teus_fcl, ct.teus_lcl, ct.kilos, ct.valor_comercial,
        ct.modalities, ct.origin_ports,
        CASE WHEN ct.bls>0 THEN round(ct.bls_direct::numeric/ct.bls,4) ELSE NULL END AS direct_pct,
        CASE WHEN ct.bls>0 THEN round(ct.bls_gloval::numeric/ct.bls,4) ELSE 0 END AS gloval_pct,
        COALESCE(cf.forwarders, '[]'::jsonb) AS forwarders,
        en.direccion_matriz
      FROM client_tot ct
      LEFT JOIN client_fwd cf ON cf.counter_id = ct.counter_id
      LEFT JOIN prospect_enrichment_ec en ON en.ruc = regexp_replace(ct.ec_company_id, '\D', '', 'g')
      ORDER BY (ct.teus_fcl + ct.teus_lcl) DESC NULLS LAST, ct.bls DESC LIMIT p_lim
    ) j
  ),
  fwd_json AS (
    SELECT jsonb_agg(to_jsonb(f) ORDER BY f.bls DESC) AS arr FROM (
      SELECT CASE WHEN is_direct_no_forwarder THEN '[Directo con naviera]'
                  ELSE COALESCE(fwd_name, '(sin clasificar)') END AS name,
             bool_or(fwd_is_gloval) AS is_gloval, count(*) AS bls, sum(COALESCE(teus_fcl,0)) AS teus
      FROM matched GROUP BY 1 ORDER BY count(*) DESC LIMIT 12
    ) f
  ),
  car_json AS (
    SELECT jsonb_agg(to_jsonb(c) ORDER BY c.bls DESC) AS arr FROM (
      SELECT COALESCE(carrier_name,'(sin clasificar)') AS name, count(*) AS bls, sum(COALESCE(teus_fcl,0)) AS teus
      FROM matched WHERE carrier_name IS NOT NULL GROUP BY carrier_name ORDER BY count(*) DESC LIMIT 12
    ) c
  ),
  prod_json AS (
    SELECT jsonb_agg(to_jsonb(p) ORDER BY p.bls DESC) AS arr FROM (
      SELECT COALESCE(producto_generico,'(sin clasificar)') AS name, count(*) AS bls, sum(COALESCE(teus_fcl,0)) AS teus
      FROM matched GROUP BY producto_generico ORDER BY count(*) DESC LIMIT 12
    ) p
  )
  SELECT jsonb_build_object(
    'totals',(SELECT to_jsonb(t) FROM totals t),
    'clients',COALESCE((SELECT arr FROM clients_json),'[]'::jsonb),
    'forwarders',COALESCE((SELECT arr FROM fwd_json),'[]'::jsonb),
    'carriers',COALESCE((SELECT arr FROM car_json),'[]'::jsonb),
    'products',COALESCE((SELECT arr FROM prod_json),'[]'::jsonb)
  ) INTO result;
  RETURN result;
END;
$function$;

CREATE OR REPLACE FUNCTION public.mi_route_filter_options(p_year integer DEFAULT NULL::integer, p_flow text DEFAULT 'import'::text)
 RETURNS jsonb
 LANGUAGE sql
 STABLE
AS $function$
  SELECT jsonb_build_object(
    'origin_ports', COALESCE((
      SELECT jsonb_agg(jsonb_build_object('port', port, 'bls', bls, 'country', country) ORDER BY bls DESC)
      FROM (
        SELECT port, max(country) AS country, sum(bls) AS bls
        FROM mi_mv_route_origin_ports
        WHERE (p_year IS NULL OR period_year = p_year)
          AND (p_flow IS NULL OR flow = p_flow)
        GROUP BY port
        HAVING sum(bls) >= 3
        ORDER BY sum(bls) DESC
        LIMIT 400
      ) p
    ), '[]'::jsonb),
    'provincias', COALESCE((
      SELECT jsonb_agg(DISTINCT provincia ORDER BY provincia)
      FROM mi_mv_route_ec_zones
      WHERE (p_year IS NULL OR period_year = p_year) AND provincia IS NOT NULL
    ), '[]'::jsonb),
    'cantones', COALESCE((
      SELECT jsonb_agg(jsonb_build_object('provincia', provincia, 'canton', canton))
      FROM (
        SELECT DISTINCT provincia, canton
        FROM mi_mv_route_ec_zones
        WHERE (p_year IS NULL OR period_year = p_year) AND canton IS NOT NULL
        ORDER BY provincia, canton
      ) c
    ), '[]'::jsonb)
  );
$function$;

CREATE OR REPLACE FUNCTION public.mi_route_port_options(p_year integer DEFAULT NULL::integer)
 RETURNS jsonb
 LANGUAGE sql
 STABLE
AS $function$
  WITH agg AS (
    SELECT port, kind, sum(bls) AS bls
    FROM mi_mv_route_port_options
    WHERE (p_year IS NULL OR period_year = p_year)
    GROUP BY port, kind
  )
  SELECT coalesce(jsonb_agg(to_jsonb(a) ORDER BY a.bls DESC), '[]'::jsonb)
  FROM agg a;
$function$;

CREATE OR REPLACE FUNCTION public.mi_unassigned_filter_options()
 RETURNS TABLE(provincias text[], verticales text[])
 LANGUAGE sql
 STABLE
 SET search_path TO 'public', 'pg_catalog'
AS $function$
  SELECT
    array(SELECT DISTINCT ec_provincia FROM public.mi_mv_unassigned_prospects
          WHERE ec_provincia IS NOT NULL ORDER BY 1),
    array(SELECT DISTINCT ec_vertical FROM public.mi_mv_unassigned_prospects
          WHERE ec_vertical IS NOT NULL ORDER BY 1);
$function$;

CREATE OR REPLACE FUNCTION public.next_sales_doc_number(p_type text)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_year integer := extract(year from now())::integer;
  v_n integer;
begin
  insert into sales_doc_counters(doc_type, year, last_n) values (p_type, v_year, 1)
  on conflict (doc_type, year) do update set last_n = sales_doc_counters.last_n + 1
  returning last_n into v_n;
  return p_type || '-' || v_year || '-' || lpad(v_n::text, 4, '0');
end $function$;

CREATE OR REPLACE FUNCTION public.norm_cliente(t text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$
  select trim(regexp_replace(
    regexp_replace(upper(coalesce(t,'')), '[^A-Z0-9 ]', ' ', 'g'),
    '\y(S A|C A|SA|CA|CIA|LTDA|ITDA|LTD|INC|CORP|LLC|SOCIEDAD|ANONIMA|COMPANIA|DEL|DE|LA|EL|Y|AND)\y', ' ', 'g'))
$function$;

CREATE OR REPLACE FUNCTION public.normalize_company_name(p_name text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
 SET search_path TO 'public', 'extensions', 'pg_catalog'
AS $function$
  -- Strip suffixes corporativos internacionales + collapse spaces.
  -- Cada token aplica con \m word boundary.
  select trim(regexp_replace(
    regexp_replace(
      regexp_replace(
        upper(unaccent(coalesce(p_name,''))),
        '\m(S\.?A\.?S?|S\.?A\.?C\.?|LTDA|LTD|CIA|C\.?A\.?|INC|LLC|CORP|CO\.?|S\.?R\.?L\.?|B\.?V\.?|N\.?V\.?|BVBA|GMBH|MBH|KG|KGAA|AG|AB|A\.?S\.?|OY|PLC|PTE|KK|PVT|SDN|BHD|SARL|SAS|SE|SPA|LIMITED|LIMITADA|COMPANY|COMPANIA|GRUPO|GROUP|HOLDING|INTERNATIONAL|INTL|GLOBAL|WORLDWIDE)\M',
        '', 'g'
      ),
      '[^A-Z0-9 ]+', ' ', 'g'
    ),
    '\s+', ' ', 'g'
  ));
$function$;

CREATE OR REPLACE FUNCTION public.normalize_wh_containers()
 RETURNS void
 LANGUAGE sql
AS $function$
  UPDATE wh_containers c
  SET container_type = x.canonical, cbm_capacity = x.cbm_capacity
  FROM (
    SELECT c2.monday_item_id, m.canonical, m.cbm_capacity
    FROM wh_containers c2
    CROSS JOIN LATERAL (
      SELECT canonical, cbm_capacity FROM wh_container_types t
      WHERE c2.container_type_raw ILIKE t.match_pattern
      ORDER BY t.priority LIMIT 1
    ) m
  ) x
  WHERE x.monday_item_id = c.monday_item_id
    AND (c.container_type IS DISTINCT FROM x.canonical OR c.cbm_capacity IS DISTINCT FROM x.cbm_capacity);
$function$;

CREATE OR REPLACE FUNCTION public.notify_credit_decision_update()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public', 'pg_catalog'
AS $function$
begin
  -- Only fire when status changes to approved or denied
  if (new.status in ('approved', 'denied') and old.status is distinct from new.status) then
    perform net.http_post(
      url := 'https://wfzdrqfurwnakrfdnbgf.supabase.co/functions/v1/notify-credit-decision',
      headers := '{"Content-Type":"application/json"}'::jsonb,
      body := jsonb_build_object(
        'record', row_to_json(new),
        'old_record', row_to_json(old)
      )
    );
  end if;
  return new;
end;
$function$;

CREATE OR REPLACE FUNCTION public.notify_credit_request_insert()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public', 'pg_catalog'
AS $function$
begin
  perform net.http_post(
    url := 'https://wfzdrqfurwnakrfdnbgf.supabase.co/functions/v1/notify-credit-request',
    headers := '{"Content-Type":"application/json"}'::jsonb,
    body := jsonb_build_object('record', row_to_json(new))
  );
  return new;
end;
$function$;

CREATE OR REPLACE FUNCTION public.office_for_magaya_company(p uuid)
 RETURNS uuid
 LANGUAGE sql
 IMMUTABLE
AS $function$
  select case p
    when 'aba24859-159c-424b-8ef3-d122fba41b7c'::uuid then 'b70721f4-6f96-440c-9ff5-2ff98231d29a'::uuid
    when 'd8b762a6-f66f-44de-bc44-2486ec1e2ae5'::uuid then 'cc987069-ac9a-41f2-85f0-0337f6b99980'::uuid
    when '20e7448c-4b80-443b-9903-6feaaf29cb1e'::uuid then '94dc11de-9354-4f13-928f-4f21314cebdd'::uuid
    when '9b807b51-5ee9-4a22-9e75-df90047ec12b'::uuid then '7e15cec2-eeb3-4fa6-b8b4-4df5d912fa14'::uuid
    else null
  end
$function$;

CREATE OR REPLACE FUNCTION public.on_picking_task_closed()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  source_id   uuid;
  warehouse   uuid;
  external_n  text;
  open_count  int;
BEGIN
  IF NEW.status <> 'closed' OR coalesce(OLD.status::text, 'pending') = 'closed' THEN RETURN NEW; END IF;
  source_id := NEW.manifest_source_id;
  SELECT warehouse_id, external_number INTO warehouse, external_n FROM manifest_sources WHERE id = source_id;
  SELECT count(*) INTO open_count FROM picking_tasks WHERE manifest_source_id = source_id AND status <> 'closed';
  IF open_count = 0 THEN
    INSERT INTO cl_alerts (warehouse_id, kind, severity, title, body, manifest_source_id, action_label, action_url)
    VALUES (warehouse, 'picking_complete', 'warning',
            'Picking completo en ' || external_n,
            'Crear StagingCheckTask y asignar Stager (≠ Picker)',
            source_id, 'Crear StagingCheck',
            '/container-loading/supervisor/staging/new?source=' || source_id);
    INSERT INTO cl_alerts (warehouse_id, kind, severity, title, body, manifest_source_id, action_label, action_url, due_at)
    VALUES (warehouse, 'reminder_4h', 'warning',
            'Recordatorio: StagingCheck pendiente en ' || external_n,
            'Han pasado 4h sin crear el StagingCheck',
            source_id, 'Crear ahora',
            '/container-loading/supervisor/staging/new?source=' || source_id,
            now() + interval '4 hours');
    UPDATE manifest_sources SET workflow_status = 'ready_for_staging' WHERE id = source_id;
  END IF;
  RETURN NEW;
END $function$;

CREATE OR REPLACE FUNCTION public.on_staging_check_closed()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE warehouse uuid; external_n text;
BEGIN
  IF NEW.status <> 'closed' OR coalesce(OLD.status::text, 'pending') = 'closed' THEN RETURN NEW; END IF;
  SELECT warehouse_id, external_number INTO warehouse, external_n FROM manifest_sources WHERE id = NEW.manifest_source_id;
  INSERT INTO cl_alerts (warehouse_id, kind, severity, title, body, manifest_source_id, action_label, action_url)
  VALUES (warehouse, 'staging_verified', 'info',
          'StagingCheck OK · ' || external_n,
          'Crear LoadingTask y asignar Loader. Si capacidad >70% saltará alerta.',
          NEW.manifest_source_id, 'Crear LoadingTask',
          '/container-loading/supervisor/loading/new?source=' || NEW.manifest_source_id);
  UPDATE manifest_sources SET workflow_status = 'staging_verified' WHERE id = NEW.manifest_source_id;
  RETURN NEW;
END $function$;

CREATE OR REPLACE FUNCTION public.on_staging_check_created()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  UPDATE cl_alerts SET status = 'dismissed'
    WHERE manifest_source_id = NEW.manifest_source_id
      AND kind IN ('picking_complete', 'reminder_4h')
      AND status = 'unread';
  INSERT INTO cl_alerts (warehouse_id, kind, severity, title, body, manifest_source_id, recipient_user_id, action_label, action_url)
  SELECT ms.warehouse_id, 'staging_assigned', 'info',
         'StagingCheck asignado',
         'Tienes un StagingCheck nuevo en ' || ms.external_number,
         NEW.manifest_source_id, NEW.assigned_to,
         'Abrir tarea', '/container-loading/stager/tasks/' || NEW.id
  FROM manifest_sources ms WHERE ms.id = NEW.manifest_source_id;
  RETURN NEW;
END $function$;

CREATE OR REPLACE FUNCTION public.ops_aceptar_transferencia(p_shipment_id uuid)
 RETURNS TABLE(out_estado text, out_recibido_por text, out_recibido_at timestamp with time zone)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_uid uuid := app_current_user_id();
  t ops_transfers%rowtype;
  v_nombre text;
begin
  if v_uid is null then
    raise exception 'No autenticado';
  end if;

  select * into t from ops_transfers where shipment_id = p_shipment_id for update;
  if not found then
    raise exception 'Este embarque no ha sido transferido a Operaciones.';
  end if;

  -- Doble clic o dos personas a la vez: devuelve lo que ya quedó, sin error.
  if t.handoff_estado = 'ACEPTADO' then
    select name into v_nombre from users where id = t.received_by;
    return query select t.handoff_estado, v_nombre, t.received_at;
    return;
  end if;

  if t.handoff_estado = 'DEVUELTO' then
    raise exception 'Este embarque fue devuelto a Customer Service. Hay que esperar a que lo vuelvan a transferir.';
  end if;

  if not app_can_operate_ops() then
    raise exception 'Solo el equipo de Operaciones puede aceptar la transferencia.';
  end if;

  if t.transferred_by = v_uid then
    raise exception 'No puedes aceptar un embarque que tú mismo transferiste: la aceptación la hace otra persona de Operaciones.';
  end if;

  perform set_config('app.ops_handoff', 'on', true);
  update ops_transfers
     set handoff_estado = 'ACEPTADO',
         received_by = v_uid,
         received_at = now(),
         updated_at = now()
   where id = t.id;

  insert into shipment_events (shipment_id, event_type, occurred_at, description, source, created_by, metadata)
  values (p_shipment_id, 'Aceptado por Operaciones', now(),
          'Desde ahora Customer Service ya no puede modificar el embarque.',
          'MANUAL', v_uid, jsonb_build_object('transfer_id', t.id));

  select name into v_nombre from users where id = v_uid;
  return query select 'ACEPTADO'::text, v_nombre, now();
end $function$;

CREATE OR REPLACE FUNCTION public.ops_booking_actualizar(p_shipment_id uuid, p_datos jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_dir shipment_direction_t;
  v_in uuid;
  v_client uuid;
  v_agent uuid;
begin
  if not (public.app_can('operaciones', 'edit')
       or public.app_can('operaciones.export', 'edit')) then
    raise exception 'no autorizado: hace falta permiso de editar en Operaciones (export)';
  end if;

  select direction into v_dir from shipments where id = p_shipment_id;
  if v_dir is null then
    return jsonb_build_object('error', 'ese booking no existe');
  end if;

  v_in := nullif(p_datos->>'client_id', '')::uuid;
  if v_in is not null then
    select id into v_client from clients where id = v_in;
    if v_client is null then select id into v_agent from agents where id = v_in; end if;
  end if;

  update shipments s set
    consignee_name   = coalesce(nullif(p_datos->>'consignee_name', ''), s.consignee_name),
    supplier         = coalesce(nullif(p_datos->>'shipper', ''), s.supplier),
    client_id        = coalesce(v_client, s.client_id),
    destino_agent_id = coalesce(v_agent, s.destino_agent_id),
    destino_tipo     = case when v_agent is not null then 'EXTERNAL_AGENT'::ops_destino_t
                            else coalesce(nullif(p_datos->>'destino_tipo', '')::ops_destino_t, s.destino_tipo) end,
    mode             = coalesce(nullif(p_datos->>'mode', '')::shipment_mode_t, s.mode),
    origin_port      = coalesce(nullif(p_datos->>'origin_port', ''), s.origin_port),
    destination_port = coalesce(nullif(p_datos->>'destination_port', ''), s.destination_port),
    incoterm         = coalesce(nullif(p_datos->>'incoterm', ''), s.incoterm),
    via_origen       = coalesce(nullif(p_datos->>'via_origen', '')::ops_via_origen_t, s.via_origen),
    equipment_type   = coalesce(nullif(p_datos->>'equipment_type', '')::ops_equipment_t, s.equipment_type),
    carrier          = coalesce(nullif(p_datos->>'carrier', ''), s.carrier),
    booking_ref      = coalesce(nullif(p_datos->>'booking_ref', ''), s.booking_ref),
    mbl              = coalesce(nullif(p_datos->>'mbl', ''), s.mbl),
    etd              = coalesce(nullif(p_datos->>'etd', '')::date, s.etd),
    eta              = coalesce(nullif(p_datos->>'eta', '')::date, s.eta),
    destino_office   = coalesce(nullif(p_datos->>'destino_office', ''), s.destino_office),
    updated_at       = now()
  where s.id = p_shipment_id;

  return jsonb_build_object('ok', true);
end;
$function$;

CREATE OR REPLACE FUNCTION public.ops_booking_ficha(p_shipment_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  j jsonb;
begin
  if not (public.app_can('operaciones', 'view')
       or public.app_can('operaciones.export', 'view')) then
    raise exception 'no autorizado: hace falta permiso de ver Operaciones (export)';
  end if;

  -- OJO: NO se devuelve nada de PBA. El PBA es confidencial y su unica
  -- proteccion es la politica de fila de shipments; este RPC es definer, asi
  -- que si lo devolviera, lo estaria regalando.
  select jsonb_build_object(
    'shipment_id', s.id,
    'shipment_code', s.shipment_code,
    'consignee_name', s.consignee_name,
    'shipper', s.supplier,
    'client_id', s.client_id,
    'cliente_crm', c.company_name,
    'mode', s.mode::text,
    'status', s.status::text,
    'origin_port', s.origin_port,
    'destination_port', s.destination_port,
    'incoterm', s.incoterm,
    'via_origen', s.via_origen::text,
    'equipment_type', s.equipment_type::text,
    'carrier', s.carrier,
    'booking_ref', s.booking_ref,
    'mbl', s.mbl,
    'etd', s.etd,
    'eta', s.eta,
    'destino_tipo', s.destino_tipo::text,
    'destino_office', s.destino_office,
    'created_at', s.created_at,
    'creado_por', u.name,
    'correo_origen', e.subject,
    'correo_de', e.sender,
    'correo_cuerpo', e.body_preview
  )
  into j
  from shipments s
  left join clients c on c.id = s.client_id
  left join users u on u.id = s.created_by
  left join ops_inbound_emails e on e.shipment_id = s.id and e.match_by = 'SI_MANUAL'
  where s.id = p_shipment_id and s.direction = 'EXPORT';

  if j is null then
    return jsonb_build_object('error', 'ese booking no existe');
  end if;
  return j;
end;
$function$;

CREATE OR REPLACE FUNCTION public.ops_bookings_recientes(p_oficina text DEFAULT 'USA'::text, p_dias integer DEFAULT 30)
 RETURNS TABLE(shipment_id uuid, shipment_code text, cliente text, shipper text, modo text, status text, destino text, via_origen text, created_at timestamp with time zone, creado_por text, correo_origen text, incompleto boolean)
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  if not (public.app_can('operaciones', 'view')
       or public.app_can('operaciones.export', 'view')) then
    raise exception 'no autorizado: hace falta permiso de ver Operaciones (export)';
  end if;

  return query
  select s.id, s.shipment_code, s.consignee_name, s.supplier,
         s.mode::text, s.status::text, s.destination_port, s.via_origen::text,
         s.created_at, u.name, e.subject,
         (coalesce(btrim(s.consignee_name), '') = '' or coalesce(btrim(s.destination_port), '') = '')
  from shipments s
  left join users u on u.id = s.created_by
  left join ops_inbound_emails e on e.shipment_id = s.id and e.match_by = 'SI_MANUAL'
  where s.office = p_oficina
    and s.direction = 'EXPORT'
    and s.consolidado_id is null
    and s.archived_at is null
    and s.created_at > now() - make_interval(days => greatest(p_dias, 1))
  order by s.created_at desc
  limit 200;
end;
$function$;

CREATE OR REPLACE FUNCTION public.ops_buscar_cliente(p_q text, p_limite integer DEFAULT 12)
 RETURNS TABLE(id uuid, nombre text, tipo text, detalle text)
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  qq text := btrim(coalesce(p_q, ''));
  q  text := '%' || qq || '%';
begin
  if not (public.app_can('operaciones', 'view')
       or public.app_can('operaciones.export', 'view')
       or public.app_can('operaciones.import', 'view')) then
    raise exception 'no autorizado: hace falta permiso de ver Operaciones';
  end if;

  return query
  with juntos as (
    select c.id, c.company_name as nombre, 'CLIENTE'::text as tipo,
           nullif(btrim(coalesce(c.office, '')), '') as detalle
    from clients c
    where c.company_name ilike q and c.deleted_at is null
    union all
    select a.id, a.company_name, 'AGENTE'::text,
           nullif(btrim(coalesce(a.country, '')), '')
    from agents a
    where a.company_name ilike q
  )
  select j.id, j.nombre, j.tipo, j.detalle
  from juntos j
  order by
    -- lo que EMPIEZA con lo escrito primero: es lo que la gente espera
    (lower(j.nombre) like lower(qq || '%')) desc,
    length(j.nombre),
    j.nombre
  limit greatest(p_limite, 1);
end;
$function$;

CREATE OR REPLACE FUNCTION public.ops_buscar_shipper(p_q text, p_limite integer DEFAULT 12)
 RETURNS TABLE(nombre text, veces bigint, fuente text)
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  qq text := btrim(coalesce(p_q, ''));
  q  text := '%' || qq || '%';
begin
  if not (public.app_can('operaciones', 'view')
       or public.app_can('operaciones.export', 'view')
       or public.app_can('operaciones.import', 'view')) then
    raise exception 'no autorizado: hace falta permiso de ver Operaciones';
  end if;

  -- Sin nada escrito no se devuelve el historial completo: son 53k nombres.
  if length(qq) < 2 then
    return;
  end if;

  return query
  with todo as (
    -- El LIMIT va en subconsulta propia: dentro de una rama de UNION es
    -- error de sintaxis.
    select * from (
      select btrim(w.shipper) as nombre, 'bodega Miami'::text as fuente
      from magaya_warehouse_receipts w
      where lower(w.shipper) like lower(q) and coalesce(btrim(w.shipper), '') <> ''
      limit 3000
    ) wr
    union all
    select btrim(l.shipper), 'consolidado'::text
    from consolidado_lineas l
    where lower(l.shipper) like lower(q) and coalesce(btrim(l.shipper), '') <> ''
    union all
    select btrim(s.supplier), 'embarques'::text
    from shipments s
    where lower(s.supplier) like lower(q) and coalesce(btrim(s.supplier), '') <> ''
  )
  select t.nombre, count(*) as veces, (array_agg(distinct t.fuente))[1] as fuente
  from todo t
  group by t.nombre
  order by
    (lower(t.nombre) like lower(qq || '%')) desc,
    count(*) desc,
    t.nombre
  limit greatest(p_limite, 1);
end;
$function$;

CREATE OR REPLACE FUNCTION public.ops_devolver_transferencia(p_shipment_id uuid, p_motivo text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_uid uuid := app_current_user_id();
  v_motivo text := btrim(coalesce(p_motivo, ''));
  t ops_transfers%rowtype;
begin
  if v_uid is null then
    raise exception 'No autenticado';
  end if;

  if length(v_motivo) < 5 then
    raise exception 'Escribe el motivo de la devolución: la CS tiene que saber qué corregir.';
  end if;

  select * into t from ops_transfers where shipment_id = p_shipment_id for update;
  if not found then
    raise exception 'Este embarque no ha sido transferido a Operaciones.';
  end if;

  if t.handoff_estado = 'DEVUELTO' then
    return;  -- ya estaba devuelto
  end if;

  if t.handoff_estado = 'ACEPTADO' then
    raise exception 'Este embarque ya fue aceptado: ahora es de Operaciones. Si hay que corregir algo, corrígelo desde Operaciones.';
  end if;

  if not app_can_operate_ops() then
    raise exception 'Solo el equipo de Operaciones puede devolver la transferencia.';
  end if;

  perform set_config('app.ops_handoff', 'on', true);
  update ops_transfers
     set handoff_estado = 'DEVUELTO',
         returned_by = v_uid,
         returned_at = now(),
         return_reason = v_motivo,
         updated_at = now()
   where id = t.id;

  insert into shipment_events (shipment_id, event_type, occurred_at, description, source, created_by, metadata)
  values (p_shipment_id, 'Devuelto a Customer Service', now(), v_motivo,
          'MANUAL', v_uid, jsonb_build_object('transfer_id', t.id));

  -- Que la CS se entere: le cae como pendiente en su Mi día.
  insert into shipment_action_items (shipment_id, title, details, assigned_to, priority, status, source_agent)
  values (p_shipment_id, 'Operaciones devolvió el embarque', v_motivo,
          t.transferred_by, 'HIGH', 'OPEN', 'OPS_HANDOFF');
end $function$;

CREATE OR REPLACE FUNCTION public.ops_dispatch_to_finance(p_shipment_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_uid uuid := app_current_user_id();
  v_role text := app_current_user_role();
  v_email text;
  v_ship shipments%rowtype;
  v_si shipping_instructions%rowtype;
  v_inv_id uuid;
  v_loc_id uuid;
  v_lines jsonb;
  v_loc_lines jsonb;
  v_loc_total numeric;
begin
  if v_uid is null then raise exception 'No autenticado'; end if;
  select lower(u.email) into v_email from users u where u.id = v_uid;
  if v_role not in ('Admin','VP','Manager','Customer Service')
     and coalesce(v_email,'') not in ('ops@glovalecuador.com','ops1@glovalecuador.com','ops2@glovalecuador.com') then
    raise exception 'Tu rol (%) no puede enviar a Facturación', v_role;
  end if;

  select * into v_ship from shipments where id = p_shipment_id for update;
  if not found then raise exception 'Embarque no encontrado'; end if;

  -- Idempotente
  select id into v_inv_id from fact_orders where shipment_id = p_shipment_id and kind = 'INVOICE_CLIENT' limit 1;
  if v_inv_id is not null then
    select id into v_loc_id from fact_orders where shipment_id = p_shipment_id and kind = 'LOCAL_CHARGES' limit 1;
    return jsonb_build_object('invoice_id', v_inv_id, 'local_id', v_loc_id, 'ya_existia', true);
  end if;

  select * into v_si from shipping_instructions where shipment_id = p_shipment_id limit 1;

  if v_si.id is not null then
    select coalesce(jsonb_agg(jsonb_build_object(
      'name', l.name, 'charge_code', l.charge_code, 'qty', l.qty,
      'sale_amount', l.sale_amount, 'cost_amount', l.cost_amount,
      'currency', l.currency, 'iva_exempt', l.iva_exempt)), '[]'::jsonb)
      into v_lines
      from sales_quote_lines l where l.si_id = v_si.id;
  else
    v_lines := '[]'::jsonb;
  end if;

  insert into fact_orders (shipment_id, si_id, client_id, kind, lines, total, created_by)
  values (p_shipment_id, v_si.id, v_ship.client_id, 'INVOICE_CLIENT', v_lines, v_si.sale_total, v_uid)
  returning id into v_inv_id;

  -- Gastos locales a naviera (EC_LOC) → Financiero
  if v_si.id is not null then
    select coalesce(jsonb_agg(jsonb_build_object(
      'name', l.name, 'charge_code', l.charge_code, 'cost_amount', l.cost_amount, 'currency', l.currency)), '[]'::jsonb),
      coalesce(sum(l.cost_amount), 0)
      into v_loc_lines, v_loc_total
      from sales_quote_lines l where l.si_id = v_si.id and l.charge_code like 'EC_LOC%';
    if v_loc_lines <> '[]'::jsonb then
      insert into fact_orders (shipment_id, si_id, client_id, kind, lines, total, created_by)
      values (p_shipment_id, v_si.id, v_ship.client_id, 'LOCAL_CHARGES', v_loc_lines, v_loc_total, v_uid)
      returning id into v_loc_id;
    end if;
  end if;

  update ops_transfers set ops_status = 'PRE_ARRIBO', updated_at = now()
   where shipment_id = p_shipment_id
     and ops_status in ('RECIBIDO','DOCUMENTACION','DECLARACION','BOOKING_CUTOFF','TRANSITO');

  insert into shipment_events (shipment_id, event_type, source, created_by, metadata)
  values (p_shipment_id, 'Enviado a Facturación y Financiero (gastos locales)', 'SYSTEM', v_uid,
          jsonb_build_object('invoice_id', v_inv_id, 'local_id', v_loc_id));

  return jsonb_build_object('invoice_id', v_inv_id, 'local_id', v_loc_id, 'ya_existia', false);
end $function$;

CREATE OR REPLACE FUNCTION public.ops_next_hbl(p_office_code text, p_port_code text)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_uid uuid := app_current_user_id();
  v_role text := app_current_user_role();
  v_email text;
  v_year int := extract(year from now())::int;
  v_seq int;
  v_ofc text := upper(coalesce(nullif(trim(p_office_code),''),'ECU'));
  v_port text := upper(coalesce(nullif(trim(p_port_code),''),'XXX'));
begin
  if v_uid is null then
    raise exception 'No autenticado';
  end if;
  select lower(u.email) into v_email from users u where u.id = v_uid;
  if v_role not in ('Admin','VP','Manager')
     and coalesce(v_email,'') not in ('ops@glovalecuador.com','ops1@glovalecuador.com','ops2@glovalecuador.com') then
    raise exception 'Tu rol (%) no puede emitir HBL', v_role;
  end if;

  insert into ops_hbl_sequence (office_code, year, last_number)
  values (v_ofc, v_year, 0)
  on conflict (office_code, year) do nothing;

  update ops_hbl_sequence
     set last_number = last_number + 1
   where office_code = v_ofc and year = v_year
  returning last_number into v_seq;

  return 'GVL-' || v_ofc || '-' || v_port || '-' || v_year::text || lpad(v_seq::text, 6, '0');
end $function$;

CREATE OR REPLACE FUNCTION public.ops_si_a_booking(p_email_id uuid, p_datos jsonb DEFAULT '{}'::jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  e         record;
  v_ship    uuid;
  v_mode    shipment_mode_t;
  v_office  text;
  v_in      uuid;
  v_client  uuid;
  v_agent   uuid;
begin
  if not (public.app_can('operaciones', 'create')
       or public.app_can('operaciones.export', 'create')) then
    raise exception 'no autorizado: hace falta permiso de crear en Operaciones (export)';
  end if;

  select * into e from ops_inbound_emails where id = p_email_id;
  if not found then
    return jsonb_build_object('error', 'el correo no existe');
  end if;
  if e.shipment_id is not null then
    return jsonb_build_object('error', 'ese correo ya esta enganchado a un embarque',
                              'shipment_id', e.shipment_id);
  end if;

  v_office := coalesce(
    nullif(btrim(coalesce(p_datos->>'office', '')), ''),
    (select u.office from users u where u.id = public.app_current_user_id())
  );
  if v_office is null then
    return jsonb_build_object('error', 'falta decir de que oficina es el embarque');
  end if;

  -- El id elegido puede ser de un cliente o de un agente. Se resuelve contra
  -- las dos tablas en vez de asumir.
  v_in := nullif(p_datos->>'client_id', '')::uuid;
  if v_in is not null then
    select id into v_client from clients where id = v_in;
    if v_client is null then
      select id into v_agent from agents where id = v_in;
    end if;
  end if;
  -- Si vino explicito un agente, manda ese.
  if v_agent is null then
    v_agent := (select a.id from agents a where a.id = nullif(p_datos->>'destino_agent_id','')::uuid);
  end if;

  v_mode := coalesce(nullif(p_datos->>'mode', ''), 'LCL')::shipment_mode_t;

  insert into shipments (
    office, mode, direction, status,
    client_id, consignee_name, supplier,
    origin_port, destination_port, incoterm,
    via_origen, destino_tipo, destino_office, destino_agent_id,
    created_by
  ) values (
    v_office, v_mode, 'EXPORT'::shipment_direction_t, 'BOOKING'::shipment_status_t,
    v_client,
    nullif(p_datos->>'consignee_name', ''),
    nullif(p_datos->>'shipper', ''),
    nullif(p_datos->>'origin_port', ''),
    nullif(p_datos->>'destination_port', ''),
    nullif(p_datos->>'incoterm', ''),
    coalesce(nullif(p_datos->>'via_origen', ''), 'FUERA_BODEGA')::ops_via_origen_t,
    case when v_agent is not null then 'EXTERNAL_AGENT'::ops_destino_t
         else nullif(p_datos->>'destino_tipo', '')::ops_destino_t end,
    nullif(p_datos->>'destino_office', ''),
    v_agent,
    public.app_current_user_id()
  )
  returning id into v_ship;

  update ops_inbound_emails
     set shipment_id = v_ship, match_by = 'SI_MANUAL', status = 'VINCULADO',
         si_estado = 'CONVERTIDA', si_resuelta_por = public.app_current_user_id(),
         si_resuelta_at = now()
   where id = p_email_id;

  return jsonb_build_object('ok', true, 'shipment_id', v_ship, 'oficina', v_office,
    'vinculo', case when v_client is not null then 'cliente'
                    when v_agent is not null then 'agente'
                    else 'solo nombre' end);
end;
$function$;

CREATE OR REPLACE FUNCTION public.ops_si_bandeja(p_oficina text DEFAULT 'USA'::text)
 RETURNS TABLE(email_id uuid, mailbox text, subject text, sender text, received_at timestamp with time zone, body_preview text, has_attachments boolean, refs jsonb, si_estado text)
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  if not (public.app_can('operaciones', 'view')
       or public.app_can('operaciones.export', 'view')) then
    raise exception 'no autorizado: hace falta permiso de ver Operaciones (export)';
  end if;

  return query
  select e.id, e.mailbox, e.subject, e.sender, e.received_at,
         e.body_preview, e.has_attachments, e.refs, e.si_estado
  from ops_inbound_emails e
  join ops_capture_mailboxes m on m.email = e.mailbox
  where e.si_estado = 'PENDIENTE'
    and (p_oficina is null or m.oficina = p_oficina)
  order by e.received_at desc
  limit 200;
end;
$function$;

CREATE OR REPLACE FUNCTION public.ops_si_descartar(p_email_id uuid, p_motivo text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  if not (public.app_can('operaciones', 'edit')
       or public.app_can('operaciones.export', 'edit')) then
    raise exception 'no autorizado: hace falta permiso de editar en Operaciones (export)';
  end if;

  update ops_inbound_emails
     set si_estado       = 'DESCARTADA',
         si_resuelta_por = public.app_current_user_id(),
         si_resuelta_at  = now(),
         error           = coalesce(nullif(p_motivo, ''), error)
   where id = p_email_id and si_estado = 'PENDIENTE';

  if not found then
    return jsonb_build_object('error', 'ese correo ya no estaba pendiente');
  end if;
  return jsonb_build_object('ok', true);
end;
$function$;

CREATE OR REPLACE FUNCTION public.ops_si_deshacer(p_shipment_id uuid, p_a_bandeja boolean DEFAULT true)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_email uuid;
begin
  if not (public.app_can('operaciones', 'edit')
       or public.app_can('operaciones.export', 'edit')) then
    raise exception 'no autorizado: hace falta permiso de editar en Operaciones (export)';
  end if;

  if exists (select 1 from ops_hbl where shipment_id = p_shipment_id)
     or exists (select 1 from ops_documents where shipment_id = p_shipment_id)
     or exists (select 1 from consolidado_lineas where shipment_id = p_shipment_id) then
    return jsonb_build_object('error',
      'ese booking ya tiene trabajo encima (HBL, documentos o carga asignada): no se deshace solo');
  end if;

  select id into v_email from ops_inbound_emails
   where shipment_id = p_shipment_id and match_by = 'SI_MANUAL' limit 1;

  if v_email is not null then
    update ops_inbound_emails
       set shipment_id = null,
           status      = 'SI_CANDIDATA',
           match_by    = 'NINGUNO',
           si_estado   = case when p_a_bandeja then 'PENDIENTE' else 'DESCARTADA' end,
           si_resuelta_por = case when p_a_bandeja then null else public.app_current_user_id() end,
           si_resuelta_at  = case when p_a_bandeja then null else now() end
     where id = v_email;
  end if;

  delete from shipments where id = p_shipment_id;

  return jsonb_build_object('ok', true, 'correo_devuelto', v_email is not null);
end;
$function$;

CREATE OR REPLACE FUNCTION public.ops_transfer(p_shipment_id uuid)
 RETURNS TABLE(out_transfer_id uuid, out_ops_status text)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_uid uuid := app_current_user_id();
  v_role text := app_current_user_role();
  v_email text;
  v_existing ops_transfers%rowtype;
  v_id uuid;
begin
  if v_uid is null then
    raise exception 'No autenticado';
  end if;

  select lower(u.email) into v_email from users u where u.id = v_uid;

  -- Autorización: roles gestores + Customer Service (quien entrega) + equipo de Operaciones
  if v_role not in ('Admin','VP','Manager','Customer Service')
     and coalesce(v_email,'') not in ('ops@glovalecuador.com','ops1@glovalecuador.com','ops2@glovalecuador.com') then
    raise exception 'Tu rol (%) no puede transferir a Operaciones', v_role;
  end if;

  perform 1 from shipments where id = p_shipment_id for update;
  if not found then
    raise exception 'Embarque no encontrado';
  end if;

  select * into v_existing from ops_transfers where shipment_id = p_shipment_id for update;
  if found then
    -- Operaciones la había devuelto: CS corrigió y la vuelve a mandar.
    if v_existing.handoff_estado = 'DEVUELTO' then
      perform set_config('app.ops_handoff', 'on', true);
      update ops_transfers
         set handoff_estado = 'PENDIENTE',
             transferred_by = v_uid,
             transferred_at = now(),
             received_by = null, received_at = null,
             returned_by = null, returned_at = null, return_reason = null,
             updated_at = now()
       where id = v_existing.id;

      insert into shipment_events (shipment_id, event_type, occurred_at, description, source, created_by, metadata)
      values (p_shipment_id, 'Transferido a Operaciones', now(),
              'Enviado de nuevo después de la devolución — pendiente de que Operaciones lo acepte',
              'MANUAL', v_uid, jsonb_build_object('transfer_id', v_existing.id, 'reenvio', true));
    end if;
    -- Idempotente en cualquier otro caso: devuelve la existente sin duplicar
    return query select v_existing.id, v_existing.ops_status::text;
    return;
  end if;

  insert into ops_transfers (shipment_id, transferred_by)
  values (p_shipment_id, v_uid)
  returning id into v_id;

  insert into shipment_events (shipment_id, event_type, occurred_at, description, source, created_by, metadata)
  values (p_shipment_id, 'Transferido a Operaciones', now(),
          'Pendiente de que Operaciones lo acepte',
          'MANUAL', v_uid, jsonb_build_object('transfer_id', v_id));

  return query select v_id, 'RECIBIDO'::text;
end $function$;

CREATE OR REPLACE FUNCTION public.ops_vacios_desde_contenedor()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare s record;
begin
  select id, office, direction, mode, carrier, eta into s from shipments where id = new.shipment_id;
  if s.direction = 'IMPORT' and s.mode = 'FCL' and coalesce(trim(new.container_number),'') <> '' then
    insert into ops_devolucion_vacios
      (office, shipment_id, shipment_container_id, container_number, size_type, naviera, fecha_descarga, created_by)
    values (s.office, s.id, new.id, new.container_number, new.size_type, s.carrier, s.eta::date, new.created_by)
    on conflict (shipment_container_id) where shipment_container_id is not null do nothing;
  end if;
  return new;
end $function$;

CREATE OR REPLACE FUNCTION public.ops_vacios_sync_numero()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  update ops_devolucion_vacios set container_number = new.container_number, size_type = new.size_type
  where shipment_container_id = new.id
    and (container_number is distinct from new.container_number or size_type is distinct from new.size_type);
  return new;
end $function$;

CREATE OR REPLACE FUNCTION public.ops_vacios_touch()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin new.updated_at := now(); return new; end $function$;

CREATE OR REPLACE FUNCTION public.pba_sync_desde_shipment()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_ref text;
begin
  v_ref := coalesce(nullif(btrim(new.hbl), ''), nullif(btrim(new.mbl), ''), new.shipment_code);

  if coalesce(new.pba_amount, 0) > 0 then
    update public.pba_payments p
       set amount    = new.pba_amount,
           currency  = coalesce(new.pba_currency, 'USD'),
           client_id = coalesce(new.client_id, p.client_id),
           bl_ref    = coalesce(v_ref, p.bl_ref),
           updated_at = now()
     where p.shipment_id = new.id
       and p.status = 'PENDING';

    if not found and not exists (select 1 from public.pba_payments p2 where p2.shipment_id = new.id) then
      insert into public.pba_payments (shipment_id, client_id, amount, currency, bl_ref, status)
      values (new.id, new.client_id, new.pba_amount, coalesce(new.pba_currency, 'USD'), v_ref, 'PENDING');
    end if;
  else
    -- PBA borrado del embarque: se retira la cobranza solo si nadie la trabajo.
    delete from public.pba_payments p
     where p.shipment_id = new.id
       and p.status = 'PENDING'
       and coalesce(p.reminder_count, 0) = 0
       and p.paid_at is null;
  end if;

  return null;
end $function$;

CREATE OR REPLACE FUNCTION public.piezas_en_bodega(n wh_notices)
 RETURNS integer
 LANGUAGE sql
 STABLE
AS $function$
  select coalesce(sum(i.pieces) filter (where i.status = 'OnHand'), 0)::int
  from public.magaya_wr_items i where i.wr_number = n.wr_number;
$function$;

CREATE OR REPLACE FUNCTION public.promote_magaya_shipment(p_magaya_shipment_id uuid)
 RETURNS shipments
 LANGUAGE plpgsql
 SET search_path TO 'public', 'pg_catalog'
AS $function$
declare
  v_ms     public.magaya_shipments;
  v_client uuid;
  v_office text;
  v_mode   shipment_mode_t;
  v_dir    shipment_direction_t;
  v_ship   public.shipments;
begin
  select * into v_ms from public.magaya_shipments where id = p_magaya_shipment_id;
  if v_ms.id is null then raise exception 'Magaya shipment % not found', p_magaya_shipment_id; end if;

  -- ¿Ya promovido? Devolver el existente
  select * into v_ship from public.shipments where magaya_shipment_id = v_ms.id;
  if v_ship.id is not null then return v_ship; end if;

  -- Match consignee → cliente CRM
  select id into v_client from public.clients
   where company_name_normalized = public.normalize_company_name(v_ms.consignee)
   limit 1;

  v_office := public.shipment_to_office(v_ms.direction, v_ms.origin, v_ms.destination);
  if v_office is null then v_office := 'Ecuador'; end if;  -- fallback

  v_mode := case
    when lower(coalesce(v_ms.mode_of_transport,'')) like '%ocean%' or lower(v_ms.service_type) like '%fcl%' then 'FCL'::shipment_mode_t
    when lower(v_ms.service_type) like '%lcl%' then 'LCL'::shipment_mode_t
    when lower(coalesce(v_ms.mode_of_transport,'')) like '%air%' then 'AIR'::shipment_mode_t
    when lower(coalesce(v_ms.mode_of_transport,'')) like '%courier%' then 'COURIER'::shipment_mode_t
    else 'FCL'::shipment_mode_t
  end;

  v_dir := case
    when v_ms.direction in ('Import','Importation') then 'IMPORT'::shipment_direction_t
    when v_ms.direction in ('Export','Exportation') then 'EXPORT'::shipment_direction_t
    else 'CROSSTRADE'::shipment_direction_t
  end;

  insert into public.shipments
    (magaya_shipment_id, client_id, office, mode, direction, status,
     carrier, origin_port, destination_port, etd, eta, supplier,
     booking_ref, mbl, hbl, created_by)
  values
    (v_ms.id, v_client, v_office, v_mode, v_dir,
     case lower(coalesce(v_ms.status,''))
       when 'onhand'    then 'IN_WAREHOUSE'::shipment_status_t
       when 'loaded'    then 'LOADED'::shipment_status_t
       when 'intransit' then 'IN_TRANSIT'::shipment_status_t
       when 'delivered' then 'DELIVERED'::shipment_status_t
       else 'BOOKING'::shipment_status_t
     end,
     v_ms.carrier, v_ms.origin, v_ms.destination, v_ms.etd, v_ms.eta, v_ms.shipper,
     v_ms.booking_number, v_ms.master_bill, null,
     public.app_current_user_id())
  returning * into v_ship;

  -- Evento inicial en timeline
  insert into public.shipment_events (shipment_id, event_type, occurred_at, description, source, created_by, metadata)
  values (
    v_ship.id, 'SHIPMENT_PROMOTED', now(),
    format('Shipment promovido desde Magaya #%s', v_ms.shipment_number),
    'SYSTEM', public.app_current_user_id(),
    jsonb_build_object('magaya_shipment_id', v_ms.id, 'magaya_status', v_ms.status)
  );

  return v_ship;
end $function$;

CREATE OR REPLACE FUNCTION public.prospect_enrichment_ec_touch_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$function$;

CREATE OR REPLACE FUNCTION public.purge_deleted_client(p_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions', 'pg_catalog'
AS $function$
declare
  v_uid  uuid := auth.uid();
  v_role text;
begin
  if v_uid is null then raise exception 'No autenticado'; end if;
  select u.role into v_role from public.users u where u.auth_user_id = v_uid;
  if v_role not in ('Admin','Administration') then
    raise exception 'Solo Admin / Administration puede vaciar la papelera';
  end if;
  begin
    delete from public.clients where id = p_id and deleted_at is not null;
  exception when foreign_key_violation then
    raise exception 'No se puede eliminar definitivamente: el cliente tiene documentos de negocio vinculados (cotizaciones, cierres, embarques, facturas u otros). Detalle: %', SQLERRM;
  end;
end $function$;

CREATE OR REPLACE FUNCTION public.purge_deleted_clients(p_ids uuid[])
 RETURNS TABLE(client_id uuid, company_name text, ok boolean, error_msg text)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions', 'pg_catalog'
AS $function$
declare
  v_uid  uuid := auth.uid();
  v_role text;
  v_id   uuid;
  v_name text;
begin
  if v_uid is null then raise exception 'No autenticado'; end if;
  select u.role into v_role from public.users u where u.auth_user_id = v_uid;
  if v_role not in ('Admin','Administration') then
    raise exception 'Solo Admin / Administration puede vaciar la papelera';
  end if;

  for v_id, v_name in
    select c.id, c.company_name
      from public.clients c
     where c.id = any(p_ids)
       and c.deleted_at is not null
  loop
    begin
      delete from public.clients where id = v_id and deleted_at is not null;
      client_id := v_id; company_name := v_name; ok := true; error_msg := null;
    exception when foreign_key_violation then
      client_id := v_id; company_name := v_name; ok := false;
      error_msg := 'Tiene documentos de negocio vinculados (cotizaciones, cierres, embarques, facturas u otros)';
    end;
    return next;
  end loop;
end $function$;

CREATE OR REPLACE FUNCTION public.quotes_protege_created_by()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  if new.created_by is distinct from old.created_by and not public.app_user_is_admin() then
    raise exception 'No se puede cambiar la vendedora dueña de la cotización (solo Admin/VP).';
  end if;
  return new;
end $function$;

CREATE OR REPLACE FUNCTION public.reception_hosts_search(p_query text, p_office text DEFAULT 'USA'::text)
 RETURNS TABLE(id uuid, name text, department text, host_type text)
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select h.id, h.name, h.department, h.host_type
  from (
    select u.id, u.name, u.department, 'employee'::text as host_type
    from public.users u
    where u.office = p_office and u.status = 'Active'
    union all
    select t.id, t.name, t.company as department, 'tenant'::text as host_type
    from public.reception_hosts t
    where t.office = p_office and t.active = true
  ) h
  where coalesce(trim(p_query), '') = ''
     or h.name ilike '%' || trim(p_query) || '%'
     or coalesce(h.department, '') ilike '%' || trim(p_query) || '%'
  order by h.name
  limit 60;
$function$;

CREATE OR REPLACE FUNCTION public.recompute_client_credit(p_client_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions', 'pg_catalog'
AS $function$
declare
  r record;
begin
  -- 1) Última aprobación vigente
  select cr.approved_amount, cr.approved_days, cr.reviewed_at, cr.reviewed_by, cr.created_at
    into r
    from public.credit_requests cr
   where cr.client_id = p_client_id and cr.status = 'approved'
   order by coalesce(cr.reviewed_at, cr.created_at) desc
   limit 1;
  if found then
    update public.clients set
      credit_status      = 'approved',
      credit_limit       = r.approved_amount,
      credit_days        = r.approved_days,
      credit_terms       = case when r.approved_days is not null then 'Net ' || r.approved_days else null end,
      credit_approved_at = coalesce(r.reviewed_at, r.created_at),
      credit_approved_by = r.reviewed_by
    where id = p_client_id;
    return;
  end if;

  -- 2) Solicitud en curso
  if exists (
    select 1 from public.credit_requests cr
     where cr.client_id = p_client_id and cr.status in ('pending','under_review')
  ) then
    update public.clients set
      credit_status = 'pending', credit_limit = 0, credit_days = 0,
      credit_terms = null, credit_approved_at = null, credit_approved_by = null
    where id = p_client_id;
    return;
  end if;

  -- 3) Último resultado negativo
  select cr.status into r
    from public.credit_requests cr
   where cr.client_id = p_client_id and cr.status in ('denied','revoked')
   order by coalesce(cr.updated_at, cr.reviewed_at, cr.created_at) desc
   limit 1;
  if found then
    update public.clients set
      credit_status = r.status, credit_limit = 0, credit_days = 0,
      credit_terms = null, credit_approved_at = null, credit_approved_by = null
    where id = p_client_id;
    return;
  end if;

  -- 4) Sin historial de requests: no tocar nada si nunca hubo requests
  --    (respeta créditos cargados a mano en el form de cliente).
end $function$;

CREATE OR REPLACE FUNCTION public.redactar_credenciales(txt text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$
  select case when txt is null then null else
    regexp_replace(
      regexp_replace(
        regexp_replace(txt,
          -- bloque completo "MAGAYA PAYMENT ... " hasta el final de la nota
          '(MAGAYA\s*PAYMENT)[\s\S]*$', '\1 [CREDENCIALES ELIMINADAS]', 'gi'),
        -- cualquier contraseña suelta
        '((?:PASSWORD|PASSW|CONTRASE[NÑ]A|CLAVE|PWD)\s*[:=]?\s*)\S+', '\1[ELIMINADA]', 'gi'),
      -- IDs de pago que suelen ir pegados a la credencial
      '(\mID\s*[:=]?\s*)(35290)\M', '\1[ELIMINADO]', 'gi')
  end;
$function$;

CREATE OR REPLACE FUNCTION public.ref_salida(n wh_notices)
 RETURNS text
 LANGUAGE sql
 STABLE
AS $function$
  select coalesce(
    nullif(w.cargo_release_number, ''),
    (select cr.cr_number
       from public.magaya_wr_items i
       join public.magaya_cargo_releases cr on cr.guid = i.cargo_release_guid
      where i.wr_number = n.wr_number
        and coalesce(i.cargo_release_guid, '') <> ''
      limit 1),
    case when w.out_date is not null then to_char(w.out_date, 'DD/MM/YYYY') end
  )
  from public.magaya_warehouse_receipts w
  where w.wr_number = n.wr_number;
$function$;

CREATE OR REPLACE FUNCTION public.refresh_mv_finanzas_docs_abiertos()
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
declare t0 timestamptz := clock_timestamp();
begin
  refresh materialized view concurrently mv_finanzas_docs_abiertos;
  return round(extract(epoch from clock_timestamp() - t0) * 1000)::text || ' ms';
end $function$;

CREATE OR REPLACE FUNCTION public.refresh_wh_metrics()
 RETURNS void
 LANGUAGE sql
AS $function$
  REFRESH MATERIALIZED VIEW CONCURRENTLY mv_wh_metrics;
  REFRESH MATERIALIZED VIEW mv_wh_container_metrics;
$function$;

CREATE OR REPLACE FUNCTION public.replace_sales_quote_lines(p_quote_id uuid, p_lines jsonb)
 RETURNS void
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
begin
  delete from sales_quote_lines where quote_id = p_quote_id;
  insert into sales_quote_lines
    (quote_id, section, charge_code, name, basis, qty,
     cost_rate, cost_amount, sale_rate, sale_amount, cost_min, sale_min,
     currency, notes, sort_order, container_type, iva_exempt, free_qty)
  select p_quote_id,
         coalesce(l->>'section','freight'),
         nullif(l->>'charge_code',''),
         coalesce(l->>'name',''),
         coalesce(l->>'basis','manual'),
         coalesce((l->>'qty')::numeric, 1),
         coalesce((l->>'cost_rate')::numeric, 0),
         coalesce((l->>'cost_amount')::numeric, 0),
         coalesce((l->>'sale_rate')::numeric, 0),
         coalesce((l->>'sale_amount')::numeric, 0),
         coalesce((l->>'cost_min')::numeric, 0),
         coalesce((l->>'sale_min')::numeric, 0),
         coalesce(l->>'currency','USD'),
         nullif(l->>'notes',''),
         coalesce((l->>'sort_order')::int, 0),
         nullif(l->>'container_type',''),
         coalesce((l->>'iva_exempt')::boolean, false),
         coalesce((l->>'free_qty')::numeric, 0)
  from jsonb_array_elements(coalesce(p_lines, '[]'::jsonb)) as l;
end $function$;

CREATE OR REPLACE FUNCTION public.replace_sales_si_lines(p_si_id uuid, p_lines jsonb)
 RETURNS void
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
begin
  delete from sales_quote_lines where si_id = p_si_id;
  insert into sales_quote_lines
    (si_id, section, charge_code, name, basis, qty,
     cost_rate, cost_amount, sale_rate, sale_amount, cost_min, sale_min,
     currency, notes, sort_order, container_type, iva_exempt, free_qty)
  select p_si_id,
         coalesce(l->>'section','freight'),
         nullif(l->>'charge_code',''),
         coalesce(l->>'name',''),
         coalesce(l->>'basis','manual'),
         coalesce((l->>'qty')::numeric, 1),
         coalesce((l->>'cost_rate')::numeric, 0),
         coalesce((l->>'cost_amount')::numeric, 0),
         coalesce((l->>'sale_rate')::numeric, 0),
         coalesce((l->>'sale_amount')::numeric, 0),
         coalesce((l->>'cost_min')::numeric, 0),
         coalesce((l->>'sale_min')::numeric, 0),
         coalesce(l->>'currency','USD'),
         nullif(l->>'notes',''),
         coalesce((l->>'sort_order')::int, 0),
         nullif(l->>'container_type',''),
         coalesce((l->>'iva_exempt')::boolean, false),
         coalesce((l->>'free_qty')::numeric, 0)
  from jsonb_array_elements(coalesce(p_lines, '[]'::jsonb)) as l;
end $function$;

CREATE OR REPLACE FUNCTION public.report_billing(p_from date, p_to date, p_office text DEFAULT 'all'::text)
 RETURNS jsonb
 LANGUAGE sql
 STABLE
AS $function$
  with base as (
    select *,
      case company_id::text
        when 'd8b762a6-f66f-44de-bc44-2486ec1e2ae5' then 'Ecuador'
        when 'aba24859-159c-424b-8ef3-d122fba41b7c' then 'USA'
        when '9b807b51-5ee9-4a22-9e75-df90047ec12b' then 'Perú'
        when '20e7448c-4b80-443b-9903-6feaaf29cb1e' then 'Panamá'
        else 'Otra' end as office,
      coalesce(nullif(total_amount_usd,0),
               case when company_id::text = '9b807b51-5ee9-4a22-9e75-df90047ec12b'
                    then coalesce(total_amount,0)/3.443 else coalesce(total_amount,0) end) as usd_amt
    from magaya_transactions
    where transaction_type = 'IN'
      and (p_office = 'all' or company_id::text = p_office)
  ),
  sel as (select * from base where created_on >= p_from and created_on <= p_to),
  prior_win as (select * from base where created_on >= (p_from - (p_to - p_from + 1)) and created_on < p_from),
  weekly as (
    select date_trunc('week', created_on)::date wk, round(sum(usd_amt)::numeric,0) usd, count(*) n
    from base where created_on >= (date_trunc('week', p_to::timestamp) - interval '11 weeks')::date and created_on <= p_to
    group by 1
  )
  select jsonb_build_object(
    'period', jsonb_build_object('from', p_from, 'to', p_to),
    'total_usd', (select round(coalesce(sum(usd_amt),0)::numeric,0) from sel),
    'count', (select count(*) from sel),
    'prior_period', jsonb_build_object('total_usd', (select round(coalesce(sum(usd_amt),0)::numeric,0) from prior_win), 'count', (select count(*) from prior_win)),
    'by_office', (select coalesce(jsonb_agg(jsonb_build_object('k',k,'usd',usd,'n',n) order by usd desc),'[]'::jsonb)
        from (select office k, round(sum(usd_amt)::numeric,0) usd, count(*) n from sel group by 1) t),
    'by_client', (select coalesce(jsonb_agg(jsonb_build_object('k',k,'usd',usd) order by usd desc),'[]'::jsonb)
        from (select coalesce(nullif(billing_client_name,''),'(s/cliente)') k, round(sum(usd_amt)::numeric,0) usd from sel group by 1 order by sum(usd_amt) desc nulls last limit 10) t),
    'weekly_trend', (select coalesce(jsonb_agg(jsonb_build_object('week', wk, 'usd', usd, 'count', n) order by wk),'[]'::jsonb) from weekly)
  );
$function$;

CREATE OR REPLACE FUNCTION public.report_containers_external(p_from date, p_to date)
 RETURNS jsonb
 LANGUAGE sql
 STABLE
AS $function$
  with sel as (
    select * from wh_containers_external where etd >= p_from and etd <= p_to
  ),
  prior_win as (
    select * from wh_containers_external
    where etd >= (p_from - (p_to - p_from + 1)) and etd < p_from
  ),
  weekly as (
    select date_trunc('week', etd)::date as wk, count(*) n
    from wh_containers_external
    where etd >= (date_trunc('week', p_to::timestamp) - interval '11 weeks')::date and etd <= p_to
    group by 1
  )
  select jsonb_build_object(
    'measure', 'contenedores cargados FUERA de bodega, por ETD (fecha de zarpe)',
    'period', jsonb_build_object('from', p_from, 'to', p_to),
    'total', (select count(*) from sel),
    'prior_period', jsonb_build_object('total', (select count(*) from prior_win)),
    'by_status', (select coalesce(jsonb_agg(jsonb_build_object('k',k,'n',c) order by c desc),'[]'::jsonb)
                from (select coalesce(nullif(status,''),'(s/estado)') k, count(*) c from sel group by 1) t),
    'by_line', (select coalesce(jsonb_agg(jsonb_build_object('k',k,'n',c) order by c desc),'[]'::jsonb)
                from (select coalesce(nullif(shipping_line,''),'(s/línea)') k, count(*) c from sel group by 1) t),
    'by_port_of_loading', (select coalesce(jsonb_agg(jsonb_build_object('k',k,'n',c) order by c desc),'[]'::jsonb)
                from (select coalesce(nullif(port_of_loading,''),'(s/puerto)') k, count(*) c from sel group by 1) t),
    'by_destination', (select coalesce(jsonb_agg(jsonb_build_object('k',k,'n',c) order by c desc),'[]'::jsonb)
                from (select coalesce(nullif(destination,''),'(s/destino)') k, count(*) c from sel group by 1) t),
    'by_destination_agent', (select coalesce(jsonb_agg(jsonb_build_object('k',k,'n',c) order by c desc),'[]'::jsonb)
                from (select coalesce(nullif(destination_agent,''),'(s/agente)') k, count(*) c from sel group by 1) t),
    'weekly_trend', (select coalesce(jsonb_agg(jsonb_build_object('week', wk, 'containers', n) order by wk),'[]'::jsonb) from weekly)
  );
$function$;

CREATE OR REPLACE FUNCTION public.report_containers_loaded(p_from date, p_to date)
 RETURNS jsonb
 LANGUAGE sql
 STABLE
AS $function$
  with sel as (
    select *,
      nullif(trim(regexp_replace(upper(coalesce(name,'')), '\s*#?\s*[0-9]+\s*$', '')), '') as client_norm
    from wh_containers where load_date >= p_from and load_date <= p_to
  ),
  prior_win as (
    select * from wh_containers where load_date >= (p_from - (p_to - p_from + 1)) and load_date < p_from
  ),
  weekly as (
    select date_trunc('week', load_date)::date as wk, count(*) n, coalesce(sum(cbm_capacity),0)::numeric(12,1) cbm
    from wh_containers
    where load_date >= (date_trunc('week', p_to::timestamp) - interval '11 weeks')::date and load_date <= p_to
    group by 1
  )
  select jsonb_build_object(
    'period', jsonb_build_object('from', p_from, 'to', p_to),
    'total', (select count(*) from sel),
    'total_cbm_capacity', (select coalesce(sum(cbm_capacity),0)::numeric(12,1) from sel),
    'prior_period', jsonb_build_object('total', (select count(*) from prior_win), 'total_cbm_capacity', (select coalesce(sum(cbm_capacity),0)::numeric(12,1) from prior_win)),
    'by_type', (select coalesce(jsonb_agg(jsonb_build_object('k', k, 'n', c) order by c desc), '[]'::jsonb) from (select coalesce(nullif(container_type,''),'(s/tipo)') k, count(*) c from sel group by 1) t),
    'by_direction', (select coalesce(jsonb_agg(jsonb_build_object('k', k, 'n', c) order by c desc), '[]'::jsonb) from (select coalesce(nullif(trade_dir,''),'(s/dir)') k, count(*) c from sel group by 1) t),
    'by_line', (select coalesce(jsonb_agg(jsonb_build_object('k', k, 'n', c) order by c desc), '[]'::jsonb) from (select coalesce(nullif(shipping_line,''),'(s/línea)') k, count(*) c from sel group by 1) t),
    'by_client', (select coalesce(jsonb_agg(jsonb_build_object('k', k, 'n', c) order by c desc), '[]'::jsonb) from (select coalesce(client_norm,'(s/nombre)') k, count(*) c from sel group by 1 order by count(*) desc limit 12) t),
    'by_owner', (select coalesce(jsonb_agg(jsonb_build_object('k', k, 'n', c) order by c desc), '[]'::jsonb) from (select coalesce(nullif(owner,''),'(s/emp)') k, count(*) c from sel group by 1 order by count(*) desc limit 12) t),
    'by_loader', (select coalesce(jsonb_agg(jsonb_build_object('k', k, 'n', c) order by c desc), '[]'::jsonb) from (select coalesce(nullif(loader,''),'(s/loader)') k, count(*) c from sel group by 1) t),
    'weekly_trend', (select coalesce(jsonb_agg(jsonb_build_object('week', wk, 'containers', n, 'cbm', cbm) order by wk), '[]'::jsonb) from weekly)
  );
$function$;

CREATE OR REPLACE FUNCTION public.report_shipments(p_from date, p_to date, p_office text DEFAULT 'all'::text)
 RETURNS jsonb
 LANGUAGE sql
 STABLE
AS $function$
  with base as (
    select *,
      case company_id::text
        when 'd8b762a6-f66f-44de-bc44-2486ec1e2ae5' then 'Ecuador'
        when 'aba24859-159c-424b-8ef3-d122fba41b7c' then 'USA'
        when '9b807b51-5ee9-4a22-9e75-df90047ec12b' then 'Perú'
        when '20e7448c-4b80-443b-9903-6feaaf29cb1e' then 'Panamá'
        else 'Otra' end as office,
      case upper(coalesce(mode_of_transport,''))
        when '' then '(s/modo)' else upper(mode_of_transport) end as modo
    from magaya_transactions
    where transaction_type = 'SH'
      and (p_office = 'all' or company_id::text = p_office)
  ),
  sel as (select * from base where created_on >= p_from and created_on <= p_to),
  prior_win as (select * from base where created_on >= (p_from - (p_to - p_from + 1)) and created_on < p_from),
  weekly as (
    select date_trunc('week', created_on)::date wk, count(*) n
    from base where created_on >= (date_trunc('week', p_to::timestamp) - interval '11 weeks')::date and created_on <= p_to
    group by 1
  )
  select jsonb_build_object(
    'period', jsonb_build_object('from', p_from, 'to', p_to),
    'total', (select count(*) from sel),
    'prior_period', jsonb_build_object('total', (select count(*) from prior_win)),
    'by_office', (select coalesce(jsonb_agg(jsonb_build_object('k',k,'n',n) order by n desc),'[]'::jsonb)
        from (select office k, count(*) n from sel group by 1) t),
    'by_mode', (select coalesce(jsonb_agg(jsonb_build_object('k',k,'n',n) order by n desc),'[]'::jsonb)
        from (select modo k, count(*) n from sel group by 1) t),
    'by_destination', (select coalesce(jsonb_agg(jsonb_build_object('k',k,'n',n) order by n desc),'[]'::jsonb)
        from (select coalesce(nullif(destination_port,''),'(s/destino)') k, count(*) n from sel group by 1 order by count(*) desc limit 10) t),
    'by_carrier', (select coalesce(jsonb_agg(jsonb_build_object('k',k,'n',n) order by n desc),'[]'::jsonb)
        from (select coalesce(nullif(carrier_name,''),'(s/carrier)') k, count(*) n from sel group by 1 order by count(*) desc limit 10) t),
    'weekly_trend', (select coalesce(jsonb_agg(jsonb_build_object('week', wk, 'count', n) order by wk),'[]'::jsonb) from weekly)
  );
$function$;

CREATE OR REPLACE FUNCTION public.report_warehouse_received(p_from date, p_to date)
 RETURNS jsonb
 LANGUAGE sql
 STABLE
AS $function$
  with sel as (
    select *, case when upper(coalesce(trade_dir,'')) = 'IMPORT' then 'IMPORT' else 'EXPORT' end as dir2
    from v_wh_receipts where created_on >= p_from and created_on <= p_to
  ),
  prior_win as (
    select *, case when upper(coalesce(trade_dir,'')) = 'IMPORT' then 'IMPORT' else 'EXPORT' end as dir2
    from v_wh_receipts where created_on >= (p_from - (p_to - p_from + 1)) and created_on < p_from
  ),
  weekly as (
    select date_trunc('week', created_on)::date as wk,
       coalesce(sum(cbm) filter (where upper(coalesce(trade_dir,'')) <> 'IMPORT'),0)::numeric(12,1) export_cbm,
       coalesce(sum(cbm) filter (where upper(coalesce(trade_dir,'')) = 'IMPORT'),0)::numeric(12,1) import_cbm,
       count(*) filter (where upper(coalesce(trade_dir,'')) <> 'IMPORT') export_wrs,
       count(*) filter (where upper(coalesce(trade_dir,'')) = 'IMPORT') import_wrs,
       coalesce(sum(pieces) filter (where upper(coalesce(trade_dir,'')) <> 'IMPORT'),0)::bigint export_pieces,
       coalesce(sum(pieces) filter (where upper(coalesce(trade_dir,'')) = 'IMPORT'),0)::bigint import_pieces
    from v_wh_receipts
    where created_on >= (date_trunc('week', p_to::timestamp) - interval '11 weeks')::date and created_on <= p_to
    group by 1
  ),
  cons as (
    select coalesce(nullif(consignee,''),'(s/consignee)') k, dir2, round(sum(cbm)::numeric,1) v
    from sel group by 1,2
  )
  select jsonb_build_object(
    'period', jsonb_build_object('from', p_from, 'to', p_to),
    'total_wrs', (select count(*) from sel),
    'total_cbm', (select coalesce(sum(cbm),0)::numeric(12,1) from sel),
    'total_pieces', (select coalesce(sum(pieces),0)::bigint from sel),
    'export', jsonb_build_object('wrs',(select count(*) from sel where dir2='EXPORT'),'cbm',(select coalesce(sum(cbm),0)::numeric(12,1) from sel where dir2='EXPORT'),'pieces',(select coalesce(sum(pieces),0)::bigint from sel where dir2='EXPORT'),'prior_cbm',(select coalesce(sum(cbm),0)::numeric(12,1) from prior_win where dir2='EXPORT')),
    'import', jsonb_build_object('wrs',(select count(*) from sel where dir2='IMPORT'),'cbm',(select coalesce(sum(cbm),0)::numeric(12,1) from sel where dir2='IMPORT'),'pieces',(select coalesce(sum(pieces),0)::bigint from sel where dir2='IMPORT'),'prior_cbm',(select coalesce(sum(cbm),0)::numeric(12,1) from prior_win where dir2='IMPORT')),
    'prior_total_cbm', (select coalesce(sum(cbm),0)::numeric(12,1) from prior_win),
    'consignees_export', (select coalesce(jsonb_agg(jsonb_build_object('k',k,'cbm',v) order by v desc),'[]'::jsonb) from (select k,v from cons where dir2='EXPORT' order by v desc nulls last limit 8) t),
    'consignees_import', (select coalesce(jsonb_agg(jsonb_build_object('k',k,'cbm',v) order by v desc),'[]'::jsonb) from (select k,v from cons where dir2='IMPORT' order by v desc nulls last limit 8) t),
    'consignees_all', (select coalesce(jsonb_agg(jsonb_build_object('k',k,'cbm',v) order by v desc),'[]'::jsonb) from (select k, sum(v) v from cons group by k order by sum(v) desc nulls last limit 8) t),
    'weekly_trend', (select coalesce(jsonb_agg(jsonb_build_object('week', wk, 'export_cbm', export_cbm, 'import_cbm', import_cbm, 'export_wrs', export_wrs, 'import_wrs', import_wrs, 'export_pieces', export_pieces, 'import_pieces', import_pieces) order by wk),'[]'::jsonb) from weekly)
  );
$function$;

CREATE OR REPLACE FUNCTION public.restore_client(p_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions', 'pg_catalog'
AS $function$
declare
  v_uid      uuid := auth.uid();
  v_role     text;
  v_conflict text;
begin
  if v_uid is null then raise exception 'No autenticado'; end if;
  select u.role into v_role from public.users u where u.auth_user_id = v_uid;
  if v_role is null or v_role not in ('Admin','Administration') then
    raise exception 'Solo Admin / Administration puede restaurar clientes';
  end if;

  select c2.company_name into v_conflict
    from public.clients c
    join public.clients c2
      on c2.deleted_at is null
     and c2.id <> c.id
     and c2.ruc = c.ruc
   where c.id = p_id
     and coalesce(c.ruc, '') <> ''
   limit 1;
  if v_conflict is not null then
    raise exception 'No se puede restaurar: su RUC ya pertenece al cliente activo "%". Corrige el RUC de ese cliente primero.', v_conflict;
  end if;

  update public.clients
     set deleted_at = null,
         deleted_by = null
   where id = p_id and deleted_at is not null;
end $function$;

CREATE OR REPLACE FUNCTION public.search_client_duplicates(p_company_name text, p_email text DEFAULT NULL::text, p_phone text DEFAULT NULL::text)
 RETURNS TABLE(id uuid, company_name text, office text, email text, phone text, similarity_score double precision)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions', 'pg_temp'
AS $function$
BEGIN
RETURN QUERY
SELECT 
c.id,
c.company_name,
c.office,
ct.email,
ct.phone,
GREATEST(
similarity(c.company_name, p_company_name),
CASE WHEN p_email IS NOT NULL AND ct.email IS NOT NULL 
THEN similarity(ct.email, p_email) 
ELSE 0 END,
CASE WHEN p_phone IS NOT NULL AND ct.phone IS NOT NULL 
THEN similarity(ct.phone, p_phone) 
ELSE 0 END
) as similarity_score
FROM clients c
LEFT JOIN contacts ct ON ct.client_id = c.id AND ct.is_primary = true
WHERE 
similarity(c.company_name, p_company_name) > 0.3
OR (p_email IS NOT NULL AND ct.email IS NOT NULL AND similarity(ct.email, p_email) > 0.5)
OR (p_phone IS NOT NULL AND ct.phone IS NOT NULL AND similarity(ct.phone, p_phone) > 0.5)
ORDER BY similarity_score DESC
LIMIT 10;
END;
$function$;

CREATE OR REPLACE FUNCTION public.search_warehouse_receipts(p_query text, p_from date DEFAULT NULL::date, p_to date DEFAULT NULL::date, p_limit integer DEFAULT 25)
 RETURNS jsonb
 LANGUAGE sql
 STABLE
AS $function$
  with params as (
    select trim(p_query) as q,
           lower(regexp_replace(p_query, '[^a-zA-Z0-9]', '', 'g')) as qn
  ),
  base as (
    select w.*,
      lower(regexp_replace(coalesce(w.shipper,''), '[^a-zA-Z0-9]', '', 'g')) sn,
      lower(regexp_replace(coalesce(w.consignee,''), '[^a-zA-Z0-9]', '', 'g')) cn,
      lower(regexp_replace(coalesce(w.billing_client,''), '[^a-zA-Z0-9]', '', 'g')) bn,
      lower(regexp_replace(coalesce(w.destination_agent,''), '[^a-zA-Z0-9]', '', 'g')) dn
    from magaya_warehouse_receipts w
    where (p_from is null or w.created_on::date >= p_from)
      and (p_to   is null or w.created_on::date <= p_to)
  ),
  matched as (
    select b.*,
      greatest(
        word_similarity((select qn from params), b.sn),
        word_similarity((select qn from params), b.cn),
        word_similarity((select qn from params), b.bn),
        word_similarity((select qn from params), b.dn)
      ) as sim
    from base b, params p
    where
      (p.q ~ '^[0-9 ,]+$' and b.wr_number = any(string_to_array(regexp_replace(p.q,'[ ,]+',',','g'), ',')))
      or
      (p.q !~ '^[0-9 ,]+$' and (
        b.sn like '%'||p.qn||'%' or b.cn like '%'||p.qn||'%' or b.bn like '%'||p.qn||'%' or b.dn like '%'||p.qn||'%'
        or word_similarity(p.qn, b.sn) > 0.5 or word_similarity(p.qn, b.cn) > 0.5
        or word_similarity(p.qn, b.bn) > 0.5 or word_similarity(p.qn, b.dn) > 0.5
      ))
  )
  select jsonb_build_object(
    'query', (select q from params),
    'count', (select count(*) from matched),
    'results', (select coalesce(jsonb_agg(r), '[]'::jsonb) from (
      select jsonb_build_object(
        'wr_number', wr_number,
        'created_on', created_on,
        'status', status,
        'shipper', shipper,
        'consignee', consignee,
        'billing_client', billing_client,
        'destination_agent', destination_agent,
        'pieces', pieces,
        'weight_lb', round(coalesce(weight,0)::numeric,0),
        'cbm', round(coalesce(cbm,0)::numeric,2),
        'carrier', carrier,
        'tracking_number', tracking_number,
        'origin', origin,
        'destination', destination,
        'destination_port', destination_port,
        'location', location_code,
        'warehouse_zone', warehouse_zone,
        'entry_date', entry_date,
        'out_date', out_date,
        'cargo_release', cargo_release_number,
        'has_attachments', has_attachments,
        'notes', left(coalesce(notes,''), 300),
        'match_score', round(sim::numeric, 2)
      ) as r
      from matched
      order by sim desc, created_on desc
      limit p_limit
    ) t)
  );
$function$;

CREATE OR REPLACE FUNCTION public.shipco_current_office()
 RETURNS text
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select u.office from public.users u where u.auth_user_id = auth.uid() limit 1
$function$;

CREATE OR REPLACE FUNCTION public.shipco_load_rates(sync_token text, dests jsonb, rates jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare v_expected text; v_rates int; v_dests int;
begin
  select value #>> '{}' into v_expected from shipco_settings where key = 'sync_token';
  if v_expected is null or sync_token is distinct from v_expected then
    raise exception 'invalid sync token';
  end if;
  if jsonb_array_length(dests) < 100 or jsonb_array_length(rates) < 1000 then
    raise exception 'payload too small (dests=%, rates=%) — refusing to replace',
      jsonb_array_length(dests), jsonb_array_length(rates);
  end if;
  delete from shipco_destinations where true;
  insert into shipco_destinations (destination_code, origin_code, destination_label, country_iso2, region, transit_days)
  select d->>'destination_code', coalesce(d->>'origin_code', 'USMIA'),
         coalesce(d->>'destination_label', d->>'destination_code'),
         d->>'country_iso2', d->>'region', nullif(d->>'transit_days','')::int
    from jsonb_array_elements(dests) d;
  delete from shipco_rates where true;
  insert into shipco_rates (origin_code, destination_code, type, charge_code, currency, rate,
                            rate_basis, minimum, maximum, uom, from_qty, to_qty,
                            effective_date, expiration_date)
  select coalesce(r->>'origin', 'USMIA'), r->>'destination', coalesce(r->>'type', 'OFR'),
         r->>'charge_code', coalesce(r->>'currency', 'USD'), (r->>'rate')::numeric,
         coalesce(r->>'basis', 'WM'), nullif(r->>'minimum','')::numeric,
         nullif(r->>'maximum','')::numeric, r->>'uom',
         nullif(r->>'from','')::numeric, nullif(r->>'to','')::numeric,
         coalesce(nullif(r->>'effective',''), '2026-01-01')::date,
         coalesce(nullif(r->>'expiration',''), '2026-12-31')::date
    from jsonb_array_elements(rates) r
   where r->>'rate' is not null and r->>'basis' is not null;
  get diagnostics v_rates = row_count;
  select count(*) into v_dests from shipco_destinations;
  return jsonb_build_object('destinations', v_dests, 'rates', v_rates);
end $function$;

CREATE OR REPLACE FUNCTION public.shipco_quote(p_dest text, p_length_in numeric, p_width_in numeric, p_height_in numeric, p_weight_lb numeric, p_qty integer DEFAULT 1, p_margin_pct numeric DEFAULT NULL::numeric)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_office text; v_is_usa boolean; v_default_margin numeric; v_margin numeric;
begin
  v_office := public.shipco_current_office();
  if v_office is null then
    return jsonb_build_object('ok', false, 'error', 'not_registered');
  end if;
  v_is_usa := (v_office = 'USA');
  select (value #>> '{}')::numeric into v_default_margin
    from shipco_settings where key = 'default_margin_pct';
  v_margin := case when v_is_usa then coalesce(p_margin_pct, v_default_margin, 20)
                   else coalesce(v_default_margin, 20) end;
  return public.shipco_quote_core(p_dest, p_length_in, p_width_in, p_height_in,
                                  p_weight_lb, p_qty, v_margin, v_is_usa);
end $function$;

CREATE OR REPLACE FUNCTION public.shipco_quote_core(p_dest text, p_length_in numeric, p_width_in numeric, p_height_in numeric, p_weight_lb numeric, p_qty integer, p_margin_pct numeric, p_include_cost boolean)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_qty int := greatest(coalesce(p_qty, 1), 1);
begin
  if p_length_in is null or p_width_in is null or p_height_in is null
     or p_length_in <= 0 or p_width_in <= 0 or p_height_in <= 0 then
    return jsonb_build_object('ok', false, 'error', 'invalid_dimensions');
  end if;
  return public.shipco_quote_core_totals(
    p_dest,
    (p_length_in * 0.0254) * (p_width_in * 0.0254) * (p_height_in * 0.0254) * v_qty,
    coalesce(p_weight_lb, 0) * 0.45359237 * v_qty,
    p_margin_pct, p_include_cost);
end $function$;

CREATE OR REPLACE FUNCTION public.shipco_quote_core_totals(p_dest text, p_cbm numeric, p_actual_kg numeric, p_margin_pct numeric, p_include_cost boolean)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_today date := current_date;
  v_cbm numeric := p_cbm; v_actual_kg numeric := coalesce(p_actual_kg, 0);
  v_vol_kg numeric; v_charg_kg numeric; v_tonnes numeric; v_actual_lb numeric; v_ref numeric;
  v_ofr record; v_dest record; r record;
  v_amount numeric; v_ofr_amount numeric; v_ofr_raw numeric;
  v_subtotal numeric; v_margin numeric; v_total numeric;
  v_surcharges jsonb := '[]'::jsonb;
  v_min_applied boolean := false;
begin
  if v_cbm is null or v_cbm <= 0 then
    return jsonb_build_object('ok', false, 'error', 'invalid_dimensions');
  end if;
  v_vol_kg := v_cbm * 1000;
  v_charg_kg := greatest(v_actual_kg, v_vol_kg);
  v_tonnes := v_charg_kg / 1000.0;
  v_actual_lb := v_actual_kg * 2.20462262;

  select * into v_dest from shipco_destinations where destination_code = p_dest;

  select * into v_ofr from shipco_rates
   where destination_code = p_dest and charge_code = 'OFR'
     and effective_date <= v_today and expiration_date >= v_today
     and (from_qty is null or (case when uom = 'CBM' then v_cbm else v_charg_kg end) >= from_qty)
     and (to_qty   is null or (case when uom = 'CBM' then v_cbm else v_charg_kg end) <= to_qty)
   order by coalesce(from_qty, -1), id limit 1;
  if v_ofr is null then
    select * into v_ofr from shipco_rates
     where destination_code = p_dest and charge_code = 'OFR'
       and effective_date <= v_today and expiration_date >= v_today
     order by coalesce(from_qty, -1), id limit 1;
  end if;
  if v_ofr is null then
    return jsonb_build_object('ok', false, 'error', 'no_rates',
      'destination', p_dest, 'label', coalesce(v_dest.destination_label, p_dest));
  end if;

  v_ofr_raw := case v_ofr.rate_basis
    when 'W'  then v_ofr.rate * v_tonnes
    when 'M'  then v_ofr.rate * v_cbm
    when 'WM' then v_ofr.rate * greatest(v_tonnes, v_cbm)
    else v_ofr.rate end;
  v_ofr_amount := v_ofr_raw;
  if v_ofr.minimum is not null and v_ofr_amount < v_ofr.minimum then
    v_ofr_amount := v_ofr.minimum; v_min_applied := true;
  end if;
  if v_ofr.maximum is not null and v_ofr_amount > v_ofr.maximum then
    v_ofr_amount := v_ofr.maximum;
  end if;
  v_subtotal := v_ofr_amount;

  for r in
    select * from shipco_rates
     where destination_code = p_dest and charge_code not in ('OFR', 'HAZ')
       and effective_date <= v_today and expiration_date >= v_today
     order by charge_code, coalesce(from_qty, -1), id
  loop
    v_ref := case when r.charge_code = 'DEN' then v_actual_lb
                  when r.uom = 'CBM' then v_cbm
                  else v_charg_kg end;
    if (r.from_qty is not null and v_ref < r.from_qty)
       or (r.to_qty is not null and v_ref > r.to_qty) then
      continue;
    end if;
    v_amount := case r.rate_basis
      when 'W'  then r.rate * v_tonnes
      when 'M'  then r.rate * v_cbm
      when 'WM' then r.rate * greatest(v_tonnes, v_cbm)
      else r.rate end;
    if r.minimum is not null and v_amount < r.minimum then v_amount := r.minimum; end if;
    if r.maximum is not null and v_amount > r.maximum then v_amount := r.maximum; end if;
    v_subtotal := v_subtotal + v_amount;
    v_surcharges := v_surcharges || jsonb_build_object('code', r.charge_code, 'amount', round(v_amount, 2));
  end loop;

  v_margin := v_subtotal * (coalesce(p_margin_pct, 20) / 100.0);
  v_total := v_subtotal + v_margin;

  return jsonb_build_object(
    'ok', true,
    'destination', p_dest,
    'label', coalesce(v_dest.destination_label, p_dest),
    'transit_days', v_dest.transit_days,
    'metrics', jsonb_build_object(
      'cbm', round(v_cbm, 3), 'actual_kg', round(v_actual_kg, 1),
      'volumetric_kg', round(v_vol_kg, 1), 'chargeable_kg', round(v_charg_kg, 1)),
    'minimum_applied', v_min_applied,
    'validity', jsonb_build_object('effective', v_ofr.effective_date, 'expiration', v_ofr.expiration_date),
    'total_usd', round(v_total, 2),
    'currency', 'USD',
    'cost', case when p_include_cost then jsonb_build_object(
      'ofr_usd', round(v_ofr_amount, 2),
      'surcharges', v_surcharges,
      'subtotal_usd', round(v_subtotal, 2),
      'margin_pct', coalesce(p_margin_pct, 20),
      'margin_usd', round(v_margin, 2)) else null end
  );
end $function$;

CREATE OR REPLACE FUNCTION public.shipco_quote_pieces(p_dest text, p_pieces jsonb, p_margin_pct numeric DEFAULT NULL::numeric)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_office text; v_is_usa boolean; v_default_margin numeric; v_margin numeric;
  v_cbm numeric := 0; v_kg numeric := 0; v_n int := 0;
  pc record; v_res jsonb;
begin
  v_office := public.shipco_current_office();
  if v_office is null then
    return jsonb_build_object('ok', false, 'error', 'not_registered');
  end if;
  v_is_usa := (v_office = 'USA');
  if p_pieces is null or jsonb_typeof(p_pieces) <> 'array' or jsonb_array_length(p_pieces) = 0 then
    return jsonb_build_object('ok', false, 'error', 'invalid_pieces');
  end if;
  for pc in
    select (e->>'length_in')::numeric as l, (e->>'width_in')::numeric as w,
           (e->>'height_in')::numeric as h, coalesce((e->>'weight_lb')::numeric, 0) as wt,
           greatest(coalesce((e->>'qty')::int, 1), 1) as q
    from jsonb_array_elements(p_pieces) e
  loop
    if pc.l is null or pc.w is null or pc.h is null or pc.l <= 0 or pc.w <= 0 or pc.h <= 0 then
      return jsonb_build_object('ok', false, 'error', 'invalid_dimensions');
    end if;
    v_cbm := v_cbm + (pc.l * 0.0254) * (pc.w * 0.0254) * (pc.h * 0.0254) * pc.q;
    v_kg  := v_kg + pc.wt * 0.45359237 * pc.q;
    v_n   := v_n + pc.q;
  end loop;
  select (value #>> '{}')::numeric into v_default_margin
    from shipco_settings where key = 'default_margin_pct';
  v_margin := case when v_is_usa then coalesce(p_margin_pct, v_default_margin, 20)
                   else coalesce(v_default_margin, 20) end;
  v_res := public.shipco_quote_core_totals(p_dest, v_cbm, v_kg, v_margin, v_is_usa);
  return v_res || jsonb_build_object('pieces', v_n);
end $function$;

CREATE OR REPLACE FUNCTION public.shipment_borrar(p_shipment_id uuid, p_definitivo boolean DEFAULT false)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  s          record;
  v_houses   int;
  v_lineas   int;
  v_hbl      int;
  v_docs     int;
  v_fact     int;
  v_estorbos text[] := '{}';
begin
  -- Solo Admin. No se usa app_can() a propósito: borrar no es una página del
  -- menú, es una facultad del administrador.
  if not public.app_user_is_admin() then
    raise exception 'solo un administrador puede borrar embarques';
  end if;

  select * into s from shipments where id = p_shipment_id;
  if not found then
    return jsonb_build_object('error', 'ese embarque no existe');
  end if;

  select count(*) into v_houses from shipments where master_shipment_id = p_shipment_id;
  select count(*) into v_lineas from consolidado_lineas where shipment_id = p_shipment_id;
  select count(*) into v_hbl    from ops_hbl where shipment_id = p_shipment_id;
  select count(*) into v_docs   from ops_documents where shipment_id = p_shipment_id;
  select count(*) into v_fact   from fact_orders where shipment_id = p_shipment_id;

  if v_houses > 0 then v_estorbos := v_estorbos || (v_houses || ' house(s) colgando'); end if;
  if v_lineas > 0 then v_estorbos := v_estorbos || (v_lineas || ' linea(s) de consolidado'); end if;
  if v_hbl    > 0 then v_estorbos := v_estorbos || (v_hbl    || ' HBL emitido(s)'); end if;
  if v_docs   > 0 then v_estorbos := v_estorbos || (v_docs   || ' documento(s)'); end if;
  if v_fact   > 0 then v_estorbos := v_estorbos || (v_fact   || ' orden(es) de facturacion'); end if;

  if array_length(v_estorbos, 1) > 0 then
    return jsonb_build_object(
      'error', 'no se puede borrar: el embarque tiene ' || array_to_string(v_estorbos, ', ') ||
               '. Hay que desarmarlo primero.',
      'estorbos', to_jsonb(v_estorbos));
  end if;

  if p_definitivo then
    -- El correo que lo originó vuelve a quedar suelto, no se borra.
    update ops_inbound_emails
       set shipment_id = null, si_estado = case when si_estado = 'CONVERTIDA' then 'PENDIENTE' else si_estado end
     where shipment_id = p_shipment_id;
    delete from shipments where id = p_shipment_id;
    return jsonb_build_object('ok', true, 'accion', 'borrado definitivo',
                              'shipment_code', s.shipment_code);
  end if;

  update shipments
     set archived_at = now(), archived_by = public.app_current_user_id(), updated_at = now()
   where id = p_shipment_id;

  return jsonb_build_object('ok', true, 'accion', 'archivado',
                            'shipment_code', s.shipment_code,
                            'nota', 'queda archivado; para borrarlo definitivamente, repetir con definitivo = true');
end;
$function$;

CREATE OR REPLACE FUNCTION public.shipment_restaurar(p_shipment_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  if not public.app_user_is_admin() then
    raise exception 'solo un administrador puede restaurar embarques';
  end if;
  update shipments set archived_at = null, archived_by = null, updated_at = now()
   where id = p_shipment_id;
  if not found then return jsonb_build_object('error', 'ese embarque no existe'); end if;
  return jsonb_build_object('ok', true);
end;
$function$;

CREATE OR REPLACE FUNCTION public.shipment_to_office(p_direction text, p_origin text, p_destination text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
 SET search_path TO 'public', 'pg_catalog'
AS $function$
  select case
    -- Para imports el office es el destino (donde llega)
    when p_direction in ('Import','Importation') then
      public.wr_destination_to_office(p_destination, null)
    -- Para exports el office es el origen (donde sale)
    when p_direction in ('Export','Exportation') then
      public.wr_destination_to_office(p_origin, null)
    -- Cross-trade y otros: probar destino primero, luego origen
    else coalesce(
      public.wr_destination_to_office(p_destination, null),
      public.wr_destination_to_office(p_origin, null)
    )
  end;
$function$;

CREATE OR REPLACE FUNCTION public.shipments_set_defaults()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
declare
  v_cs uuid;
  v_first_exec uuid;
  v_role text;
  v_sees_directos boolean := false;
  v_client_has_exec boolean := true;
  v_caller_explicit boolean := (new.cs_assigned_to is not null);
begin
  if new.client_id is not null then
    select c.assigned_to is not null
      into v_client_has_exec
      from public.clients c where c.id = new.client_id;
    -- Heredar desde cliente SOLO si el caller no fue explícito
    if not v_caller_explicit and (new.sales_executive_id is null or new.office is null) then
      select c.assigned_to, coalesce(new.office, c.office)
        into new.sales_executive_id, new.office
        from public.clients c where c.id = new.client_id;
    end if;
    if new.office is null then
      select c.office into new.office from public.clients c where c.id = new.client_id;
    end if;
  end if;

  -- LA PROPIEDAD ES DE QUIEN CREA (Andres, 29-jul). Ultimo recurso: si nadie
  -- dijo la oficina, es la de quien esta creando el embarque. La geografia
  -- (puerto de origen/destino) no tiene nada que ver con esto.
  if new.office is null then
    select u.office into new.office
      from public.users u where u.auth_user_id = auth.uid() limit 1;
  end if;

  if not v_caller_explicit and new.sales_executive_id is null then
    select role into v_role from public.users where auth_user_id = auth.uid() limit 1;
    if v_role = 'Customer Service' then
      select exists (
        select 1 from public.cs_assignments ca
        join public.users u on u.id = ca.cs_user_id
        where u.auth_user_id = auth.uid() and ca.is_directos = true and coalesce(ca.active, true) = true
      ) into v_sees_directos;
      if not (v_sees_directos and not v_client_has_exec) then
        select sales_executive_id into v_first_exec
          from public.cs_assignments ca
          join public.users u on u.id = ca.cs_user_id
          where u.auth_user_id = auth.uid()
            and ca.active and ca.sales_executive_id is not null
          order by is_primary desc nulls last
          limit 1;
        new.sales_executive_id := v_first_exec;
      end if;
    end if;
  end if;

  -- LA CS DEL CLIENTE MANDA (14-ago-2026). Si el cliente tiene CS dedicada
  -- (clients.customer_service_id — la inhouse, o la CS de cartera), el
  -- embarque va con ella, no con la CS primaria de la ejecutiva. Solo cuando
  -- nadie dijo CS explícitamente.
  if new.cs_assigned_to is null and new.client_id is not null then
    select c.customer_service_id into v_cs
      from public.clients c where c.id = new.client_id;
    new.cs_assigned_to := v_cs;
    v_cs := null;
  end if;

  if new.cs_assigned_to is null and new.sales_executive_id is not null then
    select cs_user_id into v_cs from public.cs_assignments
     where sales_executive_id = new.sales_executive_id and active and is_primary
     limit 1;
    new.cs_assigned_to := v_cs;
  end if;

  if new.cs_assigned_to is null and new.sales_executive_id is not null then
    if exists (
      select 1 from public.users u
       where u.id = new.sales_executive_id and coalesce(u.is_junior_exec, false)
    ) then
      new.cs_assigned_to := new.sales_executive_id;
    end if;
  end if;

  -- Embarque DIRECTOS (sin ejecutiva): a la CS que lo armó. Antes iba SIEMPRE a
  -- la de bandera más antigua, y con dos personas con bandera eso le mandaba a
  -- una la carga freehand de la otra.
  if new.cs_assigned_to is null and new.sales_executive_id is null and new.office is not null then
    select ca.cs_user_id into v_cs
    from public.cs_assignments ca
    join public.users u on u.id = ca.cs_user_id
    where ca.is_directos = true and coalesce(ca.active, true) = true and u.office = new.office
    order by (u.id = new.created_by) desc nulls last,
             ca.created_at asc
    limit 1;
    new.cs_assigned_to := v_cs;
  end if;

  if new.shipment_code is null then
    new.shipment_code := 'SHP-' || to_char(coalesce(new.created_at, now()),'YYYYMM') || '-' || substr(new.id::text,1,8);
  end if;
  return new;
end $function$;

CREATE OR REPLACE FUNCTION public.smoke_test_sales_exec_create_client()
 RETURNS TABLE(ok boolean, elapsed_ms numeric, error_message text)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions', 'pg_catalog'
AS $function$
declare
  v_iliana_id        uuid;
  v_iliana_auth_uid  uuid;
  v_start            timestamptz;
  v_new_id           uuid;
begin
  select id, auth_user_id into v_iliana_id, v_iliana_auth_uid
    from public.users where name='Iliana Caice' limit 1;

  if v_iliana_id is null then
    ok := false; elapsed_ms := 0;
    error_message := 'No user named "Iliana Caice" — pick another Sales Exec for the smoke test.';
    return next; return;
  end if;

  v_start := clock_timestamp();
  begin
    insert into public.clients (
      company_name, client_type, office, status, ruc, assigned_to, is_direct
    ) values (
      '__SMOKE_TEST__ ' || extract(epoch from now())::text,
      'direct_client', 'Ecuador', 'Active',
      '0999' || lpad((random()*9999999)::int::text, 7, '0') || '001',
      v_iliana_id, false
    ) returning id into v_new_id;
    -- immediately delete so the test row never lingers
    delete from public.clients where id = v_new_id;
    ok := true;
    elapsed_ms := round(extract(milliseconds from (clock_timestamp() - v_start))::numeric, 1);
    error_message := null;
  exception when others then
    ok := false;
    elapsed_ms := round(extract(milliseconds from (clock_timestamp() - v_start))::numeric, 1);
    error_message := sqlerrm;
  end;
  return next;
end $function$;

CREATE OR REPLACE FUNCTION public.soft_delete_client(p_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions', 'pg_catalog'
AS $function$
declare
  v_uid          uuid := auth.uid();
  v_user_id      uuid;
  v_user_role    text;
  v_user_office  text;
  v_assigned     uuid;
  v_account_mgr  uuid;
  v_office       text;
  v_is_direct    boolean;
  v_already_del  timestamptz;
begin
  if v_uid is null then raise exception 'No autenticado'; end if;

  select u.id, u.role, u.office into v_user_id, v_user_role, v_user_office
    from public.users u where u.auth_user_id = v_uid;

  select c.assigned_to, c.account_manager_id, c.office, c.is_direct, c.deleted_at
    into v_assigned, v_account_mgr, v_office, v_is_direct, v_already_del
    from public.clients c where c.id = p_id;

  if v_user_id is null or v_office is null then
    raise exception 'Cliente no encontrado o tu usuario no está activo';
  end if;
  if v_already_del is not null then return; end if; -- idempotent

  -- Permission: same logic as the UPDATE RLS policy plus is_direct guard.
  if not (
       v_user_role = any (array['Admin','VP'])
    or (v_user_role = any (array['Manager','Administration']) and v_office = v_user_office)
    or (v_assigned = v_user_id and v_user_role = 'Sales Executive' and v_is_direct = false)
    or (v_account_mgr = v_user_id)
    or public.has_delegation_to(v_assigned)
    or public.has_delegation_to(v_account_mgr)
  ) then
    raise exception 'No tienes permiso para mover este cliente a la papelera';
  end if;

  update public.clients
     set deleted_at = now(),
         deleted_by = v_user_id
   where id = p_id;
end $function$;

CREATE OR REPLACE FUNCTION public.sync_cr_items_to_wh_report()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public', 'pg_catalog'
AS $function$
DECLARE
  v_cr RECORD;
  v_wr RECORD;
  v_client RECORD;
  v_movement_id uuid;
  v_product_id uuid;
  v_wr_number text;
BEGIN
  -- 1. Get the CR details
  SELECT id, cr_number, consignee, shipper, created_on, pieces, tracking_number
  INTO v_cr
  FROM magaya_cargo_releases
  WHERE id = NEW.cr_id;
  
  IF v_cr.id IS NULL THEN
    RETURN NEW;
  END IF;
  
  -- 2. CRs don't have consignee filled. Link via tracking_number -> WR -> consignee
  -- tracking_number format: "88EE-{wr_number}-XX"
  v_wr_number := SPLIT_PART(v_cr.tracking_number, '-', 2);
  
  IF v_wr_number IS NOT NULL AND v_wr_number != '' THEN
    SELECT id, consignee INTO v_wr
    FROM magaya_warehouse_receipts
    WHERE wr_number = v_wr_number
    LIMIT 1;
    
    IF v_wr.id IS NOT NULL THEN
      -- Match WR consignee to wh_report_client
      SELECT id INTO v_client
      FROM wh_report_clients
      WHERE active = true 
        AND v_wr.consignee ILIKE consignee_name
      LIMIT 1;
    END IF;
  END IF;
  
  -- If no client found via WR link, skip
  IF v_client.id IS NULL THEN
    RETURN NEW;
  END IF;
  
  -- 3. Find or create the movement record
  SELECT id INTO v_movement_id
  FROM wh_report_movements
  WHERE magaya_cr_id = v_cr.id;
  
  IF v_movement_id IS NULL THEN
    INSERT INTO wh_report_movements (
      client_id, date, movement_type, reference_number,
      container_number, total_pallets, source, magaya_cr_id
    ) VALUES (
      v_client.id,
      COALESCE(v_cr.created_on, CURRENT_DATE),
      'OUT',
      v_cr.cr_number,
      v_cr.tracking_number,
      v_cr.pieces,
      'magaya_auto',
      v_cr.id
    )
    RETURNING id INTO v_movement_id;
  END IF;
  
  -- 4. Map item_description to product
  SELECT pm.product_id INTO v_product_id
  FROM wh_report_product_mappings pm
  WHERE pm.client_id = v_client.id
    AND pm.active = true
    AND NEW.item_description ILIKE pm.magaya_pattern
  ORDER BY pm.priority DESC
  LIMIT 1;
  
  -- 5. If product mapped, create movement item (negative quantity for OUT)
  IF v_product_id IS NOT NULL AND NEW.quantity IS NOT NULL AND NEW.quantity > 0 THEN
    IF NOT EXISTS (
      SELECT 1 FROM wh_report_movement_items 
      WHERE movement_id = v_movement_id AND product_id = v_product_id
    ) THEN
      INSERT INTO wh_report_movement_items (movement_id, product_id, quantity)
      VALUES (v_movement_id, v_product_id, -(NEW.quantity::integer));
    ELSE
      UPDATE wh_report_movement_items 
      SET quantity = quantity - NEW.quantity::integer
      WHERE movement_id = v_movement_id AND product_id = v_product_id;
    END IF;
  END IF;
  
  -- 6. Log unmapped items
  IF v_product_id IS NULL AND NEW.item_description IS NOT NULL THEN
    INSERT INTO wh_report_sync_log (
      source_table, source_id, client_id, item_description, status, message
    ) VALUES (
      'magaya_cr_items', NEW.id, v_client.id, NEW.item_description,
      'unmapped', 'No product mapping found for: ' || NEW.item_description
    )
    ON CONFLICT DO NOTHING;
  END IF;
  
  RETURN NEW;
END;
$function$;

CREATE OR REPLACE FUNCTION public.sync_wr_items_to_wh_report()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public', 'pg_catalog'
AS $function$
DECLARE
  v_wr RECORD;
  v_client RECORD;
  v_movement RECORD;
  v_movement_id uuid;
  v_product_id uuid;
  v_box_count integer;
  v_standard integer;
  v_is_incomplete boolean := false;
BEGIN
  -- 1. Get WR details
  SELECT id, wr_number, consignee, created_on, pieces, tracking_number INTO v_wr
  FROM magaya_warehouse_receipts WHERE id = NEW.wr_id;
  IF v_wr.id IS NULL THEN RETURN NEW; END IF;

  -- 2. Match consignee to client
  SELECT id INTO v_client FROM wh_report_clients
  WHERE active = true AND v_wr.consignee ILIKE consignee_name LIMIT 1;
  IF v_client.id IS NULL THEN RETURN NEW; END IF;

  -- 3. Find existing movement (by magaya_wr_id) or create new one
  SELECT id, source INTO v_movement FROM wh_report_movements WHERE magaya_wr_id = v_wr.id;
  
  IF v_movement.id IS NOT NULL THEN
    v_movement_id := v_movement.id;
    -- If this movement was from excel_import, DON'T modify its items
    -- The excel data is the source of truth for historical movements
    IF v_movement.source = 'excel_import' THEN
      RETURN NEW;
    END IF;
  ELSE
    -- Create new movement
    INSERT INTO wh_report_movements (client_id, date, movement_type, reference_number, container_number, total_pallets, source, magaya_wr_id)
    VALUES (v_client.id, COALESCE(v_wr.created_on, CURRENT_DATE), 'IN', v_wr.wr_number, COALESCE(NEW.container_number, v_wr.tracking_number), v_wr.pieces, 'magaya_auto', v_wr.id)
    RETURNING id INTO v_movement_id;
  END IF;

  -- 4. Map item_description to product
  SELECT pm.product_id INTO v_product_id FROM wh_report_product_mappings pm
  WHERE pm.client_id = v_client.id AND pm.active = true AND NEW.item_description ILIKE pm.magaya_pattern
  ORDER BY pm.priority DESC LIMIT 1;

  -- 5. Extract box count from description: "( XX Box )"
  v_box_count := NULL;
  BEGIN
    SELECT (regexp_match(NEW.item_description, '\(\s*(\d+)\s*Box\s*\)', 'i'))[1]::integer INTO v_box_count;
  EXCEPTION WHEN OTHERS THEN
    v_box_count := NULL;
  END;

  -- 6. Check if incomplete
  IF v_product_id IS NOT NULL AND v_box_count IS NOT NULL THEN
    SELECT standard_cartons_per_pallet INTO v_standard FROM wh_report_products WHERE id = v_product_id;
    IF v_standard IS NOT NULL AND v_box_count < v_standard THEN
      v_is_incomplete := true;
    END IF;
  END IF;

  -- 7. Create/update movement item
  IF v_product_id IS NOT NULL AND NEW.pieces > 0 THEN
    IF NOT EXISTS (SELECT 1 FROM wh_report_movement_items WHERE movement_id = v_movement_id AND product_id = v_product_id) THEN
      INSERT INTO wh_report_movement_items (movement_id, product_id, quantity, is_incomplete, cartons_per_pallet, notes)
      VALUES (v_movement_id, v_product_id, NEW.pieces, v_is_incomplete,
        CASE WHEN v_is_incomplete THEN v_box_count ELSE NULL END,
        CASE WHEN v_is_incomplete THEN 'WR ' || v_wr.wr_number || ': ' || NEW.pieces || ' X ' || v_box_count ELSE NULL END);
    ELSE
      UPDATE wh_report_movement_items 
      SET quantity = quantity + NEW.pieces,
        is_incomplete = CASE WHEN v_is_incomplete THEN true ELSE is_incomplete END,
        cartons_per_pallet = CASE WHEN v_is_incomplete THEN v_box_count ELSE cartons_per_pallet END,
        notes = CASE WHEN v_is_incomplete THEN COALESCE(notes || '; ', '') || 'WR ' || v_wr.wr_number || ': ' || NEW.pieces || ' X ' || v_box_count ELSE notes END
      WHERE movement_id = v_movement_id AND product_id = v_product_id;
    END IF;
  END IF;

  -- 8. Log unmapped
  IF v_product_id IS NULL AND NEW.item_description IS NOT NULL THEN
    INSERT INTO wh_report_sync_log (source_table, source_id, client_id, item_description, status, message)
    VALUES ('magaya_wr_items', NEW.id, v_client.id, NEW.item_description, 'unmapped', 'No product mapping found for: ' || NEW.item_description)
    ON CONFLICT DO NOTHING;
  END IF;

  RETURN NEW;
END;
$function$;

CREATE OR REPLACE FUNCTION public.tg_clients_backfill_intel_matches()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions', 'pg_catalog'
AS $function$
declare
  v_ruc_norm text;
begin
  v_ruc_norm := nullif(regexp_replace(coalesce(new.ruc,''),'\D','','g'),'');
  if v_ruc_norm is null or length(v_ruc_norm) < 10 then return new; end if;

  update public.mi_shipment_intel
     set client_id        = new.id,
         match_method     = 'RUC_EXACT',
         match_confidence = 1.000,
         matched_at       = now()
   where client_id is null
     and ec_company_id_norm = v_ruc_norm;   -- indexed!

  return new;
end $function$;

CREATE OR REPLACE FUNCTION public.tg_clients_track_soft_delete()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions', 'pg_catalog'
AS $function$
declare
  v_uid  uuid := auth.uid();
  v_role text;
  v_internal_id uuid;
begin
  -- service role / cron / SQL maintenance: pass through unchanged
  if v_uid is null then return new; end if;

  select u.role, u.id into v_role, v_internal_id
    from public.users u where u.auth_user_id = v_uid;

  -- Case A: row is being soft-deleted (deleted_at NULL -> not NULL)
  if old.deleted_at is null and new.deleted_at is not null then
    new.deleted_by := v_internal_id;
    return new;
  end if;

  -- Case B: row is being restored (deleted_at not NULL -> NULL).
  -- Only Admin / Administration can restore — Sales Exec who clicked delete
  -- by mistake has to ask an admin via the recycle bin.
  if old.deleted_at is not null and new.deleted_at is null then
    if v_role = any (array['Admin','Administration']) then
      new.deleted_by := null;
      return new;
    else
      raise exception 'Solo un Administrador puede restaurar un cliente eliminado. Pídele a un Admin que lo recupere desde la Papelera.';
    end if;
  end if;

  return new;
end $function$;

CREATE OR REPLACE FUNCTION public.tg_legacy_agent_rates_solo_lectura()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  RAISE EXCEPTION
    'Esta pantalla está desactualizada y las tarifas NO se guardarían donde el buscador las lee. Cierra la app y vuelve a abrirla (o usa "Verificar versión" en el menú) y súbelas de nuevo.'
    USING ERRCODE = 'P0001';
END $function$;

CREATE OR REPLACE FUNCTION public.tg_match_wr_on_insert()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public', 'pg_catalog'
AS $function$
begin
  if new.status = 'OnHand' and public.wr_is_gloval_usa(new.issued_by) then
    perform public.match_wr(new.id);
  end if;
  return new;
end $function$;

CREATE OR REPLACE FUNCTION public.tg_match_wr_on_update()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public', 'pg_catalog'
AS $function$
begin
  if new.status = 'OnHand'
     and (old.status is distinct from 'OnHand')
     and public.wr_is_gloval_usa(new.issued_by) then
    perform public.match_wr(new.id);
  end if;
  return new;
end $function$;

CREATE OR REPLACE FUNCTION public.tg_mi_intel_match_ruc()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions', 'pg_catalog'
AS $function$
declare
  v_client_id uuid;
  v_ruc_norm  text;
begin
  if new.client_id is not null then return new; end if;
  v_ruc_norm := nullif(regexp_replace(coalesce(new.ec_company_id,''),'\D','','g'),'');
  if v_ruc_norm is null or length(v_ruc_norm) < 10 then return new; end if;

  select c.id into v_client_id
    from public.clients c
   where regexp_replace(coalesce(c.ruc,''),'\D','','g') = v_ruc_norm
   order by c.created_at asc
   limit 1;

  if v_client_id is not null then
    new.client_id        := v_client_id;
    new.match_method     := 'RUC_EXACT';
    new.match_confidence := 1.000;
    new.matched_at       := now();
  end if;
  return new;
end $function$;

CREATE OR REPLACE FUNCTION public.tg_ops_transfers_guard()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
begin
  -- Procesos sin usuario (el cron del aviso de llegada mueve el estado): pasan.
  if auth.uid() is null then
    return new;
  end if;

  if coalesce(current_setting('app.ops_handoff', true), '') <> 'on' and (
       new.handoff_estado is distinct from old.handoff_estado
    or new.received_by    is distinct from old.received_by
    or new.received_at    is distinct from old.received_at
    or new.transferred_by is distinct from old.transferred_by
    or new.transferred_at is distinct from old.transferred_at
    or new.returned_by    is distinct from old.returned_by
    or new.returned_at    is distinct from old.returned_at
    or new.return_reason  is distinct from old.return_reason) then
    raise exception 'La aceptación o devolución de un embarque se registra con los botones de Operaciones.';
  end if;

  -- Trabajar el embarque exige haberlo aceptado: si no, se opera sin que
  -- conste quién lo tomó, que es exactamente lo que se quería evitar.
  if new.ops_status is distinct from old.ops_status and old.handoff_estado <> 'ACEPTADO' then
    raise exception 'Primero acepta la transferencia del embarque; después puedes avanzar sus hitos.';
  end if;

  return new;
end $function$;

CREATE OR REPLACE FUNCTION public.tg_protect_credit_fields()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
declare
  v_uid  uuid := auth.uid();
  v_role text;
begin
  -- service role / cron / server-side jobs: bypass
  if v_uid is null then return new; end if;

  select u.role into v_role from public.users u where u.auth_user_id = v_uid;

  -- Admin and Administration: full control over credit fields
  if v_role = any (array['Admin','Administration']) then return new; end if;

  -- Everyone else: silently revert any credit changes to old values.
  -- This lets the rest of the row update normally (no exception) — the form
  -- save succeeds, credit just stays as it was.
  new.credit_limit         := old.credit_limit;
  new.credit_terms         := old.credit_terms;
  new.credit_days          := old.credit_days;
  new.has_credit_approved  := old.has_credit_approved;
  new.credit_line_amount   := old.credit_line_amount;
  new.credit_status        := old.credit_status;
  new.credit_approved_at   := old.credit_approved_at;
  new.credit_approved_by   := old.credit_approved_by;
  new.credit_approved_date := old.credit_approved_date;
  new.credit_term          := old.credit_term;
  new.confianza_credit_amount  := old.confianza_credit_amount;
  new.handles_postdated_checks := old.handles_postdated_checks;

  return new;
end
$function$;

CREATE OR REPLACE FUNCTION public.tg_set_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public', 'pg_catalog'
AS $function$
begin new.updated_at = now(); return new; end $function$;

CREATE OR REPLACE FUNCTION public.tg_shipment_hijos_bloqueo_ops()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare
  v_msg text;
begin
  if current_user <> 'authenticated' then
    return coalesce(new, old);
  end if;

  if tg_op in ('UPDATE', 'DELETE') then
    v_msg := public.app_embarque_bloqueo_ops(old.shipment_id);
  end if;
  if v_msg is null and tg_op in ('INSERT', 'UPDATE') then
    v_msg := public.app_embarque_bloqueo_ops(new.shipment_id);
  end if;

  if v_msg is not null then
    raise exception using message = v_msg, errcode = 'P0001', hint = 'OPS_ACEPTADO';
  end if;
  return coalesce(new, old);
end $function$;

CREATE OR REPLACE FUNCTION public.tg_shipments_bloqueo_ops()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare
  v_msg text;
begin
  if current_user <> 'authenticated'
     and not (new.status = 'CANCELLED' and old.status is distinct from 'CANCELLED') then
    return new;
  end if;

  v_msg := public.app_embarque_bloqueo_ops(old.id);
  if v_msg is not null then
    raise exception using message = v_msg, errcode = 'P0001', hint = 'OPS_ACEPTADO';
  end if;
  return new;
end $function$;

CREATE OR REPLACE FUNCTION public.tg_users_sync_role()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_name text;
  v_id   uuid;
begin
  if TG_OP = 'INSERT' then
    if new.role_id is not null then
      select name into v_name from roles where id = new.role_id;
      if v_name is not null then new.role := v_name; end if;
    elsif new.role is not null then
      select id into v_id from roles where name = new.role;
      new.role_id := v_id;
    end if;
    return new;
  end if;

  -- UPDATE: solo actua si el rol se toca A PROPOSITO. Sin esta condicion,
  -- editar el telefono de alguien le cambiaria el rol de seguridad en
  -- silencio — exactamente el accidente que hay que evitar.
  if new.role_id is distinct from old.role_id and new.role_id is not null then
    select name into v_name from roles where id = new.role_id;
    if v_name is not null then new.role := v_name; end if;
  elsif new.role is distinct from old.role and new.role is not null then
    select id into v_id from roles where name = new.role;
    if v_id is not null then new.role_id := v_id; end if;
  end if;
  return new;
end;
$function$;

CREATE OR REPLACE FUNCTION public.touch_client_visits_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN NEW.updated_at = now(); RETURN NEW; END; $function$;

CREATE OR REPLACE FUNCTION public.touch_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin new.updated_at = now(); return new; end $function$;

CREATE OR REPLACE FUNCTION public.trg_credit_request_approved_notify()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions', 'pg_catalog'
AS $function$
begin
  if new.status = 'approved' and coalesce(old.status, '') <> 'approved' then
    perform net.http_post(
      url := 'https://wfzdrqfurwnakrfdnbgf.supabase.co/functions/v1/credit-approved-notify',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer <SUPABASE_ANON_KEY>'
      ),
      body := jsonb_build_object('request_id', new.id),
      timeout_milliseconds := 15000
    );
  end if;
  return new;
end $function$;

CREATE OR REPLACE FUNCTION public.trg_credit_requests_recompute()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'extensions', 'pg_catalog'
AS $function$
begin
  perform public.recompute_client_credit(coalesce(new.client_id, old.client_id));
  return coalesce(new, old);
end $function$;

CREATE OR REPLACE FUNCTION public.update_activity_metrics()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
total_minutes integer;
active_count integer;
idle_count integer;
BEGIN
-- Count active vs idle logs for this time entry
SELECT 
COUNT(*) FILTER (WHERE is_active = true),
COUNT(*) FILTER (WHERE is_active = false)
INTO active_count, idle_count
FROM activity_logs
WHERE time_entry_id = NEW.time_entry_id;

-- Update time entry with activity metrics
UPDATE time_entries
SET 
active_time_minutes = active_count,
idle_time_minutes = idle_count,
activity_percentage = CASE 
WHEN (active_count + idle_count) > 0 
THEN (active_count::numeric / (active_count + idle_count)::numeric) * 100
ELSE 0 
END,
last_activity_at = NEW.timestamp
WHERE id = NEW.time_entry_id;

RETURN NEW;
END;
$function$;

CREATE OR REPLACE FUNCTION public.update_deals_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
NEW.updated_at = now();
RETURN NEW;
END;
$function$;

CREATE OR REPLACE FUNCTION public.update_magaya_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public', 'pg_catalog'
AS $function$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$function$;

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public', 'pg_catalog'
AS $function$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$function$;

CREATE OR REPLACE FUNCTION public.user_can_see_office(p_office text)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public', 'auth'
AS $function$
  select exists (
    select 1 from public.users u
    where u.auth_user_id = auth.uid()
      and (
        u.role = any (array['Admin','VP'])
        or u.report_visibility = 'all'
        or u.office = p_office
      )
  )
$function$;

CREATE OR REPLACE FUNCTION public.ventas_approve_amendment(p_amendment_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_a quote_amendments%rowtype;
  v_q quotes%rowtype;
  v_uid uuid := app_current_user_id();
  v_role text := app_current_user_role();
  v_si shipping_instructions%rowtype;
begin
  if v_uid is null then
    raise exception 'No autenticado';
  end if;
  select * into v_a from quote_amendments where id = p_amendment_id for update;
  if not found or v_a.status <> 'pending' then
    raise exception 'El cambio ya fue decidido o no existe';
  end if;
  select * into v_q from quotes where id = v_a.quote_id for update;
  if not (v_q.created_by = v_uid or v_role in ('Admin','VP')) then
    raise exception 'Solo la vendedora dueña de la cotización (o Admin/VP) puede aprobar este cambio';
  end if;

  select * into v_si from shipping_instructions
   where quote_id = v_q.id and status <> 'cancelled'
   limit 1 for update;
  if v_si.id is not null and v_si.liq_shipment_id is not null then
    raise exception 'La SI de esta cotización ya fue sembrada en Liquidaciones — el ajuste debe hacerse en ese módulo, no vía cambio de cotización';
  end if;

  -- líneas de la cotización
  delete from sales_quote_lines where quote_id = v_q.id;
  insert into sales_quote_lines
    (quote_id, section, charge_code, name, basis, qty, cost_rate, cost_amount,
     sale_rate, sale_amount, cost_min, sale_min, currency, notes, sort_order, container_type, iva_exempt)
  select v_q.id,
         coalesce(l->>'section','freight'), nullif(l->>'charge_code',''), coalesce(l->>'name',''),
         coalesce(l->>'basis','manual'), coalesce((l->>'qty')::numeric, 1),
         coalesce((l->>'cost_rate')::numeric, 0), coalesce((l->>'cost_amount')::numeric, 0),
         coalesce((l->>'sale_rate')::numeric, 0), coalesce((l->>'sale_amount')::numeric, 0),
         coalesce((l->>'cost_min')::numeric, 0), coalesce((l->>'sale_min')::numeric, 0),
         coalesce(l->>'currency','USD'), nullif(l->>'notes',''), coalesce((l->>'sort_order')::int, 0),
         nullif(l->>'container_type',''),
         coalesce((l->>'iva_exempt')::boolean, false)
  from jsonb_array_elements(v_a.lines) as l;

  update quotes
     set cost_total = v_a.cost_total,
         sale_total = v_a.sale_total,
         profit_total = v_a.profit_total
   where id = v_q.id;

  -- la SI viva hereda el cambio (documento madre mientras no esté sellada)
  if v_si.id is not null then
    delete from sales_quote_lines where si_id = v_si.id;
    insert into sales_quote_lines
      (si_id, section, charge_code, name, basis, qty, cost_rate, cost_amount,
       sale_rate, sale_amount, cost_min, sale_min, currency, notes, sort_order, container_type, iva_exempt)
    select v_si.id,
           coalesce(l->>'section','freight'), nullif(l->>'charge_code',''), coalesce(l->>'name',''),
           coalesce(l->>'basis','manual'), coalesce((l->>'qty')::numeric, 1),
           coalesce((l->>'cost_rate')::numeric, 0), coalesce((l->>'cost_amount')::numeric, 0),
           coalesce((l->>'sale_rate')::numeric, 0), coalesce((l->>'sale_amount')::numeric, 0),
           coalesce((l->>'cost_min')::numeric, 0), coalesce((l->>'sale_min')::numeric, 0),
           coalesce(l->>'currency','USD'), nullif(l->>'notes',''), coalesce((l->>'sort_order')::int, 0),
           nullif(l->>'container_type',''),
           coalesce((l->>'iva_exempt')::boolean, false)
    from jsonb_array_elements(v_a.lines) as l;

    update shipping_instructions
       set cost_total = v_a.cost_total,
           sale_total = v_a.sale_total,
           profit_total = v_a.profit_total
     where id = v_si.id;
  end if;

  update quote_amendments
     set status = 'approved', decided_by = v_uid, decided_at = now()
   where id = p_amendment_id;
end $function$;

CREATE OR REPLACE FUNCTION public.ventas_confirm_si(p_si_id uuid)
 RETURNS TABLE(out_shipment_id uuid, out_shipment_code text)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_si shipping_instructions%rowtype;
  v_uid uuid := app_current_user_id();
  v_role text := app_current_user_role();
  v_junior boolean;
  v_ship_id uuid;
  v_code text;
  v_ship_status text;
begin
  if v_uid is null then
    raise exception 'No autenticado';
  end if;

  select * into v_si from shipping_instructions where id = p_si_id for update;
  if not found then
    raise exception 'SI no encontrada';
  end if;

  -- Autorizacion: los roles comerciales de siempre, mas la ejecutiva junior
  -- limitada a su propia cartera (se evalua sobre la fila ya bloqueada) y a las
  -- SIs DIRECTOS que ella misma armo.
  if v_role not in ('Admin','VP','Manager','Sales Executive') then
    select coalesce(u.is_junior_exec, false) into v_junior from public.users u where u.id = v_uid;
    if not (
      coalesce(v_junior, false)
      and (
        v_si.sales_executive_id = v_uid
        -- DIRECTOS: sin ejecutiva duena. La confirma quien la armo.
        or (v_si.sales_executive_id is null and v_si.created_by = v_uid)
      )
    ) then
      raise exception 'Tu rol (%) no puede confirmar shipping instructions', v_role;
    end if;
  end if;

  if v_si.status <> 'draft' then
    raise exception 'La SI ya fue confirmada o no está en borrador';
  end if;
  if v_si.client_id is null then
    raise exception 'La SI necesita un cliente del CRM vinculado';
  end if;

  if v_si.shipment_id is not null then
    -- SI nacida de un embarque existente (ventas_si_desde_embarque): confirmar
    -- EN SITIO. Jamás crear otro shipment ni escribirle nada al embarque — el
    -- embarque ya es la verdad operativa.
    select s.id, s.shipment_code, s.status::text
      into v_ship_id, v_code, v_ship_status
      from shipments s
     where s.id = v_si.shipment_id and s.archived_at is null
     for update;
    if not found then
      raise exception 'El embarque de esta SI ya no existe o está archivado';
    end if;
    if v_ship_status = 'CANCELLED' then
      raise exception 'El embarque de esta SI está cancelado';
    end if;

    update shipping_instructions
       set status = 'confirmed', confirmed_at = now(), confirmed_by = v_uid
     where id = p_si_id;

    insert into shipment_events (shipment_id, event_type, occurred_at, source, created_by, metadata)
    values (v_ship_id, 'SI ' || v_si.si_number || ' confirmada sobre el embarque', now(), 'SYSTEM', v_uid,
            jsonb_build_object('si_id', v_si.id, 'si_number', v_si.si_number));

    return query select v_ship_id, v_code;
    return;
  end if;

  -- El trigger shipments_set_defaults rutea la CS del ejecutivo y genera el código
  insert into shipments (client_id, mode, direction, status, sales_executive_id, office,
    origin_port, destination_port, etd, eta, carrier, booking_ref, mbl, hbl, incoterm, created_by)
  values (v_si.client_id, v_si.mode::shipment_mode_t,
    coalesce(nullif(v_si.direction,''),'EXPORT')::shipment_direction_t, 'BOOKING',
    v_si.sales_executive_id, coalesce(v_si.office,'Ecuador'),
    v_si.origin_port, v_si.destination_port, v_si.etd, v_si.eta, v_si.carrier,
    v_si.booking_ref, v_si.mbl, v_si.hbl, v_si.incoterm, v_uid)
  returning id, shipment_code into v_ship_id, v_code;

  if coalesce(trim(v_si.shipper_name),'') <> '' then
    insert into shipment_shippers (shipment_id, name, incoterm, origin_port, position, created_by)
    values (v_ship_id, trim(v_si.shipper_name), v_si.incoterm, v_si.origin_port, 0, v_uid);
  end if;

  if v_si.mode = 'FCL' and v_si.containers is not null then
    insert into shipment_containers (shipment_id, size_type, quantity, position, created_by)
    select v_ship_id, c->>'type', greatest(1, coalesce((c->>'qty')::int, 1)), (ord - 1)::int, v_uid
    from jsonb_array_elements(v_si.containers) with ordinality as t(c, ord)
    where coalesce(c->>'type','') <> '';
  end if;

  if coalesce(trim(v_si.origin_agent),'') <> '' then
    insert into shipment_agents (shipment_id, name, agent_role, position, created_by)
    values (v_ship_id, trim(v_si.origin_agent), 'ORIGIN', 0, v_uid);
  end if;

  insert into shipment_events (shipment_id, event_type, occurred_at, source, created_by, metadata)
  values (v_ship_id, 'SI ' || v_si.si_number || ' confirmada desde Ventas', now(), 'SYSTEM', v_uid,
          jsonb_build_object('si_id', v_si.id, 'si_number', v_si.si_number, 'quote_id', v_si.quote_id));

  update shipping_instructions
     set status = 'confirmed', shipment_id = v_ship_id, confirmed_at = now(), confirmed_by = v_uid
   where id = p_si_id;

  if v_si.quote_id is not null then
    update quotes set converted_si_id = v_si.id where id = v_si.quote_id;
  end if;

  return query select v_ship_id, v_code;
end $function$;

CREATE OR REPLACE FUNCTION public.ventas_delete_quote(p_quote_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_q quotes%rowtype;
  v_uid uuid := app_current_user_id();
  v_role text := app_current_user_role();
begin
  if v_uid is null then
    raise exception 'No autenticado';
  end if;
  select * into v_q from quotes where id = p_quote_id for update;
  if not found then
    raise exception 'La cotización no existe';
  end if;
  if v_q.sale_total is null then
    raise exception 'Esta cotización es del cotizador FCL de Freight — se elimina desde ese módulo';
  end if;
  if not (v_q.created_by = v_uid or v_role in ('Admin','VP')) then
    raise exception 'Solo el ejecutivo dueño de la cotización (o Admin/VP) puede eliminarla';
  end if;
  if exists (select 1 from shipping_instructions where quote_id = p_quote_id and status <> 'cancelled') then
    raise exception 'La cotización tiene una Shipping Instruction viva (%). Cancélala primero — si ya tiene embarque o liquidación, la cotización no debe eliminarse.',
      (select si_number from shipping_instructions where quote_id = p_quote_id and status <> 'cancelled' limit 1);
  end if;

  delete from quote_charges where quote_id = p_quote_id; -- legado sin cascade
  delete from quotes where id = p_quote_id;              -- cascadea líneas/amendments/correos
end $function$;

CREATE OR REPLACE FUNCTION public.ventas_embarques_vinculables(p_si_id uuid, p_term text DEFAULT NULL::text)
 RETURNS TABLE(id uuid, shipment_code text, estado text, hbl text, mbl text, booking_ref text, etd date, cs_nombre text, creado date)
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$
  select s.id, s.shipment_code, s.status::text, s.hbl, s.mbl, s.booking_ref, s.etd,
         (select u.name from users u where u.id = s.cs_assigned_to),
         s.created_at::date
  from shipments s
  join shipping_instructions si on si.id = p_si_id
  where s.client_id = si.client_id
    and s.archived_at is null
    and s.status <> 'CANCELLED'
    and not coalesce(s.is_master, false)
    and not exists (
      select 1 from shipping_instructions x
      where x.shipment_id = s.id and x.status <> 'cancelled'
    )
    and (
      coalesce(p_term, '') = ''
      or s.shipment_code ilike '%' || p_term || '%'
      or coalesce(s.hbl, '') ilike '%' || p_term || '%'
      or coalesce(s.mbl, '') ilike '%' || p_term || '%'
      or coalesce(s.booking_ref, '') ilike '%' || p_term || '%'
    )
  order by s.created_at desc
  limit 20;
$function$;

CREATE OR REPLACE FUNCTION public.ventas_log_quote_followup(p_quote_id uuid, p_note text DEFAULT NULL::text)
 RETURNS date
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare
  v_interval int;
  v_next date;
begin
  select coalesce(followup_interval_days, 3) into v_interval from quotes where id = p_quote_id;
  v_next := current_date + coalesce(v_interval, 3);
  insert into quote_followups (quote_id, done_by, note, next_followup_at)
  values (p_quote_id, app_current_user_id(), nullif(p_note,''), v_next);
  update quotes set last_followup_at = now(), next_followup_at = v_next where id = p_quote_id;
  return v_next;
end $function$;

CREATE OR REPLACE FUNCTION public.ventas_revert_acceptance(p_quote_id uuid)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_q quotes%rowtype;
  v_si shipping_instructions%rowtype;
  v_uid uuid := app_current_user_id();
  v_role text := app_current_user_role();
  v_resultado text := 'revertida';
begin
  if v_uid is null then
    raise exception 'No autenticado';
  end if;
  select * into v_q from quotes where id = p_quote_id for update;
  if not found then
    raise exception 'La cotización no existe';
  end if;
  if v_q.status <> 'ACCEPTED' then
    raise exception 'La cotización no está aceptada (estado actual: %)', v_q.status;
  end if;
  if not (v_q.created_by = v_uid or v_role in ('Admin','VP')) then
    raise exception 'Solo el ejecutivo dueño de la cotización (o Admin/VP) puede deshacer la aceptación';
  end if;

  select * into v_si from shipping_instructions
   where quote_id = p_quote_id and status <> 'cancelled'
   limit 1 for update;

  if v_si.id is not null then
    if v_si.liq_shipment_id is not null then
      raise exception 'La SI % ya tiene liquidación sembrada en Contabilidad — coordina con Liquidaciones antes de deshacer la aceptación', v_si.si_number;
    end if;

    if v_si.shipment_id is not null then
      -- Embarque ya creado en CS: se cancela con evento para la CS
      update shipments set status = 'CANCELLED' where id = v_si.shipment_id;
      insert into shipment_events (shipment_id, event_type, occurred_at, description, source, created_by)
      values (v_si.shipment_id, 'CANCELLED', now(),
              'El cliente desaceptó la cotización ' || v_q.quote_number || ' — embarque cancelado desde Ventas (SI ' || v_si.si_number || ')',
              'SYSTEM', v_uid);
      v_resultado := 'revertida_embarque_cancelado';
    else
      v_resultado := 'revertida_si_cancelada';
    end if;

    update shipping_instructions set status = 'cancelled' where id = v_si.id;
  end if;

  -- Cambios pendientes de aprobación quedan sin efecto
  update quote_amendments set status = 'rejected', decided_by = v_uid, decided_at = now()
   where quote_id = p_quote_id and status = 'pending';

  update quotes
     set status = 'SENT', accepted_at = null, converted_si_id = null
   where id = p_quote_id;

  return v_resultado;
end $function$;

CREATE OR REPLACE FUNCTION public.ventas_set_quote_followup(p_quote_id uuid, p_interval_days integer)
 RETURNS void
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare
  v_valid date;
  v_next date;
begin
  if p_interval_days is null or p_interval_days < 1 then
    raise exception 'La cadencia de seguimiento debe ser de al menos 1 día';
  end if;
  select valid_until into v_valid from quotes where id = p_quote_id and sale_total is not null;
  if v_valid is not null and v_valid < current_date then
    raise exception 'La cotización ya venció (validez %). Extiende la validez antes de programar seguimiento.', v_valid;
  end if;
  v_next := current_date + p_interval_days;
  if v_valid is not null and v_next > v_valid then v_next := v_valid; end if;
  update quotes
     set followup_interval_days = p_interval_days,
         next_followup_at = v_next,
         status = case when status in ('DRAFT','SENT','PENDING') then 'PENDING' else status end
   where id = p_quote_id and sale_total is not null;
end $function$;

CREATE OR REPLACE FUNCTION public.ventas_si_desde_embarque(p_shipment_id uuid)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_s shipments%rowtype;
  v_uid uuid := app_current_user_id();
  v_si_id uuid;
  v_num text;
  v_shipper text;
  v_origin_agent text;
  v_containers jsonb;
begin
  if v_uid is null then
    raise exception 'No autenticado';
  end if;

  select * into v_s from shipments where id = p_shipment_id for update;
  if not found then
    raise exception 'Embarque no encontrado';
  end if;

  -- SECURITY DEFINER salta el RLS: replicar aquí la MISMA llave de visibilidad
  -- de la policy shipments_select antes de tocar nada.
  if not (
    app_can_see_shipment_row(v_s.sales_executive_id, v_s.office, v_s.cs_assigned_to, v_s.pba_amount)
    or (v_s.client_id is not null
        and v_s.pba_amount is null
        and v_s.client_id in (select app_cs_client_ids()))
  ) then
    raise exception 'No tienes acceso a este embarque';
  end if;

  if v_s.archived_at is not null then
    raise exception 'El embarque está archivado';
  end if;
  if v_s.status = 'CANCELLED' then
    raise exception 'El embarque está cancelado';
  end if;
  if coalesce(v_s.is_master, false) then
    raise exception 'La SI se crea sobre el house, no sobre el máster del consolidado';
  end if;
  if v_s.client_id is null then
    raise exception 'El embarque necesita un cliente del CRM vinculado (Editar → Cliente) antes de crear la SI';
  end if;
  if exists (
    select 1 from shipping_instructions si
    where si.shipment_id = p_shipment_id and si.status <> 'cancelled'
  ) then
    raise exception 'Este embarque ya tiene una Shipping Instruction';
  end if;

  select s.name into v_shipper
  from shipment_shippers s
  where s.shipment_id = p_shipment_id
  order by s.position, s.created_at
  limit 1;

  select a.name into v_origin_agent
  from shipment_agents a
  where a.shipment_id = p_shipment_id and a.agent_role = 'ORIGIN'
  order by a.position, a.created_at
  limit 1;

  -- Mismo formato {type, qty} que ventas_confirm_si escribe de vuelta en
  -- shipment_containers al confirmar una SI de cotización.
  select jsonb_agg(
           jsonb_build_object('type', c.size_type, 'qty', greatest(1, coalesce(c.quantity, 1)))
           order by c.position
         )
  into v_containers
  from shipment_containers c
  where c.shipment_id = p_shipment_id and coalesce(c.size_type, '') <> '';

  v_num := next_sales_doc_number('SI');

  insert into shipping_instructions
    (si_number, status, shipment_id, quote_id, created_by,
     office, sales_executive_id, client_id, mode, direction, incoterm,
     origin_port, destination_port, etd, eta, carrier, booking_ref, mbl, hbl,
     shipper_name, consignee_name, origin_agent, containers)
  values
    (v_num, 'draft', v_s.id, null, v_uid,
     v_s.office,
     -- Atribución congelada del embarque: NULL se respeta (= DIRECTOS, la casa).
     v_s.sales_executive_id,
     v_s.client_id, v_s.mode::text, v_s.direction::text, v_s.incoterm,
     v_s.origin_port, v_s.destination_port, v_s.etd, v_s.eta, v_s.carrier,
     v_s.booking_ref, v_s.mbl, v_s.hbl,
     v_shipper, v_s.consignee_name, v_origin_agent, v_containers)
  returning id into v_si_id;

  insert into shipment_events (shipment_id, event_type, occurred_at, source, created_by, metadata)
  values (v_s.id, 'SI ' || v_num || ' creada desde el embarque', now(), 'SYSTEM', v_uid,
          jsonb_build_object('si_id', v_si_id, 'si_number', v_num));

  return v_si_id;
end $function$;

CREATE OR REPLACE FUNCTION public.ventas_si_desvincular_embarque(p_si_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_si shipping_instructions%rowtype;
  v_uid uuid := app_current_user_id();
  v_role text := app_current_user_role();
begin
  if v_uid is null then raise exception 'No autenticado'; end if;
  select * into v_si from shipping_instructions where id = p_si_id for update;
  if not found then raise exception 'SI no encontrada'; end if;
  if v_si.status <> 'draft' then
    raise exception 'La SI ya está confirmada: su embarque no se desvincula';
  end if;
  if v_si.shipment_id is null then return; end if;
  if not (
    v_role in ('Admin','VP','Manager')
    or v_si.sales_executive_id = v_uid
    or v_si.created_by = v_uid
    or v_si.sales_executive_id in (select app_cs_ventas_executives())
    or v_si.client_id in (select app_cs_clientes_habilitados())
  ) then
    raise exception 'Tu usuario no puede desvincular esta SI (es de otra cartera)';
  end if;

  insert into shipment_events (shipment_id, event_type, occurred_at, source, created_by, metadata)
  values (v_si.shipment_id, 'SI ' || v_si.si_number || ' desvinculada del embarque', now(), 'SYSTEM'::event_source_t, v_uid,
          jsonb_build_object('si_id', v_si.id, 'si_number', v_si.si_number));

  update shipping_instructions set shipment_id = null where id = p_si_id;
end $function$;

CREATE OR REPLACE FUNCTION public.ventas_si_vincular_embarque(p_si_id uuid, p_shipment_id uuid)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_si shipping_instructions%rowtype;
  v_s shipments%rowtype;
  v_uid uuid := app_current_user_id();
  v_role text := app_current_user_role();
begin
  if v_uid is null then
    raise exception 'No autenticado';
  end if;

  select * into v_si from shipping_instructions where id = p_si_id for update;
  if not found then raise exception 'SI no encontrada'; end if;
  if v_si.status <> 'draft' then
    raise exception 'Solo se puede vincular una SI en borrador';
  end if;
  if v_si.shipment_id is not null then
    raise exception 'Esta SI ya está vinculada a un embarque';
  end if;
  if v_si.client_id is null then
    raise exception 'La SI necesita un cliente del CRM vinculado';
  end if;

  if not (
    v_role in ('Admin','VP','Manager')
    or v_si.sales_executive_id = v_uid
    or v_si.created_by = v_uid
    or v_si.sales_executive_id in (select app_cs_ventas_executives())
    or v_si.client_id in (select app_cs_clientes_habilitados())
  ) then
    raise exception 'Tu usuario no puede vincular esta SI (es de otra cartera)';
  end if;

  select * into v_s from shipments where id = p_shipment_id for update;
  if not found then raise exception 'Embarque no encontrado'; end if;

  if not (
    app_can_see_shipment_row(v_s.sales_executive_id, v_s.office, v_s.cs_assigned_to, v_s.pba_amount)
    or (v_s.client_id is not null and v_s.pba_amount is null
        and v_s.client_id in (select app_cs_client_ids()))
  ) then
    raise exception 'No tienes acceso a ese embarque';
  end if;

  if v_s.archived_at is not null then raise exception 'El embarque está archivado'; end if;
  if v_s.status = 'CANCELLED' then raise exception 'El embarque está cancelado'; end if;
  if coalesce(v_s.is_master, false) then
    raise exception 'La SI se vincula al house, no al máster del consolidado';
  end if;
  if v_s.client_id is distinct from v_si.client_id then
    raise exception 'El embarque es de otro cliente: primero corrige el cliente del embarque o de la SI';
  end if;
  if exists (select 1 from shipping_instructions x
             where x.shipment_id = p_shipment_id and x.status <> 'cancelled') then
    raise exception 'Ese embarque ya tiene una Shipping Instruction';
  end if;

  update shipping_instructions set shipment_id = p_shipment_id where id = p_si_id;

  insert into shipment_events (shipment_id, event_type, occurred_at, source, created_by, metadata)
  values (v_s.id, 'SI ' || v_si.si_number || ' vinculada al embarque', now(), 'SYSTEM'::event_source_t, v_uid,
          jsonb_build_object('si_id', v_si.id, 'si_number', v_si.si_number, 'quote_id', v_si.quote_id));

  return v_s.shipment_code;
end $function$;

CREATE OR REPLACE FUNCTION public.ventas_stop_quote_followup(p_quote_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
begin
  update quotes set next_followup_at = null, followup_interval_days = null where id = p_quote_id;
end $function$;

CREATE OR REPLACE FUNCTION public.ventas_sync_si_from_quote(p_quote_id uuid)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_q quotes%rowtype;
  v_si shipping_instructions%rowtype;
  v_uid uuid := app_current_user_id();
  v_role text := app_current_user_role();
begin
  if v_uid is null then
    raise exception 'No autenticado';
  end if;
  select * into v_q from quotes where id = p_quote_id for update;
  if not found then
    raise exception 'La cotización no existe';
  end if;
  if not (v_q.created_by = v_uid or v_role in ('Admin','VP')) then
    raise exception 'Solo la vendedora dueña de la cotización (o Admin/VP) puede sincronizar la SI';
  end if;
  select * into v_si from shipping_instructions
   where quote_id = p_quote_id and status <> 'cancelled'
   limit 1 for update;
  if not found then
    return 'sin_si';
  end if;
  if v_si.status = 'confirmed' then
    return 'si_confirmada';
  end if;

  delete from sales_quote_lines where si_id = v_si.id;
  insert into sales_quote_lines
    (si_id, section, charge_code, name, basis, qty, cost_rate, cost_amount,
     sale_rate, sale_amount, cost_min, sale_min, currency, notes, sort_order, container_type, iva_exempt, free_qty)
  select v_si.id, section, charge_code, name, basis, qty, cost_rate, cost_amount,
         sale_rate, sale_amount, cost_min, sale_min, currency, notes, sort_order, container_type, iva_exempt, free_qty
    from sales_quote_lines
   where quote_id = p_quote_id
   order by sort_order;

  update shipping_instructions
     set cost_total = v_q.cost_total,
         sale_total = v_q.sale_total,
         profit_total = v_q.profit_total,
         pieces = v_q.pieces,
         gross_kg = v_q.gross_kg,
         cbm = v_q.cbm,
         chargeable_weight_kg = v_q.chargeable_weight_kg,
         containers = v_q.containers
   where id = v_si.id;

  return 'synced';
end $function$;

CREATE OR REPLACE FUNCTION public.visit_active_lookup(p_query text)
 RETURNS TABLE(visit_id uuid, visitor_name text, badge_label text, host_name text, checked_in_at timestamp with time zone)
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select v.id, vis.full_name, b.label, v.host_name_snapshot, v.checked_in_at
  from public.visits v
  join public.visitors vis on vis.id = v.visitor_id
  left join public.visitor_badges b on b.id = v.badge_id
  where v.status = 'checked_in'
    and coalesce(trim(p_query), '') <> ''
    and (
      vis.full_name ilike '%' || trim(p_query) || '%'
      or b.label ilike '%' || trim(p_query) || '%'
    )
  order by v.checked_in_at desc
  limit 1;
$function$;

CREATE OR REPLACE FUNCTION public.visitor_lookup(p_document text)
 RETURNS TABLE(full_name text, company text)
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select full_name, company
  from public.visitors
  where document_number = p_document
    and coalesce(p_document, '') <> ''
  order by updated_at desc
  limit 1;
$function$;

CREATE OR REPLACE FUNCTION public.visitor_touch_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  new.updated_at = now();
  return new;
end;
$function$;

CREATE OR REPLACE FUNCTION public.wh_decode_entities(t text)
 RETURNS text
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
declare
  m  text;
  cp int;
  r  text := coalesce(t, '');
begin
  -- Entities numéricos hex: &#x00CD; → Í
  loop
    m := (regexp_match(r, '&#[xX]([0-9A-Fa-f]{1,6});'))[1];
    exit when m is null;
    cp := ('x' || lpad(m, 8, '0'))::bit(32)::int;
    r := regexp_replace(r, '&#[xX]' || m || ';',
                        case when cp between 1 and 1114111 then chr(cp) else '' end,
                        'g');
  end loop;
  -- Entities numéricos decimales: &#205; → Í
  loop
    m := (regexp_match(r, '&#([0-9]{1,7});'))[1];
    exit when m is null;
    cp := m::int;
    r := replace(r, '&#' || m || ';',
                 case when cp between 1 and 1114111 then chr(cp) else '' end);
  end loop;
  r := replace(r, '&lt;', '<');
  r := replace(r, '&gt;', '>');
  r := replace(r, '&quot;', '"');
  r := replace(r, '&apos;', '''');
  r := replace(r, '&amp;', '&');  -- al final, para no re-interpretar
  return trim(r);
end;
$function$;

CREATE OR REPLACE FUNCTION public.wh_dias_libres(p_consignee text)
 RETURNS integer
 LANGUAGE sql
 STABLE
AS $function$
  select coalesce(
    (select t.dias_libres
       from public.wh_storage_terms t
      where t.activo and coalesce(p_consignee,'') ~* t.patron
      order by t.dias_libres desc
      limit 1),
    30);
$function$;

CREATE OR REPLACE FUNCTION public.wh_guardar_7512(p_wr text, p_numero text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_wr     text := btrim(coalesce(p_wr, ''));
  v_num    text := nullif(btrim(coalesce(p_numero, '')), '');
  v_at     timestamptz := now();
  v_lineas int := 0;
BEGIN
  IF v_wr = '' THEN
    RAISE EXCEPTION 'falta el numero de recibo de bodega';
  END IF;

  IF v_num IS NULL THEN
    DELETE FROM wh_doc_7512 w WHERE w.wr_number = v_wr;
    -- Borrar el numero limpia tambien la fecha: nunca queda un sello sin documento.
    UPDATE consolidado_lineas l
    SET doc_7512 = NULL, doc_7512_at = NULL
    FROM consolidados c
    WHERE c.id = l.consolidado_id AND c.estado IN ('ABIERTO','CERRADO')
      AND l.wr_number = v_wr;
    GET DIAGNOSTICS v_lineas = ROW_COUNT;
    RETURN jsonb_build_object('wr_number', v_wr, 'numero', NULL,
                              'registrado_at', NULL, 'lineas_espejadas', v_lineas);
  END IF;

  INSERT INTO wh_doc_7512 AS w (wr_number, numero, registrado_por, registrado_at)
  VALUES (v_wr, v_num, app_current_user_id(), v_at)
  ON CONFLICT (wr_number) DO UPDATE
    SET numero = excluded.numero,
        registrado_por = excluded.registrado_por,
        registrado_at = excluded.registrado_at;

  -- ZARPADO no se toca: esa semana ya embarco con el numero que tenia.
  UPDATE consolidado_lineas l
  SET doc_7512 = v_num, doc_7512_at = v_at
  FROM consolidados c
  WHERE c.id = l.consolidado_id AND c.estado IN ('ABIERTO','CERRADO')
    AND l.wr_number = v_wr;
  GET DIAGNOSTICS v_lineas = ROW_COUNT;

  RETURN jsonb_build_object('wr_number', v_wr, 'numero', v_num,
                            'registrado_at', v_at, 'lineas_espejadas', v_lineas);
END; $function$;

CREATE OR REPLACE FUNCTION public.wh_hazmat_de_recibo(p_wr_number text)
 RETURNS TABLE(es_hazmat boolean, uns text[])
 LANGUAGE sql
 STABLE
AS $function$
  select
    bool_or(coalesce(i.description,'') || ' ' || coalesce(i.notes,'') ~* 'haz-?mat|hazardous'),
    coalesce(array_agg(distinct m.un) filter (where m.un is not null), '{}')
  from magaya_wr_items i
  left join lateral (
    select (regexp_matches(coalesce(i.description,'') || ' ' || coalesce(i.notes,''),
                           'UN ?(\d{4})', 'g'))[1] as un
  ) m on true
  where i.wr_number = p_wr_number;
$function$;

CREATE OR REPLACE FUNCTION public.wh_notices_desactualizados(p_limit integer DEFAULT 40)
 RETURNS TABLE(wr_number text, motivo text)
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  with esperado as (
    select n.wr_number, n.body_html, n.created_at,
           n.consignee_name, n.shipper_name,
           w.consignee as consignee_wr, w.shipper as shipper_wr,
           w.weight,
           coalesce(
             nullif((select sum(i.vol_cft) from magaya_wr_items i where i.wr_number = n.wr_number), 0),
             nullif(w.volume_cft, 0)
           ) as vol_esperado
      from wh_notices n
      join magaya_warehouse_receipts w on w.wr_number = n.wr_number
     where n.status in ('DRAFT', 'READY', 'ERROR')
  )
  select e.wr_number,
         concat_ws(' + ',
           case when e.body_html not like '%Estimado Cliente:%' then 'plantilla' end,
           case when coalesce(e.weight, 0) > 0
                 and e.body_html not like '%<b>' || to_char(e.weight, 'FM9999999990.00') || ' lb%'
                then 'peso' end,
           case when coalesce(e.vol_esperado, 0) > 0
                 and e.body_html not like '%<b>' || to_char(e.vol_esperado, 'FM9999999990.00') || ' ft3%'
                then 'volumen' end,
           case when coalesce(e.consignee_wr, '') <> '' and e.consignee_wr is distinct from e.consignee_name
                then 'consignatario' end,
           case when coalesce(e.shipper_wr, '') <> '' and e.shipper_wr is distinct from e.shipper_name
                then 'proveedor' end
         ) as motivo
    from esperado e
   where e.body_html not like '%Estimado Cliente:%'
      or (coalesce(e.weight, 0) > 0
          and e.body_html not like '%<b>' || to_char(e.weight, 'FM9999999990.00') || ' lb%')
      or (coalesce(e.vol_esperado, 0) > 0
          and e.body_html not like '%<b>' || to_char(e.vol_esperado, 'FM9999999990.00') || ' ft3%')
      or (coalesce(e.consignee_wr, '') <> '' and e.consignee_wr is distinct from e.consignee_name)
      or (coalesce(e.shipper_wr, '') <> '' and e.shipper_wr is distinct from e.shipper_name)
   order by e.created_at desc
   limit greatest(1, least(coalesce(p_limit, 40), 200));
$function$;

CREATE OR REPLACE FUNCTION public.wh_notices_marcar_docs_internos()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  if new.attachments is not null and jsonb_typeof(new.attachments) = 'array' then
    select jsonb_agg(
             case
               when a->>'kind' <> 'WR_PDF'
                and a->>'kind' <> 'INTERNO'
                and (upper(a->>'name') ~ '\m[C]?HECK\s*ID\M'
                     or upper(a->>'name') ~ '\sID\.(PDF|JPG|JPEG|PNG)$')
               then jsonb_set(a, '{kind}', '"INTERNO"')
               else a
             end order by idx)
      into new.attachments
      from jsonb_array_elements(new.attachments) with ordinality t(a, idx);
  end if;
  return new;
end $function$;

CREATE OR REPLACE FUNCTION public.wh_recibos_con_saldo_para_alerta()
 RETURNS TABLE(wr_number text, consignee text, shipper text, destination_agent text, entrada date, dias integer, piezas_recibo integer, piezas_onhand integer, piezas_fuera integer, peso_onhand_lb numeric, salida_parcial date, cs_email text, es_ecuador boolean)
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select w.wr_number,
         w.consignee,
         w.shipper,
         w.destination_agent,
         coalesce(w.entry_date, w.created_on) as entrada,
         (current_date - coalesce(w.entry_date, w.created_on))::int as dias,
         w.pieces::int as piezas_recibo,
         s.piezas_onhand::int,
         s.piezas_fuera::int,
         round(s.peso_onhand_lb::numeric, 1),
         w.out_date as salida_parcial,
         coalesce(
           (select u.email from clients cl join users u on u.id = cl.customer_service_id
             where cl.company_name_normalized = w.consignee_normalized and cl.deleted_at is null
               and coalesce(u.status, 'Active') <> 'Inactive'
             limit 1),
           (select c.cs_email from client_notify_contacts c join users u on lower(u.email) = lower(c.cs_email)
             where c.cs_email is not null
               and coalesce(u.status, 'Active') <> 'Inactive'
               and length(split_part(upper(c.consignee_hint), ' (', 1)) >= 3
               and upper(w.consignee) like '%' || split_part(upper(c.consignee_hint), ' (', 1) || '%'
             limit 1)
         ) as cs_email,
         coalesce(w.destination_agent, '') ~* 'gloval\s+shipping\s+ecuador' as es_ecuador
  from v_wh_wr_saldo s
  join magaya_warehouse_receipts w on w.wr_number = s.wr_number
  where s.estado_saldo = 'PARCIAL'
    and w.last_full_fetch_at >= now() - interval '7 days'
    and coalesce(w.consignee, '') !~* '^\s*([a-z]{1,2}[\s.]+)?gloval';
$function$;

CREATE OR REPLACE FUNCTION public.wh_regimen_desde_magaya(p_bonded text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
AS $function$
  SELECT CASE
    WHEN p_bonded IS NULL OR btrim(p_bonded) = '' OR lower(btrim(p_bonded)) = 'none' THEN 'NORMAL'
    WHEN lower(p_bonded) LIKE '%containerfreight%' OR lower(btrim(p_bonded)) = 'cfs'   THEN 'CFS'
    ELSE 'BONDED'
  END;
$function$;

CREATE OR REPLACE FUNCTION public.wh_registrar_no_identificada()
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  nuevas int := 0;
  cerradas int := 0;
  importacion int := 0;
begin
  with candidatas as (
    select w.wr_number,
           case when upper(coalesce(w.consignee,'')) like '%GLOVAL%USA%AS AGENT%'
                then 'SIN_CONSIGNATARIO' else 'SIN_AGENTE' end as tipo,
           w.entry_date, w.consignee, w.destination_agent, w.shipper,
           w.pieces, w.weight, w.volume_cft, coalesce(w.created_by, w.issued_by) as quien
    from magaya_warehouse_receipts w
    where w.status = 'OnHand' and w.out_date is null
      and w.destination_agent ilike '%gloval%usa%as agent%'
      and w.entry_date >= date '2026-07-22'
      and not exists (select 1 from wh_carga_no_identificada r where r.wr_number = w.wr_number)
  ), ins as (
    insert into wh_carga_no_identificada
      (wr_number, tipo, entry_date, consignee_inicial, agente_inicial, shipper,
       piezas, peso_lb, volumen_cft, recibido_por)
    select wr_number, tipo, entry_date, wh_decode_entities(consignee),
           wh_decode_entities(destination_agent), wh_decode_entities(shipper),
           pieces, weight, volume_cft, quien
    from candidatas
    returning 1
  )
  select count(*) into nuevas from ins;

  with corregidas as (
    update wh_carga_no_identificada r
    set estado = 'IDENTIFICADA',
        identificado_at = now(),
        consignee_final = wh_decode_entities(w.consignee),
        agente_final = wh_decode_entities(w.destination_agent),
        dias_para_identificar =
          round(extract(epoch from (now() - r.detectado_at)) / 86400.0, 2),
        updated_at = now()
    from magaya_warehouse_receipts w
    where w.wr_number = r.wr_number
      and r.estado = 'SIN_IDENTIFICAR'
      and coalesce(w.destination_agent,'') not ilike '%gloval%usa%as agent%'
      and coalesce(w.destination_agent,'') <> ''
    returning 1
  )
  select count(*) into cerradas from corregidas;

  with importa as (
    update wh_carga_no_identificada r
    set estado = 'IMPORTACION', cobrable = false, updated_at = now(),
        nota = coalesce(r.nota,'') || ' · consignatario con historial de importación (destino Miami)'
    where r.estado = 'SIN_IDENTIFICAR'
      and r.tipo = 'SIN_AGENTE'
      and (
        select count(*) filter (where h.destination_port ilike '%miami%') >= 3
           and count(*) filter (where h.destination_port ilike '%miami%')
             > count(*) filter (where h.destination_port ilike '%guayaquil%')
        from magaya_warehouse_receipts h
        where upper(trim(coalesce(h.consignee,''))) = upper(trim(coalesce(r.consignee_inicial,'')))
      )
    returning 1
  )
  select count(*) into importacion from importa;

  return jsonb_build_object(
    'nuevas', nuevas, 'identificadas', cerradas, 'marcadas_importacion', importacion);
end;
$function$;

CREATE OR REPLACE FUNCTION public.wh_saldo_de_wrs(p_wrs text[])
 RETURNS TABLE(wr_number text, entry_date timestamp with time zone, estado_saldo text, piezas_onhand bigint, piezas_fuera bigint)
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  with agg as (
    select i.wr_number,
           count(*) filter (where i.status is not null) as items_con_estado,
           coalesce(sum(i.pieces) filter (where i.status = 'OnHand'), 0::bigint) as pz_onhand,
           coalesce(sum(i.pieces) filter (where i.status = any (array['Loaded','InTransit','AtDestination','Delivered'])), 0::bigint) as pz_fuera,
           coalesce(sum(i.pieces) filter (where i.status = any (array['Pending','Arriving'])), 0::bigint) as pz_por_llegar
      from magaya_wr_items i
     where i.wr_number = any (p_wrs)
     group by i.wr_number
  )
  select w.wr_number,
         w.entry_date,
         case
           when coalesce(a.items_con_estado, 0::bigint) = 0 then 'SIN_DETALLE'
           when coalesce(a.pz_onhand, 0::bigint) > 0 and coalesce(a.pz_fuera, 0::bigint) > 0 then 'PARCIAL'
           when coalesce(a.pz_onhand, 0::bigint) > 0 then 'EN_BODEGA'
           when coalesce(a.pz_fuera, 0::bigint) > 0 then 'EMBARCADO'
           when coalesce(a.pz_por_llegar, 0::bigint) > 0 then 'POR_LLEGAR'
           else 'SIN_CLASIFICAR'
         end as estado_saldo,
         coalesce(a.pz_onhand, 0::bigint),
         coalesce(a.pz_fuera, 0::bigint)
    from magaya_warehouse_receipts w
    left join agg a on a.wr_number = w.wr_number
   where w.wr_number = any (p_wrs);
$function$;

CREATE OR REPLACE FUNCTION public.wh_storage_aging_mine()
 RETURNS TABLE(wr_number text, consignee text, shipper text, entrada date, dias integer, nivel text, pieces integer, weight numeric, warehouse_zone text, location_code text, last_full_fetch_at timestamp with time zone, cs_email text, es_pool boolean, es_parcial boolean, piezas_recibo integer, dias_libres integer)
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  with me as (
    select id, role, office from public.users where auth_user_id = auth.uid() limit 1
  ),
  my_execs as (
    select ex from (
      select public.app_cs_executives() as ex
      union
      select public.app_cs_executives_full() as ex
    ) e where ex is not null
  ),
  base as (
    select w.wr_number, w.consignee, w.shipper,
      coalesce(w.entry_date, w.created_on) as entrada,
      (current_date - coalesce(w.entry_date, w.created_on))::int as dias,
      public.wh_dias_libres(w.consignee) as dias_libres,
      case when coalesce(s.items_con_estado, 0) > 0 then s.piezas_onhand::int else w.pieces end as pieces,
      case when coalesce(s.items_con_estado, 0) > 0
           then coalesce(s.peso_onhand_lb, w.weight * s.piezas_onhand / nullif(w.pieces, 0))
           else w.weight end as weight,
      w.warehouse_zone, w.location_code, w.last_full_fetch_at,
      w.consignee_normalized, w.destination_agent,
      (coalesce(s.items_con_estado, 0) > 0 and coalesce(s.piezas_fuera, 0) > 0
       and coalesce(s.piezas_onhand, 0) > 0) as es_parcial,
      w.pieces as piezas_recibo
    from public.magaya_warehouse_receipts w
    left join public.v_wh_wr_saldo s on s.wr_number = w.wr_number
    where
      case when coalesce(s.items_con_estado, 0) > 0
           then coalesce(s.piezas_onhand, 0) > 0
           else (w.out_date is null and w.status = 'OnHand') end
      and w.last_full_fetch_at >= (now() - interval '7 days')
      and coalesce(w.entry_date, w.created_on) >= (current_date - 180)
      and w.consignee !~~* '%gloval%'
      -- El umbral de entrada también sigue al plazo del cliente: con 60 días
      -- la carga empieza a avisarse a los 45, no a los 15.
      and (current_date - coalesce(w.entry_date, w.created_on)) >= (public.wh_dias_libres(w.consignee) - 15)
  ),
  own as (
    select b.wr_number,
      bool_or(c.customer_service_id is not null or c.assigned_to is not null) as tiene_dueno,
      bool_or(
        c.customer_service_id = (select id from me)
        or c.assigned_to = (select id from me)
        or c.assigned_to in (select ex from my_execs)
      ) as mio
    from base b
    left join public.clients c
      on c.deleted_at is null
     and c.company_name_normalized is not null
     and length(c.company_name_normalized) >= 5
     and b.consignee_normalized is not null
     and (
       c.company_name_normalized = b.consignee_normalized
       or b.consignee_normalized like c.company_name_normalized || ' %'
       or c.company_name_normalized like b.consignee_normalized || ' %'
     )
    group by b.wr_number
  )
  select
    b.wr_number, b.consignee, b.shipper, b.entrada, b.dias,
    (case when b.dias >= b.dias_libres     then 'VENCIDO'
          when b.dias >= b.dias_libres - 7 then 'POR_VENCER'
          else 'ATENCION' end)::text,
    b.pieces, b.weight, b.warehouse_zone, b.location_code, b.last_full_fetch_at,
    ( select c2.cs_email from public.client_notify_contacts c2
        where c2.cs_email is not null
          and length(split_part(upper(c2.consignee_hint), ' (', 1)) >= 3
          and upper(b.consignee) like ('%' || split_part(upper(c2.consignee_hint), ' (', 1) || '%')
        limit 1),
    (not coalesce(o.tiene_dueno, false)),
    b.es_parcial,
    b.piezas_recibo,
    b.dias_libres
  from base b
  join own o on o.wr_number = b.wr_number
  where
    coalesce((select role from me), '') in ('Admin','VP','Manager')
    or (
      (
        coalesce((select role from me), '') = 'Customer Service'
        or (
          coalesce((select role from me), '') = 'Administration'
          and exists (select 1 from public.cs_assignments ca where ca.cs_user_id = (select id from me) and ca.active)
        )
      )
      and coalesce((select office from me), '') <> ''
      and (
        -- Su CLIENTE de cartera se ve SIEMPRE, venga con el agente que venga.
        o.mio
        -- Lo demás, por el agente de su oficina, y solo si nadie lo tiene.
        or (coalesce(b.destination_agent, '') ~* ('gloval.*' || lower((select office from me)))
            and not coalesce(o.tiene_dueno, false))
      )
    );
$function$;

CREATE OR REPLACE FUNCTION public.wh_whr_backfill_goteo(p_lote integer DEFAULT 25, p_umbral integer DEFAULT 30)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_pend   int;
  v_enc    int := 0;
  v_quedan int;
  v_reenl  jsonb;
begin
  select count(*) into v_pend
  from wr_saldo_queue
  where resuelto_at is null and intentos < 3;

  if v_pend >= p_umbral then
    return jsonb_build_object('pendientes_en_cola', v_pend, 'encolados', 0);
  end if;

  with elegidos as (
    select u.wr_number
    from wh_whr_backfill_universo u
    where not exists (select 1 from magaya_wr_items i
                      where i.wr_number = u.wr_number and i.whr_item_id is not null)
      and not exists (select 1 from wr_saldo_queue q
                      where q.wr_number = u.wr_number
                        and ((q.resuelto_at is null and q.intentos < 3)  -- ya está en fila
                             or q.ultimo_intento_at >= u.creado_at))    -- ya se intentó con v24
    order by u.nivel, u.entrada desc nulls last, u.wr_number desc
    limit greatest(p_lote - v_pend, 0)
  )
  insert into wr_saldo_queue (wr_number, prioridad, intentos, ultimo_intento_at, resuelto_at, error)
  select wr_number, 3, 0, null, null, null from elegidos
  on conflict (wr_number) do update
    set prioridad = 3, intentos = 0, ultimo_intento_at = null, resuelto_at = null, error = null;
  get diagnostics v_enc = row_count;

  if v_enc = 0 and v_pend = 0 then
    select count(*) into v_quedan
    from wh_whr_backfill_universo u
    where not exists (select 1 from magaya_wr_items i
                      where i.wr_number = u.wr_number and i.whr_item_id is not null);
    v_reenl := consolidado_piezas_reenlazar();
    perform cron.unschedule(jobid) from cron.job where jobname = 'wh-whr-backfill-goteo';
    return jsonb_build_object('terminado', true, 'sin_numero_al_cierre', v_quedan, 'reenlace', v_reenl);
  end if;

  return jsonb_build_object('pendientes_en_cola', v_pend, 'encolados', v_enc);
end;
$function$;

CREATE OR REPLACE FUNCTION public.wh_wrs_pendientes_de_aviso(p_hours integer DEFAULT 168, p_limit integer DEFAULT 10)
 RETURNS TABLE(wr_number text, consignee text, synced_at timestamp with time zone)
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select w.wr_number, w.consignee, w.synced_at
  from public.magaya_warehouse_receipts w
  where (
      coalesce(w.entry_date, w.created_on) >= (current_date - ((greatest(p_hours,24) / 24)::int))
      or (w.created_at >= now() - make_interval(hours => greatest(p_hours, 24))
          and w.status = 'OnHand')
    )
    and coalesce(w.consignee, '') !~* '^\s*([a-z]{1,2}[\s.]+)?gloval'
    and not exists (
      select 1 from public.wh_notices n where n.wr_number = w.wr_number
    )
  order by coalesce(w.entry_date, w.created_on) desc, w.wr_number desc
  limit greatest(1, least(p_limit, 50));
$function$;

CREATE OR REPLACE FUNCTION public.wr_destination_to_office(p_port text)
 RETURNS text
 LANGUAGE sql
 IMMUTABLE
 SET search_path TO 'public', 'pg_catalog'
AS $function$
  select case
    when p_port is null or p_port = '' then null
    when p_port ilike '%quito%' or p_port ilike '%guayaquil%'    then 'Ecuador'
    when p_port ilike '%lima%'                                   then 'Peru'
    when p_port ilike '%panama%'                                 then 'Panama'
    when p_port ilike '%miami%' or p_port ilike '%florida%' or
         p_port ilike '%new york%' or p_port ilike '%houston%'   then 'USA'
    when p_port ilike '%san jose%' or p_port ilike '%santo domingo%' or
         p_port ilike '%guatemala%' or p_port ilike '%tegucigalpa%' or
         p_port ilike '%managua%'  or p_port ilike '%san salvador%' then 'USA'
    else null
  end;
$function$;

CREATE OR REPLACE FUNCTION public.wr_destination_to_office(p_port text, p_agent text DEFAULT NULL::text)
 RETURNS text
 LANGUAGE plpgsql
 STABLE
 SET search_path TO 'public', 'pg_catalog'
AS $function$
declare
  v_office text;
begin
  -- Primary: destination_port
  v_office := case
    when p_port ilike '%quito%' or p_port ilike '%guayaquil%'    then 'Ecuador'
    when p_port ilike '%lima%'                                   then 'Peru'
    when p_port ilike '%panama%'                                 then 'Panama'
    when p_port ilike '%miami%' or p_port ilike '%florida%' or
         p_port ilike '%new york%' or p_port ilike '%houston%'   then 'USA'
    when p_port ilike '%san jose%' or p_port ilike '%santo domingo%' or
         p_port ilike '%guatemala%' or p_port ilike '%tegucigalpa%' or
         p_port ilike '%managua%'  or p_port ilike '%san salvador%' then 'USA'
    else null
  end;
  if v_office is not null then return v_office; end if;

  -- Fallback: consultar agent_office_mapping
  if p_agent is null or p_agent = '' then return null; end if;
  select office into v_office
    from public.agent_office_mapping
    where active and p_agent ilike agent_pattern
    order by length(agent_pattern) desc  -- preferir patrones más específicos
    limit 1;
  return v_office;
end $function$;

CREATE OR REPLACE FUNCTION public.wr_is_gloval_usa(p_issued_by text)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE
 SET search_path TO 'public', 'pg_catalog'
AS $function$
  select coalesce(p_issued_by ilike '%gloval%shipping%usa%', false);
$function$;

CREATE OR REPLACE FUNCTION public.wr_redactar_notas()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  if new.notes is not null and new.notes ~* 'password|passw|contrase|\mclave\M|\mpwd\M|MAGAYA\s*PAYMENT' then
    new.notes := public.redactar_credenciales(new.notes);
  end if;
  return new;
end $function$;
