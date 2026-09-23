import 'package:base_ui_flutter/base_ui_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<Set<(int, int)> Function()> pumpGrid(
    WidgetTester tester, {
    required ScrollController vertical,
    required ScrollController horizontal,
    int columns = 3,
    double columnWidth = 120,
  }) async {
    var selection = <(int, int)>{};
    await tester.pumpWidget(
      MaterialApp(
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 300,
            height: 240,
            child: SingleChildScrollView(
              controller: horizontal,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 4000,
                child: SizedBox(
                  width: columns * columnWidth,
                  child: DataGridView(
                    columns: [
                      for (var i = 0; i < columns; i++)
                        DataGridViewColumn(title: 'c$i', width: columnWidth),
                    ],
                    rowCount: 200,
                    rowHeight: 20,
                    cellBuilder: (r, c) => Text('$r-$c'),
                    verticalScrollController: vertical,
                    onCellsSelected: (cells) => selection = cells,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return () => selection;
  }

  testWidgets('纵向滚动后拖拽框选命中指针所在的绝对行', (tester) async {
    final v = ScrollController();
    final h = ScrollController();
    final selected = await pumpGrid(tester, vertical: v, horizontal: h);

    v.jumpTo(100); // 5 行
    await tester.pump();

    final listTop = tester.getTopLeft(find.byType(ListView));
    final gesture = await tester.startGesture(
      listTop + const Offset(60, 40), // 视口内第 2 行 → 绝对第 7 行
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();
    await gesture.moveTo(listTop + const Offset(60, 60)); // → 绝对第 8 行
    await tester.pump();
    await gesture.up();
    await tester.pump();

    expect(selected().map((e) => e.$1).toSet(), {7, 8});

    v.dispose();
    h.dispose();
  });

  testWidgets('横向滚动后拖拽框选命中指针所在的绝对列', (tester) async {
    final v = ScrollController();
    final h = ScrollController();
    final selected = await pumpGrid(tester, vertical: v, horizontal: h);

    h.jumpTo(240); // 2 列
    v.jumpTo(100);
    await tester.pump();

    final listTop = tester.getTopLeft(find.byType(ListView));
    final gesture = await tester.startGesture(
      listTop + const Offset(300, 40), // 内容坐标 → 绝对列 2、绝对行 7
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();
    await gesture.moveTo(listTop + const Offset(300, 60));
    await tester.pump();
    await gesture.up();
    await tester.pump();

    expect(selected(), {(7, 2), (8, 2)});

    v.dispose();
    h.dispose();
  });

  testWidgets('框选模式下：单击才触发编辑，拖拽不触发', (tester) async {
    final v = ScrollController();
    final h = ScrollController();
    final taps = <(int, int)>[];
    var selection = <(int, int)>{};
    await tester.pumpWidget(
      MaterialApp(
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 300,
            height: 240,
            child: DataGridView(
              columns: const [
                DataGridViewColumn(title: 'c0', width: 120),
                DataGridViewColumn(title: 'c1', width: 120),
              ],
              rowCount: 200,
              rowHeight: 20,
              cellBuilder: (r, c) => Text('$r-$c'),
              verticalScrollController: v,
              onCellsSelected: (cells) => selection = cells,
              onCellTap: (r, c) => taps.add((r, c)),
            ),
          ),
        ),
      ),
    );

    final listTop = tester.getTopLeft(find.byType(ListView));
    // 单击：按下选中该格，抬起未移动 → 触发一次编辑
    await tester.tapAt(
      listTop + const Offset(60, 10),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();
    expect(selection, {(0, 0)});
    expect(taps, [(0, 0)]);

    // 拖拽框选：选中区域扩大，但不算单击，不应触发编辑
    final gesture = await tester.startGesture(
      listTop + const Offset(60, 30),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();
    await gesture.moveTo(listTop + const Offset(180, 70));
    await tester.pump();
    await gesture.up();
    await tester.pump();
    expect(selection.length, greaterThan(1));
    expect(taps, [(0, 0)], reason: '框选不应进入编辑');

    v.dispose();
    h.dispose();
  });
}
