import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/chart_data.dart';
import '../models/chart_style.dart';
import '../utils/math_utils.dart';

/// Resolved colour set for a single segment (all nulls filled in).
class ResolvedSegmentColors {
  final Color ring;
  final Color glow;
  final Color legend;
  final Color indicatorLine;

  const ResolvedSegmentColors({
    required this.ring,
    required this.glow,
    required this.legend,
    required this.indicatorLine,
  });
}

/// Custom painter that draws the 3D elliptical ring chart.
///
/// This painter handles:
/// 1. Per-segment shadow arcs (3D depth effect)
/// 2. Ring arcs with glow on the selected segment
/// 3. Vertical indicator line + floating label for the selected segment
///
/// Animations are handled by interpolating [selectedProgress] between
/// the previous and current selection.
class ThreeDRingPainter extends CustomPainter {
  /// Segments to paint (already filtered if [showZeroValueSegments] is false).
  final List<PieChartSegment> segments;

  /// Pre-computed arc geometry matching [segments] by index.
  final List<ArcGeometry> arcs;

  /// Resolved colours for each segment.
  final List<ResolvedSegmentColors> colors;

  /// Index of the currently selected segment.
  final int selectedIndex;

  /// Index of the previously selected segment (for cross-fade animation).
  final int previousSelectedIndex;

  /// Animation progress `0.0` → `1.0` from [previousSelectedIndex] to
  /// [selectedIndex].
  final double selectedProgress;

  /// All visual style parameters.
  final ThreeDPieChartStyle style;

  /// Whether the host app is in dark mode.
  final bool isDarkMode;

