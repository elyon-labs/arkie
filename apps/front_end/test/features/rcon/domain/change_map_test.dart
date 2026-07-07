import 'dart:async';

import 'package:cs2_rcon_client/cs2_rcon_client.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/change_map.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/models/cs2_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxidized/oxidized.dart';

import '../../../fakes/fake_rcon_connection.dart';

void main() {
  group('ChangeMap', () {
    test('it invokes `map` with the map name', () async {
      final commandCompleter = Completer<String>();
      final connection = FakeRCONConnection(
        onSendCommand: (c) {
          commandCompleter.complete(c);
          return Future.value(Ok(RCONServerPacket.responseValue(id: 1, body: 'OK')));
        },
      );

      final changeMap = ChangeMap(connection: connection);
      const map = KnownMap(name: 'de_dust2', assetName: 'de_dust2');

      await changeMap(map);

      final command = await commandCompleter.future;
      expect(command, 'map de_dust2');
    });

    test('it invokes `host_workshop_map` with the workshop id for workshop maps', () async {
      final commandCompleter = Completer<String>();
      final connection = FakeRCONConnection(
        onSendCommand: (c) {
          commandCompleter.complete(c);
          return Future.value(Ok(RCONServerPacket.responseValue(id: 1, body: 'OK')));
        },
      );

      final changeMap = ChangeMap(connection: connection);
      final map = WorkshopMap.directory.first;

      await changeMap(map);

      final command = await commandCompleter.future;
      expect(command, 'host_workshop_map ${map.workshopId}');
    });
  });
}
