import 'package:cs2_rcon_front_end/features/rcon/data/models/message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Message', () {
    group('bodyWithoutTerminalCharacter', () {
      test('returns body without terminal character when present', () {
        final message = Message(
          id: '1',
          serverId: 'server1',
          body: 'Hello, World!\x00',
          sender: Sender.server,
        );

        expect(message.bodyWithoutTerminalCharacter, equals('Hello, World!'));
      });

      test('returns full body when no terminal character is present', () {
        final message = Message(
          id: '2',
          serverId: 'server1',
          body: 'No terminal character here',
          sender: Sender.client,
        );

        expect(message.bodyWithoutTerminalCharacter, equals('No terminal character here'));
      });

      test('handles body with terminal character at the start', () {
        final message = Message(
          id: '3',
          serverId: 'server1',
          body: '\x00Starts with terminal character',
          sender: Sender.server,
        );

        expect(message.bodyWithoutTerminalCharacter, equals('\x00Starts with terminal character'));
      });
    });
  });
}
