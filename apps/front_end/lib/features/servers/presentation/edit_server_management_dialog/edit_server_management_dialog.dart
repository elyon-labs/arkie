import 'package:cs2_rcon_front_end/core_ui/_build_context.dart';
import 'package:cs2_rcon_front_end/features/server_management/domain/models/private_key_health.dart';
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
        final busy = state.isSaving || state.isSelecting;
        final canSave =
            !state.enabled ||
            (state.sshHost.trim().isNotEmpty &&
                state.sshPort > 0 &&
                state.sshPort <= 65535 &&
                state.sshUser.trim().isNotEmpty &&
                state.hostKeyFingerprint.trim().isNotEmpty &&
                state.keyHealthStatus == PrivateKeyHealthStatus.usable);
        return AlertDialog(
          title: const Text('Server management'),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Manage server over SSH'),
                    value: state.enabled,
                    onChanged: busy ? null : cubit.setEnabled,
                  ),
                  if (state.enabled)
                    ServerManagementForm(
                      sshHost: state.sshHost,
                      sshPort: state.sshPort,
                      sshUser: state.sshUser,
                      hostKeyFingerprint: state.hostKeyFingerprint,
                      privateKeyDisplayName: state.privateKeyDisplayName,
                      privateKeyError: state.error,
                      keyRequired:
                          state.keyHealthStatus == PrivateKeyHealthStatus.replacementRequired,
                      isBusy: busy,
                      onSshHostChanged: cubit.setSshHost,
                      onSshPortChanged: cubit.setSshPort,
                      onSshUserChanged: cubit.setSshUser,
                      onHostKeyFingerprintChanged: cubit.setHostKeyFingerprint,
                      onChoosePrivateKey: cubit.choosePrivateKey,
                    )
                  else
                    const Text(
                      'Saving will disable process management and remove Arkie’s managed key copy.',
                    ),
                  if (!state.enabled && state.error != null) ...[
                    SizedBox(height: context.sizes.unit),
                    Text(
                      state.error!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: busy ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: busy || !canSave ? null : cubit.save,
              child: Text(state.isSaving ? 'Saving…' : 'Save'),
            ),
          ],
        );
      },
    );
  }
}
