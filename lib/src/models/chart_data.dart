import 'package:flutter/material.dart';

/// Represents a single segment in the 3D pie/ring chart.
///
/// Each segment has a [label], a [value] (which determines its proportional
/// size relative to other segments), and optional color overrides.
///
/// ## Example
///
/// ```dart
/// PieChartSegment(
///   label: 'Large Cap',
///   value: 65.0,
///   color: Colors.blue,
/// )
/// ```
///
/// If [color] is not provided, the chart will assign a color from its
/// [ThreeDPieChartStyle.defaultSegmentColors] or from the current theme.
class PieChartSegment {
  /// Display label for this segment.
  ///
  /// Shown in the legend and on the indicator line label above the ring.
  final String label;

  /// Numeric value of this segment.
  ///
  /// The chart computes each segment's arc proportionally based on the sum
  /// of all segment values. This does **not** need to be a percentage —
  /// raw numbers work fine (e.g. revenue in dollars, count of items).
  final double value;

  /// Override color for the ring arc of this segment.
  ///
  /// When `null`, the chart picks a color from
  /// [ThreeDPieChartStyle.defaultSegmentColors] based on the segment index,
  /// or falls back to theme-derived colors.
  final Color? color;

  /// Override color for the glow effect around the selected arc.
  ///
  /// Defaults to [color] (or the auto-assigned color) if not provided.
  final Color? glowColor;

  /// Override color for the legend indicator dot of this segment.
  ///
  /// Defaults to [color] (or the auto-assigned color) if not provided.
  final Color? legendColor;

  /// Override color for the vertical indicator line drawn from the ring
  /// to the floating label when this segment is selected.
  ///
  /// Defaults to [color] (or the auto-assigned color) if not provided.
  final Color? indicatorLineColor;

  /// Optional metadata you can attach to a segment.
  ///
  /// This is returned in [ThreeDPieChart.onSegmentSelected] so you can
  /// associate domain-specific data (e.g. an ID, a model object) with
  /// a segment without subclassing.
  final dynamic extra;

  /// Creates a [PieChartSegment].
  ///
  /// [label] and [value] are required. All color fields are optional and
  /// will be auto-derived if omitted.
  const PieChartSegment({
    required this.label,
    required this.value,
    this.color,
    this.glowColor,
    this.legendColor,
    this.indicatorLineColor,
    this.extra,
  });

  /// Creates a copy of this segment with the given fields replaced.
  PieChartSegment copyWith({
    String? label,
    double? value,
    Color? color,
    Color? glowColor,
    Color? legendColor,
    Color? indicatorLineColor,
    dynamic extra,
  }) {
    return PieChartSegment(
      label: label ?? this.label,
      value: value ?? this.value,
      color: color ?? this.color,
      glowColor: glowColor ?? this.glowColor,
      legendColor: legendColor ?? this.legendColor,
      indicatorLineColor: indicatorLineColor ?? this.indicatorLineColor,
      extra: extra ?? this.extra,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PieChartSegment &&
        other.label == label &&
        other.value == value &&
        other.color == color &&
        other.glowColor == glowColor &&
        other.legendColor == legendColor &&
        other.indicatorLineColor == indicatorLineColor;
  }

  @override
  int get hashCode => Object.hash(
        label,
        value,
        color,
        glowColor,
        legendColor,
        indicatorLineColor,
      );

  @override
  String toString() =>
      'PieChartSegment(label: "$label", value: $value, color: $color)';
}
