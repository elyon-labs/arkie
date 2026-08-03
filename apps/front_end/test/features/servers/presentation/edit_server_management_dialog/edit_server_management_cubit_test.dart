import 'dart:async';
import 'dart:typed_data';

import 'package:cs2_rcon_front_end/features/server_management/data/managed_private_key_store.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/delete_managed_private_key.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/import_ssh_private_key.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/managed_private_key_reference.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/selected_private_key.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/select_ssh_private_key.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server_management_config.dart';
import 'package:cs2_rcon_front_end/features/servers/data/repository/servers_repository.dart';
import 'package:cs2_rcon_front_end/features/servers/domain/update_server_management_config.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/edit_server_management_dialog/edit_server_management_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxidized/oxidized.dart';

import '../../../../fakes/fake_managed_private_key_store.dart';
import '../../../../fakes/fake_servers_api.dart';

void main() {
  const existingReference = ManagedPrivateKeyReference(
    id: 'existing-id',
    displayName: 'existing-key',
  );
  const replacementReference = ManagedPrivateKeyReference(
    id: 'replacement-id',
    displayName: 'replacement-key',
  );

  test('initializes from configured server management values', () async {
    final server = _managedServer(existingReference);
    final harness = await _Harness.create(server: server);
    addTearDown(harness.dispose);

    final state = harness.cubit.state;

    expect(state.enabled, isTrue);
    expect(state.sshHost, 'old.example.com');
    expect(state.sshPort, 2222);
    expect(state.sshUser, 'old-user');
    expect(state.hostKeyFingerprint, 'SHA256:old');
    expect(state.privateKeyDisplayName, existingReference.displayName);
  });

  test('initializes unconfigured management with defaults', () async {
    final server = _server();
    final harness = await _Harness.create(server: server);
    addTearDown(harness.dispose);

    final state = harness.cubit.state;

    expect(state.enabled, isFalse);
    expect(state.sshHost, server.address);
    expect(state.sshPort, 22);
    expect(state.sshUser, 'arkie-cs2');
    expect(state.hostKeyFingerprint, isEmpty);
    expect(state.privateKeyDisplayName, isNull);
  });

  test('selects, cancels, reports errors, and replaces the transient key', () async {
    final first = _selected('first-key', [1, 2, 3]);
    final replacement = _selected('replacement-key', [4, 5, 6]);
    final selector = _QueueSelectSshPrivateKey([
      Ok(first),
      const Ok(null),
      const Err(PrivateKeySelectionException('Invalid private key.')),
      Ok(replacement),
    ]);
    final harness = await _Harness.create(server: _server(), selector: selector);
    addTearDown(harness.dispose);
    harness.cubit.setEnabled(true);

    await harness.cubit.selectPrivateKey();
    expect(harness.cubit.state.privateKeyDisplayName, first.displayName);

    await harness.cubit.selectPrivateKey();
    expect(harness.cubit.state.privateKeyDisplayName, first.displayName);

    await harness.cubit.selectPrivateKey();
    expect(harness.cubit.state.privateKeyDisplayName, first.displayName);
    expect(harness.cubit.state.error, 'Invalid private key.');
    expect(first.pemBytes, [1, 2, 3]);

    await harness.cubit.selectPrivateKey();
    expect(harness.cubit.state.privateKeyDisplayName, replacement.displayName);
    expect(harness.cubit.state.error, isNull);
    expect(first.pemBytes, [0, 0, 0]);
  });

  test('disabling restores the existing key label and clears replacement bytes', () async {
    final replacement = _selected('replacement-key', [1, 2, 3]);
    final harness = await _Harness.create(
      server: _managedServer(existingReference),
      selector: _QueueSelectSshPrivateKey([Ok(replacement)]),
    );
    addTearDown(harness.dispose);

    await harness.cubit.selectPrivateKey();
    harness.cubit.setEnabled(false);

    expect(replacement.pemBytes, [0, 0, 0]);
    expect(harness.cubit.state.privateKeyDisplayName, existingReference.displayName);
  });

  test('closing clears transient selected-key bytes', () async {
    final selected = _selected('replacement-key', [1, 2, 3]);
    final harness = await _Harness.create(
      server: _server(),
      selector: _QueueSelectSshPrivateKey([Ok(selected)]),
    );
    addTearDown(harness.disposeDependencies);
    harness.cubit.setEnabled(true);
    await harness.cubit.selectPrivateKey();

    await harness.cubit.close();

    expect(selected.pemBytes, [0, 0, 0]);
  });

  test('validates enabled management fields before updating', () async {
    final cases = <String, void Function(EditServerManagementCubit)>{
      'SSH host cannot be empty.': (cubit) => cubit.setSshHost(' '),
      'SSH port must be between 1 and 65535.': (cubit) => cubit.setSshPort(0),
      'SSH user cannot be empty.': (cubit) => cubit.setSshUser(' '),
      'Host key fingerprint cannot be empty.': (cubit) => cubit.setHostKeyFingerprint(' '),
    };

    for (final MapEntry(key: expected, value: invalidate) in cases.entries) {
      final harness = await _Harness.create(server: _managedServer(existingReference));
      addTearDown(harness.dispose);
      invalidate(harness.cubit);

      await harness.cubit.save();

      expect(harness.cubit.state.error, expected);
      expect(harness.api.updateServerCallCount, 0);
    }
  });

  test('requires a key before enabling unconfigured management', () async {
    final harness = await _Harness.create(server: _server());
    addTearDown(harness.dispose);
    _fillEnabledFields(harness.cubit);

    await harness.cubit.save();

    expect(harness.cubit.state.error, 'Select an SSH private key.');
    expect(harness.api.updateServerCallCount, 0);
  });

  test('saves trimmed SSH fields while retaining the existing key', () async {
    final server = _managedServer(existingReference);
    final harness = await _Harness.create(server: server);
    addTearDown(harness.dispose);
    harness.cubit
      ..setSshHost(' new.example.com ')
      ..setSshPort(22)
      ..setSshUser(' new-user ')
      ..setHostKeyFingerprint(' SHA256:new ');

    await harness.cubit.save();

    expect(harness.cubit.state.saved, isTrue);
    expect(harness.cubit.state.error, isNull);
    final saved = (await harness.api.fetchServers()).single.managementConfig!;
    expect(saved.sshHost, 'new.example.com');
    expect(saved.sshUser, 'new-user');
    expect(saved.hostKeyFingerprint, 'SHA256:new');
    expect(saved.privateKey, existingReference);
  });

  test('saves a replacement, exposes cleanup warning, and clears selected bytes', () async {
    final selected = _selected('replacement-key', [1, 2, 3]);
    final store = FakeManagedPrivateKeyStore(
      onImportKey: (_) async => const Ok(replacementReference),
      onDeleteKey: (_) async => const Err(ManagedPrivateKeyStorageException('cleanup failed')),
    );
    final harness = await _Harness.create(
      server: _managedServer(existingReference),
      selector: _QueueSelectSshPrivateKey([Ok(selected)]),
      store: store,
    );
    addTearDown(harness.dispose);
    await harness.cubit.selectPrivateKey();

    await harness.cubit.save();

    expect(harness.cubit.state.saved, isTrue);
    expect(harness.cubit.state.cleanupWarning, contains('could not remove the old private key'));
    expect(selected.pemBytes, [0, 0, 0]);
    final saved = (await harness.api.fetchServers()).single;
    expect(saved.managementConfig?.privateKey, replacementReference);
  });

  test('saves disabled management without requiring enabled-field validation', () async {
    final server = _managedServer(existingReference);
    final harness = await _Harness.create(server: server);
    addTearDown(harness.dispose);
    harness.cubit
      ..setEnabled(false)
      ..setSshHost('')
      ..setSshPort(0)
      ..setSshUser('')
      ..setHostKeyFingerprint('');

    await harness.cubit.save();

    expect(harness.cubit.state.saved, isTrue);
    expect((await harness.api.fetchServers()).single.managementConfig, isNull);
  });

  test('keeps the dialog state open with an actionable update error', () async {
    final server = _managedServer(existingReference);
    final harness = await _Harness.create(server: server);
    harness.api.updateServerResult = Err(Exception('persistence failed'));
    addTearDown(harness.dispose);

    await harness.cubit.save();

    expect(harness.cubit.state.saved, isFalse);
    expect(harness.cubit.state.isSaving, isFalse);
    expect(harness.cubit.state.error, 'Exception: persistence failed');
  });

  test('guards selection and saving while key selection is in progress', () async {
    final selection = Completer<Result<SelectedPrivateKey?, PrivateKeySelectionException>>();
    final selector = _CompleterSelectSshPrivateKey(selection);
    final harness = await _Harness.create(
      server: _managedServer(existingReference),
      selector: selector,
    );
    addTearDown(harness.dispose);

    final selectionFuture = harness.cubit.selectPrivateKey();
    expect(harness.cubit.state.isSelectingPrivateKey, isTrue);

    await harness.cubit.save();
    unawaited(harness.cubit.selectPrivateKey());

    expect(harness.api.updateServerCallCount, 0);
    expect(selector.callCount, 1);

    selection.complete(const Ok(null));
    await selectionFuture;
  });
}

