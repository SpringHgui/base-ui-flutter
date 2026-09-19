import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// The orientation of a [ScrollBar].
enum ScrollBarOrientation { horizontal, vertical }

/// 滚动条静止时的窄厚度。
const double kScrollBarSlimThickness = 5.0;

/// 滚动条悬浮 / 拖动时恢复的常规厚度。
const double kScrollBarExpandedThickness = 8.0;

/// 「静止窄、鼠标悬浮上去后恢复常规宽度」的滚动条厚度策略。
///
/// 供宿主写入全局 `ThemeData.scrollbarTheme.thickness`，覆盖 Flutter 默认
/// 滚动行为为普通 `ListView` / `ScrollView` 生成的滚动条（`ScrollBar` 控件
/// 自身的热区检测见其类注释）。
WidgetStateProperty<double> scrollbarHoverThickness({
  double slim = kScrollBarSlimThickness,
  double expanded = kScrollBarExpandedThickness,
}) {
  return WidgetStateProperty.resolveWith((states) =>
      states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.dragged)
          ? expanded
          : slim);
}

/// A WinForm-style scroll bar (horizontal or vertical).
///
/// This is a thin wrapper around Flutter's [Scrollbar] styled to match the
/// classic WinForms look via [DesktopTokens]. It serves as the virtual-scroll
/// infrastructure for data-heavy controls like [DataGridView].
///
/// 宽度策略：静止时 [kScrollBarSlimThickness] 窄条；鼠标悬浮到滚动条上
/// （或拖动它）时恢复到 `thumbThickness`（默认 8）。悬浮检测由本组件自己做
/// （MouseRegion 命中贴边热区）——不依赖 Material 内部悬浮状态，行为确定。
class ScrollBar extends StatefulWidget {
  const ScrollBar({
    super.key,
    required this.controller,
    required this.child,
    this.orientation = ScrollBarOrientation.vertical,
    this.tokens,
    this.thumbThickness,
    this.thumbVisibility = false,
  });

  /// The scroll controller of the scrollable child.
  final ScrollController controller;

  /// The scrollable content.
  final Widget child;

  /// Whether this is a horizontal or vertical scroll bar.
  final ScrollBarOrientation orientation;

  /// Token override.
  final DesktopTokens? tokens;

  /// 悬浮 / 拖动时的滚动条宽度；静止时自动收窄。默认 8。
  final double? thumbThickness;

  /// Whether the scrollbar thumb is always visible.
  /// Defaults to `false` (thumb appears only during scrolling).
  final bool thumbVisibility;

  @override
  State<ScrollBar> createState() => _ScrollBarState();
}

class _ScrollBarState extends State<ScrollBar> {
  bool _overBar = false;
  Size _boxSize = Size.zero;

  double get _expanded =>
      widget.thumbThickness ?? kScrollBarExpandedThickness;
  double get _slim =>
      _expanded < kScrollBarSlimThickness ? _expanded : kScrollBarSlimThickness;

  void _updateHover(Offset local) {
    // 热区比展开宽度再宽几像素，鼠标靠近贴边缘即可触发，无需精确瞄准。
    final band = _expanded + 4;
    final over = widget.orientation == ScrollBarOrientation.vertical
        ? local.dx >= _boxSize.width - band
        : local.dy >= _boxSize.height - band;
    if (over != _overBar) setState(() => _overBar = over);
  }

  @override
  Widget build(BuildContext context) {
    final t =
        widget.tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    return LayoutBuilder(builder: (context, c) {
      final size = c.biggest;
      final trackable = widget.orientation == ScrollBarOrientation.vertical
          ? size.width.isFinite
          : size.height.isFinite;
      if (trackable) _boxSize = size;
      return MouseRegion(
        onHover:
            trackable && _boxSize.isFinite ? (e) => _updateHover(e.localPosition) : null,
        onExit: (_) {
          if (_overBar) setState(() => _overBar = false);
        },
        child: ScrollbarTheme(
          data: ScrollbarThemeData(
            thumbColor: WidgetStatePropertyAll(t.borderColor),
            trackColor: WidgetStatePropertyAll(t.controlColor),
            trackBorderColor: WidgetStatePropertyAll(t.borderColor),
          ),
          child: Scrollbar(
            controller: widget.controller,
            thickness: _overBar ? _expanded : _slim,
            thumbVisibility: widget.thumbVisibility,
            child: widget.child,
          ),
        ),
      );
    });
  }
}

