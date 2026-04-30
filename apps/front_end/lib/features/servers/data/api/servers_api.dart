import 'package:cs2_rcon_front_end/di/graph.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:oxidized/oxidized.dart';

class ServersApi {
  ServersApi({required Box<Server> box}) : _box = box;

  factory ServersApi.create() {
    return ServersApi(box: inject());
  }

  final Box<Server> _box;

  Future<Result<Server, Exception>> addServer({
    required String name,
    required String address,
    required int port,
    required String password,
  }) async {
    return Result.asyncOf(() async {
      final server = Server.create(name: name, address: address, port: port, password: password);
      await _box.put(server.id, server);
      return server;
    });
  }

  Future<Result<void, Exception>> clearServers() async {
    return Result.asyncOf(() async {
      await _box.clear();
    });
  }

  Future<List<Server>> fetchServers() {
    return Future.value(_box.values.toList());
  }

  Future<Result<void, Exception>> removeServer(Server server) {
    return Result.asyncOf(() async {
      await _box.delete(server.id);
    });
  }

  Future<Result<void, Exception>> updateServer(Server server) {
    return Result.asyncOf(() async {
      await _box.put(server.id, server);
    });
  }
}
