# Semana 1 · Explorar los datos

**Objetivo:** entender qué hay en el dataset y sacar las primeras cifras por canal y por dispositivo.
**Tiempo estimado:** 3 a 4 horas.

## Paso 1 · Activar BigQuery (15 min)
1. Entra a <https://console.cloud.google.com/bigquery> con tu cuenta de Google.
2. Si lo pide, crea un proyecto nuevo (por ejemplo `analisis-ga4`). El modo *sandbox* es gratis y **no pide tarjeta**.
3. En el panel izquierdo, busca `ga4_obfuscated_sample_ecommerce` para ver las tablas. Abre una y mira la pestaña **Esquema**: así conoces las columnas.

## Paso 2 · Ejecutar las consultas (1–2 h)
Para cada archivo de `sql/`:
1. Léelo completo **antes** de ejecutarlo; los comentarios explican cada parte.
2. Pégalo en el editor y mira arriba a la derecha cuántos datos va a leer.
3. Ejecútalo y guarda el resultado: botón **Guardar resultados → CSV** en la carpeta `resultados/`.
4. Responde las preguntas de "📝 Para pensar" que están al final del archivo.

## Paso 3 · Tus apuntes (1 h)
Escribe aquí abajo, con tus palabras, 3 a 5 hallazgos. Ejemplo de formato:

> El canal **X** trae el **N %** de las sesiones, pero convierte **N veces** menos que **Y**.

### Mis hallazgos
1.
2.
3.

### Dudas para revisar
-

## ✅ Listo cuando
- [ ] Ejecutaste las 3 consultas sin errores
- [ ] Guardaste los 3 CSV en `resultados/`
- [ ] Escribiste al menos 3 hallazgos con cifras
- [ ] Anotaste tus dudas

## Glosario rápido
- **Usuario:** un navegador identificado por `user_pseudo_id` (no es una persona real con nombre).
- **Sesión:** una visita; termina tras 30 minutos sin actividad.
- **Conversión:** porcentaje de sesiones que terminan en compra.
- **Medio / fuente:** cómo llegó el usuario (`organic` = buscador sin pagar, `cpc` = anuncio pagado, `referral` = enlace en otra web, `(none)` = escribió la dirección directamente).
