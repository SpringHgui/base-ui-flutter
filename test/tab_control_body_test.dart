import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';

void main() {
  // 回归:Flutter 3.47 起,竖向 Column 的非 flex 子项会拿到**无界**主轴约束
  // (旧版本会夹到剩余空间)。页面面板因此拿到 maxHeight=infinity,
  // 任何要求显式高度的内容(代码编辑器 / 视口)在 performLayout 断言,
  // 整帧布局中断 → 后续鼠标命中测试连环抛 "!_debugDuringDeviceUpdate",界面卡死。
  testWidgets('TabControl 页面面板在高度有界时拿到有界最大高度', (tester) async {
    BoxConstraints? received;
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          type: MaterialType.transparency,
          child: TokenScope(
            tokens: DesktopTokens.winForm,
            child: Center(
              child: SizedBox(
                width: 400,
                height: 300,
                child: TabControl(
                  tabs: [
                    TabItem(
                      label: '定义',
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          received = constraints;
                          return const ColoredBox(color: Colors.transparent);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(received, isNotNull);
    expect(
      received!.maxHeight.isFinite,
      isTrue,
      reason: '标签页内容应被限制在剩余高度内(WinForms DisplayRectangle 语义),'
          '而不是拿到 infinity,否则编辑器/视口类内容无法布局',
    );
    expect(received!.maxHeight, greaterThan(0));
  });

  testWidgets('TabControl 在高度无界的父级里按内容自适应(对话框场景)',
      (tester) async {
    BoxConstraints? received;
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          type: MaterialType.transparency,
          child: TokenScope(
            tokens: DesktopTokens.winForm,
            child: Align(
              alignment: Alignment.topLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TabControl(
                    tabs: [
                      TabItem(
                        label: '常规',
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            received = constraints;
                            return const SizedBox(width: 200, height: 50);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull,
        reason: '无界高度下不得因 flex 子项报错(IntrinsicHeight / 滚动容器场景)');
    expect(received!.maxHeight.isInfinite, isTrue,
        reason: '父级无界时保持原有的按内容自适应语义');
    final size = tester.getSize(find.byType(TabControl));
    expect(size.height, greaterThan(50));
    expect(size.height, lessThan(90),
        reason: '整控件高度 = 标签条 + 内容 50,不得撑满或塌陷');
  });
}
