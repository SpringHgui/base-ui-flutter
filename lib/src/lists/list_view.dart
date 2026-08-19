import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// A WinForm-style list view with Details / icon / multi-select support.
///
/// Supports multiple view modes: [ListViewMode.list] for a simple list,
/// [ListViewMode.details] for a columned table view, and
/// [ListViewMode.icon] for an icon grid.
enum ListViewMode { list, details, icon }

/// Describes a column in [ListViewMode.details] mode.
class ListViewColumn {
  const ListViewColumn({
    required this.title,
    this.width,
    this.flex,
  });

  /// Column header text.
  final String title;

  /// Fixed width in logical pixels. When set, [flex] is ignored.
  final double? width;

  /// Flex factor for proportional sizing. Ignored when [width] is set.
  final int? flex;
}

/// Signature for building custom row widgets in [WinListView].
///
/// Receives the [BuildContext], the data [item], its [index], and whether
/// the row is currently [isSelected].
typedef ListViewIndexedWidgetBuilder<T> = Widget Function(
  BuildContext context,
  T item,
  int index,
  bool isSelected,
);

/// A WinForm-style list view.
///
/// Provides Details, icon, and multi-select modes similar to the WinForms
/// `ListView` control.
///
/// ## Two usage modes
///
/// **Data-driven (default):** pass [items] and optionally [itemToString].
/// The widget renders text rows automatically.
///
/// ```dart
/// WinListView<String>(
///   items: myItems,
///   selectedIndices: _sel,
///   onSelectionChanged: (s) => setState(() => _sel = s),
/// )
/// ```
///
/// **Builder mode:** pass [itemCount] and [itemBuilder] to lazily construct
/// fully custom row widgets — analogous to `ListView.builder`.
///
/// ```dart
/// WinListView<String>(
///   itemCount: 100000,
///   itemBuilder: (ctx, item, index, isSelected) => Text(item),
///   selectedIndices: _sel,
///   onSelectionChanged: (s) => setState(() => _sel = s),
/// )
/// ```
class WinListView<T> extends StatefulWidget {
  const WinListView({
    super.key,
    this.items = const [],
    this.itemCount,
    this.itemBuilder,
    this.columns = const [],
    this.mode = ListViewMode.list,
    this.selectedIndices = const {},
    this.onSelectionChanged,
    this.multiSelect = false,
    this.tokens,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
    this.itemToString,
    this.itemHeight,
    this.onItemActivated,
  });

  /// The data items.
  ///
  /// When [itemBuilder] is `null` (data-driven mode), this list supplies the
  /// rows. When [itemBuilder] is provided, [items] may be omitted and
  /// [itemCount] controls the total row count instead.
  final List<T> items;

  /// Explicit item count for builder mode.
  ///
  /// When set, overrides `items.length` as the total row count. This is
  /// useful when the data is generated lazily or loaded from an external
  /// source and should not be materialised as a full list.
  final int? itemCount;

  /// Custom row builder for builder mode.
  ///
  /// When non-null, the list view delegates row construction to this callback
  /// instead of rendering text automatically. The selection background is
  /// still applied by the surrounding container.
  final ListViewIndexedWidgetBuilder<T>? itemBuilder;

  /// Column definitions for [ListViewMode.details].
  final List<ListViewColumn> columns;

  /// The current view mode.
  final ListViewMode mode;

  /// The set of currently selected indices.
  final Set<int> selectedIndices;

  /// Called when the selection changes.
  final ValueChanged<Set<int>>? onSelectionChanged;

  /// Whether multiple items can be selected.
  final bool multiSelect;

  /// Token override.
  final DesktopTokens? tokens;

  /// Focus node for keyboard navigation.
  final FocusNode? focusNode;

  /// Whether the list view should focus itself when first built.
  final bool autofocus;

  /// Whether the list view is interactive.
  final bool enabled;

  /// Converts an item to its string representation.
  final String Function(T)? itemToString;

  /// Row height. Defaults to [DesktopTokens.controlHeight].
  final double? itemHeight;

  /// Called when an item is double-clicked or activated via Enter.
  final ValueChanged<int>? onItemActivated;

  /// Resolved item count: explicit [itemCount] takes priority over `items.length`.
  int get _effectiveItemCount => itemCount ?? items.length;

  /// Returns the data item at [index], or `null` when no items list is
  /// available (pure builder mode with no data backing).
  T? _itemAt(int index) =>
      index < items.length ? items[index] : null;

  @override
  State<WinListView<T>> createState() => _WinListViewState<T>();
}

class _WinListViewState<T> extends State<WinListView<T>> {
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
      // Clicking the already-selected single item changes nothing.
      if (newSelection.length == 1 && newSelection.contains(index)) return;
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

