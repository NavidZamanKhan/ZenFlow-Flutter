import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_badge.dart';
import '../../../core/widgets/zen_button.dart';
import '../../../core/widgets/zen_text_field.dart';
import 'auth_divider.dart';
import 'social_auth_button.dart';

class RegisterFormWidget extends StatefulWidget {
  final VoidCallback onSwitchToLogin;
  final Function(String fullName, String email, String password, String confirmPassword)?
      onRegisterSubmit;
  final VoidCallback? onGoogleLogin;

  const RegisterFormWidget({
    super.key,
    required this.onSwitchToLogin,
    this.onRegisterSubmit,
    this.onGoogleLogin,
  });

  @override
  State<RegisterFormWidget> createState() => _RegisterFormWidgetState();
}

class _RegisterFormWidgetState extends State<RegisterFormWidget> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (fullName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name.')),
      );
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address.')),
      );
      return;
    }

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 8 characters long.')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the Terms and Privacy Policy.')),
      );
      return;
    }

    widget.onRegisterSubmit?.call(fullName, email, password, confirmPassword);
  }

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top "Get started" Pill Badge
        ZenBadge(
          label: 'Get started',
          color: zen.accent,
          showDot: true,
        ),
        const SizedBox(height: 12),

        // Headline
        Text(
          'Create your account',
          style: AppTextStyles.headingLarge(zen.textPrimary),
        ),
        const SizedBox(height: 6),
        Text(
          'A few details and your quiet workspace is ready.',
          style: AppTextStyles.bodySmall(zen.textSecondary),
        ),
        const SizedBox(height: 24),

        // Full Name Field
        ZenTextField(
          controller: _fullNameController,
          labelText: 'Full name',
          hintText: 'Maya Chen',
          prefixIcon: Icon(LucideIcons.user, size: 18, color: zen.textMuted),
        ),
        const SizedBox(height: 16),

        // Email Field
        ZenTextField(
          controller: _emailController,
          labelText: 'Email',
          hintText: 'you@example.com',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icon(LucideIcons.mail, size: 18, color: zen.textMuted),
        ),
        const SizedBox(height: 16),

        // Password Field
        ZenTextField(
          controller: _passwordController,
          labelText: 'Password',
          hintText: 'At least 8 chars, mixed case, digit, symbol',
          obscureText: _obscurePassword,
          prefixIcon: Icon(LucideIcons.lock, size: 18, color: zen.textMuted),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? LucideIcons.eye_off : LucideIcons.eye,
              size: 18,
              color: zen.textMuted,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
        const SizedBox(height: 16),

        // Confirm Password Field
        ZenTextField(
          controller: _confirmPasswordController,
          labelText: 'Confirm password',
          hintText: '••••••••',
          obscureText: _obscureConfirmPassword,
          prefixIcon: Icon(LucideIcons.lock, size: 18, color: zen.textMuted),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword ? LucideIcons.eye_off : LucideIcons.eye,
              size: 18,
              color: zen.textMuted,
            ),
            onPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
          ),
        ),
        const SizedBox(height: 14),

        // Terms Checkbox
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: _agreedToTerms,
                onChanged: (val) {
                  setState(() {
                    _agreedToTerms = val ?? false;
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                activeColor: zen.accent,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Wrap(
                  children: [
                    Text(
                      'I agree to the ',
                      style: AppTextStyles.bodySmall(zen.textPrimary),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Terms ',
                        style: AppTextStyles.labelSmall(zen.accent),
                      ),
                    ),
                    Text(
                      'and ',
                      style: AppTextStyles.bodySmall(zen.textPrimary),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Privacy Policy',
                        style: AppTextStyles.labelSmall(zen.accent),
                      ),
                    ),
                    Text(
                      '.',
                      style: AppTextStyles.bodySmall(zen.textPrimary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Create Account Button
        ZenButton(
          label: 'Create account',
          onPressed: _handleSubmit,
        ),
        const SizedBox(height: 20),

        // Divider
        const AuthDivider(),
        const SizedBox(height: 20),

        // Google Sign In
        SocialAuthButton(
          onPressed: widget.onGoogleLogin ?? () {},
        ),
        const SizedBox(height: 24),

        // Footer Link
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Already have an account? ',
                style: AppTextStyles.bodySmall(zen.textSecondary),
              ),
              GestureDetector(
                onTap: widget.onSwitchToLogin,
                child: Text(
                  'Log in',
                  style: AppTextStyles.labelSmall(zen.accent),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
