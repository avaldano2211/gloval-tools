import { ContainerSpec } from "@/lib/containers";

const M_TO_IN = 39.3701;

function mToFtIn(m: number): string {
  const totalIn = Math.round(m * M_TO_IN);
  const ft = Math.floor(totalIn / 12);
  const inches = totalIn - ft * 12;
  if (inches === 0) return `${ft}' 0"`;
  return `${ft}' ${inches}"`;
}

function triple(m: number): { primary: string; secondary: string } {
  return {
    primary: `${m.toFixed(2)} m`,
    secondary: `${mToFtIn(m)}  ·  ${Math.round(m * 100)} cm`,
  };
}

const OWNER_SERIAL: Record<string, string> = {
  "20gp":  "200123 4",
  "40gp":  "400456 1",
  "40hc":  "400789 2",
  "45hc":  "451234 5",
  "20rf":  "205678 8",
  "40rfhc":"459012 6",
  "20ot":  "206789 3",
  "40ot":  "401234 0",
  "20fr":  "207890 9",
  "40fr":  "405678 7",
  "20tk":  "208901 1",
};

const SIZE_TYPE_CODE: Record<string, string> = {
  "20gp":  "22G1",
  "40gp":  "42G1",
  "40hc":  "45G1",
  "45hc":  "L5G1",
  "20rf":  "22R1",
  "40rfhc":"45R1",
  "20ot":  "22U1",
  "40ot":  "42U1",
  "20fr":  "22P1",
  "40fr":  "42P1",
  "20tk":  "22T0",
};

