import 'package:cs2_rcon_front_end/di/graph.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:cs2_rcon_front_end/features/servers/data/repository/servers_repository.dart';

/// Watches all servers in the servers repository.
class WatchServers {
  WatchServers({required ServersRepository repository}) : _repository = repository;

  factory WatchServers.create() {
    return WatchServers(repository: inject());
  }

  final ServersRepository _repository;

  Stream<List<Server>> call() {
    return _repository.watchServers();
  }
}
