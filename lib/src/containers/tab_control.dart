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
/// "Tabs") with classic WinForms chrome.
///
/// The header strip paints in the token control colour with the tabs sitting
/// on a hairline; the selected tab is painted in the surface colour, sticks up
/// a couple of pixels above its siblings and reaches one hairline lower, so it
/// covers the strip's bottom line and merges seamlessly with the framed page
/// below — the page panel omits its top border for exactly this reason.
/// Unselected tabs blend into the strip and highlight with a hover overlay
/// derived from the strip colour (light/dark aware). Hover and focus states
/// are token-driven; there are no click animations.
///
/// Supports fixed-width tabs, closable tabs, per-tab context menus, and
/// scroll arrows when the headers overflow the bar. A header-only usage
/// (every [TabItem.child] `null`, e.g. a tab strip embedded above an external
/// content area) renders without the page panel.
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

  /// Background of the header strip; `null` = the token control colour.
  final Color? tabBarColor;

  /// Background of the selected tab and the page panel (they read as one
  /// surface); `null` = the token surface colour.
  final Color? selectedTabColor;

  /// Background of a hovered (unselected) tab; `null` = the token hover
  /// overlay blended over the strip colour.
  final Color? hoverTabColor;

  /// Height of an unselected header; the selected header is slightly taller
  /// (classic WinForms). `null` = the token control height.
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
  final GlobalKey _tabBarKey = GlobalKey();
  bool _needScroll = false;
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  /// Selected tab sticks up above its unselected siblings (WinForms).
  static const double _raise = 2.0;

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

  /// Post-frame measurement of tab bar container width.
  /// Avoids [LayoutBuilder] which conflicts with [IntrinsicHeight]
  /// (e.g. when embedded inside a [DialogBox]).
  void _measureTabBarWidth() {
    if (!mounted) return;
    final box = _tabBarKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;
    final containerWidth = box.size.width;
    final totalWidth = widget.tabs.fold<double>(
      0,
      (sum, tab) => sum + (tab.width ?? widget.tabWidth),
    );
    final needScroll = totalWidth > containerWidth - 24.0 * 2;
    if (needScroll != _needScroll) {
      setState(() => _needScroll = needScroll);
    }
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

    // WinForms chrome metrics. The strip's bottom hairline doubles as the
    // page panel's top border: the selected tab (surface-filled, one hairline
    // taller at the bottom) paints over it and merges with the page, so the
    // panel itself omits its top border.
    final hasBody = widget.tabs.any((tab) => tab.child != null);
    final lineH = hasBody ? t.borderWidth : 0.0;
    final headerH = widget.barHeight ?? t.controlHeight;
    final stripH = headerH + lineH + (hasBody ? _raise : 0.0);
    final stripBg = widget.tabBarColor ?? t.controlColor;

    Widget tabHeader(int i) {
      final selected = i == index;
      return SizedBox(
        width: widget.tabs[i].width ?? widget.tabWidth,
        child: selected
            ? _TabHeader(
                tab: widget.tabs[i],
                selected: true,
                tokens: t,
                onTap: () => _select(i),
                height: stripH,
                stripColor: stripBg,
                selectedTabColor: widget.selectedTabColor,
                hoverTabColor: widget.hoverTabColor,
              )
            // Unselected tabs stop one hairline above the strip's bottom
            // line, so the line stays visible beneath them.
            : Padding(
                padding: EdgeInsets.only(bottom: lineH),
                child: _TabHeader(
                  tab: widget.tabs[i],
                  selected: false,
                  tokens: t,
                  onTap: () => _select(i),
                  height: headerH,
                  stripColor: stripBg,
                  selectedTabColor: widget.selectedTabColor,
                  hoverTabColor: widget.hoverTabColor,
                ),
              ),
      );
    }

    final tabsRow = Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_needScroll && _canScrollLeft)
          _ScrollArrow(
            tokens: t,
            icon: Icons.chevron_left,
            barColor: stripBg,
            height: stripH,
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
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < widget.tabs.length; i++) tabHeader(i),
                ],
              ),
            ),
          ),
        ),
        if (_needScroll && _canScrollRight)
          _ScrollArrow(
            tokens: t,
            icon: Icons.chevron_right,
            barColor: stripBg,
            height: stripH,
            onTap: () => _scrollBy(widget.scrollStep),
          ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            // Strip background. Positioned so the tabs row (non-positioned)
            // sizes the stack and paints on top of the hairline.
            Positioned.fill(
              child: ColoredBox(key: _tabBarKey, color: stripBg),
            ),
            // Strip bottom hairline = the page panel's top border. Painted
            // under the tabs: the taller, surface-filled selected tab covers
            // its own segment and merges with the page below.
            if (hasBody)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(height: lineH, color: t.borderColor),
              ),
            tabsRow,
            // Post-frame measurement: determines whether scroll arrows
            // are needed without LayoutBuilder (which conflicts with
            // IntrinsicHeight, e.g. inside DialogBox).
            Builder(builder: (_) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _measureTabBarWidth();
              });
              return const SizedBox.shrink();
            }),
          ],
        ),
        if (hasBody)
          DecoratedBox(
            decoration: BoxDecoration(
              // Page colour matches the selected tab so they read as one
              // surface; the top border is owned by the strip hairline.
              color: widget.selectedTabColor ?? t.surfaceColor,
              border: Border(
                left: BorderSide(color: t.borderColor, width: t.borderWidth),
                right: BorderSide(color: t.borderColor, width: t.borderWidth),
                bottom: BorderSide(color: t.borderColor, width: t.borderWidth),
              ),
            ),
            child: Padding(
              padding: widget.contentPadding ??
                  EdgeInsets.only(top: t.compactSpacing * 2),
              child: widget.tabs[index].child ?? const SizedBox.shrink(),
            ),
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
    required this.height,
    required this.stripColor,
    this.selectedTabColor,
    this.hoverTabColor,
  });

  final TabItem tab;
  final bool selected;
  final DesktopTokens tokens;
  final VoidCallback onTap;

  /// This tab's own height: the selected tab sticks up and reaches over the
  /// strip hairline, so it is taller than its unselected siblings.
  final double height;

  /// Strip background; the hover colour derives from it (light/dark aware).
  final Color stripColor;

  /// Background of the selected tab; `null` = the token surface colour.
  final Color? selectedTabColor;

  /// Background of a hovered (unselected) tab; `null` = the token hover
  /// overlay blended over the strip colour.
  final Color? hoverTabColor;

  @override
  State<_TabHeader> createState() => _TabHeaderState();
}

