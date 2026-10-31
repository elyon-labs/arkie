/// Captures the App Store screenshots off the app running in a simulator.
///
/// Run it deliberately, not in CI:
///
/// ```sh
/// dart run tool/capture_screenshots.dart            # a simulator of its own
/// dart run tool/capture_screenshots.dart <udid>     # one you already have
/// ```
///
/// Given no device it creates one, uses it and deletes it again, which is what
/// keeps a capture from depending on the state a simulator you use for other
/// things is in: a device signed into an Apple Account puts a verification
/// alert over the app, and a settled screenshot of an alert is still a
/// screenshot of an alert.
///
/// Each scene is a different canned store. The scene reaches the app as a
/// `--dart-define`, which the compiler inlines, so a scene change means
/// building and installing again rather than poking at the running app. That
/// is slow and completely deterministic. Every launch wipes Hive before it
/// writes its fixture, so a capture does not depend on the one before it.
///
/// A screenshot is only valid in the display set it was sized for, and App
/// Store Connect answers one from the wrong set with "File dimensions are
/// invalid" rather than naming the set it wanted. [target] names the set, the
/// size, and a simulator that renders that size natively; the other sets are
/// listed beside it, so moving between them is one edit.
///
/// simctl writes RGBA and App Store Connect rejects an alpha channel, so ffmpeg
/// flattens each file.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

const bundleId = 'com.elyon-labs.arkie';
const deviceName = 'Arkie screenshots';

/// The display set these captures are for.
///
/// App Store Connect also takes, for the sets Arkie could be listed under:
///
/// - 6.1"/6.3": 1179x2556 (iPhone 16), or this one.
/// - 6.9": 1320x2868 (iPhone 17 Pro Max), 1290x2796 (iPhone 16 Plus),
///   1260x2736 (iPhone Air).
///
/// One set is enough; App Store Connect scales what it is given down for every
/// smaller iPhone itself.
const target = (
  type: 'com.apple.CoreSimulator.SimDeviceType.iPhone-16-Pro',
  width: 1206,
  height: 2622,
);

/// Ordered as they should be uploaded: App Store Connect shows the first three
/// in search results.
const scenes = [
  ('console', '01-console.png'),
  ('maps', '02-maps.png'),
  ('players', '03-players.png'),
  ('saved', '04-saved.png'),
  ('servers', '05-servers.png'),
];

final appDir = Directory.current;
final outDir = Directory('${appDir.path}/assets/store/screenshots');

Future<void> main(List<String> arguments) async {
  final borrowed = arguments.isNotEmpty;
  final udid = borrowed ? arguments.first : _createDevice();

  try {
    await _capture(udid);
  } finally {
    _simctl(['shutdown', udid], allowFailure: true);
    if (!borrowed) _simctl(['delete', udid], allowFailure: true);
  }
}

Future<void> _capture(String udid) async {
  _simctl(['bootstatus', udid, '-b']);

  // Apple's own marketing art reads 9:41, and a device left to its own clock
  // would put a different time in every screenshot.
  _simctl([
    'status_bar',
    udid,
    'override',
    '--time',
    '9:41',
    '--batteryState',
    'charged',
    '--batteryLevel',
    '100',
    '--cellularMode',
    'active',
    '--cellularBars',
    '4',
    '--wifiMode',
    'active',
    '--wifiBars',
    '3',
    '--dataNetwork',
    'wifi',
  ]);

  outDir.createSync(recursive: true);

  for (final (scene, name) in scenes) {
    final file = File('${outDir.path}/$name');

    await _run('flutter', [
      'build',
      'ios',
      '--debug',
      '--simulator',
      '--target=lib/main_screenshots.dart',
      '--dart-define=ARKIE_SCREENSHOT_SCENE=$scene',
    ]);

    _simctl(['terminate', udid, bundleId], allowFailure: true);
    _simctl(['install', udid, _builtApp().path]);
    _simctl(['launch', udid, bundleId]);

    await _captureWhenSettled(udid, file);
    _flatten(file);
    _assertSize(file);

    stdout.writeln('captured $name ($scene)');
  }

  _simctl(['terminate', udid, bundleId], allowFailure: true);
}

/// Creates the simulator the screenshots are taken on and returns its udid.
///
/// The runtime is the newest one that still ships the device [target] names,
/// rather than the newest one installed: a device is dropped a few releases
/// after the phone is, and the capture size is the point of picking it.
String _createDevice() {
  final listed = _simctl(['list', 'runtimes', 'available', '--json']);
  final runtimes = (jsonDecode(listed) as Map<String, dynamic>)['runtimes'] as List;

  final ios = runtimes
      .cast<Map<String, dynamic>>()
      .where((runtime) => (runtime['identifier'] as String).contains('.iOS-'))
      .where((runtime) => _supports(runtime, target.type))
      .toList();

  if (ios.isEmpty) throw StateError('No installed iOS runtime ships ${target.type}');

  ios.sort((a, b) => _compareVersions(_version(a), _version(b)));

  return _simctl(['create', deviceName, target.type, ios.last['identifier'] as String]).trim();
}

