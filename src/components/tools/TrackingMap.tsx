import { Tracking } from "@/lib/tracking";

/**
 * Visualización simple del recorrido — no es un mapa real, es una abstracción
 * estilo "infografía" alineada al lenguaje visual del homepage Eleva
 * (curva dashed naranja sobre dotted background).
 *
 * Cuando se conecte API real, este componente puede reemplazarse por Leaflet
 * + tiles reales. La interfaz pública (recibe Tracking) no cambia.
 */
export function TrackingMap({ data }: { data: Tracking }) {
  // Map projection: simple equirectangular bounded to relevant pacific region.
  // We'll fit -160..-30 lon, -50..40 lat into 800x320 viewBox.
  const minLon = -160;
  const maxLon = -30;
  const minLat = -50;
  const maxLat = 40;
  const W = 800;
  const H = 320;

  const project = (lat: number, lon: number) => {
    const x = ((lon - minLon) / (maxLon - minLon)) * W;
    const y = ((maxLat - lat) / (maxLat - minLat)) * H;
    return [x, y] as const;
  };

  // For Asia origins (lon > 0 or < -160), shove them to left edge.
  const wrappedLon = (lon: number) => {
    if (lon > 0) return -180 + (180 - lon) * -1; // simple wrap to far left
    return Math.max(minLon, lon);
  };

  const [ox, oy] = project(data.origin.lat, wrappedLon(data.origin.lon));
  const [dx, dy] = project(data.destination.lat, data.destination.lon);

  // Find points already-passed: events with ETA in the past
  const now = Date.now();
  const passed = data.events.filter((e) => new Date(e.date).getTime() <= now);
  const lastPassed = passed[passed.length - 1];

  // Approximate current position: midpoint along origin->destination based on
  // % events passed.
  const totalEvents = 6; // assume typical journey has 6-8 stages
  const progress = Math.min(1, passed.length / totalEvents);
  const cx = ox + (dx - ox) * progress;
  const cy = oy + (dy - oy) * progress - 30 * Math.sin(progress * Math.PI); // arc

  return (
    <div className="rounded-xl bg-gv-bg-soft border border-gv-border p-4">
      <svg
        viewBox={`0 0 ${W} ${H}`}
        className="w-full h-auto"
        role="img"
        aria-label={`Ruta ${data.origin.port} → ${data.destination.port}`}
      >
        <defs>
          <pattern id="trkdots" x="0" y="0" width="20" height="20" patternUnits="userSpaceOnUse">
            <circle cx="2" cy="2" r="1" fill="#003DA5" opacity="0.15" />
          </pattern>
        </defs>
        <rect width={W} height={H} fill="url(#trkdots)" />

        {/* Path from origin to destination, arc */}
        <path
          d={`M ${ox} ${oy} Q ${(ox + dx) / 2} ${Math.min(oy, dy) - 80} ${dx} ${dy}`}
          stroke="#FF9500"
          strokeWidth="2.5"
          fill="none"
          strokeDasharray="6 4"
          opacity="0.5"
        />

        {/* Already-passed segment */}
        <path
          d={`M ${ox} ${oy} Q ${(ox + cx) / 2} ${Math.min(oy, cy) - 60} ${cx} ${cy}`}
          stroke="#FF9500"
          strokeWidth="3"
          fill="none"
        />

        {/* Origin marker */}
        <circle cx={ox} cy={oy} r="9" fill="#FF9500" stroke="white" strokeWidth="2.5" />
        <text x={ox} y={oy + 28} textAnchor="middle" fontSize="13" fontWeight="700" fill="#003DA5">
          {data.origin.port.toUpperCase()}
        </text>
        <text x={ox} y={oy + 44} textAnchor="middle" fontSize="11" fill="#4B5573">
          {data.origin.locode}
        </text>

        {/* Destination marker */}
        <circle cx={dx} cy={dy} r="9" fill="#003DA5" stroke="white" strokeWidth="2.5" />
        <text x={dx} y={dy + 28} textAnchor="middle" fontSize="13" fontWeight="700" fill="#003DA5">
          {data.destination.port.toUpperCase()}
        </text>
        <text x={dx} y={dy + 44} textAnchor="middle" fontSize="11" fill="#4B5573">
          {data.destination.locode}
        </text>

        {/* Current position pulse (only if in transit) */}
        {data.status === "in_transit" && (
          <>
            <circle cx={cx} cy={cy} r="14" fill="#FF9500" opacity="0.25">
              <animate attributeName="r" from="10" to="22" dur="1.4s" repeatCount="indefinite" />
              <animate attributeName="opacity" from="0.4" to="0" dur="1.4s" repeatCount="indefinite" />
            </circle>
            <circle cx={cx} cy={cy} r="7" fill="#FF9500" stroke="white" strokeWidth="2" />
            <text x={cx} y={cy - 18} textAnchor="middle" fontSize="11" fontWeight="700" fill="#003DA5">
              {data.vessel}
            </text>
          </>
        )}

        {/* Caption with current/last status */}
        <text x={W / 2} y={H - 10} textAnchor="middle" fontSize="11" fill="#4B5573" fontStyle="italic">
          {lastPassed
            ? `Último evento: ${lastPassed.description} en ${lastPassed.location}`
            : "Sin eventos registrados aún"}
        </text>
      </svg>
    </div>
  );
}
