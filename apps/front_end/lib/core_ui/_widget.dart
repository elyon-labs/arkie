import 'package:flutter/material.dart';

extension WidgetX on Widget {
  Widget debugBoundaries({Color color = Colors.red, ValueKey<String>? key}) {
    return ColoredBox(key: key, color: color, child: this);
  }
}
