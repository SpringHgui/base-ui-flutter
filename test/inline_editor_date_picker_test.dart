import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';

void main() {
  const zhLabels = DateTimePickerLabels(
    ok: '确定',
    cancel: '取消',
    time: '时间',
    selectTime: '选择时间',
    hour: '时',
    minute: '分',
    second: '秒',
    weekdayLabels: ['周一', '周二', '周三', '周四', '周五', '周六', '周日'],
  );

  late List<String> changes;
  late List<String> commits;

  Future<void> pumpEditor(
    WidgetTester tester, {
    required String initialValue,
    DateTimePickerMode? mode,
  }) async {
    changes = [];
    commits = [];
    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 260,
            child: InlineEditor(
              // InlineEditor 的初值只在建 State 时取一次，换用例时强制重建
              key: ValueKey('$initialValue:$mode'),
              initialValue: initialValue,
              datePickerMode: mode,
              datePickerLabels: zhLabels,
              onChanged: changes.add,
              onCommit: commits.add,
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('datePickerMode 为 null 时字段内没有按钮(行为与旧版一致)',
      (tester) async {
    await pumpEditor(tester, initialValue: 'abc', mode: null);
    expect(find.byIcon(Icons.calendar_today), findsNothing);
    expect(find.byIcon(Icons.access_time), findsNothing);
  });

  testWidgets('dateTime 模式:日历按钮开弹窗,选日后写回文本且不提交',
      (tester) async {
    await pumpEditor(
      tester,
      initialValue: '2022-12-12 20:13:06',
      mode: DateTimePickerMode.dateTime,
    );
    expect(find.byIcon(Icons.calendar_today), findsOneWidget);

    await tester.tap(find.byIcon(Icons.calendar_today));
    await tester.pumpAndSettle();

    // 弹窗文案跟随宿主传入的语言
    expect(find.text('确定'), findsOneWidget);
    expect(find.text('取消'), findsOneWidget);
    expect(find.text('周一'), findsOneWidget);
    // 打开弹窗会抢焦点:此时绝不能触发「失焦即提交」
    expect(commits, isEmpty, reason: '选值期间编辑器必须仍在编辑态');

    await tester.tap(find.text('25'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();

    expect(changes.last, '2022-12-25 20:13:06',
        reason: '只换日期,时分秒沿用单元格原值');
    expect(commits, isEmpty, reason: '选完值仍是编辑态,交给 Enter / 失焦提交');
  });

  testWidgets('取消弹窗不改文本', (tester) async {
    await pumpEditor(
      tester,
      initialValue: '2022-12-12 20:13:06',
      mode: DateTimePickerMode.dateTime,
    );
    await tester.tap(find.byIcon(Icons.calendar_today));
    await tester.pumpAndSettle();
    await tester.tap(find.text('25'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();

    expect(changes, isEmpty);
    expect(find.text('2022-12-12 20:13:06'), findsOneWidget);
  });

  testWidgets('date 模式只写日期,time 模式用时钟按钮且只写时间', (tester) async {
    await pumpEditor(
      tester,
      initialValue: '2022-12-12',
      mode: DateTimePickerMode.date,
    );
    await tester.tap(find.byIcon(Icons.calendar_today));
    await tester.pumpAndSettle();
    await tester.tap(find.text('25'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();
    expect(changes.last, '2022-12-25');

    await pumpEditor(
      tester,
      initialValue: '20:13:06',
      mode: DateTimePickerMode.time,
    );
    expect(find.byIcon(Icons.access_time), findsOneWidget);
    await tester.tap(find.byIcon(Icons.access_time));
    await tester.pumpAndSettle();
    expect(find.text('选择时间'), findsOneWidget);
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();
    // 原样确认应一字不改:若秒被清零就会写成 20:13:00 并触发一次变更
    expect(changes, isEmpty, reason: '时/分/秒全部沿用单元格原值');
    expect(find.text('20:13:06'), findsOneWidget);
  });

  testWidgets('空文本也能开弹窗(从当前时刻起算)', (tester) async {
    await pumpEditor(tester, initialValue: '', mode: DateTimePickerMode.date);
    await tester.tap(find.byIcon(Icons.calendar_today));
    await tester.pumpAndSettle();
    expect(find.text('确定'), findsOneWidget);
  });

  group('文本 ↔ 值', () {
    test('parseDateTimeField 认库内格式与裸时间', () {
      expect(parseDateTimeField('2022-12-12 20:13:06'),
          DateTime(2022, 12, 12, 20, 13, 6));
      expect(parseDateTimeField('2022-12-12'), DateTime(2022, 12, 12));
      final bare = parseDateTimeField('20:13:06')!;
      final now = DateTime.now();
      expect(
          DateTime(bare.year, bare.month, bare.day),
          DateTime(now.year, now.month, now.day),
          reason: '裸时间锚到今天,只用于取时分秒');
      expect((bare.hour, bare.minute, bare.second), (20, 13, 6));
      expect(parseDateTimeField(''), isNull);
      expect(parseDateTimeField('NULL'), isNull);
    });

    test('formatDateTimeByMode 按模式定宽输出', () {
      final dt = DateTime(2022, 1, 2, 3, 4, 5);
      expect(formatDateTimeByMode(dt, DateTimePickerMode.date), '2022-01-02');
      expect(formatDateTimeByMode(dt, DateTimePickerMode.time), '03:04:05');
      expect(
          formatDateTimeByMode(dt, DateTimePickerMode.dateTime),
          '2022-01-02 03:04:05');
    });
  });
}
