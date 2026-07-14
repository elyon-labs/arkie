import 'package:cs2_rcon_front_end/features/servers/data/models/server_management_config.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:uuid/uuid.dart';

part 'server.mapper.dart';

@MappableClass()
class Server with ServerMappable {
  Server({
    required this.id,
    required this.name,
    required this.password,
    required this.address,
    required this.port,
    this.managementConfig,
  });

  factory Server.create({
    required String name,
    required String address,
    required int port,
    required String password,
    ServerManagementConfig? managementConfig,
  }) {
    final id = const Uuid().v4();
    return Server(
      id: id,
      name: name,
      address: address,
      port: port,
      password: password,
      managementConfig: managementConfig,
    );
  }

  final String id;
  final String name;
  final String password;
  final String address;
  final int port;
  final ServerManagementConfig? managementConfig;
}
