import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../common/icon_button.dart';
import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';
import '../menus/context_menu_strip.dart';
import '../menus/menu_strip.dart';

/// One page of a [TabControl].
class TabItem extends StatelessWidget {
  const TabItem({
    super.key,
    required this.label,
    this.icon,
    this.child,
    this.onClose,
    this.width,
    this.contextMenuItems,
  });

  /// Tab header text.
  final String label;

  /// Optional leading icon.
  final Widget? icon;

  /// Page content shown while this tab is selected.
  final Widget? child;

  /// When set, a close button appears on hover and invokes this callback.
  final VoidCallback? onClose;

  /// Fixed header width; when `null` falls back to [TabControl.tabWidth].
  final double? width;

  /// Right-click menu entries (shown via [ContextMenuStrip]).
  final List<MenuModel>? contextMenuItems;

  @override
  Widget build(BuildContext context) => child ?? const SizedBox.shrink();
}

/// A tabbed container (WinForm `TabControl`; the counterpart of the shadcn
/// "Tabs"). The header bar highlights the selected tab with the token accent
/// underline; hover and focus states are token-driven.
///
/// Supports fixed-width tabs, closable tabs, per-tab context menus, and
/// scroll arrows when the headers overflow the bar. No click animations.
class TabControl extends StatefulWidget {
  const TabControl({
    super.key,
    this.initialIndex = 0,
    this.onChanged,
    this.tokens,
    required this.tabs,
    this.tabBarColor,
    this.selectedTabColor,
    this.hoverTabColor,
    this.showUnderline = true,
    this.barHeight,
    this.tabWidth = 80,
    this.scrollStep = 120,
    this.contentPadding,
  });

  /// Index of the initially selected tab.
  final int initialIndex;

  /// Called with the selected index whenever it changes.
  final ValueChanged<int>? onChanged;

  /// Token override; falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  /// The tab pages.
  final List<TabItem> tabs;

  /// Background of the whole header bar; `null` = transparent.
  final Color? tabBarColor;

  /// Background of the selected tab; defaults to the token muted color.
  final Color? selectedTabColor;

  /// Background of a hovered (unselected) tab; defaults to the token muted
  /// color.
  final Color? hoverTabColor;

  /// Whether the selected tab shows the accent underline.
  final bool showUnderline;

  /// Fixed header bar height; `null` = content-sized (padding-based).
  final double? barHeight;

  /// Default header width for tabs whose [TabItem.width] is `null`.
  final double tabWidth;

  /// Pixel distance scrolled per arrow click.
  final double scrollStep;

  /// Padding around the tab body; `null` = a top spacing of
  /// [DesktopTokens.compactSpacing] * 2. Header-only usage (e.g. a tab bar
  /// embedded in a fixed-height strip) passes [EdgeInsets.zero].
  final EdgeInsets? contentPadding;

  @override
  State<TabControl> createState() => _TabControlState();
}

