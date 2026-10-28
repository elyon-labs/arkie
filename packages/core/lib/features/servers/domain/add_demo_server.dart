import 'package:arkie_core/di/graph.dart';
import 'package:arkie_core/features/servers/data/models/server.dart';
import 'package:arkie_core/features/servers/data/repository/servers_repository.dart';
import 'package:arkie_core/features/settings/data/repository/settings_repository.dart';
import 'package:oxidized/oxidized.dart';

/// Saves the demo server so it sits in the server list like any other.
///
/// Asking twice returns the server already saved, so there is only ever one.
class AddDemoServer {
  AddDemoServer({
    required ServersRepository serversRepository,
    required SettingsRepository settingsRepository,
  }) : _settingsRepository = settingsRepository,
       _serversRepository = serversRepository;

  factory AddDemoServer.create() {
    return AddDemoServer(serversRepository: inject(), settingsRepository: inject());
  }

  final ServersRepository _serversRepository;
  final SettingsRepository _settingsRepository;

  Future<Result<Server, Exception>> call() async {
    final initialServers = await _serversRepository.getServers();
    final result = await _serversRepository.addDemoServer();
    return result.mapAsync((server) async {
      if (initialServers.isEmpty) {
        await _settingsRepository.selectServer(server.id);
      }
      return server;
    });
  }
}
