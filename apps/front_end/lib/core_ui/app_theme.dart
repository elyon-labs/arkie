import 'package:cs2_rcon_front_end/core_ui/colors.dart';
import 'package:cs2_rcon_front_end/core_ui/fade_transitions_builder.dart';
import 'package:cs2_rcon_front_end/core_ui/icons.dart';
import 'package:cs2_rcon_front_end/core_ui/sizes.dart';
import 'package:cs2_rcon_front_end/core_ui/text.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

ThemeData buildDarkTheme() {
  final base = ThemeData.dark();
  const colors = CS2RCONColors(
    accent: Color(0xFFBB86FC),
    background: Color(0xFF121212),
    backgroundSecondary: Color.fromARGB(255, 11, 11, 11),
    foreground: Color(0xFFFFFFFF),
    modal: Color(0xFF1E1E1E),
    good: Color(0xFF00FF00),
    error: Color(0xFFFF0000),
    selected: Color(0xFF1F1F1F),
    foregroundMuted: Color(0xFF999999),
    border: Color(0xFF333333),
  );
  final sizes = _buildSizes();
  final text = _buildText(base, colors);

  return base.copyWith(
    primaryColor: colors.background,
    secondaryHeaderColor: colors.accent,
    textTheme: base.textTheme.apply(fontFamily: 'SpaceMono'),
    appBarTheme: base.appBarTheme.toCustomTheme(colors, sizes),
    floatingActionButtonTheme: base.floatingActionButtonTheme.toCustomTheme(colors, sizes),
    inputDecorationTheme: base.inputDecorationTheme.toCustomTheme(text, colors),
    elevatedButtonTheme: base.elevatedButtonTheme.toCustomTheme(colors, sizes),
    scaffoldBackgroundColor: colors.background,
    tooltipTheme: base.tooltipTheme.toCustomTheme(colors, sizes),
    iconTheme: base.iconTheme.toCustomTheme(sizes),
    iconButtonTheme: _buildIconButtonTheme(colors, sizes),
    dialogTheme: base.dialogTheme.toCustomTheme(colors, sizes, text),
    listTileTheme: base.listTileTheme.toCustomTheme(colors, sizes, text),
    dropdownMenuTheme: base.dropdownMenuTheme.toCustomTheme(colors, sizes),
    menuTheme: _buildMenuTheme(colors, sizes),
    pageTransitionsTheme: _buildPageTransitionsTheme(),
    extensions: <ThemeExtension<dynamic>>[colors, text, sizes, _buildIcons()],
  );
}

ThemeData buildLightTheme() {
  final base = ThemeData.light();
  const colors = CS2RCONColors(
    accent: Color(0xFF6200EE),
    background: Color(0xFFFFFFFF),
    backgroundSecondary: Color(0xFFF5F5F5),
    foreground: Color(0xFF000000),
    modal: Color(0xFFFFFFFF),
    good: Color(0xFF008000),
    error: Color(0xFFFF0000),
    selected: Color(0xFFE0E0E0),
    foregroundMuted: Color(0xFF606060),
    border: Color(0xFFCCCCCC),
  );
  final sizes = _buildSizes();
  final text = _buildText(base, colors);
  return base.copyWith(
    primaryColor: colors.background,
    secondaryHeaderColor: colors.accent,
    textTheme: base.textTheme.apply(fontFamily: 'SpaceMono'),
    appBarTheme: base.appBarTheme.toCustomTheme(colors, sizes),
    floatingActionButtonTheme: base.floatingActionButtonTheme.toCustomTheme(colors, sizes),
    inputDecorationTheme: base.inputDecorationTheme.toCustomTheme(text, colors),
    elevatedButtonTheme: base.elevatedButtonTheme.toCustomTheme(colors, sizes),
    scaffoldBackgroundColor: colors.background,
    tooltipTheme: base.tooltipTheme.toCustomTheme(colors, sizes),
    iconTheme: base.iconTheme.toCustomTheme(sizes),
    iconButtonTheme: _buildIconButtonTheme(colors, sizes),
    dialogTheme: base.dialogTheme.toCustomTheme(colors, sizes, text),
    listTileTheme: base.listTileTheme.toCustomTheme(colors, sizes, text),
    dropdownMenuTheme: base.dropdownMenuTheme.toCustomTheme(colors, sizes),
    menuTheme: _buildMenuTheme(colors, sizes),
    pageTransitionsTheme: _buildPageTransitionsTheme(),
    extensions: <ThemeExtension<dynamic>>[colors, text, sizes, _buildIcons()],
  );
}

CS2RCONSizes _buildSizes() {
  return const CS2RCONSizes(unit: 8, edgeSpacing: 16, borderRadius: 8);
}

CS2RCONText _buildText(ThemeData base, CS2RCONColors colors) {
  return CS2RCONText(
    body: base.textTheme.bodyMedium!.copyWith(
      fontFamily: 'SpaceMono',
      fontSize: 14,
      color: colors.foreground,
    ),
    title: base.textTheme.titleMedium!.copyWith(
      fontFamily: 'SpaceMono',
      fontSize: 16,
      color: colors.foreground,
    ),
    header: base.textTheme.headlineMedium!.copyWith(
      fontFamily: 'SpaceMono',
      fontSize: 18,
      color: colors.foreground,
    ),
    caption: base.textTheme.bodySmall!.copyWith(
      fontFamily: 'SpaceMono',
      fontSize: 12,
      color: colors.foregroundMuted,
    ),
  );
}

