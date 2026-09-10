import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// A draggable resize handle between two panes (WinForm `Splitter`).
///
/// Unlike [SplitContainer], which owns a ratio-based two-pane layout, this is
/// a standalone handle: it only reports pixel deltas through [onDrag] so the
/// host decides which pane (and how) to resize. That makes it usable in
/// three-column shells, docked panels and any externally-sized layout.
///
/// Thickness, hairline color and hover highlight are token-driven; the core
/// carries no hard-coded visual value. No animation, no Material ink.
class Splitter extends StatefulWidget {
  const Splitter({
    super.key,
    required this.onDrag,
    this.orientation = Axis.horizontal,
    this.thickness = 5,
    this.showHairline = true,
    this.showHoverHighlight = true,
    this.onDragStart,
    this.onDragEnd,
    this.tokens,
  });

  /// Pointer movement along the split axis, in pixels.
  ///
  /// For [Axis.horizontal] a positive value means the pointer moved right; for
  /// [Axis.vertical] it means the pointer moved down. Callers flip the sign for
  /// panes docked to the trailing edge.
  final ValueChanged<double> onDrag;

  /// `horizontal` = vertical bar (resizes width); `vertical` = horizontal bar.
  final Axis orientation;

  /// Hit-test thickness of the handle; the visible hairline stays 1px centered.
  final double thickness;

  /// Whether the resting 1px hairline is painted (defaults to `true`).
  ///
  /// Set it to `false` when the two panes are meant to sit **flush** against
  /// each other and the handle is overlaid on the seam instead of occupying
  /// layout space: the strip draws nothing at rest, so the panes never look
  /// separated by a gap or framed by a border. Hover / drag feedback is a
  /// separate concern — see [showHoverHighlight].
  final bool showHairline;

  /// Whether the hairline switches to [DesktopTokens.primaryColor] while the
  /// pointer is over the handle or it is being dragged (defaults to `true`).
  ///
  /// Turn it off to keep the seam visually inert: with [showHairline] `true`
  /// the hairline stays a static `borderColor`, and with it `false` nothing is
  /// painted in any state. The handle keeps its resize cursor
  /// (`resizeLeftRight` / `resizeUpDown`) and its full hit-test strip, so it is
  /// still grabbable; no pointer-enter/exit callbacks are registered at all,
  /// so hovering an inert handle costs no rebuild.
  final bool showHoverHighlight;

  final VoidCallback? onDragStart;

  /// Called on drag end **and** on drag cancel, so hosts can always exit the
  /// "resizing" state.
  final VoidCallback? onDragEnd;

  /// Token override; falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  @override
  State<Splitter> createState() => _SplitterState();
}

class _SplitterState extends State<Splitter> {
  bool _hovered = false;
  bool _dragging = false;

  void _end() {
    if (!_dragging) return;
    setState(() => _dragging = false);
    widget.onDragEnd?.call();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens ??
        TokenScope.maybeOf(context) ??
        DesktopTokens.winForm;
    final horizontal = widget.orientation == Axis.horizontal;
    final vertical = !horizontal;

    void start() {
      setState(() => _dragging = true);
      widget.onDragStart?.call();
    }

    // 静止态画不画线 = showHairline;hover / 拖动换成 accent 色 = showHoverHighlight
    final active = widget.showHoverHighlight && (_hovered || _dragging);
    final line = ColoredBox(
      color: active
          ? t.primaryColor
          : (widget.showHairline ? t.borderColor : Colors.transparent),
      child: SizedBox(
        width: horizontal ? t.borderWidth : double.infinity,
        height: horizontal ? double.infinity : t.borderWidth,
      ),
    );

    return MouseRegion(
      cursor: horizontal
          ? SystemMouseCursors.resizeLeftRight
          : SystemMouseCursors.resizeUpDown,
      // 关掉高亮后没有任何视觉依赖 hover 状态 → 不注册回调,悬停零重建
      onEnter: widget.showHoverHighlight
          ? (_) => setState(() => _hovered = true)
          : null,
      onExit: widget.showHoverHighlight
          ? (_) => setState(() => _hovered = false)
          : null,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: horizontal ? (_) => start() : null,
        onHorizontalDragUpdate:
            horizontal ? (d) => widget.onDrag(d.delta.dx) : null,
        onHorizontalDragEnd: horizontal ? (_) => _end() : null,
        onHorizontalDragCancel: horizontal ? _end : null,
        onVerticalDragStart: vertical ? (_) => start() : null,
        onVerticalDragUpdate: vertical ? (d) => widget.onDrag(d.delta.dy) : null,
        onVerticalDragEnd: vertical ? (_) => _end() : null,
        onVerticalDragCancel: vertical ? _end : null,
        child: SizedBox(
          width: horizontal ? widget.thickness : double.infinity,
          height: horizontal ? double.infinity : widget.thickness,
          child: Center(child: line),
        ),
      ),
    );
  }
}
