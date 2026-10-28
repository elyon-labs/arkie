import 'package:flutter/material.dart';

class FadeTransitionsBuilder extends PageTransitionsBuilder {
  const FadeTransitionsBuilder({this.duration = const Duration(milliseconds: 90)});
  final Duration duration;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
    return FadeTransition(opacity: curved, child: child);
  }
}
