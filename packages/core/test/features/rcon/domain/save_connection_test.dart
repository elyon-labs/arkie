import 'package:arkie_core/features/rcon/domain/save_connection.dart';
import 'package:arkie_core/testing/fake_connection_cache.dart';
import 'package:arkie_core/testing/fake_rcon_connection.dart';
import 'package:arkie_core/testing/fake_rcon_socket.dart';
import 'package:cs2_rcon_client/cs2_rcon_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxidized/oxidized.dart';

void main() {
  group('SaveConnection', () {
    test('it invokes addConnection on the ConnectionCache', () async {
      late final (RCONSocket, RCONConnection) capturedPair;
      final cache = FakeConnectionCache(
        onAddConnection: (pair) {
          capturedPair = pair;
        },
      );
      const connection = FakeRCONConnection();
      final socket = FakeRCONSocket(onConnect: () => Future.value(const Ok(connection)));

      final saveConnection = SaveConnection(connectionCache: cache);

      await saveConnection(socket: socket, connection: connection);

      expect(capturedPair.$1, socket);
      expect(capturedPair.$2, connection);
    });
  });
}
