import 'package:cs2_rcon_front_end/features/rcon/data/models/message.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/models/saved_message.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/repository/saved_messages_repository.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import '../../../../fakes/fake_saved_messages_api.dart';

void main() {
  group('SavedMessagesRepository', () {
    Server buildServer({
      String name = 'Test Server',
      String address = 'localhost',
      int port = 27015,
      String password = 'password',
    }) {
      return Server.create(name: name, password: password, address: address, port: port);
    }

    SavedMessagesRepository buildSubject({required Server server, FakeSavedMessagesApi? api}) {
      return SavedMessagesRepository(server: server, api: api ?? FakeSavedMessagesApi());
    }

    Message buildMessage({
      required Server server,
      String body = 'Test message',
      Sender sender = Sender.server,
    }) {
      return Message.create(body: body, sender: sender, serverId: server.id);
    }

    SavedMessage buildSavedMessage({
      required Server server,
      String name = 'Test message',
      String body = 'Test body',
    }) {
      return SavedMessage(id: const Uuid().v4(), name: name, body: body, serverId: server.id);
    }

    test('fetches messages immediately on instantiation', () async {
      final server = buildServer();
      final api = FakeSavedMessagesApi();

      buildSubject(server: server, api: api);

      await pumpEventQueue();

      expect(api.fetchMessagesCallCount, 1);
    });

    group('watch', () {
      test('emits the messages fetched for the server', () async {
        final server = buildServer();
        final expectedMessage = buildSavedMessage(server: server);
        final api = FakeSavedMessagesApi(initialMessages: [expectedMessage]);

        final repository = buildSubject(server: server, api: api);

        final messages = await repository.watch().first;

        expect(messages, hasLength(1));
        expect(messages.single, expectedMessage);
      });
    });

    group('refresh', () {
      test('updates the stream with the latest messages', () async {
        final server = buildServer();
        final firstMessage = buildSavedMessage(server: server, name: 'first');
        final api = FakeSavedMessagesApi(initialMessages: [firstMessage]);
        final repository = buildSubject(server: server, api: api);

        expect((await repository.watch().first).single, firstMessage);

        final secondMessage = buildSavedMessage(server: server, name: 'second');
        await api.saveMessage(secondMessage);

        await repository.refresh();

        final refreshedMessages = await repository.watch().first;
        expect(refreshedMessages, hasLength(2));
        expect(refreshedMessages[1], secondMessage);
        expect(api.fetchMessagesCallCount, 2);
      });
    });

    group('saveMessage', () {
      test('returns created message and stores it via the api', () async {
        final server = buildServer();
        final api = FakeSavedMessagesApi();
        final repository = buildSubject(server: server, api: api);

        await pumpEventQueue();

        final inputMessage = buildMessage(
          server: server,
          body: 'hello world',
          sender: Sender.client,
        );

        final result = await repository.saveMessage(message: inputMessage);

        expect(result.isOk(), isTrue);
        final savedMessage = result.unwrap();
        expect(savedMessage.name, inputMessage.bodyWithoutTerminalCharacter);
        expect(savedMessage.body, inputMessage.body);
        expect(savedMessage.serverId, server.id);
        expect(api.saveMessageCallCount, 1);

        await repository.refresh();
        final storedMessages = await repository.watch().first;
        expect(storedMessages, hasLength(1));
        expect(storedMessages.single, savedMessage);
      });

      test('returns an error when the api throws', () async {
        final server = buildServer();
        final api = FakeSavedMessagesApi(
          onSaveMessage: (msg) {
            throw Exception('failure');
          },
        );
        final repository = buildSubject(server: server, api: api);

        await pumpEventQueue();

        final message = buildMessage(server: server, body: 'body', sender: Sender.client);

        final result = await repository.saveMessage(message: message);

        expect(result.isErr(), isTrue);
        expect(api.saveMessageCallCount, 1);
        expect(api.fetchMessagesCallCount, 1);
      });
    });

    group('unsaveMessage', () {
      test('removes message and updates the stream', () async {
        final server = buildServer();
        final message = buildSavedMessage(server: server);
        final api = FakeSavedMessagesApi(initialMessages: [message]);
        final repository = buildSubject(server: server, api: api);

        expect((await repository.watch().first).single, message);

        final result = await repository.unsaveMessage(message: message);

        expect(result.isOk(), isTrue);
        expect(api.unsaveMessageCallCount, 1);

        await repository.refresh();
        expect(await repository.watch().first, isEmpty);
      });

      test('returns an error when the api throws', () async {
        final server = buildServer();
        final message = buildSavedMessage(server: server);
        final api = FakeSavedMessagesApi(
          initialMessages: [message],
          onUnsaveMessage: (id) {
            throw Exception('failure');
          },
        );
        final repository = buildSubject(server: server, api: api);

        await pumpEventQueue();

        final result = await repository.unsaveMessage(message: message);

        expect(result.isErr(), isTrue);
        expect(api.unsaveMessageCallCount, 1);

        await repository.refresh();
        expect((await repository.watch().first).single, message);
      });
    });

    group('renameSavedMessage', () {
      test('renames message and updates the stream', () async {
        final server = buildServer();
        final message = buildSavedMessage(server: server, name: 'old name');
        final api = FakeSavedMessagesApi(initialMessages: [message]);
        final repository = buildSubject(server: server, api: api);

        expect((await repository.watch().first).single.name, 'old name');

        final result = await repository.renameSavedMessage(id: message.id, newName: 'new name');

        expect(result.isOk(), isTrue);
        final renamedMessage = result.unwrap();
        expect(renamedMessage.name, 'new name');
        expect(renamedMessage.id, message.id);
        expect(api.renameSavedMessageCallCount, 1);

        await repository.refresh();
        expect((await repository.watch().first).single.name, 'new name');
      });

      test('returns an error when the api throws', () async {
        final server = buildServer();
        final message = buildSavedMessage(server: server, name: 'old name');
        final api = FakeSavedMessagesApi(
          initialMessages: [message],
          onRenameSavedMessage: (serverId, id, newName) {
            throw Exception('failure');
          },
        );
        final repository = buildSubject(server: server, api: api);

        await pumpEventQueue();

        final result = await repository.renameSavedMessage(id: message.id, newName: 'new name');

        expect(result.isErr(), isTrue);
        expect(api.renameSavedMessageCallCount, 1);

        await repository.refresh();
        expect((await repository.watch().first).single.name, 'old name');
      });
    });

    group('clearMessages', () {
      test('clears messages for the current server', () async {
        final server = buildServer();
        final otherServer = buildServer(name: 'Other server');
        final serverMessage = buildSavedMessage(server: server);
        final otherMessage = buildSavedMessage(server: otherServer);
        final api = FakeSavedMessagesApi(initialMessages: [serverMessage, otherMessage]);
        final repository = buildSubject(server: server, api: api);

        expect((await repository.watch().first).single, serverMessage);

        final result = await repository.clearMessages();

        expect(result.isOk(), isTrue);
        expect(api.clearMessagesCallCount, 1);

        await repository.refresh();
        expect(await repository.watch().first, isEmpty);

        final otherServerMessages = await api.fetchMessages(otherServer.id);
        expect(otherServerMessages, [otherMessage]);
      });

      test('returns an error when the api throws', () async {
        final server = buildServer();
        final message = buildSavedMessage(server: server);
        final api = FakeSavedMessagesApi(
          initialMessages: [message],
          onClearMessages: () {
            throw Exception('failure');
          },
        );
        final repository = buildSubject(server: server, api: api);

        await pumpEventQueue();

        final result = await repository.clearMessages();

        expect(result.isErr(), isTrue);
        expect(api.clearMessagesCallCount, 1);

        await repository.refresh();
        expect((await repository.watch().first).single, message);
      });
    });
  });
}
