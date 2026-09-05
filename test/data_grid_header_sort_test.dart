import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';

/// 表头两种拖拽手势的路由：标题区横向拖动 = 排序，右缘 6px = 改列宽，
/// 并验证外层横向 SingleChildScrollView 不会抢走表头的拖动手势。
void main() {
  const columns = [
    DataGridViewColumn(title: 'A', width: 100),
    DataGridViewColumn(title: 'B', width: 100),
    DataGridViewColumn(title: 'C', width: 100),
  ];

  Widget harness(Widget grid, {double viewportWidth = 320, ScrollController? horizontal}) {
    return MaterialApp(
      home: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: viewportWidth,
          height: 240,
          child: horizontal == null
              ? grid
              : SingleChildScrollView(
                  controller: horizontal,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(width: 300, child: grid),
                ),
        ),
      ),
    );
  }

  /// 表头标题的命中点：第 col 列水平中点、垂直中点
  Offset headerPoint(WidgetTester tester, int col) =>
      tester.getTopLeft(find.byType(DataGridView)) + Offset(col * 100 + 50, 10);

  Future<void> dragFrom(WidgetTester tester, Offset from, double dx) async {
    final g = await tester.startGesture(from, kind: PointerDeviceKind.mouse);
    await tester.pump();
    for (var i = 1; i <= 4; i++) {
      await g.moveTo(from + Offset(dx * i / 4, 0));
      await tester.pump();
    }
    await g.up();
    await tester.pump();
  }

  testWidgets('向右拖列头标题 = 升序，向左拖 = 降序', (tester) async {
    final sortCalls = <(int, bool)>[];
    await tester.pumpWidget(harness(DataGridView(
      columns: columns,
      rowCount: 20,
      rowHeight: 20,
      cellBuilder: (r, c) => Text('$r$c'),
      onHeaderSort: (col, asc) => sortCalls.add((col, asc)),
    )));

    await dragFrom(tester, headerPoint(tester, 0), 60);
    expect(sortCalls, [(0, true)], reason: '向右拖应触发升序');

    await dragFrom(tester, headerPoint(tester, 1), -60);
    expect(sortCalls.last, (1, false), reason: '向左拖应触发降序');
  });

  testWidgets('不足阈值的微拖不触发排序', (tester) async {
    var called = 0;
    await tester.pumpWidget(harness(DataGridView(
      columns: columns,
      rowCount: 20,
      rowHeight: 20,
      cellBuilder: (r, c) => Text('$r$c'),
      onHeaderSort: (col, asc) => called++,
    )));

    await dragFrom(tester, headerPoint(tester, 0), 5);
    expect(called, 0, reason: '手抖一下不应让宿主重查数据');
  });

  testWidgets('拖动中实时预示方向箭头，松手后消失', (tester) async {
    await tester.pumpWidget(harness(DataGridView(
      columns: columns,
      rowCount: 20,
      rowHeight: 20,
      cellBuilder: (r, c) => Text('$r$c'),
      onHeaderSort: (col, asc) {},
    )));
    final start = headerPoint(tester, 0);
    final g = await tester.startGesture(start, kind: PointerDeviceKind.mouse);
    await tester.pump();
    await g.moveTo(start + const Offset(60, 0));
    await tester.pump();
    expect(find.byIcon(Icons.arrow_upward), findsOneWidget,
        reason: '拖动中应实时显示将应用的方向');
    await g.up();
    await tester.pump();
    expect(find.byIcon(Icons.arrow_upward), findsNothing);
  });

  testWidgets('sortColumn / sortAscending 渲染常驻排序箭头', (tester) async {
    await tester.pumpWidget(harness(DataGridView(
      columns: columns,
      rowCount: 20,
      rowHeight: 20,
      cellBuilder: (r, c) => Text('$r$c'),
      sortColumn: 1,
      sortAscending: false,
    )));
    expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
    expect(find.byIcon(Icons.arrow_upward), findsNothing);
  });

  testWidgets('拖列头右缘边框改列宽，不误触排序', (tester) async {
    final resizes = <(int, double)>[];
    final sortCalls = <(int, bool)>[];
    await tester.pumpWidget(harness(DataGridView(
      columns: columns,
      rowCount: 20,
      rowHeight: 20,
      cellBuilder: (r, c) => Text('$r$c'),
      columnWidths: const [100, 100, 100],
      onHeaderSort: (col, asc) => sortCalls.add((col, asc)),
      onColumnResize: (col, w) => resizes.add((col, w)),
    )));
    // resize 命中区贴在 A 列内侧最后 8px(约 x=92~99),取其中点起拖
    final border =
        tester.getTopLeft(find.byType(DataGridView)) + const Offset(96, 10);

    await dragFrom(tester, border, 40);
    expect(resizes, isNotEmpty, reason: '边框拖动应改列宽');
    expect(resizes.last.$1, 0);
    expect(resizes.last.$2, greaterThan(100));
    expect(sortCalls, isEmpty, reason: '改列宽不应触发排序');
  });

  testWidgets('外层横向滚动容器不抢走表头拖动手势', (tester) async {
    final h = ScrollController();
    final sortCalls = <(int, bool)>[];
    await tester.pumpWidget(harness(
      DataGridView(
        columns: columns,
        rowCount: 20,
        rowHeight: 20,
        cellBuilder: (r, c) => Text('$r$c'),
        onHeaderSort: (col, asc) => sortCalls.add((col, asc)),
      ),
      viewportWidth: 200,
      horizontal: h,
    ));

    await dragFrom(tester, headerPoint(tester, 0), 60);
    expect(sortCalls, [(0, true)], reason: '表头拖动应优先于网格横向滚动');
    expect(h.offset, 0, reason: '排序拖动不应连带滚动网格');
    h.dispose();
  });
}
