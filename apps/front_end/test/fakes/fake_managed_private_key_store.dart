import 'dart:typed_data';

import 'package:cs2_rcon_front_end/features/server_management/data/managed_private_key_store.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/managed_private_key_reference.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/selected_private_key.dart';
import 'package:oxidized/oxidized.dart';

class FakeManagedPrivateKeyStore implements ManagedPrivateKeyStore {
  FakeManagedPrivateKeyStore({this.onImportKey, this.onReadKey, this.onDeleteKey});

  final Future<Result<ManagedPrivateKeyReference, ManagedPrivateKeyStorageException>> Function(
    SelectedPrivateKey selected,
  )?
  onImportKey;
  final Future<Result<Uint8List, ManagedPrivateKeyStorageException>> Function(String id)? onReadKey;
  final Future<Result<void, ManagedPrivateKeyStorageException>> Function(String id)? onDeleteKey;

  @override
  Future<Result<ManagedPrivateKeyReference, ManagedPrivateKeyStorageException>> importKey(
    SelectedPrivateKey selected,
  ) {
    return onImportKey?.call(selected) ?? (throw UnimplementedError());
  }

  @override
  Future<Result<Uint8List, ManagedPrivateKeyStorageException>> readKey(String id) {
    return onReadKey?.call(id) ?? (throw UnimplementedError());
  }

  @override
  Future<Result<void, ManagedPrivateKeyStorageException>> deleteKey(String id) async {
    return await onDeleteKey?.call(id) ?? const Ok(null);
  }
}
