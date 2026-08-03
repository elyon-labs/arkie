import 'dart:typed_data';

import 'package:cs2_rcon_front_end/features/server_management/data/managed_private_key_store.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/delete_managed_private_key.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/import_ssh_private_key.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/managed_private_key_reference.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/selected_private_key.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server_management_config.dart';
import 'package:cs2_rcon_front_end/features/servers/data/repository/servers_repository.dart';
import 'package:cs2_rcon_front_end/features/servers/domain/models/server_management_draft.dart';
import 'package:cs2_rcon_front_end/features/servers/domain/update_server_management_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxidized/oxidized.dart';

import '../../../fakes/fake_managed_private_key_store.dart';
import '../../../fakes/fake_servers_api.dart';

void main() {
  const oldReference = ManagedPrivateKeyReference(id: 'old-id', displayName: 'old-key');
  const replacementReference = ManagedPrivateKeyReference(
    id: 'replacement-id',
    displayName: 'replacement-key',
  );

  test('edits SSH fields while retaining the existing managed key', () async {
    final server = _managedServer(oldReference);
    var importCalls = 0;
    var deleteCalls = 0;
    final harness = await _Harness.create(
      server: server,
      store: FakeManagedPrivateKeyStore(
        onImportKey: (_) async {
          importCalls++;
          return const Ok(replacementReference);
        },
        onDeleteKey: (_) async {
          deleteCalls++;
          return const Ok(null);
        },
      ),
    );
    addTearDown(harness.dispose);

    final result = await harness.subject(
      server: server,
      update: SaveServerManagementConfig(_draft()),
    );

    expect(result.isOk(), isTrue);
    expect(importCalls, 0);
    expect(deleteCalls, 0);
    final saved = (await harness.api.fetchServers()).single;
    expect(saved.managementConfig?.privateKey, oldReference);
    expect(saved.managementConfig?.sshHost, 'new.example.com');
  });

  test('enables unconfigured management with a selected key', () async {
    final server = _server();
    final harness = await _Harness.create(
      server: server,
      store: FakeManagedPrivateKeyStore(onImportKey: (_) async => const Ok(replacementReference)),
    );
    addTearDown(harness.dispose);

    final result = await harness.subject(
      server: server,
      update: SaveServerManagementConfig(_draft(selectedPrivateKey: _selected())),
    );

    expect(result.isOk(), isTrue);
    final saved = (await harness.api.fetchServers()).single;
    expect(saved.managementConfig?.privateKey, replacementReference);
  });

  test('rejects enabled management without an existing or selected key', () async {
    final server = _server();
    final harness = await _Harness.create(server: server, store: FakeManagedPrivateKeyStore());
    addTearDown(harness.dispose);

    final result = await harness.subject(
      server: server,
      update: SaveServerManagementConfig(_draft()),
    );

    expect(result.unwrapErr().toString(), 'Exception: Select an SSH private key.');
    expect(harness.api.updateServerCallCount, 0);
  });

  test('persists a replacement before deleting the old key', () async {
    final server = _managedServer(oldReference);
    late _Harness harness;
    var oldKeyDeleted = false;
    final store = FakeManagedPrivateKeyStore(
      onImportKey: (_) async => const Ok(replacementReference),
      onDeleteKey: (id) async {
        expect(id, oldReference.id);
        expect(harness.api.updateServerCallCount, 1);
        final persisted = (await harness.api.fetchServers()).single;
        expect(persisted.managementConfig?.privateKey, replacementReference);
        oldKeyDeleted = true;
        return const Ok(null);
      },
    );
    harness = await _Harness.create(server: server, store: store);
    addTearDown(harness.dispose);

    final result = await harness.subject(
      server: server,
      update: SaveServerManagementConfig(_draft(selectedPrivateKey: _selected())),
    );

    expect(result.isOk(), isTrue);
    expect(oldKeyDeleted, isTrue);
  });

  test('does not persist when replacement import fails', () async {
    final server = _managedServer(oldReference);
    final importError = Exception('import failed');
    final harness = await _Harness.create(
      server: server,
      store: FakeManagedPrivateKeyStore(
        onImportKey: (_) async => Err(ManagedPrivateKeyStorageException(importError.toString())),
      ),
    );
    addTearDown(harness.dispose);

    final result = await harness.subject(
      server: server,
      update: SaveServerManagementConfig(_draft(selectedPrivateKey: _selected())),
    );

    expect(result.isErr(), isTrue);
    expect(harness.api.updateServerCallCount, 0);
    expect((await harness.api.fetchServers()).single, server);
  });

  test('rolls back a replacement when persistence fails', () async {
    final server = _managedServer(oldReference);
    String? deletedId;
    final persistenceError = Exception('persistence failed');
    final harness = await _Harness.create(
      server: server,
      store: FakeManagedPrivateKeyStore(
        onImportKey: (_) async => const Ok(replacementReference),
        onDeleteKey: (id) async {
          deletedId = id;
          return const Ok(null);
        },
      ),
    );
    harness.api.updateServerResult = Err(persistenceError);
    addTearDown(harness.dispose);

    final result = await harness.subject(
      server: server,
      update: SaveServerManagementConfig(_draft(selectedPrivateKey: _selected())),
    );

    expect(result.unwrapErr(), same(persistenceError));
    expect(deletedId, replacementReference.id);
    expect((await harness.api.fetchServers()).single, server);
  });

  test('keeps the persistence error primary when rollback cleanup fails', () async {
    final server = _managedServer(oldReference);
    final persistenceError = Exception('persistence failed');
    final harness = await _Harness.create(
      server: server,
      store: FakeManagedPrivateKeyStore(
        onImportKey: (_) async => const Ok(replacementReference),
        onDeleteKey: (_) async => const Err(ManagedPrivateKeyStorageException('cleanup failed')),
      ),
    );
    harness.api.updateServerResult = Err(persistenceError);
    addTearDown(harness.dispose);

    final result = await harness.subject(
      server: server,
      update: SaveServerManagementConfig(_draft(selectedPrivateKey: _selected())),
    );

    expect(result.unwrapErr(), same(persistenceError));
    expect((await harness.api.fetchServers()).single, server);
  });

  test('persists disabled management before deleting the old key', () async {
    final server = _managedServer(oldReference);
    late _Harness harness;
    var oldKeyDeleted = false;
    final store = FakeManagedPrivateKeyStore(
      onDeleteKey: (id) async {
        expect(id, oldReference.id);
        expect(harness.api.updateServerCallCount, 1);
        expect((await harness.api.fetchServers()).single.managementConfig, isNull);
        oldKeyDeleted = true;
        return const Ok(null);
      },
    );
    harness = await _Harness.create(server: server, store: store);
    addTearDown(harness.dispose);

    final result = await harness.subject(
      server: server,
      update: const DisableServerManagementConfig(),
    );

    expect(result.isOk(), isTrue);
    expect(oldKeyDeleted, isTrue);
  });

  test('does not delete the old key when disabling fails to persist', () async {
    final server = _managedServer(oldReference);
    var deleteCalls = 0;
    final harness = await _Harness.create(
      server: server,
      store: FakeManagedPrivateKeyStore(
        onDeleteKey: (_) async {
          deleteCalls++;
          return const Ok(null);
        },
      ),
    );
    harness.api.updateServerResult = Err(Exception('persistence failed'));
    addTearDown(harness.dispose);

    final result = await harness.subject(
      server: server,
      update: const DisableServerManagementConfig(),
    );

    expect(result.isErr(), isTrue);
    expect(deleteCalls, 0);
    expect((await harness.api.fetchServers()).single, server);
  });

  for (final operation in ['replacement', 'disable']) {
    test('returns a non-fatal warning when $operation cleanup fails', () async {
      final server = _managedServer(oldReference);
      final harness = await _Harness.create(
        server: server,
        store: FakeManagedPrivateKeyStore(
          onImportKey: (_) async => const Ok(replacementReference),
          onDeleteKey: (_) async => const Err(ManagedPrivateKeyStorageException('cleanup failed')),
        ),
      );
      addTearDown(harness.dispose);

      final result = operation == 'replacement'
          ? await harness.subject(
              server: server,
              update: SaveServerManagementConfig(_draft(selectedPrivateKey: _selected())),
            )
          : await harness.subject(server: server, update: const DisableServerManagementConfig());

      expect(result.isOk(), isTrue);
      expect(result.unwrap().cleanupWarning, contains('could not remove the old private key'));
    });
  }
}

