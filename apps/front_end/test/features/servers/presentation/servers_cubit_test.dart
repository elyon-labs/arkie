// ignore_for_file: cascade_invocations

import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:cs2_rcon_front_end/features/servers/data/repository/servers_repository.dart';
import 'package:cs2_rcon_front_end/features/servers/domain/watch_servers.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/servers_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fakes/fake_servers_api.dart';

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

    Future<ServersCubit> buildSubject({List<Server>? servers}) async {
      final api = FakeServersApi(initialServers: servers ?? []);
      final serversRepository = ServersRepository(api: api);

      await pumpEventQueue(); // Allow server fetch to complete before subscribing.

      final cubit = ServersCubit(watchServers: WatchServers(repository: serversRepository));

      await pumpEventQueue();
      return cubit;
    }

    group('openTab', () {
      test('starts with an empty selected tab without selecting a saved server', () async {
        final server = buildServer();
        final cubit = await buildSubject(servers: [server]);

        expect(cubit.state.openTabs, hasLength(1));
        expect(cubit.state.selectedTab, cubit.state.openTabs.single);
        expect(cubit.state.selectedServer, isNull);
        await cubit.close();
      });

      test('opens another empty selected tab', () async {
        final cubit = await buildSubject();
        final firstTabId = cubit.state.selectedTabId;

        cubit.openTab();

        expect(cubit.state.openTabs, hasLength(2));
        expect(cubit.state.selectedTabId, isNot(firstTabId));
        expect(cubit.state.selectedTab, cubit.state.openTabs.last);
        expect(cubit.state.selectedServer, isNull);
        await cubit.close();
      });
    });

    group('selectServerForSelectedTab', () {
      test('assigns a saved server to the selected empty tab', () async {
        final server = buildServer();
        final cubit = await buildSubject(servers: [server]);

        cubit.selectServerForSelectedTab(server);

        expect(cubit.state.openTabs.single.serverId, server.id);
        expect(cubit.state.selectedServer, server);
        await cubit.close();
      });

      test('opens a tab when no tab is selected', () async {
        final server = buildServer();
        final cubit = await buildSubject(servers: [server]);

        cubit.closeTab(cubit.state.selectedTabId!);
        cubit.selectServerForSelectedTab(server);

        expect(cubit.state.openTabs, hasLength(1));
        expect(cubit.state.openTabs.single.serverId, server.id);
        expect(cubit.state.selectedServer, server);
        await cubit.close();
      });
    });

    group('closeTab', () {
      test('removes the selected tab and selects the next tab', () async {
        final serverA = buildServer(name: 'A');
        final serverB = buildServer(name: 'B');
        final cubit = await buildSubject(servers: [serverA, serverB]);

        cubit.selectServerForSelectedTab(serverA);
        final firstTabId = cubit.state.selectedTabId!;
        cubit.openTab();
        cubit.selectServerForSelectedTab(serverB);
        final secondTabId = cubit.state.selectedTabId!;

        cubit.selectTab(firstTabId);
        cubit.closeTab(firstTabId);

        expect(cubit.state.openTabs.map((tab) => tab.id), [secondTabId]);
        expect(cubit.state.selectedTabId, secondTabId);
        expect(cubit.state.selectedServer, serverB);
        await cubit.close();
      });

      test('keeps the current selection when closing another tab', () async {
        final serverA = buildServer(name: 'A');
        final serverB = buildServer(name: 'B');
        final cubit = await buildSubject(servers: [serverA, serverB]);

        cubit.selectServerForSelectedTab(serverA);
        final firstTabId = cubit.state.selectedTabId!;
        cubit.openTab();
        cubit.selectServerForSelectedTab(serverB);
        final secondTabId = cubit.state.selectedTabId!;

        cubit.closeTab(firstTabId);

        expect(cubit.state.openTabs.map((tab) => tab.id), [secondTabId]);
        expect(cubit.state.selectedTabId, secondTabId);
        expect(cubit.state.selectedServer, serverB);
        await cubit.close();
      });
    });

    group('selectNextServer', () {
      test('selects the next open tab', () async {
        final serverA = buildServer(name: 'A');
        final serverB = buildServer(name: 'B');
        final serverC = buildServer(name: 'C');
        final cubit = await buildSubject(servers: [serverA, serverB, serverC]);

        cubit.selectServerForSelectedTab(serverA);
        final firstTabId = cubit.state.selectedTabId!;
        cubit.openTab();
        cubit.selectServerForSelectedTab(serverB);
        final secondTabId = cubit.state.selectedTabId!;
        cubit.openTab();
        cubit.selectServerForSelectedTab(serverC);

        cubit.selectTab(firstTabId);
        cubit.selectNextServer();

        expect(cubit.state.selectedTabId, secondTabId);
        expect(cubit.state.selectedServer, serverB);
        await cubit.close();
      });

      test('wraps around to the first open tab', () async {
        final serverA = buildServer(name: 'A');
        final serverB = buildServer(name: 'B');
        final cubit = await buildSubject(servers: [serverA, serverB]);

        cubit.selectServerForSelectedTab(serverA);
        final firstTabId = cubit.state.selectedTabId!;
        cubit.openTab();
        cubit.selectServerForSelectedTab(serverB);

        cubit.selectNextServer();

        expect(cubit.state.selectedTabId, firstTabId);
        expect(cubit.state.selectedServer, serverA);
        await cubit.close();
      });

      test('keeps the initial empty tab selected when it is the only tab', () async {
        final cubit = await buildSubject();
        final tabId = cubit.state.selectedTabId;

        cubit.selectNextServer();

        expect(cubit.state.selectedTabId, tabId);
        expect(cubit.state.selectedServer, isNull);
        await cubit.close();
      });
    });

    group('selectPreviousServer', () {
      test('selects the previous open tab', () async {
        final serverA = buildServer(name: 'A');
        final serverB = buildServer(name: 'B');
        final serverC = buildServer(name: 'C');
        final cubit = await buildSubject(servers: [serverA, serverB, serverC]);

        cubit.selectServerForSelectedTab(serverA);
        cubit.openTab();
        cubit.selectServerForSelectedTab(serverB);
        final secondTabId = cubit.state.selectedTabId!;
        cubit.openTab();
        cubit.selectServerForSelectedTab(serverC);

        cubit.selectPreviousServer();

        expect(cubit.state.selectedTabId, secondTabId);
        expect(cubit.state.selectedServer, serverB);
        await cubit.close();
      });

      test('wraps around to the last open tab', () async {
        final serverA = buildServer(name: 'A');
        final serverB = buildServer(name: 'B');
        final cubit = await buildSubject(servers: [serverA, serverB]);

        cubit.selectServerForSelectedTab(serverA);
        cubit.openTab();
        cubit.selectServerForSelectedTab(serverB);
        final secondTabId = cubit.state.selectedTabId!;
        cubit.selectTab(cubit.state.openTabs.first.id);

        cubit.selectPreviousServer();

        expect(cubit.state.selectedTabId, secondTabId);
        expect(cubit.state.selectedServer, serverB);
        await cubit.close();
      });
    });
  });
}
