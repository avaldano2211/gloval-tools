import { cn } from "@/lib/utils";

export function H2({
  children,
  className,
  underline = true,
}: {
  children: React.ReactNode;
  className?: string;
  underline?: boolean;
}) {
  return (
    <h2
      className={cn(
        "text-4xl md:text-5xl font-bold text-gv-blue",
        underline && "gv-h2-underline",
        className
      )}
    >
      {children}
    </h2>
  );
}
