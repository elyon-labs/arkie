import 'package:arkie_ui/src/arkie_colors.dart';
import 'package:arkie_ui/src/arkie_metrics.dart';
import 'package:arkie_ui/src/arkie_theme.dart';
import 'package:arkie_ui/src/fade_transitions_builder.dart';
import 'package:design/design.dart';
import 'package:flutter/material.dart';

/// Builds the desktop app's [ThemeData] from [theme] (normally
/// [ArkieTheme.desktop]).
ThemeData buildDesktopTheme([ArkieTheme theme = ArkieTheme.desktop]) {
  final colors = theme.colors;
  final arkie = theme.arkieColors;
  final base = theme.baseThemeData;
  final text = theme.buildText(base.textTheme);

  return base.copyWith(
    primaryColor: colors.body,
    secondaryHeaderColor: colors.accent,
    appBarTheme: base.appBarTheme.toCustomTheme(colors, arkie, text),
    inputDecorationTheme: base.inputDecorationTheme.toCustomTheme(text, colors, arkie),
    elevatedButtonTheme: base.elevatedButtonTheme.toCustomTheme(colors, arkie),
    textButtonTheme: _buildTextButtonTheme(colors, arkie),
    filledButtonTheme: _buildFilledButtonTheme(colors),
    tooltipTheme: base.tooltipTheme.toCustomTheme(colors, arkie, text),
    iconTheme: base.iconTheme.toCustomTheme(colors),
    iconButtonTheme: _buildIconButtonTheme(colors, arkie),
    dialogTheme: base.dialogTheme.toCustomTheme(colors, arkie, text),
    listTileTheme: base.listTileTheme.toCustomTheme(colors, arkie, text),
    dropdownMenuTheme: base.dropdownMenuTheme.toCustomTheme(colors, arkie),
    menuTheme: _buildMenuTheme(colors, arkie),
    snackBarTheme: base.snackBarTheme.toCustomTheme(colors, arkie, text),
    scrollbarTheme: _buildScrollbarTheme(arkie),
    pageTransitionsTheme: _buildPageTransitionsTheme(),
    extensions: theme.extensions(text),
  );
}

RoundedRectangleBorder _outlined(Color color) {
  return RoundedRectangleBorder(
    borderRadius: ArkieMetrics.corner,
    side: BorderSide(color: color, width: ArkieMetrics.hairline),
  );
}

extension on InputDecorationThemeData {
  InputDecorationThemeData toCustomTheme(ElyonText text, ElyonColors colors, ArkieColors arkie) {
    OutlineInputBorder border(Color color) {
      return OutlineInputBorder(
        borderRadius: ArkieMetrics.corner,
        borderSide: BorderSide(color: color, width: ArkieMetrics.hairline),
      );
    }

    return copyWith(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: ArkieMetrics.snug,
        vertical: ArkieMetrics.snug,
      ),
      hintStyle: text.body.copyWith(color: arkie.textFaint),
      labelStyle: text.caption.copyWith(color: colors.muted),
      errorStyle: text.caption.copyWith(color: colors.error),
      border: border(arkie.border),
      enabledBorder: border(arkie.border),
      focusedBorder: border(colors.accent),
      errorBorder: border(colors.error),
      focusedErrorBorder: border(colors.error),
      floatingLabelBehavior: FloatingLabelBehavior.never,
    );
  }
}

extension on ElevatedButtonThemeData {
  ElevatedButtonThemeData toCustomTheme(ElyonColors colors, ArkieColors arkie) {
    return ElevatedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(colors.foreground),
        backgroundColor: WidgetStatePropertyAll(colors.body),
        surfaceTintColor: WidgetStatePropertyAll(colors.body),
        shadowColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(0),
        overlayColor: WidgetStatePropertyAll(arkie.surfacePressed),
        shape: WidgetStatePropertyAll(_outlined(arkie.border)),
      ),
    );
  }
}

extension on TooltipThemeData {
  TooltipThemeData toCustomTheme(ElyonColors colors, ArkieColors arkie, ElyonText text) {
    return copyWith(
      textStyle: text.caption.copyWith(color: colors.foreground),
      decoration: ShapeDecoration(color: colors.body, shape: _outlined(arkie.border)),
    );
  }
}

extension on DialogThemeData {
  DialogThemeData toCustomTheme(ElyonColors colors, ArkieColors arkie, ElyonText text) {
    return copyWith(
      contentTextStyle: text.body,
      insetPadding: EdgeInsets.zero,
      actionsPadding: const EdgeInsets.all(ArkieMetrics.edge),
      titleTextStyle: text.title,
      backgroundColor: colors.card,
      barrierColor: arkie.backdrop,
      elevation: 0,
      shape: _outlined(arkie.border),
    );
  }
}