/// A standalone scroll bar thumb that can be placed independently (e.g.
/// attached to a virtualised list that does not use a [ScrollView]).
///
/// This is the WinForms-style "free-standing" scroll bar.
class StandaloneScrollBar extends StatefulWidget {
  const StandaloneScrollBar({
    super.key,
    required this.orientation,
    required this.value,
    required this.min,
    required this.max,
    required this.extent,
    this.onChanged,
    this.tokens,
    this.enabled = true,
  });

  /// Horizontal or vertical.
  final ScrollBarOrientation orientation;

  /// Current scroll position.
  final double value;

  /// Minimum scroll value.
  final double min;

  /// Maximum scroll value.
  final double max;

  /// The visible extent (viewport size).
  final double extent;

  /// Called when the user drags the thumb.
  final ValueChanged<double>? onChanged;

  /// Token override.
  final DesktopTokens? tokens;

  /// Whether the scroll bar is interactive.
  final bool enabled;

  @override
  State<StandaloneScrollBar> createState() => _StandaloneScrollBarState();
}

class _StandaloneScrollBarState extends State<StandaloneScrollBar> {
  bool _dragging = false;

  double get _range => widget.max - widget.min;

  double get _thumbFraction {
    if (_range <= 0) return 1.0;
    return (widget.extent / (_range + widget.extent)).clamp(0.05, 1.0);
  }

  double get _positionFraction {
    if (_range <= 0) return 0.0;
    return ((widget.value - widget.min) / _range).clamp(0.0, 1.0);
  }

  void _handleDragStart(DragStartDetails _) =>
      setState(() => _dragging = true);

  void _handleDragEnd(DragEndDetails _) =>
      setState(() => _dragging = false);

  void _handleDragUpdate(DragUpdateDetails details, double trackLength) {
    if (!widget.enabled) return;
    final thumbLength = trackLength * _thumbFraction;
    final usable = trackLength - thumbLength;
    if (usable <= 0) return;
    final delta = widget.orientation == ScrollBarOrientation.vertical
        ? details.delta.dy
        : details.delta.dx;
    final fractionDelta = delta / usable;
    final newValue =
        (widget.value + fractionDelta * _range).clamp(widget.min, widget.max);
    widget.onChanged?.call(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens ??
        TokenScope.maybeOf(context) ??
        DesktopTokens.winForm;
    final isVertical = widget.orientation == ScrollBarOrientation.vertical;

    return LayoutBuilder(
      builder: (context, constraints) {
        final trackLength =
            isVertical ? constraints.maxHeight : constraints.maxWidth;
        final thumbLength = trackLength * _thumbFraction;
        final offset = _positionFraction * (trackLength - thumbLength);

        return GestureDetector(
          onVerticalDragStart: isVertical ? _handleDragStart : null,
          onVerticalDragUpdate: isVertical
              ? (d) => _handleDragUpdate(d, trackLength)
              : null,
          onVerticalDragEnd: isVertical ? _handleDragEnd : null,
          onHorizontalDragStart: !isVertical ? _handleDragStart : null,
          onHorizontalDragUpdate: !isVertical
              ? (d) => _handleDragUpdate(d, trackLength)
              : null,
          onHorizontalDragEnd: !isVertical ? _handleDragEnd : null,
          child: Container(
            color: t.controlColor,
            child: Stack(
              children: [
                Positioned(
                  left: isVertical ? 0 : offset,
                  top: isVertical ? offset : 0,
                  right: isVertical ? 0 : null,
                  bottom: isVertical ? null : 0,
                  width: isVertical ? null : thumbLength,
                  height: isVertical ? thumbLength : null,
                  child: Container(
                    color: _dragging
                        ? t.controlPressedColor
                        : (widget.enabled
                            ? t.borderColor
                            : t.controlDisabledColor),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
