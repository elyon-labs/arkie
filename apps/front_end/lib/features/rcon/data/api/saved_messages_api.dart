import 'package:cs2_rcon_front_end/di/graph.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/models/saved_message.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class SavedMessagesApi {
  SavedMessagesApi({required Box<SavedMessage> box}) : _box = box;

  factory SavedMessagesApi.create() {
    return SavedMessagesApi(box: inject());
  }

  final Box<SavedMessage> _box;

  Future<List<SavedMessage>> fetchMessages(String serverId) async {
    return _box.values.where((message) => message.serverId == serverId).toList();
  }

  Future<void> saveMessage(SavedMessage message) async {
    await _box.put(message.id, message);
  }

  Future<SavedMessage> renameSavedMessage(String serverId, String id, String newName) async {
    final message = _box.get(id);
    if (message == null || message.serverId != serverId) {
      throw Exception('SavedMessage with $id not found for server $serverId');
    }
    final updatedMessage = message.copyWith(name: newName);
    await _box.put(id, updatedMessage);
    return updatedMessage;
  }

  Future<void> unsaveMessage(String messageId) async {
    await _box.delete(messageId);
  }

  Future<void> clearMessages(String serverId) async {
    final keysToDelete = _box.values
        .where((message) => message.serverId == serverId)
        .map((message) => message.id)
        .toList();
    await _box.deleteAll(keysToDelete);
  }
}
