import 'package:arkie_core/features/rcon/data/connection_cache.dart';
import 'package:arkie_core/features/rcon/demo/demo_rcon_server.dart';
import 'package:cs2_rcon_client/cs2_rcon_client.dart';
import 'package:oxidized/oxidized.dart';

/// Hands out connections to [DemoRCONServer]s, holding each one for as long as
/// the app runs.
///
/// A demo connection is an ordinary [RCONConnection] whose commands are
/// answered in memory rather than over a socket, so everything that sends
/// commands is unaware of the difference. Connections are kept because the demo
/// server is stateful: reconnecting must not undo a kick or a map change, the
/// same way reconnecting to a real server would not.
class DemoConnections {
  final Map<SocketKey, RCONConnection> _connections = {};

  var _nextPacketId = 1;

  /// The connection to the demo server at [address]:[port], created on first ask.
  RCONConnection call({required String address, required int port}) {
    return _connections.putIfAbsent((address, port), () {
      final server = DemoRCONServer(address: address, port: port);
      return RCONConnection(
        sendCommand: (command) async =>
            Ok(RCONServerPacket.responseValue(id: _nextPacketId++, body: server.execute(command))),
        // There is no socket to let go of, and the server's state is meant to
        // outlive any one connection check.
        closeConnection: () async {},
      );
    });
  }

  /// Forgets every demo server, discarding the state they had accumulated.
  void clear() {
    _connections.clear();
  }
}
