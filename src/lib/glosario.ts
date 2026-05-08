/**
 * Glosario logístico — términos comunes en comercio internacional con foco LATAM.
 *
 * Cada entrada es editable directamente en este archivo. Si querés agregar
 * términos, copiá una entry existente, cambiá los campos y la pagina los
 * indexa automáticamente (search, A-Z, filtro por categoría).
 */

export type GlossaryCategory =
  | "documentos"
  | "contenedores"
  | "transporte"
  | "aduanas"
  | "tarifas"
  | "operaciones"
  | "latam"
  | "general";

export interface GlossaryTerm {
  /** Acrónimo o sigla (cuando aplique) */
  acronym?: string;
  /** Nombre completo del término */
  term: string;
  /** Definición */
  definition: string;
  /** Categoría principal */
  category: GlossaryCategory;
  /** Tags adicionales (ej: ["LATAM"], ["solo aéreo"]) */
  tags?: string[];
  /** IDs de términos relacionados (matching contra `term` o `acronym` slug) */
  relatedSlugs?: string[];
}

export const CATEGORY_LABEL: Record<GlossaryCategory, string> = {
  documentos: "Documentos",
  contenedores: "Contenedores",
  transporte: "Transporte",
  aduanas: "Aduanas",
  tarifas: "Tarifas y cargos",
  operaciones: "Operaciones",
  latam: "LATAM",
  general: "General",
};

