import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';

void main() {
  Widget host({required List<String> items, required int index, required ValueChanged<int> onChanged}) =>
      MaterialApp(
        home: TokenScope(
          tokens: DesktopTokens.winForm,
          child: Scaffold(
            body: TabStrip(
              items: items,
              index: index,
              onChanged: onChanged,
            ),
          ),
        ),
      );

  testWidgets('渲染全部标签,受控 index 决定选中项', (tester) async {
    await tester.pumpWidget(host(
      items: const ['更改', 'DDL'],
      index: 0,
      onChanged: (_) {},
    ));

    expect(find.text('更改'), findsOneWidget);
    expect(find.text('DDL'), findsOneWidget);

    final t = DesktopTokens.winForm;
    Text selectedText = tester.widget<Text>(find.text('更改'));
    expect(selectedText.style?.color, t.primaryColor);

    await tester.pumpWidget(host(
      items: const ['更改', 'DDL'],
      index: 1,
      onChanged: (_) {},
    ));
    selectedText = tester.widget<Text>(find.text('DDL'));
    expect(selectedText.style?.color, t.primaryColor);
  });

  testWidgets('按下未选中标签立即回调下标(零延迟),点击已选中项不回调', (tester) async {
    final calls = <int>[];
    await tester.pumpWidget(host(
      items: const ['更改', 'DDL'],
      index: 0,
      onChanged: calls.add,
    ));

    await tester.tap(find.text('DDL'));
    expect(calls, [1]); // tap 走 down+up,onTapDown 在按下帧即触发

    await tester.tap(find.text('更改'));
    expect(calls, [1]); // 再点选中项不产生回调
  });
}
