import 'dart:typed_data';

import 'package:cs2_rcon_front_end/di/graph.dart';
import 'package:cs2_rcon_front_end/features/server_management/data/managed_private_key_store.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/managed_private_key_reference.dart';
import 'package:oxidized/oxidized.dart';

class ReadManagedPrivateKey {
  const ReadManagedPrivateKey({required ManagedPrivateKeyStore store}) : _store = store;

  factory ReadManagedPrivateKey.create() => ReadManagedPrivateKey(store: inject());

  final ManagedPrivateKeyStore _store;

  Future<Result<Uint8List, Exception>> call(ManagedPrivateKeyReference reference) async {
    try {
      return Result.ok(await _store.readKey(reference.id));
    } on Exception catch (error) {
      return Result.err(error);
    }
  }
}
