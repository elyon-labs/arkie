import 'package:cs2_rcon_client/cs2_rcon_client.dart';
import 'package:oxidized/oxidized.dart';

class KickPlayer {
  KickPlayer({required RCONConnection connection}) : _connection = connection;

  factory KickPlayer.create({required RCONConnection connection}) {
    return KickPlayer(connection: connection);
  }

  final RCONConnection _connection;

  Future<Result<void, Exception>> call(String playerName) {
    return _connection.sendCommand('kick $playerName');
  }
}
