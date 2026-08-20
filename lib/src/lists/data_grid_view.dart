import 'dart:collection';

import 'package:flutter/gestures.dart' show kSecondaryMouseButton;
import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

// ---------------------------------------------------------------------------
// Column model
// ---------------------------------------------------------------------------

/// Describes a single column in a [DataGridView].
class DataGridViewColumn {
  const DataGridViewColumn({
    required this.title,
    this.width,
    this.flex = 1,
    this.alignment = Alignment.centerLeft,
  });

  /// Header text.
  final String title;

  /// Fixed width in logical pixels. When set, [flex] is ignored.
  final double? width;

  /// Flex factor for proportional sizing.
  final int flex;

  /// Cell content alignment.
  final Alignment alignment;
}

// ---------------------------------------------------------------------------
// Dirty tracker
// ---------------------------------------------------------------------------

/// Tracks which cells have been modified so that only dirty cells trigger a
/// rebuild. This is the foundation for keeping 100 k-row grids at 60 FPS.
class CellDirtyTracker extends ChangeNotifier {
  final HashSet<int> _dirtyRows = HashSet<int>();
  final HashSet<(int, int)> _dirtyCells = HashSet<(int, int)>();

  /// Mark an entire row as dirty.
  void markRowDirty(int row) {
    _dirtyRows.add(row);
    notifyListeners();
  }

  /// Mark a single cell as dirty.
  void markCellDirty(int row, int col) {
    _dirtyCells.add((row, col));
    notifyListeners();
  }

  /// Returns `true` when [row] needs repainting.
  bool isRowDirty(int row) => _dirtyRows.contains(row);

  /// Returns `true` when the cell at ([row], [col]) needs repainting.
  bool isCellDirty(int row, int col) =>
      _dirtyRows.contains(row) || _dirtyCells.contains((row, col));

  /// Clears all dirty flags. Typically called after a frame has been painted.
  void clearAll() {
    _dirtyRows.clear();
    _dirtyCells.clear();
  }
}

// ---------------------------------------------------------------------------
// DataGridView
// ---------------------------------------------------------------------------

/// A WinForm-style data grid view.
///
/// Provides a headless, virtualised table with cell-level dirty tracking.
/// Only visible rows are built (via [ListView.builder]), and the
/// [CellDirtyTracker] ensures that only modified cells trigger rebuilds.
///
/// Cell interactions follow the desktop fast-response rules: selection fires
/// from [Listener.onPointerDown] (zero latency), double-click lives on a
/// separate [GestureDetector] so a single click is never held back.
class DataGridView extends StatefulWidget {
  const DataGridView({
    super.key,
    required this.columns,
    required this.rowCount,
    required this.cellBuilder,
    this.dirtyTracker,
    this.selectedRow,
    this.onRowSelected,
    this.tokens,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
    this.rowHeight,
    this.showHeader = true,
    this.showRowNumbers = false,
    this.rowNumberWidth = 22,
    this.rowNumberBuilder,
    this.selectedCell,
    this.onCellSelected,
    this.onCellDoubleTap,
    this.onCellContext,
    this.headerColor,
    this.gridLineColor,
    this.selectedTextColor,
    this.cellPaddingX,
    this.headerFontSize,
    this.rowHoverColor,
    this.zebra = false,
  });

  /// Column definitions.
  final List<DataGridViewColumn> columns;

  /// Total number of data rows (may be very large).
  final int rowCount;

  /// Builds the content for a single cell. Receives the row index and column
  /// index. The returned widget is the cell's visual content.
  final Widget Function(int row, int col) cellBuilder;

  /// Optional dirty tracker for cell-level rebuild optimisation.
  final CellDirtyTracker? dirtyTracker;

  /// The currently selected row index, or `null`.
  final int? selectedRow;

  /// Called when the user selects a row (row-number column click; also the
  /// fallback when [onCellSelected] is not provided).
  final ValueChanged<int>? onRowSelected;

  /// Token override.
  final DesktopTokens? tokens;

  /// Focus node for keyboard navigation.
  final FocusNode? focusNode;

  /// Whether the grid should focus itself when first built.
  final bool autofocus;

  /// Whether the grid is interactive.
  final bool enabled;

  /// Height of each data row. Defaults to [DesktopTokens.controlHeight].
  final double? rowHeight;

  /// Whether to show the column header row.
  final bool showHeader;

  /// Whether to show the leading row-number (selection) column.
  final bool showRowNumbers;

  /// Width of the row-number column.
  final double rowNumberWidth;

  /// Builds the row-number column content; receives the row index and
  /// whether the row is selected (e.g. a play arrow for the selected row).
  final Widget Function(int row, bool rowSelected)? rowNumberBuilder;

  /// The currently selected cell as a `(row, col)` record, or `null`.
  final (int, int)? selectedCell;

  /// Called when a cell is selected (pointer-down, zero latency).
  final void Function(int row, int col)? onCellSelected;

  /// Called when a cell is double-clicked.
  final void Function(int row, int col)? onCellDoubleTap;

