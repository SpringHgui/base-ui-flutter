import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';

void main() {
  testWidgets('拖拽多选结束后单击仍可选中单个单元格', (tester) async {
    final controller = ScrollController();
    Set<(int, int)> lastSelection = {};
    await tester.pumpWidget(
      MaterialApp(
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 400,
            height: 300,
            child: DataGridView(
              columns: const [
                DataGridViewColumn(title: 'A', width: 100),
                DataGridViewColumn(title: 'B', width: 100),
              ],
              rowCount: 200,
              rowHeight: 20,
              cellBuilder: (r, c) => Text('row $r'),
              verticalScrollController: controller,
              selectedCells: null,
              onCellsSelected: (cells) => lastSelection = cells,
            ),
          ),
        ),
      ),
    );

    final gridTopLeft = tester.getTopLeft(find.byType(DataGridView));
    // 拖拽多选 3 行 x 2 列
    final drag = await tester.startGesture(
      gridTopLeft + const Offset(30, 30),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();
    await drag.moveTo(gridTopLeft + const Offset(150, 70));
    await tester.pump();
    await drag.up();
    await tester.pump();
    expect(lastSelection.length, greaterThan(1), reason: '拖拽应产生多选');

    // 拖拽结束后单击另一个单元格:应只选中该单元格
    await tester.tapAt(
      gridTopLeft + const Offset(150, 150),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();
    expect(lastSelection.length, 1, reason: '拖拽后单击应恢复单选');

    controller.dispose();
  });

  testWidgets('拖拽多选到底部边缘时自动向下滚动', (tester) async {
    final controller = ScrollController();
    Set<(int, int)> lastSelection = {};
    await tester.pumpWidget(
      MaterialApp(
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 400,
            height: 300,
            child: DataGridView(
              columns: const [DataGridViewColumn(title: 'A', width: 200)],
              rowCount: 200,
              rowHeight: 20,
              cellBuilder: (r, c) => Text('row $r'),
              verticalScrollController: controller,
              onCellsSelected: (cells) => lastSelection = cells,
            ),
          ),
        ),
      ),
    );

    // 网格左上角偏移(header 高 20)
    final gridTopLeft = tester.getTopLeft(find.byType(DataGridView));
    // 按下第一行单元格
    final gesture = await tester.startGesture(
      gridTopLeft + const Offset(60, 30),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();
    // 拖到底部边缘以内
    await gesture.moveTo(gridTopLeft + const Offset(60, 295));
    await tester.pump();
    // 停在边缘,等待自动滚动 tick
    await tester.pump(const Duration(milliseconds: 500));

    // ignore: avoid_print
    print('offset=${controller.offset} selection=${lastSelection.length}');
    expect(controller.offset, greaterThan(0), reason: '应当发生自动滚动');

    await gesture.up();
    await tester.pump();
    controller.dispose();
  });

  testWidgets('query_page 装配结构下拖拽多选自动滚动', (tester) async {
    final hController = ScrollController();
    final vController = ScrollController();
    Set<(int, int)> lastSelection = {};
    await tester.pumpWidget(
      MaterialApp(
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 400,
            height: 300,
            child: ScrollBar(
              controller: hController,
              orientation: ScrollBarOrientation.horizontal,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: hController,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 600,
                  child: ScrollBar(
                    controller: vController,
                    child: DataGridView(
                      columns: const [
                        DataGridViewColumn(title: 'A', width: 200),
                        DataGridViewColumn(title: 'B', width: 200),
                      ],
                      rowCount: 200,
                      rowHeight: 20,
                      showRowNumbers: true,
                      cellBuilder: (r, c) => Text('row $r'),
                      verticalScrollController: vController,
                      onCellsSelected: (cells) => lastSelection = cells,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final gridTopLeft = tester.getTopLeft(find.byType(DataGridView));
    final gesture = await tester.startGesture(
      gridTopLeft + const Offset(60, 30),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();
    await gesture.moveTo(gridTopLeft + const Offset(60, 295));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // ignore: avoid_print
    print('offset=${vController.offset} selection=${lastSelection.length}');
    expect(vController.offset, greaterThan(0), reason: '应当发生自动滚动');

    await gesture.up();
    await tester.pump();
    hController.dispose();
    vController.dispose();
  });

  testWidgets('拖拽多选到顶部边缘时自动向上滚动', (tester) async {
    final controller = ScrollController(initialScrollOffset: 600);
    Set<(int, int)> lastSelection = {};
    await tester.pumpWidget(
      MaterialApp(
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 400,
            height: 300,
            child: DataGridView(
              columns: const [DataGridViewColumn(title: 'A', width: 200)],
              rowCount: 200,
              rowHeight: 20,
              cellBuilder: (r, c) => Text('row $r'),
              verticalScrollController: controller,
              onCellsSelected: (cells) => lastSelection = cells,
            ),
          ),
        ),
      ),
    );

    final gridTopLeft = tester.getTopLeft(find.byType(DataGridView));
    // 按下中部单元格,向上拖出网格顶部边缘
    final gesture = await tester.startGesture(
      gridTopLeft + const Offset(60, 150),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();
    await gesture.moveTo(gridTopLeft + const Offset(60, -20));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // ignore: avoid_print
    print('offset=${controller.offset} selection=${lastSelection.length}');
    expect(controller.offset, lessThan(600), reason: '应当发生向上自动滚动');

    await gesture.up();
    await tester.pump();
    controller.dispose();
  });
}
