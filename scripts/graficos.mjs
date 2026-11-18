// Genera los gráficos del informe (SVG estáticos) a partir de los CSV de resultados/.
// Uso: node scripts/graficos.mjs   (desde la raíz del repositorio)
import fs from 'node:fs';

const leerCsv = ruta => {
  const [cab, ...filas] = fs.readFileSync(ruta, 'utf8').trim().split(/\r?\n/);
  const cols = cab.split(',');
  return filas.map(f => Object.fromEntries(f.split(',').map((v, i) => [cols[i], isNaN(+v) ? v : +v])));
};

const C = { fondo: '#fcfcfb', texto: '#0b0b0b', texto2: '#52514e', tenue: '#8a8984', linea: '#e4e3df', s1: '#2a78d6', s2: '#eb6834' };
const FUENTE = 'font-family="Segoe UI, Helvetica, Arial, sans-serif"';
const num = n => Math.round(n).toLocaleString('es-PE').replace(/,/g, ' ');
const pct = (n, d = 1) => n.toFixed(d).replace('.', ',') + ' %';
const esc = s => s.replace(/&/g, '&amp;').replace(/</g, '&lt;');

// Barra horizontal con el extremo de datos redondeado (4px) y anclada a la base.
const barra = (x, y, w, h, color) => {
  if (w <= 0) return '';
  const r = Math.min(4, w);
  return `<path d="M${x} ${y}H${x + w - r}Q${x + w} ${y} ${x + w} ${y + r}V${y + h - r}Q${x + w} ${y + h} ${x + w - r} ${y + h}H${x}Z" fill="${color}"/>`;
};

const svg = (ancho, alto, titulo, subtitulo, cuerpo) => `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${ancho} ${alto}" width="${ancho}" height="${alto}" ${FUENTE} role="img">
<title>${esc(titulo)}</title>
<rect width="${ancho}" height="${alto}" rx="12" fill="${C.fondo}"/>
<text x="28" y="40" font-size="19" font-weight="600" fill="${C.texto}">${esc(titulo)}</text>
<text x="28" y="64" font-size="13" fill="${C.texto2}">${esc(subtitulo)}</text>
${cuerpo}
</svg>`;

fs.mkdirSync('graficos', { recursive: true });

// ── 1. Embudo de compra ──────────────────────────────────────────────
const eventos = Object.fromEntries(leerCsv('resultados/01_panorama_eventos.csv').map(f => [f.evento, f.usuarios]));
const pasos = [
  ['Vio una página', 'page_view'], ['Vio un producto', 'view_item'], ['Añadió al carrito', 'add_to_cart'],
  ['Empezó a pagar', 'begin_checkout'], ['Puso datos de envío', 'add_shipping_info'],
  ['Puso datos de pago', 'add_payment_info'], ['Compró', 'purchase'],
];
{
  const base = eventos.page_view, x0 = 200, anchoMax = 420, h = 30, sep = 16, y0 = 96;
  let cuerpo = `<text x="${x0 + anchoMax + 170}" y="${y0 - 12}" font-size="11" text-anchor="end" fill="${C.tenue}">del paso anterior</text>`;
  pasos.forEach(([nombre, ev], i) => {
    const u = eventos[ev], y = y0 + i * (h + sep), w = (u / base) * anchoMax;
    const anterior = i ? eventos[pasos[i - 1][1]] : null;
    cuerpo += `<text x="${x0 - 14}" y="${y + h / 2 + 5}" font-size="14" text-anchor="end" fill="${C.texto}">${nombre}</text>`;
    cuerpo += barra(x0, y, Math.max(w, 2), h, C.s1);
    cuerpo += `<text x="${x0 + Math.max(w, 2) + 10}" y="${y + h / 2 + 5}" font-size="13" fill="${C.texto}"><tspan font-weight="600">${num(u)}</tspan><tspan fill="${C.texto2}"> · ${pct((u / base) * 100)}</tspan></text>`;
    if (anterior) cuerpo += `<text x="${x0 + anchoMax + 170}" y="${y + h / 2 + 5}" font-size="12" text-anchor="end" fill="${C.texto2}">pasa ${pct((u / anterior) * 100, 0)}</text>`;
  });
  cuerpo += `<line x1="${x0}" y1="${y0 - 6}" x2="${x0}" y2="${y0 + pasos.length * (h + sep) - sep + 6}" stroke="${C.tenue}" stroke-width="1"/>`;
  const alto = y0 + pasos.length * (h + sep) + 20;
  fs.writeFileSync('graficos/embudo.svg', svg(820, alto, 'Embudo de compra: de cada 100 visitantes, menos de 2 compran',
    'Usuarios únicos por paso · % sobre quienes vieron una página · nov 2020 – ene 2021', cuerpo));
}

