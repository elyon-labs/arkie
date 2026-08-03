import 'package:cs2_rcon_front_end/core_ui/_build_context.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/edit_server_management_dialog/edit_server_management_cubit.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/edit_server_management_dialog/edit_server_management_state.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/server_management_form/server_management_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditServerManagementDialog extends StatelessWidget {
  const EditServerManagementDialog({super.key, required this.server});

  final Server server;

  static Future<String?> show(BuildContext context, Server server) {
    return showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => EditServerManagementDialog(server: server),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EditServerManagementCubit.create(server),
      child: BlocListener<EditServerManagementCubit, EditServerManagementState>(
        listenWhen: (previous, current) => !previous.saved && current.saved,
        listener: (context, state) => Navigator.of(context).pop(state.cleanupWarning),
        child: const _Body(),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditServerManagementCubit, EditServerManagementState>(
      builder: (context, state) {
        final cubit = context.read<EditServerManagementCubit>();
        final isBusy = state.isSaving || state.isSelectingPrivateKey;
        final availableWidth = MediaQuery.sizeOf(context).width - (context.sizes.edgeSpacing * 4);
        final contentWidth = (availableWidth * 0.6).clamp(320.0, 560.0);
        return AlertDialog(
          title: const Text('Server management'),
          content: SizedBox(
            width: contentWidth,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Manage server over SSH'),
                    subtitle: const Text('Systemd backend via the arkie-cs2 dispatcher'),
                    value: state.enabled,
                    onChanged: isBusy ? null : cubit.setEnabled,
                  ),
                  if (state.enabled)
                    ServerManagementForm(
                      sshHost: state.sshHost,
                      sshPort: state.sshPort,
                      sshUser: state.sshUser,
                      hostKeyFingerprint: state.hostKeyFingerprint,
                      privateKeyDisplayName: state.privateKeyDisplayName,
                      privateKeyError: state.error,
                      isBusy: isBusy,
                      isSelectingPrivateKey: state.isSelectingPrivateKey,
                      onSshHostChanged: cubit.setSshHost,
                      onSshPortChanged: cubit.setSshPort,
                      onSshUserChanged: cubit.setSshUser,
                      onHostKeyFingerprintChanged: cubit.setHostKeyFingerprint,
                      onSelectPrivateKey: cubit.selectPrivateKey,
                    )
                  else ...[
                    const Text(
                      'Saving will disable process management and remove Arkie’s managed key copy.',
                    ),
                    if (state.error case final error?) ...[
                      SizedBox(height: context.sizes.unit),
                      Text(error, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ],
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isBusy ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: isBusy ? null : cubit.save,
              child: Text(state.isSaving ? 'Saving...' : 'Save'),
            ),
          ],
        );
      },
    );
  }
}
