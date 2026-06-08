/**
 * IMO / IMDG — 9 clases de mercancías peligrosas según el IMDG Code (Capítulo 7).
 *
 * Los rombos oficiales tienen colores de fondo y a veces texto/símbolos.
 * Para evitar reproducir los símbolos protegidos por la IMO, dibujamos los
 * rombos con su color oficial y el número de clase claramente visible.
 */

export interface ImdgClass {
  code: string;
  title: string;
  description: string;
  examples: string;
  /** Color principal del rombo (CSS) */
  bg: string;
  /** Color secundario (rayas, mitad inferior) — opcional */
  bg2?: string;
  /** Color del texto/número en el rombo */
  fg: string;
  /** Patrón especial: stripes (vertical), half (horizontal split), solid */
  pattern?: "solid" | "stripes" | "half";
}

export const IMDG_CLASSES: ImdgClass[] = [
  {
    code: "1",
    title: "Explosivos",
    description: "Sustancias y artículos que tienen un peligro de explosión masiva, proyección o fuego.",
    examples: "Pólvora, detonadores, dinamita, fuegos artificiales, municiones.",
    bg: "#FF8C2A",
    fg: "#000",
    pattern: "solid",
  },
  {
    code: "2.1",
    title: "Gases inflamables",
    description: "Gases que en mezcla 13% o menos por volumen con aire son inflamables.",
    examples: "Propano, butano, acetileno, hidrógeno.",
    bg: "#D72B2B",
    fg: "#FFF",
    pattern: "solid",
  },
  {
    code: "2.2",
    title: "Gases no inflamables, no tóxicos",
    description: "Gases asfixiantes, oxidantes, o sin riesgo subsidiario.",
    examples: "Helio, nitrógeno, oxígeno comprimido, CO₂.",
    bg: "#2BA84A",
    fg: "#FFF",
    pattern: "solid",
  },
  {
    code: "2.3",
    title: "Gases tóxicos",
    description: "Gases tóxicos o corrosivos para humanos al inhalar.",
    examples: "Cloro, amoníaco anhidro, óxido de etileno.",
    bg: "#FFFFFF",
    fg: "#000",
    pattern: "solid",
  },
  {
    code: "3",
    title: "Líquidos inflamables",
    description: "Líquidos con punto de inflamación ≤ 60°C en copa cerrada.",
    examples: "Gasolina, diésel, alcohol, pinturas, solventes, perfumes.",
    bg: "#D72B2B",
    fg: "#FFF",
    pattern: "solid",
  },
  {
    code: "4.1",
    title: "Sólidos inflamables",
    description: "Sólidos que se prenden con facilidad o pueden causar fuego por fricción.",
    examples: "Fósforos, azufre, naftalina, polvo de magnesio.",
    bg: "#FFFFFF",
    bg2: "#D72B2B",
    fg: "#000",
    pattern: "stripes",
  },
  {
    code: "4.2",
    title: "Sustancias de combustión espontánea",
    description: "Material que puede calentarse y prenderse en contacto con aire.",
    examples: "Fósforo blanco, carbón activado húmedo, algunas semillas oleaginosas.",
    bg: "#FFFFFF",
    bg2: "#D72B2B",
    fg: "#000",
    pattern: "half",
  },
  {
    code: "4.3",
    title: "Peligrosos al contacto con agua",
    description: "Sustancias que liberan gases inflamables al contacto con agua.",
    examples: "Sodio, potasio, calcio metálico, carburos.",
    bg: "#1F62B0",
    fg: "#FFF",
    pattern: "solid",
  },
  {
    code: "5.1",
    title: "Sustancias oxidantes",
    description: "Sustancias que liberan oxígeno y pueden causar o intensificar fuego.",
    examples: "Peróxido de hidrógeno, nitratos, cloratos, permanganato.",
    bg: "#FFD831",
    fg: "#000",
    pattern: "solid",
  },
  {
    code: "5.2",
    title: "Peróxidos orgánicos",
    description: "Compuestos orgánicos térmicamente inestables que pueden descomponerse violentamente.",
    examples: "Peróxido de benzoilo, peróxido de metiletilcetona.",
    bg: "#D72B2B",
    bg2: "#FFD831",
    fg: "#000",
    pattern: "half",
  },
  {
    code: "6.1",
    title: "Sustancias tóxicas",
    description: "Sustancias capaces de causar muerte o lesiones severas si se ingieren, inhalan o tocan.",
    examples: "Pesticidas, cianuros, arsénico, mercurio.",
    bg: "#FFFFFF",
    fg: "#000",
    pattern: "solid",
  },
  {
    code: "6.2",
    title: "Sustancias infecciosas",
    description: "Sustancias que contienen patógenos capaces de causar enfermedad.",
    examples: "Muestras médicas, residuos hospitalarios, cultivos virales.",
    bg: "#FFFFFF",
    fg: "#000",
    pattern: "solid",
  },
  {
    code: "7",
    title: "Materiales radiactivos",
    description: "Materiales con actividad específica > 70 kBq/kg.",
    examples: "Uranio, isótopos médicos, equipos de medición radiactivos.",
    bg: "#FFD831",
    bg2: "#FFFFFF",
    fg: "#000",
    pattern: "half",
  },
  {
    code: "8",
    title: "Sustancias corrosivas",
    description: "Sustancias que por acción química causan daño severo a tejidos o materiales.",
    examples: "Ácido sulfúrico, hidróxido de sodio, baterías, ácido clorhídrico.",
    bg: "#000000",
    bg2: "#FFFFFF",
    fg: "#FFF",
    pattern: "half",
  },
  {
    code: "9",
    title: "Mercancías peligrosas misceláneas",
    description: "Sustancias y artículos que presentan un peligro durante el transporte no cubierto por otras clases.",
    examples: "Baterías de litio, asbesto, hielo seco, motores con combustible.",
    bg: "#FFFFFF",
    fg: "#000",
    pattern: "stripes",
  },
];

