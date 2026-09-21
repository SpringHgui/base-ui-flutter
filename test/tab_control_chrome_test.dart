import 'package:base_ui_flutter/base_ui_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 标签条 chrome 回归:首个标签的左边线只在「标签条 + 正文构成闭合框」时画。
///
/// 纯标签条(每个 TabItem.child 都为 null,如 daro 的文档标签条)下部没有正文
/// 面板可以封边,左边线会变成标签左侧一条孤立的竖线 —— 那是"多了一个边框"。
void main() {
  const t = DesktopTokens.winForm;

  Widget host(Widget child) => MaterialApp(
        home: Material(
          type: MaterialType.transparency,
          child: TokenScope(
            tokens: t,
            child: Align(alignment: Alignment.topLeft, child: child),
          ),
        ),
      );

  /// 第一个标签的 chrome 是否画左边线。
  bool firstTabDrawsLeftEdge(WidgetTester tester) {
    final chromes = tester
        .widgetList(find.byWidgetPredicate(
            (w) => w.runtimeType.toString() == '_TabChrome'))
        .toList();
    expect(chromes, isNotEmpty, reason: '没找到标签 chrome(内部结构变了?)');
    return (chromes.first as dynamic).drawLeft as bool;
  }

  testWidgets('纯标签条不在首标签左侧画竖线', (tester) async {
    await tester.pumpWidget(host(const TabControl(
      tabs: [TabItem(label: '对象'), TabItem(label: 'user_info')],
    )));
    expect(firstTabDrawsLeftEdge(tester), isFalse,
        reason: '无正文时标签条悬在背景上,左边线是一条孤立竖线');
  });

  testWidgets('带正文的标签条仍然封住左边框', (tester) async {
    await tester.pumpWidget(host(const TabControl(
      tabs: [
        TabItem(label: '常规', child: SizedBox(height: 40)),
        TabItem(label: '高级', child: SizedBox(height: 40)),
      ],
    )));
    expect(firstTabDrawsLeftEdge(tester), isTrue,
        reason: '正文面板自带左边框,首标签左边线要与它对齐把框封住');
  });
}
