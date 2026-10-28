import 'dart:io';

import 'package:arkie_core/di/graph.dart';
import 'package:arkie_core/environment.dart';
import 'package:arkie_core/features/rcon/data/connection_cache.dart';
import 'package:arkie_core/features/rcon/data/models/get_socket_result.dart';
import 'package:cs2_rcon_client/cs2_rcon_client.dart';

/// Provides an RCONSocket, either by retrieving an existing connection from
/// the [ConnectionCache] or by creating a new disconnected socket.
class GetSocket {
  const GetSocket({required ConnectionCache connectionCache, required Environment environment})
    : _connectionCache = connectionCache,
      _environment = environment;

  factory GetSocket.create() {
    return GetSocket(connectionCache: inject(), environment: inject());
  }

  final Environment _environment;
  final ConnectionCache _connectionCache;

  Future<GetSocketResult> call({
    required InternetAddress hostAddress,
    required int hostPort,
    LogLevel? logLevel,
    Duration? connectTimeout,
  }) async {
    final key = (hostAddress.address, hostPort);
    final connection = await _connectionCache.getConnection(key);
    if (connection != null) {
      return ConnectedSocket(connection.$1, connection.$2);
    }

    return DisconnectedSocket(
      RCONSocket(
        hostAddress: hostAddress,
        hostPort: hostPort,
        logLevel: logLevel ?? _environment.logLevel,
        connectTimeout: connectTimeout ?? const Duration(seconds: 5),
      ),
    );
  }
}
