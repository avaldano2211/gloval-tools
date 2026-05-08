/**
 * UN/LOCODE — codes for trade and transport locations.
 * Dataset curado: ~150 puertos, aeropuertos y terminales LATAM principales.
 *
 * Estrategia (Camino B del brief): no servimos los 110.000 registros oficiales.
 * Servimos un Top LATAM curado por Gloval. Para búsquedas globales fuera de
 * LATAM redirigimos al portal oficial UNECE.
 */

export type LocodeType = "sea" | "air" | "road" | "rail" | "inland";

export interface Locode {
  code: string;        // 5-char UN/LOCODE (e.g. ECGYE)
  country: string;     // ISO 3166-1 alpha-2 (e.g. EC)
  countryName: string;
  flag: string;
  city: string;
  type: LocodeType[];
  lat: number;
  lon: number;
}

/** Oficinas físicas de Gloval Shipping. */
export const GLOVAL_OFFICES = [
  { code: "USMIA", city: "Miami",      country: "USA",     lat: 25.7617, lon: -80.1918 },
  { code: "PAPTY", city: "Panamá",     country: "Panamá",  lat:  8.9824, lon: -79.5199 },
  { code: "ECGYE", city: "Guayaquil",  country: "Ecuador", lat: -2.1894, lon: -79.8891 },
  { code: "PELIM", city: "Lima",       country: "Perú",    lat: -12.0464, lon: -77.0428 },
];

export function distanceKm(a: { lat: number; lon: number }, b: { lat: number; lon: number }): number {
  const R = 6371;
  const toRad = (d: number) => (d * Math.PI) / 180;
  const dLat = toRad(b.lat - a.lat);
  const dLon = toRad(b.lon - a.lon);
  const lat1 = toRad(a.lat);
  const lat2 = toRad(b.lat);
  const x =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(lat1) * Math.cos(lat2) * Math.sin(dLon / 2) ** 2;
  return Math.round(2 * R * Math.asin(Math.sqrt(x)));
}

/** Returns the closest Gloval office to a location with distance in km. */
export function nearestGlovalOffice(loc: { lat: number; lon: number }) {
  let best = GLOVAL_OFFICES[0];
  let bestDist = distanceKm(loc, best);
  for (let i = 1; i < GLOVAL_OFFICES.length; i++) {
    const d = distanceKm(loc, GLOVAL_OFFICES[i]);
    if (d < bestDist) {
      bestDist = d;
      best = GLOVAL_OFFICES[i];
    }
  }
  return { office: best, km: bestDist };
}

/** Returns true if this locode is a Gloval office. */
export function isGlovalOffice(code: string) {
  return GLOVAL_OFFICES.some((o) => o.code === code);
}

