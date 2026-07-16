import 'dart:typed_data';

import 'package:cs2_rcon_front_end/features/server_management/data/managed_private_key_store.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/managed_private_key_reference.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/selected_private_key.dart';

class FakeManagedPrivateKeyStore implements ManagedPrivateKeyStore {
  FakeManagedPrivateKeyStore({this.onImportKey, this.onReadKey, this.onDeleteKey});

  final Future<ManagedPrivateKeyReference> Function(SelectedPrivateKey selected)? onImportKey;
  final Future<Uint8List> Function(String id)? onReadKey;
  final Future<void> Function(String id)? onDeleteKey;

  @override
  Future<ManagedPrivateKeyReference> importKey(SelectedPrivateKey selected) {
    return onImportKey?.call(selected) ?? (throw UnimplementedError());
  }

  @override
  Future<Uint8List> readKey(String id) {
    return onReadKey?.call(id) ?? (throw UnimplementedError());
  }

  @override
  Future<void> deleteKey(String id) async {
    await onDeleteKey?.call(id);
  }
}
