import 'package:cs2_rcon_front_end/core_ui/_build_context.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/add_server_dialog/add_server_dialog.dart';
import 'package:flutter/material.dart';

class AddServerFAB extends StatelessWidget {
  const AddServerFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.sizes.edgeSpacing),
      child: FloatingActionButton.small(
        tooltip: 'Add Server',
        onPressed: () async {
          await showDialog(context: context, builder: (context) => const AddServerDialog());
        },
        child: Icon(context.icons.add),
      ),
    );
  }
}
