import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';

/// 宿主:打开 [InputDialog] 并记录 show 的回传结果。
/// 对应 daro 用法:打开需要密码的连接前弹窗补录密码。
class _Host extends StatelessWidget {
  const _Host({required this.args, required this.results});

  final Future<String?> Function(BuildContext context) args;
  final List<String?> results;

  @override
  Widget build(BuildContext context) {
    // 弹层需要 MaterialApp 之下的 context(见 list_picker_dialog_test 同款说明)
    return MaterialApp(
      home: TokenScope(
        tokens: DesktopTokens.winForm,
        child: Scaffold(
          body: Builder(builder: (context) => Center(
                child: Button(
                  text: 'open',
                  onPressed: () async {
                    results.add(await args(context));
                  },
                ),
              )),
        ),
      ),
    );
  }
}

void main() {
  Future<List<String?>> open(
    WidgetTester tester, {
    bool password = true,
    String title = '输入密码',
    String? message,
    String initialValue = '',
  }) async {
    final results = <String?>[];
    await tester.pumpWidget(_Host(
      results: results,
      args: (context) => InputDialog.show(
        context,
        title: title,
        message: message,
        initialValue: initialValue,
        password: password,
        okText: '连接',
        cancelText: '取消',
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return results;
  }

  final field = find.byType(TextField);

  testWidgets('密码模式:输入后点确定回传原文', (tester) async {
    final results =
        await open(tester, password: true, message: '连接「本地库」需要密码:');
    expect(find.text('连接「本地库」需要密码:'), findsOneWidget);

    await tester.enterText(field, 's3cret');
    await tester.pump();
    await tester.tap(find.text('连接'));
    await tester.pumpAndSettle();

    expect(results.single, 's3cret');
    expect(tester.takeException(), isNull);
  });

  testWidgets('密码模式:空输入时确定无效,输入后才可提交', (tester) async {
    final results = await open(tester, password: true);

    // 初始为空:点「连接」不产生任何回传(show 的契约:非 null 必非空)
    await tester.tap(find.text('连接'));
    await tester.pumpAndSettle();
    expect(results, isEmpty);

    await tester.enterText(field, 'x');
    await tester.pump();
    // 清空后再次禁用
    await tester.enterText(field, '');
    await tester.pump();
    await tester.tap(find.text('连接'));
    await tester.pumpAndSettle();
    expect(results, isEmpty);

    await tester.enterText(field, 'pw');
    await tester.pump();
    await tester.tap(find.text('连接'));
    await tester.pumpAndSettle();
    expect(results.single, 'pw');
  });

  testWidgets('回车提交,与点确定等价', (tester) async {
    final results = await open(tester, password: true);

    await tester.enterText(field, 'enter-me');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(results.single, 'enter-me');
  });

  testWidgets('取消回传 null,不写回宿主', (tester) async {
    final results = await open(tester, password: true);

    await tester.enterText(field, 'ignored');
    await tester.pump();
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();

    expect(results.single, isNull);
  });

  testWidgets('非密码模式:允许空提交,initialValue 预填', (tester) async {
    final results =
        await open(tester, password: false, initialValue: 'abc');

    // 预填值直接确定
    await tester.tap(find.text('连接'));
    await tester.pumpAndSettle();
    expect(results.single, 'abc');

    // 清空后仍允许提交空串
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.enterText(field, '');
    await tester.pump();
    await tester.tap(find.text('连接'));
    await tester.pumpAndSettle();
    expect(results.last, '');
  });
}
