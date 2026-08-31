import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_button.dart';
import '../../../core/widgets/zen_text_field.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/repositories/auth_repository.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_state.dart';
import 'set_password_bottom_sheet.dart';

class DeleteAccountBottomSheet extends StatefulWidget {
  const DeleteAccountBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<AuthBloc>()),
          BlocProvider.value(value: context.read<ProfileBloc>()),
        ],
        child: const DeleteAccountBottomSheet(),
      ),
    );
  }

  @override
  State<DeleteAccountBottomSheet> createState() =>
      _DeleteAccountBottomSheetState();
}

class _DeleteAccountBottomSheetState extends State<DeleteAccountBottomSheet> {
  final _authRepo = AuthRepository();

  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _otpSent = false;
  bool _sendingOtp = false;
  bool _confirmStep = false;
  bool _submitting = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    setState(() {
      _sendingOtp = true;
      _errorMessage = null;
    });
    HapticFeedback.selectionClick();

    try {
      final msg = await _authRepo.sendDeleteAccountOtp();
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

  void _handleProceedToConfirm() {
    final otp = _otpController.text.trim();
    final password = _passwordController.text;

    if (otp.length != 6) {
      setState(() => _errorMessage = 'Please enter the 6-digit verification code.');
      return;
    }
    if (password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your password.');
      return;
    }

    setState(() {
      _errorMessage = null;
      _confirmStep = true;
    });
  }

  Future<void> _handleFinalDelete() async {
    final otp = _otpController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      await _authRepo.deleteAccount(
        otp: otp,
        password: password,
      );

      if (mounted) {
        Navigator.of(context).pop();
        context.read<AuthBloc>().add(LogoutRequestedEvent());
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _submitting = false;
        _confirmStep = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, profileState) {
        final profile = profileState.profile;
        final hasPassword = profile.hasPassword;
        final email = profile.email;

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
                    Text(
                      _confirmStep ? 'Confirm deletion' : 'Delete account',
                      style: AppTextStyles.headingLarge(
                        _confirmStep || _otpSent
                            ? AppColors.danger
                            : zen.textPrimary,
                      ),
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
                const SizedBox(height: 14),

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

                if (!hasPassword) ...[
                  // Case A: Google OAuth User without a password set -> Must set password first
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.danger.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          LucideIcons.triangle_alert,
                          size: 18,
                          color: AppColors.danger,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Password required for deletion',
                                style: AppTextStyles.labelMedium(AppColors.danger)
                                    .copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'For your security, you must set up an account password before proceeding with account deletion.',
                                style: AppTextStyles.labelSmall(zen.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ZenButton(
                    label: 'Set password first',
                    icon: LucideIcons.key_round,
                    height: 44,
                    width: double.infinity,
                    onPressed: () {
                      Navigator.of(context).pop();
                      SetPasswordBottomSheet.show(context);
                    },
                  ),
                ] else if (_confirmStep) ...[
                  // Case B - Step 3: Final "Are you absolutely sure?" Confirmation
                  Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        LucideIcons.triangle_alert,
                        size: 28,
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: Text(
                      'Are you absolutely sure?',
                      style: AppTextStyles.headingMedium(zen.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'This will immediately and permanently delete your account for $email. All tasks, calendar events, expenses, and budgets will be wiped forever.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall(zen.textSecondary),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: ZenButton(
                          label: 'Back',
                          icon: LucideIcons.arrow_left,
                          variant: ZenButtonVariant.outlined,
                          height: 44,
                          onPressed: _submitting
                              ? null
                              : () => setState(() => _confirmStep = false),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ZenButton(
                          label: _submitting ? 'Deleting...' : 'Yes, delete',
                          icon: LucideIcons.trash_2,
                          variant: ZenButtonVariant.dangerSolid,
                          height: 44,
                          isLoading: _submitting,
                          onPressed: _submitting ? null : _handleFinalDelete,
                        ),
                      ),
                    ],
                  ),
                ] else if (!_otpSent) ...[
                  // Case B - Step 1: Initial Warning & Send Code (Matching User Screenshot 100%)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.danger.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          LucideIcons.triangle_alert,
                          size: 18,
                          color: AppColors.danger,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'This action is permanent and irreversible.',
                                style: AppTextStyles.labelMedium(AppColors.danger)
                                    .copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'All your tasks, calendar events, expenses, and budgets will be permanently deleted.',
                                style: AppTextStyles.labelSmall(
                                    AppColors.danger.withValues(alpha: 0.85)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  Text(
                    'To verify your identity, we will send an account deletion code to $email.',
                    style: AppTextStyles.bodySmall(zen.textSecondary),
                  ),
                  const SizedBox(height: 20),

                  ZenButton(
                    label: _sendingOtp
                        ? 'Sending code...'
                        : 'Send verification code',
                    icon: LucideIcons.mail,
                    variant: ZenButtonVariant.dangerSolid,
                    height: 46,
                    width: double.infinity,
                    isLoading: _sendingOtp,
                    onPressed: _sendingOtp ? null : _handleSendOtp,
                  ),
                ] else ...[
                  // Case B - Step 2: OTP & Password Verification Input
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
                          style: AppTextStyles.labelSmall(AppColors.danger).copyWith(
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
                    prefixIcon: Icon(LucideIcons.shield_check,
                        size: 18, color: AppColors.danger),
                  ),
                  const SizedBox(height: 14),

                  // Confirm Password
                  Text(
                    'Confirm your password',
                    style: AppTextStyles.labelMedium(zen.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  ZenTextField(
                    controller: _passwordController,
                    hintText: 'Enter current password',
                    obscureText: _obscurePassword,
                    prefixIcon:
                        Icon(LucideIcons.lock, size: 18, color: AppColors.danger),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? LucideIcons.eye : LucideIcons.eye_off,
                        size: 18,
                        color: zen.textMuted,
                      ),
                      onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: 22),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.labelMedium(zen.textMuted),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ZenButton(
                        label: 'Continue to confirmation',
                        variant: ZenButtonVariant.dangerSolid,
                        height: 42,
                        width: 205,
                        onPressed: _handleProceedToConfirm,
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
