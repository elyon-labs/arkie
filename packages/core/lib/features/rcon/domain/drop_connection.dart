import 'package:arkie_core/di/graph.dart';
import 'package:arkie_core/features/rcon/data/connection_cache.dart';
import 'package:cs2_rcon_client/cs2_rcon_client.dart';

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