/**
 * Códigos de segregación IMDG Capítulo 7.2.
 *
 * - "1" = Away from (separación de al menos 3 m horizontal)
 * - "2" = Separated from (en distintos compartimentos / un compartimento de separación)
 * - "3" = Separated by a complete compartment or hold
 * - "4" = Separated longitudinally by an intervening complete compartment or hold
 * - "X" = No se permite estiba juntos
 * - "-" = Sin restricción específica (consultar lista de mercancía individual)
 *
 * Esta matriz es a NIVEL DE CLASE PRINCIPAL. La tabla oficial es por sub-clase
 * y existen excepciones por UN Number — siempre verificar con consultor IMDG.
 */
export type SegCode = "1" | "2" | "3" | "4" | "X" | "-";

export const SEG_LEGEND: Record<SegCode, { short: string; description: string; color: string }> = {
  "1": {
    short: "1",
    description: "Away from — separados al menos 3 m horizontal en cubierta.",
    color: "#FFE4B0",
  },
  "2": {
    short: "2",
    description: "Separated from — en compartimentos diferentes con división intermedia.",
    color: "#FFC97A",
  },
  "3": {
    short: "3",
    description: "Separated by complete compartment or hold.",
    color: "#FF9500",
  },
  "4": {
    short: "4",
    description: "Separated longitudinally by intervening complete compartment.",
    color: "#FF6B00",
  },
  "X": {
    short: "X",
    description: "PROHIBIDO — no se permite estiba juntos bajo ninguna condición.",
    color: "#D72B2B",
  },
  "-": {
    short: "—",
    description: "Sin restricción específica de segregación a nivel de clase. Consultar IMDG por UN Number.",
    color: "#E5E7EB",
  },
};

