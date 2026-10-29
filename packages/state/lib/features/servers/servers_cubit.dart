import 'dart:async';

import 'package:arkie_core/features/rcon/data/api/messages_api.dart';
import 'package:arkie_core/features/rcon/data/repository/messages_repository.dart';
import 'package:arkie_core/features/servers/data/models/server.dart';
import 'package:arkie_core/features/servers/domain/add_demo_server.dart';
import 'package:arkie_core/features/servers/domain/remove_server.dart';
import 'package:arkie_core/features/servers/domain/watch_servers.dart';
import 'package:arkie_state/core/safe_emit.dart';
import 'package:arkie_state/features/servers/servers_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxidized/oxidized.dart';
import 'package:rxdart/utils.dart';

class ServersCubit extends Cubit<ServersState> {
  ServersCubit({
    required WatchServers watchServers,
    required AddDemoServer addDemoServer,
    required RemoveServer Function(Server server) removeServerFor,
  }) : _watchServers = watchServers,
       _addDemoServer = addDemoServer,
       _removeServerFor = removeServerFor,
       super(ServersState.initial()) {
    unawaited(_init());
  }

  factory ServersCubit.create() {
    return ServersCubit(
      watchServers: WatchServers.create(),
      addDemoServer: AddDemoServer.create(),
      removeServerFor: (server) => RemoveServer.create(
        messagesRepository: MessagesRepository(server: server, api: MessagesApi.create()),
      ),
    );
  }

  final WatchServers _watchServers;
  final AddDemoServer _addDemoServer;

  /// A removal needs the message store of the server it is deleting, so the use
  /// case is built per server rather than once for the cubit.
  final RemoveServer Function(Server server) _removeServerFor;

  final subs = CompositeSubscription();

  Future<void> _init() async {
    final serversSub = _watchServers().listen((servers) {
      safeEmit(
        state.copyWith(
          servers: servers,
          openTabs: _removeTabsForDeletedServers(state.openTabs, servers),
          selectedTabId: _selectedTabIdAfterServersChanged(servers),
        ),
      );
    });
    subs.add(serversSub);
  }

  /// Saves the demo server and returns it, or returns null if saving failed.
  ///
  /// Asking again once it exists hands back the one already saved.
  Future<Server?> addDemoServer() async {
    final result = await _addDemoServer();
    return result.ok().toNullable();
  }

  Future<Result<void, Exception>> removeServer(Server server) async {
    return await _removeServerFor(server)(server);
  }

  void openTab() {
    final tab = OpenServerTab.empty();
    safeEmit(state.copyWith(openTabs: [...state.openTabs, tab], selectedTabId: tab.id));
  }

  void selectTab(String tabId) {
    if (!state.openTabs.any((tab) => tab.id == tabId)) return;
    safeEmit(state.copyWith(selectedTabId: tabId));
  }

  void selectServerForSelectedTab(Server server) {
    final selectedTab = state.selectedTab;
    if (selectedTab == null) {
      final tab = OpenServerTab.forServer(server);
      safeEmit(state.copyWith(openTabs: [...state.openTabs, tab], selectedTabId: tab.id));
      return;
    }

    safeEmit(
      state.copyWith(
        openTabs: [
          for (final tab in state.openTabs)
            if (tab.id == selectedTab.id)
              NonEmptyServerTab(id: tab.id, serverId: server.id)
            else
              tab,
        ],
      ),
    );
  }

  void closeSelectedTab() {
    final selectedTabId = state.selectedTabId;
    if (selectedTabId == null) return;
    closeTab(selectedTabId);
  }

  void closeTab(String tabId) {
    final tabIndex = state.openTabs.indexWhere((tab) => tab.id == tabId);
    if (tabIndex == -1) return;

    final tabsAfterClose = [...state.openTabs]..removeAt(tabIndex);
    final openTabs = tabsAfterClose.isEmpty ? [OpenServerTab.empty()] : tabsAfterClose;
    safeEmit(
      state.copyWith(
        openTabs: openTabs,
        selectedTabId: _selectedTabIdAfterClose(tabIndex, openTabs),
      ),
    );
  }

  /// Selects the next open tab, wrapping around if at the end.
  void selectNextServer() {
    _selectTabByOffset(1);
  }

  /// Selects the previous open tab, wrapping around if at the start.
  void selectPreviousServer() {
    _selectTabByOffset(-1);
  }

  @override
  Future<void> close() async {
    await subs.dispose();
    return super.close();
  }

  List<OpenServerTab> _removeTabsForDeletedServers(List<OpenServerTab> tabs, List<Server> servers) {
    final serverIds = servers.map((server) => server.id).toSet();
    return tabs.where((tab) {
      return switch (tab) {
        EmptyServerTab() => true,
        NonEmptyServerTab(:final serverId) => serverIds.contains(serverId),
      };
    }).toList();
  }

  String? _selectedTabIdAfterServersChanged(List<Server> servers) {
    final openTabs = _removeTabsForDeletedServers(state.openTabs, servers);
    if (openTabs.isEmpty) return null;
    if (openTabs.any((tab) => tab.id == state.selectedTabId)) return state.selectedTabId;
    return openTabs.last.id;
  }

  String? _selectedTabIdAfterClose(int closedTabIndex, List<OpenServerTab> openTabs) {
    if (openTabs.isEmpty) return null;
    final selectedTabId = state.selectedTabId;
    final closedSelectedTab = state.openTabs[closedTabIndex].id == selectedTabId;
    if (!closedSelectedTab && openTabs.any((tab) => tab.id == selectedTabId)) return selectedTabId;

    final nextIndex = closedTabIndex.clamp(0, openTabs.length - 1);
    return openTabs[nextIndex].id;
  }

  void _selectTabByOffset(int offset) {
    final openTabs = state.openTabs;
    if (openTabs.isEmpty) return;

    final selectedTabId = state.selectedTabId;
    final selectedIndex = openTabs.indexWhere((tab) => tab.id == selectedTabId);
    final nextIndex = selectedIndex == -1
        ? (offset > 0 ? 0 : openTabs.length - 1)
        : (selectedIndex + offset + openTabs.length) % openTabs.length;
    safeEmit(state.copyWith(selectedTabId: openTabs[nextIndex].id));
  }
}
