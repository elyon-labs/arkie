import 'package:arkie_state/features/servers/add_server_dialog/add_server_dialog_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

class ServerPortField extends HookWidget {
  const ServerPortField({super.key, this.enabled = true});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: enabled,
      onChanged: (value) {
        context.read<AddServerDialogCubit>().setPort(int.tryParse(value) ?? 0);
      },
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(hintText: 'Server port'),
    );
  }
}
