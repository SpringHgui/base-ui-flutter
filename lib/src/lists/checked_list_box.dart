import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// A WinForm-style checked list box.
///
/// Combines [ListBox] and [CheckBox] - each item has a check box on the left
/// and a text label on the right.
class CheckedListBox<T> extends StatefulWidget {
  const CheckedListBox({
    super.key,
    required this.items,
    this.checkedIndices = const {},
    this.onItemCheckChanged,
    this.tokens,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
    this.itemToString,
    this.itemHeight,
  });

  /// The items to display.
  final List<T> items;

  /// The set of currently checked indices.
  final Set<int> checkedIndices;

  /// Called when an item's check state changes.
  final ValueChanged<Set<int>>? onItemCheckChanged;

  /// Token override.
  final DesktopTokens? tokens;

  /// Focus node for keyboard navigation.
  final FocusNode? focusNode;

  /// Whether the list box should focus itself when first built.
  final bool autofocus;

  /// Whether the list box is interactive.
  final bool enabled;

  /// Converts an item to its string representation.
  final String Function(T)? itemToString;

  /// Height of each row. Defaults to [DesktopTokens.controlHeight].
  final double? itemHeight;

  @override
  State<CheckedListBox<T>> createState() => _CheckedListBoxState<T>();
}

class _CheckedListBoxState<T> extends State<CheckedListBox<T>> {
  late final FocusNode _focusNode;
  late final bool _ownsFocusNode;

  @override
  void initState() {
    super.initState();
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  String _itemString(T item) =>
      widget.itemToString?.call(item) ?? item.toString();

  void _toggle(int index) {
    if (!widget.enabled) return;
    final newSet = Set<int>.from(widget.checkedIndices);
    if (newSet.contains(index)) {
      newSet.remove(index);
    } else {
      newSet.add(index);
    }
    widget.onItemCheckChanged?.call(newSet);
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens ??
        TokenScope.maybeOf(context) ??
        DesktopTokens.winForm;
    final rowHeight = widget.itemHeight ?? t.controlHeight;

    // Shared style/padding objects allocated once per build, not per row.
    final textStyle = TextStyle(
      fontFamily: t.fontFamily,
      fontSize: t.fontSize,
      color: widget.enabled ? t.foregroundColor : t.disabledForegroundColor,
      height: 1.0,
    );
    final rowPadding = EdgeInsets.symmetric(horizontal: t.compactSpacing);
    final boxSide = BorderSide(color: t.borderColor, width: t.borderWidth);
    final checkSize = t.controlHeight * 0.75;

    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: widget.enabled ? t.surfaceColor : t.controlDisabledColor,
          border: Border.all(color: t.borderColor, width: t.borderWidth),
          borderRadius: BorderRadius.circular(t.cornerRadius),
        ),
        child: ListView.builder(
          itemCount: widget.items.length,
          itemExtent: rowHeight,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            final isChecked = widget.checkedIndices.contains(index);
            return GestureDetector(
              onTap: () => _toggle(index),
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: rowHeight,
                padding: rowPadding,
                child: Row(
                  children: [
                    SizedBox(
                      width: checkSize,
                      height: checkSize,
                      child: Checkbox(
                        value: isChecked,
                        onChanged: (_) => _toggle(index),
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        fillColor: WidgetStateProperty.resolveWith(
                          (states) => isChecked
                              ? t.primaryColor
                              : t.surfaceColor,
                        ),
                        checkColor: t.surfaceColor,
                        side: boxSide,
                      ),
                    ),
                    SizedBox(width: t.compactSpacing),
                    Expanded(
                      child: Text(
                        _itemString(widget.items[index]),
                        style: textStyle,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
