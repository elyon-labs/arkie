import 'package:cs2_rcon_front_end/features/server_management/data/api/server_management_api.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/read_managed_private_key.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server_management_config.dart';
import 'package:oxidized/oxidized.dart';

class StartServer {
  const StartServer({
    required ServerManagementApi api,
    required ReadManagedPrivateKey readManagedPrivateKey,
  }) : _api = api,
       _readManagedPrivateKey = readManagedPrivateKey;

  factory StartServer.create() {
    return StartServer(
      api: const ServerManagementApi(),
      readManagedPrivateKey: ReadManagedPrivateKey.create(),
    );
  }

  final ServerManagementApi _api;
  final ReadManagedPrivateKey _readManagedPrivateKey;

  Future<Result<String, Exception>> call(ServerManagementConfig config) async {
    final privateKey = config.privateKey;
    if (privateKey == null) {
      return const Err(ServerManagementCredentialException());
    }
    final readResult = await _readManagedPrivateKey(privateKey);
    return readResult
        .mapErr<Exception>((_) => const ServerManagementCredentialException())
        .andThenAsync((bytes) => _api.run(config, ServerManagementAction.start, bytes));
  }
}
