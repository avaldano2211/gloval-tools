-- Jobs de pg_cron (cron.job). Estadísticas de 7 días en el comentario
-- Origen: Supabase GES (wfzdrqfurwnakrfdnbgf), esquemas public, archive, private, timeclock.
-- Extraído del catálogo el 2026-09-29 (solo lectura). Referencia: NO ejecutar en Azure.
-- Credenciales redactadas como <SUPABASE_*>.

-- #2 expire-agent-rates-daily | 0 0 * * * | activo | runs 7d: 7, fallos: 0, prom: 0.02 s
SELECT cron.schedule('expire-agent-rates-daily', '0 0 * * *', $cron$SELECT net.http_post(
    url := 'https://wfzdrqfurwnakrfdnbgf.supabase.co/functions/v1/expire-agent-rates',
    headers := '{"Content-Type": "application/json"}'::jsonb,
    body := '{}'::jsonb
  ) AS request_id;$cron$);

-- #4 magaya-sync-cargo-releases | 0 8,18 * * * | activo | runs 7d: 14, fallos: 0, prom: 0.10 s
SELECT cron.schedule('magaya-sync-cargo-releases', '0 8,18 * * *', $cron$WITH have AS (
  SELECT DISTINCT (cr_number)::int AS n
  FROM magaya_cargo_releases WHERE cr_number ~ '^[0-9]+$'
),
maxn AS (SELECT COALESCE(MAX(n), 0) AS mx FROM have),
holes AS (
  SELECT g AS n
  FROM generate_series((SELECT GREATEST(mx-150,1) FROM maxn), (SELECT mx FROM maxn)) g
  WHERE g NOT IN (SELECT n FROM have)
),
nxt AS (
  SELECT COALESCE((SELECT MIN(n) FROM holes), (SELECT mx+1 FROM maxn), 1) AS s
)
SELECT net.http_post(
  url := 'https://wfzdrqfurwnakrfdnbgf.supabase.co/functions/v1/magaya-incremental-sync',
  headers := jsonb_build_object(
    'Content-Type','application/json',
    'Authorization','Bearer <SUPABASE_ANON_KEY>'
  ),
  body := jsonb_build_object(
    'mode','cr',
    'start',(SELECT s FROM nxt),
    'end', LEAST((SELECT s FROM nxt) + 249, (SELECT mx FROM maxn) + 30)
  ),
  timeout_milliseconds := 280000
) AS request_id;$cron$);

-- #5 magaya-sync-warehouse-receipts | */5 * * * * | activo | runs 7d: 2000, fallos: 0, prom: 0.24 s
SELECT cron.schedule('magaya-sync-warehouse-receipts', '*/5 * * * *', $cron$WITH nxt AS (
    SELECT COALESCE(MAX((wr_number)::bigint), 0) + 1 AS s
    FROM magaya_warehouse_receipts
    WHERE wr_number ~ '^[0-9]+$'
      AND created_on >= CURRENT_DATE - 120
  )
  SELECT net.http_post(
    url := 'https://wfzdrqfurwnakrfdnbgf.supabase.co/functions/v1/magaya-incremental-sync',
    headers := jsonb_build_object(
      'Content-Type','application/json',
      'Authorization','Bearer <SUPABASE_ANON_KEY>'
    ),
    body := jsonb_build_object(
      'mode','wr',
      'start', (SELECT s FROM nxt),
      'end',   (SELECT s FROM nxt) + 29
    )
  ) AS request_id;$cron$);

-- #6 send-birthday-emails-daily | 0 9 * * * | activo | runs 7d: 7, fallos: 0, prom: 0.02 s
SELECT cron.schedule('send-birthday-emails-daily', '0 9 * * *', $cron$SELECT net.http_post(
    url     := 'https://wfzdrqfurwnakrfdnbgf.supabase.co/functions/v1/send-birthday-emails',
    headers := jsonb_build_object(
      'Content-Type','application/json',
      'Authorization','Bearer <SUPABASE_ANON_KEY>'
    ),
    body    := '{}'::jsonb
  ) AS request_id;$cron$);

-- #9 mi-match-and-refresh-daily | 0 9 * * * | activo | runs 7d: 7, fallos: 0, prom: 252.76 s
SELECT cron.schedule('mi-match-and-refresh-daily', '0 9 * * *', $cron$SET statement_timeout = '25min';
SET work_mem = '32MB';
SELECT public.mi_match_clients_to_intel(null, null, null, null, 0.85);$cron$);

