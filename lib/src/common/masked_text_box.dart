import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// A WinForm-style masked text box.
///
/// Restricts user input to a pattern defined by [mask]. Mask characters:
///
/// | Char | Meaning |
/// |------|---------|
/// | `0`  | Digit (required) |
/// | `9`  | Digit or space (optional) |
/// | `#`  | Digit, space, or sign (optional) |
/// | `L`  | Letter (required) |
/// | `?`  | Letter (optional) |
/// | `A`  | Alphanumeric (required) |
/// | `a`  | Alphanumeric (optional) |
/// | `&`  | Any character (required) |
/// | `C`  | Any character (optional) |
///
/// All other characters in the mask are treated as literals.
class MaskedTextBox extends StatefulWidget {
  const MaskedTextBox({
    super.key,
    required this.mask,
    this.controller,
    this.focusNode,
    this.hint,
    this.tokens,
    this.onChanged,
    this.enabled = true,
  });

  /// The input mask pattern.
  final String mask;

  /// Controls the text being edited.
  final TextEditingController? controller;

  /// Focus node for keyboard navigation.
  final FocusNode? focusNode;

  /// Placeholder shown while the field is empty.
  final String? hint;

  /// Token override.
  final DesktopTokens? tokens;

  /// Called when the text changes.
  final ValueChanged<String>? onChanged;

  /// Whether the input is editable.
  final bool enabled;

  @override
  State<MaskedTextBox> createState() => _MaskedTextBoxState();
}

class _MaskedTextBoxState extends State<MaskedTextBox> {
  late final FocusNode _focusNode;
  late final bool _ownsFocusNode;
  late final TextEditingController _controller;
  late final bool _ownsController;

  // Pre-compiled patterns shared by every call to _matchesMask — creating
  // a RegExp per character per keystroke would needlessly churn memory.
  static final RegExp _digitRe = RegExp(r'[0-9]');
  static final RegExp _digitSpaceRe = RegExp(r'[0-9 ]');
  static final RegExp _digitSpaceSignRe = RegExp(r'[0-9 +\-]');
  static final RegExp _letterRe = RegExp(r'[a-zA-Z]');
  static final RegExp _letterSpaceRe = RegExp(r'[a-zA-Z ]');
  static final RegExp _alphanumericRe = RegExp(r'[a-zA-Z0-9]');
  static final RegExp _alphanumericSpaceRe = RegExp(r'[a-zA-Z0-9 ]');

  @override
  void initState() {
    super.initState();
    _ownsFocusNode = widget.focusNode == null;
    _ownsController = widget.controller == null;
    _focusNode = widget.focusNode ?? FocusNode();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (_ownsFocusNode) _focusNode.dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  String _applyMask(String input) {
    final buffer = StringBuffer();
    int inputIdx = 0;
    for (int i = 0; i < widget.mask.length && inputIdx <= input.length; i++) {
      final m = widget.mask[i];
      if (_isMaskChar(m)) {
        if (inputIdx < input.length) {
          final ch = input[inputIdx];
          if (_matchesMask(m, ch)) {
            buffer.write(ch);
          }
          inputIdx++;
        }
      } else {
        buffer.write(m);
        if (inputIdx < input.length && input[inputIdx] == m) {
          inputIdx++;
        }
      }
    }
    return buffer.toString();
  }

  bool _isMaskChar(String ch) {
    return '09#L?Aa&C'.contains(ch);
  }

  bool _matchesMask(String mask, String ch) {
    return switch (mask) {
      '0' => _digitRe.hasMatch(ch),
      '9' => _digitSpaceRe.hasMatch(ch),
      '#' => _digitSpaceSignRe.hasMatch(ch),
      'L' => _letterRe.hasMatch(ch),
      '?' => _letterSpaceRe.hasMatch(ch),
      'A' => _alphanumericRe.hasMatch(ch),
      'a' => _alphanumericSpaceRe.hasMatch(ch),
      '&' => true,
      'C' => true,
      _ => false,
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens ??
        TokenScope.maybeOf(context) ??
        DesktopTokens.winForm;
    // isDense 会让 InputDecorator 容器塌缩到行高并贴顶,这里用精确的垂直
    // padding 把内容区垫到与控件等高,文字即垂直居中(style height:1.0 时
    // 行高恰好等于 fontSize)。
    final double padV = (t.controlHeight - t.fontSize) / 2;

    return SizedBox(
      height: t.controlHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: widget.enabled ? t.surfaceColor : t.controlDisabledColor,
          border: Border.all(color: t.borderColor, width: t.borderWidth),
          borderRadius: BorderRadius.circular(t.cornerRadius),
        ),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          enabled: widget.enabled,
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
            hintText: widget.hint,
            hintStyle: TextStyle(
              fontFamily: t.fontFamily,
              fontSize: t.fontSize,
              color: t.disabledForegroundColor,
            ),
            isDense: true,
            visualDensity: VisualDensity.standard,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: t.controlPaddingX,
              vertical: padV < 0 ? 0 : padV,
            ),
          ),
          inputFormatters: [
            TextInputFormatter.withFunction((oldValue, newValue) {
              final masked = _applyMask(newValue.text);
              return TextEditingValue(
                text: masked,
                selection: TextSelection.collapsed(
                  offset: masked.length,
                ),
              );
            }),
          ],
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}
