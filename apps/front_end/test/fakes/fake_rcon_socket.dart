import 'dart:io';

import 'package:cs2_rcon_client/cs2_rcon_client.dart';
import 'package:oxidized/src/result.dart';

import 'fake_rcon_connection.dart';

typedef HandleConnect = Future<Result<RCONConnection, Exception>> Function();

class FakeRCONSocket implements RCONSocket {
  FakeRCONSocket({
    InternetAddress? hostAddress,
    int hostPort = 27015,
    Duration connectTimeout = const Duration(seconds: 5),
    Duration commandTimeout = const Duration(milliseconds: 1500),
    LogLevel logLevel = LogLevel.debug,
    HandleConnect? onConnect,
  }) : _onConnect = onConnect ?? (() => Future.value(const Ok(FakeRCONConnection()))),
       _logLevelOverride = logLevel,
       _connectTimeoutOverride = connectTimeout,
       _commandTimeoutOverride = commandTimeout,
       _hostPortOverride = hostPort,
       _hostAddressOverride = hostAddress ?? InternetAddress.loopbackIPv4;

  final InternetAddress _hostAddressOverride;
  final int _hostPortOverride;
  final Duration _connectTimeoutOverride;
  final Duration _commandTimeoutOverride;
  final LogLevel _logLevelOverride;
  final HandleConnect _onConnect;

  @override
  Future<Result<RCONConnection, Exception>> connect({required String password}) {
    return _onConnect();
  }

  @override
  Duration get connectTimeout => _connectTimeoutOverride;

  @override
  Duration get commandTimeout => _commandTimeoutOverride;

  @override
  InternetAddress get hostAddress => _hostAddressOverride;

  @override
  int get hostPort => _hostPortOverride;

  @override
  LogLevel get logLevel => _logLevelOverride;
}
