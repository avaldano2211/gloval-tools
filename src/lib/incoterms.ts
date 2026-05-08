/**
 * Incoterms 2020 — 11 reglas oficiales de la ICC.
 *
 * Modelo de transferencia: cada fase del viaje internacional se asigna a "S"
 * (Seller / Vendedor) o "B" (Buyer / Comprador). Para cada incoterm trackeamos
 * COSTO y RIESGO por separado — la diferencia clave entre algunos términos
 * (CFR vs FOB, CIF vs CIP) es justamente cuándo se transfiere el riesgo aunque
 * el costo siga siendo del vendedor.
 */

export type Party = "S" | "B";

export interface IncotermPhase {
  /** Quién paga el costo de esta fase */
  cost: Party;
  /** Quién asume el riesgo durante esta fase */
  risk: Party;
}

export const PHASES = [
  { id: "export_packing",    labelEs: "Empaque exportación",   labelEn: "Export packing" },
  { id: "origin_load",       labelEs: "Carga en origen",        labelEn: "Origin loading" },
  { id: "origin_inland",     labelEs: "Transporte interno origen", labelEn: "Inland origin" },
  { id: "export_customs",    labelEs: "Aduana exportación",     labelEn: "Export customs" },
  { id: "main_freight",      labelEs: "Flete principal",        labelEn: "Main freight" },
  { id: "insurance",         labelEs: "Seguro",                 labelEn: "Insurance" },
  { id: "import_customs",    labelEs: "Aduana importación",     labelEn: "Import customs" },
  { id: "destination_inland",labelEs: "Transporte interno destino", labelEn: "Inland destination" },
  { id: "destination_unload",labelEs: "Descarga destino",       labelEn: "Destination unloading" },
] as const;

export type PhaseId = (typeof PHASES)[number]["id"];

export interface Incoterm {
  code: "EXW" | "FCA" | "FAS" | "FOB" | "CFR" | "CIF" | "CPT" | "CIP" | "DAP" | "DPU" | "DDP";
  name: string;
  modality: "any" | "maritime";
  summaryEs: string;
  summaryEn: string;
  /** Costo y riesgo por fase del viaje */
  phases: Record<PhaseId, IncotermPhase>;
  latamPitfalls: string[];
}

/**
 * "S" = vendedor responsable, "B" = comprador responsable.
 * Insurance: por convención, solo CIF y CIP obligan al vendedor a contratarlo;
 * en los demás términos el seguro queda en cabeza del comprador (B).
 */
function P(cost: Party, risk: Party = cost): IncotermPhase {
  return { cost, risk };
}

