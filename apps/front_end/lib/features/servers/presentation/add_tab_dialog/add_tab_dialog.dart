import 'package:cs2_rcon_front_end/core_ui/_build_context.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/add_server_dialog/add_server_dialog.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/servers_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Shows the appropriate dialog for opening a new tab.
///
/// If no servers exist, the [AddServerDialog] is shown directly.
/// Otherwise, a choice is presented: select an existing server or add a new one.
Future<void> showAddTabDialog(BuildContext context) async {
  final cubit = context.read<ServersCubit>();
  final servers = cubit.state.servers;

  if (servers.isEmpty) {
    await showDialog<void>(context: context, builder: (_) => const AddServerDialog());
    return;
  }

  final shouldAddNew = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => BlocProvider.value(
      value: cubit,
      child: const _AddTabDialog(),
    ),
  );

  if ((shouldAddNew ?? false) && context.mounted) {
    await showDialog<void>(context: context, builder: (_) => const AddServerDialog());
  }
}

class _AddTabDialog extends StatelessWidget {
  const _AddTabDialog();

  @override
  Widget build(BuildContext context) {
    final servers = context.select((ServersCubit cubit) => cubit.state.servers);
    final selectedServer = context.select((ServersCubit cubit) => cubit.state.selectedServer);

    return AlertDialog(
      title: const Text('Open tab'),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select a server', style: context.text.caption),
            SizedBox(height: context.sizes.unit),
            ...servers.map(
              (server) => _ServerTile(
                server: server,
                isSelected: selectedServer?.id == server.id,
                onTap: () {
                  context.read<ServersCubit>().selectServer(server);
                  Navigator.of(context).pop(false);
                },
              ),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: context.sizes.unit),
              leading: Icon(context.icons.add),
              title: const Text('Add new server'),
              onTap: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class _ServerTile extends StatelessWidget {
  const _ServerTile({
    required this.server,
    required this.isSelected,
    required this.onTap,
  });

  final Server server;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: context.sizes.unit),
      title: Text(server.name),
      trailing: isSelected ? Icon(context.icons.check) : null,
      onTap: onTap,
    );
  }
}
