import 'package:arkie_mobile/app.dart';
import 'package:cs2_rcon_front_end/di/graph.dart';
import 'package:cs2_rcon_front_end/environment.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/connection_cache.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/models/message.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/models/saved_message.dart';
import 'package:cs2_rcon_front_end/features/servers/data/api/servers_api.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:cs2_rcon_front_end/features/servers/data/repository/servers_repository.dart';
import 'package:cs2_rcon_front_end/features/settings/data/repository/settings_repository.dart';
import 'package:cs2_rcon_front_end/hive/hive_registrar.g.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart' hide Storage;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapters();

  await setUpGraph(
    environment: Environment.fromEnvironment(),
    serversRepository: () => ServersRepository(api: ServersApi.create()),
    settingsRepository: () => SettingsRepository(prefs: RxSharedPreferences.getInstance()),
    connectionCache: ConnectionCache.new,
    messagesBox: Hive.openBox<Message>('messages'),
    serversBox: Hive.openBox<Server>('servers'),
    savedMessagesBox: Hive.openBox<SavedMessage>('saved_messages'),
    packageInfo: PackageInfo.fromPlatform(),
  );

  runApp(const MobileApp());
}
