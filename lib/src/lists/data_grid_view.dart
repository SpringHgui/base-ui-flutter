import 'dart:async';
import 'dart:collection';

import 'package:flutter/gestures.dart' show kPrimaryMouseButton, kSecondaryMouseButton;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    this.onCellTap,
    this.onCellDoubleTap,
    this.onCellContext,
    this.headerColor,
    this.gridLineColor,
    this.selectedTextColor,
    this.cellPaddingX,
    this.headerFontSize,
    this.rowHoverColor,
    this.zebra = false,
    this.verticalScrollController,
    this.columnWidths,
    this.onColumnResize,
    this.minColumnWidth = 40,
    this.selectedCells,
    this.onCellsSelected,
    this.anchorCell,
    this.editingCell,
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

  /// Called when a cell is single-clicked (left-button pointer-down, zero
  /// latency). Distinct from [onCellSelected] so callers can attach an
  /// "enter edit" action without conflating it with mere selection.
  final void Function(int row, int col)? onCellTap;

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

  /// Optional external scroll controller for the vertical ListView.
  /// When provided, the caller can attach a ScrollBar or synchronise
  /// scrolling with other widgets.
  final ScrollController? verticalScrollController;

  /// Explicit pixel widths for every column (length must equal
  /// [columns].length). When provided, takes precedence over each
  /// column's [DataGridViewColumn.width] / [DataGridViewColumn.flex].
  final List<double>? columnWidths;

  /// Fired while the user drags a column border in the header.
  /// [columnIndex] is the column being resized; [newWidth] is the
  /// proposed width (already clamped to [minColumnWidth]).
  final void Function(int columnIndex, double newWidth)? onColumnResize;

  /// Minimum column width in logical pixels when resizing.
  final double minColumnWidth;

  /// Set of currently selected cells for multi-selection.
  /// When non-null, takes precedence over [selectedCell] for visual rendering.
  final Set<(int, int)>? selectedCells;

  /// Called when the cell selection changes (click, Ctrl+click,
  /// Shift+click, or drag selection). Receives the full new selection set.
  final ValueChanged<Set<(int, int)>>? onCellsSelected;

  /// The anchor cell for Shift+click range selection.
  /// Typically the last singly-clicked cell.
  final (int, int)? anchorCell;

  /// The cell currently in edit mode; when set, the matching cell skips the
  /// horizontal padding so the editor fills the full cell width.
  final (int, int)? editingCell;

  @override
  State<DataGridView> createState() => _DataGridViewState();
}

class _DataGridViewState extends State<DataGridView> {
  late final FocusNode _focusNode;
  late final bool _ownsFocusNode;

  // ── 拖拽多选状态 ──
  bool _isDragging = false;
  (int, int)? _dragStartCell;
  (int, int)? _dragCurrentCell;

  // ── 拖拽自动滚动 ──
  Timer? _autoScrollTimer;
  double _autoScrollPointerY = 0;
  static const double _autoScrollEdgeSize = 30.0;
  static const double _autoScrollSpeed = 12.0;

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
    _stopAutoScroll();
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
    final multiSelect = widget.onCellsSelected != null;

    Widget listArea = ListView.builder(
      controller: widget.verticalScrollController,
      itemCount: widget.rowCount,
      itemExtent: rh,
      padding: EdgeInsets.zero,
      itemBuilder: (context, row) => _buildRow(t, row, rh),
    );

