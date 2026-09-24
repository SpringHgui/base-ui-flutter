import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';

/// 固定标签(`TabControl.pinnedCount`)的回归守护。
///
/// daro 的文档标签条把第一个"对象"页钉在条首:打开的标签再多、滚得再远,
/// 它都该留在原处 —— 否则想回对象面板就得先一路滚回最左。
///
/// 另一条易踩的坑:判定"要不要滚动"时必须把固定标签的宽度从可用宽度里
/// 扣掉,否则固定标签会被算进可滚动内容,标签稍多就误判成溢出、平白弹出
/// 一对箭头。
void main() {
  const t = DesktopTokens.winForm;

  Widget host(Widget child, {double width = 200}) => MaterialApp(
        home: Material(
          type: MaterialType.transparency,
          child: TokenScope(
            tokens: t,
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(width: width, child: child),
            ),
          ),
        ),
      );

  /// 8 个标签:即使全部落到最小宽度(44),也远超 200 宽标签条的可用宽度。
  List<TabItem> manyTabs() => const [
        TabItem(label: '对象'),
        TabItem(label: '查询1'),
        TabItem(label: '查询2'),
        TabItem(label: '查询3'),
        TabItem(label: '查询4'),
        TabItem(label: '查询5'),
        TabItem(label: '查询6'),
        TabItem(label: '查询7'),
      ];

  testWidgets('固定标签不随滚动位移,其余标签照常滚动', (tester) async {
    await tester.pumpWidget(host(TabControl(
      pinnedCount: 1,
      barHeight: 26,
      tabs: manyTabs(),
    )));
    await tester.pumpAndSettle();

    // 溢出 → 两端箭头都在
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);

    // 左箭头紧贴在固定标签的**右侧**(不是整条标签的最左端):它滚的是固定块
    // 之后的内容,摆到"对象"页左边会看起来像在滚一个钉死不动的标签。
    final pinnedRight = tester.getBottomRight(find.text('对象')).dx;
    final leftArrowX = tester.getTopLeft(find.byIcon(Icons.chevron_left)).dx;
    expect(leftArrowX, greaterThanOrEqualTo(pinnedRight),
        reason: '左箭头必须排在"对象"页右边');

    final pinnedBefore = tester.getTopLeft(find.text('对象')).dx;
    final scrollableBefore = tester.getTopLeft(find.text('查询1')).dx;

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('对象')).dx, closeTo(pinnedBefore, 0.01),
        reason: '"对象"是固定标签,滚动时不该跟着位移');
    expect(tester.getTopLeft(find.text('查询1')).dx, lessThan(scrollableBefore),
        reason: '其余标签应当随滚动左移');
  });

  testWidgets('未设置 pinnedCount 时行为不变(第一个标签也参与滚动)', (tester) async {
    await tester.pumpWidget(host(TabControl(
      barHeight: 26,
      tabs: manyTabs(),
    )));
    await tester.pumpAndSettle();

    final firstBefore = tester.getTopLeft(find.text('对象')).dx;
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('对象')).dx, lessThan(firstBefore),
        reason: '不固定时第一个标签也要跟着滚');
  });

  testWidgets('固定标签的宽度不计入可滚动内容(放得下就不出箭头)', (tester) async {
    await tester.pumpWidget(host(
      TabControl(pinnedCount: 1, barHeight: 26, tabs: manyTabs()),
      width: 900,
    ));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.chevron_left), findsNothing);
    expect(find.byIcon(Icons.chevron_right), findsNothing);
  });

  testWidgets('滚动箭头格有顶边和底边(标签条上下沿不在箭头处断开)', (tester) async {
    await tester.pumpWidget(host(TabControl(
      pinnedCount: 1,
      barHeight: 26,
      tabs: manyTabs(),
    )));
    await tester.pumpAndSettle();

    // 标签头都画了顶线(_TabChrome 的 top hairline)、未选中的还画了底线;
    // 箭头格也是标签条的一段,少了这两条整条上下沿就在箭头处断开,
    // 箭头看着像浮在条外的一座孤岛。
    for (final icon in [Icons.chevron_left, Icons.chevron_right]) {
      expect(find.byIcon(icon), findsOneWidget);
      final box = tester.widget<Container>(find
          .ancestor(of: find.byIcon(icon), matching: find.byType(Container))
          .first);
      final border = (box.decoration as BoxDecoration).border as Border;
      expect(border.top.style, isNot(BorderStyle.none),
          reason: '${icon.codePoint} 箭头格缺顶边');
      expect(border.top.width, greaterThan(0));
      expect(border.bottom.style, isNot(BorderStyle.none),
          reason: '${icon.codePoint} 箭头格缺底边');
      expect(border.bottom.width, greaterThan(0));
    }
  });
}
