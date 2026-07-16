import 'package:cs2_rcon_front_end/features/server_management/domain/delete_managed_private_key.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/managed_private_key_reference.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fakes/fake_managed_private_key_store.dart';

void main() {
  const reference = ManagedPrivateKeyReference(id: 'key-id', displayName: 'id_ed25519');

  test('deletes a key through the managed store', () async {
    String? deletedId;
    final subject = DeleteManagedPrivateKey(
      store: FakeManagedPrivateKeyStore(onDeleteKey: (id) async => deletedId = id),
    );

    final result = await subject(reference);

    expect(result.isOk(), isTrue);
    expect(deletedId, 'key-id');
  });

  test('returns a storage failure', () async {
    final subject = DeleteManagedPrivateKey(
      store: FakeManagedPrivateKeyStore(onDeleteKey: (_) async => throw Exception('failed')),
    );

    final result = await subject(reference);

    expect(result.unwrapErr().toString(), contains('failed'));
  });
}
