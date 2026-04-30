import 'package:cs2_rcon_front_end/features/rcon/data/models/message.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/models/saved_message.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/repository/saved_messages_repository.dart';
import 'package:oxidized/oxidized.dart';

class SaveMessage {
  SaveMessage({required SavedMessagesRepository savedMessagesRepository})
    : _savedMessagesRepository = savedMessagesRepository;

  final SavedMessagesRepository _savedMessagesRepository;

  Future<Result<SavedMessage, Exception>> call(Message message) async {
    return await _savedMessagesRepository.saveMessage(message: message).andThenAsync((
      clientMessage,
    ) async {
      await _savedMessagesRepository.refresh();
      return Ok(clientMessage);
    });
  }
}
