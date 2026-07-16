import 'package:cs2_rcon_front_end/di/graph.dart';
import 'package:cs2_rcon_front_end/features/server_management/data/managed_private_key_store.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/managed_private_key_reference.dart';
import 'package:oxidized/oxidized.dart';

class DeleteManagedPrivateKey {
  const DeleteManagedPrivateKey({required ManagedPrivateKeyStore store}) : _store = store;

  factory DeleteManagedPrivateKey.create() => DeleteManagedPrivateKey(store: inject());

  final ManagedPrivateKeyStore _store;

  Future<Result<void, Exception>> call(ManagedPrivateKeyReference reference) async {
    try {
      await _store.deleteKey(reference.id);
      return const Result.ok(null);
    } on Exception catch (error) {
      return Result.err(error);
    }
  }
}
