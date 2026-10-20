import type { Metadata } from "next";
import { isAdmin } from "@/lib/qbo/session";
import { QboConfigError } from "@/lib/qbo/config";
import { LoginForm } from "./LoginForm";
import { QboDashboard } from "./QboDashboard";

export const metadata: Metadata = {
  title: "QuickBooks Online — Admin Gloval",
  robots: { index: false, follow: false },
};

const ERRORS: Record<string, string> = {
  access_denied: "Cancelaste la autorización en QuickBooks.",
  invalid_state: "La respuesta de QuickBooks no es válida o expiró. Intenta conectar de nuevo.",
  token_exchange: "No se pudo obtener el token de QuickBooks. Revisa Client ID / Secret / Redirect URI.",
};

export default async function QuickBooksAdminPage({
  searchParams,
}: {
  searchParams: Promise<{ error?: string; connected?: string }>;
}) {
  const { error, connected } = await searchParams;

  let admin = false;
  let configError: string | null = null;
  try {
    admin = await isAdmin();
  } catch (e) {
    if (!(e instanceof QboConfigError)) throw e;
    configError = e.message;
  }

  return (
    <div className="bg-gv-bg-soft min-h-screen pt-24">
      <div className="max-w-6xl mx-auto px-6 py-10">
        <h1 className="text-3xl md:text-4xl font-bold text-gv-blue">QuickBooks Online</h1>
        <p className="mt-2 text-sm text-gray-600">
          Herramienta interna: clientes, facturas y reportes de la empresa conectada.
        </p>

        {configError && (
          <div className="mt-6 rounded-xl border border-red-200 bg-red-50 p-4 text-sm text-red-800">
            Configuración incompleta: {configError}. Ver <code>.env.example</code>.
          </div>
        )}
        {error && (
          <div className="mt-6 rounded-xl border border-red-200 bg-red-50 p-4 text-sm text-red-800">
            {ERRORS[error] ?? `Error de QuickBooks: ${error}`}
          </div>
        )}
        {connected && !error && (
          <div className="mt-6 rounded-xl border border-green-200 bg-green-50 p-4 text-sm text-green-800">
            QuickBooks conectado correctamente.
          </div>
        )}

        <div className="mt-8">{configError ? null : admin ? <QboDashboard /> : <LoginForm />}</div>
      </div>
    </div>
  );
}
