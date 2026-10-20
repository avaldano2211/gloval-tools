import { logoutAdmin } from "@/lib/qbo/session";

export async function POST() {
  await logoutAdmin();
  return Response.json({ ok: true });
}
