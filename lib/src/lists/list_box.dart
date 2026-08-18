import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// A WinForm-style list box.
///
/// Displays a scrollable list of items. Supports single or multiple selection.
class ListBox<T> extends StatefulWidget {
  const ListBox({
    super.key,
    required this.items,
    this.selectedIndices = const {},
    this.onSelectionChanged,
    this.multiSelect = false,
    this.tokens,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
    this.itemToString,
    this.itemHeight,
  });

  /// The items to display.
  final List<T> items;

  /// The set of currently selected indices.
  final Set<int> selectedIndices;

  /// Called when the selection changes.
  final ValueChanged<Set<int>>? onSelectionChanged;

  /// Whether multiple items can be selected at once.
  final bool multiSelect;

  /// Token override. Falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  /// Focus node for keyboard navigation.
  final FocusNode? focusNode;

  /// Whether the list box should focus itself when first built.
  final bool autofocus;

  /// Whether the list box is interactive.
  final bool enabled;

  /// Converts an item to its string representation for display.
  final String Function(T)? itemToString;

  /// Height of each item row. Defaults to [DesktopTokens.controlHeight].
  final double? itemHeight;

  @override
  State<ListBox<T>> createState() => _ListBoxState<T>();
}

class _ListBoxState<T> extends State<ListBox<T>> {
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

  void _handleTap(int index) {
    if (!widget.enabled) return;
    final newSelection = Set<int>.from(widget.selectedIndices);
    if (widget.multiSelect) {
      if (newSelection.contains(index)) {
        newSelection.remove(index);
      } else {
        newSelection.add(index);
      }
    } else {
      newSelection
        ..clear()
        ..add(index);
    }
    widget.onSelectionChanged?.call(newSelection);
  }

  @override
  Widget build(BuildContext context) {
    final t =
        widget.tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    final rowHeight = widget.itemHeight ?? t.controlHeight;

    // Pre-compute shared style objects once per build instead of
    // allocating them inside every row builder.
    final normalStyle = TextStyle(
      fontFamily: t.fontFamily,
      fontSize: t.fontSize,
      color: widget.enabled ? t.foregroundColor : t.disabledForegroundColor,
      height: 1.0,
    );
    final selectedStyle = TextStyle(
      fontFamily: t.fontFamily,
      fontSize: t.fontSize,
      color: t.surfaceColor,
      height: 1.0,
    );
    final rowPadding = EdgeInsets.symmetric(horizontal: t.controlPaddingX);

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
            final isSelected = widget.selectedIndices.contains(index);
            // GestureDetector instead of InkWell: the Material ink
            // splash adds an animation controller + gesture detector
            // per row, which is the main desktop scroll bottleneck.
            return GestureDetector(
              onTap: () => _handleTap(index),
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: rowHeight,
                padding: rowPadding,
                color: isSelected ? t.primaryColor : Colors.transparent,
                alignment: Alignment.centerLeft,
                child: Text(
                  _itemString(widget.items[index]),
                  style: isSelected ? selectedStyle : normalStyle,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
