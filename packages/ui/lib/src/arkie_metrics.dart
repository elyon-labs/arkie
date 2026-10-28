import 'package:flutter/widgets.dart';

/// The measurements Arkie's terminal surfaces are drawn on.
///
/// `Sizes` from the Elyon design system still supplies the 8pt grid both apps
/// lay out on; these are the values specific to drawing panes.
abstract final class ArkieMetrics {
  /// Every border Arkie draws is this wide. A pane is an outline, so the
  /// outline never varies in weight — only in color.
  static const double hairline = 1;

  /// Panes, fields and buttons are square. A terminal does not round its
  /// corners, and one corner everywhere keeps edges reading as a single grid.
  static const BorderRadius corner = BorderRadius.zero;

  /// [corner] as a shape, for the Material themes that want one.
  static const RoundedRectangleBorder shape = RoundedRectangleBorder(borderRadius: corner);

  /// How far a pane's notched label sits in from its left or right edge.
  static const double notchInset = 12;

  static const double gutter = 4;
  static const double tight = 8;
  static const double snug = 12;
  static const double edge = 16;
  static const double loose = 24;
  static const double section = 32;
}

/// A 1.2 modular scale from a 14pt body, rounded to whole points.
abstract final class ArkieFontSize {
  static const double caption = 11;
  static const double small = 12;
  static const double body = 14;
  static const double title = 16;
  static const double heading = 19;
  static const double display = 24;
}
