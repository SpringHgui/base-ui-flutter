import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

/// A single entry inside a [ToolStrip].
sealed class ToolStripItem {
  const ToolStripItem();
}

/// A clickable button on the toolbar.
class ToolStripButton extends ToolStripItem {
  const ToolStripButton({
    this.text,
    this.icon,
    this.iconColor,
    this.onPressed,
    this.enabled = true,
    this.tooltip,
  });

  /// Display text. May be `null` when only an [icon] is shown.
  final String? text;

  /// Optional leading icon.
  final IconData? icon;

  /// Optional icon color. When omitted the icon uses [DesktopTokens.foregroundColor].
  final Color? iconColor;

  /// Called when the button is activated. When `null` the button is inert.
  final VoidCallback? onPressed;

  /// Whether the button is interactive.
  final bool enabled;

  /// Optional tooltip shown on hover.
  final String? tooltip;
}

/// A thin vertical line that separates groups of toolbar items.
class ToolStripSeparator extends ToolStripItem {
  const ToolStripSeparator();
}

/// A non-interactive text label on the toolbar.
class ToolStripLabel extends ToolStripItem {
  const ToolStripLabel({
    required this.text,
    this.enabled = true,
  });

  /// Display text.
  final String text;

  /// Whether the label is rendered in normal or disabled colour.
  final bool enabled;
}

/// A button that shows a drop-down list when clicked.
///
/// When [onPressed] is provided the button becomes a split button: tapping the
/// icon/text body fires [onPressed] directly, while the trailing caret opens
/// the drop-down [items]. When [onPressed] is `null` the whole button opens
/// the drop-down (original behaviour).
///
/// [text] may be omitted for an icon-only drop-down button (the caret is
/// hidden in that case).
class ToolStripDropDownButton extends ToolStripItem {
  const ToolStripDropDownButton({
    this.text,
    this.icon,
    this.iconColor,
    this.onPressed,
    required this.items,
    this.enabled = true,
    this.tooltip,
  });

  /// Display text. May be `null` when only an [icon] is shown.
  final String? text;

  /// Optional leading icon.
  final IconData? icon;

  /// Optional icon color. When omitted the icon uses [DesktopTokens.foregroundColor].
  final Color? iconColor;

  /// Main-button action for split buttons. When non-`null`, tapping the
  /// icon/text body triggers this callback and a caret is shown on the right
  /// to open [items]. When `null` the whole button opens [items].
  final VoidCallback? onPressed;

  /// Drop-down entries.
  final List<ToolStripDropDownEntry> items;

  /// Whether the button is interactive.
  final bool enabled;

  /// Optional tooltip shown on hover.
  final String? tooltip;
}