  /// Called when a cell is right-clicked, with the global pointer position.
  final void Function(int row, int col, Offset position)? onCellContext;

  /// Header row background; defaults to [DesktopTokens.controlColor].
  final Color? headerColor;

  /// Vertical line color between columns; defaults to
  /// [DesktopTokens.borderColor].
  final Color? gridLineColor;

  /// Text color of selected rows / cells; defaults to
  /// [DesktopTokens.surfaceColor] (kept for backward compatibility).
  final Color? selectedTextColor;

  /// Horizontal padding of data cells; defaults to
  /// [DesktopTokens.controlPaddingX].
  final double? cellPaddingX;

  /// Header text size; defaults to [DesktopTokens.fontSize].
  final double? headerFontSize;

  /// Hover background of data rows; defaults to the token hover overlay
  /// blended over [DesktopTokens.surfaceColor].
  final Color? rowHoverColor;

  /// Whether odd rows get a faint zebra tint (WinForms list-style grids).
  final bool zebra;

  @override
  State<DataGridView> createState() => _DataGridViewState();
}

class _DataGridViewState extends State<DataGridView> {
  late final FocusNode _focusNode;
  late final bool _ownsFocusNode;

  @override
  void initState() {
    super.initState();
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();
    widget.dirtyTracker?.addListener(_onDirty);
  }

