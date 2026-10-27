import 'package:cs2_rcon_front_end/features/rcon/presentation/rcon_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SavedCommandsTab extends StatelessWidget {
  const SavedCommandsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final savedMessages = context.select((RCONCubit cubit) => cubit.state.savedMessages);
    if (savedMessages.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Saved commands will appear here. Long-press a command in the chat to save it.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, height: 1.5),
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      itemCount: savedMessages.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final saved = savedMessages[index];
        return Material(
          color: Theme.of(context).colorScheme.surfaceContainer,
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
