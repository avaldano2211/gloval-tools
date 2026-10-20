import { getQboConfig, QBO_MINOR_VERSION } from "./config";
import { getValidTokens } from "./oauth";

export class QboError extends Error {
  constructor(
    message: string,
    public status: number,
    public intuitTid?: string | null,
  ) {
    super(message);
  }
}

interface QboFault {
  Fault?: { Error?: { Message?: string; Detail?: string; code?: string }[] };
}

async function qboFetch<T>(path: string, init: RequestInit = {}, params: Record<string, string> = {}): Promise<T> {
  const tokens = await getValidTokens();
  if (!tokens) throw new QboError("QuickBooks no está conectado", 409);
  const { apiBase } = getQboConfig();
  const url = new URL(`${apiBase}/v3/company/${tokens.realmId}/${path}`);
  url.search = new URLSearchParams({ ...params, minorversion: QBO_MINOR_VERSION }).toString();

  const res = await fetch(url, {
    ...init,
    headers: {
      Authorization: `Bearer ${tokens.accessToken}`,
      Accept: "application/json",
      ...(init.body ? { "Content-Type": "application/json" } : {}),
      ...init.headers,
    },
    cache: "no-store",
  });
  const json = (await res.json().catch(() => ({}))) as T & QboFault;
  if (!res.ok || json.Fault) {
    const e = json.Fault?.Error?.[0];
    const msg = e ? [e.Message, e.Detail].filter(Boolean).join(" — ") : `HTTP ${res.status}`;
    throw new QboError(msg, res.ok ? 400 : res.status, res.headers.get("intuit_tid"));
  }
  return json;
}

