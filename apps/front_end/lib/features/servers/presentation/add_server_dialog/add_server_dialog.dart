import 'package:cs2_rcon_front_end/core/async.dart';
import 'package:cs2_rcon_front_end/core_ui/_build_context.dart';
import 'package:cs2_rcon_front_end/features/servers/data/models/server.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/add_server_dialog/add_server_dialog_cubit.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/add_server_dialog/add_server_dialog_state.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/add_server_dialog/widgets/server_address_field.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/add_server_dialog/widgets/server_name_field.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/add_server_dialog/widgets/server_password_field.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/add_server_dialog/widgets/server_port_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxidized/oxidized.dart';

class AddServerDialog extends StatelessWidget {
  const AddServerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add server'),
      content: AddServerForm(
        onServerAdded: (_) => Navigator.of(context).pop(),
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }
}

class AddServerForm extends StatelessWidget {
  const AddServerForm({super.key, required this.onServerAdded, required this.onCancel});

  final ValueChanged<Server> onServerAdded;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddServerDialogCubit.create(),
      child: _AddServerFormBody(onServerAdded: onServerAdded, onCancel: onCancel),
    );
  }
}

class _AddServerFormBody extends StatelessWidget {
  const _AddServerFormBody({required this.onServerAdded, required this.onCancel});

  final ValueChanged<Server> onServerAdded;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddServerDialogCubit, AddServerDialogState>(
      listenWhen: (previous, current) => previous.addServerResult != current.addServerResult,
      listener: (context, state) {
        final addServerResult = state.addServerResult;
        switch (addServerResult) {
          case Loaded<Result<Server, String>>(:final value):
            switch (value) {
              case Ok<Server, String>(:final value):
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Server added successfully')));
                onServerAdded(value);
              case Err<Server, String>(:final error):
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Failed to add server: $error')));
            }
          case Error<Result<Server, String>>(:final error):
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Failed to add server: $error')));
          default:
            break;
        }
      },
      child: BlocBuilder<AddServerDialogCubit, AddServerDialogState>(
        builder: (context, state) {
          final isSaving = state.addServerResult is Loading<Result<Server, String>>;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: context.sizes.unit),
              const ServerNameField(),
              SizedBox(height: context.sizes.unit),
              const ServerAddressField(),
              SizedBox(height: context.sizes.unit),
              const ServerPortField(),
              SizedBox(height: context.sizes.unit),
              const ServerPasswordField(),
              SizedBox(height: context.sizes.unit),
              const _ServerManagementFields(),
              SizedBox(height: context.sizes.unit * 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: isSaving ? null : onCancel, child: const Text('Cancel')),
                  SizedBox(width: context.sizes.unit),
                  TextButton(
                    onPressed: isSaving
                        ? null
                        : () async {
                            await context.read<AddServerDialogCubit>().saveServer();
                          },
                    child: isSaving ? const Text('Adding...') : const Text('Add'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ServerManagementFields extends StatelessWidget {
  const _ServerManagementFields();

  @override
  Widget build(BuildContext context) {
    final state = context.select((AddServerDialogCubit cubit) => cubit.state);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Manage server over SSH'),
          subtitle: const Text('Systemd backend via the arkie-cs2 dispatcher'),
          value: state.enableManagement,
          onChanged: context.read<AddServerDialogCubit>().setEnableManagement,
        ),
        if (state.enableManagement) ...[
          TextField(
            onChanged: context.read<AddServerDialogCubit>().setSshHost,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(hintText: 'SSH host'),
          ),
          SizedBox(height: context.sizes.unit),
          TextField(
            onChanged: (value) => context.read<AddServerDialogCubit>().setSshPort(
              int.tryParse(value) ?? state.sshPort,
            ),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'SSH port (default 22)'),
          ),
          SizedBox(height: context.sizes.unit),
          TextFormField(
            initialValue: state.sshUser,
            onChanged: context.read<AddServerDialogCubit>().setSshUser,
            decoration: const InputDecoration(hintText: 'SSH user (arkie-cs2)'),
          ),
          SizedBox(height: context.sizes.unit),
          TextField(
            onChanged: context.read<AddServerDialogCubit>().setPrivateKeyPath,
            decoration: const InputDecoration(hintText: 'Private key path on this computer'),
          ),
          SizedBox(height: context.sizes.unit),
          TextField(
            onChanged: context.read<AddServerDialogCubit>().setHostKeyFingerprint,
            decoration: const InputDecoration(hintText: 'Host key fingerprint (SHA256:...)'),
          ),
        ],
      ],
    );
  }
}