class _TabHeaderState extends State<_TabHeader> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens;
    final selected = widget.selected;
    // WinForm colours: selected = surface (merges with the page panel),
    // unselected blends into the strip, hover derives from the strip colour.
    final selectedBg = widget.selectedTabColor ?? t.surfaceColor;
    final hoverBg = widget.hoverTabColor ??
        Color.alphaBlend(t.hoverOverlayColor, widget.stripColor);
    final bg = selected ? selectedBg : (_hover ? hoverBg : null);

    // Close button only while hovering a closable tab; takes no space.
    final showClose = _hover && widget.tab.onClose != null;
    final fg = selected ? t.foregroundColor : t.mutedForegroundColor;

    final body = MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: _TabChrome(
          color: bg,
          borderColor: t.borderColor,
          borderWidth: t.borderWidth,
          selected: selected,
          child: SizedBox(
            height: widget.height,
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: t.controlPaddingX),
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
                          // WinForms tabs keep the regular weight; state is
                          // carried by colour alone.
                          fontWeight: FontWeight.w400,
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
          ),
        ),
      ),
    );

    // Right-click menu: ContextMenuStrip detects right clicks inside the
    // region.
    if (widget.tab.contextMenuItems != null) {
      return ContextMenuStrip(
        items: widget.tab.contextMenuItems!,
        tokens: t,
        child: body,
      );
    }
    return body;
  }
}

/// Self-drawn WinForms tab chrome: a folder shape (rounded top corners, open
/// bottom) filled with [color] and, when selected, stroked with a hairline on
/// the top / left / right edges. `Border` + `BorderRadius` cannot express a
/// three-sided border with rounded corners (Flutter requires uniform
/// borders), hence the painter.
class _TabChrome extends StatelessWidget {
  const _TabChrome({
    required this.color,
    required this.borderColor,
    required this.borderWidth,
    required this.selected,
    required this.child,
  });

  final Color? color;
  final Color borderColor;
  final double borderWidth;
  final bool selected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TabChromePainter(
        color: color,
        borderColor: borderColor,
        borderWidth: borderWidth,
        selected: selected,
      ),
      child: child,
    );
  }
}

class _TabChromePainter extends CustomPainter {
  _TabChromePainter({
    required this.color,
    required this.borderColor,
    required this.borderWidth,
    required this.selected,
  });

  final Color? color;
  final Color borderColor;
  final double borderWidth;
  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    // Classic WinForms tab: slightly rounded top corners, square bottom.
    const r = 3.0;
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, r)
      ..quadraticBezierTo(0, 0, r, 0)
      ..lineTo(size.width - r, 0)
      ..quadraticBezierTo(size.width, 0, size.width, r)
      ..lineTo(size.width, size.height);
    if (color != null) {
      // Filling an open path closes it implicitly across the bottom edge.
      canvas.drawPath(path, Paint()..color = color!);
    }
    if (selected) {
      // The stroke stays open: top / left / right only, so the tab merges
      // with the page panel below instead of being boxed in.
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth
          ..color = borderColor,
      );
    }
  }

  @override
  bool shouldRepaint(_TabChromePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.borderColor != borderColor ||
      oldDelegate.borderWidth != borderWidth ||
      oldDelegate.selected != selected;
}

class _ScrollArrow extends StatefulWidget {
  const _ScrollArrow({
    required this.tokens,
    required this.icon,
    required this.barColor,
    required this.height,
    required this.onTap,
  });

  final DesktopTokens tokens;
  final IconData icon;
  final Color barColor;

  /// Full strip height (selected-tab height) so the arrow fills the bar.
  final double height;

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
          height: widget.height,
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
