import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// A one-time-password input: a row of single-character boxes driven by one
/// hidden text field (the shadcn "InputOTP").
///
/// The boxes, focus ring and disabled treatment are derived from
/// [DesktopTokens]; the core carries no hard-coded visual value.
class InputOtp extends StatefulWidget {
  const InputOtp({
    super.key,
    this.length = 6,
    this.onChanged,
    this.onCompleted,
    this.enabled = true,
    this.autofocus = false,
    this.tokens,
  });

  /// Number of digit slots (default 6).
  final int length;

  /// Called with the current text on every change.
  final ValueChanged<String>? onChanged;

  /// Called once the input reaches [length] characters.
  final ValueChanged<String>? onCompleted;

  final bool enabled;
  final bool autofocus;

  /// Token override; falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  @override
  State<InputOtp> createState() => _InputOtpState();
}

class _InputOtpState extends State<InputOtp> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode(debugLabel: 'InputOtp');

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted) setState(() {});
  }

  void _onTextChanged(String text) {
    setState(() {});
    widget.onChanged?.call(text);
    if (text.length == widget.length) {
      widget.onCompleted?.call(text);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens ??
        TokenScope.maybeOf(context) ??
        DesktopTokens.winForm;

    final text = _controller.text;
    final focused = _focusNode.hasFocus;
    // The slot after the last entered character is the "active" one.
    final activeIndex = focused ? text.length.clamp(0, widget.length - 1) : -1;

    return GestureDetector(
      onTap: widget.enabled ? () => _focusNode.requestFocus() : null,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < widget.length; i++) ...[
                if (i > 0) SizedBox(width: t.compactSpacing),
                _OtpBox(
                  character: i < text.length ? text[i] : '',
                  isActive: i == activeIndex,
                  enabled: widget.enabled,
                  tokens: t,
                ),
              ],
            ],
          ),
          // Invisible text field that owns the actual input session.
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  autofocus: widget.autofocus,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(widget.length),
                  ],
                  onChanged: _onTextChanged,
                  style: TextStyle(fontSize: t.fontSize),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.character,
    required this.isActive,
    required this.enabled,
    required this.tokens,
  });

  final String character;
  final bool isActive;
  final bool enabled;
  final DesktopTokens tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    final side = t.controlHeight * 1.2;
    final borderColor = !enabled
        ? t.borderColor
        : (isActive ? t.ringColor : t.borderColor);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: side,
      height: side,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: enabled ? t.surfaceColor : t.controlDisabledColor,
        border: Border.all(
          color: borderColor,
          width: isActive ? t.ringWidth : t.borderWidth,
        ),
        borderRadius: BorderRadius.circular(t.cornerRadius),
      ),
      child: Text(
        character,
        style: TextStyle(
          fontFamily: t.fontFamily,
          fontSize: t.fontSize * 1.1,
          fontWeight: FontWeight.w600,
          color: enabled ? t.foregroundColor : t.disabledForegroundColor,
          height: 1.0,
        ),
      ),
    );
  }
}
