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
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:oxidized/oxidized.dart';

class AddServerDialog extends HookWidget {
  const AddServerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddServerDialogCubit.create(),
      child: const _DialogBody(),
    );
  }
}

class _DialogBody extends HookWidget {
  const _DialogBody();

  @override
  Widget build(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final showSnackBar = useCallback((String message) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scaffoldMessenger.showSnackBar(SnackBar(content: Text(message)));
      });
    }, [scaffoldMessenger]);

    return BlocListener<AddServerDialogCubit, AddServerDialogState>(
      listenWhen: (previous, current) => previous.addServerResult != current.addServerResult,
      listener: (context, state) {
        final addServerResult = state.addServerResult;
        switch (addServerResult) {
          case Loaded<Result<Server, String>>(:final value):
            switch (value) {
              case Ok<Server, String>():
                showSnackBar('Server added successfully');
              case Err<Server, String>(:final error):
                showSnackBar('Failed to add server: $error');
            }
            Navigator.of(context).pop();
          case Error<Result<Server, String>>(:final error):
            showSnackBar('Failed to add server: $error');
          default:
            break;
        }
      },
      child: AlertDialog(
        title: const Text('Add server'),
        content: Column(
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await context.read<AddServerDialogCubit>().saveServer();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
