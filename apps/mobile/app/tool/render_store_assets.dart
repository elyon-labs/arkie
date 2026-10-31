/// Renders the App Store merchandising art into `assets/store`.
///
/// Run it deliberately, not in CI:
///
/// ```sh
/// dart run tool/render_store_assets.dart
/// ```
///
/// It shells out to headless Chrome rather than adding a rasteriser to a
/// Flutter package's dependencies. The PNGs are committed, so a build never
/// needs this to have run.
///
/// Both assets draw the same figure: the console pane, with a command in the
/// accent and the server's reply under it, which is what the app is. Both fill
/// their frame — against a black field, a small figure with a margin around it
/// reads as an absence rather than as restraint. The header keeps its content
/// inside the middle 83% of the width, which is what survives the crop Apple
/// applies to a 21:9 banner on a narrow device.
///
/// Screenshots are captured separately, off the running app, by
/// `tool/capture_screenshots.dart`.
library;

import 'dart:io';

const chrome = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';

/// `ArkieTheme.mobile`, transcribed. A colour changed in
/// `packages/ui/lib/src/arkie_theme.dart` has to be changed here too.
const colors = {
  'body': '#000000',
  'card': '#0E0C12',
  'border': '#2A2433',
  'foreground': '#E8E2F0',
  'muted': '#968BA6',
  'faint': '#5F5670',
  'accent': '#BB86FC',
  'good': '#7EE787',
};

/// The tagline, broken for the column it is set in: the header gives it a
/// third of the frame, the search image most of one.
const taglineInThree = ['Run your CS2 server', 'without launching', 'the game.'];
const taglineInTwo = ['Run your CS2 server', 'without launching the game.'];

/// The session the site's hero shows, in the shape the app's console draws it.
///
/// Long enough that the pane it fills has some height to it. The pane can only
/// be as wide as its longest line sets it, so length is the one way it grows.
const transcript = [
  (true, 'status'),
  (false, 'hostname : Larry’s Server'),
  (false, 'map      : de_dust2'),
  (false, 'players  : 8 humans, 2 bots (12 max)'),
  (true, 'mp_restartgame 1'),
  (false, 'Restarting the game in 1 seconds...'),
  (true, 'bot_quota 0'),
  (false, '"bot_quota" changed to "0"'),
];

final appDir = Directory.current;
final outDir = Directory('${appDir.path}/assets/store');
final fontDir = Directory('${appDir.path}/../../../packages/ui/assets/fonts');

void main() {
  outDir.createSync(recursive: true);
  final work = Directory.systemTemp.createTempSync('arkie-store-');

  try {
    for (final asset in [header, searchResults]) {
      final page = File('${work.path}/${asset.file}.html')..writeAsStringSync(asset.html());

      final result = Process.runSync(chrome, [
        '--headless',
        '--disable-gpu',
        '--hide-scrollbars',
        '--allow-file-access-from-files',
        '--force-device-scale-factor=1',
        '--default-background-color=000000ff',
        '--window-size=${asset.width},${asset.height}',
        '--screenshot=${outDir.path}/${asset.file}',
        'file://${page.path}',
      ]);

      if (result.exitCode != 0) {
        throw ProcessException(chrome, const [], result.stderr.toString().trim(), result.exitCode);
      }

      stdout.writeln('rendered ${asset.file} at ${asset.width}x${asset.height}');
    }
  } finally {
    work.deleteSync(recursive: true);
  }
}

class StoreAsset {
  const StoreAsset({
    required this.file,
    required this.width,
    required this.height,
    required this.html,
  });

  final String file;
  final int width;
  final int height;
  final String Function() html;
}

