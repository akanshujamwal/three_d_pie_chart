import 'package:flutter/material.dart';

import '../models/chart_data.dart';
import '../models/chart_style.dart';
import '../painters/ring_painter.dart';

/// A standalone legend widget for [ThreeDPieChart].
///
/// Displays each segment with a coloured indicator, label, and optional
/// value/percentage. Tapping a legend row selects the corresponding segment.
///
/// This widget is used internally by [ThreeDPieChart] but is also exported
/// so developers can build fully custom layouts.
///
/// ## Example
///
/// ```dart
/// PieChartLegend(
///   segments: mySegments,
///   colors: resolvedColors,
///   selectedIndex: 0,
///   total: 100.0,
///   style: ThreeDPieChartStyle(),
///   isDarkMode: true,
///   onSegmentTap: (index) => print('Tapped $index'),
/// )
/// ```
class PieChartLegend extends StatelessWidget {
  /// Segments to display in the legend.
  final List<PieChartSegment> segments;

  /// Resolved colours for each segment.
  final List<ResolvedSegmentColors> colors;

  /// Currently selected segment index.
  final int selectedIndex;

  /// Sum of all segment values (used to compute percentages).
  final double total;

  /// Visual style configuration.
  final ThreeDPieChartStyle style;

  /// Whether the app is in dark mode.
  final bool isDarkMode;

  /// Callback fired when a legend row is tapped.
  final ValueChanged<int>? onSegmentTap;

  /// Creates a [PieChartLegend].
  const PieChartLegend({
    super.key,
    required this.segments,
    required this.colors,
    required this.selectedIndex,
    required this.total,
    required this.style,
    required this.isDarkMode,
    this.onSegmentTap,
  });

  @override
  Widget build(BuildContext context) {
    if (segments.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < segments.length; i++)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onSegmentTap?.call(i),
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: style.legendItemVerticalPadding,
              ),
              child: Row(
                children: [
                  _buildIndicator(i),
                  const SizedBox(width: 12),
                  Expanded(child: _buildLabel(i)),
                  if (style.showLegendValue) _buildValue(i),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildIndicator(int i) {
    final size = style.legendIndicatorSize;
    BoxDecoration decoration;

    switch (style.legendIndicatorShape) {
      case LegendIndicatorShape.circle:
        decoration = BoxDecoration(
          color: colors[i].legend,
          shape: BoxShape.circle,
        );
        break;
      case LegendIndicatorShape.square:
        decoration = BoxDecoration(
          color: colors[i].legend,
        );
        break;
      case LegendIndicatorShape.roundedRect:
        decoration = BoxDecoration(
          color: colors[i].legend,
          borderRadius: BorderRadius.circular(style.legendIndicatorRadius),
        );
        break;
    }

    return Container(
      width: size,
      height: size,
      decoration: decoration,
    );
  }

  Widget _buildLabel(int i) {
    final selected = i == selectedIndex;
    final defaultUnselected = TextStyle(
      color: isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
      fontSize: 14,
      fontWeight: FontWeight.w400,
    );
    final defaultSelected = TextStyle(
      color: isDarkMode ? Colors.white : Colors.black87,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    );

    final textStyle = selected
        ? (style.legendLabelSelectedStyle ?? defaultSelected)
        : (style.legendLabelStyle ?? defaultUnselected);

    return Text(
      segments[i].label,
      style: textStyle,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildValue(int i) {
    final selected = i == selectedIndex;
    final defaultUnselected = TextStyle(
      color: isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
      fontSize: 14,
      fontWeight: FontWeight.w400,
    );
    final defaultSelected = TextStyle(
      color: isDarkMode ? Colors.white : Colors.black87,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    );

    final textStyle = selected
        ? (style.legendValueSelectedStyle ?? defaultSelected)
        : (style.legendValueStyle ?? defaultUnselected);

    final text = style.legendValueFormatter != null
        ? style.legendValueFormatter!(segments[i].value, total)
        : total > 0
            ? '${(segments[i].value / total * 100).toStringAsFixed(1)}%'
            : '0.0%';

    return Text(text, style: textStyle);
  }
}
