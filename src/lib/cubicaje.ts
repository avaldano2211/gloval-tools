export type Mode = "ocean" | "air" | "courier";
export type DimUnit = "cm" | "m" | "in";
export type WeightUnit = "kg" | "lb";

export interface Piece {
  id: string;
  length: number;
  width: number;
  height: number;
  weight: number;
  qty: number;
}

const TO_M: Record<DimUnit, number> = { cm: 0.01, m: 1, in: 0.0254 };
const TO_KG: Record<WeightUnit, number> = { kg: 1, lb: 0.453592 };

const DIM_DECIMALS: Record<DimUnit, number> = { cm: 1, m: 3, in: 2 };

/** Convierte una dimensión entre cm / m / in conservando el tamaño físico real. */
export function convertDim(v: number, from: DimUnit, to: DimUnit): number {
  if (from === to || !Number.isFinite(v)) return v;
  const out = (v * TO_M[from]) / TO_M[to];
  const f = 10 ** DIM_DECIMALS[to];
  return Math.round(out * f) / f;
}

/** Convierte un peso entre kg / lb conservando el valor físico real. */
export function convertWeight(v: number, from: WeightUnit, to: WeightUnit): number {
  if (from === to || !Number.isFinite(v)) return v;
  const out = (v * TO_KG[from]) / TO_KG[to];
  return Math.round(out * 100) / 100;
}

export type ContainerKey = "c20" | "c40" | "c40hc";

export interface ContainerLimits {
  cbm: number;
  /** Internal dimensions in meters: [length, width, height] */
  internal: [number, number, number];
  /** Door opening in meters: [width, height] — what the cargo must pass through */
  door: [number, number];
  /** Max payload kg */
  payloadKg: number;
}

/** Internal + door dims from src/lib/containers.ts (kept in sync manually). */
export const CONTAINER_LIMITS: Record<ContainerKey, ContainerLimits> = {
  c20:   { cbm: 33.2, internal: [5.898, 2.352, 2.393],  door: [2.343, 2.280], payloadKg: 28250 },
  c40:   { cbm: 67.7, internal: [12.032, 2.352, 2.393], door: [2.343, 2.280], payloadKg: 28750 },
  c40hc: { cbm: 76.4, internal: [12.032, 2.352, 2.698], door: [2.343, 2.585], payloadKg: 28600 },
};

export interface ContainerFit {
  fitsByDimension: boolean;
  fillPct: number;
  exceedsPayload: boolean;
}

export interface PieceIssue {
  index: number;
  pieceLabel: string;
  oversize: ContainerKey[];   // contenedores donde NO entra esta pieza
  /** Alto de la pieza en metros. */
  heightM: number;
  /** El alto excede la altura de la PUERTA del 40' HC (no pasa por la puerta). */
  tooTall: boolean;
  /** La huella (largo × ancho) no entra ni rotada por la puerta/piso del 40'. */
  footprintTooBig: boolean;
}

export interface CalcResult {
  totalCBM: number;
  totalGrossKg: number;
  volumetricKg: number;
  chargeableKg: number;
  containers: Record<ContainerKey, ContainerFit>;
  /** Piezas que no entran en NINGÚN contenedor estándar */
  oversizedPieces: PieceIssue[];
  /** Piezas con al menos una dimensión problemática en algún contenedor */
  oversizedAnywhere: boolean;
  suggestion: { mode: Mode | "fcl-20" | "fcl-40" | "fcl-40hc" | "flat-rack"; reason: string };
}

const VOL_DIVISOR_M3_PER_KG: Record<Mode, number> = {
  ocean: 1 / 1000,
  air: 1 / 167,
  courier: 1 / 200,
};

/**
 * ¿La pieza entra al contenedor? La carga ENTRA POR LA PUERTA y va PARADA, así
 * que el límite real de altura es la altura de la PUERTA (siempre menor que la
 * altura interna): lo que no pasa por la puerta no puede ir adentro, aunque su
 * volumen quepa de sobra. Solo la huella (largo × ancho) puede rotar 90° en el
 * piso; el lado más angosto entra por el ancho de la puerta y el más largo se
 * desliza por el largo interno.
 *
 * pieceDimsM viene como [largo, ancho, alto] (índice 2 = alto).
 */
function pieceFitsInContainer(
  pieceDimsM: [number, number, number],
  lim: ContainerLimits,
): boolean {
  const [pl, pw, ph] = pieceDimsM;
  const footMin = Math.min(pl, pw);
  const footMax = Math.max(pl, pw);
  const [doorW, doorH] = lim.door;
  const [intL, intW] = lim.internal;
  // 1) Debe PASAR por la puerta (alto + lado más angosto).
  if (ph > doorH) return false;
  if (footMin > doorW) return false;
  // 2) Debe caber en el piso interno una vez adentro.
  if (footMax > intL) return false;
  if (footMin > intW) return false;
  return true;
}

