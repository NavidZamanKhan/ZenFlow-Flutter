import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_button.dart';
import '../../../core/widgets/zen_text_field.dart';
import 'auth_divider.dart';
import 'social_auth_button.dart';

class LoginFormWidget extends StatefulWidget {
  final VoidCallback onSwitchToRegister;
  final VoidCallback onForgotPassword;
  final Function(String email, String password, bool rememberMe)? onLoginSubmit;
  final VoidCallback? onGoogleLogin;

  const LoginFormWidget({
    super.key,
    required this.onSwitchToRegister,
    required this.onForgotPassword,
    this.onLoginSubmit,
    this.onGoogleLogin,
  });

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back',
          style: AppTextStyles.headingLarge(zen.textPrimary),
        ),
        const SizedBox(height: 6),
        Text(
          'Enter your email and password to access your workspace.',
          style: AppTextStyles.bodySmall(zen.textSecondary),
        ),
        const SizedBox(height: 24),

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
          hintText: '••••••••',
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
        const SizedBox(height: 12),

        // Remember Me & Forgot Password
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _rememberMe,
                    onChanged: (val) {
                      setState(() {
                        _rememberMe = val ?? false;
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    activeColor: zen.accent,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Remember me',
                  style: AppTextStyles.bodySmall(zen.textPrimary),
                ),
              ],
            ),
            GestureDetector(
              onTap: widget.onForgotPassword,
              child: Text(
                'Forgot password?',
                style: AppTextStyles.labelSmall(zen.accent),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Sign In Button
        ZenButton(
          label: 'Sign in',
          onPressed: () {
            widget.onLoginSubmit?.call(
              _emailController.text.trim(),
              _passwordController.text,
              _rememberMe,
            );
          },
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

        // Footer link
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Don't have an account? ",
                style: AppTextStyles.bodySmall(zen.textSecondary),
              ),
              GestureDetector(
                onTap: widget.onSwitchToRegister,
                child: Text(
                  'Sign up',
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
