import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// A WinForm-style track bar (slider).
///
/// Renders a horizontal or vertical slider with tick marks.
class TrackBar extends StatefulWidget {
  const TrackBar({
    super.key,
    required this.value,
    this.onChanged,
    this.min = 0.0,
    this.max = 100.0,
    this.divisions,
    this.orientation = Axis.horizontal,
    this.tokens,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
  });

  /// Current value.
  final double value;

  /// Called when the user drags the thumb.
  final ValueChanged<double>? onChanged;

  /// Minimum value.
  final double min;

  /// Maximum value.
  final double max;

  /// Number of discrete divisions. When `null`, the slider is continuous.
  final int? divisions;

  /// Orientation of the track.
  final Axis orientation;

  /// Token override.
  final DesktopTokens? tokens;

  /// Focus node for keyboard navigation.
  final FocusNode? focusNode;

  /// Whether the track bar should focus itself when first built.
  final bool autofocus;

  /// Whether the track bar is interactive.
  final bool enabled;

  @override
  State<TrackBar> createState() => _TrackBarState();
}

class _TrackBarState extends State<TrackBar> {
  late final FocusNode _focusNode;
  late final bool _ownsFocusNode;

  @override
  void initState() {
    super.initState();
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t =
        widget.tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    final isHorizontal = widget.orientation == Axis.horizontal;

    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      child: SizedBox(
        width: isHorizontal ? null : t.controlHeight,
        height: isHorizontal ? t.controlHeight : null,
        child: SliderTheme(
          data: SliderThemeData(
            trackHeight: 2.0,
            activeTrackColor: widget.enabled
                ? t.primaryColor
                : t.controlDisabledColor,
            inactiveTrackColor: t.borderColor,
            thumbColor: widget.enabled
                ? t.primaryColor
                : t.controlDisabledColor,
            overlayColor: t.primaryColor.withValues(alpha: 0.12),
            activeTickMarkColor: t.borderColor,
            inactiveTickMarkColor: t.borderColor,
            tickMarkShape: widget.divisions != null
                ? const RoundSliderTickMarkShape(tickMarkRadius: 2.0)
                : SliderTickMarkShape.noTickMark,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          ),
          child: Slider(
            value: widget.value.clamp(widget.min, widget.max),
            min: widget.min,
            max: widget.max,
            divisions: widget.divisions,
            onChanged: widget.enabled ? widget.onChanged : null,
            autofocus: false, // already handled by Focus
          ),
        ),
      ),
    );
  }
}
