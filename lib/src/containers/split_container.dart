import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// A draggable splitter that resizes two panes (WinForm `SplitContainer`;
/// the counterpart of the shadcn "Resizable").
///
/// The divider width, hover highlight and cursor are token-driven; the
/// core carries no hard-coded visual value.
class SplitContainer extends StatefulWidget {
  const SplitContainer({
    super.key,
    required this.first,
    required this.second,
    this.orientation = Axis.horizontal,
    this.initialRatio = 0.5,
    this.minFirst,
    this.minSecond,
    this.dividerWidth = 4,
    this.onChanged,
    this.tokens,
  });

  /// First pane.
  final Widget first;

  /// Second pane.
  final Widget second;

  /// `horizontal` splits left/right; `vertical` splits top/bottom.
  final Axis orientation;

  /// Initial share (0–1) of the first pane.
  final double initialRatio;

  /// Minimum size of the first pane in pixels.
  final double? minFirst;

  /// Minimum size of the second pane in pixels.
  final double? minSecond;

  /// Divider thickness.
  final double dividerWidth;

  /// Called with the new first-pane ratio (0–1) while dragging.
  final ValueChanged<double>? onChanged;

  /// Token override; falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  @override
  State<SplitContainer> createState() => _SplitContainerState();
}

class _SplitContainerState extends State<SplitContainer> {
  late double _ratio;
  bool _hovered = false;

  /// 拖动起点：首块当时的像素尺寸与指针全局坐标。
  ///
  /// 必须是 State 字段而不能是 build() 里的局部变量：每个事件都会 setState 重建，
  /// GestureDetector 把在途识别器的回调就地换成新闭包，新闭包捕获的是**本次**构建的
  /// 局部量，而它的 dragStart 永远不会被调用 → 第二个事件读未初始化的 late 直接抛
  /// LateInitializationError，表现就是「分隔条拖一下就不动了」。
  double? _dragStartSize;
  Offset? _dragStartPosition;

  void _startDrag(Offset position, double firstSize) {
    _dragStartSize = firstSize;
    _dragStartPosition = position;
  }

  void _updateDrag(Offset position, double usable, {required bool horizontal}) {
    final startSize = _dragStartSize;
    final startPos = _dragStartPosition;
    if (startSize == null || startPos == null) return;
    final delta =
        horizontal ? position.dx - startPos.dx : position.dy - startPos.dy;
    _updateRatio((startSize + delta) / usable);
  }

  void _endDrag() {
    _dragStartSize = null;
    _dragStartPosition = null;
  }

  @override
  void initState() {
    super.initState();
    _ratio = widget.initialRatio.clamp(0.0, 1.0);
  }

  void _updateRatio(double value) {
    final clamped = value.clamp(0.0, 1.0);
    if (clamped == _ratio) return;
    setState(() => _ratio = clamped);
    widget.onChanged?.call(clamped);
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens ??
        TokenScope.maybeOf(context) ??
        DesktopTokens.winForm;

    return LayoutBuilder(
      builder: (context, constraints) {
        final total = widget.orientation == Axis.horizontal
            ? constraints.maxWidth
            : constraints.maxHeight;
        if (total.isFinite == false || total <= 0) {
          return widget.orientation == Axis.horizontal
              ? Row(children: [widget.first, widget.second])
              : Column(children: [widget.first, widget.second]);
        }

        final minFirst = widget.minFirst ?? t.controlHeight * 2;
        final minSecond = widget.minSecond ?? t.controlHeight * 2;
        final usable = total - widget.dividerWidth;
        var first = usable * _ratio;
        if (usable <= minFirst + minSecond) {
          // Viewport smaller than the combined minimums: fall back to an
          // even split so the layout never overflows or crashes.
          first = usable / 2;
        } else {
          final maxFirst = math.max(minFirst, usable - minSecond);
          first = first.clamp(minFirst, maxFirst);
        }

        final divider = MouseRegion(
          cursor: widget.orientation == Axis.horizontal
              ? SystemMouseCursors.resizeLeftRight
              : SystemMouseCursors.resizeUpDown,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragStart: widget.orientation == Axis.horizontal
                ? (d) => _startDrag(d.globalPosition, first)
                : null,
            onHorizontalDragUpdate: widget.orientation == Axis.horizontal
                ? (d) => _updateDrag(d.globalPosition, usable, horizontal: true)
                : null,
            onHorizontalDragEnd:
                widget.orientation == Axis.horizontal ? (_) => _endDrag() : null,
            onHorizontalDragCancel: widget.orientation == Axis.horizontal
                ? _endDrag
                : null,
            onVerticalDragStart: widget.orientation == Axis.vertical
                ? (d) => _startDrag(d.globalPosition, first)
                : null,
            onVerticalDragUpdate: widget.orientation == Axis.vertical
                ? (d) => _updateDrag(d.globalPosition, usable, horizontal: false)
                : null,
            onVerticalDragEnd:
                widget.orientation == Axis.vertical ? (_) => _endDrag() : null,
            onVerticalDragCancel:
                widget.orientation == Axis.vertical ? _endDrag : null,
            child: Container(
              width: widget.orientation == Axis.horizontal
                  ? widget.dividerWidth
                  : double.infinity,
              height: widget.orientation == Axis.vertical
                  ? widget.dividerWidth
                  : double.infinity,
              color: _hovered ? t.primaryColor : t.borderColor,
            ),
          ),
        );

        final panes = <Widget>[];
        if (widget.orientation == Axis.horizontal) {
          panes.add(SizedBox(width: first, child: widget.first));
          panes.add(divider);
          panes.add(Expanded(child: widget.second));
        } else {
          panes.add(SizedBox(height: first, child: widget.first));
          panes.add(divider);
          panes.add(Expanded(child: widget.second));
        }
        return widget.orientation == Axis.horizontal
            ? Row(children: panes)
            : Column(children: panes);
      },
    );
  }
}