export const INCOTERMS: Incoterm[] = [
  {
    code: "EXW",
    name: "Ex Works",
    modality: "any",
    summaryEs: "El vendedor entrega cuando pone la mercancía a disposición del comprador en sus instalaciones. Mínima obligación para el vendedor.",
    summaryEn: "Seller fulfills the obligation when goods are made available at their premises. Minimum obligation for seller.",
    phases: {
      export_packing:     P("S"),
      origin_load:        P("B"),
      origin_inland:      P("B"),
      export_customs:     P("B"),
      main_freight:       P("B"),
      insurance:          P("B"),
      import_customs:     P("B"),
      destination_inland: P("B"),
      destination_unload: P("B"),
    },
    latamPitfalls: [
      "Ecuador: el comprador extranjero no puede actuar como exportador en SENAE; usar FCA en su lugar.",
      "Perú: SUNAT exige RUC para el exportador; con EXW el comprador internacional no puede declarar la DUA.",
      "Recomendación: EXW funciona solo entre operadores domésticos. Para LATAM internacional, casi siempre FCA es lo correcto.",
    ],
  },
  {
    code: "FCA",
    name: "Free Carrier",
    modality: "any",
    summaryEs: "El vendedor entrega la mercancía al transportista nominado por el comprador en el lugar acordado. Despacho de exportación a cargo del vendedor.",
    summaryEn: "Seller delivers goods to the carrier nominated by the buyer at the agreed place. Export clearance is on seller.",
    phases: {
      export_packing:     P("S"),
      origin_load:        P("S"),
      origin_inland:      P("S"),
      export_customs:     P("S"),
      main_freight:       P("B"),
      insurance:          P("B"),
      import_customs:     P("B"),
      destination_inland: P("B"),
      destination_unload: P("B"),
    },
    latamPitfalls: [
      "Especificar EXACTAMENTE el lugar de entrega — almacén del vendedor vs. terminal del transportista cambia totalmente la responsabilidad.",
      "En Ecuador y Perú, FCA en bodega del vendedor implica que el comprador organiza recolección — coordinar con anticipación porque hay zonas con acceso restringido para camiones grandes.",
      "Para envíos contenedorizados, FCA terminal portuario suele ser más limpio que FCA bodega.",
    ],
  },
  {
    code: "FAS",
    name: "Free Alongside Ship",
    modality: "maritime",
    summaryEs: "El vendedor entrega cuando la mercancía está al costado del buque en el puerto de embarque acordado. Solo para transporte marítimo o aguas interiores.",
    summaryEn: "Seller delivers when goods are placed alongside the vessel at the named port of shipment. Sea/inland waterway only.",
    phases: {
      export_packing:     P("S"),
      origin_load:        P("S"),
      origin_inland:      P("S"),
      export_customs:     P("S"),
      main_freight:       P("B"),
      insurance:          P("B"),
      import_customs:     P("B"),
      destination_inland: P("B"),
      destination_unload: P("B"),
    },
    latamPitfalls: [
      "FAS se usa principalmente para carga break-bulk pesada o proyecto. Para contenedores, FCA terminal es preferible.",
      "En Callao y Guayaquil, costos de manipuleo en muelle (THC) suelen quedar en zona gris — pactar explícitamente quién los paga.",
    ],
  },
  {
    code: "FOB",
    name: "Free On Board",
    modality: "maritime",
    summaryEs: "El vendedor entrega la mercancía a bordo del buque designado en el puerto de embarque. Solo marítimo. Riesgo se transfiere al cruzar la borda.",
    summaryEn: "Seller delivers the goods on board the vessel nominated by the buyer at the named port of shipment. Maritime only.",
    phases: {
      export_packing:     P("S"),
      origin_load:        P("S"),
      origin_inland:      P("S"),
      export_customs:     P("S"),
      main_freight:       P("B"),
      insurance:          P("B"),
      import_customs:     P("B"),
      destination_inland: P("B"),
      destination_unload: P("B"),
    },
    latamPitfalls: [
      "FOB se usa SOLO para carga marítima a granel o break-bulk. Para contenedores la ICC recomienda FCA, no FOB, aunque la industria sigue usando FOB por costumbre.",
      "Origen LATAM: el vendedor debe contratar el agente de aduanas y pagar costos de terminal — verificar que estén incluidos en su cotización FOB.",
      "Riesgo se transfiere al cargar a bordo, no al arribar al puerto. Si la grúa rompe la mercancía durante el izado, depende del momento exacto.",
    ],
  },
  {
    code: "CFR",
    name: "Cost and Freight",
    modality: "maritime",
    summaryEs: "El vendedor paga el costo y flete principal hasta el puerto destino. El riesgo se transfiere al comprador al cargar a bordo en origen. Solo marítimo.",
    summaryEn: "Seller pays cost and freight to bring goods to the port of destination. Risk transfers when goods are loaded on board at origin. Maritime only.",
    phases: {
      export_packing:     P("S"),
      origin_load:        P("S"),
      origin_inland:      P("S"),
      export_customs:     P("S"),
      main_freight:       { cost: "S", risk: "B" },
      insurance:          P("B"),
      import_customs:     P("B"),
      destination_inland: P("B"),
      destination_unload: P("B"),
    },
    latamPitfalls: [
      "Trampa común: el comprador asume que CFR incluye seguro porque el vendedor paga el flete. NO incluye. Si el comprador no contrata seguro y hay siniestro en el mar, no hay cobertura.",
      "Útil cuando el comprador en LATAM quiere visibilidad de la naviera y certeza de tarifa, pero asume el riesgo desde origen.",
    ],
  },
  {
    code: "CIF",
    name: "Cost, Insurance and Freight",
    modality: "maritime",
    summaryEs: "Como CFR pero el vendedor también contrata el seguro mínimo (Cláusula C) hasta el puerto destino. Riesgo al comprador al cargar en origen. Solo marítimo.",
    summaryEn: "Like CFR but seller also contracts minimum insurance (Clause C) up to the destination port. Risk to buyer once loaded at origin. Maritime only.",
    phases: {
      export_packing:     P("S"),
      origin_load:        P("S"),
      origin_inland:      P("S"),
      export_customs:     P("S"),
      main_freight:       { cost: "S", risk: "B" },
      insurance:          P("S"),
      import_customs:     P("B"),
      destination_inland: P("B"),
      destination_unload: P("B"),
    },
    latamPitfalls: [
      "Cláusula C es cobertura MÍNIMA — solo siniestros catastróficos. Si la mercancía es valiosa, negociar Cláusula A (todo riesgo) y subir el costo.",
      "Panamá / ZLC: revisar que el seguro tenga cobertura en zona franca, no todos los seguros la incluyen por default.",
      "El valor asegurado es 110% del CIF por convención ICC — confirmar que el certificado lo refleje.",
    ],
  },
  {
    code: "CPT",
    name: "Carriage Paid To",
    modality: "any",
    summaryEs: "El vendedor paga el transporte hasta el destino acordado. El riesgo se transfiere al primer transportista en origen. Cualquier modo de transporte.",
    summaryEn: "Seller pays carriage to the named destination. Risk transfers to the first carrier at origin. Any mode of transport.",
    phases: {
      export_packing:     P("S"),
      origin_load:        P("S"),
      origin_inland:      P("S"),
      export_customs:     P("S"),
      main_freight:       { cost: "S", risk: "B" },
      insurance:          P("B"),
      import_customs:     P("B"),
      destination_inland: { cost: "S", risk: "B" },
      destination_unload: P("B"),
    },
    latamPitfalls: [
      "CPT es el equivalente multimodal de CFR. Útil para aéreo y combinado, donde FOB/CIF no aplican.",
      "El 'destino' debe ser específico: 'CPT Lima' es ambiguo. Usar 'CPT Almacén Cliente, Av X #Y, Lima'.",
    ],
  },
  {
    code: "CIP",
    name: "Carriage and Insurance Paid To",
    modality: "any",
    summaryEs: "Como CPT pero el vendedor además contrata seguro de cobertura amplia (Cláusula A) hasta el destino. Cualquier modo de transporte.",
    summaryEn: "Like CPT but seller also contracts wide-coverage insurance (Clause A) to the destination. Any mode.",
    phases: {
      export_packing:     P("S"),
      origin_load:        P("S"),
      origin_inland:      P("S"),
      export_customs:     P("S"),
      main_freight:       { cost: "S", risk: "B" },
      insurance:          P("S"),
      import_customs:     P("B"),
      destination_inland: { cost: "S", risk: "B" },
      destination_unload: P("B"),
    },
    latamPitfalls: [
      "Diferencia clave con CIF: CIP exige Cláusula A (todo riesgo) por default — más caro pero más cobertura.",
      "Para envíos aéreos a LATAM, CIP es preferible a CPT cuando la mercancía es electrónica o de alto valor.",
    ],
  },
  {
    code: "DAP",
    name: "Delivered at Place",
    modality: "any",
    summaryEs: "El vendedor entrega cuando la mercancía está disponible para descarga en el lugar destino acordado. No despacha importación. Cualquier modo.",
    summaryEn: "Seller delivers when goods are placed at the disposal of the buyer at the agreed destination, ready for unloading. Any mode.",
    phases: {
      export_packing:     P("S"),
      origin_load:        P("S"),
      origin_inland:      P("S"),
      export_customs:     P("S"),
      main_freight:       P("S"),
      insurance:          P("B"),
      import_customs:     P("B"),
      destination_inland: P("S"),
      destination_unload: P("B"),
    },
    latamPitfalls: [
      "DAP es el término más usado por compradores LATAM que quieren tarifa puerta a puerto sin lidiar con la naviera, pero conservando el control de la importación.",
      "El vendedor debe coordinar con un forwarder con red en destino — Gloval cubre EC/PE/PA/USA con red propia.",
    ],
  },
  {
    code: "DPU",
    name: "Delivered at Place Unloaded",
    modality: "any",
    summaryEs: "Como DAP pero el vendedor también descarga la mercancía en el lugar destino. Único Incoterm que obliga al vendedor a descargar.",
    summaryEn: "Like DAP but seller also unloads the goods at the destination. Only Incoterm that forces seller to unload.",
    phases: {
      export_packing:     P("S"),
      origin_load:        P("S"),
      origin_inland:      P("S"),
      export_customs:     P("S"),
      main_freight:       P("S"),
      insurance:          P("B"),
      import_customs:     P("B"),
      destination_inland: P("S"),
      destination_unload: P("S"),
    },
    latamPitfalls: [
      "Solo viable si el vendedor tiene capacidad operativa de descargar en destino. Verificar que el almacén destino tenga muelle, montacargas o personal.",
      "Reemplazó al antiguo DAT (Delivered at Terminal) en Incoterms 2020.",
    ],
  },
  {
    code: "DDP",
    name: "Delivered Duty Paid",
    modality: "any",
    summaryEs: "El vendedor entrega con todos los costos pagados, incluyendo derechos de importación e impuestos en destino. Máxima obligación para el vendedor.",
    summaryEn: "Seller delivers with all costs paid, including import duties and destination taxes. Maximum obligation for seller.",
    phases: {
      export_packing:     P("S"),
      origin_load:        P("S"),
      origin_inland:      P("S"),
      export_customs:     P("S"),
      main_freight:       P("S"),
      insurance:          P("B"),
      import_customs:     P("S"),
      destination_inland: P("S"),
      destination_unload: P("B"),
    },
    latamPitfalls: [
      "DDP requiere que el vendedor extranjero pueda actuar como importador — en Perú necesita RUC peruano, en Ecuador RUC SENAE, etc. La mayoría de exportadores extranjeros NO califican.",
      "Para LATAM, casi siempre se reemplaza DDP por DAP + agente local — el comprador hace despacho con su agente y el vendedor le reembolsa derechos si fue acordado.",
      "Si insistes en DDP a Perú/Ecuador, el vendedor debe contratar agente aduanal local y firmar carta poder formal — process toma 2-3 semanas adicionales.",
    ],
  },
];

export function findIncoterm(code: string) {
  return INCOTERMS.find((i) => i.code === code.toUpperCase());
}
