import 'dart:io';
import 'dart:typed_data';

import 'package:cs2_rcon_front_end/features/server_management/domain/models/managed_private_key_reference.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/selected_private_key.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

typedef ApplicationSupportDirectoryProvider = Future<Directory> Function();
typedef ManagedPrivateKeyIdProvider = String Function();
typedef SetPathPermissions = Future<void> Function(String target, String mode);

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

  Future<ManagedPrivateKeyReference> importKey(SelectedPrivateKey selected) async {
    final id = _createId();
    _validateId(id);

    File? temporary;
    try {
      final directory = await _keyDirectory();
      temporary = File(path.join(directory.path, '.$id.tmp'));
      final destination = File(path.join(directory.path, id));
      if (destination.existsSync()) {
        throw const ManagedPrivateKeyStorageException(
          'Arkie could not allocate managed private key storage.',
        );
      }

      await temporary.writeAsBytes(selected.pemBytes, flush: true);
      await _secure(temporary.path, '600');
      await temporary.rename(destination.path);

      return ManagedPrivateKeyReference(id: id, displayName: selected.displayName);
    } on Exception {
      if (temporary != null) {
        await _deleteIfPresent(temporary);
      }
      throw const ManagedPrivateKeyStorageException(
        'Arkie could not import the selected private key.',
      );
    }
  }

  Future<Uint8List> readKey(String id) async {
    _validateId(id);

    try {
      final file = File(path.join((await _keyDirectory()).path, id));
      if (!file.existsSync()) {
        throw const ManagedPrivateKeyStorageException(
          'Arkie could not find the managed private key.',
        );
      }
      return file.readAsBytes();
    } on ManagedPrivateKeyStorageException {
      rethrow;
    } on Exception {
      throw const ManagedPrivateKeyStorageException(
        'Arkie could not read the managed private key.',
      );
    }
  }

  Future<void> deleteKey(String id) async {
    _validateId(id);

    try {
      final file = File(path.join((await _keyDirectory()).path, id));
      if (file.existsSync()) {
        await file.delete();
      }
    } on Exception {
      throw const ManagedPrivateKeyStorageException(
        'Arkie could not delete the managed private key.',
      );
    }
  }

  Future<Directory> _keyDirectory() async {
    final supportDirectory = await _applicationSupportDirectory();
    final directory = Directory(path.join(supportDirectory.path, 'ssh_keys'));
    await directory.create(recursive: true);
    await _secure(directory.path, '700');
    return directory;
  }

  Future<void> _secure(String target, String mode) async {
    if (!_isWindows) {
      await _setPathPermissions(target, mode);
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

  void _validateId(String id) {
    final uuid = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
    );
    if (!uuid.hasMatch(id) || path.basename(id) != id) {
      throw ArgumentError.value(id, 'id', 'Invalid managed private key identifier');
    }
  }

  static Future<void> _setUnixPermissions(String target, String mode) async {
    final result = await Process.run('chmod', [mode, target]);
    if (result.exitCode != 0) {
      throw const ManagedPrivateKeyStorageException(
        'Arkie could not secure managed private key storage.',
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
