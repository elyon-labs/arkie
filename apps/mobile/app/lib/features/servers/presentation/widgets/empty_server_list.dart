import 'package:arkie_mobile/features/servers/presentation/add_server_sheet/add_server_sheet.dart';
import 'package:flutter/material.dart';

class EmptyServerList extends StatelessWidget {
  const EmptyServerList({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 48, 32, 128),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.dns_rounded, size: 42, color: colorScheme.primary),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your server list is quiet',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(
              'Add a CS2 server to keep its RCON console, saved commands, and maps one tap away.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant, height: 1.5),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () async {
                await showAddServerSheet(context);
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add your first server'),
            ),
          ],
        ),
      ),
    );
  }
}
