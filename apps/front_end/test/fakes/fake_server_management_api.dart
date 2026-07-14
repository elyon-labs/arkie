import 'package:cs2_rcon_front_end/features/server_management/data/api/server_management_api.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server_management_config.dart';
import 'package:oxidized/oxidized.dart';

class FakeServerManagementApi implements ServerManagementApi {
  FakeServerManagementApi({this.onRun, this.streamLogsResult});

  final Future<Result<String, Exception>> Function(
    ServerManagementConfig config,
    ServerManagementAction action,
  )?
  onRun;
  final Stream<Result<String, Exception>>? streamLogsResult;

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
    return onRun?.call(config, action) ?? Result.ok(action.name);
  }

  @override
  Stream<Result<String, Exception>> streamLogs(ServerManagementConfig config) {
    streamLogsConfig = config;
    return streamLogsResult ?? Stream.value(const Result.ok('log'));
  }
}
