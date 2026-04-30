import 'package:cs2_rcon_front_end/core_ui/colors.dart';
import 'package:cs2_rcon_front_end/core_ui/icons.dart';
import 'package:cs2_rcon_front_end/core_ui/sizes.dart';
import 'package:cs2_rcon_front_end/core_ui/text.dart';
import 'package:flutter/material.dart';

extension CoreUIBuildContextX on BuildContext {
  CS2RCONColors get colors {
    final colors = Theme.of(this).extension<CS2RCONColors>();
    if (colors == null) {
      throw Exception('CS2RCONColors not found in ThemeData extensions. Is it added to the theme?');
    }
    return colors;
  }

  CS2RCONIcons get icons {
    final icons = Theme.of(this).extension<CS2RCONIcons>();
    if (icons == null) {
      throw Exception('CS2RCONIcons not found in ThemeData extensions. Is it added to the theme?');
    }
    return icons;
  }

  CS2RCONText get text {
    final text = Theme.of(this).extension<CS2RCONText>();
    if (text == null) {
      throw Exception('CS2RCONText not found in ThemeData extensions. Is it added to the theme?');
    }
    return text;
  }

  CS2RCONSizes get sizes {
    final sizes = Theme.of(this).extension<CS2RCONSizes>();
    if (sizes == null) {
      throw Exception('CS2RCONSizes not found in ThemeData extensions. Is it added to the theme?');
    }
    return sizes;
  }
}
