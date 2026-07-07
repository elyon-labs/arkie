import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cs2_rcon_client/cs2_rcon_client.dart';

import 'rcon_client_packet_stream.dart';

typedef HandleClientPacket = Future<String> Function(RCONClientPacket packet);

/// A function for handling client connections.
///
/// If it returns true, the connection is accepted; if false, it is rejected.
typedef HandleConnect = Future<bool> Function();

class FakeRCONServer {
  FakeRCONServer({
    this.password = 'test1234',
    this.address = '127.0.0.1',
    this.port = 27015,
    this.onClientPacket,
    this.onConnect,
  });

  ServerSocket? _server;
  final List<Socket> _clients = [];
  final String password;
  final String address;
  final int port;

  int get clientCount => _clients.length;

  // Callback to handle custom command responses
  HandleClientPacket? onClientPacket;

  // Callback for when a client connects
  HandleConnect? onConnect;

  Future<void> start() async {
    _server = await ServerSocket.bind(address, port);
    _server!.listen(_handleClient);
  }

  Future<void> stop() async {
    for (final client in _clients) {
      await client.close();
    }
    _clients.clear();
    await _server?.close();
    _server = null;
  }

  Future<void> _handleClient(Socket client) async {
    final accepted = await onConnect?.call() ?? true;
    if (!accepted) {
      return;
    }
    _clients.add(client);
    final events = client.asBroadcastStream();
    RCONClientPacketStream(events).packets.listen(
      (data) => _handleData(client, data),
      onDone: () async {
        _clients.remove(client);
        await client.close();
      },
      onError: (_) async {
        _clients.remove(client);
        await client.close();
      },
    );
  }

  Future<void> _handleData(Socket client, FakeRCONClientPacket packet) async {
    switch (packet.type) {
      case ClientPacketType.SERVERDATA_AUTH:
        final authenticated = packet.body == password;
        final responseId = authenticated ? packet.id : AuthorizationPacket.invalidAuthId;
        _sendPacket(client, responseId, ServerPacketType.SERVERDATA_AUTH_RESPONSE, '');

      case ClientPacketType.SERVERDATA_EXECCOMMAND:
        // Normal command: use onCommand or a default response.
        final response = await onClientPacket?.call(packet) ?? 'Command executed';
        _sendPacket(client, packet.id, ServerPacketType.SERVERDATA_RESPONSE_VALUE, response);
      case ClientPacketType.SENTINEL:
        // The packet will contain an `echo` command with the sentinel marker.
        // Strip everything after the `echo ` part.
        String defaultSentinelResponse() {
          final commandParts = packet.body.split(' ');
          return commandParts.lastOrNull ?? '';
        }

        final response = await onClientPacket?.call(packet) ?? defaultSentinelResponse();

        _sendPacket(client, packet.id, ServerPacketType.SERVERDATA_RESPONSE_VALUE, response);
    }
  }

  void _sendPacket(Socket client, int id, ServerPacketType type, String body) {
    final bodyBytes = utf8.encode(body);
    final packetSize = 4 + 4 + bodyBytes.length + 2; // ID + Type + Body + 2 null bytes

    final buffer = BytesBuilder();
    final sizeData = ByteData(4)..setInt32(0, packetSize, Endian.little);
    buffer.add(sizeData.buffer.asUint8List());

    final idData = ByteData(4)..setInt32(0, id, Endian.little);
    buffer.add(idData.buffer.asUint8List());

    final typeData = ByteData(4)..setInt32(0, type.value, Endian.little);
    buffer
      ..add(typeData.buffer.asUint8List())
      ..add(bodyBytes)
      ..add([0, 0]); // Two null terminators

    client.add(buffer.toBytes());
  }
}

/// Represents a client packet received by the [FakeRCONServer].
class FakeRCONClientPacket extends RCONClientPacket {
  const FakeRCONClientPacket({required super.id, required super.body, required super.type});
}
