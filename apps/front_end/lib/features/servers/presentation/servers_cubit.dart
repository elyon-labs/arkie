import 'dart:async';

import 'package:cs2_rcon_front_end/core/safe_emit.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:cs2_rcon_front_end/features/servers/domain/select_server.dart';
import 'package:cs2_rcon_front_end/features/servers/domain/unselect_server.dart';
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
    required UnselectServer unselectServer,
  }) : _watchSelectedServer = watchSelectedServer,
       _watchServers = watchServers,
       _selectServer = selectServer,
       _unselectServer = unselectServer,
       super(ServersState.initial()) {
    unawaited(_init());
  }

  factory ServersCubit.create() {
    return ServersCubit(
      watchServers: WatchServers.create(),
      selectServer: SelectServer.create(),
      watchSelectedServer: WatchSelectedServer.create(),
      unselectServer: UnselectServer.create(),
    );
  }

  final WatchServers _watchServers;
  final SelectServer _selectServer;
  final UnselectServer _unselectServer;
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

  /// Closes the tab for [server] without deleting it.
  /// If [server] is currently selected, it is deselected.
  Future<void> closeTab(Server server) async {
    if (state.selectedServer?.id == server.id) {
      await _unselectServer();
    }
  }

  /// Selects the next server in the list, wrapping around if at the end.
  Future<void> selectNextServer() async {
    final servers = state.servers;
    if (servers.isEmpty) return;
    final current = state.selectedServer;
    if (current == null) {
      await _selectServer(server: servers.first);
      return;
    }
    final currentIndex = servers.indexWhere((s) => s.id == current.id);
    if (currentIndex == -1) return;
    final nextIndex = (currentIndex + 1) % servers.length;
    await _selectServer(server: servers[nextIndex]);
  }

  /// Selects the previous server in the list, wrapping around if at the start.
  Future<void> selectPreviousServer() async {
    final servers = state.servers;
    if (servers.isEmpty) return;
    final current = state.selectedServer;
    if (current == null) {
      await _selectServer(server: servers.last);
      return;
    }
    final currentIndex = servers.indexWhere((s) => s.id == current.id);
    if (currentIndex == -1) return;
    final prevIndex = (currentIndex - 1 + servers.length) % servers.length;
    await _selectServer(server: servers[prevIndex]);
  }

  @override
  Future<void> close() async {
    await subs.dispose();
    return super.close();
  }
}
