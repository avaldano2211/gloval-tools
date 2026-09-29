-- Tablas (columnas + PK/UNIQUE/CHECK/FK)
-- Origen: Supabase GES (wfzdrqfurwnakrfdnbgf), esquemas public, archive, private, timeclock.
-- Extraído del catálogo el 2026-09-29 (solo lectura). Referencia: NO ejecutar en Azure.
-- Credenciales redactadas como <SUPABASE_*>.

CREATE TABLE archive.magaya_charges (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  charge_guid text NOT NULL,
  shipment_number text NOT NULL,
  shipment_guid text,
  charge_type text,
  entity_name text,
  entity_guid text,
  quantity numeric(12,4) DEFAULT 1,
  price numeric(14,4),
  amount numeric(14,2),
  currency text DEFAULT 'USD'::text,
  charge_description text,
  charge_code text,
  charge_category text,
  account_type text,
  account_name text,
  status text,
  is_prepaid boolean DEFAULT false,
  is_credit boolean DEFAULT false,
  is_third_party boolean DEFAULT false,
  synced_at timestamp with time zone DEFAULT now(),
  created_at timestamp with time zone DEFAULT now(),
  company_id uuid DEFAULT 'aba24859-159c-424b-8ef3-d122fba41b7c'::uuid NOT NULL,
  CONSTRAINT magaya_charges_pkey PRIMARY KEY (id),
  CONSTRAINT magaya_charges_company_guid_key UNIQUE (company_id, charge_guid)
);

CREATE TABLE private._audit_billing_aliases (
  client_name_billing text NOT NULL,
  crm_client_id uuid NOT NULL,
  notes text,
  added_by text,
  added_at timestamp with time zone DEFAULT now(),
  CONSTRAINT _audit_billing_aliases_pkey PRIMARY KEY (client_name_billing)
);

CREATE TABLE private._audit_billing_ec_2026q1 (
  client_name_billing text NOT NULL,
  vendedor_billing text,
  total_ytd numeric,
  client_name_norm text GENERATED ALWAYS AS (normalize_company_name(client_name_billing)) STORED
);

CREATE TABLE private._audit_billing_ruc (
  client_name_billing text,
  vendedor_billing text,
  client_name_norm text,
  total_ytd numeric,
  magaya_tax_id text,
  magaya_name text
);

CREATE TABLE private._audit_clients_ec (
  id uuid,
  company_name text,
  norm text,
  norm_no_parens text,
  assigned_to uuid,
  is_house_account boolean,
  office text
);

CREATE TABLE private._audit_clients_ec_ruc (
  id uuid,
  company_name text,
  ruc text,
  ruc_clean text,
  assigned_to uuid,
  is_house_account boolean
);

CREATE TABLE private.cifras_sem31 (
  wr text,
  hbl text,
  pcs integer,
  kg numeric,
  cbm numeric
);

CREATE TABLE private.client_merge_audit (
  id bigint DEFAULT nextval('private.client_merge_audit_id_seq'::regclass) NOT NULL,
  merged_at timestamp with time zone DEFAULT now(),
  batch text DEFAULT 'dedup-2026-07-23'::text,
  table_name text,
  action text,
  old_client_id uuid,
  new_client_id uuid,
  row_json jsonb,
  CONSTRAINT client_merge_audit_pkey PRIMARY KEY (id)
);

CREATE TABLE private.client_merge_survivor_snapshot (
  survivor_id uuid,
  merged_at timestamp with time zone DEFAULT now(),
  batch text DEFAULT 'dedup-2026-07-23'::text,
  snapshot jsonb
);

CREATE TABLE private.closings_bak_peru_janfeb_20260804 (
  id uuid,
  old_executive_id uuid,
  backed_up_at timestamp with time zone
);

CREATE TABLE private.consolidado_avisos_bak_27jul (
  id uuid,
  consolidado_id uuid,
  cliente_key text,
  es_agente boolean,
  cs_email text,
  subject text,
  body_html text,
  recipients jsonb,
  wr_numbers text[],
  total_piezas integer,
  total_peso_lb numeric,
  total_cbm numeric,
  status text,
  sent_at timestamp with time zone,
  sent_by uuid,
  error text,
  created_at timestamp with time zone,
  updated_at timestamp with time zone
);

CREATE TABLE private.iva_backfill_audit (
  id bigint DEFAULT nextval('private.iva_backfill_audit_id_seq'::regclass) NOT NULL,
  applied_at timestamp with time zone DEFAULT now(),
  batch text DEFAULT 'iva-backfill-2026-07-24'::text,
  doc_type text,
  doc_id uuid,
  quote_number text,
  old_cost numeric,
  old_sale numeric,
  old_profit numeric,
  iva_cost numeric,
  iva_sale numeric,
  iva_line_id uuid,
  CONSTRAINT iva_backfill_audit_pkey PRIMARY KEY (id)
);

CREATE TABLE private.respaldo_estiba_sem31 (
  linea_id uuid,
  wr_number text,
  contenedor_id uuid,
  posicion integer,
  respaldado_at timestamp with time zone
);

CREATE TABLE private.tmp_excel2_diff (
  cliente text,
  cliente_norm text,
  mbl text,
  hbl text,
  etd date
);

CREATE TABLE public._cartera_ecu_20260908 (
  entidad text,
  numero text,
  monto numeric(14,2),
  fecha_emision text,
  vence text
);

CREATE TABLE public._legacy_agent_rates (
  id bigint DEFAULT nextval('agent_rates_id_seq'::regclass) NOT NULL,
  agent text,
  pol text,
  pod text,
  carrier text,
  rate_20gp numeric,
  rate_40st numeric,
  rate_40hq numeric,
  rate_40nor numeric,
  free_days integer,
  nor_free_days integer,
  validity text,
  notes text,
  trade_lane text DEFAULT 'CHINA-ECUADOR'::text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT agent_rates_pkey PRIMARY KEY (id)
);

CREATE TABLE public._marcia_retardos_20260904 (
  kind text,
  nombre_norm text,
  nombre_orig text,
  bucket_actual numeric,
  total numeric
);

CREATE TABLE public._q (
  prueba text,
  esperado text,
  obtenido text,
  ok boolean
);

CREATE TABLE public.activities (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  client_id uuid NOT NULL,
  user_id uuid NOT NULL,
  activity_type text NOT NULL,
  description text NOT NULL,
  route_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT activities_pkey PRIMARY KEY (id),
  CONSTRAINT activities_activity_type_check CHECK ((activity_type = ANY (ARRAY['contact'::text, 'meeting'::text, 'call'::text, 'email'::text, 'note'::text])))
);

CREATE TABLE public.activity_logs (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  time_entry_id uuid NOT NULL,
  user_id uuid NOT NULL,
  timestamp timestamp with time zone DEFAULT now() NOT NULL,
  is_active boolean DEFAULT true NOT NULL,
  activity_type text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT activity_logs_pkey PRIMARY KEY (id),
  CONSTRAINT activity_logs_activity_type_check CHECK ((activity_type = ANY (ARRAY['mouse'::text, 'keyboard'::text, 'click'::text, 'idle'::text, 'active'::text])))
);

CREATE TABLE public.agent_files (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  agent_id uuid,
  file_name text NOT NULL,
  file_url text NOT NULL,
  file_type text,
  file_size integer,
  category text DEFAULT 'Agreement'::text,
  description text,
  uploaded_by uuid,
  uploaded_at timestamp with time zone DEFAULT now(),
  CONSTRAINT agent_files_pkey PRIMARY KEY (id)
);

CREATE TABLE public.agent_office_mapping (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  agent_pattern text NOT NULL,
  office text NOT NULL,
  notes text,
  active boolean DEFAULT true,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT agent_office_mapping_pkey PRIMARY KEY (id)
);

CREATE TABLE public.agents (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  company_name text NOT NULL,
  country text NOT NULL,
  city text,
  agent_type text[],
  contact_name text,
  contact_email text,
  contact_phone text,
  contact_whatsapp text,
  services_offered text[],
  trade_lanes text[],
  provides_rates boolean DEFAULT false,
  sends_freehand boolean DEFAULT false,
  credit_terms_with_us text,
  commission_percentage numeric(5,2),
  status text DEFAULT 'Active'::text,
  notes text,
  rating integer,
  created_by uuid,
  handling_fee numeric(10,2),
  bl_fee numeric(10,2),
  telex_release_fee numeric(10,2),
  documentation_fee numeric(10,2),
  customs_clearance_fee numeric(10,2),
  delivery_20ft numeric(10,2),
  delivery_40ft numeric(10,2),
  delivery_40hc numeric(10,2),
  storage_per_day numeric(10,2),
  examination_fee numeric(10,2),
  other_fees text,
  other_fees_amount numeric(10,2),
  fee_notes text,
  fee_currency text DEFAULT 'USD'::text,
  fees_valid_until date,
  agent_gives_credit boolean DEFAULT false,
  agent_credit_limit numeric(12,2),
  agent_credit_terms text,
  agent_credit_status text DEFAULT 'Active'::text,
  we_give_credit boolean DEFAULT false,
  our_credit_limit numeric(12,2),
  our_credit_terms text,
  our_credit_approved_date date,
  our_credit_approved_by text,
  contact1_name text,
  contact1_title text,
  contact1_email text,
  contact1_phone text,
  contact1_mobile text,
  contact2_name text,
  contact2_title text,
  contact2_email text,
  contact2_phone text,
  contact2_mobile text,
  contact3_name text,
  contact3_title text,
  contact3_email text,
  contact3_phone text,
  contact3_mobile text,
  network text,
  CONSTRAINT agents_pkey PRIMARY KEY (id),
  CONSTRAINT agents_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);

CREATE TABLE public.air_carriers (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  name text NOT NULL,
  code text,
  carrier_type text DEFAULT 'airline'::text,
  active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT air_carriers_pkey PRIMARY KEY (id)
);

CREATE TABLE public.air_rates (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  air_carrier_id uuid,
  agent_id uuid,
  origin_code text NOT NULL,
  origin_city text,
  origin_country text,
  destination_code text NOT NULL,
  destination_city text,
  destination_country text,
  route_description text,
  frequency text,
  transit_time text,
  currency text DEFAULT 'USD'::text,
  minimum_rate numeric DEFAULT 0,
  rate_minus45 numeric,
  rate_45 numeric,
  rate_100 numeric,
  rate_300 numeric,
  rate_500 numeric,
  rate_1000 numeric,
  rate_2000 numeric,
  rate_3000 numeric,
  rate_4000 numeric,
  rate_5000 numeric,
  cha_fee numeric DEFAULT 0,
  soa_fee numeric DEFAULT 0,
  awa_fee numeric DEFAULT 0,
  airline_fees text,
  max_dimensions text,
  max_weight_per_piece text,
  source_region text,
  effective_date date,
  expiry_date date,
  active boolean DEFAULT true,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  cargo_type text DEFAULT 'GCR'::text,
  scope text DEFAULT 'global'::text NOT NULL,
  updated_by text,
  service_level text DEFAULT 'STANDARD'::text NOT NULL,
  last_confirmed_at date,
  last_confirmed_by text,
  CONSTRAINT air_rates_pkey PRIMARY KEY (id),
  CONSTRAINT air_rates_cargo_type_check CHECK ((cargo_type = ANY (ARRAY['GCR'::text, 'DGR'::text, 'PHARMA'::text, 'PERISHABLE'::text]))),
  CONSTRAINT air_rates_scope_check CHECK ((scope = ANY (ARRAY['global'::text, 'USA'::text, 'PER'::text, 'ECU'::text, 'PAN'::text]))),
  CONSTRAINT air_rates_service_level_check CHECK ((service_level = ANY (ARRAY['STANDARD'::text, 'PRIORITY'::text, 'RESERVED'::text, 'SPOT'::text, 'ACX'::text, 'NON_STACK'::text, 'NON_STACK_MAINDECK'::text, 'EXPRESS_MAINDECK'::text, 'COURIER_BAGS'::text, 'COURIER_EXPRESS'::text])))
);

CREATE TABLE public.ar_ap_sync_queue (
  id bigint GENERATED BY DEFAULT AS IDENTITY NOT NULL,
  scope text NOT NULL,
  start_date date NOT NULL,
  end_date date NOT NULL,
  recheck_interval interval DEFAULT '1 day'::interval NOT NULL,
  status text DEFAULT 'idle'::text NOT NULL,
  request_id bigint,
  attempts integer DEFAULT 0 NOT NULL,
  last_run_at timestamp with time zone,
  last_ok_at timestamp with time zone,
  last_response jsonb,
  CONSTRAINT ar_ap_sync_queue_pkey PRIMARY KEY (id),
  CONSTRAINT ar_ap_sync_queue_scope_start_date_end_date_key UNIQUE (scope, start_date, end_date)
);

CREATE TABLE public.arap_live_open (
  office text NOT NULL,
  tipo text NOT NULL,
  number text NOT NULL,
  fecha date,
  vence date,
  entidad text,
  es_ic boolean DEFAULT false,
  saldo_usd numeric NOT NULL,
  dias_venc integer,
  tramo text,
  computed_at timestamp with time zone DEFAULT now(),
  CONSTRAINT arap_live_open_pkey PRIMARY KEY (office, tipo, number)
);

CREATE TABLE public.arap_live_snapshot (
  fecha date NOT NULL,
  office text NOT NULL,
  tipo text NOT NULL,
  docs integer,
  total_usd numeric,
  docs_90 integer,
  docs_180 integer,
  computed_at timestamp with time zone DEFAULT now(),
  CONSTRAINT arap_live_snapshot_pkey PRIMARY KEY (fecha, office, tipo)
);

CREATE TABLE public.audit_log (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  table_name text NOT NULL,
  record_id uuid,
  action text NOT NULL,
  old_values jsonb,
  new_values jsonb,
  changes_summary text,
  user_id uuid,
  user_name text,
  CONSTRAINT audit_log_pkey PRIMARY KEY (id)
);

CREATE TABLE public.bank_account (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  tenant_id uuid NOT NULL,
  office_id uuid NOT NULL,
  bank_name text NOT NULL,
  account_nickname text,
  account_number_last4 text,
  account_number_encrypted text,
  iban text,
  swift text,
  account_type text DEFAULT 'checking'::text NOT NULL,
  currency text NOT NULL,
  current_balance numeric(18,2) DEFAULT 0 NOT NULL,
  available_balance numeric(18,2) DEFAULT 0 NOT NULL,
  credit_limit numeric(18,2),
  min_balance_alert numeric(18,2),
  reconciled_through_date date,
  bank_feed_provider text,
  bank_feed_account_id text,
  active boolean DEFAULT true NOT NULL,
  notes text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT bank_account_pkey PRIMARY KEY (id)
);

CREATE TABLE public.bank_transaction (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  tenant_id uuid NOT NULL,
  bank_account_id uuid NOT NULL,
  transaction_date date NOT NULL,
  value_date date,
  amount numeric(18,2) NOT NULL,
  currency text NOT NULL,
  description text,
  memo text,
  reference text,
  counterparty_name_raw text,
  matched_party_id uuid,
  matched_invoice_id uuid,
  matched_payment_id uuid,
  category text,
  category_confidence numeric(3,2),
  status text DEFAULT 'imported'::text NOT NULL,
  source text DEFAULT 'manual_csv'::text NOT NULL,
  reconciliation_batch_id uuid,
  raw_data jsonb DEFAULT '{}'::jsonb,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  subcategory text,
  expense_purpose text,
  CONSTRAINT bank_transaction_pkey PRIMARY KEY (id)
);

CREATE TABLE public.birthday_emails_sent (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  contact_id uuid,
  email text NOT NULL,
  sent_at timestamp with time zone DEFAULT now(),
  status text DEFAULT 'sent'::text NOT NULL,
  error_message text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT birthday_emails_sent_pkey PRIMARY KEY (id)
);

CREATE TABLE public.bodega_tenants (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  nombre text NOT NULL,
  campo text DEFAULT 'agente'::text NOT NULL,
  pais text,
  notas text,
  activo boolean DEFAULT true NOT NULL,
  creado_por uuid,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT bodega_tenants_pkey PRIMARY KEY (id),
  CONSTRAINT bodega_tenants_campo_check CHECK ((campo = ANY (ARRAY['agente'::text, 'consignatario'::text])))
);

CREATE TABLE public.brief_assets (
  key text NOT NULL,
  value text,
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT brief_assets_pkey PRIMARY KEY (key)
);

CREATE TABLE public.brief_emitido (
  fecha date NOT NULL,
  kind text DEFAULT 'daily'::text NOT NULL,
  hora timestamp with time zone DEFAULT now(),
  por text,
  nota text,
  CONSTRAINT brief_emitido_pkey PRIMARY KEY (fecha, kind)
);

CREATE TABLE public.caja_eod (
  fecha date NOT NULL,
  office text NOT NULL,
  monto_usd numeric,
  detalle text,
  fuente text,
  remitente text,
  hora_reporte text,
  computed_at timestamp with time zone DEFAULT now(),
  CONSTRAINT caja_eod_pkey PRIMARY KEY (fecha, office)
);

CREATE TABLE public.call_logs (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  call_id text,
  caller_phone text,
  call_duration_seconds integer,
  call_status text,
  intent text,
  transcript text,
  summary text,
  caller_name text,
  caller_company text,
  caller_email text,
  cargo_type text,
  appointment_requested boolean DEFAULT false,
  appointment_datetime text,
  is_lead boolean DEFAULT false,
  office text DEFAULT 'USA'::text,
  handled_by text DEFAULT 'Aria'::text,
  appointment_date text,
  appointment_time text,
  CONSTRAINT call_logs_pkey PRIMARY KEY (id)
);

CREATE TABLE public.carrier_advisories (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  carrier_code text NOT NULL,
  url text NOT NULL,
  title text NOT NULL,
  published_on date,
  kind text,
  effective_on date,
  affects_us boolean,
  body_text text,
  first_seen_at timestamp with time zone DEFAULT now() NOT NULL,
  notified_at timestamp with time zone,
  CONSTRAINT carrier_advisories_pkey PRIMARY KEY (id),
  CONSTRAINT carrier_advisories_url_key UNIQUE (url)
);

CREATE TABLE public.carrier_email_log (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  message_id text,
  from_address text,
  to_address text,
  subject text,
  received_at timestamp with time zone,
  body_excerpt text,
  raw_text text,
  carrier_detected text,
  parse_status text DEFAULT 'PENDING'::text,
  extracted jsonb,
  matched_shipment_id uuid,
  applied_changes jsonb,
  error_message text,
  llm_provider text,
  llm_tokens_used integer,
  created_at timestamp with time zone DEFAULT now(),
  processed_at timestamp with time zone,
  CONSTRAINT carrier_email_log_pkey PRIMARY KEY (id),
  CONSTRAINT carrier_email_log_message_id_key UNIQUE (message_id)
);

CREATE TABLE public.carrier_transit_times (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  carrier_id uuid NOT NULL,
  route_id uuid NOT NULL,
  transit_time_days integer NOT NULL,
  service_name text,
  service_frequency text,
  is_direct boolean DEFAULT true,
  transshipment_port_id uuid,
  transit_source text DEFAULT 'MANUAL'::text,
  verified_at timestamp with time zone,
  verified_by uuid,
  notes text,
  active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  vessel_name text,
  CONSTRAINT carrier_transit_times_pkey PRIMARY KEY (id),
  CONSTRAINT carrier_transit_times_carrier_id_route_id_key UNIQUE (carrier_id, route_id)
);

CREATE TABLE public.carriers (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  name character varying NOT NULL,
  code character varying NOT NULL,
  active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  contact_email character varying,
  contact_phone character varying,
  logo_url text,
  email_domains text[] DEFAULT '{}'::text[] NOT NULL,
  CONSTRAINT carriers_pkey PRIMARY KEY (id),
  CONSTRAINT carriers_code_key UNIQUE (code)
);

CREATE TABLE public.cash_movement (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  tenant_id uuid NOT NULL,
  office_id uuid NOT NULL,
  bank_account_id uuid,
  direction text NOT NULL,
  category text NOT NULL,
  source_type text,
  source_id uuid,
  party_id uuid,
  amount numeric(18,2) NOT NULL,
  currency text NOT NULL,
  amount_in_usd numeric(18,2),
  expected_date date NOT NULL,
  actual_date date,
  status text DEFAULT 'forecast'::text NOT NULL,
  confidence numeric(3,2) DEFAULT 0.85,
  linked_bank_transaction_id uuid,
  linked_scenario_id uuid,
  notes text,
  created_by uuid,
  approved_by uuid,
  approved_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  counterparty_name text,
  external_reference text,
  external_guid text,
  CONSTRAINT cash_movement_pkey PRIMARY KEY (id),
  CONSTRAINT cash_movement_external_guid_uq UNIQUE (tenant_id, external_guid)
);

CREATE TABLE public.christmas_audit_log (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  occurred_at timestamp with time zone DEFAULT now() NOT NULL,
  actor_id uuid,
  actor_email text,
  actor_role text,
  table_name text NOT NULL,
  operation text NOT NULL,
  record_id text,
  old_data jsonb,
  new_data jsonb,
  changed_cols text[],
  CONSTRAINT christmas_audit_log_pkey PRIMARY KEY (id),
  CONSTRAINT christmas_audit_log_operation_check CHECK ((operation = ANY (ARRAY['INSERT'::text, 'UPDATE'::text, 'DELETE'::text, 'LOGIN'::text])))
);

CREATE TABLE public.christmas_bookings (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  tenant_id uuid NOT NULL,
  nra_number text,
  customer_name text,
  customer_email text,
  customer_phone text,
  destination_address jsonb,
  origin_port_code text NOT NULL,
  dest_port_code text NOT NULL,
  dim_length_cm numeric,
  dim_width_cm numeric,
  dim_height_cm numeric,
  actual_weight_kg numeric,
  cbm numeric NOT NULL,
  chargeable_kg numeric NOT NULL,
  ofr_usd numeric NOT NULL,
  surcharges jsonb DEFAULT '[]'::jsonb NOT NULL,
  subtotal_usd numeric NOT NULL,
  gloval_margin_usd numeric NOT NULL,
  total_usd numeric NOT NULL,
  transit_days integer,
  status text DEFAULT 'pending'::text NOT NULL,
  os_booking_id uuid,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  confirmed_at timestamp with time zone,
  rep_id uuid,
  product_summary text,
  pallet_id uuid,
  order_number text,
  invoice_number text,
  cargo_pieces jsonb,
  documents jsonb DEFAULT '[]'::jsonb NOT NULL,
  CONSTRAINT bookings_pkey PRIMARY KEY (id),
  CONSTRAINT bookings_nra_number_key UNIQUE (nra_number),
  CONSTRAINT christmas_bookings_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'confirmed'::text, 'fulfilled'::text, 'shipped'::text, 'arrived'::text, 'delivered'::text, 'cancelled'::text])))
);

CREATE TABLE public.christmas_destinations (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  tenant_id uuid NOT NULL,
  port_code text NOT NULL,
  port_label text NOT NULL,
  country_iso2 text NOT NULL,
  transit_days integer,
  is_quick boolean DEFAULT false NOT NULL,
  active boolean DEFAULT true NOT NULL,
  display_order integer DEFAULT 0 NOT NULL,
  is_custom boolean DEFAULT false NOT NULL,
  region text,
  created_by uuid,
  CONSTRAINT destinations_pkey PRIMARY KEY (id),
  CONSTRAINT destinations_tenant_id_port_code_key UNIQUE (tenant_id, port_code)
);

CREATE TABLE public.christmas_fee_overrides (
  tenant_id uuid NOT NULL,
  destination_code text NOT NULL,
  fee_pct numeric(5,2) NOT NULL,
  updated_by uuid,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT fee_overrides_pkey PRIMARY KEY (tenant_id, destination_code),
  CONSTRAINT fee_overrides_fee_pct_check CHECK (((fee_pct >= (0)::numeric) AND (fee_pct <= (100)::numeric)))
);

CREATE TABLE public.christmas_global_settings (
  tenant_id uuid NOT NULL,
  key text NOT NULL,
  value jsonb NOT NULL,
  updated_by uuid,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT global_settings_pkey PRIMARY KEY (tenant_id, key)
);

CREATE TABLE public.christmas_pallet_presets (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  tenant_id uuid NOT NULL,
  label text NOT NULL,
  length_cm numeric NOT NULL,
  width_cm numeric NOT NULL,
  height_cm numeric NOT NULL,
  capacity_kg numeric,
  show_weight boolean DEFAULT false NOT NULL,
  display_order integer DEFAULT 0 NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT pallet_presets_pkey PRIMARY KEY (id)
);

CREATE TABLE public.christmas_products (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  tenant_id uuid NOT NULL,
  sku text,
  name text NOT NULL,
  icon_variant text,
  length_cm numeric NOT NULL,
  width_cm numeric NOT NULL,
  height_cm numeric NOT NULL,
  weight_kg numeric,
  price_from_usd numeric,
  is_popular boolean DEFAULT false NOT NULL,
  image_url text,
  display_order integer DEFAULT 0 NOT NULL,
  metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  handle text,
  body_html text,
  vendor text,
  product_type text,
  tags text[] DEFAULT '{}'::text[] NOT NULL,
  style_key text,
  weight_from_shopify boolean DEFAULT false NOT NULL,
  dims_estimated boolean DEFAULT true NOT NULL,
  all_image_urls text[] DEFAULT '{}'::text[] NOT NULL,
  all_variant_skus text[] DEFAULT '{}'::text[] NOT NULL,
  variant_count integer,
  shopify_id bigint,
  source text DEFAULT 'manual'::text NOT NULL,
  active boolean DEFAULT true NOT NULL,
  CONSTRAINT products_pkey PRIMARY KEY (id),
  CONSTRAINT products_tenant_id_sku_key UNIQUE (tenant_id, sku),
  CONSTRAINT products_source_check CHECK ((source = ANY (ARRAY['manual'::text, 'scraped'::text])))
);

CREATE TABLE public.christmas_tenants (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  slug text NOT NULL,
  name text NOT NULL,
  origin_port_code text DEFAULT 'USMIA'::text NOT NULL,
  margin_kind text DEFAULT 'percent'::text NOT NULL,
  margin_value numeric DEFAULT 25 NOT NULL,
  active boolean DEFAULT true NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT tenants_pkey PRIMARY KEY (id),
  CONSTRAINT tenants_slug_key UNIQUE (slug),
  CONSTRAINT tenants_margin_kind_check CHECK ((margin_kind = ANY (ARRAY['percent'::text, 'flat_usd'::text])))
);

CREATE TABLE public.christmas_user_profiles (
  user_id uuid NOT NULL,
  email text,
  full_name text,
  role text DEFAULT 'rep'::text NOT NULL,
  tenant_id uuid,
  active boolean DEFAULT true NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  username text,
  CONSTRAINT user_profiles_pkey PRIMARY KEY (user_id),
  CONSTRAINT user_profiles_role_check CHECK ((role = ANY (ARRAY['rep'::text, 'manager'::text, 'admin'::text])))
);

CREATE TABLE public.cierres_liquidacion (
  mes text NOT NULL,
  office text NOT NULL,
  cerrado numeric,
  facturado numeric,
  carryover numeric,
  conv_pct numeric,
  estado text,
  nota text,
  computed_at timestamp with time zone DEFAULT now(),
  CONSTRAINT cierres_liquidacion_pkey PRIMARY KEY (mes, office)
);

CREATE TABLE public.cl_alerts (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  warehouse_id uuid,
  kind cl_alert_kind NOT NULL,
  severity text DEFAULT 'info'::text NOT NULL,
  title text NOT NULL,
  body text,
  manifest_source_id uuid,
  picking_task_id uuid,
  staging_task_id uuid,
  loading_task_id uuid,
  recipient_user_id uuid,
  action_label text,
  action_url text,
  status cl_alert_status DEFAULT 'unread'::cl_alert_status NOT NULL,
  acknowledged_by uuid,
  acknowledged_at timestamp with time zone,
  due_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT cl_alerts_pkey PRIMARY KEY (id)
);

CREATE TABLE public.cl_audit_log (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  action text NOT NULL,
  target_table text NOT NULL,
  target_id uuid NOT NULL,
  performed_by uuid NOT NULL,
  reason text NOT NULL,
  metadata jsonb DEFAULT '{}'::jsonb,
  performed_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT cl_audit_log_pkey PRIMARY KEY (id)
);

CREATE TABLE public.cl_container_types (
  code text NOT NULL,
  description text NOT NULL,
  max_payload_kg numeric(10,2) NOT NULL,
  max_volume_m3 numeric(10,2) NOT NULL,
  tare_kg numeric(10,2),
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT cl_container_types_pkey PRIMARY KEY (code)
);

CREATE TABLE public.cl_scan_events (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  picking_task_id uuid,
  staging_task_id uuid,
  loading_task_id uuid,
  scanned_barcode text NOT NULL,
  matched_item_id uuid,
  result scan_result NOT NULL,
  scanned_by uuid NOT NULL,
  scanned_at timestamp with time zone DEFAULT now() NOT NULL,
  device_id text,
  metadata jsonb DEFAULT '{}'::jsonb,
  CONSTRAINT cl_scan_events_pkey PRIMARY KEY (id),
  CONSTRAINT cl_scan_events_check CHECK ((((((picking_task_id IS NOT NULL))::integer + ((staging_task_id IS NOT NULL))::integer) + ((loading_task_id IS NOT NULL))::integer) = 1))
);

CREATE TABLE public.cl_warehouses (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  code text NOT NULL,
  name text NOT NULL,
  city text,
  country text,
  split_threshold integer DEFAULT 20 NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT cl_warehouses_pkey PRIMARY KEY (id),
  CONSTRAINT cl_warehouses_code_key UNIQUE (code)
);

CREATE TABLE public.client_notify_contacts (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  client_id uuid,
  consignee_hint text,
  fwd_hint text,
  email text NOT NULL,
  role text DEFAULT 'TO'::text NOT NULL,
  source text DEFAULT 'MINED'::text NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  cs_email text,
  CONSTRAINT client_notify_contacts_pkey PRIMARY KEY (id),
  CONSTRAINT client_notify_contacts_role_check CHECK ((role = ANY (ARRAY['TO'::text, 'CC'::text, 'CC_INTERNO'::text]))),
  CONSTRAINT client_notify_contacts_source_check CHECK ((source = ANY (ARRAY['MINED'::text, 'MANUAL'::text, 'MINADO_DOMINIO'::text])))
);

CREATE TABLE public.client_visits (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  client_id uuid NOT NULL,
  executive_id uuid NOT NULL,
  office text,
  scheduled_at timestamp with time zone NOT NULL,
  status text DEFAULT 'scheduled'::text NOT NULL,
  visit_type text DEFAULT 'presencial'::text NOT NULL,
  purpose text,
  location_address text,
  completed_at timestamp with time zone,
  outcome text,
  report_notes text,
  follow_up_required boolean DEFAULT false NOT NULL,
  follow_up_date date,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT client_visits_pkey PRIMARY KEY (id),
  CONSTRAINT client_visits_outcome_check CHECK (((outcome IS NULL) OR (outcome = ANY (ARRAY['positiva'::text, 'neutral'::text, 'negativa'::text, 'reagendar'::text])))),
  CONSTRAINT client_visits_status_check CHECK ((status = ANY (ARRAY['scheduled'::text, 'completed'::text, 'cancelled'::text, 'no_show'::text]))),
  CONSTRAINT client_visits_visit_type_check CHECK ((visit_type = ANY (ARRAY['presencial'::text, 'virtual'::text])))
);

CREATE TABLE public.clients (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  company_name text NOT NULL,
  client_type text NOT NULL,
  parent_ff_id uuid,
  industries text[] DEFAULT '{}'::text[],
  office text NOT NULL,
  assigned_to uuid,
  status text DEFAULT 'Prospect'::text NOT NULL,
  credit_term text,
  credit_line_amount numeric(12,2),
  created_at timestamp with time zone DEFAULT now(),
  ruc text,
  has_credit_approved boolean DEFAULT false,
  credit_limit numeric(12,2),
  credit_terms text,
  credit_approved_date date,
  credit_approved_by text,
  current_competitor text,
  competitor_notes text,
  switching_reason text,
  uses_coload boolean DEFAULT false,
  coload_routes text[],
  coload_partner text,
  created_by uuid,
  address_line1 text,
  address_line2 text,
  city text,
  state text,
  zip_code text,
  country text,
  latitude numeric(10,8),
  longitude numeric(11,8),
  google_place_id text,
  formatted_address text,
  is_direct boolean DEFAULT false,
  is_house_account boolean DEFAULT false,
  account_manager_id uuid,
  credit_status text DEFAULT 'no_credit'::text,
  credit_days integer DEFAULT 0,
  credit_approved_at timestamp with time zone,
  company_name_normalized text GENERATED ALWAYS AS (normalize_company_name(company_name)) STORED,
  customer_service_id uuid,
  deleted_at timestamp with time zone,
  deleted_by uuid,
  confianza_credit_amount numeric,
  handles_postdated_checks boolean,
  CONSTRAINT clients_pkey PRIMARY KEY (id),
  CONSTRAINT clients_client_type_check CHECK ((client_type = ANY (ARRAY['direct_client'::text, 'freight_forwarder'::text, 'ff_customer'::text, 'prospect'::text]))),
  CONSTRAINT clients_credit_term_check CHECK ((credit_term = ANY (ARRAY['net'::text, '15_days'::text, '30_days'::text, '45_days'::text]))),
  CONSTRAINT clients_office_check CHECK ((office = ANY (ARRAY['USA'::text, 'Panama'::text, 'Ecuador'::text, 'Peru'::text]))),
  CONSTRAINT clients_status_check CHECK ((status = ANY (ARRAY['Active'::text, 'Inactive'::text, 'Prospect'::text])))
);

CREATE TABLE public.closings (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  office text NOT NULL,
  executive_id uuid,
  quote_id text,
  week integer NOT NULL,
  month text NOT NULL,
  year integer NOT NULL,
  closing_date date NOT NULL,
  client_id uuid,
  client_name text,
  is_new_client boolean DEFAULT false,
  service_type text,
  trade_type text,
  incoterm text,
  pol_aol text,
  pod_aod text,
  carrier text,
  payment_type text,
  containers_20st integer DEFAULT 0,
  containers_40hc integer DEFAULT 0,
  teus numeric DEFAULT 0,
  kg_vol numeric DEFAULT 0,
  cbm numeric DEFAULT 0,
  tons numeric DEFAULT 0,
  furgon integer DEFAULT 0,
  revenue numeric NOT NULL,
  revenue_target numeric,
  cost numeric NOT NULL,
  profit_target numeric,
  profit numeric GENERATED ALWAYS AS ((revenue - cost)) STORED,
  margin numeric GENERATED ALWAYS AS (
CASE
    WHEN (revenue > (0)::numeric) THEN ((revenue - cost) / revenue)
    ELSE (0)::numeric
END) STORED,
  how_closed text,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  created_by uuid,
  margin_pct numeric DEFAULT 0,
  furgons integer DEFAULT 0,
  weekly_target_revenue numeric,
  weekly_target_profit numeric,
  agent_name text,
  containers_fr integer,
  containers_ot integer,
  cam_group text,
  cam_subgroup text,
  CONSTRAINT closings_pkey PRIMARY KEY (id),
  CONSTRAINT closings_service_type_check CHECK ((service_type = ANY (ARRAY['FCL'::text, 'LCL'::text, 'Air'::text, 'Courier'::text, 'Furgon'::text, 'Logistics'::text])))
);

