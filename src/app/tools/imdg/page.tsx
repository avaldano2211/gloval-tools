"use client";

import { useState } from "react";
import {
  IMDG_CLASSES,
  MATRIX_AXIS,
  SEG_LEGEND,
  LATAM_IMDG_RESTRICTIONS,
  getSegregation,
  type SegCode,
} from "@/lib/imdg";
import { ImdgDiamond } from "@/components/tools/ImdgDiamond";
import { BrandButton } from "@/components/brand/BrandButton";
import { H2 } from "@/components/brand/H2";
import {
  ChevronLeft,
  AlertTriangle,
  ShieldAlert,
  X,
  TriangleAlert,
} from "lucide-react";
import Link from "next/link";

const VIEWS = [
  { id: "classes", label: "The 9 classes" },
  { id: "matrix", label: "Segregation matrix" },
  { id: "latam", label: "LATAM restrictions" },
] as const;

type ViewId = (typeof VIEWS)[number]["id"];

/** EN-only translations of class title / description / examples (lib/imdg.ts is ES). */
const CLASS_EN: Record<
  string,
  { title: string; description: string; examples: string }
> = {
  "1":   { title: "Explosives",                 description: "Substances and articles that pose a mass-explosion, projection, or fire hazard.", examples: "Gunpowder, detonators, dynamite, fireworks, ammunition." },
  "2.1": { title: "Flammable gases",            description: "Gases that are flammable in mixture of 13% or less by volume with air.", examples: "Propane, butane, acetylene, hydrogen." },
  "2.2": { title: "Non-flammable, non-toxic gases", description: "Asphyxiating, oxidizing, or low-hazard gases.", examples: "Helium, nitrogen, compressed oxygen, CO₂." },
  "2.3": { title: "Toxic gases",                description: "Gases toxic or corrosive to humans by inhalation.", examples: "Chlorine, anhydrous ammonia, ethylene oxide." },
  "3":   { title: "Flammable liquids",          description: "Liquids with flash point ≤ 60°C in closed cup.", examples: "Gasoline, diesel, alcohol, paints, solvents, perfumes." },
  "4.1": { title: "Flammable solids",           description: "Solids that ignite easily or can cause fire by friction.", examples: "Matches, sulfur, naphthalene, magnesium powder." },
  "4.2": { title: "Spontaneously combustible",  description: "Material that can heat up and ignite on air contact.", examples: "White phosphorus, wet activated carbon, some oilseeds." },
  "4.3": { title: "Dangerous when wet",         description: "Substances that release flammable gases on water contact.", examples: "Sodium, potassium, metallic calcium, carbides." },
  "5.1": { title: "Oxidizing substances",       description: "Substances that release oxygen and can cause or intensify fire.", examples: "Hydrogen peroxide, nitrates, chlorates, permanganate." },
  "5.2": { title: "Organic peroxides",          description: "Thermally unstable organic compounds that may decompose violently.", examples: "Benzoyl peroxide, methyl ethyl ketone peroxide." },
  "6.1": { title: "Toxic substances",           description: "Substances that can cause death or severe injury if ingested, inhaled, or touched.", examples: "Pesticides, cyanides, arsenic, mercury." },
  "6.2": { title: "Infectious substances",      description: "Substances containing pathogens that can cause disease.", examples: "Medical samples, hospital waste, viral cultures." },
  "7":   { title: "Radioactive material",       description: "Materials with specific activity > 70 kBq/kg.", examples: "Uranium, medical isotopes, radioactive measurement equipment." },
  "8":   { title: "Corrosive substances",       description: "Substances that by chemical action cause severe damage to tissue or materials.", examples: "Sulfuric acid, sodium hydroxide, batteries, hydrochloric acid." },
  "9":   { title: "Miscellaneous dangerous goods", description: "Substances and articles that present a hazard during transport not covered by other classes.", examples: "Lithium batteries, asbestos, dry ice, engines with fuel." },
};

