import 'package:base_ui_flutter/base_ui_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemMouseCursor;
import 'package:flutter_test/flutter_test.dart';

/// 拖动回归：分隔条必须逐事件跟手。
///
/// 历史 bug：拖动起点记在 `build()` 的局部 `late` 变量里，而每个事件都 setState 重建，
/// 在途识别器的回调被换成新闭包 → 第二个事件读未初始化的局部量抛 LateInitializationError，
/// 界面表现是「分隔条拖一下（约 10px）就再也不动」。
Finder _divider(SystemMouseCursor cursor) => find.byWidgetPredicate(
    (w) => w is MouseRegion && w.cursor == cursor);

Future<void> _pump(WidgetTester tester, Axis orientation) async {
  await tester.pumpWidget(MaterialApp(
    home: Center(
      child: SizedBox(
        width: 400,
        height: 400,
        child: SplitContainer(
          orientation: orientation,
          initialRatio: 0.45,
          minFirst: 120,
          minSecond: 120,
          first: const ColoredBox(color: Colors.red),
          second: const ColoredBox(color: Colors.blue),
        ),
      ),
    ),
  ));
  await tester.pump();
}

/// 分 [steps] 次、每次 [step] 像素地拖，返回分隔条左上角的总位移
Future<Offset> _dragSteps(
  WidgetTester tester,
  SystemMouseCursor cursor,
  int steps,
  Offset step,
) async {
  final finder = _divider(cursor);
  final before = tester.getTopLeft(finder);
  final gesture = await tester.startGesture(tester.getCenter(finder));
  await tester.pump();
  for (var i = 0; i < steps; i++) {
    await gesture.moveBy(step);
    await tester.pump();
  }
  await gesture.up();
  await tester.pump();
  expect(tester.takeException(), isNull);
  return tester.getTopLeft(finder) - before;
}

void main() {
  testWidgets('上下分割：分隔条逐事件跟手，累计位移等于指针位移', (tester) async {
    await _pump(tester, Axis.vertical);
    expect(await _dragSteps(tester, SystemMouseCursors.resizeUpDown, 6,
        const Offset(0, 10)), const Offset(0, 60));
  });

  testWidgets('左右分割：分隔条逐事件跟手，累计位移等于指针位移', (tester) async {
    await _pump(tester, Axis.horizontal);
    expect(await _dragSteps(tester, SystemMouseCursors.resizeLeftRight, 6,
        const Offset(10, 0)), const Offset(60, 0));
  });

  testWidgets('拖过最小值后反向拖能立刻跟手（不卡在上限）', (tester) async {
    await _pump(tester, Axis.vertical);
    // 先向上拖过 minFirst(120)：越界部分只记账不跟手
    await _dragSteps(
        tester, SystemMouseCursors.resizeUpDown, 12, const Offset(0, -20));
    final finder = _divider(SystemMouseCursors.resizeUpDown);
    final clamped = tester.getTopLeft(finder).dy;
    expect(clamped, lessThanOrEqualTo(100 + 124)); // Center 偏移 + minFirst + 容差
    // 再反向拖，必须按指针位移 1:1 回来
    final moved = await _dragSteps(
        tester, SystemMouseCursors.resizeUpDown, 4, const Offset(0, 15));
    expect(moved, const Offset(0, 60));
    expect(tester.getTopLeft(finder).dy, closeTo(clamped + 60, 1));
  });
}