Server _server() {
  return Server.create(name: 'Server', address: '127.0.0.1', port: 27015, password: 'password');
}

Server _managedServer(ManagedPrivateKeyReference reference) {
  return _server().copyWith(
    managementConfig: ServerManagementConfig(
      backend: ServerManagementBackend.systemd,
      sshHost: 'old.example.com',
      sshPort: 2222,
      sshUser: 'old-user',
      privateKey: reference,
      hostKeyFingerprint: 'SHA256:old',
    ),
  );
}

SelectedPrivateKey _selected(String displayName, List<int> bytes) {
  return SelectedPrivateKey(displayName: displayName, pemBytes: Uint8List.fromList(bytes));
}

void _fillEnabledFields(EditServerManagementCubit cubit) {
  cubit
    ..setEnabled(true)
    ..setSshHost('server.example.com')
    ..setSshPort(22)
    ..setSshUser('arkie-cs2')
    ..setHostKeyFingerprint('SHA256:test');
}

class _QueueSelectSshPrivateKey extends SelectSshPrivateKey {
  _QueueSelectSshPrivateKey(this.results) : super(openFile: _unusedOpenFile);

  final List<Result<SelectedPrivateKey?, PrivateKeySelectionException>> results;

  @override
  Future<Result<SelectedPrivateKey?, PrivateKeySelectionException>> call() async {
    return results.removeAt(0);
  }
}

