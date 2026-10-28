import 'package:arkie_core/features/servers/data/models/server.dart';
import 'package:arkie_core/features/servers/data/repository/servers_repository.dart';
import 'package:arkie_core/features/servers/domain/add_demo_server.dart';
import 'package:arkie_core/testing/fake_servers_api.dart';
import 'package:arkie_core/testing/fake_settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxidized/oxidized.dart';

void main() {
  test('persists the demo server and selects it when it is the first one', () async {
    final harness = await _Harness.create();
    addTearDown(harness.dispose);

    final server = (await harness.subject()).unwrap();

    expect(server.isDemo, isTrue);
    expect(harness.api.addDemoServerCallCount, 1);
    expect(await harness.settings.watchSelectedServer().first, server.id);
  });

  test('hands back the same demo server when asked twice', () async {
    final harness = await _Harness.create();
    addTearDown(harness.dispose);
    final first = (await harness.subject()).unwrap();

    final second = (await harness.subject()).unwrap();

    expect(second.id, first.id);
    expect(await harness.repository.getServers(), hasLength(1));
  });

  test('leaves the selection alone when a server already exists', () async {
    final existing = Server.create(
      name: 'Real server',
      address: '127.0.0.1',
      port: 27015,
      password: 'secret',
    );
    final harness = await _Harness.create(servers: [existing]);
    addTearDown(harness.dispose);

    await harness.subject();

    expect(await harness.settings.watchSelectedServer().first, isNull);
    expect(await harness.repository.getServers(), hasLength(2));
  });

  test('propagates a persistence failure', () async {
    final harness = await _Harness.create();
    addTearDown(harness.dispose);
    final persistenceError = Exception('persistence failed');
    harness.api.addDemoServerResult = Err(persistenceError);

    final result = await harness.subject();

    expect(result.unwrapErr(), same(persistenceError));
    expect(await harness.settings.watchSelectedServer().first, isNull);
  });
}

class _Harness {
  _Harness({
    required this.subject,
    required this.repository,
    required this.settings,
    required this.api,
  });

  static Future<_Harness> create({List<Server>? servers}) async {
    final api = FakeServersApi(initialServers: servers);
    final repository = ServersRepository(api: api);
    await repository.refresh();
    final settings = FakeSettingsRepository();
    return _Harness(
      subject: AddDemoServer(serversRepository: repository, settingsRepository: settings),
      repository: repository,
      settings: settings,
      api: api,
    );
  }

  final AddDemoServer subject;
  final ServersRepository repository;
  final FakeSettingsRepository settings;
  final FakeServersApi api;

  Future<void> dispose() async {
    await repository.dispose();
    await settings.dispose();
  }
}
