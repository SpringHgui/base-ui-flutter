import 'package:flutter/material.dart';

import '../common/button.dart';
import '../common/input.dart';
import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';
import 'dialog_box.dart';

/// A modal single-line text prompt: message + [Input] + OK / Cancel,
/// the WinForm counterpart of a "password / value required" dialog.
///
/// [show] resolves with the entered text, or `null` when dismissed
/// (Cancel / title-bar close / Escape). With [password] the field renders
/// bullets with a reveal toggle and OK stays disabled until something is
/// typed — callers can rely on a non-null result being non-empty.
///
/// ```dart
/// final pwd = await InputDialog.show(
///   context,
///   title: '输入密码',
///   message: '连接「生产库」需要密码:',
///   password: true,
///   okText: '连接',
/// );
/// if (pwd == null) return; // 用户取消
/// ```
class InputDialog extends StatefulWidget {
  const InputDialog({
    super.key,
    required this.title,
    this.message,
    this.initialValue = '',
    this.password = false,
    this.okText,
    this.cancelText,
    this.width,
    this.tokens,
  });

  /// Title bar text.
  final String title;

  /// Prompt line above the input; null hides it.
  final String? message;

  final String initialValue;

  /// Obscure input as a password field.
  final bool password;

  final String? okText;
  final String? cancelText;

  /// Surface width; defaults to a compact prompt width.
  final double? width;

  final DesktopTokens? tokens;

  static Future<String?> show(
    BuildContext context, {
    required String title,
    String? message,
    String initialValue = '',
    bool password = false,
    String? okText,
    String? cancelText,
    double? width,
    DesktopTokens? tokens,
  }) =>
      showDialog<String>(
        context: context,
        builder: (_) => InputDialog(
          title: title,
          message: message,
          initialValue: initialValue,
          password: password,
          okText: okText,
          cancelText: cancelText,
          width: width,
          tokens: tokens,
        ),
      );

  @override
  State<InputDialog> createState() => _InputDialogState();
}

class _InputDialogState extends State<InputDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialValue);
  late final FocusNode _focusNode = FocusNode();

  /// 密码模式下空输入禁止提交(show 的契约:非 null 即非空)
  bool _okEnabled = true;

  @override
  void initState() {
    super.initState();
    _okEnabled = !(widget.password && widget.initialValue.isEmpty);
    // 弹层路由动画结束后抢焦点,打开即可直接输入
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    final enabled = !(widget.password && value.isEmpty);
    if (enabled != _okEnabled) setState(() => _okEnabled = enabled);
  }

  void _confirm() {
    if (!_okEnabled) return;
    Navigator.of(context).pop(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens ??
        TokenScope.maybeOf(context) ??
        DesktopTokens.winForm;
    return DialogBox(
      title: widget.title,
      width: widget.width ?? 360,
      tokens: t,
      onClose: () => Navigator.of(context).pop(),
      footer: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Button(
              text: widget.okText ?? 'OK',
              variant: ButtonVariant.primary,
              onPressed: _okEnabled ? _confirm : null,
            ),
            const SizedBox(width: 8),
            Button(
              text: widget.cancelText ?? 'Cancel',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.message != null) ...[
              Text(
                widget.message!,
                style: TextStyle(
                  fontFamily: t.fontFamily,
                  fontSize: t.fontSize,
                  color: t.foregroundColor,
                  decoration: TextDecoration.none,
                ),
              ),
              SizedBox(height: t.compactSpacing * 2),
            ],
            Input(
              controller: _controller,
              focusNode: _focusNode,
              obscureText: widget.password,
              obscureToggle: widget.password,
              onChanged: _onChanged,
              onSubmitted: (_) => _confirm(),
              tokens: t,
            ),
          ],
        ),
      ),
    );
  }
}
