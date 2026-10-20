import { QboConfigError } from "./config";
import { QboError } from "./client";
import { isAdmin } from "./session";

/** Envuelve un Route Handler: exige sesión de admin y normaliza errores a JSON. */
export async function adminRoute(fn: () => Promise<unknown>): Promise<Response> {
  try {
    if (!(await isAdmin())) return Response.json({ error: "No autorizado" }, { status: 401 });
    return Response.json(await fn());
  } catch (e) {
    if (e instanceof QboError) {
      return Response.json({ error: e.message, intuitTid: e.intuitTid }, { status: e.status });
    }
    if (e instanceof QboConfigError || e instanceof BadRequest) {
      return Response.json({ error: e.message }, { status: e instanceof BadRequest ? 400 : 500 });
    }
    console.error("[qbo]", e);
    return Response.json({ error: "Error inesperado" }, { status: 500 });
  }
}

export class BadRequest extends Error {}

export async function readJson<T>(req: Request): Promise<T> {
  try {
    return (await req.json()) as T;
  } catch {
    throw new BadRequest("JSON inválido");
  }
}

const DATE_RE = /^\d{4}-\d{2}-\d{2}$/;

export function optDate(v: unknown, field: string): string | undefined {
  if (v == null || v === "") return undefined;
  if (typeof v !== "string" || !DATE_RE.test(v)) throw new BadRequest(`${field} debe ser AAAA-MM-DD`);
  return v;
}

export function optString(v: unknown, field: string, max = 500): string | undefined {
  if (v == null || v === "") return undefined;
  if (typeof v !== "string" || v.length > max) throw new BadRequest(`${field} inválido`);
  return v.trim() || undefined;
}
