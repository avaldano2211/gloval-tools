import {
  Container,
  Calculator,
  Radar,
  GitBranch,
  MapPin,
  TriangleAlert,
} from "lucide-react";
import { ToolCard } from "@/components/brand/ToolCard";
import { H2 } from "@/components/brand/H2";
import { BrandButton } from "@/components/brand/BrandButton";

const TOOLS = [
  {
    icon: Container,
    title: "Especificaciones de Contenedores",
    description:
      "Dimensiones, pesos y capacidad de cada tipo de contenedor ISO. Incluye restricciones de peso por carretera para Ecuador, Perú, Panamá y Colombia.",
    href: "/herramientas/contenedores",
    comingSoon: false,
  },
  {
    icon: Calculator,
    title: "Calculadora de Cubicaje",
    description:
      "Calcula CBM, peso volumétrico y peso facturable para envíos marítimos, aéreos y courier. Sugiere modalidad óptima según ruta LATAM.",
    href: "/herramientas/cubicaje",
    comingSoon: false,
  },
  {
    icon: Radar,
    title: "Rastreo de Contenedores",
    description:
      "Rastrea contenedores, BLs y buques en tiempo real. Eventos completos del recorrido con visualización en mapa.",
    href: "/herramientas/rastreo",
    comingSoon: true,
  },
  {
    icon: GitBranch,
    title: "Incoterms 2020",
    description:
      "Tabla interactiva de los 11 Incoterms con wizard de recomendación y errores comunes específicos del comercio LATAM.",
    href: "/herramientas/incoterms",
    comingSoon: true,
  },
  {
    icon: MapPin,
    title: "Códigos UN/LOCODE",
    description:
      "Búsqueda de códigos de puertos, aeropuertos y terminales. Top 200 LATAM destacados con badge de oficinas Gloval.",
    href: "/herramientas/locode",
    comingSoon: true,
  },
  {
    icon: TriangleAlert,
    title: "Tabla IMO/IMDG",
    description:
      "Las 9 clases de mercancías peligrosas, matriz de segregación y restricciones específicas por país LATAM.",
    href: "/herramientas/imdg",
    comingSoon: true,
  },
];

export default function HerramientasHub() {
  return (
    <div className="min-h-screen">
      {/* Hero */}
      <section className="relative bg-gv-navy text-white overflow-hidden">
        <div className="absolute inset-0 opacity-20">
          <svg className="w-full h-full" viewBox="0 0 1200 400" preserveAspectRatio="xMidYMid slice">
            <defs>
              <pattern id="dots" x="0" y="0" width="40" height="40" patternUnits="userSpaceOnUse">
                <circle cx="2" cy="2" r="1.5" fill="white" opacity="0.3" />
              </pattern>
            </defs>
            <rect width="1200" height="400" fill="url(#dots)" />
            <path
              d="M 100 300 Q 400 100 700 200 T 1100 150"
              stroke="#FF9500"
              strokeWidth="2"
              strokeDasharray="6 4"
              fill="none"
            />
            <circle cx="100" cy="300" r="6" fill="#FF9500" />
            <circle cx="1100" cy="150" r="6" fill="#FF9500" />
          </svg>
        </div>
        <div className="relative max-w-7xl mx-auto px-6 py-24 md:py-32">
          <span className="inline-block px-4 py-1.5 rounded-pill bg-gv-orange text-white text-xs font-bold tracking-[0.2em] uppercase mb-6">
            Herramientas
          </span>
          <h1 className="text-5xl md:text-7xl font-extrabold leading-[1.05] max-w-4xl">
            Herramientas gratuitas para tu logística internacional
          </h1>
          <p className="mt-8 text-lg md:text-xl text-white/80 max-w-2xl leading-relaxed">
            Calculadoras, referencias y rastreo creados por expertos en carga
            internacional con más de 20 años sirviendo Latinoamérica.
          </p>
        </div>
      </section>

      {/* Tools grid */}
      <section className="bg-gv-bg-soft">
        <div className="max-w-7xl mx-auto px-6 py-20">
          <H2>Explora las herramientas</H2>
          <p className="mt-6 text-base text-gv-muted max-w-2xl">
            Seis herramientas pensadas para importadores, exportadores y agentes
            logísticos que operan rutas LATAM.
          </p>
          <div className="mt-12 grid sm:grid-cols-2 lg:grid-cols-3 gap-6">
            {TOOLS.map((tool) => (
              <ToolCard key={tool.title} {...tool} />
            ))}
          </div>
        </div>
      </section>

      {/* CTA */}
      <section className="bg-white">
        <div className="max-w-4xl mx-auto px-6 py-20 text-center">
          <H2 className="!text-3xl md:!text-4xl mx-auto inline-block">
            ¿No encuentras lo que buscas?
          </H2>
          <p className="mt-8 text-lg text-gv-muted">
            Cuéntanos qué necesitas. Nuestro equipo en Miami, Panamá, Ecuador y
            Perú puede ayudarte directamente.
          </p>
          <div className="mt-10 flex flex-col sm:flex-row items-center justify-center gap-4">
            <BrandButton href="https://gloval-shipping.example/cotizacion">
              Solicitar Cotización
            </BrandButton>
            <BrandButton variant="secondary" href="https://gloval-shipping.example/contacto">
              Hablar con un asesor
            </BrandButton>
          </div>
        </div>
      </section>
    </div>
  );
}
