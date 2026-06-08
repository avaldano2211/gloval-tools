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

  // ===== SECONDARY LATAM =====
  // MÉXICO secondary (border + inland + secondary ports)
  { code: "MXTIJ", country: "MX", countryName: "México",    flag: "🇲🇽", city: "Tijuana",          type: ["air", "road"], lat: 32.5149, lon: -117.0382 },
  { code: "MXMXL", country: "MX", countryName: "México",    flag: "🇲🇽", city: "Mexicali",         type: ["road", "air"], lat: 32.6245, lon: -115.4523 },
  { code: "MXHMO", country: "MX", countryName: "México",    flag: "🇲🇽", city: "Hermosillo",       type: ["air", "inland"], lat: 29.0729, lon: -110.9559 },
  { code: "MXCJS", country: "MX", countryName: "México",    flag: "🇲🇽", city: "Ciudad Juárez",    type: ["road", "air"], lat: 31.6904, lon: -106.4245 },
  { code: "MXNLD", country: "MX", countryName: "México",    flag: "🇲🇽", city: "Nuevo Laredo",     type: ["road"], lat: 27.4901, lon: -99.5070 },
  { code: "MXRYN", country: "MX", countryName: "México",    flag: "🇲🇽", city: "Reynosa",          type: ["road", "air"], lat: 26.0922, lon: -98.2782 },
  { code: "MXMTM", country: "MX", countryName: "México",    flag: "🇲🇽", city: "Matamoros",        type: ["road"], lat: 25.8690, lon: -97.5026 },
  { code: "MXSLP", country: "MX", countryName: "México",    flag: "🇲🇽", city: "San Luis Potosí",  type: ["air", "inland"], lat: 22.1565, lon: -100.9855 },
  { code: "MXAGU", country: "MX", countryName: "México",    flag: "🇲🇽", city: "Aguascalientes",   type: ["air", "inland"], lat: 21.8853, lon: -102.2916 },
  { code: "MXBJX", country: "MX", countryName: "México",    flag: "🇲🇽", city: "León / Bajío (BJX)", type: ["air"], lat: 21.1230, lon: -101.6772 },
  { code: "MXQRO", country: "MX", countryName: "México",    flag: "🇲🇽", city: "Querétaro",        type: ["air", "inland"], lat: 20.5888, lon: -100.3899 },
  { code: "MXTLC", country: "MX", countryName: "México",    flag: "🇲🇽", city: "Toluca",           type: ["air", "inland"], lat: 19.2826, lon: -99.6557 },
  { code: "MXNLU", country: "MX", countryName: "México",    flag: "🇲🇽", city: "Felipe Ángeles (AIFA)", type: ["air"], lat: 19.7411, lon: -99.0186 },
  { code: "MXPUE", country: "MX", countryName: "México",    flag: "🇲🇽", city: "Puebla",           type: ["air", "inland"], lat: 19.0414, lon: -98.2063 },
  { code: "MXMID", country: "MX", countryName: "México",    flag: "🇲🇽", city: "Mérida",           type: ["air"], lat: 20.9674, lon: -89.5926 },
  { code: "MXOAX", country: "MX", countryName: "México",    flag: "🇲🇽", city: "Oaxaca",           type: ["air"], lat: 17.0732, lon: -96.7266 },
  { code: "MXENS", country: "MX", countryName: "México",    flag: "🇲🇽", city: "Ensenada",         type: ["sea"], lat: 31.8667, lon: -116.5963 },
  { code: "MXLAP", country: "MX", countryName: "México",    flag: "🇲🇽", city: "La Paz (BCS)",     type: ["sea", "air"], lat: 24.1426, lon: -110.3128 },
  { code: "MXACA", country: "MX", countryName: "México",    flag: "🇲🇽", city: "Acapulco",         type: ["sea", "air"], lat: 16.8530, lon: -99.8237 },
  { code: "MXPVR", country: "MX", countryName: "México",    flag: "🇲🇽", city: "Puerto Vallarta",  type: ["sea", "air"], lat: 20.6534, lon: -105.2253 },
  { code: "MXSJD", country: "MX", countryName: "México",    flag: "🇲🇽", city: "Los Cabos",        type: ["air"], lat: 23.0524, lon: -109.7212 },

  // BRASIL secondary
  { code: "BRVIX", country: "BR", countryName: "Brasil",    flag: "🇧🇷", city: "Vitória",          type: ["sea", "air"], lat: -20.3155, lon: -40.3128 },
  { code: "BRCNF", country: "BR", countryName: "Brasil",    flag: "🇧🇷", city: "Belo Horizonte",   type: ["air"], lat: -19.6244, lon: -43.9719 },
  { code: "BRPOA", country: "BR", countryName: "Brasil",    flag: "🇧🇷", city: "Porto Alegre",     type: ["sea", "air"], lat: -30.0346, lon: -51.2177 },
  { code: "BRCWB", country: "BR", countryName: "Brasil",    flag: "🇧🇷", city: "Curitiba",         type: ["air"], lat: -25.4284, lon: -49.2733 },
  { code: "BRRIG", country: "BR", countryName: "Brasil",    flag: "🇧🇷", city: "Rio Grande",       type: ["sea"], lat: -32.0353, lon: -52.0986 },
  { code: "BRITQ", country: "BR", countryName: "Brasil",    flag: "🇧🇷", city: "Itaqui (São Luís)", type: ["sea"], lat: -2.5847, lon: -44.3675 },
  { code: "BRSFS", country: "BR", countryName: "Brasil",    flag: "🇧🇷", city: "São Francisco do Sul", type: ["sea"], lat: -26.2433, lon: -48.6376 },
  { code: "BRPNE", country: "BR", countryName: "Brasil",    flag: "🇧🇷", city: "Pecém",            type: ["sea"], lat: -3.5478, lon: -38.8047 },
  { code: "BRIBB", country: "BR", countryName: "Brasil",    flag: "🇧🇷", city: "Imbituba",         type: ["sea"], lat: -28.2406, lon: -48.6711 },
  { code: "BRBEL", country: "BR", countryName: "Brasil",    flag: "🇧🇷", city: "Belém",            type: ["sea", "air"], lat: -1.4558, lon: -48.4902 },
  { code: "BRMCZ", country: "BR", countryName: "Brasil",    flag: "🇧🇷", city: "Maceió",           type: ["sea", "air"], lat: -9.6498, lon: -35.7089 },
  { code: "BRJPA", country: "BR", countryName: "Brasil",    flag: "🇧🇷", city: "João Pessoa",      type: ["air"], lat: -7.1195, lon: -34.8450 },
  { code: "BRNAT", country: "BR", countryName: "Brasil",    flag: "🇧🇷", city: "Natal",            type: ["sea", "air"], lat: -5.7945, lon: -35.2110 },
  { code: "BRGYN", country: "BR", countryName: "Brasil",    flag: "🇧🇷", city: "Goiânia",          type: ["air"], lat: -16.6869, lon: -49.2648 },
  { code: "BRCGB", country: "BR", countryName: "Brasil",    flag: "🇧🇷", city: "Cuiabá",           type: ["air"], lat: -15.6014, lon: -56.0979 },

  // ARGENTINA secondary
  { code: "ARBHI", country: "AR", countryName: "Argentina", flag: "🇦🇷", city: "Bahía Blanca",     type: ["sea", "air"], lat: -38.7196, lon: -62.2724 },
  { code: "ARCOR", country: "AR", countryName: "Argentina", flag: "🇦🇷", city: "Córdoba",          type: ["air"], lat: -31.4201, lon: -64.1888 },
  { code: "ARMDZ", country: "AR", countryName: "Argentina", flag: "🇦🇷", city: "Mendoza",          type: ["air"], lat: -32.8895, lon: -68.8458 },
  { code: "ARZAE", country: "AR", countryName: "Argentina", flag: "🇦🇷", city: "Zárate",           type: ["sea", "inland"], lat: -34.0833, lon: -59.0167 },
  { code: "ARSLO", country: "AR", countryName: "Argentina", flag: "🇦🇷", city: "San Lorenzo",      type: ["sea", "inland"], lat: -32.7558, lon: -60.7355 },
  { code: "ARSLA", country: "AR", countryName: "Argentina", flag: "🇦🇷", city: "Salta",            type: ["air"], lat: -24.7821, lon: -65.4232 },
  { code: "ARTUC", country: "AR", countryName: "Argentina", flag: "🇦🇷", city: "Tucumán",          type: ["air"], lat: -26.8083, lon: -65.2176 },
  { code: "ARCRD", country: "AR", countryName: "Argentina", flag: "🇦🇷", city: "Comodoro Rivadavia", type: ["sea", "air"], lat: -45.8636, lon: -67.4761 },
  { code: "ARLPG", country: "AR", countryName: "Argentina", flag: "🇦🇷", city: "La Plata",         type: ["sea"], lat: -34.9215, lon: -57.9545 },
  { code: "ARIGR", country: "AR", countryName: "Argentina", flag: "🇦🇷", city: "Iguazú",           type: ["air"], lat: -25.7370, lon: -54.4690 },

  // CHILE secondary
  { code: "CLCNL", country: "CL", countryName: "Chile",     flag: "🇨🇱", city: "Coronel",          type: ["sea"], lat: -37.0277, lon: -73.1333 },
  { code: "CLLIR", country: "CL", countryName: "Chile",     flag: "🇨🇱", city: "Lirquén",          type: ["sea"], lat: -36.7102, lon: -72.9881 },
  { code: "CLPMC", country: "CL", countryName: "Chile",     flag: "🇨🇱", city: "Puerto Montt",     type: ["sea", "air"], lat: -41.4717, lon: -72.9362 },
  { code: "CLPUQ", country: "CL", countryName: "Chile",     flag: "🇨🇱", city: "Punta Arenas",     type: ["sea", "air"], lat: -53.1638, lon: -70.9171 },
  { code: "CLCCP", country: "CL", countryName: "Chile",     flag: "🇨🇱", city: "Concepción",       type: ["air"], lat: -36.7726, lon: -73.1098 },
  { code: "CLLSC", country: "CL", countryName: "Chile",     flag: "🇨🇱", city: "La Serena",        type: ["air"], lat: -29.9027, lon: -71.2519 },

  // COLOMBIA secondary
  { code: "COTRB", country: "CO", countryName: "Colombia",  flag: "🇨🇴", city: "Turbo",            type: ["sea"], lat: 8.0938, lon: -76.7286 },
  { code: "COTCO", country: "CO", countryName: "Colombia",  flag: "🇨🇴", city: "Tumaco",           type: ["sea"], lat: 1.7894, lon: -78.7831 },
  { code: "COPBO", country: "CO", countryName: "Colombia",  flag: "🇨🇴", city: "Puerto Bolívar",   type: ["sea"], lat: 12.2235, lon: -71.9870 },
  { code: "COBGA", country: "CO", countryName: "Colombia",  flag: "🇨🇴", city: "Bucaramanga",      type: ["air"], lat: 7.1193, lon: -73.1227 },
  { code: "COPEI", country: "CO", countryName: "Colombia",  flag: "🇨🇴", city: "Pereira",          type: ["air"], lat: 4.8133, lon: -75.6961 },
  { code: "COCUC", country: "CO", countryName: "Colombia",  flag: "🇨🇴", city: "Cúcuta",           type: ["air", "road"], lat: 7.8939, lon: -72.5078 },

  // PERÚ secondary
  { code: "PECIX", country: "PE", countryName: "Perú",      flag: "🇵🇪", city: "Chiclayo",         type: ["air"], lat: -6.7710, lon: -79.8281 },
  { code: "PETRU", country: "PE", countryName: "Perú",      flag: "🇵🇪", city: "Trujillo",         type: ["air"], lat: -8.1090, lon: -79.0215 },
  { code: "PEAQP", country: "PE", countryName: "Perú",      flag: "🇵🇪", city: "Arequipa",         type: ["air"], lat: -16.4090, lon: -71.5375 },
  { code: "PEIQT", country: "PE", countryName: "Perú",      flag: "🇵🇪", city: "Iquitos",          type: ["air", "inland"], lat: -3.7491, lon: -73.2538 },
  { code: "PEPCL", country: "PE", countryName: "Perú",      flag: "🇵🇪", city: "Pucallpa",         type: ["air", "inland"], lat: -8.3791, lon: -74.5539 },
  { code: "PETCQ", country: "PE", countryName: "Perú",      flag: "🇵🇪", city: "Tacna",            type: ["air", "road"], lat: -18.0066, lon: -70.2484 },
  { code: "PECHM", country: "PE", countryName: "Perú",      flag: "🇵🇪", city: "Chimbote",         type: ["sea"], lat: -9.0853, lon: -78.5783 },
  { code: "PEBYV", country: "PE", countryName: "Perú",      flag: "🇵🇪", city: "Bayóvar",          type: ["sea"], lat: -5.8336, lon: -81.0335 },

  // ECUADOR secondary
  { code: "ECLOH", country: "EC", countryName: "Ecuador",   flag: "🇪🇨", city: "Loja",             type: ["air", "inland"], lat: -3.9931, lon: -79.2042 },
  { code: "ECGPS", country: "EC", countryName: "Ecuador",   flag: "🇪🇨", city: "Galápagos (Baltra)", type: ["air"], lat: -0.4544, lon: -90.2658 },
  { code: "ECLTX", country: "EC", countryName: "Ecuador",   flag: "🇪🇨", city: "Latacunga",        type: ["air", "inland"], lat: -0.9314, lon: -78.6157 },
  { code: "ECSNC", country: "EC", countryName: "Ecuador",   flag: "🇪🇨", city: "Salinas",          type: ["air", "sea"], lat: -2.2058, lon: -80.9870 },
  { code: "ECTUL", country: "EC", countryName: "Ecuador",   flag: "🇪🇨", city: "Tulcán",           type: ["road"], lat: 0.8081, lon: -77.7195 },

  // VENEZUELA secondary
  { code: "VEMUN", country: "VE", countryName: "Venezuela", flag: "🇻🇪", city: "Maturín",          type: ["air"], lat: 9.7494, lon: -63.1834 },
  { code: "VEPZO", country: "VE", countryName: "Venezuela", flag: "🇻🇪", city: "Puerto Ordaz",     type: ["sea", "air", "inland"], lat: 8.3225, lon: -62.7202 },
  { code: "VEPFI", country: "VE", countryName: "Venezuela", flag: "🇻🇪", city: "Punto Fijo",       type: ["sea"], lat: 11.6927, lon: -70.2137 },
  { code: "VEPMV", country: "VE", countryName: "Venezuela", flag: "🇻🇪", city: "Margarita (Porlamar)", type: ["air"], lat: 10.9128, lon: -63.9665 },

  // BOLIVIA secondary
  { code: "BOCBB", country: "BO", countryName: "Bolivia",   flag: "🇧🇴", city: "Cochabamba",       type: ["air", "inland"], lat: -17.3895, lon: -66.1568 },
  { code: "BOSRE", country: "BO", countryName: "Bolivia",   flag: "🇧🇴", city: "Sucre",            type: ["air"], lat: -19.0421, lon: -65.2598 },
  { code: "BOORU", country: "BO", countryName: "Bolivia",   flag: "🇧🇴", city: "Oruro",            type: ["air", "inland"], lat: -17.9833, lon: -67.1500 },
  { code: "BOTJA", country: "BO", countryName: "Bolivia",   flag: "🇧🇴", city: "Tarija",           type: ["air"], lat: -21.5350, lon: -64.7295 },

  // PARAGUAY secondary
  { code: "PYAGT", country: "PY", countryName: "Paraguay",  flag: "🇵🇾", city: "Ciudad del Este",  type: ["air", "road"], lat: -25.5095, lon: -54.6111 },
  { code: "PYVLT", country: "PY", countryName: "Paraguay",  flag: "🇵🇾", city: "Villeta",          type: ["sea", "inland"], lat: -25.5103, lon: -57.5494 },
  { code: "PYENC", country: "PY", countryName: "Paraguay",  flag: "🇵🇾", city: "Encarnación",      type: ["road"], lat: -27.3290, lon: -55.8662 },

  // URUGUAY secondary
  { code: "UYPDP", country: "UY", countryName: "Uruguay",   flag: "🇺🇾", city: "Punta del Este",   type: ["air"], lat: -34.9636, lon: -54.9521 },
  { code: "UYCYR", country: "UY", countryName: "Uruguay",   flag: "🇺🇾", city: "Colonia",          type: ["sea"], lat: -34.4626, lon: -57.8400 },
  { code: "UYPSO", country: "UY", countryName: "Uruguay",   flag: "🇺🇾", city: "Paysandú",         type: ["inland"], lat: -32.3211, lon: -58.0756 },

  // CENTRAL AMERICA / CARIBBEAN secondary + new countries
  { code: "CRLIR", country: "CR", countryName: "Costa Rica", flag: "🇨🇷", city: "Liberia",         type: ["air"], lat: 10.5933, lon: -85.5444 },
  { code: "PADAV", country: "PA", countryName: "Panamá",    flag: "🇵🇦", city: "David",            type: ["air", "road"], lat: 8.4333, lon: -82.4333 },
  { code: "PABOC", country: "PA", countryName: "Panamá",    flag: "🇵🇦", city: "Bocas del Toro",   type: ["air"], lat: 9.3408, lon: -82.2417 },
  { code: "CUSCU", country: "CU", countryName: "Cuba",      flag: "🇨🇺", city: "Santiago de Cuba", type: ["sea", "air"], lat: 20.0247, lon: -75.8217 },
  { code: "DOSPM", country: "DO", countryName: "R. Dominicana", flag: "🇩🇴", city: "San Pedro de Macorís", type: ["sea"], lat: 18.4540, lon: -69.3030 },
  { code: "DOLRM", country: "DO", countryName: "R. Dominicana", flag: "🇩🇴", city: "La Romana",   type: ["sea", "air"], lat: 18.4500, lon: -68.9667 },
  { code: "HTCAP", country: "HT", countryName: "Haití",     flag: "🇭🇹", city: "Cap-Haïtien",      type: ["sea", "air"], lat: 19.7589, lon: -72.2017 },
  { code: "BZBZE", country: "BZ", countryName: "Belize",    flag: "🇧🇿", city: "Belize City",      type: ["sea", "air"], lat: 17.5046, lon: -88.1962 },
  { code: "GYGEO", country: "GY", countryName: "Guyana",    flag: "🇬🇾", city: "Georgetown",       type: ["sea", "air"], lat: 6.8013, lon: -58.1551 },
  { code: "SRPBM", country: "SR", countryName: "Suriname",  flag: "🇸🇷", city: "Paramaribo",       type: ["sea", "air"], lat: 5.8520, lon: -55.2038 },
  { code: "GFCAY", country: "GF", countryName: "Guayana Francesa", flag: "🇬🇫", city: "Cayenne",  type: ["sea", "air"], lat: 4.9333, lon: -52.3333 },
  { code: "BBBGI", country: "BB", countryName: "Barbados",  flag: "🇧🇧", city: "Bridgetown",       type: ["sea", "air"], lat: 13.0747, lon: -59.4956 },

  // ===== USA / CANADA secondary =====
  { code: "USBOS", country: "US", countryName: "USA",       flag: "🇺🇸", city: "Boston",           type: ["sea", "air"], lat: 42.3601, lon: -71.0589 },
  { code: "USPHL", country: "US", countryName: "USA",       flag: "🇺🇸", city: "Philadelphia",     type: ["sea", "air"], lat: 39.9526, lon: -75.1652 },
  { code: "USMOB", country: "US", countryName: "USA",       flag: "🇺🇸", city: "Mobile",           type: ["sea"], lat: 30.6954, lon: -88.0399 },
  { code: "USILM", country: "US", countryName: "USA",       flag: "🇺🇸", city: "Wilmington (NC)",  type: ["sea"], lat: 34.2257, lon: -77.9447 },
  { code: "USPHX", country: "US", countryName: "USA",       flag: "🇺🇸", city: "Phoenix",          type: ["air"], lat: 33.4484, lon: -112.0740 },
  { code: "USDEN", country: "US", countryName: "USA",       flag: "🇺🇸", city: "Denver",           type: ["air"], lat: 39.7392, lon: -104.9903 },
  { code: "USDTW", country: "US", countryName: "USA",       flag: "🇺🇸", city: "Detroit",          type: ["air"], lat: 42.3314, lon: -83.0458 },
  { code: "USMSP", country: "US", countryName: "USA",       flag: "🇺🇸", city: "Minneapolis",      type: ["air"], lat: 44.9778, lon: -93.2650 },
  { code: "USSLC", country: "US", countryName: "USA",       flag: "🇺🇸", city: "Salt Lake City",   type: ["air"], lat: 40.7608, lon: -111.8910 },
  { code: "USSAT", country: "US", countryName: "USA",       flag: "🇺🇸", city: "San Antonio",      type: ["air"], lat: 29.4241, lon: -98.4936 },
  { code: "USIND", country: "US", countryName: "USA",       flag: "🇺🇸", city: "Indianapolis",     type: ["air"], lat: 39.7684, lon: -86.1581 },
  { code: "USSTL", country: "US", countryName: "USA",       flag: "🇺🇸", city: "St. Louis",        type: ["air", "inland"], lat: 38.6270, lon: -90.1994 },
  { code: "USMEM", country: "US", countryName: "USA",       flag: "🇺🇸", city: "Memphis (FedEx)",  type: ["air"], lat: 35.1495, lon: -90.0490 },
  { code: "USSDF", country: "US", countryName: "USA",       flag: "🇺🇸", city: "Louisville (UPS)", type: ["air"], lat: 38.2527, lon: -85.7585 },
  { code: "USANC", country: "US", countryName: "USA",       flag: "🇺🇸", city: "Anchorage (cargo)", type: ["air"], lat: 61.2181, lon: -149.9003 },
  { code: "USPDX", country: "US", countryName: "USA",       flag: "🇺🇸", city: "Portland",         type: ["sea", "air"], lat: 45.5152, lon: -122.6784 },
  { code: "USCLE", country: "US", countryName: "USA",       flag: "🇺🇸", city: "Cleveland",        type: ["sea", "air"], lat: 41.4993, lon: -81.6944 },
  { code: "USCVG", country: "US", countryName: "USA",       flag: "🇺🇸", city: "Cincinnati (CVG)", type: ["air"], lat: 39.0488, lon: -84.6678 },
  { code: "CAYYC", country: "CA", countryName: "Canada",    flag: "🇨🇦", city: "Calgary",          type: ["air"], lat: 51.0447, lon: -114.0719 },
  { code: "CAYEG", country: "CA", countryName: "Canada",    flag: "🇨🇦", city: "Edmonton",         type: ["air"], lat: 53.5461, lon: -113.4938 },
  { code: "CAQUE", country: "CA", countryName: "Canada",    flag: "🇨🇦", city: "Quebec City",      type: ["sea", "air"], lat: 46.8139, lon: -71.2080 },
  { code: "CASJB", country: "CA", countryName: "Canada",    flag: "🇨🇦", city: "Saint John",       type: ["sea"], lat: 45.2733, lon: -66.0633 },
  { code: "CAHAM", country: "CA", countryName: "Canada",    flag: "🇨🇦", city: "Hamilton",         type: ["sea", "inland"], lat: 43.2557, lon: -79.8711 },
  { code: "CAWNP", country: "CA", countryName: "Canada",    flag: "🇨🇦", city: "Winnipeg",         type: ["air", "inland"], lat: 49.8951, lon: -97.1384 },

  // ===== EUROPE secondary =====
  // Germany
  { code: "DEBER", country: "DE", countryName: "Germany",   flag: "🇩🇪", city: "Berlin",           type: ["air"], lat: 52.5200, lon: 13.4050 },
  { code: "DEDUS", country: "DE", countryName: "Germany",   flag: "🇩🇪", city: "Düsseldorf",       type: ["air"], lat: 51.2277, lon: 6.7735 },
  { code: "DECGN", country: "DE", countryName: "Germany",   flag: "🇩🇪", city: "Cologne",          type: ["air", "inland"], lat: 50.9375, lon: 6.9603 },
  { code: "DESTR", country: "DE", countryName: "Germany",   flag: "🇩🇪", city: "Stuttgart",        type: ["air"], lat: 48.7758, lon: 9.1829 },
  { code: "DEWVN", country: "DE", countryName: "Germany",   flag: "🇩🇪", city: "Wilhelmshaven",    type: ["sea"], lat: 53.5238, lon: 8.1056 },
  { code: "DELBC", country: "DE", countryName: "Germany",   flag: "🇩🇪", city: "Lübeck",           type: ["sea"], lat: 53.8654, lon: 10.6866 },
  // Spain
  { code: "ESVGO", country: "ES", countryName: "Spain",     flag: "🇪🇸", city: "Vigo",             type: ["sea"], lat: 42.2406, lon: -8.7207 },
  { code: "ESLPA", country: "ES", countryName: "Spain",     flag: "🇪🇸", city: "Las Palmas",       type: ["sea", "air"], lat: 28.1235, lon: -15.4363 },
  { code: "ESTGN", country: "ES", countryName: "Spain",     flag: "🇪🇸", city: "Tarragona",        type: ["sea"], lat: 41.1189, lon: 1.2445 },
  { code: "ESSVQ", country: "ES", countryName: "Spain",     flag: "🇪🇸", city: "Sevilla",          type: ["sea", "air", "inland"], lat: 37.3891, lon: -5.9845 },
  { code: "ESCAS", country: "ES", countryName: "Spain",     flag: "🇪🇸", city: "Castellón",        type: ["sea"], lat: 39.9864, lon: -0.0513 },
  // UK / Ireland
  { code: "GBLIV", country: "GB", countryName: "UK",        flag: "🇬🇧", city: "Liverpool",        type: ["sea"], lat: 53.4084, lon: -2.9916 },
  { code: "GBHUL", country: "GB", countryName: "UK",        flag: "🇬🇧", city: "Hull",             type: ["sea"], lat: 53.7676, lon: -0.3274 },
  { code: "GBTIL", country: "GB", countryName: "UK",        flag: "🇬🇧", city: "Tilbury",          type: ["sea"], lat: 51.4630, lon: 0.3589 },
  { code: "GBBRS", country: "GB", countryName: "UK",        flag: "🇬🇧", city: "Bristol",          type: ["sea", "air"], lat: 51.4545, lon: -2.5879 },
  { code: "GBABZ", country: "GB", countryName: "UK",        flag: "🇬🇧", city: "Aberdeen",         type: ["sea"], lat: 57.1497, lon: -2.0943 },
  { code: "IECRK", country: "IE", countryName: "Ireland",   flag: "🇮🇪", city: "Cork",             type: ["sea", "air"], lat: 51.8985, lon: -8.4756 },
  // France
  { code: "FRBOD", country: "FR", countryName: "France",    flag: "🇫🇷", city: "Bordeaux",         type: ["sea", "air"], lat: 44.8378, lon: -0.5792 },
  { code: "FRLYS", country: "FR", countryName: "France",    flag: "🇫🇷", city: "Lyon",             type: ["air"], lat: 45.7640, lon: 4.8357 },
  { code: "FRTLS", country: "FR", countryName: "France",    flag: "🇫🇷", city: "Toulouse",         type: ["air"], lat: 43.6047, lon: 1.4442 },
  { code: "FRNCE", country: "FR", countryName: "France",    flag: "🇫🇷", city: "Nice",             type: ["air"], lat: 43.7102, lon: 7.2620 },
  { code: "FRCQF", country: "FR", countryName: "France",    flag: "🇫🇷", city: "Calais",           type: ["sea", "road"], lat: 50.9513, lon: 1.8587 },
  { code: "FRDKK", country: "FR", countryName: "France",    flag: "🇫🇷", city: "Dunkirk",          type: ["sea"], lat: 51.0344, lon: 2.3768 },
  // Italy secondary
  { code: "ITCIV", country: "IT", countryName: "Italy",     flag: "🇮🇹", city: "Civitavecchia",    type: ["sea"], lat: 42.0944, lon: 11.7964 },
  { code: "ITLIV", country: "IT", countryName: "Italy",     flag: "🇮🇹", city: "Livorno",          type: ["sea"], lat: 43.5407, lon: 10.3162 },
  { code: "ITAUG", country: "IT", countryName: "Italy",     flag: "🇮🇹", city: "Augusta",          type: ["sea"], lat: 37.2336, lon: 15.2189 },
  { code: "ITSAL", country: "IT", countryName: "Italy",     flag: "🇮🇹", city: "Salerno",          type: ["sea"], lat: 40.6824, lon: 14.7681 },
  { code: "ITBLG", country: "IT", countryName: "Italy",     flag: "🇮🇹", city: "Bologna",          type: ["air"], lat: 44.4949, lon: 11.3426 },
  { code: "ITCAT", country: "IT", countryName: "Italy",     flag: "🇮🇹", city: "Catania",          type: ["sea", "air"], lat: 37.5079, lon: 15.0830 },
  { code: "ITBRI", country: "IT", countryName: "Italy",     flag: "🇮🇹", city: "Bari",             type: ["sea", "air"], lat: 41.1171, lon: 16.8719 },
  // Benelux secondary
  { code: "NLEIN", country: "NL", countryName: "Netherlands", flag: "🇳🇱", city: "Eindhoven",      type: ["air"], lat: 51.4416, lon: 5.4697 },
  { code: "BELGG", country: "BE", countryName: "Belgium",   flag: "🇧🇪", city: "Liège (FedEx EU)", type: ["air"], lat: 50.6326, lon: 5.5797 },
  { code: "BEGNE", country: "BE", countryName: "Belgium",   flag: "🇧🇪", city: "Ghent",            type: ["sea", "inland"], lat: 51.0543, lon: 3.7174 },
  // Nordics secondary
  { code: "DKEBJ", country: "DK", countryName: "Denmark",   flag: "🇩🇰", city: "Esbjerg",          type: ["sea"], lat: 55.4761, lon: 8.4592 },
  { code: "SEMMA", country: "SE", countryName: "Sweden",    flag: "🇸🇪", city: "Malmö",            type: ["sea"], lat: 55.6050, lon: 13.0038 },
  { code: "SEHAD", country: "SE", countryName: "Sweden",    flag: "🇸🇪", city: "Helsingborg",      type: ["sea"], lat: 56.0466, lon: 12.6948 },
  { code: "NOBGO", country: "NO", countryName: "Norway",    flag: "🇳🇴", city: "Bergen",           type: ["sea"], lat: 60.3913, lon: 5.3221 },
  { code: "NOSVG", country: "NO", countryName: "Norway",    flag: "🇳🇴", city: "Stavanger",        type: ["sea", "air"], lat: 58.9700, lon: 5.7331 },
  { code: "ISREK", country: "IS", countryName: "Iceland",   flag: "🇮🇸", city: "Reykjavik",        type: ["sea", "air"], lat: 64.1466, lon: -21.9426 },
  // Central / Eastern Europe
  { code: "PLSZZ", country: "PL", countryName: "Poland",    flag: "🇵🇱", city: "Szczecin",         type: ["sea"], lat: 53.4285, lon: 14.5528 },
  { code: "PLWAW", country: "PL", countryName: "Poland",    flag: "🇵🇱", city: "Warsaw",           type: ["air"], lat: 52.2297, lon: 21.0122 },
  { code: "CHBSL", country: "CH", countryName: "Switzerland", flag: "🇨🇭", city: "Basel",          type: ["air", "inland"], lat: 47.5596, lon: 7.5886 },
  { code: "CHZRH", country: "CH", countryName: "Switzerland", flag: "🇨🇭", city: "Zurich",         type: ["air"], lat: 47.3769, lon: 8.5417 },
  { code: "ATVIE", country: "AT", countryName: "Austria",   flag: "🇦🇹", city: "Vienna",           type: ["air"], lat: 48.2082, lon: 16.3738 },
  { code: "HUBUD", country: "HU", countryName: "Hungary",   flag: "🇭🇺", city: "Budapest",         type: ["air"], lat: 47.4979, lon: 19.0402 },
  { code: "CZPRG", country: "CZ", countryName: "Czechia",   flag: "🇨🇿", city: "Prague",           type: ["air"], lat: 50.0755, lon: 14.4378 },
  { code: "GRSKG", country: "GR", countryName: "Greece",    flag: "🇬🇷", city: "Thessaloniki",     type: ["sea", "air"], lat: 40.6401, lon: 22.9444 },
  { code: "UAODS", country: "UA", countryName: "Ukraine",   flag: "🇺🇦", city: "Odesa",            type: ["sea"], lat: 46.4825, lon: 30.7233 },

  // ===== MIDDLE EAST secondary =====
  { code: "AEKHL", country: "AE", countryName: "UAE",       flag: "🇦🇪", city: "Khor Fakkan",      type: ["sea"], lat: 25.3389, lon: 56.3567 },
  { code: "AESHJ", country: "AE", countryName: "UAE",       flag: "🇦🇪", city: "Sharjah",          type: ["sea", "air"], lat: 25.3463, lon: 55.4209 },
  { code: "SARUH", country: "SA", countryName: "Saudi Arabia", flag: "🇸🇦", city: "Riyadh",       type: ["air"], lat: 24.7136, lon: 46.6753 },
  { code: "KWKWI", country: "KW", countryName: "Kuwait",    flag: "🇰🇼", city: "Kuwait City",      type: ["sea", "air"], lat: 29.3759, lon: 47.9774 },
  { code: "BHBAH", country: "BH", countryName: "Bahrain",   flag: "🇧🇭", city: "Manama",           type: ["sea", "air"], lat: 26.0667, lon: 50.5577 },
  { code: "LBBEY", country: "LB", countryName: "Lebanon",   flag: "🇱🇧", city: "Beirut",           type: ["sea", "air"], lat: 33.8938, lon: 35.5018 },
  { code: "JOAMM", country: "JO", countryName: "Jordan",    flag: "🇯🇴", city: "Amman",            type: ["air"], lat: 31.9454, lon: 35.9284 },
  { code: "JOAQJ", country: "JO", countryName: "Jordan",    flag: "🇯🇴", city: "Aqaba",            type: ["sea"], lat: 29.5267, lon: 35.0078 },

  // ===== ASIA secondary =====
  // China extra
  { code: "CNYIN", country: "CN", countryName: "China",     flag: "🇨🇳", city: "Yingkou",          type: ["sea"], lat: 40.6694, lon: 122.2358 },
  { code: "CNTNG", country: "CN", countryName: "China",     flag: "🇨🇳", city: "Tangshan",         type: ["sea"], lat: 39.6303, lon: 118.1803 },
  { code: "CNZUH", country: "CN", countryName: "China",     flag: "🇨🇳", city: "Zhuhai",           type: ["sea", "air"], lat: 22.2710, lon: 113.5767 },
  { code: "CNSWA", country: "CN", countryName: "China",     flag: "🇨🇳", city: "Shantou",          type: ["sea"], lat: 23.3540, lon: 116.6822 },
  // Korea extra
  { code: "KRPYT", country: "KR", countryName: "South Korea", flag: "🇰🇷", city: "Pyeongtaek",    type: ["sea"], lat: 36.9920, lon: 126.8262 },
  { code: "KRUSN", country: "KR", countryName: "South Korea", flag: "🇰🇷", city: "Ulsan",         type: ["sea"], lat: 35.5384, lon: 129.3114 },
  // Japan extra
  { code: "JPHKT", country: "JP", countryName: "Japan",     flag: "🇯🇵", city: "Hakata (Fukuoka)", type: ["sea", "air"], lat: 33.5904, lon: 130.4017 },
  { code: "JPSDJ", country: "JP", countryName: "Japan",     flag: "🇯🇵", city: "Sendai",           type: ["sea", "air"], lat: 38.2682, lon: 140.8694 },
  { code: "JPSPK", country: "JP", countryName: "Japan",     flag: "🇯🇵", city: "Sapporo (CTS)",    type: ["air"], lat: 43.0618, lon: 141.3545 },
  // SE Asia
  { code: "KHSIH", country: "KH", countryName: "Cambodia",  flag: "🇰🇭", city: "Sihanoukville",    type: ["sea"], lat: 10.6333, lon: 103.5000 },
  { code: "KHPNH", country: "KH", countryName: "Cambodia",  flag: "🇰🇭", city: "Phnom Penh",       type: ["air"], lat: 11.5564, lon: 104.9282 },
  { code: "MMRGN", country: "MM", countryName: "Myanmar",   flag: "🇲🇲", city: "Yangon",           type: ["sea", "air"], lat: 16.8409, lon: 96.1735 },
  { code: "IDDPS", country: "ID", countryName: "Indonesia", flag: "🇮🇩", city: "Bali (Denpasar)",  type: ["air"], lat: -8.7480, lon: 115.1670 },
  { code: "IDMDN", country: "ID", countryName: "Indonesia", flag: "🇮🇩", city: "Medan",            type: ["sea", "air"], lat: 3.5952, lon: 98.6722 },
  // India extra
  { code: "INCOK", country: "IN", countryName: "India",     flag: "🇮🇳", city: "Cochin (Kochi)",   type: ["sea", "air"], lat: 9.9312, lon: 76.2673 },
  { code: "INTUT", country: "IN", countryName: "India",     flag: "🇮🇳", city: "Tuticorin",        type: ["sea"], lat: 8.7642, lon: 78.1348 },
  { code: "INVTZ", country: "IN", countryName: "India",     flag: "🇮🇳", city: "Visakhapatnam",    type: ["sea"], lat: 17.6868, lon: 83.2185 },
  { code: "INHYD", country: "IN", countryName: "India",     flag: "🇮🇳", city: "Hyderabad",        type: ["air"], lat: 17.3850, lon: 78.4867 },
  { code: "INBLR", country: "IN", countryName: "India",     flag: "🇮🇳", city: "Bangalore",        type: ["air"], lat: 12.9716, lon: 77.5946 },
  { code: "INAMD", country: "IN", countryName: "India",     flag: "🇮🇳", city: "Ahmedabad",        type: ["air"], lat: 23.0225, lon: 72.5714 },
  { code: "BDMOG", country: "BD", countryName: "Bangladesh", flag: "🇧🇩", city: "Mongla",          type: ["sea"], lat: 22.4866, lon: 89.5849 },
  { code: "LKHRI", country: "LK", countryName: "Sri Lanka", flag: "🇱🇰", city: "Hambantota",       type: ["sea"], lat: 6.1241, lon: 81.1185 },

  // ===== AFRICA secondary =====
  { code: "ZAPLZ", country: "ZA", countryName: "South Africa", flag: "🇿🇦", city: "Port Elizabeth", type: ["sea"], lat: -33.9608, lon: 25.6022 },
  { code: "ZAELS", country: "ZA", countryName: "South Africa", flag: "🇿🇦", city: "East London",   type: ["sea"], lat: -33.0292, lon: 27.8546 },
  { code: "ZARBY", country: "ZA", countryName: "South Africa", flag: "🇿🇦", city: "Richards Bay",  type: ["sea"], lat: -28.7807, lon: 32.0383 },
  { code: "NGONE", country: "NG", countryName: "Nigeria",   flag: "🇳🇬", city: "Onne",             type: ["sea"], lat: 4.7167, lon: 7.1500 },
  { code: "NGPHC", country: "NG", countryName: "Nigeria",   flag: "🇳🇬", city: "Port Harcourt",    type: ["sea", "air"], lat: 4.8156, lon: 7.0498 },
  { code: "DZALG", country: "DZ", countryName: "Algeria",   flag: "🇩🇿", city: "Algiers",          type: ["sea", "air"], lat: 36.7538, lon: 3.0588 },
  { code: "DZORN", country: "DZ", countryName: "Algeria",   flag: "🇩🇿", city: "Oran",             type: ["sea"], lat: 35.6911, lon: -0.6417 },
  { code: "TNTUN", country: "TN", countryName: "Tunisia",   flag: "🇹🇳", city: "Tunis",            type: ["sea", "air"], lat: 36.8065, lon: 10.1815 },
  { code: "TNBIZ", country: "TN", countryName: "Tunisia",   flag: "🇹🇳", city: "Bizerte",          type: ["sea"], lat: 37.2746, lon: 9.8748 },
  { code: "MZMPM", country: "MZ", countryName: "Mozambique", flag: "🇲🇿", city: "Maputo",          type: ["sea", "air"], lat: -25.9692, lon: 32.5732 },
  { code: "MZBEW", country: "MZ", countryName: "Mozambique", flag: "🇲🇿", city: "Beira",           type: ["sea"], lat: -19.8330, lon: 34.8851 },
  { code: "ETADD", country: "ET", countryName: "Ethiopia",  flag: "🇪🇹", city: "Addis Ababa",      type: ["air"], lat: 9.0320, lon: 38.7469 },
  { code: "DJJIB", country: "DJ", countryName: "Djibouti",  flag: "🇩🇯", city: "Djibouti",         type: ["sea"], lat: 11.5722, lon: 43.1456 },
  { code: "SDPZU", country: "SD", countryName: "Sudan",     flag: "🇸🇩", city: "Port Sudan",       type: ["sea"], lat: 19.6157, lon: 37.2167 },
  { code: "UGEBB", country: "UG", countryName: "Uganda",    flag: "🇺🇬", city: "Kampala (Entebbe)", type: ["air"], lat: 0.3476, lon: 32.5825 },
  { code: "MGTMM", country: "MG", countryName: "Madagascar", flag: "🇲🇬", city: "Toamasina",       type: ["sea"], lat: -18.1499, lon: 49.4023 },
  { code: "MGTNR", country: "MG", countryName: "Madagascar", flag: "🇲🇬", city: "Antananarivo",    type: ["air"], lat: -18.8792, lon: 47.5079 },
  { code: "MUPLU", country: "MU", countryName: "Mauritius", flag: "🇲🇺", city: "Port Louis",       type: ["sea", "air"], lat: -20.1609, lon: 57.5012 },
  { code: "RWKGL", country: "RW", countryName: "Rwanda",    flag: "🇷🇼", city: "Kigali",           type: ["air"], lat: -1.9706, lon: 30.1044 },
  { code: "LRMLW", country: "LR", countryName: "Liberia",   flag: "🇱🇷", city: "Monrovia",         type: ["sea"], lat: 6.3004, lon: -10.7969 },
  { code: "SLFNA", country: "SL", countryName: "Sierra Leone", flag: "🇸🇱", city: "Freetown",      type: ["sea"], lat: 8.4657, lon: -13.2317 },
  { code: "GMBJL", country: "GM", countryName: "Gambia",    flag: "🇬🇲", city: "Banjul",           type: ["sea", "air"], lat: 13.4549, lon: -16.5790 },
  { code: "CDFIH", country: "CD", countryName: "DR Congo",  flag: "🇨🇩", city: "Kinshasa",         type: ["air"], lat: -4.4419, lon: 15.2663 },
  { code: "ZWHRE", country: "ZW", countryName: "Zimbabwe",  flag: "🇿🇼", city: "Harare",           type: ["air"], lat: -17.8252, lon: 31.0335 },
  { code: "ZMLUN", country: "ZM", countryName: "Zambia",    flag: "🇿🇲", city: "Lusaka",           type: ["air"], lat: -15.4067, lon: 28.2871 },

  // ===== OCEANIA secondary =====
  { code: "AUADL", country: "AU", countryName: "Australia", flag: "🇦🇺", city: "Adelaide",         type: ["sea", "air"], lat: -34.9285, lon: 138.6007 },
  { code: "AUDRW", country: "AU", countryName: "Australia", flag: "🇦🇺", city: "Darwin",           type: ["sea", "air"], lat: -12.4634, lon: 130.8456 },
  { code: "AUTSV", country: "AU", countryName: "Australia", flag: "🇦🇺", city: "Townsville",       type: ["sea", "air"], lat: -19.2589, lon: 146.8169 },
  { code: "AUNTL", country: "AU", countryName: "Australia", flag: "🇦🇺", city: "Newcastle",        type: ["sea"], lat: -32.9283, lon: 151.7817 },
  { code: "AUPKL", country: "AU", countryName: "Australia", flag: "🇦🇺", city: "Port Kembla",      type: ["sea"], lat: -34.4747, lon: 150.9097 },
  { code: "AUHBA", country: "AU", countryName: "Australia", flag: "🇦🇺", city: "Hobart",           type: ["sea", "air"], lat: -42.8821, lon: 147.3272 },
  { code: "NZWLG", country: "NZ", countryName: "New Zealand", flag: "🇳🇿", city: "Wellington",     type: ["sea", "air"], lat: -41.2865, lon: 174.7762 },
  { code: "NZCHC", country: "NZ", countryName: "New Zealand", flag: "🇳🇿", city: "Christchurch",   type: ["air"], lat: -43.5321, lon: 172.6362 },
  { code: "NZLYT", country: "NZ", countryName: "New Zealand", flag: "🇳🇿", city: "Lyttelton",      type: ["sea"], lat: -43.6064, lon: 172.7236 },
  { code: "NZNPE", country: "NZ", countryName: "New Zealand", flag: "🇳🇿", city: "Napier",         type: ["sea"], lat: -39.4928, lon: 176.9120 },
  { code: "PGPOM", country: "PG", countryName: "Papua New Guinea", flag: "🇵🇬", city: "Port Moresby", type: ["sea", "air"], lat: -9.4438, lon: 147.1803 },
  { code: "FJSUV", country: "FJ", countryName: "Fiji",      flag: "🇫🇯", city: "Suva",             type: ["sea", "air"], lat: -18.1248, lon: 178.4501 },

  // ===== TERTIARY LATAM (fishing, river, regional, border) =====
  // México tertiary
  { code: "MXSCX", country: "MX", countryName: "México",    flag: "🇲🇽", city: "Salina Cruz",      type: ["sea"], lat: 16.1730, lon: -95.1972 },
  { code: "MXCOA", country: "MX", countryName: "México",    flag: "🇲🇽", city: "Coatzacoalcos",    type: ["sea"], lat: 18.1346, lon: -94.4585 },
  { code: "MXTPB", country: "MX", countryName: "México",    flag: "🇲🇽", city: "Topolobampo",      type: ["sea"], lat: 25.6017, lon: -109.0531 },
  { code: "MXMAM", country: "MX", countryName: "México",    flag: "🇲🇽", city: "Ciudad Madero",    type: ["sea"], lat: 22.2719, lon: -97.8424 },
  { code: "MXMZT", country: "MX", countryName: "México",    flag: "🇲🇽", city: "Mazatlán",         type: ["sea", "air"], lat: 23.2494, lon: -106.4111 },
  { code: "MXCME", country: "MX", countryName: "México",    flag: "🇲🇽", city: "Ciudad del Carmen", type: ["sea", "air"], lat: 18.6500, lon: -91.8233 },
  { code: "MXCPE", country: "MX", countryName: "México",    flag: "🇲🇽", city: "Campeche",         type: ["air"], lat: 19.8301, lon: -90.5349 },
  { code: "MXMLM", country: "MX", countryName: "México",    flag: "🇲🇽", city: "Morelia",          type: ["air"], lat: 19.7060, lon: -101.1950 },
  { code: "MXSLW", country: "MX", countryName: "México",    flag: "🇲🇽", city: "Saltillo",         type: ["air", "inland"], lat: 25.4232, lon: -101.0053 },
  { code: "MXTRC", country: "MX", countryName: "México",    flag: "🇲🇽", city: "Torreón",          type: ["air", "inland"], lat: 25.5428, lon: -103.4068 },
  { code: "MXDGO", country: "MX", countryName: "México",    flag: "🇲🇽", city: "Durango",          type: ["air"], lat: 24.0277, lon: -104.6532 },
  { code: "MXCTM", country: "MX", countryName: "México",    flag: "🇲🇽", city: "Chetumal",         type: ["air", "road"], lat: 18.5036, lon: -88.3056 },
  { code: "MXTAP", country: "MX", countryName: "México",    flag: "🇲🇽", city: "Tapachula",        type: ["air", "road"], lat: 14.9123, lon: -92.2603 },

  // Brasil tertiary
  { code: "BRSSB", country: "BR", countryName: "Brasil",    flag: "🇧🇷", city: "São Sebastião",    type: ["sea"], lat: -23.7903, lon: -45.4136 },
  { code: "BRACU", country: "BR", countryName: "Brasil",    flag: "🇧🇷", city: "Açu",              type: ["sea"], lat: -21.8333, lon: -41.0167 },
  { code: "BRSTM", country: "BR", countryName: "Brasil",    flag: "🇧🇷", city: "Santarém",         type: ["sea", "air", "inland"], lat: -2.4438, lon: -54.7080 },
  { code: "BRPVH", country: "BR", countryName: "Brasil",    flag: "🇧🇷", city: "Porto Velho",      type: ["air", "inland"], lat: -8.7619, lon: -63.9039 },
  { code: "BRRBR", country: "BR", countryName: "Brasil",    flag: "🇧🇷", city: "Rio Branco",       type: ["air"], lat: -9.9747, lon: -67.8243 },
  { code: "BRMCP", country: "BR", countryName: "Brasil",    flag: "🇧🇷", city: "Macapá",           type: ["sea", "air"], lat: 0.0349, lon: -51.0694 },
  { code: "BRBVB", country: "BR", countryName: "Brasil",    flag: "🇧🇷", city: "Boa Vista",        type: ["air"], lat: 2.8235, lon: -60.6758 },
  { code: "BRFLN", country: "BR", countryName: "Brasil",    flag: "🇧🇷", city: "Florianópolis",    type: ["sea", "air"], lat: -27.5954, lon: -48.5480 },
  { code: "BRIGU", country: "BR", countryName: "Brasil",    flag: "🇧🇷", city: "Foz do Iguaçu",    type: ["air", "road"], lat: -25.5169, lon: -54.5854 },
  { code: "BRVDC", country: "BR", countryName: "Brasil",    flag: "🇧🇷", city: "Vila do Conde",    type: ["sea"], lat: -1.5447, lon: -48.7517 },

  // Argentina tertiary
  { code: "ARRGA", country: "AR", countryName: "Argentina", flag: "🇦🇷", city: "Río Grande (TDF)", type: ["air"], lat: -53.7833, lon: -67.7000 },
  { code: "ARPMY", country: "AR", countryName: "Argentina", flag: "🇦🇷", city: "Puerto Madryn",    type: ["sea", "air"], lat: -42.7692, lon: -65.0385 },
  { code: "ARPSS", country: "AR", countryName: "Argentina", flag: "🇦🇷", city: "Posadas",          type: ["air"], lat: -27.3621, lon: -55.9008 },
  { code: "ARRES", country: "AR", countryName: "Argentina", flag: "🇦🇷", city: "Resistencia",      type: ["air"], lat: -27.4515, lon: -58.9867 },
  { code: "ARNQN", country: "AR", countryName: "Argentina", flag: "🇦🇷", city: "Neuquén",          type: ["air"], lat: -38.9516, lon: -68.0591 },
  { code: "ARRGL", country: "AR", countryName: "Argentina", flag: "🇦🇷", city: "Río Gallegos",     type: ["air"], lat: -51.6230, lon: -69.2168 },
  { code: "ARUAQ", country: "AR", countryName: "Argentina", flag: "🇦🇷", city: "San Juan",         type: ["air"], lat: -31.5375, lon: -68.5364 },

  // Chile tertiary
  { code: "CLMEJ", country: "CL", countryName: "Chile",     flag: "🇨🇱", city: "Mejillones",       type: ["sea"], lat: -23.0992, lon: -70.4519 },
  { code: "CLCLD", country: "CL", countryName: "Chile",     flag: "🇨🇱", city: "Caldera",          type: ["sea"], lat: -27.0667, lon: -70.8181 },
  { code: "CLCQQ", country: "CL", countryName: "Chile",     flag: "🇨🇱", city: "Coquimbo",         type: ["sea"], lat: -29.9533, lon: -71.3393 },
  { code: "CLQTV", country: "CL", countryName: "Chile",     flag: "🇨🇱", city: "Quintero",         type: ["sea"], lat: -32.7833, lon: -71.5500 },
  { code: "CLTLC", country: "CL", countryName: "Chile",     flag: "🇨🇱", city: "Talcahuano",       type: ["sea"], lat: -36.7167, lon: -73.1167 },
  { code: "CLCAS", country: "CL", countryName: "Chile",     flag: "🇨🇱", city: "Castro (Chiloé)",  type: ["air"], lat: -42.4825, lon: -73.7625 },

  // Colombia tertiary
  { code: "CORCH", country: "CO", countryName: "Colombia",  flag: "🇨🇴", city: "Riohacha",         type: ["air"], lat: 11.5444, lon: -72.9072 },
  { code: "COCVE", country: "CO", countryName: "Colombia",  flag: "🇨🇴", city: "Coveñas",          type: ["sea"], lat: 9.4042, lon: -75.6953 },
  { code: "COLET", country: "CO", countryName: "Colombia",  flag: "🇨🇴", city: "Leticia",          type: ["air", "inland"], lat: -4.2150, lon: -69.9410 },
  { code: "COADZ", country: "CO", countryName: "Colombia",  flag: "🇨🇴", city: "San Andrés",       type: ["air"], lat: 12.5847, lon: -81.7000 },
  { code: "COAXM", country: "CO", countryName: "Colombia",  flag: "🇨🇴", city: "Armenia",          type: ["air"], lat: 4.5339, lon: -75.6811 },
  { code: "COMZL", country: "CO", countryName: "Colombia",  flag: "🇨🇴", city: "Manizales",        type: ["air"], lat: 5.0703, lon: -75.5138 },
  { code: "COIPI", country: "CO", countryName: "Colombia",  flag: "🇨🇴", city: "Ipiales",          type: ["road"], lat: 0.8285, lon: -77.6453 },

  // Perú tertiary
  { code: "PETYL", country: "PE", countryName: "Perú",      flag: "🇵🇪", city: "Talara",           type: ["sea", "air"], lat: -4.5775, lon: -81.2719 },
  { code: "PEMLQ", country: "PE", countryName: "Perú",      flag: "🇵🇪", city: "Mollendo",         type: ["sea"], lat: -17.0269, lon: -72.0144 },
  { code: "PEYMS", country: "PE", countryName: "Perú",      flag: "🇵🇪", city: "Yurimaguas",       type: ["air", "inland"], lat: -5.9000, lon: -76.1167 },
  { code: "PEPUN", country: "PE", countryName: "Perú",      flag: "🇵🇪", city: "Juliaca / Puno",   type: ["air"], lat: -15.4669, lon: -70.1583 },
  { code: "PECJA", country: "PE", countryName: "Perú",      flag: "🇵🇪", city: "Cajamarca",        type: ["air"], lat: -7.1638, lon: -78.5003 },
  { code: "PEHUU", country: "PE", countryName: "Perú",      flag: "🇵🇪", city: "Huánuco",          type: ["air"], lat: -9.9306, lon: -76.2422 },
  { code: "PEPMA", country: "PE", countryName: "Perú",      flag: "🇵🇪", city: "Puerto Maldonado", type: ["air"], lat: -12.5933, lon: -69.1891 },
  { code: "PEAYP", country: "PE", countryName: "Perú",      flag: "🇵🇪", city: "Ayacucho",         type: ["air"], lat: -13.1588, lon: -74.2236 },

  // Ecuador tertiary
  { code: "ECMCH", country: "EC", countryName: "Ecuador",   flag: "🇪🇨", city: "Machala",          type: ["air"], lat: -3.2581, lon: -79.9556 },
  { code: "ECPVO", country: "EC", countryName: "Ecuador",   flag: "🇪🇨", city: "Portoviejo",       type: ["air"], lat: -1.0567, lon: -80.4549 },
  { code: "ECATF", country: "EC", countryName: "Ecuador",   flag: "🇪🇨", city: "Ambato",           type: ["inland"], lat: -1.2543, lon: -78.6229 },
  { code: "ECSDO", country: "EC", countryName: "Ecuador",   flag: "🇪🇨", city: "Santo Domingo",    type: ["inland"], lat: -0.2542, lon: -79.1719 },
  { code: "ECCHE", country: "EC", countryName: "Ecuador",   flag: "🇪🇨", city: "Chone",            type: ["inland"], lat: -0.6951, lon: -80.0934 },

  // Bolivia tertiary
  { code: "BOPSZ", country: "BO", countryName: "Bolivia",   flag: "🇧🇴", city: "Puerto Suárez",    type: ["road", "inland"], lat: -18.9608, lon: -57.7950 },
  { code: "BOYAC", country: "BO", countryName: "Bolivia",   flag: "🇧🇴", city: "Yacuiba",          type: ["road"], lat: -22.0167, lon: -63.6833 },
  { code: "BOPAI", country: "BO", countryName: "Bolivia",   flag: "🇧🇴", city: "Puerto Aguirre (Hidrovía)", type: ["sea", "inland"], lat: -18.9700, lon: -57.8000 },

  // Paraguay tertiary
  { code: "PYPJC", country: "PY", countryName: "Paraguay",  flag: "🇵🇾", city: "Pedro Juan Caballero", type: ["road"], lat: -22.5500, lon: -55.7333 },
  { code: "PYCIO", country: "PY", countryName: "Paraguay",  flag: "🇵🇾", city: "Concepción",       type: ["inland"], lat: -23.4087, lon: -57.4344 },

  // Uruguay tertiary
  { code: "UYFRB", country: "UY", countryName: "Uruguay",   flag: "🇺🇾", city: "Fray Bentos",      type: ["sea"], lat: -33.1278, lon: -58.3097 },
  { code: "UYMER", country: "UY", countryName: "Uruguay",   flag: "🇺🇾", city: "Mercedes",         type: ["inland"], lat: -33.2575, lon: -58.0306 },

  // Venezuela tertiary
  { code: "VECUM", country: "VE", countryName: "Venezuela", flag: "🇻🇪", city: "Cumaná",           type: ["sea", "air"], lat: 10.4544, lon: -64.1722 },
  { code: "VEBLA", country: "VE", countryName: "Venezuela", flag: "🇻🇪", city: "Barcelona",        type: ["air"], lat: 10.1335, lon: -64.6964 },
  { code: "VEVAL", country: "VE", countryName: "Venezuela", flag: "🇻🇪", city: "Valencia",         type: ["air", "inland"], lat: 10.1620, lon: -68.0077 },
  { code: "VEBRM", country: "VE", countryName: "Venezuela", flag: "🇻🇪", city: "Barquisimeto",     type: ["air"], lat: 10.0647, lon: -69.3469 },
  { code: "VESVZ", country: "VE", countryName: "Venezuela", flag: "🇻🇪", city: "San Cristóbal",    type: ["road"], lat: 7.7669, lon: -72.2250 },

  // Central America tertiary
  { code: "HNLCE", country: "HN", countryName: "Honduras",  flag: "🇭🇳", city: "La Ceiba",         type: ["sea", "air"], lat: 15.7597, lon: -86.7822 },
  { code: "HNRTB", country: "HN", countryName: "Honduras",  flag: "🇭🇳", city: "Roatán",           type: ["air"], lat: 16.3263, lon: -86.5226 },
  { code: "GTQTZ", country: "GT", countryName: "Guatemala", flag: "🇬🇹", city: "Quetzaltenango",   type: ["air"], lat: 14.8347, lon: -91.5181 },
  { code: "SVLUN", country: "SV", countryName: "El Salvador", flag: "🇸🇻", city: "La Unión",       type: ["sea"], lat: 13.3367, lon: -87.8431 },
  { code: "NIRFS", country: "NI", countryName: "Nicaragua", flag: "🇳🇮", city: "Bluefields",       type: ["sea", "air"], lat: 12.0144, lon: -83.7647 },
  { code: "NIPCB", country: "NI", countryName: "Nicaragua", flag: "🇳🇮", city: "Puerto Cabezas",   type: ["sea"], lat: 14.0286, lon: -83.3819 },
  { code: "CRXQP", country: "CR", countryName: "Costa Rica",flag: "🇨🇷", city: "Quepos",           type: ["sea"], lat: 9.4317, lon: -84.1639 },
  { code: "CRGLF", country: "CR", countryName: "Costa Rica",flag: "🇨🇷", city: "Golfito",          type: ["sea"], lat: 8.6353, lon: -83.1622 },
  { code: "PAARM", country: "PA", countryName: "Panamá",    flag: "🇵🇦", city: "Puerto Armuelles", type: ["sea"], lat: 8.2792, lon: -82.8625 },

  // Dominican Republic tertiary
  { code: "DOBCC", country: "DO", countryName: "R. Dominicana", flag: "🇩🇴", city: "Boca Chica",   type: ["sea"], lat: 18.4500, lon: -69.6000 },
  { code: "DOSNX", country: "DO", countryName: "R. Dominicana", flag: "🇩🇴", city: "Samaná",       type: ["air"], lat: 19.2000, lon: -69.3331 },

  // Cuba tertiary
  { code: "CUCFG", country: "CU", countryName: "Cuba",      flag: "🇨🇺", city: "Cienfuegos",       type: ["sea"], lat: 22.1500, lon: -80.4333 },
  { code: "CUHOG", country: "CU", countryName: "Cuba",      flag: "🇨🇺", city: "Holguín",          type: ["air"], lat: 20.8872, lon: -76.2631 },
  { code: "CUCMW", country: "CU", countryName: "Cuba",      flag: "🇨🇺", city: "Camagüey",         type: ["air"], lat: 21.3811, lon: -77.9092 },

  // Haiti tertiary
  { code: "HTGOA", country: "HT", countryName: "Haití",     flag: "🇭🇹", city: "Gonaïves",         type: ["sea"], lat: 19.4500, lon: -72.6833 },
  { code: "HTJAK", country: "HT", countryName: "Haití",     flag: "🇭🇹", city: "Jacmel",           type: ["sea"], lat: 18.2342, lon: -72.5347 },

  // Jamaica tertiary
  { code: "JMMBJ", country: "JM", countryName: "Jamaica",   flag: "🇯🇲", city: "Montego Bay",      type: ["sea", "air"], lat: 18.4762, lon: -77.8939 },

  // Cayman Islands / Other Caribbean small island nations
  { code: "KYGCM", country: "KY", countryName: "Cayman Is.", flag: "🇰🇾", city: "George Town",      type: ["sea", "air"], lat: 19.2866, lon: -81.3674 },
  { code: "AGSJO", country: "AG", countryName: "Antigua",   flag: "🇦🇬", city: "St. John's",       type: ["sea", "air"], lat: 17.1175, lon: -61.8456 },
  { code: "LCSLU", country: "LC", countryName: "Saint Lucia", flag: "🇱🇨", city: "Castries",       type: ["sea", "air"], lat: 14.0101, lon: -60.9875 },
  { code: "VCKTN", country: "VC", countryName: "St. Vincent",flag: "🇻🇨", city: "Kingstown",       type: ["sea", "air"], lat: 13.1600, lon: -61.2248 },
  { code: "GDSGE", country: "GD", countryName: "Grenada",   flag: "🇬🇩", city: "St. George's",     type: ["sea", "air"], lat: 12.0561, lon: -61.7488 },
  { code: "KNSKB", country: "KN", countryName: "Saint Kitts",flag: "🇰🇳", city: "Basseterre",      type: ["sea", "air"], lat: 17.2955, lon: -62.7261 },
  { code: "DMRSU", country: "DM", countryName: "Dominica",  flag: "🇩🇲", city: "Roseau",           type: ["sea", "air"], lat: 15.3092, lon: -61.3794 },
  { code: "VISTT", country: "VI", countryName: "US Virgin Is.", flag: "🇻🇮", city: "St. Thomas",   type: ["sea", "air"], lat: 18.3358, lon: -64.8963 },
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
