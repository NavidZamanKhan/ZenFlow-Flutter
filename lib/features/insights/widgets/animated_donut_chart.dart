import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/services/currency_service.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_card.dart';
import '../models/chart_segment.dart';

class AnimatedDonutChart extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<ChartSegment> segments;
  final String currency;

  const AnimatedDonutChart({
    super.key,
    required this.title,
    required this.subtitle,
    required this.segments,
    this.currency = 'BDT',
  });

  @override
  State<AnimatedDonutChart> createState() => _AnimatedDonutChartState();
}

class _AnimatedDonutChartState extends State<AnimatedDonutChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int? _selectedIndex;

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
  void didUpdateWidget(covariant AnimatedDonutChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.segments != widget.segments) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;
    final totalAmount =
        widget.segments.fold<double>(0.0, (sum, seg) => sum + seg.amount);

    final selectedSegment =
        _selectedIndex != null && _selectedIndex! < widget.segments.length
            ? widget.segments[_selectedIndex!]
            : null;

    final centerValueStr = selectedSegment != null
        ? CurrencyService().formatMoney(
            amount: selectedSegment.amount,
            currency: widget.currency,
          )
        : CurrencyService().formatMoney(
            amount: totalAmount,
            currency: widget.currency,
          );

    final centerLabelStr =
        selectedSegment != null ? selectedSegment.label : 'Total';

    return ZenCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: AppTextStyles.headingSmall(zen.textPrimary)),
          const SizedBox(height: 2),
          Text(widget.subtitle,
              style: AppTextStyles.labelSmall(zen.textSecondary)),
          const SizedBox(height: 20),

          // Donut Ring + Side Legend Row
          Row(
            children: [
              // Custom Donut Canvas with Center Hole Summary
              SizedBox(
                width: 140,
                height: 140,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, _) => CustomPaint(
                        size: const Size(140, 140),
                        painter: _DonutPainter(
                          segments: widget.segments,
                          progress: _animation.value,
                          selectedIndex: _selectedIndex,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          centerValueStr,
                          style: AppTextStyles.labelLarge(zen.textPrimary)
                              .copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          centerLabelStr,
                          style: AppTextStyles.labelSmall(zen.textMuted)
                              .copyWith(fontSize: 10.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),

              // Legend
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(widget.segments.length, (index) {
                    final seg = widget.segments[index];
                    final isSelected = _selectedIndex == index;

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedIndex =
                              _selectedIndex == index ? null : index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? zen.subtleFill
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 9,
                              height: 9,
                              decoration: BoxDecoration(
                                color: seg.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                seg.label,
                                style: AppTextStyles.bodyMedium(
                                  isSelected
                                      ? zen.textPrimary
                                      : zen.textSecondary,
                                ).copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  fontSize: 12.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${seg.percentage.toStringAsFixed(1)}%',
                              style: AppTextStyles.labelMedium(
                                isSelected ? zen.accent : zen.textMuted,
                              ).copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
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
  final int? selectedIndex;

  _DonutPainter({
    required this.segments,
    required this.progress,
    this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (segments.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) / 2) - 14;
    const strokeWidth = 18.0;
    const gapAngle = 0.045; // small gap between arcs in radians

    double startAngle = -pi / 2;

    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final isSelected = selectedIndex == i;
      final sweepAngle = (2 * pi * (segment.percentage / 100)) * progress;
      final effectiveSweep = max(0.0, sweepAngle - gapAngle);

      final paint = Paint()
        ..color = isSelected
            ? segment.color
            : (selectedIndex != null
                ? segment.color.withValues(alpha: 0.35)
                : segment.color)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? strokeWidth + 4 : strokeWidth
        ..strokeCap = StrokeCap.round;

      if (effectiveSweep > 0) {
        canvas.drawArc(
          Rect.fromCircle(
            center: center,
            radius: isSelected ? radius + 1.5 : radius,
          ),
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
      oldDelegate.progress != progress ||
      oldDelegate.segments != segments ||
      oldDelegate.selectedIndex != selectedIndex;
}
