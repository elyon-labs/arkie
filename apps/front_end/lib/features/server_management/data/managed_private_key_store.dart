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
    final result = await Result.asyncOf<ManagedPrivateKeyReference, Exception>(() async {
      final id = _createId();
      _validateId(
        id,
        const ManagedPrivateKeyStorageException(
          'Arkie generated an invalid private key identifier.',
        ),
      ).unwrap();

      final directoryResult = await _keyDirectory();
      if (directoryResult.isErr()) {
        throw const ManagedPrivateKeyStorageException(
          'Arkie could not import the selected private key.',
        );
      }

      final directory = directoryResult.unwrap();
      final temporaryFile = File(path.join(directory.path, '.$id.tmp'));
      temporary = temporaryFile;
      final destination = File(path.join(directory.path, id));
      if (destination.existsSync()) {
        throw const ManagedPrivateKeyStorageException(
          'Arkie could not import the selected private key.',
        );
      }

      await temporaryFile.writeAsBytes(selected.pemBytes, flush: true);
      final permissionResult = await _secure(temporaryFile.path, '600');
      if (permissionResult.isErr()) {
        throw const ManagedPrivateKeyStorageException(
          'Arkie could not import the selected private key.',
        );
      }
      await temporaryFile.rename(destination.path);

      return ManagedPrivateKeyReference(id: id, displayName: selected.displayName);
    });

    final cleanupFile = temporary;
    if (result.isErr() && cleanupFile != null) {
      await _deleteIfPresent(cleanupFile);
    }

    return result.mapErr(
      (error) => error is ManagedPrivateKeyStorageException
          ? error
          : const ManagedPrivateKeyStorageException(
              'Arkie could not import the selected private key.',
            ),
    );
  }

  Future<Result<Uint8List, ManagedPrivateKeyStorageException>> readKey(String id) async {
    final validationResult = _validateId(
      id,
      const ManagedPrivateKeyStorageException('Invalid managed private key identifier.'),
    );
    if (validationResult.isErr()) {
      return Err(validationResult.unwrapErr());
    }

    final result = await Result.asyncOf<Uint8List, Exception>(() async {
      final directoryResult = await _keyDirectory();
      if (directoryResult.isErr()) {
        throw const ManagedPrivateKeyStorageException(
          'Arkie could not read the managed private key.',
        );
      }

      final file = File(path.join(directoryResult.unwrap().path, id));
      if (!file.existsSync()) {
        throw const ManagedPrivateKeyStorageException(
          'Arkie could not find the managed private key.',
        );
      }
      return file.readAsBytes();
    });

    return result.mapErr(
      (error) => error is ManagedPrivateKeyStorageException
          ? error
          : const ManagedPrivateKeyStorageException(
              'Arkie could not read the managed private key.',
            ),
    );
  }

  Future<Result<void, ManagedPrivateKeyStorageException>> deleteKey(String id) async {
    final validationResult = _validateId(
      id,
      const ManagedPrivateKeyStorageException('Invalid managed private key identifier.'),
    );
    if (validationResult.isErr()) {
      return Err(validationResult.unwrapErr());
    }

    final result = await Result.asyncOf<void, Exception>(() async {
      final directoryResult = await _keyDirectory();
      if (directoryResult.isErr()) {
        throw const ManagedPrivateKeyStorageException(
          'Arkie could not delete the managed private key.',
        );
      }

      final file = File(path.join(directoryResult.unwrap().path, id));
      if (file.existsSync()) {
        await file.delete();
      }
    });

    return result.mapErr(
      (_) => const ManagedPrivateKeyStorageException(
        'Arkie could not delete the managed private key.',
      ),
    );
  }

  Future<Result<Directory, ManagedPrivateKeyStorageException>> _keyDirectory() async {
    final result = await Result.asyncOf<Directory, Exception>(() async {
      final supportDirectory = await _applicationSupportDirectory();
      final directory = Directory(path.join(supportDirectory.path, 'ssh_keys'));
      await directory.create(recursive: true);
      (await _secure(directory.path, '700')).unwrap();
      return directory;
    });

    return result.mapErr(
      (_) =>
          const ManagedPrivateKeyStorageException('Arkie could not prepare private key storage.'),
    );
  }

  Future<Result<void, ManagedPrivateKeyStorageException>> _secure(
    String target,
    String mode,
  ) async {
    if (_isWindows) {
      return const Ok(null);
    }

    final result = await Result.asyncOf<void, Exception>(() async {
      (await _setPathPermissions(target, mode)).unwrap();
    });

    return result.mapErr(
      (_) => const ManagedPrivateKeyStorageException(
        'Arkie could not secure managed private key storage.',
      ),
    );
  }

  Future<Result<void, Exception>> _deleteIfPresent(File file) {
    return Result.asyncOf(() async {
      if (file.existsSync()) {
        await file.delete();
      }
    });
  }

  Result<void, ManagedPrivateKeyStorageException> _validateId(
    String id,
    ManagedPrivateKeyStorageException error,
  ) {
    return Result<void, ManagedPrivateKeyStorageException>.of(() {
      final uuid = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
      );
      if (!uuid.hasMatch(id) || path.basename(id) != id) {
        throw error;
      }
    });
  }

  static Future<Result<void, ManagedPrivateKeyStorageException>> _setUnixPermissions(
    String target,
    String mode,
  ) async {
    final permissionResult = await Result.asyncOf<void, Exception>(() async {
      final result = await Process.run('chmod', [mode, target]);
      if (result.exitCode != 0) {
        throw const ManagedPrivateKeyStorageException(
          'Arkie could not secure managed private key storage.',
        );
      }
    });

    return permissionResult.mapErr(
      (_) => const ManagedPrivateKeyStorageException(
        'Arkie could not secure managed private key storage.',
      ),
    );
  }
}

class ManagedPrivateKeyStorageException implements Exception {
  const ManagedPrivateKeyStorageException(this.message);

  final String message;

  @override
  String toString() => message;
}
