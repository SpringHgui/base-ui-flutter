import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// A compact search input with a leading icon, text field, and clear button.
///
/// All visual values (height, border, radius, colors) are driven by
/// [DesktopTokens] — no hard-coded colors or font sizes.
class SearchInput extends StatefulWidget {
  const SearchInput({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText = '搜索...',
    this.onChanged,
    this.onSubmitted,
    this.onCleared,
    this.icon = Icons.search,
    this.tokens,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onCleared;
  final IconData icon;
  final DesktopTokens? tokens;

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final bool _ownsController;
  late final bool _ownsFocusNode;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _ownsFocusNode = widget.focusNode == null;
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _controller.addListener(_onTextChange);
  }

  void _onTextChange() {
    final has = _controller.text.isNotEmpty;
    if (has != _hasText) {
      setState(() => _hasText = has);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChange);
    if (_ownsController) _controller.dispose();
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onCleared?.call();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    final borderColor = _focusNode.hasFocus ? t.primaryColor : t.borderColor;

    return Container(
      height: t.controlHeight - 2,
      decoration: BoxDecoration(
        color: t.surfaceColor,
        border: Border.all(color: borderColor, width: t.borderWidth),
        borderRadius: BorderRadius.circular(t.cornerRadius),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: t.compactSpacing),
            child: Icon(widget.icon, size: 14, color: t.mutedForegroundColor),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              style: TextStyle(
                fontFamily: t.fontFamily,
                fontSize: t.fontSize,
                color: t.foregroundColor,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  fontFamily: t.fontFamily,
                  fontSize: t.fontSize,
                  color: t.mutedForegroundColor,
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_hasText)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _clear,
              child: Padding(
                padding: EdgeInsets.only(right: t.compactSpacing),
                child: Icon(Icons.close, size: 14, color: t.mutedForegroundColor),
              ),
            ),
        ],
      ),
    );
  }
}
