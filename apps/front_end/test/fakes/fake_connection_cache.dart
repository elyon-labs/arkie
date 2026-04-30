import 'package:cs2_rcon_client/src/rcon_connection.dart';
import 'package:cs2_rcon_client/src/rcon_socket.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/connection_cache.dart';
import 'package:flutter/widgets.dart';

class FakeConnectionCache implements ConnectionCache {
  FakeConnectionCache({
    this.onAddConnection,
    this.onGetConnection,
    this.onRemoveConnection,
    this.onClearAllConnections,
  });

  final ValueSetter<(RCONSocket, RCONConnection)>? onAddConnection;
  final ValueGetter<Future<(RCONSocket, RCONConnection)?>>? onGetConnection;
  final ValueSetter<RCONSocket>? onRemoveConnection;
  final VoidCallback? onClearAllConnections;

  @override
  Future<void> addConnection(RCONSocket socket, RCONConnection connection) async {
    onAddConnection?.call((socket, connection));
  }

  @override
  Future<void> clearAllConnections() async {
    onClearAllConnections?.call();
  }

  @override
  Future<(RCONSocket, RCONConnection)?> getConnection(SocketKey key) async {
    return onGetConnection?.call();
  }

  @override
  Future<void> removeConnection(RCONSocket socket) async {
    onRemoveConnection?.call(socket);
  }
}
