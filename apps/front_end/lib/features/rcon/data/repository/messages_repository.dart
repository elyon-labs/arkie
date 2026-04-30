import 'dart:async';

import 'package:cs2_rcon_front_end/features/rcon/data/api/messages_api.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/models/message.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:oxidized/oxidized.dart';
import 'package:rxdart/rxdart.dart';

class MessagesRepository {
  MessagesRepository({required Server server, required MessagesApi api})
    : _server = server,
      _api = api {
    unawaited(_fetch());
  }

  final Server _server;
  final MessagesApi _api;

  final _subject = BehaviorSubject<List<Message>>();

  Future<void> _fetch() async {
    final messages = await _api.fetchMessages(_server.id);
    _subject.add(messages);
  }

  Stream<List<Message>> watch() => _subject.stream;

  Future<void> refresh() async {
    await _fetch();
  }

  Future<Result<Message, Exception>> addMessage({
    required String content,
    required Sender sender,
  }) async {
    return Result.asyncOf(() async {
      final message = Message.create(body: content, sender: sender, serverId: _server.id);
      await _api.addMessage(message);
      return message;
    });
  }

  Future<Result<void, Exception>> clearMessages() async {
    return Result.asyncOf(() async {
      await _api.clearMessages(_server.id);
    });
  }
}
