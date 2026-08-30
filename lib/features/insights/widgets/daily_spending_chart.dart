import 'dart:math';

import 'package:flutter/material.dart';

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

    return ZenCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daily spending', style: AppTextStyles.headingSmall(zen.textPrimary)),
          const SizedBox(height: 2),
          Text(
            'Day by day activity this month',
            style: AppTextStyles.labelSmall(zen.textSecondary),
          ),
          const SizedBox(height: 16),

          // Spline Line Chart Canvas
          SizedBox(
            height: 140,
            width: double.infinity,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, _) => CustomPaint(
                painter: _SplineChartPainter(
                  points: widget.points,
                  progress: _animation.value,
                  lineColor: zen.accent,
                  fillColor: zen.accent,
                  gridColor: zen.border.withValues(alpha: 0.4),
                ),
              ),
            ),
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
}

class _SplineChartPainter extends CustomPainter {
  final List<DailySpendingPoint> points;
  final double progress;
  final Color lineColor;
  final Color fillColor;
  final Color gridColor;

  _SplineChartPainter({
    required this.points,
    required this.progress,
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
      final x = (size.width / (points.length - 1)) * i;
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
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, strokePaint);

    // Highlight Peak Point (e.g. Day 5)
    var peakIndex = 0;
    var peakVal = 0.0;
    for (int i = 0; i < points.length; i++) {
      if (points[i].amount > peakVal) {
        peakVal = points[i].amount;
        peakIndex = i;
      }
    }

    if (peakVal > 0 && peakIndex < offsets.length) {
      final peakOffset = offsets[peakIndex];
      // Outer halo
      canvas.drawCircle(
        peakOffset,
        6.5,
        Paint()..color = lineColor.withValues(alpha: 0.3),
      );
      // Inner dot
      canvas.drawCircle(
        peakOffset,
        3.5,
        Paint()..color = lineColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SplineChartPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.points != points;
}
