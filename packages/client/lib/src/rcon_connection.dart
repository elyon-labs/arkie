import 'package:cs2_rcon_client/cs2_rcon_client.dart';
import 'package:oxidized/oxidized.dart';

/// A function that sends a command to the game server and returns the response.
typedef SendCommand = Future<Result<RCONServerPacket, Exception>> Function(String command);

/// A function that closes the connection to the game server.
typedef CloseConnection = Future<void> Function();

/// {@template rcon_connection}
/// Represents a connection to the game server that can be used to send commands.
///
/// This is broken out of [RCONSocket] to expose only the methods available to
/// an end user once authenticated with the server. This can only be obtained
/// by calling [RCONSocket.connect].
/// {@endtemplate}
class RCONConnection {
  /// {@macro rcon_connection}
  RCONConnection({required SendCommand sendCommand, required CloseConnection closeConnection})
    : _sendCommand = sendCommand,
      _closeConnection = closeConnection;

  final SendCommand _sendCommand;
  final CloseConnection _closeConnection;

  /// Sends a command to the game server and returns the response.
  Future<Result<RCONServerPacket, Exception>> sendCommand(String command) async {
    return _sendCommand(command);
  }

  /// Closes the connection to the game server.
  Future<void> close() async {
    return _closeConnection();
  }
}
