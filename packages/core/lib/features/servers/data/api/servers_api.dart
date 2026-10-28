import 'package:arkie_core/di/graph.dart';
import 'package:arkie_core/features/servers/data/models/server.dart';
import 'package:collection/collection.dart';
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

  /// Saves the demo server, or returns the one already saved.
  ///
  /// Creating it here rather than through [addServer] is what keeps the app to
  /// a single demo server: there is no way to ask for a second one.
  Future<Result<Server, Exception>> addDemoServer() async {
    return Result.asyncOf(() async {
      final existing = _box.values.firstWhereOrNull((server) => server.isDemo);
      if (existing != null) return existing;

      final server = Server.demo();
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
