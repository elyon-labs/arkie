import 'dart:async';

import 'package:collection/collection.dart';
import 'package:cs2_rcon_front_end/core_ui/_build_context.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/message_row/message_row.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/rcon_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class Messages extends HookWidget {
  const Messages({super.key});

  @override
  Widget build(BuildContext context) {
    final messagesController = useScrollController();
    final messages = context.select((RCONCubit cubit) => cubit.state.messages);
    final savedMessages = context.select((RCONCubit cubit) => cubit.state.savedMessages);
    // Auto-scroll to bottom when new messages arrive
    useEffect(
      () {
        if (messagesController.hasClients) {
          // Delaying allows `maxScrollIntent` to be calculated after the messages have
          // been updated
          Future.delayed(const Duration(milliseconds: 100), () {
            unawaited(
              messagesController.animateTo(
                messagesController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              ),
            );
          });
        }
        return null;
      },
      [
        messages.length,
        messagesController,
        if (messagesController.hasClients) messagesController.position.maxScrollExtent else null,
      ],
    );
    return SelectionArea(
      child: SingleChildScrollView(
        // Allow some padding at the top so the first message isn't flush against the top edge
        // This allows saving (or-resending) the top message if desired.
        padding: EdgeInsets.only(top: context.sizes.edgeSpacing),
        controller: messagesController,
        child: Column(
          children: [
            for (final message in messages)
              MessageRow(
                message: message,
                associatedSavedMessage: savedMessages.firstWhereOrNull(
                  (sm) => sm.body.trim() == message.body.trim(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
