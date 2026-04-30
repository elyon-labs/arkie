import 'package:cs2_rcon_client/cs2_rcon_client.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/ban_player.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxidized/oxidized.dart';

import '../../../fakes/fake_rcon_connection.dart';

void main() {
  group('BanPlayer', () {
    test('sends banid command with duration in minutes', () async {
      final sentCommands = <String>[];
      final banPlayer = BanPlayer(
        connection: FakeRCONConnection(
          onSendCommand: (command) async {
            sentCommands.add(command);
            return Ok(RCONServerPacket.responseValue(id: 1, body: 'OK'));
          },
        ),
      );

      final result = await banPlayer('STEAM_1:1:12345', duration: const Duration(minutes: 30));

      expect(result.isOk(), isTrue);
      expect(sentCommands, contains('banid 30 STEAM_1:1:12345 kick'));
    });

    test('returns an error when the ban command fails', () async {
      final banPlayer = BanPlayer(
        connection: FakeRCONConnection(
          onSendCommand: (command) async => Err(Exception('ban failed')),
        ),
      );

      final result = await banPlayer('STEAM_1:1:12345', duration: const Duration(minutes: 5));

      expect(result.isErr(), isTrue);
      expect(result.unwrapErr().toString(), contains('ban failed'));
    });
  });
}
