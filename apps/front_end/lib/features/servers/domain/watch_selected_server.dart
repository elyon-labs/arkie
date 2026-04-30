import 'package:collection/collection.dart';
import 'package:cs2_rcon_front_end/di/graph.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:cs2_rcon_front_end/features/servers/data/repository/servers_repository.dart';
import 'package:cs2_rcon_front_end/features/settings/data/repository/settings_repository.dart';

/// Watches the currently selected server in the servers repository.
class WatchSelectedServer {
  WatchSelectedServer({
    required SettingsRepository settingsRepository,
    required ServersRepository repository,
  }) : _settingsRepository = settingsRepository,
       _serversRepository = repository;

  factory WatchSelectedServer.create() {
    return WatchSelectedServer(repository: inject(), settingsRepository: inject());
  }

  final SettingsRepository _settingsRepository;
  final ServersRepository _serversRepository;

  Stream<Server?> call() {
    return _settingsRepository.watchSelectedServer().asyncMap((serverId) async {
      if (serverId == null) {
        return null;
      }
      final servers = await _serversRepository.getServers();
      return servers.firstWhereOrNull((server) => server.id == serverId);
    });
  }
}
