import 'package:cs2_rcon_front_end/features/server_management/data/api/server_management_api.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/read_managed_private_key.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server_management_config.dart';
import 'package:oxidized/oxidized.dart';

class WatchServerLogs {
  const WatchServerLogs({
    required ServerManagementApi api,
    required ReadManagedPrivateKey readManagedPrivateKey,
  }) : _api = api,
       _readManagedPrivateKey = readManagedPrivateKey;

  factory WatchServerLogs.create() {
    return WatchServerLogs(
      api: const ServerManagementApi(),
      readManagedPrivateKey: ReadManagedPrivateKey.create(),
    );
  }

  final ServerManagementApi _api;
  final ReadManagedPrivateKey _readManagedPrivateKey;

  Stream<Result<String, Exception>> call(ServerManagementConfig config) async* {
    final privateKey = config.privateKey;
    if (privateKey == null) {
      yield const Err(ServerManagementCredentialException());
      return;
    }
    final readResult = await _readManagedPrivateKey(privateKey);
    if (readResult.isErr()) {
      yield const Err(ServerManagementCredentialException());
      return;
    }
    yield* _api.streamLogs(config, readResult.unwrap());
  }
}
