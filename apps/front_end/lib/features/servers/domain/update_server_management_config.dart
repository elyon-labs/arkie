import 'package:cs2_rcon_front_end/di/graph.dart';
import 'package:cs2_rcon_front_end/features/server_management/data/managed_private_key_store.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/private_key_health.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/server_management_draft.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/managed_private_key_reference.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server_management_config.dart';
import 'package:cs2_rcon_front_end/features/servers/data/repository/servers_repository.dart';
import 'package:oxidized/oxidized.dart';

class UpdateServerManagementConfig {
  const UpdateServerManagementConfig({
    required ServersRepository serversRepository,
    required ManagedPrivateKeyStore privateKeyStore,
  }) : _serversRepository = serversRepository,
       _privateKeyStore = privateKeyStore;

  factory UpdateServerManagementConfig.create() =>
      UpdateServerManagementConfig(serversRepository: inject(), privateKeyStore: inject());

  final ServersRepository _serversRepository;
  final ManagedPrivateKeyStore _privateKeyStore;

  Future<Result<ServerManagementUpdate, Exception>> call({
    required Server server,
    required bool enabled,
    ServerManagementDraft? draft,
  }) async {
    final oldReference = server.managementConfig?.privateKey;
    if (!enabled) {
      final persistence = await _serversRepository.updateServer(
        server.copyWith(managementConfig: null),
      );
      if (persistence.isErr()) {
        return Result.err(persistence.unwrapErr());
      }
      return Result.ok(ServerManagementUpdate(cleanupWarning: await _deleteWarning(oldReference)));
    }
    if (draft == null) {
      return Result.err(Exception('Server management settings are required.'));
    }

    ManagedPrivateKeyReference? newReference;
    try {
      final selected = draft.selectedPrivateKey;
      if (selected != null) {
        newReference = await _privateKeyStore.import(selected);
      } else {
        if (oldReference == null) {
          return Result.err(Exception('Choose a replacement private key.'));
        }
        final health = await _privateKeyStore.inspect(oldReference);
        if (health is! PrivateKeyUsable) {
          return Result.err(Exception('The existing private key must be replaced.'));
        }
      }

      final reference = newReference ?? oldReference!;
      final config = ServerManagementConfig(
        backend: draft.backend,
        sshHost: draft.sshHost,
        sshPort: draft.sshPort,
        sshUser: draft.sshUser,
        hostKeyFingerprint: draft.hostKeyFingerprint,
        privateKey: reference,
        privateKeyPath: null,
      );
      final persistence = await _serversRepository.updateServer(
        server.copyWith(managementConfig: config),
      );
      if (persistence.isErr()) {
        if (newReference != null) {
          await _deleteIgnoringErrors(newReference);
        }
        return Result.err(persistence.unwrapErr());
      }
      return Result.ok(
        ServerManagementUpdate(
          cleanupWarning: newReference == null ? null : await _deleteWarning(oldReference),
        ),
      );
    } on Exception catch (error) {
      if (newReference != null) {
        await _deleteIgnoringErrors(newReference);
      }
      return Result.err(error);
    }
  }

  Future<String?> _deleteWarning(ManagedPrivateKeyReference? reference) async {
    if (reference == null) return null;
    try {
      await _privateKeyStore.delete(reference.id);
      return null;
    } on Exception catch (error) {
      return 'Server saved, but Arkie could not remove the old private key: $error';
    }
  }

  Future<void> _deleteIgnoringErrors(ManagedPrivateKeyReference reference) async {
    try {
      await _privateKeyStore.delete(reference.id);
    } on Exception {
      // The persistence error remains the actionable failure.
    }
  }
}

class ServerManagementUpdate {
  const ServerManagementUpdate({this.cleanupWarning});
  final String? cleanupWarning;
}
