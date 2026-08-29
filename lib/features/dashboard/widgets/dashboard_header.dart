import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_badge.dart';
import '../../../core/widgets/zen_icon_button.dart';
import '../../auth/models/user_model.dart';

class DashboardHeader extends StatelessWidget {
  final UserModel user;
  final int remainingTasks;

  const DashboardHeader({
    super.key,
    required this.user,
    required this.remainingTasks,
  });

  String get _firstName =>
      user.fullName.trim().split(' ').firstOrNull ?? 'there';

  String get _salutation {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    if (hour < 21) return 'Good evening';
    return 'Good night';
  }

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_salutation, $_firstName',
                style: AppTextStyles.bodySmall(zen.textSecondary),
              ),
              const SizedBox(height: 3),
              Text(
                'Today\'s focus',
                style: AppTextStyles.displayMedium(zen.textPrimary),
              ),
              const SizedBox(height: 10),
              ZenBadge(
                label:
                    '$remainingTasks ${remainingTasks == 1 ? 'task' : 'tasks'} to go',
                color: zen.accent,
                showDot: false,
                icon: LucideIcons.list_todo,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        ZenIconButton(icon: LucideIcons.bell, hasBadge: true, onTap: () {}),
      ],
    );
  }
}
