"use client";

import { useState } from "react";
import {
  lookupTracking,
  detectCarrier,
  listDemoNumbers,
  STATUS_LABEL,
  EVENT_LABEL,
  type Tracking,
  type EventType,
} from "@/lib/tracking";
import { TrackingMap } from "@/components/tools/TrackingMap";
import { BrandButton } from "@/components/brand/BrandButton";
import { H2 } from "@/components/brand/H2";
import {
  ChevronLeft,
  Search,
  Ship,
  FileText,
  Anchor,
  AlertTriangle,
  Loader2,
  Check,
  Building2,
  Calendar,
  MapPin,
} from "lucide-react";
import Link from "next/link";

type SearchType = "container" | "bl" | "vessel";

const TABS: { id: SearchType; label: string; placeholder: string; example: string }[] = [
  { id: "container", label: "Contenedor", placeholder: "ABCD1234567",     example: "ej: MAEU1234567" },
  { id: "bl",        label: "Bill of Lading", placeholder: "Número de BL", example: "ej: MAEU987654321" },
  { id: "vessel",    label: "Buque",     placeholder: "Nombre o IMO del buque", example: "ej: MAERSK SEMARANG" },
];

const EVENT_ICONS: Record<EventType, typeof Ship> = {
  gate_in:      Building2,
  loaded:       Anchor,
  departed:     Ship,
  arrived:      MapPin,
  discharged:   Anchor,
  gate_out:     Building2,
  delivered:    Check,
  transhipment: Ship,
};

export default function RastreoPage() {
  const [tab, setTab] = useState<SearchType>("container");
  const [query, setQuery] = useState("");
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<Tracking | null>(null);
  const [notFound, setNotFound] = useState<string | null>(null);

  const detectedCarrier =
    tab === "container" && query.length >= 4 ? detectCarrier(query) : null;

  async function handleSearch(input?: string | React.FormEvent) {
    let q = query;
    if (typeof input === "string") {
      q = input;
      setQuery(input);
    } else if (input && "preventDefault" in input) {
      input.preventDefault();
    }
    if (!q.trim()) return;
    setLoading(true);
    setNotFound(null);
    setResult(null);
    const r = await lookupTracking(q);
    setLoading(false);
    if (r) setResult(r);
    else setNotFound(q.trim().toUpperCase());
  }

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
        <div className="flex items-center gap-3 mb-2">
          <span className="inline-flex items-center px-3 py-1 rounded-pill bg-gv-orange text-white text-xs font-bold tracking-[0.15em] uppercase">
            Demo
          </span>
          <span className="text-xs font-bold tracking-[0.15em] uppercase text-gv-muted">
            Datos simulados
          </span>
        </div>
        <H2>Rastreo de Contenedores</H2>
        <p className="mt-6 text-base md:text-lg text-gv-muted max-w-3xl leading-relaxed">
          Rastrea contenedores, Bills of Lading y buques con eventos en tiempo
          real, ETA y visualización de la ruta.
        </p>
      </header>

      {/* Search */}
      <section className="max-w-7xl mx-auto px-6 pb-12">
        <div className="bg-white rounded-card border border-gv-border shadow-card p-6 md:p-8">
          {/* Tabs */}
          <div className="flex gap-1 mb-6 border-b border-gv-border">
            {TABS.map((t) => {
              const active = tab === t.id;
              return (
                <button
                  key={t.id}
                  onClick={() => {
                    setTab(t.id);
                    setQuery("");
                    setResult(null);
                    setNotFound(null);
                  }}
                  className={`px-5 py-3 text-sm font-bold border-b-2 -mb-px transition-colors ${
                    active
                      ? "text-gv-blue border-gv-orange"
                      : "text-gv-muted border-transparent hover:text-gv-blue"
                  }`}
                >
                  {t.label}
                </button>
              );
            })}
          </div>

          <form onSubmit={handleSearch}>
            <div className="flex flex-col md:flex-row gap-3">
              <div className="relative flex-1">
                <Search className="absolute left-4 top-1/2 -translate-y-1/2 size-5 text-gv-muted" />
                <input
                  type="text"
                  value={query}
                  onChange={(e) => setQuery(e.target.value.toUpperCase())}
                  placeholder={TABS.find((t) => t.id === tab)!.placeholder}
                  className="w-full pl-12 pr-4 py-4 rounded-pill border border-gv-border focus:outline-none focus:ring-2 focus:ring-gv-blue/30 text-gv-blue font-semibold text-base font-mono"
                  disabled={loading}
                />
              </div>
              <BrandButton type="submit" className="shrink-0 !px-8" disabled={loading}>
                {loading ? (
                  <>
                    <Loader2 className="size-4 animate-spin" /> Rastreando…
                  </>
                ) : (
                  <>
                    <Search className="size-4" /> Rastrear
                  </>
                )}
              </BrandButton>
            </div>

            {/* Hint row */}
            <div className="mt-4 flex flex-wrap items-center gap-x-6 gap-y-1 text-xs text-gv-muted">
              <span>{TABS.find((t) => t.id === tab)!.example}</span>
              {detectedCarrier && (
                <span className="text-gv-blue font-semibold">
                  Naviera detectada: {detectedCarrier}
                </span>
              )}
            </div>
          </form>

          {/* Demo numbers */}
          {!result && !loading && (
            <div className="mt-6 pt-6 border-t border-gv-border">
              <div className="text-xs font-bold tracking-[0.15em] uppercase text-gv-muted mb-3">
                Probá con estos números demo
              </div>
              <div className="flex flex-wrap gap-2">
                {listDemoNumbers().map((d) => (
                  <button
                    key={d.number}
                    onClick={() => handleSearch(d.number)}
                    className="inline-flex items-center gap-2 px-3 py-1.5 rounded-pill bg-gv-bg-soft border border-gv-border hover:border-gv-blue text-xs font-semibold text-gv-blue font-mono"
                  >
                    {d.number}
                    <span
                      className="size-2 rounded-full"
                      style={{ background: STATUS_LABEL[d.status].color }}
                    />
                  </button>
                ))}
              </div>
            </div>
          )}
        </div>

        {/* Demo banner */}
        <div className="mt-6 bg-gv-orange/10 border border-gv-orange/30 rounded-card p-5">
          <div className="flex items-start gap-3">
            <AlertTriangle className="size-5 text-gv-orange shrink-0 mt-0.5" />
            <div className="text-sm text-gv-blue leading-relaxed">
              <strong className="font-bold">Versión demo.</strong> Esta herramienta usa datos simulados para mostrar la experiencia. La versión productiva consume API de tracking real (searates.com / shipsgo.com / similar) cubriendo Maersk, MSC, CMA-CGM, Evergreen, Hapag-Lloyd, ONE, COSCO, HMM, ZIM y otras navieras principales.
            </div>
          </div>
        </div>

        {/* Not found */}
        {notFound && !loading && (
          <div className="mt-6 bg-white border border-red-200 rounded-card p-8 text-center">
            <div className="size-12 mx-auto rounded-full bg-red-100 flex items-center justify-center">
              <Search className="size-5 text-red-600" />
            </div>
            <h3 className="mt-4 text-lg font-bold text-gv-blue">
              No encontramos &ldquo;{notFound}&rdquo;
            </h3>
            <p className="mt-2 text-sm text-gv-muted max-w-md mx-auto">
              En la versión demo solo respondemos los números de la lista de
              ejemplos. En producción la API consulta directo a la naviera.
            </p>
          </div>
        )}

        {/* Result */}
        {result && !loading && <TrackingResult data={result} />}
      </section>
    </div>
  );
}