/** Escapa un literal para el lenguaje de consultas de QBO. */
function q(s: string): string {
  return s.replace(/\\/g, "\\\\").replace(/'/g, "\\'");
}

async function query<T>(entity: string, sql: string): Promise<T[]> {
  const r = await qboFetch<{ QueryResponse: Record<string, T[] | undefined> }>("query", {}, { query: sql });
  return r.QueryResponse[entity] ?? [];
}

// ── Info de la empresa ───────────────────────────────────────────────────

export interface CompanyInfo {
  CompanyName: string;
  LegalName?: string;
  Country?: string;
}

export async function getCompanyInfo(): Promise<CompanyInfo | null> {
  const [c] = await query<CompanyInfo>("CompanyInfo", "SELECT * FROM CompanyInfo");
  return c ?? null;
}

// ── Clientes ─────────────────────────────────────────────────────────────

export interface Customer {
  Id: string;
  SyncToken: string;
  DisplayName: string;
  CompanyName?: string;
  PrimaryEmailAddr?: { Address: string };
  PrimaryPhone?: { FreeFormNumber: string };
  Balance?: number;
  CurrencyRef?: { value: string };
  Active?: boolean;
}

export async function listCustomers(search?: string): Promise<Customer[]> {
  const where = search ? ` WHERE DisplayName LIKE '%${q(search)}%'` : "";
  return query<Customer>("Customer", `SELECT * FROM Customer${where} ORDERBY DisplayName MAXRESULTS 100`);
}

export interface NewCustomer {
  displayName: string;
  companyName?: string;
  email?: string;
  phone?: string;
  taxId?: string;
  address?: { line1?: string; city?: string; country?: string; postalCode?: string };
}

export async function createCustomer(c: NewCustomer): Promise<Customer> {
  const body: Record<string, unknown> = { DisplayName: c.displayName };
  if (c.companyName) body.CompanyName = c.companyName;
  if (c.email) body.PrimaryEmailAddr = { Address: c.email };
  if (c.phone) body.PrimaryPhone = { FreeFormNumber: c.phone };
  if (c.address && Object.values(c.address).some(Boolean)) {
    body.BillAddr = {
      Line1: c.address.line1,
      City: c.address.city,
      Country: c.address.country,
      PostalCode: c.address.postalCode,
    };
  }
  const r = await qboFetch<{ Customer: Customer }>("customer", { method: "POST", body: JSON.stringify(body) });
  return r.Customer;
}

// ── Productos / servicios ────────────────────────────────────────────────

export interface Item {
  Id: string;
  Name: string;
  Type: string;
  UnitPrice?: number;
  Description?: string;
}

export async function listItems(): Promise<Item[]> {
  return query<Item>("Item", "SELECT * FROM Item WHERE Active = true ORDERBY Name MAXRESULTS 200");
}

// ── Facturas ─────────────────────────────────────────────────────────────

export interface Invoice {
  Id: string;
  DocNumber?: string;
  TxnDate: string;
  DueDate?: string;
  TotalAmt: number;
  Balance: number;
  CustomerRef: { value: string; name?: string };
  CurrencyRef?: { value: string };
  EmailStatus?: string;
}

export async function listInvoices(opts: { customerId?: string; openOnly?: boolean } = {}): Promise<Invoice[]> {
  const conds: string[] = [];
  if (opts.customerId) conds.push(`CustomerRef = '${q(opts.customerId)}'`);
  if (opts.openOnly) conds.push("Balance > '0'");
  const where = conds.length ? ` WHERE ${conds.join(" AND ")}` : "";
  return query<Invoice>("Invoice", `SELECT * FROM Invoice${where} ORDERBY TxnDate DESC MAXRESULTS 100`);
}

export interface NewInvoiceLine {
  itemId: string;
  description?: string;
  qty: number;
  unitPrice: number;
}

export interface NewInvoice {
  customerId: string;
  txnDate?: string;
  dueDate?: string;
  memo?: string;
  email?: string;
  lines: NewInvoiceLine[];
}

const round2 = (n: number) => Math.round(n * 100) / 100;

export async function createInvoice(inv: NewInvoice): Promise<Invoice> {
  const body: Record<string, unknown> = {
    CustomerRef: { value: inv.customerId },
    Line: inv.lines.map((l) => ({
      DetailType: "SalesItemLineDetail",
      Amount: round2(l.qty * l.unitPrice),
      Description: l.description || undefined,
      SalesItemLineDetail: { ItemRef: { value: l.itemId }, Qty: l.qty, UnitPrice: l.unitPrice },
    })),
  };
  if (inv.txnDate) body.TxnDate = inv.txnDate;
  if (inv.dueDate) body.DueDate = inv.dueDate;
  if (inv.memo) body.CustomerMemo = { value: inv.memo };
  if (inv.email) body.BillEmail = { Address: inv.email };
  const r = await qboFetch<{ Invoice: Invoice }>("invoice", { method: "POST", body: JSON.stringify(body) });
  return r.Invoice;
}

/** Envía la factura por email desde QuickBooks. */
export async function sendInvoice(id: string, email?: string): Promise<Invoice> {
  const r = await qboFetch<{ Invoice: Invoice }>(
    `invoice/${encodeURIComponent(id)}/send`,
    { method: "POST", headers: { "Content-Type": "application/octet-stream" } },
    email ? { sendTo: email } : {},
  );
  return r.Invoice;
}

// ── Reportes ─────────────────────────────────────────────────────────────

export const REPORTS = {
  ProfitAndLoss: "Estado de resultados (P&L)",
  BalanceSheet: "Balance general",
  AgedReceivables: "Cuentas por cobrar (antigüedad)",
  CustomerBalance: "Saldo por cliente",
} as const;

export type ReportName = keyof typeof REPORTS;

export function isReportName(s: string): s is ReportName {
  return Object.prototype.hasOwnProperty.call(REPORTS, s);
}

interface RawColData { value?: string }
interface RawRow {
  type?: string;
  ColData?: RawColData[];
  Header?: { ColData?: RawColData[] };
  Rows?: { Row?: RawRow[] };
  Summary?: { ColData?: RawColData[] };
}
interface RawReport {
  Header?: { ReportName?: string; StartPeriod?: string; EndPeriod?: string; Currency?: string };
  Columns?: { Column?: { ColTitle?: string }[] };
  Rows?: { Row?: RawRow[] };
}

export interface ReportRow {
  depth: number;
  kind: "header" | "data" | "total";
  cells: string[];
}

export interface Report {
  name: string;
  startPeriod?: string;
  endPeriod?: string;
  currency?: string;
  columns: string[];
  rows: ReportRow[];
}

function flatten(rows: RawRow[] | undefined, depth: number, out: ReportRow[]) {
  for (const r of rows ?? []) {
    const cells = (c?: RawColData[]) => (c ?? []).map((x) => x.value ?? "");
    if (r.ColData) out.push({ depth, kind: "data", cells: cells(r.ColData) });
    if (r.Header?.ColData) out.push({ depth, kind: "header", cells: cells(r.Header.ColData) });
    flatten(r.Rows?.Row, depth + 1, out);
    if (r.Summary?.ColData) out.push({ depth, kind: "total", cells: cells(r.Summary.ColData) });
  }
}

export async function getReport(
  name: ReportName,
  params: { startDate?: string; endDate?: string } = {},
): Promise<Report> {
  const p: Record<string, string> = {};
  if (params.startDate) p.start_date = params.startDate;
  if (params.endDate) p.end_date = params.endDate;
  const raw = await qboFetch<RawReport>(`reports/${name}`, {}, p);
  const rows: ReportRow[] = [];
  flatten(raw.Rows?.Row, 0, rows);
  return {
    name: raw.Header?.ReportName ?? name,
    startPeriod: raw.Header?.StartPeriod,
    endPeriod: raw.Header?.EndPeriod,
    currency: raw.Header?.Currency,
    columns: (raw.Columns?.Column ?? []).map((c) => c.ColTitle ?? ""),
    rows,
  };
}
