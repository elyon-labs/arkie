import 'package:cs2_rcon_front_end/features/rcon/data/models/saved_message.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/repository/saved_messages_repository.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/unsave_message.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import '../../../fakes/fake_saved_messages_api.dart';

void main() {
  group('UnsaveMessage', () {
    Server buildServer({
      String name = 'Test Server',
      String address = '127.0.0.1',
      int port = 27015,
      String password = 'password',
    }) {
      return Server.create(name: name, password: password, address: address, port: port);
    }

    SavedMessage buildSavedMessage({
      required Server server,
      String name = 'Test message',
      String body = 'Test body',
    }) {
      return SavedMessage(id: const Uuid().v4(), serverId: server.id, body: body, name: name);
    }

    test('unsaves the message and refreshes the repository', () async {
      final server = buildServer();
      final message = buildSavedMessage(server: server);
      final api = FakeSavedMessagesApi(initialMessages: [message]);
      final repository = SavedMessagesRepository(server: server, api: api);
      final unsaveMessage = UnsaveMessage(savedMessagesRepository: repository);

      await pumpEventQueue(); // allow initial fetch

      expect((await repository.watch().first).single, message);

      final result = await unsaveMessage(message);

      expect(result.isOk(), isTrue);
      expect(api.unsaveMessageCallCount, 1);
      expect(api.fetchMessagesCallCount, 2); // initial fetch + refresh

      expect(await repository.watch().first, isEmpty);
    });

    test('returns error when repository unsave fails and does not refresh', () async {
      final server = buildServer();
      final message = buildSavedMessage(server: server);
      final api = FakeSavedMessagesApi(
        initialMessages: [message],
        onUnsaveMessage: (_) => throw Exception('failure'),
      );
      final repository = SavedMessagesRepository(server: server, api: api);
      final unsaveMessage = UnsaveMessage(savedMessagesRepository: repository);

      await pumpEventQueue(); // allow initial fetch

      final result = await unsaveMessage(message);

      expect(result.isErr(), isTrue);
      expect(api.unsaveMessageCallCount, 1);
      expect(api.fetchMessagesCallCount, 1); // only the initial fetch
      expect((await repository.watch().first).single, message);
    });
  });
}
