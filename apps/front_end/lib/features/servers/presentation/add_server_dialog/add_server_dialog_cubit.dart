import 'dart:io';

import 'package:cs2_rcon_front_end/core/async.dart';
import 'package:cs2_rcon_front_end/core/safe_emit.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/connect.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server_management_config.dart';
import 'package:cs2_rcon_front_end/features/servers/domain/add_server.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/add_server_dialog/add_server_dialog_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxidized/oxidized.dart';

class AddServerDialogCubit extends Cubit<AddServerDialogState> {
  AddServerDialogCubit({required AddServer addServer, required Connect connect})
    : _addServer = addServer,
      _connect = connect,
      super(AddServerDialogState.initial());

  factory AddServerDialogCubit.create() {
    return AddServerDialogCubit(addServer: AddServer.create(), connect: Connect.create());
  }

  final AddServer _addServer;
  final Connect _connect;

  void setName(String name) {
    safeEmit(state.copyWith(name: name));
  }

  void setAddress(String address) {
    safeEmit(state.copyWith(address: address));
  }

  void setPort(int port) {
    safeEmit(state.copyWith(port: port));
  }

  void setPassword(String password) {
    safeEmit(state.copyWith(password: password));
  }

  void setEnableManagement(bool enableManagement) {
    safeEmit(state.copyWith(enableManagement: enableManagement));
  }

  void setSshHost(String sshHost) {
    safeEmit(state.copyWith(sshHost: sshHost));
  }

  void setSshPort(int sshPort) {
    safeEmit(state.copyWith(sshPort: sshPort));
  }

  void setSshUser(String sshUser) {
    safeEmit(state.copyWith(sshUser: sshUser));
  }

  void setPrivateKeyPath(String privateKeyPath) {
    safeEmit(state.copyWith(privateKeyPath: privateKeyPath));
  }

  void setHostKeyFingerprint(String hostKeyFingerprint) {
    safeEmit(state.copyWith(hostKeyFingerprint: hostKeyFingerprint));
  }

  Future<void> saveServer() async {
    safeEmit(state.copyWith(addServerResult: const Loading()));

    // First, make sure all inputs are valid
    // The address must not be empty and be a valid IP or hostname
    if (!_isValidHost(state.address)) {
      safeEmit(state.copyWith(addServerResult: const Error('Invalid address')));
      return;
    } else if (state.port <= 0 || state.port > 65535) {
      safeEmit(state.copyWith(addServerResult: const Error('Invalid port')));
      return;
    } else if (state.password.isEmpty) {
      safeEmit(state.copyWith(addServerResult: const Error('Password cannot be empty')));
      return;
    } else if (state.name.isEmpty) {
      safeEmit(state.copyWith(addServerResult: const Error('Name cannot be empty')));
      return;
    }

    ServerManagementConfig? managementConfig;
    if (state.enableManagement) {
      if (state.sshHost.isEmpty) {
        safeEmit(state.copyWith(addServerResult: const Error('SSH host cannot be empty')));
        return;
      } else if (state.sshPort <= 0 || state.sshPort > 65535) {
        safeEmit(state.copyWith(addServerResult: const Error('Invalid SSH port')));
        return;
      } else if (state.sshUser.isEmpty) {
        safeEmit(state.copyWith(addServerResult: const Error('SSH user cannot be empty')));
        return;
      } else if (state.privateKeyPath.isEmpty) {
        safeEmit(state.copyWith(addServerResult: const Error('Private key path cannot be empty')));
        return;
      } else if (state.hostKeyFingerprint.isEmpty) {
        safeEmit(state.copyWith(addServerResult: const Error('Host key fingerprint cannot be empty')));
        return;
      }
      managementConfig = ServerManagementConfig(
        backend: ServerManagementBackend.systemd,
        sshHost: state.sshHost,
        sshPort: state.sshPort,
        sshUser: state.sshUser,
        privateKeyPath: state.privateKeyPath,
        hostKeyFingerprint: state.hostKeyFingerprint,
      );
    }

    // Check if we can connect to the server with the provided details
    final connectResult = await _connect(
      address: state.address,
      port: state.port,
      password: state.password,
    );

    final connectError = connectResult.err().toNullable();
    if (connectError != null) {
      safeEmit(state.copyWith(addServerResult: Error('Failed to connect: $connectError')));
      return;
    }

    await _addServer(
      name: state.name,
      address: state.address,
      port: state.port,
      password: state.password,
      managementConfig: managementConfig,
    ).then((res) {
      res.match(
        (server) => safeEmit(state.copyWith(addServerResult: Loaded(Ok(server)))),
        (error) => safeEmit(state.copyWith(addServerResult: Error(error.toString()))),
      );
    });
  }
}


bool _isValidHost(String host) {
  if (host.isEmpty) {
    return false;
  }
  if (InternetAddress.tryParse(host) != null) {
    return true;
  }
  final hostname = RegExp(r'^(?=.{1,253}$)([a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)*[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?$');
  return hostname.hasMatch(host);
}
