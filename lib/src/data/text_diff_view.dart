import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// 一行在两侧的状态。
enum TextDiffKind { equal, replaced, inserted, deleted }

/// 对齐后的一行:某一侧为 `null` 表示该侧没有这一行(渲染成空槽)。
class TextDiffRow {
  const TextDiffRow({
    required this.left,
    required this.right,
    required this.leftLine,
    required this.rightLine,
    required this.kind,
  });

  final String? left;
  final String? right;

  /// 各自的行号;空槽那侧为 0(不显示数字)
  final int leftLine;
  final int rightLine;
  final TextDiffKind kind;
}

/// 中间段走 DP 的行数上限:超过就整段判为「左删右增」。
/// 宁可多标几行差异,也不能让打开页面卡在计算上。
const int _kLcsCap = 600;

/// 逐行比较两段文本,返回**两侧行数相同**的对齐结果
/// (插入 / 删除的一侧用空槽补齐),便于左右分栏同步行高。
///
/// 先掐公共前后缀再对中段跑 LCS:DDL 对比里绝大多数行本来就相同,
/// 这样一次比较的计算量可以忽略,也顺带把「只改了一行」显示成一行。
/// 行内容按 `trimRight()` 比较(尾随空白不算差异),显示仍用原文。
List<TextDiffRow> diffTextLines(String before, String after) {
  final a = before.split('\n');
  final b = after.split('\n');
  var head = 0;
  while (head < a.length &&
      head < b.length &&
      a[head].trimRight() == b[head].trimRight()) {
    head++;
  }
  var tail = 0;
  while (tail < a.length - head &&
      tail < b.length - head &&
      a[a.length - 1 - tail].trimRight() == b[b.length - 1 - tail].trimRight()) {
    tail++;
  }
  final midA = a.sublist(head, a.length - tail);
  final midB = b.sublist(head, b.length - tail);

  final rows = <TextDiffRow>[];
  for (var i = 0; i < head; i++) {
    rows.add(TextDiffRow(
      left: a[i],
      right: b[i],
      leftLine: i + 1,
      rightLine: i + 1,
      kind: TextDiffKind.equal,
    ));
  }
  // 两侧在中段起点的行号相同:前 head 行是一一对应的
  rows.addAll(_diffMiddle(midA, midB, head + 1));
  for (var i = 0; i < tail; i++) {
    rows.add(TextDiffRow(
      left: a[a.length - tail + i],
      right: b[b.length - tail + i],
      leftLine: a.length - tail + i + 1,
      rightLine: b.length - tail + i + 1,
      kind: TextDiffKind.equal,
    ));
  }
  return _mergeReplacements(rows);
}

/// 把紧邻的「删除段 + 新增段」一对一配对成「替换」,让改动行在两侧同一行上
/// 同色显示,而不是左边一条红杠、右边一条绿杠各说各话。多出来的行保持原样。
List<TextDiffRow> _mergeReplacements(List<TextDiffRow> rows) {
  final out = <TextDiffRow>[];
  var i = 0;
  while (i < rows.length) {
    if (rows[i].kind != TextDiffKind.deleted) {
      out.add(rows[i]);
      i++;
      continue;
    }
    var p = i;
    while (p < rows.length && rows[p].kind == TextDiffKind.deleted) {
      p++;
    }
    var q = p;
    while (q < rows.length && rows[q].kind == TextDiffKind.inserted) {
      q++;
    }
    final dels = rows.sublist(i, p);
    final adds = rows.sublist(p, q);
    final pairs = dels.length < adds.length ? dels.length : adds.length;
    for (var k = 0; k < pairs; k++) {
      out.add(TextDiffRow(
        left: dels[k].left,
        right: adds[k].right,
        leftLine: dels[k].leftLine,
        rightLine: adds[k].rightLine,
        kind: TextDiffKind.replaced,
      ));
    }
    out.addAll(dels.sublist(pairs));
    out.addAll(adds.sublist(pairs));
    i = q;
  }
  return out;
}

