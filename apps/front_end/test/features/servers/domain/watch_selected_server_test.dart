import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:cs2_rcon_front_end/features/servers/data/repository/servers_repository.dart';
import 'package:cs2_rcon_front_end/features/servers/domain/watch_selected_server.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fakes/fake_servers_api.dart';
import '../../../fakes/fake_settings_repository.dart';

void main() {
  group('WatchSelectedServer', () {
    Server buildServer({
      String name = 'Test Server',
      String address = '127.0.0.1',
      int port = 27015,
      String password = 'password',
    }) {
      return Server.create(name: name, password: password, address: address, port: port);
    }

    test('emits null when no server is selected', () async {
      final server = buildServer();
      final api = FakeServersApi(initialServers: [server]);
      final repository = ServersRepository(api: api);
      final settingsRepository = FakeSettingsRepository(selectedServerId: null);
      final watchSelectedServer = WatchSelectedServer(
        repository: repository,
        settingsRepository: settingsRepository,
      );

      final selected = await watchSelectedServer().first;

      expect(selected, isNull);
    });

    test('emits the selected server when one exists', () async {
      final serverA = buildServer(name: 'A');
      final serverB = buildServer(name: 'B');
      final api = FakeServersApi(initialServers: [serverA, serverB]);
      final repository = ServersRepository(api: api);
      final settingsRepository = FakeSettingsRepository(selectedServerId: serverB.id);
      final watchSelectedServer = WatchSelectedServer(
        repository: repository,
        settingsRepository: settingsRepository,
      );

      await pumpEventQueue();

      final selected = await watchSelectedServer().first;

      expect(selected, serverB);
    });

    test('emits null when selected server id is not found', () async {
      final server = buildServer();
      final api = FakeServersApi(initialServers: [server]);
      final repository = ServersRepository(api: api);
      final settingsRepository = FakeSettingsRepository(selectedServerId: 'missing');
      final watchSelectedServer = WatchSelectedServer(
        repository: repository,
        settingsRepository: settingsRepository,
      );

      await pumpEventQueue();

      final selected = await watchSelectedServer().first;

      expect(selected, isNull);
    });
  });
}
