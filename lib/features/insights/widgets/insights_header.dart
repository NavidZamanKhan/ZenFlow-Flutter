import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_icon_button.dart';
import '../../search/views/global_search_screen.dart';

class InsightsHeader extends StatelessWidget {
  const InsightsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            'Insights',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.displayLarge(zen.textPrimary),
          ),
        ),
        ZenIconButton(
          icon: LucideIcons.search,
          size: 40,
          onTap: () => GlobalSearchScreen.show(context),
        ),
      ],
    );
  }
}
