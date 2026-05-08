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
