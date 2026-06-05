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

/**
 * EN-only LATAM pitfalls (counterpart to `latamPitfalls` in src/lib/incoterms.ts).
 * Mirrors the same code → 3-bullet structure but written in English.
 */
const LATAM_PITFALLS_EN: Record<string, string[]> = {
  EXW: [
    "Ecuador: the foreign buyer cannot act as exporter at SENAE. Use FCA instead.",
    "Peru: SUNAT requires a Peruvian RUC for the exporter; under EXW the foreign buyer cannot file the DUA.",
    "Bottom line: EXW only works between domestic operators. For LATAM international trade, FCA is almost always the right choice.",
  ],
  FCA: [
    "Specify the delivery place EXACTLY — seller's warehouse vs. carrier's terminal flips responsibility entirely.",
    "In Ecuador and Peru, FCA at seller's warehouse means buyer arranges pickup — coordinate ahead because some zones restrict heavy-truck access.",
    "For containerized shipments, FCA at port terminal is usually cleaner than FCA at warehouse.",
  ],
  FAS: [
    "FAS is mainly used for heavy break-bulk or project cargo. For containers, FCA at terminal is preferable.",
    "At Callao and Guayaquil, terminal handling charges (THC) often sit in a gray area — agree explicitly who pays.",
  ],
  FOB: [
    "FOB only applies to maritime bulk or break-bulk cargo. For containers, the ICC recommends FCA, not FOB — though the industry still uses FOB by tradition.",
    "Origin LATAM: seller must hire the customs agent and pay terminal costs — verify these are included in their FOB quote.",
    "Risk transfers when loaded on board, not when arriving at the port. If a crane drops the cargo mid-lift, liability depends on the exact moment.",
  ],
  CFR: [
    "Common trap: the buyer assumes CFR includes insurance because seller pays freight. It does NOT. If buyer doesn't buy insurance and a loss occurs at sea, there's no coverage.",
    "Useful when the LATAM buyer wants carrier visibility and rate certainty, while accepting risk from origin onward.",
  ],
  CIF: [
    "Clause C is MINIMUM coverage — only catastrophic events. For high-value cargo, negotiate Clause A (all risks) and accept the higher cost.",
    "Panama / ZLC: confirm the insurance covers free-zone cargo — not every policy includes it by default.",
    "Insured value is 110% of CIF by ICC convention — confirm the certificate reflects it.",
  ],
  CPT: [
    "CPT is the multimodal counterpart to CFR. Useful for air and combined transport, where FOB/CIF do not apply.",
    "The destination must be specific: 'CPT Lima' is ambiguous. Use 'CPT Customer's Warehouse, Av. X #Y, Lima'.",
  ],
  CIP: [
    "Key difference from CIF: CIP requires Clause A (all risks) by default — pricier but broader coverage.",
    "For air shipments to LATAM, CIP is preferable to CPT when the cargo is electronics or high-value.",
  ],
  DAP: [
    "DAP is the most used term by LATAM buyers who want a door-to-port rate without dealing with the carrier, while keeping import control.",
    "Seller must coordinate with a forwarder that has a destination network — Gloval covers EC/PE/PA/USA with our own offices.",
  ],
  DPU: [
    "Only viable if the seller can actually unload at destination. Verify the destination site has a dock, forklift, or labor.",
    "Replaced the former DAT (Delivered at Terminal) in Incoterms 2020.",
  ],
  DDP: [
    "DDP requires the foreign seller to act as importer — in Peru that means a Peruvian RUC, in Ecuador a SENAE RUC, etc. Most foreign exporters do NOT qualify.",
    "For LATAM, DDP is almost always replaced by DAP + a local agent — the buyer clears customs and the seller reimburses duties if agreed.",
    "If you insist on DDP to Peru/Ecuador, the seller must hire a local customs agent and sign a formal power of attorney — process takes 2-3 extra weeks.",
  ],
};

