// Convierte SVG a PNG con Chromium (Playwright). Solo se usa para generar los
// íconos de Android; la app usa los SVG directamente.
// Uso: node tool/render_svg.js entrada.svg salida.png tamaño [entrada2.svg ...]
//      (varias capas se dibujan una encima de otra)
const { chromium } = require('playwright');
const fs = require('fs');

(async () => {
  const [, , out, size, ...inputs] = process.argv;
  const px = Number(size);
  const layers = inputs
    .map((f) => `<img src="data:image/svg+xml;base64,${fs.readFileSync(f).toString('base64')}" style="position:absolute;inset:0;width:${px}px;height:${px}px">`)
    .join('');
  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: px, height: px } });
  await page.setContent(`<html><body style="margin:0;background:transparent">${layers}</body></html>`);
  await page.waitForTimeout(50);
  await page.screenshot({ path: out, omitBackground: true, clip: { x: 0, y: 0, width: px, height: px } });
  await browser.close();
})();
