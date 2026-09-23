import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:base_ui_flutter/base_ui_flutter.dart';

void main() {
  Widget harness(Widget grid) {
    return MaterialApp(
      home: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(width: 320, height: 240, child: grid),
      ),
    );
  }

  Future<void> pump(WidgetTester tester, List<DataGridViewColumn> columns) async {
    await tester.pumpWidget(harness(DataGridView(
      columns: columns,
      rowCount: 3,
      rowHeight: 20,
      cellBuilder: (r, c) => Text('$r$c'),
    )));
  }

  Finder sizedContainer(double height) => find.byWidgetPredicate((w) =>
      w is Container &&
      w.constraints?.minHeight == height &&
      w.constraints?.maxHeight == height);

  testWidgets('仅带 subtitleIcon 的列也走两行表头（加高 14px）', (tester) async {
    await pump(tester, const [
      DataGridViewColumn(title: 'A', width: 100, subtitle: 'int'),
      DataGridViewColumn(
          title: 'B', width: 100, subtitle: 'datetime', subtitleIcon: Icons.schedule),
      DataGridViewColumn(title: 'C', width: 100),
    ]);

    expect(tester.takeException(), isNull);
    expect(sizedContainer(20 + 14), findsWidgets,
        reason: '表头应加高一条 14px 副标题行');
    expect(find.byIcon(Icons.schedule), findsOneWidget);
  });

  testWidgets('subtitleIcon 与 subtitleGlyph 同时给出时图标优先', (tester) async {
    await pump(tester, const [
      DataGridViewColumn(
        title: 'A',
        width: 100,
        subtitle: 'datetime',
        subtitleGlyph: 'dt',
        subtitleIcon: Icons.schedule,
      ),
    ]);

    expect(find.byIcon(Icons.schedule), findsOneWidget);
    expect(find.text('dt'), findsNothing);
  });

  testWidgets('图标落在副标题行内，与副标题文本同线', (tester) async {
    await pump(tester, const [
      DataGridViewColumn(
          title: 'A', width: 100, subtitle: 'datetime', subtitleIcon: Icons.schedule),
    ]);

    final icon = tester.getRect(find.byIcon(Icons.schedule));
    final subtitle = tester.getRect(find.text('datetime'));
    final title = tester.getRect(find.text('A'));
    expect(icon.top, greaterThan(title.bottom), reason: '图标应在标题行下方');
    expect((icon.center.dy - subtitle.center.dy).abs(), lessThan(2.0));
    expect(icon.right, lessThan(subtitle.left), reason: '图标应在副标题文本左侧');
  });

  testWidgets('无副标题的表头高度不变', (tester) async {
    await pump(tester, const [
      DataGridViewColumn(title: 'A', width: 100),
    ]);
    expect(sizedContainer(20 + 14), findsNothing);
  });
}
