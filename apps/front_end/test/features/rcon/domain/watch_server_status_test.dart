import 'dart:io';

import 'package:cs2_rcon_client/cs2_rcon_client.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/models/player_info.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/models/server_status.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/watch_server_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxidized/oxidized.dart';

import '../../../fakes/fake_rcon_connection.dart';

void main() {
  group('WatchServerStatus', () {
    group('with a valid server status', () {
      test('emits a ServerStatus object', () async {
        final connection = FakeRCONConnection(
          onSendCommand: (command) async {
            if (command == 'status') {
              return Ok(RCONServerPacket.responseValue(id: 1, body: _validStatus));
            } else if (command == 'status_json') {
              return Ok(RCONServerPacket.responseValue(id: 1, body: _validStatusJson));
            } else {
              fail('Unexpected command: $command');
            }
          },
        );

        final watcher = WatchServerStatus(
          connection: connection,
          pollInterval: const Duration(milliseconds: 10),
        );

        final serverStatus = await watcher().first;

        final expectedStatus = ServerStatus(
          hostname: "Larry's Server",
          version: '1.41.2.8',
          address: InternetAddress.tryParse('141.151.73.222')!,
          port: 27015,
          os: 'Linux dedicated',
          players: [
            PlayerInfo(
              name: 'Rebel',
              id: 2,
              ping: 0,
              state: 'active',
              isBot: true,
              steamId: '[A:1:2:1]',
              steamId64: '90071996842377218',
            ),
            PlayerInfo(
              name: 'Rock',
              id: 3,
              ping: 0,
              state: 'active',
              isBot: true,
              steamId: '[A:1:11:1]',
              steamId64: '90071996842377227',
            ),
            PlayerInfo(
              name: 'Ricksaw',
              id: 4,
              ping: 0,
              state: 'active',
              isBot: true,
              steamId: null,
              steamId64: null,
            ),
            PlayerInfo(
              name: 'Commando',
              id: 5,
              ping: 0,
              state: 'active',
              isBot: true,
              steamId: null,
              steamId64: null,
            ),
            PlayerInfo(
              name: 'Shamat',
              id: 6,
              ping: 0,
              state: 'active',
              isBot: true,
              steamId: null,
              steamId64: null,
            ),
          ],
          numPlayers: 5,
          numMaxPlayers: 0,
          numHumans: 0,
          numBots: 5,
          map: 'de_inferno',
        );

        expect(serverStatus, expectedStatus);

        final playersByName = {for (final player in serverStatus.players) player.name: player};

        expect(
          playersByName.keys,
          containsAll(<String>['Rebel', 'Rock', 'Ricksaw', 'Commando', 'Shamat']),
        );
        expect(playersByName.values.every((p) => p.ping == 0), isTrue);
        expect(playersByName.values.every((p) => p.state == 'active'), isTrue);
        expect(playersByName['Rebel']?.id, 2);
        expect(playersByName['Rock']?.id, 3);
        expect(playersByName['Shamat']?.id, 6);
      });
    });

    group('with an invalid server status', () {
      test('does not emit any ServerStatus object', () async {
        final connection = FakeRCONConnection(
          onSendCommand: (command) async {
            if (command == 'status') {
              return Ok(RCONServerPacket.responseValue(id: 1, body: 'invalid status response'));
            } else if (command == 'status_json') {
              return Err(Exception('status_json not available'));
            } else {
              fail('Unexpected command: $command');
            }
          },
        );

        final watcher = WatchServerStatus(
          connection: connection,
          pollInterval: const Duration(milliseconds: 10),
        );

        final stream = watcher();

        final result = await Result.asyncOf(() {
          return stream.first.timeout(
            const Duration(milliseconds: 50),
            onTimeout: () {
              throw Exception('No data emitted');
            },
          );
        });

        expect(result.isErr(), isTrue);
        expect(result.unwrapErr().toString(), contains('No data emitted'));
      });
    });
  });
}

