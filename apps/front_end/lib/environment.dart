import 'package:cs2_rcon_client/cs2_rcon_client.dart';

class Environment {
  Environment({required this.logLevel});

  factory Environment.fromEnvironment() {
    LogLevel logLevel() {
      // ignore: do_not_use_environment
      const envLogLevel = String.fromEnvironment('LOG_LEVEL', defaultValue: 'info');
      return LogLevel.values.byName(envLogLevel.toLowerCase());
    }

    return Environment(logLevel: logLevel());
  }

  final LogLevel logLevel;
}