CREATE TABLE public.cmm_chat_messages (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  conversation_id uuid NOT NULL,
  office text DEFAULT 'Ecuador'::text NOT NULL,
  role text NOT NULL,
  content text NOT NULL,
  citations jsonb,
  model text,
  input_tokens integer,
  output_tokens integer,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid,
  CONSTRAINT cmm_chat_messages_pkey PRIMARY KEY (id),
  CONSTRAINT cmm_chat_messages_role_check CHECK ((role = ANY (ARRAY['user'::text, 'assistant'::text, 'system'::text])))
);

CREATE TABLE public.cmm_client_aliases (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  office text DEFAULT 'Ecuador'::text NOT NULL,
  canonical_name text NOT NULL,
  alias_name text NOT NULL,
  notes text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid,
  CONSTRAINT cmm_client_aliases_pkey PRIMARY KEY (id),
  CONSTRAINT cmm_client_aliases_office_check CHECK ((office = ANY (ARRAY['Ecuador'::text, 'Peru'::text, 'Panama'::text, 'USA'::text])))
);

CREATE TABLE public.cmm_commission_policies (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  name text NOT NULL,
  office text DEFAULT 'Ecuador'::text NOT NULL,
  active boolean DEFAULT false NOT NULL,
  base_cmm_rate numeric(6,4) DEFAULT 0.1500 NOT NULL,
  margin_floor_pct numeric(6,2) DEFAULT 0.00 NOT NULL,
  tiers jsonb DEFAULT '[]'::jsonb NOT NULL,
  cost1_lcl numeric(10,2) DEFAULT 10 NOT NULL,
  cost1_hawb numeric(10,2) DEFAULT 10 NOT NULL,
  cost1_wr numeric(10,2) DEFAULT 0 NOT NULL,
  cost1_fcl numeric(10,2) DEFAULT 25 NOT NULL,
  cost1_default numeric(10,2) DEFAULT 10 NOT NULL,
  notes text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid,
  CONSTRAINT cmm_commission_policies_pkey PRIMARY KEY (id)
);

CREATE TABLE public.cmm_context_notes (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  office text DEFAULT 'Ecuador'::text NOT NULL,
  category text DEFAULT 'general'::text NOT NULL,
  content text NOT NULL,
  active boolean DEFAULT true NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid,
  CONSTRAINT cmm_context_notes_pkey PRIMARY KEY (id),
  CONSTRAINT cmm_context_notes_category_check CHECK ((category = ANY (ARRAY['cliente'::text, 'vendedor'::text, 'estrategia'::text, 'mercado'::text, 'operacion'::text, 'general'::text]))),
  CONSTRAINT cmm_context_notes_office_check CHECK ((office = ANY (ARRAY['Ecuador'::text, 'Peru'::text, 'Panama'::text, 'USA'::text])))
);

CREATE TABLE public.cmm_dismissed_actions (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  office text DEFAULT 'Ecuador'::text NOT NULL,
  seller_id uuid NOT NULL,
  action_id text NOT NULL,
  reason text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid,
  CONSTRAINT cmm_dismissed_actions_pkey PRIMARY KEY (id),
  CONSTRAINT cmm_dismissed_actions_office_check CHECK ((office = ANY (ARRAY['Ecuador'::text, 'Peru'::text, 'Panama'::text, 'USA'::text])))
);

CREATE TABLE public.cmm_insights (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  scope_type text NOT NULL,
  scope_id text,
  office text DEFAULT 'Ecuador'::text NOT NULL,
  period_label text NOT NULL,
  narrative_md text NOT NULL,
  highlights jsonb,
  model text,
  input_tokens integer,
  output_tokens integer,
  generated_at timestamp with time zone DEFAULT now() NOT NULL,
  generated_by uuid,
  CONSTRAINT cmm_insights_pkey PRIMARY KEY (id),
  CONSTRAINT cmm_insights_scope_type_check CHECK ((scope_type = ANY (ARRAY['team'::text, 'seller'::text])))
);

CREATE TABLE public.cmm_pending (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  upload_id uuid NOT NULL,
  seller_id uuid NOT NULL,
  office text DEFAULT 'Ecuador'::text NOT NULL,
  period_year integer NOT NULL,
  period_month integer NOT NULL,
  descripcion text NOT NULL,
  fecha date,
  base_cmm_pendiente numeric(14,4) DEFAULT 0 NOT NULL,
  cmm_pendiente numeric(14,4) DEFAULT 0 NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT cmm_pending_pkey PRIMARY KEY (id)
);

CREATE TABLE public.cmm_sellers (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  nombre text NOT NULL,
  raw_names text[] DEFAULT '{}'::text[] NOT NULL,
  office text DEFAULT 'Ecuador'::text NOT NULL,
  canal text DEFAULT 'Staff'::text NOT NULL,
  estado text DEFAULT 'Activo'::text NOT NULL,
  notas text,
  active boolean DEFAULT true NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT cmm_sellers_pkey PRIMARY KEY (id),
  CONSTRAINT cmm_sellers_canal_check CHECK ((canal = ANY (ARRAY['Staff'::text, 'Freelance'::text, 'Directos'::text]))),
  CONSTRAINT cmm_sellers_estado_check CHECK ((estado = ANY (ARRAY['Activo'::text, 'Onboarding'::text, 'Salio'::text]))),
  CONSTRAINT cmm_sellers_office_check CHECK ((office = ANY (ARRAY['Ecuador'::text, 'Peru'::text, 'Panama'::text, 'USA'::text])))
);

CREATE TABLE public.cmm_targets (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  seller_id uuid NOT NULL,
  office text DEFAULT 'Ecuador'::text NOT NULL,
  period_year integer NOT NULL,
  period_month integer NOT NULL,
  target_ganancia numeric(14,2) DEFAULT 0 NOT NULL,
  notes text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT cmm_targets_pkey PRIMARY KEY (id),
  CONSTRAINT cmm_targets_period_month_check CHECK (((period_month >= 1) AND (period_month <= 12)))
);

CREATE TABLE public.cmm_transactions (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  upload_id uuid NOT NULL,
  seller_id uuid NOT NULL,
  office text DEFAULT 'Ecuador'::text NOT NULL,
  period_year integer NOT NULL,
  period_month integer NOT NULL,
  fecha date,
  cliente text,
  transaccion_text text,
  cont text,
  cont_categoria text DEFAULT 'Otros'::text NOT NULL,
  ingresos numeric(14,4) DEFAULT 0 NOT NULL,
  otros_gastos numeric(14,4) DEFAULT 0 NOT NULL,
  ganancia numeric(14,4) DEFAULT 0 NOT NULL,
  costo1 numeric(14,4) DEFAULT 0 NOT NULL,
  base_cmm numeric(14,4) DEFAULT 0 NOT NULL,
  cmm_pagar numeric(14,4) DEFAULT 0 NOT NULL,
  formato text NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT cmm_transactions_pkey PRIMARY KEY (id),
  CONSTRAINT cmm_transactions_cont_categoria_check CHECK ((cont_categoria = ANY (ARRAY['LCL'::text, 'Aéreo'::text, 'FCL'::text, 'WR (Bodega)'::text, 'Otros'::text]))),
  CONSTRAINT cmm_transactions_formato_check CHECK ((formato = ANY (ARRAY['LIQUIDACION'::text, 'DIRECTOS'::text])))
);

CREATE TABLE public.cmm_uploads (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  uploaded_by uuid,
  uploaded_at timestamp with time zone DEFAULT now() NOT NULL,
  office text DEFAULT 'Ecuador'::text NOT NULL,
  period_year integer NOT NULL,
  period_month integer NOT NULL,
  files_count integer DEFAULT 0 NOT NULL,
  txn_count integer DEFAULT 0 NOT NULL,
  pending_count integer DEFAULT 0 NOT NULL,
  notes text,
  CONSTRAINT cmm_uploads_pkey PRIMARY KEY (id),
  CONSTRAINT cmm_uploads_office_check CHECK ((office = ANY (ARRAY['Ecuador'::text, 'Peru'::text, 'Panama'::text, 'USA'::text]))),
  CONSTRAINT cmm_uploads_period_month_check CHECK (((period_month >= 1) AND (period_month <= 12)))
);

CREATE TABLE public.commodities (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  code character varying NOT NULL,
  name character varying NOT NULL,
  description text,
  active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  hazmat boolean,
  requires_approval boolean,
  category character varying,
  hs_code text,
  is_fak boolean DEFAULT false NOT NULL,
  CONSTRAINT commodities_pkey PRIMARY KEY (id),
  CONSTRAINT commodities_code_key UNIQUE (code)
);

CREATE TABLE public.consignee_aliases (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  alias_normalized text NOT NULL,
  client_id uuid NOT NULL,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT consignee_aliases_pkey PRIMARY KEY (id),
  CONSTRAINT consignee_aliases_alias_normalized_client_id_key UNIQUE (alias_normalized, client_id)
);

CREATE TABLE public.consolidado_aereo_prefs (
  cliente_key text NOT NULL,
  es_aereo boolean DEFAULT true NOT NULL,
  updated_by uuid,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT consolidado_aereo_prefs_pkey PRIMARY KEY (cliente_key)
);

CREATE TABLE public.consolidado_agente_exclusiones (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  agente text NOT NULL,
  destino text NOT NULL,
  consolidado_id uuid,
  motivo text,
  creado_por uuid,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT consolidado_agente_exclusiones_pkey PRIMARY KEY (id)
);

CREATE TABLE public.consolidado_agente_overrides (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  consignatario text NOT NULL,
  agente text NOT NULL,
  creado_por uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT consolidado_agente_overrides_pkey PRIMARY KEY (id),
  CONSTRAINT consolidado_agente_overrides_consignatario_key UNIQUE (consignatario)
);

CREATE TABLE public.consolidado_agentes_destino (
  agente text NOT NULL,
  pais text NOT NULL,
  incluir boolean DEFAULT true NOT NULL,
  CONSTRAINT consolidado_agentes_destino_pkey PRIMARY KEY (agente)
);

CREATE TABLE public.consolidado_agrupacion_memoria (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  grupo_nombre text NOT NULL,
  miembro text NOT NULL,
  creado_por uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT consolidado_agrupacion_memoria_pkey PRIMARY KEY (id),
  CONSTRAINT consolidado_agrupacion_memoria_miembro_key UNIQUE (miembro)
);

CREATE TABLE public.consolidado_avisos (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  consolidado_id uuid NOT NULL,
  cliente_key text NOT NULL,
  es_agente boolean DEFAULT false NOT NULL,
  cs_email text,
  subject text,
  body_html text,
  recipients jsonb DEFAULT '{"cc": [], "to": []}'::jsonb NOT NULL,
  wr_numbers text[] DEFAULT '{}'::text[] NOT NULL,
  total_piezas integer,
  total_peso_lb numeric,
  total_cbm numeric,
  status text DEFAULT 'DRAFT'::text NOT NULL,
  sent_at timestamp with time zone,
  sent_by uuid,
  error text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  es_fcl boolean DEFAULT false NOT NULL,
  es_aereo boolean DEFAULT false NOT NULL,
  CONSTRAINT consolidado_avisos_pkey PRIMARY KEY (id),
  CONSTRAINT consolidado_avisos_consolidado_id_cliente_key_key UNIQUE (consolidado_id, cliente_key),
  CONSTRAINT consolidado_avisos_status_check CHECK ((status = ANY (ARRAY['DRAFT'::text, 'SENT'::text, 'SKIPPED'::text, 'ERROR'::text])))
);

CREATE TABLE public.consolidado_capacidades (
  tipo text NOT NULL,
  max_cbm numeric NOT NULL,
  objetivo_cbm numeric,
  CONSTRAINT consolidado_capacidades_pkey PRIMARY KEY (tipo)
);

CREATE TABLE public.consolidado_contenedores (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  consolidado_id uuid NOT NULL,
  tipo text NOT NULL,
  posicion integer DEFAULT 1 NOT NULL,
  numero text,
  sello text,
  notas text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT consolidado_contenedores_pkey PRIMARY KEY (id),
  CONSTRAINT consolidado_contenedores_tipo_check CHECK ((tipo = ANY (ARRAY['40HC'::text, '40NOR'::text, '20ST'::text])))
);

CREATE TABLE public.consolidado_email_bitacora (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  internet_message_id text NOT NULL,
  asunto text,
  remitente text,
  recibido_at timestamp with time zone,
  consolidado_id uuid,
  resultado text,
  procesado_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT consolidado_email_bitacora_pkey PRIMARY KEY (id),
  CONSTRAINT consolidado_email_bitacora_internet_message_id_key UNIQUE (internet_message_id)
);

CREATE TABLE public.consolidado_fcl_prefs (
  cliente_key text NOT NULL,
  es_fcl boolean DEFAULT true NOT NULL,
  updated_by uuid,
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT consolidado_fcl_prefs_pkey PRIMARY KEY (cliente_key)
);

CREATE TABLE public.consolidado_grupos (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  consolidado_id uuid NOT NULL,
  nombre text NOT NULL,
  notas text,
  creado_por uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT consolidado_grupos_pkey PRIMARY KEY (id)
);

CREATE TABLE public.consolidado_linea_hazmat (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  linea_id uuid NOT NULL,
  consolidado_id uuid NOT NULL,
  un_number text,
  imo_class text,
  created_at timestamp with time zone DEFAULT now(),
  doc_recibido boolean DEFAULT false NOT NULL,
  CONSTRAINT consolidado_linea_hazmat_pkey PRIMARY KEY (id)
);

CREATE TABLE public.consolidado_linea_movimientos (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  linea_id uuid NOT NULL,
  consolidado_id uuid NOT NULL,
  wr_number text,
  accion text NOT NULL,
  contenedor_id uuid,
  contenedor text,
  motivo text,
  hecho_por uuid,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT consolidado_linea_movimientos_pkey PRIMARY KEY (id),
  CONSTRAINT consolidado_linea_movimientos_accion_check CHECK ((accion = ANY (ARRAY['CARGA'::text, 'SACA'::text, 'CONFIRMA'::text, 'DESCONFIRMA'::text, 'NO_SE_CARGA'::text, 'SALIO'::text])))
);

CREATE TABLE public.consolidado_linea_piezas (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  linea_id uuid NOT NULL,
  consolidado_id uuid NOT NULL,
  wr_number text NOT NULL,
  wr_item_id uuid,
  whr_item_id text NOT NULL,
  piezas integer DEFAULT 1 NOT NULL,
  peso_lb numeric,
  vol_cft numeric,
  location_code text,
  package_name text,
  creado_por uuid,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT consolidado_linea_piezas_pkey PRIMARY KEY (id),
  CONSTRAINT consolidado_linea_piezas_piezas_check CHECK ((piezas > 0))
);

CREATE TABLE public.consolidado_lineas (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  consolidado_id uuid NOT NULL,
  wr_number text NOT NULL,
  consignee text,
  shipper text,
  client_id uuid,
  cs_email text,
  piezas integer,
  peso_lb numeric,
  volumen_cft numeric,
  estado text DEFAULT 'DISPONIBLE'::text NOT NULL,
  hazmat boolean DEFAULT false NOT NULL,
  factura_ok boolean DEFAULT false NOT NULL,
  tarifa_venta numeric,
  tarifa_moneda text DEFAULT 'USD'::text,
  instruido_at timestamp with time zone,
  instruido_por uuid,
  instruccion_nota text,
  contenedor text,
  sello text,
  hbl text,
  piezas_embarcadas integer,
  rodado_desde uuid,
  notas text,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  agente_destino text,
  origen_oficina text DEFAULT 'EC'::text NOT NULL,
  grupo_id uuid,
  contenedor_id uuid,
  un_number text,
  imo_class text,
  apilable boolean DEFAULT true NOT NULL,
  regimen text DEFAULT 'NORMAL'::text NOT NULL,
  doc_7512 text,
  doc_7512_at timestamp with time zone,
  nota_bodega text,
  regimen_fuente text DEFAULT 'AUTO'::text NOT NULL,
  regimen_numero text,
  regimen_fecha date,
  shipment_id uuid,
  cfs_dias_extra integer DEFAULT 0 NOT NULL,
  cfs_extra_motivo text,
  cfs_extra_por uuid,
  cfs_extra_at timestamp with time zone,
  piezas_recibo integer,
  es_parcial boolean DEFAULT false NOT NULL,
  cargado_confirmado_at timestamp with time zone,
  cargado_confirmado_por uuid,
  hazmat_fuente text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  por_llegar boolean DEFAULT false NOT NULL,
  llega_eta date,
  CONSTRAINT consolidado_lineas_pkey PRIMARY KEY (id),
  CONSTRAINT consolidado_lineas_cfs_extra_chk CHECK (((cfs_dias_extra >= 0) AND (cfs_dias_extra <= 180))),
  CONSTRAINT consolidado_lineas_estado_check CHECK ((estado = ANY (ARRAY['DISPONIBLE'::text, 'AVISADO'::text, 'INSTRUIDO'::text, 'NO_EMBARCA'::text, 'APROBADO'::text, 'EMBARCADO'::text, 'RODADO'::text, 'EXCLUIDO'::text, 'SALIO_BODEGA'::text]))),
  CONSTRAINT consolidado_lineas_hazmat_fuente_check CHECK ((hazmat_fuente = ANY (ARRAY['AUTO'::text, 'MANUAL'::text]))),
  CONSTRAINT consolidado_lineas_origen_oficina_check CHECK ((origen_oficina = ANY (ARRAY['EC'::text, 'MIAMI'::text]))),
  CONSTRAINT consolidado_lineas_regimen_check CHECK ((regimen = ANY (ARRAY['NORMAL'::text, 'BONDED'::text, 'CFS'::text]))),
  CONSTRAINT consolidado_lineas_regimen_fuente_chk CHECK ((regimen_fuente = ANY (ARRAY['AUTO'::text, 'MANUAL'::text])))
);

CREATE TABLE public.consolidado_servicios (
  codigo text NOT NULL,
  nombre text NOT NULL,
  origen text NOT NULL,
  destino text NOT NULL,
  modo text DEFAULT 'MARITIMO'::text NOT NULL,
  coordinadora_email text,
  oficina text,
  cadencia text DEFAULT 'SEMANAL'::text,
  fuente_lineas text DEFAULT 'CORREO'::text NOT NULL,
  metrica text DEFAULT 'M3'::text NOT NULL,
  timezone_origen text DEFAULT 'America/New_York'::text,
  patrones_asunto text[] DEFAULT '{}'::text[],
  activo boolean DEFAULT true NOT NULL,
  notas text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT consolidado_servicios_pkey PRIMARY KEY (codigo),
  CONSTRAINT consolidado_servicios_fuente_lineas_check CHECK ((fuente_lineas = ANY (ARRAY['MAGAYA_WR'::text, 'CORREO'::text, 'MANUAL'::text])))
);

CREATE TABLE public.consolidados (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  modo text DEFAULT 'MARITIMO'::text NOT NULL,
  anio integer NOT NULL,
  semana integer NOT NULL,
  booking text,
  transportista text,
  motonave text,
  viaje text,
  origen text DEFAULT 'MIAMI'::text NOT NULL,
  destino text DEFAULT 'GUAYAQUIL'::text NOT NULL,
  etd date,
  eta date,
  cutoff_regular timestamp with time zone,
  cutoff_hazmat timestamp with time zone,
  cutoff_instrucciones timestamp with time zone,
  estado text DEFAULT 'ABIERTO'::text NOT NULL,
  notas text,
  creado_por uuid,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  cerrado_at timestamp with time zone,
  servicio text,
  avisos_firma text,
  avisos_regen_pedido_at timestamp with time zone,
  CONSTRAINT consolidados_pkey PRIMARY KEY (id),
  CONSTRAINT consolidados_estado_check CHECK ((estado = ANY (ARRAY['ABIERTO'::text, 'CERRADO'::text, 'ZARPADO'::text, 'CANCELADO'::text]))),
  CONSTRAINT consolidados_modo_check CHECK ((modo = ANY (ARRAY['MARITIMO'::text, 'AEREO'::text])))
);

CREATE TABLE public.contacts (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  client_id uuid NOT NULL,
  full_name text NOT NULL,
  email text,
  position text,
  is_primary boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  phone2 text,
  phone3 text,
  birthday date,
  CONSTRAINT contacts_pkey PRIMARY KEY (id)
);

CREATE TABLE public.container_files (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  container_id uuid NOT NULL,
  filename text NOT NULL,
  file_path text NOT NULL,
  file_size bigint NOT NULL,
  file_type text,
  uploaded_by uuid,
  uploaded_at timestamp with time zone DEFAULT now(),
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT container_files_pkey PRIMARY KEY (id)
);

CREATE TABLE public.container_load_reports (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  loading_task_id uuid NOT NULL,
  manifest_source_id uuid NOT NULL,
  clr_number text NOT NULL,
  pdf_url text NOT NULL,
  pdf_size_bytes bigint,
  qr_code_url text,
  content_hash text NOT NULL,
  items_loaded integer NOT NULL,
  total_weight_kg numeric(10,3) NOT NULL,
  total_volume_m3 numeric(10,3),
  exceptions_count integer DEFAULT 0 NOT NULL,
  unplanned_count integer DEFAULT 0 NOT NULL,
  has_red_flag boolean DEFAULT false NOT NULL,
  red_flag_reason text,
  language text DEFAULT 'es'::text NOT NULL,
  magaya_attached boolean DEFAULT false NOT NULL,
  magaya_attached_at timestamp with time zone,
  magaya_attachment_id text,
  generated_at timestamp with time zone DEFAULT now() NOT NULL,
  generated_by uuid,
  CONSTRAINT container_load_reports_pkey PRIMARY KEY (id),
  CONSTRAINT container_load_reports_clr_number_key UNIQUE (clr_number),
  CONSTRAINT container_load_reports_loading_task_id_key UNIQUE (loading_task_id)
);

CREATE TABLE public.container_types (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  name text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  created_by uuid,
  CONSTRAINT container_types_pkey PRIMARY KEY (id),
  CONSTRAINT container_types_name_key UNIQUE (name)
);

CREATE TABLE public.contract_documents (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  contract_id uuid,
  file_name text NOT NULL,
  file_type text,
  file_size integer,
  file_url text,
  document_type text DEFAULT 'CONTRACT'::text,
  version integer DEFAULT 1,
  amendment_number text,
  uploaded_by uuid,
  notes text,
  processing_status text DEFAULT 'PENDING'::text,
  parsed_data jsonb,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT contract_documents_pkey PRIMARY KEY (id)
);

CREATE TABLE public.contract_update_lines (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  update_id uuid,
  line_number integer,
  action text,
  origin_port_code text,
  destination_port_code text,
  commodity_code text,
  commodity_name text,
  equipment_code text,
  service_type text,
  new_base_rate numeric,
  new_charges jsonb,
  new_total numeric,
  old_base_rate numeric,
  old_charges jsonb,
  old_total numeric,
  old_rate_id uuid,
  rate_change numeric,
  rate_change_pct numeric,
  matched boolean DEFAULT false,
  match_confidence text,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT contract_update_lines_pkey PRIMARY KEY (id),
  CONSTRAINT contract_update_lines_action_check CHECK ((action = ANY (ARRAY['add'::text, 'update'::text, 'remove'::text, 'unchanged'::text])))
);

CREATE TABLE public.contract_updates (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  contract_id uuid,
  uploaded_by uuid,
  file_name text NOT NULL,
  file_url text,
  file_type text,
  carrier_id uuid,
  status text DEFAULT 'pending'::text,
  parsed_data jsonb,
  diff_summary jsonb,
  rates_added integer DEFAULT 0,
  rates_updated integer DEFAULT 0,
  rates_deactivated integer DEFAULT 0,
  charges_added integer DEFAULT 0,
  error_log text,
  applied_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  new_contract_number text,
  new_effective_date date,
  new_expiry_date date,
  CONSTRAINT contract_updates_pkey PRIMARY KEY (id),
  CONSTRAINT contract_updates_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'parsing'::text, 'parsed'::text, 'previewing'::text, 'approved'::text, 'applied'::text, 'failed'::text, 'cancelled'::text])))
);

CREATE TABLE public.contracts (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  carrier_id uuid,
  agent_id uuid,
  contract_number character varying NOT NULL,
  effective_date date,
  expiry_date date,
  source_region character varying,
  managed_by character varying,
  notes text,
  active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  contract_name character varying,
  minimum_volume integer,
  minimum_volume_unit character varying,
  version integer DEFAULT 1,
  parent_contract_id uuid,
  amendment_number text,
  scope text DEFAULT 'global'::text NOT NULL,
  card_note text,
  CONSTRAINT contracts_pkey PRIMARY KEY (id),
  CONSTRAINT contracts_scope_check CHECK ((scope = ANY (ARRAY['global'::text, 'USA'::text, 'PER'::text, 'ECU'::text, 'PAN'::text])))
);

CREATE TABLE public.coordination_tasks (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  task_type text NOT NULL,
  reference_code text,
  reference_type text,
  description text,
  origin text,
  destination text,
  scheduled_date date,
  completed_date date,
  status text DEFAULT 'OPEN'::text NOT NULL,
  shipment_id uuid,
  client_id uuid,
  office text NOT NULL,
  sales_executive_id uuid,
  cs_assigned_to uuid,
  carrier_name text,
  driver_info text,
  notes text,
  archived_at timestamp with time zone,
  archived_by uuid,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid,
  updated_at timestamp with time zone DEFAULT now(),
  po_reference text,
  pickup_number text,
  order_number text,
  supplier_name text,
  origin_port text,
  destination_port text,
  extra_fields jsonb,
  CONSTRAINT coordination_tasks_pkey PRIMARY KEY (id),
  CONSTRAINT coordination_tasks_reference_type_check CHECK (((reference_type = ANY (ARRAY['FIRMS_CODE'::text, 'BOOKING'::text, 'BL'::text, 'PO'::text, 'OTHER'::text])) OR (reference_type IS NULL))),
  CONSTRAINT coordination_tasks_status_check CHECK ((status = ANY (ARRAY['OPEN'::text, 'IN_PROGRESS'::text, 'COMPLETED'::text, 'CANCELLED'::text]))),
  CONSTRAINT coordination_tasks_task_type_check CHECK ((task_type = ANY (ARRAY['PICKUP'::text, 'INLAND'::text, 'BONDED'::text, 'OTHER'::text])))
);

CREATE TABLE public.credit_documents (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  credit_request_id uuid NOT NULL,
  document_type text NOT NULL,
  file_name text NOT NULL,
  file_url text NOT NULL,
  file_size integer,
  uploaded_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT credit_documents_pkey PRIMARY KEY (id)
);

CREATE TABLE public.credit_notify_finance (
  office text NOT NULL,
  email text NOT NULL,
  name text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT credit_notify_finance_pkey PRIMARY KEY (office, email)
);

CREATE TABLE public.credit_notify_log (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  credit_request_id uuid,
  client_id uuid,
  sent_to text[] DEFAULT '{}'::text[] NOT NULL,
  cc text[] DEFAULT '{}'::text[] NOT NULL,
  subject text,
  status text NOT NULL,
  error text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT credit_notify_log_pkey PRIMARY KEY (id)
);

CREATE TABLE public.credit_requests (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  client_id uuid NOT NULL,
  requested_amount numeric NOT NULL,
  requested_days integer NOT NULL,
  currency text DEFAULT 'USD'::text,
  executive_notes text,
  status text DEFAULT 'pending'::text NOT NULL,
  approved_amount numeric,
  approved_days integer,
  admin_notes text,
  reviewed_by uuid,
  reviewed_at timestamp with time zone,
  requested_by uuid NOT NULL,
  office text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT credit_requests_pkey PRIMARY KEY (id)
);

CREATE TABLE public.cs_assignments (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  cs_user_id uuid NOT NULL,
  sales_executive_id uuid,
  is_primary boolean DEFAULT false,
  active boolean DEFAULT true,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  is_directos boolean DEFAULT false NOT NULL,
  full_cartera boolean DEFAULT false NOT NULL,
  CONSTRAINT cs_assignments_pkey PRIMARY KEY (id),
  CONSTRAINT cs_assignments_cs_user_id_sales_executive_id_key UNIQUE (cs_user_id, sales_executive_id),
  CONSTRAINT cs_assignments_exec_or_directos CHECK (((sales_executive_id IS NOT NULL) OR (is_directos = true)))
);

CREATE TABLE public.cs_cuentas_habilitadas (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  cs_user_id uuid NOT NULL,
  client_id uuid NOT NULL,
  active boolean DEFAULT true NOT NULL,
  notas text,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT cs_cuentas_habilitadas_pkey PRIMARY KEY (id),
  CONSTRAINT cs_cuentas_habilitadas_cs_user_id_client_id_key UNIQUE (cs_user_id, client_id)
);

CREATE TABLE public.cxc_send_log (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  pais text NOT NULL,
  remitente text NOT NULL,
  enviados integer DEFAULT 0 NOT NULL,
  fallidos integer DEFAULT 0 NOT NULL,
  fallidos_detalle jsonb,
  CONSTRAINT cxc_send_log_pkey PRIMARY KEY (id),
  CONSTRAINT cxc_send_log_pais_check CHECK ((pais = ANY (ARRAY['peru'::text, 'ecuador'::text])))
);

CREATE TABLE public.dashboard_agents (
  year integer,
  month integer,
  agent_name text,
  revenue numeric,
  cogs numeric,
  clients bigint,
  operations bigint
);

CREATE TABLE public.dashboard_clients (
  year integer,
  client_name text,
  agent_name text,
  country text,
  revenue numeric,
  cogs numeric,
  operations bigint
);

CREATE TABLE public.dashboard_countries (
  year integer,
  month integer,
  country text,
  revenue numeric,
  cogs numeric,
  operations bigint
);

CREATE TABLE public.dashboard_monthly_client (
  year integer,
  month integer,
  client_name text,
  business_line text,
  revenue numeric,
  cogs numeric,
  charges bigint
);

CREATE TABLE public.dashboard_pnl_flow (
  year integer,
  month integer,
  flow_type text,
  business_line text,
  revenue numeric,
  cogs numeric,
  gross_profit numeric,
  charge_count bigint
);

CREATE TABLE public.dashboard_pnl_monthly (
  year integer NOT NULL,
  month integer NOT NULL,
  business_line text NOT NULL,
  revenue numeric,
  direct_cogs numeric,
  fixed_warehouse_cogs numeric,
  gross_profit numeric,
  margin_pct numeric,
  CONSTRAINT dashboard_pnl_monthly_pkey PRIMARY KEY (year, month, business_line)
);

CREATE TABLE public.deal_quotes (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  deal_id uuid,
  quote_number text,
  amount numeric(12,2),
  valid_until date,
  services_quoted jsonb,
  file_url text,
  status text DEFAULT 'draft'::text,
  sent_at timestamp with time zone,
  notes text,
  CONSTRAINT deal_quotes_pkey PRIMARY KEY (id),
  CONSTRAINT deal_quotes_status_check CHECK ((status = ANY (ARRAY['draft'::text, 'sent'::text, 'accepted'::text, 'rejected'::text, 'expired'::text])))
);

CREATE TABLE public.deals (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  company_name text NOT NULL,
  contact_name text,
  contact_email text,
  contact_phone text,
  stage text DEFAULT 'new_lead'::text,
  priority text DEFAULT 'warm'::text,
  value numeric(12,2),
  trade_route text,
  origin_country text,
  destination_country text,
  service_type text,
  commodity text,
  volume_cbm numeric(10,2),
  weight_kg numeric(10,2),
  expected_ship_date date,
  expected_close_date date,
  assigned_to uuid,
  client_type text,
  lead_source text,
  probability integer DEFAULT 50,
  notes text,
  lost_reason text,
  won_date date,
  lost_date date,
  client_id uuid,
  office text,
  next_follow_up date,
  status_note text,
  CONSTRAINT deals_pkey PRIMARY KEY (id),
  CONSTRAINT deals_client_type_check CHECK ((client_type = ANY (ARRAY['direct_client'::text, 'freight_forwarder'::text, 'prospect'::text]))),
  CONSTRAINT deals_destination_country_check CHECK ((destination_country = ANY (ARRAY['Panama'::text, 'Ecuador'::text, 'Peru'::text, 'USA'::text]))),
  CONSTRAINT deals_lead_source_check CHECK ((lead_source = ANY (ARRAY['referral'::text, 'website'::text, 'cold_call'::text, 'trade_show'::text, 'linkedin'::text, 'other'::text]))),
  CONSTRAINT deals_priority_check CHECK ((priority = ANY (ARRAY['hot'::text, 'warm'::text, 'cold'::text]))),
  CONSTRAINT deals_probability_check CHECK (((probability >= 0) AND (probability <= 100))),
  CONSTRAINT deals_service_type_check CHECK ((service_type = ANY (ARRAY['lcl'::text, 'fcl'::text, 'air'::text, 'courier'::text]))),
  CONSTRAINT deals_stage_check CHECK ((stage = ANY (ARRAY['prospect'::text, 'qualification'::text, 'quote'::text, 'negotiation'::text, 'closing'::text]))),
  CONSTRAINT deals_trade_route_check CHECK ((trade_route = ANY (ARRAY['usa_latam'::text, 'china_latam'::text, 'europa_latam'::text, 'intra_latam'::text]))),
  CONSTRAINT valid_office CHECK (((office = ANY (ARRAY['USA'::text, 'Panama'::text, 'Ecuador'::text, 'Peru'::text])) OR (office IS NULL)))
);

CREATE TABLE public.dispatches (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  name text NOT NULL,
  week text,
  shipping_line text,
  booking text,
  owner_id uuid,
  container_type text,
  hazmat_bonded text,
  pickup_date timestamp with time zone,
  load_unload_datetime timestamp with time zone,
  carrier text,
  driver_name text,
  driver_phone text,
  truck_number text,
  status text,
  door text,
  loader text,
  lg_cr text,
  staging text,
  palos_2x4 integer DEFAULT 0,
  straps_amarillos integer DEFAULT 0,
  pallets_vacios integer DEFAULT 0,
  bolsas_aire integer DEFAULT 0,
  notes text,
  dispatch_notes text,
  office text NOT NULL,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  employee text,
  created_by_user_id uuid,
  CONSTRAINT dispatches_pkey PRIMARY KEY (id),
  CONSTRAINT dispatches_office_check CHECK ((office = ANY (ARRAY['USA'::text, 'Panama'::text, 'Ecuador'::text, 'Peru'::text])))
);

