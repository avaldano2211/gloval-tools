"use client";

import { useMemo, useState } from "react";
import {
  GLOSSARY,
  CATEGORY_LABEL,
  ALL_LETTERS,
  searchGlossary,
  groupByLetter,
  termSlug,
  type GlossaryCategory,
  type GlossaryTerm,
} from "@/lib/glosario";
import { BrandButton } from "@/components/brand/BrandButton";
import { H2 } from "@/components/brand/H2";
import {
  ChevronLeft,
  Search,
  X,
  BookOpen,
  Hash,
  Link2,
  MapPin,
} from "lucide-react";
import Link from "next/link";

const CATEGORIES: { id: "all" | GlossaryCategory; label: string }[] = [
  { id: "all", label: "Todas" },
  { id: "documentos", label: CATEGORY_LABEL.documentos },
  { id: "contenedores", label: CATEGORY_LABEL.contenedores },
  { id: "transporte", label: CATEGORY_LABEL.transporte },
  { id: "aduanas", label: CATEGORY_LABEL.aduanas },
  { id: "tarifas", label: CATEGORY_LABEL.tarifas },
  { id: "operaciones", label: CATEGORY_LABEL.operaciones },
  { id: "latam", label: CATEGORY_LABEL.latam },
];

const CATEGORY_COLORS: Record<GlossaryCategory, string> = {
  documentos:   "bg-blue-100 text-blue-800",
  contenedores: "bg-purple-100 text-purple-800",
  transporte:   "bg-cyan-100 text-cyan-800",
  aduanas:      "bg-amber-100 text-amber-800",
  tarifas:      "bg-emerald-100 text-emerald-800",
  operaciones:  "bg-pink-100 text-pink-800",
  latam:        "bg-orange-100 text-orange-800",
  general:      "bg-gray-100 text-gray-800",
};

export default function GlosarioPage() {
  const [query, setQuery] = useState("");
  const [category, setCategory] = useState<"all" | GlossaryCategory>("all");

  const filtered = useMemo(
    () => searchGlossary(query, category),
    [query, category],
  );
  const grouped = useMemo(() => groupByLetter(filtered), [filtered]);
  const presentLetters = new Set(grouped.keys());

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
          <BookOpen className="size-10 text-gv-orange shrink-0 mt-1" />
          <div>
            <H2>Glosario de Logística</H2>
            <p className="mt-6 text-base md:text-lg text-gv-muted max-w-3xl leading-relaxed">
              Diccionario de términos, siglas y conceptos del comercio internacional con foco LATAM.
              {" "}
              <span className="font-bold text-gv-blue">{GLOSSARY.length} entradas</span> y creciendo.
            </p>
          </div>
        </div>
      </header>

      {/* Search + filters sticky */}
      <section className="sticky top-0 z-20 bg-gv-bg-soft pb-6 border-b border-gv-border/50 -mb-px">
        <div className="max-w-7xl mx-auto px-6">
          <div className="bg-white rounded-card border border-gv-border shadow-card p-5">
            <div className="relative mb-4">
              <Search className="absolute left-4 top-1/2 -translate-y-1/2 size-5 text-gv-muted" />
              <input
                type="search"
                value={query}
                onChange={(e) => setQuery(e.target.value)}
                placeholder="Buscar por término, sigla o concepto…"
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
              {CATEGORIES.map((c) => {
                const active = category === c.id;
                return (
                  <button
                    key={c.id}
                    onClick={() => setCategory(c.id)}
                    className={`px-3.5 py-1.5 rounded-pill text-xs font-bold transition-colors border ${
                      active
                        ? "bg-gv-blue text-white border-gv-blue"
                        : "bg-white text-gv-blue border-gv-border hover:bg-gv-bg-soft"
                    }`}
                  >
                    {c.label}
                  </button>
                );
              })}
            </div>
          </div>

          {/* A-Z bar */}
          <div className="mt-4 bg-white rounded-pill border border-gv-border shadow-sm flex flex-wrap items-center justify-center gap-0.5 p-2 overflow-x-auto">
            {ALL_LETTERS.map((L) => {
              const has = presentLetters.has(L);
              return (
                <a
                  key={L}
                  href={has ? `#letter-${L}` : undefined}
                  onClick={(e) => {
                    if (!has) {
                      e.preventDefault();
                      return;
                    }
                  }}
                  className={`size-8 rounded-full text-xs font-bold inline-flex items-center justify-center transition-colors ${
                    has
                      ? "text-gv-blue hover:bg-gv-blue hover:text-white cursor-pointer"
                      : "text-gv-muted/40 cursor-default"
                  }`}
                  aria-disabled={!has}
                >
                  {L}
                </a>
              );
            })}
          </div>

          <div className="mt-3 text-center text-xs text-gv-muted">
            {filtered.length} resultado{filtered.length !== 1 ? "s" : ""}
            {query && (
              <>
                {" "}para <span className="font-bold text-gv-blue">&ldquo;{query}&rdquo;</span>
              </>
            )}
          </div>
        </div>
      </section>

      {/* Glossary list */}
      <section className="max-w-7xl mx-auto px-6 py-12">
        {filtered.length === 0 ? (
          <div className="bg-white rounded-card border border-gv-border shadow-card p-12 text-center">
            <Search className="size-12 text-gv-muted/40 mx-auto" />
            <p className="mt-4 text-gv-muted">
              Sin coincidencias para tu búsqueda. Probá con menos letras o cambiá la categoría.
            </p>
          </div>
        ) : (
          [...grouped.entries()].map(([letter, terms]) => (
            <div key={letter} id={`letter-${letter}`} className="mb-12 scroll-mt-44">
              <div className="flex items-center gap-4 mb-6">
                <div className="size-14 rounded-2xl bg-gv-blue text-white text-3xl font-extrabold flex items-center justify-center">
                  {letter}
                </div>
                <div className="flex-1 h-px bg-gv-border" />
                <div className="text-xs text-gv-muted font-bold tracking-widest">
                  {terms.length} {terms.length === 1 ? "término" : "términos"}
                </div>
              </div>

              <div className="grid lg:grid-cols-2 gap-5">
                {terms.map((t) => (
                  <TermCard key={termSlug(t)} term={t} onSelectRelated={(slug) => {
                    const target = GLOSSARY.find((x) => termSlug(x) === slug);
                    if (target) {
                      const head = (target.acronym ?? target.term).charAt(0).toUpperCase();
                      document.getElementById(`letter-${head}`)?.scrollIntoView({ behavior: "smooth" });
                    }
                  }} />
                ))}
              </div>
            </div>
          ))
        )}
      </section>

      {/* Footer panel */}
      <section className="max-w-7xl mx-auto px-6 pb-20">
        <div className="bg-gv-blue text-white rounded-card p-8 md:p-10">
          <div className="flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
            <div>
              <h3 className="text-2xl md:text-3xl font-bold">¿Te falta un término?</h3>
              <p className="mt-3 text-white/80 max-w-2xl leading-relaxed">
                Si no encontraste lo que buscás, escribínos. Ampliamos el glosario con
                términos que la comunidad LATAM realmente usa en sus operaciones.
              </p>
            </div>
            <BrandButton
              href="https://gloval-shipping.example/contacto?asunto=Sugerir%20termino%20glosario"
              className="!bg-gv-orange !border-gv-orange hover:!bg-gv-orange-dark shrink-0"
            >
              Sugerir un término
            </BrandButton>
          </div>
        </div>
      </section>
    </div>
  );
}