export const LOCODES: Locode[] = [
  // ARGENTINA
  { code: "ARBUE", country: "AR", countryName: "Argentina", flag: "🇦🇷", city: "Buenos Aires",   type: ["sea", "air"], lat: -34.6037, lon: -58.3816 },
  { code: "AREZE", country: "AR", countryName: "Argentina", flag: "🇦🇷", city: "Ezeiza (Aeropuerto Buenos Aires)", type: ["air"], lat: -34.8222, lon: -58.5358 },
  { code: "ARROS", country: "AR", countryName: "Argentina", flag: "🇦🇷", city: "Rosario",         type: ["sea", "inland"], lat: -32.9442, lon: -60.6505 },
  { code: "ARMDQ", country: "AR", countryName: "Argentina", flag: "🇦🇷", city: "Mar del Plata",   type: ["sea"], lat: -38.0023, lon: -57.5575 },
  { code: "ARUSH", country: "AR", countryName: "Argentina", flag: "🇦🇷", city: "Ushuaia",         type: ["sea", "air"], lat: -54.8019, lon: -68.3030 },

  // BOLIVIA
  { code: "BOLPB", country: "BO", countryName: "Bolivia",   flag: "🇧🇴", city: "La Paz",         type: ["air", "inland"], lat: -16.4897, lon: -68.1193 },
  { code: "BOSRZ", country: "BO", countryName: "Bolivia",   flag: "🇧🇴", city: "Santa Cruz",     type: ["air", "inland"], lat: -17.7833, lon: -63.1822 },

  // BRASIL
  { code: "BRSSZ", country: "BR", countryName: "Brasil",    flag: "🇧🇷", city: "Santos",          type: ["sea"], lat: -23.9608, lon: -46.3331 },
  { code: "BRSAO", country: "BR", countryName: "Brasil",    flag: "🇧🇷", city: "São Paulo",       type: ["air", "inland"], lat: -23.5505, lon: -46.6333 },
  { code: "BRRIO", country: "BR", countryName: "Brasil",    flag: "🇧🇷", city: "Rio de Janeiro",  type: ["sea", "air"], lat: -22.9068, lon: -43.1729 },
  { code: "BRPNG", country: "BR", countryName: "Brasil",    flag: "🇧🇷", city: "Paranaguá",       type: ["sea"], lat: -25.5163, lon: -48.5083 },
  { code: "BRITJ", country: "BR", countryName: "Brasil",    flag: "🇧🇷", city: "Itajaí",          type: ["sea"], lat: -26.9077, lon: -48.6618 },
  { code: "BRSSA", country: "BR", countryName: "Brasil",    flag: "🇧🇷", city: "Salvador",        type: ["sea", "air"], lat: -12.9777, lon: -38.5016 },
  { code: "BRREC", country: "BR", countryName: "Brasil",    flag: "🇧🇷", city: "Recife",          type: ["sea", "air"], lat: -8.0578, lon: -34.8829 },
  { code: "BRFOR", country: "BR", countryName: "Brasil",    flag: "🇧🇷", city: "Fortaleza",       type: ["sea", "air"], lat: -3.7327, lon: -38.5267 },
  { code: "BRMAO", country: "BR", countryName: "Brasil",    flag: "🇧🇷", city: "Manaus",          type: ["sea", "air"], lat: -3.1190, lon: -60.0217 },
  { code: "BRBSB", country: "BR", countryName: "Brasil",    flag: "🇧🇷", city: "Brasília",        type: ["air"], lat: -15.7942, lon: -47.8822 },
  { code: "BRSEP", country: "BR", countryName: "Brasil",    flag: "🇧🇷", city: "Suape",           type: ["sea"], lat: -8.3935, lon: -34.9624 },

  // CHILE
  { code: "CLVAP", country: "CL", countryName: "Chile",     flag: "🇨🇱", city: "Valparaíso",      type: ["sea"], lat: -33.0472, lon: -71.6127 },
  { code: "CLSAI", country: "CL", countryName: "Chile",     flag: "🇨🇱", city: "San Antonio",     type: ["sea"], lat: -33.5928, lon: -71.6068 },
  { code: "CLSCL", country: "CL", countryName: "Chile",     flag: "🇨🇱", city: "Santiago",        type: ["air"], lat: -33.4489, lon: -70.6693 },
  { code: "CLIQQ", country: "CL", countryName: "Chile",     flag: "🇨🇱", city: "Iquique",         type: ["sea", "air"], lat: -20.2208, lon: -70.1431 },
  { code: "CLARI", country: "CL", countryName: "Chile",     flag: "🇨🇱", city: "Arica",           type: ["sea"], lat: -18.4783, lon: -70.3126 },
  { code: "CLANF", country: "CL", countryName: "Chile",     flag: "🇨🇱", city: "Antofagasta",     type: ["sea"], lat: -23.6509, lon: -70.4017 },

  // COLOMBIA
  { code: "COCTG", country: "CO", countryName: "Colombia",  flag: "🇨🇴", city: "Cartagena",       type: ["sea"], lat: 10.3910, lon: -75.4794 },
  { code: "COBUN", country: "CO", countryName: "Colombia",  flag: "🇨🇴", city: "Buenaventura",    type: ["sea"], lat: 3.8801, lon: -77.0313 },
  { code: "COBAQ", country: "CO", countryName: "Colombia",  flag: "🇨🇴", city: "Barranquilla",    type: ["sea", "air"], lat: 10.9685, lon: -74.7813 },
  { code: "COSMR", country: "CO", countryName: "Colombia",  flag: "🇨🇴", city: "Santa Marta",     type: ["sea"], lat: 11.2408, lon: -74.1990 },
  { code: "COBOG", country: "CO", countryName: "Colombia",  flag: "🇨🇴", city: "Bogotá",          type: ["air", "inland"], lat: 4.7110, lon: -74.0721 },
  { code: "COMDE", country: "CO", countryName: "Colombia",  flag: "🇨🇴", city: "Medellín",        type: ["air"], lat: 6.2476, lon: -75.5658 },
  { code: "COCAL", country: "CO", countryName: "Colombia",  flag: "🇨🇴", city: "Cali",            type: ["air"], lat: 3.4516, lon: -76.5320 },

  // COSTA RICA
  { code: "CRSJO", country: "CR", countryName: "Costa Rica",flag: "🇨🇷", city: "San José",        type: ["air"], lat: 9.9281, lon: -84.0907 },
  { code: "CRLIO", country: "CR", countryName: "Costa Rica",flag: "🇨🇷", city: "Limón / Moín",    type: ["sea"], lat: 10.0017, lon: -83.0833 },
  { code: "CRPCL", country: "CR", countryName: "Costa Rica",flag: "🇨🇷", city: "Puerto Caldera",  type: ["sea"], lat: 9.9217, lon: -84.7232 },

  // CUBA
  { code: "CUHAV", country: "CU", countryName: "Cuba",      flag: "🇨🇺", city: "La Habana",       type: ["sea", "air"], lat: 23.1136, lon: -82.3666 },
  { code: "CUMRL", country: "CU", countryName: "Cuba",      flag: "🇨🇺", city: "Mariel",          type: ["sea"], lat: 22.9908, lon: -82.7547 },

  // REPÚBLICA DOMINICANA
  { code: "DOSDQ", country: "DO", countryName: "R. Dominicana", flag: "🇩🇴", city: "Santo Domingo", type: ["sea", "air"], lat: 18.4861, lon: -69.9312 },
  { code: "DOCBJ", country: "DO", countryName: "R. Dominicana", flag: "🇩🇴", city: "Caucedo",       type: ["sea"], lat: 18.4220, lon: -69.6388 },
  { code: "DOPOP", country: "DO", countryName: "R. Dominicana", flag: "🇩🇴", city: "Puerto Plata", type: ["sea", "air"], lat: 19.7903, lon: -70.6884 },

  // ECUADOR
  { code: "ECGYE", country: "EC", countryName: "Ecuador",   flag: "🇪🇨", city: "Guayaquil",       type: ["sea", "air"], lat: -2.1894, lon: -79.8891 },
  { code: "ECUIO", country: "EC", countryName: "Ecuador",   flag: "🇪🇨", city: "Quito",           type: ["air", "inland"], lat: -0.1807, lon: -78.4678 },
  { code: "ECMEC", country: "EC", countryName: "Ecuador",   flag: "🇪🇨", city: "Manta",           type: ["sea", "air"], lat: -0.9677, lon: -80.7089 },
  { code: "ECESM", country: "EC", countryName: "Ecuador",   flag: "🇪🇨", city: "Esmeraldas",      type: ["sea"], lat: 0.9682, lon: -79.6517 },
  { code: "ECPBO", country: "EC", countryName: "Ecuador",   flag: "🇪🇨", city: "Puerto Bolívar",  type: ["sea"], lat: -3.2581, lon: -79.9856 },
  { code: "ECCUE", country: "EC", countryName: "Ecuador",   flag: "🇪🇨", city: "Cuenca",          type: ["air", "inland"], lat: -2.9001, lon: -79.0059 },

  // EL SALVADOR
  { code: "SVSAL", country: "SV", countryName: "El Salvador", flag: "🇸🇻", city: "San Salvador",  type: ["air"], lat: 13.6929, lon: -89.2182 },
  { code: "SVAQJ", country: "SV", countryName: "El Salvador", flag: "🇸🇻", city: "Acajutla",      type: ["sea"], lat: 13.5736, lon: -89.8267 },

  // GUATEMALA
  { code: "GTGUA", country: "GT", countryName: "Guatemala", flag: "🇬🇹", city: "Guatemala City",  type: ["air"], lat: 14.6349, lon: -90.5069 },
  { code: "GTPBR", country: "GT", countryName: "Guatemala", flag: "🇬🇹", city: "Puerto Barrios",  type: ["sea"], lat: 15.7261, lon: -88.5942 },
  { code: "GTSTC", country: "GT", countryName: "Guatemala", flag: "🇬🇹", city: "Santo Tomás de Castilla", type: ["sea"], lat: 15.7000, lon: -88.6167 },
  { code: "GTPRQ", country: "GT", countryName: "Guatemala", flag: "🇬🇹", city: "Puerto Quetzal",  type: ["sea"], lat: 13.9275, lon: -90.7825 },

  // HAITÍ
  { code: "HTPAP", country: "HT", countryName: "Haití",     flag: "🇭🇹", city: "Port-au-Prince",  type: ["sea", "air"], lat: 18.5944, lon: -72.3074 },

  // HONDURAS
  { code: "HNTGU", country: "HN", countryName: "Honduras",  flag: "🇭🇳", city: "Tegucigalpa",     type: ["air"], lat: 14.0723, lon: -87.1921 },
  { code: "HNSAP", country: "HN", countryName: "Honduras",  flag: "🇭🇳", city: "San Pedro Sula",  type: ["air"], lat: 15.5042, lon: -88.0250 },
  { code: "HNPCR", country: "HN", countryName: "Honduras",  flag: "🇭🇳", city: "Puerto Cortés",   type: ["sea"], lat: 15.8333, lon: -87.9167 },

  // MÉXICO
  { code: "MXMEX", country: "MX", countryName: "México",    flag: "🇲🇽", city: "Ciudad de México", type: ["air", "inland"], lat: 19.4326, lon: -99.1332 },
  { code: "MXVER", country: "MX", countryName: "México",    flag: "🇲🇽", city: "Veracruz",        type: ["sea"], lat: 19.1738, lon: -96.1342 },
  { code: "MXMIT", country: "MX", countryName: "México",    flag: "🇲🇽", city: "Manzanillo",      type: ["sea"], lat: 19.0522, lon: -104.3158 },
  { code: "MXLZC", country: "MX", countryName: "México",    flag: "🇲🇽", city: "Lázaro Cárdenas", type: ["sea"], lat: 17.9389, lon: -102.1722 },
  { code: "MXATM", country: "MX", countryName: "México",    flag: "🇲🇽", city: "Altamira",        type: ["sea"], lat: 22.4400, lon: -97.9000 },
  { code: "MXTAM", country: "MX", countryName: "México",    flag: "🇲🇽", city: "Tampico",         type: ["sea"], lat: 22.2549, lon: -97.8686 },
  { code: "MXPGR", country: "MX", countryName: "México",    flag: "🇲🇽", city: "Progreso",        type: ["sea"], lat: 21.2829, lon: -89.6601 },
  { code: "MXMTY", country: "MX", countryName: "México",    flag: "🇲🇽", city: "Monterrey",       type: ["air", "inland"], lat: 25.6866, lon: -100.3161 },
  { code: "MXGDL", country: "MX", countryName: "México",    flag: "🇲🇽", city: "Guadalajara",     type: ["air"], lat: 20.6597, lon: -103.3496 },
  { code: "MXCUN", country: "MX", countryName: "México",    flag: "🇲🇽", city: "Cancún",          type: ["air", "sea"], lat: 21.1619, lon: -86.8515 },

  // NICARAGUA
  { code: "NIMGA", country: "NI", countryName: "Nicaragua", flag: "🇳🇮", city: "Managua",         type: ["air"], lat: 12.1364, lon: -86.2514 },
  { code: "NICIN", country: "NI", countryName: "Nicaragua", flag: "🇳🇮", city: "Corinto",         type: ["sea"], lat: 12.4833, lon: -87.1833 },

  // PANAMÁ
  { code: "PAPTY", country: "PA", countryName: "Panamá",    flag: "🇵🇦", city: "Panamá City",     type: ["air"], lat: 8.9824, lon: -79.5199 },
  { code: "PAONX", country: "PA", countryName: "Panamá",    flag: "🇵🇦", city: "Colón",           type: ["sea"], lat: 9.3559, lon: -79.9008 },
  { code: "PABLB", country: "PA", countryName: "Panamá",    flag: "🇵🇦", city: "Balboa",          type: ["sea"], lat: 8.9540, lon: -79.5580 },
  { code: "PAMIT", country: "PA", countryName: "Panamá",    flag: "🇵🇦", city: "Manzanillo (MIT)", type: ["sea"], lat: 9.3641, lon: -79.8961 },
  { code: "PACTB", country: "PA", countryName: "Panamá",    flag: "🇵🇦", city: "Cristóbal",       type: ["sea"], lat: 9.3500, lon: -79.9000 },
  { code: "PAZLC", country: "PA", countryName: "Panamá",    flag: "🇵🇦", city: "Zona Libre Colón", type: ["inland"], lat: 9.3500, lon: -79.9000 },
  { code: "PAVAC", country: "PA", countryName: "Panamá",    flag: "🇵🇦", city: "Vacamonte",       type: ["sea"], lat: 8.8833, lon: -79.7167 },

  // PARAGUAY
  { code: "PYASU", country: "PY", countryName: "Paraguay",  flag: "🇵🇾", city: "Asunción",        type: ["air", "inland"], lat: -25.2637, lon: -57.5759 },

  // PERÚ
  { code: "PELIM", country: "PE", countryName: "Perú",      flag: "🇵🇪", city: "Lima",            type: ["air"], lat: -12.0464, lon: -77.0428 },
  { code: "PECLL", country: "PE", countryName: "Perú",      flag: "🇵🇪", city: "Callao",          type: ["sea"], lat: -12.0552, lon: -77.1371 },
  { code: "PEPAI", country: "PE", countryName: "Perú",      flag: "🇵🇪", city: "Paita",           type: ["sea"], lat: -5.0850, lon: -81.1142 },
  { code: "PEMTL", country: "PE", countryName: "Perú",      flag: "🇵🇪", city: "Matarani",        type: ["sea"], lat: -16.9970, lon: -72.1078 },
  { code: "PEPCH", country: "PE", countryName: "Perú",      flag: "🇵🇪", city: "Pisco",           type: ["sea"], lat: -13.7100, lon: -76.2200 },
  { code: "PESLP", country: "PE", countryName: "Perú",      flag: "🇵🇪", city: "Salaverry",       type: ["sea"], lat: -8.2261, lon: -78.9858 },
  { code: "PEILQ", country: "PE", countryName: "Perú",      flag: "🇵🇪", city: "Ilo",             type: ["sea"], lat: -17.6394, lon: -71.3389 },
  { code: "PECUZ", country: "PE", countryName: "Perú",      flag: "🇵🇪", city: "Cusco",           type: ["air"], lat: -13.5320, lon: -71.9675 },

  // URUGUAY
  { code: "UYMVD", country: "UY", countryName: "Uruguay",   flag: "🇺🇾", city: "Montevideo",      type: ["sea", "air"], lat: -34.9011, lon: -56.1645 },
  { code: "UYNVA", country: "UY", countryName: "Uruguay",   flag: "🇺🇾", city: "Nueva Palmira",   type: ["sea", "inland"], lat: -33.8744, lon: -58.4097 },

  // VENEZUELA
  { code: "VECCS", country: "VE", countryName: "Venezuela", flag: "🇻🇪", city: "Caracas",         type: ["air"], lat: 10.4806, lon: -66.9036 },
  { code: "VELAG", country: "VE", countryName: "Venezuela", flag: "🇻🇪", city: "La Guaira",       type: ["sea"], lat: 10.6017, lon: -66.9347 },
  { code: "VEPCB", country: "VE", countryName: "Venezuela", flag: "🇻🇪", city: "Puerto Cabello",  type: ["sea"], lat: 10.4806, lon: -68.0119 },
  { code: "VEMAR", country: "VE", countryName: "Venezuela", flag: "🇻🇪", city: "Maracaibo",       type: ["sea", "air"], lat: 10.6427, lon: -71.6125 },

  // USA — gateway hubs to LATAM
  { code: "USMIA", country: "US", countryName: "USA",       flag: "🇺🇸", city: "Miami",           type: ["sea", "air"], lat: 25.7617, lon: -80.1918 },
  { code: "USHOU", country: "US", countryName: "USA",       flag: "🇺🇸", city: "Houston",         type: ["sea", "air"], lat: 29.7604, lon: -95.3698 },
  { code: "USLAX", country: "US", countryName: "USA",       flag: "🇺🇸", city: "Los Angeles",     type: ["sea", "air"], lat: 33.7405, lon: -118.2767 },
  { code: "USLGB", country: "US", countryName: "USA",       flag: "🇺🇸", city: "Long Beach",      type: ["sea"], lat: 33.7547, lon: -118.2107 },
  { code: "USJFK", country: "US", countryName: "USA",       flag: "🇺🇸", city: "New York (JFK)",  type: ["air"], lat: 40.6413, lon: -73.7781 },
  { code: "USNYC", country: "US", countryName: "USA",       flag: "🇺🇸", city: "New York / NJ",   type: ["sea"], lat: 40.6839, lon: -74.0294 },
  { code: "USORF", country: "US", countryName: "USA",       flag: "🇺🇸", city: "Norfolk",         type: ["sea"], lat: 36.8508, lon: -76.2859 },
  { code: "USCHS", country: "US", countryName: "USA",       flag: "🇺🇸", city: "Charleston",      type: ["sea"], lat: 32.7765, lon: -79.9311 },
  { code: "USSAV", country: "US", countryName: "USA",       flag: "🇺🇸", city: "Savannah",        type: ["sea"], lat: 32.0809, lon: -81.0912 },
  { code: "USORD", country: "US", countryName: "USA",       flag: "🇺🇸", city: "Chicago (ORD)",   type: ["air"], lat: 41.9742, lon: -87.9073 },
];

export const TYPE_LABEL: Record<LocodeType, string> = {
  sea: "Marítimo",
  air: "Aéreo",
  road: "Terrestre",
  rail: "Ferroviario",
  inland: "Interior",
};

export function searchLocodes(q: string, dataset: Locode[] = LOCODES): Locode[] {
  const query = q.trim().toLowerCase();
  if (!query) return dataset;
  return dataset.filter(
    (l) =>
      l.code.toLowerCase().includes(query) ||
      l.city.toLowerCase().includes(query) ||
      l.countryName.toLowerCase().includes(query) ||
      l.country.toLowerCase().includes(query),
  );
}
