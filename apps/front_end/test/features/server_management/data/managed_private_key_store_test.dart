import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cs2_rcon_front_end/features/server_management/data/managed_private_key_store.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/private_key_health.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/selected_private_key.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/managed_private_key_reference.dart';
import 'package:flutter_test/flutter_test.dart';

const _pem = '''-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACBpPal4/3f/qxFl7ugsT3C5YguwYJy66BqZZfjbVrh/LwAAAKjvACB47wAg
eAAAAAtzc2gtZWQyNTUxOQAAACBpPal4/3f/qxFl7ugsT3C5YguwYJy66BqZZfjbVrh/Lw
AAAEDA7onKLSmNPmz6svkb0EGkIFPgSpTablugz25qALF4f2k9qXj/d/+rEWXu6CxPcLli
C7BgnLroGpll+NtWuH8vAAAAIWJyYW5kb250cmF1dG1hbm5AYnJhbmRvbnMtbWFjYm9vaw
ECAwQ=
-----END OPENSSH PRIVATE KEY-----''';

void main() {
  late Directory support;
  late ManagedPrivateKeyStore store;

  setUp(() async {
    support = await Directory.systemTemp.createTemp('arkie-key-store-');
    store = ManagedPrivateKeyStore(applicationSupportDirectory: () async => support);
  });

  tearDown(() => support.delete(recursive: true));

  test('imports atomically, reads, inspects, secures, and deletes a key', () async {
    final selected = SelectedPrivateKey(
      displayName: 'id_ed25519',
      pemBytes: Uint8List.fromList(utf8.encode(_pem)),
    );

    final reference = await store.import(selected);

    expect(reference.displayName, 'id_ed25519');
    expect(utf8.decode(await store.read(reference.id)), _pem);
    expect(await store.inspect(reference), isA<PrivateKeyUsable>());
    final directory = Directory('${support.path}/ssh_keys');
    expect(directory.listSync().where((entry) => entry.path.endsWith('.tmp')), isEmpty);
    if (!Platform.isWindows) {
      expect((await FileStat.stat(directory.path)).mode & 0x1ff, 0x1c0);
      expect((await FileStat.stat('${directory.path}/${reference.id}')).mode & 0x1ff, 0x180);
    }

    await store.delete(reference.id);
    expect(store.read(reference.id), throwsA(isA<ManagedPrivateKeyException>()));
  });

  test('rejects traversal and invalid identifiers', () async {
    for (final id in ['../private-key', 'not-a-uuid', 'a/b']) {
      expect(store.read(id), throwsArgumentError);
      expect(store.delete(id), throwsArgumentError);
    }
  });

  test('classifies missing and invalid managed files', () async {
    const missing = ManagedPrivateKeyReference(
      id: '123e4567-e89b-42d3-a456-426614174000',
      displayName: 'missing',
    );
    expect(
      await store.inspect(missing),
      isA<PrivateKeyReplacementRequired>().having(
        (health) => health.reason,
        'reason',
        PrivateKeyReplacementReason.missing,
      ),
    );

    final keyDirectory = Directory('${support.path}/ssh_keys')..createSync(recursive: true);
    const invalid = ManagedPrivateKeyReference(
      id: '123e4567-e89b-42d3-a456-426614174001',
      displayName: 'invalid',
    );
    File('${keyDirectory.path}/${invalid.id}').writeAsStringSync('not a key');
    expect(
      await store.inspect(invalid),
      isA<PrivateKeyReplacementRequired>().having(
        (health) => health.reason,
        'reason',
        PrivateKeyReplacementReason.invalid,
      ),
    );
  });
}
