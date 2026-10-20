import { cookies } from "next/headers";
import { getAdminPassword } from "./config";
import { safeEqual, seal, unseal } from "./crypto";

/**
 * Sin base de datos: la sesión de admin y los tokens OAuth de QuickBooks viven
 * en cookies httpOnly cifradas (AES-256-GCM). Consecuencia: la conexión es por
 * navegador — cada admin conecta QuickBooks desde su propio navegador.
 */

const ADMIN_COOKIE = "gv_admin";
const TOKENS_COOKIE = "gv_qbo";
export const STATE_COOKIE = "gv_qbo_state";

const ADMIN_TTL_S = 60 * 60 * 8; // 8 h

const baseCookie = {
  httpOnly: true,
  secure: process.env.NODE_ENV === "production",
  sameSite: "lax" as const,
  path: "/",
};

// ── Admin ────────────────────────────────────────────────────────────────

export async function isAdmin(): Promise<boolean> {
  const store = await cookies();
  const s = unseal<{ exp: number }>(store.get(ADMIN_COOKIE)?.value);
  return !!s && s.exp > Date.now();
}

export async function loginAdmin(password: string): Promise<boolean> {
  if (!safeEqual(password, getAdminPassword())) return false;
  const store = await cookies();
  store.set(ADMIN_COOKIE, seal({ exp: Date.now() + ADMIN_TTL_S * 1000 }), {
    ...baseCookie,
    maxAge: ADMIN_TTL_S,
  });
  return true;
}

export async function logoutAdmin(): Promise<void> {
  const store = await cookies();
  store.delete(ADMIN_COOKIE);
}

// ── Tokens QBO ───────────────────────────────────────────────────────────

export interface QboTokens {
  accessToken: string;
  refreshToken: string;
  realmId: string;
  /** epoch ms */
  accessExpiresAt: number;
  /** epoch ms */
  refreshExpiresAt: number;
}

export async function readTokens(): Promise<QboTokens | null> {
  const store = await cookies();
  const t = unseal<QboTokens>(store.get(TOKENS_COOKIE)?.value);
  if (!t || t.refreshExpiresAt <= Date.now()) return null;
  return t;
}

export async function writeTokens(t: QboTokens): Promise<void> {
  const store = await cookies();
  store.set(TOKENS_COOKIE, seal(t), {
    ...baseCookie,
    maxAge: Math.max(0, Math.floor((t.refreshExpiresAt - Date.now()) / 1000)),
  });
}

export async function clearTokens(): Promise<void> {
  const store = await cookies();
  store.delete(TOKENS_COOKIE);
}

export async function setOAuthState(state: string): Promise<void> {
  const store = await cookies();
  store.set(STATE_COOKIE, state, { ...baseCookie, maxAge: 600 });
}

export async function consumeOAuthState(): Promise<string | undefined> {
  const store = await cookies();
  const v = store.get(STATE_COOKIE)?.value;
  store.delete(STATE_COOKIE);
  return v;
}
