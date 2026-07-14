import 'package:cs2_rcon_front_end/features/server_management/domain/models/selected_private_key.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server_management_config.dart';

class ServerManagementDraft {
  const ServerManagementDraft({
    required this.backend,
    required this.sshHost,
    required this.sshPort,
    required this.sshUser,
    required this.hostKeyFingerprint,
    this.selectedPrivateKey,
  });

  final ServerManagementBackend backend;
  final String sshHost;
  final int sshPort;
  final String sshUser;
  final String hostKeyFingerprint;
  final SelectedPrivateKey? selectedPrivateKey;
}
