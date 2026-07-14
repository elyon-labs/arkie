import 'dart:convert';
import 'dart:io';

import 'package:cs2_rcon_front_end/features/server_management/domain/models/selected_private_key.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:file_selector/file_selector.dart' as selector;
import 'package:path/path.dart' as path;

typedef OpenPrivateKeyFile = Future<selector.XFile?> Function();

class SshPrivateKeyPicker {
  SshPrivateKeyPicker({OpenPrivateKeyFile? openFile})
    : _openFile = openFile ?? (() => openFileSelector());

  static Future<selector.XFile?> openFileSelector() => selector.openFile();

  final OpenPrivateKeyFile _openFile;

  Future<SelectedPrivateKey?> pick() async {
    final file = await _openFile();
    if (file == null) {
      return null;
    }

    try {
      if (file.path.isNotEmpty && await FileSystemEntity.isDirectory(file.path)) {
        throw const PrivateKeySelectionException('Choose a private key file, not a folder.');
      }
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        throw const PrivateKeySelectionException('The selected private key is empty.');
      }
      final pem = utf8.decode(bytes);
      if (pem.contains('ENCRYPTED')) {
        throw const PrivateKeySelectionException(
          'Encrypted private keys are not supported yet. Choose an unencrypted key.',
        );
      }
      final identities = SSHKeyPair.fromPem(pem);
      if (identities.isEmpty) {
        throw const PrivateKeySelectionException('The selected file is not a supported SSH key.');
      }
      return SelectedPrivateKey(
        displayName: file.name.isEmpty ? path.basename(file.path) : file.name,
        pemBytes: bytes,
      );
    } on PrivateKeySelectionException {
      rethrow;
    } on FormatException catch (error) {
      throw PrivateKeySelectionException(
        'The selected file is not a valid unencrypted SSH private key: $error',
      );
    } on FileSystemException catch (error) {
      throw PrivateKeySelectionException('Arkie could not read the selected private key: $error');
    } on Exception catch (error) {
      throw PrivateKeySelectionException(
        'The selected file is not a supported unencrypted SSH private key: $error',
      );
    }
  }
}

class PrivateKeySelectionException implements Exception {
  const PrivateKeySelectionException(this.message);
  final String message;

  @override
  String toString() => message;
}