const SEG_LEGEND_EN: Record<SegCode, { short: string; description: string }> = {
  "1": { short: "1", description: "Away from — at least 3 m horizontal separation on deck." },
  "2": { short: "2", description: "Separated from — in different compartments with intervening division." },
  "3": { short: "3", description: "Separated by complete compartment or hold." },
  "4": { short: "4", description: "Separated longitudinally by an intervening complete compartment." },
  "X": { short: "X", description: "PROHIBITED — stowage together is not allowed under any condition." },
  "-": { short: "—", description: "No specific class-level restriction. Check IMDG by UN Number." },
};

const SEG_BADGE_LABEL_EN: Record<SegCode, string> = {
  "1": "Type 1",
  "2": "Type 2",
  "3": "Type 3",
  "4": "Type 4",
  "X": "Prohibited",
  "-": "No restriction",
};

const LATAM_RESTRICTIONS_EN: Record<string, { authority: string; bullets: string[] }> = {
  "Ecuador": {
    authority: "SENAE / DIRNEA / SPTMF / Joint Armed Forces Command",
    bullets: [
      "Class 1 (explosives): special permit from Joint Armed Forces Command required before shipment.",
      "Class 7 (radioactive): banned without OAEN license; importers must hold prior registration.",
      "Classes 6.1 and 6.2: require ARCSA health registration if for medical or pharmaceutical use.",
      "Class 5.2 (organic peroxides): declare type P1/P2 and SADT (Self-Accelerating Decomposition Temperature) via ECUAPASS 72h before vessel call at Contecon.",
      "Class 5.2 P2 (temperature-controlled): reefer container mandatory with continuous monitoring of Control Temperature (CT) and Emergency Temperature (ET) per IMDG Ch. 7.7.",
      "Class 5.2 Type A and unstable mixtures: banned for transit through Guayaquil — pre-coordinate with Subsecretaría de Puertos (SPTMF) for alternatives (Manta or multimodal routing).",
      "Yard storage limited: Contecon accepts Class 5.2 P2 for max 72h post-discharge; consignee must withdraw within that window to avoid abandonment and re-export.",
      "Port of Esmeraldas does not accept Class 1; use Manta or Guayaquil instead.",
    ],
  },
  "Perú": {
    authority: "DICAPI / SUNAT / DIGESA",
    bullets: [
      "IMO 1 banned at the Callao passenger zone; use the APM Callao Norte terminal.",
      "Class 7 requires authorization from IPEN (Peruvian Nuclear Energy Institute).",
      "Pre-notification: declare dangerous goods 72h before arrival via SIIA.",
      "Jorge Chávez airport (LIM): Class 1 requires coordination with the LAP-Cargo secure zone.",
      "Class 5.2 (organic peroxides): DIGESA requires prior importer registration and specific HS classification (sub-headings 2842/2933 depending on type).",
      "Class 5.2 P2 (temperature-controlled): reefer with CT/ET monitoring mandatory; DICAPI inspects pre-departure and pre-discharge.",
      "Type A and unstable mixtures: banned; require special DICAPI authorization with technical SADT justification.",
      "Callao yard storage: APMTC and DPW allow up to 96h post-discharge for Class 5.2 P2 with a signed pickup plan.",
    ],
  },
  "Panamá": {
    authority: "AMP / ACP / SENAN / ATTT",
    bullets: [
      "Class 7 (radioactive): prior license from the Panama Maritime Authority (AMP).",
      "Class 1 division 1.1 transit through the Canal: specific operating window + SENAN escort.",
      "ZLC transit: confirm insurance covers hazardous cargo within the free zone.",
      "Class 5.2 Canal transit: ACP requires declaration with SADT 96h in advance; vessel must carry an on-board thermal contingency plan.",
      "Class 5.2 P2 at MIT (Manzanillo): accepted with reefer + continuous monitoring; Balboa/Cristóbal accept under special conditions.",
      "Type A and unstable mixtures: banned in Canal transit — route through Cristóbal or Balboa with SENAN escort; pre-coordinate with AMP.",
      "ZLC peroxides: storage only in refrigerated warehouses certified by the ZLC Authority; rapid re-export mandatory.",
    ],
  },
  "Colombia": {
    authority: "DIMAR / DIAN / Ministry of Transport",
    bullets: [
      "IMDG declared in SIIA 72h before arrival at port.",
      "Cartagena, Buenaventura, and Santa Marta have dedicated piers for hazardous cargo.",
      "Inland trucking requires specialized units with certified crews (Decree 1609).",
      "Class 5.2 (organic peroxides): DIMAR Resolution 0716 — SIIA declaration with SADT + type P1/P2; SPRC and Contecar (Cartagena) have dedicated refrigerated piers.",
      "Class 5.2 P2: reefer mandatory with CT/ET monitoring; Buenaventura only allowed with immediate pickup plan (no yard storage).",
      "Type A and unstable mixtures: banned at Buenaventura; route through Cartagena with prior DIMAR + Ministry of Transport coordination.",
      "Inland transport of Class 5.2: tanker vehicles or IBCs with valid NMI certification (Decree 1609 + Resolution 1223 Min Transporte).",
    ],
  },
};

