import 'package:flutter/material.dart';

/// The colors Arkie's terminal surfaces need that `ElyonColors` has no role for.
///
/// Read in widgets through `context.arkieColors`, alongside `context.colors`.
/// Everything here serves the drawn-pane language: panes are outlined rather
/// than filled, which needs a border tone that `divider` (a separator *inside*
/// a pane) should not be doing double duty for.
@immutable
class ArkieColors extends ThemeExtension<ArkieColors> {
  const ArkieColors({
    required this.border,
    required this.borderStrong,
    required this.surfacePressed,
    required this.textFaint,
    required this.accentSurface,
    required this.backdrop,
  });

  /// The outline of a resting pane.
  final Color border;

  /// The outline of the pane holding focus, or the one being acted on.
  final Color borderStrong;

  /// The fill under a hovered or pressed row.
  final Color surfacePressed;

  /// A third text tone below `muted`, for text that is present but inert:
  /// placeholders, unprogrammed values, dot leaders.
  final Color textFaint;

  /// A low tint of the accent, for the row that is currently selected.
  final Color accentSurface;

  /// The scrim behind a modal.
  final Color backdrop;

  @override
  ArkieColors copyWith({
    Color? border,
    Color? borderStrong,
    Color? surfacePressed,
    Color? textFaint,
    Color? accentSurface,
    Color? backdrop,
  }) {
    return ArkieColors(
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      surfacePressed: surfacePressed ?? this.surfacePressed,
      textFaint: textFaint ?? this.textFaint,
      accentSurface: accentSurface ?? this.accentSurface,
      backdrop: backdrop ?? this.backdrop,
    );
  }

  @override
  ArkieColors lerp(covariant ThemeExtension<ArkieColors>? other, double t) {
    if (other is! ArkieColors) return this;
    return ArkieColors(
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      surfacePressed: Color.lerp(surfacePressed, other.surfacePressed, t)!,
      textFaint: Color.lerp(textFaint, other.textFaint, t)!,
      accentSurface: Color.lerp(accentSurface, other.accentSurface, t)!,
      backdrop: Color.lerp(backdrop, other.backdrop, t)!,
    );
  }
}
