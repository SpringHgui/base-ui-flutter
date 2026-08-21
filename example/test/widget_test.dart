import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:example/main.dart';
import 'package:example/pages/button_page.dart';
import 'package:example/pages/quick_overview_page.dart';

void main() {
  testWidgets('app boots to the Quick Overview gallery', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    await tester.pumpWidget(const ExampleApp());
    await tester.pump(const Duration(milliseconds: 100));

    // Default page is the component gallery overview.
    expect(find.byType(QuickOverviewPage), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('sidebar navigation opens a component page', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    await tester.pumpWidget(const ExampleApp());
    await tester.pump(const Duration(milliseconds: 100));

    // Navigate to the Button demo through the sidebar and verify it opens.
    // The sidebar renders each page name; the first match is the sidebar item
    // (laid out before the content area).
    await tester.tap(find.text('Button').first);
    await tester.pumpAndSettle();
    expect(find.byType(ButtonPage), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.binding.setSurfaceSize(null);
  });
}
