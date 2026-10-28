import 'package:arkie_ui/src/arkie_icons.dart';
import 'package:flutter/material.dart';

extension ArkieBuildContextX on BuildContext {
  ArkieIcons get icons {
    final icons = Theme.of(this).extension<ArkieIcons>();
    if (icons == null) {
      throw Exception('ArkieIcons not found in ThemeData extensions. Is it added to the theme?');
    }
    return icons;
  }
}
