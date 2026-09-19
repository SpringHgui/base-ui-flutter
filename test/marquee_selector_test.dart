import 'package:base_ui_flutter/base_ui_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// MarqueeSelector 只做「拖出选框 + 上报矩形」,不解释命中:
// 这里验证起手阈值、矩形坐标语义(以自身左上为原点)与起止/结束回调次数。

Future<void> _drag(WidgetTester tester, Offset from, Offset to) async {
  final g = await tester.startGesture(from);
  await tester.pump();
  await g.moveTo(to);
  await tester.pump();
  await g.up();
  await tester.pump();
}

void main() {
  late List<Rect> bands;
  late int starts;
  late int ends;

  setUp(() {
    bands = [];
    starts = 0;
    ends = 0;
  });

  Widget host({double threshold = 4}) => MaterialApp(
    home: Center(
      child: SizedBox(
        width: 300,
        height: 200,
        child: MarqueeSelector(
          threshold: threshold,
          onMarqueeStart: () => starts++,
          onMarqueeUpdate: bands.add,
          onMarqueeEnd: () => ends++,
          child: const ColoredBox(color: Colors.white),
        ),
      ),
    ),
  );

  testWidgets('位移不足阈值视为普通点击:不回调也不画选框', (tester) async {
    await tester.pumpWidget(host());
    final origin = tester.getTopLeft(find.byType(MarqueeSelector));

    await _drag(
      tester,
      origin + const Offset(10, 10),
      origin + const Offset(12, 12),
    );

    expect(bands, isEmpty);
    expect(starts, 0);
    expect(ends, 0);
  });

  testWidgets('拖动中上报以自身左上为原点的矩形,松手撤掉浮层并回调结束', (tester) async {
    await tester.pumpWidget(host());
    final origin = tester.getTopLeft(find.byType(MarqueeSelector));

    final g = await tester.startGesture(origin + const Offset(20, 30));
    await tester.pump();
    await g.moveTo(origin + const Offset(120, 90));
    await tester.pump();

    // 选框是 MarqueeSelector 内唯一的 Positioned 子项 → 用它指代浮层
    final overlay = find.descendant(
      of: find.byType(MarqueeSelector),
      matching: find.byType(Positioned),
    );
    expect(overlay, findsOneWidget);

    await g.up();
    await tester.pump();

    expect(starts, 1);
    expect(ends, 1);
    expect(bands.last, const Rect.fromLTRB(20, 30, 120, 90));
    // 结束后浮层必须撤掉,否则会一直盖在界面上挡后续点击
    expect(overlay, findsNothing);
  });

  testWidgets('反向拖动同样归一化为正宽高矩形', (tester) async {
    await tester.pumpWidget(host());
    final origin = tester.getTopLeft(find.byType(MarqueeSelector));

    await _drag(
      tester,
      origin + const Offset(150, 120),
      origin + const Offset(50, 40),
    );

    expect(bands.last, const Rect.fromLTRB(50, 40, 150, 120));
  });

  testWidgets('canStart 返回 false 时整段拖动不起框', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 300,
            height: 200,
            child: MarqueeSelector(
              canStart: (e) => false,
              onMarqueeUpdate: bands.add,
              child: const ColoredBox(color: Colors.white),
            ),
          ),
        ),
      ),
    );
    final origin = tester.getTopLeft(find.byType(MarqueeSelector));

    await _drag(
      tester,
      origin + const Offset(10, 10),
      origin + const Offset(200, 150),
    );

    expect(bands, isEmpty);
  });
}