CREATE TABLE public.drayage_rates (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  origin_kind text DEFAULT 'zip3'::text NOT NULL,
  origin_value text NOT NULL,
  origin_state text,
  destination_por_id uuid NOT NULL,
  rate_20 numeric,
  rate_40 numeric,
  rate_40h numeric,
  min_charge numeric,
  liftgate numeric,
  residential numeric,
  currency text DEFAULT 'USD'::text NOT NULL,
  transit_days integer,
  source text DEFAULT 'MANUAL'::text NOT NULL,
  carrier_name text,
  effective_date date,
  expiry_date date,
  active boolean DEFAULT true NOT NULL,
  notes text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT drayage_rates_pkey PRIMARY KEY (id),
  CONSTRAINT drayage_rates_origin_kind_origin_value_destination_por_id_s_key UNIQUE (origin_kind, origin_value, destination_por_id, source, effective_date),
  CONSTRAINT drayage_rates_origin_kind_check CHECK ((origin_kind = ANY (ARRAY['zip'::text, 'zip3'::text, 'city'::text, 'state'::text, 'zone'::text])))
);

CREATE TABLE public.ec_fcl_local_charges (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  carrier_id uuid NOT NULL,
  concept text NOT NULL,
  label text NOT NULL,
  basis text NOT NULL,
  amount numeric DEFAULT 0 NOT NULL,
  currency text DEFAULT 'USD'::text NOT NULL,
  active boolean DEFAULT true NOT NULL,
  effective_from date DEFAULT CURRENT_DATE NOT NULL,
  notes text,
  updated_by uuid,
  updated_by_email text,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  variant text DEFAULT 'GENERAL'::text NOT NULL,
  origin text,
  CONSTRAINT ec_fcl_local_charges_pkey PRIMARY KEY (id),
  CONSTRAINT ec_fcl_local_charges_amount_check CHECK ((amount >= (0)::numeric)),
  CONSTRAINT ec_fcl_local_charges_basis_check CHECK ((basis = ANY (ARRAY['per_container'::text, 'per_bl'::text]))),
  CONSTRAINT ec_fcl_local_charges_concept_check CHECK ((concept = ANY (ARRAY['FEE_PP'::text, 'FEE_CC'::text, 'REEFER'::text, 'LOCAL_BL'::text, 'EMISION_BL'::text, 'THC'::text])))
);

CREATE TABLE public.ec_fcl_local_charges_history (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  charge_id uuid NOT NULL,
  carrier_id uuid NOT NULL,
  concept text NOT NULL,
  old_amount numeric,
  new_amount numeric NOT NULL,
  old_effective_from date,
  new_effective_from date,
  changed_by uuid,
  changed_by_email text,
  changed_at timestamp with time zone DEFAULT now() NOT NULL,
  variant text DEFAULT 'GENERAL'::text NOT NULL,
  origin text,
  CONSTRAINT ec_fcl_local_charges_history_pkey PRIMARY KEY (id)
);

CREATE TABLE public.email_templates (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  name text NOT NULL,
  subject text NOT NULL,
  html_content text NOT NULL,
  language text NOT NULL,
  recipient_type text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT email_templates_pkey PRIMARY KEY (id),
  CONSTRAINT email_templates_name_key UNIQUE (name),
  CONSTRAINT email_templates_language_check CHECK ((language = ANY (ARRAY['en'::text, 'es'::text]))),
  CONSTRAINT email_templates_recipient_type_check CHECK ((recipient_type = ANY (ARRAY['client'::text, 'team'::text])))
);

CREATE TABLE public.equipment_types (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  code character varying NOT NULL,
  name character varying NOT NULL,
  size_feet integer NOT NULL,
  type character varying,
  teu_factor numeric,
  is_reefer boolean DEFAULT false,
  requires_power boolean DEFAULT false,
  has_temperature_control boolean DEFAULT false,
  active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  recommended_for text[],
  notes text,
  internal_volume_cbm numeric,
  internal_height_cm integer,
  tare_weight_kg integer,
  max_payload_kg integer,
  temperature_range_min integer,
  temperature_range_max integer,
  CONSTRAINT equipment_types_pkey PRIMARY KEY (id),
  CONSTRAINT equipment_types_code_key UNIQUE (code)
);

CREATE TABLE public.external_containers (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  name text NOT NULL,
  week text,
  shipping_line text,
  owner_id uuid,
  booking text,
  container_number text,
  container_type text,
  port_of_loading text,
  destination text,
  destination_agent text,
  doc_cut_off timestamp with time zone,
  cargo_cut_off timestamp with time zone,
  etd timestamp with time zone,
  eta timestamp with time zone,
  actual_departure_date timestamp with time zone,
  actual_arrival_date timestamp with time zone,
  status text,
  notes text,
  delay_reason text,
  office text NOT NULL,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  employee text,
  created_by_user_id uuid,
  CONSTRAINT external_containers_pkey PRIMARY KEY (id),
  CONSTRAINT external_containers_office_check CHECK ((office = ANY (ARRAY['USA'::text, 'Panama'::text, 'Ecuador'::text, 'Peru'::text])))
);

CREATE TABLE public.fact_orders (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  shipment_id uuid NOT NULL,
  si_id uuid,
  client_id uuid,
  kind text NOT NULL,
  lines jsonb DEFAULT '[]'::jsonb NOT NULL,
  total numeric,
  currency text DEFAULT 'USD'::text NOT NULL,
  status text DEFAULT 'PENDIENTE'::text NOT NULL,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT fact_orders_pkey PRIMARY KEY (id)
);

CREATE TABLE public.fcl_semanal (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  office text DEFAULT 'USA'::text NOT NULL,
  semana integer NOT NULL,
  anio integer NOT NULL,
  cliente text NOT NULL,
  client_id uuid,
  naviera text,
  booking text,
  contenedor text,
  tipo text,
  sello text,
  origen_carga text DEFAULT 'BODEGA'::text NOT NULL,
  lugar_carga text,
  fecha_carga date,
  cutoff date,
  estado text DEFAULT 'PROGRAMADO'::text NOT NULL,
  destino text,
  shipment_id uuid,
  wr_numbers text[] DEFAULT '{}'::text[],
  notas text,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT fcl_semanal_pkey PRIMARY KEY (id),
  CONSTRAINT fcl_semanal_estado_check CHECK ((estado = ANY (ARRAY['PROGRAMADO'::text, 'CARGADO'::text, 'ZARPADO'::text, 'CANCELADO'::text]))),
  CONSTRAINT fcl_semanal_origen_carga_check CHECK ((origen_carga = ANY (ARRAY['BODEGA'::text, 'FUERA'::text])))
);

CREATE TABLE public.finanzas_access (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  user_id uuid NOT NULL,
  office_code text NOT NULL,
  can_grant boolean DEFAULT false NOT NULL,
  granted_by uuid,
  granted_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT finanzas_access_pkey PRIMARY KEY (id),
  CONSTRAINT finanzas_access_user_id_office_code_key UNIQUE (user_id, office_code),
  CONSTRAINT finanzas_access_office_code_check CHECK ((office_code = ANY (ARRAY['USA'::text, 'ECU'::text, 'PAN'::text, 'PER'::text, 'HOLDING'::text, 'ALL'::text])))
);

CREATE TABLE public.finanzas_bank_match (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  bank_transaction_id uuid NOT NULL,
  office_id text NOT NULL,
  match_type text NOT NULL,
  matched_docs jsonb,
  entity_name text,
  category text,
  confidence numeric(3,2) DEFAULT 0.5 NOT NULL,
  estado text DEFAULT 'sugerido'::text NOT NULL,
  decided_by text,
  decided_at timestamp with time zone,
  notes text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT finanzas_bank_match_pkey PRIMARY KEY (id),
  CONSTRAINT finanzas_bank_match_bank_transaction_id_key UNIQUE (bank_transaction_id),
  CONSTRAINT finanzas_bank_match_category_check CHECK (((category IS NULL) OR (category = ANY (ARRAY['client_payment'::text, 'vendor_payment'::text, 'payroll'::text, 'rent'::text, 'utility'::text, 'tax'::text, 'intercompany_in'::text, 'intercompany_out'::text, 'fx_swap'::text, 'loan_disbursement'::text, 'loan_payment'::text, 'capex'::text, 'dividend'::text, 'bank_fee'::text, 'interest'::text, 'refund'::text, 'other'::text, 'uncategorized'::text])))),
  CONSTRAINT finanzas_bank_match_estado_check CHECK ((estado = ANY (ARRAY['sugerido'::text, 'confirmado'::text, 'descartado'::text]))),
  CONSTRAINT finanzas_bank_match_match_type_check CHECK ((match_type = ANY (ARRAY['refs'::text, 'monto_pm'::text, 'traspaso'::text, 'categoria'::text, 'manual'::text])))
);

CREATE TABLE public.finanzas_config_recurrente (
  office_id text NOT NULL,
  monto_mes numeric(14,2) NOT NULL,
  detalle text,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT finanzas_config_recurrente_pkey PRIMARY KEY (office_id)
);

CREATE TABLE public.finanzas_deuda_externa (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  office_id text NOT NULL,
  concepto text NOT NULL,
  saldo_usd numeric(14,2) NOT NULL,
  corte date NOT NULL,
  fuente text DEFAULT 'manual'::text NOT NULL,
  notes text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT finanzas_deuda_externa_pkey PRIMARY KEY (id),
  CONSTRAINT finanzas_deuda_externa_office_id_concepto_corte_key UNIQUE (office_id, concepto, corte)
);

CREATE TABLE public.finanzas_eeff_pl (
  office_id text NOT NULL,
  periodo text NOT NULL,
  ventas numeric(14,2) NOT NULL,
  utilidad_bruta numeric(14,2),
  utilidad_neta numeric(14,2),
  fuente text DEFAULT 'EEFF'::text NOT NULL,
  notes text,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT finanzas_eeff_pl_pkey PRIMARY KEY (office_id, periodo)
);

CREATE TABLE public.finanzas_forecast_recurrente (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  office_id text NOT NULL,
  concepto text NOT NULL,
  monto_usd numeric(14,2) NOT NULL,
  frecuencia text NOT NULL,
  dia integer,
  ancla date,
  activo boolean DEFAULT true NOT NULL,
  fuente text,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT finanzas_forecast_recurrente_pkey PRIMARY KEY (id),
  CONSTRAINT finanzas_forecast_recurrente_frecuencia_check CHECK ((frecuencia = ANY (ARRAY['mensual'::text, 'quincenal'::text, 'bisemanal'::text])))
);

CREATE TABLE public.finanzas_fx_rate (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  tenant_id uuid NOT NULL,
  from_currency text NOT NULL,
  to_currency text NOT NULL,
  rate numeric(18,8) NOT NULL,
  rate_date date NOT NULL,
  source text DEFAULT 'manual'::text NOT NULL,
  is_official boolean DEFAULT false NOT NULL,
  notes text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT finanzas_fx_rate_pkey PRIMARY KEY (id),
  CONSTRAINT finanzas_fx_rate_dim_uq UNIQUE (tenant_id, from_currency, to_currency, rate_date, source)
);

CREATE TABLE public.finanzas_presupuesto (
  office_id text NOT NULL,
  anio integer NOT NULL,
  monto_anual numeric(14,2) NOT NULL,
  notes text,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  h1 numeric(14,2),
  mensual_2h numeric(14,2),
  CONSTRAINT finanzas_presupuesto_pkey PRIMARY KEY (office_id, anio)
);

CREATE TABLE public.finanzas_rc_por_zarpar (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  office_id text NOT NULL,
  numero text NOT NULL,
  entidad text,
  monto numeric(14,2),
  registrado_at date DEFAULT ((now() AT TIME ZONE 'America/New_York'::text))::date NOT NULL,
  zarpo_at date,
  fuente text NOT NULL,
  notes text,
  CONSTRAINT finanzas_rc_por_zarpar_pkey PRIMARY KEY (id),
  CONSTRAINT finanzas_rc_por_zarpar_office_id_numero_key UNIQUE (office_id, numero)
);

CREATE TABLE public.finanzas_sync_state (
  scope text NOT NULL,
  last_cursor timestamp with time zone NOT NULL,
  last_run_at timestamp with time zone,
  rows_last_run integer DEFAULT 0,
  CONSTRAINT finanzas_sync_state_pkey PRIMARY KEY (scope)
);

CREATE TABLE public.freight_carrier_aliases (
  alias text NOT NULL,
  scac text NOT NULL,
  nota text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT freight_carrier_aliases_pkey PRIMARY KEY (alias)
);

CREATE TABLE public.freight_port_aliases (
  alias text NOT NULL,
  port_code text NOT NULL,
  nota text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT freight_port_aliases_pkey PRIMARY KEY (alias)
);

CREATE TABLE public.freight_routes (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  origin_port_id uuid,
  destination_port_id uuid,
  transit_time_days integer,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  transshipment_port_id uuid,
  service_name character varying,
  service_frequency character varying,
  is_direct boolean,
  active boolean DEFAULT true,
  notes text,
  transit_source text DEFAULT 'MANUAL'::text,
  transit_verified_at timestamp with time zone,
  transit_verified_by uuid,
  CONSTRAINT freight_routes_pkey PRIMARY KEY (id)
);

CREATE TABLE public.fx_rates (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  source text DEFAULT 'BANCO_PACIFICO'::text NOT NULL,
  currency text NOT NULL,
  instrument text DEFAULT 'Transferencia'::text NOT NULL,
  rate_buy numeric,
  rate_sell numeric NOT NULL,
  quote_style text DEFAULT 'USD_PER_UNIT'::text NOT NULL,
  quoted_on date NOT NULL,
  fetched_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT fx_rates_pkey PRIMARY KEY (id),
  CONSTRAINT fx_rates_source_currency_instrument_quoted_on_key UNIQUE (source, currency, instrument, quoted_on),
  CONSTRAINT fx_rates_quote_style_check CHECK ((quote_style = ANY (ARRAY['USD_PER_UNIT'::text, 'UNITS_PER_USD'::text])))
);

CREATE TABLE public.gloval_assets (
  id text NOT NULL,
  content_type text DEFAULT 'image/jpeg'::text NOT NULL,
  b64 text NOT NULL,
  description text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT gloval_assets_pkey PRIMARY KEY (id)
);

CREATE TABLE public.impersonation_log (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  admin_user_id uuid NOT NULL,
  target_user_id uuid NOT NULL,
  started_at timestamp with time zone DEFAULT now() NOT NULL,
  ended_at timestamp with time zone,
  ip text,
  user_agent text,
  reason text,
  via_master_password boolean DEFAULT false NOT NULL,
  CONSTRAINT impersonation_log_pkey PRIMARY KEY (id),
  CONSTRAINT no_self_impersonation CHECK ((admin_user_id <> target_user_id))
);

CREATE TABLE public.inhouse_dashboards (
  client_id uuid NOT NULL,
  rows jsonb DEFAULT '[]'::jsonb NOT NULL,
  meta jsonb DEFAULT '{}'::jsonb NOT NULL,
  file_name text DEFAULT ''::text NOT NULL,
  uploaded_by uuid,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT inhouse_dashboards_pkey PRIMARY KEY (client_id)
);

CREATE TABLE public.inhouse_despachos (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  client_id uuid NOT NULL,
  referencia text NOT NULL,
  contenedor text DEFAULT ''::text NOT NULL,
  booking text DEFAULT ''::text NOT NULL,
  consignatario text DEFAULT ''::text NOT NULL,
  estado smallint DEFAULT 1 NOT NULL,
  data jsonb,
  shipment_id uuid,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT inhouse_despachos_pkey PRIMARY KEY (id),
  CONSTRAINT inhouse_despachos_estado_check CHECK (((estado >= 1) AND (estado <= 8)))
);

CREATE TABLE public.inhouse_documentos (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  despacho_id uuid NOT NULL,
  tipo text NOT NULL,
  nombre text NOT NULL,
  sha256 text NOT NULL,
  file_url text NOT NULL,
  file_size integer,
  nro_tributario text DEFAULT ''::text NOT NULL,
  hash_fuente text DEFAULT ''::text NOT NULL,
  subido_por uuid,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT inhouse_documentos_pkey PRIMARY KEY (id),
  CONSTRAINT inhouse_documentos_tipo_check CHECK ((tipo = ANY (ARRAY['fuente_packing'::text, 'fuente_factura'::text, 'lista_html'::text, 'lista_xlsx'::text, 'lista_snapshot'::text, 'lista_pdf'::text, 'factura_html'::text, 'factura_xlsx'::text, 'factura_snapshot'::text, 'factura_pdf'::text])))
);

CREATE TABLE public.inhouse_profiles (
  client_id uuid NOT NULL,
  direccion text DEFAULT ''::text NOT NULL,
  logo text DEFAULT ''::text NOT NULL,
  pais text DEFAULT 'Ecuador'::text NOT NULL,
  formato_tributario text DEFAULT 'RIDE SRI'::text NOT NULL,
  formato_nro text DEFAULT '^\d{3}-\d{3}-\d{9}$'::text NOT NULL,
  placeholder_nro text DEFAULT '001-001-000000000'::text NOT NULL,
  col_map jsonb DEFAULT '{"desc": "B", "neto": "H", "bruto": "I", "cajas": "E", "codigo": "A", "header": "Código", "unxcaja": "F"}'::jsonb NOT NULL,
  regla_orden text DEFAULT 'factura'::text NOT NULL,
  consignatarios jsonb DEFAULT '[]'::jsonb NOT NULL,
  firma text DEFAULT ''::text NOT NULL,
  activo boolean DEFAULT true NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT inhouse_profiles_pkey PRIMARY KEY (client_id)
);

CREATE TABLE public.inland_addons (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  carrier_id uuid,
  contract_number text,
  origin_city text NOT NULL,
  origin_state text,
  pol_city text NOT NULL,
  pol_port_id uuid,
  mode text,
  rate_20 numeric,
  rate_40 numeric,
  rate_40h numeric,
  currency text DEFAULT 'USD'::text,
  cargo_nature text,
  effective_date date,
  expiry_date date,
  active boolean DEFAULT true NOT NULL,
  source_id text,
  notes text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT inland_addons_pkey PRIMARY KEY (id)
);

CREATE TABLE public.inland_carrier_area_rates (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  carrier_id uuid NOT NULL,
  area text NOT NULL,
  min_charge numeric(10,2) NOT NULL,
  per_lb_rate numeric(8,4) NOT NULL,
  sort integer DEFAULT 0 NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT inland_carrier_area_rates_pkey PRIMARY KEY (id),
  CONSTRAINT inland_carrier_area_rates_carrier_id_area_key UNIQUE (carrier_id, area),
  CONSTRAINT inland_carrier_area_rates_area_check CHECK ((area = ANY (ARRAY['A'::text, 'B'::text, 'C'::text, 'D'::text, 'E'::text, 'F'::text, 'G'::text, 'H'::text])))
);

CREATE TABLE public.inland_carrier_rates (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  carrier_id uuid NOT NULL,
  ltl_base_charge numeric(10,2) DEFAULT 55 NOT NULL,
  ltl_base_pallets_included integer DEFAULT 3 NOT NULL,
  ltl_additional_pallet_price numeric(10,2) DEFAULT 18 NOT NULL,
  ltl_weight_threshold_lbs integer DEFAULT 2000 NOT NULL,
  ltl_overweight_rate_per_lb numeric(10,4) DEFAULT 0.0350 NOT NULL,
  free_time_hours numeric(4,2) DEFAULT 1 NOT NULL,
  additional_hour_price numeric(10,2) DEFAULT 40 NOT NULL,
  pickup_attempt_pct numeric(5,2) DEFAULT 0.70 NOT NULL,
  lift_gate_price numeric(10,2) DEFAULT 45 NOT NULL,
  pickup_docs_price numeric(10,2) DEFAULT 40 NOT NULL,
  haz_mat_price numeric(10,2) DEFAULT 35 NOT NULL,
  bonded_price numeric(10,2) DEFAULT 40 NOT NULL,
  truck_24ft_price numeric(10,2) DEFAULT 210 NOT NULL,
  truck_24ft_max_weight_lbs integer DEFAULT 10000 NOT NULL,
  truck_24ft_max_pallets integer DEFAULT 10 NOT NULL,
  truck_53ft_price numeric(10,2) DEFAULT 290 NOT NULL,
  truck_53ft_max_weight_lbs integer DEFAULT 44000 NOT NULL,
  truck_53ft_max_pallets integer DEFAULT 26 NOT NULL,
  effective_from date DEFAULT CURRENT_DATE NOT NULL,
  effective_to date,
  active boolean DEFAULT true NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  zone_b_surcharge numeric(10,2) DEFAULT 15 NOT NULL,
  zone_c_surcharge numeric(10,2) DEFAULT 80 NOT NULL,
  residential_pickup_price numeric(10,2) DEFAULT 60 NOT NULL,
  CONSTRAINT inland_carrier_rates_pkey PRIMARY KEY (id)
);

CREATE TABLE public.inland_carrier_zips (
  carrier_id uuid NOT NULL,
  zip_code text NOT NULL,
  zone text DEFAULT 'A'::text NOT NULL,
  CONSTRAINT inland_carrier_zips_pkey PRIMARY KEY (carrier_id, zip_code),
  CONSTRAINT inland_carrier_zips_zone_check CHECK ((zone = ANY (ARRAY['A'::text, 'B'::text, 'C'::text, 'D'::text, 'E'::text, 'F'::text, 'G'::text, 'H'::text])))
);

CREATE TABLE public.inland_carriers (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  name text NOT NULL,
  region text DEFAULT 'Miami'::text NOT NULL,
  active boolean DEFAULT true NOT NULL,
  notes text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT inland_carriers_pkey PRIMARY KEY (id)
);

CREATE TABLE public.inland_quotes (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  carrier_id uuid,
  pickup_zip text NOT NULL,
  pickup_address text,
  pallets integer NOT NULL,
  weight_lbs numeric(10,2) NOT NULL,
  wait_hours numeric(4,2) DEFAULT 1 NOT NULL,
  lift_gate boolean DEFAULT false NOT NULL,
  pickup_docs boolean DEFAULT false NOT NULL,
  haz_mat boolean DEFAULT false NOT NULL,
  bonded boolean DEFAULT false NOT NULL,
  recommended_mode text NOT NULL,
  recommended_total numeric(10,2) NOT NULL,
  ltl_total numeric(10,2),
  truck_24ft_total numeric(10,2),
  truck_53ft_total numeric(10,2),
  client_name text,
  notes text,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  delivery_zip text NOT NULL,
  delivery_address text,
  pickup_zone text,
  delivery_zone text,
  zone_surcharge numeric(10,2),
  client_email text,
  residential_pickup boolean DEFAULT false NOT NULL,
  CONSTRAINT inland_quotes_pkey PRIMARY KEY (id),
  CONSTRAINT inland_quotes_delivery_zone_check CHECK ((delivery_zone = ANY (ARRAY['A'::text, 'B'::text, 'C'::text, 'D'::text, 'E'::text, 'F'::text, 'G'::text, 'H'::text]))),
  CONSTRAINT inland_quotes_pallets_check CHECK ((pallets > 0)),
  CONSTRAINT inland_quotes_pickup_zone_check CHECK ((pickup_zone = ANY (ARRAY['A'::text, 'B'::text, 'C'::text, 'D'::text, 'E'::text, 'F'::text, 'G'::text, 'H'::text]))),
  CONSTRAINT inland_quotes_recommended_mode_check CHECK ((recommended_mode = ANY (ARRAY['LTL'::text, 'TRUCK_24FT'::text, 'TRUCK_53FT'::text]))),
  CONSTRAINT inland_quotes_weight_lbs_check CHECK ((weight_lbs > (0)::numeric))
);

CREATE TABLE public.job_applicants (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  access_token uuid DEFAULT gen_random_uuid() NOT NULL,
  office text DEFAULT 'USA'::text NOT NULL,
  full_name text NOT NULL,
  phone text NOT NULL,
  email text,
  preferred_channel text,
  link_sent boolean DEFAULT false NOT NULL,
  link_sent_at timestamp with time zone,
  link_channel_used text,
  link_error text,
  status text DEFAULT 'registered'::text NOT NULL,
  application_data jsonb,
  resume_url text,
  submitted_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT job_applicants_pkey PRIMARY KEY (id),
  CONSTRAINT job_applicants_preferred_channel_check CHECK ((preferred_channel = ANY (ARRAY['whatsapp'::text, 'sms'::text]))),
  CONSTRAINT job_applicants_status_check CHECK ((status = ANY (ARRAY['registered'::text, 'submitted'::text])))
);

CREATE TABLE public.lcl_admin_emails (
  email text NOT NULL,
  CONSTRAINT lcl_admin_emails_pkey PRIMARY KEY (email)
);

CREATE TABLE public.lcl_lanes (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  dest text NOT NULL,
  rate_per_cbm numeric DEFAULT 0 NOT NULL,
  min_charge numeric DEFAULT 0 NOT NULL,
  bunker_per_cbm numeric DEFAULT 0 NOT NULL,
  fuel_per_cbm numeric DEFAULT 0 NOT NULL,
  margin numeric DEFAULT 0 NOT NULL,
  transit text DEFAULT ''::text,
  sort_order integer DEFAULT 0 NOT NULL,
  active boolean DEFAULT true NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT lcl_lanes_pkey PRIMARY KEY (id),
  CONSTRAINT lcl_lanes_dest_key UNIQUE (dest)
);

CREATE TABLE public.lcl_settings (
  id integer DEFAULT 1 NOT NULL,
  margin_mode text DEFAULT 'pct'::text NOT NULL,
  currency text DEFAULT 'USD'::text NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT lcl_settings_pkey PRIMARY KEY (id),
  CONSTRAINT lcl_settings_margin_mode_check CHECK ((margin_mode = ANY (ARRAY['pct'::text, 'cbm'::text]))),
  CONSTRAINT lcl_settings_singleton CHECK ((id = 1))
);

CREATE TABLE public.lcl_surcharges (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  name text DEFAULT ''::text NOT NULL,
  mode text DEFAULT 'fijo'::text NOT NULL,
  value numeric DEFAULT 0 NOT NULL,
  enabled boolean DEFAULT true NOT NULL,
  sort_order integer DEFAULT 0 NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT lcl_surcharges_pkey PRIMARY KEY (id),
  CONSTRAINT lcl_surcharges_mode_check CHECK ((mode = ANY (ARRAY['fijo'::text, 'cbm'::text, 'pct'::text])))
);

CREATE TABLE public.liq_agent_invoice_lines (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  invoice_id uuid NOT NULL,
  charge_code text NOT NULL,
  custom_name text,
  amount numeric DEFAULT 0 NOT NULL,
  prorate_by text DEFAULT 'equal'::text NOT NULL,
  sort_order integer DEFAULT 100 NOT NULL,
  CONSTRAINT liq_agent_invoice_lines_pkey PRIMARY KEY (id),
  CONSTRAINT liq_agent_invoice_lines_prorate_by_check CHECK ((prorate_by = ANY (ARRAY['equal'::text, 'cbm'::text, 'lb'::text, 'wm'::text, 'container'::text])))
);

CREATE TABLE public.liq_agent_invoices (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  master_number text NOT NULL,
  week_of date,
  agent text,
  invoice_number text,
  invoice_date date,
  total numeric DEFAULT 0 NOT NULL,
  notes text,
  applied_at timestamp with time zone,
  created_by text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT liq_agent_invoices_pkey PRIMARY KEY (id)
);

CREATE TABLE public.liq_charge_catalog (
  code text NOT NULL,
  name text NOT NULL,
  section text NOT NULL,
  modes text[] DEFAULT '{air}'::text[] NOT NULL,
  default_basis text NOT NULL,
  taxable_iva boolean DEFAULT false NOT NULL,
  sort_order integer DEFAULT 100 NOT NULL,
  active boolean DEFAULT true NOT NULL,
  CONSTRAINT liq_charge_catalog_pkey PRIMARY KEY (code),
  CONSTRAINT liq_charge_catalog_default_basis_check CHECK ((default_basis = ANY (ARRAY['per_kg_chargeable'::text, 'per_lb'::text, 'fixed'::text, 'pct_invoice'::text, 'per_wm'::text, 'per_cbm'::text, 'per_container'::text, 'manual'::text]))),
  CONSTRAINT liq_charge_catalog_section_check CHECK ((section = ANY (ARRAY['freight'::text, 'local_ec'::text])))
);

CREATE TABLE public.liq_documents (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  shipment_id uuid NOT NULL,
  kind text NOT NULL,
  file_name text,
  storage_path text NOT NULL,
  uploaded_by text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT liq_documents_pkey PRIMARY KEY (id),
  CONSTRAINT liq_documents_kind_check CHECK ((kind = ANY (ARRAY['mawb'::text, 'hawb'::text, 'mbl'::text, 'hbl'::text, 'si'::text, 'manifest'::text, 'invoice'::text, 'other'::text])))
);

CREATE TABLE public.liq_settlement_lines (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  settlement_id uuid NOT NULL,
  charge_code text NOT NULL,
  section text NOT NULL,
  basis text NOT NULL,
  applies boolean DEFAULT true NOT NULL,
  cost_rate numeric DEFAULT 0,
  cost_amount numeric DEFAULT 0 NOT NULL,
  sale_rate numeric DEFAULT 0,
  sale_amount numeric DEFAULT 0 NOT NULL,
  currency text DEFAULT 'USD'::text NOT NULL,
  notes text,
  sort_order integer DEFAULT 100 NOT NULL,
  custom_name text,
  CONSTRAINT liq_settlement_lines_pkey PRIMARY KEY (id),
  CONSTRAINT liq_settlement_lines_section_check CHECK ((section = ANY (ARRAY['freight'::text, 'local_ec'::text])))
);

CREATE TABLE public.liq_settlements (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  shipment_id uuid NOT NULL,
  week_of date,
  status text DEFAULT 'draft'::text NOT NULL,
  freight_cost_total numeric DEFAULT 0 NOT NULL,
  freight_sale_total numeric DEFAULT 0 NOT NULL,
  local_cost_total numeric DEFAULT 0 NOT NULL,
  local_sale_total numeric DEFAULT 0 NOT NULL,
  freight_profit numeric GENERATED ALWAYS AS ((freight_sale_total - freight_cost_total)) STORED,
  local_profit numeric GENERATED ALWAYS AS ((local_sale_total - local_cost_total)) STORED,
  profit_total numeric GENERATED ALWAYS AS (((freight_sale_total - freight_cost_total) + (local_sale_total - local_cost_total))) STORED,
  commission_pct numeric DEFAULT 15 NOT NULL,
  commission_amount numeric GENERATED ALWAYS AS (((((freight_sale_total - freight_cost_total) + (local_sale_total - local_cost_total)) * commission_pct) / (100)::numeric)) STORED,
  profit_net numeric GENERATED ALWAYS AS ((((freight_sale_total - freight_cost_total) + (local_sale_total - local_cost_total)) * ((1)::numeric - (commission_pct / (100)::numeric)))) STORED,
  split_usa_pct numeric DEFAULT 0 NOT NULL,
  elaborated_by text,
  invoiced_by text,
  accepted_by_seller_at timestamp with time zone,
  notes text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  split_base text DEFAULT 'freight'::text NOT NULL,
  commission_borne text DEFAULT 'ec'::text NOT NULL,
  profit_usa numeric GENERATED ALWAYS AS (((
CASE
    WHEN (split_base = 'freight'::text) THEN (freight_sale_total - freight_cost_total)
    ELSE ((freight_sale_total - freight_cost_total) + (local_sale_total - local_cost_total))
END * (split_usa_pct / (100)::numeric)) *
CASE
    WHEN (commission_borne = 'shared'::text) THEN ((1)::numeric - (commission_pct / (100)::numeric))
    ELSE (1)::numeric
END)) STORED,
  profit_ec numeric GENERATED ALWAYS AS (((((freight_sale_total - freight_cost_total) + (local_sale_total - local_cost_total)) * ((1)::numeric - (commission_pct / (100)::numeric))) - ((
CASE
    WHEN (split_base = 'freight'::text) THEN (freight_sale_total - freight_cost_total)
    ELSE ((freight_sale_total - freight_cost_total) + (local_sale_total - local_cost_total))
END * (split_usa_pct / (100)::numeric)) *
CASE
    WHEN (commission_borne = 'shared'::text) THEN ((1)::numeric - (commission_pct / (100)::numeric))
    ELSE (1)::numeric
END))) STORED,
  invoice_usa_amount numeric GENERATED ALWAYS AS ((freight_cost_total + ((
CASE
    WHEN (split_base = 'freight'::text) THEN (freight_sale_total - freight_cost_total)
    ELSE ((freight_sale_total - freight_cost_total) + (local_sale_total - local_cost_total))
END * (split_usa_pct / (100)::numeric)) *
CASE
    WHEN (commission_borne = 'shared'::text) THEN ((1)::numeric - (commission_pct / (100)::numeric))
    ELSE (1)::numeric
END))) STORED,
  CONSTRAINT liq_settlements_pkey PRIMARY KEY (id),
  CONSTRAINT liq_settlements_shipment_id_key UNIQUE (shipment_id),
  CONSTRAINT liq_settlements_commission_borne_check CHECK ((commission_borne = ANY (ARRAY['ec'::text, 'shared'::text]))),
  CONSTRAINT liq_settlements_split_base_check CHECK ((split_base = ANY (ARRAY['freight'::text, 'total'::text]))),
  CONSTRAINT liq_settlements_status_check CHECK ((status = ANY (ARRAY['draft'::text, 'ready'::text, 'accepted'::text, 'invoiced'::text, 'closed'::text, 'void'::text])))
);

CREATE TABLE public.liq_shipments (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  source text DEFAULT 'manual'::text NOT NULL,
  magaya_guid text,
  mode text NOT NULL,
  direction text DEFAULT 'export'::text NOT NULL,
  master_number text,
  house_number text,
  gateway text,
  pol text,
  pod text,
  carrier text,
  provider text,
  etd date,
  eta date,
  week_of date,
  client_name text,
  client_ruc text,
  consignee_final text,
  asesor text,
  payment_terms text,
  chargeable_weight numeric,
  gross_kg numeric,
  gross_lb numeric,
  pieces integer,
  cbm numeric,
  containers jsonb,
  pu_number text,
  wr_number text,
  status text DEFAULT 'pending'::text NOT NULL,
  notes text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  gloval_usa_origin boolean DEFAULT false NOT NULL,
  origin_agent text,
  CONSTRAINT liq_shipments_pkey PRIMARY KEY (id),
  CONSTRAINT liq_shipments_magaya_guid_key UNIQUE (magaya_guid),
  CONSTRAINT liq_shipments_mode_check CHECK ((mode = ANY (ARRAY['air'::text, 'ocean_lcl'::text, 'ocean_fcl'::text, 'other'::text]))),
  CONSTRAINT liq_shipments_source_check CHECK ((source = ANY (ARRAY['magaya_usa'::text, 'manual'::text, 'excel_import'::text]))),
  CONSTRAINT liq_shipments_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'in_liquidation'::text, 'liquidated'::text, 'invoiced'::text, 'closed'::text, 'void'::text])))
);

