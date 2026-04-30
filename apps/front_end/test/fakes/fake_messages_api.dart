import 'package:cs2_rcon_front_end/features/rcon/data/api/messages_api.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/models/message.dart';
import 'package:flutter/foundation.dart';

class FakeMessagesApi implements MessagesApi {
  FakeMessagesApi({
    List<Message>? initialMessages,
    this.onAddMessage,
    this.onFetchMessages,
    this.onDeleteMessage,
    this.onClearMessages,
  }) : _messages = List<Message>.from(initialMessages ?? const <Message>[]);

  final List<Message> _messages;
  final ValueSetter<Message>? onAddMessage;
  final VoidCallback? onFetchMessages;
  final ValueSetter<String>? onDeleteMessage;
  final VoidCallback? onClearMessages;

  int fetchMessagesCallCount = 0;
  int addMessageCallCount = 0;
  int deleteMessageCallCount = 0;
  int clearMessagesCallCount = 0;

  @override
  Future<void> addMessage(Message message) async {
    addMessageCallCount++;
    onAddMessage?.call(message);
    _messages.add(message);
  }

  @override
  Future<void> clearMessages(String serverId) async {
    clearMessagesCallCount++;
    onClearMessages?.call();
    _messages.removeWhere((message) => message.serverId == serverId);
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    deleteMessageCallCount++;
    onDeleteMessage?.call(messageId);
    _messages.removeWhere((message) => message.id == messageId);
  }

  @override
  Future<List<Message>> fetchMessages(String serverId) async {
    fetchMessagesCallCount++;
    onFetchMessages?.call();
    return _messages.where((message) => message.serverId == serverId).toList();
  }
}
