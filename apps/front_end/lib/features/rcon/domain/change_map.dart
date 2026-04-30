import 'package:cs2_rcon_client/cs2_rcon_client.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/models/cs2_map.dart';
import 'package:oxidized/oxidized.dart';

class ChangeMap {
  ChangeMap({required RCONConnection connection}) : _connection = connection;

  factory ChangeMap.create({required RCONConnection connection}) {
    return ChangeMap(connection: connection);
  }

  final RCONConnection _connection;

  Future<Result<RCONServerPacket, Exception>> call(CS2Map map) {
    return _connection.sendCommand('map ${map.name}');
  }
}
