import 'dart:ui';

import 'package:flutter/material.dart';

class CS2RCONSizes extends ThemeExtension<CS2RCONSizes> {
  const CS2RCONSizes({required this.unit, required this.edgeSpacing, required this.borderRadius});

  final double unit;
  final double edgeSpacing;
  final double borderRadius;

  @override
  ThemeExtension<CS2RCONSizes> copyWith({double? unit, double? edgeSpacing, double? borderRadius}) {
    return CS2RCONSizes(
      unit: unit ?? this.unit,
      edgeSpacing: edgeSpacing ?? this.edgeSpacing,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  @override
  CS2RCONSizes lerp(ThemeExtension<CS2RCONSizes>? other, double t) {
    if (other is! CS2RCONSizes) {
      return this;
    }
    return CS2RCONSizes(
      unit: lerpDouble(unit, other.unit, t)!,
      edgeSpacing: lerpDouble(edgeSpacing, other.edgeSpacing, t)!,
      borderRadius: lerpDouble(borderRadius, other.borderRadius, t)!,
    );
  }
}
