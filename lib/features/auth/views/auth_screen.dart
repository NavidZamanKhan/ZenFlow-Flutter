import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_card.dart';
import '../../../core/widgets/zen_icon_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_tab_switcher.dart';
import '../widgets/login_form_widget.dart';
import '../widgets/register_form_widget.dart';

class AuthScreen extends StatefulWidget {
  final AuthTab initialTab;

  const AuthScreen({
    super.key,
    this.initialTab = AuthTab.register,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late AuthTab _activeTab;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
  }

  void _onGoogleSignIn(BuildContext context) {
    context.read<AuthBloc>().add(GoogleSignInRequestedEvent());
  }

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthenticatedState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: zen.accent,
              content: Text('Welcome back, ${state.user.fullName}!'),
            ),
          );
          Navigator.of(context).maybePop();
        } else if (state is AuthFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Theme.of(context).colorScheme.error,
              content: Text(state.errorMessage),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoadingState;

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  // Top Bar with Brand Logo and Close Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: zen.accent,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: zen.accent.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'Z',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'ZenFlow',
                            style: AppTextStyles.headingMedium(zen.textPrimary),
                          ),
                        ],
                      ),
                      ZenIconButton(
                        icon: LucideIcons.x,
                        size: 38,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Main Auth Card Container
                  ZenCard(
                    padding: const EdgeInsets.all(22),
                    borderRadius: 24,
                    child: Column(
                      children: [
                        // Segmented Log In / Sign Up Switcher
                        AuthTabSwitcher(
                          activeTab: _activeTab,
                          onTabChanged: (tab) {
                            setState(() {
                              _activeTab = tab;
                            });
                          },
                        ),
                        const SizedBox(height: 24),

                        // Loading banner if authenticating
                        if (isLoading) ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(zen.accent),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  state.message ?? 'Please wait...',
                                  style: AppTextStyles.labelSmall(zen.accent),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Animated Transition between Login and Register
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 250),
                          crossFadeState: _activeTab == AuthTab.login
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          firstChild: LoginFormWidget(
                            onSwitchToRegister: () {
                              setState(() {
                                _activeTab = AuthTab.register;
                              });
                            },
                            onForgotPassword: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Forgot Password flow is next in Step 2.3'),
                                ),
                              );
                            },
                            onLoginSubmit: (email, password, rememberMe) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Email login for $email is next in Step 2.3'),
                                ),
                              );
                            },
                            onGoogleLogin: () => _onGoogleSignIn(context),
                          ),
                          secondChild: RegisterFormWidget(
                            onSwitchToLogin: () {
                              setState(() {
                                _activeTab = AuthTab.login;
                              });
                            },
                            onRegisterSubmit: (fullName, email, password) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Registration for $fullName is next in Step 2.3'),
                                ),
                              );
                            },
                            onGoogleLogin: () => _onGoogleSignIn(context),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