const C = ["1", "2.1", "2.2", "2.3", "3", "4.1", "4.2", "4.3", "5.1", "5.2", "6.1", "7", "8", "9"] as const;

/**
 * Matriz de segregación simplificada — Capítulo 7.2.4 IMDG (versión por clase).
 * Filas/columnas: 1, 2.1, 2.2, 2.3, 3, 4.1, 4.2, 4.3, 5.1, 5.2, 6.1, 7, 8, 9.
 *
 * Esta es una versión simplificada para referencia rápida. Para shipping real,
 * consultar la tabla oficial por sub-clase y la lista por UN Number.
 */
const RAW_MATRIX: Record<string, SegCode[]> = {
  "1":   ["X", "4", "2", "2", "4", "4", "4", "4", "4", "4", "2", "2", "4", "X"],
  "2.1": ["4", "X", "1", "1", "2", "1", "2", "2", "2", "2", "-", "2", "1", "-"],
  "2.2": ["2", "1", "X", "1", "1", "1", "1", "1", "1", "1", "-", "1", "1", "-"],
  "2.3": ["2", "1", "1", "X", "2", "1", "1", "1", "2", "2", "-", "1", "1", "-"],
  "3":   ["4", "2", "1", "2", "X", "1", "2", "2", "2", "2", "-", "2", "1", "-"],
  "4.1": ["4", "1", "1", "1", "1", "X", "1", "1", "1", "2", "-", "1", "1", "-"],
  "4.2": ["4", "2", "1", "1", "2", "1", "X", "1", "2", "2", "1", "2", "1", "-"],
  "4.3": ["4", "2", "1", "1", "2", "1", "1", "X", "2", "2", "-", "2", "2", "-"],
  "5.1": ["4", "2", "1", "2", "2", "1", "2", "2", "X", "2", "1", "1", "2", "-"],
  "5.2": ["4", "2", "1", "2", "2", "2", "2", "2", "2", "X", "1", "2", "2", "-"],
  "6.1": ["2", "-", "-", "-", "-", "-", "1", "-", "1", "1", "X", "-", "-", "-"],
  "7":   ["2", "2", "1", "1", "2", "1", "2", "2", "1", "2", "-", "X", "2", "-"],
  "8":   ["4", "1", "1", "1", "1", "1", "1", "2", "2", "2", "-", "2", "X", "-"],
  "9":   ["X", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "X"],
};

export function getSegregation(rowClass: string, colClass: string): SegCode {
  const row = RAW_MATRIX[rowClass];
  if (!row) return "-";
  const idx = C.indexOf(colClass as (typeof C)[number]);
  if (idx === -1) return "-";
  return row[idx];
}

export const MATRIX_AXIS = C;

export interface CountryRestriction {
  country: string;
  flag: string;
  authority: string;
  bullets: string[];
}

