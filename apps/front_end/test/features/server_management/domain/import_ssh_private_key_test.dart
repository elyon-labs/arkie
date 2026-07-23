import 'dart:typed_data';

import 'package:cs2_rcon_front_end/features/server_management/data/managed_private_key_store.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/import_ssh_private_key.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/managed_private_key_reference.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/selected_private_key.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oxidized/oxidized.dart';

import '../../../fakes/fake_managed_private_key_store.dart';

void main() {
  final selected = SelectedPrivateKey(
    displayName: 'id_ed25519',
    pemBytes: Uint8List.fromList([1, 2, 3]),
  );

  test('imports a selected key through the managed store', () async {
    const expected = ManagedPrivateKeyReference(id: 'id', displayName: 'id_ed25519');
    late SelectedPrivateKey imported;
    final subject = ImportSshPrivateKey(
      store: FakeManagedPrivateKeyStore(
        onImportKey: (value) async {
          imported = value;
          return const Ok(expected);
        },
      ),
    );

    final result = await subject(selected);

    expect(result.unwrap(), expected);
    expect(imported, same(selected));
  });

  test('returns a storage failure', () async {
    final subject = ImportSshPrivateKey(
      store: FakeManagedPrivateKeyStore(
        onImportKey: (_) async => const Err(ManagedPrivateKeyStorageException('failed')),
      ),
    );

    final result = await subject(selected);

    expect(result.unwrapErr().toString(), contains('failed'));
  });
}
