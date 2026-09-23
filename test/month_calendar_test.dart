import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';

void main() {
  late List<DateTime> picked;

  Future<void> pumpCalendar(
    WidgetTester tester, {
    required DateTime displayMonth,
    DateTime? selectedDate,
    DateTime? minDate,
    DateTime? maxDate,
    bool enabled = true,
  }) async {
    picked = [];
    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: Center(
          child: SizedBox(
            width: 264,
            child: MonthCalendar(
              displayMonth: displayMonth,
              selectedDate: selectedDate,
              minDate: minDate,
              maxDate: maxDate,
              enabled: enabled,
              onDateSelected: picked.add,
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('点顶栏标题逐级下钻:日 → 月 → 年 → 回日', (tester) async {
    await pumpCalendar(tester, displayMonth: DateTime(2022, 12));

    expect(find.text('Dec 2022'), findsOneWidget);
    expect(find.text('Jan'), findsNothing, reason: '日视图不该出现月名格');

    await tester.tap(find.text('Dec 2022'));
    await tester.pumpAndSettle();
    expect(find.text('2022'), findsOneWidget, reason: '月视图标题是年份');
    for (final m in ['Jan', 'Jun', 'Dec']) {
      expect(find.text(m), findsOneWidget);
    }
    expect(find.text('25'), findsNothing, reason: '月视图已换掉日格');

    await tester.tap(find.text('2022'));
    await tester.pumpAndSettle();
    expect(find.text('2016 - 2027'), findsOneWidget,
        reason: '2022 落在 12 年一档的 2016..2027');
    expect(find.text('2016'), findsOneWidget);
    expect(find.text('2027'), findsOneWidget);
    expect(find.text('2028'), findsNothing, reason: '一档只有 12 年');

    await tester.tap(find.text('2016 - 2027'));
    await tester.pumpAndSettle();
    expect(find.text('Dec 2022'), findsOneWidget, reason: '第三下回到日视图');
    expect(find.text('25'), findsOneWidget);
  });

  testWidgets('月视图选月、年视图选年都会落到目标月并回退一级', (tester) async {
    await pumpCalendar(tester, displayMonth: DateTime(2022, 12));

    await tester.tap(find.text('Dec 2022'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mar'));
    await tester.pumpAndSettle();
    expect(find.text('Mar 2022'), findsOneWidget,
        reason: '选完月份回到日视图且停在所选月');

    await tester.tap(find.text('Mar 2022'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2022'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2019'));
    await tester.pumpAndSettle();
    expect(find.text('2019'), findsOneWidget, reason: '选完年份回到月视图');
    await tester.tap(find.text('Jul'));
    await tester.pumpAndSettle();
    expect(find.text('Jul 2019'), findsOneWidget);
  });

  testWidgets('箭头在当前视图上步进一档:月 / 年 / 12 年', (tester) async {
    await pumpCalendar(tester, displayMonth: DateTime(2022, 12));

    await tester.tap(find.byIcon(Icons.arrow_right));
    await tester.pumpAndSettle();
    expect(find.text('Jan 2023'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_left));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_left));
    await tester.pumpAndSettle();
    expect(find.text('Nov 2022'), findsOneWidget, reason: '连退两步到 11 月');

    await tester.tap(find.text('Nov 2022'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_right));
    await tester.pumpAndSettle();
    expect(find.text('2023'), findsOneWidget, reason: '月视图步进一年');

    await tester.tap(find.text('2023'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_left));
    await tester.pumpAndSettle();
    expect(find.text('2004 - 2015'), findsOneWidget,
        reason: '年视图按整档跳到上一档');
  });

  testWidgets('点邻月的日子:回调该日期并翻到所属月', (tester) async {
    // 2022-12-01 是周四，网格从 11-28 起铺 42 格，故 '30' 命中 11-30 与 12-30
    await pumpCalendar(tester, displayMonth: DateTime(2022, 12));

    await tester.tap(find.text('30').first);
    await tester.pumpAndSettle();

    expect(picked, [DateTime(2022, 11, 30)]);
    expect(find.text('Nov 2022'), findsOneWidget, reason: '选邻月日子后翻到该月');
  });

  testWidgets('越界的日子点不动', (tester) async {
    await pumpCalendar(
      tester,
      displayMonth: DateTime(2022, 12),
      minDate: DateTime(2022, 12, 10),
      maxDate: DateTime(2022, 12, 20),
    );

    await tester.tap(find.text('25'));
    await tester.tap(find.text('9'));
    await tester.pumpAndSettle();
    expect(picked, isEmpty, reason: '区间外的日不得触发选择');

    await tester.tap(find.text('15'));
    await tester.pumpAndSettle();
    expect(picked, [DateTime(2022, 12, 15)]);
  });

  testWidgets('区间把整月 / 整年也一起禁用', (tester) async {
    await pumpCalendar(
      tester,
      displayMonth: DateTime(2022, 12),
      minDate: DateTime(2022, 12),
      maxDate: DateTime(2022, 12, 31),
    );

    await tester.tap(find.text('Dec 2022'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Jan'));
    await tester.pumpAndSettle();
    expect(find.text('Jan 2023'), findsNothing,
        reason: '2023 年在区间外，月格不可点(仍停在月视图)');
    expect(find.text('2022'), findsOneWidget);

    await tester.tap(find.text('2022'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2016'));
    await tester.pumpAndSettle();
    expect(find.text('2016 - 2027'), findsOneWidget,
        reason: '2016 年整年在区间外，不可选');
  });

  testWidgets('底部今天行只在日视图出现', (tester) async {
    await pumpCalendar(tester, displayMonth: DateTime(2022, 12));
    expect(find.textContaining('Today:'), findsOneWidget);

    await tester.tap(find.text('Dec 2022'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Today:'), findsNothing);
  });

  testWidgets('enabled=false 时标题与日子都不响应', (tester) async {
    await pumpCalendar(tester,
        displayMonth: DateTime(2022, 12), enabled: false);

    await tester.tap(find.text('Dec 2022'));
    await tester.tap(find.text('25'));
    await tester.pumpAndSettle();

    expect(find.text('Dec 2022'), findsOneWidget, reason: '仍在日视图');
    expect(picked, isEmpty);
  });
}
