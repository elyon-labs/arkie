import 'package:cs2_rcon_front_end/features/rcon/data/api/saved_messages_api.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/models/saved_message.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fakes/fake_box.dart';

void main() {
  group('SavedMessagesApi', () {
    group('fetchMessages', () {
      test('returns only messages for the provided server', () async {
        final message1 = SavedMessage(id: '1', serverId: 'server1', body: 'Hello', name: 'Hello');
        final message2 = SavedMessage(id: '2', serverId: 'server2', body: 'World', name: 'World');
        final message3 = SavedMessage(
          id: '3',
          serverId: 'server1',
          body: 'Another',
          name: 'Another',
        );
        final fakeBox = FakeBox<SavedMessage>(
          initialValues: {message1.id: message1, message2.id: message2, message3.id: message3},
        );

        final api = SavedMessagesApi(box: fakeBox);

        final messages = await api.fetchMessages('server1');

        expect(messages, equals([message1, message3]));
      });
    });

    group('saveMessage', () {
      test('adds a saved message to the box', () async {
        final fakeBox = FakeBox<SavedMessage>();
        final api = SavedMessagesApi(box: fakeBox);

        final message = SavedMessage(id: '1', serverId: 'server1', body: 'Body', name: 'Body');

        await api.saveMessage(message);

        expect(fakeBox.get(message.id), equals(message));
      });
    });

    group('unsaveMessage', () {
      test('removes the message with the given id', () async {
        final message = SavedMessage(id: '1', serverId: 'server1', body: 'Body', name: 'Body');
        final remainingMessage = SavedMessage(
          id: '2',
          serverId: 'server1',
          body: 'Keep',
          name: 'Keep',
        );
        final fakeBox = FakeBox<SavedMessage>(
          initialValues: {message.id: message, remainingMessage.id: remainingMessage},
        );
        final api = SavedMessagesApi(box: fakeBox);

        await api.unsaveMessage(message.id);

        expect(fakeBox.get(message.id), isNull);
        expect(fakeBox.get(remainingMessage.id), equals(remainingMessage));
      });
    });

    group('clearMessages', () {
      test('deletes all messages for the specified server', () async {
        final server1Message = SavedMessage(id: '1', serverId: 'server1', body: 'One', name: 'One');
        final server1Message2 = SavedMessage(
          id: '2',
          serverId: 'server1',
          body: 'Two',
          name: 'Two',
        );
        final server2Message = SavedMessage(
          id: '3',
          serverId: 'server2',
          body: 'Other',
          name: 'Other',
        );

        final fakeBox = FakeBox<SavedMessage>(
          initialValues: {
            server1Message.id: server1Message,
            server1Message2.id: server1Message2,
            server2Message.id: server2Message,
          },
        );

        final api = SavedMessagesApi(box: fakeBox);

        await api.clearMessages('server1');

        expect(fakeBox.get(server1Message.id), isNull);
        expect(fakeBox.get(server1Message2.id), isNull);
        expect(fakeBox.get(server2Message.id), equals(server2Message));
        expect(fakeBox.values.toList(), equals([server2Message]));
      });
    });

    group('renameSavedMessage', () {
      test('updates the message name when it exists for the server', () async {
        final message = SavedMessage(id: '1', serverId: 'server1', body: 'Body', name: 'Old name');
        final fakeBox = FakeBox<SavedMessage>(initialValues: {message.id: message});
        final api = SavedMessagesApi(box: fakeBox);

        final updated = await api.renameSavedMessage('server1', message.id, 'New name');

        expect(updated.name, 'New name');
        expect(updated.id, message.id);
        expect(fakeBox.get(message.id)?.name, 'New name');
      });

      test('throws when the message is missing or for another server', () async {
        final message = SavedMessage(id: '1', serverId: 'server1', body: 'Body', name: 'Old name');
        final fakeBox = FakeBox<SavedMessage>(initialValues: {message.id: message});
        final api = SavedMessagesApi(box: fakeBox);

        expect(
          () => api.renameSavedMessage('server2', message.id, 'New name'),
          throwsA(isA<Exception>()),
        );
        expect(
          () => api.renameSavedMessage('server1', 'missing-id', 'New name'),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
