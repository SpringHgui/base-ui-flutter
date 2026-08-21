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

  group('ComboBox', () {
    // Mirrors the "With hint" example (example/lib/pages/combo_box_page.dart):
    // read-only, hint, nothing selected yet.
    testWidgets('with hint opens dropdown when no value is selected',
        (tester) async {
      await tester.pumpWidget(
        wrap(SizedBox(
          width: 250,
          child: ComboBox<String>(
            items: const ['Item 1', 'Item 2', 'Item 3', 'Item 4', 'Item 5'],
            value: null,
            onChanged: (_) {},
            hint: 'selectItem',
          ),
        )),
      );

      // Nothing selected yet → tapping must still open the drop-down.
      await tester.tap(find.byType(ComboBox<String>));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 5'), findsOneWidget);
    });

    testWidgets('opens dropdown with a selected value', (tester) async {
      await tester.pumpWidget(
        wrap(ComboBox<String>(
          items: const ['Apple', 'Banana'],
          value: 'Apple',
          onChanged: (_) {},
        )),
      );

      await tester.tap(find.byType(ComboBox<String>));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // Selected value shows in the control AND in the drop-down list.
      expect(find.text('Apple'), findsNWidgets(2));
      expect(find.text('Banana'), findsOneWidget);
    });

    testWidgets('reopens dropdown after an item was selected', (tester) async {
      String? selected;
      await tester.pumpWidget(
        wrap(StatefulBuilder(
          builder: (context, setState) => ComboBox<String>(
            items: const ['Apple', 'Banana'],
            value: selected,
            onChanged: (v) => setState(() => selected = v),
          ),
        )),
      );

      // Pick Banana from the drop-down.
      await tester.tap(find.byType(ComboBox<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Banana'));
      await tester.pumpAndSettle();
      expect(selected, 'Banana');

      // Reopen after selection: didUpdateWidget syncs the display, the
      // drop-down must open again with all options.
      await tester.tap(find.byType(ComboBox<String>));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Apple'), findsOneWidget);
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
