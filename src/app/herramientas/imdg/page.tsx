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
  { id: "classes", label: "Las 9 clases" },
  { id: "matrix", label: "Matriz de segregación" },
  { id: "latam", label: "Restricciones LATAM" },
] as const;

type ViewId = (typeof VIEWS)[number]["id"];

export default function ImdgPage() {
  const [view, setView] = useState<ViewId>("classes");
  const [hoveredCell, setHoveredCell] = useState<{ row: string; col: string; code: SegCode } | null>(null);

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
        <div className="flex items-start gap-4">
          <TriangleAlert className="size-10 text-gv-orange shrink-0 mt-1" />
          <div>
            <H2>Tabla IMO / IMDG</H2>
            <p className="mt-6 text-base md:text-lg text-gv-muted max-w-3xl leading-relaxed">
              Las 9 clases de mercancías peligrosas según el Código IMDG, su
              matriz de segregación a bordo y las restricciones específicas en
              puertos LATAM.
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
            {IMDG_CLASSES.map((cls) => (
              <div
                key={cls.code}
                className="bg-white rounded-card border border-gv-border shadow-card p-6 flex gap-5 hover:shadow-card-hover hover:-translate-y-0.5 transition-all"
              >
                <div className="shrink-0">
                  <ImdgDiamond cls={cls} size={88} />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="text-xs font-bold tracking-[0.15em] uppercase text-gv-orange">
                    Clase {cls.code}
                  </div>
                  <h3 className="text-lg font-bold text-gv-blue mt-1 leading-tight">
                    {cls.title}
                  </h3>
                  <p className="text-sm text-gv-muted mt-2 leading-relaxed">
                    {cls.description}
                  </p>
                  <div className="mt-3 pt-3 border-t border-gv-border/60">
                    <div className="text-[10px] font-bold tracking-[0.15em] uppercase text-gv-blue/60 mb-1">
                      Ejemplos
                    </div>
                    <p className="text-xs text-gv-muted leading-relaxed">
                      {cls.examples}
                    </p>
                  </div>
                </div>
              </div>
            ))}
          </div>

          <div className="mt-10 p-6 rounded-card bg-white border border-gv-orange/30">
            <div className="flex items-start gap-3">
              <AlertTriangle className="size-5 text-gv-orange shrink-0 mt-0.5" />
              <div className="text-sm text-gv-blue leading-relaxed">
                <strong className="font-bold">Aviso:</strong> los rombos visualizados son una representación referencial con los colores oficiales de cada clase. Para etiquetado real de embalajes y contenedores se debe usar el simbolismo pictográfico oficial del Código IMDG.
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
              Matriz de segregación IMDG (Cap. 7.2)
            </h3>
            <p className="text-sm text-gv-muted mb-6 max-w-3xl leading-relaxed">
              Cruza dos clases para ver el código de segregación requerido
              durante estiba y transporte. Hover sobre una celda para ver el
              detalle.
            </p>

            {/* Legend */}
            <div className="flex flex-wrap gap-2 mb-6">
              {Object.entries(SEG_LEGEND).map(([code, info]) => (
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
                  <span className="text-gv-blue font-semibold">{code === "-" ? "Sin restricción" : code === "X" ? "Prohibido" : `Tipo ${code}`}</span>
                </div>
              ))}
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
                              title={`${row} con ${col}: ${info.description}`}
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
                      Clase {hoveredCell.row}
                    </span>
                    <X className="size-3 text-gv-muted" />
                    <span className="px-3 py-1 rounded-pill bg-gv-blue text-white text-xs font-bold">
                      Clase {hoveredCell.col}
                    </span>
                  </div>
                  <div className="text-sm text-gv-blue font-semibold">
                    Código {SEG_LEGEND[hoveredCell.code].short}
                  </div>
                  <div className="text-sm text-gv-muted mt-1 leading-relaxed">
                    {SEG_LEGEND[hoveredCell.code].description}
                  </div>
                </div>
              ) : (
                <p className="text-sm text-gv-muted italic">
                  Pasa el cursor sobre una celda para ver el detalle de la segregación entre dos clases.
                </p>
              )}
            </div>
          </div>

          <div className="p-6 rounded-card bg-white border border-gv-orange/30">
            <div className="flex items-start gap-3">
              <ShieldAlert className="size-5 text-gv-orange shrink-0 mt-0.5" />
              <div className="text-sm text-gv-blue leading-relaxed">
                <strong className="font-bold">Importante:</strong> esta matriz es una versión simplificada a nivel de clase principal. La tabla oficial IMDG tiene reglas adicionales por sub-clase y excepciones por número UN. Para shipping real, consultar el código IMDG vigente o un consultor certificado.
              </div>
            </div>
          </div>
        </section>
      )}

      {/* LATAM view */}
      {view === "latam" && (
        <section className="max-w-7xl mx-auto px-6 pb-16">
          <div className="grid md:grid-cols-2 gap-6">
            {LATAM_IMDG_RESTRICTIONS.map((c) => (
              <div
                key={c.country}
                className="bg-white rounded-card border border-gv-border shadow-card p-7"
              >
                <div className="flex items-center gap-3 mb-1">
                  <span className="text-3xl" aria-hidden>{c.flag}</span>
                  <h3 className="text-2xl font-bold text-gv-blue">{c.country}</h3>
                </div>
                <div className="text-xs font-semibold tracking-wider uppercase text-gv-orange mb-5">
                  {c.authority}
                </div>
                <ul className="space-y-3">
                  {c.bullets.map((b, i) => (
                    <li key={i} className="flex gap-3 text-sm leading-relaxed">
                      <span className="size-5 rounded-full bg-gv-orange text-white text-[10px] font-bold inline-flex items-center justify-center shrink-0 mt-0.5">
                        {i + 1}
                      </span>
                      <span className="text-gv-blue">{b}</span>
                    </li>
                  ))}
                </ul>
              </div>
            ))}
          </div>

          <div className="mt-10 bg-gv-blue text-white rounded-card p-8 md:p-10">
            <h3 className="text-2xl md:text-3xl font-bold mb-4">
              ¿Necesitas mover mercancía peligrosa?
            </h3>
            <p className="text-white/80 max-w-2xl leading-relaxed">
              Gloval Shipping cuenta con consultores IMDG certificados en Miami, Panamá, Ecuador y Perú. Te ayudamos con la declaración oficial, segregación, documentación y permisos por país.
            </p>
            <div className="mt-6 flex flex-col sm:flex-row gap-3">
              <BrandButton
                href="https://gloval-shipping.example/cotizacion"
                className="!bg-gv-orange !border-gv-orange hover:!bg-gv-orange-dark"
              >
                Cotizar transporte de peligrosos
              </BrandButton>
              <BrandButton
                variant="secondary"
                href="https://gloval-shipping.example/contacto"
                className="!bg-transparent !text-white !border-white hover:!bg-white/10"
              >
                Hablar con un consultor IMDG
              </BrandButton>
            </div>
          </div>
        </section>
      )}

      {/* Final disclaimer */}
      <section className="max-w-7xl mx-auto px-6 pb-20">
        <div className="text-xs text-gv-muted italic max-w-3xl">
          Esta herramienta es informativa y educativa. La declaración oficial de mercancías peligrosas en cualquier modalidad (marítimo IMDG, aéreo IATA-DGR, terrestre ADR) debe ser realizada por un consultor certificado vigente y conforme a la normativa del país de origen y destino.
        </div>
      </section>
    </div>
  );
}
