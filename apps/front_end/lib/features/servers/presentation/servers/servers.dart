import 'package:cs2_rcon_front_end/core_ui/_build_context.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/rcon.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/servers/widgets/add_server_fab.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/servers/widgets/server_tab.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/servers/widgets/settings_fab.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/servers_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class Servers extends HookWidget {
  const Servers({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ServersCubit.create(),
      child: const Scaffold(body: _Body()),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final state = context.select((ServersCubit cubit) => cubit.state);
    final selectedServer = state.selectedServer;
    final servers = state.servers;
    return Column(
      children: [
        Row(
          children: [
            const AddServerFAB(),
            ...state.servers.map(
              (server) => ServerTab(server: server, isSelected: server == selectedServer),
            ),
            const Spacer(),
            const SettingsFab(),
          ],
        ),
        if (selectedServer != null) ...[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: context.sizes.edgeSpacing,
                right: context.sizes.edgeSpacing,
                bottom: context.sizes.edgeSpacing,
              ),
              child: RCON(server: selectedServer, key: ValueKey(selectedServer)),
            ),
          ),
        ] else ...[
          Expanded(
            child: Center(
              child: servers.isEmpty
                  ? const Text('Add a server to get started.')
                  : const Text('Select a server to view RCON console.'),
            ),
          ),
        ],
      ],
    );
  }
}
