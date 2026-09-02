import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../theme/app_text_styles.dart';
import '../theme/zenflow_theme.dart';

class ZenAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String initials;
  final double size;
  final VoidCallback? onTap;
  final bool showCameraBadge;
  final bool isLoading;

  const ZenAvatar({
    super.key,
    this.avatarUrl,
    required this.initials,
    this.size = 40,
    this.onTap,
    this.showCameraBadge = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;
    final fontSize = size * 0.40;
    final hasImage = avatarUrl != null && avatarUrl!.trim().isNotEmpty;

    Widget avatarContent;

    if (hasImage) {
      avatarContent = CachedNetworkImage(
        imageUrl: avatarUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, _) => Container(
          color: zen.accentSoft,
          child: Center(
            child: SizedBox(
              width: size * 0.4,
              height: size * 0.4,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(zen.accent),
              ),
            ),
          ),
        ),
        errorWidget: (_, _, _) => _buildInitials(zen, fontSize),
      );
    } else {
      avatarContent = _buildInitials(zen, fontSize);
    }

    Widget content = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: zen.accent,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: zen.accent.withValues(alpha: 0.25),
            blurRadius: size * 0.2,
            offset: Offset(0, size * 0.05),
          ),
        ],
      ),
      child: ClipOval(
        child: Stack(
          fit: StackFit.expand,
          children: [
            avatarContent,
            if (isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.45),
                child: Center(
                  child: SizedBox(
                    width: size * 0.4,
                    height: size * 0.4,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (showCameraBadge) {
      final badgeSize = (size * 0.36).clamp(20.0, 32.0);
      content = Stack(
        clipBehavior: Clip.none,
        children: [
          content,
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                color: zen.card,
                shape: BoxShape.circle,
                border: Border.all(color: zen.border, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  LucideIcons.camera,
                  size: badgeSize * 0.55,
                  color: zen.accent,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }

  Widget _buildInitials(dynamic zen, double fontSize) {
    return Container(
      color: zen.accent,
      child: Center(
        child: Text(
          initials,
          style: AppTextStyles.labelMedium(Colors.white).copyWith(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
