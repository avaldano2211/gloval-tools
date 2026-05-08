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

export interface CalcResult {
  totalCBM: number;
  totalGrossKg: number;
  volumetricKg: number;
  chargeableKg: number;
  fillPct20: number;
  fillPct40: number;
  fillPct40HC: number;
  suggestion: { mode: Mode | "fcl-20" | "fcl-40" | "fcl-40hc"; reason: string };
}

const VOL_DIVISOR_M3_PER_KG: Record<Mode, number> = {
  ocean: 1 / 1000,
  air: 1 / 167,
  courier: 1 / 200,
};

const CONTAINER_CBM = { c20: 33.2, c40: 67.7, c40hc: 76.4 };

export function calc(
  pieces: Piece[],
  dimUnit: DimUnit,
  weightUnit: WeightUnit,
  mode: Mode,
): CalcResult {
  let totalCBM = 0;
  let totalGrossKg = 0;
  for (const p of pieces) {
    const L = p.length * TO_M[dimUnit];
    const W = p.width * TO_M[dimUnit];
    const H = p.height * TO_M[dimUnit];
    const cbm = L * W * H;
    totalCBM += cbm * p.qty;
    totalGrossKg += p.weight * TO_KG[weightUnit] * p.qty;
  }

  const volumetricKg =
    mode === "ocean"
      ? totalCBM * 1000
      : totalCBM / VOL_DIVISOR_M3_PER_KG[mode];

  const chargeableKg =
    mode === "ocean"
      ? Math.max(totalGrossKg, totalCBM * 1000)
      : Math.max(totalGrossKg, volumetricKg);

  const fillPct20 = (totalCBM / CONTAINER_CBM.c20) * 100;
  const fillPct40 = (totalCBM / CONTAINER_CBM.c40) * 100;
  const fillPct40HC = (totalCBM / CONTAINER_CBM.c40hc) * 100;

  let suggestion: CalcResult["suggestion"] = {
    mode: "ocean",
    reason: "Volumen y peso aptos para LCL marítimo.",
  };
  if (totalCBM < 1 && totalGrossKg < 100) {
    suggestion = { mode: "air", reason: "Volumen y peso bajos: aéreo o courier suelen ser más rápidos y económicos." };
  } else if (totalCBM > 25) {
    suggestion = { mode: "fcl-40hc", reason: "Volumen alto: cotiza FCL 40' HC para mejor tarifa." };
  } else if (totalCBM > 15) {
    suggestion = { mode: "fcl-40", reason: "Volumen medio-alto: evalúa FCL 40' Standard." };
  } else if (totalCBM > 8) {
    suggestion = { mode: "fcl-20", reason: "Volumen medio: evalúa FCL 20' vs LCL según ruta y frecuencia." };
  }

  return {
    totalCBM,
    totalGrossKg,
    volumetricKg,
    chargeableKg,
    fillPct20,
    fillPct40,
    fillPct40HC,
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
