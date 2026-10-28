import 'package:cs2_rcon_client/cs2_rcon_client.dart';

typedef SocketKey = (String address, int port);

/// A simple in-memory cache for RCONSocket and RCONConnection pairs.
class ConnectionCache {
  final Map<SocketKey, (RCONSocket socket, RCONConnection connection)> _cache = {};

  Future<(RCONSocket socket, RCONConnection connection)?> getConnection(SocketKey key) async {
    return _cache[key];
  }

  Future<void> addConnection(RCONSocket socket, RCONConnection connection) async {
    final key = (socket.hostAddress.address, socket.hostPort);
    _cache[key] = (socket, connection);
  }

  Future<void> removeConnection(RCONSocket socket) async {
    final key = (socket.hostAddress.address, socket.hostPort);
    _cache.remove(key);
  }

  Future<void> clearAllConnections() async {
    _cache.clear();
  }
}