CREATE TABLE public.liq_tariffs (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  charge_code text NOT NULL,
  mode text DEFAULT 'air'::text NOT NULL,
  gateway text,
  lane text,
  side text NOT NULL,
  basis text NOT NULL,
  rate numeric DEFAULT 0 NOT NULL,
  min_amount numeric,
  currency text DEFAULT 'USD'::text NOT NULL,
  valid_from date DEFAULT CURRENT_DATE NOT NULL,
  valid_to date,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT liq_tariffs_pkey PRIMARY KEY (id),
  CONSTRAINT liq_tariffs_basis_check CHECK ((basis = ANY (ARRAY['per_kg_chargeable'::text, 'per_lb'::text, 'fixed'::text, 'pct_invoice'::text, 'per_wm'::text, 'per_container'::text, 'manual'::text]))),
  CONSTRAINT liq_tariffs_side_check CHECK ((side = ANY (ARRAY['cost'::text, 'sale'::text])))
);

CREATE TABLE public.loading_exceptions (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  loading_task_id uuid NOT NULL,
  manifest_item_id uuid,
  exception_type loading_exception_type NOT NULL,
  reason text NOT NULL,
  photo_url text,
  authorized_by uuid,
  authorized_at timestamp with time zone,
  raised_by uuid NOT NULL,
  raised_at timestamp with time zone DEFAULT now(),
  CONSTRAINT loading_exceptions_pkey PRIMARY KEY (id),
  CONSTRAINT loading_exceptions_check CHECK (((exception_type <> 'damage'::loading_exception_type) OR (photo_url IS NOT NULL))),
  CONSTRAINT loading_exceptions_check1 CHECK (((exception_type <> 'skip'::loading_exception_type) OR (authorized_by IS NOT NULL)))
);

CREATE TABLE public.loading_materials (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  warehouse_id uuid,
  code text NOT NULL,
  name_es text NOT NULL,
  name_en text NOT NULL,
  category text NOT NULL,
  unit text DEFAULT 'unidad'::text NOT NULL,
  sort_order integer DEFAULT 100 NOT NULL,
  active boolean DEFAULT true NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT loading_materials_pkey PRIMARY KEY (id),
  CONSTRAINT loading_materials_code_scope_unique UNIQUE (warehouse_id, code),
  CONSTRAINT loading_materials_category_check CHECK ((category = ANY (ARRAY['strap'::text, 'airbag'::text, 'lumber'::text, 'plywood'::text, 'corner'::text, 'wrap'::text, 'equipment'::text, 'other'::text])))
);

CREATE TABLE public.loading_task_materials (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  loading_task_id uuid NOT NULL,
  material_id uuid NOT NULL,
  quantity numeric(10,2) NOT NULL,
  notes text,
  recorded_by uuid,
  recorded_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT loading_task_materials_pkey PRIMARY KEY (id),
  CONSTRAINT loading_task_materials_quantity_check CHECK ((quantity > (0)::numeric))
);

CREATE TABLE public.loading_tasks (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  manifest_source_id uuid NOT NULL,
  assigned_to uuid NOT NULL,
  container_number text NOT NULL,
  container_type text,
  status loading_task_status DEFAULT 'pending'::loading_task_status NOT NULL,
  preload_floor text,
  preload_walls text,
  preload_roof text,
  preload_doors text,
  preload_photo_url text,
  preload_completed_at timestamp with time zone,
  started_at timestamp with time zone,
  closed_at timestamp with time zone,
  loader_signature_at timestamp with time zone,
  loader_signed_by uuid,
  supervisor_signature_at timestamp with time zone,
  supervisor_signed_by uuid,
  reopened_at timestamp with time zone,
  reopened_by uuid,
  reopen_reason text,
  staging_was_overridden boolean DEFAULT false NOT NULL,
  override_reason text,
  override_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT loading_tasks_pkey PRIMARY KEY (id),
  CONSTRAINT loading_tasks_manifest_source_id_key UNIQUE (manifest_source_id)
);

CREATE TABLE public.login_history (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  user_id uuid,
  email text,
  login_at timestamp with time zone DEFAULT now(),
  ip_address text,
  user_agent text,
  device_type text,
  status text DEFAULT 'success'::text,
  office text,
  logout_at timestamp with time zone,
  session_duration_minutes integer,
  is_active boolean DEFAULT true,
  CONSTRAINT login_history_pkey PRIMARY KEY (id)
);

CREATE TABLE public.magaya_accounts (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  company_id uuid NOT NULL,
  account_number text,
  name text NOT NULL,
  account_type text NOT NULL,
  currency_code text DEFAULT 'USD'::text,
  parent_account_number text,
  parent_account_name text,
  magaya_guid text,
  is_active boolean DEFAULT true,
  raw_xml text,
  synced_at timestamp with time zone DEFAULT now(),
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT magaya_accounts_pkey PRIMARY KEY (id),
  CONSTRAINT magaya_accounts_company_id_account_number_currency_code_key UNIQUE (company_id, account_number, currency_code)
);

CREATE TABLE public.magaya_balance_override (
  office_id uuid NOT NULL,
  entity_name_clean text NOT NULL,
  source text NOT NULL,
  manual_balance numeric(15,2),
  reason text,
  set_by text DEFAULT 'system'::text,
  set_at timestamp with time zone DEFAULT now(),
  kind text,
  CONSTRAINT magaya_balance_override_pkey PRIMARY KEY (office_id, entity_name_clean)
);

CREATE TABLE public.magaya_bills (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  bill_number text NOT NULL,
  guid text,
  vendor_name text,
  vendor_guid text,
  status text,
  total_amount numeric DEFAULT 0,
  amount_paid numeric DEFAULT 0,
  issue_date date,
  due_date date,
  currency text DEFAULT 'USD'::text,
  created_by text,
  description text,
  payment_terms text,
  synced_at timestamp with time zone DEFAULT now(),
  company_id uuid NOT NULL,
  CONSTRAINT magaya_bills_pkey PRIMARY KEY (id),
  CONSTRAINT magaya_bills_company_number_key UNIQUE (company_id, bill_number)
);

CREATE TABLE public.magaya_cargo_releases (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  cr_number text NOT NULL,
  guid text,
  shipper text,
  consignee text,
  carrier text,
  tracking_number text,
  origin text,
  destination text,
  status text,
  pieces integer DEFAULT 0,
  weight numeric DEFAULT 0,
  created_by text,
  issued_by text,
  created_on date,
  synced_at timestamp with time zone DEFAULT now(),
  created_at timestamp with time zone DEFAULT now(),
  company_id uuid NOT NULL,
  CONSTRAINT magaya_cargo_releases_pkey PRIMARY KEY (id),
  CONSTRAINT magaya_cargo_releases_company_number_key UNIQUE (company_id, cr_number)
);

CREATE TABLE public.magaya_charge_definitions (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  company_id uuid NOT NULL,
  code text NOT NULL,
  description text NOT NULL,
  charge_type text,
  account_name text,
  account_type text,
  currency_code text DEFAULT 'USD'::text,
  default_amount numeric(18,2) DEFAULT 0,
  enforce_3rd_party_billing boolean DEFAULT false,
  raw_xml text,
  synced_at timestamp with time zone DEFAULT now(),
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT magaya_charge_definitions_pkey PRIMARY KEY (id),
  CONSTRAINT magaya_charge_definitions_company_id_code_key UNIQUE (company_id, code)
);

CREATE TABLE public.magaya_charges_extracted (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  tenant_id uuid DEFAULT 'a4e3e84c-7fca-4ce3-8889-1f31d8d1366f'::uuid NOT NULL,
  office_id uuid NOT NULL,
  txn_guid text NOT NULL,
  txn_number text,
  txn_type text NOT NULL,
  txn_billing_client text,
  txn_date date,
  charge_guid text,
  charge_amount numeric(14,2),
  charge_currency text,
  charge_code text,
  charge_description text,
  account_type text,
  account_name text,
  entity_name text,
  entity_type text,
  is_prepaid boolean,
  is_third_party boolean,
  charge_status text,
  extracted_at timestamp with time zone DEFAULT now(),
  CONSTRAINT magaya_charges_extracted_pkey PRIMARY KEY (id),
  CONSTRAINT magaya_charges_extracted_txn_guid_charge_guid_key UNIQUE (txn_guid, charge_guid)
);

CREATE TABLE public.magaya_clients (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  magaya_id text NOT NULL,
  name text DEFAULT ''::text,
  address text DEFAULT ''::text,
  city text DEFAULT ''::text,
  country text DEFAULT ''::text,
  email text DEFAULT ''::text,
  phone text DEFAULT ''::text,
  type text DEFAULT ''::text,
  synced_at timestamp with time zone DEFAULT now(),
  company_id uuid NOT NULL,
  CONSTRAINT magaya_clients_pkey PRIMARY KEY (id),
  CONSTRAINT magaya_clients_company_magaya_id_key UNIQUE (company_id, magaya_id)
);

CREATE TABLE public.magaya_companies (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  code text NOT NULL,
  name text NOT NULL,
  country text NOT NULL,
  magaya_server text,
  magaya_port integer DEFAULT 3691,
  magaya_api_user text,
  magaya_home_currency text DEFAULT 'USD'::text,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT magaya_companies_pkey PRIMARY KEY (id),
  CONSTRAINT magaya_companies_code_key UNIQUE (code)
);

CREATE TABLE public.magaya_cr_items (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  cr_id uuid,
  cr_number text NOT NULL,
  item_description text,
  item_code text,
  pieces integer,
  quantity numeric,
  weight numeric,
  synced_at timestamp with time zone DEFAULT now(),
  company_id uuid NOT NULL,
  CONSTRAINT magaya_cr_items_pkey PRIMARY KEY (id)
);

CREATE TABLE public.magaya_currencies (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  company_id uuid NOT NULL,
  currency_code text NOT NULL,
  name text NOT NULL,
  exchange_rate numeric(24,20),
  decimal_places integer DEFAULT 2,
  is_home_currency boolean DEFAULT false,
  synced_at timestamp with time zone DEFAULT now(),
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT magaya_currencies_pkey PRIMARY KEY (id),
  CONSTRAINT magaya_currencies_company_id_currency_code_key UNIQUE (company_id, currency_code)
);

CREATE TABLE public.magaya_entities (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  company_id uuid NOT NULL,
  magaya_guid text,
  entity_type text,
  name text NOT NULL,
  code text,
  tax_id text,
  email text,
  phone text,
  address_line1 text,
  address_line2 text,
  city text,
  state text,
  country text,
  zip_code text,
  is_active boolean DEFAULT true,
  raw_xml text,
  synced_at timestamp with time zone DEFAULT now(),
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  name_normalized text GENERATED ALWAYS AS (normalize_company_name(name)) STORED,
  CONSTRAINT magaya_entities_pkey PRIMARY KEY (id),
  CONSTRAINT magaya_entities_company_id_magaya_guid_key UNIQUE (company_id, magaya_guid)
);

CREATE TABLE public.magaya_entity_balance (
  tenant_id uuid NOT NULL,
  office_id uuid NOT NULL,
  entity_guid uuid NOT NULL,
  entity_name text NOT NULL,
  kind text NOT NULL,
  balance_usd numeric NOT NULL,
  source_bill_guid uuid,
  source_bill_number text,
  fetched_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT magaya_entity_balance_pkey PRIMARY KEY (tenant_id, office_id, entity_guid, kind)
);

CREATE TABLE public.magaya_event_definitions (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  company_id uuid NOT NULL,
  event_code text,
  description text,
  event_type text,
  raw_xml text,
  synced_at timestamp with time zone DEFAULT now(),
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT magaya_event_definitions_pkey PRIMARY KEY (id),
  CONSTRAINT magaya_event_definitions_company_id_event_code_key UNIQUE (company_id, event_code)
);

CREATE TABLE public.magaya_inventory (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  item_code text NOT NULL,
  description text DEFAULT ''::text,
  quantity numeric(15,4) DEFAULT 0,
  location text DEFAULT ''::text,
  warehouse text DEFAULT ''::text,
  synced_at timestamp with time zone DEFAULT now(),
  company_id uuid NOT NULL,
  CONSTRAINT magaya_inventory_pkey PRIMARY KEY (id),
  CONSTRAINT magaya_inventory_company_item_key UNIQUE (company_id, item_code)
);

CREATE TABLE public.magaya_invoices (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  invoice_number text NOT NULL,
  client_id text DEFAULT ''::text,
  amount numeric(15,2) DEFAULT 0,
  currency text DEFAULT 'USD'::text,
  status text DEFAULT ''::text,
  issue_date date,
  due_date date,
  synced_at timestamp with time zone DEFAULT now(),
  guid text,
  client_name text,
  client_guid text,
  created_by text,
  total_amount numeric,
  amount_paid numeric,
  payment_terms text,
  description text,
  company_id uuid NOT NULL,
  CONSTRAINT magaya_invoices_pkey PRIMARY KEY (id),
  CONSTRAINT magaya_invoices_company_guid_key UNIQUE (company_id, guid),
  CONSTRAINT magaya_invoices_company_number_key UNIQUE (company_id, invoice_number)
);

CREATE TABLE public.magaya_journal_entries (
  id text NOT NULL,
  number integer NOT NULL,
  created_on timestamp with time zone,
  created_by text,
  notes text,
  total_debit numeric(12,2),
  total_credit numeric(12,2),
  currency text DEFAULT 'USD'::text,
  has_attachments boolean DEFAULT false,
  synced_at timestamp with time zone DEFAULT now(),
  company_id uuid NOT NULL,
  CONSTRAINT magaya_journal_entries_pkey PRIMARY KEY (id),
  CONSTRAINT magaya_journal_entries_company_number_key UNIQUE (company_id, number)
);

CREATE TABLE public.magaya_journal_entry_lines (
  id text NOT NULL,
  journal_entry_id text NOT NULL,
  journal_entry_number integer NOT NULL,
  line_index integer NOT NULL,
  account_type text,
  account_name text,
  account_number text,
  debit_amount numeric(12,2) DEFAULT 0,
  credit_amount numeric(12,2) DEFAULT 0,
  description text,
  exchange_rate numeric(10,4) DEFAULT 1.0,
  currency text DEFAULT 'USD'::text,
  company_id uuid NOT NULL,
  CONSTRAINT magaya_journal_entry_lines_pkey PRIMARY KEY (id),
  CONSTRAINT magaya_journal_entry_lines_company_key UNIQUE (company_id, journal_entry_number, line_index)
);

CREATE TABLE public.magaya_payment_application (
  company_id uuid NOT NULL,
  payment_guid uuid NOT NULL,
  item_paid_guid uuid NOT NULL,
  amount_paid numeric NOT NULL,
  payment_date timestamp with time zone,
  CONSTRAINT magaya_payment_application_pkey PRIMARY KEY (company_id, payment_guid, item_paid_guid)
);

CREATE TABLE public.magaya_pickup_orders (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  pk_number text NOT NULL,
  guid text,
  vendor text,
  vendor_guid text,
  created_by text,
  total_amount numeric,
  currency text DEFAULT 'USD'::text,
  status text,
  created_on date,
  due_date date,
  description text,
  synced_at timestamp with time zone DEFAULT now(),
  created_at timestamp with time zone DEFAULT now(),
  shipper text,
  consignee text,
  pieces integer DEFAULT 0,
  weight numeric DEFAULT 0,
  company_id uuid NOT NULL,
  CONSTRAINT magaya_purchase_orders_pkey PRIMARY KEY (id),
  CONSTRAINT magaya_pickup_orders_company_number_key UNIQUE (company_id, pk_number)
);

CREATE TABLE public.magaya_shipments (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  shipment_number text NOT NULL,
  shipper text DEFAULT ''::text,
  consignee text DEFAULT ''::text,
  origin text DEFAULT ''::text,
  destination text DEFAULT ''::text,
  status text DEFAULT ''::text,
  etd date,
  eta date,
  created_at timestamp with time zone DEFAULT now(),
  synced_at timestamp with time zone DEFAULT now(),
  type text,
  guid text,
  created_by text,
  carrier text,
  mode_of_transport text,
  pieces integer DEFAULT 0,
  weight numeric DEFAULT 0,
  tracking_number text,
  issued_by text,
  total_revenue numeric(14,2) DEFAULT 0,
  total_charges integer DEFAULT 0,
  charges_synced_at timestamp with time zone,
  client_name text,
  client_guid text,
  billing_client_name text,
  description_of_goods text,
  container_numbers text,
  total_containers integer DEFAULT 0,
  service_type text,
  direction text,
  layout_type text,
  vessel_name text,
  voyage text,
  booking_number text,
  master_bill text,
  company_id uuid NOT NULL,
  CONSTRAINT magaya_shipments_pkey PRIMARY KEY (id),
  CONSTRAINT magaya_shipments_company_number_key UNIQUE (company_id, shipment_number)
);

CREATE TABLE public.magaya_status_overrides (
  txn_guid text NOT NULL,
  txn_number text NOT NULL,
  txn_type text NOT NULL,
  status_from_soap text NOT NULL,
  balance_from_soap numeric(15,2),
  checked_at timestamp with time zone DEFAULT now(),
  CONSTRAINT magaya_status_overrides_pkey PRIMARY KEY (txn_guid)
);

CREATE TABLE public.magaya_sync_log (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  company_id uuid NOT NULL,
  sync_type text NOT NULL,
  status text DEFAULT 'running'::text NOT NULL,
  records_synced integer DEFAULT 0,
  records_failed integer DEFAULT 0,
  last_transaction_date timestamp with time zone,
  last_transaction_number text,
  error_message text,
  started_at timestamp with time zone DEFAULT now(),
  completed_at timestamp with time zone,
  metadata jsonb,
  CONSTRAINT magaya_sync_log_pkey PRIMARY KEY (id)
);

CREATE TABLE public.magaya_sync_state (
  sync_type text NOT NULL,
  last_number integer DEFAULT 0 NOT NULL,
  last_synced_at timestamp with time zone DEFAULT now(),
  records_last_run integer DEFAULT 0,
  status text DEFAULT 'idle'::text,
  error_msg text,
  company_id uuid NOT NULL,
  CONSTRAINT magaya_sync_state_pkey PRIMARY KEY (company_id, sync_type)
);

CREATE TABLE public.magaya_transaction_charges (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  company_id uuid NOT NULL,
  transaction_id uuid NOT NULL,
  charge_code text,
  charge_description text,
  charge_type text,
  amount numeric(18,2),
  currency_code text DEFAULT 'USD'::text,
  exchange_rate numeric(24,20),
  amount_in_home_currency numeric(18,2),
  account_name text,
  account_number text,
  entity_name text,
  is_prepaid boolean DEFAULT false,
  raw_xml text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT magaya_transaction_charges_pkey PRIMARY KEY (id)
);

CREATE TABLE public.magaya_transactions (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  company_id uuid NOT NULL,
  magaya_guid text,
  transaction_type text NOT NULL,
  transaction_number text,
  reference_number text,
  status text,
  direction text,
  created_on timestamp with time zone,
  issued_date date,
  due_date date,
  currency_code text DEFAULT 'USD'::text,
  total_amount numeric(18,2),
  tax_amount numeric(18,2),
  mode_of_transport text,
  origin_port text,
  destination_port text,
  shipper_name text,
  consignee_name text,
  carrier_name text,
  master_bl text,
  house_bl text,
  booking_number text,
  total_pieces integer,
  total_weight numeric(18,6),
  weight_unit text DEFAULT 'lb'::text,
  total_volume numeric(18,6),
  volume_unit text DEFAULT 'ft3'::text,
  billing_client_name text,
  billing_client_guid text,
  account_number text,
  account_name text,
  version integer,
  created_by_name text,
  has_attachments boolean DEFAULT false,
  raw_xml text,
  synced_at timestamp with time zone DEFAULT now(),
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  amount_paid numeric(15,2) DEFAULT 0,
  is_credit boolean DEFAULT false,
  document_subtype text,
  total_amount_usd numeric,
  CONSTRAINT magaya_transactions_pkey PRIMARY KEY (id),
  CONSTRAINT magaya_transactions_company_id_magaya_guid_key UNIQUE (company_id, magaya_guid)
);

CREATE TABLE public.magaya_usa_shipments (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  guid text,
  number text,
  mode text,
  is_master boolean DEFAULT false,
  master_bill text,
  house_bill text,
  consignee text,
  shipper text,
  destination_agent text,
  carrier text,
  pieces integer,
  weight_kg numeric,
  volume_m3 numeric,
  origin text,
  destination text,
  etd date,
  eta date,
  status text,
  created_on date,
  liquidated boolean DEFAULT false,
  synced_at timestamp with time zone DEFAULT now() NOT NULL,
  service_type text,
  manual_master_id uuid,
  CONSTRAINT magaya_usa_shipments_pkey PRIMARY KEY (id),
  CONSTRAINT magaya_usa_shipments_guid_key UNIQUE (guid),
  CONSTRAINT magaya_usa_shipments_service_type_check CHECK (((service_type IS NULL) OR (service_type = ANY (ARRAY['AIR'::text, 'FCL'::text, 'LCL'::text]))))
);

CREATE TABLE public.magaya_vendor_payments (
  id text NOT NULL,
  number text NOT NULL,
  payment_type text,
  entity_name text,
  entity_guid text,
  amount numeric(15,2),
  payment_date date,
  created_on timestamp with time zone,
  check_number text,
  bank_account text,
  memo text,
  bills_paid jsonb,
  accounting_entries jsonb,
  synced_at timestamp with time zone DEFAULT now(),
  company_id uuid DEFAULT 'aba24859-159c-424b-8ef3-d122fba41b7c'::uuid NOT NULL,
  CONSTRAINT magaya_vendor_payments_pkey PRIMARY KEY (id)
);

CREATE TABLE public.magaya_warehouse_receipts (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  wr_number text NOT NULL,
  guid text,
  shipper text,
  consignee text,
  carrier text,
  tracking_number text,
  origin text,
  destination text,
  status text,
  pieces integer DEFAULT 0,
  weight numeric DEFAULT 0,
  created_by text,
  issued_by text,
  etd date,
  eta date,
  synced_at timestamp with time zone DEFAULT now(),
  created_at timestamp with time zone DEFAULT now(),
  created_on date,
  volume_cbm numeric,
  volume_cft numeric,
  destination_agent text,
  destination_port text,
  billing_client text,
  company_id uuid NOT NULL,
  consignee_normalized text GENERATED ALWAYS AS (normalize_company_name(consignee)) STORED,
  notes text,
  entry_date date,
  out_date date,
  warehouse_zone text,
  location_code text,
  has_attachments boolean,
  total_value numeric,
  chargeable_weight numeric,
  volume_weight numeric,
  weight_unit text,
  volume_unit text,
  length_unit text,
  measurement_units text,
  carrier_pro_number text,
  scac_number text,
  out_shipment_guid text,
  cargo_release_number text,
  custom_fields jsonb,
  last_full_fetch_at timestamp with time zone,
  cbm numeric GENERATED ALWAYS AS (round((volume_cft * 0.0283168), 4)) STORED,
  last_verify_attempt_at timestamp with time zone,
  bonded_entry text,
  bonded_entry_number text,
  bonded_entry_date date,
  bonded_checked_at timestamp with time zone,
  CONSTRAINT magaya_warehouse_receipts_pkey PRIMARY KEY (id),
  CONSTRAINT magaya_warehouse_receipts_company_number_key UNIQUE (company_id, wr_number)
);

CREATE TABLE public.magaya_wr_attachments (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  wr_id uuid NOT NULL,
  wr_number text NOT NULL,
  source text DEFAULT 'magaya'::text NOT NULL,
  magaya_doc_id text,
  filename text NOT NULL,
  content_type text,
  size_bytes integer,
  storage_path text NOT NULL,
  is_photo boolean DEFAULT false,
  description text,
  uploaded_by uuid,
  synced_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT magaya_wr_attachments_pkey PRIMARY KEY (id)
);

CREATE TABLE public.magaya_wr_items (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  wr_id uuid,
  wr_number text NOT NULL,
  item_description text,
  item_code text,
  pieces integer,
  quantity numeric,
  weight numeric,
  volume_cbm numeric,
  container_number text,
  synced_at timestamp with time zone DEFAULT now(),
  company_id uuid NOT NULL,
  description text,
  part_number text,
  internal_name text,
  length numeric,
  width numeric,
  height numeric,
  piece_volume numeric,
  piece_weight numeric,
  piece_quantity numeric,
  package_name text,
  is_pallet boolean,
  is_container boolean,
  item_type text,
  supplier text,
  notes text,
  warehouse_zone text,
  last_full_fetch_at timestamp with time zone,
  item_guid text,
  status text,
  cargo_release_guid text,
  whr_item_id text,
  location_code text,
  supplier_invoice_number text,
  supplier_po_number text,
  weight_unit text,
  volume_unit text,
  peso_lb numeric,
  vol_cft numeric,
  CONSTRAINT magaya_wr_items_pkey PRIMARY KEY (id)
);

CREATE TABLE public.manifest_items (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  manifest_source_id uuid NOT NULL,
  barcode text NOT NULL,
  item_type cl_item_type NOT NULL,
  description text,
  weight_kg numeric(10,3) NOT NULL,
  volume_m3 numeric(10,3),
  is_hazmat boolean DEFAULT false,
  hazmat_un text,
  is_heavy boolean DEFAULT false,
  is_fragile boolean DEFAULT false,
  pick_status pick_item_status DEFAULT 'in_rack'::pick_item_status NOT NULL,
  assigned_picking_task_id uuid,
  picked_at timestamp with time zone,
  picked_by uuid,
  staging_status staging_item_status DEFAULT 'pending'::staging_item_status NOT NULL,
  verified_at timestamp with time zone,
  verified_by uuid,
  load_status load_item_status DEFAULT 'pending'::load_item_status NOT NULL,
  loaded_at timestamp with time zone,
  loaded_by uuid,
  load_scan_order integer,
  load_photo_url text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  wr_number text,
  location text,
  dimensions text,
  is_bonded boolean DEFAULT false NOT NULL,
  is_fumigated boolean DEFAULT false NOT NULL,
  package_descriptor text,
  shipper_name text,
  consignee_name text,
  reference_photo_url text,
  destination_agent text,
  piece_index integer,
  wr_total_pieces integer,
  is_depalletized boolean DEFAULT false NOT NULL,
  depalletized_carton_count integer,
  depalletized_at timestamp with time zone,
  depalletized_by uuid,
  depalletized_supervisor_id uuid,
  loading_priority integer,
  CONSTRAINT manifest_items_pkey PRIMARY KEY (id),
  CONSTRAINT manifest_items_manifest_source_id_barcode_key UNIQUE (manifest_source_id, barcode),
  CONSTRAINT manifest_items_depalletized_count_chk CHECK ((((is_depalletized = false) AND (depalletized_carton_count IS NULL)) OR ((is_depalletized = true) AND (depalletized_carton_count IS NOT NULL) AND ((depalletized_carton_count >= 1) AND (depalletized_carton_count <= 10000))))),
  CONSTRAINT manifest_items_loading_priority_check CHECK (((loading_priority IS NULL) OR (loading_priority > 0)))
);

CREATE TABLE public.manifest_sources (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  source_type manifest_source_type NOT NULL,
  magaya_guid text,
  external_number text NOT NULL,
  container_number text,
  container_type text,
  customer_name text,
  destination text,
  eta date,
  warehouse_id uuid,
  workflow_status text DEFAULT 'picking_pending'::text NOT NULL,
  snapshot_taken_at timestamp with time zone,
  last_synced_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT manifest_sources_pkey PRIMARY KEY (id),
  CONSTRAINT manifest_sources_source_type_magaya_guid_key UNIQUE (source_type, magaya_guid)
);

CREATE TABLE public.market_indices_daily (
  fecha date NOT NULL,
  indice text NOT NULL,
  valor numeric,
  unidad text,
  variacion_pct numeric,
  nota text,
  fuente text,
  capturado_at timestamp with time zone DEFAULT now(),
  CONSTRAINT market_indices_daily_pkey PRIMARY KEY (fecha, indice)
);

CREATE TABLE public.mi_actor_alias (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  canonical_id uuid NOT NULL,
  alias_normalized text NOT NULL,
  alias_raw text NOT NULL,
  source_field text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT mi_actor_alias_pkey PRIMARY KEY (id),
  CONSTRAINT mi_actor_alias_canonical_id_alias_normalized_key UNIQUE (canonical_id, alias_normalized)
);

CREATE TABLE public.mi_canonical_actor (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  actor_type mi_actor_type_t NOT NULL,
  canonical_name text NOT NULL,
  is_gloval boolean DEFAULT false NOT NULL,
  gloval_office text,
  country text,
  is_direct_bucket boolean DEFAULT false NOT NULL,
  auto_created boolean DEFAULT false NOT NULL,
  metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT mi_canonical_actor_pkey PRIMARY KEY (id),
  CONSTRAINT mi_canonical_actor_actor_type_canonical_name_key UNIQUE (actor_type, canonical_name)
);

CREATE TABLE public.mi_courier_shipment (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  modality text NOT NULL,
  period_year integer NOT NULL,
  period_month integer NOT NULL,
  period_quarter integer GENERATED ALWAYS AS ((((period_month - 1) / 3) + 1)) STORED,
  operation_date date,
  shipment_date date,
  nombre_operacion text,
  codigo_dual text,
  doc_transporte_master text,
  doc_transporte_final text,
  doc_transporte_final_norm text GENERATED ALWAYS AS (NULLIF(regexp_replace(upper(COALESCE(doc_transporte_final, ''::text)), '[^A-Z0-9]'::text, ''::text, 'g'::text), ''::text)) STORED,
  manifiesto text,
  refrendo text,
  ec_company_id text,
  ec_company_id_norm text GENERATED ALWAYS AS (NULLIF(regexp_replace(COALESCE(ec_company_id, ''::text), '\D'::text, ''::text, 'g'::text), ''::text)) STORED,
  ec_company_id_type text,
  ec_company_name text,
  ec_company_name_norm text GENERATED ALWAYS AS (normalize_company_name(ec_company_name)) STORED,
  ec_provincia text,
  ec_canton text,
  ec_parroquia text,
  ec_ciiu text,
  ec_vertical text,
  foreign_company text,
  foreign_company_norm text GENERATED ALWAYS AS (normalize_company_name(foreign_company)) STORED,
  foreign_country text,
  port_ec text,
  port_ec_arrival_dep text,
  country_arrival_dep text,
  region_arrival_dep text,
  port_origin_destination text,
  locality_origin_destination text,
  country_origin_destination text,
  region_origin_destination text,
  kilos_brutos numeric(14,3),
  num_bultos numeric(12,2),
  tipo_bulto text,
  producto_pmc text,
  producto_generico text,
  tipo_producto text,
  descripcion_unidad text,
  carrier_raw text,
  agencia_naviera_raw text,
  partner_raw text,
  liberador_raw text,
  liberador_raw_norm text GENERATED ALWAYS AS (normalize_company_name(liberador_raw)) STORED,
  tipo_despacho text,
  forma_despacho text,
  responsable_despacho text,
  almacen text,
  termino_negociacion text,
  incoterm text,
  agente_aduana text,
  valor_comercial numeric(14,2),
  buque_placa text,
  viaje text,
  notificador text,
  ingested_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT mi_courier_shipment_pkey PRIMARY KEY (id),
  CONSTRAINT mi_courier_shipment_uniq UNIQUE (modality, doc_transporte_final_norm, period_year, period_month),
  CONSTRAINT mi_courier_shipment_modality_check CHECK ((modality = ANY (ARRAY['CI'::text, 'CE'::text]))),
  CONSTRAINT mi_courier_shipment_period_month_check CHECK (((period_month >= 1) AND (period_month <= 12)))
);

CREATE TABLE public.mi_etl_run (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  modality mi_modality_t NOT NULL,
  period_year integer NOT NULL,
  period_month_from integer,
  period_month_to integer,
  source_file_name text,
  source_file_hash text,
  rows_total integer DEFAULT 0 NOT NULL,
  rows_inserted integer DEFAULT 0 NOT NULL,
  rows_updated integer DEFAULT 0 NOT NULL,
  rows_failed integer DEFAULT 0 NOT NULL,
  status mi_etl_status_t DEFAULT 'RUNNING'::mi_etl_status_t NOT NULL,
  error_message text,
  triggered_by uuid,
  started_at timestamp with time zone DEFAULT now() NOT NULL,
  completed_at timestamp with time zone,
  CONSTRAINT mi_etl_run_pkey PRIMARY KEY (id),
  CONSTRAINT mi_etl_run_file_hash_key UNIQUE (source_file_hash)
);

CREATE TABLE public.mi_match_review_queue (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  ec_company_id text,
  ec_company_name text,
  ec_company_name_norm text,
  suggested_client_id uuid,
  match_method mi_match_method_t NOT NULL,
  match_confidence numeric(4,3) NOT NULL,
  occurrences integer DEFAULT 1 NOT NULL,
  total_teus_fcl numeric(12,3) DEFAULT 0 NOT NULL,
  total_kilos numeric(14,3) DEFAULT 0 NOT NULL,
  status mi_match_status_t DEFAULT 'PENDING'::mi_match_status_t NOT NULL,
  reviewed_by uuid,
  reviewed_at timestamp with time zone,
  notes text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT mi_match_review_queue_pkey PRIMARY KEY (id),
  CONSTRAINT mi_match_review_queue_ec_company_id_suggested_client_id_mat_key UNIQUE (ec_company_id, suggested_client_id, match_method)
);

