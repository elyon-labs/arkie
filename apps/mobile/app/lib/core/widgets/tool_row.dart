import 'package:arkie_ui/arkie_ui.dart';
import 'package:flutter/material.dart';

/// One row in a list: a name, what it is underneath, and whatever acts on it at
/// the end.
///
/// The lists built from these hold quite different kinds of thing — commands,
/// maps, players, links — and giving them all one row shape is what lets each
/// one read as a single list rather than a stack of unrelated controls.
class ToolRow extends StatelessWidget {
  const ToolRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.selected = false,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// The map that is loaded, or whatever else this list is currently on.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final arkie = context.arkieColors;

    return InkWell(
      onTap: onTap,
      highlightColor: arkie.surfacePressed,
      child: ColoredBox(
        color: selected ? arkie.accentSurface : Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ArkieMetrics.edge,
            vertical: ArkieMetrics.snug,
          ),
          child: Row(
            children: [
              if (leading != null) ...[leading!, const HSpace(space: ArkieMetrics.snug)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.body.copyWith(
                        color: selected ? context.colors.accent : context.colors.foreground,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.caption.copyWith(color: arkie.textFaint),
                      ),
                  ],
                ),
              ),
              if (trailing != null) ...[const HSpace(space: ArkieMetrics.tight), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}
