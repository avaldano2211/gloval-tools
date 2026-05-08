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

export type ContainerKey = "c20" | "c40" | "c40hc";

export interface ContainerLimits {
  cbm: number;
  /** Internal dimensions in meters: [length, width, height] */
  internal: [number, number, number];
  /** Max payload kg */
  payloadKg: number;
}

/** Internal dims from src/lib/containers.ts (kept in sync manually). */
export const CONTAINER_LIMITS: Record<ContainerKey, ContainerLimits> = {
  c20:   { cbm: 33.2, internal: [5.898, 2.352, 2.393], payloadKg: 28250 },
  c40:   { cbm: 67.7, internal: [12.032, 2.352, 2.393], payloadKg: 28750 },
  c40hc: { cbm: 76.4, internal: [12.032, 2.352, 2.698], payloadKg: 28600 },
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
 * Una pieza encaja en un contenedor si, ordenadas ambas por dimensión
 * ascendente, cada dim de la pieza ≤ dim correspondiente del contenedor.
 * (Esto cubre cualquier rotación posible.)
 */
function pieceFitsInContainer(
  pieceDimsM: [number, number, number],
  containerDimsM: [number, number, number],
): boolean {
  const p = [...pieceDimsM].sort((a, b) => a - b);
  const c = [...containerDimsM].sort((a, b) => a - b);
  return p[0] <= c[0] && p[1] <= c[1] && p[2] <= c[2];
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
      if (!pieceFitsInContainer(dims, CONTAINER_LIMITS[k].internal)) {
        oversize.push(k);
        dimFitByContainer[k] = false;
      }
    });
    if (oversize.length === 3) {
      oversizedPieces.push({
        index: idx,
        pieceLabel: `Pieza ${idx + 1}: ${p.length}×${p.width}×${p.height} ${dimUnit}`,
        oversize,
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