CREATE TABLE public.mi_shipment_intel (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  modality mi_modality_t NOT NULL,
  period_year integer NOT NULL,
  period_month integer NOT NULL,
  period_quarter integer GENERATED ALWAYS AS ((((period_month - 1) / 3) + 1)) STORED,
  operation_date date,
  shipment_date date,
  nombre_operacion text,
  codigo_dual text,
  doc_transporte_master text,
  doc_transporte_final text,
  doc_transporte_final_norm text GENERATED ALWAYS AS (NULLIF(regexp_replace(upper(COALESCE(doc_transporte_final, ''::text)), '[^A-Z0-9]'::text, ''::text, 'g'::text), ''::text)) STORED,
  manifiesto text,
  refrendo text,
  ec_company_id text,
  ec_company_id_norm text GENERATED ALWAYS AS (NULLIF(regexp_replace(COALESCE(ec_company_id, ''::text), '\D'::text, ''::text, 'g'::text), ''::text)) STORED,
  ec_company_id_type text,
  ec_company_name text,
  ec_company_name_norm text GENERATED ALWAYS AS (normalize_company_name(ec_company_name)) STORED,
  ec_provincia text,
  ec_canton text,
  ec_parroquia text,
  ec_ciiu text,
  ec_vertical text,
  client_id uuid,
  match_method mi_match_method_t,
  match_confidence numeric(4,3),
  matched_at timestamp with time zone,
  foreign_company text,
  foreign_company_norm text GENERATED ALWAYS AS (normalize_company_name(foreign_company)) STORED,
  foreign_country text,
  port_ec text,
  port_ec_arrival_dep text,
  country_arrival_dep text,
  region_arrival_dep text,
  port_origin_destination text,
  locality_origin_destination text,
  country_origin_destination text,
  region_origin_destination text,
  cont_count numeric(10,2),
  cont_20 numeric(10,2),
  cont_40 numeric(10,2),
  teus_fcl numeric(12,3),
  teus_lcl numeric(12,3),
  kilos_brutos numeric(14,3),
  num_bultos numeric(12,2),
  tipo_bulto text,
  producto_pmc text,
  producto_generico text,
  tipo_producto text,
  descripcion_unidad text,
  incoterm text,
  termino_negociacion text,
  valor_comercial numeric(14,2),
  carrier_raw text,
  carrier_canonical_id uuid,
  forwarder_raw_receptor text,
  forwarder_raw_liberador text,
  forwarder_canonical_id uuid,
  forwarder_roles_split boolean DEFAULT false NOT NULL,
  is_direct_no_forwarder boolean DEFAULT false NOT NULL,
  partner_raw text,
  partner_canonical_id uuid,
  origin_partner_type mi_origin_partner_t DEFAULT 'UNKNOWN'::mi_origin_partner_t NOT NULL,
  origin_partner_office text,
  agente_aduana text,
  agencia_naviera_raw text,
  liberador_doc_transporte text,
  receptor_doc_transporte text,
  almacen text,
  tipo_despacho text,
  forma_despacho text,
  responsable_despacho text,
  etl_run_id uuid,
  raw_payload jsonb,
  ingested_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  match_attempted_at timestamp with time zone,
  CONSTRAINT mi_shipment_intel_pkey PRIMARY KEY (id),
  CONSTRAINT mi_shipment_intel_modality_doc_transporte_final_norm_period_key UNIQUE (modality, doc_transporte_final_norm, period_year, period_month),
  CONSTRAINT mi_shipment_intel_period_month_check CHECK (((period_month >= 1) AND (period_month <= 12)))
);

CREATE TABLE public.monday_containers (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  monday_item_id text,
  synced_at timestamp with time zone DEFAULT now(),
  week_group text,
  item_name text,
  booking text,
  shipping_line text,
  owner text,
  haz_bonded text,
  cut_off text,
  status text,
  container_type text,
  container_number text,
  door text,
  load_unload_datetime text,
  loader text,
  staging text,
  lg_cr text,
  palos_2x4 integer,
  straps_amarillos integer,
  pallets_vacios integer,
  bolsas_de_aire integer,
  board_name text,
  year integer DEFAULT 2026,
  in_warehouse boolean DEFAULT true,
  etd text,
  eta text,
  destination_agent text,
  port_of_loading text,
  destination text,
  CONSTRAINT monday_containers_pkey PRIMARY KEY (id)
);

CREATE TABLE public.nomina_live (
  office text NOT NULL,
  je_number text NOT NULL,
  fecha date,
  periodo text,
  clase text,
  concepto text,
  notas text,
  moneda text,
  total_local numeric,
  total_usd numeric,
  girado_usd numeric,
  n_bancos integer,
  bancos text,
  es_pago boolean,
  fx numeric,
  computed_at timestamp with time zone DEFAULT now(),
  fuente text DEFAULT 'magaya'::text,
  CONSTRAINT nomina_live_pkey PRIMARY KEY (office, je_number)
);

CREATE TABLE public.offices (
  id text NOT NULL,
  name text NOT NULL,
  city text,
  country text,
  email text,
  active boolean DEFAULT false,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  code text,
  legal_name text,
  display_name text,
  cash_floor_usd numeric(14,2) DEFAULT 0,
  base_currency text DEFAULT 'USD'::text,
  is_holding boolean DEFAULT false,
  timezone text,
  country_code text,
  tenant_id uuid,
  CONSTRAINT offices_pkey PRIMARY KEY (id)
);

CREATE TABLE public.ops_capture_mailboxes (
  email text NOT NULL,
  activo boolean DEFAULT true NOT NULL,
  nota text,
  oficina text,
  captura_sin_adjunto boolean DEFAULT false NOT NULL,
  CONSTRAINT ops_capture_mailboxes_pkey PRIMARY KEY (email)
);

CREATE TABLE public.ops_client_notices (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  shipment_id uuid NOT NULL,
  notice_type text NOT NULL,
  sent_to text NOT NULL,
  sent_at timestamp with time zone DEFAULT now() NOT NULL,
  eta_at_send date,
  payload jsonb DEFAULT '{}'::jsonb NOT NULL,
  CONSTRAINT ops_client_notices_pkey PRIMARY KEY (id)
);

CREATE TABLE public.ops_devolucion_vacios (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  office text NOT NULL,
  shipment_id uuid,
  shipment_container_id uuid,
  container_number text NOT NULL,
  size_type text,
  naviera text,
  fecha_descarga date,
  fecha_retiro date,
  dias_libres integer DEFAULT 15 NOT NULL,
  fecha_limite date GENERATED ALWAYS AS ((COALESCE(fecha_retiro, fecha_descarga) + dias_libres)) STORED,
  fecha_devolucion date,
  deposito text,
  eir text,
  notas text,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT ops_devolucion_vacios_pkey PRIMARY KEY (id)
);

CREATE TABLE public.ops_documents (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  shipment_id uuid NOT NULL,
  file_name text NOT NULL,
  file_type text,
  file_size integer,
  file_url text NOT NULL,
  document_type ops_doc_type_t DEFAULT 'OTRO'::ops_doc_type_t NOT NULL,
  version integer DEFAULT 1 NOT NULL,
  source text DEFAULT 'MANUAL'::text NOT NULL,
  processing_status ops_doc_status_t DEFAULT 'PENDING'::ops_doc_status_t NOT NULL,
  extracted_json jsonb,
  error_detail text,
  applied_at timestamp with time zone,
  applied_by uuid,
  uploaded_by uuid,
  notes text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT ops_documents_pkey PRIMARY KEY (id)
);

CREATE TABLE public.ops_hbl (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  shipment_id uuid NOT NULL,
  hbl_number text,
  status text DEFAULT 'DRAFT'::text NOT NULL,
  data jsonb DEFAULT '{}'::jsonb NOT NULL,
  port_code text,
  issued_at timestamp with time zone,
  issued_by uuid,
  created_by uuid,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  originals_printed integer DEFAULT 0 NOT NULL,
  master_id uuid,
  non_negotiables_printed integer DEFAULT 0 NOT NULL,
  CONSTRAINT ops_hbl_pkey PRIMARY KEY (id),
  CONSTRAINT ops_hbl_hbl_number_key UNIQUE (hbl_number),
  CONSTRAINT ops_hbl_non_negotiables_printed_check CHECK (((non_negotiables_printed >= 0) AND (non_negotiables_printed <= 4))),
  CONSTRAINT ops_hbl_originals_printed_check CHECK (((originals_printed >= 0) AND (originals_printed <= 3)))
);

CREATE TABLE public.ops_hbl_sequence (
  office_code text NOT NULL,
  year integer NOT NULL,
  last_number integer DEFAULT 0 NOT NULL,
  CONSTRAINT ops_hbl_sequence_pkey PRIMARY KEY (office_code, year)
);

CREATE TABLE public.ops_inbound_emails (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  mailbox text NOT NULL,
  message_id text NOT NULL,
  graph_id text,
  conversation_id text,
  subject text,
  sender text,
  received_at timestamp with time zone,
  has_attachments boolean DEFAULT false NOT NULL,
  refs jsonb,
  shipment_id uuid,
  match_by text,
  docs_creados integer DEFAULT 0 NOT NULL,
  status text DEFAULT 'PENDIENTE'::text NOT NULL,
  error text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  body_preview text,
  si_estado text,
  si_resuelta_por uuid,
  si_resuelta_at timestamp with time zone,
  CONSTRAINT ops_inbound_emails_pkey PRIMARY KEY (id),
  CONSTRAINT ops_inbound_emails_si_estado_check CHECK (((si_estado IS NULL) OR (si_estado = ANY (ARRAY['PENDIENTE'::text, 'CONVERTIDA'::text, 'DESCARTADA'::text])))),
  CONSTRAINT ops_inbound_emails_status_check CHECK ((status = ANY (ARRAY['PENDIENTE'::text, 'VINCULADO'::text, 'SIN_MATCH'::text, 'IGNORADO'::text, 'ERROR'::text, 'SI_CANDIDATA'::text])))
);

CREATE TABLE public.ops_master (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  mbl text,
  data jsonb DEFAULT '{}'::jsonb NOT NULL,
  created_by uuid,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT ops_master_pkey PRIMARY KEY (id)
);

CREATE TABLE public.ops_release (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  shipment_id uuid NOT NULL,
  credit_ok boolean DEFAULT false NOT NULL,
  credit_checked_at timestamp with time zone,
  credit_note text,
  local_charges_paid boolean DEFAULT false NOT NULL,
  local_charges_paid_at timestamp with time zone,
  bl_liberado boolean DEFAULT false NOT NULL,
  bl_liberado_at timestamp with time zone,
  salida_autorizada boolean DEFAULT false NOT NULL,
  salida_autorizada_at timestamp with time zone,
  cas_issued boolean DEFAULT false NOT NULL,
  cas_issued_at timestamp with time zone,
  cas_document_id uuid,
  authorized_by uuid,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT ops_release_pkey PRIMARY KEY (id),
  CONSTRAINT ops_release_shipment_id_key UNIQUE (shipment_id)
);

CREATE TABLE public.ops_transfers (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  shipment_id uuid NOT NULL,
  transferred_by uuid NOT NULL,
  transferred_at timestamp with time zone DEFAULT now() NOT NULL,
  received_by uuid,
  ops_status ops_status_t DEFAULT 'RECIBIDO'::ops_status_t NOT NULL,
  next_milestone_due date,
  notes text,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  handoff_estado text DEFAULT 'PENDIENTE'::text NOT NULL,
  received_at timestamp with time zone,
  returned_by uuid,
  returned_at timestamp with time zone,
  return_reason text,
  CONSTRAINT ops_transfers_pkey PRIMARY KEY (id),
  CONSTRAINT ops_transfers_shipment_id_key UNIQUE (shipment_id),
  CONSTRAINT ops_transfers_handoff_estado_check CHECK ((handoff_estado = ANY (ARRAY['PENDIENTE'::text, 'ACEPTADO'::text, 'DEVUELTO'::text])))
);

CREATE TABLE public.pagos_recurrentes_live (
  office text NOT NULL,
  concepto text NOT NULL,
  periodo text NOT NULL,
  fecha_pago date,
  monto numeric,
  n_giros integer,
  detalle text,
  metodo text,
  computed_at timestamp with time zone DEFAULT now(),
  CONSTRAINT pagos_recurrentes_live_pkey PRIMARY KEY (office, concepto, periodo)
);

CREATE TABLE public.payment_commitment (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  tenant_id uuid NOT NULL,
  office_id uuid NOT NULL,
  external_guid text NOT NULL,
  invoice_number text,
  client_name text NOT NULL,
  amount_usd numeric(14,2) NOT NULL,
  due_date date,
  committed_date date NOT NULL,
  source text DEFAULT 'client_confirmed'::text NOT NULL,
  contact_method text,
  notes text,
  status text DEFAULT 'confirmed'::text NOT NULL,
  confirmed_by uuid,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  resolved_at timestamp with time zone,
  resolved_reason text,
  CONSTRAINT payment_commitment_pkey PRIMARY KEY (id)
);

CREATE TABLE public.pba_authorized_users (
  email text NOT NULL,
  note text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT pba_authorized_users_pkey PRIMARY KEY (email)
);

CREATE TABLE public.pba_payments (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  shipment_id uuid,
  client_id uuid,
  amount numeric(12,2) NOT NULL,
  currency text DEFAULT 'USD'::text,
  bl_ref text,
  guia_ref text,
  status pba_status_t DEFAULT 'PENDING'::pba_status_t NOT NULL,
  due_date date,
  paid_at timestamp with time zone,
  reminder_count integer DEFAULT 0,
  last_reminder_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT pba_payments_pkey PRIMARY KEY (id)
);

CREATE TABLE public.phone_numbers (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  contact_id uuid NOT NULL,
  phone_number text NOT NULL,
  phone_type text DEFAULT 'mobile'::text NOT NULL,
  is_primary boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT phone_numbers_pkey PRIMARY KEY (id),
  CONSTRAINT phone_numbers_phone_type_check CHECK ((phone_type = ANY (ARRAY['mobile'::text, 'office'::text, 'home'::text, 'fax'::text])))
);

CREATE TABLE public.picking_exceptions (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  picking_task_id uuid NOT NULL,
  manifest_item_id uuid,
  exception_type picking_exception_type NOT NULL,
  reason text NOT NULL,
  photo_url text,
  raised_by uuid NOT NULL,
  raised_at timestamp with time zone DEFAULT now(),
  resolved boolean DEFAULT false NOT NULL,
  resolution text,
  resolved_by uuid,
  resolved_at timestamp with time zone,
  CONSTRAINT picking_exceptions_pkey PRIMARY KEY (id),
  CONSTRAINT picking_exceptions_check CHECK (((exception_type <> 'damage'::picking_exception_type) OR (photo_url IS NOT NULL)))
);

CREATE TABLE public.picking_tasks (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  manifest_source_id uuid NOT NULL,
  task_type picking_task_type NOT NULL,
  equipment_required equipment_type DEFAULT 'NONE'::equipment_type NOT NULL,
  assigned_to uuid,
  parent_split_id uuid,
  status cl_task_status DEFAULT 'pending'::cl_task_status NOT NULL,
  started_at timestamp with time zone,
  closed_at timestamp with time zone,
  pick_count integer DEFAULT 0 NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT picking_tasks_pkey PRIMARY KEY (id),
  CONSTRAINT picking_tasks_check CHECK ((((task_type = 'PALLETS'::picking_task_type) AND (equipment_required = 'FORKLIFT'::equipment_type)) OR ((task_type = 'BOXES'::picking_task_type) AND (equipment_required = 'MANUAL'::equipment_type)) OR (task_type = 'MIXED'::picking_task_type)))
);

CREATE TABLE public.points_of_receipt (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  name text NOT NULL,
  city text NOT NULL,
  state text,
  country_code text DEFAULT 'US'::text NOT NULL,
  receipt_type text NOT NULL,
  description text,
  transit_days_delta integer,
  ramp_surcharge_applies boolean DEFAULT false NOT NULL,
  efs_default numeric,
  ihe_default numeric,
  port_id uuid,
  catalog_code text,
  latitude numeric,
  longitude numeric,
  source text DEFAULT 'MAERSK_AFLS'::text NOT NULL,
  notes text,
  active boolean DEFAULT true NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT points_of_receipt_pkey PRIMARY KEY (id),
  CONSTRAINT points_of_receipt_source_name_key UNIQUE (source, name),
  CONSTRAINT points_of_receipt_receipt_type_check CHECK ((receipt_type = ANY (ARRAY['port'::text, 'ramp'::text])))
);

CREATE TABLE public.ports (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  name character varying NOT NULL,
  code character varying NOT NULL,
  city character varying,
  country_code character varying(2),
  country_name character varying,
  region character varying,
  active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  latitude numeric,
  longitude numeric,
  port_type text DEFAULT 'port'::text,
  CONSTRAINT ports_pkey PRIMARY KEY (id),
  CONSTRAINT ports_code_key UNIQUE (code)
);

CREATE TABLE public.ports_master (
  id bigint DEFAULT nextval('ports_master_id_seq'::regclass) NOT NULL,
  code text NOT NULL,
  name text NOT NULL,
  city text,
  country text,
  type text,
  source text,
  search_text text,
  CONSTRAINT ports_master_pkey PRIMARY KEY (id),
  CONSTRAINT ports_master_type_check CHECK ((type = ANY (ARRAY['airport'::text, 'port'::text])))
);

CREATE TABLE public.pricing_rules (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  name text NOT NULL,
  description text,
  priority integer DEFAULT 100 NOT NULL,
  is_active boolean DEFAULT true NOT NULL,
  client_id uuid,
  client_tier text,
  office_id text,
  sales_rep_id uuid,
  mode text,
  carrier_id uuid,
  agent_id uuid,
  origin_filter jsonb,
  destination_filter jsonb,
  trade_lane text,
  equipment_type_id uuid,
  commodity_id uuid,
  weight_min numeric,
  weight_max numeric,
  markup_type text NOT NULL,
  markup_value numeric,
  markup_floor numeric,
  markup_ceiling numeric,
  tiered_brackets jsonb,
  effective_date date,
  expiry_date date,
  created_by uuid,
  approved_by uuid,
  approved_at timestamp with time zone,
  notes text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT pricing_rules_pkey PRIMARY KEY (id),
  CONSTRAINT pricing_rules_markup_type_check CHECK ((markup_type = ANY (ARRAY['percent'::text, 'flat'::text, 'tiered'::text, 'min_margin'::text, 'cost_plus'::text]))),
  CONSTRAINT pricing_rules_mode_check CHECK (((mode IS NULL) OR (mode = ANY (ARRAY['fcl'::text, 'lcl'::text, 'air'::text, 'ltl'::text]))))
);

CREATE TABLE public.prospect_enrichment_ec (
  ruc text NOT NULL,
  razon_social text,
  estado_contribuyente text,
  tipo_contribuyente text,
  regimen text,
  actividad_economica_principal text,
  obligado_llevar_contabilidad boolean,
  agente_retencion boolean,
  contribuyente_especial boolean,
  contribuyente_fantasma boolean,
  transacciones_inexistentes boolean,
  fecha_inicio_actividades date,
  fecha_cese date,
  fecha_reinicio_actividades date,
  fecha_actualizacion_sri date,
  representantes_legales jsonb DEFAULT '[]'::jsonb NOT NULL,
  establecimientos jsonb DEFAULT '[]'::jsonb NOT NULL,
  direccion_matriz text,
  last_fetched_at timestamp with time zone DEFAULT now() NOT NULL,
  last_error text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT prospect_enrichment_ec_pkey PRIMARY KEY (ruc)
);

CREATE TABLE public.quote_amendments (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  quote_id uuid NOT NULL,
  status text DEFAULT 'pending'::text NOT NULL,
  reason text,
  lines jsonb NOT NULL,
  cost_total numeric,
  sale_total numeric,
  profit_total numeric,
  prev_cost_total numeric,
  prev_sale_total numeric,
  prev_profit_total numeric,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  decided_by uuid,
  decided_at timestamp with time zone,
  CONSTRAINT quote_amendments_pkey PRIMARY KEY (id),
  CONSTRAINT quote_amendments_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'approved'::text, 'rejected'::text])))
);

CREATE TABLE public.quote_charges (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  quote_id uuid NOT NULL,
  rate_component_id uuid NOT NULL,
  description character varying NOT NULL,
  quantity integer,
  amount numeric NOT NULL,
  total numeric NOT NULL,
  currency character varying,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT quote_charges_pkey PRIMARY KEY (id)
);

CREATE TABLE public.quote_emails (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  quote_id uuid NOT NULL,
  to_email text NOT NULL,
  subject text,
  method text DEFAULT 'eml_outlook'::text NOT NULL,
  sent_by uuid,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT quote_emails_pkey PRIMARY KEY (id)
);

CREATE TABLE public.quote_followups (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  quote_id uuid NOT NULL,
  done_by uuid,
  note text,
  next_followup_at date,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT quote_followups_pkey PRIMARY KEY (id)
);

CREATE TABLE public.quote_pba (
  quote_id uuid NOT NULL,
  pba_cost numeric DEFAULT 0 NOT NULL,
  notes text,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_by uuid,
  CONSTRAINT quote_pba_pkey PRIMARY KEY (quote_id)
);

CREATE TABLE public.quotes (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  quote_number character varying NOT NULL,
  client_id uuid,
  deal_id uuid,
  customer_id uuid,
  customer_name character varying,
  customer_email character varying,
  customer_phone character varying,
  origin_port_id uuid,
  destination_port_id uuid,
  equipment_type_id uuid,
  commodity_id uuid NOT NULL,
  carrier_id uuid,
  selected_rate_id uuid,
  quantity integer,
  cargo_description text,
  cargo_weight_kg numeric,
  cargo_volume_cbm numeric,
  hazmat boolean DEFAULT false,
  hazmat_class character varying,
  un_number character varying,
  special_requirements text,
  base_rate numeric,
  total_charges numeric,
  subtotal numeric,
  markup_percentage numeric DEFAULT 15,
  markup_amount numeric,
  total_amount numeric,
  currency character varying DEFAULT 'USD'::character varying,
  estimated_departure_date date,
  valid_until date,
  status character varying DEFAULT 'DRAFT'::character varying,
  sent_at timestamp with time zone,
  accepted_at timestamp with time zone,
  notes text,
  created_by uuid,
  office character varying,
  created_at timestamp with time zone DEFAULT now(),
  markup_flat numeric DEFAULT 0,
  mode text DEFAULT 'ocean'::text NOT NULL,
  air_carrier_id uuid,
  selected_air_rate_id uuid,
  origin_airport_code text,
  destination_airport_code text,
  direction text,
  incoterm text,
  payment_terms text,
  origin_agent text,
  origin_share_pct numeric,
  chargeable_weight_kg numeric,
  wm_units numeric,
  pieces integer,
  cargo_pieces jsonb,
  cost_total numeric,
  sale_total numeric,
  profit_total numeric,
  presentation_mode text DEFAULT 'total'::text,
  client_lines jsonb,
  rejected_at timestamp with time zone,
  lost_reason text,
  converted_si_id uuid,
  origin_text text,
  destination_text text,
  gross_kg numeric,
  cbm numeric,
  containers jsonb,
  transit_time text,
  cargo_hazardous boolean,
  cargo_bonded boolean,
  cargo_stackable boolean,
  contact_name text,
  followup_interval_days integer,
  next_followup_at date,
  last_followup_at timestamp with time zone,
  fx_rate numeric,
  fx_currency text,
  fx_source text,
  fx_date date,
  prepared_by uuid,
  iva_omitido boolean DEFAULT false NOT NULL,
  display_currency text,
  free_days integer,
  guarantee_waiver text,
  dims_unit text,
  weight_unit text,
  is_directos boolean DEFAULT false NOT NULL,
  CONSTRAINT quotes_pkey PRIMARY KEY (id),
  CONSTRAINT quotes_quote_number_key UNIQUE (quote_number)
);

CREATE TABLE public.rate_charges (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  rate_id uuid NOT NULL,
  charge_code text NOT NULL,
  charge_name text NOT NULL,
  amount numeric NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT rate_charges_pkey PRIMARY KEY (id)
);

CREATE TABLE public.rate_components (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  code character varying NOT NULL,
  name character varying NOT NULL,
  category character varying NOT NULL,
  description text,
  calculation_type character varying,
  active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT rate_components_pkey PRIMARY KEY (id)
);

CREATE TABLE public.rate_notes (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  rate_id uuid NOT NULL,
  note_type character varying NOT NULL,
  note_text text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT rate_notes_pkey PRIMARY KEY (id)
);

CREATE TABLE public.rates (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  contract_id uuid,
  route_id uuid,
  commodity_id uuid,
  equipment_type_id uuid,
  rate_line_number character varying,
  effective_date date,
  expiry_date date,
  base_rate numeric NOT NULL,
  currency character varying DEFAULT 'USD'::character varying,
  service_type character varying,
  transit_time integer,
  notes text,
  deferred_discount numeric DEFAULT 0,
  deferred_discount_conditions text,
  active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  origin_city text,
  origin_door_city text,
  scope text DEFAULT 'global'::text NOT NULL,
  updated_by text,
  office_id text,
  agent_id uuid,
  sell_rate numeric,
  tariff_sheet_id uuid,
  is_bullet boolean DEFAULT false NOT NULL,
  bullet_expires_at timestamp with time zone,
  bullet_priority integer,
  inland_mode text DEFAULT 'PORT'::text NOT NULL,
  ipi_construction text,
  CONSTRAINT rates_pkey PRIMARY KEY (id),
  CONSTRAINT rates_inland_mode_check CHECK ((inland_mode = ANY (ARRAY['PORT'::text, 'RAMP'::text, 'RAMP_TRUCK'::text, 'DOOR'::text]))),
  CONSTRAINT rates_ipi_construction_check CHECK (((ipi_construction IS NULL) OR (ipi_construction = ANY (ARRAY['Y'::text, 'N'::text, 'E'::text, 'I'::text, 'B'::text, 'X'::text])))),
  CONSTRAINT rates_scope_check CHECK ((scope = ANY (ARRAY['global'::text, 'USA'::text, 'PER'::text, 'ECU'::text, 'PAN'::text])))
);

CREATE TABLE public.reception_hosts (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  office text DEFAULT 'USA'::text NOT NULL,
  name text NOT NULL,
  company text,
  phone text,
  email text,
  active boolean DEFAULT true NOT NULL,
  notes text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT reception_hosts_pkey PRIMARY KEY (id)
);

CREATE TABLE public.recurring_movement (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  tenant_id uuid NOT NULL,
  office_id uuid NOT NULL,
  bank_account_id uuid,
  description text NOT NULL,
  direction text NOT NULL,
  category text NOT NULL,
  party_id uuid,
  amount numeric(18,2) NOT NULL,
  currency text NOT NULL,
  frequency text NOT NULL,
  day_of_month integer,
  day_of_week integer,
  next_occurrence_date date NOT NULL,
  last_generated_date date,
  active_from date DEFAULT CURRENT_DATE NOT NULL,
  active_to date,
  auto_create boolean DEFAULT true NOT NULL,
  reminder_days_before integer DEFAULT 3,
  active boolean DEFAULT true NOT NULL,
  notes text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT recurring_movement_pkey PRIMARY KEY (id)
);

CREATE TABLE public.reminders (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  user_id uuid NOT NULL,
  source_type text NOT NULL,
  source_id uuid,
  shipment_id uuid,
  title text NOT NULL,
  body text,
  channel text DEFAULT 'in_app'::text,
  status text DEFAULT 'PENDING'::text,
  scheduled_for timestamp with time zone DEFAULT now(),
  sent_at timestamp with time zone,
  read_at timestamp with time zone,
  metadata jsonb DEFAULT '{}'::jsonb,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT reminders_pkey PRIMARY KEY (id)
);

CREATE TABLE public.rfq_log (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  office_id text NOT NULL,
  received_at timestamp with time zone DEFAULT now(),
  sender_email text NOT NULL,
  sender_name text,
  origin text,
  destination text,
  service_type text,
  cargo_description text,
  weight_kg numeric,
  volume_cbm numeric,
  dimensions text,
  pieces integer,
  status text NOT NULL,
  rate_request_sent_at timestamp with time zone,
  quoted_at timestamp with time zone,
  draft_subject text,
  agent_id uuid,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT rfq_log_pkey PRIMARY KEY (id),
  CONSTRAINT rfq_log_status_check CHECK ((status = ANY (ARRAY['quoted'::text, 'pending_rate'::text, 'missing_info'::text, 'not_rfq'::text])))
);

CREATE TABLE public.role_permissions (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  role_id uuid NOT NULL,
  page text NOT NULL,
  can_view boolean DEFAULT false,
  can_create boolean DEFAULT false,
  can_edit boolean DEFAULT false,
  can_delete boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT role_permissions_pkey PRIMARY KEY (id),
  CONSTRAINT role_permissions_role_id_page_key UNIQUE (role_id, page)
);

CREATE TABLE public.roles (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  name text NOT NULL,
  description text,
  is_system boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT roles_pkey PRIMARY KEY (id),
  CONSTRAINT roles_name_key UNIQUE (name)
);

CREATE TABLE public.routes (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  client_id uuid NOT NULL,
  origin_port text NOT NULL,
  destination_port text NOT NULL,
  is_protected boolean DEFAULT false,
  protected_by_ff_id uuid,
  deal_value numeric(12,2),
  monthly_volume numeric(12,2),
  created_at timestamp with time zone DEFAULT now(),
  origin_port_id uuid,
  destination_port_id uuid,
  CONSTRAINT routes_pkey PRIMARY KEY (id)
);

CREATE TABLE public.sales_activities (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  activity_date timestamp with time zone NOT NULL,
  activity_type text NOT NULL,
  sales_rep_id uuid NOT NULL,
  client_id uuid,
  deal_id uuid,
  company_name text,
  contact_name text,
  duration_minutes integer DEFAULT 0,
  outcome text,
  notes text,
  follow_up_required boolean DEFAULT false,
  follow_up_date date,
  follow_up_completed boolean DEFAULT false,
  office text,
  CONSTRAINT sales_activities_pkey PRIMARY KEY (id),
  CONSTRAINT sales_activities_activity_type_check CHECK ((activity_type = ANY (ARRAY['call_outbound'::text, 'call_inbound'::text, 'visit'::text, 'office_meeting'::text, 'email_sent'::text, 'email_received'::text, 'quote_sent'::text, 'follow_up'::text, 'video_call'::text, 'whatsapp'::text]))),
  CONSTRAINT sales_activities_outcome_check CHECK ((outcome = ANY (ARRAY['positive_moving_forward'::text, 'positive_requested_quote'::text, 'positive_scheduled_meeting'::text, 'neutral_follow_up'::text, 'neutral_not_available'::text, 'negative_not_interested'::text, 'negative_competitor'::text, 'negative_no_budget'::text])))
);

CREATE TABLE public.sales_doc_counters (
  doc_type text NOT NULL,
  year integer NOT NULL,
  last_n integer DEFAULT 0 NOT NULL,
  CONSTRAINT sales_doc_counters_pkey PRIMARY KEY (doc_type, year)
);

CREATE TABLE public.sales_goals (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  sales_rep_id uuid NOT NULL,
  period_type text NOT NULL,
  calls_goal integer DEFAULT 0,
  visits_goal integer DEFAULT 0,
  emails_goal integer DEFAULT 0,
  quotes_goal integer DEFAULT 0,
  meetings_goal integer DEFAULT 0,
  revenue_goal numeric(12,2),
  start_date date,
  end_date date,
  is_active boolean DEFAULT true,
  gross_profit_goal numeric(12,2) DEFAULT 0,
  office text,
  CONSTRAINT sales_goals_pkey PRIMARY KEY (id),
  CONSTRAINT sales_goals_period_type_check CHECK ((period_type = ANY (ARRAY['daily'::text, 'weekly'::text, 'monthly'::text])))
);

CREATE TABLE public.sales_live_monthly (
  office text NOT NULL,
  ym text NOT NULL,
  gross_excl_ic numeric NOT NULL,
  gross_incl_ic numeric,
  tax numeric,
  n_invoices integer,
  method text DEFAULT 'live-magaya'::text,
  computed_at timestamp with time zone DEFAULT now(),
  fuente text DEFAULT 'live-facturas'::text,
  same_period_usd numeric,
  same_period_day integer,
  CONSTRAINT sales_live_monthly_pkey PRIMARY KEY (office, ym)
);

CREATE TABLE public.sales_quote_lines (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  quote_id uuid,
  section text DEFAULT 'freight'::text NOT NULL,
  charge_code text,
  name text NOT NULL,
  basis text DEFAULT 'manual'::text NOT NULL,
  qty numeric DEFAULT 1,
  cost_rate numeric DEFAULT 0,
  cost_amount numeric DEFAULT 0,
  sale_rate numeric DEFAULT 0,
  sale_amount numeric DEFAULT 0,
  currency text DEFAULT 'USD'::text,
  notes text,
  sort_order integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  cost_min numeric DEFAULT 0,
  sale_min numeric DEFAULT 0,
  si_id uuid,
  container_type text,
  iva_exempt boolean DEFAULT false NOT NULL,
  free_qty numeric DEFAULT 0 NOT NULL,
  CONSTRAINT sales_quote_lines_pkey PRIMARY KEY (id),
  CONSTRAINT chk_line_owner CHECK (((((quote_id IS NOT NULL))::integer + ((si_id IS NOT NULL))::integer) = 1)),
  CONSTRAINT sales_quote_lines_basis_check CHECK ((basis = ANY (ARRAY['per_kg'::text, 'per_lb'::text, 'per_wm'::text, 'per_cbm'::text, 'per_container'::text, 'per_bl'::text, 'per_lashing'::text, 'fixed'::text, 'pct'::text, 'pct_local'::text, 'manual'::text]))),
  CONSTRAINT sales_quote_lines_section_check CHECK ((section = ANY (ARRAY['freight'::text, 'origin'::text, 'destination'::text, 'other'::text])))
);

CREATE TABLE public.scheduled_payment (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  tenant_id uuid NOT NULL,
  office_id uuid NOT NULL,
  external_guid text NOT NULL,
  bill_number text,
  counterparty_name text NOT NULL,
  direction text DEFAULT 'outflow'::text NOT NULL,
  scheduled_date date NOT NULL,
  amount_usd numeric(14,2) NOT NULL,
  bank_account_id uuid,
  notes text,
  status text DEFAULT 'scheduled'::text NOT NULL,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  executed_at timestamp with time zone,
  executed_by uuid,
  cancelled_at timestamp with time zone,
  cancelled_by uuid,
  cancel_reason text,
  CONSTRAINT scheduled_payment_pkey PRIMARY KEY (id)
);

CREATE TABLE public.shipco_destinations (
  destination_code text NOT NULL,
  origin_code text DEFAULT 'USMIA'::text NOT NULL,
  destination_label text NOT NULL,
  country_iso2 text,
  region text,
  transit_days integer,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT shipco_destinations_pkey PRIMARY KEY (destination_code)
);

CREATE TABLE public.shipco_rates (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  origin_code text DEFAULT 'USMIA'::text NOT NULL,
  destination_code text NOT NULL,
  type text,
  charge_code text NOT NULL,
  currency text DEFAULT 'USD'::text NOT NULL,
  rate numeric NOT NULL,
  rate_basis text NOT NULL,
  minimum numeric,
  maximum numeric,
  uom text,
  from_qty numeric,
  to_qty numeric,
  effective_date date NOT NULL,
  expiration_date date NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT shipco_rates_pkey PRIMARY KEY (id)
);

CREATE TABLE public.shipco_settings (
  key text NOT NULL,
  value jsonb NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT shipco_settings_pkey PRIMARY KEY (key)
);

CREATE TABLE public.shipment_action_items (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  shipment_id uuid NOT NULL,
  title text NOT NULL,
  details text,
  due_date date,
  assigned_to uuid,
  priority text DEFAULT 'NORMAL'::text,
  status text DEFAULT 'OPEN'::text,
  source_agent text,
  completed_at timestamp with time zone,
  completed_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT shipment_action_items_pkey PRIMARY KEY (id)
);

