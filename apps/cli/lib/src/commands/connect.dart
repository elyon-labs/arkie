import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:cs2_rcon_client/cs2_rcon_client.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:oxidized/oxidized.dart';

class Connect extends Command {
  Connect() {
    argParser
      ..addOption(
        'address',
        abbr: 'a',
        help: 'The host address of the RCON server',
        mandatory: true,
      )
      ..addOption(
        'port',
        abbr: 'P',
        help: 'The port to connect to the RCON server',
        defaultsTo: '27015',
      )
      ..addOption(
        'password',
        abbr: 'p',
        help: 'The password to authenticate with the RCON server',
        mandatory: true,
      )
      ..addOption(
        'log-level',
        abbr: 'l',
        help: 'The log level to use',
        defaultsTo: LogLevel.info.name,
        allowed: LogLevel.values.map((e) => e.name),
      );
  }
  @override
  String get description => 'Connect to a RCON server';

  @override
  String get name => 'connect';

  final _logger = Logger();

  @override
  Future<void> run() async {
    final host = argResults!['address'] as String;
    final port = int.parse(argResults!['port'] as String);
    final password = argResults!['password'] as String;
    final logLevel = argResults!['log-level'] as String;
    final parsedLogLevel = LogLevel.values.byName(logLevel);
    _logger.level = parsedLogLevel.toLevel();

    final socket = RCONSocket(
      hostAddress: InternetAddress(host),
      hostPort: port,
      logLevel: parsedLogLevel,
    );
    final connectProgress = _logger.progress('Authenticating with server...');
    final connectResult = await socket.connect(password: password);

    switch (connectResult) {
      case Ok<RCONConnection, Exception>():
        connectProgress.complete('Authenticated with server.');
      case Err<RCONConnection, Exception>(:final error):
        connectProgress.fail('Failed to authenticate with server: $error');
        return;
    }
    final connection = connectResult.unwrap();

    while (true) {
      final command = _logger.prompt('Enter command: ');
      if (command.isEmpty) {
        _logger.warn('Command cannot be empty');
        continue;
      }
      if (command.toLowerCase() == 'exit') {
        _logger.write('Exiting...');
        break;
      }
      final commandProgress = _logger.progress('Sending command $command');
      final commandResult = await connection.sendCommand(command);
      switch (commandResult) {
        case Ok<RCONServerPacket, Exception>(:final value):
          _logger.write(value.body);
          commandProgress.complete();

        case Err<RCONServerPacket, Exception>(:final error):
          commandProgress.fail(error.toString());
      }
    }
    await connection.close();
  }
}

// ignore: public_member_api_docs
extension LogLevelX on LogLevel {
  /// Converts the [LogLevel] to a [Level] from the `mason_logger` package.
  Level toLevel() {
    return switch (this) {
      LogLevel.none => Level.quiet,
      LogLevel.debug => Level.debug,
      LogLevel.info => Level.info,
      LogLevel.error => Level.error,
    };
  }
}
