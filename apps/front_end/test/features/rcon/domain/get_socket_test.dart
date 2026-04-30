import 'dart:io';

import 'package:cs2_rcon_front_end/features/rcon/data/connection_cache.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/models/get_socket_result.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/get_socket.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxidized/oxidized.dart';

import '../../../fakes/fake_environment.dart';
import '../../../fakes/fake_rcon_connection.dart';
import '../../../fakes/fake_rcon_socket.dart';

void main() {
  group('GetSocket', () {
    group('when a socket is cached', () {
      test('it returns a ConnectedSocket', () async {
        final cache = ConnectionCache();
        const rconConnection = FakeRCONConnection();
        final socket = FakeRCONSocket(onConnect: () => Future.value(const Ok(rconConnection)));

        await cache.addConnection(socket, rconConnection);

        final getSocket = GetSocket(connectionCache: cache, environment: FakeEnvironment());

        final result = await getSocket(hostAddress: InternetAddress.loopbackIPv4, hostPort: 27015);

        expect(result, isA<ConnectedSocket>());
      });
    });

    group('when a socket is not cached', () {
      test('it returns a DisconnectedSocket', () async {
        final cache = ConnectionCache();

        final getSocket = GetSocket(connectionCache: cache, environment: FakeEnvironment());

        final result = await getSocket(hostAddress: InternetAddress.loopbackIPv4, hostPort: 27015);

        expect(result, isA<DisconnectedSocket>());
      });
    });
  });
}
