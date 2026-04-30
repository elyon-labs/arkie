import 'package:cs2_rcon_client/cs2_rcon_client.dart';
import 'package:oxidized/oxidized.dart';
import 'package:test/test.dart';

void main() {
  group('RCONConnection', () {
    group('sendCommand', () {
      test('it delegates to the provided implementation', () async {
        final commandsSent = <String>[];

        Future<Ok<RCONServerPacket, Exception>> sendCommand(String command) async {
          commandsSent.add(command);
          return Ok(RCONServerPacket.responseValue(id: 1, body: 'Response'));
        }

        final connection = RCONConnection(sendCommand: sendCommand, closeConnection: () async {});

        final result = await connection.sendCommand('test_command');

        expect(result.isOk(), isTrue);
        expect(commandsSent, equals(['test_command']));
      });
    });

    group('close', () {
      test('it delegates to the provided implementation', () async {
        var wasClosed = false;

        Future<void> closeConnection() async {
          wasClosed = true;
        }

        final connection = RCONConnection(
          sendCommand: (command) async => Err(Exception()),
          closeConnection: closeConnection,
        );

        await connection.close();

        expect(wasClosed, isTrue);
      });
    });
  });
}
