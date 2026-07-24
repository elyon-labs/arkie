import 'dart:typed_data';

import 'package:cs2_rcon_front_end/core/async.dart';
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
import 'package:cs2_rcon_front_end/features/servers/presentation/add_server_dialog/add_server_dialog_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxidized/oxidized.dart';

import '../../../../fakes/fake_get_socket.dart';
import '../../../../fakes/fake_managed_private_key_store.dart';
import '../../../../fakes/fake_servers_api.dart';
import '../../../../fakes/fake_settings_repository.dart';

void main() {
  test('selects, cancels, reports errors, and replaces without losing the prior key', () async {
    final first = _selected('first-key', [1, 2, 3]);
    final replacement = _selected('replacement-key', [4, 5, 6]);
    final selector = _QueueSelectSshPrivateKey([
      Ok(first),
      const Ok(null),
      const Err(PrivateKeySelectionException('Invalid private key.')),
      Ok(replacement),
    ]);
    final harness = await _Harness.create(selector);
    addTearDown(harness.dispose);
    final cubit = harness.cubit..setEnableManagement(true);

    await cubit.selectPrivateKey();
    expect(cubit.state.privateKeyDisplayName, 'first-key');
    expect(cubit.state.privateKeySelectionError, isNull);

    await cubit.selectPrivateKey();
    expect(cubit.state.privateKeyDisplayName, 'first-key');

    await cubit.selectPrivateKey();
    expect(cubit.state.privateKeyDisplayName, 'first-key');
    expect(cubit.state.privateKeySelectionError, 'Invalid private key.');
    expect(first.pemBytes, [1, 2, 3]);

    await cubit.selectPrivateKey();
    expect(cubit.state.privateKeyDisplayName, 'replacement-key');
    expect(cubit.state.privateKeySelectionError, isNull);
    expect(first.pemBytes, [0, 0, 0]);
  });

  test('disabling management and closing clear selected key bytes', () async {
    final disabledKey = _selected('disabled-key', [1, 2, 3]);
    final closedKey = _selected('closed-key', [4, 5, 6]);
    final selector = _QueueSelectSshPrivateKey([Ok(disabledKey), Ok(closedKey)]);
    final harness = await _Harness.create(selector);
    addTearDown(harness.disposeDependencies);
    final cubit = harness.cubit..setEnableManagement(true);

    await cubit.selectPrivateKey();
    cubit.setEnableManagement(false);

    expect(disabledKey.pemBytes, [0, 0, 0]);
    expect(cubit.state.privateKeyDisplayName, isNull);

    cubit.setEnableManagement(true);
    await cubit.selectPrivateKey();
    await cubit.close();

    expect(closedKey.pemBytes, [0, 0, 0]);
  });

  test('management cannot be saved without a selected key', () async {
    final harness = await _Harness.create(_QueueSelectSshPrivateKey([]));
    addTearDown(harness.dispose);
    final cubit = harness.cubit;
    _fillValidFields(cubit);

    await cubit.saveServer();

    expect(cubit.state.addServerResult.error.unwrap(), 'Select an SSH private key');
    expect(harness.api.addServerCallCount, 0);
  });

  test('successful save imports the key and clears transient bytes', () async {
    final selected = _selected('id_ed25519', [7, 8, 9]);
    final harness = await _Harness.create(_QueueSelectSshPrivateKey([Ok(selected)]));
    addTearDown(harness.dispose);
    final cubit = harness.cubit;
    _fillValidFields(cubit);
    await cubit.selectPrivateKey();

    await cubit.saveServer();

    expect(cubit.state.addServerResult.isLoaded, isTrue);
    expect(cubit.state.privateKeyDisplayName, isNull);
    expect(selected.pemBytes, [0, 0, 0]);
    expect(harness.api.addServerCallCount, 1);
  });
}

SelectedPrivateKey _selected(String displayName, List<int> bytes) {
  return SelectedPrivateKey(displayName: displayName, pemBytes: Uint8List.fromList(bytes));
}

void _fillValidFields(AddServerDialogCubit cubit) {
  cubit
    ..setName('Managed server')
    ..setAddress('127.0.0.1')
    ..setPort(27015)
    ..setPassword('secret')
    ..setEnableManagement(true)
    ..setSshHost('server.example.com')
    ..setSshPort(22)
    ..setSshUser('arkie-cs2')
    ..setHostKeyFingerprint('fingerprint');
}

class _QueueSelectSshPrivateKey extends SelectSshPrivateKey {
  _QueueSelectSshPrivateKey(this.results) : super(openFile: _unusedOpenFile);

  final List<Result<SelectedPrivateKey?, PrivateKeySelectionException>> results;

  @override
  Future<Result<SelectedPrivateKey?, PrivateKeySelectionException>> call() async {
    return results.removeAt(0);
  }

  static Future<Never> _unusedOpenFile() async {
    throw UnimplementedError();
  }
}

class _Harness {
  _Harness({
    required this.cubit,
    required this.repository,
    required this.settings,
    required this.api,
  });

  static Future<_Harness> create(SelectSshPrivateKey selector) async {
    const reference = ManagedPrivateKeyReference(id: 'managed-id', displayName: 'id_ed25519');
    final store = FakeManagedPrivateKeyStore(onImportKey: (_) async => const Ok(reference));
    final api = FakeServersApi();
    final repository = ServersRepository(api: api);
    await repository.refresh();
    final settings = FakeSettingsRepository();
    final cache = ConnectionCache();
    final connect = Connect(
      getSocket: FakeGetSocket(),
      removeSocket: DropConnection(connectionCache: cache),
      addSocket: SaveConnection(connectionCache: cache),
    );
    final addServer = AddServer(
      serversRepository: repository,
      settingsRepository: settings,
      importSshPrivateKey: ImportSshPrivateKey(store: store),
      deleteManagedPrivateKey: DeleteManagedPrivateKey(store: store),
    );
    return _Harness(
      cubit: AddServerDialogCubit(
        addServer: addServer,
        connect: connect,
        selectSshPrivateKey: selector,
      ),
      repository: repository,
      settings: settings,
      api: api,
    );
  }

  final AddServerDialogCubit cubit;
  final ServersRepository repository;
  final FakeSettingsRepository settings;
  final FakeServersApi api;

  Future<void> dispose() async {
    await cubit.close();
    await disposeDependencies();
  }

  Future<void> disposeDependencies() async {
    await repository.dispose();
    await settings.dispose();
  }
}
