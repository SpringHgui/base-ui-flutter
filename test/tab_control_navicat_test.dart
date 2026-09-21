import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';

/// Navicat 风格标签条度量回归。
///
/// 参考实测(Navicat 16 连接对话框 @2x 截图换算成逻辑像素):
/// 未选中标签高 20.5、选中标签高 23、标签宽 = 文本 + 约 13(最小 46)。
/// winForm 令牌下(fontSize 13 / compactSpacing 4 / borderWidth 1)我们的
/// 目标是:标签头 20.65、标签条 23.65 —— 与 Navicat 同一档紧凑度。
void main() {
  const t = DesktopTokens.winForm;

  Widget host(Widget child) => MaterialApp(
        home: Material(
          type: MaterialType.transparency,
          child: TokenScope(tokens: t, child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(width: 500, child: child),
          )),
        ),
      );

  test('标签条高度与 Navicat 实测同档(不再是 controlHeight 28)', () {
    // 20.65 = 标签行高 13.65 + 上下内边距 3*2 + 边框 1
    expect(TabControl.stripHeight(t, hasBody: false), closeTo(20.65, 0.01));
    // 23.65 = 标签头 + 页面顶线 1 + 选中标签上浮 2
    expect(TabControl.stripHeight(t), closeTo(23.65, 0.01));
    // 显式 barHeight 仍然优先(文档标签条那种要略高一点的场景)
    expect(TabControl.stripHeight(t, barHeight: 26), closeTo(29, 0.01));
  });

  testWidgets('纯标签条与带页面面板时的整控件高度', (tester) async {
    await tester.pumpWidget(host(const TabControl(
      tabs: [TabItem(label: '常规'), TabItem(label: '高级')],
    )));
    expect(tester.getSize(find.byType(TabControl)).height, closeTo(20.65, 0.01),
        reason: '纯标签条(无 body)高度应贴合文字,而不是沿用 28 的控件高度');

    // 带 body 时 = 标签条 23.65(含页面顶线 1 + 选中标签上浮 2)
    //            + 默认内容上边距 8 + body 50
    await tester.pumpWidget(host(const TabControl(
      tabs: [
        TabItem(label: '常规', child: SizedBox(height: 50)),
        TabItem(label: '高级', child: SizedBox(height: 50)),
      ],
    )));
    expect(tester.getSize(find.byType(TabControl)).height, closeTo(81.65, 0.01),
        reason: '标签条高度必须与 TabControl.stripHeight 同源,'
            '对话框据此算 body 可用高度');

    await tester.pumpWidget(host(const TabControl(
      contentPadding: EdgeInsets.zero,
      tabs: [
        TabItem(label: '常规', child: SizedBox(height: 50)),
        TabItem(label: '高级', child: SizedBox(height: 50)),
      ],
    )));
    expect(tester.getSize(find.byType(TabControl)).height, closeTo(73.65, 0.01),
        reason: '对话框场景(contentPadding: zero)下整高 = stripHeight + body');
  });

  testWidgets('标签宽度按文本自适应,并以最小宽度兜底', (tester) async {
    await tester.pumpWidget(host(const TabControl(
      tabs: [
        TabItem(label: '服务'),
        TabItem(label: '连接与模式'),
        TabItem(label: 'SSL'),
      ],
    )));
    double labelWidth(String s) => tester.getRect(find.text(s)).width;

    // 短标签被最小宽度垫到 44:文字两侧各 8 的内边距,合计 44 时文字最多 28
    expect(labelWidth('服务'), lessThanOrEqualTo(28.01));
    expect(labelWidth('服务'), greaterThan(0));
    // 长标签按内容撑开,不再被压成固定 80/92/104
    expect(labelWidth('连接与模式'), greaterThan(labelWidth('服务')));
    final controlWidth = tester.getSize(find.byType(TabControl)).width;
    expect(controlWidth, lessThanOrEqualTo(500));

    // 显式 width 仍然压得住自适应
    await tester.pumpWidget(host(const TabControl(
      tabs: [TabItem(label: '服务', width: 92)],
    )));
    expect(labelWidth('服务'), lessThanOrEqualTo(92 - 16 + 0.01));
  });

  testWidgets('可关闭标签为关闭按钮预留宽度,悬停不挤压文字', (tester) async {
    await tester.pumpWidget(host(TabControl(
      tabs: [
        TabItem(label: '查询 1', onClose: () {}),
        TabItem(label: '查询 1'),
      ],
    )));
    final withClose = tester.getRect(find.text('查询 1').first).width;
    final without = tester.getRect(find.text('查询 1').last).width;
    expect(withClose, greaterThan(without),
        reason: '带关闭按钮的标签应多预留 20px,否则悬停时文案会被挤成省略号');
  });
}
