import 'package:arkie_mobile/features/servers/presentation/add_server_sheet/add_server_sheet.dart';
import 'package:arkie_ui/arkie_ui.dart';
import 'package:flutter/material.dart';

class EmptyServerList extends StatelessWidget {
  const EmptyServerList({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 48, 32, 128),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: colors.selected.withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
              child: Icon(context.icons.server, size: 42, color: colors.primary),
            ),
            const VSpace(space: 24),
            const Text(
              'Your server list is quiet',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
            ),
            const VSpace(space: 10),
            Text(
              'Add a CS2 server to keep its RCON console, saved commands, and maps one tap away.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.muted, height: 1.5),
            ),
            const VSpace(space: 24),
            FilledButton.icon(
              onPressed: () async {
                await showAddServerSheet(context);
              },
              icon: Icon(context.icons.add),
              label: const Text('Add your first server'),
            ),
          ],
        ),
      ),
    );
  }
}
