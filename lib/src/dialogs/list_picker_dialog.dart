import 'package:flutter/material.dart';

import '../common/button.dart';
import '../common/check_box.dart';
import '../common/icon_button.dart';
import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';
import 'dialog_box.dart';

/// A modal multi-select picker: tick any number of candidate items, then
/// confirm. The WinForm counterpart of a "choose related objects" dialog
/// (picking parent tables, columns, …).
///
/// It performs selection only — nothing is written back to a model: [show]
/// resolves to the checked items **in the current row order**, or `null` when
/// the user cancels. That order is meaningful to the caller (e.g. the order
/// parent tables are written in `INHERITS (…)`) — ↑ / ↓ move the marked row to
/// change it. Composed of [DialogBox] + [IconBtn] + [Button], so every visual
/// flows from [DesktopTokens] and there is no animation.
///
/// ```dart
/// final picked = await ListPickerDialog.show<String>(
///   context,
///   title: '选择继承的父表',
///   items: tables,
///   selected: current,
///   itemToString: (t) => '"public"."$t"',
/// );
/// ```
///
/// Like other overlays here it uses the root navigator by default, so the
/// enclosing [TokenScope] must sit above the `Navigator` (as in an app whose
/// `MaterialApp` is wrapped by the theme scope) for the dialog to pick up the
/// active theme; otherwise it falls back to [DesktopTokens.winForm].
class ListPickerDialog<T> extends StatefulWidget {
  const ListPickerDialog({
    super.key,
    required this.title,
    required this.items,
    this.selected = const [],
    this.itemToString,
    this.itemHeader,
    this.emptyHint,
    this.okText,
    this.cancelText,
    this.width = 420,
    this.height = 460,
    this.tokens,
  });

  /// Title bar text.
  final String title;

  /// Candidate items, displayed in this order.
  final List<T> items;

  /// Items already checked when the dialog opens.
  final List<T> selected;

  /// Candidate label renderer; defaults to `toString()`.
  final String Function(T item)? itemToString;

  /// Column header above the labels; defaults to `名称` (the reference tool
  /// labels this single column, it is not a bare checklist).
  final String? itemHeader;

  /// Message shown when [items] is empty.
  final String? emptyHint;

  /// Confirm / dismiss labels; default to `OK` / `Cancel`.
  final String? okText;
  final String? cancelText;

  /// Dialog size (defaults to a roomy list).
  final double width;
  final double height;

  /// Token override; falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  /// Shows the dialog and resolves to the confirmed selection, or `null` on
  /// cancel / close.
  static Future<List<T>?> show<T>(
    BuildContext context, {
    required String title,
    required List<T> items,
    List<T> selected = const [],
    String Function(T item)? itemToString,
    String? itemHeader,
    String? emptyHint,
    String? okText,
    String? cancelText,
    double width = 420,
    double height = 460,
    DesktopTokens? tokens,
  }) {
    return showDialog<List<T>>(
      context: context,
      builder: (_) => ListPickerDialog<T>(
        title: title,
        items: items,
        selected: selected,
        itemToString: itemToString,
        itemHeader: itemHeader,
        emptyHint: emptyHint,
        okText: okText,
        cancelText: cancelText,
        width: width,
        height: height,
        tokens: tokens,
      ),
    );
  }

  @override
  State<ListPickerDialog<T>> createState() => _ListPickerDialogState<T>();
}

class _ListPickerDialogState<T> extends State<ListPickerDialog<T>> {
  /// 行序可被 ↑↓ 改变,故拷一份而不是直接排 [widget.items]。
  late final List<T> _rows = List<T>.of(widget.items);

  /// 必须用 [Set.from] 显式建 `Set<T>`:`selected` 的默认值 `const []` 在泛型
  /// 声明处无法得知 T,运行时实际是 `List<Never>`,直接 `toSet()` 会得到
  /// `Set<Never>` → 首次勾选时 `addAll` 抛 `Iterable<Never>` 类型错误。
  late final Set<T> _checked = Set<T>.from(widget.selected);

  /// 标记行(▶):↑↓ 作用于它,单击行即置为标记行。
  int _current = 0;

  /// 「当前行」槽宽:与数据网格的行首槽同一档
  static const double _markerWidth = 16;

  String _label(T item) => widget.itemToString?.call(item) ?? item.toString();

  bool get _hasRow => _current >= 0 && _current < _rows.length;

