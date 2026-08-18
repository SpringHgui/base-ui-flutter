import 'dart:collection';

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

  /// Called when the user selects a row.
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
                itemBuilder: (context, row) => _buildRow(t, row, rh),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -- Header ---------------------------------------------------------------

  Widget _buildHeader(DesktopTokens t) {
    return Container(
      height: widget.rowHeight ?? t.controlHeight,
      decoration: BoxDecoration(
        color: t.controlColor,
        border: Border(
          bottom: BorderSide(color: t.borderColor, width: t.borderWidth),
        ),
      ),
      child: Row(
        children: widget.columns.map((col) {
          return _buildCell(
            width: col.width,
            flex: col.flex,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: t.controlPaddingX),
            child: Text(
              col.title,
              style: TextStyle(
                fontFamily: t.fontFamily,
                fontSize: t.fontSize,
                color: t.foregroundColor,
                fontWeight: FontWeight.w600,
                height: 1.0,
              ),
            ),
            border: true,
            borderColor: t.borderColor,
            borderWidth: t.borderWidth,
          );
        }).toList(),
      ),
    );
  }

  // -- Data row -------------------------------------------------------------

  Widget _buildRow(DesktopTokens t, int row, double rh) {
    final isSelected = widget.selectedRow == row;
    final bgColor = isSelected ? t.primaryColor : Colors.transparent;
    final fgColor = isSelected
        ? t.surfaceColor
        : (widget.enabled ? t.foregroundColor : t.disabledForegroundColor);

    return GestureDetector(
      onTap: widget.enabled ? () => widget.onRowSelected?.call(row) : null,
      child: Container(
        height: rh,
        color: bgColor,
        child: Row(
          children: List.generate(widget.columns.length, (col) {
            final column = widget.columns[col];
            return _buildCell(
              width: column.width,
              flex: column.flex,
              alignment: column.alignment,
              padding: EdgeInsets.symmetric(horizontal: t.controlPaddingX),
              child: widget.cellBuilder(row, col),
              border: col < widget.columns.length - 1,
              borderColor: t.borderColor,
              borderWidth: t.borderWidth,
              defaultColor: fgColor,
            );
          }),
        ),
      ),
    );
  }

  // -- Cell wrapper ---------------------------------------------------------

  Widget _buildCell({
    required double? width,
    required int flex,
    required Alignment alignment,
    required EdgeInsets padding,
    required Widget child,
    bool border = false,
    Color? borderColor,
    double? borderWidth,
    Color? defaultColor,
  }) {
    Widget content = Padding(
      padding: padding,
      child: DefaultTextStyle.merge(
        style: defaultColor != null
            ? TextStyle(color: defaultColor)
            : const TextStyle(),
        child: child,
      ),
    );

    if (alignment != Alignment.centerLeft) {
      content = Align(alignment: alignment, child: content);
    }

    if (border && borderColor != null && borderWidth != null) {
      content = Container(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: borderColor, width: borderWidth),
          ),
        ),
        child: content,
      );
    }

    if (width != null) {
      return SizedBox(width: width, child: content);
    }
    return Expanded(flex: flex, child: content);
  }
}
