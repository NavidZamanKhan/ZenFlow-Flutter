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
import '../bloc/profile_state.dart';

class ChangePasswordBottomSheet extends StatefulWidget {
  const ChangePasswordBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<ProfileBloc>(),
        child: const ChangePasswordBottomSheet(),
      ),
    );
  }

  @override
  State<ChangePasswordBottomSheet> createState() =>
      _ChangePasswordBottomSheetState();
}

class _ChangePasswordBottomSheetState extends State<ChangePasswordBottomSheet> {
  final _authRepo = AuthRepository();

  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _otpSent = false;
  bool _sendingOtp = false;
  bool _submitting = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String? _errorMessage;

  @override
  void dispose() {
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    setState(() {
      _sendingOtp = true;
      _errorMessage = null;
    });
    HapticFeedback.selectionClick();

    try {
      final msg = await _authRepo.sendPasswordResetOtp();
      setState(() {
        _otpSent = true;
        _sendingOtp = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _sendingOtp = false;
      });
    }
  }

  Future<void> _handleSubmit() async {
    final otp = _otpController.text.trim();
    final newPassword = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;

    if (otp.length != 6) {
      setState(() => _errorMessage = 'Please enter the 6-digit verification code.');
      return;
    }
    if (newPassword.isEmpty || confirm.isEmpty) {
      setState(() => _errorMessage = 'Please enter and confirm your new password.');
      return;
    }
    if (newPassword != confirm) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }
    if (newPassword.length < 8) {
      setState(() => _errorMessage = 'Password must be at least 8 characters long.');
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      final msg = await _authRepo.changePasswordWithOtp(
        otp: otp,
        newPassword: newPassword,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, profileState) {
        final email = profileState.profile.email;

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
                          'Change password',
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
                  'For your security, a 6-digit verification code will be sent to $email.',
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

                if (!_otpSent) ...[
                  // Step 1: Send Verification Code Button
                  ZenButton(
                    label: _sendingOtp ? 'Sending code...' : 'Send verification code',
                    icon: LucideIcons.mail,
                    height: 44,
                    width: double.infinity,
                    onPressed: _sendingOtp ? null : _handleSendOtp,
                  ),
                ] else ...[
                  // Step 2: OTP & New Password Form
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Verification code',
                        style: AppTextStyles.labelMedium(zen.textPrimary),
                      ),
                      GestureDetector(
                        onTap: _sendingOtp ? null : _handleSendOtp,
                        child: Text(
                          _sendingOtp ? 'Sending...' : 'Resend code',
                          style: AppTextStyles.labelSmall(zen.accent).copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ZenTextField(
                    controller: _otpController,
                    hintText: '6-digit code',
                    keyboardType: TextInputType.number,
                    prefixIcon:
                        Icon(LucideIcons.shield_check, size: 18, color: zen.accent),
                  ),
                  const SizedBox(height: 14),

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
                  const SizedBox(height: 22),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _submitting
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.labelMedium(zen.textMuted),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ZenButton(
                        label: _submitting ? 'Updating...' : 'Update password',
                        height: 42,
                        width: 160,
                        onPressed: _submitting ? null : _handleSubmit,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
