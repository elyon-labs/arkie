import 'package:cs2_rcon_front_end/features/server_management/data/api/server_management_api.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/restart_server.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/start_server.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/stop_server.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/watch_server_logs.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server_management_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxidized/oxidized.dart';

void main() {
  const config = ServerManagementConfig(
    backend: ServerManagementBackend.systemd,
    sshHost: '127.0.0.1',
    sshPort: 22,
    sshUser: 'arkie-cs2',
    privateKeyPath: '~/.ssh/arkie-cs2',
    hostKeyFingerprint: 'fingerprint',
  );

  group('server management use cases', () {
    test('StartServer starts the configured server', () async {
      final api = FakeServerManagementApi();

      final result = await StartServer(api: api)(config);

      expect(api.runConfig, config);
      expect(api.runAction, ServerManagementAction.start);
      expect(result.unwrap(), 'start');
    });

    test('StopServer stops the configured server', () async {
      final api = FakeServerManagementApi();

      final result = await StopServer(api: api)(config);

      expect(api.runConfig, config);
      expect(api.runAction, ServerManagementAction.stop);
      expect(result.unwrap(), 'stop');
    });

    test('RestartServer restarts the configured server', () async {
      final api = FakeServerManagementApi();

      final result = await RestartServer(api: api)(config);

      expect(api.runConfig, config);
      expect(api.runAction, ServerManagementAction.restart);
      expect(result.unwrap(), 'restart');
    });

    test('WatchServerLogs watches logs for the configured server', () async {
      final api = FakeServerManagementApi();

      final logs = await WatchServerLogs(api: api)(config).toList();

      expect(api.streamLogsConfig, config);
      expect(logs.single.unwrap(), 'log');
    });
  });
}

class FakeServerManagementApi implements ServerManagementApi {
  ServerManagementConfig? runConfig;
  ServerManagementAction? runAction;
  ServerManagementConfig? streamLogsConfig;

  @override
  Future<Result<String, Exception>> run(
    ServerManagementConfig config,
    ServerManagementAction action,
  ) async {
    runConfig = config;
    runAction = action;
    return Result.ok(action.name);
  }

  @override
  Stream<Result<String, Exception>> streamLogs(ServerManagementConfig config) {
    streamLogsConfig = config;
    return Stream.value(const Result.ok('log'));
  }
}
