import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:cs2_rcon_front_end/features/servers/data/repository/servers_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxidized/oxidized.dart';

import '../../../../fakes/fake_servers_api.dart';

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

    group('watchServer', () {
      test('emits null until the server appears in the repository', () async {
        final matchingServer = buildServer();
        final api = FakeServersApi();
        final repository = buildSubject(api: api);

        final valuesFuture = repository.watchServer(matchingServer.name).take(3).toList();

        final addedServerResult = await api.addServer(
          name: matchingServer.name,
          address: matchingServer.address,
          port: matchingServer.port,
          password: matchingServer.password,
        );
        final addedServer = addedServerResult.unwrap();
        await repository.refresh();

        await pumpEventQueue();

        final values = await valuesFuture;
        // First value is the seeded empty list
        expect(values[0], isNull);
        // Second value is before the server is added
        expect(values[1], isNull);
        // Third value is after the server is added
        expect(values[2], addedServer);
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

    group('updateServer', () {
      test('refreshes after success', () async {
        final server = buildServer();
        final updated = server.copyWith(name: 'Updated');
        final api = FakeServersApi(initialServers: [server]);
        final repository = buildSubject(api: api);
        await pumpEventQueue();

        final result = await repository.updateServer(updated);

        expect(result.isOk(), isTrue);
        expect(api.updateServerCallCount, 1);
        expect(api.fetchServersCallCount, 2);
        expect(await repository.watchServers().first, [updated]);
      });

      test('does not refresh after failure', () async {
        final server = buildServer();
        final api = FakeServersApi(initialServers: [server])
          ..updateServerResult = Result.err(Exception('failure'));
        final repository = buildSubject(api: api);
        await pumpEventQueue();

        final result = await repository.updateServer(server.copyWith(name: 'Updated'));

        expect(result.isErr(), isTrue);
        expect(api.fetchServersCallCount, 1);
        expect(await repository.watchServers().first, [server]);
      });
    });

    group('clearServers', () {
      test('refreshes servers when the api call succeeds', () async {
        final server = buildServer();
        final api = FakeServersApi(initialServers: [server]);
        final repository = buildSubject(api: api);

        await pumpEventQueue();

        final result = await repository.clearServers();

        expect(result.isOk(), isTrue);
        expect(api.clearServersCallCount, 1);
        expect(api.fetchServersCallCount, 2);
        expect(await repository.watchServers().first, isEmpty);
      });

      test('does not refresh when the api call fails', () async {
        final server = buildServer();
        final api = FakeServersApi(initialServers: [server])
          ..clearServersResult = Result.err(Exception('failure'));
        final repository = buildSubject(api: api);

        await pumpEventQueue();

        final result = await repository.clearServers();

        expect(result.isErr(), isTrue);
        expect(api.clearServersCallCount, 1);
        expect(api.fetchServersCallCount, 1);
        expect(await repository.watchServers().first, [server]);
      });
    });
  });
}
