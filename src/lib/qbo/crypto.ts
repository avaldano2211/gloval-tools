import { createCipheriv, createDecipheriv, createHash, randomBytes, timingSafeEqual } from "node:crypto";
import { getSessionSecret } from "./config";

function key(): Buffer {
  return createHash("sha256").update(getSessionSecret()).digest();
}

/** Cifra (AES-256-GCM) y serializa un objeto a base64url. */
export function seal(data: unknown): string {
  const iv = randomBytes(12);
  const cipher = createCipheriv("aes-256-gcm", key(), iv);
  const enc = Buffer.concat([cipher.update(JSON.stringify(data), "utf8"), cipher.final()]);
  return Buffer.concat([iv, cipher.getAuthTag(), enc]).toString("base64url");
}

/** Inverso de `seal`. Devuelve null si el valor fue alterado o el secreto cambió. */
export function unseal<T>(value: string | undefined): T | null {
  if (!value) return null;
  try {
    const buf = Buffer.from(value, "base64url");
    const decipher = createDecipheriv("aes-256-gcm", key(), buf.subarray(0, 12));
    decipher.setAuthTag(buf.subarray(12, 28));
    const dec = Buffer.concat([decipher.update(buf.subarray(28)), decipher.final()]);
    return JSON.parse(dec.toString("utf8")) as T;
  } catch {
    return null;
  }
}

/** Comparación en tiempo constante de dos strings. */
export function safeEqual(a: string, b: string): boolean {
  const ha = createHash("sha256").update(a).digest();
  const hb = createHash("sha256").update(b).digest();
  return timingSafeEqual(ha, hb);
}

export function randomToken(bytes = 24): string {
  return randomBytes(bytes).toString("base64url");
}
