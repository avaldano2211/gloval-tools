import type { NextRequest } from "next/server";
import { getReport, isReportName } from "@/lib/qbo/client";
import { adminRoute, BadRequest, optDate } from "@/lib/qbo/route";

export async function GET(request: NextRequest) {
  const p = request.nextUrl.searchParams;
  return adminRoute(async () => {
    const name = p.get("name") ?? "";
    if (!isReportName(name)) throw new BadRequest("Reporte no soportado");
    return {
      report: await getReport(name, {
        startDate: optDate(p.get("start"), "start"),
        endDate: optDate(p.get("end"), "end"),
      }),
    };
  });
}
