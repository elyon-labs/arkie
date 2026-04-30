import 'package:cs2_rcon_front_end/features/rcon/data/models/message.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/repository/messages_repository.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:cs2_rcon_front_end/features/servers/data/repository/servers_repository.dart';
import 'package:cs2_rcon_front_end/features/servers/domain/remove_server.dart';
import 'package:cs2_rcon_front_end/features/servers/domain/watch_selected_server.dart';
import 'package:cs2_rcon_front_end/features/settings/data/repository/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fakes/fake_messages_api.dart';
import '../../../fakes/fake_servers_api.dart';
import '../../../fakes/fake_settings_repository.dart';

void main() {
  group('RemoveServer', () {
    Server buildServer({
      String name = 'Test Server',
      String address = '127.0.0.1',
      int port = 27015,
      String password = 'password',
    }) {
      return Server.create(name: name, password: password, address: address, port: port);
    }

    Message buildMessage({
      required Server server,
      String body = 'test',
      Sender sender = Sender.server,
    }) {
      return Message.create(body: body, sender: sender, serverId: server.id);
    }

    Future<RemoveServer> buildSubject({
      required Server server,
      FakeServersApi? serversApi,
      FakeMessagesApi? messagesApi,
      SettingsRepository? settingsRepository,
      String? selectedServerId,
    }) async {
      final api = serversApi ?? FakeServersApi(initialServers: [server]);
      settingsRepository ??= FakeSettingsRepository(selectedServerId: selectedServerId);
      final messages = messagesApi ?? FakeMessagesApi();
      final serversRepository = ServersRepository(api: api);
      final messagesRepository = MessagesRepository(server: server, api: messages);
      final watchSelectedServer = WatchSelectedServer(
        repository: serversRepository,
        settingsRepository: settingsRepository,
      );

      await pumpEventQueue(); // Allow initial fetches to complete

      return RemoveServer(
        serversRepository: serversRepository,
        messagesRepository: messagesRepository,
        watchSelectedServer: watchSelectedServer,
        settingsRepository: settingsRepository,
      );
    }

    test('clears messages then removes server', () async {
      final server = buildServer();
      final otherServer = buildServer(name: 'Other');
      final serverMessage = buildMessage(server: server, body: 'to delete');
      final otherMessage = buildMessage(server: otherServer, body: 'to keep');
      final messagesApi = FakeMessagesApi(initialMessages: [serverMessage, otherMessage]);
      final serversApi = FakeServersApi(initialServers: [server, otherServer]);

      final removeServer = await buildSubject(
        server: server,
        serversApi: serversApi,
        messagesApi: messagesApi,
      );

      final result = await removeServer(server);

      expect(result.isOk(), isTrue);
      expect(messagesApi.clearMessagesCallCount, 1);
      expect(serversApi.removeServerCallCount, 1);
      expect(await serversApi.fetchServers(), [otherServer]);
      final remainingMessages = await messagesApi.fetchMessages(otherServer.id);
      expect(remainingMessages, [otherMessage]);
    });

    test('clears selected server when removing currently selected server', () async {
      final server = buildServer();
      final messagesApi = FakeMessagesApi();
      final serversApi = FakeServersApi(initialServers: [server]);
      final settingsRepository = FakeSettingsRepository(selectedServerId: server.id);

      final removeServer = await buildSubject(
        server: server,
        serversApi: serversApi,
        messagesApi: messagesApi,
        settingsRepository: settingsRepository,
      );

      final result = await removeServer(server);

      expect(result.isOk(), isTrue);
      expect(messagesApi.clearMessagesCallCount, 1);
      expect(serversApi.removeServerCallCount, 1);
      expect(await settingsRepository.watchSelectedServer().first, isNull);
      expect(await serversApi.fetchServers(), isEmpty);
    });

    test('does not clear selection when removing a different server', () async {
      final selectedServer = buildServer(name: 'Selected');
      final serverToRemove = buildServer(name: 'Remove me');
      final messagesApi = FakeMessagesApi();
      final serversApi = FakeServersApi(initialServers: [selectedServer, serverToRemove]);
      final settingsRepository = FakeSettingsRepository(selectedServerId: selectedServer.id);

      final removeServer = await buildSubject(
        server: serverToRemove,
        serversApi: serversApi,
        messagesApi: messagesApi,
        settingsRepository: settingsRepository,
      );

      final result = await removeServer(serverToRemove);

      expect(result.isOk(), isTrue);
      expect(messagesApi.clearMessagesCallCount, 1);
      expect(serversApi.removeServerCallCount, 1);
      expect(await settingsRepository.watchSelectedServer().first, selectedServer.id);
      expect(await serversApi.fetchServers(), [selectedServer]);
    });

    test('returns an error when clearing messages fails and does not remove server', () async {
      final server = buildServer();
      final messagesApi = FakeMessagesApi(
        onClearMessages: () {
          throw Exception('fail');
        },
      );
      final serversApi = FakeServersApi(initialServers: [server]);
      final settingsRepository = FakeSettingsRepository(selectedServerId: server.id);

      final removeServer = await buildSubject(
        server: server,
        serversApi: serversApi,
        messagesApi: messagesApi,
        settingsRepository: settingsRepository,
      );

      final result = await removeServer(server);

      expect(result.isErr(), isTrue);
      expect(messagesApi.clearMessagesCallCount, 1);
      expect(serversApi.removeServerCallCount, 0);
      expect(await settingsRepository.watchSelectedServer().first, server.id);
      expect(await serversApi.fetchServers(), [server]);
    });
  });
}
