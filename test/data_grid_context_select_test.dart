import 'package:base_ui_flutter/base_ui_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 右键的「先让落点成为选中目标,再弹菜单」口径(`DataGridView.onCellContext` 契约)。
///
/// 守护的是宿主能不能在菜单回调里直接读选中态:右键落在选区外必须收缩到那一个
/// 目标(否则「置空 / 复制」打在别的格上),落在选区内必须整批保留(否则批量项
/// 被自己的一下右键拆掉)。
void main() {
  Future<_Probe> pumpGrid(
    WidgetTester tester, {
    Set<(int, int)> selectedCells = const {},
    Set<int> selectedRows = const {},
    bool showRowNumbers = false,
  }) async {
    final probe = _Probe();
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
              rowCount: 20,
              rowHeight: 20,
              cellBuilder: (r, c) => Text('$r-$c'),
              showRowNumbers: showRowNumbers,
              selectedCells: selectedCells,
              selectedRows: selectedRows,
              onCellsSelected: (cells) =>
                  probe.selectionCalls.add(cells),
              onRowSelected: (row) => probe.rowCalls.add(row),
              onCellTap: (r, c) => probe.tapCalls.add((r, c)),
              onCellContext: (row, col, position) {
                probe.contextCalls.add((row, col));
                // 记下回调发生时已同步过几次选中:>0 才证明「先选中、后弹菜单」
                probe.selectionCallsAtContext = probe.selectionCalls.length;
              },
            ),
          ),
        ),
      ),
    );
    return probe;
  }

  Future<void> rightClickRow(WidgetTester tester, int row) async {
    final listTop = tester.getTopLeft(find.byType(ListView));
    await tester.startGesture(
      listTop + Offset(11, row * 20.0 + 10), // 行号槽宽 22,取中点
      kind: PointerDeviceKind.mouse,
      buttons: kSecondaryMouseButton,
    );
    await tester.pump();
  }

  Future<void> rightClickCell(WidgetTester tester, int row, int col) async {
    final listTop = tester.getTopLeft(find.byType(ListView));
    await tester.startGesture(
      listTop + Offset(col * 120.0 + 60, row * 20.0 + 10),
      kind: PointerDeviceKind.mouse,
      buttons: kSecondaryMouseButton,
    );
    await tester.pump();
  }

  testWidgets('右键落在选区外:先收缩为该格,菜单读到的就是该格', (tester) async {
    final region = {(0, 0), (0, 1), (1, 0), (1, 1)};
    final probe = await pumpGrid(tester, selectedCells: region);

    await rightClickCell(tester, 3, 1);

    expect(probe.selectionCalls, [{(3, 1)}], reason: '应把落点收缩成唯一选中格');
    expect(probe.selectionCallsAtContext, 1, reason: '选中同步必须早于菜单回调');
    expect(probe.contextCalls, [(3, 1)]);
    expect(probe.tapCalls, isEmpty, reason: '右键不进就地编辑');
  });

  testWidgets('右键落在选区内:整批保留,不收缩', (tester) async {
    final region = {(0, 0), (0, 1), (1, 0), (1, 1)};
    final probe = await pumpGrid(tester, selectedCells: region);

    await rightClickCell(tester, 0, 1);

    expect(probe.selectionCalls, isEmpty, reason: '区域内右键不该改选中');
    expect(probe.selectionCallsAtContext, 0);
    expect(probe.contextCalls, [(0, 1)]);
  });

  testWidgets('右键行号列:未选中行收为该行,已选中行不动', (tester) async {
    final probe = await pumpGrid(
      tester,
      showRowNumbers: true,
      selectedRows: {5},
    );

    await rightClickRow(tester, 2);
    expect(probe.rowCalls, [2]);

    await rightClickRow(tester, 5);
    expect(probe.rowCalls, [2], reason: '已选中的行不该被右键拆成单行');
    expect(probe.contextCalls, [(2, 0), (5, 0)]);
  });
}

class _Probe {
  final selectionCalls = <Set<(int, int)>>[];
  final rowCalls = <int>[];
  final tapCalls = <(int, int)>[];
  final contextCalls = <(int, int)>[];
  int selectionCallsAtContext = -1;
}
