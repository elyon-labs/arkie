import 'package:arkie_core/features/rcon/data/models/saved_message.dart';
import 'package:arkie_core/features/rcon/data/repository/saved_messages_repository.dart';

class WatchSavedMessages {
  WatchSavedMessages({required this.repository});

  final SavedMessagesRepository repository;

  Stream<List<SavedMessage>> call() {
    return repository.watch();
  }
}
