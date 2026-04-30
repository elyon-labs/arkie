import 'package:cs2_rcon_front_end/features/rcon/data/api/saved_messages_api.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/models/saved_message.dart';
import 'package:flutter/foundation.dart';

class FakeSavedMessagesApi implements SavedMessagesApi {
  FakeSavedMessagesApi({
    List<SavedMessage>? initialMessages,
    this.onSaveMessage,
    this.onFetchMessages,
    this.onUnsaveMessage,
    this.onClearMessages,
    this.onRenameSavedMessage,
  }) : _messages = List<SavedMessage>.from(initialMessages ?? const <SavedMessage>[]);

  final List<SavedMessage> _messages;
  final ValueSetter<SavedMessage>? onSaveMessage;
  final VoidCallback? onFetchMessages;
  final ValueSetter<String>? onUnsaveMessage;
  final VoidCallback? onClearMessages;
  final void Function(String serverId, String id, String newName)? onRenameSavedMessage;

  int fetchMessagesCallCount = 0;
  int saveMessageCallCount = 0;
  int unsaveMessageCallCount = 0;
  int clearMessagesCallCount = 0;
  int renameSavedMessageCallCount = 0;

  @override
  Future<void> clearMessages(String serverId) async {
    clearMessagesCallCount++;
    onClearMessages?.call();
    _messages.removeWhere((message) => message.serverId == serverId);
  }

  @override
  Future<List<SavedMessage>> fetchMessages(String serverId) async {
    fetchMessagesCallCount++;
    onFetchMessages?.call();
    return _messages.where((message) => message.serverId == serverId).toList();
  }

  @override
  Future<void> saveMessage(SavedMessage message) async {
    saveMessageCallCount++;
    onSaveMessage?.call(message);
    _messages.add(message);
  }

  @override
  Future<SavedMessage> renameSavedMessage(String serverId, String id, String newName) async {
    renameSavedMessageCallCount++;
    onRenameSavedMessage?.call(serverId, id, newName);

    final index = _messages.indexWhere(
      (message) => message.id == id && message.serverId == serverId,
    );

    if (index == -1) {
      throw Exception('Message not found');
    }

    final oldMessage = _messages[index];
    final updatedMessage = SavedMessage(
      id: oldMessage.id,
      serverId: oldMessage.serverId,
      name: newName,
      body: oldMessage.body,
    );

    _messages[index] = updatedMessage;
    return updatedMessage;
  }

  @override
  Future<void> unsaveMessage(String messageId) async {
    unsaveMessageCallCount++;
    onUnsaveMessage?.call(messageId);
    _messages.removeWhere((message) => message.id == messageId);
  }
}
