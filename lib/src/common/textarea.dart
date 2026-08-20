import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// A multi-line plain-text input, styled like the single-line [Input] but
/// growing to multiple lines (the shadcn "Textarea").
///
/// The surface, hairline border and focused accent are derived from
/// [DesktopTokens]; no visual value is hard-coded.
class Textarea extends StatefulWidget {
  const Textarea({
    super.key,
    this.controller,
    this.focusNode,
    this.hint,
    this.tokens,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.minLines = 3,
    this.maxLines,
    this.autofocus = false,
    this.expands = false,
    this.style,
    this.showBorder = true,
  });

  /// Controls the text being edited.
  final TextEditingController? controller;

  /// Focus node for keyboard navigation.
  final FocusNode? focusNode;

  /// Placeholder shown while the field is empty.
  final String? hint;

  /// Token override; falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  /// Called when the text changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits (typically Ctrl+Enter).
  final ValueChanged<String>? onSubmitted;

  /// Whether the text area is editable.
  final bool enabled;

  /// Minimum number of visible lines.
  final int minLines;

  /// Maximum number of visible lines; `null` grows without bound.
  final int? maxLines;

  /// Whether the field should focus itself when first built.
  final bool autofocus;

  /// When `true`, the field expands to fill the available space (used by
  /// code editors). Requires [maxLines] to stay `null`.
  final bool expands;

  /// Overrides the text style (e.g. a monospace family for editors).
  /// Falls back to token-derived typography when `null`.
  final TextStyle? style;

  /// When `false`, the hairline border is skipped (for editors embedded in
  /// a panel that already draws its own surface).
  final bool showBorder;

  @override
  State<Textarea> createState() => _TextareaState();
}

class _TextareaState extends State<Textarea> {
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
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (_ownsFocusNode) _focusNode.dispose();
    if (_ownsController) _controller.dispose();
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

    final field = TextField(
      controller: _controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      minLines: widget.expands ? null : widget.minLines,
      maxLines: widget.expands ? null : (widget.maxLines ?? widget.minLines),
      expands: widget.expands,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      cursorColor: t.primaryColor,
      textAlignVertical: TextAlignVertical.top,
      style:
          widget.style ??
          TextStyle(
            fontFamily: t.fontFamily,
            fontSize: t.fontSize,
            color: widget.enabled
                ? t.foregroundColor
                : t.disabledForegroundColor,
            height: 1.4,
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
        contentPadding: EdgeInsets.symmetric(
          horizontal: t.controlPaddingX,
          vertical: t.compactSpacing * 1.5,
        ),
      ),
    );
    if (!widget.showBorder) return field;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: fillColor,
        border: Border.all(color: borderColor, width: t.borderWidth),
        borderRadius: BorderRadius.circular(t.cornerRadius),
      ),
      child: field,
    );
  }
}
