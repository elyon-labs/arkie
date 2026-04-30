import 'package:cs2_rcon_front_end/di/graph.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/models/message.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class MessagesApi {
  MessagesApi({required Box<Message> box}) : _box = box;

  factory MessagesApi.create() {
    return MessagesApi(box: inject());
  }

  final Box<Message> _box;

  Future<List<Message>> fetchMessages(String serverId) async {
    return _box.values.where((message) => message.serverId == serverId).toList();
  }

  Future<void> addMessage(Message message) async {
    await _box.put(message.id, message);
  }

  Future<void> deleteMessage(String messageId) async {
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
