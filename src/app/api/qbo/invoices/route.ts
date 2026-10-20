import type { NextRequest } from "next/server";
import { createInvoice, listInvoices, type NewInvoiceLine } from "@/lib/qbo/client";
import { adminRoute, BadRequest, optDate, optString, readJson } from "@/lib/qbo/route";

export async function GET(request: NextRequest) {
  const p = request.nextUrl.searchParams;
  return adminRoute(async () => ({
    invoices: await listInvoices({
      customerId: p.get("customerId") || undefined,
      openOnly: p.get("open") === "1",
    }),
  }));
}

export async function POST(request: Request) {
  return adminRoute(async () => {
    const b = await readJson<Record<string, unknown>>(request);
    const customerId = optString(b.customerId, "customerId", 50);
    if (!customerId) throw new BadRequest("Selecciona un cliente");
    if (!Array.isArray(b.lines) || b.lines.length === 0) throw new BadRequest("Agrega al menos una línea");

    const lines: NewInvoiceLine[] = b.lines.map((raw, i) => {
      const l = (raw ?? {}) as Record<string, unknown>;
      const itemId = optString(l.itemId, `lines[${i}].itemId`, 50);
      const qty = Number(l.qty);
      const unitPrice = Number(l.unitPrice);
      if (!itemId) throw new BadRequest(`Línea ${i + 1}: selecciona un producto/servicio`);
      if (!Number.isFinite(qty) || qty <= 0) throw new BadRequest(`Línea ${i + 1}: cantidad inválida`);
      if (!Number.isFinite(unitPrice) || unitPrice < 0) throw new BadRequest(`Línea ${i + 1}: precio inválido`);
      return { itemId, qty, unitPrice, description: optString(l.description, `lines[${i}].description`, 4000) };
    });

    const invoice = await createInvoice({
      customerId,
      txnDate: optDate(b.txnDate, "txnDate"),
      dueDate: optDate(b.dueDate, "dueDate"),
      memo: optString(b.memo, "memo", 1000),
      email: optString(b.email, "email", 100),
      lines,
    });
    return { invoice };
  });
}
