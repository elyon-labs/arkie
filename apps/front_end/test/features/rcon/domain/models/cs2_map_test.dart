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

  group('KnownMap', () {
    test('uses png map asset paths', () {
      const map = KnownMap(name: 'de_dust2', assetName: 'de_dust2');

      expect(map.displayName, 'de_dust2');
      expect(map.assetPath, 'assets/maps/de_dust2.png');
    });
  });

  group('WorkshopMap', () {
    test('directory contains HLA CS2 workshop maps in source order', () {
      expect(WorkshopMap.directory, hasLength(48));
      expect(
        WorkshopMap.directory
            .take(5)
            .map((map) => (map.displayName, map.slug, map.workshopId, map.assetName)),
        [
          ('AWP India', 'awp-india', '3070290869', 'workshop_awp_india'),
          ('Abstract', 'abstract', '3079043089', 'workshop_abstract'),
          ('Anchor', 'anchor', '3592187337', 'workshop_anchor'),
          ('Assembly', 'assembly', '3071005299', 'workshop_assembly'),
          ('Belts', 'belts', '3665625941', 'workshop_belts'),
        ],
      );
    });

    test('directory workshop ids and slugs are unique', () {
      final workshopIds = WorkshopMap.directory.map((map) => map.workshopId).toSet();
      final slugs = WorkshopMap.directory.map((map) => map.slug).toSet();

      expect(workshopIds, hasLength(WorkshopMap.directory.length));
      expect(slugs, hasLength(WorkshopMap.directory.length));
    });

    test('uses webp workshop asset paths', () {
      final map = WorkshopMap.directory.first;

      expect(map.assetPath, 'assets/maps/workshop_awp_india.webp');
    });

    test('finds maps by workshop id', () {
      final map = WorkshopMap.findByWorkshopId('3079043089');

      expect(map?.displayName, 'Abstract');
    });
  });
}
