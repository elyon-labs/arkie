import 'package:cs2_rcon_client/cs2_rcon_client.dart';
import 'package:test/test.dart';

void main() {
  group('RCONPacket', () {
    group('SentinelPacket', () {
      group('isOriginOf', () {
        test('returns true when given packet is associated with the receiver', () {
          const sentinel = SentinelPacket(id: 1, commandId: 42);
          final matchingPacket = RCONServerPacket.responseValue(id: 2, body: '__CS2__END__42');

          expect(sentinel.isOriginOf(matchingPacket), isTrue);
        });

        test('returns false when given packet is not associated with the receiver', () {
          const sentinel = SentinelPacket(id: 1, commandId: 42);
          final nonMatchingPacket = RCONServerPacket.responseValue(id: 2, body: 'some other body');

          expect(sentinel.isOriginOf(nonMatchingPacket), isFalse);
        });
      });
    });

    group('combine', () {
      test('throws ArgumentError when invoked on empty list', () {
        final packets = <RCONServerPacket>[];

        expect(packets.combine, throwsArgumentError);
      });

      test('combines multiple packets into one', () {
        final packets = [
          RCONServerPacket.responseValue(id: 1, body: 'First part. '),
          RCONServerPacket.responseValue(id: 1, body: 'Second part. '),
          RCONServerPacket.responseValue(id: 1, body: 'Third part.'),
        ];

        final combinedPacket = packets.combine();

        expect(combinedPacket.id, equals(1));
        expect(combinedPacket.type, equals(ServerPacketType.SERVERDATA_RESPONSE_VALUE));
        expect(combinedPacket.body, equals('First part. Second part. Third part.'));
      });
    });
  });
}
