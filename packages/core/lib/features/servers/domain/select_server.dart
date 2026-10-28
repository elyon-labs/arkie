import 'package:arkie_core/di/graph.dart';
import 'package:arkie_core/features/servers/data/models/server.dart';
import 'package:arkie_core/features/settings/data/repository/settings_repository.dart';

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
