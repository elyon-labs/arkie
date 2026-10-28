import 'package:arkie_core/di/graph.dart';
import 'package:arkie_core/features/servers/data/models/server.dart';
import 'package:arkie_core/features/servers/data/repository/servers_repository.dart';
import 'package:arkie_core/features/settings/data/repository/settings_repository.dart';
import 'package:collection/collection.dart';

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
