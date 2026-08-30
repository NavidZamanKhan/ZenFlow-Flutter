import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_card.dart';
import '../models/chart_segment.dart';

class AnimatedDonutChart extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<ChartSegment> segments;

  const AnimatedDonutChart({
    super.key,
    required this.title,
    required this.subtitle,
    required this.segments,
  });

  @override
  State<AnimatedDonutChart> createState() => _AnimatedDonutChartState();
}

class _AnimatedDonutChartState extends State<AnimatedDonutChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
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
          Text(widget.title, style: AppTextStyles.headingSmall(zen.textPrimary)),
          const SizedBox(height: 2),
          Text(widget.subtitle, style: AppTextStyles.labelSmall(zen.textSecondary)),
          const SizedBox(height: 20),

          // Donut Ring + Side Legend Row
          Row(
            children: [
              // Custom Donut Canvas
              SizedBox(
                width: 140,
                height: 140,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, _) => CustomPaint(
                    painter: _DonutPainter(
                      segments: widget.segments,
                      progress: _animation.value,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Legend
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.segments.map((seg) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: seg.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              seg.label,
                              style: AppTextStyles.bodyMedium(zen.textPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${seg.percentage.toStringAsFixed(1)}%',
                            style: AppTextStyles.labelMedium(zen.textSecondary).copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<ChartSegment> segments;
  final double progress;

  _DonutPainter({required this.segments, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (segments.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) / 2) - 14;
    const strokeWidth = 20.0;
    const gapAngle = 0.04; // small gap between arcs in radians

    double startAngle = -pi / 2;

    for (final segment in segments) {
      final sweepAngle = (2 * pi * (segment.percentage / 100)) * progress;
      final effectiveSweep = max(0.0, sweepAngle - gapAngle);

      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      if (effectiveSweep > 0) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          effectiveSweep,
          false,
          paint,
        );
      }

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.segments != segments;
}
