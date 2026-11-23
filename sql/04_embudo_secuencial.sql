-- 04 · Embudo de compra SECUENCIAL por usuario
-- Pregunta: de la gente que mira un producto, ¿cuántos avanzan paso a paso hasta comprar,
-- y en qué paso se pierden más?
--
-- Diferencia con el avance 1: allí se contaba quién hizo cada evento, sin importar el orden.
-- Aquí un usuario solo cuenta en un paso si lo hizo DESPUÉS del paso anterior.
-- Ejemplo: alguien que compró sin "ver producto" antes no entra al embudo.

WITH eventos AS (
  SELECT
    user_pseudo_id,
    event_name,
    event_timestamp            -- microsegundos desde 1970: sirve para ordenar en el tiempo
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE
    _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
    AND event_name IN ('view_item', 'add_to_cart', 'begin_checkout',
                       'add_shipping_info', 'add_payment_info', 'purchase')
),

-- Paso 1: primera vez que el usuario ve un producto
paso1 AS (
  SELECT user_pseudo_id, MIN(event_timestamp) AS t
  FROM eventos
  WHERE event_name = 'view_item'
  GROUP BY user_pseudo_id
),

-- Cada paso siguiente: la primera vez que hizo ese evento DESPUÉS del paso anterior.
-- El JOIN deja solo a quienes llegaron al paso anterior.
paso2 AS (
  SELECT e.user_pseudo_id, MIN(e.event_timestamp) AS t
  FROM eventos e JOIN paso1 p USING (user_pseudo_id)
  WHERE e.event_name = 'add_to_cart' AND e.event_timestamp > p.t
  GROUP BY e.user_pseudo_id
),
paso3 AS (
  SELECT e.user_pseudo_id, MIN(e.event_timestamp) AS t
  FROM eventos e JOIN paso2 p USING (user_pseudo_id)
  WHERE e.event_name = 'begin_checkout' AND e.event_timestamp > p.t
  GROUP BY e.user_pseudo_id
),
paso4 AS (
  SELECT e.user_pseudo_id, MIN(e.event_timestamp) AS t
  FROM eventos e JOIN paso3 p USING (user_pseudo_id)
  WHERE e.event_name = 'add_shipping_info' AND e.event_timestamp > p.t
  GROUP BY e.user_pseudo_id
),
paso5 AS (
  SELECT e.user_pseudo_id, MIN(e.event_timestamp) AS t
  FROM eventos e JOIN paso4 p USING (user_pseudo_id)
  WHERE e.event_name = 'add_payment_info' AND e.event_timestamp > p.t
  GROUP BY e.user_pseudo_id
),
paso6 AS (
  SELECT e.user_pseudo_id, MIN(e.event_timestamp) AS t
  FROM eventos e JOIN paso5 p USING (user_pseudo_id)
  WHERE e.event_name = 'purchase' AND e.event_timestamp > p.t
  GROUP BY e.user_pseudo_id
),

conteos AS (
            SELECT 1 AS orden, '1. Ver producto'        AS paso, COUNT(*) AS usuarios FROM paso1
  UNION ALL SELECT 2,          '2. Añadir al carrito',           COUNT(*)             FROM paso2
  UNION ALL SELECT 3,          '3. Iniciar pago',                COUNT(*)             FROM paso3
  UNION ALL SELECT 4,          '4. Datos de envío',              COUNT(*)             FROM paso4
  UNION ALL SELECT 5,          '5. Datos de pago',               COUNT(*)             FROM paso5
  UNION ALL SELECT 6,          '6. Compra',                      COUNT(*)             FROM paso6
)

SELECT
  orden,
  paso,
  usuarios,
  -- Qué parte de los que empezaron (paso 1) sigue en este paso
  ROUND(100 * usuarios / FIRST_VALUE(usuarios) OVER (ORDER BY orden), 1)    AS pct_desde_inicio,
  -- Qué parte de los del paso anterior llegó a este (LAG = valor de la fila anterior)
  ROUND(100 * SAFE_DIVIDE(usuarios, LAG(usuarios) OVER (ORDER BY orden)), 1) AS pct_desde_paso_anterior
FROM
  conteos
ORDER BY
  orden;

-- 📝 Para pensar:
--   1. ¿En qué paso se pierde el mayor porcentaje de gente (pct_desde_paso_anterior más bajo)?
--   2. Compara con el embudo del avance 1 (sin orden). ¿Cambian mucho las cifras? ¿Por qué?
--   3. Limitación: aquí no se exige que todo pase en la MISMA visita. ¿Te parece bien para
--      una tienda donde la gente puede volver días después a terminar su compra?
