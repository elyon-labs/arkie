import 'dart:math' as math;
import 'package:flutter/widgets.dart';

/// Dot leaders to place between two widgets in a Row:
/// Text('A'), DotLeaders(), Text('B')
class DotLeaders extends StatelessWidget {
  const DotLeaders({
    super.key,
    this.dot = '.',
    this.style,
    this.minGap = 2.0,
    this.maxGap = 24.0,
    this.textDirection,
    this.preferredGap = 8.0,
  });

  /// Character to repeat. Default '.'.
  final String dot;

  /// TextStyle used to measure and paint the dots.
  /// If null, falls back to DefaultTextStyle.of(context).style.
  final TextStyle? style;

  /// Clamp the spacing so it doesn't get absurdly tight/loose.
  final double minGap;
  final double maxGap;

  /// Optional override; otherwise uses Directionality.of(context).
  final TextDirection? textDirection;

  /// Preferred gap between dots; used to compute initial dot count.
  /// Default is 8.0.
  final double preferredGap;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ?? DefaultTextStyle.of(context).style;
    final dir = textDirection ?? Directionality.of(context);

    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          if (!width.isFinite || width <= 0) return const SizedBox();

          // Measure a single dot.
          final painter = TextPainter(
            text: TextSpan(text: dot, style: effectiveStyle),
            textDirection: dir,
            maxLines: 1,
          )..layout();

          final dotWidth = painter.width;
          if (dotWidth <= 0) return const SizedBox();

          // Pick a dot count based on an initial "nice" gap,
          // then compute the exact gap so dots are evenly spaced
          // and side padding is balanced.
          final approxCount = math.max(
            1,
            ((width + preferredGap) / (dotWidth + preferredGap)).floor(),
          );

          // We place count dots, with "gap" space between each dot and also at both ends:
          // total = count*dotWidth + (count+1)*gap
          // gap = (width - count*dotWidth) / (count+1)
          var count = approxCount;

          double gapFor(int c) => (width - c * dotWidth) / (c + 1);

          // Adjust count until gap is in [minGap, maxGap] if possible.
          var gap = gapFor(count);
          while (count > 1 && gap < minGap) {
            count -= 1;
            gap = gapFor(count);
          }
          while (true) {
            final nextGap = gapFor(count + 1);
            if (nextGap >= minGap && nextGap <= maxGap) {
              count += 1;
              gap = nextGap;
              continue;
            }
            break;
          }

          gap = gap.clamp(minGap, maxGap);

          return CustomPaint(
            size: Size(width, painter.height),
            painter: _DotLeadersPainter(
              dot: dot,
              style: effectiveStyle,
              count: count,
              gap: gap,
              textDirection: dir,
            ),
          );
        },
      ),
    );
  }
}

class _DotLeadersPainter extends CustomPainter {
  _DotLeadersPainter({
    required this.dot,
    required this.style,
    required this.count,
    required this.gap,
    required this.textDirection,
  });

  final String dot;
  final TextStyle style;
  final int count;
  final double gap;
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final tp = TextPainter(
      text: TextSpan(text: dot, style: style),
      textDirection: textDirection,
      maxLines: 1,
    )..layout();

    final dotWidth = tp.width;
    final baselineY = (size.height - tp.height) / 2;

    // Balanced padding is achieved by using the same gap at both ends.
    var x = gap;
    for (var i = 0; i < count; i++) {
      tp.paint(canvas, Offset(x, baselineY));
      x += dotWidth + gap;
      if (x > size.width) break;
    }
  }

  @override
  bool shouldRepaint(covariant _DotLeadersPainter oldDelegate) {
    return oldDelegate.dot != dot ||
        oldDelegate.style != style ||
        oldDelegate.count != count ||
        oldDelegate.gap != gap ||
        oldDelegate.textDirection != textDirection;
  }
}
