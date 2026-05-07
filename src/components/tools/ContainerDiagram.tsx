import { ContainerSpec } from "@/lib/containers";

export function ContainerDiagram({ spec }: { spec: ContainerSpec }) {
  // Aspect-correct isometric box scaled to fit a 480x320 viewBox
  const ratio = spec.internal.length_m / spec.internal.height_m;
  const w = Math.min(360, ratio * 120);
  const h = 120;
  const depth = 60;
  const x = (480 - w - depth) / 2;
  const y = (320 - h - depth) / 2;

  return (
    <svg viewBox="0 0 480 320" className="w-full h-auto" aria-label={`Diagrama ${spec.name}`}>
      <defs>
        <pattern id="dots-bg" width="20" height="20" patternUnits="userSpaceOnUse">
          <circle cx="1.5" cy="1.5" r="1" fill="#003DA5" opacity="0.08" />
        </pattern>
      </defs>
      <rect width="480" height="320" fill="url(#dots-bg)" rx="12" />

      {/* Top face */}
      <polygon
        points={`${x},${y} ${x + w},${y} ${x + w + depth},${y - depth} ${x + depth},${y - depth}`}
        fill="#003DA5"
        opacity="0.85"
      />
      {/* Right face */}
      <polygon
        points={`${x + w},${y} ${x + w},${y + h} ${x + w + depth},${y + h - depth} ${x + w + depth},${y - depth}`}
        fill="#002C7A"
      />
      {/* Front face */}
      <rect x={x} y={y} width={w} height={h} fill="#0050D2" stroke="#003DA5" strokeWidth="2" />
      {/* Door lines */}
      <line x1={x + w * 0.5} y1={y + 8} x2={x + w * 0.5} y2={y + h - 8} stroke="#FF9500" strokeWidth="1.5" />
      <circle cx={x + w * 0.5 - 6} cy={y + h * 0.5} r="2" fill="#FF9500" />
      <circle cx={x + w * 0.5 + 6} cy={y + h * 0.5} r="2" fill="#FF9500" />

      {/* Length annotation */}
      <line x1={x} y1={y + h + 24} x2={x + w} y2={y + h + 24} stroke="#FF9500" strokeWidth="1.5" markerEnd="url(#arrow)" markerStart="url(#arrow)" />
      <text x={x + w / 2} y={y + h + 42} textAnchor="middle" fill="#003DA5" fontSize="13" fontWeight="600">
        {spec.internal.length_m.toFixed(2)} m
      </text>

      {/* Height annotation */}
      <line x1={x - 24} y1={y} x2={x - 24} y2={y + h} stroke="#FF9500" strokeWidth="1.5" />
      <text x={x - 32} y={y + h / 2} textAnchor="middle" fill="#003DA5" fontSize="13" fontWeight="600" transform={`rotate(-90 ${x - 32} ${y + h / 2})`}>
        {spec.internal.height_m.toFixed(2)} m
      </text>

      <defs>
        <marker id="arrow" markerWidth="6" markerHeight="6" refX="3" refY="3" orient="auto">
          <path d="M 0 0 L 6 3 L 0 6 Z" fill="#FF9500" />
        </marker>
      </defs>
    </svg>
  );
}
