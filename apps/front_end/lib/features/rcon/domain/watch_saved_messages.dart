import 'package:cs2_rcon_front_end/features/rcon/data/models/saved_message.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/repository/saved_messages_repository.dart';

class WatchSavedMessages {
  WatchSavedMessages({required this.repository});

  final SavedMessagesRepository repository;

  Stream<List<SavedMessage>> call() {
    return repository.watch();
  }
}
