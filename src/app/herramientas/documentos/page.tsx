"use client";

import { useMemo, useState } from "react";
import {
  DOCUMENTS,
  CATEGORY_LABEL,
  CATEGORY_DESC,
  FORMAT_COLOR,
  LANGUAGE_LABEL,
  searchDocuments,
  type DocCategory,
  type DocResource,
} from "@/lib/documents";
import { BrandButton } from "@/components/brand/BrandButton";
import { H2 } from "@/components/brand/H2";
import {
  ChevronLeft,
  Search,
  Download,
  X,
  FileText,
  Briefcase,
  ShieldCheck,
  Phone,
  ClipboardList,
  Languages,
  AlertTriangle,
} from "lucide-react";
import Link from "next/link";

const CATEGORY_ICONS: Record<DocCategory, typeof FileText> = {
  operaciones: ClipboardList,
  aduanas: ShieldCheck,
  comercial: Briefcase,
  contactos: Phone,
};

const TABS: { id: "all" | DocCategory; label: string }[] = [
  { id: "all", label: "Todos" },
  { id: "operaciones", label: "Operaciones" },
  { id: "aduanas", label: "Aduanas" },
  { id: "comercial", label: "Comercial" },
  { id: "contactos", label: "Contactos" },
];

export default function DocumentosPage() {
  const [query, setQuery] = useState("");
  const [category, setCategory] = useState<"all" | DocCategory>("all");

  const filtered = useMemo(
    () => searchDocuments(query, category),
    [query, category],
  );

  const counts = useMemo(() => {
    const c: Record<string, number> = { all: DOCUMENTS.length };
    DOCUMENTS.forEach((d) => {
      c[d.category] = (c[d.category] || 0) + 1;
    });
    return c;
  }, []);

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
        <H2>Centro de Documentos</H2>
        <p className="mt-6 text-base md:text-lg text-gv-muted max-w-3xl leading-relaxed">
          Plantillas, formularios y contactos para tus operaciones con Gloval Shipping.
          POA, SLI, Shipping Instructions, contactos por oficina y más — todo en un solo lugar.
        </p>
      </header>

      <section className="max-w-7xl mx-auto px-6 pb-12">
        {/* Search + tabs */}
        <div className="bg-white rounded-card border border-gv-border shadow-card p-6 mb-8">
          <div className="relative mb-5">
            <Search className="absolute left-4 top-1/2 -translate-y-1/2 size-5 text-gv-muted" />
            <input
              type="search"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="Buscar por título o descripción…"
              className="w-full pl-12 pr-12 py-3.5 rounded-pill border border-gv-border focus:outline-none focus:ring-2 focus:ring-gv-blue/30 text-gv-blue font-semibold"
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

          <div className="flex flex-wrap gap-2">
            {TABS.map((t) => {
              const active = category === t.id;
              return (
                <button
                  key={t.id}
                  onClick={() => setCategory(t.id)}
                  className={`inline-flex items-center gap-2 px-4 py-2 rounded-pill text-sm font-bold transition-colors border ${
                    active
                      ? "bg-gv-blue text-white border-gv-blue"
                      : "bg-white text-gv-blue border-gv-border hover:bg-gv-bg-soft"
                  }`}
                >
                  {t.label}
                  <span
                    className={`text-[10px] px-1.5 py-0.5 rounded-full ${
                      active ? "bg-white/20 text-white" : "bg-gv-bg-soft text-gv-muted"
                    }`}
                  >
                    {counts[t.id]}
                  </span>
                </button>
              );
            })}
          </div>
        </div>

        {/* Category description (when a single category is selected) */}
        {category !== "all" && (
          <div className="mb-6 flex items-start gap-3">
            <CategoryIcon cat={category} />
            <div>
              <h3 className="text-xl font-bold text-gv-blue">
                {CATEGORY_LABEL[category]}
              </h3>
              <p className="text-sm text-gv-muted mt-1">{CATEGORY_DESC[category]}</p>
            </div>
          </div>
        )}

        {/* Documents grid */}
        {filtered.length === 0 ? (
          <div className="bg-white rounded-card border border-gv-border shadow-card p-12 text-center">
            <FileText className="size-12 text-gv-muted/40 mx-auto" />
            <p className="mt-4 text-gv-muted">
              No encontramos documentos que coincidan con tu búsqueda.
            </p>
          </div>
        ) : (
          <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-5">
            {filtered.map((doc) => (
              <DocCard key={doc.id} doc={doc} />
            ))}
          </div>
        )}

        {/* Help footer */}
        <div className="mt-12 bg-gv-blue text-white rounded-card p-8 md:p-10">
          <div className="flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
            <div>
              <h3 className="text-2xl md:text-3xl font-bold">¿Necesitas otro documento?</h3>
              <p className="mt-3 text-white/80 max-w-2xl leading-relaxed">
                Si lo que buscas no está acá, escríbenos. Nuestro equipo en Miami,
                Panamá, Guayaquil y Lima te lo envía personalizado para tu operación.
              </p>
            </div>
            <BrandButton
              href="https://gloval-shipping.example/contacto"
              className="!bg-gv-orange !border-gv-orange hover:!bg-gv-orange-dark shrink-0"
            >
              Solicitar documento
            </BrandButton>
          </div>
        </div>
      </section>
    </div>
  );
}

