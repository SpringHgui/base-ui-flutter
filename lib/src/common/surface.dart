import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_extensions.dart';
import '../foundation/token_scope.dart';

/// A headless interactive surface used as the building block for
/// pressable / selectable controls (`Toggle`, `Tag`, `Item`, menu rows…).
///
/// The core carries no visual code: the base fill, hover / pressed variants
/// and the focus ring are all resolved from [DesktopTokens] (see
/// [TokenColor]). Disabled state, semantics, keyboard focus and **keyboard
/// activation** (Enter / Space) are handled here once, so every derived
/// control behaves consistently.
class Surface extends StatefulWidget {
  const Surface({
    super.key,
    this.color,
    this.hoverColor,
    this.pressedColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.padding = EdgeInsets.zero,
    this.margin,
    this.constraints,
    this.onTap,
    this.enabled = true,
    this.cursor,
    this.semanticLabel,
    this.selected,
    this.tokens,
    this.child,
  });

  /// Base fill color. When `null`, the surface is transparent.
  final Color? color;

  /// Exact hover fill (overrides the token hover overlay blend).
  final Color? hoverColor;

  /// Exact pressed fill (overrides the token pressed overlay blend).
  final Color? pressedColor;

  /// Border color. When `null` no border is drawn (except the focus ring).
  final Color? borderColor;

  /// Border width; defaults to [DesktopTokens.borderWidth].
  final double? borderWidth;

  /// Corner radius; defaults to [DesktopTokens.cornerRadius].
  final BorderRadiusGeometry? borderRadius;

  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final BoxConstraints? constraints;

  /// Called when the surface is activated (pointer tap, Enter or Space).
  /// When `null`, the surface is non-interactive (no hover / press
  /// feedback).
  final VoidCallback? onTap;

  final bool enabled;
  final MouseCursor? cursor;
  final String? semanticLabel;

  /// When set, the surface is announced as selected / toggled by
  /// screen-readers (used by `Toggle`, `Item` and friends).
  final bool? selected;

  /// Token override; falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm] (the standard library chain).
  final DesktopTokens? tokens;

  final Widget? child;

  @override
  State<Surface> createState() => _SurfaceState();
}

class _SurfaceState extends State<Surface> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focused = false;
  final FocusNode _focusNode = FocusNode(debugLabel: 'Surface');

  bool get _interactive => widget.enabled && widget.onTap != null;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocus(bool value) => setState(() => _focused = value);

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || !_interactive) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter ||
        event.logicalKey == LogicalKeyboardKey.space) {
      widget.onTap?.call();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens ??
        TokenScope.maybeOf(context) ??
        DesktopTokens.winForm;

    Color fill = widget.color ?? Colors.transparent;
    if (!_interactive) {
      fill = fill.disabledWith(t);
    } else if (_pressed) {
      fill = widget.pressedColor ?? fill.pressedWith(t);
    } else if (_hovered) {
      fill = widget.hoverColor ?? fill.hoveredWith(t);
    }

    final showBorder = _focused && _interactive && widget.borderColor != null;
    final border = Border.all(
      color: showBorder
          ? t.ringColor
          : (widget.borderColor ?? Colors.transparent),
      width: showBorder ? t.ringWidth : (widget.borderWidth ?? t.borderWidth),
    );

    return Semantics(
      label: widget.semanticLabel,
      enabled: widget.enabled,
      button: widget.onTap != null,
      focusable: _interactive,
      selected: widget.selected,
      child: MouseRegion(
        cursor: widget.cursor ??
            (_interactive ? SystemMouseCursors.click : SystemMouseCursors.basic),
        onEnter: _interactive ? (_) => setState(() => _hovered = true) : null,
        onExit: _interactive ? (_) => setState(() => _hovered = false) : null,
        child: GestureDetector(
          onTapDown: _interactive
              ? (_) => setState(() => _pressed = true)
              : null,
          onTapUp: _interactive ? (_) => setState(() => _pressed = false) : null,
          onTapCancel: _interactive
              ? () => setState(() => _pressed = false)
              : null,
          onTap: _interactive ? widget.onTap : null,
          child: Focus(
            focusNode: _focusNode,
            canRequestFocus: _interactive,
            onFocusChange: _handleFocus,
            onKeyEvent: _handleKey,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              margin: widget.margin,
              padding: widget.padding,
              constraints: widget.constraints,
              decoration: BoxDecoration(
                color: fill,
                border: widget.borderColor == null && !showBorder
                    ? null
                    : border,
                borderRadius:
                    widget.borderRadius ?? BorderRadius.circular(t.cornerRadius),
              ),
              alignment: Alignment.center,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
