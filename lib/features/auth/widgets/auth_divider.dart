import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';

class AuthDivider extends StatelessWidget {
  final String text;

  const AuthDivider({
    super.key,
    this.text = 'or continue with',
  });

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return Row(
      children: [
        Expanded(
          child: Divider(color: zen.border),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            text,
            style: AppTextStyles.labelSmall(zen.textMuted),
          ),
        ),
        Expanded(
          child: Divider(color: zen.border),
        ),
      ],
    );
  }
}
