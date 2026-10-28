import 'package:arkie_mobile/features/servers/presentation/add_server_sheet/add_server_sheet.dart';
import 'package:arkie_ui/arkie_ui.dart';
import 'package:flutter/material.dart';

/// An empty list is an invitation, so the pane is already drawn and waiting —
/// the same one the servers will fill.
class EmptyServerList extends StatelessWidget {
  const EmptyServerList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        ArkieMetrics.edge,
        ArkieMetrics.loose,
        ArkieMetrics.edge,
        ArkieMetrics.section,
      ),
      children: [
        TerminalPanel(
          label: 'servers',
          trailing: Text('0', style: context.text.caption.copyWith(color: context.colors.muted)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'No servers yet.',
                style: context.text.body.copyWith(color: context.colors.muted),
              ),
              const VSpace(space: ArkieMetrics.tight),
              Text(
                'Add a CS2 server and Arkie keeps its console, saved commands and maps a tap away.',
                style: context.text.caption.copyWith(color: context.arkieColors.textFaint),
              ),
              const VSpace(space: ArkieMetrics.loose),
              FilledButton(
                onPressed: () async => await showAddServerSheet(context),
                child: const Text('Add a server'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
