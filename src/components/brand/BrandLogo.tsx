import Image from "next/image";
import { cn } from "@/lib/utils";

interface BrandLogoProps {
  className?: string;
  variant?: "color" | "light";
  width?: number;
}

/**
 * Renders /public/logo.png. The PNG already includes both the mark and the
 * "GLOVAL shipping" wordmark, so this component is just a tuned <Image>.
 *
 * Native asset is 1510×1749 (≈1:1.16). Width prop drives the rendered size;
 * height auto-scales to preserve aspect ratio.
 */
export function BrandLogo({
  className,
  variant = "color",
  width = 96,
}: BrandLogoProps) {
  const height = Math.round(width * (1749 / 1510));
  return (
    <div
      className={cn(
        "inline-flex items-center justify-center",
        variant === "light" && "[&>img]:brightness-0 [&>img]:invert",
        className,
      )}
      style={{ width, height }}
    >
      <Image
        src="/logo.png"
        alt="Gloval Shipping"
        width={width}
        height={height}
        priority
      />
    </div>
  );
}
