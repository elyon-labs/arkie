import 'package:arkie_core/features/rcon/data/connection_cache.dart';
import 'package:cs2_rcon_client/cs2_rcon_client.dart';
import 'package:flutter/widgets.dart';

class FakeConnectionCache implements ConnectionCache {
  FakeConnectionCache({this.onAddConnection, this.onGetConnection, this.onRemoveConnection});

  final ValueSetter<(RCONSocket, RCONConnection)>? onAddConnection;
  final ValueGetter<Future<(RCONSocket, RCONConnection)?>>? onGetConnection;
  final ValueSetter<RCONSocket>? onRemoveConnection;

  @override
  Future<void> addConnection(RCONSocket socket, RCONConnection connection) async {
    onAddConnection?.call((socket, connection));
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