CREATE TABLE public.shipment_agents (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  shipment_id uuid NOT NULL,
  name text NOT NULL,
  agent_role text DEFAULT 'ORIGIN'::text NOT NULL,
  contact_name text,
  contact_email text,
  contact_phone text,
  city text,
  country text,
  notes text,
  position integer DEFAULT 0 NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid,
  CONSTRAINT shipment_agents_pkey PRIMARY KEY (id),
  CONSTRAINT shipment_agents_agent_role_check CHECK ((agent_role = ANY (ARRAY['ORIGIN'::text, 'DESTINATION'::text, 'CUSTOMS'::text, 'FREIGHT_FORWARDER'::text, 'NVOCC'::text, 'OTHER'::text])))
);

CREATE TABLE public.shipment_containers (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  shipment_id uuid NOT NULL,
  container_number text,
  size_type text,
  seal text,
  is_reefer boolean DEFAULT false,
  temperature_setting text,
  temperature_validated_at timestamp with time zone,
  temperature_validated_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  quantity integer DEFAULT 1 NOT NULL,
  position integer DEFAULT 0 NOT NULL,
  created_by uuid,
  CONSTRAINT shipment_containers_pkey PRIMARY KEY (id),
  CONSTRAINT shipment_containers_quantity_check CHECK ((quantity > 0))
);

CREATE TABLE public.shipment_events (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  shipment_id uuid NOT NULL,
  event_type text NOT NULL,
  occurred_at timestamp with time zone DEFAULT now() NOT NULL,
  description text,
  source event_source_t DEFAULT 'MANUAL'::event_source_t NOT NULL,
  created_by uuid,
  metadata jsonb DEFAULT '{}'::jsonb,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT shipment_events_pkey PRIMARY KEY (id)
);

CREATE TABLE public.shipment_shippers (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  shipment_id uuid NOT NULL,
  name text NOT NULL,
  incoterm text,
  origin_port text,
  po_number text,
  notes text,
  position integer DEFAULT 0 NOT NULL,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid,
  CONSTRAINT shipment_shippers_pkey PRIMARY KEY (id)
);

CREATE TABLE public.shipments (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  shipment_code text,
  magaya_shipment_id uuid,
  client_id uuid,
  office text NOT NULL,
  sales_executive_id uuid,
  cs_assigned_to uuid,
  mode shipment_mode_t NOT NULL,
  direction shipment_direction_t NOT NULL,
  status shipment_status_t DEFAULT 'BOOKING'::shipment_status_t NOT NULL,
  carrier text,
  origin_port text,
  destination_port text,
  etd date,
  eta date,
  eta_text text,
  incoterm text,
  supplier text,
  booking_ref text,
  mbl text,
  hbl text,
  pba_amount numeric(12,2),
  pba_currency text DEFAULT 'USD'::text,
  pba_status pba_status_t,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  search_text text GENERATED ALWAYS AS (((((((((COALESCE(booking_ref, ''::text) || ' '::text) || COALESCE(mbl, ''::text)) || ' '::text) || COALESCE(hbl, ''::text)) || ' '::text) || COALESCE(carrier, ''::text)) || ' '::text) || COALESCE(supplier, ''::text))) STORED,
  archived_at timestamp with time zone,
  archived_by uuid,
  consignee_name text,
  vessel_name text,
  voyage text,
  via_origen ops_via_origen_t,
  equipment_type ops_equipment_t,
  no_contenerizado boolean DEFAULT false NOT NULL,
  destino_tipo ops_destino_t,
  destino_office text,
  destino_agent_id uuid,
  consolidado_id uuid,
  master_shipment_id uuid,
  is_master boolean DEFAULT false NOT NULL,
  CONSTRAINT shipments_pkey PRIMARY KEY (id),
  CONSTRAINT shipments_shipment_code_key UNIQUE (shipment_code)
);

CREATE TABLE public.shipping_instructions (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  si_number text NOT NULL,
  quote_id uuid,
  status text DEFAULT 'draft'::text NOT NULL,
  office text,
  sales_executive_id uuid,
  client_id uuid,
  created_by uuid,
  mode text DEFAULT 'LCL'::text NOT NULL,
  direction text DEFAULT 'EXPORT'::text,
  incoterm text,
  payment_terms text,
  origin_port text,
  destination_port text,
  etd date,
  eta date,
  carrier text,
  booking_ref text,
  mbl text,
  hbl text,
  shipper_name text,
  shipper_address text,
  consignee_name text,
  consignee_address text,
  consignee_ruc text,
  notify_name text,
  notify_address text,
  commodity text,
  hs_codes text,
  pieces integer,
  gross_kg numeric,
  gross_lb numeric,
  chargeable_weight_kg numeric,
  cbm numeric,
  containers jsonb,
  hazmat boolean DEFAULT false,
  hazmat_detail text,
  special_instructions text,
  origin_agent text,
  origin_share_pct numeric,
  shipment_id uuid,
  confirmed_at timestamp with time zone,
  confirmed_by uuid,
  liq_shipment_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  cost_total numeric,
  sale_total numeric,
  profit_total numeric,
  cnee_final text,
  transit_time text,
  fx_rate numeric,
  fx_currency text,
  fx_source text,
  fx_date date,
  archived_at timestamp with time zone,
  archived_by uuid,
  CONSTRAINT shipping_instructions_pkey PRIMARY KEY (id),
  CONSTRAINT shipping_instructions_si_number_key UNIQUE (si_number),
  CONSTRAINT shipping_instructions_mode_check CHECK ((mode = ANY (ARRAY['FCL'::text, 'LCL'::text, 'AIR'::text, 'COURIER'::text, 'BREAKBULK'::text, 'RORO'::text]))),
  CONSTRAINT shipping_instructions_status_check CHECK ((status = ANY (ARRAY['draft'::text, 'confirmed'::text, 'cancelled'::text])))
);

CREATE TABLE public.shipping_lines (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  name text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  created_by uuid,
  CONSTRAINT shipping_lines_pkey PRIMARY KEY (id),
  CONSTRAINT shipping_lines_name_key UNIQUE (name)
);

CREATE TABLE public.staging_check_tasks (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  manifest_source_id uuid NOT NULL,
  assigned_to uuid,
  created_by uuid NOT NULL,
  status cl_task_status DEFAULT 'pending'::cl_task_status NOT NULL,
  started_at timestamp with time zone,
  closed_at timestamp with time zone,
  verified_count integer DEFAULT 0 NOT NULL,
  missing_count integer DEFAULT 0 NOT NULL,
  extra_count integer DEFAULT 0 NOT NULL,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT staging_check_tasks_pkey PRIMARY KEY (id),
  CONSTRAINT staging_check_tasks_manifest_source_id_key UNIQUE (manifest_source_id)
);

CREATE TABLE public.staging_exceptions (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  staging_task_id uuid NOT NULL,
  exception_type staging_exception_type NOT NULL,
  missing_items text[] DEFAULT '{}'::text[],
  extra_items text[] DEFAULT '{}'::text[],
  reason text,
  raised_by uuid NOT NULL,
  raised_at timestamp with time zone DEFAULT now(),
  resolved boolean DEFAULT false NOT NULL,
  resolution text,
  resolved_by uuid,
  resolved_at timestamp with time zone,
  CONSTRAINT staging_exceptions_pkey PRIMARY KEY (id)
);

CREATE TABLE public.surcharge_adjustments (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  carrier_id uuid NOT NULL,
  charge_code text NOT NULL,
  charge_name text,
  mode text NOT NULL,
  amount numeric NOT NULL,
  effective_date date NOT NULL,
  expiry_date date,
  note text,
  attachment_url text,
  active boolean DEFAULT true NOT NULL,
  created_by uuid,
  created_by_name text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT surcharge_adjustments_pkey PRIMARY KEY (id),
  CONSTRAINT surcharge_adjustments_mode_check CHECK ((mode = ANY (ARRAY['delta'::text, 'set'::text])))
);

CREATE TABLE public.surcharges (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  name character varying NOT NULL,
  code character varying,
  carrier_id uuid,
  origin_region character varying,
  destination_region character varying,
  equipment_type_id uuid,
  amount numeric NOT NULL,
  currency character varying DEFAULT 'USD'::character varying,
  calculation_type character varying,
  effective_date date,
  expiry_date date,
  active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  min_charge numeric,
  volatile boolean DEFAULT false NOT NULL,
  revision_frequency text,
  last_confirmed_at date,
  weight_basis text DEFAULT 'CHARGEABLE'::text NOT NULL,
  CONSTRAINT surcharges_pkey PRIMARY KEY (id),
  CONSTRAINT surcharges_weight_basis_check CHECK ((weight_basis = ANY (ARRAY['CHARGEABLE'::text, 'GROSS'::text])))
);

CREATE TABLE public.tariff_sheets (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  name text NOT NULL,
  description text,
  source_type text DEFAULT 'manual'::text NOT NULL,
  source_file_url text,
  contract_id uuid,
  carrier_id uuid,
  agent_id uuid,
  office_id text,
  trade_lane text,
  effective_date date,
  expiry_date date,
  uploaded_by uuid,
  status text DEFAULT 'active'::text NOT NULL,
  notes text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT tariff_sheets_pkey PRIMARY KEY (id),
  CONSTRAINT tariff_sheets_source_type_check CHECK ((source_type = ANY (ARRAY['manual'::text, 'excel_upload'::text, 'api_import'::text, 'contract_pdf'::text]))),
  CONSTRAINT tariff_sheets_status_check CHECK ((status = ANY (ARRAY['draft'::text, 'active'::text, 'expired'::text, 'superseded'::text])))
);

CREATE TABLE public.time_entries (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  user_id uuid NOT NULL,
  clock_in_time timestamp with time zone DEFAULT now() NOT NULL,
  clock_out_time timestamp with time zone,
  total_hours numeric(10,2),
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  active_time_minutes integer DEFAULT 0,
  idle_time_minutes integer DEFAULT 0,
  activity_percentage numeric(5,2) DEFAULT 0,
  last_activity_at timestamp with time zone,
  CONSTRAINT time_entries_pkey PRIMARY KEY (id)
);

CREATE TABLE public.transit_times (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  carrier_id uuid,
  origin_port_id uuid,
  destination_port_id uuid,
  transit_days integer,
  service_name character varying,
  frequency character varying,
  notes text,
  active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT transit_times_pkey PRIMARY KEY (id)
);

CREATE TABLE public.unplanned_additions (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  loading_task_id uuid NOT NULL,
  barcode text NOT NULL,
  magaya_tracking text,
  weight_kg numeric(10,3),
  volume_m3 numeric(10,3),
  reason text NOT NULL,
  authorized_by uuid NOT NULL,
  authorized_at timestamp with time zone DEFAULT now() NOT NULL,
  raised_by uuid NOT NULL,
  raised_at timestamp with time zone DEFAULT now(),
  CONSTRAINT unplanned_additions_pkey PRIMARY KEY (id)
);

CREATE TABLE public.user_delegations (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  viewer_user_id uuid NOT NULL,
  owner_user_id uuid NOT NULL,
  scope text DEFAULT 'all'::text NOT NULL,
  notes text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  created_by uuid,
  CONSTRAINT user_delegations_pkey PRIMARY KEY (id),
  CONSTRAINT user_delegations_viewer_user_id_owner_user_id_key UNIQUE (viewer_user_id, owner_user_id),
  CONSTRAINT user_delegations_check CHECK ((viewer_user_id <> owner_user_id)),
  CONSTRAINT user_delegations_scope_check CHECK ((scope = ANY (ARRAY['all'::text, 'read_only'::text])))
);

CREATE TABLE public.user_permission_overrides (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  user_id uuid NOT NULL,
  page text NOT NULL,
  can_view boolean,
  can_create boolean,
  can_edit boolean,
  can_delete boolean,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT user_permission_overrides_pkey PRIMARY KEY (id),
  CONSTRAINT user_permission_overrides_user_id_page_key UNIQUE (user_id, page)
);

CREATE TABLE public.users (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  name text NOT NULL,
  email text NOT NULL,
  office text NOT NULL,
  role text NOT NULL,
  language text DEFAULT 'en'::text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  auth_user_id uuid,
  birthday date,
  phone text,
  extension_number text,
  hire_date date,
  status text DEFAULT 'Active'::text,
  invited_at timestamp with time zone,
  invited_by uuid,
  last_login timestamp with time zone,
  updated_at timestamp with time zone DEFAULT now(),
  department text,
  role_id uuid,
  can_update_contracts boolean DEFAULT false,
  can_access_billing boolean DEFAULT false,
  report_visibility text DEFAULT 'own'::text NOT NULL,
  can_adjust_surcharges boolean DEFAULT false NOT NULL,
  is_junior_exec boolean DEFAULT false NOT NULL,
  gender text,
  cs_all_execs boolean DEFAULT false NOT NULL,
  CONSTRAINT users_pkey PRIMARY KEY (id),
  CONSTRAINT users_email_key UNIQUE (email),
  CONSTRAINT users_gender_check CHECK ((gender = ANY (ARRAY['M'::text, 'F'::text]))),
  CONSTRAINT users_language_check CHECK ((language = ANY (ARRAY['en'::text, 'es'::text]))),
  CONSTRAINT users_office_check CHECK ((office = ANY (ARRAY['USA'::text, 'Panama'::text, 'Ecuador'::text, 'Peru'::text]))),
  CONSTRAINT users_report_visibility_check CHECK ((report_visibility = ANY (ARRAY['own'::text, 'office'::text, 'all'::text]))),
  CONSTRAINT users_role_check CHECK ((role = ANY (ARRAY['Admin'::text, 'Manager'::text, 'Sales Executive'::text, 'Support'::text, 'Customer Service'::text, 'VP'::text, 'Administration'::text, 'Sales'::text, 'Operations'::text, 'Accounting'::text])))
);

CREATE TABLE public.vendor_flexibility (
  tenant_id uuid DEFAULT 'a4e3e84c-7fca-4ce3-8889-1f31d8d1366f'::uuid NOT NULL,
  counterparty_key text NOT NULL,
  tier text NOT NULL,
  max_push_weeks integer DEFAULT 0 NOT NULL,
  notes text,
  set_by uuid,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT vendor_flexibility_pkey PRIMARY KEY (tenant_id, counterparty_key)
);

CREATE TABLE public.vendor_profile (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  tenant_id uuid NOT NULL,
  vendor_name text NOT NULL,
  intensity_score_stars smallint,
  notes text,
  last_rated_at timestamp with time zone,
  rated_by uuid,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT vendor_profile_pkey PRIMARY KEY (id),
  CONSTRAINT vendor_profile_tenant_id_vendor_name_key UNIQUE (tenant_id, vendor_name)
);

CREATE TABLE public.ventas_alertas (
  id bigint DEFAULT nextval('ventas_alertas_id_seq'::regclass) NOT NULL,
  fecha date,
  severidad text,
  office text,
  ym text,
  regla text,
  detalle text,
  creado timestamp with time zone DEFAULT now(),
  CONSTRAINT ventas_alertas_pkey PRIMARY KEY (id)
);

CREATE TABLE public.ventas_congelado (
  office text NOT NULL,
  ym text NOT NULL,
  valor numeric,
  congelado_at timestamp with time zone DEFAULT now(),
  CONSTRAINT ventas_congelado_pkey PRIMARY KEY (office, ym)
);

CREATE TABLE public.visitor_badges (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  office text DEFAULT 'USA'::text NOT NULL,
  label text NOT NULL,
  badge_number integer,
  status text DEFAULT 'available'::text NOT NULL,
  notes text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT visitor_badges_pkey PRIMARY KEY (id),
  CONSTRAINT visitor_badges_office_label_key UNIQUE (office, label),
  CONSTRAINT visitor_badges_status_check CHECK ((status = ANY (ARRAY['available'::text, 'in_use'::text, 'retired'::text])))
);

CREATE TABLE public.visitors (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  full_name text NOT NULL,
  company text,
  document_type text,
  document_number text,
  phone text,
  email text,
  photo_url text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT visitors_pkey PRIMARY KEY (id)
);

CREATE TABLE public.visits (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  visitor_id uuid,
  office text DEFAULT 'USA'::text NOT NULL,
  host_user_id uuid,
  host_name_snapshot text,
  purpose text,
  badge_id uuid,
  photo_url text,
  document_type text,
  document_number text,
  nda_signed boolean DEFAULT false NOT NULL,
  nda_signature_url text,
  nda_version text,
  safety_accepted boolean DEFAULT false NOT NULL,
  status text DEFAULT 'checked_in'::text NOT NULL,
  checked_in_at timestamp with time zone DEFAULT now() NOT NULL,
  checked_out_at timestamp with time zone,
  notified_email boolean DEFAULT false NOT NULL,
  notified_whatsapp boolean DEFAULT false NOT NULL,
  notify_error text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  updated_at timestamp with time zone DEFAULT now() NOT NULL,
  host_tenant_id uuid,
  host_type text,
  CONSTRAINT visits_pkey PRIMARY KEY (id),
  CONSTRAINT visits_status_check CHECK ((status = ANY (ARRAY['checked_in'::text, 'checked_out'::text])))
);

CREATE TABLE public.warehouse_cogs_manual (
  id integer DEFAULT nextval('warehouse_cogs_manual_id_seq'::regclass) NOT NULL,
  year integer NOT NULL,
  month integer,
  category text NOT NULL,
  amount numeric(15,2) NOT NULL,
  source text DEFAULT 'manual'::text,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT warehouse_cogs_manual_pkey PRIMARY KEY (id)
);

CREATE TABLE public.warehouse_cogs_monthly (
  id integer DEFAULT nextval('warehouse_cogs_monthly_id_seq'::regclass) NOT NULL,
  year integer NOT NULL,
  month integer NOT NULL,
  category text NOT NULL,
  source text NOT NULL,
  entity_name text,
  amount numeric(14,2) NOT NULL,
  CONSTRAINT warehouse_cogs_monthly_pkey PRIMARY KEY (id),
  CONSTRAINT warehouse_cogs_monthly_year_month_category_key UNIQUE (year, month, category)
);

CREATE TABLE public.warehouse_containers (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  name text NOT NULL,
  week text,
  booking text,
  shipping_line text,
  owner_id uuid,
  container_type text,
  container_number text,
  hazmat_bonded text,
  cut_off_date timestamp with time zone,
  load_unload_datetime timestamp with time zone,
  status text,
  door text,
  loader text,
  lg_cr text,
  staging text,
  palos_2x4 integer DEFAULT 0,
  straps_amarillos integer DEFAULT 0,
  pallets_vacios integer DEFAULT 0,
  bolsas_aire integer DEFAULT 0,
  notes text,
  special_instructions text,
  office text NOT NULL,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  employee text,
  created_by_user_id uuid,
  CONSTRAINT warehouse_containers_pkey PRIMARY KEY (id),
  CONSTRAINT warehouse_containers_office_check CHECK ((office = ANY (ARRAY['USA'::text, 'Panama'::text, 'Ecuador'::text, 'Peru'::text])))
);

CREATE TABLE public.warehouse_tasks (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  name text NOT NULL,
  week text,
  description text,
  owner_id uuid,
  assigned_to_id uuid,
  agent_client text,
  status text,
  priority text,
  due_date timestamp with time zone,
  date_done timestamp with time zone,
  timeline_start timestamp with time zone,
  timeline_end timestamp with time zone,
  estimated_hours numeric,
  actual_hours numeric,
  task_type text,
  notes text,
  completion_notes text,
  blockers text,
  office text NOT NULL,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  employee text,
  created_by_user_id uuid,
  CONSTRAINT warehouse_tasks_pkey PRIMARY KEY (id),
  CONSTRAINT warehouse_tasks_office_check CHECK ((office = ANY (ARRAY['USA'::text, 'Panama'::text, 'Ecuador'::text, 'Peru'::text])))
);

CREATE TABLE public.warehouse_users (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  user_id uuid NOT NULL,
  employee_code text NOT NULL,
  warehouse_id uuid,
  roles warehouse_role[] DEFAULT '{}'::warehouse_role[] NOT NULL,
  certs warehouse_cert[] DEFAULT '{}'::warehouse_cert[] NOT NULL,
  pin_hash text,
  biometric_id text,
  active boolean DEFAULT true NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT warehouse_users_pkey PRIMARY KEY (id),
  CONSTRAINT warehouse_users_employee_code_key UNIQUE (employee_code),
  CONSTRAINT warehouse_users_user_id_key UNIQUE (user_id)
);

CREATE TABLE public.wh_carga_no_identificada (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  wr_number text NOT NULL,
  tipo text NOT NULL,
  detectado_at timestamp with time zone DEFAULT now() NOT NULL,
  entry_date date,
  consignee_inicial text,
  agente_inicial text,
  shipper text,
  piezas integer,
  peso_lb numeric,
  volumen_cft numeric,
  recibido_por text,
  estado text DEFAULT 'SIN_IDENTIFICAR'::text NOT NULL,
  identificado_at timestamp with time zone,
  consignee_final text,
  agente_final text,
  client_id uuid,
  dias_para_identificar numeric,
  cobrable boolean DEFAULT true NOT NULL,
  cargo_usd numeric,
  facturado boolean DEFAULT false NOT NULL,
  nota text,
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT wh_carga_no_identificada_pkey PRIMARY KEY (id),
  CONSTRAINT wh_carga_no_identificada_wr_number_key UNIQUE (wr_number),
  CONSTRAINT wh_carga_no_identificada_estado_check CHECK ((estado = ANY (ARRAY['SIN_IDENTIFICAR'::text, 'IDENTIFICADA'::text, 'IMPORTACION'::text, 'DESCARTADA'::text]))),
  CONSTRAINT wh_carga_no_identificada_tipo_check CHECK ((tipo = ANY (ARRAY['SIN_CONSIGNATARIO'::text, 'SIN_AGENTE'::text])))
);

CREATE TABLE public.wh_client_pallets (
  id integer DEFAULT nextval('wh_client_pallets_id_seq'::regclass) NOT NULL,
  client_group text NOT NULL,
  pallets_per_container numeric DEFAULT 25 NOT NULL,
  notes text,
  CONSTRAINT wh_client_pallets_pkey PRIMARY KEY (id),
  CONSTRAINT wh_client_pallets_client_group_key UNIQUE (client_group)
);

CREATE TABLE public.wh_container_types (
  id integer DEFAULT nextval('wh_container_types_id_seq'::regclass) NOT NULL,
  match_pattern text NOT NULL,
  canonical text NOT NULL,
  cbm_capacity numeric NOT NULL,
  priority integer DEFAULT 100 NOT NULL,
  CONSTRAINT wh_container_types_pkey PRIMARY KEY (id),
  CONSTRAINT wh_container_types_match_pattern_key UNIQUE (match_pattern)
);

CREATE TABLE public.wh_containers (
  monday_item_id bigint NOT NULL,
  board_id bigint,
  board_year integer,
  week_label text,
  week_no integer,
  name text,
  booking text,
  shipping_line text,
  owner text,
  status text,
  container_type_raw text,
  container_type text,
  cbm_capacity numeric,
  container_number text,
  load_date date,
  loader text,
  haz_bonded text,
  trade_dir text DEFAULT 'EXPORT'::text NOT NULL,
  item_created_at timestamp with time zone,
  synced_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT wh_containers_pkey PRIMARY KEY (monday_item_id)
);

CREATE TABLE public.wh_containers_external (
  monday_item_id bigint NOT NULL,
  board_id bigint,
  board_year integer,
  week_label text,
  week_no integer,
  name text,
  booking text,
  shipping_line text,
  owner text,
  container_type text,
  container_number text,
  status text,
  port_of_loading text,
  destination text,
  destination_agent text,
  doc_cutoff date,
  cargo_cutoff date,
  etd date,
  eta date,
  item_created_at timestamp with time zone,
  synced_at timestamp with time zone,
  CONSTRAINT wh_containers_external_pkey PRIMARY KEY (monday_item_id)
);

CREATE TABLE public.wh_country_map (
  id integer DEFAULT nextval('wh_country_map_id_seq'::regclass) NOT NULL,
  match_field text NOT NULL,
  match_pattern text NOT NULL,
  country text NOT NULL,
  priority integer DEFAULT 100 NOT NULL,
  CONSTRAINT wh_country_map_pkey PRIMARY KEY (id),
  CONSTRAINT wh_country_map_match_field_match_pattern_key UNIQUE (match_field, match_pattern),
  CONSTRAINT wh_country_map_match_field_check CHECK ((match_field = ANY (ARRAY['destination_agent'::text, 'consignee'::text, 'destination_port'::text])))
);

CREATE TABLE public.wh_doc_7512 (
  wr_number text NOT NULL,
  numero text NOT NULL,
  registrado_por uuid,
  registrado_at timestamp with time zone DEFAULT now() NOT NULL,
  notas text,
  CONSTRAINT wh_doc_7512_pkey PRIMARY KEY (wr_number)
);

CREATE TABLE public.wh_import_clients (
  id integer DEFAULT nextval('wh_import_clients_id_seq'::regclass) NOT NULL,
  client_group text NOT NULL,
  match_pattern text NOT NULL,
  active boolean DEFAULT true NOT NULL,
  notes text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT wh_import_clients_pkey PRIMARY KEY (id)
);

CREATE TABLE public.wh_internal_people (
  id integer DEFAULT nextval('wh_internal_people_id_seq'::regclass) NOT NULL,
  name_pattern text NOT NULL,
  office text NOT NULL,
  suggested_agent text,
  notes text,
  CONSTRAINT wh_internal_people_pkey PRIMARY KEY (id),
  CONSTRAINT wh_internal_people_name_pattern_key UNIQUE (name_pattern)
);

CREATE TABLE public.wh_loading_rates (
  id integer DEFAULT nextval('wh_loading_rates_id_seq'::regclass) NOT NULL,
  container_type text NOT NULL,
  client_group text DEFAULT 'ALL'::text NOT NULL,
  rate_usd numeric NOT NULL,
  effective_from date DEFAULT '2026-01-01'::date NOT NULL,
  notes text,
  CONSTRAINT wh_loading_rates_pkey PRIMARY KEY (id),
  CONSTRAINT wh_loading_rates_container_type_client_group_effective_from_key UNIQUE (container_type, client_group, effective_from)
);

CREATE TABLE public.wh_notices (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  wr_number text NOT NULL,
  client_id uuid,
  consignee_name text,
  shipper_name text,
  tracking text,
  observaciones text,
  invoice_status text,
  subject text,
  body_html text,
  recipients jsonb,
  attachments jsonb,
  status text DEFAULT 'DRAFT'::text NOT NULL,
  error text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  sent_at timestamp with time zone,
  sent_by uuid,
  attachments_refreshed_at timestamp with time zone,
  invoice_status_manual boolean DEFAULT false NOT NULL,
  CONSTRAINT wh_notices_pkey PRIMARY KEY (id),
  CONSTRAINT wh_notices_wr_number_key UNIQUE (wr_number),
  CONSTRAINT wh_notices_invoice_status_check CHECK ((invoice_status = ANY (ARRAY['ADJUNTA'::text, 'FALTANTE'::text, 'SIN_PACKING'::text]))),
  CONSTRAINT wh_notices_status_check CHECK ((status = ANY (ARRAY['DRAFT'::text, 'READY'::text, 'SENT'::text, 'ERROR'::text, 'SKIPPED'::text])))
);

CREATE TABLE public.wh_report_clients (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  name text NOT NULL,
  consignee_name text,
  active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT wh_report_clients_pkey PRIMARY KEY (id)
);

CREATE TABLE public.wh_report_movement_items (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  movement_id uuid,
  product_id uuid,
  quantity integer DEFAULT 0 NOT NULL,
  cartons_per_pallet integer,
  is_incomplete boolean DEFAULT false,
  notes text,
  CONSTRAINT wh_report_movement_items_pkey PRIMARY KEY (id)
);

CREATE TABLE public.wh_report_movements (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  client_id uuid,
  date date NOT NULL,
  movement_type text NOT NULL,
  reference_number text,
  container_number text,
  product_name text,
  total_pallets integer DEFAULT 0,
  packing_pallets integer DEFAULT 0,
  packing_loose integer DEFAULT 0,
  packing_total integer DEFAULT 0,
  physical_pallets integer DEFAULT 0,
  physical_loose integer DEFAULT 0,
  physical_total integer DEFAULT 0,
  extra_pallets integer DEFAULT 0,
  notes text,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  magaya_wr_id uuid,
  magaya_cr_id uuid,
  source text DEFAULT 'manual'::text,
  CONSTRAINT wh_report_movements_pkey PRIMARY KEY (id),
  CONSTRAINT wh_report_movements_movement_type_check CHECK ((movement_type = ANY (ARRAY['IN'::text, 'OUT'::text]))),
  CONSTRAINT wh_report_movements_source_check CHECK ((source = ANY (ARRAY['manual'::text, 'magaya_auto'::text, 'excel_import'::text])))
);

CREATE TABLE public.wh_report_product_mappings (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  client_id uuid NOT NULL,
  product_id uuid NOT NULL,
  magaya_pattern text NOT NULL,
  priority integer DEFAULT 0,
  active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT wh_report_product_mappings_pkey PRIMARY KEY (id),
  CONSTRAINT wh_report_product_mappings_client_id_magaya_pattern_key UNIQUE (client_id, magaya_pattern)
);

CREATE TABLE public.wh_report_products (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  client_id uuid,
  name text NOT NULL,
  short_name text,
  display_order integer DEFAULT 0,
  active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  standard_cartons_per_pallet integer,
  CONSTRAINT wh_report_products_pkey PRIMARY KEY (id)
);

CREATE TABLE public.wh_report_sync_log (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  source_table text NOT NULL,
  source_id uuid,
  client_id uuid,
  item_description text,
  status text NOT NULL,
  message text,
  resolved_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT wh_report_sync_log_pkey PRIMARY KEY (id),
  CONSTRAINT wh_report_sync_log_status_check CHECK ((status = ANY (ARRAY['unmapped'::text, 'error'::text, 'resolved'::text])))
);

CREATE TABLE public.wh_stations (
  id integer DEFAULT nextval('wh_stations_id_seq'::regclass) NOT NULL,
  person_pattern text NOT NULL,
  station text,
  role text NOT NULL,
  active boolean DEFAULT true NOT NULL,
  notes text,
  CONSTRAINT wh_stations_pkey PRIMARY KEY (id),
  CONSTRAINT wh_stations_person_pattern_key UNIQUE (person_pattern)
);

CREATE TABLE public.wh_storage_terms (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  patron text NOT NULL,
  dias_libres integer DEFAULT 30 NOT NULL,
  activo boolean DEFAULT true NOT NULL,
  nota text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT wh_storage_terms_pkey PRIMARY KEY (id),
  CONSTRAINT wh_storage_terms_patron_key UNIQUE (patron),
  CONSTRAINT wh_storage_terms_dias_libres_check CHECK (((dias_libres >= 1) AND (dias_libres <= 365)))
);

CREATE TABLE public.wh_unloading_rates (
  id integer DEFAULT nextval('wh_unloading_rates_id_seq'::regclass) NOT NULL,
  client_group text NOT NULL,
  rate_usd numeric NOT NULL,
  effective_from date DEFAULT '2026-01-01'::date NOT NULL,
  notes text,
  container_type text DEFAULT 'ALL'::text NOT NULL,
  CONSTRAINT wh_unloading_rates_pkey PRIMARY KEY (id)
);

CREATE TABLE public.wh_warehouse_costs (
  id integer DEFAULT nextval('wh_warehouse_costs_id_seq'::regclass) NOT NULL,
  month date NOT NULL,
  warehouse text NOT NULL,
  cost_type text NOT NULL,
  amount numeric NOT NULL,
  headcount integer,
  notes text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT wh_warehouse_costs_pkey PRIMARY KEY (id),
  CONSTRAINT wh_warehouse_costs_month_warehouse_cost_type_key UNIQUE (month, warehouse, cost_type),
  CONSTRAINT wh_warehouse_costs_warehouse_check CHECK ((warehouse = ANY (ARRAY['IMPORT'::text, 'EXPORT'::text, 'SHARED'::text])))
);

CREATE TABLE public.wh_whr_backfill_universo (
  wr_number text NOT NULL,
  nivel integer NOT NULL,
  motivo text NOT NULL,
  entrada date,
  creado_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT wh_whr_backfill_universo_pkey PRIMARY KEY (wr_number),
  CONSTRAINT wh_whr_backfill_universo_nivel_check CHECK (((nivel >= 1) AND (nivel <= 4)))
);

CREATE TABLE public.wr_att_backfill_queue (
  id bigint DEFAULT nextval('wr_att_backfill_queue_id_seq'::regclass) NOT NULL,
  wr_id uuid NOT NULL,
  wr_number text NOT NULL,
  guid text NOT NULL,
  status text DEFAULT 'pending'::text NOT NULL,
  files integer,
  attempts integer DEFAULT 0 NOT NULL,
  error_msg text,
  ran_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT wr_att_backfill_queue_pkey PRIMARY KEY (id),
  CONSTRAINT wr_att_backfill_queue_wr_number_key UNIQUE (wr_number)
);

CREATE TABLE public.wr_backfill_queue (
  id integer DEFAULT nextval('wr_backfill_queue_id_seq'::regclass) NOT NULL,
  start_date date NOT NULL,
  end_date date NOT NULL,
  status text DEFAULT 'pending'::text NOT NULL,
  records integer,
  error_msg text,
  ran_at timestamp with time zone,
  CONSTRAINT wr_backfill_queue_pkey PRIMARY KEY (id),
  CONSTRAINT wr_backfill_queue_start_date_key UNIQUE (start_date)
);

CREATE TABLE public.wr_match_results (
  id uuid DEFAULT gen_random_uuid() NOT NULL,
  wr_id uuid NOT NULL,
  status wr_match_status_t NOT NULL,
  matched_client_id uuid,
  matched_shipment_id uuid,
  match_score numeric(4,3),
  match_reason text,
  candidates jsonb DEFAULT '[]'::jsonb,
  resolved_by uuid,
  resolved_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  office text,
  CONSTRAINT wr_match_results_pkey PRIMARY KEY (id),
  CONSTRAINT wr_match_results_wr_id_key UNIQUE (wr_id)
);

CREATE TABLE public.wr_saldo_queue (
  wr_number text NOT NULL,
  prioridad integer DEFAULT 5 NOT NULL,
  intentos integer DEFAULT 0 NOT NULL,
  ultimo_intento_at timestamp with time zone,
  resuelto_at timestamp with time zone,
  error text,
  created_at timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT wr_saldo_queue_pkey PRIMARY KEY (wr_number)
);

CREATE TABLE timeclock.corrections (
  id integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  emp_id integer NOT NULL,
  kind text NOT NULL,
  ref_date text,
  added_punch_id integer,
  reason text,
  by_user text DEFAULT 'supervisor'::text NOT NULL,
  at timestamp with time zone DEFAULT now() NOT NULL,
  old_value text,
  new_value text,
  CONSTRAINT corrections_pkey PRIMARY KEY (id)
);

