import 'dart:io';

import 'package:cs2_rcon_client/cs2_rcon_client.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/models/get_socket_result.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/drop_connection.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/get_socket.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/save_connection.dart';
import 'package:oxidized/oxidized.dart';

/// Manages connecting to an RCON server, including retrieving cached connections
/// and saving/removing connections as needed.
///
/// If a cached connection exists, it is tested to ensure it is still valid. If not,
/// a new connection is established and cached.
///
/// The [RCONConnection] returned in a [Ok] result is guaranteed to be connected.
class Connect {
  Connect({
    required GetSocket getSocket,
    required DropConnection removeSocket,
    required SaveConnection addSocket,
  }) : _saveConnection = addSocket,
       _getSocket = getSocket,
       _dropConnection = removeSocket;

  factory Connect.create() {
    return Connect(
      getSocket: GetSocket.create(),
      removeSocket: DropConnection.create(),
      addSocket: SaveConnection.create(),
    );
  }

  final GetSocket _getSocket;
  final DropConnection _dropConnection;
  final SaveConnection _saveConnection;

  Future<Result<RCONConnection, Exception>> call({
    required String address,
    required int port,
    required String password,
  }) async {
    Future<Result<RCONConnection, Exception>> test({
      required RCONSocket socket,
      required RCONConnection connection,
    }) async {
      final result = await connection.sendCommand('echo ping').map((_) => connection);
      switch (result) {
        case Ok<RCONConnection, Exception>(:final value):
          await _saveConnection(socket: socket, connection: value);
        case Err<RCONConnection, Exception>():
          await _dropConnection(socket: socket);
      }
      return result;
    }

    Future<Result<RCONConnection, Exception>> connect({
      required RCONSocket socket,
      required String password,
    }) async {
      return socket
          .connect(password: password)
          .andThenAsync((connection) => test(socket: socket, connection: connection));
    }

    final socket = await _getSocket(hostAddress: InternetAddress(address), hostPort: port);

    switch (socket) {
      case ConnectedSocket(:final socket, :final connection):
        return test(socket: socket, connection: connection);
      case DisconnectedSocket(:final socket):
        return connect(socket: socket, password: password);
    }
  }
}
