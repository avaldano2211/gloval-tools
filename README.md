# Gloval Shipping — Herramientas

Web apps gratuitas para clientes de Gloval Shipping y la comunidad logística LATAM.

🌐 **Producción:** https://gloval-tools.vercel.app/herramientas

## Herramientas disponibles

| # | Herramienta | Ruta | Tipo |
|---|---|---|---|
| 1 | Especificaciones de Contenedores | `/herramientas/contenedores` | Referencia |
| 2 | Calculadora de Cubicaje y Peso | `/herramientas/cubicaje` | Calculadora |
| 3 | Incoterms 2020 | `/herramientas/incoterms` | Referencia |
| 4 | Tabla IMO/IMDG | `/herramientas/imdg` | Referencia |
| 5 | Códigos UN/LOCODE | `/herramientas/locode` | Búsqueda |
| 6 | Rastreo de Contenedores | `/herramientas/rastreo` | Tracking (demo) |
| 7 | Centro de Documentos | `/herramientas/documentos` | Descargas |
| 8 | Glosario de Logística | `/herramientas/glosario` | Diccionario |

## Stack

- **Next.js 16** (App Router, Turbopack)
- **React 19**
- **Tailwind CSS 4** con tokens de marca custom (`gv-blue`, `gv-orange`)
- **Inter** vía `next/font/google`
- **Lucide** para iconografía
- **TypeScript** estricto

## Brand tokens

Definidos en `src/app/globals.css` bajo `@theme`:

| Token | Valor | Uso |
|---|---|---|
| `--color-gv-blue` | `#003DA5` | Azul Gloval — texto, botones primarios, H2 |
| `--color-gv-orange` | `#FF9500` | Naranja Gloval — accents, subrayado decorativo |
| `--color-gv-navy` | `#061338` | Hero / footer dark |
| `--color-gv-bg-soft` | `#F5F7FB` | Background de sección |

## Estructura

```
src/
├── app/
│   ├── herramientas/
│   │   ├── page.tsx            # Hub con 8 cards
│   │   ├── contenedores/       # Tool 1
│   │   ├── cubicaje/           # Tool 2
│   │   ├── incoterms/          # Tool 3
│   │   ├── imdg/               # Tool 4
│   │   ├── locode/             # Tool 5
│   │   ├── rastreo/            # Tool 6 (demo)
│   │   ├── documentos/         # Tool 7
│   │   └── glosario/           # Tool 8
│   ├── globals.css             # Brand tokens + Tailwind
│   └── layout.tsx
├── components/
│   ├── brand/                  # BrandHeader, BrandFooter, BrandButton, ToolCard, H2, BrandLogo
│   └── tools/                  # ContainerDiagram, ImdgDiamond, TrackingMap
├── lib/                        # Datos y lógica de negocio
│   ├── containers.ts
│   ├── cubicaje.ts
│   ├── incoterms.ts
│   ├── imdg.ts
│   ├── locode.ts
│   ├── tracking.ts
│   ├── documents.ts
│   ├── glosario.ts
│   └── utils.ts
└── public/
    ├── logo.png                # Logo brand (1510×1749 PNG)
    └── documentos/             # Documentos descargables (POA, SLI, etc.)
```

## Desarrollo local

```bash
npm install
npm run dev
# → http://localhost:3000
```

## Deploy

Auto-deploy a Vercel desde `main` via integración Git.
URL canónica de producción: `https://gloval-tools.vercel.app`.

## Diferenciadores LATAM

Cada herramienta incluye contenido específico de mercados LATAM:
- Restricciones de peso por país en carretera (EC/PE/PA/CO)
- Incoterms con errores comunes en SENAE / SUNAT / DIAN
- IMDG con regulaciones por puerto LATAM
- LOCODE con badge de oficinas Gloval (USMIA, PAPTY, ECGYE, PELIM)
- Rutas pre-cargadas Miami/Houston/Asia → puertos LATAM
- Glosario con NANDINA, NCM, NALADISA, DUA, Pedimento, ZLC, etc.

## Cómo agregar contenido

- **Glosario:** editar array `GLOSSARY` en `src/lib/glosario.ts`
- **Documentos:** ver `public/documentos/README.md`
- **LOCODE:** array `LOCODES` en `src/lib/locode.ts`
- **Tracking demo data:** objeto `MOCK` en `src/lib/tracking.ts`
- **Rutas LATAM Cubicaje:** array `LATAM_ROUTES` en `src/lib/cubicaje.ts`

## Pendientes / fase 2

- Conectar **Rastreo** a API real (searates.com / shipsgo.com / similar)
- Bilingüe ES/EN paritario (actualmente todo en ES)
- Cambiar URLs de los CTAs de `gloval-shipping.example/...` al dominio real
- Reverse-proxy `/herramientas/*` desde el dominio principal del sitio Eleva Builds
- Upload admin de documentos vía Vercel Blob (TBD)
