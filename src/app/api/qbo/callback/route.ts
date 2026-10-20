import { redirect } from "next/navigation";
import type { NextRequest } from "next/server";
import { exchangeCode } from "@/lib/qbo/oauth";
import { consumeOAuthState, isAdmin } from "@/lib/qbo/session";

const PAGE = "/admin/quickbooks";

/** Redirect URI registrada en el portal de Intuit Developer. */
export async function GET(request: NextRequest) {
  const p = request.nextUrl.searchParams;
  const expectedState = await consumeOAuthState();

  if (!(await isAdmin())) redirect(PAGE);
  if (p.get("error")) redirect(`${PAGE}?error=${encodeURIComponent(p.get("error")!)}`);

  const code = p.get("code");
  const realmId = p.get("realmId");
  if (!code || !realmId || !expectedState || p.get("state") !== expectedState) {
    redirect(`${PAGE}?error=invalid_state`);
  }

  let ok = true;
  try {
    await exchangeCode(code, realmId);
  } catch (e) {
    console.error("[qbo] token exchange", e);
    ok = false;
  }
  redirect(ok ? `${PAGE}?connected=1` : `${PAGE}?error=token_exchange`);
}
