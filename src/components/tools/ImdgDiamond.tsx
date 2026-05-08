import { ImdgClass } from "@/lib/imdg";

/**
 * Renders a stylized IMDG diamond label with the class number visible.
 * Pattern: solid (single bg), half (top/bottom split), stripes (vertical).
 *
 * NOTE: this does NOT reproduce the official IMO/UN pictographic symbols.
 * It only conveys the class color and number for educational reference.
 */
export function ImdgDiamond({
  cls,
  size = 96,
}: {
  cls: ImdgClass;
  size?: number;
}) {
  const stroke = "#000";
  const half = size / 2;
  const numberSize = size * 0.32;

  return (
    <svg
      viewBox={`0 0 ${size} ${size}`}
      width={size}
      height={size}
      xmlns="http://www.w3.org/2000/svg"
      role="img"
      aria-label={`IMDG Clase ${cls.code}: ${cls.title}`}
    >
      <defs>
        {cls.pattern === "stripes" && (
          <pattern
            id={`stripes-${cls.code}`}
            patternUnits="userSpaceOnUse"
            width="8"
            height="8"
            patternTransform="rotate(0)"
          >
            <rect width="4" height="8" fill={cls.bg2 || "#000"} />
            <rect x="4" width="4" height="8" fill={cls.bg} />
          </pattern>
        )}
        <clipPath id={`clip-${cls.code}`}>
          <polygon points={`${half},2 ${size - 2},${half} ${half},${size - 2} 2,${half}`} />
        </clipPath>
      </defs>

      {cls.pattern === "stripes" ? (
        <polygon
          points={`${half},2 ${size - 2},${half} ${half},${size - 2} 2,${half}`}
          fill={`url(#stripes-${cls.code})`}
          stroke={stroke}
          strokeWidth="2"
        />
      ) : cls.pattern === "half" ? (
        <>
          <g clipPath={`url(#clip-${cls.code})`}>
            <rect x="0" y="0" width={size} height={half} fill={cls.bg} />
            <rect x="0" y={half} width={size} height={half} fill={cls.bg2 || "#FFF"} />
          </g>
          <polygon
            points={`${half},2 ${size - 2},${half} ${half},${size - 2} 2,${half}`}
            fill="none"
            stroke={stroke}
            strokeWidth="2"
          />
        </>
      ) : (
        <polygon
          points={`${half},2 ${size - 2},${half} ${half},${size - 2} 2,${half}`}
          fill={cls.bg}
          stroke={stroke}
          strokeWidth="2"
        />
      )}

      <text
        x={half}
        y={size - size * 0.18}
        textAnchor="middle"
        fontSize={numberSize}
        fontWeight="800"
        fill={cls.fg}
        fontFamily="Inter, system-ui, sans-serif"
      >
        {cls.code}
      </text>
    </svg>
  );
}
