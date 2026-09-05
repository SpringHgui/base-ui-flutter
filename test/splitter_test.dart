import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';

/// Host that turns splitter deltas into a pane width, mirroring how db_lite
/// wires it (left pane grows with +dx, right pane grows with -dx).
Widget _host({
  required Axis orientation,
  required List<double> deltas,
  required List<String> events,
}) {
  return MaterialApp(
    home: Material(
      type: MaterialType.transparency,
      child: TokenScope(
        tokens: DesktopTokens.winForm,
        child: Center(
          child: SizedBox(
            width: 400,
            height: 300,
            child: orientation == Axis.horizontal
                ? Row(
                    children: [
                      const Expanded(child: SizedBox()),
                      Splitter(
                        onDragStart: () => events.add('start'),
                        onDrag: deltas.add,
                        onDragEnd: () => events.add('end'),
                      ),
                      const Expanded(child: SizedBox()),
                    ],
                  )
                : Column(
                    children: [
                      const Expanded(child: SizedBox()),
                      Splitter(
                        orientation: orientation,
                        onDragStart: () => events.add('start'),
                        onDrag: deltas.add,
                        onDragEnd: () => events.add('end'),
                      ),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('horizontal Splitter reports rightward pointer deltas in px',
      (tester) async {
    final deltas = <double>[];
    final events = <String>[];
    await tester.pumpWidget(_host(
      orientation: Axis.horizontal,
      deltas: deltas,
      events: events,
    ));

    await tester.drag(find.byType(Splitter), const Offset(40, 0));
    await tester.pump();

    expect(deltas.fold(0.0, (a, b) => a + b), closeTo(40, 0.001));
    expect(events, ['start', 'end']);
  });

  testWidgets('vertical Splitter reports downward pointer deltas in px',
      (tester) async {
    final deltas = <double>[];
    final events = <String>[];
    await tester.pumpWidget(_host(
      orientation: Axis.vertical,
      deltas: deltas,
      events: events,
    ));

    await tester.drag(find.byType(Splitter), const Offset(0, -30));
    await tester.pump();

    expect(deltas.fold(0.0, (a, b) => a + b), closeTo(-30, 0.001));
    expect(events, ['start', 'end']);
  });

  testWidgets('cross-axis motion leaves the horizontal pane width unchanged',
      (tester) async {
    final deltas = <double>[];
    await tester.pumpWidget(_host(
      orientation: Axis.horizontal,
      deltas: deltas,
      events: <String>[],
    ));

    await tester.drag(find.byType(Splitter), const Offset(0, 50));
    await tester.pump();

    expect(deltas.fold(0.0, (a, b) => a + b), 0.0);
  });

  testWidgets('default hit strip is 5px wide and spans the full pane height',
      (tester) async {
    await tester.pumpWidget(_host(
      orientation: Axis.horizontal,
      deltas: <double>[],
      events: <String>[],
    ));

    // Default thickness is 5px: dragging from the extreme edge still grabs it.
    final box = tester.getSize(find.byType(Splitter));
    expect(box.width, 5);
    expect(box.height, 300);
  });
}
