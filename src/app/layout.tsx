import type { Metadata } from "next";
import { Poppins } from "next/font/google";
import "./globals.css";
import { BrandHeader } from "@/components/brand/BrandHeader";
import { BrandFooter } from "@/components/brand/BrandFooter";

const poppins = Poppins({
  variable: "--font-poppins",
  subsets: ["latin"],
  weight: ["300", "400", "500", "600", "700"],
  display: "swap",
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
    <html lang="es" className={`${poppins.variable} h-full antialiased`}>
      <body className="min-h-full flex flex-col">
        <BrandHeader />
        {/* Header es fixed; el hub mete el hero por debajo (transparent header).
            Las páginas internas agregan su propio pt-24 en el wrapper raíz. */}
        <main className="flex-1">{children}</main>
        <BrandFooter />
      </body>
    </html>
  );
}