const _validStatusJson = '''
{
	"frametime_ms": 15.625260,
	"framecomputetime_ms": 1.893068,
	"process_uptime": 2718,
	"build_version": 2000696,
	"build_source_revision": "10299884",
	"mem_phys_total_gb": 7.755085,
	"mem_phys_avail_gb": 2.537685,
	"mem_virt_total_gb": 128.000000,
	"mem_virt_avail_gb": 128.000000,
	"server":
	{
		"hibernating": false,
		"cpu_usage": 0.080566,
		"clients_bot": 12,
		"clients_human": 1,
		"clients_proxies": 0,
		"map": "de_dust2",
		"addon": "",
		"udp_port": 27015,
		"ticks_per_interval":
		{
			"buckets":
			{
				"0": 0,
				"1": 17153,
				"2": 17153,
				"3": 17153,
				"4": 17153,
				"5": 17153,
				"6": 17153,
				"7": 17153,
				"8": 17153,
				"9": 17153,
				"+inf": 17153
			},
			"created": 1766090456,
			"sum": 17153,
			"count": 17153
		},
		"framecomputetime_ms_per_interval":
		{
			"buckets":
			{
				"0": 0,
				"1": 2326,
				"2": 14639,
				"3": 16832,
				"4": 17120,
				"5": 17143,
				"6": 17147,
				"7": 17153,
				"8": 17153,
				"9": 17153,
				"10": 17153,
				"11": 17153,
				"12": 17153,
				"13": 17153,
				"14": 17153,
				"15": 17153,
				"16": 17153,
				"17": 17153,
				"18": 17153,
				"19": 17153,
				"20": 17153,
				"21": 17153,
				"22": 17153,
				"23": 17153,
				"24": 17153,
				"25": 17153,
				"26": 17153,
				"27": 17153,
				"28": 17153,
				"29": 17153,
				"30": 17153,
				"31": 17153,
				"32": 17153,
				"33": 17153,
				"34": 17153,
				"35": 17153,
				"36": 17153,
				"37": 17153,
				"38": 17153,
				"39": 17153,
				"40": 17153,
				"41": 17153,
				"42": 17153,
				"43": 17153,
				"44": 17153,
				"45": 17153,
				"46": 17153,
				"47": 17153,
				"48": 17153,
				"49": 17153,
				"50": 17153,
				"51": 17153,
				"52": 17153,
				"53": 17153,
				"54": 17153,
				"55": 17153,
				"56": 17153,
				"57": 17153,
				"58": 17153,
				"59": 17153,
				"+inf": 17153
			},
			"created": 1766090456,
			"sum": 26923314.000000,
			"count": 17153
		},
		"clients":
		[
			{
				"steamid64": "0",
				"steamid": "[I:0:0]",
				"bot": false,
				"name": ""
			},
			{
				"steamid64": "0",
				"steamid": "[I:0:0]",
				"bot": false,
				"name": ""
			},
			{
				"steamid64": "76561197997837923",
				"steamid": "[U:1:37572195]",
				"bot": false,
				"name": "LarryCucumber"
			},
			{
				"steamid64": "90071996842377218",
				"steamid": "[A:1:2:1]",
				"bot": true,
				"name": "Rebel"
			},
			{
				"steamid64": "90071996842377219",
				"steamid": "[A:1:3:1]",
				"bot": true,
				"name": "Rip"
			},
			{
				"steamid64": "90071996842377220",
				"steamid": "[A:1:4:1]",
				"bot": true,
				"name": "Wolf"
			},
			{
				"steamid64": "90071996842377221",
				"steamid": "[A:1:5:1]",
				"bot": true,
				"name": "Muhlik"
			},
			{
				"steamid64": "90071996842377222",
				"steamid": "[A:1:6:1]",
				"bot": true,
				"name": "Steel"
			},
			{
				"steamid64": "90071996842377223",
				"steamid": "[A:1:7:1]",
				"bot": true,
				"name": "Soldier"
			},
			{
				"steamid64": "90071996842377224",
				"steamid": "[A:1:8:1]",
				"bot": true,
				"name": "Crew"
			},
			{
				"steamid64": "90071996842377225",
				"steamid": "[A:1:9:1]",
				"bot": true,
				"name": "Crusher"
			},
			{
				"steamid64": "90071996842377226",
				"steamid": "[A:1:10:1]",
				"bot": true,
				"name": "Syfers"
			},
			{
				"steamid64": "90071996842377227",
				"steamid": "[A:1:11:1]",
				"bot": true,
				"name": "Rock"
			}
		],
		"player_network_loss_max": 0.000000,
		"player_network_loss_avg": 0.000000,
		"player_network_lag_max": 0.001000,
		"player_network_lag_avg": 0.001000,
		"async_networking_wait_ms": 0.000000,
		"startup_ServerModuleInit": 1609,
		"startup_GameRulesCreated": 2146,
		"startup_SteamLoggedOn": 3289,
		"startup_RequestedGcSession": 3503,
		"game_vars": 3000,
		"gc_status": "GCConnectionStatus_HAVE_SESSION",
		"sv_shutdown_requested": false,
		"frame_time_sample_count": 4096,
		"frame_time_50th_percentile": 0.015620,
		"frame_time_95th_percentile": 0.016390,
		"frame_time_max": 0.020039,
		"frame_run_time_sample_count": 4096,
		"frame_run_time_50th_percentile": 0.001732,
		"frame_run_time_95th_percentile": 0.002611,
		"frame_run_time_max": 0.006355,
		"frame_sleep_time_sample_count": 4096,
		"frame_sleep_time_50th_percentile": 0.013892,
		"frame_sleep_time_5th_percentile": 0.013009,
		"frame_sleep_time_min": 0.009257,
		"frame_animgraph_time_sample_count": 4096,
		"frame_animgraph_time_50th_percentile": 0.000239,
		"frame_animgraph_time_95th_percentile": 0.000326,
		"frame_animgraph_time_max": 0.000684,
		"steam_loggedon": true,
		"steamid64": "85568392935611682",
		"steamid": "[G:1:15572258]"
	}
}
''';

