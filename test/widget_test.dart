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

    // Verify ZenFlow branding is rendered
    expect(find.text('ZenFlow'), findsOneWidget);
    expect(find.text('Theme Appearance'), findsOneWidget);
  });
}
