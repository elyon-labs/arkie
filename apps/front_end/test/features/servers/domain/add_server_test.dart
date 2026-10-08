import 'package:cs2_rcon_front_end/features/servers/data/repository/servers_repository.dart';
import 'package:cs2_rcon_front_end/features/servers/domain/add_server.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxidized/oxidized.dart';

import '../../../fakes/fake_servers_api.dart';
import '../../../fakes/fake_settings_repository.dart';

void main() {
  test('persists the server and selects it when it is the first one', () async {
    final harness = await _Harness.create();
    addTearDown(harness.dispose);

    final result = await harness.subject(
      name: 'First server',
      address: '127.0.0.1',
      port: 27015,
      password: 'secret',
    );

    final server = result.unwrap();
    expect(harness.api.addServerCallCount, 1);
    expect(await harness.settings.watchSelectedServer().first, server.id);
  });

  test('leaves the selection alone when a server already exists', () async {
    final harness = await _Harness.create();
    addTearDown(harness.dispose);
    final first = (await harness.subject(
      name: 'First server',
      address: '127.0.0.1',
      port: 27015,
      password: 'secret',
    )).unwrap();

    await harness.subject(
      name: 'Second server',
      address: '127.0.0.2',
      port: 27015,
      password: 'secret',
    );

    expect(harness.api.addServerCallCount, 2);
    expect(await harness.settings.watchSelectedServer().first, first.id);
  });

  test('propagates a persistence failure', () async {
    final harness = await _Harness.create();
    addTearDown(harness.dispose);
    final persistenceError = Exception('persistence failed');
    harness.api.addServerResult = Err(persistenceError);

    final result = await harness.subject(
      name: 'Server',
      address: '127.0.0.1',
      port: 27015,
      password: 'secret',
    );

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

  static Future<_Harness> create() async {
    final api = FakeServersApi();
    final repository = ServersRepository(api: api);
    await repository.refresh();
    final settings = FakeSettingsRepository();
    return _Harness(
      subject: AddServer(serversRepository: repository, settingsRepository: settings),
      repository: repository,
      settings: settings,
      api: api,
    );
  }

  final AddServer subject;
  final ServersRepository repository;
  final FakeSettingsRepository settings;
  final FakeServersApi api;

  Future<void> dispose() async {
    await repository.dispose();
    await settings.dispose();
  }
}
