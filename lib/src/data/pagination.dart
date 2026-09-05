import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';
import '../common/surface.dart';
import '../common/input.dart';

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

/// 输入跳页型分页器:首页 / 上一页 / 页码输入框 / 下一页 / 尾页。
///
/// 与 [Pagination] 的页码按钮阵列不同,本控件只提供一个输入框,
/// 输入页码按回车(或点击前后箭头)跳转,适用于表数据浏览等
/// "分页针对全表"的场景。
///
/// [pageCount] 可为 null(总页数未知,如表数据页尚未统计行数):
/// 此时「共 N 页」显示为「共 ? 页」,下一页始终可点(由调用方处理空页),
/// 尾页按钮改触发 [onGoLast](由调用方执行 COUNT 等统计后跳转)。
class PageNavigator extends StatefulWidget {
  const PageNavigator({
    super.key,
    required this.currentPage,
    required this.onPageChanged,
    this.pageCount,
    this.onGoLast,
    this.showTotal = true,
    this.showFirstLast = true,
    this.tokens,
  });

  /// Total number of pages; `null` means unknown (lazy-count mode).
  final int? pageCount;

  /// Currently selected page (0-based).
  final int currentPage;

  /// Called with the new page (0-based) when the user navigates.
  final ValueChanged<int> onPageChanged;

  /// Called when the "go to last page" button is pressed while
  /// [pageCount] is `null`; the caller computes the last page (e.g. via
  /// COUNT) and then navigates. Ignored when [pageCount] is known.
  final VoidCallback? onGoLast;

  /// Whether to render a trailing "共 N 页" label.
  final bool showTotal;

  /// Whether to show first / last shortcuts.
  final bool showFirstLast;

  /// Token override; falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  @override
  State<PageNavigator> createState() => _PageNavigatorState();
}

class _PageNavigatorState extends State<PageNavigator> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.currentPage + 1}');
  }

  @override
  void didUpdateWidget(PageNavigator oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 页码被外部(箭头 / 加载 / 刷新)改变时同步输入框,覆盖用户未提交的输入
    if (widget.currentPage != oldWidget.currentPage) {
      _controller.text = '${widget.currentPage + 1}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 提交输入框内容:解析页码并跳转;非法输入回弹为当前页
  void _submit(String text) {
    final parsed = int.tryParse(text.trim());
    var target = parsed == null ? widget.currentPage : parsed - 1;
    if (target < 0) target = 0;
    final pageCount = widget.pageCount;
    // 总页数已知时按页数钳制;未知时交由调用方处理越界页
    if (pageCount != null && target >= pageCount) target = pageCount - 1;
    _controller.text = '${target + 1}';
    if (target != widget.currentPage) {
      widget.onPageChanged(target);
    }
  }

  /// 过滤非数字字符(输入过程中)
  void _onChanged(String text) {
    final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits != text) {
      _controller.text = digits;
      _controller.selection = TextSelection.collapsed(offset: digits.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    final pageCount = widget.pageCount;
    final current = widget.currentPage;
    final side = t.controlHeight;

    Widget arrowButton(
      IconData icon,
      bool enabled,
      VoidCallback onTap,
      String label,
    ) {
      return Surface(
        tokens: t,
        onTap: enabled ? onTap : null,
        color: t.popoverColor,
        borderColor: t.borderColor,
        semanticLabel: label,
        constraints: BoxConstraints(minWidth: side, minHeight: side),
        child: Icon(icon, size: t.fontSize * 1.1, color: t.foregroundColor),
      );
    }

    // 总页数未知时下一页/尾页无法预判越界,保持可点,由调用方处理空页
    final hasNext = pageCount == null || current < pageCount - 1;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showFirstLast) ...[
          arrowButton(
            Icons.first_page,
            current > 0,
            () => widget.onPageChanged(0),
            'First page',
          ),
          SizedBox(width: t.compactSpacing),
        ],
        arrowButton(
          Icons.chevron_left,
          current > 0,
          () => widget.onPageChanged(current - 1),
          'Previous page',
        ),
        SizedBox(width: t.compactSpacing),
        // 页码输入框:窄宽、居中、纯数字,Enter 跳页。
        // 垂直 padding 沿用 Input 默认的居中算法((高-字号)/2):
        // isDense 下 textAlignVertical 失效,全靠该 padding 垫出居中
        SizedBox(
          width: side * 1.7,
          height: side,
          child: Input(
            controller: _controller,
            tokens: t,
            onChanged: _onChanged,
            onSubmitted: _submit,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 4,
              vertical: (t.controlHeight - t.fontSize) / 2 < 0
                  ? 0
                  : (t.controlHeight - t.fontSize) / 2,
            ),
          ),
        ),
        SizedBox(width: t.compactSpacing),
        arrowButton(
          Icons.chevron_right,
          hasNext,
          () => widget.onPageChanged(current + 1),
          'Next page',
        ),
        if (widget.showFirstLast) ...[
          SizedBox(width: t.compactSpacing),
          arrowButton(
            Icons.last_page,
            hasNext,
            pageCount != null
                ? () => widget.onPageChanged(pageCount - 1)
                : () => widget.onGoLast?.call(),
            'Last page',
          ),
        ],
        if (widget.showTotal) ...[
          SizedBox(width: t.compactSpacing),
          Text(
            '共 ${pageCount ?? '?'} 页',
            style: TextStyle(
              fontFamily: t.fontFamily,
              fontSize: t.fontSize,
              color: t.mutedForegroundColor,
              decoration: TextDecoration.none,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }
}