/// A single entry inside a [ToolStripDropDownButton].
class ToolStripDropDownEntry {
  const ToolStripDropDownEntry({
    required this.text,
    this.onPressed,
    this.enabled = true,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool enabled;
}

// ---------------------------------------------------------------------------
// ToolStrip
// ---------------------------------------------------------------------------

/// A WinForm-style toolbar.
///
/// Renders a horizontal strip of buttons, separators, labels, and drop-down
/// buttons. All visual values are driven by [DesktopTokens].
class ToolStrip extends StatefulWidget {
  const ToolStrip({
    super.key,
    required this.items,
    this.trailingItems,
    this.trailing,
    this.borderOnTop = false,
    this.openUpward = false,
    this.tokens,
  });

  /// Toolbar entries (left-aligned).
  final List<ToolStripItem> items;

  /// Toolbar entries anchored to the right edge (after a spacer).
  final List<ToolStripItem>? trailingItems;

  /// Arbitrary widget anchored to the right edge, rendered before
  /// [trailingItems] (e.g. a `Pagination`).
  final Widget? trailing;

  /// When `true` the hairline border is drawn on top instead of below —
  /// for strips docked at the bottom of a region.
  final bool borderOnTop;

  /// When `true` drop-down overlays open above their button (for strips
  /// docked at the bottom of the window).
  final bool openUpward;

  /// Token override.
  final DesktopTokens? tokens;

  @override
  State<ToolStrip> createState() => _ToolStripState();
}

class _ToolStripState extends State<ToolStrip> {
  OverlayEntry? _overlayEntry;

  void _dismissOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showDropDown(
      ToolStripDropDownButton button, GlobalKey key, DesktopTokens t) {
    _dismissOverlay();
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final offset = renderBox.localToGlobal(Offset.zero);
    final mediaSize = MediaQuery.of(context).size;
    // 下拉面板 minWidth 140,靠右触发时夹取避免溢出屏幕右缘
    final left = offset.dx.clamp(0.0, (mediaSize.width - 160).clamp(0.0, mediaSize.width));

    _overlayEntry = OverlayEntry(
      builder: (ctx) => _ToolStripDropDownOverlay(
        items: button.items,
        // 向上弹出时以"距屏幕底边距离"定位
        position: widget.openUpward
            ? Offset(left, mediaSize.height - offset.dy)
            : Offset(left, offset.dy + renderBox.size.height),
        openUpward: widget.openUpward,
        tokens: t,
        onDismiss: _dismissOverlay,
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  void dispose() {
    _dismissOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens ??
        TokenScope.maybeOf(context) ??
        DesktopTokens.winForm;

    final hasTrailing =
        widget.trailing != null ||
        (widget.trailingItems != null && widget.trailingItems!.isNotEmpty);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.controlColor,
        border: widget.borderOnTop
            ? Border(
                top: BorderSide(color: t.borderColor, width: t.borderWidth),
              )
            : Border(
                bottom: BorderSide(color: t.borderColor, width: t.borderWidth),
              ),
      ),
      child: SizedBox(
        height: t.controlHeight + t.compactSpacing * 2,
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: t.compactSpacing, vertical: t.compactSpacing),
          child: Row(
            children: [
              for (final item in widget.items) _buildItem(item, t),
              if (hasTrailing) ...[
                const Spacer(),
                if (widget.trailing != null) widget.trailing!,
                for (final item in widget.trailingItems ?? const <ToolStripItem>[])
                  _buildItem(item, t),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(ToolStripItem item, DesktopTokens t) {
    return switch (item) {
      ToolStripButton() => _ToolStripButtonWidget(button: item, tokens: t),
      ToolStripSeparator() => _ToolStripSeparatorWidget(tokens: t),
      ToolStripLabel() => _ToolStripLabelWidget(label: item, tokens: t),
      ToolStripDropDownButton() => _ToolStripDropDownWidget(
          button: item,
          tokens: t,
          onOpen: (key) => _showDropDown(item, key, t),
        ),
    };
  }
}

// ---------------------------------------------------------------------------
// Button
// ---------------------------------------------------------------------------

class _ToolStripButtonWidget extends StatefulWidget {
  const _ToolStripButtonWidget({
    required this.button,
    required this.tokens,
  });

  final ToolStripButton button;
  final DesktopTokens tokens;

  @override
  State<_ToolStripButtonWidget> createState() =>
      _ToolStripButtonWidgetState();
}

class _ToolStripButtonWidgetState extends State<_ToolStripButtonWidget> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens;
    final b = widget.button;
    // 禁用态不响应 hover/pressed 背景变化
    final bg = !b.enabled
        ? Colors.transparent
        : (_pressed
            ? t.controlPressedColor
            : (_hovered ? t.controlHoverColor : Colors.transparent));

    final content = Container(
      height: t.controlHeight,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: t.compactSpacing * 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(t.cornerRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (b.icon != null)
            Padding(
              padding: EdgeInsets.only(
                right: b.text != null ? t.compactSpacing : 0,
              ),
              child: Icon(
                b.icon,
                size: t.fontSize + 2,
                color: b.enabled
                    ? (b.iconColor ?? t.foregroundColor)
                    : t.disabledForegroundColor,
              ),
            ),
          if (b.text != null)
            Text(
              b.text!,
              style: TextStyle(
                fontFamily: t.fontFamily,
                fontSize: t.fontSize,
                color: b.enabled
                    ? t.foregroundColor
                    : t.disabledForegroundColor,
                height: 1.0,
              ),
            ),
        ],
      ),
    );

    Widget child = content;
    if (b.tooltip != null) {
      child = Tooltip(message: b.tooltip!, child: content);
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: b.enabled
            ? (_) => setState(() => _pressed = true)
            : null,
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: b.enabled ? b.onPressed : null,
        child: child,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Separator
// ---------------------------------------------------------------------------

class _ToolStripSeparatorWidget extends StatelessWidget {
  const _ToolStripSeparatorWidget({required this.tokens});

  final DesktopTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: tokens.compactSpacing),
      child: Container(
        width: tokens.borderWidth,
        color: tokens.borderColor,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Label
// ---------------------------------------------------------------------------

class _ToolStripLabelWidget extends StatelessWidget {
  const _ToolStripLabelWidget({
    required this.label,
    required this.tokens,
  });

  final ToolStripLabel label;
  final DesktopTokens tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: t.compactSpacing),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label.text,
          style: TextStyle(
            fontFamily: t.fontFamily,
            fontSize: t.fontSize,
            color: label.enabled
                ? t.foregroundColor
                : t.disabledForegroundColor,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Drop-down button
// ---------------------------------------------------------------------------

class _ToolStripDropDownWidget extends StatefulWidget {
  const _ToolStripDropDownWidget({
    required this.button,
    required this.tokens,
    required this.onOpen,
  });

  final ToolStripDropDownButton button;
  final DesktopTokens tokens;
  final ValueChanged<GlobalKey> onOpen;

  @override
  State<_ToolStripDropDownWidget> createState() =>
      _ToolStripDropDownWidgetState();
}

class _ToolStripDropDownWidgetState
    extends State<_ToolStripDropDownWidget> {
  final _key = GlobalKey();
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens;
    final b = widget.button;
    // 禁用态不响应 hover 背景变化
    final bg = !b.enabled
        ? Colors.transparent
        : (_hovered ? t.controlHoverColor : Colors.transparent);
    final isSplit = b.onPressed != null;

    // 主按钮体(图标 + 文字 + 非 split 模式下的下拉箭头)。
    // - split 模式:点击体 = onPressed 直接执行(如新建常规表)
    // - 非 split:点击体 = 打开下拉菜单(箭头作为同一命中区的一部分)
    final bodyChild = Container(
      height: t.controlHeight,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: t.compactSpacing * 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(t.cornerRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (b.icon != null)
            Padding(
              padding: EdgeInsets.only(right: b.text != null ? t.compactSpacing : 0),
              child: Icon(
                b.icon,
                size: t.fontSize + 2,
                color: b.enabled
                    ? (b.iconColor ?? t.foregroundColor)
                    : t.disabledForegroundColor,
              ),
            ),
          if (b.text != null)
            Text(
              b.text!,
              style: TextStyle(
                fontFamily: t.fontFamily,
                fontSize: t.fontSize,
                color: b.enabled ? t.foregroundColor : t.disabledForegroundColor,
                height: 1.0,
              ),
            ),
          if (!isSplit && b.text != null)
            Padding(
              padding: EdgeInsets.only(left: t.compactSpacing),
              child: Icon(
                Icons.arrow_drop_down,
                size: t.fontSize + 2,
                color: b.enabled ? t.foregroundColor : t.disabledForegroundColor,
              ),
            ),
        ],
      ),
    );

    final body = GestureDetector(
      // split 模式下定位锚点(_key)放在右侧箭头,非 split 放在主体
      key: isSplit ? null : _key,
      behavior: HitTestBehavior.opaque,
      onTap: b.enabled
          ? () => isSplit ? b.onPressed!() : widget.onOpen(_key)
          : null,
      child: bodyChild,
    );

    if (!isSplit) {
      return MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: body,
      );
    }

    // split 模式:整颗做成"统一的一颗按钮"——悬浮时整体一个 hover 背景,
    // 主体(图标+文字)点击 = onPressed 直接执行,右侧箭头独立点击打开下拉。
    // 主体与箭头之间的细分隔线仅悬浮时显示,但常驻 1px 占位(透明),
    // 避免悬浮时按钮整体变宽。
    // 分割线颜色基于 hover 底色明暗自适应:暗底提亮、亮底加深,
    // 保证在明亮 / 暗黑两套主题下都清晰可见
    // (固定 borderColor 在亮色下与 hover 底色几乎同色,导致看不到)
    final splitDivider = Container(
      width: t.borderWidth,
      color: _hovered
          ? (bg.computeLuminance() < 0.5
              ? Color.alphaBlend(const Color(0x40FFFFFF), bg)
              : Color.alphaBlend(const Color(0x40000000), bg))
          : Colors.transparent,
    );
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Container(
        height: t.controlHeight,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(t.cornerRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: b.enabled ? b.onPressed : null,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: t.compactSpacing * 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (b.icon != null)
                      Padding(
                        padding: EdgeInsets.only(
                            right: b.text != null ? t.compactSpacing : 0),
                        child: Icon(
                          b.icon,
                          size: t.fontSize + 2,
                          color: b.enabled
                              ? (b.iconColor ?? t.foregroundColor)
                              : t.disabledForegroundColor,
                        ),
                      ),
                    if (b.text != null)
                      Text(
                        b.text!,
                        style: TextStyle(
                          fontFamily: t.fontFamily,
                          fontSize: t.fontSize,
                          color: b.enabled
                              ? t.foregroundColor
                              : t.disabledForegroundColor,
                          height: 1.0,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            splitDivider,
            GestureDetector(
              key: _key,
              behavior: HitTestBehavior.opaque,
              onTap: b.enabled ? () => widget.onOpen(_key) : null,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: t.compactSpacing * 0.5),
                child: Icon(
                  Icons.arrow_drop_down,
                  size: t.fontSize + 2,
                  color: b.enabled ? t.foregroundColor : t.disabledForegroundColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Drop-down overlay for ToolStripDropDownButton
// ---------------------------------------------------------------------------

class _ToolStripDropDownOverlay extends StatelessWidget {
  const _ToolStripDropDownOverlay({
    required this.items,
    required this.position,
    required this.tokens,
    required this.onDismiss,
    this.openUpward = false,
  });

  final List<ToolStripDropDownEntry> items;

  /// 向下弹出时为面板左上角全局坐标;向上弹出时 [Offset.dy] 表示
  /// 面板底边距屏幕底边的距离。
  final Offset position;
  final bool openUpward;
  final DesktopTokens tokens;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final t = tokens;

    final panel = Container(
            constraints: const BoxConstraints(minWidth: 140),
            padding: EdgeInsets.symmetric(vertical: t.compactSpacing),
            decoration: BoxDecoration(
              color: t.surfaceColor,
              border: Border.all(color: t.borderColor, width: t.borderWidth),
            ),
            child: IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: items.map((entry) {
                  return _ToolStripDropDownEntryWidget(
                    entry: entry,
                    tokens: t,
                    onTap: () {
                      if (entry.enabled) {
                        entry.onPressed?.call();
                        onDismiss();
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          );

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onDismiss,
            child: const ColoredBox(color: Colors.transparent),
          ),
        ),
        Positioned(
          left: position.dx,
          top: openUpward ? null : position.dy,
          bottom: openUpward ? position.dy : null,
          child: panel,
        ),
      ],
    );
  }
}

class _ToolStripDropDownEntryWidget extends StatefulWidget {
  const _ToolStripDropDownEntryWidget({
    required this.entry,
    required this.tokens,
    required this.onTap,
  });

  final ToolStripDropDownEntry entry;
  final DesktopTokens tokens;
  final VoidCallback onTap;

  @override
  State<_ToolStripDropDownEntryWidget> createState() =>
      _ToolStripDropDownEntryWidgetState();
}

class _ToolStripDropDownEntryWidgetState
    extends State<_ToolStripDropDownEntryWidget> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: t.controlHeight,
          padding:
              EdgeInsets.symmetric(horizontal: t.controlPaddingX),
          color: _hovered ? t.primaryColor : Colors.transparent,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.entry.text,
              style: TextStyle(
                fontFamily: t.fontFamily,
                fontSize: t.fontSize,
                color: _hovered
                    ? t.surfaceColor
                    : (widget.entry.enabled
                        ? t.foregroundColor
                        : t.disabledForegroundColor),
                fontWeight: FontWeight.w400,
                decoration: TextDecoration.none,
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
