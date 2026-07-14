import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cs2_rcon_front_end/features/server_management/data/managed_private_key_store.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/selected_private_key.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/server_management_draft.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server_management_config.dart';
import 'package:cs2_rcon_front_end/features/servers/data/repository/servers_repository.dart';
import 'package:cs2_rcon_front_end/features/servers/domain/add_server.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxidized/oxidized.dart';

import '../../../fakes/fake_servers_api.dart';
import '../../../fakes/fake_settings_repository.dart';

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
    support = await Directory.systemTemp.createTemp('arkie-add-key-');
    store = ManagedPrivateKeyStore(applicationSupportDirectory: () async => support);
  });

  tearDown(() => support.delete(recursive: true));

  ServerManagementDraft draft() => ServerManagementDraft(
    backend: ServerManagementBackend.systemd,
    sshHost: 'server.example.com',
    sshPort: 22,
    sshUser: 'arkie-cs2',
    hostKeyFingerprint: 'SHA256:test',
    selectedPrivateKey: SelectedPrivateKey(
      displayName: 'id_ed25519',
      pemBytes: Uint8List.fromList(utf8.encode(_pem)),
    ),
  );

  Future<Result<Server, Exception>> add(AddServer subject) => subject(
    name: 'Server',
    address: '127.0.0.1',
    port: 27015,
    password: 'password',
    managementDraft: draft(),
  );

  test('successful persistence retains the imported key', () async {
    final api = FakeServersApi();
    final subject = AddServer(
      serversRepository: ServersRepository(api: api),
      settingsRepository: FakeSettingsRepository(),
      privateKeyStore: store,
    );
    await pumpEventQueue();

    final result = await add(subject);

    expect(result.isOk(), isTrue);
    final reference = result.unwrap().managementConfig!.privateKey!;
    expect(await store.read(reference.id), isNotEmpty);
  });

  test('persistence failure removes the newly imported key', () async {
    final api = FakeServersApi()..addServerResult = Result.err(Exception('failed'));
    final subject = AddServer(
      serversRepository: ServersRepository(api: api),
      settingsRepository: FakeSettingsRepository(),
      privateKeyStore: store,
    );
    await pumpEventQueue();

    final result = await add(subject);

    expect(result.isErr(), isTrue);
    final keyDirectory = Directory('${support.path}/ssh_keys');
    expect(keyDirectory.listSync(), isEmpty);
  });
}
