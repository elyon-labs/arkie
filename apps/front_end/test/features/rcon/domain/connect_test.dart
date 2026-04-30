import 'dart:io';

import 'package:cs2_rcon_client/cs2_rcon_client.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/connection_cache.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/connect.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/drop_connection.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/get_socket.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/save_connection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxidized/oxidized.dart';

import '../../../fakes/fake_environment.dart';
import '../../../fakes/fake_get_socket.dart';
import '../../../fakes/fake_rcon_connection.dart';
import '../../../fakes/fake_rcon_socket.dart';

void main() {
  group('Connect', () {
    RCONServerPacket buildPacket({
      int id = 1,
      ServerPacketType type = ServerPacketType.SERVERDATA_RESPONSE_VALUE,
      String body = 'test response',
    }) {
      return RCONServerPacket.raw(id: id, type: type, body: body);
    }

    group('when connect is successful', () {
      group('and message is successful', () {
        test('it returns Ok with RCONConnection', () async {
          final connectionCache = ConnectionCache();
          final connection = FakeRCONConnection(onSendCommand: (_) async => Ok(buildPacket()));
          await connectionCache.addConnection(
            FakeRCONSocket(onConnect: () async => Ok(connection)),
            connection,
          );
          final subject = Connect(
            getSocket: GetSocket(connectionCache: connectionCache, environment: FakeEnvironment()),
            removeSocket: DropConnection(connectionCache: connectionCache),
            addSocket: SaveConnection(connectionCache: connectionCache),
          );

          final result = await subject.call(
            address: InternetAddress.loopbackIPv4.address,
            port: 27015,
            password: 'password',
          );

          expect(result.isOk(), isTrue);
          expect(result.unwrap(), equals(connection));
        });

        test('it caches the connection', () async {
          final connectionCache = ConnectionCache();
          final connection = FakeRCONConnection(onSendCommand: (_) async => Ok(buildPacket()));
          final subject = Connect(
            getSocket: FakeGetSocket(onConnect: () async => Ok(connection)),
            removeSocket: DropConnection(connectionCache: connectionCache),
            addSocket: SaveConnection(connectionCache: connectionCache),
          );

          final result = await subject.call(
            address: InternetAddress.loopbackIPv4.address,
            port: 27015,
            password: 'password',
          );

          expect(result.isOk(), isTrue);
          expect(result.unwrap(), equals(connection));
          expect(
            connectionCache.getConnection((InternetAddress.loopbackIPv4.address, 27015)),
            isNotNull,
          );
        });
      });

      group('and message is unsuccessful', () {
        test('it returns Err with Exception', () async {
          final connectionCache = ConnectionCache();
          final exception = Exception('Command failed');
          final connection = FakeRCONConnection(onSendCommand: (_) async => Err(exception));
          await connectionCache.addConnection(
            FakeRCONSocket(onConnect: () async => Ok(connection)),
            connection,
          );
          final subject = Connect(
            getSocket: GetSocket(connectionCache: connectionCache, environment: FakeEnvironment()),
            removeSocket: DropConnection(connectionCache: connectionCache),
            addSocket: SaveConnection(connectionCache: connectionCache),
          );

          final result = await subject.call(
            address: InternetAddress.loopbackIPv4.address,
            port: 27015,
            password: 'password',
          );

          expect(result.isErr(), isTrue);
          expect(result.unwrapErr(), equals(exception));
        });

        test('it does not cache the connection', () async {
          final connectionCache = ConnectionCache();
          final exception = Exception('Command failed');
          final connection = FakeRCONConnection(onSendCommand: (_) async => Err(exception));
          final subject = Connect(
            getSocket: FakeGetSocket(onConnect: () async => Ok(connection)),
            removeSocket: DropConnection(connectionCache: connectionCache),
            addSocket: SaveConnection(connectionCache: connectionCache),
          );

          final result = await subject.call(
            address: InternetAddress.loopbackIPv4.address,
            port: 27015,
            password: 'password',
          );

          expect(result.isErr(), isTrue);
          expect(
            await connectionCache.getConnection((InternetAddress.loopbackIPv4.address, 27015)),
            isNull,
          );
        });
      });
    });
  });
}
