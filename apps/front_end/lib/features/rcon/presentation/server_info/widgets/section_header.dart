import 'package:arkie_ui/arkie_ui.dart';
import 'package:flutter/material.dart';

/// A heading inside the sidebar pane, with a rule running out to whatever acts
/// on the section. The rule is what separates one section from the next, so
/// the sections need no boxes of their own.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.actions = const []});

  final Widget title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: DefaultTextStyle.merge(
            style: context.text.caption.copyWith(color: context.colors.muted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            child: title,
          ),
        ),
        const HSpace(space: ArkieMetrics.tight),
        Expanded(
          child: Container(height: ArkieMetrics.hairline, color: context.arkieColors.border),
        ),
        ...actions,
      ],
    );
  }
}
