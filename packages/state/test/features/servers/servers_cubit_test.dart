// ignore_for_file: cascade_invocations

import 'package:arkie_core/features/rcon/data/repository/messages_repository.dart';
import 'package:arkie_core/features/servers/data/models/server.dart';
import 'package:arkie_core/features/servers/data/repository/servers_repository.dart';
import 'package:arkie_core/features/servers/domain/add_demo_server.dart';
import 'package:arkie_core/features/servers/domain/remove_server.dart';
import 'package:arkie_core/features/servers/domain/watch_selected_server.dart';
import 'package:arkie_core/features/servers/domain/watch_servers.dart';
import 'package:arkie_core/testing/fake_messages_api.dart';
import 'package:arkie_core/testing/fake_servers_api.dart';
import 'package:arkie_core/testing/fake_settings_repository.dart';
import 'package:arkie_state/features/servers/servers_cubit.dart';
import 'package:arkie_state/features/servers/servers_state.dart';
import 'package:flutter_test/flutter_test.dart';

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
      FakeServersApi? serversApi,
      FakeMessagesApi? messagesApi,
    }) async {
      final api = serversApi ?? FakeServersApi(initialServers: servers ?? []);
      final messages = messagesApi ?? FakeMessagesApi();
      final settingsRepository = FakeSettingsRepository();
      final serversRepository = ServersRepository(api: api);

      await pumpEventQueue(); // Allow server fetch to complete before subscribing.

      final cubit = ServersCubit(
        watchServers: WatchServers(repository: serversRepository),
        addDemoServer: AddDemoServer(
          serversRepository: serversRepository,
          settingsRepository: settingsRepository,
        ),
        removeServerFor: (server) => RemoveServer(
          serversRepository: serversRepository,
          settingsRepository: settingsRepository,
          messagesRepository: MessagesRepository(server: server, api: messages),
          watchSelectedServer: WatchSelectedServer(
            repository: serversRepository,
            settingsRepository: settingsRepository,
          ),
        ),
      );

      await pumpEventQueue();
      return cubit;
    }

    Server? serverForSelectedTab(ServersCubit cubit) {
      final selectedTab = cubit.state.selectedTab;
      if (selectedTab is! NonEmptyServerTab) return null;

      for (final server in cubit.state.servers) {
        if (server.id == selectedTab.serverId) return server;
      }

      return null;
    }

    group('addDemoServer', () {
      test('saves the demo server and reports it in state', () async {
        final cubit = await buildSubject();
        expect(cubit.state.hasDemoServer, isFalse);

        final server = await cubit.addDemoServer();
        await pumpEventQueue();

        expect(server, isNotNull);
        expect(server!.isDemo, isTrue);
        expect(cubit.state.servers, [server]);
        expect(cubit.state.hasDemoServer, isTrue);
        await cubit.close();
      });

      test('only ever saves one', () async {
        final cubit = await buildSubject();

        final first = await cubit.addDemoServer();
        final second = await cubit.addDemoServer();
        await pumpEventQueue();

        expect(second!.id, first!.id);
        expect(cubit.state.servers, hasLength(1));
        await cubit.close();
      });

      test('leaves real servers alone', () async {
        final server = buildServer();
        final cubit = await buildSubject(servers: [server]);

        await cubit.addDemoServer();
        await pumpEventQueue();

        expect(cubit.state.servers, hasLength(2));
        expect(cubit.state.servers, contains(server));
        await cubit.close();
      });
    });

    group('removeServer', () {
      test('drops the server from the list', () async {
        final server = buildServer();
        final otherServer = buildServer(name: 'Other');
        final serversApi = FakeServersApi(initialServers: [server, otherServer]);
        final messagesApi = FakeMessagesApi();
        final cubit = await buildSubject(serversApi: serversApi, messagesApi: messagesApi);

        final result = await cubit.removeServer(server);
        await pumpEventQueue();

        expect(result.isOk(), isTrue);
        expect(messagesApi.clearMessagesCallCount, 1);
        expect(cubit.state.servers, [otherServer]);
        await cubit.close();
      });

      test('closes the tabs that were open for the removed server', () async {
        final server = buildServer();
        final serversApi = FakeServersApi(initialServers: [server]);
        final cubit = await buildSubject(serversApi: serversApi);
        cubit.selectServerForSelectedTab(server);

        await cubit.removeServer(server);
        await pumpEventQueue();

        expect(serverForSelectedTab(cubit), isNull);
        await cubit.close();
      });
    });

    group('openTab', () {
      test('starts with an empty selected tab without selecting a saved server', () async {
        final server = buildServer();
        final cubit = await buildSubject(servers: [server]);

        expect(cubit.state.openTabs, hasLength(1));
        expect(cubit.state.selectedTab, cubit.state.openTabs.single);
        expect(serverForSelectedTab(cubit), isNull);
        await cubit.close();
      });

      test('opens another empty selected tab', () async {
        final cubit = await buildSubject();
        final firstTabId = cubit.state.selectedTabId;

        cubit.openTab();

        expect(cubit.state.openTabs, hasLength(2));
        expect(cubit.state.selectedTabId, isNot(firstTabId));
        expect(cubit.state.selectedTab, cubit.state.openTabs.last);
        expect(serverForSelectedTab(cubit), isNull);
        await cubit.close();
      });
    });

    group('selectServerForSelectedTab', () {
      test('assigns a saved server to the selected empty tab', () async {
        final server = buildServer();
        final cubit = await buildSubject(servers: [server]);

        cubit.selectServerForSelectedTab(server);

        expect(
          cubit.state.openTabs.single,
          isA<NonEmptyServerTab>().having((tab) => tab.serverId, 'serverId', server.id),
        );
        expect(serverForSelectedTab(cubit), server);
        await cubit.close();
      });

      test('opens a tab when no tab is selected', () async {
        final server = buildServer();
        final cubit = await buildSubject(servers: [server]);

        cubit.closeTab(cubit.state.selectedTabId!);
        cubit.selectServerForSelectedTab(server);

        expect(cubit.state.openTabs, hasLength(1));
        expect(
          cubit.state.openTabs.single,
          isA<NonEmptyServerTab>().having((tab) => tab.serverId, 'serverId', server.id),
        );
        expect(serverForSelectedTab(cubit), server);
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
        expect(serverForSelectedTab(cubit), serverB);
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
        expect(serverForSelectedTab(cubit), serverB);
        await cubit.close();
      });
    });

    group('closeSelectedTab', () {
      test('removes the selected tab', () async {
        final serverA = buildServer(name: 'A');
        final serverB = buildServer(name: 'B');
        final cubit = await buildSubject(servers: [serverA, serverB]);

        cubit.selectServerForSelectedTab(serverA);
        final firstTabId = cubit.state.selectedTabId!;
        cubit.openTab();
        cubit.selectServerForSelectedTab(serverB);
        final secondTabId = cubit.state.selectedTabId!;
        cubit.selectTab(firstTabId);

        cubit.closeSelectedTab();

        expect(cubit.state.openTabs.map((tab) => tab.id), [secondTabId]);
        expect(cubit.state.selectedTabId, secondTabId);
        expect(serverForSelectedTab(cubit), serverB);
        await cubit.close();
      });

      test('opens a new empty tab when closing the only tab', () async {
        final server = buildServer();
        final cubit = await buildSubject(servers: [server]);

        cubit.selectServerForSelectedTab(server);
        final closedTabId = cubit.state.selectedTabId!;

        cubit.closeSelectedTab();

        expect(cubit.state.openTabs, hasLength(1));
        expect(cubit.state.openTabs.single, isA<EmptyServerTab>());
        expect(cubit.state.openTabs.single.id, isNot(closedTabId));
        expect(cubit.state.selectedTab, cubit.state.openTabs.single);
        expect(serverForSelectedTab(cubit), isNull);
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
        expect(serverForSelectedTab(cubit), serverB);
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
        expect(serverForSelectedTab(cubit), serverA);
        await cubit.close();
      });

      test('keeps the initial empty tab selected when it is the only tab', () async {
        final cubit = await buildSubject();
        final tabId = cubit.state.selectedTabId;

        cubit.selectNextServer();

        expect(cubit.state.selectedTabId, tabId);
        expect(serverForSelectedTab(cubit), isNull);
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
        expect(serverForSelectedTab(cubit), serverB);
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
        expect(serverForSelectedTab(cubit), serverB);
        await cubit.close();
      });
    });
  });
}