export function calc(
  pieces: Piece[],
  dimUnit: DimUnit,
  weightUnit: WeightUnit,
  mode: Mode,
): CalcResult {
  let totalCBM = 0;
  let totalGrossKg = 0;
  const oversizedPieces: PieceIssue[] = [];

  // Track if each container type can hold ALL pieces dimensionally
  const dimFitByContainer: Record<ContainerKey, boolean> = {
    c20: true,
    c40: true,
    c40hc: true,
  };

  pieces.forEach((p, idx) => {
    const L = p.length * TO_M[dimUnit];
    const W = p.width * TO_M[dimUnit];
    const H = p.height * TO_M[dimUnit];
    const dims: [number, number, number] = [L, W, H];
    totalCBM += L * W * H * p.qty;
    totalGrossKg += p.weight * TO_KG[weightUnit] * p.qty;

    const oversize: ContainerKey[] = [];
    (Object.keys(CONTAINER_LIMITS) as ContainerKey[]).forEach((k) => {
      if (!pieceFitsInContainer(dims, CONTAINER_LIMITS[k])) {
        oversize.push(k);
        dimFitByContainer[k] = false;
      }
    });
    if (oversize.length === 3) {
      const hc = CONTAINER_LIMITS.c40hc; // contenedor más permisivo
      oversizedPieces.push({
        index: idx,
        pieceLabel: `Pieza ${idx + 1}: ${p.length}×${p.width}×${p.height} ${dimUnit}`,
        oversize,
        heightM: H,
        tooTall: H > hc.door[1], // límite real = altura de la puerta
        footprintTooBig: !(Math.min(L, W) <= hc.door[0] && Math.max(L, W) <= hc.internal[0]),
      });
    }
  });

  const volumetricKg =
    mode === "ocean"
      ? totalCBM * 1000
      : totalCBM / VOL_DIVISOR_M3_PER_KG[mode];

  const chargeableKg =
    mode === "ocean"
      ? Math.max(totalGrossKg, totalCBM * 1000)
      : Math.max(totalGrossKg, volumetricKg);

  const containers = (Object.keys(CONTAINER_LIMITS) as ContainerKey[]).reduce(
    (acc, k) => {
      const lim = CONTAINER_LIMITS[k];
      acc[k] = {
        fitsByDimension: dimFitByContainer[k],
        fillPct: (totalCBM / lim.cbm) * 100,
        exceedsPayload: totalGrossKg > lim.payloadKg,
      };
      return acc;
    },
    {} as Record<ContainerKey, ContainerFit>,
  );

  let suggestion: CalcResult["suggestion"];
  if (oversizedPieces.length > 0) {
    suggestion = {
      mode: "flat-rack",
      reason:
        "Hay piezas que NO entran en contenedor estándar por dimensión. Considera Flat Rack, Open Top o break-bulk; consulta con tu agente Gloval.",
    };
  } else if (totalCBM < 1 && totalGrossKg < 100) {
    suggestion = {
      mode: "air",
      reason:
        "Volumen y peso bajos: aéreo o courier suelen ser más rápidos y económicos.",
    };
  } else if (totalCBM > 25) {
    suggestion = { mode: "fcl-40hc", reason: "Volumen alto: cotiza FCL 40' HC para mejor tarifa." };
  } else if (totalCBM > 15) {
    suggestion = { mode: "fcl-40", reason: "Volumen medio-alto: evalúa FCL 40' Standard." };
  } else if (totalCBM > 8) {
    suggestion = { mode: "fcl-20", reason: "Volumen medio: evalúa FCL 20' vs LCL según ruta y frecuencia." };
  } else {
    suggestion = { mode: "ocean", reason: "Volumen y peso aptos para LCL marítimo." };
  }

  return {
    totalCBM,
    totalGrossKg,
    volumetricKg,
    chargeableKg,
    containers,
    oversizedPieces,
    oversizedAnywhere: oversizedPieces.length > 0,
    suggestion,
  };
}

export interface Route {
  from: string;
  to: string;
  modality: "Marítimo" | "Aéreo" | "Multimodal";
  transitDays: string;
  notes: string;
}

export const LATAM_ROUTES: Route[] = [
  { from: "Miami (MIA)", to: "Guayaquil (GYE)", modality: "Marítimo", transitDays: "5–7 días", notes: "Servicio semanal vía MSK / CMA." },
  { from: "Miami (MIA)", to: "Lima (LIM)", modality: "Aéreo", transitDays: "1–2 días", notes: "Diario vía LATAM Cargo." },
  { from: "Hong Kong (HKG)", to: "Callao (CLL)", modality: "Marítimo", transitDays: "32–38 días", notes: "Vía Manzanillo PA." },
  { from: "Shanghai (SHA)", to: "Manzanillo (MIT)", modality: "Marítimo", transitDays: "28–34 días", notes: "Hub para distribución LATAM." },
  { from: "Houston (HOU)", to: "Cartagena (CTG)", modality: "Marítimo", transitDays: "4–6 días", notes: "Servicio semanal." },
  { from: "Los Angeles (LAX)", to: "Guayaquil (GYE)", modality: "Multimodal", transitDays: "5–15 días", notes: "Vía LAX→MIA tierra→GYE aéreo cuando hay backlog marítimo." },
  { from: "Madrid (MAD)", to: "Bogotá (BOG)", modality: "Aéreo", transitDays: "1–2 días", notes: "Iberia / Avianca diario." },
  { from: "Buenos Aires (BUE)", to: "Miami (MIA)", modality: "Marítimo", transitDays: "18–22 días", notes: "Vía Santos transbordo." },
];
