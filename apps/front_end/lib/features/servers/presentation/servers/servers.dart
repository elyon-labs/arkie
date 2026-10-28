import 'package:arkie_core/features/servers/data/models/server.dart';
import 'package:arkie_state/features/servers/servers_cubit.dart';
import 'package:arkie_state/features/servers/servers_state.dart';
import 'package:arkie_ui/arkie_ui.dart';
import 'package:collection/collection.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/rcon.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/add_server_dialog/add_server_dialog.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/servers/widgets/add_server_fab.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/servers/widgets/server_tab.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/servers/widgets/settings_fab.dart';
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
        const _TabStrip(),
        if (selectedTabServer != null && selectedTab != null)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                ArkieMetrics.snug,
                ArkieMetrics.loose,
                ArkieMetrics.snug,
                ArkieMetrics.snug,
              ),
              child: RCON(server: selectedTabServer, key: ValueKey(selectedTabServer)),
            ),
          )
        else if (selectedTab != null)
          Expanded(child: _OpenTabEmptyState(servers: servers))
        else
          Expanded(
            child: Center(
              child: TextButton(onPressed: cubit.openTab, child: const Text('Open a tab')),
            ),
          ),
      ],
    );
  }
}

/// The strip the whole window hangs off, ruled off from the pane below it.
class _TabStrip extends StatelessWidget {
  const _TabStrip();

  @override
  Widget build(BuildContext context) {
    final state = context.select((ServersCubit cubit) => cubit.state);
    final selectedTab = state.selectedTab;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.arkieColors.border, width: ArkieMetrics.hairline),
        ),
      ),
      child: Row(
        children: [
          const HSpace(space: ArkieMetrics.snug),
          Text('arkie', style: context.text.caption.copyWith(color: context.colors.accent)),
          const HSpace(space: ArkieMetrics.snug),
          ...state.openTabs.map(
            (tab) => ServerTab(
              tab: tab,
              server: _serverForTab(tab, state.servers),
              isSelected: tab.id == selectedTab?.id,
              allowClose:
                  state.openTabs.isNotEmpty &&
                  (state.openTabs.length != 1 || state.openTabs.single is NonEmptyServerTab),
            ),
          ),
          const AddServerFAB(),
          const Spacer(),
          const SettingsFab(),
        ],
      ),
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
    return TerminalPanel(
      label: 'open',
      padding: const EdgeInsets.symmetric(vertical: ArkieMetrics.tight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (servers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: ArkieMetrics.snug),
              child: Text(
                'No servers yet.',
                style: context.text.body.copyWith(color: context.colors.muted),
              ),
            )
          else ...[
            for (final server in servers)
              ListTile(
                title: Text(server.name),
                subtitle: Text('${server.address}:${server.port}'),
                onTap: () => context.read<ServersCubit>().selectServerForSelectedTab(server),
              ),
            const Divider(),
          ],
          ListTile(
            leading: Icon(context.icons.add),
            title: const Text('Add a server'),
            onTap: onAddServer,
          ),
        ],
      ),
    );
  }
}
