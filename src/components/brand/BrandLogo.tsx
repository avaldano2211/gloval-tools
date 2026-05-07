import { cn } from "@/lib/utils";

export function BrandLogo({ className }: { className?: string }) {
  return (
    <div className={cn("flex flex-col items-start leading-none", className)}>
      <div className="flex items-end gap-2">
        <svg
          width="44"
          height="36"
          viewBox="0 0 44 36"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
          aria-hidden
        >
          <ellipse
            cx="22"
            cy="18"
            rx="20"
            ry="9"
            stroke="#003DA5"
            strokeWidth="3"
            fill="none"
          />
          <path
            d="M 4 12 Q 22 4 40 12"
            stroke="#FF9500"
            strokeWidth="3"
            fill="none"
            strokeLinecap="round"
          />
          <circle cx="22" cy="18" r="4" fill="#003DA5" />
        </svg>
        <span className="text-3xl font-extrabold tracking-tight text-gv-blue">
          GLO<span className="text-gv-orange">VAL</span>
        </span>
      </div>
      <span className="text-[10px] tracking-[0.4em] text-gv-muted uppercase mt-1 ml-12">
        shipping
      </span>
    </div>
  );
}
