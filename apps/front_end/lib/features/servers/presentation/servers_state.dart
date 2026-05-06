import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:uuid/uuid.dart';

class ServersState {
  ServersState({required this.servers, required this.openTabs, required this.selectedTabId});

  factory ServersState.initial() {
    final tab = OpenServerTab.empty();
    return ServersState(servers: [], openTabs: [tab], selectedTabId: tab.id);
  }

  final List<Server> servers;
  final List<OpenServerTab> openTabs;
  final String? selectedTabId;

  OpenServerTab? get selectedTab {
    final selectedTabId = this.selectedTabId;
    if (selectedTabId == null) return null;

    for (final tab in openTabs) {
      if (tab.id == selectedTabId) return tab;
    }

    return null;
  }

  Server? get selectedServer {
    final serverId = selectedTab?.serverId;
    if (serverId == null) return null;

    for (final server in servers) {
      if (server.id == serverId) return server;
    }

    return null;
  }

  ServersState copyWith({
    List<Server>? servers,
    List<OpenServerTab>? openTabs,
    Object? selectedTabId = _none,
  }) {
    return ServersState(
      servers: servers ?? this.servers,
      openTabs: openTabs ?? this.openTabs,
      selectedTabId: selectedTabId == _none ? this.selectedTabId : selectedTabId as String?,
    );
  }
}

class OpenServerTab {
  const OpenServerTab({required this.id, required this.serverId});

  factory OpenServerTab.empty() {
    return OpenServerTab(id: const Uuid().v4(), serverId: null);
  }

  factory OpenServerTab.forServer(Server server) {
    return OpenServerTab(id: const Uuid().v4(), serverId: server.id);
  }

  final String id;
  final String? serverId;

  bool get isEmpty => serverId == null;

  OpenServerTab copyWith({Object? serverId = _none}) {
    return OpenServerTab(id: id, serverId: serverId == _none ? this.serverId : serverId as String?);
  }
}

const _none = Object();
