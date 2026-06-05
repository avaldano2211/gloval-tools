import Image from "next/image";
import { cn } from "@/lib/utils";

interface BrandLogoProps {
  className?: string;
  /**
   * "color" → logo a color (azul + naranja) sobre fondos claros — el `logo-sticky.svg` del sitio real.
   * "white" → logo blanco para fondos oscuros — el `logo-menu.svg` del sitio real.
   */
  variant?: "color" | "white";
  width?: number;
}

/**
 * Logo oficial Gloval Shipping. Los SVGs se descargaron directo del sitio público.
 * Aspect ratio nativo: 106×85 (ratio ≈ 1.247:1).
 */
export function BrandLogo({
  className,
  variant = "color",
  width = 100,
}: BrandLogoProps) {
  const height = Math.round(width * (85 / 106));
  const src = variant === "white" ? "/assets/logo-white.svg" : "/assets/logo-color.svg";
  return (
    <div
      className={cn("inline-flex items-center justify-center", className)}
      style={{ width, height }}
    >
      <Image
        src={src}
        alt="Gloval Shipping"
        width={width}
        height={height}
        priority
      />
    </div>
  );
}
