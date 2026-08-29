import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../showcase/views/theme_showcase_screen.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import 'auth_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthenticatedState) {
          return const ThemeShowcaseScreen();
        }

        if (state is AuthLoadingState && state.message == 'Checking session...') {
          return Scaffold(
            backgroundColor: zen.canvas,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: zen.accent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: zen.accent.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Z',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 26,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'ZenFlow',
                    style: AppTextStyles.headingLarge(zen.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(zen.accent),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Unauthenticated or AuthFailure: render locked AuthScreen as root
        return const AuthScreen(isRoot: true);
      },
    );
  }
}
