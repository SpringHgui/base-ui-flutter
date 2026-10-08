import 'package:base_ui_flutter/base_ui_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 「之前 / 之后」并排文本对比的回归。
///
/// 核心不变量是**两侧行数永远相同**:分栏靠同一份 rows 渲染,少补一个空槽
/// 两侧的行就错开了(参考工具的 diff 栏是逐行对齐的)。
void main() {
  List<TextDiffKind> kinds(List<TextDiffRow> rows) =>
      [for (final r in rows) r.kind];

  final eq = TextDiffKind.equal;
  final rep = TextDiffKind.replaced;
  final ins = TextDiffKind.inserted;
  final del = TextDiffKind.deleted;

  test('完全相同:逐行 equal,行号两侧一致', () {
    final rows = diffTextLines('a\nb\nc', 'a\nb\nc');
    expect(kinds(rows), [eq, eq, eq]);
    expect(rows.map((r) => r.leftLine), [1, 2, 3]);
    expect(rows.map((r) => r.rightLine), [1, 2, 3]);
  });

  test('只改中间一行:只有那一行是 replaced,前后行不误伤', () {
    final rows = diffTextLines('a\nb\nc\nd', 'a\nB\nc\nd');
    expect(kinds(rows), [eq, rep, eq, eq]);
    expect(rows[1].left, 'b');
    expect(rows[1].right, 'B');
  });

  test('纯新增行:另一侧留空槽(rightLine 0),行号照常推进', () {
    final rows = diffTextLines('a\nc', 'a\nb\nc');
    expect(kinds(rows), [eq, ins, eq]);
    expect(rows[1].left, isNull);
    expect(rows[1].right, 'b');
    // 左栏没有第 2 行,所以末行的左行号仍是 2、右行号是 3
    expect((rows[2].leftLine, rows[2].rightLine), (2, 3));
  });

  test('纯删除行:反向同理', () {
    final rows = diffTextLines('a\nb\nc', 'a\nc');
    expect(kinds(rows), [eq, del, eq]);
    expect(rows[1].left, 'b');
    expect(rows[1].right, isNull);
    expect((rows[2].leftLine, rows[2].rightLine), (3, 2));
  });

  test('中段整体换掉:删除段与新增段一对一配对成 replaced', () {
    final rows = diffTextLines('a\nx\ny\nz\ne', 'a\n1\n2\ne');
    // 3 删 2 增 → 2 对 replaced + 1 行剩下的 deleted
    expect(kinds(rows), [eq, rep, rep, del, eq]);
    expect(rows[3].right, isNull);
  });

  test('尾随空白不算差异,但显示仍用原文', () {
    final rows = diffTextLines('a  \nb', 'a\nb');
    expect(kinds(rows), [eq, eq]);
    expect(rows[0].left, 'a  ');
  });

  test('两侧行数相同:任意输入下每行都占一格', () {
    final rows = diffTextLines('a\nb\nc', 'x');
    // 全不等:3 删 1 增 → 1 replaced + 2 deleted,行数取两侧之和配对后仍对齐
    expect(rows.length, 3);
    expect(rows.every((r) => r.left != null), isTrue);
  });

  test('超过 LCS 上限的中段不再逐行配对,但结果与配对一致且不算崩', () {
    final before = List.generate(700, (i) => 'b$i').join('\n');
    final after = List.generate(700, (i) => 'a$i').join('\n');
    final rows = diffTextLines(before, after);
    expect(rows.length, 700);
    expect(rows.every((r) => r.kind == TextDiffKind.replaced), isTrue);
    expect(rows.first.left, 'b0');
    expect(rows.first.right, 'a0');
  });

  // ── 渲染 ──

  Widget host(Widget child) => MaterialApp(
        home: Material(
          type: MaterialType.transparency,
          child: TokenScope(
            tokens: DesktopTokens.winForm,
            child: SizedBox(width: 700, height: 320, child: child),
          ),
        ),
      );

  testWidgets('同一行在左右两栏各渲染一遍;只在一条上的行只出现一次',
      (tester) async {
    await tester.pumpWidget(host(const TextDiffView(
      before: 'keep\nold',
      after: 'keep\nnew\nadded',
    )));
    await tester.pumpAndSettle();

    expect(find.text('keep'), findsNWidgets(2), reason: '两侧都有相同行');
    expect(find.text('added'), findsOneWidget, reason: '只在右栏出现');
    expect(find.text('old'), findsOneWidget);
    expect(find.text('new'), findsOneWidget);
  });

  testWidgets('标题栏按需渲染:两个标题都为 null 时不占行', (tester) async {
    await tester.pumpWidget(host(const TextDiffView(
      before: 'a',
      after: 'b',
      beforeLabel: '之前:',
      afterLabel: '之后:',
    )));
    await tester.pumpAndSettle();
    expect(find.text('之前:'), findsOneWidget);
    expect(find.text('之后:'), findsOneWidget);

    await tester.pumpWidget(host(const TextDiffView(before: 'a', after: 'b')));
    await tester.pumpAndSettle();
    expect(find.text('之前:'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
