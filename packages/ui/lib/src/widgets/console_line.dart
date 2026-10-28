import 'package:arkie_ui/src/_build_context.dart';
import 'package:arkie_ui/src/arkie_metrics.dart';
import 'package:design/design.dart';
import 'package:flutter/material.dart';

/// One line of console traffic: either a command you sent or what came back.
///
/// ```
/// > status
///   hostname : Larry's Server
///   players  : 12 humans, 4 bots
/// ```
///
/// Your commands carry the prompt sigil and the accent; the server's reply is
/// plain and sits in the same column the sigil leaves free. Output is the bulk
/// of what is on screen, so colouring it would tint the whole console and leave
/// nothing for the accent to mean.
class ConsoleLine extends StatelessWidget {
  const ConsoleLine({
    super.key,
    required this.text,
    required this.isInput,
    this.marked = false,
    this.highlighted = false,
    this.trailing,
  });

  final String text;

  /// A command you sent, rather than a reply from the server.
  final bool isInput;

  /// The command is saved, and is in the saved-commands list.
  final bool marked;

  /// Fills the line, for the one being hovered or acted on.
  final bool highlighted;

  /// Shown at the end of the line, for per-line actions.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final arkie = context.arkieColors;

    return ColoredBox(
      color: highlighted ? arkie.surfacePressed : Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ArkieMetrics.edge,
          vertical: ArkieMetrics.gutter,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 18,
              child: isInput
                  ? Text('>', style: context.text.body.copyWith(color: colors.accent))
                  : null,
            ),
            Expanded(
              child: Text(
                text,
                style: context.text.body.copyWith(
                  color: isInput ? colors.accent : colors.foreground,
                  height: 1.45,
                ),
              ),
            ),
            if (marked) ...[
              const HSpace(space: ArkieMetrics.tight),
              Text('saved', style: context.text.caption.copyWith(color: arkie.textFaint)),
            ],
            if (trailing != null) ...[const HSpace(space: ArkieMetrics.tight), trailing!],
          ],
        ),
      ),
    );
  }
}
