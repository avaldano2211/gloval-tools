/**
 * Container Tracking — DEMO con datos mock.
 *
 * Cuando se contrate searates.com / shipsgo.com / similar:
 *   - Reemplazar `lookupTracking` por una llamada al provider.
 *   - El resto de la UI no cambia: trabaja contra el shape `Tracking`.
 *
 * Los datos mock simulan respuestas reales: 3 contenedores demo + caso "no
 * encontrado" para validar la UX completa antes de conectar API real.
 */

export type TrackingStatus =
  | "loading"      // En carga en origen
  | "in_transit"  // En tránsito (a bordo)
  | "discharged"  // Descargado en destino, en terminal
  | "delivered"   // Entregado al consignatario
  | "delayed";    // Demorado / con incidencia

export type EventType =
  | "gate_in"        // Entró a la terminal de origen
  | "loaded"         // Cargado a bordo
  | "departed"       // Zarpó de puerto
  | "arrived"        // Arribó a puerto destino
  | "discharged"     // Descargado del buque
  | "gate_out"       // Salió de la terminal
  | "delivered"      // Entregado
  | "transhipment";  // Transbordo intermedio

export interface TrackingEvent {
  date: string;            // ISO
  type: EventType;
  description: string;
  location: string;
  locode?: string;
  vessel?: string;
  voyage?: string;
}

export interface Tracking {
  number: string;
  type: "container" | "bl" | "vessel";
  carrier: string;
  carrierCode: string;
  status: TrackingStatus;
  containerType: string;     // ej: 40' HC
  origin: { port: string; locode: string; lat: number; lon: number };
  destination: { port: string; locode: string; lat: number; lon: number };
  currentLocation?: { lat: number; lon: number; description: string };
  vessel: string;
  voyage: string;
  eta: string;               // ISO
  isGlovalShipment: boolean; // marker para UX premium si Gloval mueve este BL
  events: TrackingEvent[];
}

const HK = { port: "Hong Kong", locode: "HKHKG", lat: 22.3193, lon: 114.1694 };
const CALLAO = { port: "Callao", locode: "PECLL", lat: -12.0552, lon: -77.1371 };
const SHANGHAI = { port: "Shanghai", locode: "CNSHA", lat: 31.2304, lon: 121.4737 };
const MIT = { port: "Manzanillo (MIT)", locode: "PAMIT", lat: 9.3641, lon: -79.8961 };
const GYE = { port: "Guayaquil", locode: "ECGYE", lat: -2.1894, lon: -79.8891 };
const MIA = { port: "Miami", locode: "USMIA", lat: 25.7617, lon: -80.1918 };
const HOU = { port: "Houston", locode: "USHOU", lat: 29.7604, lon: -95.3698 };
const CTG = { port: "Cartagena", locode: "COCTG", lat: 10.391, lon: -75.4794 };

