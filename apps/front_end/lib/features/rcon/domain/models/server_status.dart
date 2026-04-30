import 'dart:io';

import 'package:cs2_rcon_front_end/features/rcon/domain/models/player_info.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'server_status.mapper.dart';

@MappableClass()
class ServerStatus with ServerStatusMappable {
  ServerStatus({
    required this.hostname,
    required this.version,
    required this.address,
    required this.port,
    required this.os,
    required this.players,
    required this.numPlayers,
    required this.numMaxPlayers,
    required this.numHumans,
    required this.numBots,
    required this.map,
  });

  final String hostname;
  final String version;
  final InternetAddress address;
  final int port;
  final String os;
  final List<PlayerInfo> players;
  final int numPlayers;
  final int numMaxPlayers;
  final int numHumans;
  final int numBots;
  final String map;

  String get addressWithPort => '${address.address}:$port';
}
