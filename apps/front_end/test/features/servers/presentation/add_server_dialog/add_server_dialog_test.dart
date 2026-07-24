import 'dart:async';
import 'dart:typed_data';

import 'package:cs2_rcon_front_end/core_ui/app_theme.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/connection_cache.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/connect.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/drop_connection.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/save_connection.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/delete_managed_private_key.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/import_ssh_private_key.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/managed_private_key_reference.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/selected_private_key.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/select_ssh_private_key.dart';
import 'package:cs2_rcon_front_end/features/servers/data/repository/servers_repository.dart';
import 'package:cs2_rcon_front_end/features/servers/domain/add_server.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/add_server_dialog/add_server_dialog.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/add_server_dialog/add_server_dialog_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxidized/oxidized.dart';

import '../../../../fakes/fake_get_socket.dart';
import '../../../../fakes/fake_managed_private_key_store.dart';
import '../../../../fakes/fake_servers_api.dart';
import '../../../../fakes/fake_settings_repository.dart';

void main() {
  testWidgets('renders only the key name and disables controls while selecting', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final selection = Completer<Result<SelectedPrivateKey?, PrivateKeySelectionException>>();
    final selector = _PendingSelectSshPrivateKey(selection.future);
    final harness = await _Harness.create(selector);
    addTearDown(harness.dispose);
    harness.cubit.setEnableManagement(true);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildDarkTheme(),
        home: Scaffold(
          body: AddServerForm(cubit: harness.cubit, onServerAdded: (_) {}, onCancel: () {}),
        ),
      ),
    );

    expect(find.text('No private key selected'), findsOneWidget);
    await tester.tap(find.byKey(const Key('select-private-key-button')));
    await tester.pump();

    expect(find.text('Selecting...'), findsOneWidget);
    expect(
      tester.widgetList<TextField>(find.byType(TextField)).every((field) => field.enabled == false),
      isTrue,
    );
    expect(
      tester.widget<OutlinedButton>(find.byKey(const Key('select-private-key-button'))).onPressed,
      isNull,
    );

    selection.complete(
      Result.ok(
        SelectedPrivateKey(displayName: 'id_ed25519', pemBytes: Uint8List.fromList([1, 2, 3])),
      ),
    );
    await tester.pump();

    expect(find.text('id_ed25519'), findsOneWidget);
    expect(find.text('Replace'), findsOneWidget);
    expect(find.textContaining('/'), findsNothing);
  });
}

class _PendingSelectSshPrivateKey extends SelectSshPrivateKey {
  _PendingSelectSshPrivateKey(this.result) : super(openFile: _unusedOpenFile);

  final Future<Result<SelectedPrivateKey?, PrivateKeySelectionException>> result;

  @override
  Future<Result<SelectedPrivateKey?, PrivateKeySelectionException>> call() => result;

  static Future<Never> _unusedOpenFile() async {
    throw UnimplementedError();
  }
}

class _Harness {
  _Harness({required this.cubit, required this.repository, required this.settings});

  static Future<_Harness> create(SelectSshPrivateKey selector) async {
    final store = FakeManagedPrivateKeyStore(
      onImportKey: (_) async =>
          const Ok(ManagedPrivateKeyReference(id: 'managed-id', displayName: 'id_ed25519')),
    );
    final api = FakeServersApi();
    final repository = ServersRepository(api: api);
    await repository.refresh();
    final settings = FakeSettingsRepository();
    final cache = ConnectionCache();
    final addServer = AddServer(
      serversRepository: repository,
      settingsRepository: settings,
      importSshPrivateKey: ImportSshPrivateKey(store: store),
      deleteManagedPrivateKey: DeleteManagedPrivateKey(store: store),
    );
    return _Harness(
      cubit: AddServerDialogCubit(
        addServer: addServer,
        connect: Connect(
          getSocket: FakeGetSocket(),
          removeSocket: DropConnection(connectionCache: cache),
          addSocket: SaveConnection(connectionCache: cache),
        ),
        selectSshPrivateKey: selector,
      ),
      repository: repository,
      settings: settings,
    );
  }

  final AddServerDialogCubit cubit;
  final ServersRepository repository;
  final FakeSettingsRepository settings;

  Future<void> dispose() async {
    await cubit.close();
    await repository.dispose();
    await settings.dispose();
  }
}
