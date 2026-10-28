import 'package:arkie_ui/src/arkie_theme.dart';
import 'package:flutter/material.dart';

/// Builds the mobile app's [ThemeData] from [theme] (normally [ArkieTheme.mobile]).
ThemeData buildMobileTheme([ArkieTheme theme = ArkieTheme.mobile]) {
  final colors = theme.colors;
  final base = theme.baseThemeData;
  const radius = BorderRadius.all(Radius.circular(16));

  return base.copyWith(
    appBarTheme: AppBarThemeData(
      backgroundColor: colors.body,
      foregroundColor: colors.foreground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colors.card,
      modalBackgroundColor: colors.card,
      dragHandleColor: colors.muted,
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: colors.modal,
      hintStyle: TextStyle(color: colors.muted),
      border: const OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none),
      enabledBorder: const OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: colors.accent),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    extensions: <ThemeExtension<dynamic>>[colors, theme.buildText(base.textTheme), theme.icons],
  );
}