export const GLOSSARY: GlossaryTerm[] = [
  // A
  { acronym: "AWB",  term: "Air Waybill",                category: "documentos", definition: "Documento de transporte aéreo emitido por la aerolínea o consolidador. Funciona como recibo de la mercancía y contrato de transporte. NO es título valor (no es negociable como sí lo es el BL marítimo).", tags: ["aéreo"], relatedSlugs: ["bl", "mawb", "hawb"] },
  { acronym: "AEO",  term: "Authorized Economic Operator", category: "aduanas", definition: "Estatus otorgado por la aduana a empresas con cumplimiento aduanero ejemplar. Otorga beneficios como inspecciones reducidas, despacho prioritario y reconocimiento mutuo entre países.", tags: ["compliance"] },
  { acronym: "ALADI", term: "Asociación Latinoamericana de Integración", category: "latam", definition: "Bloque de integración económica que agrupa 13 países LATAM. Administra preferencias arancelarias y acuerdos comerciales bilaterales.", tags: ["LATAM"], relatedSlugs: ["can", "mercosur"] },
  { acronym: "ATA",  term: "Carnet ATA", category: "aduanas", definition: "Documento aduanero internacional para importación temporal libre de derechos (muestras, equipos profesionales, exhibiciones). Válido hasta 1 año.", relatedSlugs: ["temporal-import"] },

  // B
  { acronym: "BAF",  term: "Bunker Adjustment Factor", category: "tarifas", definition: "Sobrecargo de combustible en el flete marítimo. Compensa fluctuaciones del precio del bunker (combustible del buque). Se cobra como % o monto fijo por contenedor.", relatedSlugs: ["caf", "lss"] },
  { acronym: "BL",   term: "Bill of Lading", category: "documentos", definition: "Documento marítimo emitido por la naviera o NVOCC. Cumple tres funciones: recibo de la mercancía, contrato de transporte y título valor (es negociable, transfiere propiedad).", relatedSlugs: ["mbl", "hbl", "awb"] },
  {                  term: "Booking",                   category: "operaciones", definition: "Reserva de espacio en un buque o vuelo de carga. Asigna número de booking, vessel, voyage y cut-off.", relatedSlugs: ["cut-off"] },
  {                  term: "Break-bulk",                category: "transporte", definition: "Carga general que NO va contenedorizada — se manipula pieza por pieza (vehículos, maquinaria pesada, sacos, bobinas). Requiere buques especializados.", relatedSlugs: ["bulk", "ro-ro"] },
  {                  term: "Bulk",                       category: "transporte", definition: "Carga a granel transportada sin embalaje (granos, minerales, líquidos). Bulk carrier para sólidos, tanker para líquidos.", relatedSlugs: ["break-bulk"] },

  // C
  { acronym: "CAF",  term: "Currency Adjustment Factor", category: "tarifas", definition: "Sobrecargo cambiario en flete marítimo. Compensa fluctuaciones del USD vs. moneda local del armador.", relatedSlugs: ["baf"] },
  { acronym: "CAN",  term: "Comunidad Andina de Naciones", category: "latam", definition: "Bloque económico integrado por Bolivia, Colombia, Ecuador y Perú. Tiene zona de libre comercio interna (NANDINA como arancel común).", tags: ["LATAM"], relatedSlugs: ["aladi", "mercosur", "naladisa"] },
  { acronym: "CFS",  term: "Container Freight Station", category: "operaciones", definition: "Almacén donde se consolidan (stuffing) o desconsolidan (stripping) contenedores LCL. Generalmente dentro o cerca del puerto.", relatedSlugs: ["cy", "stuffing", "stripping"] },
  { acronym: "COO",  term: "Certificate of Origin", category: "documentos", definition: "Certificado que acredita el país de origen de la mercancía. Necesario para aprovechar preferencias arancelarias bajo TLCs (CAN, MERCOSUR, USMCA, ALADI).", relatedSlugs: ["form-a", "tlc"] },
  {                  term: "Consignatario / Consignee", category: "documentos", definition: "Parte a quien se le entrega la mercancía en destino. Figura en el BL como dueño de la carga al arribo. NO necesariamente es el comprador.", relatedSlugs: ["shipper", "notify-party"] },
  {                  term: "Consolidación / Consolidation", category: "operaciones", definition: "Agrupación de varios envíos LCL en un solo contenedor para optimizar flete. La hace un consolidador (NVOCC o forwarder).", relatedSlugs: ["nvocc", "lcl", "stuffing"] },
  { acronym: "CY",   term: "Container Yard", category: "operaciones", definition: "Patio de contenedores dentro del terminal portuario. Punto donde se entrega el FCL al cargar y donde se recoge en destino.", relatedSlugs: ["cfs"] },
  {                  term: "Cut-off (Stack date)", category: "operaciones", definition: "Fecha y hora límite para entregar el contenedor en el terminal antes del zarpe. Después de cut-off, la naviera no garantiza embarque en el vessel reservado.", relatedSlugs: ["booking", "rolling"] },

  // D
  { acronym: "DAU",  term: "Declaración Aduanera Única", category: "latam", definition: "Documento aduanero usado en varios países LATAM (Ecuador, Bolivia, Colombia con variantes) para declarar import/export. Equivalente al SAD europeo.", tags: ["LATAM"], relatedSlugs: ["dua", "pedimento", "sad"] },
  {                  term: "Demurrage", category: "tarifas", definition: "Cargo por exceso de tiempo del contenedor DENTRO del terminal portuario, después de los días libres (free time) post-arribo. Lo cobra la naviera.", relatedSlugs: ["detention", "free-time"] },
  {                  term: "Detention", category: "tarifas", definition: "Cargo por exceso de tiempo del contenedor FUERA del terminal (en bodega del cliente) sin devolverlo a la naviera. Diferente del demurrage.", relatedSlugs: ["demurrage", "free-time"] },
  { acronym: "DGD",  term: "Dangerous Goods Declaration", category: "documentos", definition: "Declaración formal del shipper para envíos de mercancías peligrosas (IMDG marítimo / IATA-DGR aéreo). Requiere certificación del firmante.", tags: ["peligrosos"], relatedSlugs: ["imdg", "iata-dgr", "un-number"] },
  { acronym: "DIAN", term: "Dirección de Impuestos y Aduanas Nacionales", category: "latam", definition: "Autoridad aduanera y tributaria de Colombia. Administra el SIIA (Sistema Integrado de Información Aduanera).", tags: ["Colombia"] },
  {                  term: "Drayage", category: "transporte", definition: "Transporte terrestre de corta distancia entre puerto/terminal y bodega o CFS. Tipicamente camión.", relatedSlugs: ["inland-transport"] },
  { acronym: "DUA",  term: "Declaración Única de Aduana", category: "latam", definition: "En Perú y Ecuador es el documento principal de despacho aduanero — declara mercancía, valor, origen y régimen ante SUNAT/SENAE.", tags: ["Perú", "Ecuador"], relatedSlugs: ["dau", "sunat", "senae"] },

  // E
  { acronym: "ETA",  term: "Estimated Time of Arrival", category: "operaciones", definition: "Fecha y hora estimadas de arribo al puerto/aeropuerto destino. Sujeto a cambios por demoras operativas.", relatedSlugs: ["etd", "eta-vs-rta"] },
  { acronym: "ETD",  term: "Estimated Time of Departure", category: "operaciones", definition: "Fecha y hora estimadas de zarpe del puerto/aeropuerto origen.", relatedSlugs: ["eta"] },
  {                  term: "Express BL / Telex Release", category: "documentos", definition: "Modalidad sin emisión física de BL original. La naviera libera la carga al consignatario sin que él presente el BL en papel — lo confirma vía 'telex release' del shipper.", relatedSlugs: ["bl", "obl"] },

  // F
  { acronym: "FCL",  term: "Full Container Load", category: "transporte", definition: "Modalidad donde un solo embarcador llena un contenedor completo (20', 40', 40HC, 45HC). Se cobra flete por contenedor, no por volumen.", relatedSlugs: ["lcl", "fcx", "container"] },
  {                  term: "Feeder vessel", category: "transporte", definition: "Buque pequeño que transporta carga entre un hub principal (como Manzanillo o Cartagena) y puertos secundarios LATAM. Permite cobertura sin que el buque madre pase por cada puerto.", relatedSlugs: ["transhipment", "hub"] },
  { acronym: "FEU",  term: "Forty-foot Equivalent Unit", category: "contenedores", definition: "Unidad de medida equivalente a un contenedor 40'. 1 FEU = 2 TEU. Usado para medir capacidad de buques y volumen de tráfico.", relatedSlugs: ["teu", "container"] },
  {                  term: "Flat Rack", category: "contenedores", definition: "Contenedor sin paredes laterales ni techo, solo piso reforzado. Para carga sobredimensionada (over-height u over-width) que no entra en contenedor estándar.", relatedSlugs: ["open-top", "oog"] },
  {                  term: "Forwarder / Freight Forwarder", category: "general", definition: "Operador logístico que organiza el transporte internacional en nombre del shipper o consignee. No mueve la carga directamente; contrata navieras, aerolíneas y terrestres.", relatedSlugs: ["nvocc", "broker"] },
  {                  term: "Free time", category: "tarifas", definition: "Días libres que da la naviera para usar el contenedor sin cobrar demurrage o detention. Típicamente 3–7 días en LATAM, negociable según volumen.", relatedSlugs: ["demurrage", "detention"] },
  {                  term: "Freight collect / prepaid", category: "tarifas", definition: "Collect = el flete se cobra al consignatario en destino. Prepaid = el shipper paga el flete en origen. Define quién emite el cheque al armador.", relatedSlugs: ["incoterms"] },

  // G
  { acronym: "GRI",  term: "General Rate Increase", category: "tarifas", definition: "Aumento general de tarifas de flete marítimo aplicado por las navieras, típicamente al inicio de cada trimestre. Anunciado con 30 días de anticipación.", relatedSlugs: ["pss", "baf"] },

  // H
  { acronym: "HAWB", term: "House Air Waybill", category: "documentos", definition: "AWB emitido por el forwarder o consolidador al shipper individual. Funciona como recibo y contrato dentro de un consolidado aéreo.", relatedSlugs: ["mawb", "awb", "hbl"] },
  { acronym: "HBL",  term: "House Bill of Lading", category: "documentos", definition: "BL emitido por el forwarder o NVOCC al shipper individual. Coexiste con un MBL emitido por la naviera al NVOCC en una operación consolidada.", relatedSlugs: ["mbl", "bl", "hawb"] },
  {                  term: "High Cube (HC)", category: "contenedores", definition: "Contenedor con altura interna mayor (2.698 m vs. 2.393 m del estándar). Disponible en 40' y 45'. Aumenta capacidad cúbica ~13%.", relatedSlugs: ["dc", "container", "fcl"] },
  { acronym: "HS",   term: "Harmonized System Code", category: "aduanas", definition: "Sistema armonizado de codificación arancelaria de la OMA. 6 dígitos universales; cada país agrega 2–4 dígitos adicionales (NANDINA en CAN, NCM en MERCOSUR, NALADISA en ALADI).", relatedSlugs: ["nandina", "ncm", "naladisa"] },

  // I
  { acronym: "IATA", term: "International Air Transport Association", category: "general", definition: "Asociación de aerolíneas que regula transporte aéreo de carga, incluyendo regulaciones de mercancías peligrosas (IATA-DGR) y códigos de aeropuertos.", tags: ["aéreo"], relatedSlugs: ["dgd", "iata-dgr"] },
  { acronym: "IMDG", term: "International Maritime Dangerous Goods Code", category: "documentos", definition: "Código internacional para transporte marítimo de mercancías peligrosas. Define las 9 clases, etiquetado, segregación y declaración.", tags: ["peligrosos"], relatedSlugs: ["dgd", "imo"] },
  { acronym: "IMO",  term: "International Maritime Organization", category: "general", definition: "Agencia de la ONU para asuntos marítimos. Emite normativas (SOLAS, MARPOL, IMDG) y asigna números IMO únicos a buques y mercancías peligrosas.", relatedSlugs: ["imdg", "un-number", "vgm"] },
  { acronym: "ISF",  term: "Importer Security Filing (10+2)", category: "aduanas", definition: "Declaración requerida por CBP de USA: 10 datos del importador + 2 del transportista. Debe presentarse 24h antes del embarque desde origen. Multa USD 5.000 por falta de presentación.", tags: ["USA"], relatedSlugs: ["cbp", "broker"] },
  { acronym: "ISPS", term: "International Ship and Port Facility Security", category: "tarifas", definition: "Sobrecargo de seguridad establecido por el código ISPS post-9/11. Aplica a todo embarque marítimo internacional, monto fijo por contenedor o BL.", relatedSlugs: ["surcharges"] },

  // L
  {                  term: "LATAM", category: "general", definition: "Región de América Latina. En logística internacional típicamente refiere a México y Centro+Sudamérica como zona comercial. Gloval Shipping opera con red propia en USA, Panamá, Ecuador y Perú.", tags: ["LATAM"] },
  { acronym: "LCL",  term: "Less than Container Load", category: "transporte", definition: "Modalidad donde varios shippers comparten el mismo contenedor. Se cobra flete por volumen (CBM) o peso, lo que sea mayor. Tránsito ligeramente más lento por consolidación / desconsolidación.", relatedSlugs: ["fcl", "cfs", "consolidacion"] },
  {                  term: "LOCODE (UN/LOCODE)", category: "general", definition: "Código de 5 caracteres para identificar puertos, aeropuertos y terminales (2 país + 3 lugar). Ej: ECGYE = Ecuador / Guayaquil. Mantenido por UNECE.", relatedSlugs: ["unece"] },

  // M
  {                  term: "Manifiesto / Manifest", category: "documentos", definition: "Listado oficial de toda la carga abordo de un buque o vuelo. Lo presenta el operador a la aduana antes del arribo. En LATAM se transmite electrónicamente (SIIA, ECUAPASS).", relatedSlugs: ["bl", "ecuapass"] },
  { acronym: "MAWB", term: "Master Air Waybill", category: "documentos", definition: "AWB emitido por la aerolínea al consolidador (forwarder/NVOCC). En consolidaciones aéreas, coexiste con HAWBs emitidos por el consolidador a sus clientes.", relatedSlugs: ["hawb", "awb"] },
  { acronym: "MBL",  term: "Master Bill of Lading", category: "documentos", definition: "BL emitido por la naviera al NVOCC o forwarder. En operaciones consolidadas, coexiste con HBLs emitidos por el NVOCC a cada shipper.", relatedSlugs: ["hbl", "bl"] },
  {                  term: "MERCOSUR", category: "latam", definition: "Mercado Común del Sur — bloque integrado por Argentina, Brasil, Paraguay, Uruguay (+ Bolivia y Venezuela suspendidos). Usa el arancel NCM y tiene zona de libre comercio interna.", tags: ["LATAM"], relatedSlugs: ["aladi", "can", "ncm"] },
  {                  term: "Multimodal transport", category: "transporte", definition: "Combinación de dos o más modalidades de transporte (mar + tierra + aire) bajo un solo contrato y BL. Ej: vessel a Los Angeles → camión a Miami → vuelo a Quito.", relatedSlugs: ["intermodal", "fcl"] },

  // N
  { acronym: "NCM",  term: "Nomenclatura Común del MERCOSUR", category: "aduanas", definition: "Sistema arancelario de 8 dígitos usado por MERCOSUR. Basado en HS internacional + 2 dígitos propios. Equivalente a NANDINA en CAN.", tags: ["MERCOSUR"], relatedSlugs: ["hs", "naladisa", "nandina"] },
  { acronym: "NALADISA", term: "Nomenclatura ALADI Sistema Armonizado", category: "aduanas", definition: "Sistema arancelario de 8 dígitos usado en ALADI para preferencias entre países miembro. Permite identificar productos beneficiados por acuerdos.", tags: ["LATAM"], relatedSlugs: ["aladi", "ncm", "nandina"] },
  { acronym: "NANDINA", term: "Nomenclatura Andina", category: "aduanas", definition: "Sistema arancelario de 10 dígitos usado por la Comunidad Andina (Bolivia, Colombia, Ecuador, Perú). HS de 6 + 4 dígitos andinos.", tags: ["CAN"], relatedSlugs: ["can", "ncm"] },
  { acronym: "NVOCC", term: "Non-Vessel Operating Common Carrier", category: "general", definition: "Operador que actúa como naviera (emite su propio BL) sin poseer buques. Compra espacio a navieras reales y revende a sus clientes.", relatedSlugs: ["forwarder", "hbl"] },

  // O
  { acronym: "OBL",  term: "Original Bill of Lading", category: "documentos", definition: "BL en papel firmado por la naviera, único título valor que se debe presentar para retirar la mercancía. Normalmente se emiten 3 originales (juego de 3).", relatedSlugs: ["bl", "telex-release"] },
  {                  term: "Open Top", category: "contenedores", definition: "Contenedor sin techo (cubierto por lona). Para carga over-height que no entra por la puerta normal — se carga por arriba con grúa.", relatedSlugs: ["flat-rack", "container"] },
  {                  term: "OOG (Out of Gauge)", category: "contenedores", definition: "Carga que excede dimensiones de un contenedor estándar. Requiere flat rack, open top, o break-bulk. Tarifa más alta y restricciones operativas.", relatedSlugs: ["flat-rack", "open-top"] },

  // P
  {                  term: "Packing List", category: "documentos", definition: "Detalle de bultos de un envío: cantidad, dimensiones, peso bruto/neto, marcas y numeración. Acompaña la factura comercial.", relatedSlugs: ["commercial-invoice", "bl"] },
  {                  term: "Pedimento (México)", category: "latam", definition: "Documento aduanero principal en México para importación, exportación, tránsito y régimen virtual. Equivalente al DUA andino.", tags: ["México"], relatedSlugs: ["dau", "dua"] },
  { acronym: "POD",  term: "Port of Discharge / Proof of Delivery", category: "operaciones", definition: "POD tiene dos significados: (1) Port of Discharge = puerto donde se descarga del buque. (2) Proof of Delivery = comprobante firmado de entrega final al consignee.", relatedSlugs: ["pol"] },
  { acronym: "POL",  term: "Port of Loading", category: "operaciones", definition: "Puerto donde se carga la mercancía a bordo del buque para iniciar el tránsito principal.", relatedSlugs: ["pod"] },
  { acronym: "PSS",  term: "Peak Season Surcharge", category: "tarifas", definition: "Sobrecargo aplicado por navieras durante temporadas de alta demanda (típicamente Q3-Q4 ruta Asia → USA/LATAM). Anunciado con anticipación.", relatedSlugs: ["gri", "baf"] },

  // R
  {                  term: "Reefer", category: "contenedores", definition: "Contenedor refrigerado con sistema propio de refrigeración. Para mercancía que requiere temperatura controlada (alimentos, farma, flores). Disponible en 20' y 40' HC.", relatedSlugs: ["container", "cold-chain"] },
  { acronym: "Ro-Ro", term: "Roll-on / Roll-off", category: "transporte", definition: "Modalidad para vehículos motorizados y maquinaria — la carga rueda sola al buque. Buques especializados con rampas integradas.", relatedSlugs: ["break-bulk"] },

  // S
  { acronym: "SENAE", term: "Servicio Nacional de Aduana del Ecuador", category: "latam", definition: "Autoridad aduanera de Ecuador. Administra ECUAPASS para gestión electrónica de operaciones. Su DUA equivalente se llama Declaración Aduanera de Importación.", tags: ["Ecuador"], relatedSlugs: ["ecuapass", "dua"] },
  { acronym: "SLI",  term: "Shipper's Letter of Instructions", category: "documentos", definition: "Carta del embarcador al forwarder con instrucciones detalladas: incoterm, datos del consignee/notify, ruta, modalidad, tipo de BL, servicios contratados.", relatedSlugs: ["si", "booking"] },
  {                  term: "Shipper / Embarcador", category: "documentos", definition: "Parte que envía la mercancía. Contrata el transporte y figura como tal en el BL/AWB. Generalmente coincide con el vendedor.", relatedSlugs: ["consignatario", "notify-party"] },
  {                  term: "Stripping (deconsolidación)", category: "operaciones", definition: "Proceso de vaciar un contenedor LCL en el CFS de destino y separar la carga por consignatario. Lo opuesto al stuffing.", relatedSlugs: ["stuffing", "cfs", "lcl"] },
  {                  term: "Stuffing (consolidación)", category: "operaciones", definition: "Proceso de cargar un contenedor — desde piezas sueltas en el CFS (LCL) o desde el almacén del cliente (FCL).", relatedSlugs: ["stripping", "cfs", "fcl"] },
  { acronym: "SUNAT", term: "Superintendencia Nacional de Aduanas y de Administración Tributaria", category: "latam", definition: "Autoridad aduanera y tributaria de Perú. Administra la DUA peruana y los regímenes aduaneros.", tags: ["Perú"], relatedSlugs: ["dua"] },

  // T
  { acronym: "TEU",  term: "Twenty-foot Equivalent Unit", category: "contenedores", definition: "Unidad estándar para medir capacidad de buques y volumen portuario. 1 TEU = 1 contenedor 20'. Un 40' = 2 TEU.", relatedSlugs: ["feu"] },
  { acronym: "THC",  term: "Terminal Handling Charges", category: "tarifas", definition: "Cargos por manipuleo del contenedor en terminal portuario (carga, descarga, movimientos). Hay THC origen y THC destino, pueden estar incluidos en el flete o cobrarse aparte.", relatedSlugs: ["surcharges"] },
  {                  term: "Transhipment / Transbordo", category: "operaciones", definition: "Cambio de buque durante el tránsito en un puerto hub (ej. Manzanillo Panamá, Cartagena). Permite conectar puertos donde no llega el buque madre directamente.", relatedSlugs: ["feeder", "hub"] },
  {                  term: "Through Bill of Lading", category: "documentos", definition: "BL único que cubre todo el recorrido incluyendo transbordos y/o transporte multimodal. Una sola pieza de papel para origen → destino final.", relatedSlugs: ["bl", "multimodal"] },

  // U
  {                  term: "UN Number", category: "documentos", definition: "Identificador único de 4 dígitos para mercancías peligrosas (UN0001 a UN3559). Asignado por la ONU. Determina clase IMDG, packing group y proper shipping name.", tags: ["peligrosos"], relatedSlugs: ["imdg", "dgd"] },

  // V
  { acronym: "VGM",  term: "Verified Gross Mass", category: "documentos", definition: "Peso bruto verificado del contenedor lleno. Obligatorio bajo SOLAS desde 2016 — debe declararse antes del embarque o el contenedor no carga. Se calcula pesando o por método 2 (suma de pesos individuales).", tags: ["compliance"], relatedSlugs: ["solas"] },
  {                  term: "Voyage", category: "operaciones", definition: "Número de viaje del buque. Identifica un servicio puntual de la línea (ej. MAERSK SEMARANG voy. 447S). Importante para tracking y reservas.", relatedSlugs: ["vessel"] },

  // Z
  {                  term: "Zona Franca", category: "latam", definition: "Territorio aduanero especial donde se almacena, transforma o reexporta mercancía sin pago de aranceles. En Panamá: ZLC (Colón), en otros países hay Zonas Francas industriales y comerciales.", tags: ["LATAM"], relatedSlugs: ["zlc"] },
  { acronym: "ZLC",  term: "Zona Libre de Colón (Panamá)", category: "latam", definition: "La mayor zona franca del hemisferio occidental, ubicada en Colón, Panamá. Hub de redistribución para LATAM y Caribe.", tags: ["Panamá"], relatedSlugs: ["zona-franca"] },
];

