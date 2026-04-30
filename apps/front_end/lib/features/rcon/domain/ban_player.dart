import 'package:cs2_rcon_client/cs2_rcon_client.dart';
import 'package:oxidized/oxidized.dart';

class BanPlayer {
  BanPlayer({required RCONConnection connection}) : _connection = connection;

  factory BanPlayer.create({required RCONConnection connection}) {
    return BanPlayer(connection: connection);
  }

  // ignore: unused_field
  final RCONConnection _connection;

  Future<Result<void, Exception>> call(String steamId, {required Duration duration}) async {
    // Ban command uses duration in minutes. If `duration` is zero, the ban is permanent.
    final minutes = duration.inMinutes;
    return _connection.sendCommand('banid $minutes $steamId kick');
  }
}
