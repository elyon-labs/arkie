import 'package:cs2_rcon_client/cs2_rcon_client.dart';
import 'package:cs2_rcon_client/src/_log.dart';
import 'package:logger/logger.dart';
import 'package:test/test.dart';

void main() {
  group('LogLevelX', () {
    test('it maps to the correct levels in package:logger', () {
      expect(LogLevel.none.toLoggerLevel(), equals(Level.off));
      expect(LogLevel.debug.toLoggerLevel(), equals(Level.trace));
      expect(LogLevel.info.toLoggerLevel(), equals(Level.info));
      expect(LogLevel.error.toLoggerLevel(), equals(Level.error));
    });
  });
}
