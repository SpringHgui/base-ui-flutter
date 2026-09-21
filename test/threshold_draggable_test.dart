import 'package:base_ui_flutter/base_ui_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ThresholdDraggable 要挡住框架 Draggable 的两条"没拖就先起手"的路径:
//  1. 本识别器是竞技场唯一成员时,pointer down 就被默认判接受(桌面端鼠标常态);
//  2. 鼠标起手容差只有 1px(kPrecisePointerHitSlop),单击手抖即可起手。
// 症状:双击打开一行却闪出拖拽浮层。这里两条路径都覆盖。

const _dragKey = ValueKey('draggable-row');
const _feedbackKey = ValueKey('drag-feedback');

/// 模拟**真鼠标**:框架对 mouse 用 1px 的精确指针容差,
/// 用 tester 默认的 touch 指针(容差 kTouchSlop = 18px)测不出这个差异。
Future<TestGesture> _mouseDown(WidgetTester tester, Offset at) =>
    tester.startGesture(at, kind: PointerDeviceKind.mouse);

void main() {
  late List<String> events;

  setUp(() => events = <String>[]);

  /// [competing] 为 true 时给拖拽源套一个 tap 识别器,让竞技场里有两个成员
  /// (即框架 Draggable 不会被"唯一成员默认接受"直接判赢的情况)。
  Widget host({
    double startSlop = kDragStartSlop,
    Axis? affinity,
    bool competing = false,
  }) {
    Widget draggable = SizedBox(
      key: _dragKey,
      width: 120,
      height: 40,
      child: ThresholdDraggable<String>(
        data: 'conn',
        startSlop: startSlop,
        affinity: affinity,
        feedback: const ColoredBox(key: _feedbackKey, color: Color(0xFF000000)),
        onDragStarted: () => events.add('start'),
        onDragEnd: (_) => events.add('end'),
        child: const ColoredBox(color: Color(0xFFEEEEEE)),
      ),
    );
    if (competing) {
      draggable = GestureDetector(onTap: () => events.add('tap'), child: draggable);
    }

    return MaterialApp(
      home: Center(
        child: SizedBox(
          width: 240,
          height: 40,
          child: Stack(
            children: [
              Positioned(left: 0, top: 0, width: 120, height: 40, child: draggable),
              Positioned(
                left: 120,
                top: 0,
                width: 120,
                height: 40,
                child: DragTarget<String>(
                  onAcceptWithDetails: (d) => events.add('drop:${d.data}'),
                  builder: (_, _, _) => const ColoredBox(color: Color(0xFFFFFFFF)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('竞技场里唯一的拖拽源:单纯按下不拖,不起手也不闪浮层', (tester) async {
    await tester.pumpWidget(host());
    final origin = tester.getCenter(find.byKey(_dragKey));
    events.clear();

    final g = await _mouseDown(tester, origin);
    await tester.pump();
    // 唯一成员会被竞技场默认判接受——不得因此起手
    expect(events, isEmpty);
    expect(find.byKey(_feedbackKey), findsNothing);

    await tester.pump(const Duration(milliseconds: 600)); // 足够盖过双击窗口
    await g.up();
    await tester.pump();

    expect(events, isEmpty, reason: '没拖动就不该有 start / end');
    expect(find.byKey(_feedbackKey), findsNothing);
  });

  testWidgets('鼠标手抖(不到阈值)不算拖动:不起手、不闪浮层', (tester) async {
    await tester.pumpWidget(host());
    final origin = tester.getCenter(find.byKey(_dragKey));
    events.clear();

    final g = await _mouseDown(tester, origin);
    await tester.pump();
    // 双击 / 单击时最常见的 1~3px 抖动——框架 1px 容差下这已经算拖动
    await g.moveBy(const Offset(3, 0));
    await tester.pump();
    expect(events, isEmpty, reason: '3px < 4px,不应起手');
    expect(find.byKey(_feedbackKey), findsNothing);

    await g.moveBy(const Offset(-3, 0)); // 抖回来也不算
    await tester.pump();
    await g.up();
    await tester.pump();

    expect(events, isEmpty);
    expect(find.byKey(_feedbackKey), findsNothing);
  });

  testWidgets('位移跨过阈值才起手,松手撤回浮层', (tester) async {
    await tester.pumpWidget(host());
    final origin = tester.getCenter(find.byKey(_dragKey));
    events.clear();

    final g = await _mouseDown(tester, origin);
    await tester.pump();
    await g.moveBy(const Offset(2, 0));
    await tester.pump();
    expect(events, isEmpty, reason: '2px 仍在阈值内');
    expect(find.byKey(_feedbackKey), findsNothing);

    await g.moveBy(const Offset(8, 0)); // 累计 10px > 4px
    await tester.pump();
    expect(events, ['start']);
    expect(find.byKey(_feedbackKey), findsOneWidget);

    await g.up();
    await tester.pump();
    expect(events, ['start', 'end']);
    expect(find.byKey(_feedbackKey), findsNothing);
  });

  testWidgets('跨过阈值后拖到 DragTarget 上正常放置', (tester) async {
    await tester.pumpWidget(host());
    final from = tester.getCenter(find.byKey(_dragKey));
    events.clear();

    final g = await _mouseDown(tester, from);
    await tester.pump();
    await g.moveTo(from + const Offset(120, 0));
    await tester.pump();
    await g.up();
    await tester.pump();

    expect(events, contains('start'));
    expect(events, contains('drop:conn'));
  });

  testWidgets('竞技场有竞争识别器时,阈值同样挡住手抖并能正常起手', (tester) async {
    await tester.pumpWidget(host(competing: true));
    final from = tester.getCenter(find.byKey(_dragKey));
    events.clear();

    final g = await _mouseDown(tester, from);
    await tester.pump();
    await g.moveBy(const Offset(3, 0));
    await tester.pump();
    expect(events, isEmpty);

    await g.moveBy(const Offset(20, 0));
    await tester.pump();
    expect(events, ['start']);

    await g.up();
    await tester.pump();
  });

  testWidgets('affinity 限定方向的阈值只算该轴位移', (tester) async {
    await tester.pumpWidget(host(affinity: Axis.horizontal));
    final origin = tester.getCenter(find.byKey(_dragKey));
    events.clear();

    final g = await _mouseDown(tester, origin);
    await tester.pump();
    // 纵向移动 20px:水平识别器不看 dy,不应起手
    await g.moveBy(const Offset(0, 20));
    await tester.pump();
    expect(events, isEmpty);

    await g.moveBy(const Offset(10, 0)); // 横向再走 10px 才跨阈值
    await tester.pump();
    expect(events, ['start']);

    await g.up();
    await tester.pump();
  });

  testWidgets('startSlop 可调:加大后同样的位移不再起手', (tester) async {
    await tester.pumpWidget(host(startSlop: 20));
    final origin = tester.getCenter(find.byKey(_dragKey));
    events.clear();

    final g = await _mouseDown(tester, origin);
    await tester.pump();
    await g.moveBy(const Offset(12, 0));
    await tester.pump();
    expect(events, isEmpty);

    await g.up();
    await tester.pump();
  });
}
