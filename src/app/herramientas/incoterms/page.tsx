"use client";

import { useState } from "react";
import {
  INCOTERMS,
  PHASES,
  type Incoterm,
  type PhaseId,
} from "@/lib/incoterms";
import { BrandButton } from "@/components/brand/BrandButton";
import { H2 } from "@/components/brand/H2";
import {
  ChevronLeft,
  Ship,
  Plane,
  AlertTriangle,
  ArrowRight,
} from "lucide-react";
import Link from "next/link";

export default function IncotermsPage() {
  const [selectedCode, setSelectedCode] = useState<Incoterm["code"]>("FOB");
  const selected = INCOTERMS.find((i) => i.code === selectedCode)!;

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
        <H2>Incoterms 2020</H2>
        <p className="mt-6 text-base md:text-lg text-gv-muted max-w-3xl leading-relaxed">
          Las 11 reglas oficiales de la ICC para definir responsabilidades de
          costo, riesgo y trámites entre vendedor y comprador en operaciones
          internacionales. Selecciona uno para ver detalles y errores comunes
          en LATAM.
        </p>
      </header>

      {/* Selector pills */}
      <section className="max-w-7xl mx-auto px-6 pb-10">
        <div className="bg-white rounded-card border border-gv-border shadow-card p-6">
          <div className="text-xs font-bold tracking-[0.2em] uppercase text-gv-muted mb-4">
            Selecciona un Incoterm
          </div>
          <div className="flex flex-wrap gap-2">
            {INCOTERMS.map((it) => {
              const active = it.code === selectedCode;
              return (
                <button
                  key={it.code}
                  onClick={() => setSelectedCode(it.code)}
                  className={`px-4 py-2 rounded-pill text-sm font-bold transition-colors border ${
                    active
                      ? "bg-gv-blue text-white border-gv-blue"
                      : "bg-white text-gv-blue border-gv-border hover:bg-gv-bg-soft"
                  }`}
                >
                  {it.code}
                  <span className="ml-2 inline-flex items-center" aria-label={it.modality === "maritime" ? "Solo marítimo" : "Cualquier modo"}>
                    {it.modality === "maritime" ? (
                      <Ship className={`size-3.5 ${active ? "text-white" : "text-gv-blue/60"}`} />
                    ) : (
                      <Plane className={`size-3.5 ${active ? "text-white" : "text-gv-blue/60"}`} />
                    )}
                  </span>
                </button>
              );
            })}
          </div>
          <div className="mt-4 flex flex-wrap gap-x-6 gap-y-1 text-xs text-gv-muted">
            <span className="inline-flex items-center gap-1.5">
              <Ship className="size-3.5" /> Solo marítimo / aguas interiores
            </span>
            <span className="inline-flex items-center gap-1.5">
              <Plane className="size-3.5" /> Cualquier modo de transporte
            </span>
          </div>
        </div>
      </section>

      {/* Detail card */}
      <section className="max-w-7xl mx-auto px-6 pb-12">
        <div className="bg-white rounded-card border border-gv-border shadow-card overflow-hidden">
          <div className="p-8 md:p-10 border-b border-gv-border">
            <div className="flex flex-col md:flex-row md:items-end gap-4 md:gap-6">
              <div>
                <div className="text-xs font-bold tracking-[0.2em] uppercase text-gv-orange">
                  Incoterm 2020
                </div>
                <h3 className="text-5xl md:text-6xl font-extrabold text-gv-blue mt-2 leading-none">
                  {selected.code}
                </h3>
                <div className="text-xl text-gv-muted mt-2 font-semibold">
                  {selected.name}
                </div>
              </div>
              <div className="flex-1 md:text-right">
                <span
                  className={`inline-flex items-center gap-2 px-4 py-2 rounded-pill text-xs font-bold uppercase tracking-wider ${
                    selected.modality === "maritime"
                      ? "bg-gv-blue/10 text-gv-blue"
                      : "bg-gv-orange/10 text-gv-orange"
                  }`}
                >
                  {selected.modality === "maritime" ? (
                    <>
                      <Ship className="size-4" /> Solo marítimo
                    </>
                  ) : (
                    <>
                      <Plane className="size-4" /> Cualquier modo
                    </>
                  )}
                </span>
              </div>
            </div>
            <p className="mt-6 text-base text-gv-blue leading-relaxed max-w-4xl">
              {selected.summaryEs}
            </p>
          </div>

          {/* Phases breakdown */}
          <div className="p-8 md:p-10">
            <div className="flex items-center justify-between mb-6">
              <h4 className="text-sm font-bold tracking-[0.2em] uppercase text-gv-orange">
                Reparto de costo y riesgo
              </h4>
              <Legend />
            </div>
            <div className="overflow-x-auto -mx-2 px-2">
              <table className="w-full text-sm min-w-[700px]">
                <thead>
                  <tr className="text-xs uppercase tracking-wider text-gv-muted border-b border-gv-border">
                    <th className="text-left py-3 pr-4 font-semibold w-1/2">
                      Fase del viaje
                    </th>
                    <th className="text-center py-3 px-2 font-semibold">Costo</th>
                    <th className="text-center py-3 px-2 font-semibold">Riesgo</th>
                  </tr>
                </thead>
                <tbody>
                  {PHASES.map((phase) => {
                    const p = selected.phases[phase.id as PhaseId];
                    return (
                      <tr key={phase.id} className="border-b border-gv-border/60 last:border-0">
                        <td className="py-3 pr-4 text-gv-blue font-medium">
                          {phase.labelEs}
                        </td>
                        <td className="text-center py-3 px-2">
                          <PartyChip party={p.cost} />
                        </td>
                        <td className="text-center py-3 px-2">
                          <PartyChip party={p.risk} />
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          </div>

          {/* LATAM pitfalls */}
          <div className="p-8 md:p-10 bg-gv-bg-soft border-t border-gv-border">
            <div className="flex items-center gap-2 mb-2">
              <AlertTriangle className="size-5 text-gv-orange" />
              <span className="text-xs font-bold tracking-[0.2em] uppercase text-gv-orange">
                Errores comunes en LATAM
              </span>
            </div>
            <h4 className="text-2xl font-bold text-gv-blue mb-6">
              Lo que vemos seguido en {selected.code} hacia/desde LATAM
            </h4>
            <ul className="space-y-3">
              {selected.latamPitfalls.map((item, i) => (
                <li key={i} className="flex gap-3">
                  <span className="size-6 rounded-full bg-gv-orange text-white text-xs font-bold inline-flex items-center justify-center shrink-0 mt-0.5">
                    {i + 1}
                  </span>
                  <span className="text-sm md:text-base text-gv-blue leading-relaxed">
                    {item}
                  </span>
                </li>
              ))}
            </ul>

            <div className="mt-8 flex flex-col sm:flex-row gap-3">
              <BrandButton href="https://gloval-shipping.example/cotizacion">
                Cotizar con {selected.code}
                <ArrowRight className="size-4" />
              </BrandButton>
              <BrandButton variant="secondary" href="https://gloval-shipping.example/contacto">
                Hablar con un asesor
              </BrandButton>
            </div>
          </div>
        </div>
      </section>

      {/* Comparison table — all 11 */}
      <section className="bg-white">
        <div className="max-w-7xl mx-auto px-6 py-20">
          <H2 className="!text-3xl md:!text-4xl">Comparativa rápida</H2>
          <p className="mt-6 text-base text-gv-muted max-w-3xl">
            Vista general de los 11 Incoterms en 9 fases del viaje. <PartyChip party="S" /> = vendedor, <PartyChip party="B" /> = comprador.
          </p>
          <div className="mt-10 overflow-x-auto rounded-card border border-gv-border shadow-card">
            <table className="w-full text-xs min-w-[900px] bg-white">
              <thead>
                <tr className="bg-gv-blue text-white">
                  <th className="text-left px-4 py-4 font-bold sticky left-0 bg-gv-blue z-10">
                    Incoterm
                  </th>
                  {PHASES.map((p) => (
                    <th
                      key={p.id}
                      className="text-center px-2 py-4 font-bold"
                      colSpan={2}
                    >
                      {p.labelEs}
                    </th>
                  ))}
                </tr>
                <tr className="bg-gv-blue/90 text-white text-[10px] uppercase tracking-wider">
                  <th className="sticky left-0 bg-gv-blue/90 z-10"></th>
                  {PHASES.map((p) => (
                    <Fragment key={p.id}>
                      <th className="px-1 py-2 font-medium border-l border-white/20">Costo</th>
                      <th className="px-1 py-2 font-medium">Riesgo</th>
                    </Fragment>
                  ))}
                </tr>
              </thead>
              <tbody>
                {INCOTERMS.map((it, i) => (
                  <tr
                    key={it.code}
                    className={`hover:bg-gv-bg-soft cursor-pointer ${
                      i % 2 === 0 ? "bg-white" : "bg-gv-bg-soft/40"
                    } ${it.code === selectedCode ? "ring-2 ring-gv-orange ring-inset" : ""}`}
                    onClick={() => {
                      setSelectedCode(it.code);
                      window.scrollTo({ top: 0, behavior: "smooth" });
                    }}
                  >
                    <td className="px-4 py-3 sticky left-0 bg-inherit z-10">
                      <div className="flex items-center gap-2">
                        <span className="font-extrabold text-gv-blue">{it.code}</span>
                        {it.modality === "maritime" ? (
                          <Ship className="size-3 text-gv-blue/50" />
                        ) : (
                          <Plane className="size-3 text-gv-blue/50" />
                        )}
                      </div>
                    </td>
                    {PHASES.map((phase) => {
                      const p = it.phases[phase.id as PhaseId];
                      return (
                        <Fragment key={phase.id}>
                          <td className="text-center px-1 py-3 border-l border-gv-border/40">
                            <PartyChip party={p.cost} small />
                          </td>
                          <td className="text-center px-1 py-3">
                            <PartyChip party={p.risk} small />
                          </td>
                        </Fragment>
                      );
                    })}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <p className="mt-4 text-xs text-gv-muted italic">
            Click en cualquier fila para ver el detalle completo de ese Incoterm arriba.
          </p>
        </div>
      </section>
    </div>
  );
}

// React Fragment helper for <tr> cells without keys conflict
function Fragment({ children }: { children: React.ReactNode }) {
  return <>{children}</>;
}

function PartyChip({ party, small }: { party: "S" | "B"; small?: boolean }) {
  const isSeller = party === "S";
  const size = small ? "size-5 text-[10px]" : "size-7 text-xs";
  return (
    <span
      className={`inline-flex items-center justify-center ${size} rounded-full font-bold ${
        isSeller ? "bg-gv-blue text-white" : "bg-gv-orange text-white"
      }`}
      title={isSeller ? "Vendedor (Seller)" : "Comprador (Buyer)"}
    >
      {party}
    </span>
  );
}

function Legend() {
  return (
    <div className="flex items-center gap-4 text-xs text-gv-muted">
      <span className="inline-flex items-center gap-1.5">
        <PartyChip party="S" small /> Vendedor
      </span>
      <span className="inline-flex items-center gap-1.5">
        <PartyChip party="B" small /> Comprador
      </span>
    </div>
  );
}
