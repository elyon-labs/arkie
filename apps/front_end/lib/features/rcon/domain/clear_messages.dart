import 'package:cs2_rcon_front_end/features/rcon/data/repository/messages_repository.dart';
import 'package:oxidized/oxidized.dart';

class ClearMessages {
  ClearMessages({required MessagesRepository messagesRepository})
    : _messagesRepository = messagesRepository;

  final MessagesRepository _messagesRepository;

  Future<Result<void, Exception>> call() {
    return _messagesRepository.clearMessages().andThenAsync((_) async {
      await _messagesRepository.refresh();
      return const Ok(null);
    });
  }
}
