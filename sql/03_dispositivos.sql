-- 03 · Rendimiento por dispositivo
-- Pregunta: ¿se compra igual desde el celular que desde la computadora?
--
-- Misma lógica que 02_canales.sql, pero agrupando por tipo de dispositivo.
-- Añade el ingreso promedio por sesión: cuánto "vale" en promedio cada visita.

WITH eventos AS (
  SELECT
    user_pseudo_id,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS id_sesion,
    device.category                     AS dispositivo,   -- desktop, mobile, tablet
    event_name,
    ecommerce.purchase_revenue_in_usd   AS ingreso
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE
    _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
),

resumen AS (
  SELECT
    dispositivo,
    COUNT(DISTINCT user_pseudo_id)                                        AS usuarios,
    COUNT(DISTINCT CONCAT(user_pseudo_id, '-', CAST(id_sesion AS STRING))) AS sesiones,
    COUNTIF(event_name = 'add_to_cart')                                   AS anadidos_carrito,
    COUNTIF(event_name = 'purchase')                                      AS compras,
    SUM(IF(event_name = 'purchase', ingreso, 0))                          AS ingresos_usd
  FROM
    eventos
  GROUP BY
    dispositivo
)

SELECT
  dispositivo,
  usuarios,
  sesiones,
  anadidos_carrito,
  compras,
  ROUND(ingresos_usd, 2)                              AS ingresos_usd,
  ROUND(100 * SAFE_DIVIDE(compras, sesiones), 2)      AS conversion_pct,
  ROUND(SAFE_DIVIDE(ingresos_usd, sesiones), 2)       AS ingreso_por_sesion_usd,
  -- Participación: qué parte del total de sesiones viene de cada dispositivo.
  -- SUM(...) OVER () suma todas las filas sin agruparlas (función de ventana).
  ROUND(100 * sesiones / SUM(sesiones) OVER (), 1)    AS participacion_sesiones_pct
FROM
  resumen
ORDER BY
  sesiones DESC;

-- 📝 Para pensar:
--   1. ¿Qué dispositivo tiene más sesiones? ¿Y cuál convierte mejor?
--   2. Si fueras el dueño de la tienda, ¿dónde invertirías primero para mejorar las ventas?
