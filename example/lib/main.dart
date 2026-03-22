import 'package:flutter/material.dart';
import 'package:three_d_pie_chart/three_d_pie_chart.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '3D PieChart Demo',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: const Color(0xFF2962FF),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorSchemeSeed: const Color(0xFF2962FF),
        useMaterial3: true,
      ),
      home: DemoHomePage(
        themeMode: _themeMode,
        onThemeToggle: () {
          setState(() {
            _themeMode = _themeMode == ThemeMode.dark
                ? ThemeMode.light
                : ThemeMode.dark;
          });
        },
      ),
    );
  }
}

class DemoHomePage extends StatelessWidget {
  final ThemeMode themeMode;
  final VoidCallback onThemeToggle;

  const DemoHomePage({
    super.key,
    required this.themeMode,
    required this.onThemeToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('3D PieChart Examples'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle theme',
            onPressed: onThemeToggle,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _SectionTitle('1. Basic — Market Cap Allocation'),
          _BasicExample(),
          SizedBox(height: 40),
          _SectionTitle('2. Custom Colors & Style'),
          _CustomColorsExample(),
          SizedBox(height: 40),
          _SectionTitle('3. Legend Position — Right'),
          _LegendRightExample(),
          SizedBox(height: 40),
          _SectionTitle('4. Legend Position — Top'),
          _LegendTopExample(),
          SizedBox(height: 40),
          _SectionTitle('5. No Legend / No Indicator'),
          _MinimalExample(),
          SizedBox(height: 40),
          _SectionTitle('6. Many Segments (12)'),
          _ManySegmentsExample(),
          SizedBox(height: 40),
          _SectionTitle('7. Single Segment'),
          _SingleSegmentExample(),
          SizedBox(height: 40),
          _SectionTitle('8. Show Zero-Value Segments'),
          _ZeroValueExample(),
          SizedBox(height: 40),
          _SectionTitle('9. Custom Value Formatter'),
          _FormatterExample(),
          SizedBox(height: 40),
          _SectionTitle('10. Heavy Glow & Shadow'),
          _HeavyEffectsExample(),
          SizedBox(height: 40),
          _SectionTitle('11. Flat Style (No Glow, No Shadow)'),
          _FlatExample(),
          SizedBox(height: 40),
          _SectionTitle('12. Callback Demo'),
          _CallbackExample(),
          SizedBox(height: 60),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Section helpers
// ═════════════════════════════════════════════════════════════════════════════

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _DemoCard extends StatelessWidget {
  final Widget child;
  const _DemoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 1. Basic example (mirrors the original MarketCapSection)
// ═════════════════════════════════════════════════════════════════════════════

class _BasicExample extends StatelessWidget {
  const _BasicExample();

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: ThreeDPieChart(
        segments: const [
          PieChartSegment(
            label: 'Large Cap',
            value: 65,
            color: Color(0xFF2962FF),
          ),
          PieChartSegment(
            label: 'Mid Cap',
            value: 25,
            color: Color(0xFF1939B7),
          ),
          PieChartSegment(
            label: 'Small Cap',
            value: 10,
            color: Color(0xFF00E5FF),
          ),
        ],
        title: Text(
          'Market cap allocation',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black87,
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 2. Custom colours & thicker ring
// ═════════════════════════════════════════════════════════════════════════════

class _CustomColorsExample extends StatelessWidget {
  const _CustomColorsExample();

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: ThreeDPieChart(
        segments: const [
          PieChartSegment(label: 'Equities', value: 50, color: Color(0xFFFF6D00)),
          PieChartSegment(label: 'Bonds', value: 30, color: Color(0xFF00BFA5)),
          PieChartSegment(label: 'Real Estate', value: 12, color: Color(0xFFAA00FF)),
          PieChartSegment(label: 'Cash', value: 8, color: Color(0xFFFFD600)),
        ],
        style: const ThreeDPieChartStyle(
          strokeWidth: 14,
          gapDegrees: 8,
          tiltFactor: 0.55,
          indicatorLineHeight: 60,
          legendIndicatorShape: LegendIndicatorShape.circle,
          legendIndicatorSize: 10,
        ),
        title: Text(
          'Portfolio allocation',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black87,
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 3. Legend on the right
// ═════════════════════════════════════════════════════════════════════════════

class _LegendRightExample extends StatelessWidget {
  const _LegendRightExample();

  @override
  Widget build(BuildContext context) {
    return const _DemoCard(
      child: ThreeDPieChart(
        segments: [
          PieChartSegment(label: 'Technology', value: 40),
          PieChartSegment(label: 'Healthcare', value: 25),
          PieChartSegment(label: 'Finance', value: 20),
          PieChartSegment(label: 'Energy', value: 15),
        ],
        style: ThreeDPieChartStyle(
          legendPosition: LegendPosition.right,
          legendSpacing: 16,
        ),
        chartHeight: 240,
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 4. Legend on top
// ═════════════════════════════════════════════════════════════════════════════

class _LegendTopExample extends StatelessWidget {
  const _LegendTopExample();

  @override
  Widget build(BuildContext context) {
    return const _DemoCard(
      child: ThreeDPieChart(
        segments: [
          PieChartSegment(label: 'USA', value: 55, color: Color(0xFF304FFE)),
          PieChartSegment(label: 'Europe', value: 25, color: Color(0xFF00B8D4)),
          PieChartSegment(label: 'Asia', value: 20, color: Color(0xFF1DE9B6)),
        ],
        style: ThreeDPieChartStyle(
          legendPosition: LegendPosition.top,
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 5. Minimal — no legend, no indicator
// ═════════════════════════════════════════════════════════════════════════════

class _MinimalExample extends StatelessWidget {
  const _MinimalExample();

  @override
  Widget build(BuildContext context) {
    return const _DemoCard(
      child: ThreeDPieChart(
        segments: [
          PieChartSegment(label: 'A', value: 60),
          PieChartSegment(label: 'B', value: 30),
          PieChartSegment(label: 'C', value: 10),
        ],
        style: ThreeDPieChartStyle(
          legendPosition: LegendPosition.none,
          showIndicator: false,
        ),
        chartHeight: 200,
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 6. Many segments (12)
// ═════════════════════════════════════════════════════════════════════════════

class _ManySegmentsExample extends StatelessWidget {
  const _ManySegmentsExample();

  @override
  Widget build(BuildContext context) {
    return const _DemoCard(
      child: ThreeDPieChart(
        segments: [
          PieChartSegment(label: 'Technology', value: 18),
          PieChartSegment(label: 'Healthcare', value: 14),
          PieChartSegment(label: 'Finance', value: 12),
          PieChartSegment(label: 'Consumer', value: 10),
          PieChartSegment(label: 'Energy', value: 9),
          PieChartSegment(label: 'Industrial', value: 8),
          PieChartSegment(label: 'Materials', value: 7),
          PieChartSegment(label: 'Utilities', value: 6),
          PieChartSegment(label: 'Real Estate', value: 5),
          PieChartSegment(label: 'Telecom', value: 4),
          PieChartSegment(label: 'Staples', value: 4),
          PieChartSegment(label: 'Other', value: 3),
        ],
        style: ThreeDPieChartStyle(
          gapDegrees: 4,
          strokeWidth: 8,
          legendItemVerticalPadding: 6,
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 7. Single segment
// ═════════════════════════════════════════════════════════════════════════════

class _SingleSegmentExample extends StatelessWidget {
  const _SingleSegmentExample();

  @override
  Widget build(BuildContext context) {
    return const _DemoCard(
      child: ThreeDPieChart(
        segments: [
          PieChartSegment(label: 'Large Cap', value: 100, color: Color(0xFF2962FF)),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 8. Show zero-value segments in legend
// ═════════════════════════════════════════════════════════════════════════════

class _ZeroValueExample extends StatelessWidget {
  const _ZeroValueExample();

  @override
  Widget build(BuildContext context) {
    return const _DemoCard(
      child: ThreeDPieChart(
        segments: [
          PieChartSegment(label: 'Large Cap', value: 70, color: Color(0xFF2962FF)),
          PieChartSegment(label: 'Mid Cap', value: 30, color: Color(0xFF1939B7)),
          PieChartSegment(label: 'Small Cap', value: 0, color: Color(0xFF00E5FF)),
          PieChartSegment(label: 'Micro Cap', value: 0, color: Color(0xFF00BFA5)),
        ],
        style: ThreeDPieChartStyle(
          showZeroValueSegments: true,
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 9. Custom value formatter (dollars instead of %)
// ═════════════════════════════════════════════════════════════════════════════

class _FormatterExample extends StatelessWidget {
  const _FormatterExample();

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: ThreeDPieChart(
        segments: const [
          PieChartSegment(label: 'Stocks', value: 45000),
          PieChartSegment(label: 'Bonds', value: 30000),
          PieChartSegment(label: 'Crypto', value: 15000),
          PieChartSegment(label: 'Cash', value: 10000),
        ],
        style: ThreeDPieChartStyle(
          legendValueFormatter: (value, total) {
            final k = value / 1000;
            return '\$${k.toStringAsFixed(0)}K';
          },
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 10. Heavy glow & shadow
// ═════════════════════════════════════════════════════════════════════════════

class _HeavyEffectsExample extends StatelessWidget {
  const _HeavyEffectsExample();

  @override
  Widget build(BuildContext context) {
    return const _DemoCard(
      child: ThreeDPieChart(
        segments: [
          PieChartSegment(label: 'Alpha', value: 55, color: Color(0xFFF50057)),
          PieChartSegment(label: 'Beta', value: 30, color: Color(0xFF651FFF)),
          PieChartSegment(label: 'Gamma', value: 15, color: Color(0xFF00E5FF)),
        ],
        style: ThreeDPieChartStyle(
          strokeWidth: 12,
          shadowStyle: PieChartShadowStyle(
            offsetY: 16,
            blurRadius: 8,
            opacity: 0.35,
          ),
          glowStyle: PieChartGlowStyle(
            outerSpread: 36,
            innerSpread: 14,
            outerBlur: 28,
            innerBlur: 12,
            opacity: 0.04,
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 11. Flat style — no glow, no shadow
// ═════════════════════════════════════════════════════════════════════════════

class _FlatExample extends StatelessWidget {
  const _FlatExample();

  @override
  Widget build(BuildContext context) {
    return const _DemoCard(
      child: ThreeDPieChart(
        segments: [
          PieChartSegment(label: 'React', value: 40, color: Color(0xFF61DAFB)),
          PieChartSegment(label: 'Flutter', value: 35, color: Color(0xFF02569B)),
          PieChartSegment(label: 'SwiftUI', value: 25, color: Color(0xFFFF6D00)),
        ],
        style: ThreeDPieChartStyle(
          shadowStyle: PieChartShadowStyle.none,
          glowStyle: PieChartGlowStyle.none,
          tiltFactor: 0.48,
          gapDegrees: 16,
          strokeWidth: 16,
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 12. Callback demo
// ═════════════════════════════════════════════════════════════════════════════

class _CallbackExample extends StatefulWidget {
  const _CallbackExample();

  @override
  State<_CallbackExample> createState() => _CallbackExampleState();
}

class _CallbackExampleState extends State<_CallbackExample> {
  String _selectedLabel = 'Tap a segment';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _DemoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Selected: $_selectedLabel',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ThreeDPieChart(
            segments: const [
              PieChartSegment(label: 'Growth', value: 45, color: Color(0xFF00C853)),
              PieChartSegment(label: 'Value', value: 35, color: Color(0xFF2962FF)),
              PieChartSegment(label: 'Dividend', value: 20, color: Color(0xFFFF6D00)),
            ],
            onSegmentSelected: (index, segment) {
              setState(() {
                _selectedLabel =
                    '${segment.label} — ${segment.value.toStringAsFixed(0)}%';
              });
            },
          ),
        ],
      ),
    );
  }
}
