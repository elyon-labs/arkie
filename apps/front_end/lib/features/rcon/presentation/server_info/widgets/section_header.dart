import 'package:arkie_ui/arkie_ui.dart';
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
          style: context.text.headline,
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
