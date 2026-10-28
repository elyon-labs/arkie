import 'package:arkie_ui/arkie_ui.dart';
import 'package:flutter/material.dart';

/// One row in a server-tools tab: a name, what it is underneath, and whatever
/// acts on it at the end.
///
/// The tabs hold three different kinds of thing, and giving them one row shape
/// is what lets the sheet read as a single list that changes contents.
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
