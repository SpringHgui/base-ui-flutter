import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';

/// Host that opens [ListPickerDialog] and records what `show` resolves to.
/// Mirrors how daro's table designer uses it (picking parent tables to
/// inherit): the dialog itself only selects, the host writes the result back.
class _Host<T> extends StatelessWidget {
  const _Host({
    super.key,
    required this.items,
    required this.results,
    this.selected = const [],
    this.emptyHint,
    this.itemHeader,
    this.itemToString,
  });

  final List<T> items;
  final List<T> selected;
  final String? emptyHint;
  final String? itemHeader;
  final String Function(T item)? itemToString;
  final List<List<T>?> results;

  @override
  Widget build(BuildContext context) {
    // 注意:弹层需要 MaterialApp 之下的 context,故在 home 内用 Builder 取
    // (取 _Host 自身的 context 会位于 MaterialApp 之上,无 MaterialLocalizations)。
    return MaterialApp(
      home: TokenScope(
        tokens: DesktopTokens.winForm,
        child: Scaffold(
          body: Builder(builder: (context) => Center(
                child: Button(
                  text: 'pick',
                  onPressed: () async {
                    results.add(await ListPickerDialog.show<T>(
                      context,
                      title: '选择继承的父表',
                      items: items,
                      selected: selected,
                      emptyHint: emptyHint,
                      itemHeader: itemHeader,
                      itemToString: itemToString,
                      okText: '确定',
                      cancelText: '取消',
                    ));
                  },
                ),
              )),
        ),
      ),
    );
  }
}

void main() {
  /// Pumps [items] and opens the dialog; returns the recorder that `show`
  /// results are pushed into.
  Future<List<List<String>?>> open(
    WidgetTester tester, {
    required List<String> items,
    List<String> selected = const [],
    String? emptyHint,
    String? itemHeader,
  }) async {
    final results = <List<String>?>[];
    await tester.pumpWidget(_Host<String>(
      items: items,
      selected: selected,
      emptyHint: emptyHint,
      itemHeader: itemHeader,
      results: results,
    ));
    await tester.tap(find.text('pick'));
    await tester.pumpAndSettle();
    return results;
  }

  /// Ticks row [i] (the label only marks the row — checking is the box).
  Future<void> check(WidgetTester tester, int i) =>
      tester.tap(find.byType(CheckBox).at(i));

  testWidgets('勾选多项后确定:按候选顺序而非点击顺序回传', (tester) async {
    final results = await open(tester, items: const ['a', 'b', 'c']);

    // 点击顺序 b → a → c,回传顺序仍是候选原顺序 a、b、c
    await check(tester, 1);
    await tester.pump();
    await check(tester, 0);
    await tester.pump();
    await check(tester, 2);
    await tester.pump();
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();

    expect(results.single, ['a', 'b', 'c']);
    expect(find.text('选择继承的父表'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('参考工具形态:单一「名称」列表头 + 行首当前行标记', (tester) async {
    await open(tester, items: const ['a', 'b'], itemHeader: '父表');

    expect(find.text('父表'), findsOneWidget);
    // 第 0 行是打开时的当前行:行首 ▶,其余行没有标记
    expect(find.byIcon(Icons.arrow_right), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);

    await tester.tap(find.text('b'));
    await tester.pump();
    // 点行只把 ▶ 移过去,勾选状态不变(参考工具即如此:单击=当前行)
    expect(
      tester.widgetList<CheckBox>(find.byType(CheckBox)).map((c) => c.value),
      [false, false],
    );
    await check(tester, 1);
    await tester.pump();
    expect(
      tester
          .widgetList<CheckBox>(find.byType(CheckBox))
          .map((c) => c.value)
          .toList(),
      [false, true],
    );

    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
  });

  testWidgets('↑↓ 移动当前行:回传顺序随行的次序走', (tester) async {
    final results = await open(tester, items: const ['a', 'b', 'c']);

    await check(tester, 0);
    await tester.pump();
    await check(tester, 2);
    await tester.pump();
    // 勾选 c 时 ▶ 也停在 c 那一行(点行=置当前行),上移两格 → c 走到 a 之前
    await tester.tap(find.byIcon(Icons.arrow_upward));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.arrow_upward));
    await tester.pump();
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();

    expect(results.single, ['c', 'a']);
  });

  testWidgets('打开时的预勾选项可取消,全部取消后确定回传空列表', (tester) async {
    final results = await open(
      tester,
      items: const ['a', 'b'],
      selected: const ['a', 'b'],
    );

    // 两个候选初始均为勾选态
    expect(
      tester.widgetList<CheckBox>(find.byType(CheckBox)).map((c) => c.value),
      [true, true],
    );

    await check(tester, 0);
    await tester.pump();
    await check(tester, 1);
    await tester.pump();
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();

    expect(results.single, isEmpty);
  });

  testWidgets('取消/关闭回传 null,不写回宿主', (tester) async {
    final results = await open(tester, items: const ['a']);

    await check(tester, 0);
    await tester.pump();
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();

    expect(results.single, isNull);
  });

  testWidgets('无候选时显示 emptyHint 且不渲染列表', (tester) async {
    await open(tester, items: const [], emptyHint: '当前库没有其它表');

    expect(find.text('当前库没有其它表'), findsOneWidget);
    expect(find.byType(ListView), findsNothing);

    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
  });

  testWidgets('itemToString 决定行标签,回传的仍是原对象', (tester) async {
    final results = <List<int>?>[];
    await tester.pumpWidget(_Host<int>(
      items: const [1, 2],
      itemToString: (i) => 'col_$i',
      results: results,
    ));
    await tester.tap(find.text('pick'));
    await tester.pumpAndSettle();

    expect(find.text('col_1'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await check(tester, 1);
    await tester.pump();
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();

    expect(results.single, [2]);
  });
}
