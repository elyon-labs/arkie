import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cs2_rcon_front_end/features/server_management/domain/models/private_key_health.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/selected_private_key.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/managed_private_key_reference.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

typedef ApplicationSupportDirectoryProvider = Future<Directory> Function();

class ManagedPrivateKeyStore {
  ManagedPrivateKeyStore({
    ApplicationSupportDirectoryProvider? applicationSupportDirectory,
    Uuid uuid = const Uuid(),
    bool? isWindows,
  }) : _applicationSupportDirectory = applicationSupportDirectory ?? getApplicationSupportDirectory,
       _uuid = uuid,
       _isWindows = isWindows ?? Platform.isWindows;

  final ApplicationSupportDirectoryProvider _applicationSupportDirectory;
  final Uuid _uuid;
  final bool _isWindows;

  Future<ManagedPrivateKeyReference> import(SelectedPrivateKey selected) async {
    final id = _uuid.v4();
    _validateId(id);
    final directory = await _keyDirectory();
    final temporary = File(path.join(directory.path, '.$id.tmp'));
    final destination = File(path.join(directory.path, id));
    try {
      final sink = temporary.openWrite(mode: FileMode.writeOnly);
      sink.add(selected.pemBytes);
      await sink.flush();
      await sink.close();
      await _secureFile(temporary);
      await temporary.rename(destination.path);
      return ManagedPrivateKeyReference(id: id, displayName: selected.displayName);
    } on Exception {
      if (await temporary.exists()) {
        await temporary.delete();
      }
      rethrow;
    }
  }

  Future<Uint8List> read(String id) async {
    _validateId(id);
    final file = File(path.join((await _keyDirectory()).path, id));
    try {
      if (!await file.exists()) {
        throw const ManagedPrivateKeyException(
          PrivateKeyReplacementReason.missing,
          'Arkie\'s imported private key copy could not be found.',
        );
      }
      return await file.readAsBytes();
    } on ManagedPrivateKeyException {
      rethrow;
    } on FileSystemException catch (error) {
      throw ManagedPrivateKeyException(
        PrivateKeyReplacementReason.unreadable,
        'Arkie\'s imported private key cannot be read: $error',
      );
    }
  }

  Future<PrivateKeyHealth> inspect(ManagedPrivateKeyReference reference) async {
    try {
      final bytes = await read(reference.id);
      final identities = SSHKeyPair.fromPem(utf8.decode(bytes));
      return identities.isEmpty
          ? const PrivateKeyReplacementRequired(PrivateKeyReplacementReason.invalid)
          : const PrivateKeyUsable();
    } on ManagedPrivateKeyException catch (error) {
      return PrivateKeyReplacementRequired(error.reason);
    } on Exception {
      return const PrivateKeyReplacementRequired(PrivateKeyReplacementReason.invalid);
    }
  }

  Future<void> delete(String id) async {
    _validateId(id);
    final file = File(path.join((await _keyDirectory()).path, id));
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<Directory> _keyDirectory() async {
    final support = await _applicationSupportDirectory();
    final directory = Directory(path.join(support.path, 'ssh_keys'));
    await directory.create(recursive: true);
    if (!_isWindows) {
      await _chmod(directory.path, '700');
    }
    return directory;
  }

  Future<void> _secureFile(File file) async {
    if (!_isWindows) {
      await _chmod(file.path, '600');
    }
  }

  Future<void> _chmod(String target, String mode) async {
    final result = await Process.run('chmod', [mode, target]);
    if (result.exitCode != 0) {
      throw FileSystemException('Could not secure permissions (${result.stderr})', target);
    }
  }

  void _validateId(String id) {
    final uuid = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
    );
    if (!uuid.hasMatch(id) || path.basename(id) != id || id.contains(path.separator)) {
      throw ArgumentError.value(id, 'id', 'Invalid managed private key identifier');
    }
  }
}

class ManagedPrivateKeyException implements Exception {
  const ManagedPrivateKeyException(this.reason, this.message);

  final PrivateKeyReplacementReason reason;
  final String message;

  @override
  String toString() => message;
}
