import 'package:arkie_core/features/rcon/data/models/message.dart';
import 'package:arkie_core/features/rcon/data/models/saved_message.dart';
import 'package:arkie_state/features/rcon/rcon_cubit.dart';
import 'package:arkie_ui/arkie_ui.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/message_row/widgets/client_message_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

/// One line of the console log. Hovering a command you sent reveals what can
/// be done with it, so the actions cost nothing until they are wanted.
class MessageRow extends HookWidget {
  const MessageRow({super.key, required this.message, required this.associatedSavedMessage});

  final Message message;
  final SavedMessage? associatedSavedMessage;

  @override
  Widget build(BuildContext context) {
    final isInput = message.sender == Sender.client;
    final showOptions = useState(false);

    final line = ConsoleLine(
      text: message.body,
      isInput: isInput,
      marked: associatedSavedMessage != null,
      highlighted: showOptions.value && isInput,
      trailing: showOptions.value && isInput
          ? ClientMessageOptions(
              isSaved: associatedSavedMessage != null,
              onToggleSave: () async {
                if (associatedSavedMessage != null) {
                  await context.read<RCONCubit>().unsaveMessage(associatedSavedMessage!);
                } else {
                  await context.read<RCONCubit>().saveMessage(message);
                }
              },
              onResend: () => context.read<RCONCubit>().sendCommand(message.body),
            )
          : null,
    );

    if (!isInput) return line;

    return MouseRegion(
      onEnter: (_) => showOptions.value = true,
      onExit: (_) => showOptions.value = false,
      child: line,
    );
  }
}
