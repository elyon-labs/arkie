import 'package:cs2_rcon_client/cs2_rcon_client.dart';
import 'package:cs2_rcon_front_end/di/graph.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/connection_cache.dart';

/// Removes an RCON connection from the connection cache.
class DropConnection {
  const DropConnection({required ConnectionCache connectionCache})
    : _connectionCache = connectionCache;

  factory DropConnection.create() {
    return DropConnection(connectionCache: inject());
  }

  final ConnectionCache _connectionCache;

  Future<void> call({required RCONSocket socket}) async {
    await _connectionCache.removeConnection(socket);
  }
}
