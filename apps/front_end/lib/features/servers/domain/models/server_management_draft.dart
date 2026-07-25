import 'package:cs2_rcon_front_end/features/server_management/domain/models/selected_private_key.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server_management_config.dart';

/// Transient SSH management details used while creating a server.
///
/// The selected key bytes are imported into managed storage before a
/// [ServerManagementConfig] is persisted.
class ServerManagementDraft {
  const ServerManagementDraft({
    required this.backend,
    required this.sshHost,
    required this.sshPort,
    required this.sshUser,
    required this.selectedPrivateKey,
    required this.hostKeyFingerprint,
  });

  final ServerManagementBackend backend;
  final String sshHost;
  final int sshPort;
  final String sshUser;

  /// A newly selected key to import.
  ///
  /// This is required when creating or enabling management, but may be omitted
  /// while editing to retain an existing managed key.
  final SelectedPrivateKey? selectedPrivateKey;
  final String hostKeyFingerprint;
}
