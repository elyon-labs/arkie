import 'package:cs2_rcon_client/cs2_rcon_client.dart';
import 'package:cs2_rcon_front_end/core/async.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/models/message.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/models/saved_message.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'rcon_state.mapper.dart';

@MappableClass()
class RCONState with RCONStateMappable {
  RCONState({
    required this.server,
    required this.messages,
    required this.savedMessages,
    required this.connection,
    this.lastConnectionCheckTime,
  });

  factory RCONState.initial(Server server) {
    return RCONState(server: server, messages: [], savedMessages: [], connection: const Loading());
  }

  final Server server;
  final List<Message> messages;
  final List<SavedMessage> savedMessages;
  final Async<RCONConnection> connection;
  final DateTime? lastConnectionCheckTime;
}