List<TextDiffRow> _diffMiddle(List<String> a, List<String> b, int startLine) {
  if (a.isEmpty && b.isEmpty) return const [];
  if (a.length > _kLcsCap || b.length > _kLcsCap) {
    return [
      for (var i = 0; i < a.length; i++)
        TextDiffRow(
          left: a[i],
          right: null,
          leftLine: startLine + i,
          rightLine: 0,
          kind: TextDiffKind.deleted,
        ),
      for (var i = 0; i < b.length; i++)
        TextDiffRow(
          left: null,
          right: b[i],
          leftLine: 0,
          rightLine: startLine + i,
          kind: TextDiffKind.inserted,
        ),
    ];
  }
  final m = a.length, n = b.length;
  // dp[i][j] = a[i:] 与 b[j:] 的最长公共行数
  final dp = List.generate(m + 1, (_) => List<int>.filled(n + 1, 0));
  for (var i = m - 1; i >= 0; i--) {
    for (var j = n - 1; j >= 0; j--) {
      dp[i][j] = a[i].trimRight() == b[j].trimRight()
          ? dp[i + 1][j + 1] + 1
          : (dp[i + 1][j] >= dp[i][j + 1] ? dp[i + 1][j] : dp[i][j + 1]);
    }
  }
  final out = <TextDiffRow>[];
  var i = 0, j = 0, lineA = startLine, lineB = startLine;
  while (i < m && j < n) {
    if (a[i].trimRight() == b[j].trimRight()) {
      out.add(TextDiffRow(
        left: a[i],
        right: b[j],
        leftLine: lineA++,
        rightLine: lineB++,
        kind: TextDiffKind.equal,
      ));
      i++;
      j++;
    } else if (dp[i + 1][j] >= dp[i][j + 1]) {
      out.add(TextDiffRow(
        left: a[i],
        right: null,
        leftLine: lineA++,
        rightLine: 0,
        kind: TextDiffKind.deleted,
      ));
      i++;
    } else {
      out.add(TextDiffRow(
        left: null,
        right: b[j],
        leftLine: 0,
        rightLine: lineB++,
        kind: TextDiffKind.inserted,
      ));
      j++;
    }
  }
  while (i < m) {
    out.add(TextDiffRow(
      left: a[i],
      right: null,
      leftLine: lineA++,
      rightLine: 0,
      kind: TextDiffKind.deleted,
    ));
    i++;
  }
  while (j < n) {
    out.add(TextDiffRow(
      left: null,
      right: b[j],
      leftLine: 0,
      rightLine: lineB++,
      kind: TextDiffKind.inserted,
    ));
    j++;
  }
  return out;
}

/// 左右分栏的「之前 / 之后」文本对比:两侧各自行号,差异行整行上色
/// (新增与替换绿、删除红、缺失侧中性灰),两侧共用一条垂直滚动。
class TextDiffView extends StatelessWidget {
  const TextDiffView({
    super.key,
    required this.before,
    required this.after,
    this.beforeLabel,
    this.afterLabel,
    this.fontSize = 13,
    this.lineHeight = 20,
    this.tokens,
  });

  final String before;
  final String after;

  /// 各栏顶部的小标题(如「之前:」);两侧都为 null 时不占行。
  final String? beforeLabel;
  final String? afterLabel;

  final double fontSize;
  final double lineHeight;

  /// Token override; falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  static const Color _addedSeed = Color(0xff2f9e44);
  static const Color _removedSeed = Color(0xffe03131);

  /// 差异底色:亮色主题加深、暗色主题提亮,压在同一底色上才两头都能看。
  static Color _tint(Color seed, Color base) => Color.alphaBlend(
      seed.withValues(alpha: base.computeLuminance() > 0.5 ? 0.15 : 0.26),
      base);

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    final rows = diffTextLines(before, after);
    final body = TextStyle(
      fontFamily: 'monospace',
      fontSize: fontSize,
      height: 1.0,
      color: t.foregroundColor,
      decoration: TextDecoration.none,
    );
    final numberStyle = TextStyle(
      fontFamily: 'monospace',
      fontSize: fontSize - 0.5,
      height: 1.0,
      color: t.disabledForegroundColor,
      decoration: TextDecoration.none,
    );
    final labelStyle = TextStyle(
      fontSize: t.fontSize,
      color: t.mutedForegroundColor,
      decoration: TextDecoration.none,
    );
    final changedBg = _tint(_addedSeed, t.backgroundColor);
    final removedBg = _tint(_removedSeed, t.backgroundColor);
    // 空槽(该侧没有这一行)用中性灰,和「有内容但没变」区分开
    final gapBg = Color.alphaBlend(
        t.foregroundColor.withValues(alpha: 0.05), t.backgroundColor);