/// 21:9, and cropped at the sides on a narrow device, so the content stays
/// inside the middle 83% of the frame and fills it top to bottom.
final header = StoreAsset(
  file: 'product-page-header.png',
  width: 3840,
  height: 1646,
  html: () => _page(
    width: 3840,
    height: 1646,
    extraStyles: '''
  .frame {
    display: grid;
    grid-template-columns: 1fr 1.9fr;
    gap: 150px;
    align-items: center;
    width: 3200px;
    margin: 0 auto;
    height: 100%;
    box-sizing: border-box;
  }
  .wordmark { font-size: 200px; margin-bottom: 76px; }
  .tagline { margin: 0; font-size: 84px; line-height: 1.35; }
  .panel { font-size: 72px; }
  .notch { font-size: 44px; }''',
    body:
        '''
<div class="frame">
  <div>
    <div class="wordmark"><span class="prompt">&gt;</span> arkie</div>
    <p class="tagline">${_lines(taglineInThree)}</p>
  </div>
  ${_console()}
</div>''',
  ),
);

/// 3:2, and a thumbnail in a list of results, so it carries one idea at a
/// larger size: the tagline as a headline over the same pane.
final searchResults = StoreAsset(
  file: 'search-results.png',
  width: 3840,
  height: 2560,
  html: () => _page(
    width: 3840,
    height: 2560,
    extraStyles:
        '''
  .frame {
    display: flex;
    flex-direction: column;
    justify-content: center;
    width: 3300px;
    height: 100%;
    margin: 0 auto;
    box-sizing: border-box;
  }
  .tagline {
    margin: 0 0 150px;
    color: ${colors['foreground']};
    font-size: 190px;
    line-height: 1.18;
    letter-spacing: -5px;
  }
  .panel { font-size: 104px; }
  .notch { font-size: 64px; }''',
    body:
        '''
<div class="frame">
  <p class="tagline">${_lines(taglineInTwo)}</p>
  ${_console()}
</div>''',
  ),
);

String _lines(List<String> lines) => lines.join('<br>');

/// The console pane, with its label notched into the top border the way
/// `TerminalPanel` draws one.
String _console() {
  final lines = transcript
      .map(
        (line) =>
            '''
      <div class="line">
        <span class="sigil">${line.$1 ? '&gt;' : ''}</span>
        <span class="${line.$1 ? 'input' : 'output'}">${line.$2}</span>
      </div>''',
      )
      .join('\n');

  return '''
  <div class="panel">
    <span class="notch label">arkie</span>
    <span class="notch lamp"><span class="dot"></span>live</span>
    <div class="console">
$lines
    </div>
  </div>''';
}

String _page({
  required int width,
  required int height,
  required String extraStyles,
  required String body,
}) {
  return '''
<!doctype html>
<meta charset="utf-8">
<style>
  @font-face {
    font-family: 'Space Mono';
    src: url('file://${fontDir.absolute.path}/SpaceMono-Regular.ttf') format('truetype');
    font-weight: 400;
  }
  @font-face {
    font-family: 'Space Mono';
    src: url('file://${fontDir.absolute.path}/SpaceMono-Bold.ttf') format('truetype');
    font-weight: 700;
  }
  html, body { margin: 0; padding: 0; }
  body {
    width: ${width}px;
    height: ${height}px;
    background: ${colors['body']};
    color: ${colors['foreground']};
    font-family: 'Space Mono', ui-monospace, monospace;
    -webkit-font-smoothing: antialiased;
  }
  .prompt { color: ${colors['accent']}; }
  /* Filled rather than drawn as an outline, the way the app fills a pane that
     sits above another one. On a field of black an outline has no weight. */
  .panel {
    position: relative;
    background: ${colors['card']};
    border: 5px solid ${colors['border']};
    padding: 0.9em 0.8em;
  }
  .notch {
    position: absolute;
    top: 0;
    transform: translateY(-50%);
    padding: 0 18px;
    background: ${colors['body']};
    color: ${colors['muted']};
  }
  .label { left: 40px; }
  .lamp { right: 40px; color: ${colors['good']}; }
  .dot {
    display: inline-block;
    width: 0.4em;
    height: 0.4em;
    margin-right: 0.5em;
    background: ${colors['good']};
  }
  .line { display: flex; line-height: 1.6; white-space: pre; }
  .sigil { width: 1.5em; flex: none; color: ${colors['accent']}; }
  .input { color: ${colors['accent']}; }
  .output { color: ${colors['foreground']}; }
$extraStyles
</style>
$body''';
}