export function ContainerDiagram({ spec }: { spec: ContainerSpec }) {
  const L = spec.internal.length_m;
  const W = spec.internal.width_m;
  const H = spec.internal.height_m;

  // ViewBox sized to fit the longest container (45') with annotations
  const VBW = 640;
  const VBH = 380;
  const maxBoxW = 430;
  const maxBoxH = 138;

  let scale = maxBoxH / H;
  if (L * scale > maxBoxW) scale = maxBoxW / L;

  const bw = L * scale;
  const bh = H * scale;
  // Compress depth so the side face stays readable on long containers
  const depthScale = Math.min(scale * 0.55, 22);
  const bdx = W * depthScale * 0.93; // cos(~22°)
  const bdy = W * depthScale * 0.36; // sin(~22°)

  // Center the visible footprint (front face + depth shift) inside the viewBox
  const cx = (VBW - bw - bdx) / 2 + bdx / 2;
  const cy = 150;

  const fTL = { x: cx,      y: cy };
  const fTR = { x: cx + bw, y: cy };
  const fBL = { x: cx,      y: cy + bh };
  const fBR = { x: cx + bw, y: cy + bh };
  const bTL = { x: fTL.x + bdx, y: fTL.y - bdy };
  const bTR = { x: fTR.x + bdx, y: fTR.y - bdy };
  const bBR = { x: fBR.x + bdx, y: fBR.y - bdy };

  const corrugationCount = Math.max(8, Math.round(L * 1.8));
  const isReefer = spec.category === "reefer";

  const tripL = triple(L);
  const tripW = triple(W);
  const tripH = triple(H);

  const railH = Math.max(4, bh * 0.06);
  const ownerCode = `GVAL ${OWNER_SERIAL[spec.id] ?? "000000 0"}  ${SIZE_TYPE_CODE[spec.id] ?? "00G1"}`;

  return (
    <svg
      viewBox={`0 0 ${VBW} ${VBH}`}
      className="w-full h-auto"
      aria-label={`Diagram ${spec.name}`}
    >
      <defs>
        <pattern id="dotsBg" width="20" height="20" patternUnits="userSpaceOnUse">
          <circle cx="1.5" cy="1.5" r="1" fill="#003DA5" opacity="0.08" />
        </pattern>
        <linearGradient id="topGrad" x1="0" y1="0" x2="0.4" y2="1">
          <stop offset="0%" stopColor="#2A7AE0" />
          <stop offset="100%" stopColor="#0B4DB0" />
        </linearGradient>
        <linearGradient id="sideGrad" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%"  stopColor="#0A58CC" />
          <stop offset="100%" stopColor="#003DA5" />
        </linearGradient>
        <linearGradient id="doorGrad" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%"  stopColor="#022E80" />
          <stop offset="100%" stopColor="#011548" />
        </linearGradient>
        <marker id="arr" viewBox="0 0 6 6" markerWidth="6" markerHeight="6" refX="3" refY="3" orient="auto">
          <path d="M 0 0 L 6 3 L 0 6 Z" fill="#FF8A33" />
        </marker>
        <marker id="arrStart" viewBox="0 0 6 6" markerWidth="6" markerHeight="6" refX="3" refY="3" orient="auto-start-reverse">
          <path d="M 0 0 L 6 3 L 0 6 Z" fill="#FF8A33" />
        </marker>
      </defs>

      <rect width={VBW} height={VBH} fill="url(#dotsBg)" rx="12" />

      {/* === TOP FACE === */}
      <polygon
        points={`${fTL.x},${fTL.y} ${fTR.x},${fTR.y} ${bTR.x},${bTR.y} ${bTL.x},${bTL.y}`}
        fill="url(#topGrad)"
        stroke="#001A4D"
        strokeWidth="1"
      />
      {/* Top ridges parallel to length */}
      {[0.25, 0.5, 0.75].map((t, i) => (
        <line
          key={`tr-${i}`}
          x1={fTL.x + bdx * t}
          y1={fTL.y - bdy * t}
          x2={fTR.x + bdx * t}
          y2={fTR.y - bdy * t}
          stroke="#001A4D"
          strokeWidth="0.5"
          opacity="0.35"
        />
      ))}

      {/* === RIGHT FACE (door end) === */}
      <polygon
        points={`${fTR.x},${fTR.y} ${bTR.x},${bTR.y} ${bBR.x},${bBR.y} ${fBR.x},${fBR.y}`}
        fill="url(#doorGrad)"
        stroke="#001A4D"
        strokeWidth="1"
      />

      {/* Reefer machine panel (top ~28% of door face) */}
      {isReefer &&
        (() => {
          const reeferH = bh * 0.28;
          const r1 = fTR;
          const r2 = bTR;
          const r3 = { x: bTR.x, y: bTR.y + reeferH };
          const r4 = { x: fTR.x, y: fTR.y + reeferH };
          return (
            <g>
              <polygon
                points={`${r1.x},${r1.y} ${r2.x},${r2.y} ${r3.x},${r3.y} ${r4.x},${r4.y}`}
                fill="#D9DEE6"
                stroke="#001A4D"
                strokeWidth="0.8"
              />
              {[0.2, 0.5, 0.8].map((t, i) => {
                const x = r4.x + (r3.x - r4.x) * t;
                const y = r4.y + (r3.y - r4.y) * t;
                return (
                  <rect
                    key={`vent-${i}`}
                    x={x - 6}
                    y={y - reeferH * 0.55}
                    width="12"
                    height="5"
                    fill="#5A6B85"
                    opacity="0.75"
                    rx="0.5"
                  />
                );
              })}
            </g>
          );
        })()}

      {/* Door split + horizontal panel lines */}
      {(() => {
        const splitTopX = (fTR.x + bTR.x) / 2;
        const splitTopY = (fTR.y + bTR.y) / 2;
        const splitBotX = (fBR.x + bBR.x) / 2;
        const splitBotY = (fBR.y + bBR.y) / 2;
        const reeferOffset = isReefer ? bh * 0.28 : 0;
        return (
          <g>
            <line
              x1={splitTopX}
              y1={splitTopY + reeferOffset}
              x2={splitBotX}
              y2={splitBotY}
              stroke="#01102F"
              strokeWidth="1.4"
            />
            {[0.25, 0.5, 0.75].map((t, i) => {
              const yT = fTR.y + (fBR.y - fTR.y) * t + reeferOffset * (1 - t);
              const yB = bTR.y + (bBR.y - bTR.y) * t + reeferOffset * (1 - t);
              return (
                <line
                  key={`dh-${i}`}
                  x1={fTR.x}
                  y1={yT}
                  x2={bTR.x}
                  y2={yB}
                  stroke="#01102F"
                  strokeWidth="0.5"
                  opacity="0.5"
                />
              );
            })}
          </g>
        );
      })()}

      {/* Locking bars (4 vertical) with cam handles */}
      {[0.13, 0.36, 0.64, 0.87].map((t, i) => {
        const reeferOffset = isReefer ? bh * 0.28 : 0;
        const x1 = fTR.x + (bTR.x - fTR.x) * t;
        const yTop = fTR.y + (bTR.y - fTR.y) * t + reeferOffset;
        const x2 = fBR.x + (bBR.x - fBR.x) * t;
        const yBot = fBR.y + (bBR.y - fBR.y) * t;
        const ym = yTop + (yBot - yTop) * 0.48;
        return (
          <g key={`bar-${i}`}>
            <line x1={x1} y1={yTop} x2={x2} y2={yBot} stroke="#FF8A33" strokeWidth="1.6" />
            <rect x={x1 - 1.8} y={ym} width="3.6" height="5" fill="#FF8A33" rx="0.5" />
          </g>
        );
      })}

      {/* === FRONT FACE (long side with branding) === */}
      <rect
        x={fTL.x}
        y={fTL.y}
        width={bw}
        height={bh}
        fill="url(#sideGrad)"
        stroke="#001A4D"
        strokeWidth="1.5"
      />
      {/* Top + bottom rails */}
      <rect x={fTL.x} y={fTL.y}            width={bw} height={railH} fill="#01215C" opacity="0.85" />
      <rect x={fTL.x} y={fBL.y - railH}    width={bw} height={railH} fill="#01215C" opacity="0.85" />
      {/* Vertical corrugation lines */}
      {Array.from({ length: corrugationCount }).map((_, i) => {
        const xx = fTL.x + (bw * (i + 1)) / (corrugationCount + 1);
        return (
          <line
            key={`fc-${i}`}
            x1={xx}
            y1={fTL.y + railH}
            x2={xx}
            y2={fBL.y - railH}
            stroke="#001740"
            strokeWidth="0.7"
            opacity="0.55"
          />
        );
      })}

      {/* GLOVAL SHIPPING branding */}
      <text
        x={fTL.x + bw * 0.5}
        y={fTL.y + bh * 0.50}
        textAnchor="middle"
        fontFamily="Poppins, ui-sans-serif, system-ui, sans-serif"
        fontWeight="900"
        fontSize={Math.max(16, Math.min(bh * 0.32, bw * 0.10))}
        fill="white"
        style={{ letterSpacing: `${Math.max(0.5, bh * 0.02)}px` }}
      >
        GLOVAL
      </text>
      <text
        x={fTL.x + bw * 0.5}
        y={fTL.y + bh * 0.72}
        textAnchor="middle"
        fontFamily="Poppins, ui-sans-serif, system-ui, sans-serif"
        fontWeight="700"
        fontSize={Math.max(8, Math.min(bh * 0.13, bw * 0.045))}
        fill="#FF8A33"
        style={{ letterSpacing: `${Math.max(1.2, bh * 0.05)}px` }}
      >
        SHIPPING
      </text>

      {/* ISO 6346 BIC code, top-right of front face */}
      <text
        x={fTL.x + bw - 6}
        y={fTL.y + railH + 9}
        textAnchor="end"
        fontFamily="ui-monospace, SFMono-Regular, Menlo, monospace"
        fontWeight="700"
        fontSize="8"
        fill="white"
        opacity="0.88"
      >
        {ownerCode}
      </text>

      {/* Corner castings (the 8 dark boxes at every container corner) */}
      {[
        [fTL.x - 2, fTL.y - 2],
        [fTR.x - 3, fTR.y - 2],
        [bTL.x - 2, bTL.y - 2],
        [bTR.x - 3, bTR.y - 2],
        [fBL.x - 2, fBL.y - 3],
        [fBR.x - 3, fBR.y - 3],
        [bBR.x - 3, bBR.y - 3],
      ].map(([x, y], i) => (
        <rect key={`cc-${i}`} x={x} y={y} width="5" height="5" fill="#000814" />
      ))}

      {/* === ANNOTATIONS === */}

      {/* LENGTH (bottom, along the long side) */}
      <line
        x1={fBL.x}
        y1={fBL.y + 30}
        x2={fBR.x}
        y2={fBR.y + 30}
        stroke="#FF8A33"
        strokeWidth="1.5"
        markerStart="url(#arrStart)"
        markerEnd="url(#arr)"
      />
      <text x={(fBL.x + fBR.x) / 2} y={fBL.y + 50} textAnchor="middle" fontSize="14" fontWeight="700" fill="#003DA5">
        L · {tripL.primary}
      </text>
      <text x={(fBL.x + fBR.x) / 2} y={fBL.y + 66} textAnchor="middle" fontSize="11" fontWeight="500" fill="#5A6B85">
        {tripL.secondary}
      </text>

      {/* HEIGHT (left edge) */}
      <line
        x1={fTL.x - 30}
        y1={fTL.y}
        x2={fTL.x - 30}
        y2={fBL.y}
        stroke="#FF8A33"
        strokeWidth="1.5"
        markerStart="url(#arrStart)"
        markerEnd="url(#arr)"
      />
      <g transform={`rotate(-90 ${fTL.x - 50} ${(fTL.y + fBL.y) / 2})`}>
        <text x={fTL.x - 50} y={(fTL.y + fBL.y) / 2 - 4} textAnchor="middle" fontSize="14" fontWeight="700" fill="#003DA5">
          H · {tripH.primary}
        </text>
        <text x={fTL.x - 50} y={(fTL.y + fBL.y) / 2 + 11} textAnchor="middle" fontSize="11" fontWeight="500" fill="#5A6B85">
          {tripH.secondary}
        </text>
      </g>

      {/* WIDTH (depth axis, along top-left edge) */}
      <line
        x1={fTL.x - 8}
        y1={fTL.y - 10}
        x2={bTL.x - 8}
        y2={bTL.y - 10}
        stroke="#FF8A33"
        strokeWidth="1.5"
        markerStart="url(#arrStart)"
        markerEnd="url(#arr)"
      />
      <text
        x={(fTL.x + bTL.x) / 2 - 30}
        y={(fTL.y + bTL.y) / 2 - 28}
        textAnchor="middle"
        fontSize="12"
        fontWeight="700"
        fill="#003DA5"
      >
        W · {tripW.primary}
      </text>
      <text
        x={(fTL.x + bTL.x) / 2 - 30}
        y={(fTL.y + bTL.y) / 2 - 16}
        textAnchor="middle"
        fontSize="10"
        fontWeight="500"
        fill="#5A6B85"
      >
        {tripW.secondary}
      </text>
    </svg>
  );
}
