import 'dart:async';

import 'package:arkie_mobile/features/rcon/presentation/widgets/message_bubble.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/models/message.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/models/saved_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class MessageList extends HookWidget {
  const MessageList({super.key, required this.messages, required this.savedMessages});

  final List<Message> messages;
  final List<SavedMessage> savedMessages;

  @override
  Widget build(BuildContext context) {
    final scrollController = useScrollController();
    useEffect(() {
      if (!scrollController.hasClients) return null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          unawaited(
            scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
            ),
          );
        }
      });
      return null;
    }, [messages.length]);

    if (messages.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.terminal_rounded, size: 34, color: Colors.white38),
              SizedBox(height: 14),
              Text('No command traffic yet', style: TextStyle(fontWeight: FontWeight.w700)),
              SizedBox(height: 6),
              Text(
                'Send a command below to start a conversation with the server.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.4),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      itemCount: messages.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final message = messages[index];
        SavedMessage? savedMessage;
        for (final saved in savedMessages) {
          if (saved.body.trim() == message.body.trim()) {
            savedMessage = saved;
            break;
          }
        }
        return MessageBubble(message: message, savedMessage: savedMessage);
      },
    );
  }
}
