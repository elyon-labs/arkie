import 'package:cs2_rcon_front_end/features/servers/presentation/add_server_dialog/add_server_dialog_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

class ServerPasswordField extends HookWidget {
  const ServerPasswordField({super.key, this.enabled = true});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: enabled,
      onChanged: (value) {
        context.read<AddServerDialogCubit>().setPassword(value);
      },
      obscureText: true,
      keyboardType: TextInputType.visiblePassword,
      decoration: const InputDecoration(hintText: 'Server password'),
    );
  }
}
