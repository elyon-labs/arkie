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
        title: const _Wordmark(),
        actions: [
          IconButton(
            onPressed: () async => await showAddServerSheet(context),
            icon: Icon(context.icons.add),
            tooltip: 'Add a server',
          ),
          const HSpace(space: ArkieMetrics.tight),
        ],
      ),
      body: servers.isEmpty ? const EmptyServerList() : ServerList(servers: servers),
    );
  }
}

/// The prompt the whole app hangs off: `arkie` is the command you would have
/// typed to get here.
class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('>', style: context.text.title.copyWith(color: context.colors.accent)),
        const HSpace(space: ArkieMetrics.tight),
        Text('arkie', style: context.text.title),
      ],
    );
  }
}
