import 'package:base_ui_flutter/base_ui_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 双击回归:第一次按下先被宿主的选中逻辑重绘了一帧,双击判定仍须成立。
///
/// 单元格的选中走 `Listener.onPointerDown`(零延迟、不参与竞技场),因此宿主
/// 多半会在两次点击之间 `setState` 重绘;`GestureDetector` 的 `onDoubleTap`
/// 回调每次重建都是新闭包,但不能据此重建识别器,否则第一次按下的记忆就丢了
/// (症状:双击行不生效,只有单击)。
///
/// 用例里的 `pump(Duration(milliseconds: 50))` 是必须的:`pump()` 不推进时钟,
/// 两次点击会落在同一时间戳上,双击判定天然不成立(那是用例写错,不是组件缺陷)。
void main() {
  testWidgets('选中触发的重绘不打断双击判定', (tester) async {
    var selectedRow = -1;
    var doubleTaps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 300,
            height: 200,
            child: StatefulBuilder(
              builder: (context, setState) => DataGridView(
                columns: const [
                  DataGridViewColumn(title: 'name', width: 160),
                ],
                rowCount: 5,
                rowHeight: 20,
                selectedRow: selectedRow,
                onRowSelected: (r) => setState(() => selectedRow = r),
                onCellDoubleTap: (r, c) => doubleTaps++,
                cellBuilder: (r, c) => Text('$r-$c'),
              ),
            ),
          ),
        ),
      ),
    );

    final cell = tester.getCenter(find.text('2-0'));
    await tester.tapAt(cell);
    await tester.pump(const Duration(milliseconds: 50));
    expect(selectedRow, 2, reason: '第一次按下即刻选中(零延迟)');

    await tester.tapAt(cell);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 400));

    expect(doubleTaps, 1);
  });
}