-- #10 mi-refresh-mvs-afternoon | 15 23 * * * | activo | runs 7d: 7, fallos: 0, prom: 921.17 s
SELECT cron.schedule('mi-refresh-mvs-afternoon', '15 23 * * *', $cron$SET statement_timeout = '25min';
SET work_mem = '32MB';
SELECT public.mi_refresh_all_mvs();$cron$);

-- #11 smoke-test-sales-exec-create-client | 55 7 * * * | activo | runs 7d: 7, fallos: 0, prom: 0.20 s
SELECT cron.schedule('smoke-test-sales-exec-create-client', '55 7 * * *', $cron$select public.smoke_test_sales_exec_create_client()$cron$);

-- #13 refresh-wh-metrics-am | 45 8 * * * | activo | runs 7d: 7, fallos: 0, prom: 48.55 s
SELECT cron.schedule('refresh-wh-metrics-am', '45 8 * * *', $cron$SET statement_timeout = '10min'; SET work_mem = '32MB'; SELECT refresh_wh_metrics()$cron$);

-- #14 refresh-wh-metrics-pm | 0 23 * * * | activo | runs 7d: 7, fallos: 0, prom: 55.53 s
SELECT cron.schedule('refresh-wh-metrics-pm', '0 23 * * *', $cron$SET statement_timeout = '10min'; SET work_mem = '32MB'; SELECT refresh_wh_metrics()$cron$);

-- #16 weekly-wh-report | 0 9 * * 1 | activo | runs 7d: 1, fallos: 0, prom: 0.05 s
SELECT cron.schedule('weekly-wh-report', '0 9 * * 1', $cron$SELECT net.http_post(
      url     := 'https://wfzdrqfurwnakrfdnbgf.supabase.co/functions/v1/wh-report',
      headers := '{"Content-Type":"application/json","apikey":"<SUPABASE_PUBLISHABLE_KEY>"}'::jsonb,
      body    := '{"grain":"week","periods_ago":1,"recipients":["avaldano@gmail.com","avaldano@glovalgroup.com"]}'::jsonb
  )$cron$);

-- #17 monday-containers-sync-daily | 30 9 * * * | activo | runs 7d: 7, fallos: 0, prom: 0.02 s
SELECT cron.schedule('monday-containers-sync-daily', '30 9 * * *', $cron$SELECT net.http_post(
      url:='https://wfzdrqfurwnakrfdnbgf.supabase.co/functions/v1/monday-containers-sync',
      headers:='{"Content-Type":"application/json"}'::jsonb,
      body:='{"years":["2026"]}'::jsonb)$cron$);

-- #20 monthly-wh-report | 0 10 1 * * | activo | runs 7d: 0, fallos: 0, prom: - s
SELECT cron.schedule('monthly-wh-report', '0 10 1 * *', $cron$SELECT net.http_post(
      url:='https://wfzdrqfurwnakrfdnbgf.supabase.co/functions/v1/wh-report',
      headers:='{"Content-Type":"application/json","apikey":"<SUPABASE_PUBLISHABLE_KEY>"}'::jsonb,
      body:='{"grain":"month","recipients":["avaldano@gmail.com","avaldano@glovalgroup.com"]}'::jsonb)$cron$);

-- #21 weekly-stations-report | 15 9 * * 1 | activo | runs 7d: 1, fallos: 0, prom: 0.01 s
SELECT cron.schedule('weekly-stations-report', '15 9 * * 1', $cron$SELECT net.http_post(
    url:='https://wfzdrqfurwnakrfdnbgf.supabase.co/functions/v1/wh-stations-report',
    headers:='{"Content-Type":"application/json","apikey":"<SUPABASE_PUBLISHABLE_KEY>"}'::jsonb,
    body:='{"recipients":["avaldano@gmail.com","avaldano@glovalgroup.com"]}'::jsonb)$cron$);

-- #22 magaya-usa-ec-daily | 0 8 * * * | activo | runs 7d: 7, fallos: 0, prom: 0.02 s
SELECT cron.schedule('magaya-usa-ec-daily', '0 8 * * *', $cron$select net.http_post(
      url:='https://wfzdrqfurwnakrfdnbgf.supabase.co/functions/v1/magaya-usa-sync',
      headers:=jsonb_build_object(
        'Content-Type','application/json',
        'Authorization','Bearer <SUPABASE_ANON_KEY>'
      ),
      body:=jsonb_build_object('day', to_char(current_date - 1, 'YYYY-MM-DD')),
      timeout_milliseconds:=150000
    )$cron$);

