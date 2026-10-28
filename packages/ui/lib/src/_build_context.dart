import 'package:arkie_ui/src/arkie_colors.dart';
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

extension ArkieColorsBuildContextX on BuildContext {
  ArkieColors get arkieColors {
    final colors = Theme.of(this).extension<ArkieColors>();
    if (colors == null) {
      throw Exception('ArkieColors not found in ThemeData extensions. Is it added to the theme?');
    }
    return colors;
  }
}
