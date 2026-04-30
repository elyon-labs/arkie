import 'package:cs2_rcon_front_end/di/graph.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:cs2_rcon_front_end/features/settings/data/repository/settings_repository.dart';

/// Selects a server as the active server in the servers repository.
class SelectServer {
  SelectServer({required SettingsRepository repository}) : _repository = repository;

  factory SelectServer.create() {
    return SelectServer(repository: inject());
  }

  final SettingsRepository _repository;

  Future<void> call({required Server server}) {
    return _repository.selectServer(server.id);
  }
}
