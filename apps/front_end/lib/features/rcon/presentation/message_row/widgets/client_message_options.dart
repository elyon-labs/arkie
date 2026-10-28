import 'package:arkie_ui/arkie_ui.dart';
import 'package:flutter/material.dart';

/// What can be done with a command already in the log. Sized to the line it
/// sits on, so revealing it on hover does not shift the lines below.
class ClientMessageOptions extends StatelessWidget {
  const ClientMessageOptions({
    super.key,
    required this.isSaved,
    required this.onToggleSave,
    required this.onResend,
  });

  final bool isSaved;
  final VoidCallback onToggleSave;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Action(
          tooltip: isSaved ? 'Remove saved command' : 'Save command',
          icon: isSaved ? context.icons.unsave : context.icons.save,
          onPressed: onToggleSave,
        ),
        const HSpace(space: ArkieMetrics.gutter),
        _Action(tooltip: 'Send again', icon: context.icons.send, onPressed: onResend),
      ],
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.tooltip, required this.icon, required this.onPressed});

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(ArkieMetrics.gutter / 2),
          child: Icon(icon, size: 14, color: context.colors.muted),
        ),
      ),
    );
  }
}
