import 'package:dart_mappable/dart_mappable.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/managed_private_key_reference.dart';

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
    required this.hostKeyFingerprint,
    this.privateKey,
    @Deprecated('Legacy migration data only') this.privateKeyPath,
  });

  final ServerManagementBackend backend;
  final String sshHost;
  final int sshPort;
  final String sshUser;
  final ManagedPrivateKeyReference? privateKey;
  @Deprecated('Legacy migration data only')
  final String? privateKeyPath;
  final String hostKeyFingerprint;
}