export default function ImdgPage() {
  const [view, setView] = useState<ViewId>("classes");
  const [hoveredCell, setHoveredCell] = useState<{ row: string; col: string; code: SegCode } | null>(null);

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
        <div className="flex items-start gap-4">
          <TriangleAlert className="size-10 text-gv-orange shrink-0 mt-1" />
          <div>
            <H2>IMO / IMDG Table</H2>
            <p className="mt-6 text-base md:text-lg text-gv-muted max-w-3xl leading-relaxed">
              The 9 classes of dangerous goods under the IMDG Code, the on-board
              segregation matrix, and the country-specific restrictions for LATAM ports.
            </p>
          </div>
        </div>
      </header>

      {/* View tabs */}
      <section className="max-w-7xl mx-auto px-6 pb-10">
        <div className="bg-white rounded-card border border-gv-border shadow-card p-2 inline-flex gap-1 flex-wrap">
          {VIEWS.map((v) => {
            const active = v.id === view;
            return (
              <button
                key={v.id}
                onClick={() => setView(v.id)}
                className={`px-5 py-3 rounded-xl text-sm font-bold transition-colors ${
                  active
                    ? "bg-gv-blue text-white"
                    : "text-gv-blue hover:bg-gv-bg-soft"
                }`}
              >
                {v.label}
              </button>
            );
          })}
        </div>
      </section>

      {/* CLASSES view */}
      {view === "classes" && (
        <section className="max-w-7xl mx-auto px-6 pb-16">
          <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
            {IMDG_CLASSES.map((cls) => {
              const en = CLASS_EN[cls.code];
              return (
                <div
                  key={cls.code}
                  className="bg-white rounded-card border border-gv-border shadow-card p-6 flex gap-5 hover:shadow-card-hover hover:-translate-y-0.5 transition-all"
                >
                  <div className="shrink-0">
                    <ImdgDiamond cls={cls} size={88} />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="text-xs font-bold tracking-[0.15em] uppercase text-gv-orange">
                      Class {cls.code}
                    </div>
                    <h3 className="text-lg font-bold text-gv-blue mt-1 leading-tight">
                      {en?.title ?? cls.title}
                    </h3>
                    <p className="text-sm text-gv-muted mt-2 leading-relaxed">
                      {en?.description ?? cls.description}
                    </p>
                    <div className="mt-3 pt-3 border-t border-gv-border/60">
                      <div className="text-[10px] font-bold tracking-[0.15em] uppercase text-gv-blue/60 mb-1">
                        Examples
                      </div>
                      <p className="text-xs text-gv-muted leading-relaxed">
                        {en?.examples ?? cls.examples}
                      </p>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>

          <div className="mt-10 p-6 rounded-card bg-white border border-gv-orange/30">
            <div className="flex items-start gap-3">
              <AlertTriangle className="size-5 text-gv-orange shrink-0 mt-0.5" />
              <div className="text-sm text-gv-blue leading-relaxed">
                <strong className="font-bold">Notice:</strong> the diamonds shown are a reference rendering with the official color of each class. For real packaging and container labeling, use the official IMDG Code pictographic symbols.
              </div>
            </div>
          </div>
        </section>
      )}

      {/* MATRIX view */}
      {view === "matrix" && (
        <section className="max-w-7xl mx-auto px-6 pb-16 space-y-8">
          <div className="bg-white rounded-card border border-gv-border shadow-card p-6 md:p-8">
            <h3 className="text-lg font-bold text-gv-blue mb-4">
              IMDG Segregation Matrix (Ch. 7.2)
            </h3>
            <p className="text-sm text-gv-muted mb-6 max-w-3xl leading-relaxed">
              Cross two classes to see the segregation code required during
              stowage and transport. Hover any cell to see the detail.
            </p>

            {/* Legend */}
            <div className="flex flex-wrap gap-2 mb-6">
              {Object.entries(SEG_LEGEND).map(([code, info]) => {
                const label = SEG_BADGE_LABEL_EN[code as SegCode];
                return (
                  <div
                    key={code}
                    className="flex items-center gap-2 px-3 py-1.5 rounded-pill bg-gv-bg-soft text-xs"
                  >
                    <span
                      className="size-6 rounded inline-flex items-center justify-center font-bold text-[11px]"
                      style={{
                        background: info.color,
                        color: code === "X" ? "#fff" : "#000",
                      }}
                    >
                      {info.short}
                    </span>
                    <span className="text-gv-blue font-semibold">{label}</span>
                  </div>
                );
              })}
            </div>

            <div className="overflow-x-auto -mx-2 px-2">
              <table className="border-collapse min-w-[720px]">
                <thead>
                  <tr>
                    <th className="p-2 text-xs text-gv-muted font-medium"></th>
                    {MATRIX_AXIS.map((c) => (
                      <th
                        key={`col-${c}`}
                        className="p-1 text-xs font-bold text-gv-blue w-10 align-bottom"
                      >
                        <div className="rotate-0">{c}</div>
                      </th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {MATRIX_AXIS.map((row) => (
                    <tr key={`row-${row}`}>
                      <th className="p-2 text-xs font-bold text-gv-blue text-right pr-3 sticky left-0 bg-white">
                        {row}
                      </th>
                      {MATRIX_AXIS.map((col) => {
                        const code = getSegregation(row, col);
                        const info = SEG_LEGEND[code];
                        const isDiagonal = row === col;
                        return (
                          <td
                            key={`cell-${row}-${col}`}
                            className="p-1 text-center"
                            onMouseEnter={() =>
                              setHoveredCell({ row, col, code })
                            }
                            onMouseLeave={() => setHoveredCell(null)}
                          >
                            <div
                              className={`size-9 rounded inline-flex items-center justify-center text-[13px] font-bold cursor-help transition-transform hover:scale-110 ${
                                isDiagonal ? "opacity-50" : ""
                              }`}
                              style={{
                                background: info.color,
                                color: code === "X" ? "#fff" : "#000",
                              }}
                              title={`${row} with ${col}: ${SEG_LEGEND_EN[code].description}`}
                            >
                              {info.short}
                            </div>
                          </td>
                        );
                      })}
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            {/* Hover detail panel */}
            <div className="mt-6 min-h-20 p-4 rounded-xl bg-gv-bg-soft border border-gv-border">
              {hoveredCell ? (
                <div>
                  <div className="flex items-center gap-3 mb-2">
                    <span className="px-3 py-1 rounded-pill bg-gv-blue text-white text-xs font-bold">
                      Class {hoveredCell.row}
                    </span>
                    <X className="size-3 text-gv-muted" />
                    <span className="px-3 py-1 rounded-pill bg-gv-blue text-white text-xs font-bold">
                      Class {hoveredCell.col}
                    </span>
                  </div>
                  <div className="text-sm text-gv-blue font-semibold">
                    Code {SEG_LEGEND_EN[hoveredCell.code].short}
                  </div>
                  <div className="text-sm text-gv-muted mt-1 leading-relaxed">
                    {SEG_LEGEND_EN[hoveredCell.code].description}
                  </div>
                </div>
              ) : (
                <p className="text-sm text-gv-muted italic">
                  Hover over a cell to see the segregation detail between two classes.
                </p>
              )}
            </div>
          </div>

          <div className="p-6 rounded-card bg-white border border-gv-orange/30">
            <div className="flex items-start gap-3">
              <ShieldAlert className="size-5 text-gv-orange shrink-0 mt-0.5" />
              <div className="text-sm text-gv-blue leading-relaxed">
                <strong className="font-bold">Important:</strong> this matrix is a simplified version at the main-class level. The official IMDG table has additional rules per sub-class and per UN Number exceptions. For real shipping, consult the current IMDG Code or a certified consultant.
              </div>
            </div>
          </div>
        </section>
      )}

      {/* LATAM view */}
      {view === "latam" && (
        <section className="max-w-7xl mx-auto px-6 pb-16">
          <div className="grid md:grid-cols-2 gap-6">
            {LATAM_IMDG_RESTRICTIONS.map((c) => {
              const en = LATAM_RESTRICTIONS_EN[c.country];
              return (
                <div
                  key={c.country}
                  className="bg-white rounded-card border border-gv-border shadow-card p-7"
                >
                  <div className="flex items-center gap-3 mb-1">
                    <span className="text-3xl" aria-hidden>{c.flag}</span>
                    <h3 className="text-2xl font-bold text-gv-blue">{c.country}</h3>
                  </div>
                  <div className="text-xs font-semibold tracking-wider uppercase text-gv-orange mb-5">
                    {en?.authority ?? c.authority}
                  </div>
                  <ul className="space-y-3">
                    {(en?.bullets ?? c.bullets).map((b, i) => (
                      <li key={i} className="flex gap-3 text-sm leading-relaxed">
                        <span className="size-5 rounded-full bg-gv-orange text-white text-[10px] font-bold inline-flex items-center justify-center shrink-0 mt-0.5">
                          {i + 1}
                        </span>
                        <span className="text-gv-blue">{b}</span>
                      </li>
                    ))}
                  </ul>
                </div>
              );
            })}
          </div>

          <div className="mt-10 bg-gv-blue text-white rounded-card p-8 md:p-10">
            <h3 className="text-2xl md:text-3xl font-bold mb-4">
              Need to move dangerous goods?
            </h3>
            <p className="text-white/80 max-w-2xl leading-relaxed">
              Gloval Shipping has certified IMDG consultants in Miami, Panama, Ecuador, and Peru. We handle the official declaration, segregation, documentation, and country permits.
            </p>
            <div className="mt-6 flex flex-col sm:flex-row gap-3">
              <BrandButton
                href="https://www.glovalshipping.com/request-a-quote"
                className="!bg-gv-orange !border-gv-orange hover:!bg-gv-orange-dark"
              >
                Quote dangerous goods transport
              </BrandButton>
              <BrandButton
                variant="secondary"
                href="https://www.glovalshipping.com/contact-us"
                className="!bg-transparent !text-white !border-white hover:!bg-white/10"
              >
                Talk to an IMDG consultant
              </BrandButton>
            </div>
          </div>
        </section>
      )}

      {/* Final disclaimer */}
      <section className="max-w-7xl mx-auto px-6 pb-20">
        <div className="text-xs text-gv-muted italic max-w-3xl">
          This tool is informational and educational. The official dangerous goods declaration — in any mode (maritime IMDG, air IATA-DGR, road ADR) — must be made by a currently certified consultant in accordance with origin and destination country regulations.
        </div>
      </section>
    </div>
  );
}
