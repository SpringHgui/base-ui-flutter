import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// The orientation of a [ScrollBar].
enum ScrollBarOrientation { horizontal, vertical }

/// A WinForm-style scroll bar (horizontal or vertical).
///
/// This is a thin wrapper around Flutter's [Scrollbar] styled to match the
/// classic WinForms look via [DesktopTokens]. It serves as the virtual-scroll
/// infrastructure for data-heavy controls like [DataGridView].
class ScrollBar extends StatelessWidget {
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

  /// Override for the thumb thickness. Defaults to a token-derived value.
  final double? thumbThickness;

  /// Whether the scrollbar thumb is always visible.
  /// Defaults to `false` (thumb appears only during scrolling).
  final bool thumbVisibility;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    final thickness = thumbThickness ?? 8.0;

    return ScrollbarTheme(
      data: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(t.borderColor),
        trackColor: WidgetStatePropertyAll(t.controlColor),
        trackBorderColor: WidgetStatePropertyAll(t.borderColor),
      ),
      child: Scrollbar(
        controller: controller,
        thickness: thickness,
        thumbVisibility: thumbVisibility,
        child: child,
      ),
    );
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
