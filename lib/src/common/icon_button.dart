import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// A lightweight icon-only button for toolbars / title bars.
///
/// Rendered as a borderless button with an icon (or arbitrary [child]);
/// hover gets the ghost overlay tint, [selected] gets the accent tint plus
/// an optional [outline] border. All colors come from [DesktopTokens].
/// No Material ripple, no click animation (desktop fast-paced interaction).
class IconBtn extends StatefulWidget {
  const IconBtn({
    super.key,
    this.icon,
    this.child,
    this.onTap,
    this.iconSize = 16,
    this.color,
    this.tokens,
    this.tooltip,
    this.selected = false,
    this.selectedColor,
    this.outline = false,
    this.size,
  }) : assert(
          icon != null || child != null,
          'IconBtn requires either `icon` or `child`.',
        );

  /// The icon to render (ignored when [child] is provided).
  final IconData? icon;

  /// Arbitrary content (e.g. a [CustomPaint]); replaces [icon].
  final Widget? child;

  /// Called when the button is activated. When `null`, the button is disabled.
  final VoidCallback? onTap;

  /// Icon size in logical pixels.
  final double iconSize;

  /// Icon color. Defaults to the token muted foreground color.
  final Color? color;

  /// Token override; falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  /// Optional hover tooltip.
  final String? tooltip;

  /// Whether the button is in the selected / active state: the icon (or
  /// [selectedColor]) switches to the accent color and a faint accent
  /// background is shown.
  final bool selected;

  /// Color used for the selected state; defaults to the token primary color.
  final Color? selectedColor;

  /// When `true` a hairline border is drawn (accent-tinted while selected).
  final bool outline;

  /// Fixed hit-area size; when `null` the size derives from the content.
  final Size? size;

  @override
  State<IconBtn> createState() => _IconBtnState();
}

class _IconBtnState extends State<IconBtn> {
  bool _hover = false;
  bool _pressed = false;
  final FocusNode _focusNode = FocusNode(debugLabel: 'IconBtn');

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || widget.onTap == null) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.space) {
      widget.onTap!();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final t =
        widget.tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    final enabled = widget.onTap != null;
    final accent = widget.selectedColor ?? t.primaryColor;

    final iconColor = widget.selected
        ? accent
        : (widget.color ?? t.mutedForegroundColor);

    // 背景:selected 显示 accent 淡底(hover 加深、pressed 再加深);
    // 未选中 hover / pressed 显示 overlay 灰底
    Color? bg;
    if (widget.selected) {
      final alpha = _pressed && enabled
          ? 0.28
          : (_hover && enabled ? 0.20 : 0.12);
      bg = Color.alphaBlend(accent.withValues(alpha: alpha), t.controlColor);
    } else if (_hover || _pressed) {
      final overlay = _pressed && enabled
          ? t.pressedOverlayColor
          : t.hoverOverlayColor;
      bg = Color.alphaBlend(overlay, t.controlColor);
    }

    final content = Container(
      width: widget.size?.width,
      height: widget.size?.height ?? t.controlHeight,
      constraints: widget.size == null
          ? BoxConstraints(minWidth: t.controlHeight)
          : null,
      padding: widget.size == null
          ? EdgeInsets.symmetric(horizontal: t.compactSpacing)
          : EdgeInsets.zero,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(t.cornerRadius),
        border: widget.outline
            ? Border.all(
                color: widget.selected ? accent : (widget.color ?? t.borderColor),
                width: t.borderWidth,
              )
            : null,
      ),
      child: widget.child ??
          Icon(
            widget.icon,
            size: widget.iconSize,
            color: enabled ? iconColor : t.disabledForegroundColor,
          ),
    );

    final button = Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKey,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: enabled ? (_) => setState(() => _hover = true) : null,
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
          onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
          onTapCancel: () => setState(() => _pressed = false),
          onTap: enabled ? widget.onTap : null,
          child: content,
        ),
      ),
    );

    return widget.tooltip == null ? button : Tooltip(message: widget.tooltip!, child: button);
  }
}
