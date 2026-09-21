import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';

/// Navicat 风格按钮度量回归。
///
/// 参考实测(Navicat 16「连接属性」对话框 @2x 截图换算成逻辑像素):
///
/// | 项 | Navicat | 本组件(winForm 令牌下) |
/// |---|---|---|
/// | 按钮高 | 24 | 24 |
/// | 按钮宽(短标签) | 73 | 73(buttonMinWidth) |
/// | 相邻按钮间距 | 10 | 由调用方给(示例里也用 10) |
/// | 面 / 边 | #FDFDFD / #D0D0D0 | buttonFaceColor / buttonBorderColor |
/// | 底条 | #F0F0F0 + 上方 1px #E5E5E5 | secondaryColor + borderColor 上边框 |
///
/// 注意按钮高 24 与 [DesktopTokens.controlHeight] 28 **不同**:桌面工具包里
/// 按钮总比单行编辑框高一档(VCL 24/20、WinForms 25/21),所以两者必须能分开。
///
/// 另一个必须记住的点:按钮内部的 `Container(alignment: center)` 在**有界宽度**
/// 下会吃掉整行(这是既有行为)。所以测按钮的自身尺寸必须放进 `Row`(给无界宽度),
/// 直接摆在 `Align`/`Column` 里量到的是父级宽度。
void main() {
  const t = DesktopTokens.winForm;

  Widget host(Widget child) => MaterialApp(
        home: Material(
          type: MaterialType.transparency,
          child: TokenScope(
            tokens: t,
            // 竖向可滚动 => 高度方向无界,按钮才会按内容定高
            // (按钮内部的 Container(alignment:) 在有界高度下会吃满整屏)
            child: SingleChildScrollView(
              child: Align(
                alignment: Alignment.topLeft,
                child: Row(mainAxisSize: MainAxisSize.min, children: [child]),
              ),
            ),
          ),
        ),
      );

  testWidgets('按钮高度与实测同档(24,不再是 controlHeight 28)', (tester) async {
    await tester.pumpWidget(host(Button(text: '确定', onPressed: () {})));
    expect(tester.getSize(find.byType(Button)).height, 24);
  });

  testWidgets('短文字按钮吃最小宽度(73),长文字按钮按内容撑开', (tester) async {
    // winForm 令牌:fontSize 13 → 每个 CJK 字形宽 13(测试字体为等宽方块)
    await tester.pumpWidget(host(const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Button(text: '确定', onPressed: null),
        Button(text: '取消', onPressed: null),
        Button(text: '测试连接', onPressed: null),
      ],
    )));

    final sizes = List.generate(
        3, (i) => tester.getSize(find.byType(Button).at(i)));
    expect(sizes[0].width, 73, reason: '2 字标签也要占满按钮列(实测 73)');
    expect(sizes[1].width, 73);
    expect(sizes[2].width, greaterThan(73),
        reason: '4 字标签按内容撑开,超过最小宽度 73');
  });

  testWidgets('带 child 的按钮(工具条 / 图标按钮)不受最小宽度约束', (tester) async {
    await tester.pumpWidget(host(Button(
      text: '×',
      onPressed: () {},
      child: const SizedBox(width: 20, height: 20),
    )));
    expect(tester.getSize(find.byType(Button)).width, lessThan(60),
        reason: '工具条按钮按内容自适应,不能被 73 撑破窄面板');
  });

  testWidgets('对话框底条带分隔线,按钮不再贴到对话框底边', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Material(
        type: MaterialType.transparency,
        child: TokenScope(
          tokens: t,
          child: const DialogBox(
            title: '连接属性',
            width: 400,
            onClose: null,
            footer: Row(children: [Button(text: '确定', onPressed: null)]),
            child: SizedBox(height: 40),
          ),
        ),
      ),
    ));
    final shell = tester.getSize(find
        .descendant(
          of: find.byType(DialogBox),
          matching: find.byType(IntrinsicWidth),
        )
        .first);
    // 标题栏 28+4*2=36 / body 40 / 底条 = 分隔线 1 + 上下内边距 9*2 + 按钮 24
    expect(shell.height, closeTo(36 + 40 + 1 + 9 * 2 + 24, 0.5),
        reason: '底条把按钮托起来,不再直接贴在对话框底边(旧版只有 8 的内边距、无底色)');
    // 按钮在底条内水平方向留出 padding(compactSpacing*2+2 = 10)
    final shellRect = tester.getRect(find
        .descendant(
          of: find.byType(DialogBox),
          matching: find.byType(IntrinsicWidth),
        )
        .first);
    final btnRect = tester.getRect(find.byType(Button));
    expect(btnRect.left - shellRect.left, closeTo(10, 0.5));
    expect(shellRect.bottom - btnRect.bottom, closeTo(9, 0.5),
        reason: '底条下内边距 9,按钮不贴对话框底边');
  });

  // ── 热态 / 按下态配色(参考实测 @2x 截图:悬浮 #E0EEF9 面 + #0078D4 边,
  //    常态 #FDFDFD 面 + #D0D0D0 边,下边框恒比其它三边暗 ~10.5%)──────────

  testWidgets('悬浮态染强调色,而不是把中性面色压暗', (tester) async {
    await tester.pumpWidget(host(Button(text: '确定', onPressed: () {})));
    final normal = decorationOf(tester);
    expect(normal.color, t.buttonFaceColor);

    await hover(tester);
    final hovered = decorationOf(tester);
    expect(hovered.color, t.buttonHoverFaceColor);

    // 病根守卫:把中性灰面压暗只会得到"更灰",三通道依旧相等;
    // 参考的悬浮态是染上强调色的浅蓝(蓝通道明显高于红通道)。
    Color face(BoxDecoration d) => d.color!;
    expect(face(normal).r, face(normal).b, reason: '常态是中性面色');
    expect(face(hovered).b, greaterThan(face(hovered).r + 0.02),
        reason: '悬浮必须偏蓝(染强调色),否则就是回到"越悬停越灰"');
    expect(face(hovered).g, greaterThan(face(hovered).r),
        reason: '参考 #E0EEF9:g 也高于 r');

    // 边线跟着一起换:只换面不换边会留下一条"没跟上"的灰轮廓
    final border = hovered.border! as Border;
    expect(border.top.color, t.buttonHoverBorderColor);
    expect(border.top.color, isNot(t.buttonBorderColor));
  });

  testWidgets('按下态比悬浮态再深一档,边线同步加深', (tester) async {
    await tester.pumpWidget(host(Button(text: '确定', onPressed: () {})));
    await hover(tester);
    final hovered = decorationOf(tester);

    final gesture = await pressDown(tester);
    final pressed = decorationOf(tester);
    addTearDown(gesture.up);

    expect(pressed.color, t.buttonPressedFaceColor);
    expect(_luminance(pressed.color!), lessThan(_luminance(hovered.color!)),
        reason: '按下比悬浮更深');
    final border = pressed.border! as Border;
    expect(border.top.color, t.buttonPressedBorderColor);
    expect(_luminance(border.top.color),
        lessThan(_luminance((hovered.border! as Border).top.color)),
        reason: '按下边线也要比悬浮更深(只换面不换边会留下灰轮廓)');
  });

  testWidgets('下边框比其它三边暗约 10.5%(桌面按钮的 3D 下缘)', (tester) async {
    // 参考实测:常态 #D0D0D0 → 下缘 #BABABA,悬浮 #0078D4 → 下缘 #006BBE,
    // 两条比例都是暗 ~10.5%,所以组件里用同一个 0x1B000000 现算。
    const shade = Color(0x1B000000);
    await tester.pumpWidget(host(Button(text: '确定', onPressed: () {})));

    for (final state in ['常态', '悬浮', '按下']) {
      if (state == '悬浮') await hover(tester);
      if (state == '按下') {
        final g = await pressDown(tester);
        addTearDown(g.up);
      }
      final border = decorationOf(tester).border! as Border;
      expect(border.bottom.color,
          Color.alphaBlend(shade, border.top.color),
          reason: '$state:下边框应为上边框色加暗 ~10.5%');
      expect(_luminance(border.bottom.color),
          lessThan(_luminance(border.top.color)));
      expect(border.left.color, border.top.color);
      expect(border.right.color, border.top.color,
          reason: '只有下缘被加暗,左右与上边同色');
    }
  });
}

/// 按钮外框的装饰(Button 内部只有一个 Container)。
BoxDecoration decorationOf(WidgetTester tester) {
  final container = tester.widget<Container>(find.descendant(
    of: find.byType(Button),
    matching: find.byType(Container),
  ));
  return container.decoration! as BoxDecoration;
}

/// 把鼠标移进按钮(触发 MouseRegion 的 onEnter)。
Future<void> hover(WidgetTester tester) async {
  final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await gesture.addPointer(location: Offset.zero);
  addTearDown(gesture.removePointer);
  await tester.pump();
  await gesture.moveTo(tester.getCenter(find.byType(Button)));
  await tester.pumpAndSettle();
}

/// 在已悬浮的基础上按下鼠标(触发 GestureDetector 的 onTapDown)。
Future<TestGesture> pressDown(WidgetTester tester) async {
  final gesture = await tester.startGesture(
    tester.getCenter(find.byType(Button)),
    kind: PointerDeviceKind.mouse,
  );
  await tester.pumpAndSettle();
  return gesture;
}

double _luminance(Color c) => c.computeLuminance();
