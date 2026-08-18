import 'package:flutter_test/flutter_test.dart';

import 'package:base_ui_flutter/base_ui_flutter.dart';
import 'package:example/main.dart';

void main() {
  testWidgets('renders the WinForm-style demo', (tester) async {
    await tester.pumpWidget(const ExampleApp());

    expect(find.text('Name:'), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);
    expect(find.byType(Input), findsOneWidget);
    expect(find.byType(Button), findsOneWidget);
  });
}
