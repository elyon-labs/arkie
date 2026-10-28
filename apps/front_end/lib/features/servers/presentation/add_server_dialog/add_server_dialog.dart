import 'package:arkie_core/features/servers/data/models/server.dart';
import 'package:arkie_state/features/servers/add_server_dialog/add_server_dialog_cubit.dart';
import 'package:arkie_state/features/servers/add_server_dialog/add_server_dialog_state.dart';
import 'package:arkie_ui/arkie_ui.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/add_server_dialog/widgets/server_address_field.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/add_server_dialog/widgets/server_name_field.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/add_server_dialog/widgets/server_password_field.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/add_server_dialog/widgets/server_port_field.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/servers/widgets/demo_server_tile.dart';
import 'package:dart_foundation/dart_foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oxidized/oxidized.dart';

class AddServerForm extends StatelessWidget {
  const AddServerForm({
    super.key,
    required this.onServerAdded,
    required this.onCancel,
    this.offerDemoServer = false,
  });

  final ValueChanged<Server> onServerAdded;
  final VoidCallback onCancel;

  /// Whether to offer the demo server alongside the form. Only safe where a
  /// `ServersCubit` is in scope, which is what the demo offer is saved against.
  final bool offerDemoServer;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddServerDialogCubit.create(),
      child: _AddServerFormBody(
        onServerAdded: onServerAdded,
        onCancel: onCancel,
        offerDemoServer: offerDemoServer,
      ),
    );
  }
}

class _AddServerFormBody extends StatelessWidget {
  const _AddServerFormBody({
    required this.onServerAdded,
    required this.onCancel,
    required this.offerDemoServer,
  });

  final ValueChanged<Server> onServerAdded;
  final VoidCallback onCancel;
  final bool offerDemoServer;

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
              const VSpace(),
              ServerNameField(enabled: !isSaving),
              const VSpace(),
              ServerAddressField(enabled: !isSaving),
              const VSpace(),
              ServerPortField(enabled: !isSaving),
              const VSpace(),
              ServerPasswordField(enabled: !isSaving),
              const VSpace(space: ArkieMetrics.snug),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: isSaving ? null : onCancel, child: const Text('Cancel')),
                  const HSpace(),
                  TextButton(
                    onPressed: isSaving
                        ? null
                        : () async {
                            await context.read<AddServerDialogCubit>().saveServer();
                          },
                    child: Text(isSaving ? 'Connecting…' : 'Add server'),
                  ),
                ],
              ),
              if (offerDemoServer) ...[const Divider(), DemoServerTile(onAdded: onServerAdded)],
            ],
          );
        },
      ),
    );
  }
}
