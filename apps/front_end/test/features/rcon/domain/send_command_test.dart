import 'package:cs2_rcon_client/cs2_rcon_client.dart' hide SendCommand;
import 'package:cs2_rcon_front_end/features/rcon/data/models/message.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/repository/messages_repository.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/clear_messages.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/send_command.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxidized/oxidized.dart';

import '../../../fakes/fake_messages_api.dart';
import '../../../fakes/fake_rcon_connection.dart';

void main() {
  group('SendCommand', () {
    Server buildServer({
      String name = 'Test Server',
      String address = '127.0.0.1',
      int port = 27015,
      String password = 'password',
    }) {
      return Server.create(name: name, password: password, address: address, port: port);
    }

    group('when command is `clear`', () {
      test('clears messages from MessagesRepository', () async {
        final server = buildServer();
        final repository = MessagesRepository(server: server, api: FakeMessagesApi());

        // Add a message to ensure there is something to clear
        await repository.addMessage(content: 'Test message', sender: Sender.client);
        await repository.refresh();

        final initialCount = await repository.watch().first.then((messages) => messages.length);
        expect(initialCount, greaterThan(0));

        final sendCommand = SendCommand(
          messagesRepository: repository,
          clearMessages: ClearMessages(messagesRepository: repository),
        );

        final result = await sendCommand.call('clear', connection: const FakeRCONConnection());

        expect(result.isOk(), isTrue);
        expect(result.unwrap(), isA<None<Message>>());

        final newCount = await repository.watch().first.then((messages) => messages.length);
        expect(newCount, 0);
      });
    });

    group('when sending is successful', () {
      test('saves client and server messages', () async {
        final server = buildServer();
        final savedMessages = <Message>[];
        final repository = MessagesRepository(
          server: server,
          api: FakeMessagesApi(onAddMessage: savedMessages.add),
        );

        const command = 'status';

        final sendCommand = SendCommand(
          messagesRepository: repository,
          clearMessages: ClearMessages(messagesRepository: repository),
        );

        await sendCommand.call(
          command,
          connection: FakeRCONConnection(
            onSendCommand: (cmd) async {
              return Ok(RCONServerPacket.responseValue(id: 1, body: 'Server response to: $cmd'));
            },
          ),
        );

        expect(savedMessages.length, 2);
        expect(savedMessages[0].body, command);
        expect(savedMessages[0].sender, Sender.client);
        expect(savedMessages[1].body, 'Server response to: $command');
        expect(savedMessages[1].sender, Sender.server);
      });

      test('refreshes the MessagesRepository', () async {
        final server = buildServer();
        final repository = MessagesRepository(server: server, api: FakeMessagesApi());

        const command = 'status';

        final currentCount = await repository.watch().first.then((messages) => messages.length);

        expect(currentCount, 0);

        final sendCommand = SendCommand(
          messagesRepository: repository,
          clearMessages: ClearMessages(messagesRepository: repository),
        );

        await sendCommand.call(command, connection: const FakeRCONConnection());

        final newCount = await repository.watch().first.then((messages) => messages.length);

        expect(newCount, currentCount + 2);
      });
    });

    group('when server fails to respond', () {
      test('returns an error result', () async {
        final server = buildServer();
        final repository = MessagesRepository(server: server, api: FakeMessagesApi());

        const command = 'status';

        final sendCommand = SendCommand(
          messagesRepository: repository,
          clearMessages: ClearMessages(messagesRepository: repository),
        );

        final result = await sendCommand.call(
          command,
          connection: FakeRCONConnection(
            onSendCommand: (cmd) async {
              return Err(Exception('Failed to send command'));
            },
          ),
        );

        expect(result.isErr(), isTrue);
      });
    });
  });
}
