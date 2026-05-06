import 'dart:async';

import 'package:cs2_rcon_front_end/core/safe_emit.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:cs2_rcon_front_end/features/servers/domain/watch_servers.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/servers_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/utils.dart';

class ServersCubit extends Cubit<ServersState> {
  ServersCubit({required WatchServers watchServers})
    : _watchServers = watchServers,
      super(ServersState.initial()) {
    unawaited(_init());
  }

  factory ServersCubit.create() {
    return ServersCubit(watchServers: WatchServers.create());
  }

  final WatchServers _watchServers;

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
            if (tab.id == selectedTab.id) tab.copyWith(serverId: server.id) else tab,
        ],
      ),
    );
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
    return tabs.where((tab) => tab.serverId == null || serverIds.contains(tab.serverId)).toList();
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
