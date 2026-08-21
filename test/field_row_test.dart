import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';

// ignore: avoid_relative_lib_imports
import '../example/lib/pages/field_row_page.dart';

void main() {
  testWidgets('FieldRow with bare Input child does not throw '
      '(regression: unbounded width)', (tester) async {
    // A Row lays out non-flex children with an unbounded max width, which made
    // TextField-based children assert "InputDecorator cannot have an unbounded
    // width" in debug builds. FieldRow must bound its child via Flexible.
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          type: MaterialType.transparency,
          child: TokenScope(
            tokens: DesktopTokens.winForm,
            child: const SizedBox(
              width: 320,
              child: Column(
                children: [
                  FieldRow(label: 'Host:', child: Input(hint: 'localhost')),
                  SizedBox(height: 8),
                  FieldRow(child: Input(hint: 'no label')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(FieldRow), findsNWidgets(2));
    expect(find.byType(Input), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('FieldRow keeps fixed-width child unchanged', (tester) async {
    // db_lite relies on the fixed-width pattern:
    // FieldRow(child: SizedBox(width: 280, child: Input(...)))
    // Flexible (loose) must not force the child to stretch.
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          type: MaterialType.transparency,
          child: TokenScope(
            tokens: DesktopTokens.winForm,
            child: const SizedBox(
              width: 400,
              child: FieldRow(
                label: '数据库名:',
                child: SizedBox(width: 280, child: Input(hint: 'test')),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final sizedBox = tester.widget<SizedBox>(
      find.byWidgetPredicate((w) => w is SizedBox && w.width == 280),
    );
    expect(sizedBox.width, 280);
    expect(tester.takeException(), isNull);
  });

  testWidgets('FieldRowPage renders all demos', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          type: MaterialType.transparency,
          child: TokenScope(
            tokens: DesktopTokens.winForm,
            child: const FieldRowPage(),
          ),
        ),
      ),
    );
    await tester.pump();

    // 3 demo sections + content
    expect(find.text('Basic'), findsOneWidget);
    expect(find.text('Without label (alignment spacer)'), findsOneWidget);
    expect(find.text('Custom label width'), findsOneWidget);

    // labels
    expect(find.text('Host:'), findsOneWidget);
    expect(find.text('Port:'), findsOneWidget);
    expect(find.text('User:'), findsOneWidget);
    expect(find.text('Name:'), findsOneWidget);
    expect(find.text('Connection:'), findsOneWidget);
    expect(find.text('Password:'), findsOneWidget);

    // 7 Inputs total (3 basic + 2 no-label + 2 custom-width)
    expect(find.byType(Input), findsNWidgets(7));

    // No exception during layout
    expect(tester.takeException(), isNull);
  });
}
