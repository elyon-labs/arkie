import 'dart:convert';
import 'dart:io';

import 'package:cs2_rcon_front_end/features/server_management/domain/models/selected_private_key.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:file_selector/file_selector.dart' as selector;
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;

typedef OpenPrivateKeyFile = Future<selector.XFile?> Function();

class SshPrivateKeyPicker {
  SshPrivateKeyPicker({OpenPrivateKeyFile? openFile}) : _openFile = openFile ?? selector.openFile;

  final OpenPrivateKeyFile _openFile;

  Future<SelectedPrivateKey?> pick() async {
    try {
      final file = await _openFile();
      if (file == null) {
        return null;
      }

      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        throw const PrivateKeySelectionException('The selected private key is empty.');
      }

      final pem = utf8.decode(bytes);
      if (SSHKeyPair.isEncryptedPem(pem)) {
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
    } on SSHKeyDecryptError {
      throw const PrivateKeySelectionException(
        'Encrypted private keys are not supported yet. Choose an unencrypted key.',
      );
      // dartssh2 reports unsupported PEM types as an Error even though the
      // selected file is user input rather than a programming failure.
      // ignore: avoid_catching_errors
    } on UnsupportedError {
      throw const PrivateKeySelectionException(
        'The selected file is not a supported SSH private key.',
      );
    } on SSHError {
      throw const PrivateKeySelectionException('The selected file is not a valid SSH private key.');
    } on FormatException {
      throw const PrivateKeySelectionException('The selected file is not a valid SSH private key.');
    } on FileSystemException {
      throw const PrivateKeySelectionException('Arkie could not read the selected private key.');
    } on PlatformException {
      throw const PrivateKeySelectionException('Arkie could not open the private key picker.');
    }
  }
}

class PrivateKeySelectionException implements Exception {
  const PrivateKeySelectionException(this.message);

  final String message;

  @override
  String toString() => message;
}
