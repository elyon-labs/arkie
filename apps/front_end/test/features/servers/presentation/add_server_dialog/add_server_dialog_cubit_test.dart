import 'package:cs2_rcon_front_end/core/async.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/connection_cache.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/connect.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/drop_connection.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/save_connection.dart';
import 'package:cs2_rcon_front_end/features/servers/data/repository/servers_repository.dart';
import 'package:cs2_rcon_front_end/features/servers/domain/add_server.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/add_server_dialog/add_server_dialog_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fakes/fake_get_socket.dart';
import '../../../../fakes/fake_servers_api.dart';
import '../../../../fakes/fake_settings_repository.dart';

void main() {
  test('rejects an invalid address without persisting', () async {
    final harness = await _Harness.create();
    addTearDown(harness.dispose);
    final cubit = harness.cubit;
    _fillValidFields(cubit);
    cubit.setAddress('not a host');

    await cubit.saveServer();

    expect(cubit.state.addServerResult.error.unwrap(), 'Invalid address');
    expect(harness.api.addServerCallCount, 0);
  });

  test('rejects an out-of-range port without persisting', () async {
    final harness = await _Harness.create();
    addTearDown(harness.dispose);
    final cubit = harness.cubit;
    _fillValidFields(cubit);
    cubit.setPort(70000);

    await cubit.saveServer();

    expect(cubit.state.addServerResult.error.unwrap(), 'Invalid port');
    expect(harness.api.addServerCallCount, 0);
  });

  test('rejects an empty password without persisting', () async {
    final harness = await _Harness.create();
    addTearDown(harness.dispose);
    final cubit = harness.cubit;
    _fillValidFields(cubit);
    cubit.setPassword('');

    await cubit.saveServer();

    expect(cubit.state.addServerResult.error.unwrap(), 'Password cannot be empty');
    expect(harness.api.addServerCallCount, 0);
  });

  test('rejects an empty name without persisting', () async {
    final harness = await _Harness.create();
    addTearDown(harness.dispose);
    final cubit = harness.cubit;
    _fillValidFields(cubit);
    cubit.setName('');

    await cubit.saveServer();

    expect(cubit.state.addServerResult.error.unwrap(), 'Name cannot be empty');
    expect(harness.api.addServerCallCount, 0);
  });

  test('persists the server once every field is valid', () async {
    final harness = await _Harness.create();
    addTearDown(harness.dispose);
    final cubit = harness.cubit;
    _fillValidFields(cubit);

    await cubit.saveServer();

    expect(cubit.state.addServerResult.isLoaded, isTrue);
    expect(harness.api.addServerCallCount, 1);
  });
}

void _fillValidFields(AddServerDialogCubit cubit) {
  cubit
    ..setName('Server')
    ..setAddress('127.0.0.1')
    ..setPort(27015)
    ..setPassword('secret');
}

class _Harness {
  _Harness({
    required this.cubit,
    required this.repository,
    required this.settings,
    required this.api,
  });

  static Future<_Harness> create() async {
    final api = FakeServersApi();
    final repository = ServersRepository(api: api);
    await repository.refresh();
    final settings = FakeSettingsRepository();
    final cache = ConnectionCache();
    final connect = Connect(
      getSocket: FakeGetSocket(),
      removeSocket: DropConnection(connectionCache: cache),
      addSocket: SaveConnection(connectionCache: cache),
    );
    return _Harness(
      cubit: AddServerDialogCubit(
        addServer: AddServer(serversRepository: repository, settingsRepository: settings),
        connect: connect,
      ),
      repository: repository,
      settings: settings,
      api: api,
    );
  }

  final AddServerDialogCubit cubit;
  final ServersRepository repository;
  final FakeSettingsRepository settings;
  final FakeServersApi api;

  Future<void> dispose() async {
    await cubit.close();
    await repository.dispose();
    await settings.dispose();
  }
}
