import 'dart:async';

import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/server_management_section/server_management_cubit.dart';
import 'package:cs2_rcon_front_end/features/server_management/data/api/server_management_api.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/restart_server.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/start_server.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/stop_server.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/watch_server_logs.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server_management_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxidized/oxidized.dart';

import '../../../../../fakes/fake_server_management_api.dart';

void main() {
  const config = ServerManagementConfig(
    backend: ServerManagementBackend.systemd,
    sshHost: '127.0.0.1',
    sshPort: 22,
    sshUser: 'arkie-cs2',
    privateKeyPath: '~/.ssh/arkie-cs2',
    hostKeyFingerprint: 'fingerprint',
  );

  ServerManagementCubit buildSubject(FakeServerManagementApi api) {
    return ServerManagementCubit(
      config: config,
      startServer: StartServer(api: api),
      stopServer: StopServer(api: api),
      restartServer: RestartServer(api: api),
      watchServerLogs: WatchServerLogs(api: api),
    );
  }

  test('runs lifecycle actions and tracks their ephemeral state', () async {
    final resultCompleter = Completer<Result<String, Exception>>();
    final api = FakeServerManagementApi(onRun: (_, _) => resultCompleter.future);
    final cubit = buildSubject(api);
    addTearDown(cubit.close);

    final restart = cubit.restart();

    expect(cubit.state.isBusy, isTrue);
    expect(api.runAction, ServerManagementAction.restart);

    resultCompleter.complete(const Result.ok('restarted'));
    await restart;

    expect(cubit.state.isBusy, isFalse);
    expect(cubit.state.status, 'restarted');
  });

  test('tracks logs and clears them before cancellation finishes', () async {
    final cancelCompleter = Completer<void>();
    final logController = StreamController<Result<String, Exception>>(
      onCancel: () => cancelCompleter.future,
    );
    final api = FakeServerManagementApi(streamLogsResult: logController.stream);
    final cubit = buildSubject(api);
    addTearDown(() async {
      if (!cancelCompleter.isCompleted) {
        cancelCompleter.complete();
      }
      await logController.close();
      await cubit.close();
    });

    await cubit.toggleLogs();
    expect(cubit.state.isStreamingLogs, isTrue);
    expect(cubit.state.status, 'Streaming logs...');

    logController.add(const Result.ok('server log'));
    await pumpEventQueue();
    expect(cubit.state.logs, ['server log']);

    final stopLogs = cubit.toggleLogs();
    expect(cubit.state.isStreamingLogs, isFalse);
    expect(cubit.state.status, isNull);
    expect(cubit.state.logs, isEmpty);

    cancelCompleter.complete();
    await stopLogs;
  });
}
