import 'dart:typed_data';

import 'package:cs2_rcon_front_end/features/server_management/data/api/server_management_api.dart';
import 'package:cs2_rcon_front_end/features/server_management/data/managed_private_key_store.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/managed_private_key_reference.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/stop_server.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server_management_config.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fakes/fake_read_managed_private_key.dart';
import '../../../fakes/fake_server_management_api.dart';

void main() {
  test('stops the configured server', () async {
    const config = ServerManagementConfig(
      backend: ServerManagementBackend.systemd,
      sshHost: '127.0.0.1',
      sshPort: 22,
      sshUser: 'arkie-cs2',
      privateKey: ManagedPrivateKeyReference(id: 'key-id', displayName: 'id_ed25519'),
      hostKeyFingerprint: 'fingerprint',
    );
    final api = FakeServerManagementApi();
    final bytes = Uint8List.fromList([4, 5, 6]);

    final result = await StopServer(
      api: api,
      readManagedPrivateKey: fakeReadManagedPrivateKey(bytes: bytes),
    )(config);

    expect(api.runConfig, config);
    expect(api.runAction, ServerManagementAction.stop);
    expect(api.runPrivateKeyBytes, bytes);
    expect(result.unwrap(), 'stop');
  });

  test('does not invoke SSH when the managed key is missing', () async {
    const config = ServerManagementConfig(
      backend: ServerManagementBackend.systemd,
      sshHost: '127.0.0.1',
      sshPort: 22,
      sshUser: 'arkie-cs2',
      privateKey: ManagedPrivateKeyReference(id: 'missing', displayName: 'id_ed25519'),
      hostKeyFingerprint: 'fingerprint',
    );
    final api = FakeServerManagementApi();

    final result = await StopServer(
      api: api,
      readManagedPrivateKey: fakeReadManagedPrivateKey(
        error: const ManagedPrivateKeyStorageException(
          'Arkie could not find the managed private key.',
        ),
      ),
    )(config);

    expect(result.unwrapErr(), isA<ServerManagementCredentialException>());
    expect(api.runConfig, isNull);
  });
}