-- #23 monday-external-containers-sync-daily | 35 9 * * * | activo | runs 7d: 7, fallos: 0, prom: 0.01 s
SELECT cron.schedule('monday-external-containers-sync-daily', '35 9 * * *', $cron$SELECT net.http_post(
    url:='https://wfzdrqfurwnakrfdnbgf.supabase.co/functions/v1/monday-external-containers-sync',
    headers:='{"Content-Type":"application/json","Authorization":"Bearer <SUPABASE_ANON_KEY>"}'::jsonb,
    body:='{"years":["2026"]}'::jsonb)$cron$);

-- #24 sales-quotes-expire | 5 10 * * * | activo | runs 7d: 7, fallos: 0, prom: 0.05 s
SELECT cron.schedule('sales-quotes-expire', '5 10 * * *', $cron$update quotes set status = 'EXPIRED'
   where status in ('SENT','PENDING') and sale_total is not null
     and valid_until is not null and valid_until < current_date$cron$);

-- #25 magaya-wr-rescan-daily | 45 9 * * * | activo | runs 7d: 7, fallos: 0, prom: 0.27 s
SELECT cron.schedule('magaya-wr-rescan-daily', '45 9 * * *', $cron$WITH mx AS (
    SELECT COALESCE(MAX((wr_number)::bigint), 0) AS m
    FROM magaya_warehouse_receipts
    WHERE wr_number ~ '^[0-9]+$' AND created_on >= CURRENT_DATE - 120
  )
  SELECT net.http_post(
    url := 'https://wfzdrqfurwnakrfdnbgf.supabase.co/functions/v1/magaya-incremental-sync',
    headers := jsonb_build_object(
      'Content-Type','application/json',
      'Authorization','Bearer <SUPABASE_ANON_KEY>'
    ),
    body := jsonb_build_object('mode','wr','start', GREATEST(m - 999, 1), 'end', m - 500)
  ) FROM mx$cron$);

-- #26 sales-quote-followups-daily | 15 13 * * * | activo | runs 7d: 7, fallos: 0, prom: 0.01 s
SELECT cron.schedule('sales-quote-followups-daily', '15 13 * * *', $cron$select net.http_post(
    url := 'https://wfzdrqfurwnakrfdnbgf.supabase.co/functions/v1/sales-quote-followups',
    headers := jsonb_build_object(
      'Content-Type','application/json',
      'Authorization','Bearer <SUPABASE_ANON_KEY>'
    ),
    body := '{}'::jsonb
  );$cron$);

-- #27 fx-rates-banco-pacifico | 30 12,15 * * * | activo | runs 7d: 14, fallos: 0, prom: 0.01 s
SELECT cron.schedule('fx-rates-banco-pacifico', '30 12,15 * * *', $cron$select net.http_post(
    url := 'https://wfzdrqfurwnakrfdnbgf.supabase.co/functions/v1/fx-rates-sync',
    headers := jsonb_build_object(
      'Content-Type','application/json',
      'Authorization','Bearer <SUPABASE_ANON_KEY>'
    ),
    body := '{}'::jsonb
  );$cron$);

-- #28 sync-health-alert-daily | 0 13 * * * | activo | runs 7d: 7, fallos: 0, prom: 0.02 s
SELECT cron.schedule('sync-health-alert-daily', '0 13 * * *', $cron$SELECT net.http_post(
  url := 'https://wfzdrqfurwnakrfdnbgf.supabase.co/functions/v1/sync-health-alert',
  headers := jsonb_build_object(
    'Content-Type','application/json',
    'Authorization','Bearer <SUPABASE_ANON_KEY>'
  ),
  body := '{}'::jsonb,
  timeout_milliseconds := 30000
);$cron$);

-- #29 ops-eta-notify-daily | 30 13 * * * | INACTIVO | runs 7d: 0, fallos: 0, prom: - s
SELECT cron.schedule('ops-eta-notify-daily', '30 13 * * *', $cron$select net.http_post(
    url := 'https://wfzdrqfurwnakrfdnbgf.supabase.co/functions/v1/ops-eta-notify',
    headers := jsonb_build_object(
      'Content-Type','application/json',
      'Authorization','Bearer <SUPABASE_ANON_KEY>'
    ),
    body := '{}'::jsonb,
    timeout_milliseconds := 60000
  );$cron$);

