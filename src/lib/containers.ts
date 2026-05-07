export interface ContainerSpec {
  id: string;
  name: string;
  category: "dry" | "reefer" | "open-top" | "flat-rack" | "tank";
  internal: { length_m: number; width_m: number; height_m: number };
  door: { width_m: number; height_m: number };
  external: { length_m: number; width_m: number; height_m: number };
  weights: { tare_kg: number; max_gross_kg: number; payload_kg: number };
  capacity: { cbm: number; cuft: number };
  pallets: { us_48x40: number; eur_120x80: number };
}

export const CONTAINERS: ContainerSpec[] = [
  {
    id: "20gp",
    name: "20' Standard (DC)",
    category: "dry",
    internal: { length_m: 5.898, width_m: 2.352, height_m: 2.393 },
    door:     { width_m: 2.343, height_m: 2.28 },
    external: { length_m: 6.058, width_m: 2.438, height_m: 2.591 },
    weights:  { tare_kg: 2230, max_gross_kg: 30480, payload_kg: 28250 },
    capacity: { cbm: 33.2, cuft: 1172 },
    pallets:  { us_48x40: 10, eur_120x80: 11 },
  },
  {
    id: "40gp",
    name: "40' Standard (DC)",
    category: "dry",
    internal: { length_m: 12.032, width_m: 2.352, height_m: 2.393 },
    door:     { width_m: 2.343, height_m: 2.28 },
    external: { length_m: 12.192, width_m: 2.438, height_m: 2.591 },
    weights:  { tare_kg: 3750, max_gross_kg: 32500, payload_kg: 28750 },
    capacity: { cbm: 67.7, cuft: 2390 },
    pallets:  { us_48x40: 20, eur_120x80: 24 },
  },
  {
    id: "40hc",
    name: "40' High Cube (HC)",
    category: "dry",
    internal: { length_m: 12.032, width_m: 2.352, height_m: 2.698 },
    door:     { width_m: 2.343, height_m: 2.585 },
    external: { length_m: 12.192, width_m: 2.438, height_m: 2.896 },
    weights:  { tare_kg: 3900, max_gross_kg: 32500, payload_kg: 28600 },
    capacity: { cbm: 76.4, cuft: 2698 },
    pallets:  { us_48x40: 20, eur_120x80: 24 },
  },
  {
    id: "45hc",
    name: "45' High Cube (HC)",
    category: "dry",
    internal: { length_m: 13.556, width_m: 2.352, height_m: 2.698 },
    door:     { width_m: 2.343, height_m: 2.585 },
    external: { length_m: 13.716, width_m: 2.438, height_m: 2.896 },
    weights:  { tare_kg: 4800, max_gross_kg: 32500, payload_kg: 27700 },
    capacity: { cbm: 86.0, cuft: 3037 },
    pallets:  { us_48x40: 24, eur_120x80: 27 },
  },
  {
    id: "20rf",
    name: "20' Reefer",
    category: "reefer",
    internal: { length_m: 5.456, width_m: 2.290, height_m: 2.260 },
    door:     { width_m: 2.290, height_m: 2.244 },
    external: { length_m: 6.058, width_m: 2.438, height_m: 2.591 },
    weights:  { tare_kg: 3050, max_gross_kg: 30480, payload_kg: 27430 },
    capacity: { cbm: 28.3, cuft: 1000 },
    pallets:  { us_48x40: 9, eur_120x80: 10 },
  },
  {
    id: "40rfhc",
    name: "40' Reefer High Cube",
    category: "reefer",
    internal: { length_m: 11.583, width_m: 2.286, height_m: 2.535 },
    door:     { width_m: 2.286, height_m: 2.519 },
    external: { length_m: 12.192, width_m: 2.438, height_m: 2.896 },
    weights:  { tare_kg: 4800, max_gross_kg: 32500, payload_kg: 27700 },
    capacity: { cbm: 67.1, cuft: 2370 },
    pallets:  { us_48x40: 20, eur_120x80: 23 },
  },
  {
    id: "20ot",
    name: "20' Open Top",
    category: "open-top",
    internal: { length_m: 5.898, width_m: 2.352, height_m: 2.348 },
    door:     { width_m: 2.343, height_m: 2.279 },
    external: { length_m: 6.058, width_m: 2.438, height_m: 2.591 },
    weights:  { tare_kg: 2280, max_gross_kg: 30480, payload_kg: 28200 },
    capacity: { cbm: 32.6, cuft: 1151 },
    pallets:  { us_48x40: 10, eur_120x80: 11 },
  },
  {
    id: "40ot",
    name: "40' Open Top",
    category: "open-top",
    internal: { length_m: 12.032, width_m: 2.352, height_m: 2.348 },
    door:     { width_m: 2.343, height_m: 2.279 },
    external: { length_m: 12.192, width_m: 2.438, height_m: 2.591 },
    weights:  { tare_kg: 3850, max_gross_kg: 32500, payload_kg: 28650 },
    capacity: { cbm: 66.5, cuft: 2348 },
    pallets:  { us_48x40: 20, eur_120x80: 24 },
  },
  {
    id: "20fr",
    name: "20' Flat Rack",
    category: "flat-rack",
    internal: { length_m: 5.940, width_m: 2.345, height_m: 2.350 },
    door:     { width_m: 0, height_m: 0 },
    external: { length_m: 6.058, width_m: 2.438, height_m: 2.591 },
    weights:  { tare_kg: 2740, max_gross_kg: 30480, payload_kg: 27740 },
    capacity: { cbm: 32.7, cuft: 1155 },
    pallets:  { us_48x40: 10, eur_120x80: 11 },
  },
  {
    id: "40fr",
    name: "40' Flat Rack",
    category: "flat-rack",
    internal: { length_m: 12.080, width_m: 2.400, height_m: 2.140 },
    door:     { width_m: 0, height_m: 0 },
    external: { length_m: 12.192, width_m: 2.438, height_m: 2.591 },
    weights:  { tare_kg: 5000, max_gross_kg: 45000, payload_kg: 40000 },
    capacity: { cbm: 62.0, cuft: 2189 },
    pallets:  { us_48x40: 20, eur_120x80: 24 },
  },
  {
    id: "20tk",
    name: "20' Tank",
    category: "tank",
    internal: { length_m: 6.058, width_m: 2.438, height_m: 2.591 },
    door:     { width_m: 0, height_m: 0 },
    external: { length_m: 6.058, width_m: 2.438, height_m: 2.591 },
    weights:  { tare_kg: 4200, max_gross_kg: 36000, payload_kg: 31800 },
    capacity: { cbm: 26.0, cuft: 918 },
    pallets:  { us_48x40: 0, eur_120x80: 0 },
  },
];

