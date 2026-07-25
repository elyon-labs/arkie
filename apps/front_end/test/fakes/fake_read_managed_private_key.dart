import 'dart:typed_data';

import 'package:cs2_rcon_front_end/features/server_management/data/managed_private_key_store.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/read_managed_private_key.dart';
import 'package:oxidized/oxidized.dart';

import 'fake_managed_private_key_store.dart';

class FakeReadManagedPrivateKey extends ReadManagedPrivateKey {
  FakeReadManagedPrivateKey({Uint8List? bytes, ManagedPrivateKeyStorageException? error})
    : super(
        store: FakeManagedPrivateKeyStore(
          onReadKey: (_) async =>
              error == null ? Ok(bytes ?? Uint8List.fromList([1, 2, 3])) : Err(error),
        ),
      );
}
