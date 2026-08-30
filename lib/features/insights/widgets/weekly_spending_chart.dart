import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_card.dart';

class WeeklySpendingChart extends StatefulWidget {
  final List<double> weeklyAmounts;

  const WeeklySpendingChart({super.key, required this.weeklyAmounts});

  @override
  State<WeeklySpendingChart> createState() => _WeeklySpendingChartState();
}

class _WeeklySpendingChartState extends State<WeeklySpendingChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
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
    final maxAmount = widget.weeklyAmounts.isEmpty
        ? 1000.0
        : widget.weeklyAmounts.reduce(max);
    final effectiveMax = maxAmount > 0 ? maxAmount : 1000.0;

    return ZenCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly spending', style: AppTextStyles.headingSmall(zen.textPrimary)),
          const SizedBox(height: 2),
          Text(
            'The last seven calendar days',
            style: AppTextStyles.labelSmall(zen.textSecondary),
          ),
          const SizedBox(height: 20),

          // 7 Day Bars
          SizedBox(
            height: 120,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (index) {
                    final amount = index < widget.weeklyAmounts.length
                        ? widget.weeklyAmounts[index]
                        : 0.0;
                    final heightFactor = (amount / effectiveMax) * _animation.value;
                    final isPeak = amount > 0 && amount == maxAmount;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Vertical Bar
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: 22,
                              height: max(4.0, 95.0 * heightFactor),
                              decoration: BoxDecoration(
                                color: isPeak ? zen.accent : zen.subtleFill,
                                borderRadius: BorderRadius.circular(6),
                                border: isPeak
                                    ? null
                                    : Border.all(color: zen.border),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Day Name
                        Text(
                          _days[index],
                          style: AppTextStyles.labelSmall(
                            isPeak ? zen.accent : zen.textMuted,
                          ).copyWith(
                            fontSize: 10.5,
                            fontWeight: isPeak ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
