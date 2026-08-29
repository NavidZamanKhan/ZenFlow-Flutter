import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_button.dart';
import '../../../core/widgets/zen_text_field.dart';

class SampleTaskBottomSheet extends StatelessWidget {
  const SampleTaskBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.zenColors.surface,
      builder: (ctx) => const SampleTaskBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'New Task',
                style: AppTextStyles.headingMedium(zen.textPrimary),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(LucideIcons.x, color: zen.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const ZenTextField(
            labelText: 'Title',
            hintText: 'e.g. Finalize Q3 roadmap',
          ),
          const SizedBox(height: 14),
          const ZenTextField(
            labelText: 'Description (optional)',
            hintText: 'Add details, links, or notes...',
            maxLines: 2,
          ),
          const SizedBox(height: 20),
          ZenButton(
            label: 'Create Task',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
