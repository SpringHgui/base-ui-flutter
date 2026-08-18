import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:base_ui_flutter/base_ui_flutter.dart';

Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('Label', () {
    testWidgets('renders its text', (tester) async {
      await tester.pumpWidget(wrap(const Label('Hello')));
      expect(find.text('Hello'), findsOneWidget);
    });
  });

  group('Button', () {
    testWidgets('renders text and invokes onPressed', (tester) async {
      var pressed = 0;
      await tester.pumpWidget(
        wrap(Button(text: 'OK', onPressed: () => pressed++)),
      );

      expect(find.text('OK'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);

      await tester.tap(find.text('OK'));
      expect(pressed, 1);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(wrap(const Button(text: 'OK')));

      final button = tester.widget<TextButton>(find.byType(TextButton));
      expect(button.onPressed, isNull);
    });
  });

  group('Input', () {
    testWidgets('edits text and reports onChanged', (tester) async {
      final controller = TextEditingController();
      String? changed;
      await tester.pumpWidget(
        wrap(Input(controller: controller, onChanged: (v) => changed = v)),
      );

      await tester.enterText(find.byType(TextField), 'hi');

      expect(controller.text, 'hi');
      expect(changed, 'hi');

      controller.dispose();
    });
  });

  group('TokenScope', () {
    testWidgets('provides tokens to descendants', (tester) async {
      const custom = DesktopTokens(cornerRadius: 8.0);
      DesktopTokens? resolved;

      await tester.pumpWidget(
        MaterialApp(
          home: TokenScope(
            tokens: custom,
            child: Builder(
              builder: (context) {
                resolved = TokenScope.maybeOf(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(resolved, custom);
    });
  });
}
