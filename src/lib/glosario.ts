/**
 * Glosario logístico — términos comunes en comercio internacional con foco LATAM.
 *
 * Cada entrada es editable directamente en este archivo. Si querés agregar
 * términos, copiá una entry existente, cambiá los campos y la pagina los
 * indexa automáticamente (search, A-Z, filtro por categoría).
 *
 * EN translations live in optional `termEn` and `definitionEn` fields — when
 * absent, /tools/glossary falls back to the Spanish text.
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
  /** Nombre completo del término (ES) */
  term: string;
  /** Definición (ES) */
  definition: string;
  /** Optional EN translations — used by /tools/glossary. */
  termEn?: string;
  definitionEn?: string;
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
  { acronym: "AWB",  term: "Air Waybill",                category: "documentos", definition: "Documento de transporte aéreo emitido por la aerolínea o consolidador. Funciona como recibo de la mercancía y contrato de transporte. NO es título valor (no es negociable como sí lo es el BL marítimo).", termEn: "Air Waybill", definitionEn: "Air transport document issued by the airline or consolidator. Acts as a receipt and contract of carriage. Unlike the ocean BL, it is NOT a document of title (not negotiable).", tags: ["aéreo"], relatedSlugs: ["bl", "mawb", "hawb"] },
  { acronym: "AEO",  term: "Authorized Economic Operator", category: "aduanas", definition: "Estatus otorgado por la aduana a empresas con cumplimiento aduanero ejemplar. Otorga beneficios como inspecciones reducidas, despacho prioritario y reconocimiento mutuo entre países.", termEn: "Authorized Economic Operator", definitionEn: "Customs status granted to companies with an exemplary compliance record. Benefits include reduced inspections, priority clearance, and mutual recognition between countries.", tags: ["compliance"] },
  { acronym: "ALADI", term: "Asociación Latinoamericana de Integración", category: "latam", definition: "Bloque de integración económica que agrupa 13 países LATAM. Administra preferencias arancelarias y acuerdos comerciales bilaterales.", termEn: "Latin American Integration Association", definitionEn: "Economic integration bloc of 13 LATAM countries. Administers tariff preferences and bilateral trade agreements.", tags: ["LATAM"], relatedSlugs: ["can", "mercosur"] },
  { acronym: "ATA",  term: "Carnet ATA", category: "aduanas", definition: "Documento aduanero internacional para importación temporal libre de derechos (muestras, equipos profesionales, exhibiciones). Válido hasta 1 año.", termEn: "ATA Carnet", definitionEn: "International customs document for duty-free temporary import (samples, professional equipment, exhibitions). Valid for up to 1 year.", relatedSlugs: ["temporal-import"] },

  // B
  { acronym: "BAF",  term: "Bunker Adjustment Factor", category: "tarifas", definition: "Sobrecargo de combustible en el flete marítimo. Compensa fluctuaciones del precio del bunker (combustible del buque). Se cobra como % o monto fijo por contenedor.", termEn: "Bunker Adjustment Factor", definitionEn: "Fuel surcharge on ocean freight. Offsets bunker fuel price swings. Charged as a % or fixed amount per container.", relatedSlugs: ["caf", "lss"] },
  { acronym: "BL",   term: "Bill of Lading", category: "documentos", definition: "Documento marítimo emitido por la naviera o NVOCC. Cumple tres funciones: recibo de la mercancía, contrato de transporte y título valor (es negociable, transfiere propiedad).", termEn: "Bill of Lading", definitionEn: "Ocean transport document issued by the carrier or NVOCC. Serves three roles: cargo receipt, contract of carriage, and document of title (negotiable, transfers ownership).", relatedSlugs: ["mbl", "hbl", "awb"] },
  {                  term: "Booking",                   category: "operaciones", definition: "Reserva de espacio en un buque o vuelo de carga. Asigna número de booking, vessel, voyage y cut-off.", termEn: "Booking", definitionEn: "Space reservation on a vessel or cargo flight. Assigns booking number, vessel, voyage, and cut-off.", relatedSlugs: ["cut-off"] },
  {                  term: "Break-bulk",                category: "transporte", definition: "Carga general que NO va contenedorizada — se manipula pieza por pieza (vehículos, maquinaria pesada, sacos, bobinas). Requiere buques especializados.", termEn: "Break-bulk", definitionEn: "General cargo that is NOT containerized — handled piece by piece (vehicles, heavy machinery, bags, coils). Requires specialized vessels.", relatedSlugs: ["bulk", "ro-ro"] },
  {                  term: "Bulk",                       category: "transporte", definition: "Carga a granel transportada sin embalaje (granos, minerales, líquidos). Bulk carrier para sólidos, tanker para líquidos.", termEn: "Bulk", definitionEn: "Loose cargo carried without packaging (grain, minerals, liquids). Bulk carrier for dry, tanker for liquid.", relatedSlugs: ["break-bulk"] },

  // C
  { acronym: "CAF",  term: "Currency Adjustment Factor", category: "tarifas", definition: "Sobrecargo cambiario en flete marítimo. Compensa fluctuaciones del USD vs. moneda local del armador.", termEn: "Currency Adjustment Factor", definitionEn: "Currency surcharge on ocean freight. Offsets USD swings against the carrier's local currency.", relatedSlugs: ["baf"] },
  { acronym: "CAN",  term: "Comunidad Andina de Naciones", category: "latam", definition: "Bloque económico integrado por Bolivia, Colombia, Ecuador y Perú. Tiene zona de libre comercio interna (NANDINA como arancel común).", termEn: "Andean Community", definitionEn: "Economic bloc made up of Bolivia, Colombia, Ecuador, and Peru. Operates an internal free-trade area (NANDINA as the common tariff).", tags: ["LATAM"], relatedSlugs: ["aladi", "mercosur", "naladisa"] },
  { acronym: "CFS",  term: "Container Freight Station", category: "operaciones", definition: "Almacén donde se consolidan (stuffing) o desconsolidan (stripping) contenedores LCL. Generalmente dentro o cerca del puerto.", termEn: "Container Freight Station", definitionEn: "Warehouse where LCL containers are stuffed or stripped. Typically inside or near the port.", relatedSlugs: ["cy", "stuffing", "stripping"] },
  { acronym: "COO",  term: "Certificate of Origin", category: "documentos", definition: "Certificado que acredita el país de origen de la mercancía. Necesario para aprovechar preferencias arancelarias bajo TLCs (CAN, MERCOSUR, USMCA, ALADI).", termEn: "Certificate of Origin", definitionEn: "Certifies the country of origin of the goods. Required to claim tariff preferences under FTAs (CAN, MERCOSUR, USMCA, ALADI).", relatedSlugs: ["form-a", "tlc"] },
  {                  term: "Consignatario / Consignee", category: "documentos", definition: "Parte a quien se le entrega la mercancía en destino. Figura en el BL como dueño de la carga al arribo. NO necesariamente es el comprador.", termEn: "Consignee", definitionEn: "Party to whom the goods are delivered at destination. Shown on the BL as the cargo owner on arrival. NOT necessarily the buyer.", relatedSlugs: ["shipper", "notify-party"] },
  {                  term: "Consolidación / Consolidation", category: "operaciones", definition: "Agrupación de varios envíos LCL en un solo contenedor para optimizar flete. La hace un consolidador (NVOCC o forwarder).", termEn: "Consolidation", definitionEn: "Grouping multiple LCL shipments into a single container to optimize freight. Done by a consolidator (NVOCC or forwarder).", relatedSlugs: ["nvocc", "lcl", "stuffing"] },
  { acronym: "CY",   term: "Container Yard", category: "operaciones", definition: "Patio de contenedores dentro del terminal portuario. Punto donde se entrega el FCL al cargar y donde se recoge en destino.", termEn: "Container Yard", definitionEn: "Container yard inside the port terminal. Drop-off point for the FCL at origin and pickup point at destination.", relatedSlugs: ["cfs"] },
  {                  term: "Cut-off (Stack date)", category: "operaciones", definition: "Fecha y hora límite para entregar el contenedor en el terminal antes del zarpe. Después de cut-off, la naviera no garantiza embarque en el vessel reservado.", termEn: "Cut-off (Stack date)", definitionEn: "Deadline to deliver the container at the terminal before vessel departure. After cut-off, the carrier no longer guarantees loading on the booked vessel.", relatedSlugs: ["booking", "rolling"] },

  // D
  { acronym: "DAU",  term: "Declaración Aduanera Única", category: "latam", definition: "Documento aduanero usado en varios países LATAM (Ecuador, Bolivia, Colombia con variantes) para declarar import/export. Equivalente al SAD europeo.", termEn: "Single Customs Declaration (LATAM)", definitionEn: "Customs document used in several LATAM countries (Ecuador, Bolivia, Colombia with variants) to declare imports/exports. Equivalent to the European SAD.", tags: ["LATAM"], relatedSlugs: ["dua", "pedimento", "sad"] },
  {                  term: "Demurrage", category: "tarifas", definition: "Cargo por exceso de tiempo del contenedor DENTRO del terminal portuario, después de los días libres (free time) post-arribo. Lo cobra la naviera.", termEn: "Demurrage", definitionEn: "Charge for keeping the container INSIDE the port terminal beyond the free time after arrival. Billed by the carrier.", relatedSlugs: ["detention", "free-time"] },
  {                  term: "Detention", category: "tarifas", definition: "Cargo por exceso de tiempo del contenedor FUERA del terminal (en bodega del cliente) sin devolverlo a la naviera. Diferente del demurrage.", termEn: "Detention", definitionEn: "Charge for keeping the container OUTSIDE the terminal (at the consignee's premises) beyond the free time. Different from demurrage.", relatedSlugs: ["demurrage", "free-time"] },
  { acronym: "DGD",  term: "Dangerous Goods Declaration", category: "documentos", definition: "Declaración formal del shipper para envíos de mercancías peligrosas (IMDG marítimo / IATA-DGR aéreo). Requiere certificación del firmante.", termEn: "Dangerous Goods Declaration", definitionEn: "Formal shipper declaration for hazardous shipments (IMDG by sea / IATA-DGR by air). Signatory must be certified.", tags: ["peligrosos"], relatedSlugs: ["imdg", "iata-dgr", "un-number"] },
  { acronym: "DIAN", term: "Dirección de Impuestos y Aduanas Nacionales", category: "latam", definition: "Autoridad aduanera y tributaria de Colombia. Administra el SIIA (Sistema Integrado de Información Aduanera).", termEn: "DIAN — National Tax and Customs Authority of Colombia", definitionEn: "Colombia's customs and tax authority. Administers SIIA (Integrated Customs Information System).", tags: ["Colombia"] },
  {                  term: "Drayage", category: "transporte", definition: "Transporte terrestre de corta distancia entre puerto/terminal y bodega o CFS. Tipicamente camión.", termEn: "Drayage", definitionEn: "Short-distance road transport between port/terminal and warehouse or CFS. Typically by truck.", relatedSlugs: ["inland-transport"] },
  { acronym: "DUA",  term: "Declaración Única de Aduana", category: "latam", definition: "En Perú y Ecuador es el documento principal de despacho aduanero — declara mercancía, valor, origen y régimen ante SUNAT/SENAE.", termEn: "Single Customs Declaration (Peru / Ecuador)", definitionEn: "Main customs clearance document in Peru and Ecuador — declares cargo, value, origin, and regime to SUNAT/SENAE.", tags: ["Perú", "Ecuador"], relatedSlugs: ["dau", "sunat", "senae"] },

  // E
  { acronym: "ETA",  term: "Estimated Time of Arrival", category: "operaciones", definition: "Fecha y hora estimadas de arribo al puerto/aeropuerto destino. Sujeto a cambios por demoras operativas.", termEn: "Estimated Time of Arrival", definitionEn: "Estimated date and time of arrival at destination port/airport. Subject to operational delays.", relatedSlugs: ["etd", "eta-vs-rta"] },
  { acronym: "ETD",  term: "Estimated Time of Departure", category: "operaciones", definition: "Fecha y hora estimadas de zarpe del puerto/aeropuerto origen.", termEn: "Estimated Time of Departure", definitionEn: "Estimated date and time of departure from origin port/airport.", relatedSlugs: ["eta"] },
  {                  term: "Express BL / Telex Release", category: "documentos", definition: "Modalidad sin emisión física de BL original. La naviera libera la carga al consignatario sin que él presente el BL en papel — lo confirma vía 'telex release' del shipper.", termEn: "Express BL / Telex Release", definitionEn: "Mode without issuing a paper original BL. The carrier releases the cargo to the consignee without paper presentation — confirmed via a shipper 'telex release'.", relatedSlugs: ["bl", "obl"] },

  // F
  { acronym: "FCL",  term: "Full Container Load", category: "transporte", definition: "Modalidad donde un solo embarcador llena un contenedor completo (20', 40', 40HC, 45HC). Se cobra flete por contenedor, no por volumen.", termEn: "Full Container Load", definitionEn: "Mode where a single shipper fills a complete container (20', 40', 40HC, 45HC). Charged per container, not by volume.", relatedSlugs: ["lcl", "fcx", "container"] },
  {                  term: "Feeder vessel", category: "transporte", definition: "Buque pequeño que transporta carga entre un hub principal (como Manzanillo o Cartagena) y puertos secundarios LATAM. Permite cobertura sin que el buque madre pase por cada puerto.", termEn: "Feeder vessel", definitionEn: "Small vessel that moves cargo between a main hub (like Manzanillo or Cartagena) and secondary LATAM ports. Provides coverage without the mother vessel calling each port.", relatedSlugs: ["transhipment", "hub"] },
  { acronym: "FEU",  term: "Forty-foot Equivalent Unit", category: "contenedores", definition: "Unidad de medida equivalente a un contenedor 40'. 1 FEU = 2 TEU. Usado para medir capacidad de buques y volumen de tráfico.", termEn: "Forty-foot Equivalent Unit", definitionEn: "Measurement unit equal to one 40' container. 1 FEU = 2 TEU. Used to size vessel capacity and traffic volume.", relatedSlugs: ["teu", "container"] },
  {                  term: "Flat Rack", category: "contenedores", definition: "Contenedor sin paredes laterales ni techo, solo piso reforzado. Para carga sobredimensionada (over-height u over-width) que no entra en contenedor estándar.", termEn: "Flat Rack", definitionEn: "Container without side walls or roof, only a reinforced floor. For oversized cargo (over-height or over-width) that doesn't fit in a standard box.", relatedSlugs: ["open-top", "oog"] },
  {                  term: "Forwarder / Freight Forwarder", category: "general", definition: "Operador logístico que organiza el transporte internacional en nombre del shipper o consignee. No mueve la carga directamente; contrata navieras, aerolíneas y terrestres.", termEn: "Freight Forwarder", definitionEn: "Logistics operator that arranges international transport on behalf of the shipper or consignee. Doesn't move the cargo directly — books carriers, airlines, and trucking.", relatedSlugs: ["nvocc", "broker"] },
  {                  term: "Free time", category: "tarifas", definition: "Días libres que da la naviera para usar el contenedor sin cobrar demurrage o detention. Típicamente 3–7 días en LATAM, negociable según volumen.", termEn: "Free time", definitionEn: "Free days the carrier grants for container use without demurrage or detention. Typically 3–7 days in LATAM, negotiable by volume.", relatedSlugs: ["demurrage", "detention"] },
  {                  term: "Freight collect / prepaid", category: "tarifas", definition: "Collect = el flete se cobra al consignatario en destino. Prepaid = el shipper paga el flete en origen. Define quién emite el cheque al armador.", termEn: "Freight collect / prepaid", definitionEn: "Collect = freight billed to the consignee at destination. Prepaid = shipper pays at origin. Defines who pays the carrier.", relatedSlugs: ["incoterms"] },

  // G
  { acronym: "GRI",  term: "General Rate Increase", category: "tarifas", definition: "Aumento general de tarifas de flete marítimo aplicado por las navieras, típicamente al inicio de cada trimestre. Anunciado con 30 días de anticipación.", termEn: "General Rate Increase", definitionEn: "Industry-wide ocean freight rate increase applied by carriers, typically at the start of each quarter. Announced 30 days ahead.", relatedSlugs: ["pss", "baf"] },

  // H
  { acronym: "HAWB", term: "House Air Waybill", category: "documentos", definition: "AWB emitido por el forwarder o consolidador al shipper individual. Funciona como recibo y contrato dentro de un consolidado aéreo.", termEn: "House Air Waybill", definitionEn: "AWB issued by the forwarder or consolidator to the individual shipper. Acts as receipt and contract within an air consolidation.", relatedSlugs: ["mawb", "awb", "hbl"] },
  { acronym: "HBL",  term: "House Bill of Lading", category: "documentos", definition: "BL emitido por el forwarder o NVOCC al shipper individual. Coexiste con un MBL emitido por la naviera al NVOCC en una operación consolidada.", termEn: "House Bill of Lading", definitionEn: "BL issued by the forwarder or NVOCC to the individual shipper. Coexists with an MBL issued by the carrier to the NVOCC in a consolidated move.", relatedSlugs: ["mbl", "bl", "hawb"] },
  {                  term: "High Cube (HC)", category: "contenedores", definition: "Contenedor con altura interna mayor (2.698 m vs. 2.393 m del estándar). Disponible en 40' y 45'. Aumenta capacidad cúbica ~13%.", termEn: "High Cube (HC)", definitionEn: "Container with taller internal height (2.698 m vs. 2.393 m for standard). Available in 40' and 45'. Adds ~13% cubic capacity.", relatedSlugs: ["dc", "container", "fcl"] },
  { acronym: "HS",   term: "Harmonized System Code", category: "aduanas", definition: "Sistema armonizado de codificación arancelaria de la OMA. 6 dígitos universales; cada país agrega 2–4 dígitos adicionales (NANDINA en CAN, NCM en MERCOSUR, NALADISA en ALADI).", termEn: "Harmonized System Code", definitionEn: "WCO harmonized tariff coding system. 6 universal digits; each country adds 2–4 extra digits (NANDINA in CAN, NCM in MERCOSUR, NALADISA in ALADI).", relatedSlugs: ["nandina", "ncm", "naladisa"] },

  // I
  { acronym: "IATA", term: "International Air Transport Association", category: "general", definition: "Asociación de aerolíneas que regula transporte aéreo de carga, incluyendo regulaciones de mercancías peligrosas (IATA-DGR) y códigos de aeropuertos.", termEn: "International Air Transport Association", definitionEn: "Airline association regulating air cargo transport, including dangerous goods (IATA-DGR) and airport codes.", tags: ["aéreo"], relatedSlugs: ["dgd", "iata-dgr"] },
  { acronym: "IMDG", term: "International Maritime Dangerous Goods Code", category: "documentos", definition: "Código internacional para transporte marítimo de mercancías peligrosas. Define las 9 clases, etiquetado, segregación y declaración.", termEn: "International Maritime Dangerous Goods Code", definitionEn: "International code for maritime transport of hazardous goods. Defines the 9 classes, labeling, segregation, and declaration.", tags: ["peligrosos"], relatedSlugs: ["dgd", "imo"] },
  { acronym: "IMO",  term: "International Maritime Organization", category: "general", definition: "Agencia de la ONU para asuntos marítimos. Emite normativas (SOLAS, MARPOL, IMDG) y asigna números IMO únicos a buques y mercancías peligrosas.", termEn: "International Maritime Organization", definitionEn: "UN agency for maritime affairs. Issues regulations (SOLAS, MARPOL, IMDG) and assigns unique IMO numbers to vessels and dangerous goods.", relatedSlugs: ["imdg", "un-number", "vgm"] },
  { acronym: "ISF",  term: "Importer Security Filing (10+2)", category: "aduanas", definition: "Declaración requerida por CBP de USA: 10 datos del importador + 2 del transportista. Debe presentarse 24h antes del embarque desde origen. Multa USD 5.000 por falta de presentación.", termEn: "Importer Security Filing (10+2)", definitionEn: "Filing required by US CBP: 10 importer data fields + 2 carrier fields. Must be filed 24h before loading at origin. USD 5,000 penalty for non-filing.", tags: ["USA"], relatedSlugs: ["cbp", "broker"] },
  { acronym: "ISPS", term: "International Ship and Port Facility Security", category: "tarifas", definition: "Sobrecargo de seguridad establecido por el código ISPS post-9/11. Aplica a todo embarque marítimo internacional, monto fijo por contenedor o BL.", termEn: "International Ship and Port Facility Security", definitionEn: "Security surcharge under the ISPS code post-9/11. Applies to every international ocean shipment as a fixed amount per container or BL.", relatedSlugs: ["surcharges"] },

  // L
  {                  term: "LATAM", category: "general", definition: "Región de América Latina. En logística internacional típicamente refiere a México y Centro+Sudamérica como zona comercial. Gloval Shipping opera con red propia en USA, Panamá, Ecuador y Perú.", termEn: "LATAM", definitionEn: "Latin America region. In international logistics, typically Mexico plus Central and South America as a trade area. Gloval Shipping operates its own offices in USA, Panama, Ecuador, and Peru.", tags: ["LATAM"] },
  { acronym: "LCL",  term: "Less than Container Load", category: "transporte", definition: "Modalidad donde varios shippers comparten el mismo contenedor. Se cobra flete por volumen (CBM) o peso, lo que sea mayor. Tránsito ligeramente más lento por consolidación / desconsolidación.", termEn: "Less than Container Load", definitionEn: "Mode where multiple shippers share the same container. Freight charged by volume (CBM) or weight, whichever is greater. Slightly longer transit due to consolidation / deconsolidation.", relatedSlugs: ["fcl", "cfs", "consolidacion"] },
  {                  term: "LOCODE (UN/LOCODE)", category: "general", definition: "Código de 5 caracteres para identificar puertos, aeropuertos y terminales (2 país + 3 lugar). Ej: ECGYE = Ecuador / Guayaquil. Mantenido por UNECE.", termEn: "LOCODE (UN/LOCODE)", definitionEn: "5-character code identifying ports, airports, and terminals (2 country + 3 location). e.g. ECGYE = Ecuador / Guayaquil. Maintained by UNECE.", relatedSlugs: ["unece"] },

  // M
  {                  term: "Manifiesto / Manifest", category: "documentos", definition: "Listado oficial de toda la carga abordo de un buque o vuelo. Lo presenta el operador a la aduana antes del arribo. En LATAM se transmite electrónicamente (SIIA, ECUAPASS).", termEn: "Manifest", definitionEn: "Official list of all cargo on board a vessel or flight. Filed by the operator with customs before arrival. In LATAM transmitted electronically (SIIA, ECUAPASS).", relatedSlugs: ["bl", "ecuapass"] },
  { acronym: "MAWB", term: "Master Air Waybill", category: "documentos", definition: "AWB emitido por la aerolínea al consolidador (forwarder/NVOCC). En consolidaciones aéreas, coexiste con HAWBs emitidos por el consolidador a sus clientes.", termEn: "Master Air Waybill", definitionEn: "AWB issued by the airline to the consolidator (forwarder/NVOCC). In air consolidations, coexists with HAWBs the consolidator issues to its clients.", relatedSlugs: ["hawb", "awb"] },
  { acronym: "MBL",  term: "Master Bill of Lading", category: "documentos", definition: "BL emitido por la naviera al NVOCC o forwarder. En operaciones consolidadas, coexiste con HBLs emitidos por el NVOCC a cada shipper.", termEn: "Master Bill of Lading", definitionEn: "BL issued by the carrier to the NVOCC or forwarder. In consolidated moves, coexists with HBLs issued by the NVOCC to each shipper.", relatedSlugs: ["hbl", "bl"] },
  {                  term: "MERCOSUR", category: "latam", definition: "Mercado Común del Sur — bloque integrado por Argentina, Brasil, Paraguay, Uruguay (+ Bolivia y Venezuela suspendidos). Usa el arancel NCM y tiene zona de libre comercio interna.", termEn: "MERCOSUR", definitionEn: "Southern Common Market — bloc of Argentina, Brazil, Paraguay, Uruguay (+ Bolivia and Venezuela suspended). Uses the NCM tariff with an internal free-trade area.", tags: ["LATAM"], relatedSlugs: ["aladi", "can", "ncm"] },
  {                  term: "Multimodal transport", category: "transporte", definition: "Combinación de dos o más modalidades de transporte (mar + tierra + aire) bajo un solo contrato y BL. Ej: vessel a Los Angeles → camión a Miami → vuelo a Quito.", termEn: "Multimodal transport", definitionEn: "Combination of two or more modes (sea + road + air) under a single contract and BL. e.g. vessel to Los Angeles → truck to Miami → flight to Quito.", relatedSlugs: ["intermodal", "fcl"] },

  // N
  { acronym: "NCM",  term: "Nomenclatura Común del MERCOSUR", category: "aduanas", definition: "Sistema arancelario de 8 dígitos usado por MERCOSUR. Basado en HS internacional + 2 dígitos propios. Equivalente a NANDINA en CAN.", termEn: "MERCOSUR Common Nomenclature", definitionEn: "8-digit tariff system used by MERCOSUR. Built on the international HS + 2 own digits. Equivalent to CAN's NANDINA.", tags: ["MERCOSUR"], relatedSlugs: ["hs", "naladisa", "nandina"] },
  { acronym: "NALADISA", term: "Nomenclatura ALADI Sistema Armonizado", category: "aduanas", definition: "Sistema arancelario de 8 dígitos usado en ALADI para preferencias entre países miembro. Permite identificar productos beneficiados por acuerdos.", termEn: "ALADI Harmonized Nomenclature", definitionEn: "8-digit tariff system used in ALADI for preferences between member countries. Identifies products benefiting from trade agreements.", tags: ["LATAM"], relatedSlugs: ["aladi", "ncm", "nandina"] },
  { acronym: "NANDINA", term: "Nomenclatura Andina", category: "aduanas", definition: "Sistema arancelario de 10 dígitos usado por la Comunidad Andina (Bolivia, Colombia, Ecuador, Perú). HS de 6 + 4 dígitos andinos.", termEn: "Andean Nomenclature", definitionEn: "10-digit tariff system used by the Andean Community (Bolivia, Colombia, Ecuador, Peru). 6 HS digits + 4 Andean digits.", tags: ["CAN"], relatedSlugs: ["can", "ncm"] },
  { acronym: "NVOCC", term: "Non-Vessel Operating Common Carrier", category: "general", definition: "Operador que actúa como naviera (emite su propio BL) sin poseer buques. Compra espacio a navieras reales y revende a sus clientes.", termEn: "Non-Vessel Operating Common Carrier", definitionEn: "Operator that acts as a carrier (issues its own BL) without owning vessels. Buys space from actual carriers and resells to its clients.", relatedSlugs: ["forwarder", "hbl"] },

  // O
  { acronym: "OBL",  term: "Original Bill of Lading", category: "documentos", definition: "BL en papel firmado por la naviera, único título valor que se debe presentar para retirar la mercancía. Normalmente se emiten 3 originales (juego de 3).", termEn: "Original Bill of Lading", definitionEn: "Paper BL signed by the carrier, the only document of title that must be presented to release the cargo. Typically issued in a set of 3 originals.", relatedSlugs: ["bl", "telex-release"] },
  {                  term: "Open Top", category: "contenedores", definition: "Contenedor sin techo (cubierto por lona). Para carga over-height que no entra por la puerta normal — se carga por arriba con grúa.", termEn: "Open Top", definitionEn: "Container without a roof (covered by tarp). For over-height cargo that won't fit through the regular door — loaded from above by crane.", relatedSlugs: ["flat-rack", "container"] },
  {                  term: "OOG (Out of Gauge)", category: "contenedores", definition: "Carga que excede dimensiones de un contenedor estándar. Requiere flat rack, open top, o break-bulk. Tarifa más alta y restricciones operativas.", termEn: "OOG (Out of Gauge)", definitionEn: "Cargo exceeding standard container dimensions. Requires flat rack, open top, or break-bulk. Higher rates and operating restrictions.", relatedSlugs: ["flat-rack", "open-top"] },

  // P
  {                  term: "Packing List", category: "documentos", definition: "Detalle de bultos de un envío: cantidad, dimensiones, peso bruto/neto, marcas y numeración. Acompaña la factura comercial.", termEn: "Packing List", definitionEn: "Detail of the shipment's packages: quantity, dimensions, gross/net weight, marks and numbers. Accompanies the commercial invoice.", relatedSlugs: ["commercial-invoice", "bl"] },
  {                  term: "Pedimento (México)", category: "latam", definition: "Documento aduanero principal en México para importación, exportación, tránsito y régimen virtual. Equivalente al DUA andino.", termEn: "Pedimento (Mexico)", definitionEn: "Mexico's main customs document for import, export, transit, and virtual regimes. Equivalent to the Andean DUA.", tags: ["México"], relatedSlugs: ["dau", "dua"] },
  { acronym: "POD",  term: "Port of Discharge / Proof of Delivery", category: "operaciones", definition: "POD tiene dos significados: (1) Port of Discharge = puerto donde se descarga del buque. (2) Proof of Delivery = comprobante firmado de entrega final al consignee.", termEn: "Port of Discharge / Proof of Delivery", definitionEn: "POD has two meanings: (1) Port of Discharge = port where vessel discharges. (2) Proof of Delivery = signed receipt of final delivery to the consignee.", relatedSlugs: ["pol"] },
  { acronym: "POL",  term: "Port of Loading", category: "operaciones", definition: "Puerto donde se carga la mercancía a bordo del buque para iniciar el tránsito principal.", termEn: "Port of Loading", definitionEn: "Port where cargo is loaded on board the vessel to start the main carriage.", relatedSlugs: ["pod"] },
  { acronym: "PSS",  term: "Peak Season Surcharge", category: "tarifas", definition: "Sobrecargo aplicado por navieras durante temporadas de alta demanda (típicamente Q3-Q4 ruta Asia → USA/LATAM). Anunciado con anticipación.", termEn: "Peak Season Surcharge", definitionEn: "Surcharge applied by carriers during high-demand seasons (typically Q3-Q4 on the Asia → USA/LATAM trade). Announced in advance.", relatedSlugs: ["gri", "baf"] },

  // R
  {                  term: "Reefer", category: "contenedores", definition: "Contenedor refrigerado con sistema propio de refrigeración. Para mercancía que requiere temperatura controlada (alimentos, farma, flores). Disponible en 20' y 40' HC.", termEn: "Reefer", definitionEn: "Refrigerated container with its own cooling system. For temperature-controlled cargo (food, pharma, flowers). Available in 20' and 40' HC.", relatedSlugs: ["container", "cold-chain"] },
  { acronym: "Ro-Ro", term: "Roll-on / Roll-off", category: "transporte", definition: "Modalidad para vehículos motorizados y maquinaria — la carga rueda sola al buque. Buques especializados con rampas integradas.", termEn: "Roll-on / Roll-off", definitionEn: "Mode for self-propelled vehicles and machinery — cargo rolls on/off the vessel under its own power. Specialized vessels with built-in ramps.", relatedSlugs: ["break-bulk"] },

  // S
  { acronym: "SENAE", term: "Servicio Nacional de Aduana del Ecuador", category: "latam", definition: "Autoridad aduanera de Ecuador. Administra ECUAPASS para gestión electrónica de operaciones. Su DUA equivalente se llama Declaración Aduanera de Importación.", termEn: "SENAE — Ecuador National Customs Service", definitionEn: "Ecuador's customs authority. Administers ECUAPASS for electronic operations. Its DUA equivalent is the Declaración Aduanera de Importación.", tags: ["Ecuador"], relatedSlugs: ["ecuapass", "dua"] },
  { acronym: "SLI",  term: "Shipper's Letter of Instructions", category: "documentos", definition: "Carta del embarcador al forwarder con instrucciones detalladas: incoterm, datos del consignee/notify, ruta, modalidad, tipo de BL, servicios contratados.", termEn: "Shipper's Letter of Instructions", definitionEn: "Letter from the shipper to the forwarder with detailed instructions: incoterm, consignee/notify data, routing, mode, BL type, contracted services.", relatedSlugs: ["si", "booking"] },
  {                  term: "Shipper / Embarcador", category: "documentos", definition: "Parte que envía la mercancía. Contrata el transporte y figura como tal en el BL/AWB. Generalmente coincide con el vendedor.", termEn: "Shipper", definitionEn: "Party sending the cargo. Books transport and is named as such on the BL/AWB. Usually the same as the seller.", relatedSlugs: ["consignatario", "notify-party"] },
  {                  term: "Stripping (deconsolidación)", category: "operaciones", definition: "Proceso de vaciar un contenedor LCL en el CFS de destino y separar la carga por consignatario. Lo opuesto al stuffing.", termEn: "Stripping (deconsolidation)", definitionEn: "Process of unloading an LCL container at the destination CFS and separating cargo by consignee. The opposite of stuffing.", relatedSlugs: ["stuffing", "cfs", "lcl"] },
  {                  term: "Stuffing (consolidación)", category: "operaciones", definition: "Proceso de cargar un contenedor — desde piezas sueltas en el CFS (LCL) o desde el almacén del cliente (FCL).", termEn: "Stuffing (consolidation)", definitionEn: "Process of loading a container — from loose pieces at the CFS (LCL) or from the customer's warehouse (FCL).", relatedSlugs: ["stripping", "cfs", "fcl"] },
  { acronym: "SUNAT", term: "Superintendencia Nacional de Aduanas y de Administración Tributaria", category: "latam", definition: "Autoridad aduanera y tributaria de Perú. Administra la DUA peruana y los regímenes aduaneros.", termEn: "SUNAT — Peru National Customs and Tax Authority", definitionEn: "Peru's customs and tax authority. Administers the Peruvian DUA and customs regimes.", tags: ["Perú"], relatedSlugs: ["dua"] },

  // T
  { acronym: "TEU",  term: "Twenty-foot Equivalent Unit", category: "contenedores", definition: "Unidad estándar para medir capacidad de buques y volumen portuario. 1 TEU = 1 contenedor 20'. Un 40' = 2 TEU.", termEn: "Twenty-foot Equivalent Unit", definitionEn: "Standard unit for vessel capacity and port volume. 1 TEU = 1 × 20' container. A 40' = 2 TEU.", relatedSlugs: ["feu"] },
  { acronym: "THC",  term: "Terminal Handling Charges", category: "tarifas", definition: "Cargos por manipuleo del contenedor en terminal portuario (carga, descarga, movimientos). Hay THC origen y THC destino, pueden estar incluidos en el flete o cobrarse aparte.", termEn: "Terminal Handling Charges", definitionEn: "Charges for handling the container at the port terminal (loading, discharge, moves). Origin THC and destination THC may be included in the freight or billed separately.", relatedSlugs: ["surcharges"] },
  {                  term: "Transhipment / Transbordo", category: "operaciones", definition: "Cambio de buque durante el tránsito en un puerto hub (ej. Manzanillo Panamá, Cartagena). Permite conectar puertos donde no llega el buque madre directamente.", termEn: "Transhipment", definitionEn: "Switch of vessel during transit at a hub port (e.g. Manzanillo Panama, Cartagena). Connects ports the mother vessel doesn't call directly.", relatedSlugs: ["feeder", "hub"] },
  {                  term: "Through Bill of Lading", category: "documentos", definition: "BL único que cubre todo el recorrido incluyendo transbordos y/o transporte multimodal. Una sola pieza de papel para origen → destino final.", termEn: "Through Bill of Lading", definitionEn: "Single BL covering the entire journey including transhipments and/or multimodal legs. One paper from origin → final destination.", relatedSlugs: ["bl", "multimodal"] },

  // U
  {                  term: "UN Number", category: "documentos", definition: "Identificador único de 4 dígitos para mercancías peligrosas (UN0001 a UN3559). Asignado por la ONU. Determina clase IMDG, packing group y proper shipping name.", termEn: "UN Number", definitionEn: "Unique 4-digit identifier for dangerous goods (UN0001 to UN3559). Assigned by the UN. Drives IMDG class, packing group, and proper shipping name.", tags: ["peligrosos"], relatedSlugs: ["imdg", "dgd"] },

  // V
  { acronym: "VGM",  term: "Verified Gross Mass", category: "documentos", definition: "Peso bruto verificado del contenedor lleno. Obligatorio bajo SOLAS desde 2016 — debe declararse antes del embarque o el contenedor no carga. Se calcula pesando o por método 2 (suma de pesos individuales).", termEn: "Verified Gross Mass", definitionEn: "Verified gross mass of the loaded container. Mandatory under SOLAS since 2016 — must be declared before loading or the container won't board. Calculated by weighing or via method 2 (sum of individual weights).", tags: ["compliance"], relatedSlugs: ["solas"] },
  {                  term: "Voyage", category: "operaciones", definition: "Número de viaje del buque. Identifica un servicio puntual de la línea (ej. MAERSK SEMARANG voy. 447S). Importante para tracking y reservas.", termEn: "Voyage", definitionEn: "Vessel voyage number. Identifies a specific sailing (e.g. MAERSK SEMARANG voy. 447S). Important for tracking and bookings.", relatedSlugs: ["vessel"] },

  // Z
  {                  term: "Zona Franca", category: "latam", definition: "Territorio aduanero especial donde se almacena, transforma o reexporta mercancía sin pago de aranceles. En Panamá: ZLC (Colón), en otros países hay Zonas Francas industriales y comerciales.", termEn: "Free Trade Zone", definitionEn: "Special customs territory where cargo is stored, transformed, or re-exported without paying duties. Panama: ZLC (Colón); other countries have industrial and commercial Free Zones.", tags: ["LATAM"], relatedSlugs: ["zlc"] },
  { acronym: "ZLC",  term: "Zona Libre de Colón (Panamá)", category: "latam", definition: "La mayor zona franca del hemisferio occidental, ubicada en Colón, Panamá. Hub de redistribución para LATAM y Caribe.", termEn: "Colón Free Zone (Panama)", definitionEn: "The largest free trade zone in the western hemisphere, located in Colón, Panama. Redistribution hub for LATAM and the Caribbean.", tags: ["Panamá"], relatedSlugs: ["zona-franca"] },
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
      (t.termEn?.toLowerCase().includes(query) ?? false) ||
      (t.acronym?.toLowerCase().includes(query) ?? false) ||
      t.definition.toLowerCase().includes(query) ||
      (t.definitionEn?.toLowerCase().includes(query) ?? false) ||
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
