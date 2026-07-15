import 'dart:convert';
import 'dart:io';

import 'package:cs2_rcon_front_end/features/server_management/domain/models/selected_private_key.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:file_selector/file_selector.dart' as selector;
import 'package:flutter/services.dart';
import 'package:oxidized/oxidized.dart';
import 'package:path/path.dart' as path;

typedef OpenPrivateKeyFile = Future<selector.XFile?> Function();

class SelectSshPrivateKey {
  const SelectSshPrivateKey({required OpenPrivateKeyFile openFile}) : _openFile = openFile;

  factory SelectSshPrivateKey.create() => const SelectSshPrivateKey(openFile: selector.openFile);

  final OpenPrivateKeyFile _openFile;

  Future<Result<SelectedPrivateKey?, PrivateKeySelectionException>> call() async {
    try {
      final file = await _openFile();
      if (file == null) {
        return const Result.ok(null);
      }

      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        return const Result.err(PrivateKeySelectionException('The selected private key is empty.'));
      }

      final pem = utf8.decode(bytes);
      if (SSHKeyPair.isEncryptedPem(pem)) {
        return const Result.err(
          PrivateKeySelectionException(
            'Encrypted private keys are not supported yet. Choose an unencrypted key.',
          ),
        );
      }

      final identities = SSHKeyPair.fromPem(pem);
      if (identities.isEmpty) {
        return const Result.err(
          PrivateKeySelectionException('The selected file is not a supported SSH key.'),
        );
      }

      return Result.ok(
        SelectedPrivateKey(
          displayName: file.name.isEmpty ? path.basename(file.path) : file.name,
          pemBytes: bytes,
        ),
      );
    } on SSHKeyDecryptError {
      return const Result.err(
        PrivateKeySelectionException(
          'Encrypted private keys are not supported yet. Choose an unencrypted key.',
        ),
      );
      // dartssh2 reports unsupported PEM types as an Error even though the
      // selected file is user input rather than a programming failure.
      // ignore: avoid_catching_errors
    } on UnsupportedError {
      return const Result.err(
        PrivateKeySelectionException('The selected file is not a supported SSH private key.'),
      );
    } on SSHError {
      return const Result.err(
        PrivateKeySelectionException('The selected file is not a valid SSH private key.'),
      );
    } on FormatException {
      return const Result.err(
        PrivateKeySelectionException('The selected file is not a valid SSH private key.'),
      );
    } on FileSystemException {
      return const Result.err(
        PrivateKeySelectionException('Arkie could not read the selected private key.'),
      );
    } on PlatformException {
      return const Result.err(
        PrivateKeySelectionException('Arkie could not open the private key picker.'),
      );
    } on Exception {
      return const Result.err(
        PrivateKeySelectionException('Arkie could not select the private key.'),
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
