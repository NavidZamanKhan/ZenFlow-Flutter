import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';

class ZenBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool showDot;
  final IconData? icon;

  const ZenBadge({
    super.key,
    required this.label,
    required this.color,
    this.showDot = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ] else if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: AppTextStyles.labelSmall(color),
          ),
        ],
      ),
    );
  }
}
