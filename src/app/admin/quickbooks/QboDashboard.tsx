"use client";

import { useCallback, useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { FileText, Link2, LogOut, Plus, RefreshCw, Send, Trash2, Unplug, Users, BarChart3 } from "lucide-react";
import { BrandButton } from "@/components/brand/BrandButton";
import { cn } from "@/lib/utils";
import type { Customer, Invoice, Item, Report, ReportName } from "@/lib/qbo/client";

// Duplicado de REPORTS en lib/qbo/client (ese módulo es solo de servidor).
const REPORT_OPTIONS: { value: ReportName; label: string }[] = [
  { value: "ProfitAndLoss", label: "Estado de resultados (P&L)" },
  { value: "BalanceSheet", label: "Balance general" },
  { value: "AgedReceivables", label: "Cuentas por cobrar (antigüedad)" },
  { value: "CustomerBalance", label: "Saldo por cliente" },
];

interface Status {
  connected: boolean;
  environment: "sandbox" | "production";
  realmId?: string;
  companyName?: string | null;
  refreshExpiresAt?: number;
}

async function api<T>(url: string, init?: RequestInit): Promise<T> {
  const res = await fetch(url, {
    ...init,
    headers: init?.body ? { "Content-Type": "application/json" } : undefined,
  });
  const json = await res.json().catch(() => ({}));
  if (!res.ok) {
    const tid = json.intuitTid ? ` (intuit_tid ${json.intuitTid})` : "";
    throw new Error((json.error ?? `HTTP ${res.status}`) + tid);
  }
  return json as T;
}

const money = (n: number | undefined, cur?: string) =>
  n == null ? "—" : n.toLocaleString("es", { style: "currency", currency: cur ?? "USD" });

const input = "w-full rounded-lg border border-gray-300 px-3 py-2 text-sm bg-white";
const card = "rounded-2xl bg-white p-6 shadow-sm";

type Tab = "customers" | "invoices" | "reports";

export function QboDashboard() {
  const router = useRouter();
  const [status, setStatus] = useState<Status | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [tab, setTab] = useState<Tab>("customers");

  const loadStatus = useCallback(() => {
    api<Status>("/api/qbo/status").then(
      (r) => {
        setError(null);
        setStatus(r);
      },
      (e) => setError(e.message),
    );
  }, []);
  useEffect(loadStatus, [loadStatus]);

  async function disconnect() {
    if (!confirm("¿Desconectar QuickBooks? Se revocará el acceso.")) return;
    await api("/api/qbo/disconnect", { method: "POST" }).catch((e) => setError(e.message));
    loadStatus();
  }

  async function logout() {
    await fetch("/api/admin/logout", { method: "POST" });
    router.refresh();
  }

  return (
    <div className="space-y-6">
      <div className={cn(card, "flex flex-wrap items-center justify-between gap-4")}>
        <div>
          {!status ? (
            <p className="text-sm text-gray-500">{error ?? "Cargando estado…"}</p>
          ) : status.connected ? (
            <>
              <p className="font-semibold text-gv-blue">{status.companyName ?? "Empresa conectada"}</p>
              <p className="text-xs text-gray-500">
                Realm {status.realmId} · {status.environment === "sandbox" ? "Sandbox" : "Producción"}
                {status.refreshExpiresAt &&
                  ` · reconectar antes de ${new Date(status.refreshExpiresAt).toLocaleDateString("es")}`}
              </p>
            </>
          ) : (
            <p className="text-sm text-gray-700">
              QuickBooks no está conectado ({status.environment === "sandbox" ? "Sandbox" : "Producción"}).
            </p>
          )}
        </div>
        <div className="flex flex-wrap gap-2">
          {status && !status.connected && (
            // Navegación completa: el endpoint redirige a Intuit.
            <a
              href="/api/qbo/connect"
              className="inline-flex items-center gap-2 rounded-pill bg-[#2CA01C] px-6 py-3 text-sm font-semibold text-white hover:opacity-90"
            >
              <Link2 className="h-4 w-4" /> Conectar a QuickBooks
            </a>
          )}
          {status?.connected && (
            <BrandButton variant="outline" className="!text-gv-blue !border-gv-blue px-5 py-2.5" onClick={disconnect}>
              <Unplug className="h-4 w-4" /> Desconectar
            </BrandButton>
          )}
          <BrandButton variant="outline" className="!text-gray-600 !border-gray-300 px-5 py-2.5" onClick={logout}>
            <LogOut className="h-4 w-4" /> Salir
          </BrandButton>
        </div>
      </div>

      {status && error && <p className="text-sm text-red-700">{error}</p>}

      {status?.connected && (
        <>
          <div className="flex gap-2">
            {(
              [
                ["customers", "Clientes", Users],
                ["invoices", "Facturas", FileText],
                ["reports", "Reportes", BarChart3],
              ] as const
            ).map(([key, label, Icon]) => (
              <button
                key={key}
                onClick={() => setTab(key)}
                className={cn(
                  "inline-flex items-center gap-2 rounded-pill px-5 py-2 text-sm font-semibold",
                  tab === key ? "bg-gv-blue text-white" : "bg-white text-gv-blue hover:bg-white/70",
                )}
              >
                <Icon className="h-4 w-4" /> {label}
              </button>
            ))}
          </div>
          {tab === "customers" && <CustomersTab />}
          {tab === "invoices" && <InvoicesTab />}
          {tab === "reports" && <ReportsTab />}
        </>
      )}
    </div>
  );
}

// ── Clientes ─────────────────────────────────────────────────────────────

function CustomersTab() {
  const [q, setQ] = useState("");
  const [customers, setCustomers] = useState<Customer[] | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [showForm, setShowForm] = useState(false);

  const load = useCallback((search: string) => {
    api<{ customers: Customer[] }>(`/api/qbo/customers?q=${encodeURIComponent(search)}`).then(
      (r) => {
        setError(null);
        setCustomers(r.customers);
      },
      (e) => setError(e.message),
    );
  }, []);
  useEffect(() => load(""), [load]);

  return (
    <div className="space-y-4">
      <div className={card}>
        <div className="flex flex-wrap gap-2">
          <form
            className="flex flex-1 gap-2"
            onSubmit={(e) => {
              e.preventDefault();
              load(q);
            }}
          >
            <input className={input} placeholder="Buscar por nombre…" value={q} onChange={(e) => setQ(e.target.value)} />
            <BrandButton type="submit" variant="filled" className="px-5 py-2">
              Buscar
            </BrandButton>
          </form>
          <BrandButton variant="orange" className="px-5 py-2" onClick={() => setShowForm((v) => !v)}>
            <Plus className="h-4 w-4" /> Nuevo cliente
          </BrandButton>
        </div>
        {showForm && (
          <NewCustomerForm
            onCreated={() => {
              setShowForm(false);
              load(q);
            }}
          />
        )}
      </div>

      <div className={card}>
        {error && <p className="text-sm text-red-700">{error}</p>}
        {!customers && !error && <p className="text-sm text-gray-500">Cargando…</p>}
        {customers && (
          <table className="w-full text-sm">
            <thead className="text-left text-xs uppercase text-gray-500">
              <tr>
                <th className="py-2">Nombre</th>
                <th>Empresa</th>
                <th>Email</th>
                <th>Teléfono</th>
                <th className="text-right">Saldo</th>
              </tr>
            </thead>
            <tbody>
              {customers.map((c) => (
                <tr key={c.Id} className="border-t border-gray-100">
                  <td className="py-2 font-medium">{c.DisplayName}</td>
                  <td>{c.CompanyName ?? "—"}</td>
                  <td>{c.PrimaryEmailAddr?.Address ?? "—"}</td>
                  <td>{c.PrimaryPhone?.FreeFormNumber ?? "—"}</td>
                  <td className="text-right">{money(c.Balance, c.CurrencyRef?.value)}</td>
                </tr>
              ))}
              {customers.length === 0 && (
                <tr>
                  <td colSpan={5} className="py-4 text-center text-gray-500">
                    Sin resultados
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}

function NewCustomerForm({ onCreated }: { onCreated: () => void }) {
  const [f, setF] = useState({
    displayName: "",
    companyName: "",
    email: "",
    phone: "",
    addressLine1: "",
    city: "",
    country: "",
    postalCode: "",
  });
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  const set = (k: keyof typeof f) => (e: React.ChangeEvent<HTMLInputElement>) => setF({ ...f, [k]: e.target.value });

  async function submit(e: React.FormEvent) {
    e.preventDefault();
    setBusy(true);
    setError(null);
    try {
      await api("/api/qbo/customers", { method: "POST", body: JSON.stringify(f) });
      onCreated();
    } catch (err) {
      setError((err as Error).message);
    } finally {
      setBusy(false);
    }
  }

  const fields: [keyof typeof f, string][] = [
    ["displayName", "Nombre a mostrar *"],
    ["companyName", "Empresa"],
    ["email", "Email"],
    ["phone", "Teléfono"],
    ["addressLine1", "Dirección"],
    ["city", "Ciudad"],
    ["country", "País"],
    ["postalCode", "Código postal"],
  ];

  return (
    <form onSubmit={submit} className="mt-4 grid gap-3 border-t border-gray-100 pt-4 sm:grid-cols-2">
      {fields.map(([k, label]) => (
        <label key={k} className="text-xs text-gray-600">
          {label}
          <input className={cn(input, "mt-1")} value={f[k]} onChange={set(k)} required={k === "displayName"} />
        </label>
      ))}
      {error && <p className="text-sm text-red-700 sm:col-span-2">{error}</p>}
      <div className="sm:col-span-2">
        <BrandButton type="submit" variant="filled" className="px-6 py-2.5" disabled={busy}>
          Crear en QuickBooks
        </BrandButton>
      </div>
    </form>
  );
}

// ── Facturas ─────────────────────────────────────────────────────────────

function InvoicesTab() {
  const [invoices, setInvoices] = useState<Invoice[] | null>(null);
  const [openOnly, setOpenOnly] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [notice, setNotice] = useState<string | null>(null);
  const [showForm, setShowForm] = useState(false);

  const load = useCallback(() => {
    api<{ invoices: Invoice[] }>(`/api/qbo/invoices${openOnly ? "?open=1" : ""}`).then(
      (r) => {
        setError(null);
        setInvoices(r.invoices);
      },
      (e) => setError(e.message),
    );
  }, [openOnly]);
  useEffect(load, [load]);

  async function send(inv: Invoice) {
    if (!confirm(`¿Enviar la factura ${inv.DocNumber ?? inv.Id} por email desde QuickBooks?`)) return;
    setNotice(null);
    try {
      await api(`/api/qbo/invoices/${inv.Id}/send`, { method: "POST", body: "{}" });
      setNotice(`Factura ${inv.DocNumber ?? inv.Id} enviada.`);
      load();
    } catch (e) {
      setError((e as Error).message);
    }
  }

  return (
    <div className="space-y-4">
      <div className={cn(card, "flex flex-wrap items-center justify-between gap-3")}>
        <label className="flex items-center gap-2 text-sm text-gray-700">
          <input type="checkbox" checked={openOnly} onChange={(e) => setOpenOnly(e.target.checked)} />
          Solo con saldo pendiente
        </label>
        <div className="flex gap-2">
          <BrandButton variant="outline" className="!text-gv-blue !border-gv-blue px-4 py-2" onClick={load}>
            <RefreshCw className="h-4 w-4" />
          </BrandButton>
          <BrandButton variant="orange" className="px-5 py-2" onClick={() => setShowForm((v) => !v)}>
            <Plus className="h-4 w-4" /> Nueva factura
          </BrandButton>
        </div>
      </div>

      {showForm && (
        <NewInvoiceForm
          onCreated={(inv) => {
            setShowForm(false);
            setNotice(`Factura ${inv.DocNumber ?? inv.Id} creada por ${money(inv.TotalAmt, inv.CurrencyRef?.value)}.`);
            load();
          }}
        />
      )}

      <div className={card}>
        {notice && <p className="mb-3 text-sm text-green-700">{notice}</p>}
        {error && <p className="text-sm text-red-700">{error}</p>}
        {!invoices && !error && <p className="text-sm text-gray-500">Cargando…</p>}
        {invoices && (
          <table className="w-full text-sm">
            <thead className="text-left text-xs uppercase text-gray-500">
              <tr>
                <th className="py-2">N.º</th>
                <th>Cliente</th>
                <th>Fecha</th>
                <th>Vence</th>
                <th className="text-right">Total</th>
                <th className="text-right">Saldo</th>
                <th />
              </tr>
            </thead>
            <tbody>
              {invoices.map((i) => (
                <tr key={i.Id} className="border-t border-gray-100">
                  <td className="py-2 font-medium">{i.DocNumber ?? i.Id}</td>
                  <td>{i.CustomerRef.name ?? i.CustomerRef.value}</td>
                  <td>{i.TxnDate}</td>
                  <td>{i.DueDate ?? "—"}</td>
                  <td className="text-right">{money(i.TotalAmt, i.CurrencyRef?.value)}</td>
                  <td className={cn("text-right", i.Balance > 0 && "font-semibold text-gv-orange")}>
                    {money(i.Balance, i.CurrencyRef?.value)}
                  </td>
                  <td className="text-right">
                    <button
                      onClick={() => send(i)}
                      title={i.EmailStatus === "EmailSent" ? "Reenviar por email" : "Enviar por email"}
                      className="rounded p-1 text-gv-blue hover:bg-gv-bg-soft"
                    >
                      <Send className="h-4 w-4" />
                    </button>
                  </td>
                </tr>
              ))}
              {invoices.length === 0 && (
                <tr>
                  <td colSpan={7} className="py-4 text-center text-gray-500">
                    Sin facturas
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}

interface LineDraft {
  itemId: string;
  description: string;
  qty: string;
  unitPrice: string;
}

const emptyLine = (): LineDraft => ({ itemId: "", description: "", qty: "1", unitPrice: "" });

function NewInvoiceForm({ onCreated }: { onCreated: (inv: Invoice) => void }) {
  const [customers, setCustomers] = useState<Customer[]>([]);
  const [items, setItems] = useState<Item[]>([]);
  const [customerId, setCustomerId] = useState("");
  const [txnDate, setTxnDate] = useState(new Date().toISOString().slice(0, 10));
  const [dueDate, setDueDate] = useState("");
  const [memo, setMemo] = useState("");
  const [lines, setLines] = useState<LineDraft[]>([emptyLine()]);
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    api<{ customers: Customer[] }>("/api/qbo/customers").then((r) => setCustomers(r.customers), (e) => setError(e.message));
    api<{ items: Item[] }>("/api/qbo/items").then((r) => setItems(r.items), (e) => setError(e.message));
  }, []);

  const updateLine = (i: number, patch: Partial<LineDraft>) =>
    setLines((ls) => ls.map((l, j) => (j === i ? { ...l, ...patch } : l)));

  const total = lines.reduce((s, l) => s + (Number(l.qty) || 0) * (Number(l.unitPrice) || 0), 0);

  async function submit(e: React.FormEvent) {
    e.preventDefault();
    setBusy(true);
    setError(null);
    try {
      const r = await api<{ invoice: Invoice }>("/api/qbo/invoices", {
        method: "POST",
        body: JSON.stringify({
          customerId,
          txnDate,
          dueDate,
          memo,
          lines: lines.map((l) => ({ ...l, qty: Number(l.qty), unitPrice: Number(l.unitPrice) })),
        }),
      });
      onCreated(r.invoice);
    } catch (err) {
      setError((err as Error).message);
    } finally {
      setBusy(false);
    }
  }

  return (
    <form onSubmit={submit} className={cn(card, "space-y-4")}>
      <div className="grid gap-3 sm:grid-cols-3">
        <label className="text-xs text-gray-600">
          Cliente *
          <select className={cn(input, "mt-1")} value={customerId} onChange={(e) => setCustomerId(e.target.value)} required>
            <option value="">Seleccionar…</option>
            {customers.map((c) => (
              <option key={c.Id} value={c.Id}>
                {c.DisplayName}
              </option>
            ))}
          </select>
        </label>
        <label className="text-xs text-gray-600">
          Fecha
          <input type="date" className={cn(input, "mt-1")} value={txnDate} onChange={(e) => setTxnDate(e.target.value)} />
        </label>
        <label className="text-xs text-gray-600">
          Vencimiento
          <input type="date" className={cn(input, "mt-1")} value={dueDate} onChange={(e) => setDueDate(e.target.value)} />
        </label>
      </div>

      <div className="space-y-2">
        {lines.map((l, i) => (
          <div key={i} className="grid gap-2 sm:grid-cols-[2fr_3fr_1fr_1fr_auto]">
            <select
              className={input}
              value={l.itemId}
              required
              onChange={(e) => {
                const it = items.find((x) => x.Id === e.target.value);
                updateLine(i, {
                  itemId: e.target.value,
                  description: l.description || it?.Description || "",
                  unitPrice: l.unitPrice || (it?.UnitPrice != null ? String(it.UnitPrice) : ""),
                });
              }}
            >
              <option value="">Producto / servicio…</option>
              {items.map((it) => (
                <option key={it.Id} value={it.Id}>
                  {it.Name}
                </option>
              ))}
            </select>
            <input
              className={input}
              placeholder="Descripción (p.ej. Flete marítimo 1x40HC SHA→GYE)"
              value={l.description}
              onChange={(e) => updateLine(i, { description: e.target.value })}
            />
            <input
              className={input}
              type="number"
              min="0"
              step="any"
              placeholder="Cant."
              value={l.qty}
              required
              onChange={(e) => updateLine(i, { qty: e.target.value })}
            />
            <input
              className={input}
              type="number"
              min="0"
              step="0.01"
              placeholder="Precio"
              value={l.unitPrice}
              required
              onChange={(e) => updateLine(i, { unitPrice: e.target.value })}
            />
            <button
              type="button"
              disabled={lines.length === 1}
              onClick={() => setLines((ls) => ls.filter((_, j) => j !== i))}
              className="rounded p-2 text-gray-400 hover:text-red-600 disabled:opacity-30"
            >
              <Trash2 className="h-4 w-4" />
            </button>
          </div>
        ))}
        <button
          type="button"
          onClick={() => setLines((ls) => [...ls, emptyLine()])}
          className="inline-flex items-center gap-1 text-sm font-semibold text-gv-blue"
        >
          <Plus className="h-4 w-4" /> Agregar línea
        </button>
      </div>

      <label className="block text-xs text-gray-600">
        Mensaje al cliente
        <input className={cn(input, "mt-1")} value={memo} onChange={(e) => setMemo(e.target.value)} />
      </label>

      {error && <p className="text-sm text-red-700">{error}</p>}
      <div className="flex items-center justify-between">
        <p className="text-sm text-gray-700">
          Subtotal: <span className="font-semibold">{money(total)}</span>{" "}
          <span className="text-xs text-gray-500">(impuestos según configuración de QuickBooks)</span>
        </p>
        <BrandButton type="submit" variant="filled" className="px-6 py-2.5" disabled={busy}>
          Crear factura
        </BrandButton>
      </div>
    </form>
  );
}

// ── Reportes ─────────────────────────────────────────────────────────────

function ReportsTab() {
  const today = new Date().toISOString().slice(0, 10);
  const [name, setName] = useState<ReportName>("ProfitAndLoss");
  const [start, setStart] = useState(today.slice(0, 4) + "-01-01");
  const [end, setEnd] = useState(today);
  const [report, setReport] = useState<Report | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  async function run(e?: React.FormEvent) {
    e?.preventDefault();
    setBusy(true);
    setError(null);
    try {
      const qs = new URLSearchParams({ name, start, end });
      setReport((await api<{ report: Report }>(`/api/qbo/reports?${qs}`)).report);
    } catch (err) {
      setError((err as Error).message);
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="space-y-4">
      <form onSubmit={run} className={cn(card, "grid gap-3 sm:grid-cols-[2fr_1fr_1fr_auto] sm:items-end")}>
        <label className="text-xs text-gray-600">
          Reporte
          <select className={cn(input, "mt-1")} value={name} onChange={(e) => setName(e.target.value as ReportName)}>
            {REPORT_OPTIONS.map((r) => (
              <option key={r.value} value={r.value}>
                {r.label}
              </option>
            ))}
          </select>
        </label>
        <label className="text-xs text-gray-600">
          Desde
          <input type="date" className={cn(input, "mt-1")} value={start} onChange={(e) => setStart(e.target.value)} />
        </label>
        <label className="text-xs text-gray-600">
          Hasta
          <input type="date" className={cn(input, "mt-1")} value={end} onChange={(e) => setEnd(e.target.value)} />
        </label>
        <BrandButton type="submit" variant="filled" className="px-6 py-2.5" disabled={busy}>
          Generar
        </BrandButton>
      </form>

      {error && <p className="text-sm text-red-700">{error}</p>}
      {report && (
        <div className={cn(card, "overflow-x-auto")}>
          <p className="font-semibold text-gv-blue">{report.name}</p>
          <p className="text-xs text-gray-500">
            {report.startPeriod} → {report.endPeriod} {report.currency && `· ${report.currency}`}
          </p>
          <table className="mt-4 w-full text-sm">
            <thead className="text-left text-xs uppercase text-gray-500">
              <tr>
                {report.columns.map((c, i) => (
                  <th key={i} className={cn("py-2", i > 0 && "text-right")}>
                    {c}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {report.rows.map((r, i) => (
                <tr
                  key={i}
                  className={cn(
                    "border-t border-gray-100",
                    r.kind === "header" && "font-semibold text-gv-blue",
                    r.kind === "total" && "font-semibold bg-gv-bg-soft",
                  )}
                >
                  {r.cells.map((c, j) => (
                    <td
                      key={j}
                      className={cn("py-1.5", j > 0 && "text-right tabular-nums")}
                      style={j === 0 ? { paddingLeft: `${r.depth * 16}px` } : undefined}
                    >
                      {c}
                    </td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