export default function IncotermsPage() {
  const [selectedCode, setSelectedCode] = useState<Incoterm["code"]>("FOB");
  const selected = INCOTERMS.find((i) => i.code === selectedCode)!;
  const pitfallsEn = LATAM_PITFALLS_EN[selected.code] ?? selected.latamPitfalls;

  return (
    <div className="bg-gv-bg-soft min-h-screen pt-24">
      <div className="max-w-7xl mx-auto px-6 pt-8">
        <Link
          href="/tools"
          className="inline-flex items-center gap-1 text-sm text-gv-blue/70 hover:text-gv-blue"
        >
          <ChevronLeft className="size-4" />
          Back to Tools
        </Link>
      </div>

      <header className="max-w-7xl mx-auto px-6 pt-6 pb-12">
        <H2>Incoterms 2020</H2>
        <p className="mt-6 text-base md:text-lg text-gv-muted max-w-3xl leading-relaxed">
          The ICC&apos;s 11 official rules that define cost, risk, and clearance
          responsibilities between seller and buyer in international trade.
          Select one to see details and common pitfalls in LATAM.
        </p>
      </header>

      {/* Selector pills */}
      <section className="max-w-7xl mx-auto px-6 pb-10">
        <div className="bg-white rounded-card border border-gv-border shadow-card p-6">
          <div className="text-xs font-bold tracking-[0.2em] uppercase text-gv-muted mb-4">
            Select an Incoterm
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
                  <span className="ml-2 inline-flex items-center" aria-label={it.modality === "maritime" ? "Maritime only" : "Any mode"}>
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
              <Ship className="size-3.5" /> Maritime / inland waterway only
            </span>
            <span className="inline-flex items-center gap-1.5">
              <Plane className="size-3.5" /> Any mode of transport
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
                      <Ship className="size-4" /> Maritime only
                    </>
                  ) : (
                    <>
                      <Plane className="size-4" /> Any mode
                    </>
                  )}
                </span>
              </div>
            </div>
            <p className="mt-6 text-base text-gv-blue leading-relaxed max-w-4xl">
              {selected.summaryEn}
            </p>
          </div>

          {/* Phases breakdown */}
          <div className="p-8 md:p-10">
            <div className="flex items-center justify-between mb-6">
              <h4 className="text-sm font-bold tracking-[0.2em] uppercase text-gv-orange">
                Cost &amp; risk allocation
              </h4>
              <Legend />
            </div>
            <div className="overflow-x-auto -mx-2 px-2">
              <table className="w-full text-sm min-w-[700px]">
                <thead>
                  <tr className="text-xs uppercase tracking-wider text-gv-muted border-b border-gv-border">
                    <th className="text-left py-3 pr-4 font-semibold w-1/2">
                      Journey phase
                    </th>
                    <th className="text-center py-3 px-2 font-semibold">Cost</th>
                    <th className="text-center py-3 px-2 font-semibold">Risk</th>
                  </tr>
                </thead>
                <tbody>
                  {PHASES.map((phase) => {
                    const p = selected.phases[phase.id as PhaseId];
                    return (
                      <tr key={phase.id} className="border-b border-gv-border/60 last:border-0">
                        <td className="py-3 pr-4 text-gv-blue font-medium">
                          {phase.labelEn}
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
                Common pitfalls in LATAM
              </span>
            </div>
            <h4 className="text-2xl font-bold text-gv-blue mb-6">
              What we see often with {selected.code} to or from LATAM
            </h4>
            <ul className="space-y-3">
              {pitfallsEn.map((item, i) => (
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
              <BrandButton variant="filled" href="https://www.glovalshipping.com/request-a-quote">
                Quote with {selected.code}
                <ArrowRight className="size-4" />
              </BrandButton>
              <BrandButton variant="secondary" href="https://www.glovalshipping.com/contact-us">
                Talk to an advisor
              </BrandButton>
            </div>
          </div>
        </div>
      </section>

      {/* Comparison table — all 11 */}
      <section className="bg-white">
        <div className="max-w-7xl mx-auto px-6 py-20">
          <H2 className="!text-3xl md:!text-4xl">Quick comparison</H2>
          <p className="mt-6 text-base text-gv-muted max-w-3xl">
            Overview of the 11 Incoterms across 9 journey phases. <PartyChip party="S" /> = seller, <PartyChip party="B" /> = buyer.
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
                      {p.labelEn}
                    </th>
                  ))}
                </tr>
                <tr className="bg-gv-blue/90 text-white text-[10px] uppercase tracking-wider">
                  <th className="sticky left-0 bg-gv-blue/90 z-10"></th>
                  {PHASES.map((p) => (
                    <Fragment key={p.id}>
                      <th className="px-1 py-2 font-medium border-l border-white/20">Cost</th>
                      <th className="px-1 py-2 font-medium">Risk</th>
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
            Click any row to view the full detail of that Incoterm above.
          </p>
        </div>
      </section>
    </div>
  );
}

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
      title={isSeller ? "Seller" : "Buyer"}
    >
      {party}
    </span>
  );
}

function Legend() {
  return (
    <div className="flex items-center gap-4 text-xs text-gv-muted">
      <span className="inline-flex items-center gap-1.5">
        <PartyChip party="S" small /> Seller
      </span>
      <span className="inline-flex items-center gap-1.5">
        <PartyChip party="B" small /> Buyer
      </span>
    </div>
  );
}