Server _server() {
  return Server.create(name: 'Server', address: '127.0.0.1', port: 27015, password: 'password');
}

Server _managedServer(ManagedPrivateKeyReference reference) {
  return _server().copyWith(
    managementConfig: ServerManagementConfig(
      backend: ServerManagementBackend.systemd,
      sshHost: 'old.example.com',
      sshPort: 22,
      sshUser: 'old-user',
      privateKey: reference,
      hostKeyFingerprint: 'SHA256:old',
    ),
  );
}

ServerManagementDraft _draft({SelectedPrivateKey? selectedPrivateKey}) {
  return ServerManagementDraft(
    backend: ServerManagementBackend.systemd,
    sshHost: 'new.example.com',
    sshPort: 2222,
    sshUser: 'new-user',
    selectedPrivateKey: selectedPrivateKey,
    hostKeyFingerprint: 'SHA256:new',
  );
}

SelectedPrivateKey _selected() {
  return SelectedPrivateKey(
    displayName: 'replacement-key',
    pemBytes: Uint8List.fromList([1, 2, 3]),
  );
}

class _Harness {
  const _Harness({required this.subject, required this.repository, required this.api});

  static Future<_Harness> create({
    required Server server,
    required FakeManagedPrivateKeyStore store,
  }) async {
    final api = FakeServersApi(initialServers: [server]);
    final repository = ServersRepository(api: api);
    await repository.refresh();
    return _Harness(
      subject: UpdateServerManagementConfig(
        serversRepository: repository,
        importSshPrivateKey: ImportSshPrivateKey(store: store),
        deleteManagedPrivateKey: DeleteManagedPrivateKey(store: store),
      ),
      repository: repository,
      api: api,
    );
  }

  final UpdateServerManagementConfig subject;
  final ServersRepository repository;
  final FakeServersApi api;

  Future<void> dispose() => repository.dispose();
}