-- #30 wh-notice-builder-scan | */4 * * * * | activo | runs 7d: 2492, fallos: 0, prom: 0.01 s
SELECT cron.schedule('wh-notice-builder-scan', '*/4 * * * *', $cron$select net.http_post(
    url := 'https://wfzdrqfurwnakrfdnbgf.supabase.co/functions/v1/wh-notice-scan-worker',
    headers := jsonb_build_object('Content-Type','application/json','Authorization','Bearer <SUPABASE_ANON_KEY>'),
    body := '{"limit": 8, "hours": 168}'::jsonb,
    timeout_milliseconds := 170000
  );$cron$);

-- #32 wh-storage-alert-daily | 30 13 * * 1-5 | activo | runs 7d: 5, fallos: 0, prom: 0.03 s
SELECT cron.schedule('wh-storage-alert-daily', '30 13 * * 1-5', $cron$select net.http_post(
    url := 'https://wfzdrqfurwnakrfdnbgf.supabase.co/functions/v1/wh-storage-alert',
    headers := jsonb_build_object('Content-Type','application/json','Authorization','Bearer <SUPABASE_ANON_KEY>'),
    body := '{"min_dias": 23, "refresh": 0}'::jsonb,
    timeout_milliseconds := 150000
  );$cron$);

-- #33 wh-onhand-verify-critico | */3 * * * * | activo | runs 7d: 3330, fallos: 0, prom: 0.01 s
SELECT cron.schedule('wh-onhand-verify-critico', '*/3 * * * *', $cron$select net.http_post(
    url := 'https://wfzdrqfurwnakrfdnbgf.supabase.co/functions/v1/wh-onhand-verify',
    headers := jsonb_build_object('Content-Type','application/json','Authorization','Bearer <SUPABASE_ANON_KEY>'),
    body := '{"limit": 45, "concurrency": 3, "min_dias": 12, "max_dias": 45}'::jsonb,
    timeout_milliseconds := 150000
  );$cron$);

-- #34 wh-onhand-verify-resto | 7,22,37,52 * * * * | activo | runs 7d: 665, fallos: 0, prom: 0.01 s
SELECT cron.schedule('wh-onhand-verify-resto', '7,22,37,52 * * * *', $cron$select net.http_post(
    url := 'https://wfzdrqfurwnakrfdnbgf.supabase.co/functions/v1/wh-onhand-verify',
    headers := jsonb_build_object('Content-Type','application/json','Authorization','Bearer <SUPABASE_ANON_KEY>'),
    body := '{"limit": 45, "concurrency": 3, "min_dias": 46, "max_dias": 150}'::jsonb,
    timeout_milliseconds := 150000
  );$cron$);

-- #35 ops-email-capture-loop | */20 * * * * | activo | runs 7d: 497, fallos: 0, prom: 0.02 s
SELECT cron.schedule('ops-email-capture-loop', '*/20 * * * *', $cron$select net.http_post(
    url := 'https://wfzdrqfurwnakrfdnbgf.supabase.co/functions/v1/ops-email-capture',
    headers := jsonb_build_object('Content-Type','application/json','Authorization','Bearer <SUPABASE_ANON_KEY>'),
    body := '{"hours": 6, "limit_por_buzon": 25}'::jsonb,
    timeout_milliseconds := 150000
  );$cron$);

-- #36 wr-enrich-frescos | 1-59/5 * * * * | activo | runs 7d: 1995, fallos: 0, prom: 0.01 s
SELECT cron.schedule('wr-enrich-frescos', '1-59/5 * * * *', $cron$select net.http_post(
    url := 'https://wfzdrqfurwnakrfdnbgf.supabase.co/functions/v1/wh-onhand-verify',
    headers := jsonb_build_object('Content-Type','application/json','Authorization','Bearer <SUPABASE_ANON_KEY>'),
    body := '{"limit": 30, "concurrency": 3, "min_dias": 0, "max_dias": 11, "statuses": ["OnHand", ""]}'::jsonb,
    timeout_milliseconds := 150000
  );$cron$);

-- #37 consolidado-refresh-abierto | 9,24,39,54 * * * * | activo | runs 7d: 665, fallos: 0, prom: 19.62 s
SELECT cron.schedule('consolidado-refresh-abierto', '9,24,39,54 * * * *', $cron$select public.consolidado_refresh_abierto();$cron$);

