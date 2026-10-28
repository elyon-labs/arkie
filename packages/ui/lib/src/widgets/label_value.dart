import 'package:arkie_ui/src/_build_context.dart';
import 'package:arkie_ui/src/widgets/dot_leaders.dart';
import 'package:design/design.dart';
import 'package:flutter/material.dart';

/// A label and its value on one line, joined by dot leaders.
///
/// ```
/// players......................12/24
/// ```
///
/// Monospace means every value in a stack of these lands on the same column,
/// which is what makes a pane full of them scannable.
class LabelValue extends StatelessWidget {
  const LabelValue({super.key, required this.label, required this.value});

  final Widget label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    final leaderStyle = context.text.body.copyWith(color: context.arkieColors.textFaint);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DefaultTextStyle.merge(
          style: context.text.body.copyWith(color: context.colors.muted),
          child: label,
        ),
        Expanded(child: DotLeaders(style: leaderStyle)),
        DefaultTextStyle.merge(
          style: context.text.body,
          textAlign: TextAlign.end,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          child: value,
        ),
      ],
    );
  }
}
