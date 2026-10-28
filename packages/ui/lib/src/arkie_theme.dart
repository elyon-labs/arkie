import 'package:arkie_ui/src/arkie_colors.dart';
import 'package:arkie_ui/src/arkie_icons.dart';
import 'package:arkie_ui/src/arkie_metrics.dart';
import 'package:design/design.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

/// The theme shared by every Arkie app.
///
/// Each app picks one of the predefined themes ([desktop], [mobile]) and builds
/// its [ThemeData] from it, so every color an app paints comes from [colors]
/// (read in widgets through `context.colors`) or [arkieColors].
///
/// Both apps are dark. Arkie draws a console, and a console is dark the way a
/// terminal is: the surfaces are near-black so the text on them is the only
/// thing with any weight.
@immutable
class ArkieTheme {
  const ArkieTheme({
    required this.brightness,
    required this.colors,
    required this.arkieColors,
    required this.icons,
    required this.fontFamily,
  });

  static const String spaceMono = 'packages/arkie_ui/SpaceMono';

  /// Purple marks what is yours: the command you typed, the pane you are in,
  /// the map that is loaded. It is never spent on anything else, which is what
  /// keeps it legible against a screen otherwise made of greys.
  static const Color _accent = Color(0xFFBB86FC);

  /// The accent while a control is held down.
  static const Color accentPressed = Color(0xFF9A6AD8);

  /// The neutrals carry a violet cast so they read as belonging to the accent
  /// rather than as a grey theme that happens to have a purple in it.
  static const _palette = ElyonColors(
    primary: _accent,
    onPrimary: Color(0xFF120018),
    secondary: Color(0xFF17141D),
    onSecondary: Color(0xFFE8E2F0),
    secondaryInteractive: Color(0xFF201B29),
    onSecondaryInteractive: Color(0xFFE8E2F0),
    accent: _accent,
    onAccent: Color(0xFF120018),
    muted: Color(0xFF968BA6),
    onMuted: Color(0xFF000000),
    selected: Color(0xFF1C1026),
    onSelected: _accent,
    body: Color(0xFF000000),
    card: Color(0xFF0E0C12),
    modal: Color(0xFF17141D),
    foreground: Color(0xFFE8E2F0),
    error: Color(0xFFFF7B72),
    onError: Color(0xFF1A0908),
    warning: Color(0xFFE8C06A),
    onWarning: Color(0xFF1A1408),
    good: Color(0xFF7EE787),
    onGood: Color(0xFF04140A),
    divider: Color(0xFF1C1823),
  );

  static const _terminal = ArkieColors(
    border: Color(0xFF2A2433),
    borderStrong: Color(0xFF6B5B80),
    surfacePressed: Color(0xFF201B29),
    textFaint: Color(0xFF5F5670),
    accentSurface: Color(0xFF1C1026),
    backdrop: Color(0xCC000000),
  );

  static const desktop = ArkieTheme(
    brightness: Brightness.dark,
    fontFamily: spaceMono,
    icons: _desktopIcons,
    colors: _palette,
    arkieColors: _terminal,
  );

  static const mobile = ArkieTheme(
    brightness: Brightness.dark,
    fontFamily: spaceMono,
    icons: _mobileIcons,
    colors: _palette,
    arkieColors: _terminal,
  );

  final Brightness brightness;
  final ElyonColors colors;
  final ArkieColors arkieColors;
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
      outline: arkieColors.border,
      outlineVariant: colors.divider,
    );
  }

  /// The base [ThemeData] both app themes build on.
  ThemeData get baseThemeData {
    return ThemeData(
      colorScheme: colorScheme,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: colors.body,
      // A spreading circle is the one round shape Material insists on. Presses
      // read as a change of fill instead.
      splashFactory: NoSplash.splashFactory,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.accent,
        selectionColor: arkieColors.accentSurface,
        selectionHandleColor: colors.accent,
      ),
      dividerTheme: DividerThemeData(
        color: colors.divider,
        thickness: ArkieMetrics.hairline,
        space: ArkieMetrics.hairline,
      ),
    );
  }

  ElyonText buildText(TextTheme textTheme) {
    return ElyonText(
      body: textTheme.bodyMedium!.copyWith(
        fontSize: ArkieFontSize.body,
        color: colors.foreground,
        height: 1.45,
      ),
      title: textTheme.titleMedium!.copyWith(
        fontSize: ArkieFontSize.title,
        color: colors.foreground,
        fontWeight: FontWeight.w700,
      ),
      headline: textTheme.headlineMedium!.copyWith(
        fontSize: ArkieFontSize.heading,
        color: colors.foreground,
        fontWeight: FontWeight.w700,
      ),
      caption: textTheme.bodySmall!.copyWith(fontSize: ArkieFontSize.caption, color: colors.muted),
    );
  }

  /// The theme extensions every Arkie [ThemeData] registers.
  List<ThemeExtension<dynamic>> extensions(ElyonText text) {
    return <ThemeExtension<dynamic>>[colors, arkieColors, text, icons];
  }
}

const _desktopIcons = ArkieIcons(
  server: Ionicons.serverOutline,
  settings: Ionicons.settingsOutline,
  delete: Ionicons.trashOutline,
  save: Ionicons.bookmarkOutline,
  unsave: Ionicons.bookmark,
  send: Ionicons.paperPlaneOutline,
  edit: Ionicons.pencilOutline,
  grid: Ionicons.gridOutline,
  list: Ionicons.listOutline,
  menu: Ionicons.ellipsisVerticalOutline,
  back: Ionicons.arrowBackOutline,
  close: Ionicons.closeOutline,
  bot: Icons.computer_outlined,
  human: Ionicons.personOutline,
  kick: Ionicons.logOutOutline,
  ban: Ionicons.closeCircleOutline,
  add: Ionicons.addOutline,
  github: Ionicons.logoGithub,
  check: Ionicons.checkmarkOutline,
);

/// Outline icons throughout: a filled icon next to a pane drawn as an outline
/// is the one thing on screen with a solid body.
const _mobileIcons = ArkieIcons(
  server: Ionicons.serverOutline,
  settings: Ionicons.settingsOutline,
  delete: Ionicons.trashOutline,
  save: Ionicons.bookmarkOutline,
  unsave: Ionicons.bookmark,
  send: Ionicons.returnDownBackOutline,
  edit: Ionicons.pencilOutline,
  grid: Ionicons.gridOutline,
  list: Ionicons.listOutline,
  menu: Ionicons.ellipsisVerticalOutline,
  back: Ionicons.chevronBackOutline,
  close: Ionicons.closeOutline,
  bot: Icons.computer_outlined,
  human: Ionicons.personOutline,
  kick: Ionicons.logOutOutline,
  ban: Ionicons.closeCircleOutline,
  add: Ionicons.addOutline,
  github: Ionicons.logoGithub,
  check: Ionicons.checkmarkOutline,
);