-- #38 wr-refetch-recien-creados | 3-59/10 * * * * | activo | runs 7d: 1001, fallos: 0, prom: 0.01 s
SELECT cron.schedule('wr-refetch-recien-creados', '3-59/10 * * * *', $cron$select net.http_post(
    url := 'https://wfzdrqfurwnakrfdnbgf.supabase.co/functions/v1/wh-onhand-verify',
    headers := jsonb_build_object('Content-Type','application/json','Authorization','Bearer <SUPABASE_ANON_KEY>'),
    body := '{"limit": 40, "concurrency": 4, "min_dias": 0, "max_dias": 2, "statuses": ["OnHand", ""], "reintento_horas": 4}'::jsonb,
    timeout_milliseconds := 150000
  );$cron$);

-- #39 wh-no-identificada-registro | 13,43 * * * * | activo | runs 7d: 336, fallos: 0, prom: 49.79 s
SELECT cron.schedule('wh-no-identificada-registro', '13,43 * * * *', $cron$select public.wh_registrar_no_identificada();$cron$);

-- #40 wr-att-backfill-drain | */2 * * * * | activo | runs 7d: 4989, fallos: 0, prom: 0.01 s
SELECT cron.schedule('wr-att-backfill-drain', '*/2 * * * *', $cron$select net.http_post(
      url := 'https://wfzdrqfurwnakrfdnbgf.supabase.co/functions/v1/wr-att-backfill-worker',
      headers := jsonb_build_object('Content-Type','application/json',
        'Authorization','Bearer <SUPABASE_ANON_KEY>'),
      body := '{"limit":20}'::jsonb,
      timeout_milliseconds := 150000)$cron$);

-- #41 wh-notice-refresh-attachments | */5 * * * * | activo | runs 7d: 2000, fallos: 0, prom: 0.01 s
SELECT cron.schedule('wh-notice-refresh-attachments', '*/5 * * * *', $cron$select net.http_post(
    url := 'https://wfzdrqfurwnakrfdnbgf.supabase.co/functions/v1/wh-notice-builder',
    headers := jsonb_build_object('Content-Type','application/json','Authorization','Bearer <SUPABASE_ANON_KEY>'),
    body := '{"refresh": true, "limit": 25, "hours": 24}'::jsonb,
    timeout_milliseconds := 170000
  );$cron$);

-- #42 wh-saldo-backfill | */2 * * * * | activo | runs 7d: 4989, fallos: 0, prom: 0.01 s
SELECT cron.schedule('wh-saldo-backfill', '*/2 * * * *', $cron$select net.http_post(
    url := 'https://wfzdrqfurwnakrfdnbgf.supabase.co/functions/v1/wh-saldo-backfill-worker',
    headers := jsonb_build_object('Content-Type','application/json','Authorization','Bearer <SUPABASE_ANON_KEY>'),
    body := '{"limit": 25}'::jsonb,
    timeout_milliseconds := 170000
  );$cron$);

-- #44 seaboard-advisory-watch | 15 8 * * * | activo | runs 7d: 7, fallos: 0, prom: 0.02 s
SELECT cron.schedule('seaboard-advisory-watch', '15 8 * * *', $cron$select net.http_post(
    url := 'https://wfzdrqfurwnakrfdnbgf.supabase.co/functions/v1/seaboard-advisory-watch',
    headers := jsonb_build_object('Content-Type','application/json',
      'Authorization', (select substring(command from 'Bearer [A-Za-z0-9._-]+') from cron.job where jobid = 36)),
    body := '{}'::jsonb
  );$cron$);

