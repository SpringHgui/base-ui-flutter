import 'package:base_ui_flutter/base_ui_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 横向虚拟化(DataGridView 的可选开关)的行为守卫。
///
/// 宽表把整个网格放进横向 SingleChildScrollView 时,旧版每一行都会把**所有列**
/// 建成真实 widget(哪怕滚出视口),于是勾选列 / 选择 / 缩放的重建量 ∝
/// 可见行 × 全部列。开启 horizontalScrollController + horizontalViewportWidth
/// 后,数据行只渲染与视口相交的列(左右占位条撑出等宽)。
///
/// 这些用例钉住虚拟化最容易静默回归的三件事:
/// * 视口外的列确实没被建出来(省重建);
/// * 横向滚动会换窗(滚进来的列出现、滚出去的被回收);
/// * 换窗后单元格的列下标不错位(点击命中正确的列),行号列随内容滚出,
///   且表头不虚拟化(列宽调整 / 排序手柄常驻)。

const _colW = 120.0;
const _viewport = 300.0; // 视口内约 2.5 列
const _columns = 12;

Future<void> _pump(
  WidgetTester tester,
  ScrollController h, {
  bool rowNumbers = false,
  double? viewportWidth = _viewport,
  void Function(int row, int col)? onCellTap,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: _viewport,
          height: 240,
          child: SingleChildScrollView(
            controller: h,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: (rowNumbers ? 22 : 0) + _columns * _colW,
              child: DataGridView(
                columns: [
                  for (var i = 0; i < _columns; i++)
                    DataGridViewColumn(title: 'c$i', width: _colW),
                ],
                // 虚拟化要求显式列宽(与宿主表数据页同构)
                columnWidths: [for (var i = 0; i < _columns; i++) _colW],
                rowCount: 5,
                rowHeight: 20,
                showRowNumbers: rowNumbers,
                rowNumberBuilder: rowNumbers
                    ? (r, sel) => Text('R$r')
                    : null,
                cellBuilder: (r, c) => Text('$r-$c'),
                horizontalScrollController: h,
                horizontalViewportWidth: viewportWidth,
                onCellTap: onCellTap,
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('视口外的列不建 widget,表头仍整行渲染', (tester) async {
    final h = ScrollController();
    await _pump(tester, h);
    addTearDown(h.dispose);

    // 视口 [0,300):col0/1/2 相交,col3 起于 360 → 不渲染
    expect(find.text('0-0'), findsOneWidget);
    expect(find.text('0-1'), findsOneWidget);
    expect(find.text('0-2'), findsOneWidget);
    expect(find.text('0-3'), findsNothing, reason: 'col3 起点 360 > 视口右界 300');
    expect(find.text('0-11'), findsNothing);
    // 表头不虚拟化:最右列标题仍在(列宽调整 / 排序手柄需常驻)
    expect(find.text('c11'), findsOneWidget);
  });

  testWidgets('横向滚动换窗:滚进来的列出现,滚出去的被回收', (tester) async {
    final h = ScrollController();
    await _pump(tester, h);
    addTearDown(h.dispose);

    h.jumpTo(600); // 视口 [600,900)
    await tester.pump();

    expect(find.text('0-0'), findsNothing, reason: 'col0 已滚出左界');
    expect(find.text('0-5'), findsOneWidget); // [600,720)
    expect(find.text('0-7'), findsOneWidget); // [840,960) 与视口相交
    expect(find.text('0-8'), findsNothing); // [960,1080) 在视口右界之外
  });

  testWidgets('换窗后点击命中正确的数据列(列下标不错位)', (tester) async {
    final h = ScrollController();
    final taps = <(int, int)>[];
    await _pump(tester, h, onCellTap: (r, c) => taps.add((r, c)));
    addTearDown(h.dispose);

    h.jumpTo(600);
    await tester.pump();

    await tester.tap(find.text('0-6'), kind: PointerDeviceKind.mouse);
    await tester.pump();
    expect(taps, contains((0, 6)), reason: '虚拟化后 col6 的点击坐标应仍是列 6');
  });

  testWidgets('行号列随内容滚出视口', (tester) async {
    final h = ScrollController();
    await _pump(tester, h, rowNumbers: true);
    addTearDown(h.dispose);

    // offset 0:行号列 [0,22) 在视口内
    expect(find.text('R0'), findsOneWidget);

    h.jumpTo(300); // 越过行号列宽
    await tester.pump();
    expect(find.text('R0'), findsNothing, reason: '行号列应随横向滚动滑出');
    // 行号滚出后,数据列照常渲染(col2 [262,382) 与 [300,600) 相交)
    expect(find.text('0-2'), findsOneWidget);
  });

  testWidgets('未给视口宽时回退整行渲染(所有列都建)', (tester) async {
    final h = ScrollController();
    await _pump(tester, h, viewportWidth: null);
    addTearDown(h.dispose);

    expect(find.text('0-0'), findsOneWidget);
    expect(find.text('0-11'), findsOneWidget, reason: '无视口宽 → 不虚拟化');
  });
}
