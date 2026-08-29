import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/bloc/theme_bloc.dart';
import 'core/theme/bloc/theme_state.dart';
import 'core/theme/zenflow_theme.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/views/auth_gate.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ThemeBloc(),
        ),
        BlocProvider(
          create: (_) => AuthBloc()..add(CheckAuthStatusEvent()),
        ),
      ],
      child: const ZenFlowApp(),
    ),
  );
}

class ZenFlowApp extends StatelessWidget {
  const ZenFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return MaterialApp(
          title: 'ZenFlow',
          debugShowCheckedModeBanner: false,
          themeMode: themeState.themeMode,
          theme: ZenFlowTheme.lightTheme(themeState.accentColor),
          darkTheme: ZenFlowTheme.darkTheme(themeState.accentColor),
          home: const AuthGate(),
        );
      },
    );
  }
}
