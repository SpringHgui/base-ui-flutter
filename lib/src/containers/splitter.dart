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

    final line = ColoredBox(
      color: _hovered || _dragging ? t.primaryColor : t.borderColor,
      child: SizedBox(
        width: horizontal ? t.borderWidth : double.infinity,
        height: horizontal ? double.infinity : t.borderWidth,
      ),
    );

    return MouseRegion(
      cursor: horizontal
          ? SystemMouseCursors.resizeLeftRight
          : SystemMouseCursors.resizeUpDown,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
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
