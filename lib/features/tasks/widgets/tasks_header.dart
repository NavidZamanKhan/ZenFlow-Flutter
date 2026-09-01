import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_badge.dart';
import '../../../core/widgets/zen_icon_button.dart';
import '../../search/views/global_search_screen.dart';

class TasksHeader extends StatelessWidget {
  final int pendingCount;
  final VoidCallback onNewTaskPressed;

  const TasksHeader({
    super.key,
    required this.pendingCount,
    required this.onNewTaskPressed,
  });

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            children: [
              Text(
                'Tasks',
                style: AppTextStyles.displayLarge(zen.textPrimary),
              ),
              const SizedBox(width: 10),
              ZenBadge(
                label: '$pendingCount left',
                color: zen.accent,
                showDot: false,
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ZenIconButton(
              icon: LucideIcons.search,
              size: 40,
              onTap: () => GlobalSearchScreen.show(context),
            ),
            const SizedBox(width: 8),
            ZenIconButton(
              icon: LucideIcons.plus,
              size: 40,
              backgroundColor: zen.accent,
              iconColor: Colors.white,
              onTap: () {
                HapticFeedback.lightImpact();
                onNewTaskPressed();
              },
            ),
          ],
        ),
      ],
    );
  }
}
