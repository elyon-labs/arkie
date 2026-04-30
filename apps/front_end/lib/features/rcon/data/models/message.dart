import 'package:uuid/uuid.dart';

/// The sender of a [Message].
enum Sender { client, server }

/// A message sent or received from the RCON server.
class Message {
  Message({
    required this.id,
    required this.body,
    required this.sender,
    required this.serverId,
    this.sortKey = 0,
  });

  factory Message.create({required String body, required Sender sender, required String serverId}) {
    final id = const Uuid().v4();
    final sortKey = DateTime.now().microsecondsSinceEpoch;
    return Message(id: id, body: body, sender: sender, serverId: serverId, sortKey: sortKey);
  }

  /// The unique identifier of the message.
  final String id;

  /// The ID of the server this message is associated with.
  final String serverId;

  /// The body of the message.
  final String body;

  /// The sender of the message.
  final Sender sender;

  /// A key used to sort messages chronologically.
  final int sortKey;

  /// The body of the message without any terminal character.
  String get bodyWithoutTerminalCharacter {
    final indexOfNullTerminator = body.indexOf('\x00');
    if (indexOfNullTerminator >= 1) {
      return body.substring(0, indexOfNullTerminator);
    }
    return body;
  }
}
