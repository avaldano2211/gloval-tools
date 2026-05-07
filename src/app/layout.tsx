import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import { BrandHeader } from "@/components/brand/BrandHeader";
import { BrandFooter } from "@/components/brand/BrandFooter";

const inter = Inter({
  variable: "--font-inter",
  subsets: ["latin"],
  weight: ["400", "500", "600", "700", "800"],
});

export const metadata: Metadata = {
  title: "Herramientas Gloval Shipping",
  description:
    "Herramientas gratuitas para tu logística internacional: especificaciones de contenedores, calculadora de cubicaje, rastreo, Incoterms 2020, UN/LOCODE, IMO/IMDG.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="es" className={`${inter.variable} h-full antialiased`}>
      <body className="min-h-full flex flex-col">
        <BrandHeader />
        <main className="flex-1">{children}</main>
        <BrandFooter />
      </body>
    </html>
  );
}
