import 'package:arkie_ui/arkie_ui.dart';
import 'package:cs2_rcon_front_end/core_ui/dot_leaders.dart';
import 'package:flutter/material.dart';

class LabelValue extends StatelessWidget {
  const LabelValue({super.key, required this.label, required this.value});

  final Widget label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        DefaultTextStyle.merge(
          style: context.text.body.copyWith(color: context.colors.muted),
          child: label,
        ),
        Expanded(
          child: DotLeaders(style: context.text.body.copyWith(color: context.colors.muted)),
        ),
        DefaultTextStyle.merge(
          textAlign: TextAlign.end,
          child: value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
