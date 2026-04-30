import 'package:cs2_rcon_front_end/features/rcon/data/models/message.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/repository/messages_repository.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fakes/fake_messages_api.dart';

void main() {
  group('MessagesRepository', () {
    Server buildServer({
      String name = 'Test Server',
      String address = 'localhost',
      int port = 27015,
      String password = 'password',
    }) {
      return Server.create(name: name, password: password, address: address, port: port);
    }

    MessagesRepository buildSubject({required Server server, FakeMessagesApi? api}) {
      return MessagesRepository(server: server, api: api ?? FakeMessagesApi());
    }

    Message buildMessage({
      required Server server,
      String body = 'Test message',
      Sender sender = Sender.server,
    }) {
      return Message.create(body: body, sender: sender, serverId: server.id);
    }

    Matcher matchesMessage(Message expected) {
      return isA<Message>()
          .having((message) => message.body, 'body', expected.body)
          .having((message) => message.sender, 'sender', expected.sender)
          .having((message) => message.serverId, 'serverId', expected.serverId);
    }

    test('fetches messages immediately on instantiation', () async {
      final server = buildServer();
      final api = FakeMessagesApi();

      buildSubject(server: server, api: api);

      await pumpEventQueue();

      expect(api.fetchMessagesCallCount, 1);
    });

    group('watch', () {
      test('emits the messages fetched for the server', () async {
        final server = buildServer();
        final expectedMessage = buildMessage(server: server);
        final api = FakeMessagesApi(initialMessages: [expectedMessage]);

        final repository = buildSubject(server: server, api: api);

        final messages = await repository.watch().first;

        expect(messages, hasLength(1));
        expect(messages.single, matchesMessage(expectedMessage));
      });
    });

    group('refresh', () {
      test('updates the stream with the latest messages', () async {
        final server = buildServer();
        final firstMessage = buildMessage(server: server, body: 'first');
        final api = FakeMessagesApi(initialMessages: [firstMessage]);
        final repository = buildSubject(server: server, api: api);

        expect((await repository.watch().first).single, matchesMessage(firstMessage));

        final secondMessage = buildMessage(server: server, body: 'second');
        await api.addMessage(secondMessage);

        await repository.refresh();

        final refreshedMessages = await repository.watch().first;
        expect(refreshedMessages, hasLength(2));
        expect(refreshedMessages[1], matchesMessage(secondMessage));
        expect(api.fetchMessagesCallCount, 2);
      });
    });

    group('addMessage', () {
      test('returns created message and stores it via the api', () async {
        final server = buildServer();
        final api = FakeMessagesApi();
        final repository = buildSubject(server: server, api: api);

        await pumpEventQueue();

        final result = await repository.addMessage(content: 'hello world', sender: Sender.client);

        expect(result.isOk(), isTrue);
        final message = result.unwrap();
        expect(message.body, 'hello world');
        expect(message.sender, Sender.client);
        expect(message.serverId, server.id);
        expect(api.addMessageCallCount, 1);

        await repository.refresh();
        final storedMessages = await repository.watch().first;
        expect(storedMessages, hasLength(1));
        expect(storedMessages.single, matchesMessage(message));
      });

      test('returns an error when the api throws', () async {
        final server = buildServer();
        final api = FakeMessagesApi(
          onAddMessage: (msg) {
            throw Exception('failure');
          },
        );
        final repository = buildSubject(server: server, api: api);

        await pumpEventQueue();

        final result = await repository.addMessage(content: 'should fail', sender: Sender.server);

        expect(result.isErr(), isTrue);
        expect(api.addMessageCallCount, 1);
        expect(api.fetchMessagesCallCount, 1);
      });
    });

    group('clearMessages', () {
      test('clears messages for the current server', () async {
        final server = buildServer();
        final otherServer = buildServer(name: 'Other server');
        final serverMessage = buildMessage(server: server);
        final otherMessage = buildMessage(server: otherServer);
        final api = FakeMessagesApi(initialMessages: [serverMessage, otherMessage]);
        final repository = buildSubject(server: server, api: api);

        expect((await repository.watch().first).single, matchesMessage(serverMessage));

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
        final message = buildMessage(server: server);
        final api = FakeMessagesApi(
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
        expect((await repository.watch().first).single, matchesMessage(message));
      });
    });
  });
}
