import 'dart:async';

import 'package:cs2_rcon_front_end/core/safe_emit.dart';
import 'package:cs2_rcon_front_end/di/graph.dart';
import 'package:cs2_rcon_front_end/features/server_management/data/managed_private_key_store.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/private_key_health.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/server_management_section/server_management_state.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/restart_server.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/start_server.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/stop_server.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/watch_server_logs.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server_management_config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxidized/oxidized.dart';

class ServerManagementCubit extends Cubit<ServerManagementState> {
  ServerManagementCubit({
    required ServerManagementConfig config,
    required StartServer startServer,
    required StopServer stopServer,
    required RestartServer restartServer,
    required WatchServerLogs watchServerLogs,
    ManagedPrivateKeyStore? privateKeyStore,
  }) : _config = config,
       _startServer = startServer,
       _stopServer = stopServer,
       _restartServer = restartServer,
       _watchServerLogs = watchServerLogs,
       _privateKeyStore = privateKeyStore,
       super(
         ServerManagementState.initial().copyWith(
           keyHealthStatus: privateKeyStore == null
               ? PrivateKeyHealthStatus.usable
               : PrivateKeyHealthStatus.checking,
         ),
       ) {
    if (privateKeyStore != null) unawaited(_inspectKey());
  }

  factory ServerManagementCubit.create({required ServerManagementConfig config}) {
    return ServerManagementCubit(
      config: config,
      startServer: StartServer.create(),
      stopServer: StopServer.create(),
      restartServer: RestartServer.create(),
      watchServerLogs: WatchServerLogs.create(),
      privateKeyStore: inject(),
    );
  }

  final ServerManagementConfig _config;
  final StartServer _startServer;
  final StopServer _stopServer;
  final RestartServer _restartServer;
  final WatchServerLogs _watchServerLogs;
  final ManagedPrivateKeyStore? _privateKeyStore;

  StreamSubscription<Result<String, Exception>>? _logSubscription;
  int _logGeneration = 0;

  Future<void> _inspectKey() async {
    final reference = _config.privateKey;
    final health = reference == null
        ? PrivateKeyReplacementRequired(
            _config.privateKeyPath != null
                ? PrivateKeyReplacementReason.legacyPath
                : PrivateKeyReplacementReason.missing,
          )
        : await _privateKeyStore!.inspect(reference);
    safeEmit(
      state.copyWith(
        keyHealthStatus: health is PrivateKeyUsable
            ? PrivateKeyHealthStatus.usable
            : PrivateKeyHealthStatus.replacementRequired,
        keyReplacementReason: health is PrivateKeyReplacementRequired ? health.reason : null,
      ),
    );
  }

  Future<void> start() {
    return _runAction(name: 'start', run: () => _startServer(_config));
  }

  Future<void> stop() {
    return _runAction(name: 'stop', run: () => _stopServer(_config));
  }

  Future<void> restart() {
    return _runAction(name: 'restart', run: () => _restartServer(_config));
  }

  Future<void> _runAction({
    required String name,
    required Future<Result<String, Exception>> Function() run,
  }) async {
    if (state.isBusy || state.keyHealthStatus != PrivateKeyHealthStatus.usable) {
      return;
    }

    safeEmit(state.copyWith(isBusy: true));
    final result = await run();
    final status = result.when(
      ok: (output) => output.isEmpty ? '$name completed' : output,
      err: (error) => 'Failed to $name: $error',
    );
    safeEmit(state.copyWith(isBusy: false, status: status));
  }

  Future<void> toggleLogs() async {
    if (state.keyHealthStatus != PrivateKeyHealthStatus.usable) return;
    final activeSubscription = _logSubscription;
    if (activeSubscription != null) {
      _logGeneration++;
      _logSubscription = null;
      safeEmit(state.copyWith(isStreamingLogs: false, logs: [], status: null));
      await activeSubscription.cancel();
      return;
    }

    final generation = ++_logGeneration;
    safeEmit(state.copyWith(isStreamingLogs: true, logs: [], status: 'Streaming logs...'));
    _logSubscription = _watchServerLogs(_config).listen(
      (result) {
        if (generation != _logGeneration) {
          return;
        }
        result.when(
          ok: _addLog,
          err: (error) => safeEmit(state.copyWith(status: 'Log stream failed: $error')),
        );
      },
      onDone: () {
        if (generation != _logGeneration) {
          return;
        }
        _logSubscription = null;
        safeEmit(
          state.copyWith(
            isStreamingLogs: false,
            status: state.status == 'Streaming logs...' ? null : state.status,
          ),
        );
      },
    );
  }

  void _addLog(String line) {
    final logs = state.logs;
    safeEmit(
      state.copyWith(logs: [...(logs.length > 199 ? logs.sublist(logs.length - 199) : logs), line]),
    );
  }

  @override
  Future<void> close() async {
    _logGeneration++;
    await _logSubscription?.cancel();
    _logSubscription = null;
    return super.close();
  }
}
