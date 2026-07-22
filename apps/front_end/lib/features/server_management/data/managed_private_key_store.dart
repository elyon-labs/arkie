import 'dart:io';
import 'dart:typed_data';

import 'package:cs2_rcon_front_end/features/server_management/domain/models/managed_private_key_reference.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/selected_private_key.dart';
import 'package:oxidized/oxidized.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

typedef ApplicationSupportDirectoryProvider = Future<Directory> Function();
typedef ManagedPrivateKeyIdProvider = String Function();
typedef SetPathPermissions =
    Future<Result<void, ManagedPrivateKeyStorageException>> Function(String target, String mode);

class ManagedPrivateKeyStore {
  ManagedPrivateKeyStore({
    ApplicationSupportDirectoryProvider? applicationSupportDirectory,
    ManagedPrivateKeyIdProvider? createId,
    SetPathPermissions? setPathPermissions,
    bool? isWindows,
  }) : _applicationSupportDirectory = applicationSupportDirectory ?? getApplicationSupportDirectory,
       _createId = createId ?? const Uuid().v4,
       _setPathPermissions = setPathPermissions ?? _setUnixPermissions,
       _isWindows = isWindows ?? Platform.isWindows;

  final ApplicationSupportDirectoryProvider _applicationSupportDirectory;
  final ManagedPrivateKeyIdProvider _createId;
  final SetPathPermissions _setPathPermissions;
  final bool _isWindows;

  Future<Result<ManagedPrivateKeyReference, ManagedPrivateKeyStorageException>> importKey(
    SelectedPrivateKey selected,
  ) async {
    File? temporary;
    try {
      final id = _createId();
      if (!_isValidId(id)) {
        return const Err(
          ManagedPrivateKeyStorageException('Arkie generated an invalid private key identifier.'),
        );
      }

      final directoryResult = await _keyDirectory();
      if (directoryResult.isErr()) {
        return const Err(
          ManagedPrivateKeyStorageException('Arkie could not import the selected private key.'),
        );
      }

      final directory = directoryResult.unwrap();
      temporary = File(path.join(directory.path, '.$id.tmp'));
      final destination = File(path.join(directory.path, id));
      if (destination.existsSync()) {
        return const Err(
          ManagedPrivateKeyStorageException('Arkie could not import the selected private key.'),
        );
      }

      await temporary.writeAsBytes(selected.pemBytes, flush: true);
      final permissionResult = await _secure(temporary.path, '600');
      if (permissionResult.isErr()) {
        await _deleteIfPresent(temporary);
        return const Err(
          ManagedPrivateKeyStorageException('Arkie could not import the selected private key.'),
        );
      }
      await temporary.rename(destination.path);

      return Ok(ManagedPrivateKeyReference(id: id, displayName: selected.displayName));
    } on Exception {
      if (temporary != null) {
        await _deleteIfPresent(temporary);
      }
      return const Err(
        ManagedPrivateKeyStorageException('Arkie could not import the selected private key.'),
      );
    }
  }

  Future<Result<Uint8List, ManagedPrivateKeyStorageException>> readKey(String id) async {
    if (!_isValidId(id)) {
      return const Err(
        ManagedPrivateKeyStorageException('Invalid managed private key identifier.'),
      );
    }

    try {
      final directoryResult = await _keyDirectory();
      if (directoryResult.isErr()) {
        return const Err(
          ManagedPrivateKeyStorageException('Arkie could not read the managed private key.'),
        );
      }

      final file = File(path.join(directoryResult.unwrap().path, id));
      if (!file.existsSync()) {
        return const Err(
          ManagedPrivateKeyStorageException('Arkie could not find the managed private key.'),
        );
      }
      return Ok(await file.readAsBytes());
    } on Exception {
      return const Err(
        ManagedPrivateKeyStorageException('Arkie could not read the managed private key.'),
      );
    }
  }

  Future<Result<void, ManagedPrivateKeyStorageException>> deleteKey(String id) async {
    if (!_isValidId(id)) {
      return const Err(
        ManagedPrivateKeyStorageException('Invalid managed private key identifier.'),
      );
    }

    try {
      final directoryResult = await _keyDirectory();
      if (directoryResult.isErr()) {
        return const Err(
          ManagedPrivateKeyStorageException('Arkie could not delete the managed private key.'),
        );
      }

      final file = File(path.join(directoryResult.unwrap().path, id));
      if (file.existsSync()) {
        await file.delete();
      }
      return const Ok(null);
    } on Exception {
      return const Err(
        ManagedPrivateKeyStorageException('Arkie could not delete the managed private key.'),
      );
    }
  }

  Future<Result<Directory, ManagedPrivateKeyStorageException>> _keyDirectory() async {
    try {
      final supportDirectory = await _applicationSupportDirectory();
      final directory = Directory(path.join(supportDirectory.path, 'ssh_keys'));
      await directory.create(recursive: true);
      final permissionResult = await _secure(directory.path, '700');
      if (permissionResult.isErr()) {
        return Err(permissionResult.unwrapErr());
      }
      return Ok(directory);
    } on Exception {
      return const Err(
        ManagedPrivateKeyStorageException('Arkie could not prepare private key storage.'),
      );
    }
  }

  Future<Result<void, ManagedPrivateKeyStorageException>> _secure(
    String target,
    String mode,
  ) async {
    if (_isWindows) {
      return const Ok(null);
    }

    try {
      return await _setPathPermissions(target, mode);
    } on Exception {
      return const Err(
        ManagedPrivateKeyStorageException('Arkie could not secure managed private key storage.'),
      );
    }
  }

  Future<void> _deleteIfPresent(File file) async {
    try {
      if (file.existsSync()) {
        await file.delete();
      }
    } on Exception {
      // Cleanup must not replace the operation's original failure.
    }
  }

  bool _isValidId(String id) {
    final uuid = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
    );
    return uuid.hasMatch(id) && path.basename(id) == id;
  }

  static Future<Result<void, ManagedPrivateKeyStorageException>> _setUnixPermissions(
    String target,
    String mode,
  ) async {
    try {
      final result = await Process.run('chmod', [mode, target]);
      if (result.exitCode != 0) {
        return const Err(
          ManagedPrivateKeyStorageException('Arkie could not secure managed private key storage.'),
        );
      }
      return const Ok(null);
    } on Exception {
      return const Err(
        ManagedPrivateKeyStorageException('Arkie could not secure managed private key storage.'),
      );
    }
  }
}

class ManagedPrivateKeyStorageException implements Exception {
  const ManagedPrivateKeyStorageException(this.message);

  final String message;

  @override
  String toString() => message;
}
