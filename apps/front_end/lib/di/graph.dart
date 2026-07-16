import 'package:cs2_rcon_front_end/environment.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/connection_cache.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/models/message.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/models/saved_message.dart';
import 'package:cs2_rcon_front_end/features/server_management/data/managed_private_key_store.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:cs2_rcon_front_end/features/servers/data/repository/servers_repository.dart';
import 'package:cs2_rcon_front_end/features/settings/data/repository/settings_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

GetIt _graph = GetIt.instance;

T inject<T extends Object>([String? instanceName]) => _graph.get<T>(instanceName: instanceName);

typedef LazyBuilder<T> = T Function();

Future<void> setUpGraph({
  required Environment environment,
  required LazyBuilder<ServersRepository> serversRepository,
  required LazyBuilder<SettingsRepository> settingsRepository,
  required LazyBuilder<ConnectionCache> connectionCache,
  required LazyBuilder<ManagedPrivateKeyStore> managedPrivateKeyStore,
  required Future<Box<Message>> messagesBox,
  required Future<Box<SavedMessage>> savedMessagesBox,
  required Future<Box<Server>> serversBox,
  required Future<PackageInfo> packageInfo,
}) async {
  _graph
    ..registerSingleton(environment)
    ..registerLazySingleton(serversRepository, dispose: (db) => db.dispose())
    ..registerLazySingleton(settingsRepository, dispose: (db) => db.dispose())
    ..registerLazySingleton(connectionCache)
    ..registerLazySingleton(managedPrivateKeyStore)
    ..registerSingletonAsync(() async => await messagesBox)
    ..registerSingletonAsync(() async => await savedMessagesBox)
    ..registerSingletonAsync(() async => await serversBox)
    ..registerSingletonAsync(() async => await packageInfo);
  await _graph.allReady();
}
