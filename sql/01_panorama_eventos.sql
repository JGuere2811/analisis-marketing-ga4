-- 01 · Panorama de eventos
-- Pregunta: ¿qué cosas hace la gente en la tienda y cuántas personas las hacen?
--
-- En GA4 todo es un "evento": ver una página (page_view), ver un producto (view_item),
-- añadir al carrito (add_to_cart), iniciar el pago (begin_checkout), comprar (purchase)...
-- Esta consulta cuenta cada tipo de evento y cuántos usuarios distintos lo generaron.

SELECT
  event_name                          AS evento,
  COUNT(*)                            AS veces,            -- total de eventos
  COUNT(DISTINCT user_pseudo_id)      AS usuarios          -- personas (navegadores) distintas
FROM
  -- El asterisco junta todas las tablas diarias events_20201101, events_20201102, ...
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE
  -- _TABLE_SUFFIX es la parte de la fecha del nombre de cada tabla: así limitamos el periodo.
  _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
GROUP BY
  evento
ORDER BY
  veces DESC;

-- 📝 Para pensar:
--   1. ¿Cuántos usuarios vieron una página y cuántos compraron? ¿Qué porcentaje es?
--   2. Ordena mentalmente estos eventos como pasos de una compra. ¿Dónde se cae más gente?
