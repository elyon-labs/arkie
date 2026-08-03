import 'package:cs2_rcon_front_end/di/graph.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/delete_managed_private_key.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/import_ssh_private_key.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server_management_config.dart';
import 'package:cs2_rcon_front_end/features/servers/data/repository/servers_repository.dart';
import 'package:cs2_rcon_front_end/features/servers/domain/models/server_management_draft.dart';
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
    required ImportSshPrivateKey importSshPrivateKey,
    required DeleteManagedPrivateKey deleteManagedPrivateKey,
  }) : _settingsRepository = settingsRepository,
       _serversRepository = serversRepository,
       _importSshPrivateKey = importSshPrivateKey,
       _deleteManagedPrivateKey = deleteManagedPrivateKey;

  factory AddServer.create() {
    return AddServer(
      serversRepository: inject(),
      settingsRepository: inject(),
      importSshPrivateKey: ImportSshPrivateKey.create(),
      deleteManagedPrivateKey: DeleteManagedPrivateKey.create(),
    );
  }

  final ServersRepository _serversRepository;
  final SettingsRepository _settingsRepository;
  final ImportSshPrivateKey _importSshPrivateKey;
  final DeleteManagedPrivateKey _deleteManagedPrivateKey;

  Future<Result<Server, Exception>> call({
    required String name,
    required String address,
    required int port,
    required String password,
    ServerManagementDraft? managementDraft,
  }) async {
    final initialServers = await _serversRepository.getServers();
    final Result<ServerManagementConfig?, Exception> managementConfigResult;
    if (managementDraft == null) {
      managementConfigResult = const Ok(null);
    } else {
      final selectedPrivateKey = managementDraft.selectedPrivateKey;
      if (selectedPrivateKey == null) {
        managementConfigResult = Err(Exception('Select an SSH private key.'));
      } else {
        managementConfigResult = (await _importSshPrivateKey(selectedPrivateKey))
            // Widen the storage error so the result can compose with repository errors below.
            .mapErr<Exception>((error) => error)
            .map<ServerManagementConfig?>(
              (privateKey) => ServerManagementConfig(
                backend: managementDraft.backend,
                sshHost: managementDraft.sshHost,
                sshPort: managementDraft.sshPort,
                sshUser: managementDraft.sshUser,
                privateKey: privateKey,
                hostKeyFingerprint: managementDraft.hostKeyFingerprint,
              ),
            );
      }
    }

    return managementConfigResult.andThenAsync((managementConfig) async {
      final result = await _serversRepository.addServer(
        name: name,
        address: address,
        port: port,
        password: password,
        managementConfig: managementConfig,
      );
      final importedPrivateKey = managementConfig?.privateKey;
      final cleanedResult = await result.mapErrAsync((error) async {
        if (importedPrivateKey != null) {
          await _deleteManagedPrivateKey(importedPrivateKey);
        }
        return error;
      });
      return cleanedResult.mapAsync((server) async {
        if (initialServers.isEmpty) {
          await _settingsRepository.selectServer(server.id);
        }
        return server;
      });
    });
  }
}
