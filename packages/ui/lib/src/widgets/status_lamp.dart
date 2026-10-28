import 'package:arkie_ui/src/arkie_metrics.dart';
import 'package:design/design.dart';
import 'package:flutter/material.dart';

/// What the link to a server is currently doing.
enum LinkState { live, connecting, offline }

/// A square lamp and a word for [LinkState], small enough to notch into a
/// pane's top border or sit in an app bar.
///
/// The lamp is square rather than round because every other edge Arkie draws
/// is, and a round dot next to a drawn pane reads as borrowed from elsewhere.
class StatusLamp extends StatelessWidget {
  const StatusLamp({super.key, required this.state, this.label});

  final LinkState state;

  /// Replaces the state's own word, for cases where the pane says it better.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final (word, color) = switch (state) {
      LinkState.live => ('live', context.colors.good),
      LinkState.connecting => ('connecting', context.colors.warning),
      LinkState.offline => ('offline', context.colors.error),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 6, height: 6, color: color),
        const HSpace(space: ArkieMetrics.gutter + 2),
        Text(label ?? word, style: context.text.caption.copyWith(color: color)),
      ],
    );
  }
}