export interface CountryRoadLimit {
  country: string;
  flag: string;
  max_gross_kg: number;
  notes: string;
}

export const LATAM_ROAD_LIMITS: CountryRoadLimit[] = [
  {
    country: "Ecuador",
    flag: "🇪🇨",
    max_gross_kg: 28000,
    notes: "Máx 28 ton sobre eje en zonas de montaña. Permiso especial para sobrepeso vía MTOP.",
  },
  {
    country: "Perú",
    flag: "🇵🇪",
    max_gross_kg: 30000,
    notes: "Máx 30 ton bruto en carretera. SUTRAN regula sobrepesos. Restricciones adicionales en sierra.",
  },
  {
    country: "Panamá",
    flag: "🇵🇦",
    max_gross_kg: 27000,
    notes: "Máx 27 ton en vías principales. Permiso AAP para sobrepeso.",
  },
  {
    country: "Colombia",
    flag: "🇨🇴",
    max_gross_kg: 32000,
    notes: "Máx 32 ton bruto. INVIAS regula. Restricciones de circulación en Bogotá según categoría.",
  },
];

export interface PortCompatibility {
  port: string;
  country: string;
  flag: string;
  accepts_45hc: boolean;
  notes: string;
}

export const LATAM_PORT_COMPATIBILITY: PortCompatibility[] = [
  { port: "Guayaquil (GYE)", country: "Ecuador", flag: "🇪🇨", accepts_45hc: false, notes: "Operación habitual hasta 40' HC. 45' caso por caso." },
  { port: "Callao (CLL)", country: "Perú", flag: "🇵🇪", accepts_45hc: true, notes: "Acepta 45' HC en terminal APM y DPW." },
  { port: "Manzanillo (MIT)", country: "Panamá", flag: "🇵🇦", accepts_45hc: true, notes: "Acepta 45' HC sin restricciones." },
  { port: "Cartagena (CTG)", country: "Colombia", flag: "🇨🇴", accepts_45hc: true, notes: "Acepta 45' HC en SPRC y Contecar." },
  { port: "Buenaventura (BUN)", country: "Colombia", flag: "🇨🇴", accepts_45hc: false, notes: "Restricción operativa para 45'. Hasta 40' HC." },
  { port: "Veracruz (VER)", country: "México", flag: "🇲🇽", accepts_45hc: true, notes: "Acepta 45' HC. Restricción de altura en algunas zonas internas." },
  { port: "Santos (SSZ)", country: "Brasil", flag: "🇧🇷", accepts_45hc: true, notes: "Acepta 45' HC sin restricciones." },
  { port: "San Antonio (SAI)", country: "Chile", flag: "🇨🇱", accepts_45hc: true, notes: "Acepta 45' HC." },
];
