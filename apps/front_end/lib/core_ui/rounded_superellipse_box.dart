import 'package:cs2_rcon_front_end/core_ui/_build_context.dart';
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
          borderRadius: BorderRadius.all(Radius.circular(context.sizes.borderRadius)),
        ),
      ),
      child: child,
    );
  }
}
