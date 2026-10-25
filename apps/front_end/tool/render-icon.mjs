/**
 * Rasterises assets/icon.svg into the PNGs flutter_launcher_icons and the
 * Debian packaging point at.
 *
 * Run deliberately with `pnpm app:icon:render` from the repository root, then
 * `dart run flutter_launcher_icons` to push the result into the macOS asset
 * catalogue and the Windows .ico. Neither is run in CI: the PNGs and the
 * generated icons are committed, so a build never needs this to have run.
 *
 * It shells out to headless Chrome rather than taking on an npm rasteriser.
 * The SVG is inlined into a page instead of loaded as an <img>, which lets
 * each target be a few lines of CSS over #plate and #mark rather than an edit
 * to the source markup.
 */
import { execFileSync } from 'node:child_process';
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const CHROME = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
const here = dirname(fileURLToPath(import.meta.url));
const assets = join(here, '..', 'assets');

/**
 * macOS draws app icons smaller than their canvas and expects the art to
 * carry its own rounded shape, so that target is inset to Apple's grid: an
 * 824pt body on a 1024pt canvas, the rest transparent. Windows and Linux
 * composite nothing of their own, so they take the plate at full bleed.
 */
const MACOS_BODY_SCALE = 824 / 1024;

const TARGETS = [
  { file: 'icon.png', size: 1024 },
  { file: 'icon-macos.png', size: 1024, scale: MACOS_BODY_SCALE },
];

const svg = readFileSync(join(assets, 'icon.svg'), 'utf8');

function page(target) {
  // Scaling both layers together keeps the corner radius in proportion, which
  // a transform on the plate alone would not.
  const scale = target.scale
    ? `#plate, #mark {
    transform-box: view-box;
    transform-origin: 512px 512px;
    transform: scale(${target.scale});
  }`
    : '';

  return `<!doctype html>
<meta charset="utf-8">
<style>
  html, body { margin: 0; padding: 0; background: transparent; }
  svg { display: block; width: ${target.size}px; height: ${target.size}px; }
  ${scale}
</style>
${svg}`;
}

const work = mkdtempSync(join(tmpdir(), 'arkie-icon-'));

try {
  for (const target of TARGETS) {
    const html = join(work, `${target.file}.html`);
    writeFileSync(html, page(target));

    execFileSync(
      CHROME,
      [
        '--headless',
        '--disable-gpu',
        '--hide-scrollbars',
        '--default-background-color=00000000',
        `--window-size=${target.size},${target.size}`,
        `--screenshot=${join(assets, target.file)}`,
        `file://${html}`,
      ],
      { stdio: 'pipe' },
    );

    console.log(`rendered ${target.file} at ${target.size}px`);
  }
} finally {
  rmSync(work, { recursive: true, force: true });
}
