import type { NextRequest } from "next/server";
import { createCustomer, listCustomers } from "@/lib/qbo/client";
import { adminRoute, BadRequest, optString, readJson } from "@/lib/qbo/route";

export async function GET(request: NextRequest) {
  return adminRoute(async () => ({
    customers: await listCustomers(request.nextUrl.searchParams.get("q")?.trim() || undefined),
  }));
}

export async function POST(request: Request) {
  return adminRoute(async () => {
    const b = await readJson<Record<string, unknown>>(request);
    const displayName = optString(b.displayName, "displayName", 500);
    if (!displayName) throw new BadRequest("El nombre es obligatorio");
    const email = optString(b.email, "email", 100);
    if (email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) throw new BadRequest("Email inválido");
    const customer = await createCustomer({
      displayName,
      companyName: optString(b.companyName, "companyName", 100),
      email,
      phone: optString(b.phone, "phone", 30),
      address: {
        line1: optString(b.addressLine1, "addressLine1"),
        city: optString(b.city, "city", 255),
        country: optString(b.country, "country", 255),
        postalCode: optString(b.postalCode, "postalCode", 30),
      },
    });
    return { customer };
  });
}
