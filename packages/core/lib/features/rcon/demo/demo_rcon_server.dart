import 'package:arkie_core/features/rcon/domain/models/cs2_map.dart';

/// A CS2 server that lives in memory instead of on a host somewhere.
///
/// It backs the demo server the app can save, which is how App Store review
/// sees the console, the player list and the map picker work without a real
/// server to point at. Responses are shaped like the real thing — `status` and
/// `status_json` agree with each other, `maps *` lists the stock maps, `find`
/// prints the column layout the autocomplete parses — so nothing downstream
/// needs to know it is talking to this.
///
/// Changes are held for as long as the connection is open and written nowhere,
/// so it behaves like a server: a kicked player stays gone, a map change sticks
/// and a cvar keeps the value it was set to.
class DemoRCONServer {
  DemoRCONServer({required this.address, required this.port, DateTime? startedAt})
    : _startedAt = startedAt ?? DateTime.now();

  /// The address the saved demo server points at, echoed back in `status` so
  /// the server pane agrees with the entry in the server list.
  final String address;

  /// The port the saved demo server points at.
  final int port;

  final DateTime _startedAt;

  static const hostname = 'Arkie Demo Server';
  static const version = '1.40.8.4';
  static const buildVersion = 14008;
  static const buildSourceRevision = '9144';
  static const os = 'Linux dedicated';
  static const maxPlayers = 10;
  static const _privateAddress = '10.0.0.12';

  String _map = 'de_dust2';
  final List<_DemoPlayer> _players = _DemoPlayer.roster();
  final Map<String, String> _cvars = {
    for (final cvar in _DemoCvar.directory) cvar.name: cvar.value,
  };

  /// Runs [command] and returns what the server would have printed.
  ///
  /// Every command returns something, because an empty response reads as a
  /// broken connection further up.
  String execute(String command) {
    final trimmed = command.trim();
    if (trimmed.isEmpty) return 'Unknown command';

    final parts = trimmed.split(RegExp(r'\s+'));
    final name = parts.first.toLowerCase();
    final arguments = parts.skip(1).toList();
    final rest = trimmed.substring(parts.first.length).trim();

    return switch (name) {
      'echo' => rest,
      'status' => _status(),
      'status_json' => _statusJson(),
      'maps' => _maps(),
      'find' => _find(rest),
      'kick' => _kick(rest),
      'banid' => _banId(arguments),
      'map' || 'changelevel' => _changeMap(arguments.firstOrNull),
      'host_workshop_map' => _changeWorkshopMap(arguments.firstOrNull),
      'say' => rest.isEmpty ? 'Usage: say <message>' : 'Console: $rest',
      'mp_restartgame' => 'Restarting the game in ${arguments.firstOrNull ?? '1'} seconds...',
      _ => _cvar(parts.first, rest),
    };
  }

  String _status() {
    final humans = _players.where((player) => !player.isBot).length;
    final bots = _players.length - humans;

    final lines = [
      'hostname: $hostname',
      'version : $version/$buildVersion $buildSourceRevision secure  public',
      'steamid : [A:1:2894805422:43018](90264585384124431)',
      'udp/ip  : $_privateAddress:$port  (public $address:$port)',
      'os/type : $os',
      'players : $humans humans, $bots bots ($maxPlayers max) (not hibernating) (unreserved)',
      '',
      '# Map: $_map',
      '# Loaded spawngroups:',
      '#   loaded spawngroup(  1) : SV:  [1: $_map | world layer]',
      '',
      '---------players--------',
      'id  time ping loss      state   rate adr name',
      ..._players.map((player) => player.statusLine(_startedAt)),
      '#end',
    ];

    return '${lines.join('\n')}\n';
  }

  String _statusJson() {
    final humans = _players.where((player) => !player.isBot).length;
    final bots = _players.length - humans;
    final uptime = DateTime.now().difference(_startedAt).inSeconds + 2706;

    final clients = _players
        .map(
          (player) =>
              '    {"steamid64": "${player.steamId64}", "steamid": "${player.steamId}", '
              '"bot": ${player.isBot}, "name": "${player.name}"}',
        )
        .join(',\n');

    return '''
{
  "process_uptime": $uptime,
  "build_version": $buildVersion,
  "build_source_revision": "$buildSourceRevision",
  "mem_phys_total_gb": 16.0,
  "mem_phys_avail_gb": 11.2,
  "server": {
    "hibernating": false,
    "cpu_usage": 7.4,
    "clients_bot": $bots,
    "clients_human": $humans,
    "clients_proxies": 0,
    "clients": [
$clients
    ],
    "map": "$_map",
    "addon": "",
    "udp_port": $port
  }
}
''';
  }

