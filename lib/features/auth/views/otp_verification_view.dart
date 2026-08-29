import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_button.dart';
import '../../../core/widgets/zen_card.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../models/pending_registration_model.dart';
import '../widgets/otp_input_boxes.dart';

class OtpVerificationView extends StatefulWidget {
  final PendingRegistrationModel pendingRegistration;

  const OtpVerificationView({
    super.key,
    required this.pendingRegistration,
  });

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  String _otp = '';
  int _secondsRemaining = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCooldownTimer();
  }

  void _startCooldownTimer() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = 60;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onVerify() {
    if (_otp.length == 6) {
      context.read<AuthBloc>().add(
            VerifyOtpSubmittedEvent(
              pendingRegistrationId: widget.pendingRegistration.pendingRegistrationId,
              otp: _otp,
            ),
          );
    }
  }

  void _onResend() {
    if (_secondsRemaining == 0) {
      context.read<AuthBloc>().add(
            ResendOtpRequestedEvent(
              pendingRegistrationId: widget.pendingRegistration.pendingRegistrationId,
            ),
          );
      _startCooldownTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is PendingOtpState && state.resendMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: zen.accent,
              content: Text(state.resendMessage!),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoadingState;

        return ZenCard(
          padding: const EdgeInsets.all(22),
          borderRadius: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon Header
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: zen.accentSoft,
                  shape: BoxShape.circle,
                  border: Border.all(color: zen.accentLightBorder),
                ),
                child: Center(
                  child: Icon(
                    LucideIcons.mail,
                    size: 26,
                    color: zen.accent,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              Text(
                'Verify your email',
                style: AppTextStyles.headingMedium(zen.textPrimary),
              ),
              const SizedBox(height: 8),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTextStyles.bodyMedium(zen.textSecondary),
                  children: [
                    const TextSpan(text: "We've sent a 6-digit code to\n"),
                    TextSpan(
                      text: widget.pendingRegistration.email,
                      style: AppTextStyles.labelMedium(zen.textPrimary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // 6-Digit OTP Boxes
              OtpInputBoxes(
                onChanged: (val) {
                  setState(() {
                    _otp = val;
                  });
                },
                onCompleted: (val) {
                  setState(() {
                    _otp = val;
                  });
                  _onVerify();
                },
              ),
              const SizedBox(height: 24),

              // Cooldown timer & Resend button
              if (_secondsRemaining > 0)
                Text(
                  'Resend code in 00:${_secondsRemaining.toString().padLeft(2, '0')}',
                  style: AppTextStyles.bodySmall(zen.textSecondary),
                )
              else
                InkWell(
                  onTap: isLoading ? null : _onResend,
                  child: Text(
                    'Resend verification code',
                    style: AppTextStyles.labelMedium(zen.accent),
                  ),
                ),

              const SizedBox(height: 24),

              // Submit Button
              ZenButton(
                label: 'Verify & Enter Workspace',
                isLoading: isLoading,
                onPressed: _otp.length == 6 ? _onVerify : null,
              ),

              const SizedBox(height: 16),

              // Back to Sign Up
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(CancelOtpVerificationEvent());
                },
                child: Text(
                  'Wrong email? Back to Sign up',
                  style: AppTextStyles.labelSmall(zen.textSecondary),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
