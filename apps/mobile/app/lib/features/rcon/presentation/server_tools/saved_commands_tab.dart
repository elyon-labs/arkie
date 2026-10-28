import 'package:arkie_mobile/core/widgets/centered_hint.dart';
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
      return const CenteredHint(
        'Saved commands will appear here. Long-press a command in the chat to save it.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      itemCount: savedMessages.length,
      separatorBuilder: (_, _) => const VSpace(),
      itemBuilder: (context, index) {
        final saved = savedMessages[index];
        return Material(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(16),
          child: ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            leading: const Icon(Icons.terminal_rounded),
            title: Text(saved.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(saved.body, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: const Icon(Icons.play_arrow_rounded),
            onTap: () async {
              await context.read<RCONCubit>().sendCommand(saved.body);
              if (!context.mounted) return;
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }
}
