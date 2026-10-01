#!/usr/bin/env node
// Daily audit: Warehouse Receipts in Magaya (Miami) whose consignee matches a
// rule (e.g. ILGUECORP) but whose Destination Agent is missing or wrong, so the
// destination office (Magaya Ecuador) can't see them. Sends an Outlook alert.
//
// Usage:
//   node audit.mjs                 # query Magaya API, email if issues found
//   node audit.mjs --dry-run       # query Magaya API, print only
//   node audit.mjs --file wr.xml   # audit a saved WarehouseReceipts XML (no API)
//
// No dependencies; Node 20+ (global fetch).

import { readFile, writeFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import path from "node:path";

const here = path.dirname(fileURLToPath(import.meta.url));
const args = process.argv.slice(2);
const DRY_RUN = args.includes("--dry-run");
const fileArg = args.includes("--file") ? args[args.indexOf("--file") + 1] : null;

// ---------- Magaya SOAP API (CSSoapService) ----------
// NOTE: method/parameter names follow Magaya's documented CSSoapService API.
// Verify against your server's WSDL (http://<host>:<port>/CSSoapService?wsdl).

function env(name, required = true) {
  const v = process.env[name];
  if (required && !v) throw new Error(`Missing env var ${name}`);
  return v;
}

const xmlEscape = (s) =>
  String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");

function xmlUnescape(s) {
  return s
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&quot;/g, '"')
    .replace(/&apos;/g, "'")
    .replace(/&#(\d+);/g, (_, n) => String.fromCharCode(Number(n)))
    .replace(/&amp;/g, "&");
}

async function soapCall(method, params) {
  const url = env("MAGAYA_API_URL"); // e.g. http://1.2.3.4:3691/CSSoapService
  const body =
    `<?xml version="1.0" encoding="utf-8"?>` +
    `<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:CSSoapService">` +
    `<soapenv:Body><urn:${method}>` +
    Object.entries(params)
      .map(([k, v]) => `<${k}>${xmlEscape(v)}</${k}>`)
      .join("") +
    `</urn:${method}></soapenv:Body></soapenv:Envelope>`;

  const res = await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "text/xml; charset=utf-8",
      SOAPAction: `"urn:CSSoapService#${method}"`,
    },
    body,
  });
  const text = await res.text();
  if (!res.ok) throw new Error(`Magaya ${method} HTTP ${res.status}: ${text.slice(0, 500)}`);
  return text;
}

function soapOut(xml, tag) {
  const m = xml.match(new RegExp(`<(?:\\w+:)?${tag}[^>]*>([\\s\\S]*?)</(?:\\w+:)?${tag}>`));
  return m ? m[1] : "";
}

async function fetchWarehouseReceiptsXml(lookbackDays) {
  const startRes = await soapCall("StartSession", {
    user: env("MAGAYA_USER"),
    pass: env("MAGAYA_PASS"),
  });
  const key = soapOut(startRes, "access_key");
  if (!key) throw new Error(`StartSession failed: ${startRes.slice(0, 500)}`);

  try {
    const end = new Date();
    const start = new Date(end.getTime() - lookbackDays * 86400000);
    const ymd = (d) => d.toISOString().slice(0, 10);
    const res = await soapCall("GetTransRangeByDate", {
      access_key: key,
      type: "WH", // Warehouse Receipts
      start_date: ymd(start),
      end_date: ymd(end),
      flags: process.env.MAGAYA_FLAGS ?? "0",
    });
    const list = soapOut(res, "trans_list_xml");
    if (!list) throw new Error(`GetTransRangeByDate returned no data: ${res.slice(0, 500)}`);
    return xmlUnescape(list);
  } finally {
    await soapCall("EndSession", { access_key: key }).catch(() => {});
  }
}

// ---------- XML parsing (minimal, no deps) ----------

function blocks(xml, tag) {
  const re = new RegExp(`<${tag}(?:\\s[^>]*)?>([\\s\\S]*?)</${tag}>`, "g");
  return [...xml.matchAll(re)].map((m) => m[1]);
}

function text(xml, ...paths) {
  // Returns the first non-empty value among paths like "DestinationAgentName"
  // or "DestinationAgent/Name".
  for (const p of paths) {
    let cur = xml;
    for (const part of p.split("/")) {
      const b = blocks(cur, part)[0];
      if (b === undefined) {
        cur = null;
        break;
      }
      cur = b;
    }
    if (cur && !cur.includes("<")) {
      const v = xmlUnescape(cur).trim();
      if (v) return v;
    }
  }
  return "";
}

export function parseReceipts(xml) {
  return blocks(xml, "WarehouseReceipt").map((wr) => ({
    number: text(wr, "Number"),
    date: text(wr, "CreatedOn", "CreatedDate").slice(0, 10),
    status: text(wr, "Status"),
    shipper: text(wr, "ShipperName", "Shipper/Name"),
    consignee: text(wr, "ConsigneeName", "Consignee/Name"),
    destinationAgent: text(wr, "DestinationAgentName", "DestinationAgent/Name"),
    pieces: text(wr, "TotalPieces"),
    weight: text(wr, "TotalWeight"),
  }));
}

