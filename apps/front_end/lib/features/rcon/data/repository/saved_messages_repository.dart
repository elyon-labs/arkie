import 'dart:async';

import 'package:cs2_rcon_front_end/features/rcon/data/api/saved_messages_api.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/models/message.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/models/saved_message.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:oxidized/oxidized.dart';
import 'package:rxdart/rxdart.dart';

class SavedMessagesRepository {
  SavedMessagesRepository({required Server server, required SavedMessagesApi api})
    : _server = server,
      _api = api {
    unawaited(_fetch());
  }

  final Server _server;
  final SavedMessagesApi _api;

  final _subject = BehaviorSubject<List<SavedMessage>>();

  Future<void> _fetch() async {
    final messages = await _api.fetchMessages(_server.id);
    _subject.add(messages);
  }

  Stream<List<SavedMessage>> watch() => _subject.stream;

  Future<void> refresh() async {
    await _fetch();
  }

  Future<Result<SavedMessage, Exception>> saveMessage({required Message message}) async {
    return Result.asyncOf(() async {
      final savedMessage = SavedMessage.create(message);
      await _api.saveMessage(savedMessage);
      return savedMessage;
    });
  }

  Future<Result<SavedMessage, Exception>> renameSavedMessage({
    required String id,
    required String newName,
  }) async {
    return Result.asyncOf(() async {
      return _api.renameSavedMessage(_server.id, id, newName);
    });
  }

  Future<Result<void, Exception>> clearMessages() async {
    return Result.asyncOf(() async {
      await _api.clearMessages(_server.id);
    });
  }

  Future<Result<void, Exception>> unsaveMessage({required SavedMessage message}) async {
    return Result.asyncOf(() async {
      await _api.unsaveMessage(message.id);
    });
  }
}
