import Link from "next/link";
import { cn } from "@/lib/utils";

type Variant = "primary" | "secondary";

interface BaseProps {
  variant?: Variant;
  className?: string;
  children: React.ReactNode;
}

const styles: Record<Variant, string> = {
  primary:
    "bg-gv-blue text-white hover:bg-gv-blue-dark border border-gv-blue",
  secondary:
    "bg-white text-gv-blue border border-gv-blue hover:bg-gv-bg-soft",
};

const base =
  "inline-flex items-center justify-center gap-2 rounded-pill px-7 py-3.5 text-sm font-semibold transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-gv-blue focus-visible:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed";

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
