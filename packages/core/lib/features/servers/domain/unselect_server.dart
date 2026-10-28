import 'package:arkie_core/di/graph.dart';
import 'package:arkie_core/features/settings/data/repository/settings_repository.dart';

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
