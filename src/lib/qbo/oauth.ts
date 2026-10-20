import {
  getQboConfig,
  QBO_AUTHORIZE_URL,
  QBO_REVOKE_URL,
  QBO_SCOPE,
  QBO_TOKEN_URL,
} from "./config";
import { randomToken } from "./crypto";
import { clearTokens, readTokens, setOAuthState, writeTokens, type QboTokens } from "./session";

interface TokenResponse {
  access_token: string;
  refresh_token: string;
  expires_in: number;
  x_refresh_token_expires_in: number;
}

function basicAuth(): string {
  const { clientId, clientSecret } = getQboConfig();
  return "Basic " + Buffer.from(`${clientId}:${clientSecret}`).toString("base64");
}

async function tokenRequest(body: Record<string, string>): Promise<TokenResponse> {
  const res = await fetch(QBO_TOKEN_URL, {
    method: "POST",
    headers: {
      Authorization: basicAuth(),
      Accept: "application/json",
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams(body),
    cache: "no-store",
  });
  if (!res.ok) {
    throw new Error(`Intuit token endpoint respondió ${res.status}: ${await res.text()}`);
  }
  return res.json();
}

function toTokens(r: TokenResponse, realmId: string): QboTokens {
  const now = Date.now();
  return {
    accessToken: r.access_token,
    refreshToken: r.refresh_token,
    realmId,
    accessExpiresAt: now + r.expires_in * 1000,
    refreshExpiresAt: now + r.x_refresh_token_expires_in * 1000,
  };
}

/** URL de autorización de Intuit; guarda el `state` anti-CSRF en cookie. */
export async function buildAuthorizeUrl(): Promise<string> {
  const { clientId, redirectUri } = getQboConfig();
  const state = randomToken();
  await setOAuthState(state);
  const url = new URL(QBO_AUTHORIZE_URL);
  url.search = new URLSearchParams({
    client_id: clientId,
    response_type: "code",
    scope: QBO_SCOPE,
    redirect_uri: redirectUri,
    state,
  }).toString();
  return url.toString();
}

export async function exchangeCode(code: string, realmId: string): Promise<QboTokens> {
  const { redirectUri } = getQboConfig();
  const r = await tokenRequest({ grant_type: "authorization_code", code, redirect_uri: redirectUri });
  const t = toTokens(r, realmId);
  await writeTokens(t);
  return t;
}

/** Tokens válidos, refrescando el access token si vence en < 2 min. */
export async function getValidTokens(): Promise<QboTokens | null> {
  const t = await readTokens();
  if (!t) return null;
  if (t.accessExpiresAt - Date.now() > 120_000) return t;
  try {
    const r = await tokenRequest({ grant_type: "refresh_token", refresh_token: t.refreshToken });
    const next = toTokens(r, t.realmId);
    await writeTokens(next);
    return next;
  } catch {
    // Refresh token inválido o revocado → hay que volver a conectar.
    await clearTokens();
    return null;
  }
}

export async function revoke(): Promise<void> {
  const t = await readTokens();
  await clearTokens();
  if (!t) return;
  await fetch(QBO_REVOKE_URL, {
    method: "POST",
    headers: {
      Authorization: basicAuth(),
      Accept: "application/json",
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ token: t.refreshToken }),
    cache: "no-store",
  }).catch(() => undefined);
}
