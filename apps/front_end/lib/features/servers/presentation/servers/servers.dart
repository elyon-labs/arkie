import 'package:collection/collection.dart';
import 'package:cs2_rcon_front_end/core_ui/_build_context.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/rcon.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/add_server_dialog/add_server_dialog.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/servers/widgets/add_server_fab.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/servers/widgets/server_tab.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/servers/widgets/settings_fab.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/servers_cubit.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/servers_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class Servers extends StatelessWidget {
  const Servers({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: _Body());
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ServersCubit>();
    final state = context.select((ServersCubit cubit) => cubit.state);
    final selectedTab = state.selectedTab;
    final servers = state.servers;
    final selectedTabServer = selectedTab == null ? null : _serverForTab(selectedTab, servers);

    return Column(
      children: [
        Row(
          children: [
            const AddServerFAB(),
            ...state.openTabs.map(
              (tab) => ServerTab(
                tab: tab,
                server: _serverForTab(tab, servers),
                isSelected: tab.id == selectedTab?.id,
                allowClose:
                    state.openTabs.isNotEmpty &&
                    (state.openTabs.length != 1 || state.openTabs.single is NonEmptyServerTab),
              ),
            ),
            const Spacer(),
            const SettingsFab(),
          ],
        ),
        if (selectedTabServer != null && selectedTab != null) ...[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: context.sizes.edgeSpacing,
                right: context.sizes.edgeSpacing,
                bottom: context.sizes.edgeSpacing,
              ),
              child: RCON(server: selectedTabServer, key: ValueKey(selectedTabServer)),
            ),
          ),
        ] else if (selectedTab != null) ...[
          Expanded(child: _OpenTabEmptyState(servers: servers)),
        ] else ...[
          Expanded(
            child: Center(
              child: TextButton(onPressed: cubit.openTab, child: const Text('Open a tab')),
            ),
          ),
        ],
      ],
    );
  }
}

Server? _serverForTab(OpenServerTab tab, List<Server> servers) {
  return switch (tab) {
    EmptyServerTab() => null,
    NonEmptyServerTab(:final serverId) => servers.firstWhereOrNull((s) => s.id == serverId),
  };
}

class _OpenTabEmptyState extends HookWidget {
  const _OpenTabEmptyState({required this.servers});

  final List<Server> servers;

  @override
  Widget build(BuildContext context) {
    final isAddingServer = useState(false);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: isAddingServer.value
            ? AddServerForm(
                onServerAdded: (server) {
                  context.read<ServersCubit>().selectServerForSelectedTab(server);
                  isAddingServer.value = false;
                },
                onCancel: () => isAddingServer.value = false,
              )
            : _SelectServerForTab(servers: servers, onAddServer: () => isAddingServer.value = true),
      ),
    );
  }
}

class _SelectServerForTab extends StatelessWidget {
  const _SelectServerForTab({required this.servers, required this.onAddServer});

  final List<Server> servers;
  final VoidCallback onAddServer;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Open tab', style: context.text.caption),
        SizedBox(height: context.sizes.unit),
        if (servers.isEmpty) ...[
          const Text('Add a server to use this tab.'),
        ] else ...[
          ...servers.map(
            (server) => ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: context.sizes.unit),
              title: Text(server.name),
              onTap: () => context.read<ServersCubit>().selectServerForSelectedTab(server),
            ),
          ),
          const Divider(),
        ],
        ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: context.sizes.unit),
          leading: Icon(context.icons.add),
          title: const Text('Add new server'),
          onTap: onAddServer,
        ),
      ],
    );
  }
}
