import 'package:flutter/material.dart';

/// Where the legend is positioned relative to the ring chart.
enum LegendPosition {
  /// Legend appears below the chart (default).
  bottom,

  /// Legend appears above the chart.
  top,

  /// Legend appears to the left of the chart.
  left,

  /// Legend appears to the right of the chart.
  right,

  /// Legend is hidden entirely.
  none,
}

/// Shape of the legend indicator dot.
enum LegendIndicatorShape {
  /// Rounded rectangle (default).
  roundedRect,

  /// Perfect circle.
  circle,

  /// Square with no rounding.
  square,
}

/// Controls every visual aspect of the [ThreeDPieChart].
///
/// All properties have sensible defaults. Pass only the fields you want
/// to customise — everything else adapts to the current [ThemeData].
///
/// ## Example
///
/// ```dart
/// ThreeDPieChartStyle(
///   strokeWidth: 14.0,
///   gapDegrees: 10.0,
///   tiltFactor: 0.5,
///   animationDuration: Duration(milliseconds: 400),
///   shadowStyle: PieChartShadowStyle(
///     offsetY: 12.0,
///     blurRadius: 5.0,
///   ),
/// )
/// ```
class ThreeDPieChartStyle {
  // ─────────────────────────── Ring geometry ────────────────────────────────

  /// Width of each ring arc stroke in logical pixels.
  ///
  /// Defaults to `10.0`.
  final double strokeWidth;

  /// Gap between adjacent segments in degrees.
  ///
  /// Set to `0.0` for a seamless ring. The gap is distributed evenly
  /// between all segments. When there is only one segment, the gap is
  /// ignored automatically.
  ///
  /// Defaults to `12.0`.
  final double gapDegrees;

  /// How much the ring is "tilted" to create the 3D perspective effect.
  ///
  /// `1.0` = perfect circle (no tilt), `0.0` = fully squished (invisible).
  /// Values between `0.3` and `0.7` give the best 3D look.
  ///
  /// Defaults to `0.52`.
  final double tiltFactor;

  /// Horizontal radius of the ellipse as a fraction of the available width.
  ///
  /// `0.42` means the ellipse's horizontal radius is 42% of the widget width.
  ///
  /// Defaults to `0.42`.
  final double radiusFraction;

  /// Vertical offset of the ellipse center from the widget's vertical center.
  ///
  /// Positive values shift the ring downward (creating room for top labels).
  ///
  /// Defaults to `30.0`.
  final double centerOffsetY;

  // ─────────────────────── Unselected segment ──────────────────────────────

  /// Color used for ring arcs that are **not** currently selected.
  ///
  /// If `null`, defaults to `Colors.grey[700]` in dark mode and
  /// `Colors.grey[300]` in light mode.
  final Color? unselectedColor;

  // ──────────────────────── Shadow / depth ──────────────────────────────────

  /// Shadow configuration for the 3D depth effect beneath the ring.
  ///
  /// Pass [PieChartShadowStyle.none] to disable shadows entirely.
  final PieChartShadowStyle shadowStyle;

  // ────────────────────────── Glow effect ───────────────────────────────────

  /// Glow configuration for the selected segment.
  ///
  /// Pass [PieChartGlowStyle.none] to disable glow entirely.
  final PieChartGlowStyle glowStyle;

  // ───────────────────── Indicator line + label ────────────────────────────

  /// Height (in logical pixels) of the vertical indicator line drawn
  /// from the ring to the floating label above the selected segment.
  ///
  /// Defaults to `50.0`.
  final double indicatorLineHeight;

  /// Stroke width of the indicator line.
  ///
  /// Defaults to `1.5`.
  final double indicatorLineWidth;

  /// Whether the indicator line uses a gradient that fades toward the top.
  ///
  /// Defaults to `true`.
  final bool indicatorLineGradient;

  /// Text style for the floating label above the selected segment.
  ///
  /// If `null`, defaults to a 12 px white (dark mode) or black (light mode)
  /// label derived from the theme.
  final TextStyle? indicatorLabelStyle;

  /// Whether to show the indicator line and floating label at all.
  ///
  /// Defaults to `true`.
  final bool showIndicator;

  // ──────────────────────── Legend styling ──────────────────────────────────

  /// Where the legend is placed relative to the chart.
  ///
  /// Defaults to [LegendPosition.bottom].
  final LegendPosition legendPosition;

  /// Spacing between the chart and the legend.
  ///
  /// Defaults to `24.0`.
  final double legendSpacing;

  /// Shape of the small indicator next to each legend item.
  ///
  /// Defaults to [LegendIndicatorShape.roundedRect].
  final LegendIndicatorShape legendIndicatorShape;

  /// Size (width & height) of the legend indicator dot.
  ///
  /// Defaults to `12.0`.
  final double legendIndicatorSize;

