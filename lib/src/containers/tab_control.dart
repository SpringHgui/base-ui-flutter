import 'dart:math' as math;
import 'package:flutter/gestures.dart';
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

/// 滚动箭头格的宽度(标签条两端各一格)。
const double _kArrowWidth = 24.0;

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
/// The bottom hairline is drawn on every tab **except the selected one**, so
/// the selected tab reads as "open" into the content below (see
/// [_TabChrome.drawBottom]); a header-only strip has no full-width bottom line
/// of its own, so each cell draws its own, otherwise the row's lower edge
/// dissolves into the background.
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
/// scroll arrows when the headers overflow the bar. [pinnedCount] keeps the
/// leading N headers outside the scroll viewport so they never scroll away.
/// A header-only usage
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
    this.unselectedTabColor,
    this.hoverTabColor,
    this.barHeight,
    this.tabWidth,
    this.minTabWidth,
    this.tabPaddingX,
    this.scrollStep = 120,
    this.contentPadding,
    this.pinnedCount = 0,
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

  /// Background of an unselected tab; `null` = the strip colour lifted
  /// [_unselectedLift] toward the surface colour.
  ///
  /// 显式钉死这个颜色可以避免"提亮"步骤把纯白调成近白:当调用方的 surface 与
  /// strip 都接近白色时(例如 daro 的 `surfaceColor == background` 配上白色
  /// 标签条),提亮结果会落在 #FCFCFC~#FDFDFD 这类**不是纯白**的档位上,整条
  /// 标签看起来就"不干净"。要求"未选中 = 纯白"的调用方直接传
  /// [DesktopTokens.backgroundColor] 即可。
  final Color? unselectedTabColor;

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

  /// 条首固定、不参与滚动的标签个数(默认 0 = 全部可滚动)。
  ///
  /// 前 N 个标签排在滚动视口**之外**,始终贴在标签条左边;其余标签进
  /// 滚动视口。典型用法是 daro 的文档标签条:第一个永远是"对象"页
  /// (`AppState.objectsTabKey`),它是应用的主入口,不该被后面打开的标签
  /// 挤出视野 —— 否则打开的标签一多,想回到"对象"页就只能先一路滚回最左。
  ///
  /// 固定标签照常参与选中/键盘导航,只是 [_ensureVisible] 对它们直接跳过
  /// (恒在视野里),且判定"是否溢出"时会先把它们的宽度从可用宽度里扣掉。
  final int pinnedCount;

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

  /// 本帧**可滚动**标签头的总宽度(不含固定标签),在 [build] 里算好后
  /// 供滚动箭头判定使用。
  double _tabsWidth = 0;

  /// 本帧固定标签头的总宽度(不参与滚动的那部分)。
  ///
  /// 判定"要不要滚动"时必须把它从可用宽度里扣掉 —— 否则固定标签会被算成
  /// 可滚动内容,标签稍多就误判成溢出、平白弹出箭头。
  double _pinnedWidth = 0;

  /// 本帧**可滚动**标签头的宽度(与 [build] 同源,不含固定标签),
  /// 用于把选中标签滚进可视区。
  List<double> _scrollWidths = const [];

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
      final next = widget.initialIndex.clamp(0, widget.tabs.length - 1);
      if (next != _index) {
        _index = next;
        _scheduleEnsureVisible();
      }
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
    _scheduleEnsureVisible();
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
  ///
  /// 同时刷新「是否需要箭头」和「两端还能不能滚」。老实现把两端可用性只挂在
  /// 滚动监听上,而监听要等用户**已经滚动过**才会触发 —— 于是标签多到溢出时
  /// 两个箭头一个都不出现,标签再也滚不到,即"标签太多时没有滚动"。
  void _syncScrollMetrics() {
    if (!mounted) return;
    final box = _tabBarKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;
    final containerWidth = box.size.width;
    // 两端各留一个箭头格、再扣掉固定标签占的宽度后仍然放不下,才需要滚动。
    final needScroll =
        _tabsWidth > containerWidth - _pinnedWidth - _kArrowWidth * 2;
    final canLeft = _canScrollTowards(-1, needScroll);
    final canRight = _canScrollTowards(1, needScroll);
    if (needScroll != _needScroll ||
        canLeft != _canScrollLeft ||
        canRight != _canScrollRight) {
      setState(() {
        _needScroll = needScroll;
        _canScrollLeft = canLeft;
        _canScrollRight = canRight;
      });
    }
  }

  /// [direction] 取 `-1` / `1` 时分别表示"还能向左 / 向右滚"。
  ///
  /// 留 0.5 的容差:滚动动画的终点是浮点值,严格比较会让箭头在触底后
  /// 一直停在"可点"状态。
  bool _canScrollTowards(int direction, bool needScroll) {
    if (!needScroll || !_scroll.hasClients) return false;
    final pos = _scroll.position;
    return direction < 0
        ? pos.pixels > 0.5
        : pos.pixels < pos.maxScrollExtent - 0.5;
  }

  /// 滚动位置变化:只刷新两端箭头可用性(是否需要箭头由 [_syncScrollMetrics] 管)。
  void _updateArrowVisibility() {
    if (!_needScroll) return;
    final canLeft = _canScrollTowards(-1, true);
    final canRight = _canScrollTowards(1, true);
    if (canLeft != _canScrollLeft || canRight != _canScrollRight) {
      setState(() {
        _canScrollLeft = canLeft;
        _canScrollRight = canRight;
      });
    }
  }

  /// 把第 [index] 个标签滚进可视区。
  ///
  /// 用键盘方向键或右键菜单切到被裁掉的标签时,选中的标签若留在视野之外,
  /// 看起来就像"没切过去"。
  void _ensureVisible(int index) {
    if (!mounted || !_scroll.hasClients) return;
    // 固定标签恒在视野里(它们的索引落在可滚动区之前),直接跳过。
    final scrollIndex = index - widget.pinnedCount;
    if (scrollIndex < 0 || scrollIndex >= _scrollWidths.length) return;
    final pos = _scroll.position;
    final left =
        _scrollWidths.take(scrollIndex).fold<double>(0, (a, b) => a + b);
    final right = left + _scrollWidths[scrollIndex];
    final viewport = pos.viewportDimension;
    double? target;
    if (left < pos.pixels) {
      target = left;
    } else if (right > pos.pixels + viewport) {
      target = right - viewport;
    }
    if (target == null) return;
    _scroll.animateTo(
      target.clamp(0.0, pos.maxScrollExtent),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }

  /// 延到下一帧再滚:索引变化多发生在指针事件里,此刻滚动视图还没完成重排。
  void _scheduleEnsureVisible() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureVisible(_index));
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

    // 前 [TabControl.pinnedCount] 个标签固定在条首、不参与滚动(如 daro 的
    // "对象"页);其余标签进滚动视口。宽度仍按全量算,只是拆分归属:
    // 固定部分的宽度要从"可用宽度"里扣掉,滚动部分的宽度才用于溢出判定。
    final pinned = widget.pinnedCount.clamp(0, widget.tabs.length);
    final widths = <double>[
      for (final tab in widget.tabs) _headerWidth(context, t, tab),
    ];
    _pinnedWidth = widths.take(pinned).fold(0.0, (sum, w) => sum + w);
    _tabsWidth = widths.skip(pinned).fold(0.0, (sum, w) => sum + w);
    _scrollWidths = widths.sublist(pinned);

    Widget tabHeader(int i) {
      final selected = i == index;
      return SizedBox(
        width: widths[i],
        child: selected
            ? _TabHeader(
                tab: widget.tabs[i],
                selected: true,
                drawLeftEdge: hasBody && i == 0,
                stripBottomLine: hasBody,
                tokens: t,
                onTap: () => _select(i),
                height: stripH,
                padX: _padX(t),
                stripColor: stripBg,
                selectedTabColor: widget.selectedTabColor,
                unselectedTabColor: widget.unselectedTabColor,
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
                  stripBottomLine: hasBody,
                  tokens: t,
                  onTap: () => _select(i),
                  height: headerH,
                  padX: _padX(t),
                  stripColor: stripBg,
                  selectedTabColor: widget.selectedTabColor,
                  unselectedTabColor: widget.unselectedTabColor,
                  hoverTabColor: widget.hoverTabColor,
                ),
              ),
      );
    }

    // 固定标签与滚动视口、箭头同一行排布:[固定…] [左箭头] [滚动视口] [右箭头]。
    // 左箭头必须紧跟在**固定标签右侧**,不能摆到整条最左端 —— 它滚的是固定块
    // 之后的内容,摆在"对象"页左边会看起来像在滚一个钉死不动的标签。
    final tabsRow = Focus(
      focusNode: _barFocus,
      onKeyEvent: _handleBarKey,
      child: Listener(
        // 桌面习惯:滚轮压在标签条上就直接横向滚,不必去够那对小箭头。
        onPointerSignal: (event) {
          if (event is! PointerScrollEvent) return;
          final delta = event.scrollDelta.dy != 0
              ? event.scrollDelta.dy
              : event.scrollDelta.dx;
          if (delta != 0) _scrollBy(delta);
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 固定标签:排在滚动视口**之外** —— 它们不随滚动位移,
            // 永远贴在标签条左侧(如 daro 的"对象"页)。
            for (var i = 0; i < pinned; i++) tabHeader(i),
            // 只要溢出,两个箭头就恒在(滚不动的一侧置灰),与 Navicat 一致 ——
            // 若按"能不能滚"决定显隐,箭头会在滚动到端点时突然消失,整条标签
            // 左右抽搐 24px。
            if (_needScroll)
              _ScrollArrow(
                tokens: t,
                icon: Icons.chevron_left,
                barColor: stripBg,
                height: stripH,
                enabled: _canScrollLeft,
                dividerOnRight: true,
                onTap: () => _scrollBy(-widget.scrollStep),
              ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scroll,
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = pinned; i < widget.tabs.length; i++)
                      tabHeader(i),
                  ],
                ),
              ),
            ),
            if (_needScroll)
              _ScrollArrow(
                tokens: t,
                icon: Icons.chevron_right,
                barColor: stripBg,
                height: stripH,
                enabled: _canScrollRight,
                onTap: () => _scrollBy(widget.scrollStep),
              ),
          ],
        ),
      ),
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
                child: Container(height: lineH, color: t.buttonBorderColor),
              ),
            tabsRow,
            // Post-frame measurement: determines whether scroll arrows
            // are needed without LayoutBuilder (which conflicts with
            // IntrinsicHeight, e.g. inside DialogBox).
            Builder(builder: (_) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _syncScrollMetrics();
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
                // 面板面色是白的(选中标签/正文同底),轮廓必须用比通用
                // 细线深一档的控件边线,否则整块白色糊在一起 —— 与 Button
                // "面色变白后补回轮廓感"同一条规则。
                border: Border(
                  left: BorderSide(
                      color: t.buttonBorderColor, width: t.borderWidth),
                  right: BorderSide(
                      color: t.buttonBorderColor, width: t.borderWidth),
                  bottom: BorderSide(
                      color: t.buttonBorderColor, width: t.borderWidth),
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
    required this.stripBottomLine,
    required this.tokens,
    required this.onTap,
    required this.height,
    required this.padX,
    required this.stripColor,
    this.selectedTabColor,
    this.unselectedTabColor,
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

  /// 标签条底部是否已经有横贯全宽的发丝线(带正文的标签条才有,由
  /// [TabControl] 自己画)。
  ///
  /// 有的话未选中的标签**不必**自画底线 —— 它就在那条线的正上方紧贴,再画
  /// 一条只会叠成 2px 粗。纯标签条(没有正文、因而不画全宽底线)才需要每个
  /// 格子自己补底线,否则一排标签悬在白底上、下沿全无交代。
  final bool stripBottomLine;

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

  /// Background of an unselected tab; `null` = the strip colour lifted toward
  /// the surface colour (see [TabControl.unselectedTabColor]).
  final Color? unselectedTabColor;

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
    // 选中 = surface(与页面面板同底);未选中 = 调用方钉死的颜色,没给才
    // 退回"条底向页面底色提亮一档";hover 再叠一层(明暗自适应)。
    final selectedBg = widget.selectedTabColor ?? t.surfaceColor;
    // 未选中:优先用调用方钉死的颜色。白底标签条上"向面色提亮"会把纯白调成
    // #FCFCFC~#FDFDFD 这类近白,白得不利落,整条标签就发脏。
    final unselectedBg = widget.unselectedTabColor ??
        Color.alphaBlend(
            t.surfaceColor.withValues(alpha: _unselectedLift),
            widget.stripColor);
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
          // 标签面色是白的/近白的,轮廓用控件边线(比通用细线深一档)才立得住:
          // 通用细线压在纯白标签上几乎看不见,标签之间就糊成一片"脏白"。
          borderColor: t.buttonBorderColor,
          borderWidth: t.borderWidth,
          // 每个标签都画顶边 + 右侧分隔线;左边线只给首个标签,且仅当标签条
          // 与正文构成闭合框(相邻两标签因此共用一条 1px 竖线,与 Navicat 一致)。
          drawLeft: widget.drawLeftEdge,
          drawRight: true,
          // 底边只有**未选中**的标签才画:选中那个留空,与下方正文连通。
          // 但若条底本来就有全宽的底线(带正文的标签条),就别再画 —— 两者
          // 正好重叠,会叠成 2px 粗。
          drawBottom: !widget.stripBottomLine && !selected,
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
/// divider against the next tab), left ([drawLeft], first tab of a framed
/// strip only) and bottom ([drawBottom], every tab **except the selected
/// one**).
///
/// The fill is inset by the right hairline so two adjacent tabs share exactly
/// one divider column instead of drawing two.
///
/// 底边只画在**未选中**的标签上(选中那个传 `drawBottom: false`):它的底边
/// 留空,与下方内容连通,这是经典 WinForms / Navicat 的"抽屉"观感 —— 一排
/// 标签都站在那里,只有当前这个"往下开口"。它也因此比兄弟多占那 1px 底边
/// (填充一直铺到条底),看着像跟正文连成一块。
class _TabChrome extends StatelessWidget {
  const _TabChrome({
    required this.color,
    required this.borderColor,
    required this.borderWidth,
    required this.drawLeft,
    required this.drawRight,
    required this.child,
    this.drawBottom = false,
  });

  final Color? color;
  final Color borderColor;
  final double borderWidth;
  final bool drawLeft;
  final bool drawRight;
  final bool drawBottom;
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
        drawBottom: drawBottom,
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
    required this.drawBottom,
  });

  final Color? color;
  final Color borderColor;
  final double borderWidth;
  final bool drawLeft;
  final bool drawRight;
  final bool drawBottom;

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
    // Bottom hairline: 未选中的标签才有(选中那个留空与正文连通)。
    if (drawBottom) {
      canvas.drawRect(
        Rect.fromLTWH(0, size.height - borderWidth, size.width, borderWidth),
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
      oldDelegate.drawRight != drawRight ||
      oldDelegate.drawBottom != drawBottom;
}

class _ScrollArrow extends StatefulWidget {
  const _ScrollArrow({
    required this.tokens,
    required this.icon,
    required this.barColor,
    required this.height,
    required this.onTap,
    this.enabled = true,
    this.dividerOnRight = false,
  });

  final DesktopTokens tokens;
  final IconData icon;
  final Color barColor;

  /// Full strip height (selected-tab height) so the arrow fills the bar.
  final double height;

  final VoidCallback onTap;

  /// 该方向是否还能继续滚。不能时箭头置灰且不响应点击 —— 两端箭头恒在
  /// (Navicat 的做法),只是到头的一侧变灰,不在滚动时忽隐忽现。
  final bool enabled;

  /// 分隔线画在哪一侧:左箭头画右缘、右箭头画左缘,把箭头格与标签分开。
  /// 否则白底标签条上只剩一个孤零零的雪佛龙,看不出是个可点的格子。
  final bool dividerOnRight;

  @override
  State<_ScrollArrow> createState() => _ScrollArrowState();
}

class _ScrollArrowState extends State<_ScrollArrow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens;
    final active = widget.enabled;
    final hovered = active && _hover;
    return MouseRegion(
      cursor: active ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: active ? widget.onTap : null,
        child: Container(
          width: _kArrowWidth,
          height: widget.height,
          // 显式居中:Container 有 child 但没给 alignment 时,child 是被摆在
          // 内边距的**左上角**(不是居中),雪佛龙会挤在格子左上,与标签文字
          // 的居中基线对不齐。
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: hovered
                ? Color.alphaBlend(t.hoverOverlayColor, widget.barColor)
                : widget.barColor,
            border: Border(
              // 顶/底边:箭头格也是标签条的一段 —— 标签头都画顶线,未选中的
              // 标签头又画底线;少了这两条,箭头看着像浮在条外的一座孤岛
              // (顶线和底线都在箭头处断开)。箭头没有"选中"态,两条恒有。
              top: BorderSide(
                  color: t.buttonBorderColor, width: t.borderWidth),
              bottom: BorderSide(
                  color: t.buttonBorderColor, width: t.borderWidth),
              left: widget.dividerOnRight
                  ? BorderSide.none
                  : BorderSide(
                      color: t.buttonBorderColor, width: t.borderWidth),
              right: widget.dividerOnRight
                  ? BorderSide(
                      color: t.buttonBorderColor, width: t.borderWidth)
                  : BorderSide.none,
            ),
          ),
          child: Icon(
            widget.icon,
            size: 16,
            color: !active
                ? t.disabledForegroundColor
                : (hovered ? t.foregroundColor : t.mutedForegroundColor),
          ),
        ),
      ),
    );
  }
}
