import 'package:cs2_rcon_front_end/app/presentation/app_cubit.dart';
import 'package:cs2_rcon_front_end/app/presentation/app_state.dart';
import 'package:cs2_rcon_front_end/core_ui/app_theme.dart';
import 'package:cs2_rcon_front_end/di/graph.dart';
import 'package:cs2_rcon_front_end/environment.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/connection_cache.dart';
import 'package:cs2_rcon_front_end/features/servers/data/api/servers_api.dart';
import 'package:cs2_rcon_front_end/features/servers/data/repository/servers_repository.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/servers/servers.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/servers/widgets/server_shortcuts.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/servers_cubit.dart';
import 'package:cs2_rcon_front_end/features/settings/data/repository/settings_repository.dart';
import 'package:cs2_rcon_front_end/hive/hive_registrar.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart' hide Storage;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapters();

  await setUpGraph(
    environment: Environment.fromEnvironment(),
    serversRepository: () => ServersRepository(api: ServersApi.create()),
    settingsRepository: () => SettingsRepository(prefs: RxSharedPreferences.getInstance()),
    connectionCache: ConnectionCache.new,
    messagesBox: Hive.openBox('messages'),
    serversBox: Hive.openBox('servers'),
    savedMessagesBox: Hive.openBox('saved_messages'),
    packageInfo: PackageInfo.fromPlatform(),
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AppCubit.create()),
        BlocProvider(create: (_) => ServersCubit.create()),
      ],
      child: BlocBuilder<AppCubit, AppState>(
        builder: (context, state) {
          return Builder(
            builder: (context) {
              return MaterialApp(
                themeMode: state.themeMode,
                debugShowCheckedModeBanner: false,
                theme: buildLightTheme(),
                darkTheme: buildDarkTheme(),
                builder: (context, child) =>
                    ServerShortcuts(child: child ?? const SizedBox.shrink()),
                home: const Servers(),
              );
            },
          );
        },
      ),
    );
  }
}
