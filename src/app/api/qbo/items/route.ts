import { listItems } from "@/lib/qbo/client";
import { adminRoute } from "@/lib/qbo/route";

export async function GET() {
  return adminRoute(async () => ({ items: await listItems() }));
}