  /// Border radius applied when [legendIndicatorShape] is
  /// [LegendIndicatorShape.roundedRect].
  ///
  /// Defaults to `4.0`.
  final double legendIndicatorRadius;

  /// Text style for legend labels.
  ///
  /// If `null`, derived from the current theme.
  final TextStyle? legendLabelStyle;

  /// Text style for legend labels when the segment is selected.
  ///
  /// If `null`, defaults to [legendLabelStyle] with `FontWeight.w600`
  /// and full opacity.
  final TextStyle? legendLabelSelectedStyle;

  /// Text style for legend percentage/value text.
  ///
  /// If `null`, derived from the current theme.
  final TextStyle? legendValueStyle;

  /// Text style for legend percentage/value when the segment is selected.
  ///
  /// If `null`, defaults to [legendValueStyle] with `FontWeight.w600`.
  final TextStyle? legendValueSelectedStyle;

  /// Vertical padding around each legend row.
  ///
  /// Defaults to `10.0`.
  final double legendItemVerticalPadding;

  /// Whether to show the percentage value in the legend.
  ///
  /// Defaults to `true`.
  final bool showLegendValue;

  /// A custom formatter for the legend value text.
  ///
  /// Receives the segment's value and the total of all segment values.
  /// Return the string to display (e.g. `'65.0%'`, `'$1.2M'`).
  ///
  /// If `null`, displays `'XX.X%'` by default.
  final String Function(double value, double total)? legendValueFormatter;

  // ─────────────────────── Animation ────────────────────────────────────────

  /// Duration of the selection animation.
  ///
  /// Defaults to `300ms`.
  final Duration animationDuration;

  /// Easing curve for the selection animation.
  ///
  /// Defaults to [Curves.easeInOut].
  final Curve animationCurve;

  // ───────────────────── Default color palette ─────────────────────────────

  /// Ordered list of colors assigned to segments that don't specify
  /// their own [PieChartSegment.color].
  ///
  /// The list wraps around if there are more segments than colors.
  ///
  /// If `null`, a built-in palette is used.
  final List<Color>? defaultSegmentColors;

  // ───────────────────── Zero-value handling ───────────────────────────────

  /// Whether to render segments whose [PieChartSegment.value] is `0`.
  ///
  /// When `false` (default), zero-value segments are excluded from the ring
  /// and the legend. When `true`, they appear in the legend (with `0.0%`)
  /// but occupy no arc space on the ring.
  final bool showZeroValueSegments;

  /// Creates a [ThreeDPieChartStyle] with all visual parameters.
  ///
  /// Every field has a sensible default so you only need to pass the
  /// properties you want to change.
  const ThreeDPieChartStyle({
    this.strokeWidth = 10.0,
    this.gapDegrees = 12.0,
    this.tiltFactor = 0.52,
    this.radiusFraction = 0.42,
    this.centerOffsetY = 30.0,
    this.unselectedColor,
    this.shadowStyle = const PieChartShadowStyle(),
    this.glowStyle = const PieChartGlowStyle(),
    this.indicatorLineHeight = 50.0,
    this.indicatorLineWidth = 1.5,
    this.indicatorLineGradient = true,
    this.indicatorLabelStyle,
    this.showIndicator = true,
    this.legendPosition = LegendPosition.bottom,
    this.legendSpacing = 24.0,
    this.legendIndicatorShape = LegendIndicatorShape.roundedRect,
    this.legendIndicatorSize = 12.0,
    this.legendIndicatorRadius = 4.0,
    this.legendLabelStyle,
    this.legendLabelSelectedStyle,
    this.legendValueStyle,
    this.legendValueSelectedStyle,
    this.legendItemVerticalPadding = 10.0,
    this.showLegendValue = true,
    this.legendValueFormatter,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.defaultSegmentColors,
    this.showZeroValueSegments = false,
  });

