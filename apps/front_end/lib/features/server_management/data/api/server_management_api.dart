import 'dart:async';
import 'dart:convert';

import 'package:cs2_rcon_front_end/di/graph.dart';
import 'package:cs2_rcon_front_end/features/server_management/data/managed_private_key_store.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/private_key_health.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server_management_config.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:oxidized/oxidized.dart';

class ServerManagementApi {
  const ServerManagementApi({required ManagedPrivateKeyStore privateKeyStore})
    : _privateKeyStore = privateKeyStore;

  factory ServerManagementApi.create() => ServerManagementApi(privateKeyStore: inject());

  final ManagedPrivateKeyStore _privateKeyStore;

  Future<Result<String, Exception>> run(
    ServerManagementConfig config,
    ServerManagementAction action,
  ) {
    return Result.asyncOf(() async {
      final client = await _connect(config);
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

  Stream<Result<String, Exception>> streamLogs(ServerManagementConfig config) async* {
    SSHClient? client;
    SSHSession? session;
    try {
      client = await _connect(config);
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

  Future<SSHClient> _connect(ServerManagementConfig config) async {
    final reference = config.privateKey;
    if (reference == null) {
      final reason = config.privateKeyPath != null
          ? PrivateKeyReplacementReason.legacyPath
          : PrivateKeyReplacementReason.missing;
      throw ServerManagementCredentialException(
        reason,
        reason == PrivateKeyReplacementReason.legacyPath
            ? 'This private key must be reselected after Arkie\'s storage update.'
            : 'No imported private key is configured.',
      );
    }
    late final List<int> keyBytes;
    try {
      keyBytes = await _privateKeyStore.read(reference.id);
    } on ManagedPrivateKeyException catch (error) {
      throw ServerManagementCredentialException(error.reason, error.message);
    } on Exception catch (error) {
      throw ServerManagementCredentialException(
        PrivateKeyReplacementReason.invalid,
        'The managed private key reference is invalid: $error',
      );
    }
    late final List<SSHKeyPair> identities;
    try {
      identities = SSHKeyPair.fromPem(utf8.decode(keyBytes));
      if (identities.isEmpty) {
        throw const FormatException('No supported identity found');
      }
    } on Exception catch (error) {
      throw ServerManagementCredentialException(
        PrivateKeyReplacementReason.invalid,
        'Arkie\'s imported private key is invalid: $error',
      );
    }
    final socket = await SSHSocket.connect(config.sshHost, config.sshPort);
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

  String _dispatcherCommand(ServerManagementAction action) => 'arkie-cs2 ${action.name}';
}

class ServerManagementCredentialException extends ServerManagementException {
  const ServerManagementCredentialException(this.reason, super.message);

  final PrivateKeyReplacementReason reason;
}

enum ServerManagementAction { start, stop, restart, logs }

class ServerManagementException implements Exception {
  const ServerManagementException(this.message);
  final String message;

  @override
  String toString() => message;
}
