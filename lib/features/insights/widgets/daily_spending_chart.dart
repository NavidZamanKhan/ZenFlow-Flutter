import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_card.dart';
import '../models/daily_spending_point.dart';

class DailySpendingChart extends StatefulWidget {
  final List<DailySpendingPoint> points;

  const DailySpendingChart({super.key, required this.points});

  @override
  State<DailySpendingChart> createState() => _DailySpendingChartState();
}

class _DailySpendingChartState extends State<DailySpendingChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    final selectedPoint =
        _hoveredIndex != null && _hoveredIndex! < widget.points.length
            ? widget.points[_hoveredIndex!]
            : null;

    return ZenCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Daily spending',
                        style: AppTextStyles.headingSmall(zen.textPrimary)),
                    const SizedBox(height: 2),
                    Text(
                      'Day by day activity this month',
                      style: AppTextStyles.labelSmall(zen.textSecondary),
                    ),
                  ],
                ),
              ),
              if (selectedPoint != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: zen.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: zen.accent.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    'Day ${selectedPoint.day} · ৳${NumberFormat('#,##0').format(selectedPoint.amount)}',
                    style: AppTextStyles.labelSmall(zen.accent).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Spline Line Chart Canvas with Touch Scrubber
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              const height = 130.0;

              return GestureDetector(
                onPanDown: (details) =>
                    _handleTouch(details.localPosition.dx, width),
                onPanUpdate: (details) =>
                    _handleTouch(details.localPosition.dx, width),
                onPanEnd: (_) => setState(() => _hoveredIndex = null),
                onPanCancel: () => setState(() => _hoveredIndex = null),
                onTapDown: (details) =>
                    _handleTouch(details.localPosition.dx, width),
                onTapUp: (_) => setState(() => _hoveredIndex = null),
                child: SizedBox(
                  height: height,
                  width: width,
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, _) => CustomPaint(
                      painter: _SplineChartPainter(
                        points: widget.points,
                        progress: _animation.value,
                        hoveredIndex: _hoveredIndex,
                        lineColor: zen.accent,
                        fillColor: zen.accent,
                        gridColor: zen.border.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),

          // Day markers row (1, 5, 10, 15, 20, 25, 31)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('1', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('5', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('10', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('15', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('20', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('25', style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('31', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  void _handleTouch(double localX, double totalWidth) {
    if (widget.points.isEmpty) return;
    final step = totalWidth / max(1, widget.points.length - 1);
    final index = (localX / step).round().clamp(0, widget.points.length - 1);
    if (_hoveredIndex != index) {
      HapticFeedback.selectionClick();
      setState(() => _hoveredIndex = index);
    }
  }
}

class _SplineChartPainter extends CustomPainter {
  final List<DailySpendingPoint> points;
  final double progress;
  final int? hoveredIndex;
  final Color lineColor;
  final Color fillColor;
  final Color gridColor;

  _SplineChartPainter({
    required this.points,
    required this.progress,
    required this.hoveredIndex,
    required this.lineColor,
    required this.fillColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    // Draw horizontal dashed grid lines
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.8;

    for (int i = 0; i <= 3; i++) {
      final y = size.height * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final maxAmount = points.map((p) => p.amount).reduce(max);
    final effectiveMax = maxAmount > 0 ? maxAmount * 1.15 : 1000.0;

    final offsets = <Offset>[];
    for (int i = 0; i < points.length; i++) {
      final x = (size.width / max(1, points.length - 1)) * i;
      final normalizedY = (points[i].amount / effectiveMax) * progress;
      final y = size.height - (normalizedY * size.height);
      offsets.add(Offset(x, y));
    }

    if (offsets.length < 2) return;

    // Build smooth cubic bezier path
    final path = Path()..moveTo(offsets[0].dx, offsets[0].dy);
    for (int i = 0; i < offsets.length - 1; i++) {
      final p0 = offsets[i];
      final p1 = offsets[i + 1];
      final midX = (p0.dx + p1.dx) / 2;
      path.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
    }

    // Draw Gradient Underfill
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          fillColor.withValues(alpha: 0.25),
          fillColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // Draw Line Stroke
    final strokePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, strokePaint);

    // Highlight Hovered or Peak Point
    final targetIndex = hoveredIndex ?? _getPeakIndex(points);
    if (targetIndex >= 0 && targetIndex < offsets.length) {
      final targetOffset = offsets[targetIndex];

      if (hoveredIndex != null) {
        // Vertical guide line
        canvas.drawLine(
          Offset(targetOffset.dx, 0),
          Offset(targetOffset.dx, size.height),
          Paint()
            ..color = lineColor.withValues(alpha: 0.3)
            ..strokeWidth = 1.2,
        );
      }

      // Outer halo
      canvas.drawCircle(
        targetOffset,
        hoveredIndex != null ? 8.0 : 6.5,
        Paint()..color = lineColor.withValues(alpha: 0.3),
      );
      // Inner dot
      canvas.drawCircle(
        targetOffset,
        3.5,
        Paint()..color = lineColor,
      );
      // White center
      canvas.drawCircle(
        targetOffset,
        1.5,
        Paint()..color = Colors.white,
      );
    }
  }

  int _getPeakIndex(List<DailySpendingPoint> pts) {
    var peakIndex = 0;
    var peakVal = 0.0;
    for (int i = 0; i < pts.length; i++) {
      if (pts[i].amount > peakVal) {
        peakVal = pts[i].amount;
        peakIndex = i;
      }
    }
    return peakIndex;
  }

  @override
  bool shouldRepaint(covariant _SplineChartPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.points != points ||
      oldDelegate.hoveredIndex != hoveredIndex;
}
