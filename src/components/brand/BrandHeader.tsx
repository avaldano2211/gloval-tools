import Link from "next/link";
import { BrandLogo } from "./BrandLogo";

const NAV = [
  { label: "Inicio", href: "https://gloval-shipping.example/" },
  { label: "Servicios", href: "https://gloval-shipping.example/servicios" },
  { label: "Ubicaciones", href: "https://gloval-shipping.example/ubicaciones" },
  { label: "Cotización", href: "https://gloval-shipping.example/cotizacion" },
  { label: "Rastreo", href: "https://gloval-shipping.example/rastreo" },
  { label: "Herramientas", href: "/herramientas", active: true },
  { label: "Blogs", href: "https://gloval-shipping.example/blogs" },
];

export function BrandHeader() {
  return (
    <header className="w-full border-b border-gv-border bg-white">
      <div className="max-w-7xl mx-auto px-6 py-5 flex items-center justify-between">
        <Link href="/herramientas" aria-label="Gloval Shipping — Herramientas">
          <BrandLogo width={100} />
        </Link>
        <nav className="hidden md:flex items-center gap-8">
          {NAV.map((item) => (
            <Link
              key={item.label}
              href={item.href}
              className={`text-sm font-medium transition-colors ${
                item.active
                  ? "text-gv-blue underline underline-offset-8 decoration-gv-orange decoration-2"
                  : "text-gv-blue/80 hover:text-gv-blue"
              }`}
            >
              {item.label}
            </Link>
          ))}
        </nav>
      </div>
    </header>
  );
}
