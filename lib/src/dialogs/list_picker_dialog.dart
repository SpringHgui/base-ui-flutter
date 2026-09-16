import 'package:flutter/material.dart';

import '../common/button.dart';
import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';
import '../lists/checked_list_box.dart';
import 'dialog_box.dart';

/// A modal multi-select picker: tick any number of candidate items, then
/// confirm. The WinForm counterpart of a "choose related objects" dialog
/// (picking parent tables, columns, …).
///
/// It performs selection only — nothing is written back to a model: [show]
/// resolves to the checked items **in candidate order**, or `null` when the
/// user cancels. Composed of [DialogBox] + [CheckedListBox] + [Button], so
/// every visual flows from [DesktopTokens] and there is no animation.
///
/// ```dart
/// final picked = await ListPickerDialog.show<String>(
///   context,
///   title: '选择继承的父表',
///   items: tables,
///   selected: current,
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
  /// 必须用 [Set.from] 显式建 `Set<T>`:`selected` 的默认值 `const []` 在泛型
  /// 声明处无法得知 T,运行时实际是 `List<Never>`,直接 `toSet()` 会得到
  /// `Set<Never>` → 首次勾选时 `addAll` 抛 `Iterable<Never>` 类型错误。
  late final Set<T> _checked = Set<T>.from(widget.selected);

  String _label(T item) => widget.itemToString?.call(item) ?? item.toString();

  void _confirm() => Navigator.of(context).pop(<T>[
        // 按候选顺序回传,点击先后不影响结果(同名项去重由 Set 承担)
        for (final item in widget.items) //
          if (_checked.contains(item)) item,
      ]);

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens ??
        TokenScope.maybeOf(context) ??
        DesktopTokens.winForm;
    // CheckedListBox 按下标控勾选:每次构建反推一次(候选量级小)
    final checkedIndices = <int>{
      for (var i = 0; i < widget.items.length; i++)
        if (_checked.contains(widget.items[i])) i,
    };
    return DialogBox(
      title: widget.title,
      width: widget.width,
      height: widget.height,
      tokens: t,
      onClose: () => Navigator.of(context).pop(),
      footer: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Button(text: widget.okText ?? 'OK', onPressed: _confirm),
            const SizedBox(width: 8),
            Button(
              text: widget.cancelText ?? 'Cancel',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
      child: widget.items.isEmpty
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
              child: SizedBox(
                width: double.infinity,
                child: CheckedListBox<T>(
                  items: widget.items,
                  checkedIndices: checkedIndices,
                  itemToString: _label,
                  tokens: t,
                  onItemCheckChanged: (indices) => setState(() {
                    _checked
                      ..clear()
                      ..addAll(indices.map((i) => widget.items[i]));
                  }),
                ),
              ),
            ),
    );
  }
}
