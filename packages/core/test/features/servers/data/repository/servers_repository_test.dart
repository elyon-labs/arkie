import 'package:arkie_core/features/servers/data/models/server.dart';
import 'package:arkie_core/features/servers/data/repository/servers_repository.dart';
import 'package:arkie_core/testing/fake_servers_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxidized/oxidized.dart';

void main() {
  group('ServersRepository', () {
    ServersRepository buildSubject({FakeServersApi? api}) {
      return ServersRepository(api: api ?? FakeServersApi());
    }

    Server buildServer({
      String name = 'Test Server',
      String address = 'localhost',
      int port = 27015,
      String password = 'password',
    }) {
      return Server.create(name: name, password: password, address: address, port: port);
    }

    test('fetches servers immediately on instantiation', () async {
      final api = FakeServersApi();

      buildSubject(api: api);

      await pumpEventQueue();

      expect(api.fetchServersCallCount, 1);
    });

    group('watchServers', () {
      test('emits the seeded list followed by fetched servers', () async {
        final expectedServer = buildServer();
        final api = FakeServersApi(initialServers: [expectedServer]);
        final repository = buildSubject(api: api);

        final values = await repository.watchServers().take(2).toList();

        expect(values[0], isEmpty);
        expect(values[1], [expectedServer]);
      });
    });

    group('addServer', () {
      test('refreshes servers when the api call succeeds', () async {
        final newServer = buildServer(name: 'Second Server');
        final api = FakeServersApi();
        final repository = buildSubject(api: api);

        await pumpEventQueue();

        final result = await repository.addServer(
          name: newServer.name,
          address: newServer.address,
          port: newServer.port,
          password: newServer.password,
        );

        final addedServer = result.unwrap();

        expect(result.isOk(), isTrue);
        expect(api.addServerCallCount, 1);
        expect(api.fetchServersCallCount, 2);
        final servers = await repository.watchServers().first;
        expect(servers, [addedServer]);
      });

      test('does not refresh servers when the api call fails', () async {
        final api = FakeServersApi()..addServerResult = Result.err(Exception('failure'));
        final repository = buildSubject(api: api);

        await pumpEventQueue();

        final result = await repository.addServer(
          name: 'name',
          address: 'address',
          port: 1234,
          password: 'pass',
        );

        expect(result.isErr(), isTrue);
        expect(api.addServerCallCount, 1);
        expect(api.fetchServersCallCount, 1);
        expect(await repository.watchServers().first, isEmpty);
      });
    });

    group('removeServer', () {
      test('refreshes servers when the api call succeeds', () async {
        final server = buildServer();
        final api = FakeServersApi(initialServers: [server]);
        final repository = buildSubject(api: api);

        await pumpEventQueue();

        final result = await repository.removeServer(server);

        expect(result.isOk(), isTrue);
        expect(api.removeServerCallCount, 1);
        expect(api.fetchServersCallCount, 2);
        expect(await repository.watchServers().first, isEmpty);
      });

      test('does not refresh when the api call fails', () async {
        final server = buildServer();
        final api = FakeServersApi(initialServers: [server])
          ..removeServerResult = Result.err(Exception('failure'));
        final repository = buildSubject(api: api);

        await pumpEventQueue();

        final result = await repository.removeServer(server);

        expect(result.isErr(), isTrue);
        expect(api.removeServerCallCount, 1);
        expect(api.fetchServersCallCount, 1);
        expect(await repository.watchServers().first, [server]);
      });
    });
  });
}
