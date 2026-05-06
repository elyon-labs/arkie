import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:uuid/uuid.dart';

part 'servers_state.mapper.dart';

@MappableClass()
class ServersState with ServersStateMappable {
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
}

@MappableClass(discriminatorKey: 'type')
sealed class OpenServerTab with OpenServerTabMappable {
  const OpenServerTab({required this.id});

  factory OpenServerTab.empty() {
    return EmptyServerTab(id: const Uuid().v4());
  }

  factory OpenServerTab.forServer(Server server) {
    return NonEmptyServerTab(id: const Uuid().v4(), serverId: server.id);
  }

  final String id;
}

@MappableClass()
class EmptyServerTab extends OpenServerTab with EmptyServerTabMappable {
  const EmptyServerTab({required super.id});
}

@MappableClass()
class NonEmptyServerTab extends OpenServerTab with NonEmptyServerTabMappable {
  const NonEmptyServerTab({required super.id, required this.serverId});

  final String serverId;
}