const _validStatus = '''
Server:  Running [0.0.0.0:27015]
Client:  Disconnected
----- Status -----
@ Current  :  game
source   : console
hostname : Larry's Server
spawn    : 3
version  : 1.41.2.8/14128 10603 secure  public
steamid  : [G:1:15572258] (85568392935611682)
udp/ip   : 0.0.0.0:27015 (public 141.151.73.222:27015)
os/type  : Linux dedicated
players  : 0 humans, 5 bots (0 max) (hibernating) (unreserved)
---------spawngroups----
loaded spawngroup(  1)  : SV:  [1: de_inferno | main lump | mapload]
loaded spawngroup(  2)  : SV:  [2: maps/prefabs/de_inferno/inferno_skybox | main lump | mapload | point_prefab]
loaded spawngroup(  3)  : SV:  [3: prefabs/misc/counterterrorist_team_intro | main lump | mapload | point_prefab]
loaded spawngroup(  4)  : SV:  [4: prefabs/misc/terrorist_team_intro | main lump | mapload | point_prefab]
loaded spawngroup(  5)  : SV:  [5: prefabs/misc/terrorist_team_intro_variant2 | main lump | mapload | point_prefab]
loaded spawngroup(  6)  : SV:  [6: prefabs/misc/counterterrorist_team_intro_variant2 | main lump | mapload | point_prefab]
loaded spawngroup(  7)  : SV:  [7: prefabs/misc/counterterrorist_wingman_intro | main lump | mapload | point_prefab]
loaded spawngroup(  8)  : SV:  [8: prefabs/misc/terrorist_wingman_intro | main lump | mapload | point_prefab]
loaded spawngroup(  9)  : SV:  [9: prefabs/misc/end_of_match | main lump | mapload | point_prefab]
loaded spawngroup( 10)  : SV:  [10: prefabs/misc/team_select | main lump | mapload | point_prefab]
---------players--------
  id     time ping loss      state   rate adr name
65535 [NoChan]    0    0 challenging      0unknown ''
65535 [NoChan]    0    0 challenging      0unknown ''
   2      BOT    0    0     active      0 'Rebel'
   3      BOT    0    0     active      0 'Rock'
   4      BOT    0    0     active      0 'Ricksaw'
   5      BOT    0    0     active      0 'Commando'
   6      BOT    0    0     active      0 'Shamat'
#end
''';
