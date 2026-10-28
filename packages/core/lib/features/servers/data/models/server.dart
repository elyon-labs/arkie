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
    this.isDemo = false,
  });

  factory Server.create({
    required String name,
    required String address,
    required int port,
    required String password,
  }) {
    final id = const Uuid().v4();
    return Server(id: id, name: name, address: address, port: port, password: password);
  }

  /// The stand-in server, answered in memory rather than over the network.
  ///
  /// Its address is in the range reserved for documentation, so it can never
  /// collide with a server somebody actually runs.
  factory Server.demo() {
    final id = const Uuid().v4();
    return Server(
      id: id,
      name: 'Demo server',
      address: demoAddress,
      port: demoPort,
      password: 'demo',
      isDemo: true,
    );
  }

  static const demoAddress = '203.0.113.10';
  static const demoPort = 27015;

  final String id;
  final String name;
  final String password;
  final String address;
  final int port;

  /// Whether this server is answered by the in-app demo server instead of a
  /// real one. At most one saved server has this set.
  final bool isDemo;
}