bool _supports(Map<String, dynamic> runtime, String type) {
  final supported = (runtime['supportedDeviceTypes'] as List?) ?? const [];
  return supported.cast<Map<String, dynamic>>().any((device) => device['identifier'] == type);
}

/// A runtime's version as numbers, so 26.0 sorts above 9.4 rather than under it.
List<int> _version(Map<String, dynamic> runtime) {
  return (runtime['version'] as String).split('.').map((part) => int.tryParse(part) ?? 0).toList();
}

int _compareVersions(List<int> a, List<int> b) {
  for (var index = 0; index < a.length || index < b.length; index += 1) {
    final left = index < a.length ? a[index] : 0;
    final right = index < b.length ? b[index] : 0;
    if (left != right) return left.compareTo(right);
  }
  return 0;
}

Directory _builtApp() {
  final candidates = [
    Directory('${appDir.path}/build/ios/iphonesimulator/Runner.app'),
    Directory('${appDir.path}/build/ios/Debug-iphonesimulator/Runner.app'),
  ];

  return candidates.firstWhere(
    (candidate) => candidate.existsSync(),
    orElse: () => throw StateError('The build produced no Runner.app'),
  );
}

/// Screenshots [udid] until two in a row come back identical, which is as close
/// as the simulator gets to saying the app has stopped moving.
///
/// The wait in front of the first one is long enough to be past the launch
/// image, the connection to the demo server and, where a scene opens one, the
/// sheet's animation.
Future<void> _captureWhenSettled(String udid, File file) async {
  await Future<void>.delayed(const Duration(seconds: 8));

  List<int>? previous;
  for (var attempt = 0; attempt < 24; attempt += 1) {
    _simctl(['io', udid, 'screenshot', '--type', 'png', file.path]);
    final current = file.readAsBytesSync();
    if (previous != null && _sameBytes(previous, current)) return;
    previous = current;
    await Future<void>.delayed(const Duration(milliseconds: 1500));
  }

  throw StateError('${file.path} never settled');
}

bool _sameBytes(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var index = 0; index < a.length; index += 1) {
    if (a[index] != b[index]) return false;
  }
  return true;
}

void _flatten(File file) {
  final flattened = '${file.path}.rgb.png';
  _check(
    Process.runSync('ffmpeg', [
      '-y',
      '-loglevel',
      'error',
      '-i',
      file.path,
      '-pix_fmt',
      'rgb24',
      '-map_metadata',
      '-1',
      flattened,
    ]),
    'ffmpeg',
  );
  File(flattened).renameSync(file.path);
  _stripAncillaryChunks(file);
}

/// Rewrites [file] with only the chunks a PNG needs to be a PNG.
///
/// ffmpeg carries the screenshot's metadata across and writes a `pHYs` of its
/// own whose horizontal resolution is zero, which is not a size any reader can
/// make sense of. Nothing downstream wants the colour or density chunks either,
/// so the file goes up as pixels and nothing else.
void _stripAncillaryChunks(File file) {
  const keep = {'IHDR', 'IDAT', 'IEND'};

  final bytes = file.readAsBytesSync();
  final out = BytesBuilder()..add(bytes.sublist(0, 8));

  var offset = 8;
  while (offset < bytes.length) {
    final length = bytes.buffer.asByteData(bytes.offsetInBytes + offset, 4).getUint32(0);
    final type = String.fromCharCodes(bytes.sublist(offset + 4, offset + 8));
    final end = offset + 12 + length;

    if (keep.contains(type)) out.add(bytes.sublist(offset, end));
    offset = end;
  }

  file.writeAsBytesSync(out.takeBytes());
}

/// Reads the width and height out of the PNG's IHDR rather than shelling out
/// for them.
void _assertSize(File file) {
  final header = file.readAsBytesSync().sublist(16, 24).buffer.asByteData();
  final width = header.getUint32(0);
  final height = header.getUint32(4);

  if (width != target.width || height != target.height) {
    throw StateError('${file.path} is ${width}x$height, expected ${target.width}x${target.height}');
  }
}

String _simctl(List<String> arguments, {bool allowFailure = false}) {
  final result = Process.runSync('xcrun', ['simctl', ...arguments]);
  if (allowFailure) return result.stdout as String;
  return _check(result, 'simctl ${arguments.first}');
}

String _check(ProcessResult result, String what) {
  if (result.exitCode != 0) {
    throw ProcessException(what, const [], result.stderr.toString().trim(), result.exitCode);
  }
  return result.stdout as String;
}

Future<void> _run(String executable, List<String> arguments) async {
  final process = await Process.start(
    executable,
    arguments,
    workingDirectory: appDir.path,
    mode: ProcessStartMode.inheritStdio,
  );
  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    throw ProcessException(executable, arguments, 'exited with $exitCode', exitCode);
  }
}
