import 'package:flutter/material.dart';

const arkieBackground = Color(0xFF0E1014);
const arkieSurface = Color(0xFF171A21);
const arkieSurfaceElevated = Color(0xFF202530);
const arkieAccent = Color(0xFFBB86FC);

ThemeData buildArkieTheme() {
  final colorScheme = ColorScheme.fromSeed(seedColor: arkieAccent, brightness: Brightness.dark)
      .copyWith(
        surface: arkieBackground,
        surfaceContainer: arkieSurface,
        surfaceContainerHigh: arkieSurfaceElevated,
        primary: arkieAccent,
        onPrimary: Colors.black,
      );

  return ThemeData(
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: arkieBackground,
    useMaterial3: true,
    fontFamily: 'monospace',
    appBarTheme: const AppBarTheme(
      backgroundColor: arkieBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: arkieSurfaceElevated,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: arkieAccent),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
