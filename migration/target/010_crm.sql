-- 010 · CRM y ventas: tablas e índices
-- Generado por migration/tools/to_tsql.mjs desde el catálogo de Supabase (2026-09-29). No editar a mano:
-- cambiar el generador y volver a correrlo. Idempotente: se puede ejecutar varias veces.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- public.activity_logs | ~18 filas
IF OBJECT_ID(N'[dbo].[activity_logs]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[activity_logs] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_activity_logs_id] DEFAULT (NEWSEQUENTIALID()),
  [time_entry_id] UNIQUEIDENTIFIER NOT NULL,
  [user_id] UNIQUEIDENTIFIER NOT NULL,
  [timestamp] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_activity_logs_timestamp] DEFAULT (SYSDATETIMEOFFSET()),
  [is_active] BIT NOT NULL CONSTRAINT [DF_activity_logs_is_active] DEFAULT (1),
  [activity_type] NVARCHAR(MAX) NOT NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_activity_logs_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [activity_logs_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [activity_logs_activity_type_check] CHECK (([activity_type]  IN (N'mouse', N'keyboard', N'click', N'idle', N'active')))
);
END
GO

-- public.call_logs | ~206 filas
IF OBJECT_ID(N'[dbo].[call_logs]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[call_logs] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_call_logs_id] DEFAULT (NEWSEQUENTIALID()),
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_call_logs_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [call_id] NVARCHAR(MAX) NULL,
  [caller_phone] NVARCHAR(MAX) NULL,
  [call_duration_seconds] INT NULL,
  [call_status] NVARCHAR(MAX) NULL,
  [intent] NVARCHAR(MAX) NULL,
  [transcript] NVARCHAR(MAX) NULL,
  [summary] NVARCHAR(MAX) NULL,
  [caller_name] NVARCHAR(MAX) NULL,
  [caller_company] NVARCHAR(MAX) NULL,
  [caller_email] NVARCHAR(MAX) NULL,
  [cargo_type] NVARCHAR(MAX) NULL,
  [appointment_requested] BIT NULL CONSTRAINT [DF_call_logs_appointment_requested] DEFAULT (0),
  [appointment_datetime] NVARCHAR(MAX) NULL,
  [is_lead] BIT NULL CONSTRAINT [DF_call_logs_is_lead] DEFAULT (0),
  [office] NVARCHAR(MAX) NULL CONSTRAINT [DF_call_logs_office] DEFAULT (N'USA'),
  [handled_by] NVARCHAR(MAX) NULL CONSTRAINT [DF_call_logs_handled_by] DEFAULT (N'Aria'),
  [appointment_date] NVARCHAR(MAX) NULL,
  [appointment_time] NVARCHAR(MAX) NULL,
  CONSTRAINT [call_logs_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.client_notify_contacts | ~777 filas
IF OBJECT_ID(N'[dbo].[client_notify_contacts]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[client_notify_contacts] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_client_notify_contacts_id] DEFAULT (NEWSEQUENTIALID()),
  [client_id] UNIQUEIDENTIFIER NULL,
  [consignee_hint] NVARCHAR(255) NULL,
  [fwd_hint] NVARCHAR(MAX) NULL,
  [email] NVARCHAR(100) NOT NULL,
  [role] NVARCHAR(50) NOT NULL CONSTRAINT [DF_client_notify_contacts_role] DEFAULT (N'TO'),
  [source] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_client_notify_contacts_source] DEFAULT (N'MINED'),
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_client_notify_contacts_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [cs_email] NVARCHAR(MAX) NULL,
  CONSTRAINT [client_notify_contacts_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [client_notify_contacts_role_check] CHECK (([role]  IN (N'TO', N'CC', N'CC_INTERNO'))),
  CONSTRAINT [client_notify_contacts_source_check] CHECK (([source]  IN (N'MINED', N'MANUAL', N'MINADO_DOMINIO')))
);
END
GO

-- public.client_visits | ~260 filas
IF OBJECT_ID(N'[dbo].[client_visits]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[client_visits] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_client_visits_id] DEFAULT (NEWSEQUENTIALID()),
  [client_id] UNIQUEIDENTIFIER NOT NULL,
  [executive_id] UNIQUEIDENTIFIER NOT NULL,
  [office] NVARCHAR(50) NULL,
  [scheduled_at] DATETIMEOFFSET NOT NULL,
  [status] NVARCHAR(50) NOT NULL CONSTRAINT [DF_client_visits_status] DEFAULT (N'scheduled'),
  [visit_type] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_client_visits_visit_type] DEFAULT (N'presencial'),
  [purpose] NVARCHAR(MAX) NULL,
  [location_address] NVARCHAR(MAX) NULL,
  [completed_at] DATETIMEOFFSET NULL,
  [outcome] NVARCHAR(MAX) NULL,
  [report_notes] NVARCHAR(MAX) NULL,
  [follow_up_required] BIT NOT NULL CONSTRAINT [DF_client_visits_follow_up_required] DEFAULT (0),
  [follow_up_date] DATE NULL,
  [created_by] UNIQUEIDENTIFIER NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_client_visits_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_client_visits_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [client_visits_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [client_visits_outcome_check] CHECK ((([outcome] IS NULL) OR ([outcome]  IN (N'positiva', N'neutral', N'negativa', N'reagendar')))),
  CONSTRAINT [client_visits_status_check] CHECK (([status]  IN (N'scheduled', N'completed', N'cancelled', N'no_show'))),
  CONSTRAINT [client_visits_visit_type_check] CHECK (([visit_type]  IN (N'presencial', N'virtual')))
);
END
GO

-- public.clients | ~1,895 filas
IF OBJECT_ID(N'[dbo].[clients]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[clients] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_clients_id] DEFAULT (NEWSEQUENTIALID()),
  [company_name] NVARCHAR(MAX) NOT NULL,
  [client_type] NVARCHAR(MAX) NOT NULL,
  [parent_ff_id] UNIQUEIDENTIFIER NULL,
  [industries] NVARCHAR(MAX) NULL CONSTRAINT [DF_clients_industries] DEFAULT (N'[]'),
  [office] NVARCHAR(50) NOT NULL,
  [assigned_to] UNIQUEIDENTIFIER NULL,
  [status] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_clients_status] DEFAULT (N'Prospect'),
  [credit_term] NVARCHAR(MAX) NULL,
  [credit_line_amount] DECIMAL(12,2) NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_clients_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [ruc] NVARCHAR(50) NULL,
  [has_credit_approved] BIT NULL CONSTRAINT [DF_clients_has_credit_approved] DEFAULT (0),
  [credit_limit] DECIMAL(12,2) NULL,
  [credit_terms] NVARCHAR(MAX) NULL,
  [credit_approved_date] DATE NULL,
  [credit_approved_by] NVARCHAR(MAX) NULL,
  [current_competitor] NVARCHAR(MAX) NULL,
  [competitor_notes] NVARCHAR(MAX) NULL,
  [switching_reason] NVARCHAR(MAX) NULL,
  [uses_coload] BIT NULL CONSTRAINT [DF_clients_uses_coload] DEFAULT (0),
  [coload_routes] NVARCHAR(MAX) NULL,
  [coload_partner] NVARCHAR(MAX) NULL,
  [created_by] UNIQUEIDENTIFIER NULL,
  [address_line1] NVARCHAR(MAX) NULL,
  [address_line2] NVARCHAR(MAX) NULL,
  [city] NVARCHAR(MAX) NULL,
  [state] NVARCHAR(MAX) NULL,
  [zip_code] NVARCHAR(MAX) NULL,
  [country] NVARCHAR(MAX) NULL,
  [latitude] DECIMAL(10,8) NULL,
  [longitude] DECIMAL(11,8) NULL,
  [google_place_id] NVARCHAR(MAX) NULL,
  [formatted_address] NVARCHAR(MAX) NULL,
  [is_direct] BIT NULL CONSTRAINT [DF_clients_is_direct] DEFAULT (0),
  [is_house_account] BIT NULL CONSTRAINT [DF_clients_is_house_account] DEFAULT (0),
  [account_manager_id] UNIQUEIDENTIFIER NULL,
  [credit_status] NVARCHAR(MAX) NULL CONSTRAINT [DF_clients_credit_status] DEFAULT (N'no_credit'),
  [credit_days] INT NULL CONSTRAINT [DF_clients_credit_days] DEFAULT (0),
  [credit_approved_at] DATETIMEOFFSET NULL,
  [company_name_normalized] NVARCHAR(MAX) NULL,
  [customer_service_id] UNIQUEIDENTIFIER NULL,
  [deleted_at] DATETIMEOFFSET NULL,
  [deleted_by] UNIQUEIDENTIFIER NULL,
  [confianza_credit_amount] DECIMAL(38,10) NULL,
  [handles_postdated_checks] BIT NULL,
  CONSTRAINT [clients_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [clients_client_type_check] CHECK (([client_type]  IN (N'direct_client', N'freight_forwarder', N'ff_customer', N'prospect'))),
  CONSTRAINT [clients_credit_term_check] CHECK (([credit_term]  IN (N'net', N'15_days', N'30_days', N'45_days'))),
  CONSTRAINT [clients_office_check] CHECK (([office]  IN (N'USA', N'Panama', N'Ecuador', N'Peru'))),
  CONSTRAINT [clients_status_check] CHECK (([status]  IN (N'Active', N'Inactive', N'Prospect'))),
  CONSTRAINT [CK_clients_industries_json] CHECK (ISJSON([industries]) = 1),
  CONSTRAINT [CK_clients_coload_routes_json] CHECK (ISJSON([coload_routes]) = 1)
);
END
GO

-- public.contacts | ~1,308 filas
IF OBJECT_ID(N'[dbo].[contacts]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[contacts] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_contacts_id] DEFAULT (NEWSEQUENTIALID()),
  [client_id] UNIQUEIDENTIFIER NOT NULL,
  [full_name] NVARCHAR(MAX) NOT NULL,
  [email] NVARCHAR(MAX) NULL,
  [position] NVARCHAR(MAX) NULL,
  [is_primary] BIT NULL CONSTRAINT [DF_contacts_is_primary] DEFAULT (0),
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_contacts_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [phone2] NVARCHAR(MAX) NULL,
  [phone3] NVARCHAR(MAX) NULL,
  [birthday] DATE NULL,
  CONSTRAINT [contacts_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.credit_documents | ~296 filas
IF OBJECT_ID(N'[dbo].[credit_documents]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[credit_documents] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_credit_documents_id] DEFAULT (NEWSEQUENTIALID()),
  [credit_request_id] UNIQUEIDENTIFIER NOT NULL,
  [document_type] NVARCHAR(MAX) NOT NULL,
  [file_name] NVARCHAR(MAX) NOT NULL,
  [file_url] NVARCHAR(MAX) NOT NULL,
  [file_size] INT NULL,
  [uploaded_by] UNIQUEIDENTIFIER NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_credit_documents_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [credit_documents_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.credit_notify_finance | ~16 filas
IF OBJECT_ID(N'[dbo].[credit_notify_finance]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[credit_notify_finance] (
  [office] NVARCHAR(50) NOT NULL,
  [email] NVARCHAR(100) NOT NULL,
  [name] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_credit_notify_finance_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [credit_notify_finance_pkey] PRIMARY KEY ([office], [email])
);
END
GO

-- public.credit_notify_log | ~2 filas
IF OBJECT_ID(N'[dbo].[credit_notify_log]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[credit_notify_log] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_credit_notify_log_id] DEFAULT (NEWSEQUENTIALID()),
  [credit_request_id] UNIQUEIDENTIFIER NULL,
  [client_id] UNIQUEIDENTIFIER NULL,
  [sent_to] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_credit_notify_log_sent_to] DEFAULT (N'[]'),
  [cc] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_credit_notify_log_cc] DEFAULT (N'[]'),
  [subject] NVARCHAR(MAX) NULL,
  [status] NVARCHAR(MAX) NOT NULL,
  [error] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_credit_notify_log_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [credit_notify_log_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [CK_credit_notify_log_sent_to_json] CHECK (ISJSON([sent_to]) = 1),
  CONSTRAINT [CK_credit_notify_log_cc_json] CHECK (ISJSON([cc]) = 1)
);
END
GO

-- public.credit_requests | ~112 filas
IF OBJECT_ID(N'[dbo].[credit_requests]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[credit_requests] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_credit_requests_id] DEFAULT (NEWSEQUENTIALID()),
  [client_id] UNIQUEIDENTIFIER NOT NULL,
  [requested_amount] DECIMAL(38,10) NOT NULL,
  [requested_days] INT NOT NULL,
  [currency] NVARCHAR(MAX) NULL CONSTRAINT [DF_credit_requests_currency] DEFAULT (N'USD'),
  [executive_notes] NVARCHAR(MAX) NULL,
  [status] NVARCHAR(50) NOT NULL CONSTRAINT [DF_credit_requests_status] DEFAULT (N'pending'),
  [approved_amount] DECIMAL(38,10) NULL,
  [approved_days] INT NULL,
  [admin_notes] NVARCHAR(MAX) NULL,
  [reviewed_by] UNIQUEIDENTIFIER NULL,
  [reviewed_at] DATETIMEOFFSET NULL,
  [requested_by] UNIQUEIDENTIFIER NOT NULL,
  [office] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_credit_requests_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_credit_requests_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [credit_requests_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.cs_assignments | ~11 filas
IF OBJECT_ID(N'[dbo].[cs_assignments]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[cs_assignments] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_cs_assignments_id] DEFAULT (NEWSEQUENTIALID()),
  [cs_user_id] UNIQUEIDENTIFIER NOT NULL,
  [sales_executive_id] UNIQUEIDENTIFIER NULL,
  [is_primary] BIT NULL CONSTRAINT [DF_cs_assignments_is_primary] DEFAULT (0),
  [active] BIT NULL CONSTRAINT [DF_cs_assignments_active] DEFAULT (1),
  [created_by] UNIQUEIDENTIFIER NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_cs_assignments_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [is_directos] BIT NOT NULL CONSTRAINT [DF_cs_assignments_is_directos] DEFAULT (0),
  [full_cartera] BIT NOT NULL CONSTRAINT [DF_cs_assignments_full_cartera] DEFAULT (0),
  CONSTRAINT [cs_assignments_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [cs_assignments_exec_or_directos] CHECK ((([sales_executive_id] IS NOT NULL) OR ([is_directos] = 1)))
);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'cs_assignments_cs_user_id_sales_executive_id_key' AND object_id = OBJECT_ID(N'[dbo].[cs_assignments]'))
CREATE UNIQUE INDEX [cs_assignments_cs_user_id_sales_executive_id_key] ON [dbo].[cs_assignments] ([cs_user_id], [sales_executive_id]) WHERE [sales_executive_id] IS NOT NULL;
GO

-- public.cs_cuentas_habilitadas | ~2 filas
IF OBJECT_ID(N'[dbo].[cs_cuentas_habilitadas]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[cs_cuentas_habilitadas] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_cs_cuentas_habilitadas_id] DEFAULT (NEWSEQUENTIALID()),
  [cs_user_id] UNIQUEIDENTIFIER NOT NULL,
  [client_id] UNIQUEIDENTIFIER NOT NULL,
  [active] BIT NOT NULL CONSTRAINT [DF_cs_cuentas_habilitadas_active] DEFAULT (1),
  [notas] NVARCHAR(MAX) NULL,
  [created_by] UNIQUEIDENTIFIER NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_cs_cuentas_habilitadas_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [cs_cuentas_habilitadas_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [cs_cuentas_habilitadas_cs_user_id_client_id_key] UNIQUE ([cs_user_id], [client_id])
);
END
GO

-- public.deals | ~1,255 filas
IF OBJECT_ID(N'[dbo].[deals]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[deals] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_deals_id] DEFAULT (NEWSEQUENTIALID()),
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_deals_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_deals_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  [company_name] NVARCHAR(MAX) NOT NULL,
  [contact_name] NVARCHAR(MAX) NULL,
  [contact_email] NVARCHAR(MAX) NULL,
  [contact_phone] NVARCHAR(MAX) NULL,
  [stage] NVARCHAR(MAX) NULL CONSTRAINT [DF_deals_stage] DEFAULT (N'new_lead'),
  [priority] NVARCHAR(MAX) NULL CONSTRAINT [DF_deals_priority] DEFAULT (N'warm'),
  [value] DECIMAL(12,2) NULL,
  [trade_route] NVARCHAR(MAX) NULL,
  [origin_country] NVARCHAR(MAX) NULL,
  [destination_country] NVARCHAR(MAX) NULL,
  [service_type] NVARCHAR(MAX) NULL,
  [commodity] NVARCHAR(MAX) NULL,
  [volume_cbm] DECIMAL(10,2) NULL,
  [weight_kg] DECIMAL(10,2) NULL,
  [expected_ship_date] DATE NULL,
  [expected_close_date] DATE NULL,
  [assigned_to] UNIQUEIDENTIFIER NULL,
  [client_type] NVARCHAR(MAX) NULL,
  [lead_source] NVARCHAR(MAX) NULL,
  [probability] INT NULL CONSTRAINT [DF_deals_probability] DEFAULT (50),
  [notes] NVARCHAR(MAX) NULL,
  [lost_reason] NVARCHAR(MAX) NULL,
  [won_date] DATE NULL,
  [lost_date] DATE NULL,
  [client_id] UNIQUEIDENTIFIER NULL,
  [office] NVARCHAR(50) NULL,
  [next_follow_up] DATE NULL,
  [status_note] NVARCHAR(MAX) NULL,
  CONSTRAINT [deals_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [deals_client_type_check] CHECK (([client_type]  IN (N'direct_client', N'freight_forwarder', N'prospect'))),
  CONSTRAINT [deals_destination_country_check] CHECK (([destination_country]  IN (N'Panama', N'Ecuador', N'Peru', N'USA'))),
  CONSTRAINT [deals_lead_source_check] CHECK (([lead_source]  IN (N'referral', N'website', N'cold_call', N'trade_show', N'linkedin', N'other'))),
  CONSTRAINT [deals_priority_check] CHECK (([priority]  IN (N'hot', N'warm', N'cold'))),
  CONSTRAINT [deals_probability_check] CHECK ((([probability] >= 0) AND ([probability] <= 100))),
  CONSTRAINT [deals_service_type_check] CHECK (([service_type]  IN (N'lcl', N'fcl', N'air', N'courier'))),
  CONSTRAINT [deals_stage_check] CHECK (([stage]  IN (N'prospect', N'qualification', N'quote', N'negotiation', N'closing'))),
  CONSTRAINT [deals_trade_route_check] CHECK (([trade_route]  IN (N'usa_latam', N'china_latam', N'europa_latam', N'intra_latam'))),
  CONSTRAINT [valid_office] CHECK ((([office]  IN (N'USA', N'Panama', N'Ecuador', N'Peru')) OR ([office] IS NULL)))
);
END
GO

-- public.prospect_enrichment_ec | ~103 filas
IF OBJECT_ID(N'[dbo].[prospect_enrichment_ec]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[prospect_enrichment_ec] (
  [ruc] NVARCHAR(50) NOT NULL,
  [razon_social] NVARCHAR(MAX) NULL,
  [estado_contribuyente] NVARCHAR(MAX) NULL,
  [tipo_contribuyente] NVARCHAR(MAX) NULL,
  [regimen] NVARCHAR(MAX) NULL,
  [actividad_economica_principal] NVARCHAR(MAX) NULL,
  [obligado_llevar_contabilidad] BIT NULL,
  [agente_retencion] BIT NULL,
  [contribuyente_especial] BIT NULL,
  [contribuyente_fantasma] BIT NULL,
  [transacciones_inexistentes] BIT NULL,
  [fecha_inicio_actividades] DATE NULL,
  [fecha_cese] DATE NULL,
  [fecha_reinicio_actividades] DATE NULL,
  [fecha_actualizacion_sri] DATE NULL,
  [representantes_legales] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_prospect_enrichment_ec_representantes_legales] DEFAULT (N'[]'),
  [establecimientos] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_prospect_enrichment_ec_establecimientos] DEFAULT (N'[]'),
  [direccion_matriz] NVARCHAR(MAX) NULL,
  [last_fetched_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_prospect_enrichment_ec_last_fetched_at] DEFAULT (SYSDATETIMEOFFSET()),
  [last_error] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_prospect_enrichment_ec_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_prospect_enrichment_ec_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [prospect_enrichment_ec_pkey] PRIMARY KEY ([ruc]),
  CONSTRAINT [CK_prospect_enrichment_ec_representantes_legales_json] CHECK (ISJSON([representantes_legales]) = 1),
  CONSTRAINT [CK_prospect_enrichment_ec_establecimientos_json] CHECK (ISJSON([establecimientos]) = 1)
);
END
GO

-- public.quote_amendments | ~11 filas
IF OBJECT_ID(N'[dbo].[quote_amendments]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[quote_amendments] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_quote_amendments_id] DEFAULT (NEWSEQUENTIALID()),
  [quote_id] UNIQUEIDENTIFIER NOT NULL,
  [status] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_quote_amendments_status] DEFAULT (N'pending'),
  [reason] NVARCHAR(MAX) NULL,
  [lines] NVARCHAR(MAX) NOT NULL,
  [cost_total] DECIMAL(38,10) NULL,
  [sale_total] DECIMAL(38,10) NULL,
  [profit_total] DECIMAL(38,10) NULL,
  [prev_cost_total] DECIMAL(38,10) NULL,
  [prev_sale_total] DECIMAL(38,10) NULL,
  [prev_profit_total] DECIMAL(38,10) NULL,
  [created_by] UNIQUEIDENTIFIER NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_quote_amendments_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [decided_by] UNIQUEIDENTIFIER NULL,
  [decided_at] DATETIMEOFFSET NULL,
  CONSTRAINT [quote_amendments_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [quote_amendments_status_check] CHECK (([status]  IN (N'pending', N'approved', N'rejected'))),
  CONSTRAINT [CK_quote_amendments_lines_json] CHECK (ISJSON([lines]) = 1)
);
END
GO

-- public.quote_emails | ~181 filas
IF OBJECT_ID(N'[dbo].[quote_emails]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[quote_emails] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_quote_emails_id] DEFAULT (NEWSEQUENTIALID()),
  [quote_id] UNIQUEIDENTIFIER NOT NULL,
  [to_email] NVARCHAR(MAX) NOT NULL,
  [subject] NVARCHAR(MAX) NULL,
  [method] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_quote_emails_method] DEFAULT (N'eml_outlook'),
  [sent_by] UNIQUEIDENTIFIER NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_quote_emails_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [quote_emails_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.quote_followups | ~4 filas
IF OBJECT_ID(N'[dbo].[quote_followups]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[quote_followups] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_quote_followups_id] DEFAULT (NEWSEQUENTIALID()),
  [quote_id] UNIQUEIDENTIFIER NOT NULL,
  [done_by] UNIQUEIDENTIFIER NULL,
  [note] NVARCHAR(MAX) NULL,
  [next_followup_at] DATE NULL,
  [created_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_quote_followups_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [quote_followups_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.quote_pba | ~146 filas
IF OBJECT_ID(N'[dbo].[quote_pba]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[quote_pba] (
  [quote_id] UNIQUEIDENTIFIER NOT NULL,
  [pba_cost] DECIMAL(38,10) NOT NULL CONSTRAINT [DF_quote_pba_pba_cost] DEFAULT (0),
  [notes] NVARCHAR(MAX) NULL,
  [updated_at] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_quote_pba_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_by] UNIQUEIDENTIFIER NULL,
  CONSTRAINT [quote_pba_pkey] PRIMARY KEY ([quote_id])
);
END
GO

-- public.quotes | ~1,231 filas
IF OBJECT_ID(N'[dbo].[quotes]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[quotes] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_quotes_id] DEFAULT (NEWSEQUENTIALID()),
  [quote_number] NVARCHAR(50) NOT NULL,
  [client_id] UNIQUEIDENTIFIER NULL,
  [deal_id] UNIQUEIDENTIFIER NULL,
  [customer_id] UNIQUEIDENTIFIER NULL,
  [customer_name] NVARCHAR(MAX) NULL,
  [customer_email] NVARCHAR(MAX) NULL,
  [customer_phone] NVARCHAR(MAX) NULL,
  [origin_port_id] UNIQUEIDENTIFIER NULL,
  [destination_port_id] UNIQUEIDENTIFIER NULL,
  [equipment_type_id] UNIQUEIDENTIFIER NULL,
  [commodity_id] UNIQUEIDENTIFIER NOT NULL,
  [carrier_id] UNIQUEIDENTIFIER NULL,
  [selected_rate_id] UNIQUEIDENTIFIER NULL,
  [quantity] INT NULL,
  [cargo_description] NVARCHAR(MAX) NULL,
  [cargo_weight_kg] DECIMAL(38,10) NULL,
  [cargo_volume_cbm] DECIMAL(38,10) NULL,
  [hazmat] BIT NULL CONSTRAINT [DF_quotes_hazmat] DEFAULT (0),
  [hazmat_class] NVARCHAR(MAX) NULL,
  [un_number] NVARCHAR(MAX) NULL,
  [special_requirements] NVARCHAR(MAX) NULL,
  [base_rate] DECIMAL(38,10) NULL,
  [total_charges] DECIMAL(38,10) NULL,
  [subtotal] DECIMAL(38,10) NULL,
  [markup_percentage] DECIMAL(38,10) NULL CONSTRAINT [DF_quotes_markup_percentage] DEFAULT (15),
  [markup_amount] DECIMAL(38,10) NULL,
  [total_amount] DECIMAL(38,10) NULL,
  [currency] NVARCHAR(MAX) NULL CONSTRAINT [DF_quotes_currency] DEFAULT (N'USD'),
  [estimated_departure_date] DATE NULL,
  [valid_until] DATE NULL,
  [status] NVARCHAR(MAX) NULL CONSTRAINT [DF_quotes_status] DEFAULT (N'DRAFT'),
  [sent_at] DATETIMEOFFSET NULL,
  [accepted_at] DATETIMEOFFSET NULL,
  [notes] NVARCHAR(MAX) NULL,
  [created_by] UNIQUEIDENTIFIER NULL,
  [office] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_quotes_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [markup_flat] DECIMAL(38,10) NULL CONSTRAINT [DF_quotes_markup_flat] DEFAULT (0),
  [mode] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_quotes_mode] DEFAULT (N'ocean'),
  [air_carrier_id] UNIQUEIDENTIFIER NULL,
  [selected_air_rate_id] UNIQUEIDENTIFIER NULL,
  [origin_airport_code] NVARCHAR(MAX) NULL,
  [destination_airport_code] NVARCHAR(MAX) NULL,
  [direction] NVARCHAR(MAX) NULL,
  [incoterm] NVARCHAR(MAX) NULL,
  [payment_terms] NVARCHAR(MAX) NULL,
  [origin_agent] NVARCHAR(MAX) NULL,
  [origin_share_pct] DECIMAL(38,10) NULL,
  [chargeable_weight_kg] DECIMAL(38,10) NULL,
  [wm_units] DECIMAL(38,10) NULL,
  [pieces] INT NULL,
  [cargo_pieces] NVARCHAR(MAX) NULL,
  [cost_total] DECIMAL(38,10) NULL,
  [sale_total] DECIMAL(38,10) NULL,
  [profit_total] DECIMAL(38,10) NULL,
  [presentation_mode] NVARCHAR(MAX) NULL CONSTRAINT [DF_quotes_presentation_mode] DEFAULT (N'total'),
  [client_lines] NVARCHAR(MAX) NULL,
  [rejected_at] DATETIMEOFFSET NULL,
  [lost_reason] NVARCHAR(MAX) NULL,
  [converted_si_id] UNIQUEIDENTIFIER NULL,
  [origin_text] NVARCHAR(MAX) NULL,
  [destination_text] NVARCHAR(MAX) NULL,
  [gross_kg] DECIMAL(38,10) NULL,
  [cbm] DECIMAL(38,10) NULL,
  [containers] NVARCHAR(MAX) NULL,
  [transit_time] NVARCHAR(MAX) NULL,
  [cargo_hazardous] BIT NULL,
  [cargo_bonded] BIT NULL,
  [cargo_stackable] BIT NULL,
  [contact_name] NVARCHAR(MAX) NULL,
  [followup_interval_days] INT NULL,
  [next_followup_at] DATE NULL,
  [last_followup_at] DATETIMEOFFSET NULL,
  [fx_rate] DECIMAL(38,10) NULL,
  [fx_currency] NVARCHAR(MAX) NULL,
  [fx_source] NVARCHAR(MAX) NULL,
  [fx_date] DATE NULL,
  [prepared_by] UNIQUEIDENTIFIER NULL,
  [iva_omitido] BIT NOT NULL CONSTRAINT [DF_quotes_iva_omitido] DEFAULT (0),
  [display_currency] NVARCHAR(MAX) NULL,
  [free_days] INT NULL,
  [guarantee_waiver] NVARCHAR(MAX) NULL,
  [dims_unit] NVARCHAR(MAX) NULL,
  [weight_unit] NVARCHAR(MAX) NULL,
  [is_directos] BIT NOT NULL CONSTRAINT [DF_quotes_is_directos] DEFAULT (0),
  CONSTRAINT [quotes_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [quotes_quote_number_key] UNIQUE ([quote_number]),
  CONSTRAINT [CK_quotes_cargo_pieces_json] CHECK (ISJSON([cargo_pieces]) = 1),
  CONSTRAINT [CK_quotes_client_lines_json] CHECK (ISJSON([client_lines]) = 1),
  CONSTRAINT [CK_quotes_containers_json] CHECK (ISJSON([containers]) = 1)
);
END
GO

-- public.reminders | ~16 filas
IF OBJECT_ID(N'[dbo].[reminders]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[reminders] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_reminders_id] DEFAULT (NEWSEQUENTIALID()),
  [user_id] UNIQUEIDENTIFIER NOT NULL,
  [source_type] NVARCHAR(MAX) NOT NULL,
  [source_id] UNIQUEIDENTIFIER NULL,
  [shipment_id] UNIQUEIDENTIFIER NULL,
  [title] NVARCHAR(MAX) NOT NULL,
  [body] NVARCHAR(MAX) NULL,
  [channel] NVARCHAR(MAX) NULL CONSTRAINT [DF_reminders_channel] DEFAULT (N'in_app'),
  [status] NVARCHAR(50) NULL CONSTRAINT [DF_reminders_status] DEFAULT (N'PENDING'),
  [scheduled_for] DATETIMEOFFSET NULL CONSTRAINT [DF_reminders_scheduled_for] DEFAULT (SYSDATETIMEOFFSET()),
  [sent_at] DATETIMEOFFSET NULL,
  [read_at] DATETIMEOFFSET NULL,
  [metadata] NVARCHAR(MAX) NULL CONSTRAINT [DF_reminders_metadata] DEFAULT (N'{}'),
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_reminders_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [reminders_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [CK_reminders_metadata_json] CHECK (ISJSON([metadata]) = 1)
);
END
GO

-- public.sales_activities | ~618 filas
IF OBJECT_ID(N'[dbo].[sales_activities]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[sales_activities] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_sales_activities_id] DEFAULT (NEWSEQUENTIALID()),
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_sales_activities_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [activity_date] DATETIMEOFFSET NOT NULL,
  [activity_type] NVARCHAR(MAX) NOT NULL,
  [sales_rep_id] UNIQUEIDENTIFIER NOT NULL,
  [client_id] UNIQUEIDENTIFIER NULL,
  [deal_id] UNIQUEIDENTIFIER NULL,
  [company_name] NVARCHAR(MAX) NULL,
  [contact_name] NVARCHAR(MAX) NULL,
  [duration_minutes] INT NULL CONSTRAINT [DF_sales_activities_duration_minutes] DEFAULT (0),
  [outcome] NVARCHAR(MAX) NULL,
  [notes] NVARCHAR(MAX) NULL,
  [follow_up_required] BIT NULL CONSTRAINT [DF_sales_activities_follow_up_required] DEFAULT (0),
  [follow_up_date] DATE NULL,
  [follow_up_completed] BIT NULL CONSTRAINT [DF_sales_activities_follow_up_completed] DEFAULT (0),
  [office] NVARCHAR(MAX) NULL,
  CONSTRAINT [sales_activities_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [sales_activities_activity_type_check] CHECK (([activity_type]  IN (N'call_outbound', N'call_inbound', N'visit', N'office_meeting', N'email_sent', N'email_received', N'quote_sent', N'follow_up', N'video_call', N'whatsapp'))),
  CONSTRAINT [sales_activities_outcome_check] CHECK (([outcome]  IN (N'positive_moving_forward', N'positive_requested_quote', N'positive_scheduled_meeting', N'neutral_follow_up', N'neutral_not_available', N'negative_not_interested', N'negative_competitor', N'negative_no_budget')))
);
END
GO

-- public.sales_doc_counters | ~2 filas
IF OBJECT_ID(N'[dbo].[sales_doc_counters]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[sales_doc_counters] (
  [doc_type] NVARCHAR(50) NOT NULL,
  [year] INT NOT NULL,
  [last_n] INT NOT NULL CONSTRAINT [DF_sales_doc_counters_last_n] DEFAULT (0),
  CONSTRAINT [sales_doc_counters_pkey] PRIMARY KEY ([doc_type], [year])
);
END
GO

-- public.sales_goals | ~21 filas
IF OBJECT_ID(N'[dbo].[sales_goals]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[sales_goals] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_sales_goals_id] DEFAULT (NEWSEQUENTIALID()),
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_sales_goals_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [sales_rep_id] UNIQUEIDENTIFIER NOT NULL,
  [period_type] NVARCHAR(MAX) NOT NULL,
  [calls_goal] INT NULL CONSTRAINT [DF_sales_goals_calls_goal] DEFAULT (0),
  [visits_goal] INT NULL CONSTRAINT [DF_sales_goals_visits_goal] DEFAULT (0),
  [emails_goal] INT NULL CONSTRAINT [DF_sales_goals_emails_goal] DEFAULT (0),
  [quotes_goal] INT NULL CONSTRAINT [DF_sales_goals_quotes_goal] DEFAULT (0),
  [meetings_goal] INT NULL CONSTRAINT [DF_sales_goals_meetings_goal] DEFAULT (0),
  [revenue_goal] DECIMAL(12,2) NULL,
  [start_date] DATE NULL,
  [end_date] DATE NULL,
  [is_active] BIT NULL CONSTRAINT [DF_sales_goals_is_active] DEFAULT (1),
  [gross_profit_goal] DECIMAL(12,2) NULL CONSTRAINT [DF_sales_goals_gross_profit_goal] DEFAULT (0),
  [office] NVARCHAR(MAX) NULL,
  CONSTRAINT [sales_goals_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [sales_goals_period_type_check] CHECK (([period_type]  IN (N'daily', N'weekly', N'monthly')))
);
END
GO

-- public.sales_live_monthly | ~72 filas
IF OBJECT_ID(N'[dbo].[sales_live_monthly]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[sales_live_monthly] (
  [office] NVARCHAR(50) NOT NULL,
  [ym] NVARCHAR(50) NOT NULL,
  [gross_excl_ic] DECIMAL(38,10) NOT NULL,
  [gross_incl_ic] DECIMAL(38,10) NULL,
  [tax] DECIMAL(38,10) NULL,
  [n_invoices] INT NULL,
  [method] NVARCHAR(MAX) NULL CONSTRAINT [DF_sales_live_monthly_method] DEFAULT (N'live-magaya'),
  [computed_at] DATETIMEOFFSET NULL CONSTRAINT [DF_sales_live_monthly_computed_at] DEFAULT (SYSDATETIMEOFFSET()),
  [fuente] NVARCHAR(MAX) NULL CONSTRAINT [DF_sales_live_monthly_fuente] DEFAULT (N'live-facturas'),
  [same_period_usd] DECIMAL(38,10) NULL,
  [same_period_day] INT NULL,
  CONSTRAINT [sales_live_monthly_pkey] PRIMARY KEY ([office], [ym])
);
END
GO

-- public.sales_quote_lines | ~17,708 filas
IF OBJECT_ID(N'[dbo].[sales_quote_lines]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[sales_quote_lines] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_sales_quote_lines_id] DEFAULT (NEWSEQUENTIALID()),
  [quote_id] UNIQUEIDENTIFIER NULL,
  [section] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_sales_quote_lines_section] DEFAULT (N'freight'),
  [charge_code] NVARCHAR(MAX) NULL,
  [name] NVARCHAR(MAX) NOT NULL,
  [basis] NVARCHAR(MAX) NOT NULL CONSTRAINT [DF_sales_quote_lines_basis] DEFAULT (N'manual'),
  [qty] DECIMAL(38,10) NULL CONSTRAINT [DF_sales_quote_lines_qty] DEFAULT (1),
  [cost_rate] DECIMAL(38,10) NULL CONSTRAINT [DF_sales_quote_lines_cost_rate] DEFAULT (0),
  [cost_amount] DECIMAL(38,10) NULL CONSTRAINT [DF_sales_quote_lines_cost_amount] DEFAULT (0),
  [sale_rate] DECIMAL(38,10) NULL CONSTRAINT [DF_sales_quote_lines_sale_rate] DEFAULT (0),
  [sale_amount] DECIMAL(38,10) NULL CONSTRAINT [DF_sales_quote_lines_sale_amount] DEFAULT (0),
  [currency] NVARCHAR(MAX) NULL CONSTRAINT [DF_sales_quote_lines_currency] DEFAULT (N'USD'),
  [notes] NVARCHAR(MAX) NULL,
  [sort_order] INT NULL CONSTRAINT [DF_sales_quote_lines_sort_order] DEFAULT (0),
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_sales_quote_lines_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [cost_min] DECIMAL(38,10) NULL CONSTRAINT [DF_sales_quote_lines_cost_min] DEFAULT (0),
  [sale_min] DECIMAL(38,10) NULL CONSTRAINT [DF_sales_quote_lines_sale_min] DEFAULT (0),
  [si_id] UNIQUEIDENTIFIER NULL,
  [container_type] NVARCHAR(MAX) NULL,
  [iva_exempt] BIT NOT NULL CONSTRAINT [DF_sales_quote_lines_iva_exempt] DEFAULT (0),
  [free_qty] DECIMAL(38,10) NOT NULL CONSTRAINT [DF_sales_quote_lines_free_qty] DEFAULT (0),
  CONSTRAINT [sales_quote_lines_pkey] PRIMARY KEY ([id]),
  CONSTRAINT [chk_line_owner] CHECK ((((CASE WHEN [quote_id] IS NOT NULL THEN 1 ELSE 0 END) + (CASE WHEN [si_id] IS NOT NULL THEN 1 ELSE 0 END)) = 1)),
  CONSTRAINT [sales_quote_lines_basis_check] CHECK (([basis]  IN (N'per_kg', N'per_lb', N'per_wm', N'per_cbm', N'per_container', N'per_bl', N'per_lashing', N'fixed', N'pct', N'pct_local', N'manual'))),
  CONSTRAINT [sales_quote_lines_section_check] CHECK (([section]  IN (N'freight', N'origin', N'destination', N'other')))
);
END
GO

-- public.time_entries | ~6 filas
IF OBJECT_ID(N'[dbo].[time_entries]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[time_entries] (
  [id] UNIQUEIDENTIFIER NOT NULL CONSTRAINT [DF_time_entries_id] DEFAULT (NEWSEQUENTIALID()),
  [user_id] UNIQUEIDENTIFIER NOT NULL,
  [clock_in_time] DATETIMEOFFSET NOT NULL CONSTRAINT [DF_time_entries_clock_in_time] DEFAULT (SYSDATETIMEOFFSET()),
  [clock_out_time] DATETIMEOFFSET NULL,
  [total_hours] DECIMAL(10,2) NULL,
  [notes] NVARCHAR(MAX) NULL,
  [created_at] DATETIMEOFFSET NULL CONSTRAINT [DF_time_entries_created_at] DEFAULT (SYSDATETIMEOFFSET()),
  [updated_at] DATETIMEOFFSET NULL CONSTRAINT [DF_time_entries_updated_at] DEFAULT (SYSDATETIMEOFFSET()),
  [active_time_minutes] INT NULL CONSTRAINT [DF_time_entries_active_time_minutes] DEFAULT (0),
  [idle_time_minutes] INT NULL CONSTRAINT [DF_time_entries_idle_time_minutes] DEFAULT (0),
  [activity_percentage] DECIMAL(5,2) NULL CONSTRAINT [DF_time_entries_activity_percentage] DEFAULT (0),
  [last_activity_at] DATETIMEOFFSET NULL,
  CONSTRAINT [time_entries_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.ventas_alertas | ~3 filas
IF OBJECT_ID(N'[dbo].[ventas_alertas]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[ventas_alertas] (
  [id] BIGINT NOT NULL CONSTRAINT [DF_ventas_alertas_id] DEFAULT (NEXT VALUE FOR [dbo].[ventas_alertas_id_seq]),
  [fecha] DATE NULL,
  [severidad] NVARCHAR(MAX) NULL,
  [office] NVARCHAR(MAX) NULL,
  [ym] NVARCHAR(MAX) NULL,
  [regla] NVARCHAR(MAX) NULL,
  [detalle] NVARCHAR(MAX) NULL,
  [creado] DATETIMEOFFSET NULL CONSTRAINT [DF_ventas_alertas_creado] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [ventas_alertas_pkey] PRIMARY KEY ([id])
);
END
GO

-- public.ventas_congelado | ~7 filas
IF OBJECT_ID(N'[dbo].[ventas_congelado]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[ventas_congelado] (
  [office] NVARCHAR(50) NOT NULL,
  [ym] NVARCHAR(50) NOT NULL,
  [valor] DECIMAL(38,10) NULL,
  [congelado_at] DATETIMEOFFSET NULL CONSTRAINT [DF_ventas_congelado_congelado_at] DEFAULT (SYSDATETIMEOFFSET()),
  CONSTRAINT [ventas_congelado_pkey] PRIMARY KEY ([office], [ym])
);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_activity_logs_time_entry_id' AND object_id = OBJECT_ID(N'[dbo].[activity_logs]'))
CREATE INDEX [idx_activity_logs_time_entry_id] ON [dbo].[activity_logs] ([time_entry_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_activity_logs_user_id' AND object_id = OBJECT_ID(N'[dbo].[activity_logs]'))
CREATE INDEX [idx_activity_logs_user_id] ON [dbo].[activity_logs] ([user_id]);
GO

IF COL_LENGTH(N'[dbo].[client_notify_contacts]', N'consignee_hint__nn') IS NULL
ALTER TABLE [dbo].[client_notify_contacts] ADD [consignee_hint__nn] AS COALESCE([consignee_hint], N'') PERSISTED;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'client_notify_contacts_uniq' AND object_id = OBJECT_ID(N'[dbo].[client_notify_contacts]'))
CREATE UNIQUE INDEX [client_notify_contacts_uniq] ON [dbo].[client_notify_contacts] ([client_id], [consignee_hint__nn], [email], [role]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_client_visits_client' AND object_id = OBJECT_ID(N'[dbo].[client_visits]'))
CREATE INDEX [idx_client_visits_client] ON [dbo].[client_visits] ([client_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_client_visits_exec' AND object_id = OBJECT_ID(N'[dbo].[client_visits]'))
CREATE INDEX [idx_client_visits_exec] ON [dbo].[client_visits] ([executive_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_client_visits_office' AND object_id = OBJECT_ID(N'[dbo].[client_visits]'))
CREATE INDEX [idx_client_visits_office] ON [dbo].[client_visits] ([office]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_client_visits_sched' AND object_id = OBJECT_ID(N'[dbo].[client_visits]'))
CREATE INDEX [idx_client_visits_sched] ON [dbo].[client_visits] ([scheduled_at]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_client_visits_status' AND object_id = OBJECT_ID(N'[dbo].[client_visits]'))
CREATE INDEX [idx_client_visits_status] ON [dbo].[client_visits] ([status]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'clients_customer_service_id_idx' AND object_id = OBJECT_ID(N'[dbo].[clients]'))
CREATE INDEX [clients_customer_service_id_idx] ON [dbo].[clients] ([customer_service_id]) WHERE ([customer_service_id] IS NOT NULL);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'clients_deleted_at_idx' AND object_id = OBJECT_ID(N'[dbo].[clients]'))
CREATE INDEX [clients_deleted_at_idx] ON [dbo].[clients] ([deleted_at]) WHERE ([deleted_at] IS NOT NULL);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'clients_ruc_unique' AND object_id = OBJECT_ID(N'[dbo].[clients]'))
CREATE UNIQUE INDEX [clients_ruc_unique] ON [dbo].[clients] ([ruc]) WHERE (([ruc] IS NOT NULL) AND ([ruc] <> N'') AND ([deleted_at] IS NULL)) AND [ruc] IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_clients_account_manager_id' AND object_id = OBJECT_ID(N'[dbo].[clients]'))
CREATE INDEX [idx_clients_account_manager_id] ON [dbo].[clients] ([account_manager_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_clients_assigned_to' AND object_id = OBJECT_ID(N'[dbo].[clients]'))
CREATE INDEX [idx_clients_assigned_to] ON [dbo].[clients] ([assigned_to]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_clients_created_by' AND object_id = OBJECT_ID(N'[dbo].[clients]'))
CREATE INDEX [idx_clients_created_by] ON [dbo].[clients] ([created_by]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_clients_is_direct' AND object_id = OBJECT_ID(N'[dbo].[clients]'))
CREATE INDEX [idx_clients_is_direct] ON [dbo].[clients] ([is_direct]) WHERE ([is_direct] = 1);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_clients_office' AND object_id = OBJECT_ID(N'[dbo].[clients]'))
CREATE INDEX [idx_clients_office] ON [dbo].[clients] ([office]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_clients_parent_ff_id' AND object_id = OBJECT_ID(N'[dbo].[clients]'))
CREATE INDEX [idx_clients_parent_ff_id] ON [dbo].[clients] ([parent_ff_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_contacts_client_id' AND object_id = OBJECT_ID(N'[dbo].[contacts]'))
CREATE INDEX [idx_contacts_client_id] ON [dbo].[contacts] ([client_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_credit_documents_credit_request_id' AND object_id = OBJECT_ID(N'[dbo].[credit_documents]'))
CREATE INDEX [idx_credit_documents_credit_request_id] ON [dbo].[credit_documents] ([credit_request_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_credit_documents_uploaded_by' AND object_id = OBJECT_ID(N'[dbo].[credit_documents]'))
CREATE INDEX [idx_credit_documents_uploaded_by] ON [dbo].[credit_documents] ([uploaded_by]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'credit_notify_log_request_idx' AND object_id = OBJECT_ID(N'[dbo].[credit_notify_log]'))
CREATE INDEX [credit_notify_log_request_idx] ON [dbo].[credit_notify_log] ([credit_request_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_credit_requests_client_id' AND object_id = OBJECT_ID(N'[dbo].[credit_requests]'))
CREATE INDEX [idx_credit_requests_client_id] ON [dbo].[credit_requests] ([client_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_credit_requests_requested_by' AND object_id = OBJECT_ID(N'[dbo].[credit_requests]'))
CREATE INDEX [idx_credit_requests_requested_by] ON [dbo].[credit_requests] ([requested_by]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_credit_requests_reviewed_by' AND object_id = OBJECT_ID(N'[dbo].[credit_requests]'))
CREATE INDEX [idx_credit_requests_reviewed_by] ON [dbo].[credit_requests] ([reviewed_by]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_credit_requests_status' AND object_id = OBJECT_ID(N'[dbo].[credit_requests]'))
CREATE INDEX [idx_credit_requests_status] ON [dbo].[credit_requests] ([status]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'cs_assign_cs_idx' AND object_id = OBJECT_ID(N'[dbo].[cs_assignments]'))
CREATE INDEX [cs_assign_cs_idx] ON [dbo].[cs_assignments] ([cs_user_id]) WHERE ([active] = 1);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'cs_assign_exec_idx' AND object_id = OBJECT_ID(N'[dbo].[cs_assignments]'))
CREATE INDEX [cs_assign_exec_idx] ON [dbo].[cs_assignments] ([sales_executive_id]) WHERE ([active] = 1);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_cs_assignments_created_by' AND object_id = OBJECT_ID(N'[dbo].[cs_assignments]'))
CREATE INDEX [idx_cs_assignments_created_by] ON [dbo].[cs_assignments] ([created_by]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_deals_created_at' AND object_id = OBJECT_ID(N'[dbo].[deals]'))
CREATE INDEX [idx_deals_created_at] ON [dbo].[deals] ([created_at]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_deals_office' AND object_id = OBJECT_ID(N'[dbo].[deals]'))
CREATE INDEX [idx_deals_office] ON [dbo].[deals] ([office]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'prospect_enrichment_ec_last_fetched_idx' AND object_id = OBJECT_ID(N'[dbo].[prospect_enrichment_ec]'))
CREATE INDEX [prospect_enrichment_ec_last_fetched_idx] ON [dbo].[prospect_enrichment_ec] ([last_fetched_at]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'uq_amendment_pending' AND object_id = OBJECT_ID(N'[dbo].[quote_amendments]'))
CREATE UNIQUE INDEX [uq_amendment_pending] ON [dbo].[quote_amendments] ([quote_id]) WHERE ([status] = N'pending');
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_quote_emails_quote' AND object_id = OBJECT_ID(N'[dbo].[quote_emails]'))
CREATE INDEX [idx_quote_emails_quote] ON [dbo].[quote_emails] ([quote_id], [created_at] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_quote_followups_quote' AND object_id = OBJECT_ID(N'[dbo].[quote_followups]'))
CREATE INDEX [idx_quote_followups_quote] ON [dbo].[quote_followups] ([quote_id], [created_at] DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_quotes_carrier_id' AND object_id = OBJECT_ID(N'[dbo].[quotes]'))
CREATE INDEX [idx_quotes_carrier_id] ON [dbo].[quotes] ([carrier_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_quotes_client' AND object_id = OBJECT_ID(N'[dbo].[quotes]'))
CREATE INDEX [idx_quotes_client] ON [dbo].[quotes] ([client_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_quotes_commodity_id' AND object_id = OBJECT_ID(N'[dbo].[quotes]'))
CREATE INDEX [idx_quotes_commodity_id] ON [dbo].[quotes] ([commodity_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_quotes_created_by' AND object_id = OBJECT_ID(N'[dbo].[quotes]'))
CREATE INDEX [idx_quotes_created_by] ON [dbo].[quotes] ([created_by]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_quotes_deal_id' AND object_id = OBJECT_ID(N'[dbo].[quotes]'))
CREATE INDEX [idx_quotes_deal_id] ON [dbo].[quotes] ([deal_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_quotes_destination_port_id' AND object_id = OBJECT_ID(N'[dbo].[quotes]'))
CREATE INDEX [idx_quotes_destination_port_id] ON [dbo].[quotes] ([destination_port_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_quotes_equipment_type_id' AND object_id = OBJECT_ID(N'[dbo].[quotes]'))
CREATE INDEX [idx_quotes_equipment_type_id] ON [dbo].[quotes] ([equipment_type_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_quotes_origin_port_id' AND object_id = OBJECT_ID(N'[dbo].[quotes]'))
CREATE INDEX [idx_quotes_origin_port_id] ON [dbo].[quotes] ([origin_port_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_quotes_selected_rate_id' AND object_id = OBJECT_ID(N'[dbo].[quotes]'))
CREATE INDEX [idx_quotes_selected_rate_id] ON [dbo].[quotes] ([selected_rate_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_reminders_shipment_id' AND object_id = OBJECT_ID(N'[dbo].[reminders]'))
CREATE INDEX [idx_reminders_shipment_id] ON [dbo].[reminders] ([shipment_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'reminders_scheduled_idx' AND object_id = OBJECT_ID(N'[dbo].[reminders]'))
CREATE INDEX [reminders_scheduled_idx] ON [dbo].[reminders] ([scheduled_for]) WHERE ([status] = N'PENDING');
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'reminders_user_status_idx' AND object_id = OBJECT_ID(N'[dbo].[reminders]'))
CREATE INDEX [reminders_user_status_idx] ON [dbo].[reminders] ([user_id], [status]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_sales_activities_date' AND object_id = OBJECT_ID(N'[dbo].[sales_activities]'))
CREATE INDEX [idx_sales_activities_date] ON [dbo].[sales_activities] ([activity_date]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_sales_activities_deal_id' AND object_id = OBJECT_ID(N'[dbo].[sales_activities]'))
CREATE INDEX [idx_sales_activities_deal_id] ON [dbo].[sales_activities] ([deal_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_sales_activities_sales_rep_id' AND object_id = OBJECT_ID(N'[dbo].[sales_activities]'))
CREATE INDEX [idx_sales_activities_sales_rep_id] ON [dbo].[sales_activities] ([sales_rep_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_sq_lines_quote' AND object_id = OBJECT_ID(N'[dbo].[sales_quote_lines]'))
CREATE INDEX [idx_sq_lines_quote] ON [dbo].[sales_quote_lines] ([quote_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_sq_lines_si' AND object_id = OBJECT_ID(N'[dbo].[sales_quote_lines]'))
CREATE INDEX [idx_sq_lines_si] ON [dbo].[sales_quote_lines] ([si_id]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_time_entries_clock_in_time' AND object_id = OBJECT_ID(N'[dbo].[time_entries]'))
CREATE INDEX [idx_time_entries_clock_in_time] ON [dbo].[time_entries] ([clock_in_time]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_time_entries_clock_out_time' AND object_id = OBJECT_ID(N'[dbo].[time_entries]'))
CREATE INDEX [idx_time_entries_clock_out_time] ON [dbo].[time_entries] ([clock_out_time]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'idx_time_entries_user_id' AND object_id = OBJECT_ID(N'[dbo].[time_entries]'))
CREATE INDEX [idx_time_entries_user_id] ON [dbo].[time_entries] ([user_id]);
GO
