import 'dart:io';

import 'package:arkie_core/features/rcon/data/models/get_socket_result.dart';
import 'package:arkie_core/features/rcon/domain/get_socket.dart';
import 'package:arkie_core/testing/fake_rcon_socket.dart';
import 'package:cs2_rcon_client/cs2_rcon_client.dart';

class FakeGetSocket implements GetSocket {
  FakeGetSocket({this.onConnect});

  final HandleConnect? onConnect;

  @override
  Future<GetSocketResult> call({
    required InternetAddress hostAddress,
    required int hostPort,
    LogLevel? logLevel,
    Duration? connectTimeout,
  }) async {
    return DisconnectedSocket(
      FakeRCONSocket(
        hostAddress: hostAddress,
        hostPort: hostPort,
        logLevel: logLevel ?? LogLevel.debug,
        connectTimeout: connectTimeout ?? const Duration(seconds: 5),
        onConnect: onConnect,
      ),
    );
  }
}
