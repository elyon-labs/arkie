import 'package:cs2_rcon_front_end/features/rcon/domain/models/cs2_map.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/models/player_info.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/models/pending_action.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PendingAction', () {
    group('PendingKick', () {
      test('description includes player display name', () {
        final player = PlayerInfo(
          isBot: true,
          name: 'Rebel',
          id: 2,
          ping: 0,
          state: 'active',
          steamId: null,
          steamId64: null,
        );

        final action = PendingKick(player);

        expect(action.description, 'Kicking BOT Rebel');
      });
    });

    group('PendingBan', () {
      test('description includes player display name and defaults to permanent', () {
        final player = PlayerInfo(
          isBot: false,
          name: 'Alice',
          id: 1,
          ping: 10,
          state: 'active',
          steamId: null,
          steamId64: null,
        );

        final action = PendingBan(player, duration: Duration.zero);

        expect(action.description, 'Banning Alice (permanent)');
      });

      test('description uses player display name and duration ban description', () {
        final player = PlayerInfo(
          isBot: true,
          name: 'Rebel',
          id: 2,
          ping: 0,
          state: 'active',
          steamId: null,
          steamId64: null,
        );

        final action = PendingBan(player, duration: const Duration(minutes: 30));

        expect(action.description, 'Banning BOT Rebel (30m)');
      });
    });

    group('PendingMapChange', () {
      test('description includes map display name', () {
        const map = KnownMap(name: 'de_inferno', assetName: 'de_inferno');

        const action = PendingMapChange(map);

        expect(action.description, 'Changing map to de_inferno');
      });

      test('description uses workshop map display name', () {
        final map = WorkshopMap.directory.first;

        final action = PendingMapChange(map);

        expect(action.description, 'Changing map to AWP India');
      });
    });
  });
}
