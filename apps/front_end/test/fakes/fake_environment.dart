import 'package:cs2_rcon_client/src/models/log.dart';
import 'package:cs2_rcon_front_end/environment.dart';

class FakeEnvironment implements Environment {
  @override
  LogLevel get logLevel => LogLevel.debug;
}
