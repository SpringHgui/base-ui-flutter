import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../common/icon_button.dart';
import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';
import '../menus/context_menu_strip.dart';
import '../menus/menu_strip.dart';

/// 标签文本字号:比正文小一号。
double _labelFontSize(DesktopTokens t) => t.fontSize * 0.875;

/// 标签文本的单行行高(与 [_tabLabelStyle] 的 `height` 保持一致)。
double _labelLineHeight(DesktopTokens t) => _labelFontSize(t) * 1.2;

/// 标签内垂直内边距。
///
/// 实测 Navicat 的标签高度几乎贴着文字(12px 字 → 高 20.5px),
/// 上下留白只有 2.5px 左右;取 `compactSpacing` 的 3/4 复现这种紧凑度。
double _tabPaddingY(DesktopTokens t) => t.compactSpacing * 0.75;

/// 自动宽度模式下,图标与标签之间的间距。
const double _iconGap = 6;

/// 自动宽度模式下,可关闭标签为关闭按钮预留的宽度。
///
/// 关闭按钮只在悬停时出现;不预留的话,鼠标一进入标签,文案就会被挤成
/// 省略号(标签宽度是按文本算死的)。16px 按钮 + 4px 间距 = 20。
const double _closeReserve = 20;

/// 选中标签比未选中的兄弟高出多少(经典 WinForms / Navicat 的"拔起"效果)。
const double _raise = 2.0;

/// 未选中标签底色相对标签条底色的提亮量。
///
/// Navicat 的未选中标签 (#F3F3F3) 比条底 (#F0F0F0) 略浅一档;这里统一
/// 表达为"向页面底色靠拢一点":亮色主题下变浅、暗色主题下变深,都读作
/// 一个凹槽而不是一条额外的色带。
const double _unselectedLift = 0.22;

/// 标签文本样式。测量宽度与渲染必须同源,因此抽成函数。
///
/// 注意:这里**只**给标签自己的取值。真正渲染的 [Text] 会把
/// `DefaultTextStyle`(Material 主题里带 letterSpacing / wordSpacing)合并
/// 进来,所以自动宽度必须用 [_resolvedLabelStyle] 取合并后的样式测量,
/// 否则量出来的宽度比实际窄,长标题会被压成省略号。
TextStyle _tabLabelStyle(DesktopTokens t, Color fg) => TextStyle(
      fontFamily: t.fontFamily,
      fontSize: _labelFontSize(t),
      fontWeight: FontWeight.w400,
      color: fg,
      height: 1.2,
      decoration: TextDecoration.none,
    );

/// 标签文本的最终样式 = 环境 [DefaultTextStyle] 合并 [_tabLabelStyle]。
TextStyle _resolvedLabelStyle(
  BuildContext context,
  DesktopTokens t,
  Color fg,
) =>
    DefaultTextStyle.of(context).style.merge(_tabLabelStyle(t, fg));

/// One page of a [TabControl].
class TabItem extends StatelessWidget {
  const TabItem({
    super.key,
    required this.label,
    this.icon,
    this.iconWidth = 16,
    this.child,
    this.onClose,
    this.width,
    this.contextMenuItems,
  });

  /// Tab header text.
  final String label;

  /// Optional leading icon.
  final Widget? icon;

  /// 自动宽度模式下为 [icon] 预留的宽度,需与实际图标尺寸一致(默认 16)。
  final double iconWidth;

  /// Page content shown while this tab is selected.
  final Widget? child;

  /// When set, a close button appears on hover — pinned to the tab's right
  /// edge — and invokes this callback.
  final VoidCallback? onClose;

  /// Fixed header width; `null` = 交给 [TabControl.tabWidth],再退到按文本自适应。
  final double? width;

  /// Right-click menu entries (shown via [ContextMenuStrip]).
  final List<MenuModel>? contextMenuItems;

  @override
  Widget build(BuildContext context) => child ?? const SizedBox.shrink();
}

