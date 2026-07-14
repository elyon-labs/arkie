import 'package:cs2_rcon_front_end/di/graph.dart';
import 'package:cs2_rcon_front_end/features/server_management/data/managed_private_key_store.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/server_management_draft.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/managed_private_key_reference.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server_management_config.dart';
import 'package:cs2_rcon_front_end/features/servers/data/repository/servers_repository.dart';
import 'package:cs2_rcon_front_end/features/settings/data/repository/settings_repository.dart';
import 'package:oxidized/oxidized.dart';

/// Adds a new server to the servers repository.
///
/// If this is the first server being added, it is automatically selected as the
/// active server.
class AddServer {
  AddServer({
    required ServersRepository serversRepository,
    required SettingsRepository settingsRepository,
    ManagedPrivateKeyStore? privateKeyStore,
  }) : _settingsRepository = settingsRepository,
       _serversRepository = serversRepository,
       _privateKeyStore = privateKeyStore ?? ManagedPrivateKeyStore();

  factory AddServer.create() {
    return AddServer(
      serversRepository: inject(),
      settingsRepository: inject(),
      privateKeyStore: inject(),
    );
  }

  final ServersRepository _serversRepository;
  final SettingsRepository _settingsRepository;
  final ManagedPrivateKeyStore _privateKeyStore;

  Future<Result<Server, Exception>> call({
    required String name,
    required String address,
    required int port,
    required String password,
    ServerManagementDraft? managementDraft,
  }) async {
    final initialServers = await _serversRepository.getServers();
    ManagedPrivateKeyReference? importedKey;
    ServerManagementConfig? managementConfig;
    final selectedKey = managementDraft?.selectedPrivateKey;
    if (managementDraft != null) {
      if (selectedKey == null) {
        return Result.err(Exception('Choose a private key before enabling server management.'));
      }
      try {
        importedKey = await _privateKeyStore.import(selectedKey);
        managementConfig = ServerManagementConfig(
          backend: managementDraft.backend,
          sshHost: managementDraft.sshHost,
          sshPort: managementDraft.sshPort,
          sshUser: managementDraft.sshUser,
          hostKeyFingerprint: managementDraft.hostKeyFingerprint,
          privateKey: importedKey,
          privateKeyPath: null,
        );
      } on Exception catch (error) {
        return Result.err(error);
      }
    }
    final result = await _serversRepository.addServer(
      name: name,
      address: address,
      port: port,
      password: password,
      managementConfig: managementConfig,
    );

    if (result.isErr() && importedKey != null) {
      try {
        await _privateKeyStore.delete(importedKey.id);
      } on Exception {
        // Preserve the original persistence failure.
      }
    }

    if (initialServers.isEmpty && result.isOk()) {
      await _settingsRepository.selectServer(result.unwrap().id);
    }

    return result;
  }
}
