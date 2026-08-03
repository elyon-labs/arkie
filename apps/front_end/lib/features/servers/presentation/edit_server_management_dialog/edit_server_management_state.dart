import 'package:dart_mappable/dart_mappable.dart';

part 'edit_server_management_state.mapper.dart';

@MappableClass()
class EditServerManagementState with EditServerManagementStateMappable {
  const EditServerManagementState({
    required this.enabled,
    required this.sshHost,
    required this.sshPort,
    required this.sshUser,
    required this.hostKeyFingerprint,
    required this.privateKeyDisplayName,
    required this.isSelectingPrivateKey,
    required this.isSaving,
    this.error,
    this.cleanupWarning,
    this.saved = false,
  });

  final bool enabled;
  final String sshHost;
  final int sshPort;
  final String sshUser;
  final String hostKeyFingerprint;
  final String? privateKeyDisplayName;
  final bool isSelectingPrivateKey;
  final bool isSaving;
  final String? error;
  final String? cleanupWarning;
  final bool saved;
}
