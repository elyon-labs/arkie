import 'package:arkie_core/environment.dart';
import 'package:cs2_rcon_client/cs2_rcon_client.dart';

class FakeEnvironment implements Environment {
  @override
  LogLevel get logLevel => LogLevel.debug;
}
