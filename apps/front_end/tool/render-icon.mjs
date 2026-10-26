/**
 * Rasterises assets/icon.svg into the PNGs flutter_launcher_icons and the
 * Debian packaging point at, and assembles the Windows .ico outright.
 *
 * Run deliberately with `pnpm app:icon:render` from the repository root, then
 * `dart run flutter_launcher_icons` to push the macOS PNG into the asset
 * catalogue. Neither is run in CI: the PNGs and the generated icons are
 * committed, so a build never needs this to have run.
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
const windowsIcon = join(here, '..', 'windows', 'runner', 'resources', 'app_icon.ico');

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

/**
 * Every size Windows asks for: 16 in a title bar, 20 and 24 for a small
 * taskbar button, 32 in the taskbar and Alt-Tab, 40 at 125% scaling, 48 for
 * Explorer's large icons, and the rest for its extra large and jumbo views.
 * A size Windows cannot find it downscales from whichever it can, which is
 * what left the icon soft when the file held 48 alone.
 *
 * Each one is rasterised from the vector at its final size rather than
 * resampled from a big PNG, so the stroke stays crisp at 16 and 20 where a
 * downscale turns it to mush.
 */
const WINDOWS_SIZES = [16, 20, 24, 32, 40, 48, 64, 128, 256];

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

function render(target, destination) {
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
      `--screenshot=${destination}`,
      `file://${html}`,
    ],
    { stdio: 'pipe' },
  );
}

/**
 * Packs already-encoded PNGs into an .ico. Windows has read PNG-compressed
 * entries since Vista and this app targets Windows 10, so the frames go in
 * as they come out of Chrome rather than being decoded back to the BMP the
 * format originally carried.
 *
 * A 256px frame is declared as 0, the format having one byte per axis.
 */
function ico(frames) {
  const header = Buffer.alloc(6);
  header.writeUInt16LE(0, 0); // reserved
  header.writeUInt16LE(1, 2); // an icon rather than a cursor
  header.writeUInt16LE(frames.length, 4);

  const directory = Buffer.alloc(frames.length * 16);
  let offset = header.length + directory.length;

  frames.forEach(({ size, png }, index) => {
    const entry = index * 16;
    directory.writeUInt8(size === 256 ? 0 : size, entry);
    directory.writeUInt8(size === 256 ? 0 : size, entry + 1);
    directory.writeUInt8(0, entry + 2); // not palettised
    directory.writeUInt8(0, entry + 3); // reserved
    directory.writeUInt16LE(1, entry + 4); // colour planes
    directory.writeUInt16LE(32, entry + 6); // bits per pixel
    directory.writeUInt32LE(png.length, entry + 8);
    directory.writeUInt32LE(offset, entry + 12);
    offset += png.length;
  });

  return Buffer.concat([header, directory, ...frames.map((frame) => frame.png)]);
}

try {
  for (const target of TARGETS) {
    render(target, join(assets, target.file));
    console.log(`rendered ${target.file} at ${target.size}px`);
  }

  const frames = WINDOWS_SIZES.map((size) => {
    const file = join(work, `windows-${size}.png`);
    render({ file: `windows-${size}`, size }, file);
    return { size, png: readFileSync(file) };
  });

  writeFileSync(windowsIcon, ico(frames));
  console.log(`rendered app_icon.ico at ${WINDOWS_SIZES.join(', ')}px`);
} finally {
  rmSync(work, { recursive: true, force: true });
}
