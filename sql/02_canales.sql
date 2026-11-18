-- 02 · Rendimiento por canal de adquisición
-- Pregunta: ¿qué canales traen usuarios que compran?
--
-- Ojo: traffic_source es el canal por el que el usuario llegó LA PRIMERA VEZ,
-- no el de cada visita.

WITH eventos AS (
  SELECT
    user_pseudo_id,
    -- El id de la sesión está "escondido" dentro de event_params, que es una lista de pares
    -- clave/valor. UNNEST abre esa lista para buscar la clave 'ga_session_id'.
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS id_sesion,
    traffic_source.medium               AS medio,     -- organic, cpc, referral, (none)...
    traffic_source.source               AS fuente,    -- google, (direct), ...
    event_name,
    ecommerce.purchase_revenue_in_usd   AS ingreso
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE
    _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
)

SELECT
  medio,
  fuente,
  COUNT(DISTINCT user_pseudo_id)                                        AS usuarios,
  -- Una sesión se identifica por usuario + id de sesión (el id solo no es único).
  COUNT(DISTINCT CONCAT(user_pseudo_id, '-', CAST(id_sesion AS STRING))) AS sesiones,
  COUNTIF(event_name = 'purchase')                                      AS compras,
  ROUND(SUM(IF(event_name = 'purchase', ingreso, 0)), 2)                AS ingresos_usd,
  -- Conversión = compras / sesiones. SAFE_DIVIDE evita el error de dividir entre cero.
  ROUND(100 * SAFE_DIVIDE(
    COUNTIF(event_name = 'purchase'),
    COUNT(DISTINCT CONCAT(user_pseudo_id, '-', CAST(id_sesion AS STRING)))
  ), 2)                                                                 AS conversion_pct
FROM
  eventos
GROUP BY
  medio, fuente
ORDER BY
  sesiones DESC;

-- 📝 Para pensar:
--   1. ¿Qué canal trae MÁS sesiones? ¿Es también el que tiene MEJOR conversión?
--   2. ¿Qué significan medio = '(none)' y fuente = '(direct)'?
--   3. ¿Cuántas filas salen como '<Other>' o '(data deleted)'? ¿Afecta tus conclusiones?
