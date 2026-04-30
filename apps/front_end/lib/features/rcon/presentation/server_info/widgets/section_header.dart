import 'package:cs2_rcon_front_end/core_ui/_build_context.dart';
import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.actions = const []});

  final Widget title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        DefaultTextStyle.merge(
          child: title,
          style: context.text.header,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Row(
            children: [
              for (final action in actions)
                FractionalTranslation(translation: const Offset(0.25, 0), child: action),
            ],
          ),
        ),
      ],
    );
  }
}
