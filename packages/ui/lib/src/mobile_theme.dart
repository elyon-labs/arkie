import 'package:arkie_ui/src/arkie_colors.dart';
import 'package:arkie_ui/src/arkie_metrics.dart';
import 'package:arkie_ui/src/arkie_theme.dart';
import 'package:design/design.dart';
import 'package:flutter/material.dart';

/// Builds the mobile app's [ThemeData] from [theme] (normally [ArkieTheme.mobile]).
ThemeData buildMobileTheme([ArkieTheme theme = ArkieTheme.mobile]) {
  final colors = theme.colors;
  final arkie = theme.arkieColors;
  final base = theme.baseThemeData;
  final text = theme.buildText(base.textTheme);

  OutlineInputBorder border(Color color) {
    return OutlineInputBorder(
      borderRadius: ArkieMetrics.corner,
      borderSide: BorderSide(color: color, width: ArkieMetrics.hairline),
    );
  }

  return base.copyWith(
    appBarTheme: AppBarThemeData(
      backgroundColor: colors.body,
      foregroundColor: colors.foreground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: ArkieMetrics.edge,
      titleTextStyle: text.title,
      iconTheme: IconThemeData(color: colors.muted, size: 20),
      shape: Border(
        bottom: BorderSide(color: arkie.border, width: ArkieMetrics.hairline),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colors.card,
      modalBackgroundColor: colors.card,
      modalBarrierColor: arkie.backdrop,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      dragHandleColor: arkie.border,
      dragHandleSize: const Size(32, ArkieMetrics.hairline * 2),
      shape: ArkieMetrics.shape,
    ),
    inputDecorationTheme: InputDecorationThemeData(
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
      disabledBorder: border(colors.divider),
      focusedBorder: border(colors.accent),
      errorBorder: border(colors.error),
      focusedErrorBorder: border(colors.error),
      floatingLabelBehavior: FloatingLabelBehavior.never,
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: ArkieMetrics.edge),
      titleTextStyle: text.body,
      subtitleTextStyle: text.caption.copyWith(color: arkie.textFaint),
      iconColor: colors.muted,
      selectedColor: colors.accent,
      selectedTileColor: arkie.accentSurface,
      shape: ArkieMetrics.shape,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: colors.accent,
      unselectedLabelColor: colors.muted,
      labelStyle: text.caption,
      unselectedLabelStyle: text.caption,
      indicatorColor: colors.accent,
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: arkie.border,
      dividerHeight: ArkieMetrics.hairline,
      overlayColor: WidgetStatePropertyAll(arkie.surfacePressed),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return colors.secondaryInteractive;
          if (states.contains(WidgetState.pressed)) return ArkieTheme.accentPressed;
          return colors.accent;
        }),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled) ? colors.muted : colors.onAccent,
        ),
        textStyle: WidgetStatePropertyAll(text.body.copyWith(fontWeight: FontWeight.w700)),
        elevation: const WidgetStatePropertyAll(0),
        minimumSize: const WidgetStatePropertyAll(Size.fromHeight(48)),
        shape: const WidgetStatePropertyAll(ArkieMetrics.shape),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(colors.accent),
        textStyle: WidgetStatePropertyAll(text.caption.copyWith(color: colors.accent)),
        overlayColor: WidgetStatePropertyAll(arkie.surfacePressed),
        shape: const WidgetStatePropertyAll(ArkieMetrics.shape),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        iconSize: const WidgetStatePropertyAll(20),
        foregroundColor: WidgetStatePropertyAll(colors.muted),
        overlayColor: WidgetStatePropertyAll(arkie.surfacePressed),
        shape: const WidgetStatePropertyAll(ArkieMetrics.shape),
      ),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? colors.accent : arkie.borderStrong,
      ),
    ),
    switchTheme: _buildSwitchTheme(colors, arkie),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: colors.card,
      contentTextStyle: text.caption.copyWith(color: colors.foreground),
      actionTextColor: colors.accent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: ArkieMetrics.corner,
        side: BorderSide(color: arkie.border, width: ArkieMetrics.hairline),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: colors.accent,
      linearMinHeight: ArkieMetrics.hairline * 2,
    ),
    extensions: theme.extensions(text),
  );
}

/// The thumb stays dark in both states; the track is what carries the state,
/// the way a lamp does elsewhere in the app.
SwitchThemeData _buildSwitchTheme(ElyonColors colors, ArkieColors arkie) {
  return SwitchThemeData(
    thumbColor: WidgetStatePropertyAll(colors.body),
    trackColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected) ? colors.accent : arkie.border,
    ),
    trackOutlineColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected) ? colors.accent : arkie.borderStrong,
    ),
    trackOutlineWidth: const WidgetStatePropertyAll(ArkieMetrics.hairline),
  );
}
