import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/bloc/theme_bloc.dart';
import 'core/theme/bloc/theme_state.dart';
import 'core/theme/zenflow_theme.dart';
import 'features/showcase/views/theme_showcase_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(BlocProvider(create: (_) => ThemeBloc(), child: const ZenFlowApp()));
}

class ZenFlowApp extends StatelessWidget {
  const ZenFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return MaterialApp(
          title: 'ZenFlow',
          debugShowCheckedModeBanner: false,
          themeMode: state.themeMode,
          theme: ZenFlowTheme.lightTheme(state.accentColor),
          darkTheme: ZenFlowTheme.darkTheme(state.accentColor),
          home: const ThemeShowcaseScreen(),
        );
      },
    );
  }
}
