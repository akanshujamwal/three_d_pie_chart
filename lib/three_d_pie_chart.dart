/// A highly customizable, production-grade 3D tilted elliptical ring chart
/// (pie/donut chart) for Flutter.
///
/// ## Quick Start
///
/// ```dart
/// import 'package:three_d_pie_chart/three_d_pie_chart.dart';
///
/// ThreeDPieChart(
///   segments: [
///     PieChartSegment(label: 'Large Cap', value: 65),
///     PieChartSegment(label: 'Mid Cap',   value: 25),
///     PieChartSegment(label: 'Small Cap', value: 10),
///   ],
/// )
/// ```
///
/// See [ThreeDPieChart] for the main widget, [ThreeDPieChartStyle] for
/// customisation options, and [PieChartSegment] for segment data.
library three_d_pie_chart;

// Models
export 'src/models/chart_data.dart';
export 'src/models/chart_style.dart';

// Widgets
export 'src/widgets/three_d_pie_chart_widget.dart';
export 'src/widgets/chart_legend.dart';

// Utilities (advanced usage)
export 'src/utils/math_utils.dart'
    show ArcGeometry, computeArcs, kDefaultPalette, resolveSegmentColor;

// Painter (advanced usage — for custom compositions)
export 'src/painters/ring_painter.dart'
    show ThreeDRingPainter, ResolvedSegmentColors;
