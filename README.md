# ¿Qué canales traen clientes que sí compran? · Análisis de GA4 en BigQuery

> 🚧 **Proyecto en curso — semana 1 de 3.** Los hallazgos se completan a medida que avanza el análisis.

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
notas/
  semana-1.md               ← guía de trabajo y preguntas de la semana
dashboard/                  ← (semana 3) dashboard y capturas
```

## Plan
| Semana | Entregable |
|---|---|
| 1 | Exploración: eventos, canales y dispositivos |
| 2 | Embudo de compra (vista → carrito → pago → compra) y cohortes de retención |
| 3 | Dashboard (resumen, embudo, canales), informe de una página y conclusiones |

## Hallazgos
*Se completan al terminar cada semana.*

## Herramientas
SQL (BigQuery) · Google Analytics 4 · Power BI / Looker Studio

---
Autor: **Jose Manuel Güere Casas** · [Portafolio](https://jguere2811.github.io)
