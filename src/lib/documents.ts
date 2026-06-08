/**
 * Centro de documentos — catálogo de descargas para clientes.
 *
 * Todos los archivos viven en /public/documentos/{filename}.
 * Para reemplazar un placeholder con un documento real:
 *   1. Subí el archivo a public/documentos/ con el filename de abajo.
 *   2. Cambiá `placeholder: true` → `placeholder: false`.
 *   3. Actualizá `sizeKb` con el tamaño real (opcional).
 */

export type DocCategory = "operaciones" | "aduanas" | "comercial" | "contactos";
export type DocFormat = "PDF" | "DOCX" | "XLSX" | "ZIP";
export type DocLanguage = "es" | "en" | "es-en";

export interface DocResource {
  id: string;
  title: string;
  description: string;
  /** Optional EN translations — when missing, EN pages fall back to ES. */
  titleEn?: string;
  descriptionEn?: string;
  category: DocCategory;
  language: DocLanguage;
  format: DocFormat;
  filename: string;
  sizeKb?: number;
  /** Si está en true, el archivo aún no se ha subido. Botón muestra estado especial. */
  placeholder: boolean;
}

export const CATEGORY_LABEL: Record<DocCategory, string> = {
  operaciones: "Operaciones",
  aduanas: "Aduanas",
  comercial: "Comercial",
  contactos: "Contactos",
};

export const CATEGORY_DESC: Record<DocCategory, string> = {
  operaciones: "Formularios e instrucciones para el día a día del embarque.",
  aduanas: "Documentos para procesos aduaneros en USA y LATAM.",
  comercial: "Términos, contratos y solicitudes comerciales.",
  contactos: "Directorio de oficinas Gloval y contactos clave.",
};

