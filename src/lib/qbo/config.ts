/**
 * Configuración de QuickBooks Online (Intuit) leída de variables de entorno.
 * Ver `.env.example` para la lista completa.
 */

export type QboEnvironment = "sandbox" | "production";

export interface QboConfig {
  clientId: string;
  clientSecret: string;
  redirectUri: string;
  environment: QboEnvironment;
  apiBase: string;
}

export const QBO_AUTHORIZE_URL = "https://appcenter.intuit.com/connect/oauth2";
export const QBO_TOKEN_URL = "https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer";
export const QBO_REVOKE_URL = "https://developer.api.intuit.com/v2/oauth2/tokens/revoke";
export const QBO_SCOPE = "com.intuit.quickbooks.accounting";
export const QBO_MINOR_VERSION = "75";

const API_BASE: Record<QboEnvironment, string> = {
  sandbox: "https://sandbox-quickbooks.api.intuit.com",
  production: "https://quickbooks.api.intuit.com",
};

export class QboConfigError extends Error {}

function required(name: string): string {
  const v = process.env[name];
  if (!v) throw new QboConfigError(`Falta la variable de entorno ${name}`);
  return v;
}

export function getQboConfig(): QboConfig {
  const env = (process.env.QBO_ENVIRONMENT ?? "sandbox") as QboEnvironment;
  if (env !== "sandbox" && env !== "production") {
    throw new QboConfigError("QBO_ENVIRONMENT debe ser 'sandbox' o 'production'");
  }
  return {
    clientId: required("QBO_CLIENT_ID"),
    clientSecret: required("QBO_CLIENT_SECRET"),
    redirectUri: required("QBO_REDIRECT_URI"),
    environment: env,
    apiBase: API_BASE[env],
  };
}

/** Secreto usado para cifrar las cookies de sesión y de tokens (mín. 32 caracteres). */
export function getSessionSecret(): string {
  const s = required("QBO_SESSION_SECRET");
  if (s.length < 32) throw new QboConfigError("QBO_SESSION_SECRET debe tener al menos 32 caracteres");
  return s;
}

export function getAdminPassword(): string {
  return required("QBO_ADMIN_PASSWORD");
}
