import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';

/// ToolStrip 的 trailing 槽与 ExpandableSearch 的展开态。
///
/// 两条都是宿主（daro 对象面板工具栏「最右侧搜索框」）踩到的：
///   1. 左侧按钮组原先用 `Flexible(fit: loose)`，它不吸收余量，于是 trailing
///      紧贴按钮尾巴、整条右半空着 —— 注释里写的「钉在右缘」并没有发生。
///   2. ExpandableSearch 恒从收起态起步，宿主把过滤词存在跨页面存活的状态对象里
///      时，页面重建后输入框会藏进放大镜（内容还在，看着却像被清空）。
void main() {
  const trailingKey = Key('trailing');

  Future<void> pumpStrip(
    WidgetTester tester, {
    required double width,
    required int buttonCount,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: width,
            child: ToolStrip(
              items: [
                for (var i = 0; i < buttonCount; i++)
                  ToolStripButton(text: 'B$i', onPressed: () {}),
              ],
              trailing: const SizedBox(key: trailingKey, width: 90, height: 20),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('trailing 钉在右缘,与按钮组之间留出余量', (tester) async {
    await pumpStrip(tester, width: 800, buttonCount: 2);

    final strip = tester.getRect(find.byType(ToolStrip));
    final trailing = tester.getRect(find.byKey(trailingKey));
    expect(trailing.right, closeTo(strip.right - DesktopTokens.winForm.compactSpacing, 0.5));
    expect(trailing.left, greaterThan(tester.getRect(find.text('B1')).right),
        reason: '按钮组窄时 trailing 不能被挤在按钮旁边');
  });

  testWidgets('按钮组宽到放不下时横向滚动,不溢出报错', (tester) async {
    await pumpStrip(tester, width: 220, buttonCount: 12);
    expect(tester.takeException(), isNull);
    final trailing = tester.getRect(find.byKey(trailingKey));
    expect(trailing.right,
        closeTo(220 - DesktopTokens.winForm.compactSpacing, 0.5));
  });

  testWidgets('外部 controller 已有文本时,搜索框直接以展开态出现', (tester) async {
    final controller = TextEditingController(text: 'car');
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ExpandableSearch(controller: controller, onChanged: (_) {}),
      ),
    ));

    expect(find.byType(SearchInput), findsOneWidget);
    expect(find.text('car'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget,
        reason: '展开态的放大镜是输入框前缀,不该退回图标按钮');
  });

  testWidgets('controller 为空时仍是收起态(默认不变)', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ExpandableSearch(controller: TextEditingController(), onChanged: (_) {}),
      ),
    ));

    expect(find.byType(SearchInput), findsNothing);
    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();
    expect(find.byType(SearchInput), findsOneWidget);
  });
}
