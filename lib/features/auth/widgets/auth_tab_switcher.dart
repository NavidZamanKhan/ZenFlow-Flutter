import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';

enum AuthTab { login, register }

class AuthTabSwitcher extends StatelessWidget {
  final AuthTab activeTab;
  final ValueChanged<AuthTab> onTabChanged;

  const AuthTabSwitcher({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: zen.subtleFill,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: zen.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              title: 'Log in',
              isActive: activeTab == AuthTab.login,
              onTap: () => onTabChanged(AuthTab.login),
            ),
          ),
          Expanded(
            child: _TabButton(
              title: 'Sign up',
              isActive: activeTab == AuthTab.register,
              onTap: () => onTabChanged(AuthTab.register),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isActive ? zen.card : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: zen.isDark ? 0.2 : 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            title,
            style: AppTextStyles.labelMedium(
              isActive ? zen.textPrimary : zen.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
