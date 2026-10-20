import { redirect } from "next/navigation";
import { buildAuthorizeUrl } from "@/lib/qbo/oauth";
import { isAdmin } from "@/lib/qbo/session";

export async function GET() {
  if (!(await isAdmin())) redirect("/admin/quickbooks");
  redirect(await buildAuthorizeUrl());
}
