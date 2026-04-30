import 'package:cs2_rcon_front_end/features/servers/data/api/servers_api.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:oxidized/oxidized.dart';

class FakeServersApi implements ServersApi {
  FakeServersApi({List<Server>? initialServers})
    : _servers = List<Server>.from(initialServers ?? const <Server>[]);

  final List<Server> _servers;

  int fetchServersCallCount = 0;
  int addServerCallCount = 0;
  int removeServerCallCount = 0;
  int clearServersCallCount = 0;

  Result<Server, Exception>? addServerResult;
  Result<void, Exception>? removeServerResult;
  Result<void, Exception>? clearServersResult;

  @override
  Future<List<Server>> fetchServers() async {
    fetchServersCallCount++;
    return List<Server>.from(_servers);
  }

  @override
  Future<Result<Server, Exception>> addServer({
    required String name,
    required String address,
    required int port,
    required String password,
  }) async {
    addServerCallCount++;
    final result = addServerResult;
    if (result != null) {
      return result;
    }
    final server = Server.create(name: name, password: password, address: address, port: port);
    _servers.add(server);
    return Result.ok(server);
  }

  @override
  Future<Result<void, Exception>> removeServer(Server server) async {
    removeServerCallCount++;
    final result = removeServerResult;
    if (result != null) {
      return result;
    }
    _servers.removeWhere((candidate) => candidate == server);
    return const Result.ok(null);
  }

  @override
  Future<Result<void, Exception>> updateServer(Server server) {
    throw UnimplementedError();
  }

  @override
  Future<Result<void, Exception>> clearServers() async {
    clearServersCallCount++;
    final result = clearServersResult;
    if (result != null) {
      return result;
    }
    _servers.clear();
    return const Result.ok(null);
  }
}
