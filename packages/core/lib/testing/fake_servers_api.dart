import 'package:arkie_core/features/servers/data/api/servers_api.dart';
import 'package:arkie_core/features/servers/data/models/server.dart';
import 'package:collection/collection.dart';
import 'package:oxidized/oxidized.dart';

class FakeServersApi implements ServersApi {
  FakeServersApi({List<Server>? initialServers})
    : _servers = List<Server>.from(initialServers ?? const <Server>[]);

  final List<Server> _servers;

  int fetchServersCallCount = 0;
  int addServerCallCount = 0;
  int addDemoServerCallCount = 0;
  int removeServerCallCount = 0;

  Result<Server, Exception>? addServerResult;
  Result<Server, Exception>? addDemoServerResult;
  Result<void, Exception>? removeServerResult;

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
  Future<Result<Server, Exception>> addDemoServer() async {
    addDemoServerCallCount++;
    final result = addDemoServerResult;
    if (result != null) {
      return result;
    }
    final existing = _servers.where((candidate) => candidate.isDemo).firstOrNull;
    if (existing != null) {
      return Result.ok(existing);
    }
    final server = Server.demo();
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
}
