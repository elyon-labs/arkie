import 'dart:typed_data';

import 'package:cs2_rcon_front_end/features/server_management/data/api/server_management_api.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server_management_config.dart';
import 'package:oxidized/oxidized.dart';

class FakeServerManagementApi implements ServerManagementApi {
  FakeServerManagementApi({this.onRun, this.streamLogsResult});

  final Future<Result<String, Exception>> Function(
    ServerManagementConfig config,
    ServerManagementAction action,
    Uint8List privateKeyBytes,
  )?
  onRun;
  final Stream<Result<String, Exception>>? streamLogsResult;

  ServerManagementConfig? runConfig;
  ServerManagementAction? runAction;
  Uint8List? runPrivateKeyBytes;
  ServerManagementConfig? streamLogsConfig;
  Uint8List? streamLogsPrivateKeyBytes;

  @override
  Future<Result<String, Exception>> run(
    ServerManagementConfig config,
    ServerManagementAction action,
    Uint8List privateKeyBytes,
  ) async {
    runConfig = config;
    runAction = action;
    runPrivateKeyBytes = privateKeyBytes;
    return onRun?.call(config, action, privateKeyBytes) ?? Result.ok(action.name);
  }

  @override
  Stream<Result<String, Exception>> streamLogs(
    ServerManagementConfig config,
    Uint8List privateKeyBytes,
  ) {
    streamLogsConfig = config;
    streamLogsPrivateKeyBytes = privateKeyBytes;
    return streamLogsResult ?? Stream.value(const Result.ok('log'));
  }
}