function DocCard({ doc }: { doc: DocResource }) {
  const fmt = FORMAT_COLOR[doc.format];
  const Icon = CATEGORY_ICONS[doc.category];

  return (
    <div className="group bg-white rounded-card border border-gv-border shadow-card p-6 flex flex-col hover:shadow-card-hover hover:-translate-y-0.5 transition-all">
      <div className="flex items-start justify-between gap-3 mb-4">
        <div className="size-12 rounded-xl bg-gv-bg-soft flex items-center justify-center shrink-0">
          <Icon className="size-6 text-gv-blue" strokeWidth={2} />
        </div>
        <span
          className="px-2.5 py-1 rounded-md text-[10px] font-bold tracking-wider"
          style={{ background: fmt.bg, color: fmt.fg }}
        >
          {doc.format}
        </span>
      </div>

      <h3 className="text-lg font-bold text-gv-blue leading-tight">{doc.title}</h3>
      <p className="mt-2 text-sm text-gv-muted leading-relaxed flex-1">
        {doc.description}
      </p>

      <div className="mt-5 flex items-center justify-between gap-3 text-xs">
        <span className="inline-flex items-center gap-1.5 text-gv-muted">
          <Languages className="size-3.5" /> {LANGUAGE_LABEL[doc.language]}
        </span>
        {doc.sizeKb && (
          <span className="text-gv-muted">{(doc.sizeKb / 1024).toFixed(1)} MB</span>
        )}
      </div>

      <div className="mt-5">
        {doc.placeholder ? (
          <button
            disabled
            className="w-full inline-flex items-center justify-center gap-2 px-5 py-3 rounded-pill bg-gv-bg-soft text-gv-muted text-sm font-bold border border-gv-border cursor-not-allowed"
            title="Documento aún no disponible"
          >
            <AlertTriangle className="size-4 text-gv-orange" />
            Próximamente
          </button>
        ) : (
          <a
            href={`/documentos/${doc.filename}`}
            download
            className="w-full inline-flex items-center justify-center gap-2 px-5 py-3 rounded-pill bg-gv-blue text-white hover:bg-gv-blue-dark text-sm font-bold transition-colors"
          >
            <Download className="size-4" />
            Descargar
          </a>
        )}
      </div>
    </div>
  );
}

function CategoryIcon({ cat }: { cat: DocCategory }) {
  const Icon = CATEGORY_ICONS[cat];
  return (
    <div className="size-12 rounded-xl bg-gv-orange/10 flex items-center justify-center shrink-0">
      <Icon className="size-6 text-gv-orange" />
    </div>
  );
}
