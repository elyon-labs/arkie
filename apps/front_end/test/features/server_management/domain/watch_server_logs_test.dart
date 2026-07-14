import 'package:cs2_rcon_front_end/features/server_management/domain/watch_server_logs.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server_management_config.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fakes/fake_server_management_api.dart';

void main() {
  test('watches logs for the configured server', () async {
    const config = ServerManagementConfig(
      backend: ServerManagementBackend.systemd,
      sshHost: '127.0.0.1',
      sshPort: 22,
      sshUser: 'arkie-cs2',
      privateKeyPath: '~/.ssh/arkie-cs2',
      hostKeyFingerprint: 'fingerprint',
    );
    final api = FakeServerManagementApi();

    final logs = await WatchServerLogs(api: api)(config).toList();

    expect(api.streamLogsConfig, config);
    expect(logs.single.unwrap(), 'log');
  });
}
