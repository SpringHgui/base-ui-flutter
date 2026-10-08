import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';

/// ghost 按钮的**聚焦态不得铺底色**。
///
/// 焦点是输入焦点、选中是状态，两种语义不能共用一种画法：宿主工具条 / ribbon
/// 上「当前模式」通常自己铺一层强调色浅底（daro ribbon = accent 16% 叠 control），
/// 而 ghost 聚焦原先叠的是 primaryColor 14% 同一族浅底，肉眼分不出，
/// 于是同一排出现两个看着都被点中的按钮。
void main() {
  const t = DesktopTokens.winForm;

  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: TokenScope(tokens: t, child: Row(children: [child])),
            ),
          ),
        ),
      );

  BoxDecoration deco(WidgetTester tester, int index) => (tester
          .widget<Container>(find
              .descendant(
                  of: find.byType(Button), matching: find.byType(Container))
              .at(index))
          .decoration as BoxDecoration);

  testWidgets('ghost 聚焦：只有描边，底色保持透明', (tester) async {
    final node = FocusNode();
    await pump(tester, Button(
      text: 'a',
      variant: ButtonVariant.ghost,
      focusNode: node,
      onPressed: () {},
    ));
    expect(deco(tester, 0).color, Colors.transparent);

    node.requestFocus();
    await tester.pump();
    final d = deco(tester, 0);
    expect(d.color, Colors.transparent,
        reason: '聚焦底色会与宿主的选中底色撞色，两者都必须是浅蓝底时才成立');
    expect((d.border as Border).top.color, t.primaryColor);
  });

  testWidgets('ghost 常态 / 悬浮仍按原样区分', (tester) async {
    await pump(tester, Button(
      text: 'a',
      variant: ButtonVariant.ghost,
      onPressed: () {},
    ));
    expect(deco(tester, 0).color, Colors.transparent);

    final hover = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await hover.addPointer(location: Offset.zero);
    await tester.pump();
    await hover.moveTo(tester.getCenter(find.byType(Button)));
    await tester.pump();
    expect(deco(tester, 0).color,
        Color.alphaBlend(t.hoverOverlayColor, t.controlColor));
  });

  testWidgets('solid 变体不受影响：聚焦仍换成强调色边', (tester) async {
    final node = FocusNode();
    await pump(tester, Button(
      text: 'a',
      focusNode: node,
      onPressed: () {},
    ));
    node.requestFocus();
    await tester.pump();
    final d = deco(tester, 0);
    expect((d.border as Border).top.color, t.primaryColor);
    expect(d.color, t.buttonFaceColor, reason: '实心底由面色承担，与聚焦无关');
  });
}