  String _maps() {
    final names = KnownMap.directory.map((map) => map.name).toList()..sort();
    return '${names.map((name) => 'PATH: GAME\n maps/$name.vpk').join('\n')}\n';
  }

  String _find(String query) {
    final matches = _DemoCvar.directory
        .where((cvar) => query.isEmpty || cvar.name.contains(query.toLowerCase()))
        .toList();

    if (matches.isEmpty) return 'No matching commands or convars for "$query"\n';

    final rows = matches.map((cvar) => cvar.findRow(_cvars[cvar.name] ?? cvar.value));

    return [
      'Found ${matches.length} matching commands/convars:',
      '--------------',
      _DemoCvar.findHeader,
      _DemoCvar.findUnderline,
      ...rows,
      '',
    ].join('\n');
  }

  String _kick(String name) {
    if (name.isEmpty) return 'Usage: kick <name>';

    final target = _players.firstWhere(
      (player) => player.name.toLowerCase() == name.toLowerCase(),
      orElse: _DemoPlayer.none,
    );
    if (target.isNone) return 'No player named "$name" is connected.';

    _players.remove(target);
    return 'Kicking "${target.name}" (reason: "Kicked by console")\n';
  }

  String _banId(List<String> arguments) {
    if (arguments.length < 2) return 'Usage: banid <minutes> <steamid> [kick]';

    final minutes = int.tryParse(arguments.first);
    if (minutes == null) return 'banid: "${arguments.first}" is not a duration in minutes.';

    final steamId = arguments[1];
    final target = _players.firstWhere(
      (player) => player.steamId == steamId || player.steamId64 == steamId,
      orElse: _DemoPlayer.none,
    );

    final duration = minutes == 0 ? 'permanently' : 'for $minutes minutes';
    if (target.isNone) return 'banid: added $steamId to the ban list $duration.\n';

    _players.remove(target);
    return 'banid: banned "${target.name}" $duration and kicked them.\n';
  }

  String _changeMap(String? name) {
    if (name == null) return 'Usage: map <mapname>';

    final known = KnownMap.directory.any((map) => map.name == name);
    if (!known) return 'map load failed: "$name" is not on this server.';

    _map = name;
    return 'Changelevel to $name\n';
  }

  String _changeWorkshopMap(String? workshopId) {
    if (workshopId == null) return 'Usage: host_workshop_map <published file id>';

    _map = 'workshop/$workshopId';
    return 'Subscribing to workshop item $workshopId and changing level...\n';
  }

  /// Reads a cvar, or sets it when a value follows, falling back to the
  /// unknown-command line a real server prints.
  String _cvar(String name, String value) {
    final current = _cvars[name.toLowerCase()];
    if (current == null) return 'Unknown command "$name"';

    if (value.isEmpty) return '"$name" = "$current"\n';

    final cleaned = value.replaceAll('"', '');
    _cvars[name.toLowerCase()] = cleaned;
    return '"$name" changed to "$cleaned"\n';
  }
}

/// One of the players the demo server reports as connected.
class _DemoPlayer {
  const _DemoPlayer({
    required this.id,
    required this.name,
    required this.isBot,
    required this.ping,
    required this.steamId,
    required this.steamId64,
    required this.joinedSecondsAgo,
    required this.networkAddress,
  });

  /// The absence of a player, so a lookup miss does not need a nullable hop.
  factory _DemoPlayer.none() {
    return const _DemoPlayer(
      id: -1,
      name: '',
      isBot: false,
      ping: 0,
      steamId: '',
      steamId64: '',
      joinedSecondsAgo: 0,
      networkAddress: '',
    );
  }

  /// A full-ish server: a couple of humans so the player tools have a real
  /// target, and bots to fill the scoreboard out.
  static List<_DemoPlayer> roster() {
    return [
      const _DemoPlayer(
        id: 0,
        name: 'tempo',
        isBot: false,
        ping: 34,
        steamId: '[U:1:84921044]',
        steamId64: '76561198045186772',
        joinedSecondsAgo: 1750,
        networkAddress: '198.51.100.24:27005',
      ),
      const _DemoPlayer(
        id: 1,
        name: 'kirsche',
        isBot: false,
        ping: 58,
        steamId: '[U:1:201337480]',
        steamId64: '76561198161603208',
        joinedSecondsAgo: 702,
        networkAddress: '198.51.100.77:27005',
      ),
      const _DemoPlayer(
        id: 2,
        name: 'Dennis',
        isBot: true,
        ping: 0,
        steamId: 'BOT',
        steamId64: 'BOT',
        joinedSecondsAgo: 0,
        networkAddress: '',
      ),
      const _DemoPlayer(
        id: 3,
        name: 'Lars',
        isBot: true,
        ping: 0,
        steamId: 'BOT',
        steamId64: 'BOT',
        joinedSecondsAgo: 0,
        networkAddress: '',
      ),
      const _DemoPlayer(
        id: 4,
        name: 'Vitaliy',
        isBot: true,
        ping: 0,
        steamId: 'BOT',
        steamId64: 'BOT',
        joinedSecondsAgo: 0,
        networkAddress: '',
      ),
    ];
  }

