import 'package:cs2_rcon_front_end/features/servers/presentation/add_server_dialog/add_server_dialog_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

class ServerAddressField extends HookWidget {
  const ServerAddressField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (value) {
        context.read<AddServerDialogCubit>().setAddress(value);
      },
      keyboardType: TextInputType.url,
      decoration: const InputDecoration(hintText: 'Server address'),
    );
  }
}