extension on IconThemeData {
  IconThemeData toCustomTheme(ElyonColors colors) {
    return copyWith(size: ArkieMetrics.edge, color: colors.muted);
  }
}

extension on ListTileThemeData {
  ListTileThemeData toCustomTheme(ElyonColors colors, ArkieColors arkie, ElyonText text) {
    return copyWith(
      contentPadding: const EdgeInsets.symmetric(horizontal: ArkieMetrics.snug),
      visualDensity: VisualDensity.compact,
      titleTextStyle: text.body,
      subtitleTextStyle: text.caption.copyWith(color: arkie.textFaint),
      iconColor: colors.muted,
      selectedColor: colors.accent,
      selectedTileColor: arkie.accentSurface,
      shape: ArkieMetrics.shape,
    );
  }
}

extension on DropdownMenuThemeData {
  DropdownMenuThemeData toCustomTheme(ElyonColors colors, ArkieColors arkie) {
    return copyWith(menuStyle: _menuStyle(colors, arkie));
  }
}

extension on AppBarThemeData {
  AppBarThemeData toCustomTheme(ElyonColors colors, ArkieColors arkie, ElyonText text) {
    return copyWith(
      backgroundColor: colors.body,
      foregroundColor: colors.foreground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: text.title,
      iconTheme: IconThemeData(color: colors.muted, size: ArkieMetrics.edge),
      shape: Border(
        bottom: BorderSide(color: arkie.border, width: ArkieMetrics.hairline),
      ),
    );
  }
}

extension on SnackBarThemeData {
  SnackBarThemeData toCustomTheme(ElyonColors colors, ArkieColors arkie, ElyonText text) {
    return copyWith(
      behavior: SnackBarBehavior.floating,
      backgroundColor: colors.card,
      contentTextStyle: text.body,
      actionTextColor: colors.accent,
      elevation: 0,
      shape: _outlined(arkie.border),
    );
  }
}

MenuStyle _menuStyle(ElyonColors colors, ArkieColors arkie) {
  return MenuStyle(
    backgroundColor: WidgetStatePropertyAll(colors.card),
    surfaceTintColor: WidgetStatePropertyAll(colors.card),
    elevation: const WidgetStatePropertyAll(0),
    padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: ArkieMetrics.gutter)),
    shape: WidgetStatePropertyAll(_outlined(arkie.border)),
  );
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
MenuThemeData _buildMenuTheme(ElyonColors colors, ArkieColors arkie) {
  return MenuThemeData(style: _menuStyle(colors, arkie));
}

/// IconButtonThemeData has no `copyWith`, so this doesn't follow the same pattern as other
/// theme-building extensions.
IconButtonThemeData _buildIconButtonTheme(ElyonColors colors, ArkieColors arkie) {
  return IconButtonThemeData(
    style: ButtonStyle(
      padding: const WidgetStatePropertyAll(EdgeInsets.all(ArkieMetrics.gutter)),
      visualDensity: VisualDensity.compact,
      iconSize: const WidgetStatePropertyAll(ArkieMetrics.edge),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.hovered) ? colors.accent : colors.muted,
      ),
      overlayColor: WidgetStatePropertyAll(arkie.surfacePressed),
      shape: const WidgetStatePropertyAll(ArkieMetrics.shape),
    ),
  );
}

TextButtonThemeData _buildTextButtonTheme(ElyonColors colors, ArkieColors arkie) {
  return TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStatePropertyAll(colors.accent),
      overlayColor: WidgetStatePropertyAll(arkie.surfacePressed),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: ArkieMetrics.snug, vertical: ArkieMetrics.tight),
      ),
      shape: const WidgetStatePropertyAll(ArkieMetrics.shape),
    ),
  );
}

FilledButtonThemeData _buildFilledButtonTheme(ElyonColors colors) {
  return FilledButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return colors.secondaryInteractive;
        if (states.contains(WidgetState.pressed)) return ArkieTheme.accentPressed;
        return colors.accent;
      }),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled) ? colors.muted : colors.onAccent,
      ),
      elevation: const WidgetStatePropertyAll(0),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: ArkieMetrics.edge, vertical: ArkieMetrics.snug),
      ),
      shape: const WidgetStatePropertyAll(ArkieMetrics.shape),
    ),
  );
}

ScrollbarThemeData _buildScrollbarTheme(ArkieColors arkie) {
  return ScrollbarThemeData(
    thickness: const WidgetStatePropertyAll(ArkieMetrics.gutter),
    radius: Radius.zero,
    thumbColor: WidgetStatePropertyAll(arkie.border),
  );
}
