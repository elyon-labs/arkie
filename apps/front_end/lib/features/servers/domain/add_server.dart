import 'package:cs2_rcon_front_end/di/graph.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server_management_config.dart';
import 'package:cs2_rcon_front_end/features/servers/data/repository/servers_repository.dart';
import 'package:cs2_rcon_front_end/features/settings/data/repository/settings_repository.dart';
import 'package:oxidized/oxidized.dart';

/// Adds a new server to the servers repository.
///
/// If this is the first server being added, it is automatically selected as the
/// active server.
class AddServer {
  AddServer({
    required ServersRepository serversRepository,
    required SettingsRepository settingsRepository,
  }) : _settingsRepository = settingsRepository,
       _serversRepository = serversRepository;

  factory AddServer.create() {
    return AddServer(serversRepository: inject(), settingsRepository: inject());
  }

  final ServersRepository _serversRepository;
  final SettingsRepository _settingsRepository;

  Future<Result<Server, Exception>> call({
    required String name,
    required String address,
    required int port,
    required String password,
    ServerManagementConfig? managementConfig,
  }) async {
    final initialServers = await _serversRepository.getServers();
    final result = await _serversRepository.addServer(
      name: name,
      address: address,
      port: port,
      password: password,
      managementConfig: managementConfig,
    );

    if (initialServers.isEmpty && result.isOk()) {
      await _settingsRepository.selectServer(result.unwrap().id);
    }

    return result;
  }
}
