import 'dart:typed_data';

import 'package:cs2_rcon_client/cs2_rcon_client.dart';
import 'package:cs2_rcon_client/src/rcon_server_packet_stream.dart';
import 'package:test/test.dart';

void main() {
  group('RCONServerPacketStream', () {
    group('packets', () {
      group('when TCP chunk contains multiple packets', () {
        test('emits all packets separately', () async {
          final packet1 = RCONServerPacket.responseValue(id: 1, body: 'First packet');
          final packet2 = RCONServerPacket.responseValue(id: 2, body: 'Second packet');

          // Convert packets to bytes and concatenate.
          final bytes = <int>[...packet1.toBytes(), ...packet2.toBytes()];

          final stream = Stream<List<int>>.fromIterable([bytes]);
          final packetStream = RCONServerPacketStream(stream);

          final receivedPackets = await packetStream.packets.toList();

          expect(receivedPackets.length, equals(2));
          expect(receivedPackets[0].id, equals(packet1.id));
          expect(receivedPackets[0].body, equals(packet1.body));
          expect(receivedPackets[1].id, equals(packet2.id));
          expect(receivedPackets[1].body, equals(packet2.body));
        });
      });

      group('when TCP chunk contains partial packets', () {
        test('it waits for a full packet and emits it', () async {
          final packet = RCONServerPacket.responseValue(id: 1, body: 'Partial packet test');

          final bytes = packet.toBytes();

          // Split bytes into two chunks.
          final splitIndex = bytes.length ~/ 2;
          final chunk1 = bytes.sublist(0, splitIndex);
          final chunk2 = bytes.sublist(splitIndex);

          final stream = Stream<List<int>>.fromIterable([chunk1, chunk2]);
          final packetStream = RCONServerPacketStream(stream);

          final receivedPackets = await packetStream.packets.toList();

          expect(receivedPackets.length, equals(1));
          expect(receivedPackets[0].id, equals(packet.id));
          expect(receivedPackets[0].body, equals(packet.body));
        });
      });

      group('when payload size is too large', () {
        // Create payload with size larger than RCONPacket.maxPacketSize
        List<int> createOversizedPayload() {
          const oversizedSize = RCONPacket.maxPacketSize + 1;
          final byteData = ByteData(4)..setInt32(0, oversizedSize, Endian.little);
          return byteData.buffer.asUint8List();
        }

        test('emits an error', () async {
          final oversizedPayload = createOversizedPayload();

          final stream = Stream<List<int>>.fromIterable([oversizedPayload]);
          final packetStream = RCONServerPacketStream(stream);

          final errors = <Object>[];
          packetStream.packets.listen(
            (_) {},
            onError: (Object error) {
              errors.add(error);
            },
          );

          // Allow time for the stream to process.
          await Future<void>.delayed(const Duration(milliseconds: 100));

          // Expect an error about payload size exceeding maximum.
          // The other error is related to the incomplete packet on done.
          expect(errors.length, equals(2));
          expect(
            errors.first,
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              equals('Invalid RCON packet size: 2097153 (buffer length: 4)'),
            ),
          );
        });
      });

      group('when source stream emits an error', () {
        test('it emits the error to listeners', () async {
          final stream = Stream<List<int>>.error(Exception('Test stream error'));
          final packetStream = RCONServerPacketStream(stream);

          final errors = <Object>[];
          packetStream.packets.listen(
            (_) {},
            onError: (Object error) {
              errors.add(error);
            },
          );

          // Allow time for the stream to process.
          await Future<void>.delayed(const Duration(milliseconds: 100));

          expect(errors.length, equals(1));
          expect(
            errors.first,
            isA<Exception>().having((e) => e.toString(), 'toString', contains('Test stream error')),
          );
        });
      });
    });
  });
}
