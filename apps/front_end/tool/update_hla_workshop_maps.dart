import 'dart:convert';
import 'dart:io';

const _sourceUrl = 'https://hla.gg/api/maps/index';
const _mapModelPath = 'lib/features/rcon/domain/models/cs2_map.dart';
const _assetDirectoryPath = 'assets/maps';
const _generatedStart = '      // HLA_WORKSHOP_MAPS_START';
const _generatedEnd = '      // HLA_WORKSHOP_MAPS_END';

Future<void> main(List<String> args) async {
  final dryRun = args.contains('--dry-run');
  final projectRoot = Directory.current;
  final mapModel = File('${projectRoot.path}/$_mapModelPath');
  final assetDirectory = Directory('${projectRoot.path}/$_assetDirectoryPath');

  if (!mapModel.existsSync()) {
    stderr.writeln('Run this script from apps/front_end.');
    exitCode = 64;
    return;
  }

  final maps = await _fetchMaps(Uri.parse(_sourceUrl));
  final generatedBlock = _buildGeneratedBlock(maps);
  final nextMapModelContents = _replaceGeneratedBlock(mapModel.readAsStringSync(), generatedBlock);

  var changed = false;
  if (nextMapModelContents != mapModel.readAsStringSync()) {
    changed = true;
    if (!dryRun) {
      mapModel.writeAsStringSync(nextMapModelContents);
    }
  }

  if (!assetDirectory.existsSync() && !dryRun) {
    assetDirectory.createSync(recursive: true);
  }

  for (final map in maps) {
    final asset = File('${assetDirectory.path}/${map.assetName}.webp');
    final bytes = await _fetchBytes(map.previewImageUrl);
    if (!asset.existsSync() || !_sameBytes(asset.readAsBytesSync(), bytes)) {
      changed = true;
      if (!dryRun) {
        asset.writeAsBytesSync(bytes);
      }
    }
  }

  final expectedAssets = maps.map((map) => '${map.assetName}.webp').toSet();
  final staleAssets = assetDirectory.listSync().whereType<File>().where((file) {
    final name = file.uri.pathSegments.last;
    return name.startsWith('workshop_') && name.endsWith('.webp') && !expectedAssets.contains(name);
  }).toList();

  for (final asset in staleAssets) {
    changed = true;
    if (!dryRun) {
      asset.deleteSync();
    }
  }

  if (changed) {
    stdout.writeln(
      dryRun ? 'HLA workshop maps are out of date.' : 'Updated ${maps.length} HLA workshop maps.',
    );
  } else {
    stdout.writeln('HLA workshop maps are already up to date.');
  }
}

Future<List<_HlaMap>> _fetchMaps(Uri source) async {
  final body = utf8.decode(await _fetchBytes(source));
  final json = jsonDecode(body) as Map<String, Object?>;
  final rawRecords = json['maps'];
  if (rawRecords is! List) {
    throw const FormatException('HLA map index did not include a maps list.');
  }
  final records = rawRecords.cast<Object?>();
  return records
      .whereType<Map<String, Object?>>()
      .where((record) => record['hasCS2'] == true)
      .where((record) {
        final previewImageUrl = record['previewImageUrl'];
        return previewImageUrl is String && previewImageUrl.contains('/media/maps/workshop/');
      })
      .map(_HlaMap.fromJson)
      .whereType<_HlaMap>()
      .toList(growable: false);
}

Future<List<int>> _fetchBytes(Uri uri) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(uri);
    final response = await request.close();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException('GET $uri returned ${response.statusCode}', uri: uri);
    }
    return await response.fold<List<int>>(<int>[], (buffer, chunk) => buffer..addAll(chunk));
  } finally {
    client.close();
  }
}

String _buildGeneratedBlock(List<_HlaMap> maps) {
  final buffer = StringBuffer()
    ..writeln(_generatedStart)
    ..writeln('      // Generated from $_sourceUrl.');

  for (final map in maps) {
    buffer
      ..writeln('      WorkshopMap(')
      ..writeln('        name: ${_dartString(map.slug)},')
      ..writeln('        assetName: ${_dartString(map.assetName)},')
      ..writeln('        slug: ${_dartString(map.slug)},')
      ..writeln('        workshopId: ${_dartString(map.workshopId)},')
      ..writeln('        displayName: ${_dartString(map.displayName)},')
      ..writeln('      ),');
  }

  buffer.write(_generatedEnd);
  return buffer.toString();
}

String _replaceGeneratedBlock(String contents, String generatedBlock) {
  final start = contents.indexOf(_generatedStart);
  final end = contents.indexOf(_generatedEnd);
  if (start == -1 || end == -1 || end < start) {
    throw StateError('Could not find HLA workshop map generated markers in $_mapModelPath.');
  }
  return contents.replaceRange(start, end + _generatedEnd.length, generatedBlock);
}

String _dartString(String value) {
  final buffer = StringBuffer("'");
  for (final rune in value.runes) {
    switch (rune) {
      case 0x08:
        buffer.write(r'\b');
      case 0x09:
        buffer.write(r'\t');
      case 0x0A:
        buffer.write(r'\n');
      case 0x0C:
        buffer.write(r'\f');
      case 0x0D:
        buffer.write(r'\r');
      case 0x24:
        buffer.write(r'\$');
      case 0x27:
        buffer.write(r"\'");
      case 0x5C:
        buffer.write(r'\\');
      default:
        if (rune >= 0x20 && rune <= 0x7E) {
          buffer.writeCharCode(rune);
        } else if (rune <= 0xFFFF) {
          buffer
            ..write(r'\u')
            ..write(rune.toRadixString(16).padLeft(4, '0'));
        } else {
          buffer
            ..write(r'\u{')
            ..write(rune.toRadixString(16))
            ..write('}');
        }
    }
  }
  buffer.write("'");
  return buffer.toString();
}

bool _sameBytes(List<int> left, List<int> right) {
  if (left.length != right.length) return false;
  for (var i = 0; i < left.length; i++) {
    if (left[i] != right[i]) return false;
  }
  return true;
}

class _HlaMap {
  const _HlaMap({
    required this.slug,
    required this.displayName,
    required this.workshopId,
    required this.previewImageUrl,
  });

  factory _HlaMap.fromJson(Map<String, Object?> json) {
    final slug = json['slug'];
    final displayName = json['displayName'];
    final previewImageUrl = json['previewImageUrl'];

    if (slug is! String || displayName is! String || previewImageUrl is! String) {
      throw FormatException('Invalid HLA map record: $json');
    }

    final uri = Uri.parse(previewImageUrl);
    final match = RegExp(r'/workshop/(\d+)\.webp$').firstMatch(uri.path);
    if (match == null) {
      throw FormatException('CS2 map "$slug" does not have a workshop preview URL.');
    }

    return _HlaMap(
      slug: slug,
      displayName: displayName,
      workshopId: match.group(1)!,
      previewImageUrl: uri,
    );
  }

  final String slug;
  final String displayName;
  final String workshopId;
  final Uri previewImageUrl;

  String get assetName => 'workshop_${slug.replaceAll(RegExp('[^a-zA-Z0-9]+'), '_')}';
}