class _TabControlState extends State<TabControl> {
  late int _index;
  final FocusNode _barFocus = FocusNode(debugLabel: 'TabControl');
  final ScrollController _scroll = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.tabs.length - 1);
    _scroll.addListener(_updateArrowVisibility);
  }

  @override
  void didUpdateWidget(TabControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIndex != oldWidget.initialIndex) {
      _index = widget.initialIndex.clamp(0, widget.tabs.length - 1);
    }
  }

  @override
  void dispose() {
    _scroll.removeListener(_updateArrowVisibility);
    _scroll.dispose();
    _barFocus.dispose();
    super.dispose();
  }

  void _select(int index) {
    if (index == _index || index < 0 || index >= widget.tabs.length) return;
    setState(() => _index = index);
    widget.onChanged?.call(index);
  }

  void _updateArrowVisibility() {
    final canLeft = _scroll.hasClients && _scroll.offset > 0;
    final canRight = _scroll.hasClients &&
        _scroll.offset < _scroll.position.maxScrollExtent;
    if (canLeft != _canScrollLeft || canRight != _canScrollRight) {
      setState(() {
        _canScrollLeft = canLeft;
        _canScrollRight = canRight;
      });
    }
  }

  void _scrollBy(double delta) {
    if (!_scroll.hasClients) return;
    _scroll.animateTo(
      (_scroll.offset + delta)
          .clamp(0.0, _scroll.position.maxScrollExtent),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  KeyEventResult _handleBarKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
        event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _select((_index + 1) % widget.tabs.length);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
        event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _select((_index - 1 + widget.tabs.length) % widget.tabs.length);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.home) {
      _select(0);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.end) {
      _select(widget.tabs.length - 1);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens ??
        TokenScope.maybeOf(context) ??
        DesktopTokens.winForm;
    if (widget.tabs.isEmpty) return const SizedBox.shrink();
    final index = _index.clamp(0, widget.tabs.length - 1);
    const arrowWidth = 24.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: widget.tabBarColor ?? Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: t.borderColor,
                width: t.borderWidth,
              ),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = widget.tabs.fold<double>(
                0,
                (sum, tab) => sum + (tab.width ?? widget.tabWidth),
              );
              final needScroll = totalWidth > constraints.maxWidth - arrowWidth * 2;
              // 标签数量变化后刷新箭头可见性
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => _updateArrowVisibility());

              final bar = IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (needScroll && _canScrollLeft)
                      _ScrollArrow(
                        tokens: t,
                        icon: Icons.chevron_left,
                        barColor: widget.tabBarColor ?? t.surfaceColor,
                        onTap: () => _scrollBy(-widget.scrollStep),
                      ),
                    Expanded(
                      child: Focus(
                        focusNode: _barFocus,
                        onKeyEvent: _handleBarKey,
                        child: SingleChildScrollView(
                          controller: _scroll,
                          scrollDirection: Axis.horizontal,
                          physics: const NeverScrollableScrollPhysics(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (var i = 0; i < widget.tabs.length; i++)
                                SizedBox(
                                  width:
                                      widget.tabs[i].width ?? widget.tabWidth,
                                  child: _TabHeader(
                                    tab: widget.tabs[i],
                                    selected: i == index,
                                    tokens: t,
                                    onTap: () => _select(i),
                                    barHeight: widget.barHeight,
                                    selectedTabColor: widget.selectedTabColor,
                                    hoverTabColor: widget.hoverTabColor,
                                    showUnderline: widget.showUnderline,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (needScroll && _canScrollRight)
                      _ScrollArrow(
                        tokens: t,
                        icon: Icons.chevron_right,
                        barColor: widget.tabBarColor ?? t.surfaceColor,
                        onTap: () => _scrollBy(widget.scrollStep),
                      ),
                  ],
                ),
              );
              return bar;
            },
          ),
        ),
        Padding(
          padding:
              widget.contentPadding ??
              EdgeInsets.only(top: t.compactSpacing * 2),
          child: widget.tabs[index].child ?? const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _TabHeader extends StatefulWidget {
  const _TabHeader({
    required this.tab,
    required this.selected,
    required this.tokens,
    required this.onTap,
    this.barHeight,
    this.selectedTabColor,
    this.hoverTabColor,
    this.showUnderline = true,
  });

  final TabItem tab;
  final bool selected;
  final DesktopTokens tokens;
  final VoidCallback onTap;
  final double? barHeight;
  final Color? selectedTabColor;
  final Color? hoverTabColor;
  final bool showUnderline;

  @override
  State<_TabHeader> createState() => _TabHeaderState();
}

class _TabHeaderState extends State<_TabHeader> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens;
    final selected = widget.selected;
    // 选中态底与 hover 底均来自参数(默认 token muted 色)
    final bg = selected
        ? (widget.selectedTabColor ?? t.mutedColor)
        : (_hover ? (widget.hoverTabColor ?? t.mutedColor) : Colors.transparent);
    // 关闭按钮仅在悬浮且可关闭时显示,不占位
    final showClose = _hover && widget.tab.onClose != null;
    final fg = selected ? t.foregroundColor : t.mutedForegroundColor;

    final body = MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Container(
          height: widget.barHeight,
          alignment: widget.barHeight == null ? null : Alignment.center,
          padding: EdgeInsets.symmetric(
            horizontal: t.controlPaddingX,
            vertical: widget.barHeight == null ? t.compactSpacing * 1.5 : 0,
          ),
          decoration: BoxDecoration(
            color: bg,
            border: Border(
              right: BorderSide(
                color: t.borderColor,
                width: t.borderWidth * 0.5,
              ),
            ),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(t.cornerRadius),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.tab.icon != null) ...[
                widget.tab.icon!,
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  widget.tab.label,
                  style: TextStyle(
                    fontFamily: t.fontFamily,
                    fontSize: t.fontSize * 0.875,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: fg,
                    height: 1.2,
                    decoration: TextDecoration.none,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              if (showClose) ...[
                const SizedBox(width: 4),
                IconBtn(
                  icon: Icons.close,
                  iconSize: 11,
                  size: const Size(16, 16),
                  color: t.mutedForegroundColor,
                  tokens: t,
                  onTap: widget.tab.onClose,
                ),
              ],
            ],
          ),
        ),
      ),
    );

    // 选中下划线(无动画)
    final underline = widget.showUnderline
        ? Container(
            height: 2,
            margin: EdgeInsets.only(top: t.compactSpacing),
            color: selected ? t.primaryColor : Colors.transparent,
          )
        : null;

    Widget header = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        body,
        if (underline != null) underline,
      ],
    );

    // 右键菜单:ContextMenuStrip 检测子区域内的右键点击
    if (widget.tab.contextMenuItems != null) {
      header = ContextMenuStrip(
        items: widget.tab.contextMenuItems!,
        tokens: t,
        child: header,
      );
    }
    return header;
  }
}

class _ScrollArrow extends StatefulWidget {
  const _ScrollArrow({
    required this.tokens,
    required this.icon,
    required this.barColor,
    required this.onTap,
  });

  final DesktopTokens tokens;
  final IconData icon;
  final Color barColor;
  final VoidCallback onTap;

  @override
  State<_ScrollArrow> createState() => _ScrollArrowState();
}

class _ScrollArrowState extends State<_ScrollArrow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Container(
          width: 24,
          color: _hover
              ? Color.alphaBlend(t.hoverOverlayColor, widget.barColor)
              : widget.barColor,
          child: Icon(
            widget.icon,
            size: 16,
            color: _hover ? t.foregroundColor : t.mutedForegroundColor,
          ),
        ),
      ),
    );
  }
}
