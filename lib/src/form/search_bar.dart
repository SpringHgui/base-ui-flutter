import 'package:flutter/material.dart';

import '../common/icon_button.dart';
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

/// 可展开的搜索框:收起时是一个放大镜按钮,点击展开为 [SearchInput];
/// 失焦且内容为空时自动收起(工具栏搜索场景)。
class ExpandableSearch extends StatefulWidget {
  const ExpandableSearch({
    super.key,
    this.controller,
    this.hintText = '搜索...',
    this.expandedWidth = 200,
    this.onChanged,
    this.onSubmitted,
    this.icon = Icons.search,
    this.tokens,
  });

  final TextEditingController? controller;
  final String hintText;

  /// 展开态输入框宽度。
  final double expandedWidth;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final IconData icon;
  final DesktopTokens? tokens;

  @override
  State<ExpandableSearch> createState() => _ExpandableSearchState();
}

class _ExpandableSearchState extends State<ExpandableSearch> {
  bool _expanded = false;
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    // 展开态下若清空内容并失去焦点,自动收起为放大镜
    if (!_focusNode.hasFocus && _controller.text.isEmpty && mounted) {
      setState(() => _expanded = false);
    }
  }

  void _expand() {
    setState(() => _expanded = true);
    // 展开后自动聚焦输入框
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _collapse() {
    // clear 不触发 onChanged,需手动通知父级清空过滤
    widget.onChanged?.call('');
    _controller.clear();
    setState(() => _expanded = false);
  }

  @override
  Widget build(BuildContext context) {
    final t =
        widget.tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    if (!_expanded) {
      return IconBtn(
        icon: widget.icon,
        iconSize: 18,
        color: t.foregroundColor,
        tooltip: widget.hintText,
        tokens: t,
        onTap: _expand,
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.expandedWidth,
          child: SearchInput(
            controller: _controller,
            focusNode: _focusNode,
            hintText: widget.hintText,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            onCleared: _collapse,
            tokens: t,
          ),
        ),
        const SizedBox(width: 2),
        IconBtn(
          icon: Icons.close,
          iconSize: 18,
          color: t.foregroundColor,
          tooltip: '收起',
          tokens: t,
          onTap: _collapse,
        ),
      ],
    );
  }
}
