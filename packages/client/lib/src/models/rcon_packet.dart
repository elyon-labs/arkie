import 'dart:convert';
import 'dart:typed_data';

/// {@template rcon_packet}
/// Represents the shared structure for all packets exchanged over the RCON protocol.
///
/// This base class is extended by [RCONClientPacket] and [RCONServerPacket] to model
/// packets originating from the client or server respectively while preserving type safety
/// around their packet kinds.
/// {@endtemplate}
sealed class RCONPacket<T extends RCONPacketType> {
  /// {@macro rcon_packet}
  const RCONPacket({required this.id, required this.type, required this.body});

  /// 32-bit little-endian signed integer indicating the ID of the packet.
  final int id;

  /// Represents the packet type and enforces whether it originated from the
  /// client or server.
  final T type;

  /// The body of the packet, which can be a command or a response.
  final String body;

  /// The maximum size of a packet payload in bytes (per the size field).
  /// CS2 can return very large responses (e.g. cvarlist), so this must be
  /// much larger than the old 4096-byte Source docs suggest.
  static const int maxPacketSize = 2 * 1024 * 1024; // 2 MiB

  /// 32-bit little-endian signed integer indicating the size of the packet.
  /// Note that the size of this field itself is not included in this size.
  ///
  /// Per the RCON spec, the payload must include two null terminators:
  /// one after the body string and another for an empty string.
  int get size => 4 + 4 + utf8.encode(body).length + 2;

  /// Convert packet data into bytes for transmission.
  Uint8List toBytes() {
    final buffer = BytesBuilder()
      ..add(_int32ToBytes(size))
      ..add(_int32ToBytes(id))
      ..add(_int32ToBytes(type.value))
      ..add(utf8.encode(body))
      ..add([0x00, 0x00]); // Two null terminators

    return buffer.toBytes();
  }

  Uint8List _int32ToBytes(int value) {
    final byteData = ByteData(4)..setInt32(0, value, Endian.little);
    return byteData.buffer.asUint8List();
  }

  @override
  String toString() => 'Packet(size: $size, id: $id, type: $type, body: $body)';
}

/// Contract for the integer value of a packet type.
abstract interface class RCONPacketType {
  /// The integer value representing the packet type.
  int get value;
}

/// Represents packet types that can be sent from the client to the server.
enum ClientPacketType implements RCONPacketType {
  /// The first packet sent by the client to authenticate with the server.
  // ignore: constant_identifier_names
  SERVERDATA_AUTH(3),

  /// Represents a command packet sent to the server.
  // ignore: constant_identifier_names
  SERVERDATA_EXECCOMMAND(2),

  /// Sentinel packet type used to signal the end of multi-packet responses.
  /// Sent by the client, but is actually the same type as `SERVERDATA_RESPONSE_VALUE`.
  // ignore: constant_identifier_names
  SENTINEL(0);

  const ClientPacketType(this.value);

  @override
  final int value;
}

/// Represents packet types that are emitted by the server.
enum ServerPacketType implements RCONPacketType {
  /// Represents a notification of the connection's current auth status.
  // ignore: constant_identifier_names
  SERVERDATA_AUTH_RESPONSE(2),

  /// Represents the response to a SERVERDATA_EXECCOMMAND packet.
  // ignore: constant_identifier_names
  SERVERDATA_RESPONSE_VALUE(0);

  const ServerPacketType(this.value);

  @override
  final int value;
}

/// {@template client_packet}
/// Base class for packets created by the client and sent to the server.
/// {@endtemplate}
abstract class RCONClientPacket extends RCONPacket<ClientPacketType> {
  /// {@macro client_packet}
  const RCONClientPacket({required super.id, required super.type, required super.body});
}

/// {@template server_packet}
/// A packet sent from the server to the client in response to client requests.
/// {@endtemplate}
class RCONServerPacket extends RCONPacket<ServerPacketType> {
  /// {@macro server_packet}
  const RCONServerPacket._({required super.id, required super.type, required super.body});

  /// {@macro server_packet}.
  ///
  /// Specifically for command responses.
  factory RCONServerPacket.responseValue({required int id, required String body}) {
    return RCONServerPacket._(id: id, type: ServerPacketType.SERVERDATA_RESPONSE_VALUE, body: body);
  }

  /// {@macro server_packet}
  ///
  /// Prefer using specialized constructors like [RCONServerPacket.responseValue] when possible.
  factory RCONServerPacket.raw({
    required int id,
    required String body,
    required ServerPacketType type,
  }) {
    return RCONServerPacket._(id: id, type: type, body: body);
  }

