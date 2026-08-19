import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';
import '../common/surface.dart';

/// A page-number pager — the counterpart of the shadcn "Pagination".
///
/// Renders previous / next arrows, page-number buttons and (optionally)
/// first / last shortcuts, with ellipsis for large page counts.
class Pagination extends StatelessWidget {
  const Pagination({
    super.key,
    required this.pageCount,
    required this.currentPage,
    required this.onPageChanged,
    this.siblingCount = 1,
    this.showFirstLast = true,
    this.tokens,
  });

  /// Total number of pages.
  final int pageCount;

  /// Currently selected page (0-based).
  final int currentPage;

  /// Called with the new page (0-based) when the user navigates.
  final ValueChanged<int> onPageChanged;

  /// How many page numbers to show around the current page.
  final int siblingCount;

  /// Whether to show first / last shortcuts.
  final bool showFirstLast;

  /// Token override; falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  /// The visible page numbers, with `null` marking ellipsis gaps.
  List<int?> _pages() {
    final pages = <int?>[];
    if (pageCount <= 7) {
      return [for (var i = 0; i < pageCount; i++) i];
    }
    pages.add(0);
    final start = (currentPage - siblingCount).clamp(1, pageCount - 2);
    final end = (currentPage + siblingCount).clamp(1, pageCount - 2);
    if (start > 1) pages.add(null);
    for (var i = start; i <= end; i++) {
      pages.add(i);
    }
    if (end < pageCount - 2) pages.add(null);
    pages.add(pageCount - 1);
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    // 按钮边长与控件标准高度一致,便于嵌入 ToolStrip 等紧凑容器
    final side = t.controlHeight;

    Widget arrowButton(IconData icon, int? target, {String? label}) {
      final enabled = target != null && target >= 0 && target < pageCount;
      return Surface(
        tokens: t,
        onTap: enabled ? () => onPageChanged(target) : null,
        color: t.popoverColor,
        borderColor: t.borderColor,
        semanticLabel: label,
        constraints: BoxConstraints(minWidth: side, minHeight: side),
        child: Icon(icon, size: t.fontSize * 1.1, color: t.foregroundColor),
      );
    }

    Widget pageButton(int page, {bool ellipsis = false}) {
      final selected = page == currentPage;
      return Surface(
        tokens: t,
        onTap: ellipsis ? null : () => onPageChanged(page),
        color: selected ? t.primaryColor : Colors.transparent,
        hoverColor: selected ? null : t.mutedColor,
        borderColor: selected ? null : t.borderColor,
        semanticLabel: ellipsis ? null : 'Page ${page + 1}',
        constraints: BoxConstraints(minWidth: side, minHeight: side),
        child: ellipsis
            ? Text(
                '…',
                style: TextStyle(
                  fontFamily: t.fontFamily,
                  fontSize: t.fontSize,
                  color: t.mutedForegroundColor,
                ),
              )
            : Text(
                '${page + 1}',
                style: TextStyle(
                  fontFamily: t.fontFamily,
                  fontSize: t.fontSize * 0.875,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? t.surfaceColor : t.foregroundColor,
                  height: 1.2,
                ),
              ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showFirstLast) ...[
          arrowButton(Icons.first_page, currentPage > 0 ? 0 : null,
              label: 'First page'),
          SizedBox(width: t.compactSpacing),
        ],
        arrowButton(
          Icons.chevron_left,
          currentPage > 0 ? currentPage - 1 : null,
          label: 'Previous page',
        ),
        SizedBox(width: t.compactSpacing),
        for (final page in _pages()) ...[
          if (page == null)
            pageButton(0, ellipsis: true)
          else
            pageButton(page),
          SizedBox(width: t.compactSpacing),
        ],
        arrowButton(
          Icons.chevron_right,
          currentPage < pageCount - 1 ? currentPage + 1 : null,
          label: 'Next page',
        ),
        if (showFirstLast) ...[
          SizedBox(width: t.compactSpacing),
          arrowButton(
            Icons.last_page,
            currentPage < pageCount - 1 ? pageCount - 1 : null,
            label: 'Last page',
          ),
        ],
      ],
    );
  }
}
