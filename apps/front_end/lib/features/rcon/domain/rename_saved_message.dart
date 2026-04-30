import 'package:cs2_rcon_front_end/features/rcon/data/models/saved_message.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/repository/saved_messages_repository.dart';
import 'package:oxidized/oxidized.dart';

class RenameSavedMessage {
  RenameSavedMessage({required this.savedMessagesRepository});

  final SavedMessagesRepository savedMessagesRepository;

  Future<Result<SavedMessage, Exception>> call({
    required String id,
    required String newName,
  }) async {
    return savedMessagesRepository.renameSavedMessage(id: id, newName: newName).andThenAsync((
      savedMessage,
    ) async {
      await savedMessagesRepository.refresh();

      return Ok(savedMessage);
    });
  }
}