  /// Convert bytes into a packet originating from the server for processing.
  factory RCONServerPacket.fromBytes(Uint8List bytes) {
    final byteData = ByteData.sublistView(bytes);

    final size = byteData.getInt32(0, Endian.little);
    final id = byteData.getInt32(4, Endian.little);
    final rawType = byteData.getInt32(8, Endian.little);

    // payload = id + type + body + terminators (size bytes long)
    final payload = bytes.sublist(4, 4 + size);

    // RCON payloads must end with two null terminators.
    final hasDoubleNullTerminator =
        payload.length >= 2 &&
        payload[payload.length - 1] == 0x00 &&
        payload[payload.length - 2] == 0x00;

    // body sits inside payload: [id(4)][type(4)][body(...)] [terminators]
    const bodyStartInPayload = 8;
    if (!hasDoubleNullTerminator) {
      throw const FormatException(
        'Invalid RCON server packet terminator: expected two trailing null bytes',
      );
    }
    final bodyEndInPayload = payload.length - 2;
    final bodyBytes = payload.sublist(bodyStartInPayload, bodyEndInPayload);
    final body = utf8.decode(bodyBytes);

    final type = ServerPacketType.values.firstWhere(
      (t) => t.value == rawType,
      orElse: () => throw FormatException('Unknown ServerPacketType: $rawType with body: $body'),
    );

    return RCONServerPacket._(id: id, type: type, body: body);
  }
}

/// {@template authorization_packet}
/// Represents an authorization packet sent to the server.
///
/// This must be the first packet sent to the server. If the password is correct,
/// the server will respond with an [RCONServerPacket] with the same ID. Otherwise,
/// the ID will be [AuthorizationPacket.invalidAuthId].
/// {@endtemplate}
class AuthorizationPacket extends RCONClientPacket {
  /// {@macro authorization_packet}
  factory AuthorizationPacket(String password) {
    return AuthorizationPacket._(id: 0, type: ClientPacketType.SERVERDATA_AUTH, body: password);
  }

  const AuthorizationPacket._({required super.id, required super.type, required super.body});

  /// The ID returned by the server when authentication fails.
  static const invalidAuthId = -1;
}

/// {@template command_packet}
/// Represents a command packet sent to the server.
///
/// The server will respond with one or more [RCONServerPacket]s with the same ID.
/// {@endtemplate}
class ExecCommandPacket extends RCONClientPacket {
  const ExecCommandPacket._({required super.id, required super.type, required super.body});

  /// {@macro command_packet}
  factory ExecCommandPacket.withCommand(String command, {required int id}) {
    return ExecCommandPacket._(
      id: id,
      type: ClientPacketType.SERVERDATA_EXECCOMMAND,
      body: command,
    );
  }
}

/// {@template sentinel_packet}
/// A packet sent by the client to signal the end of a multi-packet command response.
/// This packet contains a unique marker in its body that the server will echo back
/// in its responses, allowing the client to detect when the full response has been received.
///
/// Note: One would expect this to be a [RCONClientPacket], but due to the way the RCON protocol
/// works, the server echoes back the sentinel as a [RCONServerPacket] of type
/// [ServerPacketType.SERVERDATA_RESPONSE_VALUE].
/// {@endtemplate}
class SentinelPacket extends RCONClientPacket {
  /// {@macro empty_response_value_packet}
  const SentinelPacket({required super.id, required this.commandId})
    : super(
        type: ClientPacketType.SENTINEL,
        body: 'echo ${SentinelPacket.sentinelPrefix}$commandId',
      );

  /// The command ID that this sentinel is associated with.
  final int commandId;

  /// Unique prefix used in the sentinel packet body to identify it.
  static const sentinelPrefix = '__CS2__END__';

  /// Checks if the given packet is a matching response for this sentinel.
  bool isOriginOf(RCONServerPacket packet) {
    return packet.type == ServerPacketType.SERVERDATA_RESPONSE_VALUE &&
        packet.body.contains('${SentinelPacket.sentinelPrefix}$commandId');
  }
}

// ignore: public_member_api_docs
extension RCONServerPacketsX on Iterable<RCONServerPacket> {
  /// Combines multiple packets into a single packet by combining their bodies.
  ///
  /// Preserves the ID and type of the first packet.
  /// If called on an empty list, throws an [ArgumentError].
  RCONServerPacket combine() {
    final packets = toList();
    if (packets.isEmpty) {
      throw ArgumentError('Cannot combine an empty list of packets');
    }
    final combinedBody = packets.map((p) => p.body).join();
    return RCONServerPacket.raw(id: packets.first.id, type: packets.first.type, body: combinedBody);
  }
}
