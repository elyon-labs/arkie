import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'servers_state.mapper.dart';

@MappableClass()
class ServersState with ServersStateMappable {
  ServersState({required this.servers, required this.selectedServer});

  factory ServersState.initial() => ServersState(servers: [], selectedServer: null);

  final List<Server> servers;
  final Server? selectedServer;
}