  void _move(int delta) {
    final to = _current + delta;
    if (!_hasRow || to < 0 || to >= _rows.length) return;
    setState(() {
      final item = _rows.removeAt(_current);
      _rows.insert(to, item);
      _current = to;
    });
  }

  void _confirm() => Navigator.of(context).pop(<T>[
        // 按当前行序回传:点击先后不影响结果,行序才是调用方要的顺序
        for (final item in _rows) //
          if (_checked.contains(item)) item,
      ]);

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens ??
        TokenScope.maybeOf(context) ??
        DesktopTokens.winForm;
    return DialogBox(
      title: widget.title,
      width: widget.width,
      height: widget.height,
      tokens: t,
      onClose: () => Navigator.of(context).pop(),
      footer: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: Row(
          children: [
            _op(t, Icons.arrow_upward, _current > 0 ? () => _move(-1) : null),
            const SizedBox(width: 4),
            _op(
              t,
              Icons.arrow_downward,
              _hasRow && _current < _rows.length - 1 ? () => _move(1) : null,
            ),
            const Spacer(),
            Button(text: widget.okText ?? 'OK', onPressed: _confirm),
            const SizedBox(width: 8),
            Button(
              text: widget.cancelText ?? 'Cancel',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
      child: _rows.isEmpty
          ? Center(
              child: Text(
                widget.emptyHint ?? 'No items to choose from.',
                style: TextStyle(
                  fontFamily: t.fontFamily,
                  fontSize: t.fontSize,
                  fontWeight: FontWeight.w400,
                  color: t.mutedForegroundColor,
                  decoration: TextDecoration.none,
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _head(t),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: t.surfaceColor,
                        border: Border.all(color: t.borderColor, width: t.borderWidth),
                        borderRadius: BorderRadius.circular(t.cornerRadius),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: ListView.builder(
                        itemCount: _rows.length,
                        itemExtent: t.controlHeight,
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, i) => _rowView(t, i),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  /// 底部左侧的行操作按钮(灰底描边,与网格弹窗同一档)
  Widget _op(DesktopTokens t, IconData icon, VoidCallback? onTap) => IconBtn(
        icon: icon,
        iconSize: 15,
        size: const Size(28, 26),
        outline: true,
        tokens: t,
        color: onTap == null ? t.disabledForegroundColor : t.foregroundColor,
        onTap: onTap,
      );

  Widget _head(DesktopTokens t) => Container(
        height: 26,
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: t.secondaryColor,
          border: Border(bottom: BorderSide(color: t.borderColor, width: t.borderWidth)),
          borderRadius: BorderRadius.circular(t.cornerRadius),
        ),
        child: Row(
          children: [
            const SizedBox(width: _markerWidth),
            const SizedBox(width: 24),
            Expanded(
              child: Text(
                widget.itemHeader ?? '名称',
                style: TextStyle(
                  fontFamily: t.fontFamily,
                  fontSize: t.fontSize,
                  fontWeight: FontWeight.w600,
                  color: t.mutedForegroundColor,
                  decoration: TextDecoration.none,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      );

  /// 行:按下即置为标记行(零延迟);勾选框单独决定是否选中
  Widget _rowView(DesktopTokens t, int i) {
    final item = _rows[i];
    final isCurrent = i == _current;
    return Listener(
      onPointerDown: (_) => setState(() => _current = i),
      child: Container(
        height: t.controlHeight,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        color: isCurrent
            ? Color.alphaBlend(t.primaryColor.withValues(alpha: 0.16), t.surfaceColor)
            : (i.isOdd
                ? Color.alphaBlend(
                    t.foregroundColor.withValues(alpha: 0.03), t.surfaceColor)
                : t.surfaceColor),
        child: Row(
          children: [
            SizedBox(
              width: _markerWidth,
              child: isCurrent
                  ? Icon(Icons.arrow_right, size: 16, color: t.foregroundColor)
                  : null,
            ),
            const SizedBox(width: 4),
            CheckBox(
              value: _checked.contains(item),
              tokens: t,
              onChanged: (v) => setState(() {
                if (v ?? false) {
                  _checked.add(item);
                } else {
                  _checked.remove(item);
                }
              }),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                _label(item),
                style: TextStyle(
                  fontFamily: t.fontFamily,
                  fontSize: t.fontSize,
                  color: t.foregroundColor,
                  height: 1.0,
                  decoration: TextDecoration.none,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
