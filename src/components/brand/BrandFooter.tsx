import { BrandLogo } from "./BrandLogo";

const OFFICES = [
  { city: "Miami", country: "USA", flag: "🇺🇸" },
  { city: "Panamá", country: "Panama", flag: "🇵🇦" },
  { city: "Guayaquil", country: "Ecuador", flag: "🇪🇨" },
  { city: "Lima", country: "Perú", flag: "🇵🇪" },
];

export function BrandFooter() {
  return (
    <footer className="w-full bg-gv-navy text-white mt-24">
      <div className="max-w-7xl mx-auto px-6 py-16 grid md:grid-cols-3 gap-12">
        <div>
          <BrandLogo className="[&_span]:text-white [&_.text-gv-blue]:text-white" />
          <p className="mt-6 text-sm text-white/70 leading-relaxed max-w-sm">
            Expertos en logística internacional con más de 20 años de experiencia
            sirviendo a Latinoamérica.
          </p>
        </div>
        <div>
          <h4 className="text-xs font-bold tracking-[0.2em] uppercase text-gv-orange mb-4">
            Oficinas
          </h4>
          <ul className="space-y-2 text-sm text-white/80">
            {OFFICES.map((o) => (
              <li key={o.city} className="flex items-center gap-2">
                <span aria-hidden>{o.flag}</span>
                <span>
                  {o.city}, {o.country}
                </span>
              </li>
            ))}
          </ul>
        </div>
        <div>
          <h4 className="text-xs font-bold tracking-[0.2em] uppercase text-gv-orange mb-4">
            Herramientas
          </h4>
          <ul className="space-y-2 text-sm text-white/80">
            <li>Especificaciones de Contenedores</li>
            <li>Calculadora de Cubicaje</li>
            <li>Rastreo de Contenedores</li>
            <li>Incoterms 2020</li>
            <li>Códigos UN/LOCODE</li>
            <li>Tabla IMO/IMDG</li>
          </ul>
        </div>
      </div>
      <div className="border-t border-white/10">
        <div className="max-w-7xl mx-auto px-6 py-6 text-xs text-white/50 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-2">
          <span>© {new Date().getFullYear()} Gloval Shipping. Todos los derechos reservados.</span>
          <span>Las herramientas son informativas. Para cotizaciones oficiales contacta a tu agente Gloval.</span>
        </div>
      </div>
    </footer>
  );
}
