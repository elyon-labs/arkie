import 'dart:typed_data';

import 'package:cs2_rcon_front_end/features/server_management/domain/models/managed_private_key_reference.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/read_managed_private_key.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fakes/fake_managed_private_key_store.dart';

void main() {
  const reference = ManagedPrivateKeyReference(id: 'key-id', displayName: 'id_ed25519');

  test('reads key bytes through the managed store', () async {
    String? readId;
    final subject = ReadManagedPrivateKey(
      store: FakeManagedPrivateKeyStore(
        onReadKey: (id) async {
          readId = id;
          return Uint8List.fromList([1, 2, 3]);
        },
      ),
    );

    final result = await subject(reference);

    expect(readId, 'key-id');
    expect(result.unwrap(), [1, 2, 3]);
  });

  test('returns a storage failure', () async {
    final subject = ReadManagedPrivateKey(
      store: FakeManagedPrivateKeyStore(onReadKey: (_) async => throw Exception('failed')),
    );

    final result = await subject(reference);

    expect(result.unwrapErr().toString(), contains('failed'));
  });
}
