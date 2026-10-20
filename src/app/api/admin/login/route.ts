import { loginAdmin } from "@/lib/qbo/session";

export async function POST(request: Request) {
  const { password } = (await request.json().catch(() => ({}))) as { password?: unknown };
  if (typeof password !== "string" || !(await loginAdmin(password))) {
    return Response.json({ error: "Contraseña incorrecta" }, { status: 401 });
  }
  return Response.json({ ok: true });
}
