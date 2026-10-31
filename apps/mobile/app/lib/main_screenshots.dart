/// The entry point the App Store screenshots are taken from.
///
/// It is the real app — the same pages, cubits and theme — started on a canned
/// store instead of whatever the simulator happened to be holding. Every scene
/// wipes Hive first, writes its fixture, and then opens the page the screenshot
/// wants, so a capture is the same whichever order the scenes run in.
///
/// The scene comes in as a `--dart-define`, so changing it means building
/// again rather than poking at a running app. That is slower and completely
/// deterministic. `tool/capture_screenshots.dart` drives it.
///
/// The server it talks to is the in-app demo server, so the console, the map
/// list and the roster in the screenshots are answers a real CS2 server would
/// have given to the same commands.
library;

import 'package:arkie_core/di/graph.dart';
import 'package:arkie_core/environment.dart';
import 'package:arkie_core/features/rcon/data/connection_cache.dart';
import 'package:arkie_core/features/rcon/data/models/message.dart';
import 'package:arkie_core/features/rcon/data/models/saved_message.dart';
import 'package:arkie_core/features/rcon/demo/demo_connections.dart';
import 'package:arkie_core/features/rcon/demo/demo_rcon_server.dart';
import 'package:arkie_core/features/servers/data/api/servers_api.dart';
import 'package:arkie_core/features/servers/data/models/server.dart';
import 'package:arkie_core/features/servers/data/repository/servers_repository.dart';
import 'package:arkie_core/features/settings/data/repository/settings_repository.dart';
import 'package:arkie_core/hive/hive_registrar.g.dart';
import 'package:arkie_mobile/app.dart';
import 'package:arkie_mobile/features/rcon/presentation/server_chat_page.dart';
import 'package:arkie_mobile/features/rcon/presentation/server_tools/server_tools_sheet.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart' hide Storage;

/// One App Store screenshot: which page opens, over which fixture.
enum Scene {
  console,
  maps,
  players,
  saved,
  servers;

  static Scene fromEnvironment() {
    // ignore: do_not_use_environment
    const name = String.fromEnvironment('ARKIE_SCREENSHOT_SCENE');
    return Scene.values.firstWhere(
      (scene) => scene.name == name,
      orElse: () => throw StateError('ARKIE_SCREENSHOT_SCENE is "$name"; expected one of $values'),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final scene = Scene.fromEnvironment();

  await Hive.initFlutter();
  Hive.registerAdapters();

  for (final name in ['messages', 'servers', 'saved_messages']) {
    await Hive.deleteBoxFromDisk(name);
  }

  final messages = await Hive.openBox<Message>('messages');
  final servers = await Hive.openBox<Server>('servers');
  final savedMessages = await Hive.openBox<SavedMessage>('saved_messages');

  final demo = await _writeFixture(
    servers: servers,
    messages: messages,
    savedMessages: savedMessages,
  );

  await setUpGraph(
    environment: Environment.fromEnvironment(),
    serversRepository: () => ServersRepository(api: ServersApi.create()),
    settingsRepository: () => SettingsRepository(prefs: RxSharedPreferences.getInstance()),
    connectionCache: ConnectionCache.new,
    demoConnections: DemoConnections.new,
    messagesBox: Future.value(messages),
    serversBox: Future.value(servers),
    savedMessagesBox: Future.value(savedMessages),
    packageInfo: PackageInfo.fromPlatform(),
  );

  runApp(MobileApp(home: _home(scene, demo)));
}

Widget? _home(Scene scene, Server demo) {
  return switch (scene) {
    Scene.servers => null,
    Scene.console => ServerChatPage(server: demo),
    Scene.saved => ServerChatPage(server: demo, initialTool: ServerTool.saved),
    Scene.maps => ServerChatPage(server: demo, initialTool: ServerTool.maps),
    Scene.players => ServerChatPage(server: demo, initialTool: ServerTool.players),
  };
}

/// The servers the list shows, borrowed from the ranges reserved for
/// documentation so no screenshot ever points at a host somebody runs.
const _savedServers = [
  ('Larry’s Server', '198.51.100.24', 27015),
  ('Scrim box', '192.0.2.44', 27015),
  ('Retake 128t', '198.51.100.9', 27016),
];

/// The console transcript, newest last. Each command is run against a
/// [DemoRCONServer] so the reply beneath it is the one the app would have
/// printed rather than prose written to look like it.
const _transcript = ['say Knife round, then live', 'mp_friendlyfire 1', 'status'];

/// The commands worth a button, as the saved pane lists them.
const _saved = [
  ('warmup', 'mp_warmuptime 10'),
  ('restart', 'mp_restartgame 1'),
  ('no bots', 'bot_quota 0'),
  ('live', 'say Knife round, then live'),
];

/// Writes every scene's fixture and returns the demo server the console pages
/// open on.
Future<Server> _writeFixture({
  required Box<Server> servers,
  required Box<Message> messages,
  required Box<SavedMessage> savedMessages,
}) async {
  for (final (name, address, port) in _savedServers) {
    final server = Server.create(name: name, address: address, port: port, password: 'rcon');
    await servers.put(server.id, server);
  }

  final demo = Server.demo();
  await servers.put(demo.id, demo);

  final console = DemoRCONServer(address: demo.address, port: demo.port);
  var sortKey = 0;

  Future<void> write(String body, Sender sender) async {
    final message = Message(
      id: '${demo.id}-${sortKey.toString().padLeft(2, '0')}',
      body: body,
      sender: sender,
      serverId: demo.id,
      sortKey: sortKey++,
    );
    await messages.put(message.id, message);
  }

  for (final command in _transcript) {
    await write(command, Sender.client);
    await write(console.execute(command), Sender.server);
  }

  for (final (name, body) in _saved) {
    final saved = SavedMessage(id: '${demo.id}-$name', serverId: demo.id, body: body, name: name);
    await savedMessages.put(saved.id, saved);
  }

  return demo;
}
