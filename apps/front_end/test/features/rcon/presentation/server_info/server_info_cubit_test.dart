import 'package:cs2_rcon_client/cs2_rcon_client.dart';
import 'package:cs2_rcon_front_end/core/async.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/ban_player.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/change_map.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/kick_player.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/models/cs2_map.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/models/player_info.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/models/server_status.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/watch_server_maps.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/watch_server_status.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/server_info_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxidized/oxidized.dart';

import '../../../../fakes/fake_rcon_connection.dart';

void main() {
  group('ServerInfoCubit', () {
    const map = KnownMap(name: 'de_inferno', assetName: 'de_inferno');

    FakeRCONConnection buildConnection({
      required List<String> sentCommands,
      bool shouldFailStatus = false,
    }) {
      var currentMap = 'de_dust2';
      return FakeRCONConnection(
        onSendCommand: (command) async {
          sentCommands.add(command);
          if (command == 'maps *') {
            return Ok(RCONServerPacket.responseValue(id: 1, body: 'de_dust2\nde_inferno'));
          } else if (command == 'status') {
            if (shouldFailStatus) {
              return Err(Exception('status failed'));
            }
            return Ok(RCONServerPacket.responseValue(id: 1, body: _statusBodyFor(currentMap)));
          } else if (command == 'status_json') {
            return Ok(RCONServerPacket.responseValue(id: 1, body: _statusJsonBody));
          } else if (command.startsWith('map ')) {
            currentMap = command.replaceFirst('map ', '');
            return Ok(RCONServerPacket.responseValue(id: 1, body: 'OK'));
          } else if (command.startsWith('kick ')) {
            return Ok(RCONServerPacket.responseValue(id: 1, body: 'OK'));
          } else if (command.startsWith('banid ')) {
            return Ok(RCONServerPacket.responseValue(id: 1, body: 'OK'));
          }
          return Err(Exception('Unexpected command: $command'));
        },
      );
    }

    ServerInfoCubit buildCubit({
      required FakeRCONConnection connection,
      Duration pollInterval = const Duration(milliseconds: 10),
    }) {
      return ServerInfoCubit(
        watchServerStatus: WatchServerStatus(connection: connection, pollInterval: pollInterval),
        watchServerMaps: WatchServerMaps(connection: connection, pollInterval: pollInterval),
        changeMap: ChangeMap(connection: connection),
        kickPlayer: KickPlayer(connection: connection),
        banPlayer: BanPlayer(connection: connection),
      );
    }

    group('initialization', () {
      test('loads maps and status on init', () async {
        final sentCommands = <String>[];
        final cubit = buildCubit(connection: buildConnection(sentCommands: sentCommands));

        addTearDown(cubit.close);

        await Future.delayed(const Duration(milliseconds: 50));

        expect(sentCommands, containsAll(['maps *', 'status', 'status_json']));
        expect(cubit.state.maps, contains(map));
        expect(cubit.state.workshopMaps, WorkshopMap.directory);
        expect(cubit.state.status, isA<Loaded<ServerStatus>>());
      });
    });

    group('changeMap', () {
      test('sets pending action, issues command, and clears pending action', () async {
        final sentCommands = <String>[];
        final cubit = buildCubit(connection: buildConnection(sentCommands: sentCommands));

        addTearDown(cubit.close);

        await Future.delayed(const Duration(milliseconds: 50));

        final resultFuture = cubit.changeMap(map);

        expect(cubit.state.pendingAction, isA<Some>());

        await Future.delayed(const Duration(milliseconds: 3100));
        final result = await resultFuture;

        expect(result.isOk(), isTrue);
        expect(sentCommands.any((c) => c == 'map ${map.name}'), isTrue);
        expect(cubit.state.pendingAction, isA<None>());
        expect(
          cubit.state.status,
          isA<Loaded<ServerStatus>>().having((s) => s.value.map, 'map', map.name),
        );
      });
    });

    group('kickPlayer', () {
      test('succeeds and clears pending action', () async {
        final sentCommands = <String>[];
        final cubit = buildCubit(connection: buildConnection(sentCommands: sentCommands));

        addTearDown(cubit.close);

        await Future.delayed(const Duration(milliseconds: 50));

        final resultFuture = cubit.kickPlayer(
          PlayerInfo(
            isBot: false,
            name: 'PlayerOne',
            id: 1,
            ping: 0,
            state: 'active',
            steamId: null,
            steamId64: null,
          ),
        );

        expect(cubit.state.pendingAction, isA<Some>());

        await Future.delayed(const Duration(milliseconds: 3100));
        final result = await resultFuture;

        expect(result.isOk(), isTrue);
        expect(sentCommands.contains('kick PlayerOne'), isTrue);
        expect(cubit.state.pendingAction, isA<None>());
      });

      test('returns error when status is not loaded', () async {
        final sentCommands = <String>[];
        final connection = buildConnection(sentCommands: sentCommands, shouldFailStatus: true);
        final cubit = buildCubit(connection: connection);

        addTearDown(cubit.close);

        await Future.delayed(const Duration(milliseconds: 50));

        final result = await cubit.kickPlayer(
          PlayerInfo(
            isBot: false,
            name: 'PlayerOne',
            id: 1,
            ping: 0,
            state: 'active',
            steamId: null,
            steamId64: null,
          ),
        );

        expect(result.isErr(), isTrue);
        expect(cubit.state.pendingAction, isA<None>());
        expect(sentCommands.contains('kick PlayerOne'), isFalse);
      });
    });

    group('banPlayer', () {
      test('succeeds and clears pending action', () async {
        final sentCommands = <String>[];
        final cubit = buildCubit(connection: buildConnection(sentCommands: sentCommands));

        addTearDown(cubit.close);

        await Future.delayed(const Duration(milliseconds: 50));

        final resultFuture = cubit.banPlayer(
          PlayerInfo(
            isBot: false,
            name: 'PlayerOne',
            id: 1,
            ping: 0,
            state: 'active',
            steamId: 'STEAM_1:1:12345',
            steamId64: 'steamId64',
          ),
          duration: const Duration(minutes: 30),
        );

        expect(cubit.state.pendingAction, isA<Some>());

        await Future.delayed(const Duration(milliseconds: 3100));
        final result = await resultFuture;

        expect(result.isOk(), isTrue);
        expect(sentCommands.contains('banid 30 STEAM_1:1:12345 kick'), isTrue);
        expect(cubit.state.pendingAction, isA<None>());
      });

      test('returns error when steamId is null', () async {
        final sentCommands = <String>[];
        final cubit = buildCubit(connection: buildConnection(sentCommands: sentCommands));

        addTearDown(cubit.close);

        await Future.delayed(const Duration(milliseconds: 50));

        final result = await cubit.banPlayer(
          PlayerInfo(
            isBot: false,
            name: 'PlayerOne',
            id: 1,
            ping: 0,
            state: 'active',
            steamId: null,
            steamId64: null,
          ),
          duration: const Duration(minutes: 30),
        );

        expect(result.isErr(), isTrue);
        expect(cubit.state.pendingAction, isA<None>());
        expect(sentCommands.any((c) => c.startsWith('banid ')), isFalse);
      });
    });
  });
}

const _statusJsonBody = '''
{
  "process_uptime": 1,
  "build_version": 1,
  "build_source_revision": "rev",
  "mem_phys_total_gb": 1.0,
  "mem_phys_avail_gb": 1.0,
  "server": {
    "hibernating": false,
    "cpu_usage": 0.0,
    "clients_bot": 0,
    "clients_human": 0,
    "clients_proxies": 0,
    "map": "de_dust2",
    "addon": "",
    "udp_port": 27015,
    "ticks_per_interval": {"buckets": {"0": 0}},
    "clients": []
  }
}
''';

String _statusBodyFor(String mapName) =>
    '''
Server:  Running [0.0.0.0:27015]
Client:  Disconnected
----- Status -----
hostname : Test Server
version  : 1.0.0.0
udp/ip   : 0.0.0.0:27015 (public 127.0.0.1:27015)
os/type  : Linux
players  : 0 humans, 0 bots (0 max) (hibernating) (unreserved)
---------spawngroups----
loaded spawngroup(  1)  : SV:  [1: $mapName | main lump | mapload]
---------players--------
  id     time ping loss      state   rate adr name
#end
''';
