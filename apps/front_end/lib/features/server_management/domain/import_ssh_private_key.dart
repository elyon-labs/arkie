import 'package:cs2_rcon_front_end/di/graph.dart';
import 'package:cs2_rcon_front_end/features/server_management/data/managed_private_key_store.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/managed_private_key_reference.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/selected_private_key.dart';
import 'package:oxidized/oxidized.dart';

class ImportSshPrivateKey {
  const ImportSshPrivateKey({required ManagedPrivateKeyStore store}) : _store = store;

  factory ImportSshPrivateKey.create() => ImportSshPrivateKey(store: inject());

  final ManagedPrivateKeyStore _store;

  Future<Result<ManagedPrivateKeyReference, Exception>> call(SelectedPrivateKey selected) async {
    try {
      return Result.ok(await _store.importKey(selected));
    } on Exception catch (error) {
      return Result.err(error);
    }
  }
}
