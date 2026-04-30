import 'package:cs2_rcon_front_end/core_ui/_build_context.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/models/message.dart';
import 'package:cs2_rcon_front_end/features/rcon/data/models/saved_message.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/message_row/widgets/client_message_options.dart';
import 'package:cs2_rcon_front_end/features/rcon/presentation/rcon_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

class MessageRow extends HookWidget {
  const MessageRow({super.key, required this.message, required this.associatedSavedMessage});

  final Message message;
  final SavedMessage? associatedSavedMessage;

  @override
  Widget build(BuildContext context) {
    final showOptions = useState(false);

    final color = switch (message.sender) {
      Sender.client => context.colors.foreground,
      Sender.server => context.colors.accent,
    };

    final child = Stack(
      alignment: Alignment.centerLeft,
      clipBehavior: Clip.none,
      children: [
        ColoredBox(
          color: showOptions.value && message.sender == Sender.client
              ? context.colors.modal
              : Colors.transparent,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.sizes.edgeSpacing,
              vertical: context.sizes.unit,
            ),
            child: SizedBox(
              width: double.infinity,
              child: Text(message.body, style: TextStyle(color: color)),
            ),
          ),
        ),
        if (showOptions.value && message.sender == Sender.client)
          Positioned(
            top: 0,
            right: 0,
            child: Align(
              alignment: Alignment.topRight,
              child: FractionalTranslation(
                translation: const Offset(0, -0.5),
                child: ClientMessageOptions(
                  isSaved: associatedSavedMessage != null,
                  onToggleSave: () async {
                    if (associatedSavedMessage != null) {
                      await context.read<RCONCubit>().unsaveMessage(associatedSavedMessage!);
                    } else {
                      await context.read<RCONCubit>().saveMessage(message);
                    }
                  },
                  onResend: () => context.read<RCONCubit>().sendCommand(message.body),
                ),
              ),
            ),
          ),
      ],
    );

    if (message.sender == Sender.server) {
      return child;
    }

    // Allow user to save client messages to favorite commands
    return MouseRegion(
      onEnter: (event) {
        showOptions.value = true;
      },
      onExit: (event) {
        showOptions.value = false;
      },
      child: child,
    );
  }
}
