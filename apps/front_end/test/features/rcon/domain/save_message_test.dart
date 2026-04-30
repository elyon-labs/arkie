import 'package:cs2_rcon_front_end/features/rcon/data/models/message.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/repository/saved_messages_repository.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/save_message.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fakes/fake_saved_messages_api.dart';

void main() {
  group('SaveMessage', () {
    Server buildServer({
      String name = 'Test Server',
      String address = '127.0.0.1',
      int port = 27015,
      String password = 'password',
    }) {
      return Server.create(name: name, password: password, address: address, port: port);
    }

    test('saves the message and refreshes the repository', () async {
      final server = buildServer();
      final api = FakeSavedMessagesApi();
      final repository = SavedMessagesRepository(server: server, api: api);
      final saveMessage = SaveMessage(savedMessagesRepository: repository);

      await pumpEventQueue(); // allow initial fetch

      final message = Message.create(body: 'say hello', sender: Sender.client, serverId: server.id);

      final result = await saveMessage(message);

      expect(result.isOk(), isTrue);
      final savedMessage = result.unwrap();
      expect(savedMessage.name, 'say hello');
      expect(savedMessage.body, 'say hello');
      expect(savedMessage.serverId, server.id);
      expect(api.saveMessageCallCount, 1);
      expect(api.fetchMessagesCallCount, 2); // initial fetch + refresh

      final storedMessages = await repository.watch().first;
      expect(storedMessages, hasLength(1));
      expect(storedMessages.single, savedMessage);
    });

    test('returns error when repository save fails and does not refresh', () async {
      final server = buildServer();
      final api = FakeSavedMessagesApi(onSaveMessage: (_) => throw Exception('failure'));
      final repository = SavedMessagesRepository(server: server, api: api);
      final saveMessage = SaveMessage(savedMessagesRepository: repository);

      await pumpEventQueue(); // allow initial fetch

      final message = Message.create(body: 'say hello', sender: Sender.client, serverId: server.id);

      final result = await saveMessage(message);

      expect(result.isErr(), isTrue);
      expect(api.saveMessageCallCount, 1);
      expect(api.fetchMessagesCallCount, 1); // only the initial fetch
      expect(await repository.watch().first, isEmpty);
    });
  });
}