    // 多选模式:包裹 Listener 跟踪拖拽选择
    if (multiSelect) {
      listArea = Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (event) {
          if (event.buttons != kPrimaryMouseButton) return;
          final row = _rowAtY(event.localPosition.dy, rh);
          if (row == null || row >= widget.rowCount) return;
          final col = _colAtX(event.localPosition);
          if (col == null) return;
          _dragStartCell = (row, col);
          _dragCurrentCell = (row, col);
          _isDragging = false; // 尚未移动,不算拖拽
        },
        onPointerMove: (event) {
          if (_dragStartCell == null) return;
          _autoScrollPointerY = event.localPosition.dy;
          final row = _rowAtY(event.localPosition.dy, rh);
          if (row == null) return;
          final col = _colAtX(event.localPosition);
          if (col == null) return;
          final newCell = (row, col);
          if (!_isDragging && newCell != _dragStartCell) {
            _isDragging = true;
          }
          if (_isDragging && newCell != _dragCurrentCell) {
            _dragCurrentCell = newCell;
            _updateDragSelection();
          }
          // 边缘检测:靠近顶部/底部时启动自动滚动
          final size = context.size;
          if (size != null && _isDragging) {
            final h = size.height;
            if (_autoScrollPointerY < _autoScrollEdgeSize ||
                _autoScrollPointerY > h - _autoScrollEdgeSize) {
              _startAutoScroll();
            } else {
              _stopAutoScroll();
            }
          }
        },
        onPointerUp: (event) {
          final wasDragging = _isDragging;
          _dragStartCell = null;
          _dragCurrentCell = null;
          _isDragging = false;
          _stopAutoScroll();
          // 拖拽中重建的行缓存了 isDragging=true,结束时必须再重建,
          // 否则单元格 onPointerDown 会被过期的 isDragging 拦截(无法单选)
          if (wasDragging) setState(() {});
        },
        onPointerCancel: (event) {
          final wasDragging = _isDragging;
          _dragStartCell = null;
          _dragCurrentCell = null;
          _isDragging = false;
          _stopAutoScroll();
          if (wasDragging) setState(() {});
        },
        child: listArea,
      );
    }

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
            Expanded(child: listArea),
          ],
        ),
      ),
    );
  }

  // ── 拖拽多选辅助 ─────────────────────────────────────────

  int? _rowAtY(double localY, double rh) {
    if (localY < 0) return null;
    final row = localY ~/ rh;
    if (row >= widget.rowCount) return widget.rowCount - 1;
    return row;
  }

  int? _colAtX(Offset localPos) {
    final widths = widget.columnWidths;
    final cols = widget.columns;
    double x = localPos.dx;
    // 跳过行号列
    if (widget.showRowNumbers) {
      x -= widget.rowNumberWidth;
    }
    if (x < 0) return null;
    double offset = 0;
    for (var i = 0; i < cols.length; i++) {
      final cw = widths != null ? widths[i] : (cols[i].width ?? 0);
      if (cw == 0) continue;
      offset += cw;
      if (x <= offset) return i;
    }
    return cols.length - 1;
  }

  void _updateDragSelection() {
    final start = _dragStartCell;
    final current = _dragCurrentCell;
    if (start == null || current == null) return;
    final minRow = start.$1 < current.$1 ? start.$1 : current.$1;
    final maxRow = start.$1 > current.$1 ? start.$1 : current.$1;
    final minCol = start.$2 < current.$2 ? start.$2 : current.$2;
    final maxCol = start.$2 > current.$2 ? start.$2 : current.$2;
    final cells = <(int, int)>{};
    for (var r = minRow; r <= maxRow; r++) {
      for (var c = minCol; c <= maxCol; c++) {
        cells.add((r, c));
      }
    }
    widget.onCellsSelected?.call(cells);
  }

  // ── 自动滚动 ─────────────────────────────────────────

  void _startAutoScroll() {
    if (_autoScrollTimer != null) return;
    _autoScrollTimer = Timer.periodic(
      const Duration(milliseconds: 16),
      (_) => _performAutoScroll(),
    );
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  void _performAutoScroll() {
    final controller = widget.verticalScrollController;
    if (controller == null || !controller.hasClients) {
      _stopAutoScroll();
      return;
    }
    final size = context.size;
    if (size == null) return;
    final h = size.height;
    final rh = widget.rowHeight ?? 26.0;

    double delta = 0;
    if (_autoScrollPointerY < _autoScrollEdgeSize) {
      final ratio = 1.0 - _autoScrollPointerY / _autoScrollEdgeSize;
      delta = -_autoScrollSpeed * ratio;
    } else if (_autoScrollPointerY > h - _autoScrollEdgeSize) {
      final ratio =
          (_autoScrollPointerY - (h - _autoScrollEdgeSize)) / _autoScrollEdgeSize;
      delta = _autoScrollSpeed * ratio;
    }
    if (delta == 0) return;

    final maxScroll = controller.position.maxScrollExtent;
    final newOffset = (controller.offset + delta).clamp(0.0, maxScroll);
    if (newOffset == controller.offset) return;
    controller.jumpTo(newOffset);

    // 根据滚动后的新可见区域更新拖拽选中的行
    if (_dragStartCell != null) {
      final localY = _autoScrollPointerY;
      final row = _rowAtY(localY, rh);
      if (row != null) {
        final col = _dragCurrentCell?.$2 ?? _dragStartCell!.$2;
        final newCell = (row, col);
        if (_dragCurrentCell != newCell) {
          _dragCurrentCell = newCell;
          _updateDragSelection();
        }
      }
    }
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
          for (var i = 0; i < widget.columns.length; i++)
            _buildHeaderCell(
              t,
              i,
              widget.columns[i],
              lineColor,
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(
    DesktopTokens t,
    int columnIndex,
    DataGridViewColumn col,
    Color lineColor,
  ) {
    final widths = widget.columnWidths;
    final w = widths != null ? widths[columnIndex] : col.width;

    Widget cell = Container(
      height: widget.rowHeight ?? t.controlHeight,
      padding: EdgeInsets.symmetric(
        horizontal: widget.cellPaddingX ?? t.controlPaddingX,
      ),
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

    Widget sized;
    if (w != null) {
      sized = SizedBox(width: w, child: cell);
    } else {
      sized = Expanded(flex: col.flex, child: cell);
    }

    // 列头拖拽调整宽度:最后一列无需 resize handle
    final onResize = widget.onColumnResize;
    if (onResize == null ||
        columnIndex >= (widths?.length ?? widget.columns.length) - 1) {
      return sized;
    }

    return Stack(
      children: [
        sized,
        Positioned(
          right: -3,
          top: 0,
          bottom: 0,
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: (details) {
                final currentWidth =
                    widget.columnWidths?[columnIndex] ?? col.width;
                if (currentWidth == null) return;
                final newWidth = (currentWidth + details.delta.dx)
                    .clamp(widget.minColumnWidth, double.infinity);
                onResize(columnIndex, newWidth);
              },
              child: const SizedBox(width: 6),
            ),
          ),
        ),
      ],
    );
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
      selectedCells: widget.selectedCells,
      anchorCell: widget.anchorCell,
      isDragging: _isDragging,
      onCellsSelected: widget.onCellsSelected,
      enabled: widget.enabled,
      onRowSelected: widget.onRowSelected,
      onCellSelected: widget.onCellSelected,
      onCellTap: widget.onCellTap,
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
      columnWidths: widget.columnWidths,
      editingCell: widget.editingCell,
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
    this.selectedCells,
    this.anchorCell,
    this.isDragging = false,
    this.onCellsSelected,
    required this.onRowSelected,
    required this.onCellSelected,
    required this.enabled,
    this.onCellTap,
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
    this.columnWidths,
    this.editingCell,
  });

  final DesktopTokens t;
  final int row;
  final double rowHeight;
  final List<DataGridViewColumn> columns;
  final Widget Function(int row, int col) cellBuilder;
  final bool isSelected;
  final (int, int)? selectedCell;
  final Set<(int, int)>? selectedCells;
  final (int, int)? anchorCell;
  final bool isDragging;
  final ValueChanged<Set<(int, int)>>? onCellsSelected;
  final ValueChanged<int>? onRowSelected;
  final void Function(int row, int col)? onCellSelected;
  final void Function(int row, int col)? onCellTap;
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
  final List<double>? columnWidths;
  final (int, int)? editingCell;

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
    final multiSelect = w.onCellsSelected != null;
    // 多选模式:从 selectedCells 集合判断;否则回退单选 selectedCell
    final cellSelected = multiSelect
        ? (w.selectedCells?.contains((w.row, col)) ?? false)
        : (w.selectedCell != null &&
            w.selectedCell!.$1 == w.row &&
            w.selectedCell!.$2 == col);
    // 单元格选中时文字反白,否则跟随行文字色
    final fg = cellSelected
        ? w.selectedTextColor
        : (w.isSelected
            ? w.selectedTextColor
            : (w.enabled ? w.t.foregroundColor : w.t.disabledForegroundColor));

    Widget cell = Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: w.enabled
          ? (event) {
              // 拖拽进行中,跳过单元格选中逻辑(由 DataGridView 层统一处理)
              if (w.isDragging) return;
              if (event.buttons == kSecondaryMouseButton) {
                w.onCellContext?.call(w.row, col, event.position);
                return;
              }
              if (multiSelect) {
                final ctrl = HardwareKeyboard.instance.isControlPressed;
                final shift = HardwareKeyboard.instance.isShiftPressed;
                final current = w.selectedCells ?? <(int, int)>{};
                final cell = (w.row, col);
                Set<(int, int)> newSel;
                if (shift) {
                  // Shift+click: 从锚点到当前单元格矩形范围选择
                  final anchor = w.anchorCell ?? cell;
                  final minR = anchor.$1 < cell.$1 ? anchor.$1 : cell.$1;
                  final maxR = anchor.$1 > cell.$1 ? anchor.$1 : cell.$1;
                  final minC = anchor.$2 < cell.$2 ? anchor.$2 : cell.$2;
                  final maxC = anchor.$2 > cell.$2 ? anchor.$2 : cell.$2;
                  newSel = <(int, int)>{};
                  for (var r = minR; r <= maxR; r++) {
                    for (var c = minC; c <= maxC; c++) {
                      newSel.add((r, c));
                    }
                  }
                } else if (ctrl) {
                  // Ctrl+click: 切换单个单元格
                  newSel = Set<(int, int)>.from(current);
                  if (!newSel.remove(cell)) newSel.add(cell);
                } else {
                  // 普通点击: 仅选中该单元格
                  newSel = {cell};
                }
                w.onCellsSelected?.call(newSel);
              } else {
                w.onCellSelected?.call(w.row, col);
                if (w.onCellSelected == null) {
                  w.onRowSelected?.call(w.row);
                }
                w.onCellTap?.call(w.row, col);
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
          decoration: BoxDecoration(
            color: cellSelected ? w.t.primaryColor : null,
            border: Border(
              right: BorderSide(color: w.gridLineColor, width: w.t.borderWidth),
            ),
          ),
          child: (w.editingCell != null &&
                  w.editingCell!.$1 == w.row &&
                  w.editingCell!.$2 == col)
              ? DefaultTextStyle.merge(
                  style: TextStyle(color: fg),
                  child: w.cellBuilder(w.row, col),
                )
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: w.cellPaddingX),
                  child: DefaultTextStyle.merge(
                    style: TextStyle(color: fg),
                    child: w.cellBuilder(w.row, col),
                  ),
                ),
        ),
      ),
    );

    if (column.alignment != Alignment.centerLeft) {
      cell = Align(alignment: column.alignment, child: cell);
    }
    final widths = w.columnWidths;
    final cw = widths != null ? widths[col] : column.width;
    if (cw != null) {
      return SizedBox(width: cw, child: cell);
    }
    return Expanded(flex: column.flex, child: cell);
  }
}
