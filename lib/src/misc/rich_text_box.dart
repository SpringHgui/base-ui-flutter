import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// A WinForm-style rich text box.
///
/// Wraps Flutter's [EditableText] styled with [DesktopTokens] to provide
/// basic rich-text editing. For full RTF support a dedicated engine would
/// be needed; this implementation covers the common case of styled spans.
class RichTextBox extends StatefulWidget {
  const RichTextBox({
    super.key,
    this.controller,
    this.focusNode,
    this.tokens,
    this.enabled = true,
    this.minLines = 3,
    this.maxLines,
  });

  /// Controls the text being edited.
  final TextEditingController? controller;

  /// Focus node for keyboard navigation.
  final FocusNode? focusNode;

  /// Token override.
  final DesktopTokens? tokens;

  /// Whether the text box is editable.
  final bool enabled;

  /// Minimum visible lines.
  final int minLines;

  /// Maximum visible lines. `null` means unlimited.
  final int? maxLines;

  @override
  State<RichTextBox> createState() => _RichTextBoxState();
}

class _RichTextBoxState extends State<RichTextBox> {
  late final FocusNode _focusNode;
  late final bool _ownsFocusNode;
  late final TextEditingController _controller;
  late final bool _ownsController;

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

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens ??
        TokenScope.maybeOf(context) ??
        DesktopTokens.winForm;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: widget.enabled ? t.surfaceColor : t.controlDisabledColor,
        border: Border.all(color: t.borderColor, width: t.borderWidth),
        borderRadius: BorderRadius.circular(t.cornerRadius),
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        enabled: widget.enabled,
        readOnly: !widget.enabled,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        cursorColor: t.primaryColor,
        style: TextStyle(
          fontFamily: t.fontFamily,
          fontSize: t.fontSize,
          color: widget.enabled
              ? t.foregroundColor
              : t.disabledForegroundColor,
        ),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: EdgeInsets.all(t.compactSpacing),
        ),
      ),
    );
  }
}
