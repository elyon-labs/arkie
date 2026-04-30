import 'dart:io';

import 'package:cs2_rcon_front_end/core/async.dart';
import 'package:cs2_rcon_front_end/core/safe_emit.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/connect.dart';
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

  Future<void> saveServer() async {
    safeEmit(state.copyWith(addServerResult: const Loading()));

    // First, make sure all inputs are valid
    // The address must not be empty and be a valid IP or hostname
    if (state.address.isEmpty || InternetAddress.tryParse(state.address) == null) {
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
    ).then((res) {
      res.match(
        (server) => safeEmit(state.copyWith(addServerResult: Loaded(Ok(server)))),
        (error) => safeEmit(state.copyWith(addServerResult: Error(error.toString()))),
      );
    });
  }
}
