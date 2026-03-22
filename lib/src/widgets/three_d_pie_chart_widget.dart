import 'package:flutter/material.dart';

import '../models/chart_data.dart';
import '../models/chart_style.dart';
import '../painters/ring_painter.dart';
import '../utils/math_utils.dart';
import 'chart_legend.dart';

/// Callback signature for segment selection events.
///
/// [index] is the zero-based position in the (filtered) segments list.
/// [segment] is the corresponding [PieChartSegment] data.
typedef SegmentSelectedCallback = void Function(
    int index, PieChartSegment segment);

/// A highly customizable 3D tilted elliptical ring chart for Flutter.
///
/// Feed it a list of [PieChartSegment]s and it renders an interactive
/// ring chart with a 3D perspective effect, smooth selection animations,
/// configurable glow/shadow, and a built-in (or hidden) legend.
///
/// ## Minimal example
///
/// ```dart
/// ThreeDPieChart(
///   segments: [
///     PieChartSegment(label: 'Large Cap', value: 65),
///     PieChartSegment(label: 'Mid Cap',   value: 25),
///     PieChartSegment(label: 'Small Cap', value: 10),
///   ],
/// )
/// ```
///
/// ## Full customisation
///
/// ```dart
/// ThreeDPieChart(
///   segments: segments,
///   style: ThreeDPieChartStyle(
///     strokeWidth: 14,
///     gapDegrees: 8,
///     tiltFactor: 0.55,
///     animationDuration: Duration(milliseconds: 500),
///     legendPosition: LegendPosition.right,
///     showZeroValueSegments: true,
///     shadowStyle: PieChartShadowStyle(offsetY: 14, blurRadius: 6),
///     glowStyle: PieChartGlowStyle(outerSpread: 30),
///   ),
///   chartHeight: 280,
///   initialSelectedIndex: 0,
///   onSegmentSelected: (index, segment) {
///     print('Selected: ${segment.label}');
///   },
/// )
/// ```
class ThreeDPieChart extends StatefulWidget {
  /// The data segments to display.
  ///
  /// Must contain at least one segment with a value > 0 (unless
  /// [ThreeDPieChartStyle.showZeroValueSegments] is `true`, in which
  /// case they appear in the legend but not the ring).
  final List<PieChartSegment> segments;

  /// Visual style. See [ThreeDPieChartStyle] for all options.
  ///
  /// Defaults to `ThreeDPieChartStyle()` which gives sensible dark-mode
  /// defaults that adapt to the app's [ThemeData].
  final ThreeDPieChartStyle style;

  /// Height of the ring chart area (not including the legend).
  ///
  /// Defaults to `260.0`.
  final double chartHeight;

  /// Horizontal padding inside the ring chart area.
  ///
  /// Defaults to `32.0`.
  final double chartHorizontalPadding;

  /// Initially selected segment index.
  ///
  /// Defaults to `0` (first segment). Pass `-1` for no initial selection
  /// (the ring will render with all segments in the unselected colour).
  final int initialSelectedIndex;

  /// Called when a segment is tapped (either on the ring or in the legend).
  ///
  /// Receives the segment index and the corresponding [PieChartSegment].
  final SegmentSelectedCallback? onSegmentSelected;

  /// Optional title widget displayed above the chart.
  ///
  /// If `null`, no title is shown. Pass any widget — typically a [Text].
  final Widget? title;

  /// Optional widget shown when there are no segments (or all are zero
  /// and [showZeroValueSegments] is `false`).
  final Widget? emptyState;

  /// Creates a [ThreeDPieChart].
  const ThreeDPieChart({
    super.key,
    required this.segments,
    this.style = const ThreeDPieChartStyle(),
    this.chartHeight = 260.0,
    this.chartHorizontalPadding = 32.0,
    this.initialSelectedIndex = 0,
    this.onSegmentSelected,
    this.title,
    this.emptyState,
  });

  @override
  State<ThreeDPieChart> createState() => _ThreeDPieChartState();
}

