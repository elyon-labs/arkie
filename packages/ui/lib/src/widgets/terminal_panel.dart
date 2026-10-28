import 'package:arkie_ui/src/_build_context.dart';
import 'package:arkie_ui/src/arkie_metrics.dart';
import 'package:design/design.dart';
import 'package:flutter/material.dart';

/// A pane drawn as an outline, with its label notched into the top border.
///
/// ```
/// ┌─ server ──────────────── live ─┐
/// │ address..............10.0.0.4  │
/// └────────────────────────────────┘
/// ```
///
/// The label and [trailing] sit on the border line itself, each filled with
/// [notchColor] so they cut the border rather than overlap it. That colour has
/// to match whatever the pane is painted on, which is the body by default.
class TerminalPanel extends StatelessWidget {
  const TerminalPanel({
    super.key,
    required this.child,
    this.label,
    this.trailing,
    this.focused = false,
    this.padding = const EdgeInsets.all(ArkieMetrics.edge),
    this.fill,
    this.notchColor,
  });

  final Widget child;

  /// Named like the command that would produce the pane's contents, so it reads
  /// as part of the console rather than as a heading over it.
  final String? label;

  /// Notched into the right of the top border, opposite [label]. A status lamp,
  /// a count, or anything else that qualifies the whole pane.
  final Widget? trailing;

  /// Draws the outline in `borderStrong`, marking the pane being acted on.
  final bool focused;

  final EdgeInsetsGeometry padding;

  /// Panes are outlines by default; a fill is for the few that need to sit
  /// above another pane, such as a menu or a suggestion list.
  final Color? fill;

  /// What the pane is painted on. The notches are filled with it to cut the
  /// border cleanly.
  final Color? notchColor;

  @override
  Widget build(BuildContext context) {
    final arkie = context.arkieColors;
    final cutColor = notchColor ?? context.colors.body;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: fill,
            border: Border.all(
              color: focused ? arkie.borderStrong : arkie.border,
              width: ArkieMetrics.hairline,
            ),
          ),
          child: Padding(padding: padding, child: child),
        ),
        if (label != null)
          _Notch(
            alignment: Alignment.topLeft,
            color: cutColor,
            child: Text(
              label!,
              style: context.text.caption.copyWith(
                color: focused ? context.colors.accent : context.colors.muted,
              ),
            ),
          ),
        if (trailing != null)
          _Notch(alignment: Alignment.topRight, color: cutColor, child: trailing!),
      ],
    );
  }
}

/// Straddles the top border, filled so the border does not show through.
class _Notch extends StatelessWidget {
  const _Notch({required this.alignment, required this.color, required this.child});

  final Alignment alignment;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isLeft = alignment == Alignment.topLeft;

    return Positioned(
      top: 0,
      left: isLeft ? ArkieMetrics.notchInset : null,
      right: isLeft ? null : ArkieMetrics.notchInset,
      child: FractionalTranslation(
        translation: const Offset(0, -0.5),
        child: ColoredBox(
          color: color,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: ArkieMetrics.gutter + 2),
            child: child,
          ),
        ),
      ),
    );
  }
}
