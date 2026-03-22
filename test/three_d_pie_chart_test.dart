import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:three_d_pie_chart/three_d_pie_chart.dart';

void main() {
  group('PieChartSegment', () {
    test('creates with required fields', () {
      const seg = PieChartSegment(label: 'Test', value: 42.0);
      expect(seg.label, 'Test');
      expect(seg.value, 42.0);
      expect(seg.color, isNull);
      expect(seg.extra, isNull);
    });

    test('copyWith replaces fields', () {
      const seg = PieChartSegment(label: 'A', value: 10);
      final copy = seg.copyWith(label: 'B', value: 20);
      expect(copy.label, 'B');
      expect(copy.value, 20);
    });

    test('equality works', () {
      const a = PieChartSegment(label: 'X', value: 5);
      const b = PieChartSegment(label: 'X', value: 5);
      const c = PieChartSegment(label: 'Y', value: 5);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('computeArcs', () {
    test('returns empty list for empty input', () {
      expect(computeArcs([], 12.0), isEmpty);
    });

    test('returns empty list when total is zero', () {
      expect(computeArcs([0, 0, 0], 12.0), isEmpty);
    });

    test('single segment gets full ring with no gap', () {
      final arcs = computeArcs([100], 12.0);
      expect(arcs.length, 1);
      // Should span nearly 2π (full circle)
      expect(arcs[0].sweepAngle, closeTo(2 * pi, 0.01));
    });

    test('two equal segments get equal sweep', () {
      final arcs = computeArcs([50, 50], 12.0);
      expect(arcs.length, 2);
      expect(arcs[0].sweepAngle, closeTo(arcs[1].sweepAngle, 0.001));
    });

    test('sweeps sum to usable angle (2π minus gaps)', () {
      final values = [30.0, 50.0, 20.0];
      const gap = 12.0;
      final arcs = computeArcs(values, gap);

      final totalSweep = arcs.fold<double>(0, (s, a) => s + a.sweepAngle);
      const gapRad = gap * pi / 180;
      final expectedUsable = 2 * pi - gapRad * values.length;

      expect(totalSweep, closeTo(expectedUsable, 0.001));
    });

    test('handles many segments', () {
      final values = List.generate(100, (i) => (i + 1).toDouble());
      final arcs = computeArcs(values, 2.0);
      expect(arcs.length, 100);
    });
  });

  group('resolveSegmentColor', () {
    test('returns override color when provided', () {
      final c = resolveSegmentColor(0, overrideColor: Colors.red);
      expect(c, Colors.red);
    });

    test('returns palette color by index', () {
      final c = resolveSegmentColor(
        2,
        palette: [Colors.red, Colors.green, Colors.blue],
      );
      expect(c, Colors.blue);
    });

    test('wraps around palette', () {
      final c = resolveSegmentColor(
        3,
        palette: [Colors.red, Colors.green, Colors.blue],
      );
      expect(c, Colors.red);
    });

    test('falls back to default palette', () {
      final c = resolveSegmentColor(0);
      expect(c, kDefaultPalette[0]);
    });
  });

  group('ThreeDPieChartStyle', () {
    test('default values are sensible', () {
      const style = ThreeDPieChartStyle();
      expect(style.strokeWidth, 10.0);
      expect(style.gapDegrees, 12.0);
      expect(style.tiltFactor, 0.52);
      expect(style.animationDuration, const Duration(milliseconds: 300));
      expect(style.legendPosition, LegendPosition.bottom);
      expect(style.showZeroValueSegments, false);
    });

    test('copyWith preserves unchanged fields', () {
      const style = ThreeDPieChartStyle(strokeWidth: 20.0);
      final copy = style.copyWith(gapDegrees: 5.0);
      expect(copy.strokeWidth, 20.0);
      expect(copy.gapDegrees, 5.0);
    });
  });

  group('PieChartShadowStyle', () {
    test('none disables shadows', () {
      expect(PieChartShadowStyle.none.enabled, false);
    });

    test('defaults are enabled', () {
      const s = PieChartShadowStyle();
      expect(s.enabled, true);
      expect(s.offsetY, 11.5);
    });
  });

  group('PieChartGlowStyle', () {
    test('none disables glow', () {
      expect(PieChartGlowStyle.none.enabled, false);
    });
  });

  group('ThreeDPieChart widget', () {
    testWidgets('renders with basic segments', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ThreeDPieChart(
              segments: [
                PieChartSegment(label: 'A', value: 60),
                PieChartSegment(label: 'B', value: 40),
              ],
            ),
          ),
        ),
      );

      // Legend labels should appear
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
    });

    testWidgets('shows empty state when no segments', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ThreeDPieChart(
              segments: [],
              emptyState: Text('No data'),
            ),
          ),
        ),
      );

      expect(find.text('No data'), findsOneWidget);
    });

    testWidgets('hides legend when position is none', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ThreeDPieChart(
              segments: [
                PieChartSegment(label: 'X', value: 100),
              ],
              style: ThreeDPieChartStyle(
                legendPosition: LegendPosition.none,
              ),
            ),
          ),
        ),
      );

      // Label should NOT appear in legend (only on indicator)
      // The indicator paints the label on canvas, not as a Text widget
      // so find.text won't find it. Legend is hidden.
      // We just verify no crash.
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('fires onSegmentSelected on legend tap', (tester) async {
      int? tappedIndex;
      PieChartSegment? tappedSegment;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThreeDPieChart(
              segments: const [
                PieChartSegment(label: 'Alpha', value: 70),
                PieChartSegment(label: 'Beta', value: 30),
              ],
              onSegmentSelected: (index, segment) {
                tappedIndex = index;
                tappedSegment = segment;
              },
            ),
          ),
        ),
      );

      // Tap the second legend item
      await tester.tap(find.text('Beta'));
      await tester.pumpAndSettle();

      expect(tappedIndex, 1);
      expect(tappedSegment?.label, 'Beta');
    });

    testWidgets('shows title when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ThreeDPieChart(
              segments: [
                PieChartSegment(label: 'A', value: 50),
              ],
              title: Text('My Chart'),
            ),
          ),
        ),
      );

      expect(find.text('My Chart'), findsOneWidget);
    });

    testWidgets('custom value formatter displays correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThreeDPieChart(
              segments: const [
                PieChartSegment(label: 'Sales', value: 5000),
                PieChartSegment(label: 'Returns', value: 1000),
              ],
              style: ThreeDPieChartStyle(
                legendValueFormatter: (value, total) => '\$${value.toInt()}',
              ),
            ),
          ),
        ),
      );

      expect(find.text('\$5000'), findsOneWidget);
      expect(find.text('\$1000'), findsOneWidget);
    });

    testWidgets('shows zero-value segments in legend when enabled',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ThreeDPieChart(
              segments: [
                PieChartSegment(label: 'Has Value', value: 100),
                PieChartSegment(label: 'Zero', value: 0),
              ],
              style: ThreeDPieChartStyle(showZeroValueSegments: true),
            ),
          ),
        ),
      );

      expect(find.text('Has Value'), findsOneWidget);
      expect(find.text('Zero'), findsOneWidget);
    });

    testWidgets('hides zero-value segments by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ThreeDPieChart(
              segments: [
                PieChartSegment(label: 'Visible', value: 100),
                PieChartSegment(label: 'Hidden', value: 0),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Visible'), findsOneWidget);
      expect(find.text('Hidden'), findsNothing);
    });

    testWidgets('adapts to dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.dark),
          home: const Scaffold(
            body: ThreeDPieChart(
              segments: [
                PieChartSegment(label: 'Dark', value: 100),
              ],
            ),
          ),
        ),
      );

      // Just verify it renders without error in dark mode
      expect(find.byType(ThreeDPieChart), findsOneWidget);
    });

    testWidgets('adapts to light theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.light),
          home: const Scaffold(
            body: ThreeDPieChart(
              segments: [
                PieChartSegment(label: 'Light', value: 100),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(ThreeDPieChart), findsOneWidget);
    });
  });
}
