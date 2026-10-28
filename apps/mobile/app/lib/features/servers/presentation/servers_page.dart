import 'package:arkie_mobile/features/servers/presentation/add_server_sheet/add_server_sheet.dart';
import 'package:arkie_mobile/features/servers/presentation/widgets/empty_server_list.dart';
import 'package:arkie_mobile/features/servers/presentation/widgets/server_list.dart';
import 'package:arkie_state/features/servers/servers_cubit.dart';
import 'package:arkie_ui/arkie_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ServersPage extends StatelessWidget {
  const ServersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => ServersCubit.create(), child: const _ServersView());
  }
}

class _ServersView extends StatelessWidget {
  const _ServersView();

  @override
  Widget build(BuildContext context) {
    final servers = context.select((ServersCubit cubit) => cubit.state.servers);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Arkie', style: TextStyle(fontWeight: FontWeight.w800)),
            Text(
              'YOUR SERVERS',
              style: TextStyle(fontSize: 11, letterSpacing: 1.8, color: context.colors.muted),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => showAboutDialog(
              context: context,
              applicationName: 'Arkie',
              applicationVersion: 'Mobile preview',
              applicationLegalese: 'RCON console for Counter-Strike 2 servers.',
            ),
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'About Arkie',
          ),
          const HSpace(),
        ],
      ),
      body: servers.isEmpty ? const EmptyServerList() : ServerList(servers: servers),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await showAddServerSheet(context);
        },
        icon: Icon(context.icons.add),
        label: const Text('Add server'),
      ),
    );
  }
}
