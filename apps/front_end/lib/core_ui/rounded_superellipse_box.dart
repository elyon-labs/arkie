import 'package:arkie_ui/arkie_ui.dart';
import 'package:flutter/material.dart';

class RoundedSuperellipseBox extends StatelessWidget {
  const RoundedSuperellipseBox({super.key, required this.child, this.color, this.side});

  final Widget child;
  final Color? color;
  final BorderSide? side;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: color,
        shape: RoundedSuperellipseBorder(
          side: side ?? BorderSide.none,
          borderRadius: const BorderRadius.all(Radius.circular(Sizes.borderRadius)),
        ),
      ),
      child: child,
    );
  }
}
