import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_card.dart';
import '../models/focus_task.dart';

class ProductivityCard extends StatefulWidget {
  final List<FocusTask> tasks;

  const ProductivityCard({super.key, required this.tasks});

  @override
  State<ProductivityCard> createState() => _ProductivityCardState();
}

class _ProductivityCardState extends State<ProductivityCard> {
  int? _hoveredIndex;

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _fullDayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;
    final now = DateTime.now();
    final todayIndex = (now.weekday - 1).clamp(0, 6);

    final stats = _calculateWeeklyStats(widget.tasks, now);
    final activeIndex = _hoveredIndex ?? todayIndex;
    final activeCount = stats.dailyCompleted[activeIndex];
    final activeDayName = _fullDayNames[activeIndex];

    return ZenCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Icon(
                LucideIcons.chart_no_axes_combined,
                size: 18,
                color: zen.accent,
              ),
              const SizedBox(width: 8),
              Text(
                'Productivity',
                style: AppTextStyles.headingSmall(zen.textPrimary),
              ),
              const Spacer(),
              Icon(
                LucideIcons.trending_up,
                size: 16,
                color: AppColors.success,
              ),
              const SizedBox(width: 4),
              Text(
                '${stats.completedThisWeek} done',
                style: AppTextStyles.labelMedium(AppColors.success).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),

          // Subtitle
          Text(
            '${stats.weekLabel} · ${stats.subtitle}',
            style: AppTextStyles.bodySmall(zen.textMuted),
          ),
          const SizedBox(height: 14),