function TermCard({
  term,
  onSelectRelated,
}: {
  term: GlossaryTerm;
  onSelectRelated: (slug: string) => void;
}) {
  return (
    <article
      id={termSlug(term)}
      className="bg-white rounded-card border border-gv-border shadow-card p-6 hover:shadow-card-hover transition-shadow scroll-mt-52"
    >
      <header className="mb-3">
        <div className="flex items-start gap-3 flex-wrap">
          {term.acronym && (
            <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-md bg-gv-blue text-white text-sm font-extrabold font-mono tracking-wider">
              <Hash className="size-3" />
              {term.acronym}
            </span>
          )}
          <h3 className="text-lg font-bold text-gv-blue leading-tight flex-1">
            {term.term}
          </h3>
        </div>
        <div className="mt-2 flex flex-wrap gap-1.5">
          <span className={`text-[10px] font-bold tracking-widest uppercase px-2 py-0.5 rounded ${CATEGORY_COLORS[term.category]}`}>
            {CATEGORY_LABEL[term.category]}
          </span>
          {term.tags?.map((tag) => (
            <span
              key={tag}
              className="inline-flex items-center gap-1 text-[10px] font-bold tracking-wider uppercase px-2 py-0.5 rounded bg-gv-bg-soft text-gv-muted"
            >
              {tag === "LATAM" && <MapPin className="size-3" />}
              {tag}
            </span>
          ))}
        </div>
      </header>

      <p className="text-sm text-gv-muted leading-relaxed">{term.definition}</p>

      {term.relatedSlugs && term.relatedSlugs.length > 0 && (
        <footer className="mt-4 pt-4 border-t border-gv-border/60">
          <div className="text-[10px] font-bold tracking-widest uppercase text-gv-muted mb-2 flex items-center gap-1">
            <Link2 className="size-3" />
            Relacionados
          </div>
          <div className="flex flex-wrap gap-1.5">
            {term.relatedSlugs.map((slug) => {
              const t = GLOSSARY.find((x) => termSlug(x) === slug);
              const label = t?.acronym ?? t?.term ?? slug;
              return (
                <button
                  key={slug}
                  onClick={() => onSelectRelated(slug)}
                  className={`text-xs px-2.5 py-1 rounded-pill border transition-colors ${
                    t
                      ? "border-gv-border text-gv-blue hover:bg-gv-blue hover:text-white hover:border-gv-blue"
                      : "border-gv-border/40 text-gv-muted/60 cursor-default"
                  }`}
                  disabled={!t}
                >
                  {label}
                </button>
              );
            })}
          </div>
        </footer>
      )}
    </article>
  );
}
