# Semana 3 · Dashboard e informe ejecutivo

**Entregado:**
- [Dashboard interactivo](https://jguere2811.github.io/proyectos/dashboard-ga4.html) (HTML + SVG + JavaScript): se abre desde cualquier navegador, sin cuenta de Power BI.
- [Informe ejecutivo de una página](../informe-ejecutivo.pdf): se genera desde `informe-ejecutivo.html` imprimiéndolo a PDF.

## Práctica: replicar el dashboard en Power BI (2 a 3 horas)
Sirve para practicar para el examen **PL-300** y para tener capturas de Power BI en el portafolio.

1. **Obtener datos → Texto/CSV** y carga los archivos de `resultados/`:
   `02b_canales_agrupados.csv`, `03_dispositivos.csv`, `04_embudo_secuencial.csv`, `05_cohortes.csv`.
2. En **Power Query**, revisa los tipos: números como *Número decimal*, `cohorte` como *Fecha*.
3. Crea estas **medidas DAX** en la tabla de canales:
   ```DAX
   Sesiones = SUM('02b_canales_agrupados'[sesiones])
   Compras = SUM('02b_canales_agrupados'[compras])
   Ingresos = SUM('02b_canales_agrupados'[ingresos_usd])
   Conversión % = DIVIDE([Compras], [Sesiones])
   Ticket promedio = DIVIDE([Ingresos], [Compras])
   ```
4. **Página 1 · Resumen:** 4 tarjetas (Sesiones, Compras, Conversión %, Ingresos) y un gráfico de barras horizontales del embudo (`paso` contra `usuarios`).
5. **Página 2 · Canales:** barras de `Conversión %` por canal, con una **línea de referencia** en 1,58 % (panel de análisis → *Línea constante*), y un segmentador para elegir la métrica.
6. **Página 3 · Retención:** una **matriz** con `cohorte` en filas y las columnas `volvio_dias_*`, con **formato condicional → escala de colores** en un solo tono de azul.
7. Guarda el archivo como `dashboard/analisis-ga4.pbix`, saca una captura de cada página y súbelas a `dashboard/`.

## ✅ Listo cuando
- [x] Dashboard web publicado en el portafolio
- [x] Informe de una página en PDF
- [ ] (Opcional) Versión en Power BI con capturas en `dashboard/`
