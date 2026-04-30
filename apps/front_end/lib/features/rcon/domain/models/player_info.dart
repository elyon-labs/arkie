import 'package:dart_mappable/dart_mappable.dart';

part 'player_info.mapper.dart';

@MappableClass()
class PlayerInfo with PlayerInfoMappable {
  PlayerInfo({
    required this.isBot,
    required this.name,
    required this.id,
    required this.ping,
    required this.state,
    required this.steamId,
    required this.steamId64,
  });

  final bool isBot;
  final String name;
  final int id;
  final int ping;
  final String state;
  // Steam IDs nullable because they are not always available.
  final String? steamId;
  final String? steamId64;
}

extension PlayerInfoX on PlayerInfo {
  String get displayName => isBot ? 'BOT $name' : name;

  String get description => 'ID: $id, Ping: $ping, SteamID: ${steamId ?? "???"}';
}
