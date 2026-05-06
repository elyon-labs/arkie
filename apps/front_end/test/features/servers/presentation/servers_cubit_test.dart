import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:cs2_rcon_front_end/features/servers/data/repository/servers_repository.dart';
import 'package:cs2_rcon_front_end/features/servers/domain/select_server.dart';
import 'package:cs2_rcon_front_end/features/servers/domain/unselect_server.dart';
import 'package:cs2_rcon_front_end/features/servers/domain/watch_selected_server.dart';
import 'package:cs2_rcon_front_end/features/servers/domain/watch_servers.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/servers_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fakes/fake_servers_api.dart';
import '../../../fakes/fake_settings_repository.dart';

void main() {
  group('ServersCubit', () {
    Server buildServer({
      String name = 'Test Server',
      String address = '127.0.0.1',
      int port = 27015,
      String password = 'password',
    }) {
      return Server.create(name: name, password: password, address: address, port: port);
    }

    Future<ServersCubit> buildSubject({
      List<Server>? servers,
    }) async {
      final api = FakeServersApi(initialServers: servers ?? []);
      final settingsRepository = FakeSettingsRepository();
      final serversRepository = ServersRepository(api: api);

      await pumpEventQueue(); // Allow server fetch to complete before subscribing.

      final cubit = ServersCubit(
        watchServers: WatchServers(repository: serversRepository),
        selectServer: SelectServer(repository: settingsRepository),
        watchSelectedServer: WatchSelectedServer(
          repository: serversRepository,
          settingsRepository: settingsRepository,
        ),
        unselectServer: UnselectServer(repository: settingsRepository),
      );

      await pumpEventQueue();
      return cubit;
    }

    group('closeTab', () {
      test('deselects the server when it is currently selected', () async {
        final server = buildServer();
        final cubit = await buildSubject(servers: [server]);

        await cubit.selectServer(server);
        await pumpEventQueue();
        expect(cubit.state.selectedServer, server);

        await cubit.closeTab(server);
        await pumpEventQueue();

        expect(cubit.state.selectedServer, isNull);
        await cubit.close();
      });

      test('does nothing when the closed server is not currently selected', () async {
        final serverA = buildServer(name: 'A');
        final serverB = buildServer(name: 'B');
        final cubit = await buildSubject(servers: [serverA, serverB]);

        await cubit.selectServer(serverA);
        await pumpEventQueue();
        expect(cubit.state.selectedServer, serverA);

        await cubit.closeTab(serverB);
        await pumpEventQueue();

        expect(cubit.state.selectedServer, serverA);
        await cubit.close();
      });
    });

    group('selectNextServer', () {
      test('selects the next server in the list', () async {
        final serverA = buildServer(name: 'A');
        final serverB = buildServer(name: 'B');
        final serverC = buildServer(name: 'C');
        final cubit = await buildSubject(servers: [serverA, serverB, serverC]);

        await cubit.selectServer(serverA);
        await pumpEventQueue();

        await cubit.selectNextServer();
        await pumpEventQueue();

        expect(cubit.state.selectedServer, serverB);
        await cubit.close();
      });

      test('wraps around to the first server when at the end of the list', () async {
        final serverA = buildServer(name: 'A');
        final serverB = buildServer(name: 'B');
        final cubit = await buildSubject(servers: [serverA, serverB]);

        await cubit.selectServer(serverB);
        await pumpEventQueue();

        await cubit.selectNextServer();
        await pumpEventQueue();

        expect(cubit.state.selectedServer, serverA);
        await cubit.close();
      });

      test('selects the first server when no server is currently selected', () async {
        final serverA = buildServer(name: 'A');
        final serverB = buildServer(name: 'B');
        final cubit = await buildSubject(servers: [serverA, serverB]);

        expect(cubit.state.selectedServer, isNull);

        await cubit.selectNextServer();
        await pumpEventQueue();

        expect(cubit.state.selectedServer, serverA);
        await cubit.close();
      });

      test('does nothing when there are no servers', () async {
        final cubit = await buildSubject();

        await cubit.selectNextServer();
        await pumpEventQueue();

        expect(cubit.state.selectedServer, isNull);
        await cubit.close();
      });
    });

    group('selectPreviousServer', () {
      test('selects the previous server in the list', () async {
        final serverA = buildServer(name: 'A');
        final serverB = buildServer(name: 'B');
        final serverC = buildServer(name: 'C');
        final cubit = await buildSubject(servers: [serverA, serverB, serverC]);

        await cubit.selectServer(serverC);
        await pumpEventQueue();

        await cubit.selectPreviousServer();
        await pumpEventQueue();

        expect(cubit.state.selectedServer, serverB);
        await cubit.close();
      });

      test('wraps around to the last server when at the start of the list', () async {
        final serverA = buildServer(name: 'A');
        final serverB = buildServer(name: 'B');
        final cubit = await buildSubject(servers: [serverA, serverB]);

        await cubit.selectServer(serverA);
        await pumpEventQueue();

        await cubit.selectPreviousServer();
        await pumpEventQueue();

        expect(cubit.state.selectedServer, serverB);
        await cubit.close();
      });

      test('selects the last server when no server is currently selected', () async {
        final serverA = buildServer(name: 'A');
        final serverB = buildServer(name: 'B');
        final cubit = await buildSubject(servers: [serverA, serverB]);

        expect(cubit.state.selectedServer, isNull);

        await cubit.selectPreviousServer();
        await pumpEventQueue();

        expect(cubit.state.selectedServer, serverB);
        await cubit.close();
      });

      test('does nothing when there are no servers', () async {
        final cubit = await buildSubject();

        await cubit.selectPreviousServer();
        await pumpEventQueue();

        expect(cubit.state.selectedServer, isNull);
        await cubit.close();
      });
    });
  });
}
