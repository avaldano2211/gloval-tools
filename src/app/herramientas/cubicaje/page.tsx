"use client";

import { useMemo, useState } from "react";
import {
  Piece,
  Mode,
  DimUnit,
  WeightUnit,
  calc,
  LATAM_ROUTES,
  type ContainerKey,
} from "@/lib/cubicaje";
import { BrandButton } from "@/components/brand/BrandButton";
import { H2 } from "@/components/brand/H2";
import {
  ChevronLeft,
  Plus,
  Trash2,
  Ship,
  Plane,
  Package,
  Lightbulb,
  Download,
  AlertTriangle,
} from "lucide-react";
import Link from "next/link";

const MODES: { id: Mode; label: string; icon: typeof Ship; sub: string }[] = [
  { id: "ocean", label: "Marítimo", icon: Ship, sub: "1 CBM = 1.000 kg" },
  { id: "air", label: "Aéreo (IATA)", icon: Plane, sub: "1 m³ = 167 kg" },
  { id: "courier", label: "Courier", icon: Package, sub: "1 m³ = 200 kg" },
];

let _id = 0;
const newPiece = (): Piece => ({
  id: `p_${++_id}_${Date.now()}`,
  length: 100,
  width: 100,
  height: 100,
  weight: 50,
  qty: 1,
});

