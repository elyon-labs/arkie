import 'package:arkie_ui/src/arkie_theme.dart';
import 'package:arkie_ui/src/fade_transitions_builder.dart';
import 'package:design/design.dart';
import 'package:flutter/material.dart';

/// Builds the desktop app's [ThemeData] from [theme] (normally
/// [ArkieTheme.desktopDark] or [ArkieTheme.desktopLight]).
ThemeData buildDesktopTheme(ArkieTheme theme) {
  final colors = theme.colors;
  final base = theme.baseThemeData;
  final text = theme.buildText(base.textTheme);

  return base.copyWith(
    primaryColor: colors.body,
    secondaryHeaderColor: colors.accent,
    appBarTheme: base.appBarTheme.toCustomTheme(colors),
    floatingActionButtonTheme: base.floatingActionButtonTheme.toCustomTheme(colors),
    inputDecorationTheme: base.inputDecorationTheme.toCustomTheme(text, colors),
    elevatedButtonTheme: base.elevatedButtonTheme.toCustomTheme(colors),
    tooltipTheme: base.tooltipTheme.toCustomTheme(colors, theme.fontFamily),
    iconTheme: base.iconTheme.toCustomTheme(),
    iconButtonTheme: _buildIconButtonTheme(colors),
    dialogTheme: base.dialogTheme.toCustomTheme(colors, text),
    listTileTheme: base.listTileTheme.toCustomTheme(colors, text),
    dropdownMenuTheme: base.dropdownMenuTheme.toCustomTheme(colors),
    menuTheme: _buildMenuTheme(colors),
    pageTransitionsTheme: _buildPageTransitionsTheme(),
    extensions: <ThemeExtension<dynamic>>[colors, text, theme.icons],
  );
}

extension on InputDecorationThemeData {
  InputDecorationThemeData toCustomTheme(ElyonText text, ElyonColors colors) {
    return copyWith(
      border: const UnderlineInputBorder(),
      hintStyle: text.body.copyWith(color: colors.muted),
      floatingLabelBehavior: FloatingLabelBehavior.never,
    );
  }
}

extension on ElevatedButtonThemeData {
  ElevatedButtonThemeData toCustomTheme(ElyonColors colors) {
    return ElevatedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(colors.foreground),
        backgroundColor: WidgetStatePropertyAll(colors.body),
        surfaceTintColor: WidgetStatePropertyAll(colors.body),
        shadowColor: const WidgetStatePropertyAll(Colors.transparent),
        overlayColor: WidgetStatePropertyAll(colors.card),
        shape: const WidgetStatePropertyAll(
          RoundedSuperellipseBorder(
            borderRadius: BorderRadius.all(Radius.circular(Sizes.borderRadius)),
          ),
        ),
      ),
    );
  }
}

extension on FloatingActionButtonThemeData {
  FloatingActionButtonThemeData toCustomTheme(ElyonColors colors) {
    return copyWith(
      backgroundColor: colors.body,
      elevation: 0,
      shape: const RoundedSuperellipseBorder(
        borderRadius: BorderRadius.all(Radius.circular(Sizes.borderRadius)),
      ),
    );
  }
}

extension on TooltipThemeData {
  TooltipThemeData toCustomTheme(ElyonColors colors, String fontFamily) {
    return copyWith(
      textStyle: TextStyle(color: colors.foreground, fontFamily: fontFamily, fontSize: 12),
      decoration: ShapeDecoration(
        color: colors.body,
        shape: RoundedSuperellipseBorder(
          borderRadius: const BorderRadius.all(Radius.circular(Sizes.borderRadius)),
          side: BorderSide(color: colors.divider),
        ),
      ),
    );
  }
}

extension on DialogThemeData {
  DialogThemeData toCustomTheme(ElyonColors colors, ElyonText text) {
    return copyWith(
      contentTextStyle: text.body,
      insetPadding: EdgeInsets.zero,
      actionsPadding: const EdgeInsets.all(Sizes.edgePadding),
      titleTextStyle: text.headline,
      backgroundColor: colors.modal,
      shape: const RoundedSuperellipseBorder(
        borderRadius: BorderRadius.all(Radius.circular(Sizes.borderRadius)),
      ),
    );
  }
}

extension on IconThemeData {
  IconThemeData toCustomTheme() {
    return copyWith(size: Sizes.unit * 2.5);
  }
}

extension on ListTileThemeData {
  ListTileThemeData toCustomTheme(ElyonColors colors, ElyonText text) {
    return copyWith(
      contentPadding: const EdgeInsets.symmetric(horizontal: Sizes.edgePadding),
      visualDensity: VisualDensity.compact,
      titleTextStyle: text.title,
      subtitleTextStyle: text.caption,
      selectedColor: colors.accent,
    );
  }
}

extension on DropdownMenuThemeData {
  DropdownMenuThemeData toCustomTheme(ElyonColors colors) {
    return copyWith(
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(colors.modal),
        shape: const WidgetStatePropertyAll(
          RoundedSuperellipseBorder(
            borderRadius: BorderRadius.all(Radius.circular(Sizes.borderRadius / 2)),
          ),
        ),
      ),
    );
  }
}

extension on AppBarThemeData {
  AppBarThemeData toCustomTheme(ElyonColors colors) {
    return copyWith(
      backgroundColor: colors.body,
      elevation: 0,
      iconTheme: IconThemeData(color: colors.foreground, size: Sizes.unit * 2.5),
    );
  }
}

PageTransitionsTheme _buildPageTransitionsTheme() {
  return const PageTransitionsTheme(
    builders: {
      TargetPlatform.windows: FadeTransitionsBuilder(),
      TargetPlatform.macOS: FadeTransitionsBuilder(),
      TargetPlatform.linux: FadeTransitionsBuilder(),
    },
  );
}

/// MenuThemeData has no `copyWith`, so this doesn't follow the same pattern as other
/// theme-building extensions.
MenuThemeData _buildMenuTheme(ElyonColors colors) {
  return MenuThemeData(
    style: MenuStyle(
      backgroundColor: WidgetStatePropertyAll(colors.modal),
      shape: const WidgetStatePropertyAll(
        RoundedSuperellipseBorder(
          borderRadius: BorderRadius.all(Radius.circular(Sizes.borderRadius / 2)),
        ),
      ),
    ),
  );
}

/// IconButtonThemeData has no `copyWith`, so this doesn't follow the same pattern as other
/// theme-building extensions.
IconButtonThemeData _buildIconButtonTheme(ElyonColors colors) {
  return IconButtonThemeData(
    style: ButtonStyle(
      padding: const WidgetStatePropertyAll(EdgeInsets.zero),
      visualDensity: VisualDensity.compact,
      foregroundColor: WidgetStatePropertyAll(colors.foreground),
      shape: const WidgetStatePropertyAll(
        RoundedSuperellipseBorder(
          borderRadius: BorderRadius.all(Radius.circular(Sizes.borderRadius)),
        ),
      ),
    ),
  );
}
