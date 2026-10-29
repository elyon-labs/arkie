import 'package:arkie_core/features/servers/data/models/server.dart';
import 'package:arkie_state/features/servers/servers_cubit.dart';
import 'package:arkie_ui/arkie_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The actions a server line can take beyond opening it. Long-pressing the line
/// is the only way in, so anything destructive lives here rather than one tap
/// away in the list.
Future<void> showServerActionsSheet(BuildContext context, Server server) async {
  final cubit = context.read<ServersCubit>();
  final messenger = ScaffoldMessenger.of(context);

  final action = await showModalBottomSheet<_ServerAction>(
    context: context,
    showDragHandle: true,
    builder: (_) => _ServerActionsSheet(server: server),
  );

  if (action != _ServerAction.delete || !context.mounted) return;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => _ConfirmDeleteServerDialog(server: server),
  );

  if (confirmed != true) return;

  final result = await cubit.removeServer(server);
  result.match(
    (_) => messenger.showSnackBar(SnackBar(content: Text('Deleted ${server.name}.'))),
    (error) => messenger.showSnackBar(SnackBar(content: Text(error.toString()))),
  );
}

enum _ServerAction { delete }

class _ServerActionsSheet extends StatelessWidget {
  const _ServerActionsSheet({required this.server});

  final Server server;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              ArkieMetrics.edge,
              0,
              ArkieMetrics.edge,
              ArkieMetrics.snug,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  server.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.body.copyWith(color: context.colors.accent),
                ),
                Text(
                  '${server.address}:${server.port}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.caption.copyWith(color: context.arkieColors.textFaint),
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: Icon(context.icons.delete, color: context.colors.error),
            title: Text(
              'Delete server',
              style: context.text.body.copyWith(color: context.colors.error),
            ),
            onTap: () => Navigator.of(context).pop(_ServerAction.delete),
          ),
          const VSpace(space: ArkieMetrics.tight),
        ],
      ),
    );
  }
}

class _ConfirmDeleteServerDialog extends StatelessWidget {
  const _ConfirmDeleteServerDialog({required this.server});

  final Server server;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete server'),
      content: Text('Delete ${server.name} and its command log? This cannot be undone.'),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text('Delete', style: TextStyle(color: context.colors.error)),
        ),
      ],
    );
  }
}
