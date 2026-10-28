import 'package:arkie_core/features/rcon/data/models/saved_message.dart';
import 'package:arkie_core/features/rcon/data/repository/saved_messages_repository.dart';
import 'package:oxidized/oxidized.dart';

class UnsaveMessage {
  UnsaveMessage({required SavedMessagesRepository savedMessagesRepository})
    : _savedMessagesRepository = savedMessagesRepository;

  final SavedMessagesRepository _savedMessagesRepository;

  Future<Result<void, Exception>> call(SavedMessage message) async {
    return await _savedMessagesRepository.unsaveMessage(message: message).andThenAsync((
      clientMessage,
    ) async {
      await _savedMessagesRepository.refresh();
      return const Ok(null);
    });
  }
}
