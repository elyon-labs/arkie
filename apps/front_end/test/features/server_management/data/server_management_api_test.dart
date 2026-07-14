import 'dart:io';

import 'package:cs2_rcon_front_end/features/server_management/data/api/server_management_api.dart';
import 'package:cs2_rcon_front_end/features/server_management/data/managed_private_key_store.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/private_key_health.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/managed_private_key_reference.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server_management_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory support;
  late ServerManagementApi api;

  setUp(() async {
    support = await Directory.systemTemp.createTemp('arkie-ssh-api-');
    api = ServerManagementApi(
      privateKeyStore: ManagedPrivateKeyStore(applicationSupportDirectory: () async => support),
    );
  });

  tearDown(() => support.delete(recursive: true));

  ServerManagementConfig config({ManagedPrivateKeyReference? privateKey, String? privateKeyPath}) =>
      ServerManagementConfig(
        backend: ServerManagementBackend.systemd,
        sshHost: '127.0.0.1',
        sshPort: 22,
        sshUser: 'arkie-cs2',
        hostKeyFingerprint: 'SHA256:test',
        privateKey: privateKey,
        privateKeyPath: privateKeyPath,
      );

  test('rejects a legacy external path without reading it', () async {
    final result = await api.run(
      config(privateKeyPath: '/tmp/must-not-be-read'),
      ServerManagementAction.restart,
    );
    expect(
      result.unwrapErr(),
      isA<ServerManagementCredentialException>().having(
        (error) => error.reason,
        'reason',
        PrivateKeyReplacementReason.legacyPath,
      ),
    );
  });

  test('reports a missing managed copy specifically', () async {
    final result = await api.run(
      config(
        privateKey: const ManagedPrivateKeyReference(
          id: '123e4567-e89b-42d3-a456-426614174000',
          displayName: 'missing',
        ),
      ),
      ServerManagementAction.restart,
    );
    expect(
      result.unwrapErr(),
      isA<ServerManagementCredentialException>().having(
        (error) => error.reason,
        'reason',
        PrivateKeyReplacementReason.missing,
      ),
    );
  });

  test('reports corrupt managed content as invalid', () async {
    const reference = ManagedPrivateKeyReference(
      id: '123e4567-e89b-42d3-a456-426614174001',
      displayName: 'corrupt',
    );
    final directory = Directory('${support.path}/ssh_keys')..createSync();
    File('${directory.path}/${reference.id}').writeAsStringSync('not a private key');

    final result = await api.run(config(privateKey: reference), ServerManagementAction.restart);
    expect(
      result.unwrapErr(),
      isA<ServerManagementCredentialException>().having(
        (error) => error.reason,
        'reason',
        PrivateKeyReplacementReason.invalid,
      ),
    );
  });
}
