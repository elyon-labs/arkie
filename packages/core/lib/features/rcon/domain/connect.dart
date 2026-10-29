import 'dart:io';

import 'package:arkie_core/di/graph.dart';
import 'package:arkie_core/features/rcon/data/models/get_socket_result.dart';
import 'package:arkie_core/features/rcon/demo/demo_connections.dart';
import 'package:arkie_core/features/rcon/domain/drop_connection.dart';
import 'package:arkie_core/features/rcon/domain/get_socket.dart';
import 'package:arkie_core/features/rcon/domain/save_connection.dart';
import 'package:cs2_rcon_client/cs2_rcon_client.dart';
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
    DemoConnections? demoConnections,
  }) : _saveConnection = addSocket,
       _getSocket = getSocket,
       _dropConnection = removeSocket,
       _demoConnections = demoConnections ?? DemoConnections();

  factory Connect.create() {
    return Connect(
      getSocket: GetSocket.create(),
      removeSocket: DropConnection.create(),
      addSocket: SaveConnection.create(),
      demoConnections: inject(),
    );
  }

  final GetSocket _getSocket;
  final DropConnection _dropConnection;
  final SaveConnection _saveConnection;
  final DemoConnections _demoConnections;

  /// How long to wait for a hostname to resolve before giving up. A DNS lookup
  /// that never answers would otherwise leave the caller waiting forever.
  static const lookupTimeout = Duration(seconds: 5);

  /// Connects to the server at [address]:[port].
  ///
  /// When [isDemo] is set, the connection is answered by the in-app demo server
  /// instead of the network. It is the only place that draws the distinction —
  /// the [RCONConnection] handed back behaves the same either way.
  Future<Result<RCONConnection, Exception>> call({
    required String address,
    required int port,
    required String password,
    bool isDemo = false,
  }) async {
    if (isDemo) {
      return Ok(_demoConnections(address: address, port: port));
    }

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

    final hostAddress = await _resolve(address);

    switch (hostAddress) {
      case Err<InternetAddress, Exception>(:final error):
        return Err(error);
      case Ok<InternetAddress, Exception>(value: final host):
        final socket = await _getSocket(hostAddress: host, hostPort: port);

        switch (socket) {
          case ConnectedSocket(:final socket, :final connection):
            return test(socket: socket, connection: connection);
          case DisconnectedSocket(:final socket):
            return connect(socket: socket, password: password);
        }
    }
  }

  /// Turns a stored address into one the socket can dial. A server may be saved
  /// under a hostname, which [InternetAddress] itself rejects, so anything that
  /// is not already a numeric address goes through DNS.
  Future<Result<InternetAddress, Exception>> _resolve(String address) async {
    final literal = InternetAddress.tryParse(address);
    if (literal != null) return Ok(literal);

    return Result.asyncOf(() async {
      final resolved = await InternetAddress.lookup(address).timeout(
        lookupTimeout,
        onTimeout: () => throw SocketException('Timed out resolving host: $address'),
      );
      if (resolved.isEmpty) {
        throw SocketException('Could not resolve host: $address');
      }
      return resolved.first;
    });
  }
}
