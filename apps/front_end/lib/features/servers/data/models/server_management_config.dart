import 'package:cs2_rcon_front_end/features/server_management/domain/models/managed_private_key_reference.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'server_management_config.mapper.dart';

@MappableEnum()
enum ServerManagementBackend { systemd }

@MappableClass()
class ServerManagementConfig with ServerManagementConfigMappable {
  const ServerManagementConfig({
    required this.backend,
    required this.sshHost,
    required this.sshPort,
    required this.sshUser,
    required this.privateKey,
    required this.hostKeyFingerprint,
  });

  final ServerManagementBackend backend;
  final String sshHost;
  final int sshPort;
  final String sshUser;
  final ManagedPrivateKeyReference? privateKey;
  final String hostKeyFingerprint;
}
