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
    required this.privateKeyPath,
    required this.hostKeyFingerprint,
  });

  final ServerManagementBackend backend;
  final String sshHost;
  final int sshPort;
  final String sshUser;
  final String privateKeyPath;
  final String hostKeyFingerprint;
}
