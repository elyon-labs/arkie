import 'package:cs2_rcon_client/cs2_rcon_client.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/models/cs2_map.dart';
import 'package:rxdart/rxdart.dart';

class WatchServerMaps {
  WatchServerMaps({required RCONConnection connection, required Duration pollInterval})
    : _pollInterval = pollInterval,
      _connection = connection;

  factory WatchServerMaps.create({required RCONConnection connection, Duration? pollInterval}) {
    return WatchServerMaps(
      connection: connection,
      pollInterval: pollInterval ?? const Duration(seconds: 5),
    );
  }

  final Duration _pollInterval;
  final RCONConnection _connection;

  Stream<List<CS2Map>> call() {
    return Stream.periodic(_pollInterval).startWith(null).asyncMap((_) async {
      final maps = await _connection.sendCommand('maps *');
      return maps.when(ok: (p) => p.toMaps(), err: (_) => null);
    }).whereNotNull();
  }
}

extension on RCONServerPacket {
  List<CS2Map> toMaps() {
    final maps = <CS2Map>[];

    for (final map in KnownMap.directory) {
      if (body.contains(map.name)) {
        maps.add(map);
      }
    }

    // TODO: Parse workshop maps from the response body.

    return maps;
  }
}
