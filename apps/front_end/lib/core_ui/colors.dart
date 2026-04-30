import 'package:flutter/material.dart';

class CS2RCONColors extends ThemeExtension<CS2RCONColors> {
  const CS2RCONColors({
    required this.accent,
    required this.background,
    required this.backgroundSecondary,
    required this.foreground,
    required this.modal,
    required this.good,
    required this.error,
    required this.selected,
    required this.foregroundMuted,
    required this.border,
  });

  final Color accent;
  final Color background;
  final Color backgroundSecondary;
  final Color foreground;
  final Color modal;
  final Color good;
  final Color error;
  final Color selected;
  final Color foregroundMuted;
  final Color border;

  @override
  CS2RCONColors copyWith({
    Color? accent,
    Color? background,
    Color? backgroundSecondary,
    Color? foreground,
    Color? modal,
    Color? good,
    Color? error,
    Color? selected,
    Color? foregroundMuted,
    Color? border,
  }) {
    return CS2RCONColors(
      accent: accent ?? this.accent,
      background: background ?? this.background,
      backgroundSecondary: backgroundSecondary ?? this.backgroundSecondary,
      foreground: foreground ?? this.foreground,
      modal: modal ?? this.modal,
      good: good ?? this.good,
      error: error ?? this.error,
      selected: selected ?? this.selected,
      foregroundMuted: foregroundMuted ?? this.foregroundMuted,
      border: border ?? this.border,
    );
  }

  @override
  CS2RCONColors lerp(ThemeExtension<CS2RCONColors>? other, double t) {
    if (other is! CS2RCONColors) {
      return this;
    }
    return CS2RCONColors(
      accent: Color.lerp(accent, other.accent, t)!,
      background: Color.lerp(background, other.background, t)!,
      backgroundSecondary: Color.lerp(backgroundSecondary, other.backgroundSecondary, t)!,
      foreground: Color.lerp(foreground, other.foreground, t)!,
      modal: Color.lerp(modal, other.modal, t)!,
      good: Color.lerp(good, other.good, t)!,
      error: Color.lerp(error, other.error, t)!,
      selected: Color.lerp(selected, other.selected, t)!,
      foregroundMuted: Color.lerp(foregroundMuted, other.foregroundMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
    );
  }
}
