import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_button.dart';
import '../../../core/widgets/zen_text_field.dart';
import '../../auth/repositories/auth_repository.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';

class SetPasswordBottomSheet extends StatefulWidget {
  const SetPasswordBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<ProfileBloc>(),
        child: const SetPasswordBottomSheet(),
      ),
    );
  }

  @override
  State<SetPasswordBottomSheet> createState() => _SetPasswordBottomSheetState();
}

class _SetPasswordBottomSheetState extends State<SetPasswordBottomSheet> {
  final _authRepo = AuthRepository();

  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final newPassword = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;

    if (newPassword.isEmpty || confirm.isEmpty) {
      setState(() => _errorMessage = 'Please fill in both password fields.');
      return;
    }
    if (newPassword != confirm) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }
    if (newPassword.length < 8) {
      setState(
          () => _errorMessage = 'Password must be at least 8 characters long.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authRepo.setPassword(
        newPassword: newPassword,
        confirmPassword: confirm,
      );

      if (mounted) {
        final profileBloc = context.read<ProfileBloc>();
        final current = profileBloc.state.profile;
        profileBloc.add(
          UpdateProfileEvent(current.copyWith(hasPassword: true)),
        );

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Password set successfully! You can now log in with email and password.',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 20,
        right: 20,
        top: 14,
      ),
      decoration: BoxDecoration(
        color: zen.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: zen.border)),
      ),
      child: SingleChildScrollView(
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
            const SizedBox(height: 14),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: zen.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(LucideIcons.key_round,
                          size: 18, color: zen.accent),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Set account password',
                      style: AppTextStyles.headingLarge(zen.textPrimary),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: zen.subtleFill,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(LucideIcons.x, size: 16, color: zen.textMuted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Text(
              'Create a password so you can sign in using your email address in addition to Google One-Click login.',
              style: AppTextStyles.bodySmall(zen.textSecondary),
            ),
            const SizedBox(height: 16),

            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.danger.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.circle_alert,
                      size: 16,
                      color: AppColors.danger,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: AppTextStyles.labelSmall(AppColors.danger),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // New Password Field
            Text(
              'New password',
              style: AppTextStyles.labelMedium(zen.textPrimary),
            ),
            const SizedBox(height: 6),
            ZenTextField(
              controller: _newPasswordController,
              hintText: 'Minimum 8 characters',
              obscureText: _obscureNew,
              prefixIcon: Icon(LucideIcons.lock, size: 18, color: zen.accent),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNew ? LucideIcons.eye : LucideIcons.eye_off,
                  size: 18,
                  color: zen.textMuted,
                ),
                onPressed: () => setState(() => _obscureNew = !_obscureNew),
              ),
            ),
            const SizedBox(height: 14),

            // Confirm New Password Field
            Text(
              'Confirm new password',
              style: AppTextStyles.labelMedium(zen.textPrimary),
            ),
            const SizedBox(height: 6),
            ZenTextField(
              controller: _confirmPasswordController,
              hintText: 'Re-type new password',
              obscureText: _obscureConfirm,
              prefixIcon: Icon(LucideIcons.lock, size: 18, color: zen.accent),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm ? LucideIcons.eye : LucideIcons.eye_off,
                  size: 18,
                  color: zen.textMuted,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            const SizedBox(height: 14),

            // Password Policy Notice Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: zen.subtleFill,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: zen.border.withValues(alpha: 0.6)),
              ),
              child: Text(
                'Password must contain at least 8 characters, an uppercase letter, a lowercase letter, a digit, and a special character.',
                style: AppTextStyles.labelSmall(zen.textMuted).copyWith(
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 22),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      _isLoading ? null : () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.labelMedium(zen.textMuted),
                  ),
                ),
                const SizedBox(width: 12),
                ZenButton(
                  label: _isLoading ? 'Setting...' : 'Set password',
                  height: 42,
                  width: 145,
                  onPressed: _isLoading ? null : _submit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