    // 内容宽 = 最长行的字符数 × 单字符宽。等宽字体下算一次就够,
    // 比让 Text 自己撑开稳定:既不换行,也不会盖到邻栏。
    final charW = _measureCharWidth(body);
    final leftW = _maxChars(rows, true) * charW;
    final rightW = _maxChars(rows, false) * charW;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (beforeLabel != null || afterLabel != null)
          Container(
            color: t.secondaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(child: Text(beforeLabel ?? '', style: labelStyle)),
                SizedBox(width: t.borderWidth),
                Expanded(child: Text(afterLabel ?? '', style: labelStyle)),
              ],
            ),
          ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 4, bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _pane(
                    rows: rows,
                    left: true,
                    contentWidth: leftW,
                    body: body,
                    numberStyle: numberStyle,
                    background: t.backgroundColor,
                    changedBg: changedBg,
                    removedBg: removedBg,
                    gapBg: gapBg,
                  ),
                ),
                Container(width: t.borderWidth, color: t.borderColor),
                Expanded(
                  child: _pane(
                    rows: rows,
                    left: false,
                    contentWidth: rightW,
                    body: body,
                    numberStyle: numberStyle,
                    background: t.backgroundColor,
                    changedBg: changedBg,
                    removedBg: removedBg,
                    gapBg: gapBg,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _pane({
    required List<TextDiffRow> rows,
    required bool left,
    required double contentWidth,
    required TextStyle body,
    required TextStyle numberStyle,
    required Color background,
    required Color changedBg,
    required Color removedBg,
    required Color gapBg,
  }) {
    final numberWidth =
        _maxDigits(rows, left) * _measureCharWidth(numberStyle) + 10;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: numberWidth + contentWidth + 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final r in rows)
              _row(
                text: left ? r.left : r.right,
                number: left ? r.leftLine : r.rightLine,
                kind: r.kind,
                body: body,
                numberStyle: numberStyle,
                background: background,
                changedBg: changedBg,
                removedBg: removedBg,
                gapBg: gapBg,
                numberWidth: numberWidth,
                contentWidth: contentWidth,
              ),
          ],
        ),
      ),
    );
  }

  Widget _row({
    required String? text,
    required int number,
    required TextDiffKind kind,
    required TextStyle body,
    required TextStyle numberStyle,
    required Color background,
    required Color changedBg,
    required Color removedBg,
    required Color gapBg,
    required double numberWidth,
    required double contentWidth,
  }) {
    // 插入行的左侧、删除行的右侧本来就是空槽,由 text == null 走 gapBg
    final rowBg = switch (kind) {
      TextDiffKind.equal => background,
      TextDiffKind.replaced || TextDiffKind.inserted => changedBg,
      TextDiffKind.deleted => removedBg,
    };
    return Container(
      height: lineHeight,
      color: text == null ? gapBg : rowBg,
      child: Row(
        children: [
          SizedBox(
            width: numberWidth,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(number == 0 ? '' : '$number', style: numberStyle),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: contentWidth,
            child: text == null
                ? null
                : Align(
                    alignment: Alignment.centerLeft,
                    child: Text(text,
                        style: body,
                        softWrap: false,
                        overflow: TextOverflow.clip),
                  ),
          ),
        ],
      ),
    );
  }

  static double _measureCharWidth(TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: '0' * 10, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    return tp.width / 10;
  }

  static int _maxChars(List<TextDiffRow> rows, bool left) {
    var max = 1;
    for (final r in rows) {
      final s = left ? r.left : r.right;
      if (s != null && s.length > max) max = s.length;
    }
    return max;
  }

  static int _maxDigits(List<TextDiffRow> rows, bool left) {
    var max = 1;
    for (final r in rows) {
      final n = left ? r.leftLine : r.rightLine;
      if (n > max) max = n;
    }
    return '$max'.length;
  }
}
