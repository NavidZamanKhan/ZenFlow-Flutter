import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';

class AvatarPickerBottomSheet extends StatelessWidget {
  final bool hasExistingAvatar;
  final ValueChanged<String> onImageSelected;
  final VoidCallback onRemoveAvatar;

  const AvatarPickerBottomSheet({
    super.key,
    required this.hasExistingAvatar,
    required this.onImageSelected,
    required this.onRemoveAvatar,
  });

  static Future<void> show(
    BuildContext context, {
    required bool hasExistingAvatar,
    required ValueChanged<String> onImageSelected,
    required VoidCallback onRemoveAvatar,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => AvatarPickerBottomSheet(
        hasExistingAvatar: hasExistingAvatar,
        onImageSelected: onImageSelected,
        onRemoveAvatar: onRemoveAvatar,
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    Navigator.of(context).pop();
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked != null && picked.path.isNotEmpty) {
        HapticFeedback.mediumImpact();
        onImageSelected(picked.path);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: zen.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: zen.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Grab handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: zen.border,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 18),

          Text(
            'Profile Photo',
            style: AppTextStyles.headingLarge(zen.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose how you want to update your profile photo.',
            style: AppTextStyles.bodySmall(zen.textSecondary),
          ),
          const SizedBox(height: 20),

          // 1. Take Photo
          _ActionTile(
            icon: LucideIcons.camera,
            title: 'Take photo',
            subtitle: 'Capture a new picture with camera',
            onTap: () => _pickImage(context, ImageSource.camera),
          ),
          const SizedBox(height: 10),

          // 2. Choose from Gallery
          _ActionTile(
            icon: LucideIcons.image,
            title: 'Choose from gallery',
            subtitle: 'Select an existing photo from library',
            onTap: () => _pickImage(context, ImageSource.gallery),
          ),

          // 3. Remove Photo (if exists)
          if (hasExistingAvatar) ...[
            const SizedBox(height: 10),
            _ActionTile(
              icon: LucideIcons.trash_2,
              title: 'Remove photo',
              subtitle: 'Revert back to default initials',
              isDestructive: true,
              onTap: () {
                Navigator.of(context).pop();
                HapticFeedback.mediumImpact();
                onRemoveAvatar();
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;
    final color = isDestructive ? Colors.red.shade400 : zen.accent;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: zen.subtleFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDestructive
                ? Colors.red.withValues(alpha: 0.2)
                : zen.border.withValues(alpha: 0.8),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelLarge(
                      isDestructive ? Colors.red.shade400 : zen.textPrimary,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall(zen.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(LucideIcons.chevron_right, size: 16, color: zen.textMuted),
          ],
        ),
      ),
    );
  }
}
