import 'package:flutter/material.dart';
import '../theme/zenflow_theme.dart';

class ZenCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? customBgColor;
  final Color? customBorderColor;
  final double borderRadius;

  const ZenCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin,
    this.onTap,
    this.customBgColor,
    this.customBorderColor,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    final container = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: customBgColor ?? zen.card,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: customBorderColor ?? zen.border,
          width: 1,
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: container,
      );
    }

    return container;
  }
}
