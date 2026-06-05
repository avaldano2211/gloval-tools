import Image from "next/image";
import {
  Container,
  Calculator,
  Radar,
  GitBranch,
  MapPin,
  TriangleAlert,
  FolderDown,
  BookOpen,
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
      "Rastrea contenedores, BLs y buques con eventos en tiempo real, ETA y visualización de la ruta. Versión demo con datos simulados.",
    href: "/herramientas/rastreo",
    comingSoon: false,
  },
  {
    icon: GitBranch,
    title: "Incoterms 2020",
    description:
      "Las 11 reglas oficiales con desglose de costo y riesgo por fase del viaje. Errores comunes específicos del comercio LATAM.",
    href: "/herramientas/incoterms",
    comingSoon: false,
  },
  {
    icon: MapPin,
    title: "Códigos UN/LOCODE",
    description:
      "Búsqueda de códigos de puertos, aeropuertos y terminales. Top 90+ LATAM destacados con distancia a la oficina Gloval más cercana.",
    href: "/herramientas/locode",
    comingSoon: false,
  },
  {
    icon: TriangleAlert,
    title: "Tabla IMO/IMDG",
    description:
      "Las 9 clases de mercancías peligrosas, matriz de segregación y restricciones específicas por país LATAM.",
    href: "/herramientas/imdg",
    comingSoon: false,
  },
  {
    icon: FolderDown,
    title: "Centro de Documentos",
    description:
      "POA, Shipping Instructions, formularios aduaneros, T&C, directorio de oficinas y más. Plantillas listas para usar.",
    href: "/herramientas/documentos",
    comingSoon: false,
  },
  {
    icon: BookOpen,
    title: "Glosario de Logística",
    description:
      "Diccionario de siglas y términos del comercio internacional con foco LATAM. BL, AWB, CFS, NANDINA, NCM, ZLC y muchos más.",
    href: "/herramientas/glosario",
    comingSoon: false,
  },
];

export default function HerramientasHub() {
  return (
    <div className="min-h-screen">
      {/* Hero — full-bleed photo + dark overlay, alineado a glovalshipping.com */}
      <section className="relative h-[88vh] min-h-[640px] flex items-center text-white overflow-hidden">
        <Image
          src="/assets/hero-bg.jpg"
          alt="Buque de carga internacional"
          fill
          priority
          quality={85}
          sizes="100vw"
          className="object-cover object-center -z-10"
        />
        {/* Overlay para legibilidad */}
        <div className="absolute inset-0 bg-gradient-to-r from-gv-navy/85 via-gv-navy/55 to-transparent -z-10" />

        <div className="relative max-w-7xl mx-auto px-6 w-full">
          <h1 className="text-4xl md:text-6xl font-bold leading-[1.1] max-w-2xl !text-white">
            Free Tools for International Freight
          </h1>
          <p className="mt-6 text-base md:text-lg text-white/90 max-w-xl leading-relaxed font-light">
            Calculadoras, referencias y rastreo creados por expertos en carga
            internacional con más de 20 años sirviendo Latinoamérica.
          </p>
          <div className="mt-10 flex flex-col sm:flex-row gap-4">
            <BrandButton href="#tools" className="!px-12">
              Explore Tools
            </BrandButton>
            <BrandButton
              variant="outline"
              href="https://www.glovalshipping.com/request-a-quote"
              className="!px-12"
            >
              Request Quote
            </BrandButton>
          </div>
        </div>
      </section>

      {/* Tools grid */}
      <section id="tools" className="bg-gv-bg-soft scroll-mt-20">
        <div className="max-w-7xl mx-auto px-6 py-20">
          <H2>Explora las herramientas</H2>
          <p className="mt-6 text-base text-gv-muted max-w-2xl leading-relaxed">
            Ocho herramientas pensadas para importadores, exportadores y agentes
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
          <p className="mt-8 text-base md:text-lg text-gv-muted leading-relaxed">
            Cuéntanos qué necesitas. Nuestro equipo en Miami, Panamá, Ecuador y
            Perú puede ayudarte directamente.
          </p>
          <div className="mt-10 flex flex-col sm:flex-row items-center justify-center gap-4">
            <BrandButton variant="filled" href="https://www.glovalshipping.com/request-a-quote">
              Request Quote
            </BrandButton>
            <BrandButton variant="orange" href="https://www.glovalshipping.com/contact-us">
              Hablar con un asesor
            </BrandButton>
          </div>
        </div>
      </section>
    </div>
  );
}
