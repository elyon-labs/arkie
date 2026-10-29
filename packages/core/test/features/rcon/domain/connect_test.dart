import 'dart:io';

import 'package:arkie_core/features/rcon/data/connection_cache.dart';
import 'package:arkie_core/features/rcon/demo/demo_connections.dart';
import 'package:arkie_core/features/rcon/domain/connect.dart';
import 'package:arkie_core/features/rcon/domain/drop_connection.dart';
import 'package:arkie_core/features/rcon/domain/get_socket.dart';
import 'package:arkie_core/features/rcon/domain/save_connection.dart';
import 'package:arkie_core/testing/fake_environment.dart';
import 'package:arkie_core/testing/fake_get_socket.dart';
import 'package:arkie_core/testing/fake_rcon_connection.dart';
import 'package:arkie_core/testing/fake_rcon_socket.dart';
import 'package:cs2_rcon_client/cs2_rcon_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxidized/oxidized.dart';

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

    group('when the server is the demo server', () {
      test('it answers in memory without touching the network', () async {
        final connectionCache = ConnectionCache();
        final subject = Connect(
          getSocket: FakeGetSocket(onConnect: () async => fail('should not open a socket')),
          removeSocket: DropConnection(connectionCache: connectionCache),
          addSocket: SaveConnection(connectionCache: connectionCache),
          demoConnections: DemoConnections(),
        );

        final result = await subject.call(
          address: '203.0.113.10',
          port: 27015,
          password: 'demo',
          isDemo: true,
        );

        final response = await result.unwrap().sendCommand('echo ping');
        expect(response.unwrap().body, 'ping');
      });

      test('it does not put the demo connection in the socket cache', () async {
        final connectionCache = ConnectionCache();
        final subject = Connect(
          getSocket: FakeGetSocket(onConnect: () async => fail('should not open a socket')),
          removeSocket: DropConnection(connectionCache: connectionCache),
          addSocket: SaveConnection(connectionCache: connectionCache),
          demoConnections: DemoConnections(),
        );

        await subject.call(address: '203.0.113.10', port: 27015, password: 'demo', isDemo: true);

        expect(await connectionCache.getConnection(('203.0.113.10', 27015)), isNull);
      });

      test('it hands back the same connection each time, so its state holds', () async {
        final connectionCache = ConnectionCache();
        final subject = Connect(
          getSocket: FakeGetSocket(onConnect: () async => fail('should not open a socket')),
          removeSocket: DropConnection(connectionCache: connectionCache),
          addSocket: SaveConnection(connectionCache: connectionCache),
          demoConnections: DemoConnections(),
        );

        Future<RCONConnection> connect() async {
          final result = await subject.call(
            address: '203.0.113.10',
            port: 27015,
            password: 'demo',
            isDemo: true,
          );
          return result.unwrap();
        }

        expect(await connect(), same(await connect()));
      });
    });

    group('when the address is a hostname', () {
      test('it resolves the hostname and connects', () async {
        final connectionCache = ConnectionCache();
        final connection = FakeRCONConnection(onSendCommand: (_) async => Ok(buildPacket()));
        final subject = Connect(
          getSocket: FakeGetSocket(onConnect: () async => Ok(connection)),
          removeSocket: DropConnection(connectionCache: connectionCache),
          addSocket: SaveConnection(connectionCache: connectionCache),
        );

        final result = await subject.call(address: 'localhost', port: 27015, password: 'password');

        expect(result.isOk(), isTrue);
        expect(result.unwrap(), equals(connection));
      });

      test('it returns Err when the hostname does not resolve', () async {
        final connectionCache = ConnectionCache();
        final connection = FakeRCONConnection(onSendCommand: (_) async => Ok(buildPacket()));
        final subject = Connect(
          getSocket: FakeGetSocket(onConnect: () async => Ok(connection)),
          removeSocket: DropConnection(connectionCache: connectionCache),
          addSocket: SaveConnection(connectionCache: connectionCache),
        );

        final result = await subject.call(
          address: 'arkie-does-not-exist.invalid',
          port: 27015,
          password: 'password',
        );

        expect(result.isErr(), isTrue);
        expect(result.unwrapErr(), isA<SocketException>());
      });
    });
  });
}