/// A tabbed container (WinForm `TabControl`; the counterpart of the shadcn
/// "Tabs") with classic desktop chrome, tuned to match Navicat 1:1.
///
/// ## Chrome
///
/// The header strip paints in the token control colour. **Every** tab is a
/// flat, square-cornered box: hairline on the top edge, a 1px vertical
/// divider on its right edge (so two adjacent tabs are separated by exactly
/// one hairline, not two), plus a left hairline on the first tab — but only
/// when the strip is framed together with a page body (see [_TabHeader.drawLeftEdge]).
/// The selected tab is filled with the surface colour, sticks up [_raise]
/// pixels above its siblings and reaches one hairline lower, so it covers the
/// strip's bottom line and merges seamlessly with the framed page below — the
/// page panel omits its top border for exactly this reason. Unselected tabs
/// are lifted [_unselectedLift] toward the surface colour and highlight with a
/// hover overlay derived from the strip colour (light/dark aware).
///
/// ## Sizing
///
/// Headers **auto-fit their label** by default: height comes from the label
/// line box + [_tabPaddingY] * 2 + the border, width from the measured label
/// (+ [TabItem.iconWidth]) + [tabPaddingX] * 2, with [minTabWidth] as a floor.
/// That is the Navicat look — a 2-character tab is ~44px wide, not 80 — and it
/// is why no caller needs to hard-code pixel widths. Pass [tabWidth] (or
/// [TabItem.width]) to opt back into fixed-width tabs (e.g. a stretched
/// document strip), and [barHeight] to override the height.
///
/// Supports fixed-width tabs, closable tabs, per-tab context menus, and
/// scroll arrows when the headers overflow the bar. A header-only usage
/// (every [TabItem.child] `null`, e.g. a tab strip embedded above an external
/// content area) renders without the page panel — and therefore without the
/// first tab's left hairline, since there is no framed box to close.
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
    this.tabWidth,
    this.minTabWidth,
    this.tabPaddingX,
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
  /// (classic WinForms). `null` = derived from the label metrics, i.e.
  /// `labelLineHeight + tabPaddingY * 2 + borderWidth`.
  final double? barHeight;

  /// Default header width for tabs whose [TabItem.width] is `null`.
  /// `null` (the default) = auto-fit the label, Navicat style.
  final double? tabWidth;

  /// Floor for auto-fitted header width; `null` = `compactSpacing * 11` (~44).
  final double? minTabWidth;

  /// Horizontal padding inside a header; `null` = `compactSpacing * 2` (~8).
  final double? tabPaddingX;

  /// Pixel distance scrolled per arrow click.
  final double scrollStep;

  /// Padding around the tab body; `null` = a top spacing of
  /// [DesktopTokens.compactSpacing] * 2. Header-only usage (e.g. a tab bar
  /// embedded in a fixed-height strip) passes [EdgeInsets.zero].
  final EdgeInsets? contentPadding;

  /// 标签条本身的可见高度(未选中标签头 + 页面顶线 + 选中标签上浮量)。
  ///
  /// 与内部布局同源:宿主需要为标签页正文留出固定高度时(例如 [DialogBox]
  /// 里 `height: _kBodyHeight` + `contentPadding: zero` 的用法)调它来算,
  /// 不要再硬编码 31 / 32 这类数字 —— 标签条高度已经改成跟随字号自动推导。
  ///
  /// [hasBody] 为 `false`(纯标签条,所有 [TabItem.child] 都是 `null`)时
  /// 不含页面顶线。
  static double stripHeight(
    DesktopTokens tokens, {
    double? barHeight,
    bool hasBody = true,
  }) {
    final h = barHeight ??
        (_labelLineHeight(tokens) +
            _tabPaddingY(tokens) * 2 +
            tokens.borderWidth);
    return hasBody ? h + tokens.borderWidth + _raise : h;
  }

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

  /// 本帧所有标签头的总宽度,在 [build] 里算好后供滚动箭头判定使用。
  double _tabsWidth = 0;

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

  // ── 几何(Navicat 度量)────────────────────────────────────────────────

  double _headerHeight(DesktopTokens t) =>
      widget.barHeight ??
      (_labelLineHeight(t) + _tabPaddingY(t) * 2 + t.borderWidth);

  double _padX(DesktopTokens t) =>
      widget.tabPaddingX ?? t.compactSpacing * 2;

  double _minWidth(DesktopTokens t) =>
      widget.minTabWidth ?? t.compactSpacing * 11;

  /// 单个标签头的宽度:显式 [TabItem.width] > [TabControl.tabWidth] > 按文本自适应。
  double _headerWidth(BuildContext context, DesktopTokens t, TabItem tab) {
    final fixed = tab.width ?? widget.tabWidth;
    if (fixed != null) return fixed;

    final painter = TextPainter(
      text: TextSpan(
        text: tab.label,
        style: _resolvedLabelStyle(context, t, t.foregroundColor),
      ),
      maxLines: 1,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.maybeTextScalerOf(context) ?? TextScaler.noScaling,
    )..layout();
    var content = painter.width;
    if (tab.icon != null) content += tab.iconWidth + _iconGap;
    if (tab.onClose != null) content += _closeReserve;
    return math.max(_minWidth(t), content + _padX(t) * 2);
  }

  /// Post-frame measurement of tab bar container width.
  /// Avoids [LayoutBuilder] which conflicts with [IntrinsicHeight]
  /// (e.g. when embedded inside a [DialogBox]).
  void _measureTabBarWidth() {
    if (!mounted) return;
    final box = _tabBarKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;
    final containerWidth = box.size.width;
    final needScroll = _tabsWidth > containerWidth - 24.0 * 2;
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

    // Navicat chrome metrics. The strip's bottom hairline doubles as the
    // page panel's top border: the selected tab (surface-filled, one hairline
    // taller at the bottom) paints over it and merges with the page, so the
    // panel itself omits its top border.
    final hasBody = widget.tabs.any((tab) => tab.child != null);
    final lineH = hasBody ? t.borderWidth : 0.0;
    final headerH = _headerHeight(t);
    final stripH = headerH + lineH + (hasBody ? _raise : 0.0);
    final stripBg = widget.tabBarColor ?? t.controlColor;

    final widths = <double>[
      for (final tab in widget.tabs) _headerWidth(context, t, tab),
    ];
    _tabsWidth = widths.fold(0.0, (sum, w) => sum + w);

    Widget tabHeader(int i) {
      final selected = i == index;
      return SizedBox(
        width: widths[i],
        child: selected
            ? _TabHeader(
                tab: widget.tabs[i],
                selected: true,
                drawLeftEdge: hasBody && i == 0,
                tokens: t,
                onTap: () => _select(i),
                height: stripH,
                padX: _padX(t),
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
                  drawLeftEdge: hasBody && i == 0,
                  tokens: t,
                  onTap: () => _select(i),
                  height: headerH,
                  padX: _padX(t),
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
          // Flexible(loose) rather than a plain child: since Flutter 3.47 a
          // vertical Column lays out its non-flex children with an *unbounded*
          // main axis, so any page body that needs an explicit height (code
          // editor, viewport) asserts during layout and the frame dies. As a
          // loose flex child the panel fills the remaining height when the
          // TabControl is itself height-bounded (WinForms display rectangle),
          // and still shrink-wraps its content in unbounded contexts such as
          // [DialogBox]'s IntrinsicHeight.
          Flexible(
            child: DecoratedBox(
              decoration: BoxDecoration(
                // Page colour matches the selected tab so they read as one
                // surface; the top border is owned by the strip hairline.
                color: widget.selectedTabColor ?? t.surfaceColor,
                border: Border(
                  left: BorderSide(color: t.borderColor, width: t.borderWidth),
                  right: BorderSide(color: t.borderColor, width: t.borderWidth),
                  bottom: BorderSide(
                      color: t.borderColor, width: t.borderWidth),
                ),
              ),
              child: Padding(
                padding: widget.contentPadding ??
                    EdgeInsets.only(top: t.compactSpacing * 2),
                child: widget.tabs[index].child ?? const SizedBox.shrink(),
              ),
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
    required this.drawLeftEdge,
    required this.tokens,
    required this.onTap,
    required this.height,
    required this.padX,
    required this.stripColor,
    this.selectedTabColor,
    this.hoverTabColor,
  });

  final TabItem tab;
  final bool selected;

  /// 是否在左边缘画竖线(只有第一个标签会开)。
  ///
  /// 只在「标签条与正文构成一个闭合框」时开:那种场景下正文面板自带左边框,
  /// 首个标签的左边线正好与它对齐、把框封住。纯标签条(每个 [TabItem.child]
  /// 都为 null,如 daro 的文档标签条)悬在背景之上、下方没有框,画出来就是
  /// 标签左边多一条孤立竖线 —— 所以不画。
  final bool drawLeftEdge;

  final DesktopTokens tokens;
  final VoidCallback onTap;

  /// This tab's own height: the selected tab sticks up and reaches over the
  /// strip hairline, so it is taller than its unselected siblings.
  final double height;

  /// 标签内水平内边距。
  final double padX;

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

  Widget _label(DesktopTokens t, Color fg) => Text(
        widget.tab.label,
        style: _tabLabelStyle(t, fg),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      );

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens;
    final selected = widget.selected;
    // 选中 = surface(与页面面板同底);未选中 = 条底向页面底色提亮一档,
    // hover 再叠一层(明暗自适应)。
    final selectedBg = widget.selectedTabColor ?? t.surfaceColor;
    final unselectedBg = Color.alphaBlend(
        t.surfaceColor.withValues(alpha: _unselectedLift), widget.stripColor);
    final hoverBg = widget.hoverTabColor ??
        Color.alphaBlend(t.hoverOverlayColor, widget.stripColor);
    final bg = selected ? selectedBg : (_hover ? hoverBg : unselectedBg);

    // Close button: hover only, pinned to the tab's right edge; hidden while
    // not hovering (takes no space). Closable tabs left-align the icon +
    // label so the label never shifts when the button appears; non-closable
    // tabs keep the centred look.
    final isClosable = widget.tab.onClose != null;
    final showClose = _hover && isClosable;
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
          // 每个标签都画顶边 + 右侧分隔线;左边线只给首个标签,且仅当标签条
          // 与正文构成闭合框(相邻两标签因此共用一条 1px 竖线,与 Navicat 一致)。
          drawLeft: widget.drawLeftEdge,
          drawRight: true,
          child: SizedBox(
            height: widget.height,
            child: isClosable
                // Closable: icon + label anchored left, close button pinned
                // to the right edge on hover. The Expanded label absorbs the
                // width change, so nothing jumps when the button appears.
                ? Padding(
                    padding: EdgeInsets.only(
                      left: widget.padX,
                      right: 4,
                    ),
                    child: Row(
                      children: [
                        if (widget.tab.icon != null) ...[
                          widget.tab.icon!,
                          const SizedBox(width: _iconGap),
                        ],
                        Expanded(child: _label(t, fg)),
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
                  )
                : Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: widget.padX,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.tab.icon != null) ...[
                            widget.tab.icon!,
                            const SizedBox(width: _iconGap),
                          ],
                          Flexible(child: _label(t, fg)),
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

/// Self-drawn tab chrome: a flat square box filled with [color] and stroked
/// with hairlines — top always, right ([drawRight], which doubles as the
/// divider against the next tab) and left ([drawLeft], first tab of a framed
/// strip only).
///
/// The fill is inset by the right hairline so two adjacent tabs share exactly
/// one divider column instead of drawing two. The bottom edge is never
/// stroked: the selected tab reaches over the strip's bottom line so it
/// merges with the page panel below.
class _TabChrome extends StatelessWidget {
  const _TabChrome({
    required this.color,
    required this.borderColor,
    required this.borderWidth,
    required this.drawLeft,
    required this.drawRight,
    required this.child,
  });

  final Color? color;
  final Color borderColor;
  final double borderWidth;
  final bool drawLeft;
  final bool drawRight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TabChromePainter(
        color: color,
        borderColor: borderColor,
        borderWidth: borderWidth,
        drawLeft: drawLeft,
        drawRight: drawRight,
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
    required this.drawLeft,
    required this.drawRight,
  });

  final Color? color;
  final Color borderColor;
  final double borderWidth;
  final bool drawLeft;
  final bool drawRight;

  @override
  void paint(Canvas canvas, Size size) {
    if (color != null) {
      // 右侧 1px 留给分隔线,否则相邻标签会叠出 2px 竖线。
      final w = drawRight ? math.max(0.0, size.width - borderWidth) : size.width;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, w, size.height),
        Paint()..color = color!,
      );
    }
    final stroke = Paint()..color = borderColor;
    // Top hairline: full width, shared with the tab's own box.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, borderWidth),
      stroke,
    );
    // Right hairline = the divider between this tab and the next one.
    if (drawRight) {
      canvas.drawRect(
        Rect.fromLTWH(size.width - borderWidth, 0, borderWidth, size.height),
        stroke,
      );
    }
    // Left hairline: first tab of a framed strip only (see [drawLeft]).
    if (drawLeft) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, borderWidth, size.height),
        stroke,
      );
    }
  }

  @override
  bool shouldRepaint(_TabChromePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.borderColor != borderColor ||
      oldDelegate.borderWidth != borderWidth ||
      oldDelegate.drawLeft != drawLeft ||
      oldDelegate.drawRight != drawRight;
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
