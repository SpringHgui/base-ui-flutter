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
    this.itemToString,
  });

  final List<T> items;
  final List<T> selected;
  final String? emptyHint;
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
  }) async {
    final results = <List<String>?>[];
    await tester.pumpWidget(_Host<String>(
      items: items,
      selected: selected,
      emptyHint: emptyHint,
      results: results,
    ));
    await tester.tap(find.text('pick'));
    await tester.pumpAndSettle();
    return results;
  }

  testWidgets('勾选多项后确定:按候选顺序而非点击顺序回传', (tester) async {
    final results = await open(tester, items: const ['a', 'b', 'c']);

    // 点击顺序 b → a → c,回传顺序仍是候选原顺序 a、b、c
    await tester.tap(find.text('b'));
    await tester.pump();
    await tester.tap(find.text('a'));
    await tester.pump();
    await tester.tap(find.text('c'));
    await tester.pump();
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();

    expect(results.single, ['a', 'b', 'c']);
    expect(find.text('选择继承的父表'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('打开时的预勾选项可取消,全部取消后确定回传空列表', (tester) async {
    final results = await open(
      tester,
      items: const ['a', 'b'],
      selected: const ['a', 'b'],
    );

    // 两个候选初始均为勾选态
    final box =
        tester.widget<CheckedListBox<String>>(find.byType(CheckedListBox<String>));
    expect(box.checkedIndices, {0, 1});

    await tester.tap(find.text('a'));
    await tester.pump();
    await tester.tap(find.text('b'));
    await tester.pump();
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();

    expect(results.single, isEmpty);
  });

  testWidgets('取消/关闭回传 null,不写回宿主', (tester) async {
    final results = await open(tester, items: const ['a']);

    await tester.tap(find.text('a'));
    await tester.pump();
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();

    expect(results.single, isNull);
  });

  testWidgets('无候选时显示 emptyHint 且不渲染列表', (tester) async {
    await open(tester, items: const [], emptyHint: '当前库没有其它表');

    expect(find.text('当前库没有其它表'), findsOneWidget);
    expect(find.byType(CheckedListBox<String>), findsNothing);

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

    await tester.tap(find.text('col_2'));
    await tester.pump();
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();

    expect(results.single, [2]);
  });
}