function TrackingResult({ data }: { data: Tracking }) {
  const status = STATUS_LABEL[data.status];
  return (
    <div className="mt-6 space-y-6">
      {/* Gloval premium banner */}
      {data.isGlovalShipment && (
        <div className="bg-gv-blue text-white rounded-card p-6 flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <Building2 className="size-8 text-gv-orange shrink-0" />
            <div>
              <div className="text-xs font-bold tracking-[0.2em] uppercase text-gv-orange">
                Envío Gloval Shipping
              </div>
              <div className="text-lg font-bold mt-1">
                Este BL pertenece a una operación nuestra
              </div>
            </div>
          </div>
          <BrandButton
            href="https://gloval-shipping.example/portal"
            className="!bg-gv-orange !border-gv-orange hover:!bg-gv-orange-dark shrink-0"
          >
            Abrir en portal del cliente
          </BrandButton>
        </div>
      )}

      {/* Header card */}
      <div className="bg-white rounded-card border border-gv-border shadow-card p-6 md:p-8">
        <div className="flex flex-col md:flex-row md:items-start gap-6 md:gap-10">
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-2 text-xs font-bold tracking-[0.15em] uppercase text-gv-muted">
              {data.type === "container" ? "Contenedor" : data.type === "bl" ? "Bill of Lading" : "Buque"}
            </div>
            <div className="font-mono text-3xl md:text-4xl font-extrabold text-gv-blue mt-1">
              {data.number}
            </div>
            <div className="mt-3 flex flex-wrap gap-x-6 gap-y-1 text-sm">
              <div>
                <span className="text-gv-muted">Naviera:</span>{" "}
                <span className="font-bold text-gv-blue">{data.carrier}</span>
              </div>
              <div>
                <span className="text-gv-muted">Buque:</span>{" "}
                <span className="font-bold text-gv-blue">{data.vessel}</span> · {data.voyage}
              </div>
              <div>
                <span className="text-gv-muted">Tipo:</span>{" "}
                <span className="font-bold text-gv-blue">{data.containerType}</span>
              </div>
            </div>
          </div>

          <div className="flex flex-col items-start md:items-end shrink-0">
            <span
              className="inline-flex items-center gap-2 px-4 py-2 rounded-pill text-xs font-bold uppercase tracking-wider text-white"
              style={{ background: status.color }}
            >
              <span className="size-2 rounded-full bg-white animate-pulse" />
              {status.label}
            </span>
            <div className="mt-3 text-right">
              <div className="text-xs text-gv-muted uppercase tracking-wider font-bold">ETA</div>
              <div className="text-lg font-bold text-gv-blue mt-1">
                {new Date(data.eta).toLocaleDateString("es", { day: "numeric", month: "short", year: "numeric" })}
              </div>
            </div>
          </div>
        </div>

        {/* Origin -> Destination */}
        <div className="mt-8 grid grid-cols-1 md:grid-cols-[1fr_auto_1fr] gap-4 md:gap-6 items-center">
          <PortBlock label="Origen" port={data.origin.port} locode={data.origin.locode} />
          <Ship className="size-7 text-gv-orange justify-self-center hidden md:block" strokeWidth={1.5} />
          <PortBlock label="Destino" port={data.destination.port} locode={data.destination.locode} alignRight />
        </div>
      </div>

      {/* Map + timeline */}
      <div className="grid lg:grid-cols-[1.4fr_1fr] gap-6">
        <div className="bg-white rounded-card border border-gv-border shadow-card p-6 md:p-8">
          <h3 className="text-sm font-bold tracking-[0.2em] uppercase text-gv-orange mb-4">
            Ruta del envío
          </h3>
          <TrackingMap data={data} />
        </div>

        <div className="bg-white rounded-card border border-gv-border shadow-card p-6 md:p-8">
          <h3 className="text-sm font-bold tracking-[0.2em] uppercase text-gv-orange mb-6">
            Eventos
          </h3>
          <ol className="relative">
            <span className="absolute left-3.5 top-2 bottom-2 w-px bg-gv-border" aria-hidden />
            {data.events.slice().reverse().map((e, i) => {
              const Icon = EVENT_ICONS[e.type];
              const isLatest = i === 0;
              return (
                <li key={`${e.date}-${e.type}`} className="relative pl-12 pb-6 last:pb-0">
                  <span
                    className={`absolute left-0 top-0 size-7 rounded-full flex items-center justify-center ${
                      isLatest ? "bg-gv-orange text-white" : "bg-gv-bg-soft text-gv-blue border border-gv-border"
                    }`}
                  >
                    <Icon className="size-3.5" />
                  </span>
                  <div className="text-xs font-bold tracking-[0.15em] uppercase text-gv-orange/80">
                    {EVENT_LABEL[e.type]}
                  </div>
                  <div className="text-sm font-bold text-gv-blue mt-0.5">
                    {e.description}
                  </div>
                  <div className="text-xs text-gv-muted mt-1 flex items-center gap-1.5">
                    <Calendar className="size-3" />
                    {new Date(e.date).toLocaleString("es", {
                      day: "numeric",
                      month: "short",
                      year: "numeric",
                      hour: "2-digit",
                      minute: "2-digit",
                    })}
                  </div>
                  <div className="text-xs text-gv-blue mt-1 flex items-center gap-1.5">
                    <MapPin className="size-3 text-gv-muted" />
                    {e.location}
                    {e.locode && <span className="font-mono text-gv-muted">({e.locode})</span>}
                  </div>
                  {e.vessel && (
                    <div className="text-xs text-gv-muted mt-0.5 flex items-center gap-1.5">
                      <Ship className="size-3" />
                      {e.vessel} · {e.voyage}
                    </div>
                  )}
                </li>
              );
            })}
          </ol>
        </div>
      </div>

      {/* CTA */}
      <div className="bg-white rounded-card border border-gv-border shadow-card p-6 md:p-8 flex flex-col sm:flex-row items-start sm:items-center gap-4 justify-between">
        <div>
          <div className="text-xs font-bold tracking-[0.15em] uppercase text-gv-orange">
            ¿Tu próximo embarque?
          </div>
          <h4 className="text-lg font-bold text-gv-blue mt-1">
            Cotiza con Gloval y rastrea desde tu portal de cliente.
          </h4>
        </div>
        <div className="flex gap-3">
          <BrandButton href="https://gloval-shipping.example/cotizacion">
            Solicitar Cotización
          </BrandButton>
        </div>
      </div>

      {/* Disclaimer */}
      <p className="text-xs text-gv-muted italic">
        En producción, los datos provienen de las navieras vía API. Pueden tener un retraso de 4–24 horas. Para datos en tiempo real consulta con tu agente Gloval.
      </p>
    </div>
  );
}

function PortBlock({
  label,
  port,
  locode,
  alignRight,
}: {
  label: string;
  port: string;
  locode: string;
  alignRight?: boolean;
}) {
  return (
    <div className={`p-5 rounded-xl bg-gv-bg-soft ${alignRight ? "md:text-right" : ""}`}>
      <div className="text-xs font-bold tracking-[0.15em] uppercase text-gv-muted">
        {label}
      </div>
      <div className="text-xl font-bold text-gv-blue mt-1.5">{port}</div>
      <div className="text-xs font-mono text-gv-muted mt-1">{locode}</div>
    </div>
  );
}
