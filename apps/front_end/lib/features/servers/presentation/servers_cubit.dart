import 'dart:async';

import 'package:cs2_rcon_front_end/core/safe_emit.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:cs2_rcon_front_end/features/servers/domain/select_server.dart';
import 'package:cs2_rcon_front_end/features/servers/domain/watch_selected_server.dart';
import 'package:cs2_rcon_front_end/features/servers/domain/watch_servers.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/servers_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/utils.dart';

class ServersCubit extends Cubit<ServersState> {
  ServersCubit({
    required WatchServers watchServers,
    required SelectServer selectServer,
    required WatchSelectedServer watchSelectedServer,
  }) : _watchSelectedServer = watchSelectedServer,
       _watchServers = watchServers,
       _selectServer = selectServer,
       super(ServersState.initial()) {
    unawaited(_init());
  }

  factory ServersCubit.create() {
    return ServersCubit(
      watchServers: WatchServers.create(),
      selectServer: SelectServer.create(),
      watchSelectedServer: WatchSelectedServer.create(),
    );
  }

  final WatchServers _watchServers;
  final SelectServer _selectServer;

  final WatchSelectedServer _watchSelectedServer;

  final subs = CompositeSubscription();

  Future<void> _init() async {
    final serversSub = _watchServers().listen((servers) {
      safeEmit(ServersState(servers: servers, selectedServer: state.selectedServer));
    });
    final selectedSub = _watchSelectedServer().listen((selectedServer) {
      safeEmit(ServersState(servers: state.servers, selectedServer: selectedServer));
    });
    subs
      ..add(selectedSub)
      ..add(serversSub);
  }

  Future<void> selectServer(Server server) async {
    await _selectServer(server: server);
  }

  @override
  Future<void> close() async {
    await subs.dispose();
    return super.close();
  }
}
