import 'dart:async';

import 'package:arkie_core/features/rcon/domain/kick_player.dart';
import 'package:arkie_core/testing/fake_rcon_connection.dart';
import 'package:cs2_rcon_client/cs2_rcon_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxidized/oxidized.dart';

void main() {
  group('KickPlayer', () {
    test('sends the kick command with the player name', () async {
      final commandCompleter = Completer<String>();
      final connection = FakeRCONConnection(
        onSendCommand: (command) async {
          commandCompleter.complete(command);
          return Ok(RCONServerPacket.responseValue(id: 1, body: 'OK'));
        },
      );
      final kickPlayer = KickPlayer(connection: connection);

      final result = await kickPlayer('PlayerOne');

      expect(await commandCompleter.future, 'kick PlayerOne');
      expect(result.isOk(), isTrue);
    });

    test('returns an error when the kick command fails', () async {
      final kickPlayer = KickPlayer(
        connection: FakeRCONConnection(
          onSendCommand: (_) async => Err(Exception('Failed to kick player')),
        ),
      );

      final result = await kickPlayer('PlayerOne');

      expect(result.isErr(), isTrue);
    });
  });
}
