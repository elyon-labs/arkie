import 'package:cs2_rcon_front_end/features/rcon/domain/models/player_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlayerInfo', () {
    group('displayName', () {
      test('prefixes BOT when isBot is true', () {
        final player = PlayerInfo(
          isBot: true,
          name: 'Rebel',
          id: 2,
          ping: 0,
          state: 'active',
          steamId: null,
          steamId64: null,
        );

        expect(player.displayName, 'BOT Rebel');
      });

      test('returns name when isBot is false', () {
        final player = PlayerInfo(
          isBot: false,
          name: 'Alice',
          id: 1,
          ping: 25,
          state: 'active',
          steamId: '[U:1:123]',
          steamId64: '76561198000000123',
        );

        expect(player.displayName, 'Alice');
      });
    });

    group('description', () {
      test('includes id, ping, and steamId when present', () {
        final player = PlayerInfo(
          isBot: false,
          name: 'Alice',
          id: 42,
          ping: 15,
          state: 'active',
          steamId: '[U:1:123]',
          steamId64: '76561198000000123',
        );

        expect(player.description, 'ID: 42, Ping: 15, SteamID: [U:1:123]');
      });

      test('falls back to ??? when steamId is missing', () {
        final player = PlayerInfo(
          isBot: false,
          name: 'Bob',
          id: 7,
          ping: 50,
          state: 'active',
          steamId: null,
          steamId64: null,
        );

        expect(player.description, 'ID: 7, Ping: 50, SteamID: ???');
      });
    });
  });
}
