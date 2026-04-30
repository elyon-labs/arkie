import 'dart:io';

import 'package:collection/collection.dart';
import 'package:cs2_rcon_client/cs2_rcon_client.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/models/player_info.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/models/server_status.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/models/server_status_json.dart';
import 'package:rxdart/rxdart.dart';

class WatchServerStatus {
  WatchServerStatus({required RCONConnection connection, required Duration pollInterval})
    : _pollInterval = pollInterval,
      _connection = connection;

  factory WatchServerStatus.create({required RCONConnection connection, Duration? pollInterval}) {
    return WatchServerStatus(
      connection: connection,
      pollInterval: pollInterval ?? const Duration(seconds: 5),
    );
  }

  final Duration _pollInterval;
  final RCONConnection _connection;

  Stream<ServerStatus> call() {
    return Stream.periodic(_pollInterval).startWith(null).asyncMap((_) async {
      final rawStatusFuture = _connection.sendCommand('status');
      final statusJsonFuture = _connection.sendCommand('status_json');

      final responses = await (rawStatusFuture, statusJsonFuture).wait;

      final rawStatus = responses.$1.mapOr((p) => p.toServerStatus(), null);
      final statusJson = responses.$2.mapOr((p) => ServerStatusJsonMapper.fromJson(p.body), null);

      // `status_json` provides steamid and steamid64, which `status` does not.
      // Use most of the data from `status`, but supplement player info with steamids from `status_json`.
      final players = rawStatus?.players.map((player) {
        final matchingJsonPlayer = statusJson?.server.clients.firstWhereOrNull(
          // Technically possible for two players to have the same name and bot status,
          // but unlikely enough to ignore for this purpose.
          (p) => p.name == player.name && p.isBot == player.isBot,
        );
        return PlayerInfo(
          name: player.name,
          id: player.id,
          ping: player.ping,
          state: player.state,
          isBot: player.isBot,
          steamId: matchingJsonPlayer?.steamId,
          steamId64: matchingJsonPlayer?.steamId64,
        );
      }).nonNulls;

      return rawStatus?.copyWith(players: players?.toList());
    }).whereNotNull();
  }
}

extension on RCONServerPacket {
  ServerStatus? toServerStatus() {
    final hostnameRegex = RegExp(r'hostname\s*:\s*(.+)');
    final match = hostnameRegex.firstMatch(body);
    if (match == null) return null;
    final hostname = match.group(1)?.trim() ?? '';

    // Parse version (captures up to the slash)
    final versionRegex = RegExp(r'version\s*:\s*([0-9]+(?:\.[0-9]+)*)');
    final versionMatch = versionRegex.firstMatch(body);
    final version = versionMatch?.group(1)?.trim() ?? '0.0.0.0';

    // Parse public IP address
    final addressRegex = RegExp(r'public\s+([\d.]+):(\d+)');
    final addressMatch = addressRegex.firstMatch(body);
    final ipString = addressMatch?.group(1) ?? '0.0.0.0';
    final address = InternetAddress(ipString);
    final port = int.tryParse(addressMatch?.group(2) ?? '') ?? 0;

    // Parse OS
    final osRegex = RegExp(r'os/type\s*:\s*(.+)');
    final osMatch = osRegex.firstMatch(body);
    final os = osMatch?.group(1)?.trim() ?? '';

    // Parse players, humans, bots, and max players
    final playersRegex = RegExp(r'players\s*:\s*(\d+)\s+humans,\s*(\d+)\s+bots\s*\((\d+)\s+max\)');
    final playersMatch = playersRegex.firstMatch(body);
    final numHumans = int.tryParse(playersMatch?.group(1) ?? '0') ?? 0;
    final numBots = int.tryParse(playersMatch?.group(2) ?? '0') ?? 0;
    final numMaxPlayers = int.tryParse(playersMatch?.group(3) ?? '0') ?? 0;
    final numPlayers = numHumans + numBots;

    // Parse player info
    final playersSectionRegex = RegExp('---------players--------(.+?)#end', dotAll: true);
    final playersSectionMatch = playersSectionRegex.firstMatch(body);
    final playersSection = playersSectionMatch?.group(1) ?? '';
    final playerLines = playersSection
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty && !line.startsWith('id'));
    final playerRegex = RegExp(r"^\s*(\d+)\s+([^\s]+)\s+(\d+)\s+\d+\s+([^\s]+)\s+[^']*'([^']*)'");
    final players = playerLines
        .map((line) {
          final match = playerRegex.firstMatch(line);
          if (match == null) return null;

          final id = int.tryParse(match.group(1) ?? '') ?? 0;
          final timeOrBot = match.group(2) ?? '';
          final ping = int.tryParse(match.group(3) ?? '') ?? 0;
          final state = match.group(4) ?? '';
          final name = match.group(5) ?? '';

          if (name.isEmpty) return null;

          final isBot = timeOrBot.toUpperCase() == 'BOT';

          return PlayerInfo(
            name: name,
            id: id,
            ping: ping,
            state: state,
            isBot: isBot,
            steamId: null,
            steamId64: null,
          );
        })
        .whereType<PlayerInfo>()
        .toList();

    // Parse map name from spawngroup
    final mapRegex = RegExp(r'loaded spawngroup\(\s*1\)\s*:\s*SV:\s*\[\d+:\s*(\S+)');
    final mapMatch = mapRegex.firstMatch(body);
    final map = mapMatch?.group(1) ?? '';

    return ServerStatus(
      hostname: hostname,
      version: version,
      address: address,
      port: port,
      os: os,
      players: players,
      numPlayers: numPlayers,
      numMaxPlayers: numMaxPlayers,
      numHumans: numHumans,
      numBots: numBots,
      map: map,
    );
  }
}
