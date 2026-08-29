import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_card.dart';
import '../models/focus_task.dart';

class ProductivityCard extends StatelessWidget {
  final List<FocusTask> tasks;
  const ProductivityCard({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;
    final completed = tasks.where((task) => task.isComplete).length;
    final score = tasks.isEmpty ? 0 : (completed / tasks.length * 100).round();
    return ZenCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                color: Colors.green.shade500,
              ),
              const SizedBox(width: 4),
              Text(
                '$completed done',
                style: AppTextStyles.labelMedium(Colors.green.shade600),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            tasks.isEmpty
                ? 'Add a task to start tracking your rhythm.'
                : 'Completion across your current tasks.',
            style: AppTextStyles.bodySmall(zen.textMuted),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$score%', style: AppTextStyles.statNumber(zen.textPrimary)),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  'tasks completed',
                  style: AppTextStyles.labelSmall(zen.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 88,
            width: double.infinity,
            child: CustomPaint(
              painter: _WeeklyChartPainter(
                accent: zen.accent,
                grid: zen.border,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: 'MTWTFSS'
                .split('')
                .map(
                  (day) =>
                      Text(day, style: AppTextStyles.labelSmall(zen.textMuted)),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _WeeklyChartPainter extends CustomPainter {
  final Color accent;
  final Color grid;
  const _WeeklyChartPainter({required this.accent, required this.grid});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = grid.withValues(alpha: .7)
      ..strokeWidth = 1;
    for (var y = size.height * .15; y < size.height; y += size.height * .32) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    final points = [0.78, .63, .69, .40, .49, .23, .12]
        .asMap()
        .entries
        .map(
          (entry) =>
              Offset(entry.key * size.width / 6, entry.value * size.height),
        )
        .toList();
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];
      path.cubicTo(
        (previous.dx + current.dx) / 2,
        previous.dy,
        (previous.dx + current.dx) / 2,
        current.dy,
        current.dx,
        current.dy,
      );
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(points.last, 4, Paint()..color = accent);
    canvas.drawCircle(
      points.last,
      8,
      Paint()..color = accent.withValues(alpha: .16),
    );
  }

  @override
  bool shouldRepaint(covariant _WeeklyChartPainter old) =>
      old.accent != accent || old.grid != grid;
}
