import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:cs2_rcon_front_end/features/servers/data/repository/servers_repository.dart';

/// Watches a specific server by its name in the servers repository.
class WatchServer {
  WatchServer({required ServersRepository repository}) : _repository = repository;

  final ServersRepository _repository;

  Stream<Server?> call(String serverName) {
    return _repository.watchServer(serverName);
  }
}
