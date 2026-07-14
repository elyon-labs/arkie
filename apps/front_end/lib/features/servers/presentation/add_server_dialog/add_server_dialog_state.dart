import 'package:cs2_rcon_front_end/core/async.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:oxidized/oxidized.dart';

part 'add_server_dialog_state.mapper.dart';

@MappableClass()
class AddServerDialogState with AddServerDialogStateMappable {
  AddServerDialogState({
    required this.addServerResult,
    required this.name,
    required this.address,
    required this.port,
    required this.password,
    this.enableManagement = false,
    this.sshHost = '',
    this.sshPort = 22,
    this.sshUser = 'arkie-cs2',
    this.privateKeyPath = '',
    this.hostKeyFingerprint = '',
  });

  factory AddServerDialogState.initial() {
    return AddServerDialogState(
      addServerResult: const Idle(),
      name: '',
      address: '',
      port: 27015,
      password: '',
    );
  }

  final Async<Result<Server, String>> addServerResult;
  final String name;
  final String address;
  final int port;
  final String password;
  final bool enableManagement;
  final String sshHost;
  final int sshPort;
  final String sshUser;
  final String privateKeyPath;
  final String hostKeyFingerprint;
}
