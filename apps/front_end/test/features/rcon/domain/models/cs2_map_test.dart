import 'package:cs2_rcon_front_end/features/rcon/domain/models/cs2_map.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CS2Map', () {
    group('type', () {
      test('returns defusal for maps starting with de_', () {
        const map = KnownMap(name: 'de_dust2', assetName: 'de_dust2');
        expect(map.type, CS2MapType.defusal);
      });

      test('returns hostageRescue for maps starting with cs_ or csgo_', () {
        const map = KnownMap(name: 'cs_office', assetName: 'cs_office');
        expect(map.type, CS2MapType.hostageRescue);
        const map2 = KnownMap(name: 'csgo_hijack', assetName: 'csgo_hijack');
        expect(map2.type, CS2MapType.hostageRescue);
      });

      test('returns armsRace for maps starting with ar_', () {
        const map = KnownMap(name: 'ar_baggage', assetName: 'ar_baggage');
        expect(map.type, CS2MapType.armsRace);
      });

      test('returns other for maps with unknown prefix', () {
        const map = KnownMap(name: 'aim_map', assetName: 'aim_map');
        expect(map.type, CS2MapType.other);
      });
    });
  });
}
