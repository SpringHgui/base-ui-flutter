import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';

/// 守护 [Textarea] 的 readOnly:只读承载「内容」(渲染出来的 JSON、生成的脚本)时,
/// 文字必须仍然可以聚焦 / 拖选 / 复制。`enabled: false` 做不到 ——
/// Material 的 TextField 在禁用态整块忽略指针,等于让用户只能看。
void main() {
  Widget wrap(Widget child) => MaterialApp(
        home: TokenScope(
          tokens: DesktopTokens.winForm,
          child: Scaffold(
            body: SizedBox(width: 320, height: 200, child: child),
          ),
        ),
      );

  final field = find.byType(EditableText);

  testWidgets('readOnly 拒绝输入,原文一个字符不动', (tester) async {
    final controller = TextEditingController(text: 'hello world');
    await tester.pumpWidget(
        wrap(Textarea(controller: controller, readOnly: true)));

    await tester.enterText(field, 'nope');
    await tester.pump();

    expect(controller.text, 'hello world');
  });

  testWidgets('readOnly 仍可拖选,选区落在文本上', (tester) async {
    final controller = TextEditingController(text: 'hello world');
    await tester.pumpWidget(
        wrap(Textarea(
            controller: controller, readOnly: true, minLines: 1, maxLines: 1)));

    final box = tester.renderObject<RenderBox>(field);
    final from = box.localToGlobal(Offset(box.size.width / 4, box.size.height / 2));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: from);
    await mouse.down(from); // addPointer 只登记指针,按下要显式 down
    await mouse.moveTo(from + const Offset(120, 0));
    await mouse.up();
    await tester.pumpAndSettle();

    // 读 EditableText 的现值,而不是 controller.selection:纯选区变化
    // 在未挂输入连接时未必回写到 controller。
    final sel = tester
        .state<EditableTextState>(field)
        .textEditingValue
        .selection;
    expect(sel.isValid && sel.end > sel.start, isTrue,
        reason: '只读框拿不到选区就等于不能复制');
  });

  testWidgets('默认可编辑(不传 readOnly 时行为不变)', (tester) async {
    final controller = TextEditingController(text: 'a');
    await tester.pumpWidget(wrap(Textarea(controller: controller)));

    await tester.enterText(field, 'ab');
    await tester.pump();

    expect(controller.text, 'ab');
  });
}
