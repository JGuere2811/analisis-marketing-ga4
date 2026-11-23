-- 05 · Cohortes de retención
-- Pregunta: de la gente que llega por primera vez en una semana, ¿cuántos vuelven después?
--
-- Una "cohorte" es un grupo de usuarios que empezó en la misma semana.
-- Se mide si volvieron en los días 1–7, 8–14 y 15–30 después de su primera visita.
--
-- Solo se toman usuarios cuya PRIMERA visita a la tienda (user_first_touch_timestamp)
-- fue entre el 1 de noviembre y el 31 de diciembre de 2020. Así todos tienen al menos
-- 30 días de datos para ver si vuelven (el dataset termina el 31 de enero de 2021).

WITH actividad AS (
  -- Un registro por usuario y por día en que tuvo actividad
  SELECT DISTINCT
    user_pseudo_id,
    PARSE_DATE('%Y%m%d', event_date)                          AS dia,
    DATE(TIMESTAMP_MICROS(user_first_touch_timestamp))        AS primer_dia
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE
    _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
    AND user_first_touch_timestamp IS NOT NULL
),

usuarios AS (
  SELECT
    user_pseudo_id,
    MIN(primer_dia)                                           AS primer_dia
  FROM actividad
  GROUP BY user_pseudo_id
  HAVING MIN(primer_dia) BETWEEN '2020-11-01' AND '2020-12-31'
),

dias_desde_inicio AS (
  SELECT
    u.user_pseudo_id,
    DATE_TRUNC(u.primer_dia, WEEK(MONDAY))                    AS cohorte,   -- lunes de esa semana
    DATE_DIFF(a.dia, u.primer_dia, DAY)                       AS dias
  FROM usuarios u
  JOIN actividad a USING (user_pseudo_id)
)

SELECT
  cohorte,
  COUNT(DISTINCT user_pseudo_id)                                              AS usuarios_nuevos,
  ROUND(100 * COUNT(DISTINCT IF(dias BETWEEN 1  AND 7,  user_pseudo_id, NULL))
            / COUNT(DISTINCT user_pseudo_id), 1)                              AS volvio_dias_1_7_pct,
  ROUND(100 * COUNT(DISTINCT IF(dias BETWEEN 8  AND 14, user_pseudo_id, NULL))
            / COUNT(DISTINCT user_pseudo_id), 1)                              AS volvio_dias_8_14_pct,
  ROUND(100 * COUNT(DISTINCT IF(dias BETWEEN 15 AND 30, user_pseudo_id, NULL))
            / COUNT(DISTINCT user_pseudo_id), 1)                              AS volvio_dias_15_30_pct,
  ROUND(100 * COUNT(DISTINCT IF(dias BETWEEN 1  AND 30, user_pseudo_id, NULL))
            / COUNT(DISTINCT user_pseudo_id), 1)                              AS volvio_en_30_dias_pct
FROM
  dias_desde_inicio
GROUP BY
  cohorte
ORDER BY
  cohorte;

-- 📝 Para pensar:
--   1. En promedio, ¿qué porcentaje vuelve dentro de los 30 días? ¿Es mucho o poco?
--   2. ¿Las cohortes de noviembre (Black Friday) vuelven más o menos que las de diciembre (Navidad)?
--   3. La última cohorte (semana del 28 de diciembre) solo tiene 4 días de usuarios nuevos.
--      ¿Por qué tiene menos usuarios y cómo lo explicarías en el informe?
