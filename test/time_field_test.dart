import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';

void main() {
  late DateTime value;
  late List<DateTime> changes;

  Future<void> pumpField(
    WidgetTester tester, {
    DateTime? initial,
    bool enabled = true,
  }) async {
    value = initial ?? DateTime(2022, 12, 12, 10, 20, 30);
    changes = [];
    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: Center(
          child: SizedBox(
            width: 160,
            child: StatefulBuilder(
              builder: (context, setState) => TimeField(
                value: value,
                enabled: enabled,
                autofocus: true,
                onChanged: (v) {
                  changes.add(v);
                  setState(() => value = v);
                },
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  /// 点某一段使其成为当前段
  Future<void> focusSegment(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  String hhmmss(DateTime v) =>
      '${v.hour.toString().padLeft(2, '0')}:${v.minute.toString().padLeft(2, '0')}:${v.second.toString().padLeft(2, '0')}';

  testWidgets('默认当前段是「时」:上下按钮只动小时，时分秒原样回传', (tester) async {
    await pumpField(tester);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('20'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_drop_up));
    await tester.pumpAndSettle();
    expect(hhmmss(value), '11:20:30');

    await tester.tap(find.byIcon(Icons.arrow_drop_down));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.arrow_drop_down));
    await tester.pumpAndSettle();
    expect(hhmmss(value), '09:20:30', reason: '两次向下 = 10-2');
    expect(changes.length, 3);
    expect(value.year, 2022, reason: '日期部分必须原样带回，否则弹窗会改掉日期');
  });

  testWidgets('点「分」段后微调落在分上', (tester) async {
    await pumpField(tester);
    await focusSegment(tester, '20');

    await tester.tap(find.byIcon(Icons.arrow_drop_up));
    await tester.pumpAndSettle();
    expect(hhmmss(value), '10:21:30');

    await focusSegment(tester, '30');
    await tester.tap(find.byIcon(Icons.arrow_drop_up));
    await tester.pumpAndSettle();
    expect(hhmmss(value), '10:21:31', reason: '换段后上一段不再受影响');
  });

  testWidgets('各段按自己的进制回环:23→00、59→00、0→上界', (tester) async {
    await pumpField(tester, initial: DateTime(2022, 12, 12, 23, 0, 59));
    await tester.tap(find.byIcon(Icons.arrow_drop_up));
    await tester.pumpAndSettle();
    expect(hhmmss(value), '00:00:59', reason: '时到顶回 0，不进位到分');

    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(hhmmss(value), '23:00:59', reason: '时到底回 23');

    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(hhmmss(value), '23:00:58', reason: 'End 跳到秒段，向下 = 59-1');

    await pumpField(tester, initial: DateTime(2022, 12, 12, 10, 59, 30));
    await focusSegment(tester, '59');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pumpAndSettle();
    expect(hhmmss(value), '10:00:30', reason: '分到顶回 0，不进位到时');
  });

  testWidgets('← → 切段，↑ ↓ 改当前段', (tester) async {
    await pumpField(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pumpAndSettle();
    expect(hhmmss(value), '10:21:30');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pumpAndSettle();
    expect(hhmmss(value), '11:21:30', reason: '连退两段回到时段');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pumpAndSettle();
    expect(hhmmss(value), '12:21:30', reason: '第一段不能再往左退');
  });

  testWidgets('数字键累加并在装不下第二位时自动前进到下一段', (tester) async {
    await pumpField(tester, initial: DateTime(2022, 12, 12, 0, 0, 0));

    await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
    await tester.pumpAndSettle();
    expect(hhmmss(value), '01:00:00', reason: '先按的 1 当个位');
    await tester.sendKeyEvent(LogicalKeyboardKey.digit7);
    await tester.pumpAndSettle();
    expect(hhmmss(value), '17:00:00', reason: '再按 7 拼成 17');
    expect(value.minute, 0);

    // 17 已吃不下第三位，当前段应自动前进到「分」
    await tester.sendKeyEvent(LogicalKeyboardKey.digit4);
    await tester.pumpAndSettle();
    expect(hhmmss(value), '17:04:00');
    await tester.sendKeyEvent(LogicalKeyboardKey.digit5);
    await tester.pumpAndSettle();
    expect(hhmmss(value), '17:45:00', reason: '分按 10 进制累加');
  });

  testWidgets('拼不出合法值时用新数字重启该段', (tester) async {
    // 小时 2 再按 9 = 29，超出 23，应视作重新输入 9
    await pumpField(tester, initial: DateTime(2022, 12, 12, 2, 0, 0));
    await tester.sendKeyEvent(LogicalKeyboardKey.digit9);
    await tester.pumpAndSettle();
    expect(hhmmss(value), '09:00:00');
  });

  testWidgets('Backspace 退回上一段并把该段清零', (tester) async {
    await pumpField(tester);
    await focusSegment(tester, '30');

    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.pumpAndSettle();
    expect(hhmmss(value), '10:00:30', reason: '从秒段退回，清掉分段');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pumpAndSettle();
    expect(hhmmss(value), '10:01:30', reason: '当前段已退到分');

    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.pumpAndSettle();
    expect(hhmmss(value), '00:01:30', reason: '再按一次退到时段');
  });

  testWidgets('滚轮在控件上直接微调当前段', (tester) async {
    await pumpField(tester);
    final center = tester.getCenter(find.byType(TimeField));

    await tester.sendEventToBinding(PointerScrollEvent(
      position: center,
      scrollDelta: const Offset(0, 40),
    ));
    await tester.pumpAndSettle();
    expect(hhmmss(value), '09:20:30', reason: '向下滚 = 减');

    await tester.sendEventToBinding(PointerScrollEvent(
      position: center,
      scrollDelta: const Offset(0, -40),
    ));
    await tester.pumpAndSettle();
    expect(hhmmss(value), '10:20:30', reason: '向上滚 = 加');
  });

  testWidgets('enabled=false 时按钮、键盘、滚轮全部无效', (tester) async {
    await pumpField(tester, enabled: false);

    await tester.tap(find.byIcon(Icons.arrow_drop_up));
    await tester.sendKeyEvent(LogicalKeyboardKey.digit9);
    await tester.sendEventToBinding(PointerScrollEvent(
      position: tester.getCenter(find.byType(TimeField)),
      scrollDelta: const Offset(0, -40),
    ));
    await tester.pumpAndSettle();

    expect(changes, isEmpty);
    expect(find.text('10'), findsOneWidget);
  });
}
