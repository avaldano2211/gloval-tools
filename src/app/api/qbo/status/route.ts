import { getCompanyInfo } from "@/lib/qbo/client";
import { getQboConfig } from "@/lib/qbo/config";
import { getValidTokens } from "@/lib/qbo/oauth";
import { adminRoute } from "@/lib/qbo/route";

export async function GET() {
  return adminRoute(async () => {
    const { environment } = getQboConfig();
    const tokens = await getValidTokens();
    if (!tokens) return { connected: false, environment };
    const company = await getCompanyInfo();
    return {
      connected: true,
      environment,
      realmId: tokens.realmId,
      companyName: company?.CompanyName ?? null,
      refreshExpiresAt: tokens.refreshExpiresAt,
    };
  });
}
