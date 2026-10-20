"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { Lock } from "lucide-react";
import { BrandButton } from "@/components/brand/BrandButton";

export function LoginForm() {
  const router = useRouter();
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  async function submit(e: React.FormEvent) {
    e.preventDefault();
    setBusy(true);
    setError(null);
    const res = await fetch("/api/admin/login", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ password }),
    });
    setBusy(false);
    if (res.ok) router.refresh();
    else setError((await res.json().catch(() => ({}))).error ?? "Error");
  }

  return (
    <form onSubmit={submit} className="max-w-sm rounded-2xl bg-white p-6 shadow-sm">
      <div className="flex items-center gap-2 font-semibold text-gv-blue">
        <Lock className="h-4 w-4" /> Acceso administrador
      </div>
      <input
        type="password"
        autoComplete="current-password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        placeholder="Contraseña"
        className="mt-4 w-full rounded-lg border border-gray-300 px-3 py-2 text-sm"
      />
      {error && <p className="mt-2 text-sm text-red-700">{error}</p>}
      <BrandButton type="submit" variant="filled" className="mt-4 w-full" disabled={busy || !password}>
        Entrar
      </BrandButton>
    </form>
  );
}