class _CompleterSelectSshPrivateKey extends SelectSshPrivateKey {
  _CompleterSelectSshPrivateKey(this.completer) : super(openFile: _unusedOpenFile);

  final Completer<Result<SelectedPrivateKey?, PrivateKeySelectionException>> completer;
  int callCount = 0;

  @override
  Future<Result<SelectedPrivateKey?, PrivateKeySelectionException>> call() {
    callCount++;
    return completer.future;
  }
}

Future<Never> _unusedOpenFile() async {
  throw UnimplementedError();
}

class _Harness {
  const _Harness({required this.cubit, required this.repository, required this.api});

  static Future<_Harness> create({
    required Server server,
    SelectSshPrivateKey? selector,
    FakeManagedPrivateKeyStore? store,
  }) async {
    final keyStore = store ?? FakeManagedPrivateKeyStore();
    final api = FakeServersApi(initialServers: [server]);
    final repository = ServersRepository(api: api);
    await repository.refresh();
    final update = UpdateServerManagementConfig(
      serversRepository: repository,
      importSshPrivateKey: ImportSshPrivateKey(store: keyStore),
      deleteManagedPrivateKey: DeleteManagedPrivateKey(store: keyStore),
    );
    return _Harness(
      cubit: EditServerManagementCubit(
        server: server,
        updateServerManagementConfig: update,
        selectSshPrivateKey: selector ?? _QueueSelectSshPrivateKey([]),
      ),
      repository: repository,
      api: api,
    );
  }

  final EditServerManagementCubit cubit;
  final ServersRepository repository;
  final FakeServersApi api;

  Future<void> dispose() async {
    await cubit.close();
    await disposeDependencies();
  }

  Future<void> disposeDependencies() => repository.dispose();
}
