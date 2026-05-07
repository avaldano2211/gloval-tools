"use client";

import { useState } from "react";
import {
  CONTAINERS,
  LATAM_ROAD_LIMITS,
  LATAM_PORT_COMPATIBILITY,
} from "@/lib/containers";
import { ContainerDiagram } from "@/components/tools/ContainerDiagram";
import { BrandButton } from "@/components/brand/BrandButton";
import { H2 } from "@/components/brand/H2";
import { ChevronLeft, Truck, Anchor, Check, X } from "lucide-react";
import Link from "next/link";

export default function ContenedoresPage() {
  const [selectedId, setSelectedId] = useState("40hc");
  const spec = CONTAINERS.find((c) => c.id === selectedId)!;

  const groups: { label: string; ids: string[] }[] = [
    { label: "Estándar (DC)", ids: ["20gp", "40gp", "40hc", "45hc"] },
    { label: "Refrigerado", ids: ["20rf", "40rfhc"] },
    { label: "Open Top", ids: ["20ot", "40ot"] },
    { label: "Flat Rack", ids: ["20fr", "40fr"] },
    { label: "Tanque", ids: ["20tk"] },
  ];

  return (
    <div className="bg-gv-bg-soft min-h-screen">
      {/* Breadcrumb */}
      <div className="max-w-7xl mx-auto px-6 pt-8">
        <Link
          href="/herramientas"
          className="inline-flex items-center gap-1 text-sm text-gv-blue/70 hover:text-gv-blue"
        >
          <ChevronLeft className="size-4" />
          Volver a Herramientas
        </Link>
      </div>

      {/* Header */}
      <header className="max-w-7xl mx-auto px-6 pt-6 pb-12">
        <H2>Especificaciones de Contenedores</H2>
        <p className="mt-6 text-base md:text-lg text-gv-muted max-w-3xl leading-relaxed">
          Dimensiones, pesos y capacidad de cada tipo de contenedor estándar
          ISO. Selecciona un tipo para ver su ficha técnica completa.
        </p>
      </header>

      {/* Selector + Detail */}
      <section className="max-w-7xl mx-auto px-6 pb-12 grid lg:grid-cols-[280px_1fr] gap-8">
        {/* Sidebar: type selector */}
        <aside className="bg-white rounded-card border border-gv-border shadow-card p-6 h-fit lg:sticky lg:top-6">
          <h3 className="text-xs font-bold tracking-[0.2em] uppercase text-gv-muted mb-4">
            Tipos
          </h3>
          {groups.map((group) => (
            <div key={group.label} className="mb-5 last:mb-0">
              <div className="text-xs font-semibold text-gv-blue/60 uppercase tracking-wider mb-2">
                {group.label}
              </div>
              <ul className="space-y-1">
                {group.ids.map((id) => {
                  const c = CONTAINERS.find((c) => c.id === id);
                  if (!c) return null;
                  const active = id === selectedId;
                  return (
                    <li key={id}>
                      <button
                        onClick={() => setSelectedId(id)}
                        className={`w-full text-left px-3 py-2 rounded-lg text-sm font-medium transition-colors ${
                          active
                            ? "bg-gv-blue text-white"
                            : "text-gv-blue hover:bg-gv-bg-soft"
                        }`}
                      >
                        {c.name}
                      </button>
                    </li>
                  );
                })}
              </ul>
            </div>
          ))}
        </aside>

        {/* Main: diagram + spec */}
        <div className="space-y-6">
          {/* Diagram card */}
          <div className="bg-white rounded-card border border-gv-border shadow-card p-8">
            <h3 className="text-2xl font-bold text-gv-blue">{spec.name}</h3>
            <div className="mt-6 max-w-xl mx-auto">
              <ContainerDiagram spec={spec} />
            </div>
          </div>

          {/* Spec table */}
          <div className="bg-white rounded-card border border-gv-border shadow-card p-8">
            <h4 className="text-sm font-bold tracking-[0.2em] uppercase text-gv-orange mb-6">
              Ficha técnica
            </h4>
            <div className="grid sm:grid-cols-2 gap-6">
              <SpecBlock title="Dimensiones internas" rows={[
                ["Largo", `${spec.internal.length_m.toFixed(3)} m / ${(spec.internal.length_m * 3.281).toFixed(2)} ft`],
                ["Ancho", `${spec.internal.width_m.toFixed(3)} m / ${(spec.internal.width_m * 3.281).toFixed(2)} ft`],
                ["Alto",  `${spec.internal.height_m.toFixed(3)} m / ${(spec.internal.height_m * 3.281).toFixed(2)} ft`],
              ]} />
              <SpecBlock title="Dimensiones externas" rows={[
                ["Largo", `${spec.external.length_m.toFixed(3)} m`],
                ["Ancho", `${spec.external.width_m.toFixed(3)} m`],
                ["Alto",  `${spec.external.height_m.toFixed(3)} m`],
              ]} />
              {(spec.door.width_m > 0) && (
                <SpecBlock title="Dimensiones de puerta" rows={[
                  ["Ancho", `${spec.door.width_m.toFixed(3)} m`],
                  ["Alto",  `${spec.door.height_m.toFixed(3)} m`],
                ]} />
              )}
              <SpecBlock title="Pesos" rows={[
                ["Tara",         `${spec.weights.tare_kg.toLocaleString()} kg`],
                ["Carga útil",   `${spec.weights.payload_kg.toLocaleString()} kg`],
                ["Máximo bruto", `${spec.weights.max_gross_kg.toLocaleString()} kg`],
              ]} />
              <SpecBlock title="Capacidad" rows={[
                ["Volumen", `${spec.capacity.cbm.toFixed(1)} m³ / ${spec.capacity.cuft.toLocaleString()} ft³`],
                ["Pallets US 48×40", `${spec.pallets.us_48x40} unidades`],
                ["Pallets EUR 120×80", `${spec.pallets.eur_120x80} unidades`],
              ]} />
            </div>

            <div className="mt-8 pt-6 border-t border-gv-border flex flex-col sm:flex-row gap-3">
              <BrandButton href="https://gloval-shipping.example/cotizacion">
                Cotizar este contenedor
              </BrandButton>
              <BrandButton variant="secondary" href={`/herramientas/cubicaje?from=${spec.id}`}>
                Calcular cubicaje
              </BrandButton>
            </div>
          </div>
        </div>
      </section>

      {/* LATAM differentiator: road weight limits */}
      <section className="bg-white">
        <div className="max-w-7xl mx-auto px-6 py-20">
          <div className="flex items-center gap-3 mb-2">
            <Truck className="size-6 text-gv-orange" />
            <span className="text-xs font-bold tracking-[0.2em] uppercase text-gv-orange">
              Diferenciador LATAM
            </span>
          </div>
          <H2 className="!text-3xl md:!text-4xl">Restricciones de peso por país</H2>
          <p className="mt-6 text-base text-gv-muted max-w-3xl">
            El peso máximo bruto en carretera varía por país. Importante para
            FCL hacia/desde puertos LATAM con tramos terrestres extensos.
          </p>
          <div className="mt-10 grid sm:grid-cols-2 lg:grid-cols-4 gap-4">
            {LATAM_ROAD_LIMITS.map((c) => (
              <div
                key={c.country}
                className="bg-gv-bg-soft rounded-card p-6 border border-gv-border"
              >
                <div className="flex items-center gap-2 text-2xl">
                  <span aria-hidden>{c.flag}</span>
                </div>
                <div className="mt-2 text-lg font-bold text-gv-blue">{c.country}</div>
                <div className="mt-3 text-3xl font-extrabold text-gv-blue">
                  {(c.max_gross_kg / 1000).toFixed(0)}
                  <span className="text-sm font-medium text-gv-muted ml-1">ton máx</span>
                </div>
                <p className="mt-3 text-xs text-gv-muted leading-relaxed">{c.notes}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* LATAM differentiator: port compatibility */}
      <section className="bg-gv-bg-soft">
        <div className="max-w-7xl mx-auto px-6 py-20">
          <div className="flex items-center gap-3 mb-2">
            <Anchor className="size-6 text-gv-orange" />
            <span className="text-xs font-bold tracking-[0.2em] uppercase text-gv-orange">
              Compatibilidad por puerto
            </span>
          </div>
          <H2 className="!text-3xl md:!text-4xl">¿Acepta 45&apos; HC?</H2>
          <p className="mt-6 text-base text-gv-muted max-w-3xl">
            No todos los puertos LATAM aceptan contenedores 45&apos; High Cube.
            Verifica antes de cotizar.
          </p>
          <div className="mt-10 bg-white rounded-card border border-gv-border shadow-card overflow-hidden">
            <table className="w-full text-sm">
              <thead className="bg-gv-blue text-white">
                <tr>
                  <th className="text-left px-6 py-4 font-semibold">Puerto</th>
                  <th className="text-left px-6 py-4 font-semibold">País</th>
                  <th className="text-center px-6 py-4 font-semibold">Acepta 45&apos; HC</th>
                  <th className="text-left px-6 py-4 font-semibold">Notas</th>
                </tr>
              </thead>
              <tbody>
                {LATAM_PORT_COMPATIBILITY.map((p, i) => (
                  <tr
                    key={p.port}
                    className={i % 2 === 0 ? "bg-white" : "bg-gv-bg-soft/50"}
                  >
                    <td className="px-6 py-4 font-semibold text-gv-blue">{p.port}</td>
                    <td className="px-6 py-4 text-gv-muted">
                      <span className="mr-2" aria-hidden>{p.flag}</span>
                      {p.country}
                    </td>
                    <td className="px-6 py-4 text-center">
                      {p.accepts_45hc ? (
                        <span className="inline-flex items-center gap-1 px-3 py-1 rounded-pill bg-green-100 text-green-800 text-xs font-semibold">
                          <Check className="size-3" /> Sí
                        </span>
                      ) : (
                        <span className="inline-flex items-center gap-1 px-3 py-1 rounded-pill bg-orange-100 text-orange-800 text-xs font-semibold">
                          <X className="size-3" /> No
                        </span>
                      )}
                    </td>
                    <td className="px-6 py-4 text-xs text-gv-muted">{p.notes}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <p className="mt-6 text-xs text-gv-muted italic">
            Información de referencia. Verifica con tu agente Gloval para tu
            embarque específico, ya que las condiciones operativas pueden cambiar.
          </p>
        </div>
      </section>
    </div>
  );
}

function SpecBlock({ title, rows }: { title: string; rows: [string, string][] }) {
  return (
    <div>
      <h5 className="text-xs font-bold tracking-[0.15em] uppercase text-gv-blue/60 mb-3">
        {title}
      </h5>
      <dl className="space-y-2">
        {rows.map(([label, value]) => (
          <div
            key={label}
            className="flex justify-between gap-3 text-sm border-b border-gv-border/60 pb-1.5"
          >
            <dt className="text-gv-muted">{label}</dt>
            <dd className="text-gv-blue font-semibold text-right">{value}</dd>
          </div>
        ))}
      </dl>
    </div>
  );
}
