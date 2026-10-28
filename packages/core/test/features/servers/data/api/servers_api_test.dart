import 'package:arkie_core/features/servers/data/api/servers_api.dart';
import 'package:arkie_core/features/servers/data/models/server.dart';
import 'package:arkie_core/testing/fake_box.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ServersApi', () {
    Server buildServer({
      String name = 'Test Server',
      String address = 'localhost',
      int port = 27015,
      String password = 'password',
    }) {
      return Server.create(name: name, address: address, port: port, password: password);
    }

    group('fetchServers', () {
      test('returns all servers from the box', () async {
        final server1 = buildServer(name: 'Server 1');
        final server2 = buildServer(name: 'Server 2');
        final fakeBox = FakeBox<Server>(initialValues: {server1.id: server1, server2.id: server2});
        final api = ServersApi(box: fakeBox);

        final servers = await api.fetchServers();

        expect(servers, equals([server1, server2]));
      });
    });

    group('addServer', () {
      test('stores the server in the box and returns it', () async {
        final fakeBox = FakeBox<Server>();
        final api = ServersApi(box: fakeBox);

        final result = await api.addServer(
          name: 'New Server',
          address: '127.0.0.1',
          port: 27015,
          password: 'secret',
        );

        expect(result.isOk(), isTrue);
        final server = result.unwrap();
        expect(fakeBox.get(server.id), equals(server));
      });
    });

    group('addDemoServer', () {
      test('stores the demo server in the box and returns it', () async {
        final fakeBox = FakeBox<Server>();
        final api = ServersApi(box: fakeBox);

        final result = await api.addDemoServer();

        final server = result.unwrap();
        expect(server.isDemo, isTrue);
        expect(server.address, Server.demoAddress);
        expect(fakeBox.get(server.id), equals(server));
      });

      test('returns the demo server already saved rather than a second one', () async {
        final fakeBox = FakeBox<Server>();
        final api = ServersApi(box: fakeBox);
        final first = (await api.addDemoServer()).unwrap();

        final second = (await api.addDemoServer()).unwrap();

        expect(second.id, first.id);
        expect(fakeBox.values.where((server) => server.isDemo), hasLength(1));
      });

      test('leaves real servers alone', () async {
        final server = buildServer();
        final fakeBox = FakeBox<Server>(initialValues: {server.id: server});
        final api = ServersApi(box: fakeBox);

        await api.addDemoServer();

        expect(fakeBox.values, hasLength(2));
        expect(fakeBox.get(server.id), equals(server));
      });

      test('returns an error when the box write fails', () async {
        final error = Exception('put failed');
        final fakeBox = FakeBox<Server>(onPut: (_, _) => throw error);
        final api = ServersApi(box: fakeBox);

        final result = await api.addDemoServer();

        expect(result.unwrapErr(), same(error));
      });
    });

    group('removeServer', () {
      test('removes the server from the box', () async {
        final server = buildServer();
        final fakeBox = FakeBox<Server>(initialValues: {server.id: server});
        final api = ServersApi(box: fakeBox);

        final result = await api.removeServer(server);

        expect(result.isOk(), isTrue);
        expect(fakeBox.get(server.id), isNull);
      });
    });

    group('updateServer', () {
      test('updates the server in the box', () async {
        final server = buildServer();
        final updated = Server(
          id: server.id,
          name: 'Updated',
          address: server.address,
          port: server.port,
          password: server.password,
        );
        final fakeBox = FakeBox<Server>(initialValues: {server.id: server});
        final api = ServersApi(box: fakeBox);

        final result = await api.updateServer(updated);

        expect(result.isOk(), isTrue);
        expect(fakeBox.get(server.id), equals(updated));
      });

      test('returns an error when the box update fails', () async {
        final server = buildServer();
        final error = Exception('update failed');
        final fakeBox = FakeBox<Server>(onPut: (_, _) => throw error);
        final api = ServersApi(box: fakeBox);

        final result = await api.updateServer(server);

        expect(result.unwrapErr(), same(error));
      });
    });

    group('clearServers', () {
      test('clears all servers from the box', () async {
        final server = buildServer();
        final fakeBox = FakeBox<Server>(initialValues: {server.id: server});
        final api = ServersApi(box: fakeBox);

        final result = await api.clearServers();

        expect(result.isOk(), isTrue);
        expect(fakeBox.values, isEmpty);
      });
    });
  });
}
