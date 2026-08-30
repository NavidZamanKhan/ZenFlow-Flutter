import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';

class InsightsHeader extends StatelessWidget {
  const InsightsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return Text(
      'Insights',
      style: AppTextStyles.displayLarge(zen.textPrimary),
    );
  }
}