export default function CubicajePage() {
  const [pieces, setPieces] = useState<Piece[]>([newPiece()]);
  const [dimUnit, setDimUnit] = useState<DimUnit>("cm");
  const [weightUnit, setWeightUnit] = useState<WeightUnit>("kg");
  const [mode, setMode] = useState<Mode>("ocean");
  const [routeIdx, setRouteIdx] = useState<number | "">("");

  const result = useMemo(
    () => calc(pieces, dimUnit, weightUnit, mode),
    [pieces, dimUnit, weightUnit, mode],
  );

  const updatePiece = (id: string, field: keyof Piece, value: number) => {
    setPieces((ps) =>
      ps.map((p) => (p.id === id ? { ...p, [field]: value } : p)),
    );
  };

  const exportCSV = () => {
    const header = `Largo (${dimUnit}),Ancho (${dimUnit}),Alto (${dimUnit}),Peso (${weightUnit}),Cantidad`;
    const rows = pieces.map(
      (p) => `${p.length},${p.width},${p.height},${p.weight},${p.qty}`,
    );
    const summary = [
      "",
      "Resumen",
      `Modalidad,${mode}`,
      `CBM total,${result.totalCBM.toFixed(3)}`,
      `Peso bruto (kg),${result.totalGrossKg.toFixed(2)}`,
      `Peso volumétrico (kg),${result.volumetricKg.toFixed(2)}`,
      `Peso facturable (kg),${result.chargeableKg.toFixed(2)}`,
    ];
    const blob = new Blob([[header, ...rows, ...summary].join("\n")], {
      type: "text/csv;charset=utf-8;",
    });
    const a = document.createElement("a");
    a.href = URL.createObjectURL(blob);
    a.download = `cubicaje-gloval-${new Date().toISOString().slice(0, 10)}.csv`;
    a.click();
    URL.revokeObjectURL(a.href);
  };

  return (
    <div className="bg-gv-bg-soft min-h-screen">
      <div className="max-w-7xl mx-auto px-6 pt-8">
        <Link
          href="/herramientas"
          className="inline-flex items-center gap-1 text-sm text-gv-blue/70 hover:text-gv-blue"
        >
          <ChevronLeft className="size-4" />
          Volver a Herramientas
        </Link>
      </div>

      <header className="max-w-7xl mx-auto px-6 pt-6 pb-12">
        <H2>Calculadora de Cubicaje y Peso</H2>
        <p className="mt-6 text-base md:text-lg text-gv-muted max-w-3xl leading-relaxed">
          Calcula CBM, peso volumétrico y peso facturable para envíos
          marítimos, aéreos y courier. Sugiere modalidad óptima según volumen y
          ruta LATAM.
        </p>
      </header>

      <section className="max-w-7xl mx-auto px-6 pb-12 grid lg:grid-cols-[1fr_360px] gap-8">
        {/* LEFT: Pieces table */}
        <div className="space-y-6">
          {/* Mode tabs */}
          <div className="bg-white rounded-card border border-gv-border shadow-card p-2 flex gap-1">
            {MODES.map((m) => {
              const active = m.id === mode;
              const Icon = m.icon;
              return (
                <button
                  key={m.id}
                  onClick={() => setMode(m.id)}
                  className={`flex-1 px-4 py-3 rounded-xl text-left transition-colors ${
                    active
                      ? "bg-gv-blue text-white"
                      : "text-gv-blue hover:bg-gv-bg-soft"
                  }`}
                >
                  <div className="flex items-center gap-2 font-semibold text-sm">
                    <Icon className="size-4" /> {m.label}
                  </div>
                  <div
                    className={`text-xs mt-0.5 ${
                      active ? "text-white/70" : "text-gv-muted"
                    }`}
                  >
                    {m.sub}
                  </div>
                </button>
              );
            })}
          </div>

          {/* Units */}
          <div className="bg-white rounded-card border border-gv-border shadow-card p-6">
            <div className="flex flex-wrap items-center gap-4">
              <UnitSelect
                label="Dimensiones"
                value={dimUnit}
                options={["cm", "m", "in"]}
                onChange={(v) => setDimUnit(v as DimUnit)}
              />
              <UnitSelect
                label="Peso"
                value={weightUnit}
                options={["kg", "lb"]}
                onChange={(v) => setWeightUnit(v as WeightUnit)}
              />
            </div>

            {/* Pieces */}
            <div className="mt-6 overflow-x-auto">
              <table className="w-full text-sm">
                <thead>
                  <tr className="text-xs uppercase tracking-wider text-gv-muted">
                    <th className="text-left pb-2 font-semibold">Largo ({dimUnit})</th>
                    <th className="text-left pb-2 font-semibold">Ancho ({dimUnit})</th>
                    <th className="text-left pb-2 font-semibold">Alto ({dimUnit})</th>
                    <th className="text-left pb-2 font-semibold">Peso ({weightUnit})</th>
                    <th className="text-left pb-2 font-semibold">Cant.</th>
                    <th className="pb-2 w-10"></th>
                  </tr>
                </thead>
                <tbody>
                  {pieces.map((p, idx) => (
                    <tr key={p.id} className="border-t border-gv-border">
                      {(["length", "width", "height", "weight", "qty"] as const).map(
                        (field) => (
                          <td key={field} className="py-2 pr-2">
                            <input
                              type="number"
                              min={0}
                              value={p[field]}
                              onChange={(e) =>
                                updatePiece(p.id, field, +e.target.value || 0)
                              }
                              className="w-full px-3 py-2 rounded-lg border border-gv-border focus:outline-none focus:ring-2 focus:ring-gv-blue/30 text-gv-blue font-semibold"
                            />
                          </td>
                        ),
                      )}
                      <td className="py-2">
                        <button
                          onClick={() =>
                            setPieces((ps) =>
                              ps.length > 1 ? ps.filter((x) => x.id !== p.id) : ps,
                            )
                          }
                          disabled={pieces.length === 1}
                          className="size-9 rounded-lg flex items-center justify-center text-gv-muted hover:text-red-600 hover:bg-red-50 disabled:opacity-30 disabled:cursor-not-allowed"
                          aria-label={`Eliminar pieza ${idx + 1}`}
                        >
                          <Trash2 className="size-4" />
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
              <button
                onClick={() => setPieces((ps) => [...ps, newPiece()])}
                className="mt-4 inline-flex items-center gap-1.5 text-sm font-semibold text-gv-blue hover:text-gv-blue-dark"
              >
                <Plus className="size-4" /> Agregar pieza
              </button>
            </div>
          </div>

          {/* LATAM differentiator: route selector */}
          <div className="bg-white rounded-card border border-gv-border shadow-card p-6">
            <div className="flex items-center gap-2 mb-3">
              <span className="text-xs font-bold tracking-[0.2em] uppercase text-gv-orange">
                Diferenciador LATAM
              </span>
            </div>
            <h3 className="text-lg font-bold text-gv-blue">
              Ruta estimada (opcional)
            </h3>
            <p className="text-sm text-gv-muted mt-1 mb-4">
              Selecciona una ruta común y te sugerimos la modalidad típica + tránsito promedio.
            </p>
            <select
              value={routeIdx}
              onChange={(e) =>
                setRouteIdx(e.target.value === "" ? "" : +e.target.value)
              }
              className="w-full px-4 py-3 rounded-lg border border-gv-border bg-white text-gv-blue font-semibold focus:outline-none focus:ring-2 focus:ring-gv-blue/30"
            >
              <option value="">— Selecciona una ruta —</option>
              {LATAM_ROUTES.map((r, i) => (
                <option key={i} value={i}>
                  {r.from} → {r.to} ({r.modality})
                </option>
              ))}
            </select>
            {routeIdx !== "" && (
              <div className="mt-4 p-4 rounded-xl bg-gv-bg-soft text-sm">
                <div className="font-semibold text-gv-blue">
                  {LATAM_ROUTES[routeIdx].from} → {LATAM_ROUTES[routeIdx].to}
                </div>
                <div className="text-gv-muted mt-1">
                  Modalidad típica: <strong className="text-gv-blue">{LATAM_ROUTES[routeIdx].modality}</strong>{" "}
                  · Tránsito: <strong className="text-gv-blue">{LATAM_ROUTES[routeIdx].transitDays}</strong>
                </div>
                <div className="text-xs text-gv-muted mt-2">
                  {LATAM_ROUTES[routeIdx].notes}
                </div>
              </div>
            )}
          </div>
        </div>

        {/* RIGHT: Results sticky */}
        <aside className="lg:sticky lg:top-6 h-fit space-y-4">
          <div className="bg-white rounded-card border border-gv-border shadow-card p-6">
            <h3 className="text-sm font-bold tracking-[0.2em] uppercase text-gv-orange mb-4">
              Resultados
            </h3>
            <ResultRow label="CBM total" value={`${result.totalCBM.toFixed(3)} m³`} big />
            <ResultRow label="Peso bruto" value={`${result.totalGrossKg.toFixed(2)} kg`} />
            <ResultRow label="Peso volumétrico" value={`${result.volumetricKg.toFixed(2)} kg`} />
            <ResultRow
              label="Peso facturable"
              value={`${result.chargeableKg.toFixed(2)} kg`}
              highlight
            />

            {/* Oversize warning */}
            {result.oversizedAnywhere && (
              <div className="mt-6 pt-6 border-t border-gv-border">
                <div className="p-4 rounded-xl bg-red-50 border border-red-200">
                  <div className="flex items-start gap-2">
                    <AlertTriangle className="size-5 text-red-600 shrink-0 mt-0.5" />
                    <div>
                      <div className="text-xs font-bold tracking-[0.15em] uppercase text-red-600 mb-1">
                        Piezas fuera de medida
                      </div>
                      <div className="text-sm text-gv-blue font-semibold">
                        {result.oversizedPieces.length} pieza{result.oversizedPieces.length !== 1 ? "s" : ""} no encaja{result.oversizedPieces.length === 1 ? "" : "n"} en contenedor estándar.
                      </div>
                      <ul className="mt-2 space-y-1 text-xs text-gv-muted">
                        {result.oversizedPieces.map((p) => (
                          <li key={p.index}>• {p.pieceLabel}</li>
                        ))}
                      </ul>
                      <div className="mt-2 text-xs text-gv-muted leading-relaxed">
                        Considera <strong className="text-gv-blue">Flat Rack</strong>, <strong className="text-gv-blue">Open Top</strong> o <strong className="text-gv-blue">break-bulk</strong>. Ver dimensiones internas en <Link href="/herramientas/contenedores" className="text-gv-blue underline">Especificaciones de Contenedores</Link>.
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            )}

            {/* Container fill bars */}
            <div className="mt-6 pt-6 border-t border-gv-border">
              <div className="text-xs font-bold tracking-[0.15em] uppercase text-gv-blue/60 mb-3">
                Utilización de contenedor
              </div>
              <FillBar
                label="20' Standard"
                pct={result.containers.c20.fillPct}
                fits={result.containers.c20.fitsByDimension}
                exceedsPayload={result.containers.c20.exceedsPayload}
              />
              <FillBar
                label="40' Standard"
                pct={result.containers.c40.fillPct}
                fits={result.containers.c40.fitsByDimension}
                exceedsPayload={result.containers.c40.exceedsPayload}
              />
              <FillBar
                label="40' High Cube"
                pct={result.containers.c40hc.fillPct}
                fits={result.containers.c40hc.fitsByDimension}
                exceedsPayload={result.containers.c40hc.exceedsPayload}
              />
            </div>

            {/* Suggestion */}
            <div className="mt-6 pt-6 border-t border-gv-border">
              <div className="flex items-start gap-2">
                <Lightbulb className="size-5 text-gv-orange shrink-0 mt-0.5" />
                <div>
                  <div className="text-xs font-bold tracking-[0.15em] uppercase text-gv-orange mb-1">
                    Sugerencia
                  </div>
                  <div className="text-sm text-gv-blue font-semibold capitalize">
                    {result.suggestion.mode.replace("-", " ")}
                  </div>
                  <div className="text-xs text-gv-muted mt-1 leading-relaxed">
                    {result.suggestion.reason}
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div className="space-y-2">
            <BrandButton
              href="https://gloval-shipping.example/cotizacion"
              className="w-full"
            >
              Cotizar este embarque
            </BrandButton>
            <BrandButton
              variant="secondary"
              onClick={exportCSV}
              className="w-full"
            >
              <Download className="size-4" /> Descargar CSV
            </BrandButton>
          </div>

          <p className="text-xs text-gv-muted leading-relaxed px-2">
            Cálculo informativo. La cotización oficial considera dimensiones
            paletizadas, tarifas de mercado y restricciones del carrier.
          </p>
        </aside>
      </section>
    </div>
  );
}

function UnitSelect({
  label,
  value,
  options,
  onChange,
}: {
  label: string;
  value: string;
  options: string[];
  onChange: (v: string) => void;
}) {
  return (
    <div className="flex items-center gap-2">
      <span className="text-xs font-bold tracking-[0.15em] uppercase text-gv-muted">
        {label}
      </span>
      <div className="flex rounded-pill border border-gv-border overflow-hidden">
        {options.map((opt) => {
          const active = opt === value;
          return (
            <button
              key={opt}
              onClick={() => onChange(opt)}
              className={`px-3 py-1.5 text-xs font-semibold transition-colors ${
                active
                  ? "bg-gv-blue text-white"
                  : "bg-white text-gv-blue hover:bg-gv-bg-soft"
              }`}
            >
              {opt}
            </button>
          );
        })}
      </div>
    </div>
  );
}

function ResultRow({
  label,
  value,
  big,
  highlight,
}: {
  label: string;
  value: string;
  big?: boolean;
  highlight?: boolean;
}) {
  return (
    <div
      className={`flex items-baseline justify-between gap-2 py-2 ${
        highlight ? "border-t border-b border-gv-orange/30 my-2" : ""
      }`}
    >
      <span
        className={`${
          highlight ? "text-gv-orange font-bold uppercase text-xs tracking-wider" : "text-gv-muted text-sm"
        }`}
      >
        {label}
      </span>
      <span
        className={`text-gv-blue font-extrabold ${
          big ? "text-2xl" : highlight ? "text-xl" : "text-base"
        }`}
      >
        {value}
      </span>
    </div>
  );
}

function FillBar({
  label,
  pct,
  fits,
  exceedsPayload,
}: {
  label: string;
  pct: number;
  fits: boolean;
  exceedsPayload: boolean;
}) {
  const clamped = Math.min(100, Math.max(0, pct));
  const overVolume = pct > 100;
  const hasIssue = !fits || overVolume || exceedsPayload;

  let badge: string | null = null;
  if (!fits) badge = "No encaja";
  else if (overVolume) badge = "Excede volumen";
  else if (exceedsPayload) badge = "Excede peso";

  return (
    <div className="mb-3 last:mb-0">
      <div className="flex justify-between items-center text-xs mb-1">
        <span className={`font-semibold ${!fits ? "text-red-600 line-through" : "text-gv-blue"}`}>
          {label}
        </span>
        <div className="flex items-center gap-2">
          {badge && (
            <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full bg-red-100 text-red-700 text-[10px] font-bold uppercase tracking-wider">
              <AlertTriangle className="size-3" />
              {badge}
            </span>
          )}
          <span className={`font-bold ${hasIssue ? "text-red-600" : "text-gv-muted"}`}>
            {fits ? `${pct.toFixed(0)}%` : "—"}
          </span>
        </div>
      </div>
      <div className="h-2 bg-gv-bg-soft rounded-full overflow-hidden">
        <div
          className={`h-full rounded-full transition-all ${
            !fits ? "bg-red-300" : overVolume ? "bg-red-500" : "bg-gv-blue"
          }`}
          style={{ width: `${fits ? clamped : 100}%` }}
        />
      </div>
    </div>
  );
}
