import 'package:cs2_rcon_front_end/features/server_management/domain/models/managed_private_key_reference.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server_management_config.dart';
import 'package:cs2_rcon_front_end/hive/hive_adapters.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  group('ServerManagementConfigAdapter', () {
    test('ignores the retired private-key path field in a legacy record', () {
      final reader = _RecordingReader(
        bytes: [6, 0, 1, 2, 3, 4, 5],
        values: [
          ServerManagementBackend.systemd,
          'server.example.com',
          22,
          'arkie-cs2',
          '/private/legacy/id_ed25519',
          'fingerprint',
        ],
      );

      final config = ServerManagementConfigAdapter().read(reader);

      expect(config.privateKey, isNull);
      expect(config.sshHost, 'server.example.com');
      expect(config.hostKeyFingerprint, 'fingerprint');
    });

    test('round-trips a managed private-key reference on field 6', () {
      const config = ServerManagementConfig(
        backend: ServerManagementBackend.systemd,
        sshHost: 'server.example.com',
        sshPort: 2222,
        sshUser: 'operator',
        privateKey: ManagedPrivateKeyReference(id: 'managed-id', displayName: 'id_ed25519'),
        hostKeyFingerprint: 'fingerprint',
      );
      final writer = _RecordingWriter();

      ServerManagementConfigAdapter().write(writer, config);
      final restored = ServerManagementConfigAdapter().read(
        _RecordingReader(bytes: writer.bytes, values: writer.values),
      );

      expect(restored, config);
      expect(writer.bytes, [6, 0, 1, 2, 3, 5, 6]);
      expect(writer.bytes, isNot(contains(4)));
    });

    test('preserves all existing type ids and assigns the managed reference id 6', () {
      expect(ServerManagementConfigAdapter().typeId, 4);
      expect(ServerManagementBackendAdapter().typeId, 5);
      expect(ManagedPrivateKeyReferenceAdapter().typeId, 6);
    });
  });
}

class _RecordingReader implements BinaryReader {
  _RecordingReader({required List<int> bytes, required List<Object?> values})
    : _bytes = List<int>.from(bytes),
      _values = List<Object?>.from(values);

  final List<int> _bytes;
  final List<Object?> _values;

  @override
  int readByte() => _bytes.removeAt(0);

  @override
  dynamic read([int? typeId]) => _values.removeAt(0);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _RecordingWriter implements BinaryWriter {
  final List<int> bytes = [];
  final List<Object?> values = [];

  @override
  void writeByte(int byte) => bytes.add(byte);

  @override
  void write<T>(T value, {bool withTypeId = true}) => values.add(value);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
