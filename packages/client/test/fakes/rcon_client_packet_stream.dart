import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cs2_rcon_client/src/models/rcon_packet.dart';

import 'fake_rcon_server.dart';

/// {@template rcon_client_packet_stream}
/// Converts a raw TCP byte stream into framed RCON client packets.
///
/// Because this is not used in production code, it exists in test only to allow us to
/// act as a fake RCON server for testing purposes.
///
/// See also: [FakeRCONServer] which uses this to parse incoming packets from clients.
/// {@endtemplate}
class RCONClientPacketStream {
  /// {@macro rcon_client_packet_stream}
  RCONClientPacketStream(Stream<List<int>> source)
    : _source = source,
      _controller = StreamController<FakeRCONClientPacket>.broadcast() {
    _listen();
  }

  final Stream<List<int>> _source;
  final StreamController<FakeRCONClientPacket> _controller;
  final List<int> _buffer = [];

  static const _lengthFieldSize = 4; // bytes in size field

  /// The stream of parsed RCON server packets.
  Stream<FakeRCONClientPacket> get packets => _controller.stream;

  void _listen() {
    _source.listen(
      _onChunk,
      onError: (Object error, StackTrace stackTrace) {
        _controller.addError(error, stackTrace);
      },
      onDone: () async {
        if (_buffer.isNotEmpty) {
          _controller.addError(
            StateError(
              'Socket closed with incomplete RCON packet in buffer (len=${_buffer.length})',
            ),
          );
        }
        await _controller.close();
      },
      cancelOnError: false,
    );
  }

  void _onChunk(List<int> chunk) {
    _buffer.addAll(chunk);

    _drainBuffer();
  }

  void _drainBuffer() {
    while (true) {
      // Need at least 4 bytes to read size.
      if (_buffer.length < _lengthFieldSize) {
        return;
      }

      final payloadSize = _readInt32LE(_buffer, 0);

      // Basic sanity: size must be positive and not absurdly huge.
      if (payloadSize <= 0 || payloadSize > RCONPacket.maxPacketSize) {
        final firstBytesToShow = _buffer.length.clamp(0, 16);
        _buffer.take(firstBytesToShow).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');

        _controller.addError(
          FormatException(
            'Invalid RCON packet size: $payloadSize (buffer length: ${_buffer.length})',
          ),
        );

        // Best effort: drop this byte and try again next iteration.
        // If maxPacketSize is large enough, this should never happen in normal flow.
        _buffer.removeAt(0);
        continue;
      }

      final totalPacketLength = _lengthFieldSize + payloadSize;

      if (_buffer.length < totalPacketLength) {
        // Not enough data yet to form a full packet.
        return;
      }

      final packetBytes = Uint8List.fromList(_buffer.sublist(0, totalPacketLength));

      try {
        final packet = packetBytes.toRCONClientPacket();
        _controller.add(packet);
      } catch (e, st) {
        _controller.addError(e, st);
      }

      _buffer.removeRange(0, totalPacketLength);

      // Loop again in case there are additional full packets in the buffer.
    }
  }

  int _readInt32LE(List<int> bytes, int offset) {
    if (bytes.length < offset + 4) {
      // This really shouldn't happen because callers check length first,
      // but log it just in case.
      return 0;
    }

    final view = ByteData(4)
      ..setUint8(0, bytes[offset])
      ..setUint8(1, bytes[offset + 1])
      ..setUint8(2, bytes[offset + 2])
      ..setUint8(3, bytes[offset + 3]);

    final value = view.getInt32(0, Endian.little);
    return value;
  }
}

extension on Uint8List {
  /// Parses raw bytes received by a server into a [RCONClientPacket].
  FakeRCONClientPacket toRCONClientPacket() {
    final byteData = ByteData.sublistView(this);
    final id = byteData.getInt32(4, Endian.little);
    final rawType = byteData.getInt32(8, Endian.little);
    final type = ClientPacketType.values.firstWhere(
      (e) => e.value == rawType,
      orElse: () => throw FormatException('Unknown client packet type: $rawType'),
    );
    final payloadSize = byteData.getInt32(0, Endian.little);
    final payload = sublist(4, 4 + payloadSize);

    final hasDoubleNullTerminator =
        payload.length >= 2 &&
        payload[payload.length - 1] == 0x00 &&
        payload[payload.length - 2] == 0x00;
    if (!hasDoubleNullTerminator) {
      throw const FormatException('Client packet missing double null terminator');
    }

    final body = utf8.decode(sublist(12, length - 2));

    return FakeRCONClientPacket(id: id, type: type, body: body);
  }
}
