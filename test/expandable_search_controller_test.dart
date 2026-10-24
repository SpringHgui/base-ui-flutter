import 'package:base_ui_flutter/base_ui_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('expandAndFocus 从收起态打开输入框并聚焦', (tester) async {
    final expand = ExpandableSearchController();
    final text = TextEditingController();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ExpandableSearch(controller: text, expandController: expand),
      ),
    ));

    expect(find.byType(SearchInput), findsNothing);
    expand.expandAndFocus();
    await tester.pump();

    expect(find.byType(SearchInput), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus,
      isTrue,
    );
  });

  testWidgets('collapse 清空内容并向宿主补发 onChanged("")', (tester) async {
    final expand = ExpandableSearchController();
    final text = TextEditingController(text: 'abc');
    final seen = <String>[];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ExpandableSearch(
          controller: text,
          expandController: expand,
          onChanged: seen.add,
        ),
      ),
    ));

    // 外部 controller 里已有内容 → 起步即展开态
    expect(find.byType(SearchInput), findsOneWidget);
    expand.collapse();
    await tester.pump();

    expect(find.byType(SearchInput), findsNothing);
    expect(text.text, isEmpty);
    expect(seen, ['']);
  });

  testWidgets('句柄未挂到组件上时调用不报错', (tester) async {
    final expand = ExpandableSearchController();
    expand.expandAndFocus();
    expand.collapse();
    expect(tester.takeException(), isNull);
  });
}