          // Stat Number + Context
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${stats.score}%',
                style: AppTextStyles.statNumber(zen.textPrimary),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  'tasks completed',
                  style: AppTextStyles.labelSmall(zen.textMuted),
                ),
              ),
              const Spacer(),

              // Interactive Scrubber Indicator Tooltip
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: _hoveredIndex != null
                      ? zen.accent.withValues(alpha: 0.14)
                      : zen.subtleFill,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: _hoveredIndex != null
                        ? zen.accent.withValues(alpha: 0.4)
                        : zen.border.withValues(alpha: 0.6),
                  ),
                ),
                child: Text(
                  '$activeDayName · $activeCount done',
                  style: AppTextStyles.labelSmall(
                    _hoveredIndex != null ? zen.accent : zen.textSecondary,
                  ).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Interactive Responsive Graph Area
          LayoutBuilder(
            builder: (context, constraints) {
              final chartWidth = constraints.maxWidth;
              const chartHeight = 110.0;

              return GestureDetector(
                onPanDown: (details) =>
                    _handleTouch(details.localPosition.dx, chartWidth),
                onPanUpdate: (details) =>
                    _handleTouch(details.localPosition.dx, chartWidth),
                onPanEnd: (_) => setState(() => _hoveredIndex = null),
                onPanCancel: () => setState(() => _hoveredIndex = null),
                onTapDown: (details) =>
                    _handleTouch(details.localPosition.dx, chartWidth),
                onTapUp: (_) => setState(() => _hoveredIndex = null),
                child: SizedBox(
                  height: chartHeight,
                  width: chartWidth,
                  child: CustomPaint(
                    painter: _DynamicWeeklyChartPainter(
                      dailyCounts: stats.dailyCompleted,
                      todayIndex: todayIndex,
                      hoveredIndex: _hoveredIndex,
                      accent: zen.accent,
                      gridColor: zen.border,
                      isDark: zen.isDark,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),

          // Days Row (M T W T F S S)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final isToday = index == todayIndex;
              final isHovered = index == _hoveredIndex;

              return Expanded(
                child: Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 140),
                    style: AppTextStyles.labelSmall(
                      isHovered
                          ? zen.accent
                          : (isToday ? zen.textPrimary : zen.textMuted),
                    ).copyWith(
                      fontWeight: (isToday || isHovered)
                          ? FontWeight.w700
                          : FontWeight.w500,
                      fontSize: 11,
                    ),
                    child: Text(_dayLabels[index]),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _handleTouch(double localX, double totalWidth) {
    final index = ((localX / totalWidth) * 6.5).round().clamp(0, 6);
    if (_hoveredIndex != index) {
      HapticFeedback.selectionClick();
      setState(() => _hoveredIndex = index);
    }
  }

  _WeeklyProductivityStats _calculateWeeklyStats(
    List<FocusTask> tasks,
    DateTime now,
  ) {
    final weekday = now.weekday; // 1 = Monday, 7 = Sunday
    final monday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: weekday - 1));
    final nextMonday = monday.add(const Duration(days: 7));

    final dailyCounts = List<int>.filled(7, 0);
    int completedThisWeek = 0;
    int dueThisWeek = 0;
    int dueCompleted = 0;

    for (final task in tasks) {
      if (task.dueDate != null) {
        final due = DateTime(
          task.dueDate!.year,
          task.dueDate!.month,
          task.dueDate!.day,
        );
        if ((due.isAtSameMomentAs(monday) || due.isAfter(monday)) &&
            due.isBefore(nextMonday)) {
          dueThisWeek++;
          final dayIndex = (due.weekday - 1).clamp(0, 6);
          if (task.isComplete) {
            dueCompleted++;
            dailyCounts[dayIndex]++;
          }
        }
      } else if (task.isComplete) {
        final todayIdx = (now.weekday - 1).clamp(0, 6);
        dailyCounts[todayIdx]++;
        completedThisWeek++;
      }
    }

    completedThisWeek += dueCompleted;

    int score = 0;
    if (dueThisWeek > 0) {
      score = ((dueCompleted / dueThisWeek) * 100).round();
    } else if (tasks.isNotEmpty) {
      final totalCompleted = tasks.where((t) => t.isComplete).length;
      score = ((totalCompleted / tasks.length) * 100).round();
    }

    final weekMonthStr = DateFormat('MMM d').format(monday);
    final subtitle = dueThisWeek > 0
        ? '$dueCompleted/$dueThisWeek due this week completed'
        : completedThisWeek > 0
            ? '$completedThisWeek completed this week'
            : 'Complete tasks due this week to score';

    return _WeeklyProductivityStats(
      score: score,
      completedThisWeek: completedThisWeek,
      dueThisWeek: dueThisWeek,
      dueCompleted: dueCompleted,
      dailyCompleted: dailyCounts,
      weekLabel: 'Week of $weekMonthStr',
      subtitle: subtitle,
    );
  }
}

class _WeeklyProductivityStats {
  final int score;
  final int completedThisWeek;
  final int dueThisWeek;
  final int dueCompleted;
  final List<int> dailyCompleted;
  final String weekLabel;
  final String subtitle;

  const _WeeklyProductivityStats({
    required this.score,
    required this.completedThisWeek,
    required this.dueThisWeek,
    required this.dueCompleted,
    required this.dailyCompleted,
    required this.weekLabel,
    required this.subtitle,
  });
}

class _DynamicWeeklyChartPainter extends CustomPainter {
  final List<int> dailyCounts;
  final int todayIndex;
  final int? hoveredIndex;
  final Color accent;
  final Color gridColor;
  final bool isDark;

  const _DynamicWeeklyChartPainter({
    required this.dailyCounts,
    required this.todayIndex,
    required this.hoveredIndex,
    required this.accent,
    required this.gridColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 12.0;
    final rightPad = size.width - 12.0;
    final availableWidth = rightPad - leftPad;
    const topPad = 12.0;
    final bottomPad = size.height - 14.0;
    final availableHeight = bottomPad - topPad;

    // 1. Draw Subtle Dashed Guidelines
    final gridPaint = Paint()
      ..color = gridColor.withValues(alpha: isDark ? 0.35 : 0.65)
      ..strokeWidth = 1.0;

    for (int i = 1; i <= 3; i++) {
      final y = topPad + (availableHeight * (i / 4));
      _drawDashedLine(
        canvas,
        Offset(leftPad, y),
        Offset(rightPad, y),
        gridPaint,
      );
    }

    // 2. Compute Responsive Normalized Points
    final maxVal = (dailyCounts.isNotEmpty
            ? dailyCounts.reduce((a, b) => a > b ? a : b)
            : 0)
        .clamp(1, 100);

    final points = <Offset>[];
    for (int i = 0; i < 7; i++) {
      final x = leftPad + (i * (availableWidth / 6));
      final count = i < dailyCounts.length ? dailyCounts[i] : 0;
      final ratio = count / maxVal;
      // Map ratio to vertical canvas bounds
      final y = bottomPad - (ratio * availableHeight * 0.85);
      points.add(Offset(x, y));
    }

    if (points.isEmpty) return;

    // 3. Build Smooth Cubic Bezier Path
    final linePath = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final cpX = (p0.dx + p1.dx) / 2;
      linePath.cubicTo(cpX, p0.dy, cpX, p1.dy, p1.dx, p1.dy);
    }

    // 4. Draw Soft Gradient Area Fill under the Curve
    final areaPath = Path.from(linePath)
      ..lineTo(points.last.dx, bottomPad + 8)
      ..lineTo(points.first.dx, bottomPad + 8)
      ..close();

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          accent.withValues(alpha: isDark ? 0.26 : 0.18),
          accent.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, topPad, size.width, availableHeight + 12));

    canvas.drawPath(areaPath, gradientPaint);

    // 5. Draw Glowing Line Stroke
    final linePaint = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(linePath, linePaint);

    // 6. Draw Active / Hovered Indicator Point
    final highlightIndex = hoveredIndex ?? todayIndex;
    if (highlightIndex >= 0 && highlightIndex < points.length) {
      final p = points[highlightIndex];

      // Vertical guide beam when scrubbing
      if (hoveredIndex != null) {
        final beamPaint = Paint()
          ..color = accent.withValues(alpha: 0.25)
          ..strokeWidth = 1.5;
        _drawDashedLine(
          canvas,
          Offset(p.dx, topPad),
          Offset(p.dx, bottomPad),
          beamPaint,
        );
      }

      // Outer Pulsing Glow Circle
      final outerGlow = Paint()
        ..color = accent.withValues(alpha: isDark ? 0.35 : 0.22);
      canvas.drawCircle(p, hoveredIndex != null ? 10 : 8, outerGlow);

      // Inner Solid Accent Circle
      final innerDot = Paint()..color = accent;
      canvas.drawCircle(p, 4.5, innerDot);

      // Crisp White Center Core
      final coreDot = Paint()..color = Colors.white;
      canvas.drawCircle(p, 2.0, coreDot);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashWidth = 3.5;
    const dashSpace = 3.5;
    double currentX = p1.dx;

    while (currentX < p2.dx) {
      canvas.drawLine(
        Offset(currentX, p1.dy),
        Offset((currentX + dashWidth).clamp(p1.dx, p2.dx), p1.dy),
        paint,
      );
      currentX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DynamicWeeklyChartPainter old) =>
      old.dailyCounts != dailyCounts ||
      old.todayIndex != todayIndex ||
      old.hoveredIndex != hoveredIndex ||
      old.accent != accent ||
      old.gridColor != gridColor ||
      old.isDark != isDark;
}
