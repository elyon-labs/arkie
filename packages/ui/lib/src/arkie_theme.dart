import 'package:arkie_ui/src/arkie_icons.dart';
import 'package:design/design.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

/// The theme shared by every Arkie app.
///
/// Each app picks one of the predefined themes ([desktopDark], [desktopLight],
/// [mobile]) and builds its [ThemeData] from it, so every color an app paints
/// comes from [colors] (read in widgets through `context.colors`).
@immutable
class ArkieTheme {
  const ArkieTheme({
    required this.brightness,
    required this.colors,
    required this.icons,
    required this.fontFamily,
  });

  static const String spaceMono = 'packages/arkie_ui/SpaceMono';

  static const desktopDark = ArkieTheme(
    brightness: Brightness.dark,
    fontFamily: spaceMono,
    icons: _desktopIcons,
    colors: ElyonColors(
      primary: Color(0xFFBB86FC),
      onPrimary: Color(0xFF000000),
      secondary: Color(0xFF1F1F1F),
      onSecondary: Color(0xFFFFFFFF),
      secondaryInteractive: Color(0xFF333333),
      onSecondaryInteractive: Color(0xFFFFFFFF),
      accent: Color(0xFFBB86FC),
      onAccent: Color(0xFF000000),
      muted: Color(0xFF999999),
      onMuted: Color(0xFF000000),
      selected: Color(0xFF1F1F1F),
      onSelected: Color(0xFFFFFFFF),
      body: Color(0xFF121212),
      card: Color(0xFF0B0B0B),
      modal: Color(0xFF1E1E1E),
      foreground: Color(0xFFFFFFFF),
      error: Color(0xFFFF0000),
      onError: Color(0xFFFFFFFF),
      warning: Color(0xFFFFC107),
      onWarning: Color(0xFF000000),
      good: Color(0xFF00FF00),
      onGood: Color(0xFF000000),
      divider: Color(0xFF333333),
    ),
  );

  static const desktopLight = ArkieTheme(
    brightness: Brightness.light,
    fontFamily: spaceMono,
    icons: _desktopIcons,
    colors: ElyonColors(
      primary: Color(0xFF6200EE),
      onPrimary: Color(0xFFFFFFFF),
      secondary: Color(0xFFE0E0E0),
      onSecondary: Color(0xFF000000),
      secondaryInteractive: Color(0xFFCCCCCC),
      onSecondaryInteractive: Color(0xFF000000),
      accent: Color(0xFF6200EE),
      onAccent: Color(0xFFFFFFFF),
      muted: Color(0xFF606060),
      onMuted: Color(0xFFFFFFFF),
      selected: Color(0xFFE0E0E0),
      onSelected: Color(0xFF000000),
      body: Color(0xFFFFFFFF),
      card: Color(0xFFF5F5F5),
      modal: Color(0xFFFFFFFF),
      foreground: Color(0xFF000000),
      error: Color(0xFFFF0000),
      onError: Color(0xFFFFFFFF),
      warning: Color(0xFFB26A00),
      onWarning: Color(0xFFFFFFFF),
      good: Color(0xFF008000),
      onGood: Color(0xFFFFFFFF),
      divider: Color(0xFFCCCCCC),
    ),
  );

  static const mobile = ArkieTheme(
    brightness: Brightness.dark,
    fontFamily: 'monospace',
    icons: _mobileIcons,
    colors: ElyonColors(
      primary: Color(0xFFBB86FC),
      onPrimary: Color(0xFF000000),
      secondary: Color(0xFFCFC1DA),
      onSecondary: Color(0xFF362D40),
      secondaryInteractive: Color(0xFF202530),
      onSecondaryInteractive: Color(0xFFE8E0E8),
      accent: Color(0xFFBB86FC),
      onAccent: Color(0xFF000000),
      muted: Color(0xFFCCC4CF),
      onMuted: Color(0xFF0E1014),
      selected: Color(0xFF543B72),
      onSelected: Color(0xFFEEDBFF),
      body: Color(0xFF0E1014),
      card: Color(0xFF171A21),
      modal: Color(0xFF202530),
      foreground: Color(0xFFE8E0E8),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      warning: Color(0xFFFFD740),
      onWarning: Color(0xFF000000),
      good: Color(0xFF69F0AE),
      onGood: Color(0xFF000000),
      divider: Color(0xFF4A454E),
    ),
  );

