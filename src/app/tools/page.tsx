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

/**
 * EN hub at /tools (primary public entry point).
 *
 * Each tool card currently links to its existing Spanish internal page under
 * /herramientas/* — those pages will be translated in a later pass. A
 * language switcher in the header lets the user toggle to /herramientas (ES
 * hub) at any time.
 */
const TOOLS = [
  {
    icon: Container,
    title: "Container Specifications",
    description:
      "Dimensions, weight, and capacity for each ISO container type. Includes road weight limits for Ecuador, Peru, Panama, and Colombia.",
    href: "/tools/containers",
    comingSoon: false,
  },
  {
    icon: Calculator,
    title: "Volume & Weight Calculator",
    description:
      "Compute CBM, volumetric weight, and chargeable weight for ocean, air, and courier shipments. Suggests the best mode based on LATAM routes.",
    href: "/tools/calculator",
    comingSoon: false,
  },
  {
    icon: Radar,
    title: "Container Tracking",
    description:
      "Track containers, BLs, and vessels with live events, ETA, and route map. Demo version with simulated data.",
    href: "/tools/tracking",
    comingSoon: false,
  },
  {
    icon: GitBranch,
    title: "Incoterms 2020",
    description:
      "All 11 official rules with cost-and-risk breakdown per shipment phase. Common pitfalls specific to LATAM trade.",
    href: "/tools/incoterms",
    comingSoon: false,
  },
  {
    icon: MapPin,
    title: "UN/LOCODE Search",
    description:
      "Lookup codes for ports, airports, and terminals. Top 90+ LATAM locations highlighted with distance to nearest Gloval office.",
    href: "/tools/locode",
    comingSoon: false,
  },
  {
    icon: TriangleAlert,
    title: "IMO/IMDG Table",
    description:
      "The 9 classes of dangerous goods, segregation matrix, and country-specific restrictions across LATAM.",
    href: "/tools/imdg",
    comingSoon: false,
  },
  {
    icon: FolderDown,
    title: "Document Center",
    description:
      "POA, Shipping Instructions, customs forms, T&C, office directory and more. Ready-to-use templates.",
    href: "/tools/documents",
    comingSoon: false,
  },
  {
    icon: BookOpen,
    title: "Logistics Glossary",
    description:
      "Dictionary of international trade acronyms and terms with a LATAM focus. BL, AWB, CFS, NANDINA, NCM, ZLC and many more.",
    href: "/tools/glossary",
    comingSoon: false,
  },
];

export default function ToolsHub() {
  return (
    <div className="min-h-screen">
      {/* Hero — full-bleed photo + dark overlay, aligned to glovalshipping.com */}
      <section className="relative h-[88vh] min-h-[640px] flex items-center text-white overflow-hidden">
        <Image
          src="/assets/hero-bg.jpg"
          alt="International freight vessel"
          fill
          priority
          quality={85}
          sizes="100vw"
          className="object-cover object-center -z-10"
        />
        <div className="absolute inset-0 bg-gradient-to-r from-gv-navy/85 via-gv-navy/55 to-transparent -z-10" />

        <div className="relative max-w-7xl mx-auto px-6 w-full">
          <h1 className="text-4xl md:text-6xl font-bold leading-[1.1] max-w-2xl !text-white">
            Free Tools for International Freight
          </h1>
          <p className="mt-6 text-base md:text-lg text-white/90 max-w-xl leading-relaxed font-light">
            Calculators, references, and tracking built by experts in
            international cargo with 20+ years serving Latin America.
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
          <H2>Explore the tools</H2>
          <p className="mt-6 text-base text-gv-muted max-w-2xl leading-relaxed">
            Eight tools built for importers, exporters, and freight agents
            operating LATAM routes.
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
            Don&apos;t see what you need?
          </H2>
          <p className="mt-8 text-base md:text-lg text-gv-muted leading-relaxed">
            Tell us what you&apos;re looking for. Our team in Miami, Panama,
            Ecuador, and Peru can help you directly.
          </p>
          <div className="mt-10 flex flex-col sm:flex-row items-center justify-center gap-4">
            <BrandButton variant="filled" href="https://www.glovalshipping.com/request-a-quote">
              Request Quote
            </BrandButton>
            <BrandButton variant="orange" href="https://www.glovalshipping.com/contact-us">
              Talk to an advisor
            </BrandButton>
          </div>
        </div>
      </section>
    </div>
  );
}
