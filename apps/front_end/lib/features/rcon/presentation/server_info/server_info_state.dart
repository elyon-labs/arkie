import 'package:cs2_rcon_front_end/core/async.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/models/cs2_map.dart';
import 'package:cs2_rcon_front_end/features/rcon/domain/models/server_status.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/server_info/models/pending_action.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:oxidized/oxidized.dart';

part 'server_info_state.mapper.dart';

@MappableClass()
class ServerInfoState with ServerInfoStateMappable {
  ServerInfoState({
    required this.status,
    required this.maps,
    required this.workshopMaps,
    required this.pendingAction,
  });

  factory ServerInfoState.initial() {
    return ServerInfoState(
      status: const Loading(),
      maps: [],
      workshopMaps: WorkshopMap.directory,
      pendingAction: const None(),
    );
  }

  final Async<ServerStatus> status;
  final List<CS2Map> maps;
  final List<WorkshopMap> workshopMaps;
  final Option<PendingAction> pendingAction;
}
