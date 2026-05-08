"use client";

import { useMemo, useState } from "react";
import {
  LOCODES,
  TYPE_LABEL,
  GLOVAL_OFFICES,
  searchLocodes,
  nearestGlovalOffice,
  isGlovalOffice,
  type Locode,
  type LocodeType,
} from "@/lib/locode";
import { BrandButton } from "@/components/brand/BrandButton";
import { H2 } from "@/components/brand/H2";
import {
  ChevronLeft,
  Search,
  Ship,
  Plane,
  Train,
  Truck,
  Warehouse,
  MapPin,
  X,
  Building2,
  Filter,
} from "lucide-react";
import Link from "next/link";

const TYPE_ICONS: Record<LocodeType, typeof Ship> = {
  sea: Ship,
  air: Plane,
  rail: Train,
  road: Truck,
  inland: Warehouse,
};

const ALL_COUNTRIES = Array.from(
  new Set(LOCODES.map((l) => l.countryName)),
).sort();

export default function LocodePage() {
  const [query, setQuery] = useState("");
  const [typeFilter, setTypeFilter] = useState<LocodeType | "all">("all");
  const [countryFilter, setCountryFilter] = useState<string>("all");
  const [selected, setSelected] = useState<Locode | null>(null);

  const filtered = useMemo(() => {
    let list = searchLocodes(query);
    if (typeFilter !== "all") list = list.filter((l) => l.type.includes(typeFilter));
    if (countryFilter !== "all") list = list.filter((l) => l.countryName === countryFilter);
    return list;
  }, [query, typeFilter, countryFilter]);

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
        <H2>Códigos UN/LOCODE</H2>
        <p className="mt-6 text-base md:text-lg text-gv-muted max-w-3xl leading-relaxed">
          Búsqueda de códigos UN/LOCODE para puertos, aeropuertos y terminales.
          Top {LOCODES.length} ubicaciones LATAM curadas por Gloval — con
          distancia a la oficina más cercana.
        </p>
      </header>

      <section className="max-w-7xl mx-auto px-6 pb-12 grid lg:grid-cols-[1fr_400px] gap-8">
        <div>
          {/* Search bar */}
          <div className="bg-white rounded-card border border-gv-border shadow-card p-6">
            <div className="relative">
              <Search className="absolute left-4 top-1/2 -translate-y-1/2 size-5 text-gv-muted" />
              <input
                type="search"
                value={query}
                onChange={(e) => setQuery(e.target.value)}
                placeholder="Buscar por código, ciudad o país (ej: GYE, Callao, Brasil)…"
                className="w-full pl-12 pr-12 py-4 rounded-pill border border-gv-border focus:outline-none focus:ring-2 focus:ring-gv-blue/30 text-gv-blue font-semibold text-base"
              />
              {query && (
                <button
                  onClick={() => setQuery("")}
                  className="absolute right-3 top-1/2 -translate-y-1/2 size-9 rounded-full hover:bg-gv-bg-soft flex items-center justify-center"
                  aria-label="Limpiar búsqueda"
                >
                  <X className="size-4 text-gv-muted" />
                </button>
              )}
            </div>

            <div className="mt-5 flex flex-wrap items-center gap-3">
              <div className="flex items-center gap-1.5 text-xs font-bold tracking-[0.15em] uppercase text-gv-muted">
                <Filter className="size-3.5" /> Filtros
              </div>
              {/* Type filter */}
              <div className="flex flex-wrap gap-1">
                <FilterChip active={typeFilter === "all"} onClick={() => setTypeFilter("all")}>
                  Todos
                </FilterChip>
                {(["sea", "air", "inland"] as LocodeType[]).map((t) => {
                  const Icon = TYPE_ICONS[t];
                  return (
                    <FilterChip
                      key={t}
                      active={typeFilter === t}
                      onClick={() => setTypeFilter(t)}
                    >
                      <Icon className="size-3.5" />
                      {TYPE_LABEL[t]}
                    </FilterChip>
                  );
                })}
              </div>
              {/* Country filter */}
              <select
                value={countryFilter}
                onChange={(e) => setCountryFilter(e.target.value)}
                className="px-4 py-1.5 rounded-pill border border-gv-border bg-white text-gv-blue text-xs font-semibold focus:outline-none focus:ring-2 focus:ring-gv-blue/30"
              >
                <option value="all">Todos los países</option>
                {ALL_COUNTRIES.map((c) => (
                  <option key={c} value={c}>{c}</option>
                ))}
              </select>
            </div>
          </div>

          {/* Result count */}
          <div className="mt-6 mb-3 flex items-baseline justify-between">
            <div className="text-sm text-gv-muted">
              <span className="font-bold text-gv-blue">{filtered.length}</span> ubicaciones
              {query && (
                <>
                  {" "}para <span className="font-bold text-gv-blue">&ldquo;{query}&rdquo;</span>
                </>
              )}
            </div>
            <a
              href="https://service.unece.org/trade/locode/"
              target="_blank"
              rel="noopener noreferrer"
              className="text-xs text-gv-blue hover:underline"
            >
              ¿Buscas fuera de LATAM? UNECE oficial →
            </a>
          </div>

          {/* Results table */}
          <div className="bg-white rounded-card border border-gv-border shadow-card overflow-hidden">
            {filtered.length === 0 ? (
              <div className="p-12 text-center">
                <MapPin className="size-12 text-gv-muted/40 mx-auto" />
                <p className="mt-4 text-gv-muted">
                  No encontramos ubicaciones que coincidan.
                </p>
                <p className="mt-1 text-xs text-gv-muted">
                  Probá con el código de país (EC, PE), ciudad (Guayaquil), o reseteá los filtros.
                </p>
              </div>
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead>
                    <tr className="bg-gv-bg-soft text-xs uppercase tracking-wider text-gv-muted">
                      <th className="text-left px-5 py-3 font-semibold">Código</th>
                      <th className="text-left px-3 py-3 font-semibold">Ciudad</th>
                      <th className="text-left px-3 py-3 font-semibold hidden sm:table-cell">País</th>
                      <th className="text-left px-3 py-3 font-semibold">Tipo</th>
                      <th className="text-right px-5 py-3 font-semibold">Gloval</th>
                    </tr>
                  </thead>
                  <tbody>
                    {filtered.map((l, i) => {
                      const isOffice = isGlovalOffice(l.code);
                      const nearest = isOffice ? null : nearestGlovalOffice(l);
                      const isSelected = selected?.code === l.code;
                      return (
                        <tr
                          key={l.code}
                          onClick={() => setSelected(l)}
                          className={`cursor-pointer transition-colors ${
                            isSelected
                              ? "bg-gv-blue/5"
                              : i % 2 === 0
                              ? "bg-white hover:bg-gv-bg-soft/60"
                              : "bg-gv-bg-soft/30 hover:bg-gv-bg-soft/60"
                          }`}
                        >
                          <td className="px-5 py-3 font-mono font-bold text-gv-blue">{l.code}</td>
                          <td className="px-3 py-3 text-gv-blue font-semibold">
                            <span className="sm:hidden mr-1.5" aria-hidden>{l.flag}</span>
                            {l.city}
                          </td>
                          <td className="px-3 py-3 text-gv-muted hidden sm:table-cell">
                            <span className="mr-2" aria-hidden>{l.flag}</span>
                            {l.countryName}
                          </td>
                          <td className="px-3 py-3">
                            <div className="flex gap-1">
                              {l.type.map((t) => {
                                const Icon = TYPE_ICONS[t];
                                return (
                                  <span
                                    key={t}
                                    className="size-7 rounded-md bg-gv-bg-soft text-gv-blue flex items-center justify-center"
                                    title={TYPE_LABEL[t]}
                                  >
                                    <Icon className="size-3.5" />
                                  </span>
                                );
                              })}
                            </div>
                          </td>
                          <td className="px-5 py-3 text-right text-xs">
                            {isOffice ? (
                              <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-pill bg-gv-orange text-white font-bold uppercase tracking-wider">
                                <Building2 className="size-3" /> Oficina
                              </span>
                            ) : (
                              <span className="text-gv-muted">
                                {nearest!.km.toLocaleString()} km de {nearest!.office.city}
                              </span>
                            )}
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        </div>

        {/* Detail sidebar */}
        <aside className="lg:sticky lg:top-6 h-fit">
          {selected ? (
            <SelectedDetail loc={selected} onClose={() => setSelected(null)} />
          ) : (
            <div className="bg-white rounded-card border border-gv-border shadow-card p-8 text-center">
              <MapPin className="size-12 text-gv-blue/30 mx-auto" />
              <h3 className="mt-4 text-lg font-bold text-gv-blue">
                Selecciona una ubicación
              </h3>
              <p className="mt-2 text-sm text-gv-muted leading-relaxed">
                Haz click en cualquier fila para ver detalles, distancia a la
                oficina Gloval más cercana, y opciones de cotización.
              </p>
              <div className="mt-6 pt-6 border-t border-gv-border">
                <div className="text-xs font-bold tracking-[0.15em] uppercase text-gv-orange mb-3">
                  Oficinas Gloval
                </div>
                <ul className="space-y-2 text-sm">
                  {GLOVAL_OFFICES.map((o) => (
                    <li key={o.code} className="flex items-center justify-between">
                      <span className="text-gv-blue font-semibold">{o.city}</span>
                      <span className="font-mono text-xs text-gv-muted">{o.code}</span>
                    </li>
                  ))}
                </ul>
              </div>
            </div>
          )}
        </aside>
      </section>

      {/* Disclaimer */}
      <section className="max-w-7xl mx-auto px-6 pb-20">
        <div className="text-xs text-gv-muted italic max-w-3xl">
          Dataset curado de las {LOCODES.length} ubicaciones más relevantes para
          comercio LATAM. Para el listado oficial completo (~110.000 entradas
          globales), consulta el portal UN/LOCODE de la UNECE.
        </div>
      </section>
    </div>
  );
}

function FilterChip({
  active,
  onClick,
  children,
}: {
  active: boolean;
  onClick: () => void;
  children: React.ReactNode;
}) {
  return (
    <button
      onClick={onClick}
      className={`inline-flex items-center gap-1.5 px-3 py-1.5 rounded-pill text-xs font-semibold transition-colors border ${
        active
          ? "bg-gv-blue text-white border-gv-blue"
          : "bg-white text-gv-blue border-gv-border hover:bg-gv-bg-soft"
      }`}
    >
      {children}
    </button>
  );
}

function SelectedDetail({ loc, onClose }: { loc: Locode; onClose: () => void }) {
  const isOffice = isGlovalOffice(loc.code);
  const nearest = isOffice ? null : nearestGlovalOffice(loc);

  return (
    <div className="bg-white rounded-card border border-gv-border shadow-card overflow-hidden">
      <div className="bg-gv-blue text-white p-6">
        <div className="flex items-start justify-between">
          <div>
            <div className="text-xs font-bold tracking-[0.2em] uppercase text-white/70">
              UN/LOCODE
            </div>
            <div className="font-mono text-3xl font-extrabold mt-1">{loc.code}</div>
          </div>
          <button
            onClick={onClose}
            className="size-9 rounded-full hover:bg-white/10 flex items-center justify-center"
            aria-label="Cerrar"
          >
            <X className="size-4" />
          </button>
        </div>
        <div className="mt-4 flex items-center gap-3">
          <span className="text-3xl" aria-hidden>{loc.flag}</span>
          <div>
            <div className="text-xl font-bold leading-none">{loc.city}</div>
            <div className="text-sm text-white/70 mt-1">{loc.countryName}</div>
          </div>
        </div>
      </div>

      <div className="p-6 space-y-5">
        <div>
          <div className="text-xs font-bold tracking-[0.15em] uppercase text-gv-blue/60 mb-2">
            Tipos de transporte
          </div>
          <div className="flex flex-wrap gap-2">
            {loc.type.map((t) => {
              const Icon = TYPE_ICONS[t];
              return (
                <span
                  key={t}
                  className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-pill bg-gv-bg-soft text-gv-blue text-xs font-semibold"
                >
                  <Icon className="size-3.5" />
                  {TYPE_LABEL[t]}
                </span>
              );
            })}
          </div>
        </div>

        <div>
          <div className="text-xs font-bold tracking-[0.15em] uppercase text-gv-blue/60 mb-2">
            Coordenadas
          </div>
          <div className="font-mono text-sm text-gv-blue">
            {loc.lat.toFixed(4)}°, {loc.lon.toFixed(4)}°
          </div>
        </div>

        {isOffice ? (
          <div className="p-4 rounded-xl bg-gv-orange/10 border border-gv-orange/30">
            <div className="flex items-center gap-2 text-xs font-bold tracking-[0.15em] uppercase text-gv-orange">
              <Building2 className="size-4" /> Oficina Gloval
            </div>
            <p className="mt-2 text-sm text-gv-blue leading-relaxed">
              Esta es una de nuestras oficinas con red propia. Atención
              directa, sin red de agentes intermediarios.
            </p>
          </div>
        ) : (
          <div>
            <div className="text-xs font-bold tracking-[0.15em] uppercase text-gv-blue/60 mb-2">
              Oficina Gloval más cercana
            </div>
            <div className="p-4 rounded-xl bg-gv-bg-soft border border-gv-border">
              <div className="flex items-center justify-between">
                <div>
                  <div className="font-bold text-gv-blue">{nearest!.office.city}</div>
                  <div className="text-xs text-gv-muted mt-0.5 font-mono">
                    {nearest!.office.code}
                  </div>
                </div>
                <div className="text-right">
                  <div className="text-3xl font-extrabold text-gv-orange leading-none">
                    {nearest!.km.toLocaleString()}
                  </div>
                  <div className="text-xs text-gv-muted mt-1">km</div>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>

      <div className="p-6 pt-0 space-y-2">
        <BrandButton
          href={`https://gloval-shipping.example/cotizacion?from=${loc.code}`}
          className="w-full"
        >
          Cotizar desde {loc.city}
        </BrandButton>
        <BrandButton
          variant="secondary"
          href={`https://gloval-shipping.example/cotizacion?to=${loc.code}`}
          className="w-full"
        >
          Cotizar hacia {loc.city}
        </BrandButton>
      </div>
    </div>
  );
}