const MOCK: Record<string, Tracking> = {
  // Contenedor Maersk — en tránsito, mid-Pacific
  MAEU1234567: {
    number: "MAEU1234567",
    type: "container",
    carrier: "Maersk Line",
    carrierCode: "MAEU",
    status: "in_transit",
    containerType: "40' HC",
    origin: HK,
    destination: CALLAO,
    currentLocation: { lat: 5, lon: -140, description: "Pacífico Sur, en ruta a Manzanillo" },
    vessel: "MAERSK SEMARANG",
    voyage: "447S",
    eta: "2026-05-22T14:00:00Z",
    isGlovalShipment: false,
    events: [
      { date: "2026-04-28T09:15:00Z", type: "gate_in",      description: "Gate-in en terminal de origen",   location: "HIT Terminal, Hong Kong",     locode: "HKHKG" },
      { date: "2026-04-30T03:45:00Z", type: "loaded",       description: "Cargado a bordo",                  location: "HIT Terminal, Hong Kong",     locode: "HKHKG", vessel: "MAERSK SEMARANG", voyage: "447S" },
      { date: "2026-04-30T22:10:00Z", type: "departed",     description: "Zarpe del puerto de origen",      location: "Hong Kong",                    locode: "HKHKG", vessel: "MAERSK SEMARANG", voyage: "447S" },
      { date: "2026-05-08T18:30:00Z", type: "transhipment", description: "Transbordo programado",            location: "Manzanillo (MIT), Panamá",     locode: "PAMIT" },
    ],
  },

  // Maersk BL — entregado completo
  MAEU987654321: {
    number: "MAEU987654321",
    type: "bl",
    carrier: "Maersk Line",
    carrierCode: "MAEU",
    status: "delivered",
    containerType: "40' HC × 3",
    origin: SHANGHAI,
    destination: GYE,
    vessel: "MAERSK CABO SAN ROQUE",
    voyage: "412S",
    eta: "2026-04-15T08:00:00Z",
    isGlovalShipment: true,  // Marca como Gloval shipment
    events: [
      { date: "2026-03-12T11:00:00Z", type: "gate_in",     description: "Gate-in",                         location: "Yangshan Terminal, Shanghai",  locode: "CNSHA" },
      { date: "2026-03-14T08:20:00Z", type: "loaded",      description: "Cargado a bordo",                 location: "Yangshan Terminal, Shanghai",  locode: "CNSHA", vessel: "MAERSK CABO SAN ROQUE", voyage: "412S" },
      { date: "2026-03-14T19:00:00Z", type: "departed",    description: "Zarpe",                            location: "Shanghai",                     locode: "CNSHA", vessel: "MAERSK CABO SAN ROQUE", voyage: "412S" },
      { date: "2026-04-04T06:00:00Z", type: "transhipment",description: "Transbordo en hub",                location: "Manzanillo (MIT), Panamá",     locode: "PAMIT" },
      { date: "2026-04-13T22:30:00Z", type: "arrived",     description: "Arribo a puerto destino",          location: "Guayaquil",                    locode: "ECGYE" },
      { date: "2026-04-14T14:15:00Z", type: "discharged",  description: "Descarga del buque",               location: "Contecon, Guayaquil",          locode: "ECGYE" },
      { date: "2026-04-15T10:00:00Z", type: "gate_out",    description: "Salida de terminal",              location: "Contecon, Guayaquil",          locode: "ECGYE" },
      { date: "2026-04-16T16:45:00Z", type: "delivered",   description: "Entregado a consignatario",        location: "Almacén cliente, Daule, Ecuador", locode: "ECGYE" },
    ],
  },

  // CMA-CGM — en carga
  CMAU9876543: {
    number: "CMAU9876543",
    type: "container",
    carrier: "CMA CGM",
    carrierCode: "CMAU",
    status: "loading",
    containerType: "20' Standard",
    origin: HOU,
    destination: CTG,
    vessel: "CMA CGM AMAZON",
    voyage: "208W",
    eta: "2026-05-16T20:00:00Z",
    isGlovalShipment: false,
    events: [
      { date: "2026-05-05T14:20:00Z", type: "gate_in", description: "Gate-in en terminal de origen", location: "Bayport Terminal, Houston", locode: "USHOU" },
    ],
  },

  // MSC — descargado, esperando salida de terminal
  MSCU7654321: {
    number: "MSCU7654321",
    type: "container",
    carrier: "Mediterranean Shipping Company",
    carrierCode: "MSCU",
    status: "discharged",
    containerType: "40' Standard",
    origin: MIA,
    destination: CALLAO,
    vessel: "MSC ALICANTE",
    voyage: "326S",
    eta: "2026-05-06T15:00:00Z",
    isGlovalShipment: false,
    events: [
      { date: "2026-04-22T09:30:00Z", type: "gate_in",    description: "Gate-in",                  location: "Port Miami Terminal",       locode: "USMIA" },
      { date: "2026-04-24T07:15:00Z", type: "loaded",     description: "Cargado a bordo",          location: "Port Miami Terminal",       locode: "USMIA", vessel: "MSC ALICANTE", voyage: "326S" },
      { date: "2026-04-24T16:40:00Z", type: "departed",   description: "Zarpe",                     location: "Miami",                     locode: "USMIA", vessel: "MSC ALICANTE", voyage: "326S" },
      { date: "2026-05-01T05:20:00Z", type: "transhipment", description: "Transbordo",             location: "Manzanillo (MIT), Panamá",  locode: "PAMIT" },
      { date: "2026-05-05T20:10:00Z", type: "arrived",    description: "Arribo a Callao",          location: "Callao, Perú",              locode: "PECLL" },
      { date: "2026-05-06T10:30:00Z", type: "discharged", description: "Descargado del buque",     location: "APM Terminals, Callao",     locode: "PECLL" },
    ],
  },
};

const CARRIER_PREFIXES: Record<string, string> = {
  MAEU: "Maersk Line",
  MSCU: "Mediterranean Shipping Company",
  CMAU: "CMA CGM",
  HLXU: "Hapag-Lloyd",
  EVRU: "Evergreen",
  ONEY: "Ocean Network Express (ONE)",
  COSU: "COSCO Shipping",
  HMMU: "HMM",
  ZIMU: "ZIM",
};

export function detectCarrier(containerNumber: string): string | null {
  const prefix = containerNumber.slice(0, 4).toUpperCase();
  return CARRIER_PREFIXES[prefix] ?? null;
}

export const VALID_CONTAINER_RE = /^[A-Z]{4}\d{7}$/;

/** Hits mock data. Devuelve null si no encuentra el contenedor/BL. */
export async function lookupTracking(query: string): Promise<Tracking | null> {
  // Simula latencia de API real
  await new Promise((r) => setTimeout(r, 600));
  const key = query.trim().toUpperCase();
  return MOCK[key] ?? null;
}

export function listDemoNumbers(): { number: string; carrier: string; status: TrackingStatus }[] {
  return Object.values(MOCK).map((t) => ({
    number: t.number,
    carrier: t.carrier,
    status: t.status,
  }));
}

export const STATUS_LABEL: Record<TrackingStatus, { label: string; color: string }> = {
  loading:    { label: "En carga (origen)",    color: "#FBBF24" },
  in_transit: { label: "En tránsito",          color: "#3B82F6" },
  discharged: { label: "Descargado",           color: "#06B6D4" },
  delivered:  { label: "Entregado",            color: "#16A34A" },
  delayed:    { label: "Demorado",             color: "#DC2626" },
};

export const EVENT_LABEL: Record<EventType, string> = {
  gate_in:      "Gate-in",
  loaded:       "Cargado a bordo",
  departed:     "Zarpe",
  arrived:      "Arribo",
  discharged:   "Descarga",
  gate_out:     "Gate-out",
  delivered:    "Entregado",
  transhipment: "Transbordo",
};
