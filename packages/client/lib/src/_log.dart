import 'package:cs2_rcon_client/src/models/models.dart';
import 'package:logger/logger.dart';

/// Extension methods for [LogLevel].
extension LogLevelX on LogLevel {
  /// Converts a [LogLevel] to a [Level] from the `logger` package.
  Level toLoggerLevel() {
    return switch (this) {
      LogLevel.none => Level.off,
      LogLevel.debug => Level.trace,
      LogLevel.info => Level.info,
      LogLevel.error => Level.error,
    };
  }
}
