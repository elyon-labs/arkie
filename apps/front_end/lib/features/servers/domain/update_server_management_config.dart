import 'package:cs2_rcon_front_end/di/graph.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/delete_managed_private_key.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/import_ssh_private_key.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/managed_private_key_reference.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server_management_config.dart';
import 'package:cs2_rcon_front_end/features/servers/data/repository/servers_repository.dart';
import 'package:cs2_rcon_front_end/features/servers/domain/models/server_management_draft.dart';
import 'package:oxidized/oxidized.dart';

class UpdateServerManagementConfig {
  const UpdateServerManagementConfig({
    required ServersRepository serversRepository,
    required ImportSshPrivateKey importSshPrivateKey,
    required DeleteManagedPrivateKey deleteManagedPrivateKey,
  }) : _serversRepository = serversRepository,
       _importSshPrivateKey = importSshPrivateKey,
       _deleteManagedPrivateKey = deleteManagedPrivateKey;

  factory UpdateServerManagementConfig.create() {
    return UpdateServerManagementConfig(
      serversRepository: inject(),
      importSshPrivateKey: ImportSshPrivateKey.create(),
      deleteManagedPrivateKey: DeleteManagedPrivateKey.create(),
    );
  }

  final ServersRepository _serversRepository;
  final ImportSshPrivateKey _importSshPrivateKey;
  final DeleteManagedPrivateKey _deleteManagedPrivateKey;

  Future<Result<ServerManagementUpdate, Exception>> call({
    required Server server,
    required bool enabled,
    ServerManagementDraft? draft,
  }) async {
    final oldReference = server.managementConfig?.privateKey;
    if (!enabled) {
      final persistenceResult = await _serversRepository.updateServer(
        server.copyWith(managementConfig: null),
      );
      if (persistenceResult.isErr()) {
        return Err(persistenceResult.unwrapErr());
      }
      return Ok(ServerManagementUpdate(cleanupWarning: await _deleteWarning(oldReference)));
    }

    if (draft == null) {
      return Err(Exception('Server management settings are required.'));
    }

    final selectedPrivateKey = draft.selectedPrivateKey;
    ManagedPrivateKeyReference? replacement;
    if (selectedPrivateKey != null) {
      final importResult = await _importSshPrivateKey(selectedPrivateKey);
      if (importResult.isErr()) {
        return Err(importResult.unwrapErr());
      }
      replacement = importResult.unwrap();
    } else if (oldReference == null) {
      return Err(Exception('Select an SSH private key.'));
    }

    final newConfig = ServerManagementConfig(
      backend: draft.backend,
      sshHost: draft.sshHost,
      sshPort: draft.sshPort,
      sshUser: draft.sshUser,
      privateKey: replacement ?? oldReference,
      hostKeyFingerprint: draft.hostKeyFingerprint,
    );
    final persistenceResult = await _serversRepository.updateServer(
      server.copyWith(managementConfig: newConfig),
    );
    if (persistenceResult.isErr()) {
      if (replacement != null) {
        await _deleteManagedPrivateKey(replacement);
      }
      return Err(persistenceResult.unwrapErr());
    }

    return Ok(
      ServerManagementUpdate(
        cleanupWarning: replacement == null ? null : await _deleteWarning(oldReference),
      ),
    );
  }

  Future<String?> _deleteWarning(ManagedPrivateKeyReference? reference) async {
    if (reference == null) {
      return null;
    }
    final result = await _deleteManagedPrivateKey(reference);
    return result.when(
      ok: (_) => null,
      err: (error) => 'Server saved, but Arkie could not remove the old private key: $error',
    );
  }
}

class ServerManagementUpdate {
  const ServerManagementUpdate({this.cleanupWarning});

  final String? cleanupWarning;
}
