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

  // CHINA — Asia hubs to LATAM
  { code: "CNSHA", country: "CN", countryName: "China",     flag: "🇨🇳", city: "Shanghai",         type: ["sea", "air"], lat: 31.2304, lon: 121.4737 },
  { code: "CNPVG", country: "CN", countryName: "China",     flag: "🇨🇳", city: "Shanghai Pudong (PVG)", type: ["air"], lat: 31.1443, lon: 121.8083 },
  { code: "CNNGB", country: "CN", countryName: "China",     flag: "🇨🇳", city: "Ningbo",           type: ["sea"], lat: 29.8683, lon: 121.5440 },
  { code: "CNSZX", country: "CN", countryName: "China",     flag: "🇨🇳", city: "Shenzhen",         type: ["sea", "air"], lat: 22.5429, lon: 114.0596 },
  { code: "CNYTN", country: "CN", countryName: "China",     flag: "🇨🇳", city: "Yantian",          type: ["sea"], lat: 22.5781, lon: 114.2697 },
  { code: "CNCAN", country: "CN", countryName: "China",     flag: "🇨🇳", city: "Guangzhou",        type: ["sea", "air"], lat: 23.1291, lon: 113.2644 },
  { code: "CNQIN", country: "CN", countryName: "China",     flag: "🇨🇳", city: "Qingdao",          type: ["sea"], lat: 36.0671, lon: 120.3826 },
  { code: "CNTXG", country: "CN", countryName: "China",     flag: "🇨🇳", city: "Tianjin (Xingang)", type: ["sea"], lat: 39.0028, lon: 117.7166 },
  { code: "CNXMG", country: "CN", countryName: "China",     flag: "🇨🇳", city: "Xiamen",           type: ["sea", "air"], lat: 24.4798, lon: 118.0894 },
  { code: "CNDLC", country: "CN", countryName: "China",     flag: "🇨🇳", city: "Dalian",           type: ["sea"], lat: 38.9140, lon: 121.6147 },
  { code: "CNFOC", country: "CN", countryName: "China",     flag: "🇨🇳", city: "Fuzhou",           type: ["sea"], lat: 26.0745, lon: 119.2965 },
  { code: "CNLYG", country: "CN", countryName: "China",     flag: "🇨🇳", city: "Lianyungang",      type: ["sea"], lat: 34.7330, lon: 119.2185 },
  { code: "CNPEK", country: "CN", countryName: "China",     flag: "🇨🇳", city: "Beijing (PEK)",    type: ["air"], lat: 40.0801, lon: 116.5846 },
  { code: "CNCTU", country: "CN", countryName: "China",     flag: "🇨🇳", city: "Chengdu",          type: ["air", "inland"], lat: 30.5728, lon: 104.0668 },
  { code: "CNHGH", country: "CN", countryName: "China",     flag: "🇨🇳", city: "Hangzhou",         type: ["air", "inland"], lat: 30.2741, lon: 120.1551 },
  { code: "CNCKG", country: "CN", countryName: "China",     flag: "🇨🇳", city: "Chongqing",        type: ["air", "inland"], lat: 29.5630, lon: 106.5516 },

  // HONG KONG SAR
  { code: "HKHKG", country: "HK", countryName: "Hong Kong", flag: "🇭🇰", city: "Hong Kong",        type: ["sea", "air"], lat: 22.3193, lon: 114.1694 },

  // SINGAPORE
  { code: "SGSIN", country: "SG", countryName: "Singapore", flag: "🇸🇬", city: "Singapore",        type: ["sea", "air"], lat: 1.3521, lon: 103.8198 },

  // SOUTH KOREA
  { code: "KRPUS", country: "KR", countryName: "South Korea", flag: "🇰🇷", city: "Busan",          type: ["sea", "air"], lat: 35.1796, lon: 129.0756 },
  { code: "KRICN", country: "KR", countryName: "South Korea", flag: "🇰🇷", city: "Incheon",        type: ["sea", "air"], lat: 37.4602, lon: 126.4407 },
  { code: "KRSEL", country: "KR", countryName: "South Korea", flag: "🇰🇷", city: "Seoul",          type: ["air"], lat: 37.5665, lon: 126.9780 },
  { code: "KRGMP", country: "KR", countryName: "South Korea", flag: "🇰🇷", city: "Gwangyang",      type: ["sea"], lat: 34.8997, lon: 127.6951 },

  // JAPAN
  { code: "JPTYO", country: "JP", countryName: "Japan",     flag: "🇯🇵", city: "Tokyo",            type: ["sea", "air"], lat: 35.6762, lon: 139.6503 },
  { code: "JPYOK", country: "JP", countryName: "Japan",     flag: "🇯🇵", city: "Yokohama",         type: ["sea"], lat: 35.4437, lon: 139.6380 },
  { code: "JPNGO", country: "JP", countryName: "Japan",     flag: "🇯🇵", city: "Nagoya",           type: ["sea", "air"], lat: 35.1815, lon: 136.9066 },
  { code: "JPOSA", country: "JP", countryName: "Japan",     flag: "🇯🇵", city: "Osaka",            type: ["sea", "air"], lat: 34.6937, lon: 135.5023 },
  { code: "JPUKB", country: "JP", countryName: "Japan",     flag: "🇯🇵", city: "Kobe",             type: ["sea"], lat: 34.6901, lon: 135.1955 },
  { code: "JPNRT", country: "JP", countryName: "Japan",     flag: "🇯🇵", city: "Narita (NRT)",     type: ["air"], lat: 35.7647, lon: 140.3863 },
  { code: "JPKIX", country: "JP", countryName: "Japan",     flag: "🇯🇵", city: "Kansai (KIX)",     type: ["air"], lat: 34.4348, lon: 135.2444 },

  // TAIWAN
  { code: "TWKHH", country: "TW", countryName: "Taiwan",    flag: "🇹🇼", city: "Kaohsiung",        type: ["sea", "air"], lat: 22.6273, lon: 120.3014 },
  { code: "TWTPE", country: "TW", countryName: "Taiwan",    flag: "🇹🇼", city: "Taipei (Taoyuan)", type: ["air"], lat: 25.0797, lon: 121.2342 },
  { code: "TWKEL", country: "TW", countryName: "Taiwan",    flag: "🇹🇼", city: "Keelung",          type: ["sea"], lat: 25.1276, lon: 121.7392 },
  { code: "TWTXG", country: "TW", countryName: "Taiwan",    flag: "🇹🇼", city: "Taichung",         type: ["sea"], lat: 24.2987, lon: 120.5247 },

  // VIETNAM
  { code: "VNSGN", country: "VN", countryName: "Vietnam",   flag: "🇻🇳", city: "Ho Chi Minh City", type: ["sea", "air"], lat: 10.7626, lon: 106.6602 },
  { code: "VNHPH", country: "VN", countryName: "Vietnam",   flag: "🇻🇳", city: "Hai Phong",        type: ["sea"], lat: 20.8449, lon: 106.6881 },
  { code: "VNHAN", country: "VN", countryName: "Vietnam",   flag: "🇻🇳", city: "Hanoi",            type: ["air"], lat: 21.0285, lon: 105.8542 },
  { code: "VNCMT", country: "VN", countryName: "Vietnam",   flag: "🇻🇳", city: "Cai Mep",          type: ["sea"], lat: 10.5316, lon: 107.0301 },

  // THAILAND
  { code: "THBKK", country: "TH", countryName: "Thailand",  flag: "🇹🇭", city: "Bangkok",          type: ["sea", "air"], lat: 13.7563, lon: 100.5018 },
  { code: "THLCH", country: "TH", countryName: "Thailand",  flag: "🇹🇭", city: "Laem Chabang",     type: ["sea"], lat: 13.0816, lon: 100.8826 },

  // MALAYSIA
  { code: "MYPKG", country: "MY", countryName: "Malaysia",  flag: "🇲🇾", city: "Port Klang",       type: ["sea"], lat: 3.0036, lon: 101.3920 },
  { code: "MYKUL", country: "MY", countryName: "Malaysia",  flag: "🇲🇾", city: "Kuala Lumpur",     type: ["air"], lat: 3.1390, lon: 101.6869 },
  { code: "MYPEN", country: "MY", countryName: "Malaysia",  flag: "🇲🇾", city: "Penang",           type: ["sea", "air"], lat: 5.4141, lon: 100.3288 },
  { code: "MYTPP", country: "MY", countryName: "Malaysia",  flag: "🇲🇾", city: "Tanjung Pelepas",  type: ["sea"], lat: 1.3650, lon: 103.5519 },

  // INDONESIA
  { code: "IDJKT", country: "ID", countryName: "Indonesia", flag: "🇮🇩", city: "Jakarta",          type: ["sea", "air"], lat: -6.2088, lon: 106.8456 },
  { code: "IDSUB", country: "ID", countryName: "Indonesia", flag: "🇮🇩", city: "Surabaya",         type: ["sea"], lat: -7.2575, lon: 112.7521 },

  // PHILIPPINES
  { code: "PHMNL", country: "PH", countryName: "Philippines", flag: "🇵🇭", city: "Manila",         type: ["sea", "air"], lat: 14.5995, lon: 120.9842 },
  { code: "PHCEB", country: "PH", countryName: "Philippines", flag: "🇵🇭", city: "Cebu",           type: ["sea", "air"], lat: 10.3157, lon: 123.8854 },

  // INDIA
  { code: "INNSA", country: "IN", countryName: "India",     flag: "🇮🇳", city: "Nhava Sheva (JNPT)", type: ["sea"], lat: 18.9489, lon: 72.9525 },
  { code: "INBOM", country: "IN", countryName: "India",     flag: "🇮🇳", city: "Mumbai",           type: ["air"], lat: 19.0760, lon: 72.8777 },
  { code: "INMAA", country: "IN", countryName: "India",     flag: "🇮🇳", city: "Chennai",          type: ["sea", "air"], lat: 13.0827, lon: 80.2707 },
  { code: "INMUN", country: "IN", countryName: "India",     flag: "🇮🇳", city: "Mundra",           type: ["sea"], lat: 22.8389, lon: 69.7232 },
  { code: "INDEL", country: "IN", countryName: "India",     flag: "🇮🇳", city: "Delhi",            type: ["air"], lat: 28.6139, lon: 77.2090 },
  { code: "INCCU", country: "IN", countryName: "India",     flag: "🇮🇳", city: "Kolkata",          type: ["sea", "air"], lat: 22.5726, lon: 88.3639 },

  // BANGLADESH / SRI LANKA / PAKISTAN
  { code: "BDCGP", country: "BD", countryName: "Bangladesh", flag: "🇧🇩", city: "Chittagong",      type: ["sea"], lat: 22.3569, lon: 91.7832 },
  { code: "LKCMB", country: "LK", countryName: "Sri Lanka", flag: "🇱🇰", city: "Colombo",          type: ["sea", "air"], lat: 6.9271, lon: 79.8612 },
  { code: "PKKHI", country: "PK", countryName: "Pakistan",  flag: "🇵🇰", city: "Karachi",          type: ["sea", "air"], lat: 24.8607, lon: 67.0011 },

  // UAE / MIDDLE EAST
  { code: "AEJEA", country: "AE", countryName: "UAE",       flag: "🇦🇪", city: "Jebel Ali",        type: ["sea"], lat: 24.9857, lon: 55.0590 },
  { code: "AEDXB", country: "AE", countryName: "UAE",       flag: "🇦🇪", city: "Dubai (DXB)",      type: ["air"], lat: 25.2532, lon: 55.3657 },
  { code: "AEAUH", country: "AE", countryName: "UAE",       flag: "🇦🇪", city: "Abu Dhabi",        type: ["sea", "air"], lat: 24.4539, lon: 54.3773 },
  { code: "SAJED", country: "SA", countryName: "Saudi Arabia", flag: "🇸🇦", city: "Jeddah",        type: ["sea", "air"], lat: 21.4858, lon: 39.1925 },
  { code: "SADMM", country: "SA", countryName: "Saudi Arabia", flag: "🇸🇦", city: "Dammam",        type: ["sea"], lat: 26.4207, lon: 50.0888 },
  { code: "QADOH", country: "QA", countryName: "Qatar",     flag: "🇶🇦", city: "Doha",             type: ["sea", "air"], lat: 25.2854, lon: 51.5310 },
  { code: "OMSLL", country: "OM", countryName: "Oman",      flag: "🇴🇲", city: "Salalah",          type: ["sea"], lat: 17.0151, lon: 54.0924 },
  { code: "IRBND", country: "IR", countryName: "Iran",      flag: "🇮🇷", city: "Bandar Abbas",     type: ["sea"], lat: 27.1865, lon: 56.2808 },

  // TURKEY
  { code: "TRIST", country: "TR", countryName: "Turkey",    flag: "🇹🇷", city: "Istanbul",         type: ["sea", "air"], lat: 41.0082, lon: 28.9784 },
  { code: "TRAMB", country: "TR", countryName: "Turkey",    flag: "🇹🇷", city: "Ambarli",          type: ["sea"], lat: 40.9665, lon: 28.6800 },
  { code: "TRMER", country: "TR", countryName: "Turkey",    flag: "🇹🇷", city: "Mersin",           type: ["sea"], lat: 36.8121, lon: 34.6415 },
  { code: "TRIZM", country: "TR", countryName: "Turkey",    flag: "🇹🇷", city: "Izmir",            type: ["sea"], lat: 38.4192, lon: 27.1287 },

  // ISRAEL / EGYPT / JORDAN
  { code: "ILHFA", country: "IL", countryName: "Israel",    flag: "🇮🇱", city: "Haifa",            type: ["sea"], lat: 32.8156, lon: 34.9892 },
  { code: "ILASH", country: "IL", countryName: "Israel",    flag: "🇮🇱", city: "Ashdod",           type: ["sea"], lat: 31.7949, lon: 34.6411 },
  { code: "EGALY", country: "EG", countryName: "Egypt",     flag: "🇪🇬", city: "Alexandria",       type: ["sea"], lat: 31.2001, lon: 29.9187 },
  { code: "EGPSD", country: "EG", countryName: "Egypt",     flag: "🇪🇬", city: "Port Said",        type: ["sea"], lat: 31.2565, lon: 32.2841 },
  { code: "EGCAI", country: "EG", countryName: "Egypt",     flag: "🇪🇬", city: "Cairo",            type: ["air"], lat: 30.0444, lon: 31.2357 },

  // NETHERLANDS / BELGIUM
  { code: "NLRTM", country: "NL", countryName: "Netherlands", flag: "🇳🇱", city: "Rotterdam",      type: ["sea"], lat: 51.9244, lon: 4.4777 },
  { code: "NLAMS", country: "NL", countryName: "Netherlands", flag: "🇳🇱", city: "Amsterdam",      type: ["sea", "air"], lat: 52.3676, lon: 4.9041 },
  { code: "BEANR", country: "BE", countryName: "Belgium",   flag: "🇧🇪", city: "Antwerp",          type: ["sea"], lat: 51.2194, lon: 4.4025 },
  { code: "BEZEE", country: "BE", countryName: "Belgium",   flag: "🇧🇪", city: "Zeebrugge",        type: ["sea"], lat: 51.3286, lon: 3.2076 },
  { code: "BEBRU", country: "BE", countryName: "Belgium",   flag: "🇧🇪", city: "Brussels",         type: ["air"], lat: 50.8503, lon: 4.3517 },

  // GERMANY
  { code: "DEHAM", country: "DE", countryName: "Germany",   flag: "🇩🇪", city: "Hamburg",          type: ["sea", "air"], lat: 53.5511, lon: 9.9937 },
  { code: "DEBRV", country: "DE", countryName: "Germany",   flag: "🇩🇪", city: "Bremerhaven",      type: ["sea"], lat: 53.5396, lon: 8.5810 },
  { code: "DEFRA", country: "DE", countryName: "Germany",   flag: "🇩🇪", city: "Frankfurt (FRA)",  type: ["air"], lat: 50.0379, lon: 8.5622 },
  { code: "DEMUC", country: "DE", countryName: "Germany",   flag: "🇩🇪", city: "Munich (MUC)",     type: ["air"], lat: 48.3538, lon: 11.7861 },

  // UK / IRELAND
  { code: "GBFXT", country: "GB", countryName: "UK",        flag: "🇬🇧", city: "Felixstowe",       type: ["sea"], lat: 51.9540, lon: 1.3506 },
  { code: "GBSOU", country: "GB", countryName: "UK",        flag: "🇬🇧", city: "Southampton",      type: ["sea"], lat: 50.9097, lon: -1.4044 },
  { code: "GBLGW", country: "GB", countryName: "UK",        flag: "🇬🇧", city: "London Gateway",   type: ["sea"], lat: 51.5117, lon: 0.4889 },
  { code: "GBLON", country: "GB", countryName: "UK",        flag: "🇬🇧", city: "London Heathrow",  type: ["air"], lat: 51.4700, lon: -0.4543 },
  { code: "IEDUB", country: "IE", countryName: "Ireland",   flag: "🇮🇪", city: "Dublin",           type: ["sea", "air"], lat: 53.3498, lon: -6.2603 },

  // FRANCE
  { code: "FRLEH", country: "FR", countryName: "France",    flag: "🇫🇷", city: "Le Havre",         type: ["sea"], lat: 49.4944, lon: 0.1079 },
  { code: "FRMRS", country: "FR", countryName: "France",    flag: "🇫🇷", city: "Marseille",        type: ["sea", "air"], lat: 43.2965, lon: 5.3698 },
  { code: "FRCDG", country: "FR", countryName: "France",    flag: "🇫🇷", city: "Paris (CDG)",      type: ["air"], lat: 49.0097, lon: 2.5479 },

  // SPAIN / PORTUGAL
  { code: "ESVLC", country: "ES", countryName: "Spain",     flag: "🇪🇸", city: "Valencia",         type: ["sea"], lat: 39.4699, lon: -0.3763 },
  { code: "ESALG", country: "ES", countryName: "Spain",     flag: "🇪🇸", city: "Algeciras",        type: ["sea"], lat: 36.1408, lon: -5.4562 },
  { code: "ESBCN", country: "ES", countryName: "Spain",     flag: "🇪🇸", city: "Barcelona",        type: ["sea", "air"], lat: 41.3851, lon: 2.1734 },
  { code: "ESMAD", country: "ES", countryName: "Spain",     flag: "🇪🇸", city: "Madrid",           type: ["air"], lat: 40.4168, lon: -3.7038 },
  { code: "ESBIO", country: "ES", countryName: "Spain",     flag: "🇪🇸", city: "Bilbao",           type: ["sea"], lat: 43.2630, lon: -2.9350 },
  { code: "PTSIE", country: "PT", countryName: "Portugal",  flag: "🇵🇹", city: "Sines",            type: ["sea"], lat: 37.9555, lon: -8.8696 },
  { code: "PTLIS", country: "PT", countryName: "Portugal",  flag: "🇵🇹", city: "Lisbon",           type: ["sea", "air"], lat: 38.7223, lon: -9.1393 },

  // ITALY / GREECE / MEDITERRANEAN
  { code: "ITGOA", country: "IT", countryName: "Italy",     flag: "🇮🇹", city: "Genoa",            type: ["sea"], lat: 44.4056, lon: 8.9463 },
  { code: "ITSPE", country: "IT", countryName: "Italy",     flag: "🇮🇹", city: "La Spezia",        type: ["sea"], lat: 44.1023, lon: 9.8243 },
  { code: "ITTRS", country: "IT", countryName: "Italy",     flag: "🇮🇹", city: "Trieste",          type: ["sea"], lat: 45.6495, lon: 13.7768 },
  { code: "ITNAP", country: "IT", countryName: "Italy",     flag: "🇮🇹", city: "Naples",           type: ["sea"], lat: 40.8518, lon: 14.2681 },
  { code: "ITMIL", country: "IT", countryName: "Italy",     flag: "🇮🇹", city: "Milan",            type: ["air"], lat: 45.4642, lon: 9.1900 },
  { code: "GRPIR", country: "GR", countryName: "Greece",    flag: "🇬🇷", city: "Piraeus",          type: ["sea"], lat: 37.9474, lon: 23.6379 },
  { code: "MTMAR", country: "MT", countryName: "Malta",     flag: "🇲🇹", city: "Marsaxlokk",       type: ["sea"], lat: 35.8333, lon: 14.5333 },
  { code: "CYLMS", country: "CY", countryName: "Cyprus",    flag: "🇨🇾", city: "Limassol",         type: ["sea"], lat: 34.6786, lon: 33.0413 },

  // NORDIC / EASTERN EUROPE
  { code: "DKCPH", country: "DK", countryName: "Denmark",   flag: "🇩🇰", city: "Copenhagen",       type: ["sea", "air"], lat: 55.6761, lon: 12.5683 },
  { code: "DKAAR", country: "DK", countryName: "Denmark",   flag: "🇩🇰", city: "Aarhus",           type: ["sea"], lat: 56.1629, lon: 10.2039 },
  { code: "SEGOT", country: "SE", countryName: "Sweden",    flag: "🇸🇪", city: "Gothenburg",       type: ["sea"], lat: 57.7089, lon: 11.9746 },
  { code: "SESTO", country: "SE", countryName: "Sweden",    flag: "🇸🇪", city: "Stockholm",        type: ["sea", "air"], lat: 59.3293, lon: 18.0686 },
  { code: "NOOSL", country: "NO", countryName: "Norway",    flag: "🇳🇴", city: "Oslo",             type: ["sea", "air"], lat: 59.9139, lon: 10.7522 },
  { code: "FIHEL", country: "FI", countryName: "Finland",   flag: "🇫🇮", city: "Helsinki",         type: ["sea", "air"], lat: 60.1699, lon: 24.9384 },
  { code: "PLGDN", country: "PL", countryName: "Poland",    flag: "🇵🇱", city: "Gdansk",           type: ["sea"], lat: 54.3520, lon: 18.6466 },
  { code: "PLGDY", country: "PL", countryName: "Poland",    flag: "🇵🇱", city: "Gdynia",           type: ["sea"], lat: 54.5189, lon: 18.5305 },
  { code: "RULED", country: "RU", countryName: "Russia",    flag: "🇷🇺", city: "St. Petersburg",   type: ["sea"], lat: 59.9311, lon: 30.3609 },
  { code: "RUVVO", country: "RU", countryName: "Russia",    flag: "🇷🇺", city: "Vladivostok",      type: ["sea"], lat: 43.1056, lon: 131.8735 },
  { code: "RUMOW", country: "RU", countryName: "Russia",    flag: "🇷🇺", city: "Moscow",           type: ["air"], lat: 55.7558, lon: 37.6173 },
  { code: "ROCND", country: "RO", countryName: "Romania",   flag: "🇷🇴", city: "Constanta",        type: ["sea"], lat: 44.1598, lon: 28.6348 },
  { code: "BGVAR", country: "BG", countryName: "Bulgaria",  flag: "🇧🇬", city: "Varna",            type: ["sea"], lat: 43.2141, lon: 27.9147 },
  { code: "SIKOP", country: "SI", countryName: "Slovenia",  flag: "🇸🇮", city: "Koper",            type: ["sea"], lat: 45.5469, lon: 13.7294 },
  { code: "HRRJK", country: "HR", countryName: "Croatia",   flag: "🇭🇷", city: "Rijeka",           type: ["sea"], lat: 45.3271, lon: 14.4422 },

  // CANADA
  { code: "CAVAN", country: "CA", countryName: "Canada",    flag: "🇨🇦", city: "Vancouver",        type: ["sea", "air"], lat: 49.2827, lon: -123.1207 },
  { code: "CAPRR", country: "CA", countryName: "Canada",    flag: "🇨🇦", city: "Prince Rupert",    type: ["sea"], lat: 54.3150, lon: -130.3209 },
  { code: "CAMTR", country: "CA", countryName: "Canada",    flag: "🇨🇦", city: "Montreal",         type: ["sea", "air"], lat: 45.5017, lon: -73.5673 },
  { code: "CATOR", country: "CA", countryName: "Canada",    flag: "🇨🇦", city: "Toronto",          type: ["air"], lat: 43.6532, lon: -79.3832 },
  { code: "CAHAL", country: "CA", countryName: "Canada",    flag: "🇨🇦", city: "Halifax",          type: ["sea"], lat: 44.6488, lon: -63.5752 },

  // MORE USA
  { code: "USOAK", country: "US", countryName: "USA",       flag: "🇺🇸", city: "Oakland",          type: ["sea"], lat: 37.8044, lon: -122.2712 },
  { code: "USSEA", country: "US", countryName: "USA",       flag: "🇺🇸", city: "Seattle / Tacoma", type: ["sea", "air"], lat: 47.6062, lon: -122.3321 },
  { code: "USBAL", country: "US", countryName: "USA",       flag: "🇺🇸", city: "Baltimore",        type: ["sea"], lat: 39.2904, lon: -76.6122 },
  { code: "USJAX", country: "US", countryName: "USA",       flag: "🇺🇸", city: "Jacksonville",     type: ["sea"], lat: 30.3322, lon: -81.6557 },
  { code: "USMSY", country: "US", countryName: "USA",       flag: "🇺🇸", city: "New Orleans",      type: ["sea"], lat: 29.9511, lon: -90.0715 },
  { code: "USTPA", country: "US", countryName: "USA",       flag: "🇺🇸", city: "Tampa",            type: ["sea", "air"], lat: 27.9506, lon: -82.4572 },
  { code: "USDFW", country: "US", countryName: "USA",       flag: "🇺🇸", city: "Dallas (DFW)",     type: ["air"], lat: 32.8998, lon: -97.0403 },
  { code: "USATL", country: "US", countryName: "USA",       flag: "🇺🇸", city: "Atlanta (ATL)",    type: ["air"], lat: 33.6407, lon: -84.4277 },

  // CARIBBEAN
  { code: "JMKIN", country: "JM", countryName: "Jamaica",   flag: "🇯🇲", city: "Kingston",         type: ["sea", "air"], lat: 17.9712, lon: -76.7920 },
  { code: "BSFPO", country: "BS", countryName: "Bahamas",   flag: "🇧🇸", city: "Freeport",         type: ["sea"], lat: 26.5333, lon: -78.6951 },
  { code: "TTPOS", country: "TT", countryName: "Trinidad y Tobago", flag: "🇹🇹", city: "Port of Spain", type: ["sea", "air"], lat: 10.6549, lon: -61.5019 },
  { code: "AWORJ", country: "AW", countryName: "Aruba",     flag: "🇦🇼", city: "Oranjestad",       type: ["sea", "air"], lat: 12.5186, lon: -70.0359 },
  { code: "CWWIL", country: "CW", countryName: "Curaçao",   flag: "🇨🇼", city: "Willemstad",       type: ["sea", "air"], lat: 12.1224, lon: -68.8819 },
  { code: "PRSJU", country: "PR", countryName: "Puerto Rico", flag: "🇵🇷", city: "San Juan",       type: ["sea", "air"], lat: 18.4655, lon: -66.1057 },

  // OCEANIA
  { code: "AUSYD", country: "AU", countryName: "Australia", flag: "🇦🇺", city: "Sydney",           type: ["sea", "air"], lat: -33.8688, lon: 151.2093 },
  { code: "AUMEL", country: "AU", countryName: "Australia", flag: "🇦🇺", city: "Melbourne",        type: ["sea", "air"], lat: -37.8136, lon: 144.9631 },
  { code: "AUBNE", country: "AU", countryName: "Australia", flag: "🇦🇺", city: "Brisbane",         type: ["sea", "air"], lat: -27.4698, lon: 153.0251 },
  { code: "AUFRE", country: "AU", countryName: "Australia", flag: "🇦🇺", city: "Fremantle / Perth", type: ["sea", "air"], lat: -32.0569, lon: 115.7439 },
  { code: "NZAKL", country: "NZ", countryName: "New Zealand", flag: "🇳🇿", city: "Auckland",       type: ["sea", "air"], lat: -36.8485, lon: 174.7633 },
  { code: "NZTAU", country: "NZ", countryName: "New Zealand", flag: "🇳🇿", city: "Tauranga",       type: ["sea"], lat: -37.6878, lon: 176.1651 },

  // AFRICA
  { code: "ZADUR", country: "ZA", countryName: "South Africa", flag: "🇿🇦", city: "Durban",        type: ["sea"], lat: -29.8587, lon: 31.0218 },
  { code: "ZACPT", country: "ZA", countryName: "South Africa", flag: "🇿🇦", city: "Cape Town",     type: ["sea", "air"], lat: -33.9249, lon: 18.4241 },
  { code: "ZAJNB", country: "ZA", countryName: "South Africa", flag: "🇿🇦", city: "Johannesburg",  type: ["air"], lat: -26.2041, lon: 28.0473 },
  { code: "NGLOS", country: "NG", countryName: "Nigeria",   flag: "🇳🇬", city: "Lagos",            type: ["sea", "air"], lat: 6.5244, lon: 3.3792 },
  { code: "KEMBA", country: "KE", countryName: "Kenya",     flag: "🇰🇪", city: "Mombasa",          type: ["sea"], lat: -4.0435, lon: 39.6682 },
  { code: "KENBO", country: "KE", countryName: "Kenya",     flag: "🇰🇪", city: "Nairobi",          type: ["air"], lat: -1.2921, lon: 36.8219 },
  { code: "MACAS", country: "MA", countryName: "Morocco",   flag: "🇲🇦", city: "Casablanca",       type: ["sea", "air"], lat: 33.5731, lon: -7.5898 },
  { code: "MATNG", country: "MA", countryName: "Morocco",   flag: "🇲🇦", city: "Tangier Med",      type: ["sea"], lat: 35.8855, lon: -5.5083 },
  { code: "TZDAR", country: "TZ", countryName: "Tanzania",  flag: "🇹🇿", city: "Dar es Salaam",    type: ["sea"], lat: -6.7924, lon: 39.2083 },
  { code: "GHTKD", country: "GH", countryName: "Ghana",     flag: "🇬🇭", city: "Tema",             type: ["sea"], lat: 5.6794, lon: 0.0166 },
  { code: "GHACC", country: "GH", countryName: "Ghana",     flag: "🇬🇭", city: "Accra",            type: ["air"], lat: 5.6037, lon: -0.1870 },
  { code: "CIABJ", country: "CI", countryName: "Ivory Coast", flag: "🇨🇮", city: "Abidjan",        type: ["sea", "air"], lat: 5.3600, lon: -4.0083 },
  { code: "AOLAD", country: "AO", countryName: "Angola",    flag: "🇦🇴", city: "Luanda",           type: ["sea", "air"], lat: -8.8390, lon: 13.2894 },
  { code: "CMDLA", country: "CM", countryName: "Cameroon",  flag: "🇨🇲", city: "Douala",           type: ["sea", "air"], lat: 4.0511, lon: 9.7679 },
  { code: "SNDKR", country: "SN", countryName: "Senegal",   flag: "🇸🇳", city: "Dakar",            type: ["sea", "air"], lat: 14.7167, lon: -17.4677 },
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
