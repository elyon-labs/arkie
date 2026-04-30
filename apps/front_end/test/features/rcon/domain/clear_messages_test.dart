import 'package:cs2_rcon_front_end/features/rcon/data/models/message.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/repository/messages_repository.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/clear_messages.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fakes/fake_messages_api.dart';

void main() {
  group('ClearMessages', () {
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

    test('clears messages and refreshes the repository', () async {
      final server = buildServer();
      final initialMessage = buildMessage(server: server);
      final api = FakeMessagesApi(initialMessages: [initialMessage]);
      final repository = MessagesRepository(server: server, api: api);
      final clearMessages = ClearMessages(messagesRepository: repository);

      await pumpEventQueue(); // allow initial fetch

      expect(await repository.watch().first, [initialMessage]);

      final result = await clearMessages();

      await pumpEventQueue(); // allow refresh

      expect(result.isOk(), isTrue);
      expect(api.clearMessagesCallCount, 1);
      expect(api.fetchMessagesCallCount, 2); // initial fetch + refresh
      expect(await repository.watch().first, isEmpty);
    });

    test('returns an error when repository clear fails and does not refresh', () async {
      final server = buildServer();
      final initialMessage = buildMessage(server: server);
      final api = FakeMessagesApi(
        initialMessages: [initialMessage],
        onClearMessages: () => throw Exception('failed to clear'),
      );
      final repository = MessagesRepository(server: server, api: api);
      final clearMessages = ClearMessages(messagesRepository: repository);

      await pumpEventQueue(); // allow initial fetch

      final result = await clearMessages();

      expect(result.isErr(), isTrue);
      expect(api.clearMessagesCallCount, 1);
      expect(api.fetchMessagesCallCount, 1); // only the initial fetch
      expect(await repository.watch().first, [initialMessage]);
    });
  });
}
