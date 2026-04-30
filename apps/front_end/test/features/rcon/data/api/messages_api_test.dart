import 'package:cs2_rcon_front_end/features/rcon/data/api/messages_api.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/models/message.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fakes/fake_box.dart';

void main() {
  group('MessagesApi', () {
    group('fetchMessages', () {
      test('returns only messages for the provided server', () async {
        final message1 = Message(
          id: '1',
          serverId: 'server1',
          body: 'Hello',
          sender: Sender.client,
        );
        final message2 = Message(
          id: '2',
          serverId: 'server2',
          body: 'World',
          sender: Sender.server,
        );
        final message3 = Message(
          id: '3',
          serverId: 'server1',
          body: 'Another',
          sender: Sender.server,
        );
        final fakeBox = FakeBox<Message>(
          initialValues: {message1.id: message1, message2.id: message2, message3.id: message3},
        );

        final messagesApi = MessagesApi(box: fakeBox);

        final messages = await messagesApi.fetchMessages('server1');

        expect(messages, equals([message1, message3]));
      });
    });

    group('addMessage', () {
      test('adds a message to the box', () async {
        final fakeBox = FakeBox<Message>();
        final messagesApi = MessagesApi(box: fakeBox);

        final message = Message.create(
          serverId: 'server1',
          body: 'Test message',
          sender: Sender.client,
        );

        await messagesApi.addMessage(message);

        expect(fakeBox.get(message.id), equals(message));
      });
    });

    group('deleteMessage', () {
      test('removes the message with the given id', () async {
        final message = Message(
          id: '1',
          serverId: 'server1',
          body: 'Delete me',
          sender: Sender.client,
        );
        final remainingMessage = Message(
          id: '2',
          serverId: 'server1',
          body: 'Keep me',
          sender: Sender.server,
        );
        final fakeBox = FakeBox<Message>(
          initialValues: {message.id: message, remainingMessage.id: remainingMessage},
        );
        final messagesApi = MessagesApi(box: fakeBox);

        await messagesApi.deleteMessage(message.id);

        expect(fakeBox.get(message.id), isNull);
        expect(fakeBox.get(remainingMessage.id), equals(remainingMessage));
      });
    });

    group('clearMessages', () {
      test('deletes all messages for the specified server', () async {
        final server1Message = Message(
          id: '1',
          serverId: 'server1',
          body: 'From server1',
          sender: Sender.client,
        );
        final server1Message2 = Message(
          id: '2',
          serverId: 'server1',
          body: 'Also server1',
          sender: Sender.server,
        );
        final server2Message = Message(
          id: '3',
          serverId: 'server2',
          body: 'From server2',
          sender: Sender.client,
        );

        final fakeBox = FakeBox<Message>(
          initialValues: {
            server1Message.id: server1Message,
            server1Message2.id: server1Message2,
            server2Message.id: server2Message,
          },
        );

        final messagesApi = MessagesApi(box: fakeBox);

        await messagesApi.clearMessages('server1');

        expect(fakeBox.get(server1Message.id), isNull);
        expect(fakeBox.get(server1Message2.id), isNull);
        expect(fakeBox.get(server2Message.id), equals(server2Message));
        expect(fakeBox.values.toList(), equals([server2Message]));
      });
    });
  });
}
