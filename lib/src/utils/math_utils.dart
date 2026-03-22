import 'dart:math';

import 'package:flutter/material.dart';

/// Pre-computed arc geometry for a single segment.
///
/// Used by both the painter (to draw arcs) and the state (to hit-test taps).
class ArcGeometry {
  /// Start angle in radians (measured from 3 o'clock, counter-clockwise
  /// is negative). The chart starts at 12 o'clock (−π/2).
  final double startAngle;

  /// Sweep angle in radians.
  final double sweepAngle;

  const ArcGeometry({
    required this.startAngle,
    required this.sweepAngle,
  });
}

/// Computes [ArcGeometry] for every segment.
///
/// [values] – the raw numeric value of each segment.
/// [gapDegrees] – gap between adjacent segments in degrees.
///
/// Returns an empty list when [values] is empty or sums to zero.
List<ArcGeometry> computeArcs(List<double> values, double gapDegrees) {
  if (values.isEmpty) return const [];

  final total = values.fold<double>(0.0, (s, v) => s + v);
  if (total <= 0) return const [];

  final count = values.length;
  final gapRad = count == 1 ? 0.0 : gapDegrees * pi / 180;
  final usable = 2 * pi - gapRad * count;

  final arcs = <ArcGeometry>[];
  double cursor = -pi / 2; // start at 12 o'clock

  for (int i = 0; i < count; i++) {
    final sweep = (values[i] / total) * usable;
    arcs.add(ArcGeometry(
      startAngle: cursor + gapRad / 2,
      sweepAngle: sweep,
    ));
    cursor += sweep + gapRad;
  }

  return arcs;
}

/// Returns the index of the segment hit by [tapPos], or `-1` if none.
///
/// [tapPos] is in the local coordinate system of the chart widget.
/// [widgetSize] is the size of the chart area.
/// [arcs] are the pre-computed arc geometries.
/// [rx], [ry] are the ellipse radii.
/// [cx], [cy] is the center of the ellipse.
/// [strokeWidth] is the ring stroke width (used for tap tolerance).
int hitTestSegment({
  required Offset tapPos,
  required List<ArcGeometry> arcs,
  required double cx,
  required double cy,
  required double rx,
  required double ry,
  required double strokeWidth,
}) {
  if (arcs.isEmpty) return -1;

  final dx = tapPos.dx - cx;
  final dy = tapPos.dy - cy;

  // Normalise to unit ellipse
  final nx = dx / rx;
  final ny = dy / ry;
  final dist = sqrt(nx * nx + ny * ny);

  // Generous tap tolerance
  final tolerance = (strokeWidth * 2.5) / rx;
  if (dist < (1.0 - tolerance) || dist > (1.0 + tolerance)) return -1;

  final tapAngle = atan2(dy / ry, dx / rx);

  for (int i = 0; i < arcs.length; i++) {
    if (_isAngleInArc(tapAngle, arcs[i].startAngle, arcs[i].sweepAngle)) {
      return i;
    }
  }

  return -1;
}

/// Whether [angle] falls within the arc starting at [start] with [sweep].
bool _isAngleInArc(double angle, double start, double sweep) {
  final nAngle = _normalise(angle);
  final nStart = _normalise(start);
  final nEnd = _normalise(start + sweep);

  if (nStart <= nEnd) {
    return nAngle >= nStart && nAngle <= nEnd;
  } else {
    return nAngle >= nStart || nAngle <= nEnd;
  }
}

/// Normalise an angle to the range [0, 2π).
double _normalise(double a) {
  a %= 2 * pi;
  if (a < 0) a += 2 * pi;
  return a;
}

/// Built-in color palette used when the user doesn't supply colours.
///
/// 20 distinct, visually balanced colours that cycle for large segment counts.
const List<Color> kDefaultPalette = [
  Color(0xFF2962FF), // vivid blue
  Color(0xFF00E5FF), // cyan
  Color(0xFF1939B7), // deep blue
  Color(0xFF00BFA5), // teal
  Color(0xFFAA00FF), // purple
  Color(0xFFFF6D00), // orange
  Color(0xFFFFD600), // yellow
  Color(0xFFDD2C00), // red
  Color(0xFF64DD17), // green
  Color(0xFFC51162), // pink
  Color(0xFF6200EA), // deep purple
  Color(0xFF00C853), // green accent
  Color(0xFFFF3D00), // deep orange
  Color(0xFF304FFE), // indigo
  Color(0xFF00B8D4), // cyan accent
  Color(0xFFAEEA00), // lime
  Color(0xFFD50000), // red accent
  Color(0xFF1DE9B6), // teal accent
  Color(0xFFF50057), // pink accent
  Color(0xFF651FFF), // deep purple accent
];

/// Returns the effective color for a segment at [index].
///
/// Uses the segment's own [overrideColor] if provided, otherwise picks
/// from [palette] (cycling if necessary), and finally falls back to the
/// [kDefaultPalette].
Color resolveSegmentColor(
  int index, {
  Color? overrideColor,
  List<Color>? palette,
}) {
  if (overrideColor != null) return overrideColor;
  final p = palette ?? kDefaultPalette;
  return p[index % p.length];
}
