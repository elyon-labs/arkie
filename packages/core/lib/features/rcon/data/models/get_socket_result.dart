import 'package:cs2_rcon_client/cs2_rcon_client.dart';

/// The result of attempting to get an RCONSocket, which may be
/// either a [DisconnectedSocket] or [ConnectedSocket].
sealed class GetSocketResult {}

/// A socket that is not yet connected to a server.
///
/// To obtain an [RCONConnection], you must first call
/// [RCONSocket.connect] on the enclosed [socket].
final class DisconnectedSocket extends GetSocketResult {
  DisconnectedSocket(this.socket);

  final RCONSocket socket;
}

/// A socket that is already connected to a server.
final class ConnectedSocket extends GetSocketResult {
  ConnectedSocket(this.socket, this.connection);

  final RCONSocket socket;
  final RCONConnection connection;
}
