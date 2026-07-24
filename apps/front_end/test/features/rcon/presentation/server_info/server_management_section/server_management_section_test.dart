import 'dart:async';

import 'package:cs2_rcon_front_end/core_ui/app_theme.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/server_management_section/server_management_cubit.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/server_management_section/server_management_section.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/managed_private_key_reference.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/restart_server.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/start_server.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/stop_server.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/watch_server_logs.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server_management_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxidized/oxidized.dart';

import '../../../../../fakes/fake_read_managed_private_key.dart';
import '../../../../../fakes/fake_server_management_api.dart';

void main() {
  testWidgets('renders cubit state and delegates log toggling', (tester) async {
    final cancelCompleter = Completer<void>();
    final logController = StreamController<Result<String, Exception>>(
      onCancel: () => cancelCompleter.future,
    );
    final api = FakeServerManagementApi(streamLogsResult: logController.stream);
    const config = ServerManagementConfig(
      backend: ServerManagementBackend.systemd,
      sshHost: '127.0.0.1',
      sshPort: 22,
      sshUser: 'arkie-cs2',
      privateKey: ManagedPrivateKeyReference(id: 'key-id', displayName: 'id_ed25519'),
      hostKeyFingerprint: 'fingerprint',
    );
    final cubit = ServerManagementCubit(
      config: config,
      startServer: StartServer(api: api, readManagedPrivateKey: fakeReadManagedPrivateKey()),
      stopServer: StopServer(api: api, readManagedPrivateKey: fakeReadManagedPrivateKey()),
      restartServer: RestartServer(api: api, readManagedPrivateKey: fakeReadManagedPrivateKey()),
      watchServerLogs: WatchServerLogs(
        api: api,
        readManagedPrivateKey: fakeReadManagedPrivateKey(),
      ),
    );
    addTearDown(() async {
      if (!cancelCompleter.isCompleted) {
        cancelCompleter.complete();
      }
      await logController.close();
      await cubit.close();
    });
    final server = Server.create(
      name: 'Test server',
      address: '127.0.0.1',
      port: 27015,
      password: 'password',
      managementConfig: config,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: buildDarkTheme(),
        home: Scaffold(
          body: ServerManagementSection(server: server, cubit: cubit),
        ),
      ),
    );

    expect(find.text('Start'), findsNothing);
    expect(find.text('Stop'), findsNothing);
    final sectionWidth = tester.getSize(find.byType(ServerManagementSection)).width;
    for (final label in ['Restart', 'Stream logs']) {
      expect(tester.getSize(find.widgetWithText(ElevatedButton, label)).width, sectionWidth);
    }

    await tester.tap(find.text('Stream logs'));
    await tester.pump();
    logController.add(const Result.ok('server log'));
    await tester.pump();

    expect(find.text('Streaming logs...'), findsOneWidget);
    expect(find.text('server log'), findsOneWidget);
    expect(find.text('Stop logs'), findsOneWidget);

    await tester.tap(find.text('Stop logs'));
    await tester.pump();

    expect(find.text('Streaming logs...'), findsNothing);
    expect(find.text('server log'), findsNothing);
    expect(find.text('Stream logs'), findsOneWidget);
  });
}
