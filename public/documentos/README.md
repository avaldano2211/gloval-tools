# Documentos para clientes

Esta carpeta sirve los archivos de la herramienta **Centro de Documentos**
(`/herramientas/documentos`).

## Cómo agregar un documento real

1. Subí el archivo a esta carpeta usando **exactamente** el filename listado
   en `src/lib/documents.ts` para ese documento. Ejemplos:
   - `POA_Gloval_Shipping.pdf`
   - `SLI_Shipper_Letter_of_Instructions.pdf`
   - `SI_Shipping_Instructions.pdf`
   - `Directorio_Oficinas_Gloval.pdf`
   - …etc.
2. Abrí `src/lib/documents.ts` y cambiá la entrada correspondiente:
   ```ts
   placeholder: true   →   placeholder: false
   ```
   Opcionalmente agregá `sizeKb` con el tamaño del archivo.
3. Commit + deploy. La card pasa de "Próximamente" a un botón "Descargar"
   funcional.

## ¿Cómo agregar un documento nuevo (que no está en el catálogo)?

Editá `src/lib/documents.ts` y agregá una entrada nueva al array `DOCUMENTS`:

```ts
{
  id: "mi-documento",
  title: "Mi documento nuevo",
  description: "…",
  category: "operaciones" | "aduanas" | "comercial" | "contactos",
  language: "es" | "en" | "es-en",
  format: "PDF" | "DOCX" | "XLSX" | "ZIP",
  filename: "Mi_Documento.pdf",
  placeholder: false,  // si ya subiste el archivo
}
```

## Notas

- Los archivos en esta carpeta se sirven públicamente — no subir documentos
  con datos sensibles (contratos firmados, POAs ya completados, info de
  clientes específicos). Solo plantillas en blanco / información general.
- Vercel sirve estos archivos con cache de 1 año. Si actualizás un archivo,
  cambiá el filename para evitar problemas de cache (ej:
  `POA_Gloval_Shipping_v2.pdf`) y actualizá `src/lib/documents.ts`.
