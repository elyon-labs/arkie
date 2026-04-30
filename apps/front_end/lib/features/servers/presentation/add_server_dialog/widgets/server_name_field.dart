import 'package:cs2_rcon_front_end/features/servers/presentation/add_server_dialog/add_server_dialog_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

class ServerNameField extends HookWidget {
  const ServerNameField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (value) {
        context.read<AddServerDialogCubit>().setName(value);
      },
      decoration: const InputDecoration(hintText: 'Server name'),
    );
  }
}