export function termSlug(t: GlossaryTerm): string {
  return (t.acronym ?? t.term).toLowerCase().replace(/[^a-z0-9]/g, "-").replace(/-+/g, "-").replace(/^-|-$/g, "");
}

export function searchGlossary(q: string, category?: GlossaryCategory | "all"): GlossaryTerm[] {
  const query = q.trim().toLowerCase();
  return GLOSSARY.filter((t) => {
    if (category && category !== "all" && t.category !== category) return false;
    if (!query) return true;
    return (
      t.term.toLowerCase().includes(query) ||
      (t.acronym?.toLowerCase().includes(query) ?? false) ||
      t.definition.toLowerCase().includes(query) ||
      (t.tags?.some((g) => g.toLowerCase().includes(query)) ?? false)
    );
  });
}

export function groupByLetter(terms: GlossaryTerm[]) {
  const groups = new Map<string, GlossaryTerm[]>();
  for (const t of terms) {
    const head = (t.acronym ?? t.term).charAt(0).toUpperCase();
    if (!groups.has(head)) groups.set(head, []);
    groups.get(head)!.push(t);
  }
  // Sort each group alphabetically
  for (const [k, list] of groups) {
    list.sort((a, b) =>
      (a.acronym ?? a.term).localeCompare(b.acronym ?? b.term, "es"),
    );
    groups.set(k, list);
  }
  // Sort keys alphabetically
  return new Map([...groups.entries()].sort());
}

export const ALL_LETTERS = [
  "A","B","C","D","E","F","G","H","I","J","K","L","M",
  "N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
];
