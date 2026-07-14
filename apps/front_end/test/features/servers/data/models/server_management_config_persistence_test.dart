import 'dart:io';

import 'package:cs2_rcon_front_end/features/server_management/domain/models/private_key_health.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/managed_private_key_reference.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server_management_config.dart';
import 'package:cs2_rcon_front_end/hive/hive_adapters.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('arkie-hive-compat-');
    Hive.init(directory.path);
  });

  tearDown(() async {
    await Hive.close();
    Hive.resetAdapters();
    await directory.delete(recursive: true);
  });

  test(
    'pre-managed-key records deserialize with their path retained only as legacy data',
    () async {
      Hive
        ..registerAdapter(_LegacyConfigAdapter())
        ..registerAdapter(ServerManagementBackendAdapter());
      final legacyBox = await Hive.openBox<_LegacyConfig>('legacy');
      await legacyBox.put(
        'config',
        const _LegacyConfig(
          backend: ServerManagementBackend.systemd,
          sshHost: 'server.example.com',
          sshPort: 22,
          sshUser: 'arkie-cs2',
          privateKeyPath: '~/.ssh/id_ed25519',
          hostKeyFingerprint: 'SHA256:test',
        ),
      );
      await legacyBox.close();
      Hive.resetAdapters();
      Hive
        ..registerAdapter(ServerManagementConfigAdapter())
        ..registerAdapter(ServerManagementBackendAdapter())
        ..registerAdapter(ManagedPrivateKeyReferenceAdapter());

      final migratedBox = await Hive.openBox<ServerManagementConfig>('legacy');
      final config = migratedBox.get('config')!;

      expect(config.privateKey, isNull);
      expect(config.privateKeyPath, '~/.ssh/id_ed25519');
      final reason = config.privateKey == null && config.privateKeyPath != null
          ? PrivateKeyReplacementReason.legacyPath
          : null;
      expect(reason, PrivateKeyReplacementReason.legacyPath);
    },
  );

  test('new records round trip a managed reference and no external path', () async {
    Hive
      ..registerAdapter(ServerManagementConfigAdapter())
      ..registerAdapter(ServerManagementBackendAdapter())
      ..registerAdapter(ManagedPrivateKeyReferenceAdapter());
    final box = await Hive.openBox<ServerManagementConfig>('new');
    const expected = ServerManagementConfig(
      backend: ServerManagementBackend.systemd,
      sshHost: 'server.example.com',
      sshPort: 22,
      sshUser: 'arkie-cs2',
      hostKeyFingerprint: 'SHA256:test',
      privateKey: ManagedPrivateKeyReference(
        id: '123e4567-e89b-42d3-a456-426614174000',
        displayName: 'id_ed25519',
      ),
    );
    await box.put('config', expected);

    final actual = box.get('config')!;
    expect(actual.privateKey, expected.privateKey);
    expect(actual.privateKeyPath, isNull);
  });
}

class _LegacyConfig {
  const _LegacyConfig({
    required this.backend,
    required this.sshHost,
    required this.sshPort,
    required this.sshUser,
    required this.privateKeyPath,
    required this.hostKeyFingerprint,
  });

  final ServerManagementBackend backend;
  final String sshHost;
  final int sshPort;
  final String sshUser;
  final String privateKeyPath;
  final String hostKeyFingerprint;
}

class _LegacyConfigAdapter extends TypeAdapter<_LegacyConfig> {
  @override
  int get typeId => 4;

  @override
  _LegacyConfig read(BinaryReader reader) => throw UnimplementedError();

  @override
  void write(BinaryWriter writer, _LegacyConfig obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.backend)
      ..writeByte(1)
      ..write(obj.sshHost)
      ..writeByte(2)
      ..write(obj.sshPort)
      ..writeByte(3)
      ..write(obj.sshUser)
      ..writeByte(4)
      ..write(obj.privateKeyPath)
      ..writeByte(5)
      ..write(obj.hostKeyFingerprint);
  }
}
