import Link from "next/link";
import { cn } from "@/lib/utils";

/**
 * Variantes alineadas a glovalshipping.com:
 *
 * - **primary**: blanco con texto azul vivo (estilo "Request Quote" del hero).
 *   Pill (radius 999), bold 600, sin borde. Usado en hero y CTAs grandes.
 * - **filled**: azul vivo sólido con texto blanco. Para CTAs sobre fondos claros.
 * - **outline**: transparente con borde blanco y texto blanco. Para hero secundario.
 * - **orange**: naranja sólido con texto blanco (estilo "Submit" del form). Para acciones primarias destacadas.
 */
type Variant = "primary" | "filled" | "outline" | "orange" | "secondary";

interface BaseProps {
  variant?: Variant;
  className?: string;
  children: React.ReactNode;
}

const styles: Record<Variant, string> = {
  primary:
    "bg-white text-gv-blue-bright hover:bg-gv-bg-soft border border-white",
  filled:
    "bg-gv-blue-bright text-white hover:bg-gv-blue-bright-dark border border-gv-blue-bright",
  outline:
    "bg-transparent text-white hover:bg-white/10 border border-white",
  orange:
    "bg-gv-orange text-white hover:bg-gv-orange-dark border border-gv-orange",
  // Alias para retrocompatibilidad — secondary se renderiza como filled (azul vivo sólido).
  secondary:
    "bg-gv-blue-bright text-white hover:bg-gv-blue-bright-dark border border-gv-blue-bright",
};

const base =
  "inline-flex items-center justify-center gap-2 rounded-pill px-8 py-3.5 text-sm font-semibold transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-gv-blue-bright focus-visible:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed";

export function BrandButton({
  variant = "primary",
  className,
  children,
  href,
  ...rest
}: BaseProps & (
  | (React.ButtonHTMLAttributes<HTMLButtonElement> & { href?: undefined })
  | { href: string; type?: undefined; onClick?: undefined; disabled?: undefined }
)) {
  const cls = cn(base, styles[variant], className);
  if (href) {
    return (
      <Link href={href} className={cls}>
        {children}
      </Link>
    );
  }
  return (
    <button className={cls} {...(rest as React.ButtonHTMLAttributes<HTMLButtonElement>)}>
      {children}
    </button>
  );
}