CREATE TABLE timeclock.employees (
  id integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  badge text NOT NULL,
  name text NOT NULL,
  pin text NOT NULL,
  shift_start text DEFAULT '08:30'::text NOT NULL,
  shift_end text DEFAULT '17:00'::text NOT NULL,
  site_id text DEFAULT 'MIA'::text NOT NULL,
  hourly_rate double precision DEFAULT 15.0 NOT NULL,
  active integer DEFAULT 1 NOT NULL,
  CONSTRAINT employees_pkey PRIMARY KEY (id),
  CONSTRAINT employees_badge_key UNIQUE (badge)
);

CREATE TABLE timeclock.punches (
  id integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  emp_id integer NOT NULL,
  ts text NOT NULL,
  source text DEFAULT 'legacy'::text NOT NULL,
  lat double precision,
  lng double precision,
  dist_m double precision,
  in_fence integer,
  token_ok integer,
  selfie text,
  deleted integer DEFAULT 0 NOT NULL,
  note text,
  CONSTRAINT punches_pkey PRIMARY KEY (id)
);

CREATE TABLE timeclock.sites (
  id text NOT NULL,
  name text NOT NULL,
  lat double precision,
  lng double precision,
  radius_m integer DEFAULT 250 NOT NULL,
  secret text NOT NULL,
  tz text DEFAULT 'America/New_York'::text NOT NULL,
  workweek_start integer DEFAULT 0 NOT NULL,
  max_shift_hours double precision DEFAULT 14.0 NOT NULL,
  ot_weekly_threshold double precision DEFAULT 40.0 NOT NULL,
  ot_multiplier double precision DEFAULT 1.5 NOT NULL,
  CONSTRAINT sites_pkey PRIMARY KEY (id)
);

