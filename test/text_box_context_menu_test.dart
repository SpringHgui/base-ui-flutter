import 'package:base_ui_flutter/base_ui_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 输入框右键菜单:换成 Win10 风格(本库的 [ContextMenuPanel] 渲染),
/// 不再用 Flutter 自带的 Material 选择工具条。
///
/// 这里验的是替换后仍然成立的两件事:
/// 1. 弹的是本库面板,且四项恒定列出(做不了的置灰,不是隐藏);
/// 2. 动作与关闭仍由 EditableTextState 负责——点「全选」真的全选、面板随即收起。
void main() {
  final l10n = const DefaultMaterialLocalizations();
  final labels = [
    l10n.cutButtonLabel,
    l10n.copyButtonLabel,
    l10n.pasteButtonLabel,
    l10n.selectAllButtonLabel,
  ];

  Future<TextEditingController> pumpInput(
    WidgetTester tester, {
    required String text,
  }) async {
    final controller = TextEditingController(text: text);
    addTearDown(controller.dispose);
    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: 240, child: Input(controller: controller)),
        ),
      ),
    ));
    return controller;
  }

  Future<void> rightClickInField(WidgetTester tester) async {
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(Input)),
      kind: PointerDeviceKind.mouse,
      buttons: kSecondaryButton,
    );
    await gesture.up();
    await tester.pump();
  }

  testWidgets('右键弹的是本库菜单面板,而不是 Material 工具条', (tester) async {
    await pumpInput(tester, text: 'hello world');

    await rightClickInField(tester);

    expect(find.byType(ContextMenuPanel), findsOneWidget);
    expect(find.byType(TextSelectionToolbar), findsNothing);
    // 无选区:四项仍全部列出
    for (final label in labels) {
      expect(find.text(label), findsOneWidget, reason: '$label 应该出现在菜单里');
    }
  });

  testWidgets('点「全选」真的全选文本,并收起菜单', (tester) async {
    final controller = await pumpInput(tester, text: 'hello world');

    await rightClickInField(tester);
    await tester.tap(find.text(l10n.selectAllButtonLabel));
    await tester.pump();

    expect(controller.selection,
        const TextSelection(baseOffset: 0, extentOffset: 11));
    expect(find.byType(ContextMenuPanel), findsNothing);
  });
}