-- #45 wh-saldo-reencolar | 20 7 * * * | activo | runs 7d: 7, fallos: 0, prom: 0.97 s
SELECT cron.schedule('wh-saldo-reencolar', '20 7 * * *', $cron$with candidatos as (
    -- a) Lo que tiene saldo en bodega y su detalle está viejo.
    select s.wr_number
    from public.v_wh_wr_saldo s
    where s.tiene_saldo is true
      and (s.items_frescos_al is null or s.items_frescos_al < now() - interval '3 days')

    union

    -- b) Lo que está en bodega y nunca se le pidió el detalle.
    select s.wr_number
    from public.v_wh_wr_saldo s
    where s.estado_saldo = 'SIN_DETALLE' and s.status_cabecera = 'OnHand'

    union

    -- c) NUEVO: todo lo que está en un consolidado vivo, sin mirar la cabecera.
    --    Es el que se embarca rápido y se perdía. De estos necesitamos saber
    --    qué piezas se cargaron, que es justo lo que la cabecera no dice.
    select l.wr_number
    from public.consolidado_lineas l
    join public.consolidados c on c.id = l.consolidado_id
    left join public.v_wh_wr_saldo s on s.wr_number = l.wr_number
    where c.estado <> 'ANULADO'
      and c.etd >= current_date - 60          -- semanas recientes, no el archivo
      and l.estado in ('DISPONIBLE','AVISADO','INSTRUIDO','EMBARCADO')
      and (s.items_con_estado is null or s.items_con_estado = 0
           or s.items_frescos_al is null
           or s.items_frescos_al < now() - interval '3 days')
  )
  insert into public.wr_saldo_queue (wr_number, prioridad, intentos, ultimo_intento_at, resuelto_at, error)
  select wr_number, 1, 0, null, null, null from candidatos
  on conflict (wr_number) do update
    set intentos = 0, ultimo_intento_at = null, resuelto_at = null, error = null, prioridad = 1;$cron$);

-- #46 wh-notice-refresh-cola-larga | 15,45 * * * * | activo | runs 7d: 336, fallos: 0, prom: 0.01 s
SELECT cron.schedule('wh-notice-refresh-cola-larga', '15,45 * * * *', $cron$select net.http_post(
    url := 'https://wfzdrqfurwnakrfdnbgf.supabase.co/functions/v1/wh-notice-builder',
    headers := jsonb_build_object('Content-Type','application/json','Authorization','Bearer <SUPABASE_ANON_KEY>'),
    body := '{"refresh": true, "limit": 25, "hours": 240}'::jsonb,
    timeout_milliseconds := 170000
  );$cron$);

-- #47 wh-notice-rebody | */10 * * * * | activo | runs 7d: 999, fallos: 0, prom: 0.01 s
SELECT cron.schedule('wh-notice-rebody', '*/10 * * * *', $cron$select net.http_post(
    url := 'https://wfzdrqfurwnakrfdnbgf.supabase.co/functions/v1/wh-notice-builder',
    headers := jsonb_build_object(
      'Content-Type','application/json',
      'Authorization','Bearer <SUPABASE_ANON_KEY>'),
    body := jsonb_build_object('rebody', true, 'limit', 60),
    timeout_milliseconds := 120000);$cron$);

-- #49 purge-cron-history | 10 6 * * 0 | activo | runs 7d: 1, fallos: 0, prom: 1.96 s
SELECT cron.schedule('purge-cron-history', '10 6 * * 0', $cron$delete from cron.job_run_details where end_time < now() - interval '30 days'$cron$);

-- #51 wh-recientes-refresco-completo | 3,33 * * * * | activo | runs 7d: 336, fallos: 0, prom: 0.26 s
SELECT cron.schedule('wh-recientes-refresco-completo', '3,33 * * * *', $cron$insert into public.wr_saldo_queue (wr_number, prioridad, intentos, ultimo_intento_at, resuelto_at, error)
  select w.wr_number, 1, 0, null, null, null
  from public.magaya_warehouse_receipts w
  where coalesce(w.entry_date, w.created_on) >= current_date - 3
    and coalesce(w.consignee, '') !~* '^\s*([a-z]{1,2}[\s.]+)?gloval'
    and (
      -- peso aún sin registrar: reintento agresivo (cada corrida)
      coalesce(w.weight, 0) = 0
      -- o fetch viejo: el recibo reciente se refresca completo cada ~4 h
      or coalesce(w.last_full_fetch_at, 'epoch') < now() - interval '4 hours'
    )
    and not exists (
      select 1 from public.wr_saldo_queue q
      where q.wr_number = w.wr_number and q.resuelto_at is null
    )
  on conflict (wr_number) do update
    set intentos = 0, ultimo_intento_at = null, resuelto_at = null, error = null, prioridad = 1;$cron$);

-- #52 finanzas-refresh-mv-unified | */10 5-23 * * * | activo | runs 7d: 789, fallos: 0, prom: 11.79 s
SELECT cron.schedule('finanzas-refresh-mv-unified', '*/10 5-23 * * *', $cron$select finanzas_refresh_mv_unified()$cron$);

