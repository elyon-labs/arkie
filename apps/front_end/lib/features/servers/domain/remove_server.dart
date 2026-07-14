import 'package:cs2_rcon_front_end/di/graph.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/repository/messages_repository.dart';
import 'package:cs2_rcon_front_end/features/server_management/data/managed_private_key_store.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:cs2_rcon_front_end/features/servers/data/repository/servers_repository.dart';
import 'package:cs2_rcon_front_end/features/servers/domain/watch_selected_server.dart';
import 'package:cs2_rcon_front_end/features/settings/data/repository/settings_repository.dart';
import 'package:oxidized/oxidized.dart';

/// Removes a server from the servers repository.
class RemoveServer {
  RemoveServer({
    required SettingsRepository settingsRepository,
    required ServersRepository serversRepository,
    required MessagesRepository messagesRepository,
    required WatchSelectedServer watchSelectedServer,
    ManagedPrivateKeyStore? privateKeyStore,
  }) : _settingsRepository = settingsRepository,
       _serversRepository = serversRepository,
       _messagesRepository = messagesRepository,
       _watchSelectedServer = watchSelectedServer,
       _privateKeyStore = privateKeyStore ?? ManagedPrivateKeyStore();

  factory RemoveServer.create({required MessagesRepository messagesRepository}) {
    return RemoveServer(
      settingsRepository: inject(),
      serversRepository: inject(),
      messagesRepository: messagesRepository,
      watchSelectedServer: WatchSelectedServer.create(),
      privateKeyStore: inject(),
    );
  }

  final SettingsRepository _settingsRepository;
  final ServersRepository _serversRepository;
  final MessagesRepository _messagesRepository;
  final WatchSelectedServer _watchSelectedServer;
  final ManagedPrivateKeyStore _privateKeyStore;
  String? cleanupWarning;

  Future<Result<void, Exception>> call(Server server) async {
    cleanupWarning = null;
    // First, delete all messages associated with the server.
    return await _messagesRepository.clearMessages().andThenAsync((_) async {
      // Get a hold of the currently selected server.
      final currentSelectedServer = await _watchSelectedServer().first;

      final result = await _serversRepository.removeServer(server);

      // If the removed server was the selected server, clear the selection.
      if (result.isOk()) {
        if (currentSelectedServer != null && currentSelectedServer.id == server.id) {
          await _settingsRepository.clearSelectedServer();
        }
        final key = server.managementConfig?.privateKey;
        if (key != null) {
          try {
            await _privateKeyStore.delete(key.id);
          } on Exception catch (error) {
            cleanupWarning =
                'Server deleted, but its managed private key could not be removed: $error';
          }
        }
      }

      return result;
    });
  }
}
