import 'package:flutter/material.dart';

import '../theme/zenflow_theme.dart';

class ZenIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color? iconColor;
  final bool hasBadge;

  const ZenIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 40,
    this.iconColor,
    this.hasBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: zen.surface,
          shape: BoxShape.circle,
          border: Border.all(color: zen.border),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              icon,
              size: size * 0.45,
              color: iconColor ?? zen.textPrimary,
            ),
            if (hasBadge)
              Positioned(
                top: size * 0.2,
                right: size * 0.2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
