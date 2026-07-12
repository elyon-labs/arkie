import 'dart:async';

import 'package:cs2_rcon_front_end/features/servers/data/api/servers_api.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server_management_config.dart';
import 'package:oxidized/oxidized.dart';
import 'package:rxdart/rxdart.dart';

class ServersRepository {
  ServersRepository({required ServersApi api}) : _api = api {
    unawaited(_fetchServers());
  }

  final ServersApi _api;

  final _subject = BehaviorSubject<List<Server>>.seeded([]);

  Future<void> _fetchServers() async {
    final servers = await _api.fetchServers();
    _subject.add(servers);
  }

  Future<List<Server>> getServers() async {
    return _subject.value;
  }

  Stream<List<Server>> watchServers() => _subject.stream;

  Stream<Server?> watchServer(String serverName) {
    return _subject.stream.map((servers) {
      for (final server in servers) {
        if (server.name == serverName) {
          return server;
        }
      }
      return null;
    });
  }

  Future<Result<Server, Exception>> addServer({
    required String name,
    required String address,
    required int port,
    required String password,
    ServerManagementConfig? managementConfig,
  }) {
    return _mutate(
      () => _api.addServer(name: name, address: address, port: port, password: password, managementConfig: managementConfig),
    );
  }

  Future<Result<void, Exception>> removeServer(Server server) {
    return _mutate(() => _api.removeServer(server));
  }

  Future<Result<void, Exception>> clearServers() {
    return _mutate(_api.clearServers);
  }

  Future<Result<T, Exception>> _mutate<T>(Future<Result<T, Exception>> Function() mutation) async {
    final result = await mutation();
    if (result.isOk()) {
      await refresh();
    }
    return result;
  }

  Future<void> refresh() => _fetchServers();

  Future<void> dispose() async {
    await _subject.close();
  }
}
