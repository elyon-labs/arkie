import 'package:cs2_rcon_front_end/features/rcon/data/models/message.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:uuid/uuid.dart';

part 'saved_message.mapper.dart';

/// A model representing a saved message/command that can be reused.
@MappableClass()
class SavedMessage with SavedMessageMappable {
  SavedMessage({required this.id, required this.serverId, required this.body, required this.name});

  factory SavedMessage.create(Message message) {
    final id = const Uuid().v4();
    return SavedMessage(
      id: id,
      serverId: message.serverId,
      body: message.body,
      name: message.bodyWithoutTerminalCharacter,
    );
  }

  /// The unique identifier of the saved message.
  final String id;

  /// The ID of the server this saved message is associated with.
  final String serverId;

  /// The body of the saved message. This is what is sent to the server.
  final String body;

  /// The name of the saved message. This is used for display purposes.
  final String name;
}
