import 'package:cs2_rcon_front_end/features/server_management/data/api/server_management_api.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server_management_config.dart';
import 'package:oxidized/oxidized.dart';

class RestartServer {
  const RestartServer({required ServerManagementApi api}) : _api = api;

  factory RestartServer.create() {
    return const RestartServer(api: ServerManagementApi());
  }

  final ServerManagementApi _api;

  Future<Result<String, Exception>> call(ServerManagementConfig config) {
    return _api.run(config, ServerManagementAction.restart);
  }
}