  final Brightness brightness;
  final ElyonColors colors;
  final ArkieIcons icons;
  final String fontFamily;

  /// A Material [ColorScheme] whose roles are all taken from [colors], so
  /// Material widgets that are not explicitly styled still use Arkie's colors.
  ColorScheme get colorScheme {
    return ColorScheme.fromSeed(seedColor: colors.accent, brightness: brightness).copyWith(
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      primaryContainer: colors.selected,
      onPrimaryContainer: colors.onSelected,
      secondary: colors.secondary,
      onSecondary: colors.onSecondary,
      tertiary: colors.accent,
      onTertiary: colors.onAccent,
      surface: colors.body,
      onSurface: colors.foreground,
      onSurfaceVariant: colors.muted,
      surfaceContainerLowest: colors.body,
      surfaceContainerLow: colors.card,
      surfaceContainer: colors.card,
      surfaceContainerHigh: colors.modal,
      surfaceContainerHighest: colors.modal,
      error: colors.error,
      onError: colors.onError,
      outline: colors.divider,
      outlineVariant: colors.divider,
    );
  }

  /// The base [ThemeData] both app themes build on.
  ThemeData get baseThemeData {
    return ThemeData(
      colorScheme: colorScheme,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: colors.body,
    );
  }

  ElyonText buildText(TextTheme textTheme) {
    return ElyonText(
      body: textTheme.bodyMedium!.copyWith(fontSize: 14, color: colors.foreground),
      title: textTheme.titleMedium!.copyWith(fontSize: 16, color: colors.foreground),
      headline: textTheme.headlineMedium!.copyWith(fontSize: 18, color: colors.foreground),
      caption: textTheme.bodySmall!.copyWith(fontSize: 12, color: colors.muted),
    );
  }
}

const _desktopIcons = ArkieIcons(
  server: Ionicons.server_outline,
  settings: Ionicons.settings_outline,
  delete: Ionicons.trash_outline,
  save: Ionicons.bookmark_outline,
  unsave: Ionicons.bookmark,
  send: Ionicons.paper_plane_outline,
  edit: Ionicons.pencil_outline,
  grid: Ionicons.grid_outline,
  list: Ionicons.list_outline,
  menu: Ionicons.ellipsis_vertical_outline,
  back: Ionicons.arrow_back_outline,
  close: Ionicons.close_outline,
  bot: Icons.computer_outlined,
  human: Ionicons.person_outline,
  kick: Ionicons.log_out_outline,
  ban: Ionicons.close_circle_outline,
  add: Ionicons.add_outline,
  github: Ionicons.logo_github,
  check: Ionicons.checkmark_outline,
);

const _mobileIcons = ArkieIcons(
  server: Icons.dns_rounded,
  settings: Icons.settings_rounded,
  delete: Icons.delete_outline_rounded,
  save: Icons.bookmark_add_outlined,
  unsave: Icons.bookmark_remove_outlined,
  send: Icons.arrow_upward_rounded,
  edit: Icons.edit_rounded,
  grid: Icons.grid_view_rounded,
  list: Icons.list_rounded,
  menu: Icons.more_vert_rounded,
  back: Icons.arrow_back_rounded,
  close: Icons.close_rounded,
  bot: Icons.smart_toy_outlined,
  human: Icons.person_outline_rounded,
  kick: Icons.logout_rounded,
  ban: Icons.block_rounded,
  add: Icons.add_rounded,
  github: Ionicons.logo_github,
  check: Icons.check_circle_rounded,
);
