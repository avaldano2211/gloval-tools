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
  const bBL = { x: fBL.x + bdx, y: fBL.y - bdy };

  const corrugationCount = Math.max(8, Math.round(L * 1.8));

  // Variant geometry / styling
  const isReefer   = spec.category === "reefer";
  const isOpenTop  = spec.category === "open-top";
  const isFlatRack = spec.category === "flat-rack";
  const hasRoof    = !isOpenTop && !isFlatRack;
  const hasDoorEnd = !isFlatRack; // flat racks have collapsible end walls, no doors

  // Reefers are white aluminium; every other type is Gloval-blue steel.
  const sideFill = isReefer ? "url(#sideGradW)" : "url(#sideGrad)";
  const topFill  = isReefer ? "url(#topGradW)"  : "url(#topGrad)";
  const doorFill = isReefer ? "url(#doorGradW)" : "url(#doorGrad)";
  const edge      = isReefer ? "#8C99B0" : "#001A4D";
  const railFill  = isReefer ? "#C4CDD9" : "#01215C";
  const corrFill  = isReefer ? "#A9B5C6" : "#001740";
  const glovalFill = isReefer ? "#003DA5" : "#FFFFFF";
  const bicFill    = isReefer ? "#33415C" : "#FFFFFF";

  const tripL = triple(L);
  const tripW = triple(W);
  const tripH = triple(H);

  const railH = Math.max(4, bh * 0.06);
  const ownerCode = `GVAL ${OWNER_SERIAL[spec.id] ?? "000000 0"}  ${SIZE_TYPE_CODE[spec.id] ?? "00G1"}`;

  // Flat-rack deck (platform) geometry
  const deckH = Math.max(10, bh * 0.16);
  const dTL = { x: fTL.x, y: fBL.y - deckH };
  const dTR = { x: fTR.x, y: fBR.y - deckH };
  const dBL = { x: dTL.x + bdx, y: dTL.y - bdy };
  const dBR = { x: dTR.x + bdx, y: dTR.y - bdy };

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
        {/* Blue steel */}
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
        {/* White aluminium (reefer) */}
        <linearGradient id="topGradW" x1="0" y1="0" x2="0.4" y2="1">
          <stop offset="0%" stopColor="#FFFFFF" />
          <stop offset="100%" stopColor="#E2E8F0" />
        </linearGradient>
        <linearGradient id="sideGradW" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%"  stopColor="#FBFCFE" />
          <stop offset="100%" stopColor="#DCE3EC" />
        </linearGradient>
        <linearGradient id="doorGradW" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%"  stopColor="#EEF2F7" />
          <stop offset="100%" stopColor="#CBD4E0" />
        </linearGradient>
        <marker id="arr" viewBox="0 0 6 6" markerWidth="6" markerHeight="6" refX="3" refY="3" orient="auto">
          <path d="M 0 0 L 6 3 L 0 6 Z" fill="#FF8A33" />
        </marker>
        <marker id="arrStart" viewBox="0 0 6 6" markerWidth="6" markerHeight="6" refX="3" refY="3" orient="auto-start-reverse">
          <path d="M 0 0 L 6 3 L 0 6 Z" fill="#FF8A33" />
        </marker>
      </defs>

      <rect width={VBW} height={VBH} fill="url(#dotsBg)" rx="12" />

      {/* ===================== FLAT RACK ===================== */}
      {isFlatRack && (
        <g>
          {/* Deck: top, front and right faces */}
          <polygon
            points={`${dTL.x},${dTL.y} ${dTR.x},${dTR.y} ${dBR.x},${dBR.y} ${dBL.x},${dBL.y}`}
            fill="url(#topGrad)"
            stroke={edge}
            strokeWidth="1"
          />
          <polygon
            points={`${dTR.x},${dTR.y} ${dBR.x},${dBR.y} ${bBR.x},${bBR.y} ${fBR.x},${fBR.y}`}
            fill="url(#doorGrad)"
            stroke={edge}
            strokeWidth="1"
          />
          <rect x={dTL.x} y={dTL.y} width={bw} height={deckH} fill="url(#sideGrad)" stroke={edge} strokeWidth="1.2" />
          {/* Fork pockets on the deck beam */}
          {[0.3, 0.7].map((t, i) => (
            <rect key={`fp-${i}`} x={dTL.x + bw * t - 10} y={dTL.y + deckH * 0.4} width="20" height={deckH * 0.34} fill="#01102F" opacity="0.5" rx="1" />
          ))}

          {/* Collapsible END WALLS (the two short ends only) */}
          {[
            { tf: fTL, tb: bTL, bf: dTL, bb: dBL }, // left end
            { tf: fTR, tb: bTR, bf: dTR, bb: dBR }, // right end
          ].map((w, i) => (
            <g key={`ew-${i}`}>
              <polygon
                points={`${w.tf.x},${w.tf.y} ${w.tb.x},${w.tb.y} ${w.bb.x},${w.bb.y} ${w.bf.x},${w.bf.y}`}
                fill={i === 0 ? "url(#sideGrad)" : "url(#doorGrad)"}
                stroke={edge}
                strokeWidth="1.2"
              />
              {/* horizontal rails => reads as a collapsible frame */}
              {[0.34, 0.68].map((t, j) => (
                <line
                  key={`ewr-${i}-${j}`}
                  x1={w.tf.x + (w.bf.x - w.tf.x) * t}
                  y1={w.tf.y + (w.bf.y - w.tf.y) * t}
                  x2={w.tb.x + (w.bb.x - w.tb.x) * t}
                  y2={w.tb.y + (w.bb.y - w.tb.y) * t}
                  stroke="#01102F"
                  strokeWidth="1"
                  opacity="0.55"
                />
              ))}
            </g>
          ))}

          {/* Branding on the deck side beam */}
          <text
            x={dTL.x + bw * 0.5}
            y={dTL.y + deckH * 0.62}
            textAnchor="middle"
            fontFamily="Poppins, ui-sans-serif, system-ui, sans-serif"
            fontWeight="900"
            fontSize={Math.max(8, Math.min(deckH * 0.55, bw * 0.05))}
            fill="#FFFFFF"
            style={{ letterSpacing: "0.5px" }}
          >
            GLOVAL <tspan fill="#FF8A33" fontWeight="700">SHIPPING</tspan>
          </text>

          {/* Corner castings (deck bottom + end-wall tops) */}
          {[
            [fBL.x - 2, fBL.y - 3], [fBR.x - 3, fBR.y - 3], [bBR.x - 3, bBR.y - 3], [bBL.x - 2, bBL.y - 3],
            [fTL.x - 2, fTL.y - 2], [fTR.x - 3, fTR.y - 2], [bTL.x - 2, bTL.y - 2], [bTR.x - 3, bTR.y - 2],
          ].map(([x, y], i) => (
            <rect key={`cc-${i}`} x={x} y={y} width="5" height="5" fill="#000814" />
          ))}
        </g>
      )}

      {/* ===================== CLOSED / OPEN-TOP BOX ===================== */}
      {!isFlatRack && (
        <g>
          {/* --- TOP: solid roof --- */}
          {hasRoof && (
            <g>
              <polygon
                points={`${fTL.x},${fTL.y} ${fTR.x},${fTR.y} ${bTR.x},${bTR.y} ${bTL.x},${bTL.y}`}
                fill={topFill}
                stroke={edge}
                strokeWidth="1"
              />
              {[0.25, 0.5, 0.75].map((t, i) => (
                <line
                  key={`tr-${i}`}
                  x1={fTL.x + bdx * t}
                  y1={fTL.y - bdy * t}
                  x2={fTR.x + bdx * t}
                  y2={fTR.y - bdy * t}
                  stroke={edge}
                  strokeWidth="0.5"
                  opacity="0.35"
                />
              ))}
            </g>
          )}

          {/* --- TOP: open (no roof) — recessed cavity + rim + removable bows --- */}
          {isOpenTop && (
            <g>
              {/* dark interior so you can see "into" the open box */}
              <polygon
                points={`${fTL.x},${fTL.y} ${fTR.x},${fTR.y} ${bTR.x},${bTR.y} ${bTL.x},${bTL.y}`}
                fill="#01102F"
                stroke={edge}
                strokeWidth="1"
              />
              {/* top rail frame */}
              <polygon
                points={`${fTL.x},${fTL.y} ${fTR.x},${fTR.y} ${bTR.x},${bTR.y} ${bTL.x},${bTL.y}`}
                fill="none"
                stroke="#FF8A33"
                strokeWidth="2"
              />
              {/* removable roof bows across the opening */}
              {[0.25, 0.5, 0.75].map((t, i) => (
                <line
                  key={`bow-${i}`}
                  x1={fTL.x + bw * t}
                  y1={fTL.y}
                  x2={bTL.x + bw * t}
                  y2={bTL.y}
                  stroke="#5A6B85"
                  strokeWidth="1.4"
                  opacity="0.85"
                />
              ))}
            </g>
          )}

          {/* --- DOOR END (right face) --- */}
          {hasDoorEnd && (
            <g>
              <polygon
                points={`${fTR.x},${fTR.y} ${bTR.x},${bTR.y} ${bBR.x},${bBR.y} ${fBR.x},${fBR.y}`}
                fill={doorFill}
                stroke={edge}
                strokeWidth="1"
              />

              {/* Reefer machine panel (top ~28% of the door face) */}
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
                        fill="#9AA7BD"
                        stroke="#5A6B85"
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
                            fill="#3C4960"
                            opacity="0.85"
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
                    <line x1={splitTopX} y1={splitTopY + reeferOffset} x2={splitBotX} y2={splitBotY} stroke="#01102F" strokeWidth="1.4" />
                    {[0.25, 0.5, 0.75].map((t, i) => {
                      const yT = fTR.y + (fBR.y - fTR.y) * t + reeferOffset * (1 - t);
                      const yB = bTR.y + (bBR.y - bTR.y) * t + reeferOffset * (1 - t);
                      return (
                        <line key={`dh-${i}`} x1={fTR.x} y1={yT} x2={bTR.x} y2={yB} stroke="#01102F" strokeWidth="0.5" opacity="0.5" />
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
            </g>
          )}

          {/* --- FRONT FACE (long side with branding) --- */}
          <rect x={fTL.x} y={fTL.y} width={bw} height={bh} fill={sideFill} stroke={edge} strokeWidth="1.5" />
          {/* Top + bottom rails */}
          <rect x={fTL.x} y={fTL.y}         width={bw} height={railH} fill={railFill} opacity="0.85" />
          <rect x={fTL.x} y={fBL.y - railH} width={bw} height={railH} fill={railFill} opacity="0.85" />
          {/* Vertical corrugation lines */}
          {Array.from({ length: corrugationCount }).map((_, i) => {
            const xx = fTL.x + (bw * (i + 1)) / (corrugationCount + 1);
            return (
              <line key={`fc-${i}`} x1={xx} y1={fTL.y + railH} x2={xx} y2={fBL.y - railH} stroke={corrFill} strokeWidth="0.7" opacity="0.5" />
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
            fill={glovalFill}
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
            fill={bicFill}
            opacity="0.88"
          >
            {ownerCode}
          </text>

          {/* Corner castings */}
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
        </g>
      )}

      {/* ===================== ANNOTATIONS ===================== */}

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
