import 'package:arkie_mobile/core/theme.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/models/message.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/models/saved_message.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/rcon_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message, required this.savedMessage});

  final Message message;
  final SavedMessage? savedMessage;

  @override
  Widget build(BuildContext context) {
    final isClient = message.sender == Sender.client;
    final colorScheme = Theme.of(context).colorScheme;
    return Align(
      alignment: isClient ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: isClient
            ? () async {
                await _showMessageActions(context);
              }
            : null,
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.84),
          padding: const EdgeInsets.fromLTRB(14, 11, 14, 10),
          decoration: BoxDecoration(
            color: isClient ? colorScheme.primaryContainer : arkieSurface,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isClient ? 18 : 5),
              bottomRight: Radius.circular(isClient ? 5 : 18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isClient ? Icons.arrow_upward_rounded : Icons.south_rounded,
                    size: 13,
                    color: isClient ? colorScheme.onPrimaryContainer : colorScheme.primary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    isClient ? 'COMMAND' : 'SERVER',
                    style: TextStyle(
                      fontSize: 9,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w800,
                      color: isClient ? colorScheme.onPrimaryContainer : colorScheme.primary,
                    ),
                  ),
                  if (savedMessage != null) ...[
                    const SizedBox(width: 7),
                    Icon(Icons.bookmark_rounded, size: 12, color: colorScheme.primary),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              SelectableText(
                message.bodyWithoutTerminalCharacter,
                style: TextStyle(
                  color: isClient ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showMessageActions(BuildContext context) async {
    final cubit = context.read<RCONCubit>();
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.replay_rounded),
              title: const Text('Send again'),
              onTap: () async {
                await cubit.sendCommand(message.body);
                if (!context.mounted) return;
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(
                savedMessage == null ? Icons.bookmark_add_outlined : Icons.bookmark_remove_outlined,
              ),
              title: Text(savedMessage == null ? 'Save command' : 'Remove saved command'),
              onTap: () async {
                if (savedMessage == null) {
                  await cubit.saveMessage(message);
                } else {
                  await cubit.unsaveMessage(savedMessage!);
                }
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
