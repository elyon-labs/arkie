import 'dart:io';

import 'package:cs2_rcon_front_end/features/rcon/data/connection_cache.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fakes/fake_rcon_connection.dart';
import '../../../fakes/fake_rcon_socket.dart';

void main() {
  group('ConnectionCache', () {
    group('getConnection', () {
      test('returns null when socket is not cached', () async {
        final connectionCache = ConnectionCache();
        const key = ('127.0.0.1', 27015);
        final socket = await connectionCache.getConnection(key);
        expect(socket, isNull);
      });

      test('returns cached connection when it exists', () async {
        final connectionCache = ConnectionCache();
        final socket = FakeRCONSocket(hostAddress: InternetAddress.loopbackIPv4, hostPort: 27015);
        const connection = FakeRCONConnection();
        const key = ('127.0.0.1', 27015);
        await connectionCache.addConnection(socket, connection);
        final cachedSocket = await connectionCache.getConnection(key);
        expect(cachedSocket, equals((socket, connection)));
      });
    });

    group('setSocket', () {
      test('caches the socket', () async {
        final connectionCache = ConnectionCache();
        final socket = FakeRCONSocket(hostAddress: InternetAddress.loopbackIPv4, hostPort: 27015);
        const connection = FakeRCONConnection();
        const key = ('127.0.0.1', 27015);
        await connectionCache.addConnection(socket, connection);
        final cachedSocket = await connectionCache.getConnection(key);
        expect(cachedSocket, equals((socket, connection)));
      });
    });

    group('removeSocket', () {
      test('removes the socket from cache', () async {
        final connectionCache = ConnectionCache();
        final socket = FakeRCONSocket(hostAddress: InternetAddress.loopbackIPv4, hostPort: 27015);
        const key = ('127.0.0.1', 27015);
        await connectionCache.addConnection(socket, const FakeRCONConnection());
        final cachedSocket = connectionCache.getConnection(key);
        expect(cachedSocket, isNotNull);

        await connectionCache.removeConnection(socket);
        final removedSocket = await connectionCache.getConnection(key);
        expect(removedSocket, isNull);
      });
    });

    group('clearAllConnections', () {
      test('clears all cached sockets', () async {
        final connectionCache = ConnectionCache();
        final socket1 = FakeRCONSocket(hostAddress: InternetAddress.loopbackIPv4, hostPort: 27015);
        final socket2 = FakeRCONSocket(hostAddress: InternetAddress.loopbackIPv4, hostPort: 27016);
        const key1 = ('127.0.0.1', 27015);
        const key2 = ('127.0.0.1', 27016);
        await connectionCache.addConnection(socket1, const FakeRCONConnection());
        await connectionCache.addConnection(socket2, const FakeRCONConnection());
        await connectionCache.clearAllConnections();
        final cachedSocket1 = await connectionCache.getConnection(key1);
        final cachedSocket2 = await connectionCache.getConnection(key2);
        expect(cachedSocket1, isNull);
        expect(cachedSocket2, isNull);
      });
    });
  });
}
