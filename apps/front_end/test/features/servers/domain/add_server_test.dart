import 'dart:typed_data';

import 'package:cs2_rcon_front_end/features/server_management/data/managed_private_key_store.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/delete_managed_private_key.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/import_ssh_private_key.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/managed_private_key_reference.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/selected_private_key.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server_management_config.dart';
import 'package:cs2_rcon_front_end/features/servers/data/repository/servers_repository.dart';
import 'package:cs2_rcon_front_end/features/servers/domain/add_server.dart';
import 'package:cs2_rcon_front_end/features/servers/domain/models/server_management_draft.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxidized/oxidized.dart';

import '../../../fakes/fake_managed_private_key_store.dart';
import '../../../fakes/fake_servers_api.dart';
import '../../../fakes/fake_settings_repository.dart';

void main() {
  const reference = ManagedPrivateKeyReference(id: 'managed-id', displayName: 'id_ed25519');

  test('imports and persists a managed key reference without deleting it', () async {
    var importCalls = 0;
    var deleteCalls = 0;
    final store = FakeManagedPrivateKeyStore(
      onImportKey: (_) async {
        importCalls++;
        return const Ok(reference);
      },
      onDeleteKey: (_) async {
        deleteCalls++;
        return const Ok(null);
      },
    );
    final harness = await _Harness.create(store: store);
    addTearDown(harness.dispose);

    final result = await harness.subject(
      name: 'Managed server',
      address: '127.0.0.1',
      port: 27015,
      password: 'secret',
      managementDraft: _draft(),
    );

    expect(result.unwrap().managementConfig?.privateKey, reference);
    expect(importCalls, 1);
    expect(deleteCalls, 0);
    expect(harness.api.addServerCallCount, 1);
  });

  test('does not persist when managed-key import fails', () async {
    final store = FakeManagedPrivateKeyStore(
      onImportKey: (_) async => const Err(
        ManagedPrivateKeyStorageException('Arkie could not import the selected private key.'),
      ),
    );
    final harness = await _Harness.create(store: store);
    addTearDown(harness.dispose);

    final result = await harness.subject(
      name: 'Managed server',
      address: '127.0.0.1',
      port: 27015,
      password: 'secret',
      managementDraft: _draft(),
    );

    expect(result.isErr(), isTrue);
    expect(harness.api.addServerCallCount, 0);
  });

  test('deletes the imported key when server persistence fails', () async {
    String? deletedId;
    final store = FakeManagedPrivateKeyStore(
      onImportKey: (_) async => const Ok(reference),
      onDeleteKey: (id) async {
        deletedId = id;
        return const Ok(null);
      },
    );
    final persistenceError = Exception('persistence failed');
    final harness = await _Harness.create(store: store);
    harness.api.addServerResult = Err(persistenceError);
    addTearDown(harness.dispose);

    final result = await harness.subject(
      name: 'Managed server',
      address: '127.0.0.1',
      port: 27015,
      password: 'secret',
      managementDraft: _draft(),
    );

    expect(result.unwrapErr(), same(persistenceError));
    expect(deletedId, reference.id);
  });

  test('cleanup failure does not replace the persistence error', () async {
    final store = FakeManagedPrivateKeyStore(
      onImportKey: (_) async => const Ok(reference),
      onDeleteKey: (_) async => const Err(
        ManagedPrivateKeyStorageException('Arkie could not delete the managed private key.'),
      ),
    );
    final persistenceError = Exception('persistence failed');
    final harness = await _Harness.create(store: store);
    harness.api.addServerResult = Err(persistenceError);
    addTearDown(harness.dispose);

    final result = await harness.subject(
      name: 'Managed server',
      address: '127.0.0.1',
      port: 27015,
      password: 'secret',
      managementDraft: _draft(),
    );

    expect(result.unwrapErr(), same(persistenceError));
  });

  test('management-disabled save does not import a key', () async {
    var importCalls = 0;
    final store = FakeManagedPrivateKeyStore(
      onImportKey: (_) async {
        importCalls++;
        return const Ok(reference);
      },
    );
    final harness = await _Harness.create(store: store);
    addTearDown(harness.dispose);

    final result = await harness.subject(
      name: 'RCON-only server',
      address: '127.0.0.1',
      port: 27015,
      password: 'secret',
    );

    expect(result.unwrap().managementConfig, isNull);
    expect(importCalls, 0);
    expect(harness.api.addServerCallCount, 1);
  });
}

ServerManagementDraft _draft() {
  return ServerManagementDraft(
    backend: ServerManagementBackend.systemd,
    sshHost: 'server.example.com',
    sshPort: 22,
    sshUser: 'arkie-cs2',
    selectedPrivateKey: SelectedPrivateKey(
      displayName: 'id_ed25519',
      pemBytes: Uint8List.fromList([1, 2, 3]),
    ),
    hostKeyFingerprint: 'fingerprint',
  );
}

class _Harness {
  _Harness({
    required this.subject,
    required this.repository,
    required this.settings,
    required this.api,
  });

  static Future<_Harness> create({required FakeManagedPrivateKeyStore store}) async {
    final api = FakeServersApi();
    final repository = ServersRepository(api: api);
    await repository.refresh();
    final settings = FakeSettingsRepository();
    return _Harness(
      subject: AddServer(
        serversRepository: repository,
        settingsRepository: settings,
        importSshPrivateKey: ImportSshPrivateKey(store: store),
        deleteManagedPrivateKey: DeleteManagedPrivateKey(store: store),
      ),
      repository: repository,
      settings: settings,
      api: api,
    );
  }

  final AddServer subject;
  final ServersRepository repository;
  final FakeSettingsRepository settings;
  final FakeServersApi api;

  Future<void> dispose() async {
    await repository.dispose();
    await settings.dispose();
  }
}
