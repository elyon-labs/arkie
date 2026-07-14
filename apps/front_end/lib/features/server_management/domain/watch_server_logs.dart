import 'package:cs2_rcon_front_end/features/server_management/data/api/server_management_api.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server_management_config.dart';
import 'package:oxidized/oxidized.dart';

class WatchServerLogs {
  const WatchServerLogs({required ServerManagementApi api}) : _api = api;

  factory WatchServerLogs.create() {
    return const WatchServerLogs(api: ServerManagementApi());
  }

  final ServerManagementApi _api;

  Stream<Result<String, Exception>> call(ServerManagementConfig config) {
    return _api.streamLogs(config);
  }
}
