import 'package:arkie_core/features/rcon/domain/drop_connection.dart';
import 'package:arkie_core/testing/fake_connection_cache.dart';
import 'package:arkie_core/testing/fake_rcon_connection.dart';
import 'package:arkie_core/testing/fake_rcon_socket.dart';
import 'package:cs2_rcon_client/cs2_rcon_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxidized/oxidized.dart';

void main() {
  group('DropConnection', () {
    test('it invokes removeConnection on the ConnectionCache', () async {
      late final RCONSocket capturedSocket;
      final cache = FakeConnectionCache(
        onRemoveConnection: (socket) {
          capturedSocket = socket;
        },
      );
      const connection = FakeRCONConnection();
      final socket = FakeRCONSocket(onConnect: () => Future.value(const Ok(connection)));

      final dropConnection = DropConnection(connectionCache: cache);

      await dropConnection(socket: socket);

      expect(capturedSocket, socket);
    });
  });
}
