import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// A WinForm-style single-line text box.
///
/// The editable surface, hairline border, and focused accent are all derived
/// from a [DesktopTokens] set; this widget carries no hard-coded visual code.
class Input extends StatefulWidget {
  const Input({
    super.key,
    this.controller,
    this.focusNode,
    this.hint,
    this.tokens,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.textInputAction,
    this.keyboardType,
  });

  /// Controls the text being edited.
  final TextEditingController? controller;

  /// Focus node for keyboard navigation.
  final FocusNode? focusNode;

  /// Placeholder shown while the field is empty.
  final String? hint;

  /// Token override for this input. Falls back to the enclosing [TokenScope],
  /// then to [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  /// Called when the text changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits (typically Enter).
  final ValueChanged<String>? onSubmitted;

  /// Whether the input is editable. When `false`, it renders disabled.
  final bool enabled;

  /// The action for the keyboard's submit button.
  final TextInputAction? textInputAction;

  /// The type of keyboard to show for editing.
  final TextInputType? keyboardType;

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  late final FocusNode _focusNode;
  late final TextEditingController _controller;
  late final bool _ownsFocusNode;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsFocusNode = widget.focusNode == null;
    _ownsController = widget.controller == null;
    _focusNode = widget.focusNode ?? FocusNode();
    _controller = widget.controller ?? TextEditingController();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    final focused = _focusNode.hasFocus;

    final borderColor =
        !widget.enabled ? t.borderColor : (focused ? t.primaryColor : t.borderColor);
    final fillColor = widget.enabled ? t.surfaceColor : t.controlDisabledColor;

    return SizedBox(
      height: t.controlHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fillColor,
          border: Border.all(color: borderColor, width: t.borderWidth),
          borderRadius: BorderRadius.circular(t.cornerRadius),
        ),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          enabled: widget.enabled,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          textInputAction: widget.textInputAction,
          keyboardType: widget.keyboardType,
          cursorColor: t.primaryColor,
          textAlignVertical: TextAlignVertical.center,
          style: TextStyle(
            fontFamily: t.fontFamily,
            fontSize: t.fontSize,
            color:
                widget.enabled ? t.foregroundColor : t.disabledForegroundColor,
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
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            contentPadding:
                EdgeInsets.symmetric(horizontal: t.controlPaddingX),
          ),
        ),
      ),
    );
  }
}
