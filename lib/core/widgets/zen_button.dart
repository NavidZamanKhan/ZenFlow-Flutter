import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';
import '../theme/zenflow_theme.dart';

enum ZenButtonVariant { primary, outlined, subtle, danger }

class ZenButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ZenButtonVariant variant;
  final bool isLoading;
  final double height;
  final double? width;

  const ZenButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = ZenButtonVariant.primary,
    this.isLoading = false,
    this.height = 48,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    Color bg;
    Color fg;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case ZenButtonVariant.primary:
        bg = zen.accent;
        fg = Colors.white;
        break;
      case ZenButtonVariant.outlined:
        bg = Colors.transparent;
        fg = zen.textPrimary;
        borderSide = BorderSide(color: zen.border, width: 1);
        break;
      case ZenButtonVariant.subtle:
        bg = zen.isDark ? zen.accentSoft : zen.accentLightBg;
        fg = zen.accent;
        borderSide = BorderSide(
          color: zen.isDark ? zen.border : zen.accentLightBorder,
          width: 1,
        );
        break;
      case ZenButtonVariant.danger:
        bg = Colors.transparent;
        fg = Theme.of(context).colorScheme.error;
        borderSide = BorderSide(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
          width: 1,
        );
        break;
    }

    final content = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: AppTextStyles.labelLarge(fg),
              ),
            ],
          );

    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
            side: borderSide,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: content,
      ),
    );
  }
}
