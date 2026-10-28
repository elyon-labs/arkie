import 'package:arkie_core/features/rcon/demo/demo_connections.dart';
import 'package:arkie_core/features/rcon/domain/find_command.dart';
import 'package:arkie_core/features/rcon/domain/models/cs2_map.dart';
import 'package:arkie_core/features/rcon/domain/watch_server_maps.dart';
import 'package:arkie_core/features/rcon/domain/watch_server_status.dart';
import 'package:cs2_rcon_client/cs2_rcon_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DemoConnections', () {
    const address = '203.0.113.10';
    const port = 27015;

    RCONConnection buildConnection([DemoConnections? connections]) {
      return (connections ?? DemoConnections())(address: address, port: port);
    }

    test('hands back the same connection for the same server', () {
      final subject = DemoConnections();

      expect(subject(address: address, port: port), same(subject(address: address, port: port)));
    });

    test('keeps each server its own', () {
      final subject = DemoConnections();

      expect(
        subject(address: address, port: port),
        isNot(same(subject(address: '203.0.113.11', port: port))),
      );
    });

    test('holds state across connections to the same server', () async {
      final subject = DemoConnections();
      await buildConnection(subject).sendCommand('map de_nuke');

      final status = await buildConnection(subject).sendCommand('status');

      expect(status.unwrap().body, contains('de_nuke'));
    });

    test('forgets everything once cleared', () async {
      final subject = DemoConnections();
      await buildConnection(subject).sendCommand('map de_nuke');

      subject.clear();

      final status = await buildConnection(subject).sendCommand('status');
      expect(status.unwrap().body, contains('de_dust2'));
    });

    // The point of the demo server is that the panes fill in, so the real
    // parsers have to be able to read what it says.
    group('the server status watcher', () {
      test('reads the status the demo server reports', () async {
        final watcher = WatchServerStatus(
          connection: buildConnection(),
          pollInterval: const Duration(milliseconds: 10),
        );

        final status = await watcher().first;

        expect(status.hostname, 'Arkie Demo Server');
        expect(status.version, '1.40.8.4');
        expect(status.address.address, address);
        expect(status.port, port);
        expect(status.os, 'Linux dedicated');
        expect(status.map, 'de_dust2');
        expect(status.numHumans, 2);
        expect(status.numBots, 3);
        expect(status.numMaxPlayers, 10);
        expect(status.players, hasLength(5));
      });

      test('matches the steam ids from status_json onto the players', () async {
        final watcher = WatchServerStatus(
          connection: buildConnection(),
          pollInterval: const Duration(milliseconds: 10),
        );

        final status = await watcher().first;
        final human = status.players.firstWhere((player) => player.name == 'tempo');
        final bot = status.players.firstWhere((player) => player.isBot);

        expect(human.isBot, isFalse);
        expect(human.ping, 34);
        expect(human.state, 'active');
        expect(human.steamId, '[U:1:84921044]');
        expect(human.steamId64, '76561198045186772');
        expect(bot.steamId, 'BOT');
      });

      test('sees a kicked player leave', () async {
        final connection = buildConnection();
        final watcher = WatchServerStatus(
          connection: connection,
          pollInterval: const Duration(milliseconds: 10),
        );

        await connection.sendCommand('kick tempo');
        final status = await watcher().first;

        expect(status.numHumans, 1);
        expect(status.players.map((player) => player.name), isNot(contains('tempo')));
      });
    });

    group('the server maps watcher', () {
      test('reads every stock map out of the demo server', () async {
        final watcher = WatchServerMaps(
          connection: buildConnection(),
          pollInterval: const Duration(milliseconds: 10),
        );

        final maps = await watcher().first;

        expect(maps.map((map) => map.name), containsAll(KnownMap.directory.map((m) => m.name)));
      });
    });

    group('command autocomplete', () {
      test('reads the convars the demo server knows about', () async {
        final connection = buildConnection();
        final subject = FindCommand(connection: connection);

        final commands = (await subject(
          commandPart: 'mp_warmuptime',
          connection: connection,
        )).unwrap();

        expect(commands.first.name, 'mp_warmuptime');
        expect(commands.first.description, 'Duration of the warmup period, in seconds.');
      });

      test('comes back empty rather than failing on no match', () async {
        final connection = buildConnection();
        final subject = FindCommand(connection: connection);

        final commands = (await subject(commandPart: 'zzzznope', connection: connection)).unwrap();

        expect(commands, isEmpty);
      });
    });
  });
}
