"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useEffect, useState } from "react";
import { BrandLogo } from "./BrandLogo";

const NAV = [
  { label: "Home",      href: "https://www.glovalshipping.com/" },
  { label: "Services",  href: "https://www.glovalshipping.com/services" },
  { label: "Locations", href: "https://www.glovalshipping.com/locations" },
  { label: "Quote",     href: "https://www.glovalshipping.com/request-a-quote" },
  { label: "Tracking",  href: "https://www.glovalshipping.com/track-shipment" },
  { label: "Tools",     href: "/tools", isTools: true },
];

/**
 * Header alineado a glovalshipping.com.
 *
 * - **Hub `/tools` (EN) o `/herramientas` (ES)**: arranca transparente sobre el hero oscuro,
 *   se solidifica al scrollear (>60px).
 * - **Otras páginas** (`/herramientas/contenedores`, `/cubicaje`, etc.): siempre
 *   sólido porque no hay hero oscuro detrás.
 * - Incluye **language switcher** EN/ES que swappea entre /tools y /herramientas.
 */
export function BrandHeader() {
  const pathname = usePathname();
  const isHubPage = pathname === "/tools" || pathname === "/herramientas";

  const [solid, setSolid] = useState(true);

  useEffect(() => {
    if (!isHubPage) {
      setSolid(true);
      return;
    }
    const update = () => setSolid(window.scrollY > 60);
    update();
    window.addEventListener("scroll", update, { passive: true });
    return () => window.removeEventListener("scroll", update);
  }, [isHubPage]);

  const isTransparent = !solid;
  // "Tools" item está active en cualquier /tools, /tools/*, /herramientas, /herramientas/*
  const isToolsActive =
    pathname === "/tools" ||
    pathname.startsWith("/tools/") ||
    pathname === "/herramientas" ||
    pathname.startsWith("/herramientas/");

  // El switcher refleja el idioma actual. Si estamos en /herramientas o sub-pages → ES, otherwise → EN.
  const currentLang: "EN" | "ES" =
    pathname === "/herramientas" || pathname.startsWith("/herramientas/") ? "ES" : "EN";

  // Mapeo de slugs paralelos entre EN y ES — el switcher mantiene la página actual.
  const SLUG_EN_TO_ES: Record<string, string> = {
    "containers": "contenedores",
    "calculator": "cubicaje",
    "tracking":   "rastreo",
    "incoterms":  "incoterms",
    "locode":     "locode",
    "imdg":       "imdg",
    "documents":  "documentos",
    "glossary":   "glosario",
  };
  const SLUG_ES_TO_EN: Record<string, string> = Object.fromEntries(
    Object.entries(SLUG_EN_TO_ES).map(([en, es]) => [es, en]),
  );

  let otherLangHref = currentLang === "EN" ? "/herramientas" : "/tools";
  if (currentLang === "EN" && pathname.startsWith("/tools/")) {
    const slug = pathname.split("/")[2];
    const mapped = SLUG_EN_TO_ES[slug];
    if (mapped) otherLangHref = `/herramientas/${mapped}`;
  } else if (currentLang === "ES" && pathname.startsWith("/herramientas/")) {
    const slug = pathname.split("/")[2];
    const mapped = SLUG_ES_TO_EN[slug];
    if (mapped) otherLangHref = `/tools/${mapped}`;
  }
  const otherLangLabel = currentLang === "EN" ? "ES" : "EN";

  return (
    <header
      className={[
        "fixed top-0 left-0 right-0 z-40 transition-all duration-300",
        isTransparent
          ? "bg-transparent"
          : "bg-white/95 backdrop-blur shadow-[0_2px_12px_rgba(0,70,167,0.06)]",
      ].join(" ")}
    >
      <div className="max-w-7xl mx-auto px-6 py-4 flex items-center justify-between">
        <Link href="/tools" aria-label="Gloval Shipping — Tools">
          <BrandLogo variant={isTransparent ? "white" : "color"} width={90} />
        </Link>
        <nav className="hidden md:flex items-center gap-8">
          {NAV.map((item) => {
            const active = item.isTools ? isToolsActive : false;
            const colorClass = isTransparent ? "text-white" : "text-gv-blue";
            const inactiveClass = isTransparent
              ? "text-white/85 hover:text-white"
              : "text-gv-blue/80 hover:text-gv-blue";
            return (
              <Link
                key={item.label}
                href={item.href}
                className={`relative text-sm font-semibold transition-colors ${
                  active
                    ? `${colorClass} after:absolute after:-bottom-1.5 after:left-0 after:right-0 after:h-[3px] after:bg-gv-orange after:rounded-full`
                    : inactiveClass
                }`}
              >
                {item.label}
              </Link>
            );
          })}

          {/* Language switcher */}
          <LanguageSwitcher
            currentLang={currentLang}
            otherLangHref={otherLangHref}
            otherLangLabel={otherLangLabel}
            isTransparent={isTransparent}
          />
        </nav>
      </div>
    </header>
  );
}

function LanguageSwitcher({
  currentLang,
  otherLangHref,
  otherLangLabel,
  isTransparent,
}: {
  currentLang: "EN" | "ES";
  otherLangHref: string;
  otherLangLabel: string;
  isTransparent: boolean;
}) {
  const baseColor = isTransparent ? "text-white" : "text-gv-blue";
  const borderColor = isTransparent ? "border-white/40" : "border-gv-border";
  const hoverBg = isTransparent ? "hover:bg-white/10" : "hover:bg-gv-bg-soft";

  return (
    <div
      className={`inline-flex items-center rounded-pill border ${borderColor} overflow-hidden text-xs font-bold`}
    >
      <span className={`${baseColor} px-3 py-1.5 bg-gv-orange/90 text-white`}>
        {currentLang}
      </span>
      <Link
        href={otherLangHref}
        className={`${baseColor} px-3 py-1.5 ${hoverBg} transition-colors`}
        aria-label={`Switch to ${otherLangLabel}`}
      >
        {otherLangLabel}
      </Link>
    </div>
  );
}
