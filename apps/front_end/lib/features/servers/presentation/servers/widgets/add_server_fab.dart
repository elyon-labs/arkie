import 'package:cs2_rcon_front_end/core_ui/_build_context.dart';
import 'package:cs2_rcon_front_end/features/servers/presentation/add_tab_dialog/add_tab_dialog.dart';
import 'package:flutter/material.dart';

class AddServerFAB extends StatelessWidget {
  const AddServerFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.sizes.edgeSpacing),
      child: FloatingActionButton.small(
        tooltip: 'Add Tab',
        onPressed: () async {
          await showAddTabDialog(context);
        },
        child: Icon(context.icons.add),
      ),
    );
  }
}
