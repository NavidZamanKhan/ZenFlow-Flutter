import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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
  int? _selectedBarIndex;

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
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant WeeklySpendingChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.weeklyAmounts != widget.weeklyAmounts) {
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
    final maxAmount = widget.weeklyAmounts.isEmpty
        ? 1000.0
        : widget.weeklyAmounts.reduce(max);
    final effectiveMax = maxAmount > 0 ? maxAmount : 1000.0;

    final selectedAmount = _selectedBarIndex != null &&
            _selectedBarIndex! < widget.weeklyAmounts.length
        ? widget.weeklyAmounts[_selectedBarIndex!]
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
                    Text('Weekly spending',
                        style: AppTextStyles.headingSmall(zen.textPrimary)),
                    const SizedBox(height: 2),
                    Text(
                      'The last seven calendar days',
                      style: AppTextStyles.labelSmall(zen.textSecondary),
                    ),
                  ],
                ),
              ),
              if (selectedAmount != null)
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
                    '${_days[_selectedBarIndex!]} · ৳${NumberFormat('#,##0').format(selectedAmount)}',
                    style: AppTextStyles.labelSmall(zen.accent).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
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
                    final heightFactor =
                        (amount / effectiveMax) * _animation.value;
                    final isPeak = amount > 0 && amount == maxAmount;
                    final isSelected = _selectedBarIndex == index;

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedBarIndex =
                              _selectedBarIndex == index ? null : index;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Vertical Bar
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: isSelected ? 26 : 22,
                                height: max(4.0, 92.0 * heightFactor),
                                decoration: BoxDecoration(
                                  gradient: (isPeak || isSelected)
                                      ? LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            zen.accent,
                                            zen.accent.withValues(alpha: 0.8),
                                          ],
                                        )
                                      : null,
                                  color: (isPeak || isSelected)
                                      ? null
                                      : zen.subtleFill,
                                  borderRadius: BorderRadius.circular(7),
                                  border: (isPeak || isSelected)
                                      ? Border.all(
                                          color:
                                              zen.accent.withValues(alpha: 0.5),
                                          width: 1.5,
                                        )
                                      : Border.all(
                                          color:
                                              zen.border.withValues(alpha: 0.7),
                                        ),
                                  boxShadow: (isPeak || isSelected)
                                      ? [
                                          BoxShadow(
                                            color: zen.accent
                                                .withValues(alpha: 0.25),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Day Name
                          Text(
                            _days[index],
                            style: AppTextStyles.labelSmall(
                              (isPeak || isSelected)
                                  ? zen.accent
                                  : zen.textMuted,
                            ).copyWith(
                              fontSize: 10.5,
                              fontWeight: (isPeak || isSelected)
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
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