-- #53 finanzas-refresh-mv-arap | */10 * * * * | activo | runs 7d: 999, fallos: 0, prom: 3.65 s
SELECT cron.schedule('finanzas-refresh-mv-arap', '*/10 * * * *', $cron$select finanzas_refresh_mv_arap()$cron$);

-- #54 finanzas-matching-diario | 30 11 * * * | activo | runs 7d: 7, fallos: 0, prom: 0.28 s
SELECT cron.schedule('finanzas-matching-diario', '30 11 * * *', $cron$select finanzas_run_bank_matching(o) from unnest(array['ECU','USA','PAN','PER']) o$cron$);

-- #57 finanzas-refresh-mv-docs | 5-59/10 * * * * | activo | runs 7d: 1001, fallos: 0, prom: 0.98 s
SELECT cron.schedule('finanzas-refresh-mv-docs', '5-59/10 * * * *', $cron$select refresh_mv_finanzas_docs_abiertos()$cron$);

-- #59 consolidado-refresco-magaya-instruidas | */15 * * * * | activo | runs 7d: 670, fallos: 0, prom: 0.05 s
SELECT cron.schedule('consolidado-refresco-magaya-instruidas', '*/15 * * * *', $cron$insert into public.wr_saldo_queue (wr_number, prioridad, intentos, ultimo_intento_at, resuelto_at, error)
  select distinct l.wr_number, 0, 0, null::timestamptz, null::timestamptz, null::text
  from public.consolidado_lineas l
  join public.consolidados c on c.id = l.consolidado_id
  join public.magaya_warehouse_receipts w on w.wr_number = l.wr_number
  where c.estado in ('ABIERTO', 'CERRADO')
    and l.estado in ('INSTRUIDO', 'APROBADO')
    and coalesce(w.last_full_fetch_at, 'epoch') < now() - interval '30 minutes'
    and not exists (select 1 from public.wr_saldo_queue q
                     where q.wr_number = l.wr_number and q.resuelto_at is null)
  on conflict (wr_number) do update
    set intentos = 0, ultimo_intento_at = null, resuelto_at = null, error = null, prioridad = 0;$cron$);

-- #62 magaya-wr-rellenar-huecos | 7,27,47 * * * * | activo | runs 7d: 497, fallos: 0, prom: 0.33 s
SELECT cron.schedule('magaya-wr-rellenar-huecos', '7,27,47 * * * *', $cron$select public.magaya_wr_encolar_huecos();$cron$);

-- #63 magaya-wr-rescan-daily-b | 55 9 * * * | activo | runs 7d: 7, fallos: 0, prom: 0.26 s
SELECT cron.schedule('magaya-wr-rescan-daily-b', '55 9 * * *', $cron$WITH mx AS (
    SELECT COALESCE(MAX((wr_number)::bigint), 0) AS m
    FROM magaya_warehouse_receipts
    WHERE wr_number ~ '^[0-9]+$' AND created_on >= CURRENT_DATE - 120
  )
  
  SELECT net.http_post(
    url := 'https://wfzdrqfurwnakrfdnbgf.supabase.co/functions/v1/magaya-incremental-sync',
    headers := jsonb_build_object(
      'Content-Type','application/json',
      'Authorization','Bearer <SUPABASE_ANON_KEY>'
    ),
    body := jsonb_build_object('mode','wr','start', m - 499, 'end', m)
  ) FROM mx$cron$);

-- #65 consolidado-avisos-autoregenerar | 12,27,42,57 * * * * | activo | runs 7d: 665, fallos: 0, prom: 0.02 s
SELECT cron.schedule('consolidado-avisos-autoregenerar', '12,27,42,57 * * * *', $cron$select public.consolidado_regenerar_avisos_si_cambio();$cron$);

-- #66 consolidado-sync-magaya-confirmadas | 7,22,37,52 * * * * | activo | runs 7d: 665, fallos: 0, prom: 0.04 s
SELECT cron.schedule('consolidado-sync-magaya-confirmadas', '7,22,37,52 * * * *', $cron$select public.consolidado_sync_magaya_confirmadas();$cron$);

-- #67 mi-refresh-forwarder-detail | 45 23 * * * | activo | runs 7d: 1, fallos: 0, prom: 91.64 s
SELECT cron.schedule('mi-refresh-forwarder-detail', '45 23 * * *', $cron$SET statement_timeout = '25min'; SET work_mem = '64MB'; SELECT public.mi_refresh_forwarder_detail();$cron$);
