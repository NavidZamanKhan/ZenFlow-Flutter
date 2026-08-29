import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    final isLogin = activeTab == AuthTab.login;

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: zen.subtleFill,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: zen.border),
      ),
      child: Stack(
        children: [
          // --- 1. The Physical Sliding Thumb Pill ---
          AnimatedAlign(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOutCubic,
            alignment: isLogin ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: zen.card,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: zen.border.withValues(alpha: 0.5),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: zen.isDark ? 0.3 : 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- 2. Interactive Touch Target & Label Layer ---
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (!isLogin) {
                      HapticFeedback.selectionClick();
                      onTabChanged(AuthTab.login);
                    }
                  },
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: AppTextStyles.labelMedium(
                        isLogin ? zen.textPrimary : zen.textSecondary,
                      ),
                      child: const Text('Log in'),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (isLogin) {
                      HapticFeedback.selectionClick();
                      onTabChanged(AuthTab.register);
                    }
                  },
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: AppTextStyles.labelMedium(
                        !isLogin ? zen.textPrimary : zen.textSecondary,
                      ),
                      child: const Text('Sign up'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
