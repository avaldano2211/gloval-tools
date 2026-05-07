import Link from "next/link";
import { LucideIcon, ArrowRight } from "lucide-react";

interface ToolCardProps {
  icon: LucideIcon;
  title: string;
  description: string;
  href: string;
  comingSoon?: boolean;
}

export function ToolCard({
  icon: Icon,
  title,
  description,
  href,
  comingSoon,
}: ToolCardProps) {
  const content = (
    <div className="group relative h-full bg-white rounded-card border border-gv-border shadow-card hover:shadow-card-hover transition-all duration-200 hover:-translate-y-1 p-8 flex flex-col">
      <div className="size-14 rounded-xl bg-gv-bg-soft flex items-center justify-center mb-6 group-hover:bg-gv-blue/10 transition-colors">
        <Icon className="size-7 text-gv-blue" strokeWidth={2} />
      </div>
      <h3 className="text-xl font-bold text-gv-blue mb-2">{title}</h3>
      <p className="text-sm text-gv-muted leading-relaxed flex-1">{description}</p>
      <div className="mt-6 flex items-center gap-2 text-sm font-semibold text-gv-blue">
        {comingSoon ? (
          <span className="inline-flex items-center px-3 py-1 rounded-pill bg-gv-orange text-white text-xs uppercase tracking-wider">
            Próximamente
          </span>
        ) : (
          <>
            <span>Abrir herramienta</span>
            <ArrowRight className="size-4 group-hover:translate-x-1 transition-transform" />
          </>
        )}
      </div>
    </div>
  );

  if (comingSoon) {
    return <div aria-disabled className="cursor-not-allowed opacity-90">{content}</div>;
  }

  return (
    <Link href={href} className="block h-full">
      {content}
    </Link>
  );
}
