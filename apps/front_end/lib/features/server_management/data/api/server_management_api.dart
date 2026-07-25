import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cs2_rcon_front_end/features/servers/data/models/server_management_config.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:oxidized/oxidized.dart';

class ServerManagementApi {
  const ServerManagementApi({
    Future<SSHSocket> Function(String host, int port) connectSocket = SSHSocket.connect,
  }) : _connectSocket = connectSocket;

  final Future<SSHSocket> Function(String host, int port) _connectSocket;

  Future<Result<String, Exception>> run(
    ServerManagementConfig config,
    ServerManagementAction action,
    Uint8List privateKeyBytes,
  ) {
    return Result.asyncOf(() async {
      final client = await _connect(config, privateKeyBytes);
      try {
        final result = await client.runWithResult(_dispatcherCommand(action));
        final output = utf8.decode([
          ...result.stdout,
          ...result.stderr,
        ], allowMalformed: true).trim();
        if (result.exitCode != 0) {
          throw ServerManagementException(output.isEmpty ? 'Remote command failed' : output);
        }
        return output;
      } finally {
        client.close();
      }
    });
  }

  Stream<Result<String, Exception>> streamLogs(
    ServerManagementConfig config,
    Uint8List privateKeyBytes,
  ) async* {
    SSHClient? client;
    SSHSession? session;
    try {
      client = await _connect(config, privateKeyBytes);
      session = await client.execute(_dispatcherCommand(ServerManagementAction.logs));
      await for (final line
          in session.stdout
              .map<List<int>>((bytes) => bytes)
              .transform(utf8.decoder)
              .transform(const LineSplitter())) {
        yield Result.ok(line);
      }
      final exitCode = await session.waitForExit();
      if (exitCode != 0 && exitCode != null) {
        yield Result.err(ServerManagementException('Remote log stream exited with $exitCode'));
      }
    } on Exception catch (error) {
      yield Result.err(error);
    } finally {
      session?.close();
      client?.close();
    }
  }

  Future<SSHClient> _connect(ServerManagementConfig config, Uint8List privateKeyBytes) async {
    final identities = _parsePrivateKey(privateKeyBytes);
    final socket = await _connectSocket(config.sshHost, config.sshPort);
    final expected = config.hostKeyFingerprint.trim();
    final client = SSHClient(
      socket,
      username: config.sshUser,
      identities: identities,
      onVerifyHostKey: (_, fingerprint) => utf8.decode(fingerprint) == expected,
    );
    await client.authenticated;
    return client;
  }

  List<SSHKeyPair> _parsePrivateKey(Uint8List privateKeyBytes) {
    try {
      if (privateKeyBytes.isEmpty) {
        throw const ServerManagementCredentialException();
      }
      final pem = utf8.decode(privateKeyBytes);
      if (pem.trim().isEmpty || SSHKeyPair.isEncryptedPem(pem)) {
        throw const ServerManagementCredentialException();
      }
      final identities = SSHKeyPair.fromPem(pem);
      if (identities.isEmpty) {
        throw const ServerManagementCredentialException();
      }
      return identities;
    } on ServerManagementCredentialException {
      rethrow;
    } on FormatException {
      throw const ServerManagementCredentialException();
      // dartssh2 reports unsupported PEM types as an Error even though the
      // managed file is user-provided credential content.
      // ignore: avoid_catching_errors
    } on UnsupportedError {
      throw const ServerManagementCredentialException();
    } on SSHError {
      throw const ServerManagementCredentialException();
    }
  }

  String _dispatcherCommand(ServerManagementAction action) => 'arkie-cs2 ${action.name}';
}

enum ServerManagementAction { start, stop, restart, logs }

class ServerManagementException implements Exception {
  const ServerManagementException(this.message);
  final String message;

  @override
  String toString() => message;
}

class ServerManagementCredentialException implements Exception {
  const ServerManagementCredentialException([
    this.message = 'Arkie could not use the managed SSH private key.',
  ]);

  final String message;

  @override
  String toString() => message;
}
