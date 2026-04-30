import 'dart:io';

import 'package:cs2_rcon_client/cs2_rcon_client.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import '../fakes/fake_rcon_server.dart';

void main() {
  group('RCONSocket', () {
    group('connect', () {
      test('returns Ok when password is correct', () async {
        final server = FakeRCONServer(
          address: InternetAddress.loopbackIPv4.address,
          port: 27015,
          password: 'test1234',
        );

        await server.start();

        addTearDown(() async {
          await server.stop();
        });

        final socket = RCONSocket(
          hostAddress: InternetAddress.loopbackIPv4,
          logLevel: LogLevel.none,
        );
        final result = await socket.connect(password: 'test1234');

        expect(result.isOk(), isTrue);
        expect(result.unwrap(), isA<RCONConnection>());
      });

      test('returns Err when password is incorrect', () async {
        final server = FakeRCONServer(
          address: InternetAddress.loopbackIPv4.address,
          port: 27015,
          password: 'test1234',
        );

        await server.start();

        addTearDown(() async {
          await server.stop();
        });

        final socket = RCONSocket(
          hostAddress: InternetAddress.loopbackIPv4,
          logLevel: LogLevel.none,
        );
        final result = await socket.connect(password: 'wrongpassword');

        expect(result.isErr(), isTrue);
        expect(result.unwrapErr(), isA<AuthorizationException>());
      });

      test('returns Err when connection times out', () async {
        final server = FakeRCONServer(
          address: InternetAddress.loopbackIPv4.address,
          port: 27015,
          password: 'test1234',
          onConnect: () async {
            // Simulate a delay to trigger timeout
            await Future<void>.delayed(const Duration(seconds: 2));
            // Reject the connection
            return false;
          },
        );

        await server.start();

        addTearDown(() async {
          await server.stop();
        });

        final socket = RCONSocket(
          hostAddress: InternetAddress.loopbackIPv4,
          connectTimeout: const Duration(milliseconds: 300),
          logLevel: LogLevel.none,
        );

        final result = await socket.connect(password: 'test1234');

        expect(result.isErr(), isTrue);
        expect(result.unwrapErr(), isA<CommandTimeoutException>());
      });
    });

    group('sendCommand', () {
      test('sends a command and receives the correct response', () async {
        final receivedPackets = <RCONClientPacket>[];

        final server = FakeRCONServer(
          address: InternetAddress.loopbackIPv4.address,
          port: 27015,
          password: 'test1234',
          onClientPacket: (packet) async {
            receivedPackets.add(packet);
            if (packet.body == 'status') {
              return 'Server Status: Online\nPlayers: 10/20';
            } else if (packet.type == ClientPacketType.SENTINEL) {
              final commandParts = packet.body.split(' ');
              return commandParts.lastOrNull ?? '';
            }
            return 'Unknown command';
          },
        );

        await server.start();

        addTearDown(() async {
          await server.stop();
        });

        final socket = RCONSocket(
          hostAddress: InternetAddress.loopbackIPv4,
          logLevel: LogLevel.none,
        );
        final connectResult = await socket.connect(password: 'test1234');

        expect(connectResult.isOk(), isTrue);
        final connection = connectResult.unwrap();

        final commandResult = await connection.sendCommand('status');

        await pumpEventQueue();

        expect(commandResult.isOk(), isTrue);
        final response = commandResult.unwrap();
        expect(response.body, contains('Server Status'));
      });

      test('handles parallel commands without mixing responses', () async {
        final server = FakeRCONServer(
          address: InternetAddress.loopbackIPv4.address,
          port: 27015,
          password: 'test1234',
          onClientPacket: (packet) async {
            if (packet.body == 'status') {
              return 'RAW_STATUS';
            }
            if (packet.body == 'status_json') {
              return '{"status": "ok"}';
            }
            if (packet.type == ClientPacketType.SENTINEL) {
              final commandParts = packet.body.split(' ');
              return commandParts.lastOrNull ?? '';
            }
            return 'Unexpected command: ${packet.body}';
          },
        );

        await server.start();

        addTearDown(() async {
          await server.stop();
        });

        final socket = RCONSocket(
          hostAddress: InternetAddress.loopbackIPv4,
          logLevel: LogLevel.none,
        );
        final connectResult = await socket.connect(password: 'test1234');

        expect(connectResult.isOk(), isTrue);
        final connection = connectResult.unwrap();

        final (rawStatusResult, statusJsonResult) = await (
          connection.sendCommand('status'),
          connection.sendCommand('status_json'),
        ).wait;

        expect(rawStatusResult.isOk(), isTrue);
        expect(statusJsonResult.isOk(), isTrue);

        expect(rawStatusResult.unwrap().body, 'RAW_STATUS');
        expect(statusJsonResult.unwrap().body, '{"status": "ok"}');
      });
    });

    group('close', () {
      test('closes the socket connection', () async {
        final server = FakeRCONServer(
          address: InternetAddress.loopbackIPv4.address,
          port: 27015,
          password: 'test1234',
        );

        await server.start();
        addTearDown(() async {
          await server.stop();
        });

        final socket = RCONSocket(
          hostAddress: InternetAddress.loopbackIPv4,
          logLevel: LogLevel.none,
        );
        final result = await socket.connect(password: 'test1234');

        expect(result.isOk(), isTrue);
        final connection = result.unwrap();

        await connection.close();

        // Since Socket does not expose a direct way to check if it's closed,
        // we can attempt to send a command and expect it to fail.
        final sendResult = await connection.sendCommand('status');
        expect(sendResult.isErr(), isTrue);
        expect(sendResult.unwrapErr(), isA<SocketClosedException>());
      });
    });
  });
}