export const DOCUMENTS: DocResource[] = [
  // OPERACIONES
  {
    id: "poa",
    title: "POA — Power of Attorney",
    description:
      "Carta poder para que Gloval Shipping actúe como agente del importador / exportador en trámites aduaneros y de transporte.",
    titleEn: "POA — Power of Attorney",
    descriptionEn:
      "Authorizes Gloval Shipping to act as the importer's or exporter's agent for customs and transport processes.",
    category: "operaciones",
    language: "es-en",
    format: "PDF",
    filename: "POA_Gloval_Shipping.pdf",
    placeholder: true,
  },
  {
    id: "sli",
    title: "SLI — Shipper's Letter of Instructions",
    description:
      "Instrucciones formales del embarcador: detalles del cargo, consignatario, ruta, modalidad y servicios contratados.",
    titleEn: "SLI — Shipper's Letter of Instructions",
    descriptionEn:
      "Formal shipper instructions: cargo details, consignee, routing, mode, and contracted services.",
    category: "operaciones",
    language: "es-en",
    format: "PDF",
    filename: "SLI_Shipper_Letter_of_Instructions.pdf",
    placeholder: true,
  },
  {
    id: "si",
    title: "SI — Shipping Instructions (BL Draft)",
    description:
      "Información para emisión del Bill of Lading: shipper, consignee, notify party, mercancía, marcas y números.",
    titleEn: "SI — Shipping Instructions (BL Draft)",
    descriptionEn:
      "Information to issue the Bill of Lading: shipper, consignee, notify party, cargo description, marks and numbers.",
    category: "operaciones",
    language: "es-en",
    format: "PDF",
    filename: "SI_Shipping_Instructions.pdf",
    placeholder: true,
  },
  {
    id: "booking",
    title: "Booking Request",
    description:
      "Solicitud de reserva de espacio: datos del envío, fechas requeridas, modalidad y ruta.",
    titleEn: "Booking Request",
    descriptionEn:
      "Space reservation request: shipment data, required dates, mode, and routing.",
    category: "operaciones",
    language: "es",
    format: "PDF",
    filename: "Booking_Request_Gloval.pdf",
    placeholder: true,
  },
  {
    id: "dgd",
    title: "DGD — Dangerous Goods Declaration",
    description:
      "Declaración para envíos de mercancías peligrosas (IMDG / IATA). Requiere validación por consultor certificado.",
    titleEn: "DGD — Dangerous Goods Declaration",
    descriptionEn:
      "Declaration for hazardous shipments (IMDG / IATA). Requires sign-off from a certified consultant.",
    category: "operaciones",
    language: "en",
    format: "PDF",
    filename: "DGD_Dangerous_Goods_Declaration.pdf",
    placeholder: true,
  },
  {
    id: "cargo-release",
    title: "Cargo Release Authorization",
    description:
      "Autorización formal para liberar la carga al consignatario o agente designado.",
    titleEn: "Cargo Release Authorization",
    descriptionEn:
      "Formal authorization to release the cargo to the consignee or designated agent.",
    category: "operaciones",
    language: "es-en",
    format: "PDF",
    filename: "Cargo_Release_Authorization.pdf",
    placeholder: true,
  },

  // ADUANAS
  {
    id: "isf",
    title: "ISF 10+2 — Importer Security Filing (USA)",
    description:
      "Información requerida por CBP de USA para envíos marítimos con destino EE.UU. — debe presentarse 24h antes del embarque.",
    titleEn: "ISF 10+2 — Importer Security Filing (USA)",
    descriptionEn:
      "Data required by US CBP for ocean shipments to the US — must be filed 24h before vessel loading.",
    category: "aduanas",
    language: "en",
    format: "PDF",
    filename: "ISF_10_plus_2_Importer_Security_Filing.pdf",
    placeholder: true,
  },
  {
    id: "broker-auth",
    title: "Customs Broker Authorization",
    description:
      "Autorización para que el agente aduanal Gloval (o su corresponsal) actúe en nombre del importador.",
    titleEn: "Customs Broker Authorization",
    descriptionEn:
      "Authorizes the Gloval customs broker (or its correspondent) to act on behalf of the importer.",
    category: "aduanas",
    language: "es-en",
    format: "PDF",
    filename: "Customs_Broker_Authorization.pdf",
    placeholder: true,
  },
  {
    id: "carta-cesion",
    title: "Carta de Cesión de Derechos (Ecuador / Perú)",
    description:
      "Documento usado en aduanas LATAM para ceder derechos de importación a un tercero.",
    titleEn: "Assignment of Rights Letter (Ecuador / Peru)",
    descriptionEn:
      "Document used in LATAM customs to assign import rights to a third party.",
    category: "aduanas",
    language: "es",
    format: "DOCX",
    filename: "Carta_Cesion_Derechos.docx",
    placeholder: true,
  },
  {
    id: "anexo-24",
    title: "Anexo 24 (México)",
    description:
      "Formato del SAT para empresas IMMEX — control de inventarios de programas de fomento.",
    titleEn: "Annex 24 (Mexico)",
    descriptionEn:
      "Mexican SAT form for IMMEX companies — inventory control for promotion programs.",
    category: "aduanas",
    language: "es",
    format: "XLSX",
    filename: "Anexo_24_SAT_Mexico.xlsx",
    placeholder: true,
  },

  // COMERCIAL
  {
    id: "tyc",
    title: "Términos y Condiciones Generales",
    description:
      "T&C generales de los servicios de Gloval Shipping. Aplican a toda contratación.",
    titleEn: "General Terms & Conditions",
    descriptionEn:
      "General T&Cs covering Gloval Shipping services. Apply to every engagement.",
    category: "comercial",
    language: "es-en",
    format: "PDF",
    filename: "Terminos_y_Condiciones_Gloval.pdf",
    placeholder: true,
  },
  {
    id: "credit-app",
    title: "Solicitud de Línea de Crédito",
    description:
      "Formulario para solicitar términos de pago a crédito — requiere referencias comerciales y bancarias.",
    titleEn: "Credit Line Application",
    descriptionEn:
      "Form to request credit payment terms — requires trade and bank references.",
    category: "comercial",
    language: "es",
    format: "PDF",
    filename: "Solicitud_Linea_Credito_Gloval.pdf",
    placeholder: true,
  },
  {
    id: "service-contract",
    title: "Contrato Marco de Servicios Logísticos",
    description:
      "Plantilla de contrato para clientes recurrentes con volúmenes anuales acordados.",
    titleEn: "Master Logistics Services Agreement",
    descriptionEn:
      "Contract template for recurring clients with agreed annual volumes.",
    category: "comercial",
    language: "es",
    format: "DOCX",
    filename: "Contrato_Marco_Servicios_Logisticos.docx",
    placeholder: true,
  },

  // CONTACTOS
  {
    id: "office-directory",
    title: "Directorio de Oficinas Gloval",
    description:
      "Lista completa de oficinas (Miami, Panamá, Guayaquil, Lima) con direcciones, teléfonos, emails y horarios.",
    titleEn: "Gloval Office Directory",
    descriptionEn:
      "Full office list (Miami, Panama, Guayaquil, Lima) with addresses, phones, emails, and hours.",
    category: "contactos",
    language: "es-en",
    format: "PDF",
    filename: "Directorio_Oficinas_Gloval.pdf",
    placeholder: true,
  },
  {
    id: "dept-directory",
    title: "Directorio por Departamento",
    description:
      "Contactos directos por área: Pricing, Customer Service, Operaciones, Cobranzas, Aduanas, Compliance.",
    titleEn: "Department Directory",
    descriptionEn:
      "Direct contacts by area: Pricing, Customer Service, Operations, Collections, Customs, Compliance.",
    category: "contactos",
    language: "es",
    format: "PDF",
    filename: "Directorio_Departamentos_Gloval.pdf",
    placeholder: true,
  },
  {
    id: "emergency",
    title: "Contactos de Emergencia 24/7",
    description:
      "Línea de emergencia operativa fuera de horario y por país (incidentes, demoras críticas, mercancía retenida).",
    titleEn: "24/7 Emergency Contacts",
    descriptionEn:
      "After-hours operations line by country (incidents, critical delays, cargo holds).",
    category: "contactos",
    language: "es-en",
    format: "PDF",
    filename: "Contactos_Emergencia_24_7.pdf",
    placeholder: true,
  },
];

export function searchDocuments(query: string, category?: DocCategory | "all") {
  const q = query.trim().toLowerCase();
  return DOCUMENTS.filter((d) => {
    if (category && category !== "all" && d.category !== category) return false;
    if (!q) return true;
    return (
      d.title.toLowerCase().includes(q) ||
      d.description.toLowerCase().includes(q) ||
      d.id.toLowerCase().includes(q)
    );
  });
}

export const FORMAT_COLOR: Record<DocFormat, { bg: string; fg: string }> = {
  PDF:  { bg: "#FEE2E2", fg: "#B91C1C" },
  DOCX: { bg: "#DBEAFE", fg: "#1E40AF" },
  XLSX: { bg: "#D1FAE5", fg: "#047857" },
  ZIP:  { bg: "#F3F4F6", fg: "#374151" },
};

export const LANGUAGE_LABEL: Record<DocLanguage, string> = {
  es: "ES",
  en: "EN",
  "es-en": "ES / EN",
};
