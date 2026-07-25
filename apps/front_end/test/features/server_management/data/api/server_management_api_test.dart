import 'dart:typed_data';

import 'package:cs2_rcon_front_end/features/server_management/data/api/server_management_api.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server_management_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const config = ServerManagementConfig(
    backend: ServerManagementBackend.systemd,
    sshHost: '127.0.0.1',
    sshPort: 22,
    sshUser: 'arkie-cs2',
    privateKey: null,
    hostKeyFingerprint: 'fingerprint',
  );

  test('invalid private-key content fails before opening a socket', () async {
    var connectCalls = 0;
    final api = ServerManagementApi(
      connectSocket: (_, _) async {
        connectCalls++;
        throw StateError('socket must not be opened');
      },
    );

    for (final bytes in [
      Uint8List(0),
      Uint8List.fromList([0xff, 0xfe]),
      Uint8List.fromList('-----BEGIN CERTIFICATE-----\nAA==\n-----END CERTIFICATE-----'.codeUnits),
    ]) {
      final result = await api.run(config, ServerManagementAction.start, bytes);

      expect(result.unwrapErr(), isA<ServerManagementCredentialException>());
    }
    expect(connectCalls, 0);
  });

  test('invalid log credential emits one error without opening a socket', () async {
    var connectCalls = 0;
    final api = ServerManagementApi(
      connectSocket: (_, _) async {
        connectCalls++;
        throw StateError('socket must not be opened');
      },
    );

    final logs = await api.streamLogs(config, Uint8List(0)).toList();

    expect(logs, hasLength(1));
    expect(logs.single.unwrapErr(), isA<ServerManagementCredentialException>());
    expect(connectCalls, 0);
  });
}