// ── 2 y 3. Canales ───────────────────────────────────────────────────
const grupo = ({ medio, fuente }) => {
  if (medio === 'organic' && fuente === 'google') return 'Google orgánico';
  if (medio === '(none)') return 'Directo';
  if (medio === 'referral' && fuente === 'shop.googlemerchandisestore.com') return 'Autorreferencia (la propia tienda)';
  if (medio === 'referral') return 'Referidos de otros sitios';
  if (medio === 'cpc') return 'Anuncios de Google (cpc)';
  if (medio === 'organic') return 'Otros buscadores';
  return 'Sin dato (anonimizado)';
};
const canales = {};
for (const f of leerCsv('resultados/02_canales.csv')) {
  const g = (canales[grupo(f)] ??= { sesiones: 0, compras: 0, ingresos: 0 });
  g.sesiones += f.sesiones; g.compras += f.compras; g.ingresos += f.ingresos_usd;
}
const tot = Object.values(canales).reduce((a, g) => ({ sesiones: a.sesiones + g.sesiones, compras: a.compras + g.compras, ingresos: a.ingresos + g.ingresos }), { sesiones: 0, compras: 0, ingresos: 0 });
const lista = Object.entries(canales).sort((a, b) => b[1].sesiones - a[1].sesiones);
fs.writeFileSync('resultados/02b_canales_agrupados.csv', 'canal,sesiones,compras,ingresos_usd,pct_sesiones,pct_ingresos,conversion_pct,ticket_usd\n' +
  lista.map(([n, g]) => [n, g.sesiones, g.compras, g.ingresos, (100 * g.sesiones / tot.sesiones).toFixed(1), (100 * g.ingresos / tot.ingresos).toFixed(1), (100 * g.compras / g.sesiones).toFixed(2), (g.ingresos / g.compras).toFixed(1)].join(',')).join('\n') + '\n');

{ // 2. Participación en sesiones vs. ingresos
  const x0 = 250, anchoMax = 470, hb = 14, gap = 2, sepG = 18, y0 = 112, maxPct = 35;
  let cuerpo = `<rect x="28" y="80" width="12" height="12" rx="3" fill="${C.s1}"/><text x="46" y="91" font-size="13" fill="${C.texto}">% de las sesiones</text>
<rect x="180" y="80" width="12" height="12" rx="3" fill="${C.s2}"/><text x="198" y="91" font-size="13" fill="${C.texto}">% de los ingresos</text>`;
  lista.forEach(([n, g], i) => {
    const y = y0 + i * (2 * hb + gap + sepG), ps = 100 * g.sesiones / tot.sesiones, pi = 100 * g.ingresos / tot.ingresos;
    cuerpo += `<text x="${x0 - 14}" y="${y + hb + 5}" font-size="13" text-anchor="end" fill="${C.texto}">${esc(n)}</text>`;
    cuerpo += barra(x0, y, ps / maxPct * anchoMax, hb, C.s1) + `<text x="${x0 + ps / maxPct * anchoMax + 8}" y="${y + hb - 2}" font-size="12" fill="${C.texto2}">${pct(ps)}</text>`;
    cuerpo += barra(x0, y + hb + gap, pi / maxPct * anchoMax, hb, C.s2) + `<text x="${x0 + pi / maxPct * anchoMax + 8}" y="${y + 2 * hb + gap - 2}" font-size="12" fill="${C.texto2}">${pct(pi)}</text>`;
  });
  const alto = y0 + lista.length * (2 * hb + gap + sepG) + 10;
  cuerpo += `<line x1="${x0}" y1="${y0 - 6}" x2="${x0}" y2="${alto - 22}" stroke="${C.tenue}"/>`;
  fs.writeFileSync('graficos/canales-participacion.svg', svg(820, alto, 'Qué parte de las visitas y de los ingresos trae cada canal',
    `Canal de adquisición del usuario · ${num(tot.sesiones)} sesiones · USD ${num(tot.ingresos)} en ingresos`, cuerpo));
}

{ // 3. Conversión por canal frente al promedio
  const conv = lista.map(([n, g]) => [n, 100 * g.compras / g.sesiones]).sort((a, b) => b[1] - a[1]);
  const prom = 100 * tot.compras / tot.sesiones, x0 = 250, anchoMax = 420, h = 24, sep = 14, y0 = 100, max = 4;
  let cuerpo = `<text x="${x0 + anchoMax + 90}" y="${y0 - 12}" font-size="11" text-anchor="end" fill="${C.tenue}">conversión</text>`;
  conv.forEach(([n, c], i) => {
    const y = y0 + i * (h + sep), w = c / max * anchoMax, destacado = n.startsWith('Anuncios');
    cuerpo += `<text x="${x0 - 14}" y="${y + h / 2 + 5}" font-size="13" text-anchor="end" fill="${C.texto}" ${destacado ? 'font-weight="600"' : ''}>${esc(n)}</text>`;
    cuerpo += barra(x0, y, w, h, destacado ? C.s2 : C.s1);
    cuerpo += `<text x="${x0 + anchoMax + 90}" y="${y + h / 2 + 5}" font-size="13" font-weight="600" text-anchor="end" fill="${C.texto}">${pct(c, 2)}</text>`;
  });
  const yFin = y0 + conv.length * (h + sep) - sep, xp = x0 + prom / max * anchoMax;
  cuerpo += `<line x1="${x0}" y1="${y0 - 6}" x2="${x0}" y2="${yFin + 6}" stroke="${C.tenue}"/>`;
  cuerpo += `<line x1="${xp}" y1="${y0 - 14}" x2="${xp}" y2="${yFin + 8}" stroke="${C.texto2}" stroke-width="1.5" stroke-dasharray="4 4"/>`;
  cuerpo += `<text x="${xp}" y="${yFin + 26}" font-size="12" text-anchor="middle" fill="${C.texto2}">promedio ${pct(prom, 2)}</text>`;
  fs.writeFileSync('graficos/canales-conversion.svg', svg(820, yFin + 44, 'Conversión por canal: los anuncios pagados convierten menos',
    '% de sesiones que terminan en compra · la línea punteada es el promedio de la tienda', cuerpo));
}
console.log('Gráficos generados en graficos/ y resumen en resultados/02b_canales_agrupados.csv');