CS2RCONIcons _buildIcons() {
  return const CS2RCONIcons(
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
}

extension on InputDecorationThemeData {
  InputDecorationThemeData toCustomTheme(CS2RCONText text, CS2RCONColors colors) {
    return copyWith(
      border: const UnderlineInputBorder(),
      hintStyle: text.body.copyWith(color: colors.foregroundMuted),
      floatingLabelBehavior: FloatingLabelBehavior.never,
    );
  }
}

extension on ElevatedButtonThemeData {
  ElevatedButtonThemeData toCustomTheme(CS2RCONColors colors, CS2RCONSizes sizes) {
    return ElevatedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(colors.foreground),
        backgroundColor: WidgetStatePropertyAll(colors.background),
        surfaceTintColor: WidgetStatePropertyAll(colors.background),
        shadowColor: const WidgetStatePropertyAll(Colors.transparent),
        overlayColor: WidgetStatePropertyAll(colors.backgroundSecondary),
        shape: WidgetStatePropertyAll(
          RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(sizes.borderRadius)),
        ),
      ),
    );
  }
}

extension on FloatingActionButtonThemeData {
  FloatingActionButtonThemeData toCustomTheme(CS2RCONColors colors, CS2RCONSizes sizes) {
    return copyWith(
      backgroundColor: colors.background,
      elevation: 0,
      shape: RoundedSuperellipseBorder(
        borderRadius: BorderRadius.all(Radius.circular(sizes.borderRadius)),
      ),
    );
  }
}

extension on TooltipThemeData {
  TooltipThemeData toCustomTheme(CS2RCONColors colors, CS2RCONSizes sizes) {
    return copyWith(
      textStyle: TextStyle(color: colors.foreground, fontFamily: 'SpaceMono', fontSize: 12),
      decoration: ShapeDecoration(
        color: colors.background,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.all(Radius.circular(sizes.borderRadius)),
          side: BorderSide(color: colors.border),
        ),
      ),
    );
  }
}

extension on DialogThemeData {
  DialogThemeData toCustomTheme(CS2RCONColors colors, CS2RCONSizes sizes, CS2RCONText text) {
    return copyWith(
      contentTextStyle: text.body,
      insetPadding: EdgeInsets.zero,
      actionsPadding: EdgeInsets.all(sizes.edgeSpacing),
      titleTextStyle: text.header,
      backgroundColor: colors.modal,
      shape: RoundedSuperellipseBorder(
        borderRadius: BorderRadius.all(Radius.circular(sizes.borderRadius)),
      ),
    );
  }
}

extension on IconThemeData {
  IconThemeData toCustomTheme(CS2RCONSizes sizes) {
    return copyWith(size: sizes.unit * 2.5);
  }
}

extension on ListTileThemeData {
  ListTileThemeData toCustomTheme(CS2RCONColors colors, CS2RCONSizes sizes, CS2RCONText text) {
    return copyWith(
      contentPadding: EdgeInsets.symmetric(horizontal: sizes.edgeSpacing),
      visualDensity: VisualDensity.compact,
      titleTextStyle: text.title,
      subtitleTextStyle: text.caption,
      selectedColor: colors.accent,
    );
  }
}

extension on DropdownMenuThemeData {
  DropdownMenuThemeData toCustomTheme(CS2RCONColors colors, CS2RCONSizes sizes) {
    return copyWith(
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(colors.modal),
        shape: WidgetStatePropertyAll(
          RoundedSuperellipseBorder(
            borderRadius: BorderRadius.all(Radius.circular(sizes.borderRadius / 2)),
          ),
        ),
      ),
    );
  }
}

extension on AppBarThemeData {
  AppBarThemeData toCustomTheme(CS2RCONColors colors, CS2RCONSizes sizes) {
    return copyWith(
      backgroundColor: colors.background,
      elevation: 0,
      iconTheme: IconThemeData(color: colors.foreground, size: sizes.unit * 2.5),
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
MenuThemeData _buildMenuTheme(CS2RCONColors colors, CS2RCONSizes sizes) {
  return MenuThemeData(
    style: MenuStyle(
      backgroundColor: WidgetStatePropertyAll(colors.modal),
      shape: WidgetStatePropertyAll(
        RoundedSuperellipseBorder(
          borderRadius: BorderRadius.all(Radius.circular(sizes.borderRadius / 2)),
        ),
      ),
    ),
  );
}

/// IconButtonThemeData has no `copyWith`, so this doesn't follow the same pattern as other
/// theme-building extensions.
IconButtonThemeData _buildIconButtonTheme(CS2RCONColors colors, CS2RCONSizes sizes) {
  return IconButtonThemeData(
    style: ButtonStyle(
      padding: const WidgetStatePropertyAll(EdgeInsets.zero),
      visualDensity: VisualDensity.compact,
      foregroundColor: WidgetStatePropertyAll(colors.foreground),
      shape: WidgetStatePropertyAll(
        RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(sizes.borderRadius)),
      ),
    ),
  );
}
