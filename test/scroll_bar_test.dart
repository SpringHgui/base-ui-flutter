import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:base_ui_flutter/base_ui_flutter.dart';

void main() {
  Widget host(Widget child) =>
      MaterialApp(home: Scaffold(body: Center(child: child)));

  double scrollbarThickness(WidgetTester tester) =>
      tester.widget<Scrollbar>(find.byType(Scrollbar)).thickness!;

  Future<TestGesture> mouseAt(WidgetTester tester, Offset at) async {
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: at);
    addTearDown(gesture.removePointer);
    await tester.pumpAndSettle();
    return gesture;
  }

  Future<void> pumpBar(
    WidgetTester tester, {
    ScrollBarOrientation orientation = ScrollBarOrientation.vertical,
    double? thumbThickness,
  }) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(host(SizedBox(
      width: 200,
      height: 200,
      child: ScrollBar(
        controller: controller,
        orientation: orientation,
        thumbThickness: thumbThickness,
        thumbVisibility: true,
        child: orientation == ScrollBarOrientation.vertical
            ? ListView.builder(
                controller: controller,
                itemExtent: 40,
                itemCount: 50,
                itemBuilder: (_, i) => SizedBox(height: 40),
              )
            : SingleChildScrollView(
                controller: controller,
                scrollDirection: Axis.horizontal,
                child: const SizedBox(width: 2000, height: 200),
              ),
      ),
    )));
    controller.jumpTo(80);
    await tester.pumpAndSettle();
  }

  testWidgets('纵向滚动条:静止 5px,悬浮到右缘恢复 8px,移开后收窄', (tester) async {
    await pumpBar(tester);
    expect(scrollbarThickness(tester), kScrollBarSlimThickness);

    final gesture = await mouseAt(tester, const Offset(400, 300));
    await gesture.moveTo(const Offset(498, 300));
    await tester.pumpAndSettle();
    expect(scrollbarThickness(tester), kScrollBarExpandedThickness);

    await gesture.moveTo(const Offset(400, 300));
    await tester.pumpAndSettle();
    expect(scrollbarThickness(tester), kScrollBarSlimThickness);
  });

  testWidgets('横向滚动条:悬浮到底缘恢复 8px', (tester) async {
    await pumpBar(tester, orientation: ScrollBarOrientation.horizontal);
    expect(scrollbarThickness(tester), kScrollBarSlimThickness);

    final gesture = await mouseAt(tester, const Offset(400, 300));
    await gesture.moveTo(const Offset(400, 398));
    await tester.pumpAndSettle();
    expect(scrollbarThickness(tester), kScrollBarExpandedThickness);
  });

  testWidgets('thumbThickness 自定义悬浮宽度,静止宽度不超过它', (tester) async {
    await pumpBar(tester, thumbThickness: 4);
    expect(scrollbarThickness(tester), 4);

    final gesture = await mouseAt(tester, const Offset(400, 300));
    await gesture.moveTo(const Offset(498, 300));
    await tester.pumpAndSettle();
    expect(scrollbarThickness(tester), 4);
  });

  test('scrollbarHoverThickness:悬浮/拖动为宽、静止为窄', () {
    final p = scrollbarHoverThickness();
    expect(p.resolve(const {}), kScrollBarSlimThickness);
    expect(p.resolve(const {WidgetState.hovered}), kScrollBarExpandedThickness);
    expect(p.resolve(const {WidgetState.dragged}), kScrollBarExpandedThickness);
  });
}
