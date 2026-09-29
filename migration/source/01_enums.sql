-- Tipos enum
-- Origen: Supabase GES (wfzdrqfurwnakrfdnbgf), esquemas public, archive, private, timeclock.
-- Extraído del catálogo el 2026-09-29 (solo lectura). Referencia: NO ejecutar en Azure.
-- Credenciales redactadas como <SUPABASE_*>.

CREATE TYPE public.cl_alert_kind AS ENUM ('picking_complete', 'picking_exception', 'staging_assigned', 'staging_discrepancy', 'staging_verified', 'capacity_warning', 'loading_created', 'loading_exception', 'unplanned_addition', 'override', 'reopened', 'reminder_4h');
CREATE TYPE public.cl_alert_status AS ENUM ('unread', 'acknowledged', 'dismissed');
CREATE TYPE public.cl_item_type AS ENUM ('pallet', 'box', 'bag', 'package', 'envelope');
CREATE TYPE public.cl_task_status AS ENUM ('pending', 'in_progress', 'paused', 'closed', 'blocked_discrepancy', 'cancelled');
CREATE TYPE public.equipment_type AS ENUM ('NONE', 'FORKLIFT', 'MANUAL');
CREATE TYPE public.event_source_t AS ENUM ('MANUAL', 'MAGAYA', 'EMAIL_AGENT', 'SLA_AGENT', 'SYSTEM');
CREATE TYPE public.load_item_status AS ENUM ('pending', 'loaded', 'exception');
CREATE TYPE public.loading_exception_type AS ENUM ('damage', 'illegible', 'skip');
CREATE TYPE public.loading_task_status AS ENUM ('pending', 'pre_load', 'in_progress', 'paused', 'closed', 'reopened', 'cancelled');
CREATE TYPE public.manifest_source_type AS ENUM ('shipment', 'cargo_release');
CREATE TYPE public.mi_actor_type_t AS ENUM ('FORWARDER', 'CARRIER', 'PARTNER');
CREATE TYPE public.mi_etl_status_t AS ENUM ('RUNNING', 'COMPLETED', 'FAILED', 'PARTIAL');
CREATE TYPE public.mi_match_method_t AS ENUM ('RUC_EXACT', 'NAME_FUZZY', 'MANUAL');
CREATE TYPE public.mi_match_status_t AS ENUM ('PENDING', 'APPROVED', 'REJECTED', 'AUTO_ACCEPTED');
CREATE TYPE public.mi_modality_t AS ENUM ('SI', 'SE', 'AI', 'AE');
CREATE TYPE public.mi_origin_partner_t AS ENUM ('GLOVAL_NETWORK', 'THIRD_PARTY', 'DIRECT_NO_AGENT', 'UNKNOWN');
CREATE TYPE public.ops_destino_t AS ENUM ('GLOVAL_OFFICE', 'EXTERNAL_AGENT');
CREATE TYPE public.ops_doc_status_t AS ENUM ('PENDING', 'PROCESSING', 'PARSED', 'IMPORTED', 'ERROR');
CREATE TYPE public.ops_doc_type_t AS ENUM ('MBL', 'HBL', 'DRAFT_BL', 'AWB', 'PACKING', 'FACTURA_COMERCIAL', 'CERT_ORIGEN', 'AVISO_ZARPE', 'AVISO_LLEGADA', 'MANIFIESTO', 'CAS', 'OTRO', 'MBL_INSTRUCTION', 'SHIPPING_INSTRUCTION');
CREATE TYPE public.ops_equipment_t AS ENUM ('DRY', 'REEFER', 'NOR', 'FLAT_RACK', 'OPEN_TOP', 'RORO', 'BREAK_BULK');
CREATE TYPE public.ops_status_t AS ENUM ('RECIBIDO', 'DOCUMENTACION', 'DECLARACION', 'BOOKING_CUTOFF', 'TRANSITO', 'PRE_ARRIBO', 'ADUANA', 'LIBERACION', 'ENTREGADO');
CREATE TYPE public.ops_via_origen_t AS ENUM ('BODEGA', 'FUERA_BODEGA', 'CONSOLIDADO');
CREATE TYPE public.pba_status_t AS ENUM ('PENDING', 'REMINDED', 'PAID', 'WRITTEN_OFF');
CREATE TYPE public.pick_item_status AS ENUM ('in_rack', 'picked', 'exception');
CREATE TYPE public.picking_exception_type AS ENUM ('not_found_in_location', 'short_stock', 'damage');
CREATE TYPE public.picking_task_type AS ENUM ('MIXED', 'PALLETS', 'BOXES');
CREATE TYPE public.scan_result AS ENUM ('ok', 'wrong_task', 'not_in_manifest', 'duplicate', 'not_staged', 'illegible', 'unknown_barcode');
CREATE TYPE public.shipment_direction_t AS ENUM ('IMPORT', 'EXPORT', 'CROSSTRADE');
CREATE TYPE public.shipment_mode_t AS ENUM ('FCL', 'LCL', 'AIR', 'COURIER', 'BREAKBULK', 'RORO');
CREATE TYPE public.shipment_status_t AS ENUM ('BOOKING', 'IN_WAREHOUSE', 'LOADED', 'IN_TRANSIT', 'ARRIVED', 'CUSTOMS', 'RELEASED', 'DELIVERED', 'CANCELLED');
CREATE TYPE public.staging_exception_type AS ENUM ('discrepancy', 'damaged');
CREATE TYPE public.staging_item_status AS ENUM ('pending', 'verified', 'missing', 'extra');
CREATE TYPE public.warehouse_cert AS ENUM ('forklift_certified');
CREATE TYPE public.warehouse_role AS ENUM ('picker', 'loader', 'supervisor', 'manager', 'dispatcher');
CREATE TYPE public.wr_match_status_t AS ENUM ('AUTO_MATCHED', 'SUGGESTED', 'ORPHAN', 'CONFIRMED', 'REJECTED', 'IGNORED');
