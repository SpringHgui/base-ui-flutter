import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';

/// 密集表格的单元格规则:内容在列内**垂直居中**、水平方向按 `column.alignment`
/// 对齐(数值列右对齐),且对齐只在单元格容器**内部**做——容器必须仍占满整列,
/// 否则竖向网格线与选中底色会跟着文字宽度走。
void main() {
  const rowHeight = 22.0;
  const paddingX = 6.0;
  const colWidth = 200.0;

  Future<void> pumpGrid(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: colWidth * 2,
          height: 120,
          child: DataGridView(
            columns: const [
              DataGridViewColumn(title: 'colA', width: colWidth),
              DataGridViewColumn(
                  title: 'colB',
                  width: colWidth,
                  alignment: Alignment.centerRight),
            ],
            rowCount: 1,
            rowHeight: rowHeight,
            cellPaddingX: paddingX,
            // 显式行高 10:测试字体的默认行盒会撑满整格,量不出「居中」
            cellBuilder: (row, col) => Text(
              col == 0 ? 'aaa' : '123',
              style: const TextStyle(fontSize: 10, height: 1.0),
            ),
          ),
        ),
      ),
    ));
    expect(tester.takeException(), isNull);
  }

  /// 单元格容器:行高被写死成 [rowHeight] 的 Container(整行自己也是一个)
  final cellContainers = find.byWidgetPredicate((w) =>
      w is Container &&
      w.constraints != null &&
      w.constraints!.minHeight == rowHeight &&
      w.constraints!.maxHeight == rowHeight);

  Rect cellRectOf(WidgetTester tester, String text) => tester.getRect(
      find.ancestor(of: find.text(text), matching: cellContainers).first);

  testWidgets('文本列左对齐、数值列右对齐,且都垂直居中于行内', (tester) async {
    await pumpGrid(tester);
    final left = tester.getRect(find.text('aaa'));
    final leftCell = cellRectOf(tester, 'aaa');
    final right = tester.getRect(find.text('123'));
    final rightCell = cellRectOf(tester, '123');

    // 垂直:文字中线与单元格中线重合(改前文字贴着行顶)
    expect(left.center.dy, closeTo(leftCell.center.dy, 0.6),
        reason: '左对齐列的文字应垂直居中');
    expect(right.center.dy, closeTo(rightCell.center.dy, 0.6),
        reason: '右对齐列的文字应垂直居中');
    expect(left.height, closeTo(10, 0.6), reason: '行盒只占自身高度,不被拉成整行高');

    // 水平:各自贴所在列的内边距(单元格有 1px 右边线,Container 会按内边距处理)
    expect(left.left, closeTo(leftCell.left + paddingX, 0.6));
    expect(right.right, closeTo(rightCell.right - paddingX, 1.5));
  });

  testWidgets('右对齐只移动内容,不收缩单元格(容器仍占满列宽)', (tester) async {
    await pumpGrid(tester);
    final cell = cellRectOf(tester, '123');
    final text = tester.getRect(find.text('123'));

    expect(cell.width, closeTo(colWidth, 1),
        reason: '右对齐列的单元格容器应等于列宽,否则竖线与选中块会跟着文字走');
    expect(text.width, lessThan(cell.width));
  });

  testWidgets('Input 支持自定义高度:紧凑单元格里的编辑器不再撑破行',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Material(
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            // 只限定宽度:高度交给 Input 自己报,否则父级的紧高度会盖掉 height 参数
            width: 200,
            child: Input(height: rowHeight),
          ),
        ),
      ),
    ));
    expect(tester.takeException(), isNull);
    expect(tester.getRect(find.byType(Input)).height, closeTo(rowHeight, 0.6));
  });
}
