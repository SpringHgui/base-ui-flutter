import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';

/// 守护 [Input] 与 [ImeSuppression] 的接线:
/// 密码框(obscureText)获焦关输入法、失焦还原;普通框不碰;宿主没注入时静默。
void main() {
  tearDown(() => ImeSuppression.handler = null);

  Widget wrap(Widget child) => MaterialApp(
        home: TokenScope(
          tokens: DesktopTokens.winForm,
          child: Scaffold(body: child),
        ),
      );

  testWidgets('密码框获焦关输入法、失焦还原', (tester) async {
    final calls = <bool>[];
    ImeSuppression.handler = calls.add;
    final focus = FocusNode();
    await tester.pumpWidget(wrap(Input(focusNode: focus, obscureText: true)));
    expect(calls, isEmpty, reason: '未获焦不应动输入法');

    focus.requestFocus();
    await tester.pump();
    expect(calls, [true]);

    focus.unfocus();
    await tester.pump();
    expect(calls, [true, false]);
    focus.dispose();
  });

  testWidgets('普通输入框不碰输入法', (tester) async {
    final calls = <bool>[];
    ImeSuppression.handler = calls.add;
    final focus = FocusNode();
    await tester.pumpWidget(wrap(Input(focusNode: focus)));
    focus.requestFocus();
    await tester.pump();
    focus.unfocus();
    await tester.pump();
    expect(calls, isEmpty);
    focus.dispose();
  });

  testWidgets('宿主未注入 handler 时不报错(退回旧行为)', (tester) async {
    ImeSuppression.handler = null;
    final focus = FocusNode();
    await tester.pumpWidget(wrap(Input(focusNode: focus, obscureText: true)));
    focus.requestFocus();
    await tester.pump();
    focus.unfocus();
    await tester.pump();
    focus.dispose();
  });

  testWidgets('获焦期间销毁密码框会还原输入法', (tester) async {
    final calls = <bool>[];
    ImeSuppression.handler = calls.add;
    final focus = FocusNode();
    await tester.pumpWidget(wrap(Input(focusNode: focus, obscureText: true)));
    focus.requestFocus();
    await tester.pump();
    expect(calls, [true]);
    // 直接拆树(模拟密码框获焦时窗口被关):dispose 必须补一次 restore,
    // 否则输入法被永久解绑,之后所有输入框都打不了中文。
    await tester.pumpWidget(wrap(const SizedBox.shrink()));
    await tester.pump();
    expect(calls, [true, false]);
    focus.dispose();
  });
}
