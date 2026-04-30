import 'package:cs2_rcon_front_end/features/servers/presentation/add_server_dialog/add_server_dialog.dart';
import 'package:flutter/material.dart';

class AddServerButton extends StatelessWidget {
  const AddServerButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () async {
        await showDialog(context: context, builder: (_) => const AddServerDialog());
      },
      child: const Text('Add server'),
    );
  }
}
