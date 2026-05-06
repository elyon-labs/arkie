import 'package:cs2_rcon_front_end/di/graph.dart';
import 'package:cs2_rcon_front_end/features/settings/data/repository/settings_repository.dart';

/// Clears the currently selected server without deleting it.
class UnselectServer {
  UnselectServer({required SettingsRepository repository}) : _repository = repository;

  factory UnselectServer.create() {
    return UnselectServer(repository: inject());
  }

  final SettingsRepository _repository;

  Future<void> call() {
    return _repository.clearSelectedServer();
  }
}
