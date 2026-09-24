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

  /// Solid **accent** button: [DesktopTokens.primaryColor] fill with
  /// [DesktopTokens.accentForegroundColor] text. Use for the single primary
  /// action in a dialog or panel (OK / Apply / Save).
  primary,
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
/// - **按下(pointer down)即 `requestFocus`**,显示焦点边框,即使随后按住拖出
///   按钮外再松开(tap 取消)也保留焦点;这与桌面按钮一致;
/// - **完整点击**(按下 + 松开都在按钮内)额外触发 `onPressed` 回调;
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
/// 手写 `GestureDetector + MouseRegion + Focus`,按下(pointer down)即请求焦点,
/// 与桌面按钮一致;只有**完整点击**(按下 + 松手都在按钮内)才触发 `onPressed`。
class _ButtonState extends State<Button> {
  /// 下边框的加暗量(~10.5% 黑),见 build 里的说明。
  static const Color _bottomShade = Color(0x1B000000);

  late final FocusNode _focusNode;
  late final bool _ownsFocusNode;

  bool _hover = false;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();
    // 焦点进出不会自动触发 rebuild,而 build 里读的 _focusNode.hasFocus
    // 又不会自己刷新;不监听的话,键盘 Tab 聚焦后聚焦边框 / 背景永远画不出来。
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
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
    final primary = widget.variant == ButtonVariant.primary;

    // 背景:ghost 透明 + 悬停/按下混合;solid 用 buttonFaceColor,
    // hover / pressed 由叠加色现算(与 Input 一致) —— 这样主题只要给一个
    // 面色,hover/pressed 自动明暗自适应,不会出现"面色改了但悬停色还是旧的"
    // 这种半截配色。primary 强调色实底。
    final Color face = t.buttonFaceColor;
    final Color bg;
    if (ghost) {
      bg = _pressed
          ? Color.alphaBlend(t.pressedOverlayColor, t.controlColor)
          : _hover
              ? Color.alphaBlend(t.hoverOverlayColor, t.controlColor)
              : _focusNode.hasFocus
                  ? Color.alphaBlend(
                      t.primaryColor.withValues(alpha: 0.14), t.controlColor)
                  : Colors.transparent;
    } else if (primary) {
      // 实心色底上 hoverOverlay(约 4% 黑)几乎看不出来,故两级都取
      // pressedOverlay:hover 叠一层,按下再叠一层
      bg = disabled
          ? t.primaryColor.withValues(alpha: 0.45)
          : _pressed
          ? Color.alphaBlend(
              t.pressedOverlayColor,
              Color.alphaBlend(t.pressedOverlayColor, t.primaryColor),
            )
          : _hover
          ? Color.alphaBlend(t.pressedOverlayColor, t.primaryColor)
          : t.primaryColor;
    } else {
      bg = disabled
          ? t.controlDisabledColor
          : _pressed
          ? t.buttonPressedFaceColor
          : _hover
          ? t.buttonHoverFaceColor
          : face;
    }

    // 边框:ghost 无边框;primary 与底色同色(纯色块),聚焦时才露出描边;
    // solid 用按钮专用边色(比通用控件边线略深,贴合桌面按钮的"硬边"观感),
    // 聚焦时换成高亮色。热态 / 按下态跟着面色一起换色 —— 只换面不换边的话,
    // 蓝面配灰边会显出一条"没跟上"的轮廓。
    final Border? border;
    if (ghost) {
      // ghost 是「无边框」变体,但若完全不画聚焦边框,键盘 Tab 聚焦后看不出
      // 焦点落点。聚焦时补一圈强调色描边,常态用透明边框占位避免布局抖动。
      border = Border.all(
        color: _focusNode.hasFocus ? t.primaryColor : Colors.transparent,
        width: t.borderWidth,
      );
    } else if (primary) {
      border = Border.all(
        color: _focusNode.hasFocus ? t.foregroundColor : bg,
        width: t.borderWidth,
      );
    } else {
      final Color line;
      if (_focusNode.hasFocus) {
        line = t.primaryColor;
      } else if (disabled) {
        line = t.buttonBorderColor;
      } else if (_pressed) {
        line = t.buttonPressedBorderColor;
      } else if (_hover) {
        line = t.buttonHoverBorderColor;
      } else {
        line = t.buttonBorderColor;
      }
      // 下缘比上 / 左 / 右暗一档:桌面按钮(VCL / Aero)用底部暗边做 3D 观感。
      // 参考图实测这条比例恒定 —— 常态 #D0D0D0→#BABABA、悬浮
      // #0078D4→#006BBE,都是暗 ~10.5%,所以从当前边色现算,不加令牌。
      BorderSide side(Color c) => BorderSide(color: c, width: t.borderWidth);
      border = Border(
        top: side(line),
        left: side(line),
        right: side(line),
        bottom: side(Color.alphaBlend(_bottomShade, line)),
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
              : (_) {
                  _focusNode.requestFocus();
                  setState(() => _pressed = true);
                },
          onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
          onTapCancel: disabled ? null : () => setState(() => _pressed = false),
          onTap: disabled ? null : _handlePressed,
          child: Container(
            // 高度取 buttonHeight(桌面按钮比单行编辑框矮一档,见 DesktopTokens);
            // 仍是最小高度而非固定高度:child(如图标+文字列)更高时按钮自然撑高,
            // 避免溢出。
            //
            // 纯文字按钮(无自定义 child)再接受一个最小宽度:桌面对话框把
            // 「确定 / 取消 / 上一步」摆在等宽的按钮列上,不会贴着字收紧
            // (Navicat 实测 73×24)。带 child 的按钮(图标按钮 / 工具条按钮)
            // 一律按内容自适应,免得窄工具栏被撑破。
            constraints: BoxConstraints(
              minHeight: t.buttonHeight,
              minWidth: widget.child == null ? t.buttonMinWidth : 0,
            ),
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
                color: primary
                    ? (disabled
                          ? t.accentForegroundColor.withValues(alpha: 0.6)
                          : t.accentForegroundColor)
                    : (disabled
                          ? t.disabledForegroundColor
                          : t.foregroundColor),
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
