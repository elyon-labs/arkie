import 'dart:async';

import 'package:arkie_core/features/rcon/data/models/message.dart';
import 'package:arkie_core/features/rcon/data/models/saved_message.dart';
import 'package:arkie_state/features/rcon/rcon_cubit.dart';
import 'package:arkie_ui/arkie_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// The console log: commands and replies in the order they happened, one
/// column, no sides. A command and the reply it produced belong together, and
/// putting them on opposite edges of the screen is what made that hard to read.
///
/// The list is built bottom-up so the newest line is on screen the moment the
/// log opens, without waiting for a scroll to settle after layout.
class MessageList extends HookWidget {
  const MessageList({super.key, required this.messages, required this.savedMessages});

  final List<Message> messages;
  final List<SavedMessage> savedMessages;

  @override
  Widget build(BuildContext context) {
    final scrollController = useScrollController();
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!scrollController.hasClients) return;
        unawaited(
          scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
          ),
        );
      });
      return null;
    }, [messages.length]);

    if (messages.isEmpty) return const _EmptyLog();

    return SelectionArea(
      child: ListView.builder(
        controller: scrollController,
        reverse: true,
        padding: const EdgeInsets.symmetric(vertical: ArkieMetrics.snug),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[messages.length - 1 - index];
          final isInput = message.sender == Sender.client;
          final saved = _savedMatching(message);

          return GestureDetector(
            onLongPress: isInput
                ? () async => await _showLineActions(context, message, saved)
                : null,
            child: ConsoleLine(
              text: message.bodyWithoutTerminalCharacter,
              isInput: isInput,
              marked: saved != null,
            ),
          );
        },
      ),
    );
  }

  SavedMessage? _savedMatching(Message message) {
    for (final saved in savedMessages) {
      if (saved.body.trim() == message.body.trim()) return saved;
    }
    return null;
  }
}

class _EmptyLog extends StatelessWidget {
  const _EmptyLog();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ArkieMetrics.section),
        child: Text(
          'Send a command to start the log.',
          textAlign: TextAlign.center,
          style: context.text.caption.copyWith(color: context.arkieColors.textFaint),
        ),
      ),
    );
  }
}

Future<void> _showLineActions(BuildContext context, Message message, SavedMessage? saved) async {
  final cubit = context.read<RCONCubit>();

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              ArkieMetrics.edge,
              0,
              ArkieMetrics.edge,
              ArkieMetrics.snug,
            ),
            child: Text(
              message.bodyWithoutTerminalCharacter,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: sheetContext.text.body.copyWith(color: sheetContext.colors.accent),
            ),
          ),
          const Divider(),
          ListTile(
            leading: Icon(sheetContext.icons.send),
            title: const Text('Send again'),
            onTap: () async {
              Navigator.of(sheetContext).pop();
              await cubit.sendCommand(message.body);
            },
          ),
          ListTile(
            leading: Icon(saved == null ? sheetContext.icons.save : sheetContext.icons.unsave),
            title: Text(saved == null ? 'Save command' : 'Remove saved command'),
            onTap: () async {
              Navigator.of(sheetContext).pop();
              if (saved == null) {
                await cubit.saveMessage(message);
              } else {
                await cubit.unsaveMessage(saved);
              }
            },
          ),
          const VSpace(space: ArkieMetrics.tight),
        ],
      ),
    ),
  );
}
