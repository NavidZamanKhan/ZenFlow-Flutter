import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zenflow_flutter/core/theme/bloc/theme_bloc.dart';
import 'package:zenflow_flutter/main.dart';

void main() {
  testWidgets('ZenFlow App Theme with BLoC smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => ThemeBloc(),
        child: const ZenFlowApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify ZenFlow branding is rendered
    expect(find.text('ZenFlow'), findsWidgets);
    expect(find.text('Theme Appearance'), findsOneWidget);
  });
}
