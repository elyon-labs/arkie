import 'package:cs2_rcon_front_end/features/rcon/data/models/message.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/repository/messages_repository.dart';

class WatchServerMessages {
  WatchServerMessages({required MessagesRepository messagesRepository})
    : _messagesRepository = messagesRepository;

  final MessagesRepository _messagesRepository;

  Stream<List<Message>> call() {
    return _messagesRepository.watch().map((messages) {
      final sortedMessages = List<Message>.from(messages)
        ..sort((a, b) => a.sortKey.compareTo(b.sortKey));
      return sortedMessages;
    });
  }
}
