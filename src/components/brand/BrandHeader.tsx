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
  { label: "Tools",     href: "/herramientas", active: true },
];

/**
 * Header alineado a glovalshipping.com.
 *
 * - **Hub `/herramientas`**: arranca transparente sobre el hero oscuro, se
 *   solidifica al scrollear (>60px).
 * - **Otras páginas** (`/herramientas/contenedores`, `/cubicaje`, etc.): siempre
 *   sólido porque no hay hero oscuro detrás.
 */
export function BrandHeader() {
  const pathname = usePathname();
  const isHubPage = pathname === "/herramientas";

  // Manejamos hub vs otras pages con un solo useEffect.
  // Default: opaque. En el hub, el effect cambia a transparent si scrollY === 0.
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
        <Link href="/herramientas" aria-label="Gloval Shipping — Tools">
          <BrandLogo variant={isTransparent ? "white" : "color"} width={90} />
        </Link>
        <nav className="hidden md:flex items-center gap-9">
          {NAV.map((item) => {
            const colorClass = isTransparent ? "text-white" : "text-gv-blue";
            const inactiveClass = isTransparent
              ? "text-white/85 hover:text-white"
              : "text-gv-blue/80 hover:text-gv-blue";
            return (
              <Link
                key={item.label}
                href={item.href}
                className={`relative text-sm font-semibold transition-colors ${
                  item.active
                    ? `${colorClass} after:absolute after:-bottom-1.5 after:left-0 after:right-0 after:h-[3px] after:bg-gv-orange after:rounded-full`
                    : inactiveClass
                }`}
              >
                {item.label}
              </Link>
            );
          })}
        </nav>
      </div>
    </header>
  );
}