-- Foreign keys (al final para no depender del orden de creación)
ALTER TABLE archive.magaya_charges ADD CONSTRAINT magaya_charges_company_id_fkey FOREIGN KEY (company_id) REFERENCES magaya_companies(id);
ALTER TABLE private._audit_billing_aliases ADD CONSTRAINT _audit_billing_aliases_crm_client_id_fkey FOREIGN KEY (crm_client_id) REFERENCES clients(id);
ALTER TABLE public.activities ADD CONSTRAINT activities_client_id_fkey FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE;
ALTER TABLE public.activities ADD CONSTRAINT activities_route_id_fkey FOREIGN KEY (route_id) REFERENCES routes(id) ON DELETE SET NULL;
ALTER TABLE public.activity_logs ADD CONSTRAINT activity_logs_time_entry_id_fkey FOREIGN KEY (time_entry_id) REFERENCES time_entries(id) ON DELETE CASCADE;
ALTER TABLE public.agent_files ADD CONSTRAINT agent_files_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES agents(id) ON DELETE CASCADE;
ALTER TABLE public.agent_office_mapping ADD CONSTRAINT agent_office_mapping_created_by_fkey FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE public.air_rates ADD CONSTRAINT air_rates_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES agents(id);
ALTER TABLE public.air_rates ADD CONSTRAINT air_rates_air_carrier_id_fkey FOREIGN KEY (air_carrier_id) REFERENCES air_carriers(id);
ALTER TABLE public.birthday_emails_sent ADD CONSTRAINT birthday_emails_sent_contact_id_fkey FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE CASCADE;
ALTER TABLE public.bodega_tenants ADD CONSTRAINT bodega_tenants_creado_por_fkey FOREIGN KEY (creado_por) REFERENCES users(id);
ALTER TABLE public.carrier_email_log ADD CONSTRAINT carrier_email_log_matched_shipment_id_fkey FOREIGN KEY (matched_shipment_id) REFERENCES shipments(id);
ALTER TABLE public.carrier_transit_times ADD CONSTRAINT carrier_transit_times_carrier_id_fkey FOREIGN KEY (carrier_id) REFERENCES carriers(id);
ALTER TABLE public.carrier_transit_times ADD CONSTRAINT carrier_transit_times_route_id_fkey FOREIGN KEY (route_id) REFERENCES freight_routes(id);
ALTER TABLE public.carrier_transit_times ADD CONSTRAINT carrier_transit_times_transshipment_port_id_fkey FOREIGN KEY (transshipment_port_id) REFERENCES ports(id);
ALTER TABLE public.carrier_transit_times ADD CONSTRAINT carrier_transit_times_verified_by_fkey FOREIGN KEY (verified_by) REFERENCES users(id);
ALTER TABLE public.christmas_bookings ADD CONSTRAINT bookings_pallet_id_fkey FOREIGN KEY (pallet_id) REFERENCES christmas_pallet_presets(id);
ALTER TABLE public.christmas_bookings ADD CONSTRAINT bookings_rep_id_fkey FOREIGN KEY (rep_id) REFERENCES auth.users(id);
ALTER TABLE public.christmas_bookings ADD CONSTRAINT bookings_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES christmas_tenants(id) ON DELETE CASCADE;
ALTER TABLE public.christmas_destinations ADD CONSTRAINT destinations_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id);
ALTER TABLE public.christmas_destinations ADD CONSTRAINT destinations_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES christmas_tenants(id) ON DELETE CASCADE;
ALTER TABLE public.christmas_fee_overrides ADD CONSTRAINT fee_overrides_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES christmas_tenants(id) ON DELETE CASCADE;
ALTER TABLE public.christmas_fee_overrides ADD CONSTRAINT fee_overrides_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES auth.users(id);
ALTER TABLE public.christmas_global_settings ADD CONSTRAINT global_settings_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES christmas_tenants(id) ON DELETE CASCADE;
ALTER TABLE public.christmas_global_settings ADD CONSTRAINT global_settings_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES auth.users(id);
ALTER TABLE public.christmas_pallet_presets ADD CONSTRAINT pallet_presets_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES christmas_tenants(id) ON DELETE CASCADE;
ALTER TABLE public.christmas_products ADD CONSTRAINT products_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES christmas_tenants(id) ON DELETE CASCADE;
ALTER TABLE public.christmas_user_profiles ADD CONSTRAINT user_profiles_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES christmas_tenants(id) ON DELETE SET NULL;
ALTER TABLE public.christmas_user_profiles ADD CONSTRAINT user_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public.cl_alerts ADD CONSTRAINT cl_alerts_acknowledged_by_fkey FOREIGN KEY (acknowledged_by) REFERENCES warehouse_users(id);
ALTER TABLE public.cl_alerts ADD CONSTRAINT cl_alerts_loading_task_id_fkey FOREIGN KEY (loading_task_id) REFERENCES loading_tasks(id);
ALTER TABLE public.cl_alerts ADD CONSTRAINT cl_alerts_manifest_source_id_fkey FOREIGN KEY (manifest_source_id) REFERENCES manifest_sources(id);
ALTER TABLE public.cl_alerts ADD CONSTRAINT cl_alerts_picking_task_id_fkey FOREIGN KEY (picking_task_id) REFERENCES picking_tasks(id);
ALTER TABLE public.cl_alerts ADD CONSTRAINT cl_alerts_recipient_user_id_fkey FOREIGN KEY (recipient_user_id) REFERENCES warehouse_users(id);
ALTER TABLE public.cl_alerts ADD CONSTRAINT cl_alerts_staging_task_id_fkey FOREIGN KEY (staging_task_id) REFERENCES staging_check_tasks(id);
ALTER TABLE public.cl_alerts ADD CONSTRAINT cl_alerts_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES cl_warehouses(id);
ALTER TABLE public.cl_audit_log ADD CONSTRAINT cl_audit_log_performed_by_fkey FOREIGN KEY (performed_by) REFERENCES warehouse_users(id);
ALTER TABLE public.cl_scan_events ADD CONSTRAINT cl_scan_events_loading_task_id_fkey FOREIGN KEY (loading_task_id) REFERENCES loading_tasks(id) ON DELETE SET NULL;
ALTER TABLE public.cl_scan_events ADD CONSTRAINT cl_scan_events_matched_item_id_fkey FOREIGN KEY (matched_item_id) REFERENCES manifest_items(id);
ALTER TABLE public.cl_scan_events ADD CONSTRAINT cl_scan_events_picking_task_id_fkey FOREIGN KEY (picking_task_id) REFERENCES picking_tasks(id) ON DELETE SET NULL;
ALTER TABLE public.cl_scan_events ADD CONSTRAINT cl_scan_events_scanned_by_fkey FOREIGN KEY (scanned_by) REFERENCES warehouse_users(id);
ALTER TABLE public.cl_scan_events ADD CONSTRAINT cl_scan_events_staging_task_id_fkey FOREIGN KEY (staging_task_id) REFERENCES staging_check_tasks(id) ON DELETE SET NULL;
ALTER TABLE public.client_notify_contacts ADD CONSTRAINT client_notify_contacts_client_id_fkey FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE;
ALTER TABLE public.client_visits ADD CONSTRAINT client_visits_client_id_fkey FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE;
ALTER TABLE public.client_visits ADD CONSTRAINT client_visits_created_by_fkey FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE public.client_visits ADD CONSTRAINT client_visits_executive_id_fkey FOREIGN KEY (executive_id) REFERENCES users(id);
ALTER TABLE public.clients ADD CONSTRAINT clients_account_manager_id_fkey FOREIGN KEY (account_manager_id) REFERENCES users(id);
ALTER TABLE public.clients ADD CONSTRAINT clients_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL;
ALTER TABLE public.clients ADD CONSTRAINT clients_customer_service_id_fkey FOREIGN KEY (customer_service_id) REFERENCES users(id) ON DELETE SET NULL;
ALTER TABLE public.clients ADD CONSTRAINT clients_deleted_by_fkey FOREIGN KEY (deleted_by) REFERENCES users(id) ON DELETE SET NULL;
ALTER TABLE public.clients ADD CONSTRAINT clients_parent_ff_id_fkey FOREIGN KEY (parent_ff_id) REFERENCES clients(id) ON DELETE SET NULL;
ALTER TABLE public.closings ADD CONSTRAINT closings_client_id_fkey FOREIGN KEY (client_id) REFERENCES clients(id);
ALTER TABLE public.closings ADD CONSTRAINT closings_executive_id_fkey FOREIGN KEY (executive_id) REFERENCES users(id);
ALTER TABLE public.cmm_chat_messages ADD CONSTRAINT cmm_chat_messages_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL;
ALTER TABLE public.cmm_client_aliases ADD CONSTRAINT cmm_client_aliases_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL;
ALTER TABLE public.cmm_commission_policies ADD CONSTRAINT cmm_commission_policies_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL;
ALTER TABLE public.cmm_context_notes ADD CONSTRAINT cmm_context_notes_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL;
ALTER TABLE public.cmm_dismissed_actions ADD CONSTRAINT cmm_dismissed_actions_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL;
ALTER TABLE public.cmm_dismissed_actions ADD CONSTRAINT cmm_dismissed_actions_seller_id_fkey FOREIGN KEY (seller_id) REFERENCES cmm_sellers(id) ON DELETE CASCADE;
ALTER TABLE public.cmm_insights ADD CONSTRAINT cmm_insights_generated_by_fkey FOREIGN KEY (generated_by) REFERENCES auth.users(id) ON DELETE SET NULL;
ALTER TABLE public.cmm_pending ADD CONSTRAINT cmm_pending_seller_id_fkey FOREIGN KEY (seller_id) REFERENCES cmm_sellers(id);
ALTER TABLE public.cmm_pending ADD CONSTRAINT cmm_pending_upload_id_fkey FOREIGN KEY (upload_id) REFERENCES cmm_uploads(id) ON DELETE CASCADE;
ALTER TABLE public.cmm_targets ADD CONSTRAINT cmm_targets_seller_id_fkey FOREIGN KEY (seller_id) REFERENCES cmm_sellers(id) ON DELETE CASCADE;
ALTER TABLE public.cmm_transactions ADD CONSTRAINT cmm_transactions_seller_id_fkey FOREIGN KEY (seller_id) REFERENCES cmm_sellers(id);
ALTER TABLE public.cmm_transactions ADD CONSTRAINT cmm_transactions_upload_id_fkey FOREIGN KEY (upload_id) REFERENCES cmm_uploads(id) ON DELETE CASCADE;
ALTER TABLE public.cmm_uploads ADD CONSTRAINT cmm_uploads_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES auth.users(id) ON DELETE SET NULL;
ALTER TABLE public.consignee_aliases ADD CONSTRAINT consignee_aliases_client_id_fkey FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE;
ALTER TABLE public.consignee_aliases ADD CONSTRAINT consignee_aliases_created_by_fkey FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE public.consolidado_aereo_prefs ADD CONSTRAINT consolidado_aereo_prefs_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES users(id);
ALTER TABLE public.consolidado_agente_exclusiones ADD CONSTRAINT consolidado_agente_exclusiones_consolidado_id_fkey FOREIGN KEY (consolidado_id) REFERENCES consolidados(id) ON DELETE CASCADE;
ALTER TABLE public.consolidado_agente_exclusiones ADD CONSTRAINT consolidado_agente_exclusiones_creado_por_fkey FOREIGN KEY (creado_por) REFERENCES users(id);
ALTER TABLE public.consolidado_avisos ADD CONSTRAINT consolidado_avisos_consolidado_id_fkey FOREIGN KEY (consolidado_id) REFERENCES consolidados(id) ON DELETE CASCADE;
ALTER TABLE public.consolidado_avisos ADD CONSTRAINT consolidado_avisos_sent_by_fkey FOREIGN KEY (sent_by) REFERENCES users(id);
ALTER TABLE public.consolidado_contenedores ADD CONSTRAINT consolidado_contenedores_consolidado_id_fkey FOREIGN KEY (consolidado_id) REFERENCES consolidados(id) ON DELETE CASCADE;
ALTER TABLE public.consolidado_email_bitacora ADD CONSTRAINT consolidado_email_bitacora_consolidado_id_fkey FOREIGN KEY (consolidado_id) REFERENCES consolidados(id);
ALTER TABLE public.consolidado_grupos ADD CONSTRAINT consolidado_grupos_consolidado_id_fkey FOREIGN KEY (consolidado_id) REFERENCES consolidados(id) ON DELETE CASCADE;
ALTER TABLE public.consolidado_linea_hazmat ADD CONSTRAINT consolidado_linea_hazmat_consolidado_id_fkey FOREIGN KEY (consolidado_id) REFERENCES consolidados(id) ON DELETE CASCADE;
ALTER TABLE public.consolidado_linea_hazmat ADD CONSTRAINT consolidado_linea_hazmat_linea_id_fkey FOREIGN KEY (linea_id) REFERENCES consolidado_lineas(id) ON DELETE CASCADE;
ALTER TABLE public.consolidado_linea_movimientos ADD CONSTRAINT consolidado_linea_movimientos_consolidado_id_fkey FOREIGN KEY (consolidado_id) REFERENCES consolidados(id);
ALTER TABLE public.consolidado_linea_movimientos ADD CONSTRAINT consolidado_linea_movimientos_contenedor_id_fkey FOREIGN KEY (contenedor_id) REFERENCES consolidado_contenedores(id) ON DELETE SET NULL;
ALTER TABLE public.consolidado_linea_movimientos ADD CONSTRAINT consolidado_linea_movimientos_hecho_por_fkey FOREIGN KEY (hecho_por) REFERENCES users(id);
ALTER TABLE public.consolidado_linea_movimientos ADD CONSTRAINT consolidado_linea_movimientos_linea_id_fkey FOREIGN KEY (linea_id) REFERENCES consolidado_lineas(id) ON DELETE CASCADE;
ALTER TABLE public.consolidado_linea_piezas ADD CONSTRAINT consolidado_linea_piezas_consolidado_id_fkey FOREIGN KEY (consolidado_id) REFERENCES consolidados(id);
ALTER TABLE public.consolidado_linea_piezas ADD CONSTRAINT consolidado_linea_piezas_creado_por_fkey FOREIGN KEY (creado_por) REFERENCES users(id);
ALTER TABLE public.consolidado_linea_piezas ADD CONSTRAINT consolidado_linea_piezas_linea_id_fkey FOREIGN KEY (linea_id) REFERENCES consolidado_lineas(id) ON DELETE CASCADE;
ALTER TABLE public.consolidado_linea_piezas ADD CONSTRAINT consolidado_linea_piezas_wr_item_id_fkey FOREIGN KEY (wr_item_id) REFERENCES magaya_wr_items(id) ON DELETE SET NULL;
ALTER TABLE public.consolidado_lineas ADD CONSTRAINT consolidado_lineas_cargado_confirmado_por_fkey FOREIGN KEY (cargado_confirmado_por) REFERENCES users(id);
ALTER TABLE public.consolidado_lineas ADD CONSTRAINT consolidado_lineas_cfs_extra_por_fkey FOREIGN KEY (cfs_extra_por) REFERENCES users(id);
ALTER TABLE public.consolidado_lineas ADD CONSTRAINT consolidado_lineas_client_id_fkey FOREIGN KEY (client_id) REFERENCES clients(id);
ALTER TABLE public.consolidado_lineas ADD CONSTRAINT consolidado_lineas_consolidado_id_fkey FOREIGN KEY (consolidado_id) REFERENCES consolidados(id) ON DELETE CASCADE;
ALTER TABLE public.consolidado_lineas ADD CONSTRAINT consolidado_lineas_contenedor_id_fkey FOREIGN KEY (contenedor_id) REFERENCES consolidado_contenedores(id) ON DELETE SET NULL;
ALTER TABLE public.consolidado_lineas ADD CONSTRAINT consolidado_lineas_grupo_id_fkey FOREIGN KEY (grupo_id) REFERENCES consolidado_grupos(id) ON DELETE SET NULL;
ALTER TABLE public.consolidado_lineas ADD CONSTRAINT consolidado_lineas_instruido_por_fkey FOREIGN KEY (instruido_por) REFERENCES users(id);
ALTER TABLE public.consolidado_lineas ADD CONSTRAINT consolidado_lineas_rodado_desde_fkey FOREIGN KEY (rodado_desde) REFERENCES consolidado_lineas(id) ON DELETE SET NULL;
ALTER TABLE public.consolidado_lineas ADD CONSTRAINT consolidado_lineas_shipment_id_fkey FOREIGN KEY (shipment_id) REFERENCES shipments(id) ON DELETE SET NULL;
ALTER TABLE public.consolidados ADD CONSTRAINT consolidados_creado_por_fkey FOREIGN KEY (creado_por) REFERENCES users(id);
ALTER TABLE public.consolidados ADD CONSTRAINT consolidados_servicio_fkey FOREIGN KEY (servicio) REFERENCES consolidado_servicios(codigo);
ALTER TABLE public.contacts ADD CONSTRAINT contacts_client_id_fkey FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE;
ALTER TABLE public.container_files ADD CONSTRAINT container_files_container_id_fkey FOREIGN KEY (container_id) REFERENCES warehouse_containers(id) ON DELETE CASCADE;
ALTER TABLE public.container_load_reports ADD CONSTRAINT container_load_reports_generated_by_fkey FOREIGN KEY (generated_by) REFERENCES warehouse_users(id);
ALTER TABLE public.container_load_reports ADD CONSTRAINT container_load_reports_loading_task_id_fkey FOREIGN KEY (loading_task_id) REFERENCES loading_tasks(id) ON DELETE CASCADE;
ALTER TABLE public.container_load_reports ADD CONSTRAINT container_load_reports_manifest_source_id_fkey FOREIGN KEY (manifest_source_id) REFERENCES manifest_sources(id);
ALTER TABLE public.contract_documents ADD CONSTRAINT contract_documents_contract_id_fkey FOREIGN KEY (contract_id) REFERENCES contracts(id);
ALTER TABLE public.contract_documents ADD CONSTRAINT contract_documents_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES users(id);
ALTER TABLE public.contract_update_lines ADD CONSTRAINT contract_update_lines_update_id_fkey FOREIGN KEY (update_id) REFERENCES contract_updates(id) ON DELETE CASCADE;
ALTER TABLE public.contract_updates ADD CONSTRAINT contract_updates_carrier_id_fkey FOREIGN KEY (carrier_id) REFERENCES carriers(id);
ALTER TABLE public.contract_updates ADD CONSTRAINT contract_updates_contract_id_fkey FOREIGN KEY (contract_id) REFERENCES contracts(id);
ALTER TABLE public.contract_updates ADD CONSTRAINT contract_updates_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES users(id);
ALTER TABLE public.contracts ADD CONSTRAINT contracts_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES agents(id);
ALTER TABLE public.contracts ADD CONSTRAINT contracts_carrier_id_fkey FOREIGN KEY (carrier_id) REFERENCES carriers(id);
ALTER TABLE public.contracts ADD CONSTRAINT contracts_parent_contract_id_fkey FOREIGN KEY (parent_contract_id) REFERENCES contracts(id);
ALTER TABLE public.coordination_tasks ADD CONSTRAINT coordination_tasks_archived_by_fkey FOREIGN KEY (archived_by) REFERENCES users(id);
ALTER TABLE public.coordination_tasks ADD CONSTRAINT coordination_tasks_client_id_fkey FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE SET NULL;
ALTER TABLE public.coordination_tasks ADD CONSTRAINT coordination_tasks_created_by_fkey FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE public.coordination_tasks ADD CONSTRAINT coordination_tasks_cs_assigned_to_fkey FOREIGN KEY (cs_assigned_to) REFERENCES users(id);
ALTER TABLE public.coordination_tasks ADD CONSTRAINT coordination_tasks_sales_executive_id_fkey FOREIGN KEY (sales_executive_id) REFERENCES users(id);
ALTER TABLE public.coordination_tasks ADD CONSTRAINT coordination_tasks_shipment_id_fkey FOREIGN KEY (shipment_id) REFERENCES shipments(id) ON DELETE SET NULL;
ALTER TABLE public.credit_documents ADD CONSTRAINT credit_documents_credit_request_id_fkey FOREIGN KEY (credit_request_id) REFERENCES credit_requests(id) ON DELETE CASCADE;
ALTER TABLE public.credit_documents ADD CONSTRAINT credit_documents_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES users(id);
ALTER TABLE public.credit_notify_log ADD CONSTRAINT credit_notify_log_credit_request_id_fkey FOREIGN KEY (credit_request_id) REFERENCES credit_requests(id) ON DELETE SET NULL;
ALTER TABLE public.credit_requests ADD CONSTRAINT credit_requests_client_id_fkey FOREIGN KEY (client_id) REFERENCES clients(id);
ALTER TABLE public.credit_requests ADD CONSTRAINT credit_requests_requested_by_fkey FOREIGN KEY (requested_by) REFERENCES users(id);
ALTER TABLE public.credit_requests ADD CONSTRAINT credit_requests_reviewed_by_fkey FOREIGN KEY (reviewed_by) REFERENCES users(id);
ALTER TABLE public.cs_assignments ADD CONSTRAINT cs_assignments_created_by_fkey FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE public.cs_assignments ADD CONSTRAINT cs_assignments_cs_user_id_fkey FOREIGN KEY (cs_user_id) REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE public.cs_assignments ADD CONSTRAINT cs_assignments_sales_executive_id_fkey FOREIGN KEY (sales_executive_id) REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE public.cs_cuentas_habilitadas ADD CONSTRAINT cs_cuentas_habilitadas_client_id_fkey FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE;
ALTER TABLE public.cs_cuentas_habilitadas ADD CONSTRAINT cs_cuentas_habilitadas_created_by_fkey FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE public.cs_cuentas_habilitadas ADD CONSTRAINT cs_cuentas_habilitadas_cs_user_id_fkey FOREIGN KEY (cs_user_id) REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE public.dispatches ADD CONSTRAINT dispatches_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES clients(id) ON DELETE SET NULL;
ALTER TABLE public.drayage_rates ADD CONSTRAINT drayage_rates_destination_por_id_fkey FOREIGN KEY (destination_por_id) REFERENCES points_of_receipt(id);
ALTER TABLE public.ec_fcl_local_charges ADD CONSTRAINT ec_fcl_local_charges_carrier_id_fkey FOREIGN KEY (carrier_id) REFERENCES carriers(id);
ALTER TABLE public.external_containers ADD CONSTRAINT external_containers_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES clients(id) ON DELETE SET NULL;
ALTER TABLE public.fact_orders ADD CONSTRAINT fact_orders_client_id_fkey FOREIGN KEY (client_id) REFERENCES clients(id);
ALTER TABLE public.fact_orders ADD CONSTRAINT fact_orders_created_by_fkey FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE public.fact_orders ADD CONSTRAINT fact_orders_shipment_id_fkey FOREIGN KEY (shipment_id) REFERENCES shipments(id);
ALTER TABLE public.fact_orders ADD CONSTRAINT fact_orders_si_id_fkey FOREIGN KEY (si_id) REFERENCES shipping_instructions(id);
ALTER TABLE public.fcl_semanal ADD CONSTRAINT fcl_semanal_client_id_fkey FOREIGN KEY (client_id) REFERENCES clients(id);
ALTER TABLE public.fcl_semanal ADD CONSTRAINT fcl_semanal_shipment_id_fkey FOREIGN KEY (shipment_id) REFERENCES shipments(id) ON DELETE SET NULL;
ALTER TABLE public.finanzas_access ADD CONSTRAINT finanzas_access_granted_by_fkey FOREIGN KEY (granted_by) REFERENCES users(id);
ALTER TABLE public.finanzas_access ADD CONSTRAINT finanzas_access_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE public.finanzas_bank_match ADD CONSTRAINT finanzas_bank_match_bank_transaction_id_fkey FOREIGN KEY (bank_transaction_id) REFERENCES bank_transaction(id) ON DELETE CASCADE;
ALTER TABLE public.finanzas_bank_match ADD CONSTRAINT finanzas_bank_match_office_id_fkey FOREIGN KEY (office_id) REFERENCES offices(id);
ALTER TABLE public.finanzas_config_recurrente ADD CONSTRAINT finanzas_config_recurrente_office_id_fkey FOREIGN KEY (office_id) REFERENCES offices(id);
ALTER TABLE public.finanzas_deuda_externa ADD CONSTRAINT finanzas_deuda_externa_office_id_fkey FOREIGN KEY (office_id) REFERENCES offices(id);
ALTER TABLE public.finanzas_eeff_pl ADD CONSTRAINT finanzas_eeff_pl_office_id_fkey FOREIGN KEY (office_id) REFERENCES offices(id);
ALTER TABLE public.finanzas_forecast_recurrente ADD CONSTRAINT finanzas_forecast_recurrente_office_id_fkey FOREIGN KEY (office_id) REFERENCES offices(id);
ALTER TABLE public.finanzas_presupuesto ADD CONSTRAINT finanzas_presupuesto_office_id_fkey FOREIGN KEY (office_id) REFERENCES offices(id);
ALTER TABLE public.finanzas_rc_por_zarpar ADD CONSTRAINT finanzas_rc_por_zarpar_office_id_fkey FOREIGN KEY (office_id) REFERENCES offices(id);
ALTER TABLE public.freight_routes ADD CONSTRAINT freight_routes_destination_port_id_fkey FOREIGN KEY (destination_port_id) REFERENCES ports(id);
ALTER TABLE public.freight_routes ADD CONSTRAINT freight_routes_origin_port_id_fkey FOREIGN KEY (origin_port_id) REFERENCES ports(id);
ALTER TABLE public.freight_routes ADD CONSTRAINT freight_routes_transit_verified_by_fkey FOREIGN KEY (transit_verified_by) REFERENCES users(id);
ALTER TABLE public.freight_routes ADD CONSTRAINT freight_routes_transshipment_port_id_fkey FOREIGN KEY (transshipment_port_id) REFERENCES ports(id);
ALTER TABLE public.impersonation_log ADD CONSTRAINT impersonation_log_admin_user_id_fkey FOREIGN KEY (admin_user_id) REFERENCES users(id) ON DELETE RESTRICT;
ALTER TABLE public.impersonation_log ADD CONSTRAINT impersonation_log_target_user_id_fkey FOREIGN KEY (target_user_id) REFERENCES users(id) ON DELETE RESTRICT;
ALTER TABLE public.inhouse_dashboards ADD CONSTRAINT inhouse_dashboards_client_id_fkey FOREIGN KEY (client_id) REFERENCES clients(id);
ALTER TABLE public.inhouse_dashboards ADD CONSTRAINT inhouse_dashboards_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES users(id);
ALTER TABLE public.inhouse_despachos ADD CONSTRAINT inhouse_despachos_client_id_fkey FOREIGN KEY (client_id) REFERENCES clients(id);
ALTER TABLE public.inhouse_despachos ADD CONSTRAINT inhouse_despachos_created_by_fkey FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE public.inhouse_despachos ADD CONSTRAINT inhouse_despachos_shipment_id_fkey FOREIGN KEY (shipment_id) REFERENCES shipments(id) ON DELETE SET NULL;
ALTER TABLE public.inhouse_documentos ADD CONSTRAINT inhouse_documentos_despacho_id_fkey FOREIGN KEY (despacho_id) REFERENCES inhouse_despachos(id) ON DELETE CASCADE;
ALTER TABLE public.inhouse_documentos ADD CONSTRAINT inhouse_documentos_subido_por_fkey FOREIGN KEY (subido_por) REFERENCES users(id);
ALTER TABLE public.inhouse_profiles ADD CONSTRAINT inhouse_profiles_client_id_fkey FOREIGN KEY (client_id) REFERENCES clients(id);
ALTER TABLE public.inland_addons ADD CONSTRAINT inland_addons_carrier_id_fkey FOREIGN KEY (carrier_id) REFERENCES carriers(id);
ALTER TABLE public.inland_addons ADD CONSTRAINT inland_addons_pol_port_id_fkey FOREIGN KEY (pol_port_id) REFERENCES ports(id);
ALTER TABLE public.inland_carrier_area_rates ADD CONSTRAINT inland_carrier_area_rates_carrier_id_fkey FOREIGN KEY (carrier_id) REFERENCES inland_carriers(id) ON DELETE CASCADE;
ALTER TABLE public.inland_carrier_rates ADD CONSTRAINT inland_carrier_rates_carrier_id_fkey FOREIGN KEY (carrier_id) REFERENCES inland_carriers(id) ON DELETE CASCADE;
ALTER TABLE public.inland_carrier_zips ADD CONSTRAINT inland_carrier_zips_carrier_id_fkey FOREIGN KEY (carrier_id) REFERENCES inland_carriers(id) ON DELETE CASCADE;
ALTER TABLE public.inland_quotes ADD CONSTRAINT inland_quotes_carrier_id_fkey FOREIGN KEY (carrier_id) REFERENCES inland_carriers(id);
ALTER TABLE public.inland_quotes ADD CONSTRAINT inland_quotes_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL;
ALTER TABLE public.liq_agent_invoice_lines ADD CONSTRAINT liq_agent_invoice_lines_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES liq_agent_invoices(id) ON DELETE CASCADE;
ALTER TABLE public.liq_documents ADD CONSTRAINT liq_documents_shipment_id_fkey FOREIGN KEY (shipment_id) REFERENCES liq_shipments(id) ON DELETE CASCADE;
ALTER TABLE public.liq_settlement_lines ADD CONSTRAINT liq_settlement_lines_charge_code_fkey FOREIGN KEY (charge_code) REFERENCES liq_charge_catalog(code);
ALTER TABLE public.liq_settlement_lines ADD CONSTRAINT liq_settlement_lines_settlement_id_fkey FOREIGN KEY (settlement_id) REFERENCES liq_settlements(id) ON DELETE CASCADE;
ALTER TABLE public.liq_settlements ADD CONSTRAINT liq_settlements_shipment_id_fkey FOREIGN KEY (shipment_id) REFERENCES liq_shipments(id) ON DELETE CASCADE;
ALTER TABLE public.liq_tariffs ADD CONSTRAINT liq_tariffs_charge_code_fkey FOREIGN KEY (charge_code) REFERENCES liq_charge_catalog(code);
ALTER TABLE public.loading_exceptions ADD CONSTRAINT loading_exceptions_authorized_by_fkey FOREIGN KEY (authorized_by) REFERENCES warehouse_users(id);
ALTER TABLE public.loading_exceptions ADD CONSTRAINT loading_exceptions_loading_task_id_fkey FOREIGN KEY (loading_task_id) REFERENCES loading_tasks(id) ON DELETE CASCADE;
ALTER TABLE public.loading_exceptions ADD CONSTRAINT loading_exceptions_manifest_item_id_fkey FOREIGN KEY (manifest_item_id) REFERENCES manifest_items(id);
ALTER TABLE public.loading_exceptions ADD CONSTRAINT loading_exceptions_raised_by_fkey FOREIGN KEY (raised_by) REFERENCES warehouse_users(id);
ALTER TABLE public.loading_materials ADD CONSTRAINT loading_materials_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES cl_warehouses(id) ON DELETE CASCADE;
ALTER TABLE public.loading_task_materials ADD CONSTRAINT loading_task_materials_loading_task_id_fkey FOREIGN KEY (loading_task_id) REFERENCES loading_tasks(id) ON DELETE CASCADE;
ALTER TABLE public.loading_task_materials ADD CONSTRAINT loading_task_materials_material_id_fkey FOREIGN KEY (material_id) REFERENCES loading_materials(id) ON DELETE RESTRICT;
ALTER TABLE public.loading_task_materials ADD CONSTRAINT loading_task_materials_recorded_by_fkey FOREIGN KEY (recorded_by) REFERENCES warehouse_users(id);
ALTER TABLE public.loading_tasks ADD CONSTRAINT loading_tasks_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES warehouse_users(id);
ALTER TABLE public.loading_tasks ADD CONSTRAINT loading_tasks_container_type_fkey FOREIGN KEY (container_type) REFERENCES cl_container_types(code);
ALTER TABLE public.loading_tasks ADD CONSTRAINT loading_tasks_loader_signed_by_fkey FOREIGN KEY (loader_signed_by) REFERENCES warehouse_users(id);
ALTER TABLE public.loading_tasks ADD CONSTRAINT loading_tasks_manifest_source_id_fkey FOREIGN KEY (manifest_source_id) REFERENCES manifest_sources(id) ON DELETE CASCADE;
ALTER TABLE public.loading_tasks ADD CONSTRAINT loading_tasks_override_by_fkey FOREIGN KEY (override_by) REFERENCES warehouse_users(id);
ALTER TABLE public.loading_tasks ADD CONSTRAINT loading_tasks_reopened_by_fkey FOREIGN KEY (reopened_by) REFERENCES warehouse_users(id);
ALTER TABLE public.loading_tasks ADD CONSTRAINT loading_tasks_supervisor_signed_by_fkey FOREIGN KEY (supervisor_signed_by) REFERENCES warehouse_users(id);
ALTER TABLE public.magaya_accounts ADD CONSTRAINT magaya_accounts_company_id_fkey FOREIGN KEY (company_id) REFERENCES magaya_companies(id) ON DELETE CASCADE;
ALTER TABLE public.magaya_bills ADD CONSTRAINT magaya_bills_company_id_fkey FOREIGN KEY (company_id) REFERENCES magaya_companies(id);
ALTER TABLE public.magaya_cargo_releases ADD CONSTRAINT magaya_cargo_releases_company_id_fkey FOREIGN KEY (company_id) REFERENCES magaya_companies(id);
ALTER TABLE public.magaya_charge_definitions ADD CONSTRAINT magaya_charge_definitions_company_id_fkey FOREIGN KEY (company_id) REFERENCES magaya_companies(id) ON DELETE CASCADE;
ALTER TABLE public.magaya_clients ADD CONSTRAINT magaya_clients_company_id_fkey FOREIGN KEY (company_id) REFERENCES magaya_companies(id);
ALTER TABLE public.magaya_cr_items ADD CONSTRAINT magaya_cr_items_company_id_fkey FOREIGN KEY (company_id) REFERENCES magaya_companies(id);
ALTER TABLE public.magaya_cr_items ADD CONSTRAINT magaya_cr_items_cr_id_fkey FOREIGN KEY (cr_id) REFERENCES magaya_cargo_releases(id) ON DELETE CASCADE;
ALTER TABLE public.magaya_currencies ADD CONSTRAINT magaya_currencies_company_id_fkey FOREIGN KEY (company_id) REFERENCES magaya_companies(id) ON DELETE CASCADE;
ALTER TABLE public.magaya_entities ADD CONSTRAINT magaya_entities_company_id_fkey FOREIGN KEY (company_id) REFERENCES magaya_companies(id) ON DELETE CASCADE;
ALTER TABLE public.magaya_event_definitions ADD CONSTRAINT magaya_event_definitions_company_id_fkey FOREIGN KEY (company_id) REFERENCES magaya_companies(id) ON DELETE CASCADE;
ALTER TABLE public.magaya_inventory ADD CONSTRAINT magaya_inventory_company_id_fkey FOREIGN KEY (company_id) REFERENCES magaya_companies(id);
ALTER TABLE public.magaya_invoices ADD CONSTRAINT magaya_invoices_company_id_fkey FOREIGN KEY (company_id) REFERENCES magaya_companies(id);
ALTER TABLE public.magaya_journal_entries ADD CONSTRAINT magaya_journal_entries_company_id_fkey FOREIGN KEY (company_id) REFERENCES magaya_companies(id);
ALTER TABLE public.magaya_journal_entry_lines ADD CONSTRAINT magaya_journal_entry_lines_company_id_fkey FOREIGN KEY (company_id) REFERENCES magaya_companies(id);
ALTER TABLE public.magaya_journal_entry_lines ADD CONSTRAINT magaya_journal_entry_lines_journal_entry_id_fkey FOREIGN KEY (journal_entry_id) REFERENCES magaya_journal_entries(id) ON DELETE CASCADE;
ALTER TABLE public.magaya_pickup_orders ADD CONSTRAINT magaya_pickup_orders_company_id_fkey FOREIGN KEY (company_id) REFERENCES magaya_companies(id);
ALTER TABLE public.magaya_shipments ADD CONSTRAINT magaya_shipments_company_id_fkey FOREIGN KEY (company_id) REFERENCES magaya_companies(id);
ALTER TABLE public.magaya_sync_log ADD CONSTRAINT magaya_sync_log_company_id_fkey FOREIGN KEY (company_id) REFERENCES magaya_companies(id) ON DELETE CASCADE;
ALTER TABLE public.magaya_sync_state ADD CONSTRAINT magaya_sync_state_company_id_fkey FOREIGN KEY (company_id) REFERENCES magaya_companies(id);
ALTER TABLE public.magaya_transaction_charges ADD CONSTRAINT fk_tx_charges_company FOREIGN KEY (company_id) REFERENCES magaya_companies(id) ON DELETE CASCADE;
ALTER TABLE public.magaya_transaction_charges ADD CONSTRAINT fk_tx_charges_transaction FOREIGN KEY (transaction_id) REFERENCES magaya_transactions(id) ON DELETE CASCADE;
ALTER TABLE public.magaya_transactions ADD CONSTRAINT magaya_transactions_company_id_fkey FOREIGN KEY (company_id) REFERENCES magaya_companies(id) ON DELETE CASCADE;
ALTER TABLE public.magaya_usa_shipments ADD CONSTRAINT magaya_usa_shipments_manual_master_id_fkey FOREIGN KEY (manual_master_id) REFERENCES magaya_usa_shipments(id) ON DELETE SET NULL;
ALTER TABLE public.magaya_vendor_payments ADD CONSTRAINT magaya_vendor_payments_company_id_fkey FOREIGN KEY (company_id) REFERENCES magaya_companies(id);
ALTER TABLE public.magaya_warehouse_receipts ADD CONSTRAINT magaya_warehouse_receipts_company_id_fkey FOREIGN KEY (company_id) REFERENCES magaya_companies(id);
ALTER TABLE public.magaya_wr_attachments ADD CONSTRAINT magaya_wr_attachments_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES users(id);
ALTER TABLE public.magaya_wr_attachments ADD CONSTRAINT magaya_wr_attachments_wr_id_fkey FOREIGN KEY (wr_id) REFERENCES magaya_warehouse_receipts(id) ON DELETE CASCADE;
ALTER TABLE public.magaya_wr_items ADD CONSTRAINT magaya_wr_items_company_id_fkey FOREIGN KEY (company_id) REFERENCES magaya_companies(id);
ALTER TABLE public.magaya_wr_items ADD CONSTRAINT magaya_wr_items_wr_id_fkey FOREIGN KEY (wr_id) REFERENCES magaya_warehouse_receipts(id) ON DELETE CASCADE;
ALTER TABLE public.manifest_items ADD CONSTRAINT fk_manifest_items_pick_task FOREIGN KEY (assigned_picking_task_id) REFERENCES picking_tasks(id) ON DELETE SET NULL;
ALTER TABLE public.manifest_items ADD CONSTRAINT manifest_items_depalletized_by_fkey FOREIGN KEY (depalletized_by) REFERENCES warehouse_users(id);
ALTER TABLE public.manifest_items ADD CONSTRAINT manifest_items_depalletized_supervisor_id_fkey FOREIGN KEY (depalletized_supervisor_id) REFERENCES warehouse_users(id);
ALTER TABLE public.manifest_items ADD CONSTRAINT manifest_items_loaded_by_fkey FOREIGN KEY (loaded_by) REFERENCES warehouse_users(id);
ALTER TABLE public.manifest_items ADD CONSTRAINT manifest_items_manifest_source_id_fkey FOREIGN KEY (manifest_source_id) REFERENCES manifest_sources(id) ON DELETE CASCADE;
ALTER TABLE public.manifest_items ADD CONSTRAINT manifest_items_picked_by_fkey FOREIGN KEY (picked_by) REFERENCES warehouse_users(id);
ALTER TABLE public.manifest_items ADD CONSTRAINT manifest_items_verified_by_fkey FOREIGN KEY (verified_by) REFERENCES warehouse_users(id);
ALTER TABLE public.manifest_sources ADD CONSTRAINT manifest_sources_container_type_fkey FOREIGN KEY (container_type) REFERENCES cl_container_types(code);
ALTER TABLE public.manifest_sources ADD CONSTRAINT manifest_sources_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES cl_warehouses(id);
ALTER TABLE public.mi_actor_alias ADD CONSTRAINT mi_actor_alias_canonical_id_fkey FOREIGN KEY (canonical_id) REFERENCES mi_canonical_actor(id) ON DELETE CASCADE;
ALTER TABLE public.mi_etl_run ADD CONSTRAINT mi_etl_run_triggered_by_fkey FOREIGN KEY (triggered_by) REFERENCES users(id);
ALTER TABLE public.mi_match_review_queue ADD CONSTRAINT mi_match_review_queue_reviewed_by_fkey FOREIGN KEY (reviewed_by) REFERENCES users(id);
ALTER TABLE public.mi_match_review_queue ADD CONSTRAINT mi_match_review_queue_suggested_client_id_fkey FOREIGN KEY (suggested_client_id) REFERENCES clients(id) ON DELETE CASCADE;
ALTER TABLE public.mi_shipment_intel ADD CONSTRAINT mi_shipment_intel_carrier_canonical_id_fkey FOREIGN KEY (carrier_canonical_id) REFERENCES mi_canonical_actor(id) ON DELETE SET NULL;
ALTER TABLE public.mi_shipment_intel ADD CONSTRAINT mi_shipment_intel_client_id_fkey FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE SET NULL;
ALTER TABLE public.mi_shipment_intel ADD CONSTRAINT mi_shipment_intel_etl_run_id_fkey FOREIGN KEY (etl_run_id) REFERENCES mi_etl_run(id) ON DELETE SET NULL;
ALTER TABLE public.mi_shipment_intel ADD CONSTRAINT mi_shipment_intel_forwarder_canonical_id_fkey FOREIGN KEY (forwarder_canonical_id) REFERENCES mi_canonical_actor(id) ON DELETE SET NULL;
ALTER TABLE public.mi_shipment_intel ADD CONSTRAINT mi_shipment_intel_partner_canonical_id_fkey FOREIGN KEY (partner_canonical_id) REFERENCES mi_canonical_actor(id) ON DELETE SET NULL;
ALTER TABLE public.ops_client_notices ADD CONSTRAINT ops_client_notices_shipment_id_fkey FOREIGN KEY (shipment_id) REFERENCES shipments(id);
ALTER TABLE public.ops_devolucion_vacios ADD CONSTRAINT ops_devolucion_vacios_shipment_container_id_fkey FOREIGN KEY (shipment_container_id) REFERENCES shipment_containers(id) ON DELETE CASCADE;
ALTER TABLE public.ops_devolucion_vacios ADD CONSTRAINT ops_devolucion_vacios_shipment_id_fkey FOREIGN KEY (shipment_id) REFERENCES shipments(id) ON DELETE SET NULL;
ALTER TABLE public.ops_documents ADD CONSTRAINT ops_documents_applied_by_fkey FOREIGN KEY (applied_by) REFERENCES users(id);
ALTER TABLE public.ops_documents ADD CONSTRAINT ops_documents_shipment_id_fkey FOREIGN KEY (shipment_id) REFERENCES shipments(id);
ALTER TABLE public.ops_documents ADD CONSTRAINT ops_documents_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES users(id);
ALTER TABLE public.ops_hbl ADD CONSTRAINT ops_hbl_created_by_fkey FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE public.ops_hbl ADD CONSTRAINT ops_hbl_issued_by_fkey FOREIGN KEY (issued_by) REFERENCES users(id);
ALTER TABLE public.ops_hbl ADD CONSTRAINT ops_hbl_master_id_fkey FOREIGN KEY (master_id) REFERENCES ops_master(id);
ALTER TABLE public.ops_hbl ADD CONSTRAINT ops_hbl_shipment_id_fkey FOREIGN KEY (shipment_id) REFERENCES shipments(id);
ALTER TABLE public.ops_inbound_emails ADD CONSTRAINT ops_inbound_emails_shipment_id_fkey FOREIGN KEY (shipment_id) REFERENCES shipments(id) ON DELETE SET NULL;
ALTER TABLE public.ops_inbound_emails ADD CONSTRAINT ops_inbound_emails_si_resuelta_por_fkey FOREIGN KEY (si_resuelta_por) REFERENCES users(id);
ALTER TABLE public.ops_master ADD CONSTRAINT ops_master_created_by_fkey FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE public.ops_release ADD CONSTRAINT ops_release_authorized_by_fkey FOREIGN KEY (authorized_by) REFERENCES users(id);
ALTER TABLE public.ops_release ADD CONSTRAINT ops_release_cas_document_id_fkey FOREIGN KEY (cas_document_id) REFERENCES ops_documents(id);
ALTER TABLE public.ops_release ADD CONSTRAINT ops_release_shipment_id_fkey FOREIGN KEY (shipment_id) REFERENCES shipments(id);
ALTER TABLE public.ops_transfers ADD CONSTRAINT ops_transfers_received_by_fkey FOREIGN KEY (received_by) REFERENCES users(id);
ALTER TABLE public.ops_transfers ADD CONSTRAINT ops_transfers_returned_by_fkey FOREIGN KEY (returned_by) REFERENCES users(id);
ALTER TABLE public.ops_transfers ADD CONSTRAINT ops_transfers_shipment_id_fkey FOREIGN KEY (shipment_id) REFERENCES shipments(id);
ALTER TABLE public.ops_transfers ADD CONSTRAINT ops_transfers_transferred_by_fkey FOREIGN KEY (transferred_by) REFERENCES users(id);
ALTER TABLE public.pba_payments ADD CONSTRAINT pba_payments_client_id_fkey FOREIGN KEY (client_id) REFERENCES clients(id);
ALTER TABLE public.pba_payments ADD CONSTRAINT pba_payments_shipment_id_fkey FOREIGN KEY (shipment_id) REFERENCES shipments(id) ON DELETE SET NULL;
ALTER TABLE public.phone_numbers ADD CONSTRAINT phone_numbers_contact_id_fkey FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE CASCADE;
ALTER TABLE public.picking_exceptions ADD CONSTRAINT picking_exceptions_manifest_item_id_fkey FOREIGN KEY (manifest_item_id) REFERENCES manifest_items(id);
ALTER TABLE public.picking_exceptions ADD CONSTRAINT picking_exceptions_picking_task_id_fkey FOREIGN KEY (picking_task_id) REFERENCES picking_tasks(id) ON DELETE CASCADE;
ALTER TABLE public.picking_exceptions ADD CONSTRAINT picking_exceptions_raised_by_fkey FOREIGN KEY (raised_by) REFERENCES warehouse_users(id);
ALTER TABLE public.picking_exceptions ADD CONSTRAINT picking_exceptions_resolved_by_fkey FOREIGN KEY (resolved_by) REFERENCES warehouse_users(id);
ALTER TABLE public.picking_tasks ADD CONSTRAINT picking_tasks_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES warehouse_users(id);
ALTER TABLE public.picking_tasks ADD CONSTRAINT picking_tasks_manifest_source_id_fkey FOREIGN KEY (manifest_source_id) REFERENCES manifest_sources(id) ON DELETE CASCADE;
ALTER TABLE public.picking_tasks ADD CONSTRAINT picking_tasks_parent_split_id_fkey FOREIGN KEY (parent_split_id) REFERENCES picking_tasks(id);
ALTER TABLE public.points_of_receipt ADD CONSTRAINT points_of_receipt_port_id_fkey FOREIGN KEY (port_id) REFERENCES ports(id);
ALTER TABLE public.pricing_rules ADD CONSTRAINT pricing_rules_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES agents(id) ON DELETE CASCADE;
ALTER TABLE public.pricing_rules ADD CONSTRAINT pricing_rules_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES auth.users(id) ON DELETE SET NULL;
ALTER TABLE public.pricing_rules ADD CONSTRAINT pricing_rules_carrier_id_fkey FOREIGN KEY (carrier_id) REFERENCES carriers(id) ON DELETE CASCADE;
ALTER TABLE public.pricing_rules ADD CONSTRAINT pricing_rules_client_id_fkey FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE;
ALTER TABLE public.pricing_rules ADD CONSTRAINT pricing_rules_commodity_id_fkey FOREIGN KEY (commodity_id) REFERENCES commodities(id) ON DELETE CASCADE;
ALTER TABLE public.pricing_rules ADD CONSTRAINT pricing_rules_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL;
ALTER TABLE public.pricing_rules ADD CONSTRAINT pricing_rules_equipment_type_id_fkey FOREIGN KEY (equipment_type_id) REFERENCES equipment_types(id) ON DELETE CASCADE;
ALTER TABLE public.pricing_rules ADD CONSTRAINT pricing_rules_office_id_fkey FOREIGN KEY (office_id) REFERENCES offices(id) ON DELETE CASCADE;
ALTER TABLE public.pricing_rules ADD CONSTRAINT pricing_rules_sales_rep_id_fkey FOREIGN KEY (sales_rep_id) REFERENCES auth.users(id) ON DELETE SET NULL;
ALTER TABLE public.quote_amendments ADD CONSTRAINT quote_amendments_created_by_fkey FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE public.quote_amendments ADD CONSTRAINT quote_amendments_decided_by_fkey FOREIGN KEY (decided_by) REFERENCES users(id);
ALTER TABLE public.quote_amendments ADD CONSTRAINT quote_amendments_quote_id_fkey FOREIGN KEY (quote_id) REFERENCES quotes(id) ON DELETE CASCADE;
ALTER TABLE public.quote_charges ADD CONSTRAINT quote_charges_quote_id_fkey FOREIGN KEY (quote_id) REFERENCES quotes(id);
ALTER TABLE public.quote_charges ADD CONSTRAINT quote_charges_rate_component_id_fkey FOREIGN KEY (rate_component_id) REFERENCES rate_components(id);
ALTER TABLE public.quote_emails ADD CONSTRAINT quote_emails_quote_id_fkey FOREIGN KEY (quote_id) REFERENCES quotes(id) ON DELETE CASCADE;
ALTER TABLE public.quote_followups ADD CONSTRAINT quote_followups_quote_id_fkey FOREIGN KEY (quote_id) REFERENCES quotes(id) ON DELETE CASCADE;
ALTER TABLE public.quote_pba ADD CONSTRAINT quote_pba_quote_id_fkey FOREIGN KEY (quote_id) REFERENCES quotes(id) ON DELETE CASCADE;
ALTER TABLE public.quotes ADD CONSTRAINT quotes_air_carrier_id_fkey FOREIGN KEY (air_carrier_id) REFERENCES air_carriers(id);
ALTER TABLE public.quotes ADD CONSTRAINT quotes_carrier_id_fkey FOREIGN KEY (carrier_id) REFERENCES carriers(id);
ALTER TABLE public.quotes ADD CONSTRAINT quotes_client_id_fkey FOREIGN KEY (client_id) REFERENCES clients(id);
ALTER TABLE public.quotes ADD CONSTRAINT quotes_commodity_id_fkey FOREIGN KEY (commodity_id) REFERENCES commodities(id);
ALTER TABLE public.quotes ADD CONSTRAINT quotes_created_by_fkey FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE public.quotes ADD CONSTRAINT quotes_deal_id_fkey FOREIGN KEY (deal_id) REFERENCES deals(id);
ALTER TABLE public.quotes ADD CONSTRAINT quotes_destination_port_id_fkey FOREIGN KEY (destination_port_id) REFERENCES ports(id);
ALTER TABLE public.quotes ADD CONSTRAINT quotes_equipment_type_id_fkey FOREIGN KEY (equipment_type_id) REFERENCES equipment_types(id);
ALTER TABLE public.quotes ADD CONSTRAINT quotes_origin_port_id_fkey FOREIGN KEY (origin_port_id) REFERENCES ports(id);
ALTER TABLE public.quotes ADD CONSTRAINT quotes_prepared_by_fkey FOREIGN KEY (prepared_by) REFERENCES users(id);
ALTER TABLE public.quotes ADD CONSTRAINT quotes_selected_air_rate_id_fkey FOREIGN KEY (selected_air_rate_id) REFERENCES air_rates(id);
ALTER TABLE public.quotes ADD CONSTRAINT quotes_selected_rate_id_fkey FOREIGN KEY (selected_rate_id) REFERENCES rates(id);
ALTER TABLE public.rate_charges ADD CONSTRAINT rate_charges_rate_id_fkey FOREIGN KEY (rate_id) REFERENCES rates(id);
ALTER TABLE public.rate_notes ADD CONSTRAINT rate_notes_rate_id_fkey FOREIGN KEY (rate_id) REFERENCES rates(id);
ALTER TABLE public.rates ADD CONSTRAINT rates_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES agents(id) ON DELETE SET NULL;
ALTER TABLE public.rates ADD CONSTRAINT rates_commodity_id_fkey FOREIGN KEY (commodity_id) REFERENCES commodities(id);
ALTER TABLE public.rates ADD CONSTRAINT rates_contract_id_fkey FOREIGN KEY (contract_id) REFERENCES contracts(id);
ALTER TABLE public.rates ADD CONSTRAINT rates_equipment_type_id_fkey FOREIGN KEY (equipment_type_id) REFERENCES equipment_types(id);
ALTER TABLE public.rates ADD CONSTRAINT rates_office_id_fkey FOREIGN KEY (office_id) REFERENCES offices(id) ON DELETE SET NULL;
ALTER TABLE public.rates ADD CONSTRAINT rates_route_id_fkey FOREIGN KEY (route_id) REFERENCES freight_routes(id);
ALTER TABLE public.rates ADD CONSTRAINT rates_tariff_sheet_id_fkey FOREIGN KEY (tariff_sheet_id) REFERENCES tariff_sheets(id) ON DELETE SET NULL;
ALTER TABLE public.reminders ADD CONSTRAINT reminders_shipment_id_fkey FOREIGN KEY (shipment_id) REFERENCES shipments(id) ON DELETE SET NULL;
ALTER TABLE public.reminders ADD CONSTRAINT reminders_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE public.rfq_log ADD CONSTRAINT rfq_log_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES agents(id);
ALTER TABLE public.rfq_log ADD CONSTRAINT rfq_log_office_id_fkey FOREIGN KEY (office_id) REFERENCES offices(id);
ALTER TABLE public.role_permissions ADD CONSTRAINT role_permissions_role_id_fkey FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE;
ALTER TABLE public.routes ADD CONSTRAINT routes_client_id_fkey FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE;
ALTER TABLE public.routes ADD CONSTRAINT routes_destination_port_id_fkey FOREIGN KEY (destination_port_id) REFERENCES ports(id);
ALTER TABLE public.routes ADD CONSTRAINT routes_origin_port_id_fkey FOREIGN KEY (origin_port_id) REFERENCES ports(id);
ALTER TABLE public.routes ADD CONSTRAINT routes_protected_by_ff_id_fkey FOREIGN KEY (protected_by_ff_id) REFERENCES clients(id) ON DELETE SET NULL;
ALTER TABLE public.sales_quote_lines ADD CONSTRAINT sales_quote_lines_quote_id_fkey FOREIGN KEY (quote_id) REFERENCES quotes(id) ON DELETE CASCADE;
ALTER TABLE public.sales_quote_lines ADD CONSTRAINT sales_quote_lines_si_id_fkey FOREIGN KEY (si_id) REFERENCES shipping_instructions(id) ON DELETE CASCADE;
ALTER TABLE public.shipment_action_items ADD CONSTRAINT shipment_action_items_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES users(id);
ALTER TABLE public.shipment_action_items ADD CONSTRAINT shipment_action_items_completed_by_fkey FOREIGN KEY (completed_by) REFERENCES users(id);
ALTER TABLE public.shipment_action_items ADD CONSTRAINT shipment_action_items_shipment_id_fkey FOREIGN KEY (shipment_id) REFERENCES shipments(id) ON DELETE CASCADE;
ALTER TABLE public.shipment_agents ADD CONSTRAINT shipment_agents_created_by_fkey FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE public.shipment_agents ADD CONSTRAINT shipment_agents_shipment_id_fkey FOREIGN KEY (shipment_id) REFERENCES shipments(id) ON DELETE CASCADE;
ALTER TABLE public.shipment_containers ADD CONSTRAINT shipment_containers_created_by_fkey FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE public.shipment_containers ADD CONSTRAINT shipment_containers_shipment_id_fkey FOREIGN KEY (shipment_id) REFERENCES shipments(id) ON DELETE CASCADE;
ALTER TABLE public.shipment_containers ADD CONSTRAINT shipment_containers_temperature_validated_by_fkey FOREIGN KEY (temperature_validated_by) REFERENCES users(id);
ALTER TABLE public.shipment_events ADD CONSTRAINT shipment_events_created_by_fkey FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE public.shipment_events ADD CONSTRAINT shipment_events_shipment_id_fkey FOREIGN KEY (shipment_id) REFERENCES shipments(id) ON DELETE CASCADE;
ALTER TABLE public.shipment_shippers ADD CONSTRAINT shipment_shippers_created_by_fkey FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE public.shipment_shippers ADD CONSTRAINT shipment_shippers_shipment_id_fkey FOREIGN KEY (shipment_id) REFERENCES shipments(id) ON DELETE CASCADE;
ALTER TABLE public.shipments ADD CONSTRAINT shipments_archived_by_fkey FOREIGN KEY (archived_by) REFERENCES users(id);
ALTER TABLE public.shipments ADD CONSTRAINT shipments_client_id_fkey FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE RESTRICT;
ALTER TABLE public.shipments ADD CONSTRAINT shipments_consolidado_id_fkey FOREIGN KEY (consolidado_id) REFERENCES consolidados(id);
ALTER TABLE public.shipments ADD CONSTRAINT shipments_created_by_fkey FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE public.shipments ADD CONSTRAINT shipments_cs_assigned_to_fkey FOREIGN KEY (cs_assigned_to) REFERENCES users(id);
ALTER TABLE public.shipments ADD CONSTRAINT shipments_magaya_shipment_id_fkey FOREIGN KEY (magaya_shipment_id) REFERENCES magaya_shipments(id) ON DELETE SET NULL;
ALTER TABLE public.shipments ADD CONSTRAINT shipments_master_shipment_id_fkey FOREIGN KEY (master_shipment_id) REFERENCES shipments(id) ON DELETE SET NULL;
ALTER TABLE public.shipments ADD CONSTRAINT shipments_sales_executive_id_fkey FOREIGN KEY (sales_executive_id) REFERENCES users(id);
ALTER TABLE public.shipping_instructions ADD CONSTRAINT shipping_instructions_client_id_fkey FOREIGN KEY (client_id) REFERENCES clients(id);
ALTER TABLE public.shipping_instructions ADD CONSTRAINT shipping_instructions_confirmed_by_fkey FOREIGN KEY (confirmed_by) REFERENCES users(id);
ALTER TABLE public.shipping_instructions ADD CONSTRAINT shipping_instructions_created_by_fkey FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE public.shipping_instructions ADD CONSTRAINT shipping_instructions_quote_id_fkey FOREIGN KEY (quote_id) REFERENCES quotes(id) ON DELETE SET NULL;
ALTER TABLE public.shipping_instructions ADD CONSTRAINT shipping_instructions_sales_executive_id_fkey FOREIGN KEY (sales_executive_id) REFERENCES users(id);
ALTER TABLE public.shipping_instructions ADD CONSTRAINT shipping_instructions_shipment_id_fkey FOREIGN KEY (shipment_id) REFERENCES shipments(id);
ALTER TABLE public.staging_check_tasks ADD CONSTRAINT staging_check_tasks_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES warehouse_users(id);
ALTER TABLE public.staging_check_tasks ADD CONSTRAINT staging_check_tasks_created_by_fkey FOREIGN KEY (created_by) REFERENCES warehouse_users(id);
ALTER TABLE public.staging_check_tasks ADD CONSTRAINT staging_check_tasks_manifest_source_id_fkey FOREIGN KEY (manifest_source_id) REFERENCES manifest_sources(id) ON DELETE CASCADE;
ALTER TABLE public.staging_exceptions ADD CONSTRAINT staging_exceptions_raised_by_fkey FOREIGN KEY (raised_by) REFERENCES warehouse_users(id);
ALTER TABLE public.staging_exceptions ADD CONSTRAINT staging_exceptions_resolved_by_fkey FOREIGN KEY (resolved_by) REFERENCES warehouse_users(id);
ALTER TABLE public.staging_exceptions ADD CONSTRAINT staging_exceptions_staging_task_id_fkey FOREIGN KEY (staging_task_id) REFERENCES staging_check_tasks(id) ON DELETE CASCADE;
ALTER TABLE public.surcharge_adjustments ADD CONSTRAINT surcharge_adjustments_carrier_id_fkey FOREIGN KEY (carrier_id) REFERENCES carriers(id) ON DELETE CASCADE;
ALTER TABLE public.surcharges ADD CONSTRAINT surcharges_carrier_id_fkey FOREIGN KEY (carrier_id) REFERENCES carriers(id);
ALTER TABLE public.surcharges ADD CONSTRAINT surcharges_equipment_type_id_fkey FOREIGN KEY (equipment_type_id) REFERENCES equipment_types(id);
ALTER TABLE public.tariff_sheets ADD CONSTRAINT tariff_sheets_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES agents(id) ON DELETE SET NULL;
ALTER TABLE public.tariff_sheets ADD CONSTRAINT tariff_sheets_carrier_id_fkey FOREIGN KEY (carrier_id) REFERENCES carriers(id) ON DELETE SET NULL;
ALTER TABLE public.tariff_sheets ADD CONSTRAINT tariff_sheets_contract_id_fkey FOREIGN KEY (contract_id) REFERENCES contracts(id) ON DELETE SET NULL;
ALTER TABLE public.tariff_sheets ADD CONSTRAINT tariff_sheets_office_id_fkey FOREIGN KEY (office_id) REFERENCES offices(id) ON DELETE SET NULL;
ALTER TABLE public.tariff_sheets ADD CONSTRAINT tariff_sheets_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES auth.users(id) ON DELETE SET NULL;
ALTER TABLE public.transit_times ADD CONSTRAINT transit_times_carrier_id_fkey FOREIGN KEY (carrier_id) REFERENCES carriers(id);
ALTER TABLE public.transit_times ADD CONSTRAINT transit_times_destination_port_id_fkey FOREIGN KEY (destination_port_id) REFERENCES ports(id);
ALTER TABLE public.transit_times ADD CONSTRAINT transit_times_origin_port_id_fkey FOREIGN KEY (origin_port_id) REFERENCES ports(id);
ALTER TABLE public.unplanned_additions ADD CONSTRAINT unplanned_additions_authorized_by_fkey FOREIGN KEY (authorized_by) REFERENCES warehouse_users(id);
ALTER TABLE public.unplanned_additions ADD CONSTRAINT unplanned_additions_loading_task_id_fkey FOREIGN KEY (loading_task_id) REFERENCES loading_tasks(id) ON DELETE CASCADE;
ALTER TABLE public.unplanned_additions ADD CONSTRAINT unplanned_additions_raised_by_fkey FOREIGN KEY (raised_by) REFERENCES warehouse_users(id);
ALTER TABLE public.user_delegations ADD CONSTRAINT user_delegations_created_by_fkey FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE public.user_delegations ADD CONSTRAINT user_delegations_owner_user_id_fkey FOREIGN KEY (owner_user_id) REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE public.user_delegations ADD CONSTRAINT user_delegations_viewer_user_id_fkey FOREIGN KEY (viewer_user_id) REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE public.users ADD CONSTRAINT users_auth_user_id_fkey FOREIGN KEY (auth_user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE public.users ADD CONSTRAINT users_role_id_fkey FOREIGN KEY (role_id) REFERENCES roles(id);
ALTER TABLE public.visits ADD CONSTRAINT visits_badge_id_fkey FOREIGN KEY (badge_id) REFERENCES visitor_badges(id) ON DELETE SET NULL;
ALTER TABLE public.visits ADD CONSTRAINT visits_host_tenant_id_fkey FOREIGN KEY (host_tenant_id) REFERENCES reception_hosts(id) ON DELETE SET NULL;
ALTER TABLE public.visits ADD CONSTRAINT visits_host_user_id_fkey FOREIGN KEY (host_user_id) REFERENCES users(id) ON DELETE SET NULL;
ALTER TABLE public.visits ADD CONSTRAINT visits_visitor_id_fkey FOREIGN KEY (visitor_id) REFERENCES visitors(id) ON DELETE SET NULL;
ALTER TABLE public.warehouse_containers ADD CONSTRAINT warehouse_containers_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES clients(id) ON DELETE SET NULL;
ALTER TABLE public.warehouse_tasks ADD CONSTRAINT warehouse_tasks_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES clients(id) ON DELETE SET NULL;
ALTER TABLE public.warehouse_users ADD CONSTRAINT warehouse_users_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE public.warehouse_users ADD CONSTRAINT warehouse_users_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES cl_warehouses(id);
ALTER TABLE public.wh_doc_7512 ADD CONSTRAINT wh_doc_7512_registrado_por_fkey FOREIGN KEY (registrado_por) REFERENCES users(id);
ALTER TABLE public.wh_notices ADD CONSTRAINT wh_notices_client_id_fkey FOREIGN KEY (client_id) REFERENCES clients(id);
ALTER TABLE public.wh_notices ADD CONSTRAINT wh_notices_sent_by_fkey FOREIGN KEY (sent_by) REFERENCES users(id);
ALTER TABLE public.wh_report_movement_items ADD CONSTRAINT wh_report_movement_items_movement_id_fkey FOREIGN KEY (movement_id) REFERENCES wh_report_movements(id) ON DELETE CASCADE;
ALTER TABLE public.wh_report_movement_items ADD CONSTRAINT wh_report_movement_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES wh_report_products(id);
ALTER TABLE public.wh_report_movements ADD CONSTRAINT wh_report_movements_client_id_fkey FOREIGN KEY (client_id) REFERENCES wh_report_clients(id) ON DELETE CASCADE;
ALTER TABLE public.wh_report_movements ADD CONSTRAINT wh_report_movements_magaya_cr_id_fkey FOREIGN KEY (magaya_cr_id) REFERENCES magaya_cargo_releases(id);
ALTER TABLE public.wh_report_movements ADD CONSTRAINT wh_report_movements_magaya_wr_id_fkey FOREIGN KEY (magaya_wr_id) REFERENCES magaya_warehouse_receipts(id);
ALTER TABLE public.wh_report_product_mappings ADD CONSTRAINT wh_report_product_mappings_client_id_fkey FOREIGN KEY (client_id) REFERENCES wh_report_clients(id);
ALTER TABLE public.wh_report_product_mappings ADD CONSTRAINT wh_report_product_mappings_product_id_fkey FOREIGN KEY (product_id) REFERENCES wh_report_products(id);
ALTER TABLE public.wh_report_products ADD CONSTRAINT wh_report_products_client_id_fkey FOREIGN KEY (client_id) REFERENCES wh_report_clients(id) ON DELETE CASCADE;
ALTER TABLE public.wh_report_sync_log ADD CONSTRAINT wh_report_sync_log_client_id_fkey FOREIGN KEY (client_id) REFERENCES wh_report_clients(id);
ALTER TABLE public.wr_match_results ADD CONSTRAINT wr_match_results_matched_client_id_fkey FOREIGN KEY (matched_client_id) REFERENCES clients(id) ON DELETE SET NULL;
ALTER TABLE public.wr_match_results ADD CONSTRAINT wr_match_results_matched_shipment_id_fkey FOREIGN KEY (matched_shipment_id) REFERENCES shipments(id);
ALTER TABLE public.wr_match_results ADD CONSTRAINT wr_match_results_resolved_by_fkey FOREIGN KEY (resolved_by) REFERENCES users(id);
ALTER TABLE public.wr_match_results ADD CONSTRAINT wr_match_results_wr_id_fkey FOREIGN KEY (wr_id) REFERENCES magaya_warehouse_receipts(id) ON DELETE CASCADE;
ALTER TABLE timeclock.employees ADD CONSTRAINT employees_site_id_fkey FOREIGN KEY (site_id) REFERENCES timeclock.sites(id);
ALTER TABLE timeclock.punches ADD CONSTRAINT punches_emp_id_fkey FOREIGN KEY (emp_id) REFERENCES timeclock.employees(id);
