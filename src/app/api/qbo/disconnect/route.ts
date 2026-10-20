import { revoke } from "@/lib/qbo/oauth";
import { adminRoute } from "@/lib/qbo/route";

export async function POST() {
  return adminRoute(async () => {
    await revoke();
    return { ok: true };
  });
}
