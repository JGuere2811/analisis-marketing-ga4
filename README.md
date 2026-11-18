# ¿Qué canales traen clientes que sí compran? · Análisis de GA4 en BigQuery

> 📄 **[Leer el informe completo →](informe.md)** · Avance 1 de 3 publicado (exploración). Semanas 2 y 3 en curso.

## La pregunta de negocio
Una tienda en línea invierte tiempo y dinero en varios canales (búsqueda orgánica, anuncios, referencias, correo…). La pregunta es simple:

**¿Qué canales traen visitas que terminan en compra, y en qué paso del camino se pierde la gente?**

## Los datos
- **Fuente:** dataset público de ejemplo de Google Analytics 4 de la *Google Merchandise Store*, publicado por Google en BigQuery:
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce`
- **Periodo:** 1 de noviembre de 2020 al 31 de enero de 2021 (incluye Black Friday y Navidad).
- **Formato:** una tabla por día (`events_YYYYMMDD`), con un registro por evento (vista de página, carrito, compra…).
- **Privacidad:** Google ofusca los datos; algunos valores aparecen como `<Other>` o `(data deleted)`. No hay datos personales.

### Limitaciones que hay que tener en cuenta
- `traffic_source` indica el **canal por el que llegó el usuario la primera vez**, no el de cada visita. Por eso aquí se habla de *canal de adquisición del usuario*.
- El dataset **no incluye el gasto en publicidad**. Si más adelante se estima un costo por canal, se indicará claramente como **dato simulado**.

## Cómo reproducirlo
1. Entra a [BigQuery](https://console.cloud.google.com/bigquery) con una cuenta de Google. El modo *sandbox* es gratuito y no pide tarjeta.
2. Copia cada archivo de la carpeta [`sql/`](sql) en el editor y ejecútalo.
3. Antes de ejecutar, BigQuery muestra cuántos datos va a leer; todas estas consultas están muy por debajo del límite gratuito (1 TB al mes).

## Estructura
```
sql/
  01_panorama_eventos.sql   ← qué eventos existen y cuántos usuarios los generan
  02_canales.sql            ← usuarios, sesiones, compras e ingresos por canal
  03_dispositivos.sql       ← lo mismo, por tipo de dispositivo
resultados/                 ← resultados de cada consulta en CSV
informe.md                  ← el estudio: hallazgos, gráficos y limitaciones
graficos/                   ← gráficos del informe (SVG)
scripts/graficos.mjs        ← genera los gráficos desde los CSV (node scripts/graficos.mjs)
notas/
  semana-1.md               ← guía de trabajo y preguntas de la semana
dashboard/                  ← (semana 3) dashboard y capturas
```

## Plan
| Semana | Entregable |
|---|---|
| 1 ✅ | Exploración: eventos y canales → [informe, avance 1](informe.md) |
| 2 | Dispositivos, embudo de compra (vista → carrito → pago → compra) y cohortes de retención |
| 3 | Dashboard (resumen, embudo, canales), informe de una página y conclusiones |

## Hallazgos principales (avance 1)
![Embudo de compra](graficos/embudo.svg)

- **Solo el 1,6 % de los visitantes compra**, y la mayor fuga está **antes del carrito**: el 77 % no abre ningún producto.
- **En el pago, el 41 % abandona** entre los datos de envío y los de pago.
- **Google orgánico** trae el 31 % de las visitas, pero convierte por debajo del promedio (1,29 % frente a 1,58 %).
- **Los anuncios de Google** tienen la conversión (1,06 %) y el ticket (USD 54,6) más bajos.
- **El 8 % de las sesiones son autorreferencias**: un error de medición que le quita el crédito a los canales reales.

👉 Detalle, gráficos, tablas y limitaciones en el **[informe](informe.md)**.

## Herramientas
SQL (BigQuery) · Google Analytics 4 · Power BI / Looker Studio

---
Autor: **Jose Manuel Güere Casas** · [Portafolio](https://jguere2811.github.io)
