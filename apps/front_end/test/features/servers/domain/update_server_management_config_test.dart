import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cs2_rcon_front_end/features/server_management/data/managed_private_key_store.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/selected_private_key.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/server_management_draft.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server_management_config.dart';
import 'package:cs2_rcon_front_end/features/servers/data/repository/servers_repository.dart';
import 'package:cs2_rcon_front_end/features/servers/domain/update_server_management_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxidized/oxidized.dart';

import '../../../fakes/fake_servers_api.dart';

const _pem = '''-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACBpPal4/3f/qxFl7ugsT3C5YguwYJy66BqZZfjbVrh/LwAAAKjvACB47wAg
eAAAAAtzc2gtZWQyNTUxOQAAACBpPal4/3f/qxFl7ugsT3C5YguwYJy66BqZZfjbVrh/Lw
AAAEDA7onKLSmNPmz6svkb0EGkIFPgSpTablugz25qALF4f2k9qXj/d/+rEWXu6CxPcLli
C7BgnLroGpll+NtWuH8vAAAAIWJyYW5kb250cmF1dG1hbm5AYnJhbmRvbnMtbWFjYm9vaw
ECAwQ=
-----END OPENSSH PRIVATE KEY-----''';

void main() {
  late Directory support;
  late ManagedPrivateKeyStore store;

  setUp(() async {
    support = await Directory.systemTemp.createTemp('arkie-update-key-');
    store = ManagedPrivateKeyStore(applicationSupportDirectory: () async => support);
  });

  tearDown(() => support.delete(recursive: true));

  ServerManagementDraft draft({SelectedPrivateKey? selected}) => ServerManagementDraft(
    backend: ServerManagementBackend.systemd,
    sshHost: 'server.example.com',
    sshPort: 22,
    sshUser: 'arkie-cs2',
    hostKeyFingerprint: 'SHA256:test',
    selectedPrivateKey: selected,
  );

  SelectedPrivateKey selected(String name) =>
      SelectedPrivateKey(displayName: name, pemBytes: Uint8List.fromList(utf8.encode(_pem)));

  Future<Server> managedServer() async {
    final reference = await store.import(selected('old-key'));
    return Server.create(
      name: 'Server',
      address: '127.0.0.1',
      port: 27015,
      password: 'password',
      managementConfig: ServerManagementConfig(
        backend: ServerManagementBackend.systemd,
        sshHost: 'old.example.com',
        sshPort: 22,
        sshUser: 'old-user',
        hostKeyFingerprint: 'SHA256:old',
        privateKey: reference,
      ),
    );
  }

  test('edits fields while retaining a usable key', () async {
    final server = await managedServer();
    final oldReference = server.managementConfig!.privateKey!;
    final api = FakeServersApi(initialServers: [server]);
    final update = UpdateServerManagementConfig(
      serversRepository: ServersRepository(api: api),
      privateKeyStore: store,
    );
    await pumpEventQueue();

    final result = await update(server: server, enabled: true, draft: draft());

    expect(result.isOk(), isTrue);
    final saved = (await api.fetchServers()).single;
    expect(saved.managementConfig?.privateKey, oldReference);
    expect(saved.managementConfig?.sshHost, 'server.example.com');
    expect(await store.read(oldReference.id), isNotEmpty);
  });

  test('replacement swaps references and deletes the old key', () async {
    final server = await managedServer();
    final oldReference = server.managementConfig!.privateKey!;
    final api = FakeServersApi(initialServers: [server]);
    final update = UpdateServerManagementConfig(
      serversRepository: ServersRepository(api: api),
      privateKeyStore: store,
    );
    await pumpEventQueue();

    final result = await update(
      server: server,
      enabled: true,
      draft: draft(selected: selected('new-key')),
    );

    expect(result.isOk(), isTrue);
    final newReference = (await api.fetchServers()).single.managementConfig!.privateKey!;
    expect(newReference, isNot(oldReference));
    expect(newReference.displayName, 'new-key');
    expect(store.read(oldReference.id), throwsA(isA<ManagedPrivateKeyException>()));
    expect(await store.read(newReference.id), isNotEmpty);
  });

  test('persistence failure removes the replacement and preserves old configuration', () async {
    final server = await managedServer();
    final oldReference = server.managementConfig!.privateKey!;
    final api = FakeServersApi(initialServers: [server])
      ..updateServerResult = Result.err(Exception('failed'));
    final update = UpdateServerManagementConfig(
      serversRepository: ServersRepository(api: api),
      privateKeyStore: store,
    );
    await pumpEventQueue();

    final result = await update(
      server: server,
      enabled: true,
      draft: draft(selected: selected('new-key')),
    );

    expect(result.isErr(), isTrue);
    expect((await api.fetchServers()).single, server);
    expect(await store.read(oldReference.id), isNotEmpty);
    expect(Directory('${support.path}/ssh_keys').listSync().whereType<File>(), hasLength(1));
  });

  test('disabling persists null configuration before deleting its key', () async {
    final server = await managedServer();
    final oldReference = server.managementConfig!.privateKey!;
    final api = FakeServersApi(initialServers: [server]);
    final update = UpdateServerManagementConfig(
      serversRepository: ServersRepository(api: api),
      privateKeyStore: store,
    );
    await pumpEventQueue();

    final result = await update(server: server, enabled: false);

    expect(result.isOk(), isTrue);
    expect((await api.fetchServers()).single.managementConfig, isNull);
    expect(store.read(oldReference.id), throwsA(isA<ManagedPrivateKeyException>()));
  });
}