  final int id;
  final String name;
  final bool isBot;
  final int ping;
  final String steamId;
  final String steamId64;
  final int joinedSecondsAgo;
  final String networkAddress;

  bool get isNone => id == -1;

  /// The player's row in a `status` response, with connected time counted from
  /// [startedAt] so the pane ticks over between polls.
  String statusLine(DateTime startedAt) {
    final connected = Duration(
      seconds: DateTime.now().difference(startedAt).inSeconds + joinedSecondsAgo,
    );
    final time = isBot
        ? 'BOT'
        : '${connected.inMinutes.toString().padLeft(2, '0')}:'
              '${(connected.inSeconds % 60).toString().padLeft(2, '0')}';

    return [
      id.toString().padLeft(2),
      time.padRight(5),
      ping.toString().padLeft(4),
      '0'.padLeft(5),
      'active'.padLeft(11),
      (isBot ? '0' : '786432').padLeft(7),
      if (networkAddress.isNotEmpty) networkAddress,
      "'$name'",
    ].join(' ');
  }
}

/// A convar the demo server knows about, so `find` has something to list and
/// the console can read and write it.
class _DemoCvar {
  const _DemoCvar({
    required this.name,
    required this.value,
    required this.flags,
    required this.help,
  });

  final String name;
  final String value;
  final String flags;
  final String help;

  static const _nameWidth = 40;
  static const _valueWidth = 17;
  static const _flagsWidth = 20;

  static String get findHeader => _row('cvar name', 'value', 'flags', 'help text');

  static String get findUnderline =>
      _row('_' * _nameWidth, '_' * _valueWidth, '_' * _flagsWidth, '_' * 9);

  static List<_DemoCvar> get directory {
    return const [
      _DemoCvar(
        name: 'bot_quota',
        value: '3',
        flags: 'rep, release',
        help: 'Determines the total number of bots in the game.',
      ),
      _DemoCvar(
        name: 'mp_autoteambalance',
        value: '1',
        flags: 'rep, release',
        help: 'Toggles server autoteambalance.',
      ),
      _DemoCvar(
        name: 'mp_friendlyfire',
        value: '0',
        flags: 'rep, release',
        help: 'Toggles whether teammates can injure each other.',
      ),
      _DemoCvar(
        name: 'mp_maxrounds',
        value: '24',
        flags: 'rep, release',
        help: 'Maximum number of rounds to play before the match ends.',
      ),
      _DemoCvar(
        name: 'mp_restartgame',
        value: '',
        flags: 'release',
        help: 'Restarts the game in the specified number of seconds.',
      ),
      _DemoCvar(
        name: 'mp_roundtime',
        value: '1.92',
        flags: 'rep, release',
        help: 'How many minutes each round takes.',
      ),
      _DemoCvar(
        name: 'mp_timelimit',
        value: '0',
        flags: 'rep, release',
        help: 'Game time per map in minutes.',
      ),
      _DemoCvar(
        name: 'mp_warmuptime',
        value: '60',
        flags: 'rep, release',
        help: 'Duration of the warmup period, in seconds.',
      ),
      _DemoCvar(
        name: 'sv_cheats',
        value: '0',
        flags: 'rep, notify, release',
        help: 'Allow cheat commands on this server.',
      ),
      _DemoCvar(name: 'sv_gravity', value: '800', flags: 'rep, release', help: 'World gravity.'),
      _DemoCvar(
        name: 'sv_password',
        value: '',
        flags: 'protected, release',
        help: 'Server password for entry into multiplayer games.',
      ),
      _DemoCvar(
        name: 'sv_visiblemaxplayers',
        value: '-1',
        flags: 'release',
        help: 'Overrides the max players reported to prospective clients.',
      ),
    ];
  }

  /// This convar as a row under [findHeader], with the help text starting at
  /// the same column the header puts it in.
  String findRow(String currentValue) {
    return _row(name, '"$currentValue"', flags, help);
  }

  static String _row(String name, String value, String flags, String help) {
    return '${name.padRight(_nameWidth)} '
        '${value.padRight(_valueWidth)} '
        '${flags.padRight(_flagsWidth)} '
        '$help';
  }
}
