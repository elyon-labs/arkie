/**
 * Rasterises public/icon.svg into the PNGs the site needs but cannot serve as
 * SVG: the Apple touch icon, and the social card that link previews use.
 *
 * Run deliberately with `pnpm web:assets:render`, not in CI. It shells out to
 * headless Chrome rather than taking on an npm rasteriser as a dependency.
 * The PNGs are committed, so a build never needs this to have run.
 */
import { execFileSync } from 'node:child_process';
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const CHROME = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
const here = dirname(fileURLToPath(import.meta.url));
const publicDir = join(here, '..', 'public');

const svg = readFileSync(join(publicDir, 'icon.svg'), 'utf8');
const fontFace = (weight, file) => `
  @font-face {
    font-family: 'Space Mono';
    src: url('file://${join(publicDir, 'fonts', file)}') format('woff2');
    font-weight: ${weight};
  }`;

const TOUCH_ICON = { file: 'apple-touch-icon.png', width: 180, height: 180 };
const SOCIAL_CARD = { file: 'og-image.png', width: 1200, height: 630 };

/** Squared off, because iOS applies its own mask to whatever it is given. */
function touchIconPage() {
  return `<!doctype html>
<meta charset="utf-8">
<style>
  html, body { margin: 0; padding: 0; background: #121212; }
  svg { display: block; width: ${TOUCH_ICON.width}px; height: ${TOUCH_ICON.height}px; }
  #plate { rx: 0; }
</style>
${svg}`;
}

/**
 * The card is the mark beside the wordmark and tagline, drawn with the same
 * tokens as the site so a link preview looks like the page behind it.
 */
function socialCardPage() {
  return `<!doctype html>
<meta charset="utf-8">
<style>
  ${fontFace(400, 'space-mono-regular.woff2')}
  ${fontFace(700, 'space-mono-bold.woff2')}
  html, body { margin: 0; padding: 0; }
  body {
    display: flex;
    align-items: center;
    gap: 64px;
    width: ${SOCIAL_CARD.width}px;
    height: ${SOCIAL_CARD.height}px;
    padding: 0 80px;
    box-sizing: border-box;
    background: #121212;
    color: #FFFFFF;
    font-family: 'Space Mono', ui-monospace, Menlo, monospace;
  }
  svg { display: block; flex: none; width: 220px; height: 220px; }
  h1 { margin: 0; font-size: 72px; font-weight: 700; letter-spacing: -1px; }
  p { margin: 28px 0 0; font-size: 28px; line-height: 1.45; color: #999999; }
  strong { color: #BB86FC; font-weight: 400; }
</style>
${svg}
<div>
  <h1>Arkie</h1>
  <p>Run your <strong>Counter-Strike 2</strong> server<br>without launching the game.</p>
</div>`;
}

const work = mkdtempSync(join(tmpdir(), 'arkie-web-assets-'));

try {
  for (const [target, page] of [
    [TOUCH_ICON, touchIconPage],
    [SOCIAL_CARD, socialCardPage],
  ]) {
    const html = join(work, `${target.file}.html`);
    writeFileSync(html, page());

    execFileSync(
      CHROME,
      [
        '--headless',
        '--disable-gpu',
        '--hide-scrollbars',
        '--allow-file-access-from-files',
        '--default-background-color=121212ff',
        `--window-size=${target.width},${target.height}`,
        `--screenshot=${join(publicDir, target.file)}`,
        `file://${html}`,
      ],
      { stdio: 'pipe' },
    );

    console.log(`rendered ${target.file} at ${target.width}x${target.height}`);
  }
} finally {
  rmSync(work, { recursive: true, force: true });
}
