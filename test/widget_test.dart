import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zenflow_flutter/main.dart';

void main() {
  testWidgets('ZenFlow App Theme smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ZenFlowApp(),
      ),
    );

    // Verify ZenFlow branding is rendered
    expect(find.text('ZenFlow'), findsOneWidget);
    expect(find.text('Theme Appearance'), findsOneWidget);
  });
}
