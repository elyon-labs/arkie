import 'package:cs2_rcon_front_end/features/rcon/data/models/saved_message.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/repository/saved_messages_repository.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/rename_saved_message.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import '../../../fakes/fake_saved_messages_api.dart';

void main() {
  group('RenameSavedMessage', () {
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
      String name = 'Old name',
      String body = 'Test body',
    }) {
      return SavedMessage(id: const Uuid().v4(), serverId: server.id, body: body, name: name);
    }

    test('renames the message and refreshes the repository', () async {
      final server = buildServer();
      final message = buildSavedMessage(server: server, name: 'old name');
      final api = FakeSavedMessagesApi(initialMessages: [message]);
      final repository = SavedMessagesRepository(server: server, api: api);
      final renameSavedMessage = RenameSavedMessage(savedMessagesRepository: repository);

      await pumpEventQueue(); // allow initial fetch
      expect((await repository.watch().first).single.name, 'old name');

      final result = await renameSavedMessage(id: message.id, newName: 'new name');

      expect(result.isOk(), isTrue);
      final renamedMessage = result.unwrap();
      expect(renamedMessage.name, 'new name');
      expect(renamedMessage.id, message.id);
      expect(renamedMessage.serverId, server.id);
      expect(api.renameSavedMessageCallCount, 1);
      expect(api.fetchMessagesCallCount, 2); // initial fetch + refresh

      expect((await repository.watch().first).single.name, 'new name');
    });

    test('returns error when repository rename fails and does not refresh', () async {
      final server = buildServer();
      final message = buildSavedMessage(server: server, name: 'old name');
      final api = FakeSavedMessagesApi(
        initialMessages: [message],
        onRenameSavedMessage: (_, __, ___) => throw Exception('failure'),
      );
      final repository = SavedMessagesRepository(server: server, api: api);
      final renameSavedMessage = RenameSavedMessage(savedMessagesRepository: repository);

      await pumpEventQueue(); // allow initial fetch

      final result = await renameSavedMessage(id: message.id, newName: 'new name');

      expect(result.isErr(), isTrue);
      expect(api.renameSavedMessageCallCount, 1);
      expect(api.fetchMessagesCallCount, 1); // only initial fetch
      expect((await repository.watch().first).single.name, 'old name');
    });
  });
}
