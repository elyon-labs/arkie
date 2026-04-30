import 'package:cs2_rcon_client/cs2_rcon_client.dart';
import 'package:cs2_rcon_front_end/di/graph.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/connection_cache.dart';

/// Saves an active RCON connection to the connection cache.
class SaveConnection {
  const SaveConnection({required ConnectionCache connectionCache})
    : _connectionCache = connectionCache;

  factory SaveConnection.create() {
    return SaveConnection(connectionCache: inject());
  }

  final ConnectionCache _connectionCache;

  Future<void> call({required RCONSocket socket, required RCONConnection connection}) async {
    await _connectionCache.addConnection(socket, connection);
  }
}
