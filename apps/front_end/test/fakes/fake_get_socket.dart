import 'dart:io';

import 'package:cs2_rcon_client/src/models/log.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/models/get_socket_result.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/get_socket.dart';

import 'fake_rcon_socket.dart';

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