  /// Creates a copy with the given fields replaced.
  ThreeDPieChartStyle copyWith({
    double? strokeWidth,
    double? gapDegrees,
    double? tiltFactor,
    double? radiusFraction,
    double? centerOffsetY,
    Color? unselectedColor,
    PieChartShadowStyle? shadowStyle,
    PieChartGlowStyle? glowStyle,
    double? indicatorLineHeight,
    double? indicatorLineWidth,
    bool? indicatorLineGradient,
    TextStyle? indicatorLabelStyle,
    bool? showIndicator,
    LegendPosition? legendPosition,
    double? legendSpacing,
    LegendIndicatorShape? legendIndicatorShape,
    double? legendIndicatorSize,
    double? legendIndicatorRadius,
    TextStyle? legendLabelStyle,
    TextStyle? legendLabelSelectedStyle,
    TextStyle? legendValueStyle,
    TextStyle? legendValueSelectedStyle,
    double? legendItemVerticalPadding,
    bool? showLegendValue,
    String Function(double value, double total)? legendValueFormatter,
    Duration? animationDuration,
    Curve? animationCurve,
    List<Color>? defaultSegmentColors,
    bool? showZeroValueSegments,
  }) {
    return ThreeDPieChartStyle(
      strokeWidth: strokeWidth ?? this.strokeWidth,
      gapDegrees: gapDegrees ?? this.gapDegrees,
      tiltFactor: tiltFactor ?? this.tiltFactor,
      radiusFraction: radiusFraction ?? this.radiusFraction,
      centerOffsetY: centerOffsetY ?? this.centerOffsetY,
      unselectedColor: unselectedColor ?? this.unselectedColor,
      shadowStyle: shadowStyle ?? this.shadowStyle,
      glowStyle: glowStyle ?? this.glowStyle,
      indicatorLineHeight: indicatorLineHeight ?? this.indicatorLineHeight,
      indicatorLineWidth: indicatorLineWidth ?? this.indicatorLineWidth,
      indicatorLineGradient:
          indicatorLineGradient ?? this.indicatorLineGradient,
      indicatorLabelStyle: indicatorLabelStyle ?? this.indicatorLabelStyle,
      showIndicator: showIndicator ?? this.showIndicator,
      legendPosition: legendPosition ?? this.legendPosition,
      legendSpacing: legendSpacing ?? this.legendSpacing,
      legendIndicatorShape:
          legendIndicatorShape ?? this.legendIndicatorShape,
      legendIndicatorSize: legendIndicatorSize ?? this.legendIndicatorSize,
      legendIndicatorRadius:
          legendIndicatorRadius ?? this.legendIndicatorRadius,
      legendLabelStyle: legendLabelStyle ?? this.legendLabelStyle,
      legendLabelSelectedStyle:
          legendLabelSelectedStyle ?? this.legendLabelSelectedStyle,
      legendValueStyle: legendValueStyle ?? this.legendValueStyle,
      legendValueSelectedStyle:
          legendValueSelectedStyle ?? this.legendValueSelectedStyle,
      legendItemVerticalPadding:
          legendItemVerticalPadding ?? this.legendItemVerticalPadding,
      showLegendValue: showLegendValue ?? this.showLegendValue,
      legendValueFormatter: legendValueFormatter ?? this.legendValueFormatter,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      defaultSegmentColors: defaultSegmentColors ?? this.defaultSegmentColors,
      showZeroValueSegments:
          showZeroValueSegments ?? this.showZeroValueSegments,
    );
  }
}

/// Shadow parameters for the 3D depth effect beneath the ring.
///
/// ## Example
///
/// ```dart
/// PieChartShadowStyle(
///   offsetY: 12.0,
///   blurRadius: 5.0,
///   opacity: 0.2,
/// )
/// ```
class PieChartShadowStyle {
  /// Horizontal offset of the shadow relative to the ring.
  final double offsetX;

  /// Vertical offset of the shadow relative to the ring.
  ///
  /// Positive values push the shadow downward, enhancing the 3D look.
  final double offsetY;

  /// Gaussian blur radius of the shadow.
  final double blurRadius;

  /// Opacity of the shadow (0.0 – 1.0).
  final double opacity;

  /// Extra stroke width added to the shadow arc beyond the ring stroke.
  final double extraWidth;

  /// Whether shadows are enabled.
  final bool enabled;

  /// Creates a [PieChartShadowStyle].
  const PieChartShadowStyle({
    this.offsetX = 0.0,
    this.offsetY = 11.5,
    this.blurRadius = 4.5,
    this.opacity = 0.18,
    this.extraWidth = 0.05,
    this.enabled = true,
  });

  /// A convenience constant that disables shadows.
  static const PieChartShadowStyle none = PieChartShadowStyle(enabled: false);
}

/// Glow parameters for the currently selected segment.
///
/// The glow is rendered as two concentric blurred arcs behind the
/// selected segment to give it a soft luminous highlight.
///
/// ## Example
///
/// ```dart
/// PieChartGlowStyle(
///   innerSpread: 8.0,
///   outerSpread: 26.0,
///   innerBlur: 8.0,
///   outerBlur: 20.0,
/// )
/// ```
class PieChartGlowStyle {
  /// Extra stroke width added to the inner glow layer.
  final double innerSpread;

  /// Extra stroke width added to the outer glow layer.
  final double outerSpread;

  /// Blur radius for the inner glow.
  final double innerBlur;

  /// Blur radius for the outer glow.
  final double outerBlur;

  /// Opacity of both glow layers (0.0 – 1.0).
  final double opacity;

  /// Whether glow is enabled.
  final bool enabled;

  /// Creates a [PieChartGlowStyle].
  const PieChartGlowStyle({
    this.innerSpread = 8.0,
    this.outerSpread = 26.0,
    this.innerBlur = 8.0,
    this.outerBlur = 20.0,
    this.opacity = 0.01,
    this.enabled = true,
  });

  /// A convenience constant that disables glow.
  static const PieChartGlowStyle none = PieChartGlowStyle(enabled: false);
}
