import 'dart:typed_data';

import 'package:cs2_rcon_front_end/features/server_management/data/api/server_management_api.dart';
import 'package:cs2_rcon_front_end/features/server_management/data/managed_private_key_store.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/managed_private_key_reference.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/watch_server_logs.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server_management_config.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fakes/fake_read_managed_private_key.dart';
import '../../../fakes/fake_server_management_api.dart';

void main() {
  test('watches logs for the configured server', () async {
    const config = ServerManagementConfig(
      backend: ServerManagementBackend.systemd,
      sshHost: '127.0.0.1',
      sshPort: 22,
      sshUser: 'arkie-cs2',
      privateKey: ManagedPrivateKeyReference(id: 'key-id', displayName: 'id_ed25519'),
      hostKeyFingerprint: 'fingerprint',
    );
    final api = FakeServerManagementApi();
    final bytes = Uint8List.fromList([10, 11, 12]);

    final logs = await WatchServerLogs(
      api: api,
      readManagedPrivateKey: fakeReadManagedPrivateKey(bytes: bytes),
    )(config).toList();

    expect(api.streamLogsConfig, config);
    expect(api.streamLogsPrivateKeyBytes, bytes);
    expect(logs.single.unwrap(), 'log');
  });

  test('emits one error and closes when the managed key cannot be read', () async {
    const config = ServerManagementConfig(
      backend: ServerManagementBackend.systemd,
      sshHost: '127.0.0.1',
      sshPort: 22,
      sshUser: 'arkie-cs2',
      privateKey: ManagedPrivateKeyReference(id: 'missing', displayName: 'id_ed25519'),
      hostKeyFingerprint: 'fingerprint',
    );
    final api = FakeServerManagementApi();

    final logs = await WatchServerLogs(
      api: api,
      readManagedPrivateKey: fakeReadManagedPrivateKey(
        error: const ManagedPrivateKeyStorageException(
          'Arkie could not find the managed private key.',
        ),
      ),
    )(config).toList();

    expect(logs, hasLength(1));
    expect(logs.single.unwrapErr(), isA<ServerManagementCredentialException>());
    expect(api.streamLogsConfig, isNull);
  });
}
