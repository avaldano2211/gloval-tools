import { sendInvoice } from "@/lib/qbo/client";
import { adminRoute, optString, readJson } from "@/lib/qbo/route";

export async function POST(request: Request, ctx: RouteContext<"/api/qbo/invoices/[id]/send">) {
  return adminRoute(async () => {
    const { id } = await ctx.params;
    const b = await readJson<Record<string, unknown>>(request).catch(() => ({}) as Record<string, unknown>);
    return { invoice: await sendInvoice(id, optString(b.email, "email", 100)) };
  });
}