    // Pre-compute shared styles once per build to avoid per-row allocations.
    final itemStyle = TextStyle(
      fontFamily: t.fontFamily,
      fontSize: t.fontSize,
      color: widget.enabled ? t.foregroundColor : t.disabledForegroundColor,
      height: 1.0,
    );
    final selectedItemStyle = TextStyle(
      fontFamily: t.fontFamily,
      fontSize: t.fontSize,
      color: t.surfaceColor,
      height: 1.0,
    );
    final hPadding = EdgeInsets.symmetric(horizontal: t.controlPaddingX);

    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: widget.enabled ? t.surfaceColor : t.controlDisabledColor,
          border: Border.all(color: t.borderColor, width: t.borderWidth),
          borderRadius: BorderRadius.circular(t.cornerRadius),
        ),
        child: Column(
          children: [
            if (widget.mode == ListViewMode.details &&
                widget.columns.isNotEmpty)
              _buildHeader(t, itemStyle, hPadding),
            Expanded(
              child: ListView.builder(
                itemCount: widget._effectiveItemCount,
                itemExtent: rowHeight,
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) => _buildRow(
                  t, index, rowHeight,
                  itemStyle: itemStyle,
                  selectedItemStyle: selectedItemStyle,
                  hPadding: hPadding,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    DesktopTokens t,
    TextStyle itemStyle,
    EdgeInsets hPadding,
  ) {
    return Container(
      height: t.controlHeight,
      decoration: BoxDecoration(
        color: t.controlColor,
        border: Border(
          bottom: BorderSide(color: t.borderColor, width: t.borderWidth),
        ),
      ),
      child: Row(
        children: [
          for (final col in widget.columns)
            _buildColumnCell(
              col: col,
              hPadding: hPadding,
              borderColor: t.borderColor,
              borderWidth: t.borderWidth,
              child: Text(col.title, style: itemStyle),
            ),
        ],
      ),
    );
  }

  /// Sizes a column cell honouring a fixed [ListViewColumn.width] when
  /// present, otherwise falling back to [ListViewColumn.flex] (the header
  /// and data rows must agree or columns misalign).
  Widget _buildColumnCell({
    required ListViewColumn col,
    required EdgeInsets hPadding,
    required Color borderColor,
    required double borderWidth,
    required Widget child,
  }) {
    Widget cell = Container(
      padding: hPadding,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: borderColor, width: borderWidth),
        ),
      ),
      child: child,
    );
    if (col.width != null) {
      cell = SizedBox(width: col.width, child: cell);
    } else {
      cell = Expanded(flex: col.flex ?? 1, child: cell);
    }
    return cell;
  }

  Widget _buildRow(
    DesktopTokens t,
    int index,
    double rowHeight, {
    required TextStyle itemStyle,
    required TextStyle selectedItemStyle,
    required EdgeInsets hPadding,
  }) {
    final isSelected = widget.selectedIndices.contains(index);

    // 选中走 Listener.onPointerDown(零延迟):onTap 与 onDoubleTap 同注册时,
    // 单击会被双击判定窗口 hold 约 300ms。双击激活由 GestureDetector 单独处理。
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: widget.enabled ? (_) => _handleTap(index) : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onDoubleTap: widget.enabled
            ? () => widget.onItemActivated?.call(index)
            : null,
        child: Container(
          height: rowHeight,
          color: isSelected ? t.primaryColor : null,
          child: _buildRowContent(
            t, index, isSelected, itemStyle, selectedItemStyle, hPadding,
          ),
        ),
      ),
    );
  }

  /// Builds the inner content of a row — either via the user-supplied
  /// [itemBuilder] or the default text rendering.
  Widget _buildRowContent(
    DesktopTokens t,
    int index,
    bool isSelected,
    TextStyle itemStyle,
    TextStyle selectedItemStyle,
    EdgeInsets hPadding,
  ) {
    final builder = widget.itemBuilder;
    final item = widget._itemAt(index);

    // --- Builder mode: delegate to user callback --------------------------------
    if (builder != null && item != null) {
      return builder(context, item, index, isSelected);
    }

    // --- Data-driven mode: default text rendering -------------------------------
    final style = isSelected ? selectedItemStyle : itemStyle;
    final text = item != null ? _itemString(item) : '';

    if (widget.mode == ListViewMode.details &&
        widget.columns.isNotEmpty) {
      return Row(
        children: [
          for (final col in widget.columns)
            _buildColumnCell(
              col: col,
              hPadding: hPadding,
              borderColor: t.borderColor,
              borderWidth: t.borderWidth,
              child: Text(text, style: style),
            ),
        ],
      );
    }

    return Padding(
      padding: hPadding,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(text, style: style),
      ),
    );
  }
}