class _ThreeDPieChartState extends State<ThreeDPieChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;

  int _selectedIndex = 0;
  int _previousSelectedIndex = 0;

  /// Segments actually rendered (filtered if needed).
  List<PieChartSegment> _activeSegments = [];

  /// All segments including zero-value (used for legend when showZero is true).
  List<PieChartSegment> _allSegments = [];

  /// Arcs for _activeSegments.
  List<ArcGeometry> _arcs = [];

  /// Resolved colours for _activeSegments.
  List<ResolvedSegmentColors> _colors = [];

  /// Resolved colours for _allSegments (used for legend).
  List<ResolvedSegmentColors> _allColors = [];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: widget.style.animationDuration,
    );
    _animation = CurvedAnimation(
      parent: _animController,
      curve: widget.style.animationCurve,
    );
    _animController.value = 1.0; // start fully resolved

    _rebuildData();
    _selectedIndex = widget.initialSelectedIndex.clamp(
      _activeSegments.isEmpty ? -1 : 0,
      _activeSegments.length - 1,
    );
    _previousSelectedIndex = _selectedIndex;
  }

  @override
  void didUpdateWidget(covariant ThreeDPieChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update animation config if changed
    if (oldWidget.style.animationDuration != widget.style.animationDuration) {
      _animController.duration = widget.style.animationDuration;
    }
    if (oldWidget.style.animationCurve != widget.style.animationCurve) {
      _animation = CurvedAnimation(
        parent: _animController,
        curve: widget.style.animationCurve,
      );
    }

    _rebuildData();

    // Clamp selection to new data bounds
    if (_selectedIndex >= _activeSegments.length) {
      _selectedIndex =
          _activeSegments.isEmpty ? -1 : _activeSegments.length - 1;
      _previousSelectedIndex = _selectedIndex;
      _animController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ─────────────────────── Data processing ─────────────────────────────────

  void _rebuildData() {
    _allSegments = List<PieChartSegment>.from(widget.segments);

    if (widget.style.showZeroValueSegments) {
      _activeSegments =
          _allSegments.where((s) => s.value > 0).toList();
    } else {
      _activeSegments =
          _allSegments.where((s) => s.value > 0).toList();
    }

    _arcs = computeArcs(
      _activeSegments.map((s) => s.value).toList(),
      widget.style.gapDegrees,
    );

    _colors = _resolveColors(_activeSegments);
    _allColors = _resolveColors(
      widget.style.showZeroValueSegments ? _allSegments : _activeSegments,
    );
  }

  List<ResolvedSegmentColors> _resolveColors(List<PieChartSegment> segs) {
    return List.generate(segs.length, (i) {
      final base = resolveSegmentColor(
        i,
        overrideColor: segs[i].color,
        palette: widget.style.defaultSegmentColors,
      );
      return ResolvedSegmentColors(
        ring: base,
        glow: segs[i].glowColor ?? base,
        legend: segs[i].legendColor ?? base,
        indicatorLine: segs[i].indicatorLineColor ?? base,
      );
    });
  }

  // ─────────────────────── Selection ───────────────────────────────────────

  void _selectSegment(int index) {
    if (index < 0 || index >= _activeSegments.length) return;
    if (index == _selectedIndex && _animController.isCompleted) return;

    setState(() {
      _previousSelectedIndex = _selectedIndex;
      _selectedIndex = index;
    });

    _animController.forward(from: 0.0);

    widget.onSegmentSelected?.call(index, _activeSegments[index]);
  }

  /// Map an "all segments" index to the "active segments" index.
  int _allToActiveIndex(int allIndex) {
    if (!widget.style.showZeroValueSegments) return allIndex;
    final target = _allSegments[allIndex];
    return _activeSegments.indexOf(target);
  }

  // ─────────────────────── Build ───────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_activeSegments.isEmpty) {
      return widget.emptyState ?? const SizedBox.shrink();
    }

    final chartWidget = _buildChart(isDark);
    final legendSegments =
        widget.style.showZeroValueSegments ? _allSegments : _activeSegments;
    final legendColors =
        widget.style.showZeroValueSegments ? _allColors : _colors;
    final legendWidget = widget.style.legendPosition != LegendPosition.none
        ? _buildLegend(legendSegments, legendColors, isDark)
        : const SizedBox.shrink();

    final titleWidget = widget.title;

    switch (widget.style.legendPosition) {
      case LegendPosition.top:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (titleWidget != null) titleWidget,
            if (titleWidget != null) const SizedBox(height: 8),
            legendWidget,
            SizedBox(height: widget.style.legendSpacing),
            chartWidget,
          ],
        );

      case LegendPosition.bottom:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (titleWidget != null) titleWidget,
            chartWidget,
            SizedBox(height: widget.style.legendSpacing),
            legendWidget,
          ],
        );

      case LegendPosition.left:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (titleWidget != null) titleWidget,
            if (titleWidget != null) const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: legendWidget),
                SizedBox(width: widget.style.legendSpacing),
                Expanded(flex: 2, child: chartWidget),
              ],
            ),
          ],
        );

      case LegendPosition.right:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (titleWidget != null) titleWidget,
            if (titleWidget != null) const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 2, child: chartWidget),
                SizedBox(width: widget.style.legendSpacing),
                Expanded(child: legendWidget),
              ],
            ),
          ],
        );

      case LegendPosition.none:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (titleWidget != null) titleWidget,
            chartWidget,
          ],
        );
    }
  }

  Widget _buildChart(bool isDark) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: widget.chartHorizontalPadding),
      child: GestureDetector(
        onTapUp: (details) {
          // localPosition is now relative to the SizedBox (inside padding)
          final chartWidth = context.size != null
              ? context.size!.width - widget.chartHorizontalPadding * 2
              : 0.0;
          final cx = chartWidth / 2;
          final cy = widget.chartHeight / 2 + widget.style.centerOffsetY;
          final rx = chartWidth * widget.style.radiusFraction;
          final ry = rx * widget.style.tiltFactor;

          final hitIndex = hitTestSegment(
            tapPos: details.localPosition,
            arcs: _arcs,
            cx: cx,
            cy: cy,
            rx: rx,
            ry: ry,
            strokeWidth: widget.style.strokeWidth,
          );

          if (hitIndex >= 0) {
            _selectSegment(hitIndex);
          }
        },
        child: SizedBox(
          height: widget.chartHeight,
          width: double.infinity,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, _) {
              return CustomPaint(
                painter: ThreeDRingPainter(
                  segments: _activeSegments,
                  arcs: _arcs,
                  colors: _colors,
                  selectedIndex: _selectedIndex,
                  previousSelectedIndex: _previousSelectedIndex,
                  selectedProgress: _animation.value,
                  style: widget.style,
                  isDarkMode: isDark,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(
    List<PieChartSegment> legendSegments,
    List<ResolvedSegmentColors> legendColors,
    bool isDark,
  ) {
    final total = legendSegments.fold<double>(0.0, (s, seg) => s + seg.value);

    return PieChartLegend(
      segments: legendSegments,
      colors: legendColors,
      selectedIndex: widget.style.showZeroValueSegments
          ? _activeToAllIndex(_selectedIndex)
          : _selectedIndex,
      total: total,
      style: widget.style,
      isDarkMode: isDark,
      onSegmentTap: (i) {
        final activeIdx =
            widget.style.showZeroValueSegments ? _allToActiveIndex(i) : i;
        if (activeIdx >= 0) _selectSegment(activeIdx);
      },
    );
  }

  /// Map an "active segments" index to the "all segments" index.
  int _activeToAllIndex(int activeIndex) {
    if (!widget.style.showZeroValueSegments) return activeIndex;
    if (activeIndex < 0 || activeIndex >= _activeSegments.length) {
      return activeIndex;
    }
    final target = _activeSegments[activeIndex];
    return _allSegments.indexOf(target);
  }
}


