import 'package:cs2_rcon_client/cs2_rcon_client.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/models/message.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/repository/messages_repository.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/clear_messages.dart';
import 'package:oxidized/oxidized.dart';

class SendCommand {
  SendCommand({
    required MessagesRepository messagesRepository,
    required ClearMessages clearMessages,
  }) : _messagesRepository = messagesRepository,
       _clearMessages = clearMessages;

  final MessagesRepository _messagesRepository;
  final ClearMessages _clearMessages;

  Future<Result<Option<Message>, Exception>> call(
    String command, {
    required RCONConnection connection,
  }) async {
    if (command.trim() == 'clear') {
      return await _clearMessages().map((_) => const None<Message>());
    }

    return await _messagesRepository
        .addMessage(content: command, sender: Sender.client)
        .andThenAsync((_) async {
          await _messagesRepository.refresh();
          return await connection.sendCommand(command);
        })
        .andThenAsync((packet) async {
          final message = await _messagesRepository.addMessage(
            content: packet.body,
            sender: Sender.server,
          );
          await _messagesRepository.refresh();
          return message.map(Some.new);
        });
  }
}