  ThreeDRingPainter({
    required this.segments,
    required this.arcs,
    required this.colors,
    required this.selectedIndex,
    required this.previousSelectedIndex,
    required this.selectedProgress,
    required this.style,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (segments.isEmpty || arcs.isEmpty) return;

    final cx = size.width / 2;
    final cy = size.height / 2 + style.centerOffsetY;
    final rx = size.width * style.radiusFraction;
    final ry = rx * style.tiltFactor;

    final ellipseRect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: rx * 2,
      height: ry * 2,
    );

    // ── LAYER 1: Shadows ──────────────────────────────────────────────────
    if (style.shadowStyle.enabled) {
      _paintShadows(canvas, cx, cy, rx, ry);
    }

    // ── LAYER 2: Ring arcs + glow ─────────────────────────────────────────
    _paintArcs(canvas, ellipseRect);

    // ── LAYER 3: Indicator line + label ───────────────────────────────────
    if (style.showIndicator && selectedIndex >= 0) {
      _paintIndicator(canvas, cx, cy, rx, ry);
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Layer 1 – Shadows
  // ───────────────────────────────────────────────────────────────────────────

  void _paintShadows(
      Canvas canvas, double cx, double cy, double rx, double ry) {
    final shadow = style.shadowStyle;
    final shadowRect = Rect.fromCenter(
      center: Offset(cx + shadow.offsetX, cy + shadow.offsetY),
      width: rx * 2,
      height: ry * 2,
    );

    for (int i = 0; i < segments.length; i++) {
      final isOldSel = i == previousSelectedIndex;
      final isNewSel = i == selectedIndex;

      // Interpolate shadow colour between states
      Color shadowColor;
      if (isNewSel && isOldSel) {
        // Same segment stayed selected
        shadowColor = _segmentShadowColor(i, true);
      } else if (isNewSel) {
        shadowColor = Color.lerp(
          _segmentShadowColor(i, false),
          _segmentShadowColor(i, true),
          selectedProgress,
        )!;
      } else if (isOldSel) {
        shadowColor = Color.lerp(
          _segmentShadowColor(i, true),
          _segmentShadowColor(i, false),
          selectedProgress,
        )!;
      } else {
        shadowColor = _segmentShadowColor(i, false);
      }

      canvas.drawArc(
        shadowRect,
        arcs[i].startAngle,
        arcs[i].sweepAngle,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = style.strokeWidth + shadow.extraWidth
          ..strokeCap = StrokeCap.round
          ..color = shadowColor
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadow.blurRadius),
      );
    }
  }

  Color _segmentShadowColor(int i, bool selected) {
    final shadow = style.shadowStyle;
    if (selected) {
        final g = colors[i].glow;
      return Color.fromRGBO(
          (g.r * 255).round(),
        (g.g * 255).round(),
        (g.b * 255).round(),
        shadow.opacity,
      );
    }
    return Color.fromRGBO(160, 160, 160, shadow.opacity * 0.8);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Layer 2 – Ring arcs + glow
  // ───────────────────────────────────────────────────────────────────────────

  void _paintArcs(Canvas canvas, Rect ellipseRect) {
    final glow = style.glowStyle;
    final unselected =
        style.unselectedColor ?? (isDarkMode ? const Color(0xFF42444B) : const Color(0xFFD1D5DB));

    for (int i = 0; i < segments.length; i++) {
      final st = arcs[i].startAngle;
      final sw = arcs[i].sweepAngle;

      final isOldSel = i == previousSelectedIndex;
      final isNewSel = i == selectedIndex;

      // Compute animated selection amount for this segment
      double selAmount = 0.0;
      if (isNewSel && isOldSel) {
        selAmount = 1.0;
      } else if (isNewSel) {
        selAmount = selectedProgress;
      } else if (isOldSel) {
        selAmount = 1.0 - selectedProgress;
      }

      // Glow layers (only if segment has some selection amount)
      if (glow.enabled && selAmount > 0.01) {
        final glowOpacity = glow.opacity * selAmount;
          final gc = colors[i].glow;
        final glowColor = Color.fromRGBO(
          (gc.r * 255).round(),
          (gc.g * 255).round(),
          (gc.b * 255).round(),
          glowOpacity,
        );

        canvas.drawArc(
          ellipseRect,
          st,
          sw,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = style.strokeWidth + glow.outerSpread * selAmount
            ..strokeCap = StrokeCap.round
            ..color = glowColor
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, glow.outerBlur),
        );

        canvas.drawArc(
          ellipseRect,
          st,
          sw,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = style.strokeWidth + glow.innerSpread * selAmount
            ..strokeCap = StrokeCap.round
            ..color = glowColor
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, glow.innerBlur),
        );
      }

      // Main arc
      final arcColor = Color.lerp(unselected, colors[i].ring, selAmount)!;
      canvas.drawArc(
        ellipseRect,
        st,
        sw,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = style.strokeWidth
          ..strokeCap = StrokeCap.round
          ..color = arcColor,
      );
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Layer 3 – Indicator line + label
  // ───────────────────────────────────────────────────────────────────────────

  void _paintIndicator(
      Canvas canvas, double cx, double cy, double rx, double ry) {
    // Interpolate indicator position between old and new segment
    final oldMid = previousSelectedIndex >= 0 && previousSelectedIndex < arcs.length
        ? arcs[previousSelectedIndex].startAngle +
            arcs[previousSelectedIndex].sweepAngle / 2
        : arcs[selectedIndex].startAngle + arcs[selectedIndex].sweepAngle / 2;

    final newMid =
        arcs[selectedIndex].startAngle + arcs[selectedIndex].sweepAngle / 2;

    // Shortest-path interpolation for angles
    final midAngle = _lerpAngle(oldMid, newMid, selectedProgress);

    final ringX = cx + rx * cos(midAngle);
    final ringY = cy + ry * sin(midAngle);
    final ringPt = Offset(ringX, ringY);

    final lineH = style.indicatorLineHeight;
    final lineTop = Offset(ringX, ringY - lineH);

    // Gradient or solid line
    final lineColor = colors[selectedIndex].indicatorLine;
    final Paint linePaint = Paint()..strokeWidth = style.indicatorLineWidth;

    if (style.indicatorLineGradient) {
      linePaint.shader = ui.Gradient.linear(
        ringPt,
        lineTop,
        [
          lineColor,
          Color.fromRGBO(
             (lineColor.r * 255).round(),
            (lineColor.g * 255).round(),
            (lineColor.b * 255).round(),
            0.2,
          ),
        ],
      );
    } else {
      linePaint.color = lineColor;
    }

    // Fade the indicator in/out during animation
    canvas.save();
    canvas.drawLine(ringPt, lineTop, linePaint);

    // Label
    final labelStyle = style.indicatorLabelStyle ??
        TextStyle(
          color: isDarkMode ? Colors.white : Colors.black87,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.3,
        );

    final tp = TextPainter(
      text: TextSpan(
        text: segments[selectedIndex].label,
        style: labelStyle,
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(
      canvas,
      Offset(ringX - tp.width / 2, lineTop.dy - tp.height - 4),
    );
    canvas.restore();
  }

  /// Interpolate between two angles using the shortest-path approach.
  double _lerpAngle(double a, double b, double t) {
    double diff = (b - a) % (2 * pi);
    if (diff > pi) diff -= 2 * pi;
    if (diff < -pi) diff += 2 * pi;
    return a + diff * t;
  }

  @override
  bool shouldRepaint(covariant ThreeDRingPainter old) {
    return old.selectedIndex != selectedIndex ||
        old.previousSelectedIndex != previousSelectedIndex ||
        old.selectedProgress != selectedProgress ||
        old.segments != segments ||
        old.isDarkMode != isDarkMode;
  }
}
