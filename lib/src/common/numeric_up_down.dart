import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// A WinForm-style numeric up/down control.
///
/// Displays a numeric value with up and down arrow buttons for incrementing
/// and decrementing.
class NumericUpDown extends StatefulWidget {
  const NumericUpDown({
    super.key,
    required this.value,
    this.onChanged,
    this.min = 0,
    this.max = 100,
    this.step = 1,
    this.decimals = 0,
    this.tokens,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
  });

  /// The current numeric value.
  final double value;

  /// Called when the value changes.
  final ValueChanged<double>? onChanged;

  /// Minimum allowed value.
  final double min;

  /// Maximum allowed value.
  final double max;

  /// Increment / decrement step.
  final double step;

  /// Number of decimal places to display.
  final int decimals;

  /// Token override.
  final DesktopTokens? tokens;

  /// Focus node for keyboard navigation.
  final FocusNode? focusNode;

  /// Whether the control should focus itself when first built.
  final bool autofocus;

  /// Whether the control is interactive.
  final bool enabled;

  @override
  State<NumericUpDown> createState() => _NumericUpDownState();
}

class _NumericUpDownState extends State<NumericUpDown> {
  late final FocusNode _focusNode;
  late final bool _ownsFocusNode;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();
    _controller = TextEditingController(text: _format(widget.value));
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant NumericUpDown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _controller.text = _format(widget.value);
    }
  }

  String _format(double value) => value.toStringAsFixed(widget.decimals);

  double _clamp(double value) => value.clamp(widget.min, widget.max);

  void _increment() {
    if (!widget.enabled) return;
    final next = _clamp(widget.value + widget.step);
    widget.onChanged?.call(next);
  }

  void _decrement() {
    if (!widget.enabled) return;
    final next = _clamp(widget.value - widget.step);
    widget.onChanged?.call(next);
  }

  void _commitText() {
    final parsed = double.tryParse(_controller.text);
    if (parsed != null) {
      widget.onChanged?.call(_clamp(parsed));
    } else {
      _controller.text = _format(widget.value);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (_ownsFocusNode) _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t =
        widget.tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    final focused = _focusNode.hasFocus;

    final borderColor = !widget.enabled
        ? t.borderColor
        : (focused ? t.primaryColor : t.borderColor);
    final fillColor = widget.enabled ? t.surfaceColor : t.controlDisabledColor;
    final buttonWidth = t.controlHeight * 0.75;

    return SizedBox(
      height: t.controlHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fillColor,
          border: Border.all(color: borderColor, width: t.borderWidth),
          borderRadius: BorderRadius.circular(t.cornerRadius),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: widget.autofocus,
                enabled: widget.enabled,
                onSubmitted: (_) => _commitText(),
                onEditingComplete: _commitText,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                cursorColor: t.primaryColor,
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(
                  fontFamily: t.fontFamily,
                  fontSize: t.fontSize,
                  color: widget.enabled
                      ? t.foregroundColor
                      : t.disabledForegroundColor,
                  height: 1.0,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: t.controlPaddingX),
                ),
              ),
            ),
            _buildButton(
              icon: Icons.arrow_drop_up,
              onTap: _increment,
              tokens: t,
              width: buttonWidth,
            ),
            _buildButton(
              icon: Icons.arrow_drop_down,
              onTap: _decrement,
              tokens: t,
              width: buttonWidth,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required VoidCallback onTap,
    required DesktopTokens tokens,
    required double width,
  }) {
    return SizedBox(
      width: width,
      child: InkWell(
        onTap: widget.enabled ? onTap : null,
        child: Icon(
          icon,
          size: tokens.fontSize + 4,
          color: widget.enabled
              ? tokens.foregroundColor
              : tokens.disabledForegroundColor,
        ),
      ),
    );
  }
}
