# Semana 2 · Dispositivos, embudo secuencial y retención

**Objetivo:** responder tres preguntas nuevas para el avance 2 del informe.
**Tiempo estimado:** 3 a 4 horas (puedes partirlo en 3 sesiones de 1 hora, una por consulta).

| Consulta | Pregunta |
|---|---|
| `sql/03_dispositivos.sql` | ¿Se compra igual desde el celular que desde la computadora? |
| `sql/04_embudo_secuencial.sql` | Paso a paso, ¿dónde abandona la gente que mira un producto? |
| `sql/05_cohortes_retencion.sql` | De los usuarios nuevos de cada semana, ¿cuántos vuelven en 30 días? |

## Cómo trabajar cada consulta
1. Léela completa antes de ejecutarla; los comentarios explican cada parte.
2. Pégala en BigQuery y revisa arriba a la derecha cuántos datos va a leer (todas leen menos de 1 GB).
3. Ejecútala y guarda el resultado con **Guardar resultados → CSV** en `resultados/`, con el mismo número:
   `03_dispositivos.csv`, `04_embudo_secuencial.csv`, `05_cohortes.csv`.
4. Responde las preguntas de "📝 Para pensar" al final del archivo.
5. Si una consulta da error, copia el mensaje completo y me lo pasas.

## Conceptos nuevos de esta semana
- **Embudo secuencial:** un paso solo cuenta si ocurrió *después* del anterior. Es más estricto que el del avance 1.
- **`JOIN ... USING (user_pseudo_id)`:** une dos tablas por el mismo usuario; deja solo a los que aparecen en ambas.
- **`LAG()` y `FIRST_VALUE()`:** funciones de ventana; miran la fila anterior o la primera sin agrupar.
- **Cohorte:** grupo de usuarios que empezó en la misma semana. Sirve para comparar grupos justos entre sí.
- **Retención:** % de una cohorte que vuelve a la tienda en un periodo (días 1–7, 8–14, 15–30).

## Mis hallazgos
### Dispositivos
1. El celular trae el 39,8 % de las sesiones y convierte 1,64 %, algo más que la computadora (1,54 %).
2. La tablet solo pesa 2,2 % y convierte 1,39 %: no justifica un esfuerzo aparte.

### Embudo secuencial
1. De 61 252 personas que vieron un producto, solo el 19,7 % lo añadió al carrito: la mayor fuga.
2. Del carrito al pago pasa el 40,7 %; desde los datos de envío, 8 de cada 10 completan cada paso.
3. Corrige el avance 1: la pérdida entre envío y pago es 20 %, no 41 %.

### Retención
1. En promedio vuelve el 10,7 % en 30 días (la mayoría en la primera semana: 8,3 %).
2. Noviembre retiene más (12,9 %) que diciembre (8,3 %); la peor cohorte es la del 28 de diciembre (6,7 %).

### Dudas / correcciones
- La consulta 05 daba "Aggregations of aggregations are not allowed": el alias `primer_dia` del `MIN()` tenía el mismo nombre que la columna. Se renombró la columna a `primer_toque`.

## ✅ Listo cuando
- [x] Ejecutaste las 3 consultas sin errores
- [x] Guardaste los 3 CSV en `resultados/`
- [x] Escribiste al menos 2 hallazgos por consulta, con cifras
- [x] Anotaste tus dudas

Con eso armamos los gráficos y el **avance 2 del informe**, y lo publicamos en GitHub.
