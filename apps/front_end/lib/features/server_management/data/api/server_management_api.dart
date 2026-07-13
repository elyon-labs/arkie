import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cs2_rcon_front_end/features/servers/data/models/server_management_config.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:oxidized/oxidized.dart';

class ServerManagementApi {
  const ServerManagementApi();

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
    final keyFile = File(_expandHome(config.privateKeyPath));
    final identities = SSHKeyPair.fromPem(await keyFile.readAsString());
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

  String _expandHome(String path) {
    if (!path.startsWith('~/')) {
      return path;
    }
    final home = Platform.environment['HOME'];
    if (home == null || home.isEmpty) {
      return path;
    }
    return '$home/${path.substring(2)}';
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
