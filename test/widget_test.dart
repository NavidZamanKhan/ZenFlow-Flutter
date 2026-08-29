import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zenflow_flutter/core/theme/bloc/theme_bloc.dart';
import 'package:zenflow_flutter/features/auth/bloc/auth_bloc.dart';
import 'package:zenflow_flutter/main.dart';

void main() {
  testWidgets('ZenFlow App Theme with MultiBlocProvider smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeBloc()),
          BlocProvider(create: (_) => AuthBloc()),
        ],
        child: const ZenFlowApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify ZenFlow branding is rendered
    expect(find.text('ZenFlow'), findsWidgets);
    expect(find.text('Theme Appearance'), findsOneWidget);
  });
}
