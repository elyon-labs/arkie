import 'package:cs2_rcon_front_end/hive/hive_adapters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('hive adapters', () {
    test('pins the type id of every persisted model', () {
      expect(ServerAdapter().typeId, 0);
      expect(MessageAdapter().typeId, 1);
      expect(SenderAdapter().typeId, 2);
      expect(SavedMessageAdapter().typeId, 3);
    });

    test('retires the type ids of the removed SSH management models', () {
      final typeIds = [
        ServerAdapter().typeId,
        MessageAdapter().typeId,
        SenderAdapter().typeId,
        SavedMessageAdapter().typeId,
      ];

      expect(typeIds, isNot(contains(4)));
      expect(typeIds, isNot(contains(5)));
      expect(typeIds, isNot(contains(6)));
    });
  });
}
