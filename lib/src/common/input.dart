import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';
import '../menus/text_box_context_menu.dart';

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
    this.obscureText = false,
    this.obscureToggle = false,
    this.selectAllOnFocus,
    this.contentPadding,
    this.textAlign,
    this.height,
    this.trailing,
    this.showBorder = true,
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

  /// Whether to hide the text (password field).
  final bool obscureText;

  /// When `true` (and [obscureText] is also `true`), a self-drawn eye toggle
  /// is rendered inside the field's right edge so the user can switch between
  /// masked dots and plaintext. No ripple, no click animation.
  final bool obscureToggle;

  /// Whether to select all text when the field gains focus.
  ///
  /// `null` follows the platform default (desktop: true → 聚焦即全选;
  /// Android/iOS: false). Pass `false` when the field should keep its current
  /// cursor position on focus instead (e.g. inline cell editors).
  final bool? selectAllOnFocus;

  /// Override the default content padding inside the input field.
  /// When null, defaults to
  /// `EdgeInsets.symmetric(horizontal: t.controlPaddingX, vertical: (t.controlHeight - t.fontSize) / 2)`
  /// so that the text is vertically centered.
  final EdgeInsetsGeometry? contentPadding;

  /// Text alignment of the field content (e.g. center for a page-number box).
  /// When null, defaults to [TextAlign.start].
  final TextAlign? textAlign;

  /// 控件高度。当 null 时取 [DesktopTokens.controlHeight]。
  /// 供紧凑场景使用（如表格单元格内的行内编辑器），内部垂直留白按此高度推导。
  final double? height;

  /// 渲染在边框内右缘的附加控件（如「…」浏览按钮、日历按钮）。
  /// 与 [obscureToggle] 的眼睛按钮可共存：眼睛在前、trailing 在最右。
  final Widget? trailing;

  /// 是否绘制边框与底色。默认 `true`（有 1px 描边 + 控件底色）。
  /// 传 `false` 得到贴附在宿主面板上的**无边框 / 无底**扁平输入（如列面板
  /// 底部的内嵌搜索框）：去掉描边与白色底，文字直接落在宿主背景上。
  final bool showBorder;

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  late final FocusNode _focusNode;
  late final TextEditingController _controller;
  late final bool _ownsFocusNode;
  late final bool _ownsController;

  /// 用户点击眼睛按钮后的显隐状态;仅在 [Input.obscureToggle] 生效时参与计算
  bool _obscured = true;
  bool _toggleHover = false;
  bool _togglePressed = false;

  @override
  void initState() {
    super.initState();
    _ownsFocusNode = widget.focusNode == null;
    _ownsController = widget.controller == null;
    _focusNode = widget.focusNode ?? FocusNode();
    _controller = widget.controller ?? TextEditingController();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(Input oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 外部关闭密码模式时,重置用户切换状态,避免残留明文显示
    if (oldWidget.obscureText && !widget.obscureText) {
      _obscured = true;
    }
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

    final showToggle = widget.obscureText && widget.obscureToggle;
    final trailing = widget.trailing;

    return SizedBox(
      height: widget.height ?? t.controlHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: widget.showBorder ? fillColor : Colors.transparent,
          border: widget.showBorder
              ? Border.all(color: borderColor, width: t.borderWidth)
              : null,
          borderRadius: BorderRadius.circular(t.cornerRadius),
        ),
        child: (showToggle || trailing != null)
            ? Row(
                children: [
                  Expanded(child: _textField(t)),
                  // 挂在字段内的按钮必须与输入框同属一个 tap region:否则按下它们
                  // 会被 EditableText 当成「点到框外」而先失焦,宿主(如 InlineEditor
                  // 的失焦即提交)会在抬起前就把字段拆掉,点击再也传不进来。
                  if (showToggle)
                    TextFieldTapRegion(child: _obscureToggle(t)),
                  if (trailing != null) TextFieldTapRegion(child: trailing),
                ],
              )
            : _textField(t),
      ),
    );
  }

  /// 输入框本体(不含边框;边框由外层 DecoratedBox 提供)
  Widget _textField(DesktopTokens t) {
    // isDense 会让 InputDecorator 容器塌缩到行高并贴顶,导致 textAlignVertical
    // 失效。这里用精确的垂直 padding 把内容区垫到与控件等高,文字即垂直居中
    // (style height:1.0 时行高恰好等于 fontSize)。
    final boxHeight = widget.height ?? t.controlHeight;
    final padV = ((boxHeight - t.fontSize) / 2).clamp(0.0, double.infinity);
    final customPadding = widget.contentPadding;
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      textInputAction: widget.textInputAction,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText && (widget.obscureToggle ? _obscured : true),
      selectAllOnFocus: widget.selectAllOnFocus,
      // Flutter 默认的工具条是 Material 风格,换成与全库一致的 Win10 菜单
      contextMenuBuilder: (context, editable) =>
          buildTextBoxContextMenu(context, editable, tokens: t),
      textAlign: widget.textAlign ?? TextAlign.start,
      cursorWidth: 1.0,
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
        visualDensity: VisualDensity.standard,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        contentPadding: customPadding == null
            ? EdgeInsets.symmetric(
                horizontal: t.controlPaddingX,
                vertical: padV,
              )
            : (widget.height == null
                ? customPadding
                : customPadding.add(EdgeInsets.symmetric(vertical: padV))),
      ),
    );
  }

  /// 密码可见性切换按钮(眼睛):自绘 hover / pressed,无动画,不硬编码颜色。
  /// 点击只切换 [Input.obscureText] 的生效结果,不抢占输入框焦点。
  Widget _obscureToggle(DesktopTokens t) {
    final visible = !_obscured;

    Color? bg;
    if (_togglePressed && widget.enabled) {
      bg = Color.alphaBlend(t.pressedOverlayColor, t.controlColor);
    } else if (_toggleHover && widget.enabled) {
      bg = Color.alphaBlend(t.hoverOverlayColor, t.controlColor);
    }

    return MouseRegion(
      cursor: widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: widget.enabled ? (_) => setState(() => _toggleHover = true) : null,
      onExit: (_) => setState(() => _toggleHover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: widget.enabled ? (_) => setState(() => _togglePressed = true) : null,
        onTapUp: widget.enabled ? (_) => setState(() => _togglePressed = false) : null,
        onTapCancel: () => setState(() => _togglePressed = false),
        onTap: widget.enabled ? () => setState(() => _obscured = !_obscured) : null,
        child: Container(
          width: t.controlHeight,
          height: t.controlHeight,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(t.cornerRadius),
          ),
          child: Icon(
            visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 15,
            color: widget.enabled
                ? (visible ? t.primaryColor : t.mutedForegroundColor)
                : t.disabledForegroundColor,
          ),
        ),
      ),
    );
  }
}