  @override
  void didUpdateWidget(covariant DataGridView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dirtyTracker != widget.dirtyTracker) {
      oldWidget.dirtyTracker?.removeListener(_onDirty);
      widget.dirtyTracker?.addListener(_onDirty);
    }
  }

  @override
  void dispose() {
    widget.dirtyTracker?.removeListener(_onDirty);
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  void _onDirty() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t =
        widget.tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    final rh = widget.rowHeight ?? t.controlHeight;

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
            if (widget.showHeader) _buildHeader(t),
            Expanded(
              child: ListView.builder(
                itemCount: widget.rowCount,
                itemExtent: rh,
                padding: EdgeInsets.zero,
                itemBuilder: (context, row) =>
                    _buildRow(t, row, rh),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -- Header ---------------------------------------------------------------

  Widget _buildHeader(DesktopTokens t) {
    final lineColor = widget.gridLineColor ?? t.borderColor;
    return Container(
      height: widget.rowHeight ?? t.controlHeight,
      decoration: BoxDecoration(
        color: widget.headerColor ?? t.controlColor,
        border: Border(
          bottom: BorderSide(color: t.borderColor, width: t.borderWidth),
        ),
      ),
      child: Row(
        children: [
          if (widget.showRowNumbers)
            SizedBox(
              width: widget.rowNumberWidth,
              child: Container(
                height: widget.rowHeight ?? t.controlHeight,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: lineColor, width: t.borderWidth),
                  ),
                ),
              ),
            ),
          for (final col in widget.columns)
            _buildHeaderCell(
              t,
              col,
              lineColor,
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(DesktopTokens t, DataGridViewColumn col, Color lineColor) {
    Widget cell = Container(
      height: widget.rowHeight ?? t.controlHeight,
      padding: EdgeInsets.symmetric(horizontal: widget.cellPaddingX ?? t.controlPaddingX),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: lineColor, width: t.borderWidth),
        ),
      ),
      child: Text(
        col.title,
        style: TextStyle(
          fontFamily: t.fontFamily,
          fontSize: widget.headerFontSize ?? t.fontSize,
          color: t.foregroundColor,
          fontWeight: FontWeight.w600,
          height: 1.0,
          decoration: TextDecoration.none,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
    if (col.width != null) {
      return SizedBox(width: col.width, child: cell);
    }
    return Expanded(flex: col.flex, child: cell);
  }

  // -- Data row -------------------------------------------------------------

  Widget _buildRow(DesktopTokens t, int row, double rh) {
    return _DataGridRow(
      t: t,
      row: row,
      rowHeight: rh,
      columns: widget.columns,
      cellBuilder: widget.cellBuilder,
      isSelected: widget.selectedRow == row,
      selectedCell: widget.selectedCell,
      enabled: widget.enabled,
      onRowSelected: widget.onRowSelected,
      onCellSelected: widget.onCellSelected,
      onCellDoubleTap: widget.onCellDoubleTap,
      onCellContext: widget.onCellContext,
      showRowNumbers: widget.showRowNumbers,
      rowNumberWidth: widget.rowNumberWidth,
      rowNumberBuilder: widget.rowNumberBuilder,
      gridLineColor: widget.gridLineColor ?? t.borderColor,
      selectedTextColor:
          widget.selectedTextColor ?? t.surfaceColor,
      cellPaddingX: widget.cellPaddingX ?? t.controlPaddingX,
      hoverColor: widget.rowHoverColor ??
          Color.alphaBlend(t.hoverOverlayColor, t.surfaceColor),
      zebra: widget.zebra,
    );
  }
}

/// 单行数据行:hover 态由行内自持,避免整页重建;行号列按下选中整行,
/// 单元格按下选中该单元格,均用 [Listener.onPointerDown] 零延迟触发;
/// 双击动作单独挂 [GestureDetector],不影响单击响应速度。
class _DataGridRow extends StatefulWidget {
  const _DataGridRow({
    required this.t,
    required this.row,
    required this.rowHeight,
    required this.columns,
    required this.cellBuilder,
    required this.isSelected,
    required this.selectedCell,
    required this.onRowSelected,
    required this.onCellSelected,
    required this.enabled,
    this.onCellDoubleTap,
    this.onCellContext,
    this.showRowNumbers = false,
    this.rowNumberWidth = 22,
    this.rowNumberBuilder,
    required this.gridLineColor,
    required this.selectedTextColor,
    required this.cellPaddingX,
    required this.hoverColor,
    required this.zebra,
  });

  final DesktopTokens t;
  final int row;
  final double rowHeight;
  final List<DataGridViewColumn> columns;
  final Widget Function(int row, int col) cellBuilder;
  final bool isSelected;
  final (int, int)? selectedCell;
  final ValueChanged<int>? onRowSelected;
  final void Function(int row, int col)? onCellSelected;
  final void Function(int row, int col)? onCellDoubleTap;
  final void Function(int row, int col, Offset position)? onCellContext;
  final bool enabled;
  final bool showRowNumbers;
  final double rowNumberWidth;
  final Widget Function(int row, bool rowSelected)? rowNumberBuilder;
  final Color gridLineColor;
  final Color selectedTextColor;
  final double cellPaddingX;
  final Color hoverColor;
  final bool zebra;

  @override
  State<_DataGridRow> createState() => _DataGridRowState();
}

class _DataGridRowState extends State<_DataGridRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final w = widget;
    // hover 色基于表面色派生,明暗自适应
    final bg = w.isSelected
        ? w.t.primaryColor
        : (_hovered && w.enabled
            ? w.hoverColor
            : (w.zebra && w.row.isOdd
                ? Color.alphaBlend(
                    w.t.hoverOverlayColor.withValues(alpha: 0.4),
                    w.t.surfaceColor,
                  )
                : Colors.transparent));

    return MouseRegion(
      onEnter: w.enabled ? (_) => setState(() => _hovered = true) : null,
      onExit: (_) => setState(() => _hovered = false),
      child: Container(
        height: w.rowHeight,
        color: bg,
        child: Row(
          children: [
            if (w.showRowNumbers) _buildRowNumberCell(),
            for (var col = 0; col < w.columns.length; col++)
              _buildCell(col),
          ],
        ),
      ),
    );
  }

  // 行号(选中)列:按下选中整行;右键同样弹菜单(作用于首列)
  Widget _buildRowNumberCell() {
    final w = widget;
    return SizedBox(
      width: w.rowNumberWidth,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: w.enabled
            ? (event) {
                w.onRowSelected?.call(w.row);
                if (event.buttons == kSecondaryMouseButton) {
                  w.onCellContext?.call(w.row, 0, event.position);
                }
              }
            : null,
        child: Container(
          height: w.rowHeight,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: w.gridLineColor, width: w.t.borderWidth),
            ),
          ),
          child: w.rowNumberBuilder?.call(w.row, w.isSelected),
        ),
      ),
    );
  }

  Widget _buildCell(int col) {
    final w = widget;
    final column = w.columns[col];
    final cellSelected = w.selectedCell != null &&
        w.selectedCell!.$1 == w.row &&
        w.selectedCell!.$2 == col;
    // 单元格选中时文字反白,否则跟随行文字色
    final fg = cellSelected
        ? w.selectedTextColor
        : (w.isSelected
            ? w.selectedTextColor
            : (w.enabled ? w.t.foregroundColor : w.t.disabledForegroundColor));

    Widget cell = Listener(
      behavior: HitTestBehavior.opaque,
      // 左键:按下瞬间选中该单元格(零延迟);右键:选中并弹出单元格菜单
      onPointerDown: w.enabled
          ? (event) {
              w.onCellSelected?.call(w.row, col);
              // 未提供单元格选中时回退到整行选中(向后兼容)
              if (w.onCellSelected == null) {
                w.onRowSelected?.call(w.row);
              }
              if (event.buttons == kSecondaryMouseButton) {
                w.onCellContext?.call(w.row, col, event.position);
              }
            }
          : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onDoubleTap: w.enabled && w.onCellDoubleTap != null
            ? () => w.onCellDoubleTap!(w.row, col)
            : null,
        child: Container(
          height: w.rowHeight,
          padding: EdgeInsets.symmetric(horizontal: w.cellPaddingX),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: cellSelected ? w.t.primaryColor : null,
            border: Border(
              right: BorderSide(color: w.gridLineColor, width: w.t.borderWidth),
            ),
          ),
          child: DefaultTextStyle.merge(
            style: TextStyle(color: fg),
            child: w.cellBuilder(w.row, col),
          ),
        ),
      ),
    );

    if (column.alignment != Alignment.centerLeft) {
      cell = Align(alignment: column.alignment, child: cell);
    }
    if (column.width != null) {
      return SizedBox(width: column.width, child: cell);
    }
    return Expanded(flex: column.flex, child: cell);
  }
}
