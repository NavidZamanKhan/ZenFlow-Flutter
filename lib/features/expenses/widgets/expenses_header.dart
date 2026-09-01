import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_icon_button.dart';
import '../../search/views/global_search_screen.dart';

class ExpensesHeader extends StatelessWidget {
  final VoidCallback onAddExpense;

  const ExpensesHeader({super.key, required this.onAddExpense});

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            'Expenses',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.displayLarge(zen.textPrimary),
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
                onAddExpense();
              },
            ),
          ],
        ),
      ],
    );
  }
}
