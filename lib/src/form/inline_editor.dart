import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../common/input.dart';
import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// 单元格内联编辑器:构建后自动聚焦,Enter / 失焦提交,Esc 取消。
///
/// 防双触发:提交或取消后失焦回调不再二次提交。视觉完全由
/// [DesktopTokens] 驱动(内部复用 [Input])。
class InlineEditor extends StatefulWidget {
  const InlineEditor({
    super.key,
    required this.initialValue,
    required this.onCommit,
    this.onChanged,
    this.onCancel,
    this.height,
    this.tokens,
    this.contentPadding,
  });

  /// 初始文本。
  final String initialValue;

  /// 提交回调(Enter / 失焦)。
  final ValueChanged<String> onCommit;

  /// 每次文本变化时回调(可用于实时标记 dirty 等)。
  final ValueChanged<String>? onChanged;

  /// 取消回调(Esc)。
  final VoidCallback? onCancel;

  /// 编辑框高度;默认 [DesktopTokens.controlHeight]。
  final double? height;

  /// Token 覆盖;回退到外层 [TokenScope],最后 [DesktopTokens.winForm]。
  final DesktopTokens? tokens;

  /// 内边距覆盖;传 [EdgeInsets.zero] 可消除与外层容器的双重间距。
  final EdgeInsetsGeometry? contentPadding;

  @override
  State<InlineEditor> createState() => _InlineEditorState();
}

class _InlineEditorState extends State<InlineEditor> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialValue);
  late final FocusNode _focusNode = FocusNode();

  /// 防止提交/取消后失焦回调二次触发。
  bool _finished = false;

  /// 是否已按 Esc 取消(取消后失焦不再提交)。
  bool _cancelled = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    // 构建完成后主动聚焦输入框,直接进入可输入状态
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _onTextChanged() {
    widget.onChanged?.call(_controller.text);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _finish() {
    if (_finished || _cancelled) return;
    _finished = true;
    widget.onCommit(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final t =
        widget.tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    return Focus(
      // Esc 取消编辑(按键沿焦点链上冒,输入框聚焦时也能拦截)
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          _cancelled = true;
          widget.onCancel?.call();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      // 点击别处失焦 → 提交
      onFocusChange: (focused) {
        if (!focused) _finish();
      },
      child: SizedBox(
        height: widget.height ?? t.controlHeight,
        child: Input(
          controller: _controller,
          focusNode: _focusNode,
          tokens: t,
          contentPadding: widget.contentPadding,
          onSubmitted: (_) => _finish(),
        ),
      ),
    );
  }
}
