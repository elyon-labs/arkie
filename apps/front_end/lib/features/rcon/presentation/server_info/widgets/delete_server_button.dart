import 'package:cs2_rcon_front_end/features/rcon/presentation/rcon_cubit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeleteServerButton extends StatelessWidget {
  const DeleteServerButton({super.key});

  @override
  Widget build(BuildContext context) {
    final server = context.select((RCONCubit cubit) => cubit.state.server);
    final dialogContext = context;

    return ElevatedButton(
      onPressed: () async {
        final shouldDelete = await showDialog<bool>(
          context: dialogContext,
          builder: (context) => const _ConfirmDeleteServerDialog(),
        );

        if ((shouldDelete ?? false) && context.mounted) {
          // Delete the server
          await dialogContext.read<RCONCubit>().removeServer(server);
        }
      },
      child: const Text('Delete Server'),
    );
  }
}

class _ConfirmDeleteServerDialog extends StatelessWidget {
  const _ConfirmDeleteServerDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete server'),
      content: const Text(
        'Are you sure you want to delete this server? This action cannot be undone.',
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
      ],
    );
  }
}