export const LATAM_IMDG_RESTRICTIONS: CountryRestriction[] = [
  {
    country: "Ecuador",
    flag: "🇪🇨",
    authority: "SENAE / DIRNEA / SPTMF / Comando Conjunto FFAA",
    bullets: [
      "Clase 1 (explosivos): permiso especial Comando Conjunto FFAA antes de embarque.",
      "Clase 7 (radiactivos): prohibido sin licencia OAEN; importadores deben tener registro previo.",
      "Clase 6.1 y 6.2: requieren registro sanitario ARCSA si tiene uso médico/farmacéutico.",
      "Clase 5.2 (peróxidos orgánicos): declarar tipo P1/P2 y SADT (Self-Accelerating Decomposition Temperature) en ECUAPASS 72h antes del arribo a Contecon.",
      "Clase 5.2 P2 (con control de temperatura): obligatorio contenedor reefer con monitoreo continuo de Control Temperature (CT) y Emergency Temperature (ET) según IMDG Cap. 7.7.",
      "Clase 5.2 tipo A y mezclas inestables: prohibidos en tránsito por Guayaquil — pre-coordinar con la Subsecretaría de Puertos (SPTMF) para rutas alternativas (Manta o multimodal).",
      "Permanencia limitada en patio: Contecon admite Clase 5.2 P2 máximo 72h post-descarga; el consignatario debe retirar antes para evitar abandono y reexportación.",
      "Puerto Esmeraldas no acepta Clase 1; usar Manta o Guayaquil.",
    ],
  },
  {
    country: "Perú",
    flag: "🇵🇪",
    authority: "DICAPI / SUNAT / DIGESA",
    bullets: [
      "IMO 1 prohibido en zona pasajeros del puerto Callao; usar terminal APM Callao Norte.",
      "Clase 7 requiere autorización IPEN (Instituto Peruano de Energía Nuclear).",
      "Anticipación: declarar peligrosos 72h antes de arribo en SIIA.",
      "Aeropuerto Jorge Chávez (LIM): clase 1 requiere coordinación con LAP-Cargo zona segura.",
      "Clase 5.2 (peróxidos orgánicos): DIGESA exige registro previo de importador y clasificación HS específica (subpartidas 2842/2933 según tipo).",
      "Clase 5.2 P2 (control de temperatura): reefer con monitoreo CT/ET; DICAPI inspecciona pre-zarpe y pre-descarga.",
      "Tipo A y mezclas inestables: prohibidos; requieren autorización especial DICAPI con justificación técnica de SADT.",
      "Permanencia en Callao: APMTC y DPW permiten hasta 96h post-descarga para Clase 5.2 P2 con plan de retiro firmado.",
    ],
  },
  {
    country: "Panamá",
    flag: "🇵🇦",
    authority: "AMP / ACP / SENAN / ATTT",
    bullets: [
      "Clase 7 (radiactivos): licencia previa Autoridad Marítima de Panamá (AMP).",
      "Clase 1 división 1.1 a través del Canal: ventana operativa específica + escolta SENAN.",
      "Tránsito ZLC: confirmar que el seguro cubra mercancía peligrosa en zona franca.",
      "Clase 5.2 tránsito por Canal de Panamá: ACP exige declaración con SADT 96h antes; vessel debe llevar a bordo plan de contingencia térmica.",
      "Clase 5.2 P2 en MIT (Manzanillo): aceptado con reefer + monitoreo continuo; Balboa/Cristóbal aceptan con condiciones especiales.",
      "Tipo A y mezclas inestables: prohibidos en tránsito por el Canal — usar Cristóbal o Balboa con escolta SENAN; coordinar con AMP.",
      "ZLC peróxidos: almacenamiento solo en bodegas refrigeradas certificadas por la Autoridad ZLC; reexpedición rápida obligatoria.",
    ],
  },
  {
    country: "Colombia",
    flag: "🇨🇴",
    authority: "DIMAR / DIAN / Ministerio de Transporte",
    bullets: [
      "IMDG declarado en SIIA con 72h de anticipación al arribo a puerto.",
      "Cartagena, Buenaventura y Santa Marta tienen muelles dedicados para peligrosos.",
      "Transporte terrestre interno requiere unidades especializadas con tripulación certificada (Decreto 1609).",
      "Clase 5.2 (peróxidos orgánicos): DIMAR Resolución 0716 — declaración SIIA con SADT + tipo P1/P2; SPRC y Contecar (Cartagena) tienen muelle dedicado refrigerado.",
      "Clase 5.2 P2: reefer obligatorio con monitoreo CT/ET; Buenaventura admite solo con plan de retiro inmediato (sin permanencia en patio).",
      "Tipo A y mezclas inestables: prohibidos por Buenaventura; usar Cartagena con coordinación previa DIMAR + Min Transporte.",
      "Transporte terrestre interno de Clase 5.2: vehículos cisterna o GRG con certificación NMI vigente (Decreto 1609 + Resolución 1223 Min Transporte).",
    ],
  },
];
