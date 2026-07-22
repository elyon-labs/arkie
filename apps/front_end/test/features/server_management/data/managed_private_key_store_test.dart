import 'dart:io';
import 'dart:typed_data';

import 'package:cs2_rcon_front_end/features/server_management/data/managed_private_key_store.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/selected_private_key.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxidized/oxidized.dart';
import 'package:path/path.dart' as path;

const _id = '123e4567-e89b-42d3-a456-426614174000';

void main() {
  late Directory supportDirectory;

  setUp(() async {
    supportDirectory = await Directory.systemTemp.createTemp('arkie-managed-key-store-');
  });

  tearDown(() async {
    if (supportDirectory.existsSync()) {
      await supportDirectory.delete(recursive: true);
    }
  });

  ManagedPrivateKeyStore buildSubject({
    ManagedPrivateKeyIdProvider? createId,
    SetPathPermissions? setPathPermissions,
    bool isWindows = true,
  }) {
    return ManagedPrivateKeyStore(
      applicationSupportDirectory: () async => supportDirectory,
      createId: createId ?? () => _id,
      setPathPermissions: setPathPermissions,
      isWindows: isWindows,
    );
  }

  SelectedPrivateKey selectedKey() =>
      SelectedPrivateKey(displayName: 'id_ed25519', pemBytes: Uint8List.fromList([1, 2, 3, 4]));

  test('imports key bytes under an opaque identifier and returns metadata', () async {
    final store = buildSubject();

    final reference = (await store.importKey(selectedKey())).unwrap();

    expect(reference.id, _id);
    expect(reference.displayName, 'id_ed25519');
    expect(await File(path.join(supportDirectory.path, 'ssh_keys', _id)).readAsBytes(), [
      1,
      2,
      3,
      4,
    ]);
    expect(
      Directory(path.join(supportDirectory.path, 'ssh_keys')).listSync().whereType<File>(),
      hasLength(1),
    );
  });

  test('reads an imported key', () async {
    final store = buildSubject();
    expect((await store.importKey(selectedKey())).isOk(), isTrue);

    final bytes = (await store.readKey(_id)).unwrap();

    expect(bytes, [1, 2, 3, 4]);
  });

  test('does not overwrite an existing managed key when an identifier collides', () async {
    final store = buildSubject();
    expect((await store.importKey(selectedKey())).isOk(), isTrue);

    final collisionResult = await store.importKey(
      SelectedPrivateKey(displayName: 'replacement', pemBytes: Uint8List.fromList([9, 9, 9])),
    );

    expect(collisionResult.unwrapErr(), isA<ManagedPrivateKeyStorageException>());
    expect((await store.readKey(_id)).unwrap(), [1, 2, 3, 4]);
  });

  test('reports a missing key without exposing its storage path', () async {
    final store = buildSubject();

    final read = await store.readKey(_id);

    expect(
      read.unwrapErr(),
      isA<ManagedPrivateKeyStorageException>()
          .having((error) => error.message, 'message', contains('could not find'))
          .having((error) => error.message, 'message', isNot(contains(supportDirectory.path))),
    );
  });

  test('deletes an imported key and is idempotent when it is already absent', () async {
    final store = buildSubject();
    expect((await store.importKey(selectedKey())).isOk(), isTrue);

    expect((await store.deleteKey(_id)).isOk(), isTrue);
    expect((await store.deleteKey(_id)).isOk(), isTrue);

    expect(File(path.join(supportDirectory.path, 'ssh_keys', _id)).existsSync(), isFalse);
  });

  test('secures the key directory and temporary key before rename', () async {
    final permissions = <(String, String)>[];
    final store = buildSubject(
      isWindows: false,
      setPathPermissions: (target, mode) async {
        permissions.add((target, mode));
        return const Ok(null);
      },
    );

    expect((await store.importKey(selectedKey())).isOk(), isTrue);

    expect(permissions.map((entry) => entry.$2), ['700', '600']);
    expect(permissions.first.$1, path.join(supportDirectory.path, 'ssh_keys'));
    expect(permissions.last.$1, path.join(supportDirectory.path, 'ssh_keys', '.$_id.tmp'));
  });

  test('applies restrictive permissions on Unix-like platforms', () async {
    if (Platform.isWindows) return;
    final store = buildSubject(isWindows: false);

    expect((await store.importKey(selectedKey())).isOk(), isTrue);

    final directory = await FileStat.stat(path.join(supportDirectory.path, 'ssh_keys'));
    final key = await FileStat.stat(path.join(supportDirectory.path, 'ssh_keys', _id));
    expect(directory.modeString(), endsWith('rwx------'));
    expect(key.modeString(), endsWith('rw-------'));
  });

  test('removes temporary bytes when import fails', () async {
    final store = buildSubject(
      isWindows: false,
      setPathPermissions: (target, mode) async {
        if (mode == '600') {
          return const Err(
            ManagedPrivateKeyStorageException('Arkie could not set private key permissions.'),
          );
        }
        return const Ok(null);
      },
    );

    final result = await store.importKey(selectedKey());

    expect(result.unwrapErr(), isA<ManagedPrivateKeyStorageException>());

    expect(
      Directory(path.join(supportDirectory.path, 'ssh_keys')).listSync().whereType<File>(),
      isEmpty,
    );
  });

  test('rejects malformed identifiers before touching the filesystem', () async {
    final store = buildSubject();

    expect((await store.readKey('../id_ed25519')).isErr(), isTrue);
    expect((await store.deleteKey('not-a-uuid')).isErr(), isTrue);
    expect(Directory(path.join(supportDirectory.path, 'ssh_keys')).existsSync(), isFalse);
  });

  test('rejects a malformed generated identifier before touching the filesystem', () async {
    final store = buildSubject(createId: () => '../id_ed25519');

    expect((await store.importKey(selectedKey())).isErr(), isTrue);

    expect(Directory(path.join(supportDirectory.path, 'ssh_keys')).existsSync(), isFalse);
  });
}
