import 'package:arkie_mobile/core/widgets/centered_hint.dart';
import 'package:arkie_mobile/core/widgets/tool_row.dart';
import 'package:arkie_state/features/rcon/rcon_cubit.dart';
import 'package:arkie_ui/arkie_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SavedCommandsTab extends StatelessWidget {
  const SavedCommandsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final savedMessages = context.select((RCONCubit cubit) => cubit.state.savedMessages);
    if (savedMessages.isEmpty) {
      return const CenteredHint('Long-press a command in the console to save it here.');
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: ArkieMetrics.loose),
      itemCount: savedMessages.length,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, index) {
        final saved = savedMessages[index];
        return ToolRow(
          title: saved.name,
          subtitle: saved.body,
          leading: Text('>', style: context.text.body.copyWith(color: context.colors.accent)),
          onTap: () async {
            await context.read<RCONCubit>().sendCommand(saved.body);
            if (!context.mounted) return;
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}
