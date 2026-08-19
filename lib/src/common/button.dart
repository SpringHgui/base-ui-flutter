import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// Visual style of a [Button].
enum ButtonVariant {
  /// Solid WinForm-style push button: a hairline border and a button-face
  /// fill that lightens on hover and darkens on press. This is the default
  /// and matches the classic desktop look.
  solid,

  /// Borderless "ghost" button: a transparent background with a subtle hover
  /// and pressed overlay blended over the surrounding surface. Ideal for
  /// toolbar / ribbon icon buttons that live inside a borderless
  /// [ButtonGroup].
  ghost,
}

/// A WinForm-style push button.
///
/// The core is headless: hover, pressed, focused, and disabled visuals are
/// all derived from a [DesktopTokens] set, so no color, font, or spacing is
/// hard-coded here.
///
/// Provide either [text] (a plain label) or [child] (arbitrary content such
/// as an icon + caption column). When both are given, [child] is shown and
/// [text] is kept only as a semantic label.
///
/// Focus behavior (WinForms convention):
/// - 按下(pointer down)只显示 pressed 视觉,**不获取焦点**;
/// - **完整点击**(按下 + 松开都在按钮内)才 `requestFocus`,显示焦点边框;
/// - 长按后移走鼠标(tap 取消)不会获取焦点;
/// - Tab 键导航聚焦后同样显示焦点边框。
class Button extends StatefulWidget {
  const Button({
    super.key,
    this.text,
    this.child,
    this.onPressed,
    this.tokens,
    this.variant = ButtonVariant.solid,
    this.focusNode,
    this.autofocus = false,
  }) : assert(
          text != null || child != null,
          'Button requires either `text` or `child`.',
        );

  /// Semantic label for the button. Rendered as the visual content unless
  /// [child] is provided, in which case it is kept for accessibility only.
  final String? text;

  /// Arbitrary visual content. When non-null, it replaces the default
  /// [Text] built from [text] — use this for icon buttons or rich layouts.
  final Widget? child;

  /// Called when the button is activated. When `null`, the button is disabled.
  final VoidCallback? onPressed;

  /// Token override for this button. Falls back to the enclosing [TokenScope],
  /// then to [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  /// Visual style of the button. Defaults to [ButtonVariant.solid].
  final ButtonVariant variant;

  /// Focus node for keyboard navigation. When null, the button owns one.
  final FocusNode? focusNode;

  /// Whether the button should focus itself when first built.
  final bool autofocus;

  @override
  State<Button> createState() => _ButtonState();
}

/// [Button] 的 State:管理 hover / pressed / focus 状态。
///
/// 不使用 `TextButton`(其 InkWell `canRequestFocus` 会在按下瞬间请求焦点,
/// 导致"长按移走鼠标"也显示焦点边框),改为
/// `GestureDetector + MouseRegion + Focus` 手绘,聚焦时机完全可控。
class _ButtonState extends State<Button> {
  late final FocusNode _focusNode;
  late final bool _ownsFocusNode;

  bool _hover = false;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  /// 完整点击(松开)才触发:请求焦点 + 调用用户回调。
  void _handlePressed() {
    _focusNode.requestFocus();
    widget.onPressed?.call();
  }

  /// 键盘激活(焦点在按钮上按 Enter / Space)。
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || widget.onPressed == null) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.space) {
      _handlePressed();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final t =
        widget.tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    final disabled = widget.onPressed == null;
    final ghost = widget.variant == ButtonVariant.ghost;

    // 背景:ghost 透明 + 悬停/按下混合;solid 实色
    final Color bg;
    if (ghost) {
      bg = _pressed
          ? Color.alphaBlend(t.pressedOverlayColor, t.controlColor)
          : _hover
              ? Color.alphaBlend(t.hoverOverlayColor, t.controlColor)
              : Colors.transparent;
    } else {
      bg = disabled
          ? t.controlDisabledColor
          : _pressed
              ? t.controlPressedColor
              : _hover
                  ? t.controlHoverColor
                  : t.controlColor;
    }

    // 边框:ghost 无边框;solid 聚焦时用高亮色
    final Border? border;
    if (ghost) {
      border = null;
    } else {
      border = Border.all(
        color: _focusNode.hasFocus ? t.primaryColor : t.borderColor,
        width: t.borderWidth,
      );
    }

    final content = widget.child ?? Text(widget.text ?? '');

    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      onKeyEvent: _handleKeyEvent,
      child: MouseRegion(
        onEnter: disabled ? null : (_) => setState(() => _hover = true),
        onExit: disabled ? null : (_) => setState(() => _hover = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: disabled
              ? null
              : (_) => setState(() => _pressed = true),
          onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: disabled ? null : _handlePressed,
          child: Container(
            // 最小高度 = controlHeight,不强制固定高度:child(如图标+文字列)
            // 更高时按钮自然撑高,避免溢出
            constraints: BoxConstraints(minHeight: t.controlHeight),
            padding: EdgeInsets.symmetric(horizontal: t.controlPaddingX),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              border: border,
              borderRadius: BorderRadius.circular(t.cornerRadius),
            ),
            child: DefaultTextStyle(
              style: TextStyle(
                fontFamily: t.fontFamily,
                fontSize: t.fontSize,
                color: disabled ? t.disabledForegroundColor : t.foregroundColor,
                height: 1.0,
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