// ---------- Rules ----------

const norm = (s) => s.toUpperCase().replace(/\s+/g, " ").trim();
const normStatus = (s) => s.toLowerCase().replace(/[\s_-]/g, "");

export function audit(receipts, config) {
  const ignored = new Set((config.ignoreStatuses ?? []).map(normStatus));
  const issues = [];
  for (const wr of receipts) {
    if (ignored.has(normStatus(wr.status))) continue;
    for (const rule of config.rules) {
      const hit = rule.consigneeContains.some((c) => norm(wr.consignee).includes(norm(c)));
      if (!hit) continue;
      const agent = norm(wr.destinationAgent);
      const ok = rule.expectedDestinationAgentContains.some((a) => agent.includes(norm(a)));
      if (!ok) {
        issues.push({
          ...wr,
          rule: rule.name,
          problem: agent ? "Agente destino incorrecto" : "Sin agente destino",
        });
      }
    }
  }
  return issues;
}

// ---------- Report + Outlook (Microsoft Graph) ----------

function htmlReport(issues) {
  const cell = (v) => `<td style="border:1px solid #ccc;padding:4px 8px">${xmlEscape(v || "—")}</td>`;
  const rows = issues
    .map((i) =>
      `<tr>${[i.number, i.date, i.status, i.shipper, i.consignee, i.destinationAgent, i.problem, i.rule]
        .map(cell)
        .join("")}</tr>`,
    )
    .join("");
  const head = ["WR", "Fecha", "Status", "Shipper", "Consignee", "Agente destino actual", "Problema", "Regla"]
    .map((h) => `<th style="border:1px solid #ccc;padding:4px 8px;background:#003DA5;color:#fff">${h}</th>`)
    .join("");
  return (
    `<p>Se encontraron <b>${issues.length}</b> Warehouse Receipts sin el agente de destino correcto. ` +
    `No son visibles para la oficina de destino hasta corregirlos en Magaya.</p>` +
    `<table style="border-collapse:collapse;font-family:Arial;font-size:12px"><tr>${head}</tr>${rows}</table>`
  );
}

async function sendOutlook(subject, html) {
  const tenant = env("GRAPH_TENANT_ID");
  const tokenRes = await fetch(`https://login.microsoftonline.com/${tenant}/oauth2/v2.0/token`, {
    method: "POST",
    body: new URLSearchParams({
      client_id: env("GRAPH_CLIENT_ID"),
      client_secret: env("GRAPH_CLIENT_SECRET"),
      scope: "https://graph.microsoft.com/.default",
      grant_type: "client_credentials",
    }),
  });
  const token = (await tokenRes.json()).access_token;
  if (!token) throw new Error(`Graph token failed (HTTP ${tokenRes.status})`);

  const to = env("ALERT_TO").split(",").map((a) => ({ emailAddress: { address: a.trim() } }));
  const res = await fetch(
    `https://graph.microsoft.com/v1.0/users/${encodeURIComponent(env("ALERT_FROM"))}/sendMail`,
    {
      method: "POST",
      headers: { Authorization: `Bearer ${token}`, "Content-Type": "application/json" },
      body: JSON.stringify({
        message: { subject, body: { contentType: "HTML", content: html }, toRecipients: to },
        saveToSentItems: true,
      }),
    },
  );
  if (!res.ok) throw new Error(`Graph sendMail HTTP ${res.status}: ${await res.text()}`);
}

// ---------- Main ----------

async function main() {
  const config = JSON.parse(await readFile(path.join(here, "rules.json"), "utf8"));
  const xml = fileArg
    ? await readFile(fileArg, "utf8")
    : await fetchWarehouseReceiptsXml(config.lookbackDays);

  const receipts = parseReceipts(xml);
  if (receipts.length === 0) {
    // Guard: an empty parse usually means the XML shape differs from what we expect.
    throw new Error("No WarehouseReceipt elements parsed — check API flags / XML format.");
  }
  if (receipts.every((r) => !r.consignee)) {
    throw new Error("Parsed receipts but no consignee names — check field mapping in parseReceipts().");
  }

  const issues = audit(receipts, config);
  console.log(`Receipts checked: ${receipts.length}. Issues: ${issues.length}.`);
  for (const i of issues) {
    console.log(`  WR ${i.number} ${i.date} [${i.status}] ${i.consignee} -> agent: "${i.destinationAgent}" (${i.problem})`);
  }

  const html = htmlReport(issues);
  await writeFile(path.join(here, "last-report.html"), html);

  if (issues.length === 0 || DRY_RUN || fileArg) return;
  await sendOutlook(`[Magaya] ${issues.length} WR sin agente destino correcto`, html);
  console.log("Alert email sent.");
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main().catch((err) => {
    console.error(err.message);
    process.exit(1);
  });
}
