import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// 独立可用的工具栏按钮:图标 + 文本(或仅图标),自绘 hover / pressed /
/// 禁用态,无 Material 水波纹与点击动画。
///
/// 与 [ToolStripButton](数据模型,只能放在 [ToolStrip] 中)不同,本组件是
/// 可直接挂在任意布局(自定义工具条 / 上下文栏 / 拆分按钮 / 下拉触发器)里的
/// widget。所有视觉值均由 [DesktopTokens] 驱动;hover / pressed 底色基于
/// [backgroundColor](默认控件底色)派生,明暗自适应。
class ToolbarButton extends StatefulWidget {
  const ToolbarButton({
    super.key,
    this.icon,
    this.iconWidget,
    this.iconColor,
    this.text,
    this.onTap,
    this.enabled = true,
    this.tooltip,
    this.showCaret = false,
    this.outlined = false,
    this.filled = false,
    this.caretAtEnd = false,
    this.width,
    this.backgroundColor,
    this.height,
    this.textMaxWidth,
    this.paddingX,
    this.tokens,
  });

  /// 前置图标;为 `null` 时仅显示 [text]。
  final IconData? icon;

  /// 任意 widget 图标(如品牌图标 [CustomPaint]);优先于 [icon]。
  final Widget? iconWidget;

  /// 图标强调色(功能强调,如运行=蓝 / 停止=红);默认主文字色。
  final Color? iconColor;

  /// 按钮文本;为 `null` 时仅显示 [icon]。
  final String? text;

  /// 水平内边距(左右各一份)。`null` = `compactSpacing * 2`。
  ///
  /// 纯图标工具栏的点击块宽度是「图标 + 2 × 内边距」,参考工具实测这一档是
  /// 25(14 图标 + 5.5 × 2),比默认的 8 × 2 紧一档。传 [width] 只改外框、
  /// 不改内边距,内容超宽时会溢出,所以紧凑图标按钮要连内边距一起给。
  final double? paddingX;

  /// 点击回调;为 `null` 时按钮禁用。
  final VoidCallback? onTap;

  final bool enabled;

  /// 悬浮提示。
  final String? tooltip;

  /// 尾部下拉箭头(▾),用于下拉触发器。
  final bool showCaret;

  /// 显示 1px 边框(触发器样式)。
  final bool outlined;

  /// 白底输入框样式(下拉触发器用):底色取 [DesktopTokens.backgroundColor],
  /// 边框恒为 [DesktopTokens.borderColor](hover 不变色),无 hover / pressed
  /// 底色变化 —— 复刻 WinForms ComboBox 的静态字段外观。
  final bool filled;

  /// 把尾部箭头推到控件右端(文本占剩余宽度),配合 [width] 得到
  /// 「图标 + 文本左对齐、箭头钉右」的下拉框观感。
  final bool caretAtEnd;

  /// 固定总宽(含内边距);`null` 时按内容收缩。
  final double? width;

  /// hover / pressed 底色的派生基底;默认控件底色 [DesktopTokens.controlColor]。
  final Color? backgroundColor;

  /// 固定高度;默认 [DesktopTokens.controlHeight]。
  final double? height;

  /// 文本最大宽度(超出省略),用于窄条触发器。
  final double? textMaxWidth;

  /// Token 覆盖;回退到外层 [TokenScope],最后 [DesktopTokens.winForm]。
  final DesktopTokens? tokens;

  @override
  State<ToolbarButton> createState() => _ToolbarButtonState();
}

class _ToolbarButtonState extends State<ToolbarButton> {
  bool _hovered = false;
  bool _pressed = false;

  Widget _textContent(DesktopTokens t, Color textColor) => Text(
        widget.text!,
        style: TextStyle(
          fontFamily: t.fontFamily,
          fontSize: t.fontSize,
          color: textColor,
          height: 1.0,
          decoration: TextDecoration.none,
          fontWeight: FontWeight.w400,
        ),
        overflow: TextOverflow.ellipsis,
      );

  @override
  Widget build(BuildContext context) {
    final t =
        widget.tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    final enabled = widget.enabled && widget.onTap != null;
    final base = widget.backgroundColor ?? t.controlColor;

    // hover / pressed 底色基于所在栏底色派生,明暗自适应;
    // filled(下拉框样式)则是静态白底,不随 hover 变化
    final Color bg;
    if (widget.filled) {
      bg = t.backgroundColor;
    } else if (!enabled) {
      bg = Colors.transparent;
    } else if (_pressed) {
      bg = Color.alphaBlend(t.pressedOverlayColor, base);
    } else if (_hovered) {
      bg = Color.alphaBlend(t.hoverOverlayColor, base);
    } else {
      bg = Colors.transparent;
    }

    final iconColor = enabled
        ? (widget.iconColor ?? t.foregroundColor)
        : t.disabledForegroundColor;
    final textColor = enabled ? t.foregroundColor : t.disabledForegroundColor;

    final content = Container(
      height: widget.height ?? t.controlHeight,
      padding: EdgeInsets.symmetric(horizontal: widget.paddingX ?? t.compactSpacing * 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(t.cornerRadius),
        border: widget.filled
            ? Border.all(color: t.borderColor, width: t.borderWidth)
            : widget.outlined
                ? Border.all(
                    color: _hovered && enabled ? t.primaryColor : t.borderColor,
                    width: t.borderWidth,
                  )
                : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.iconWidget != null) ...[
            widget.iconWidget!,
            if (widget.text != null || widget.showCaret)
              SizedBox(width: t.compactSpacing),
          ] else if (widget.icon != null) ...[
            Icon(widget.icon, size: t.fontSize + 2, color: iconColor),
            if (widget.text != null || widget.showCaret)
              SizedBox(width: t.compactSpacing),
          ],
          if (widget.text != null)
            if (widget.caretAtEnd && widget.width != null)
              // 定宽下拉框:文本吃掉箭头以外的剩余宽度(超长省略)
              Flexible(
                child: ConstrainedBox(
                  constraints: widget.textMaxWidth == null
                      ? const BoxConstraints()
                      : BoxConstraints(maxWidth: widget.textMaxWidth!),
                  child: _textContent(t, textColor),
                ),
              )
            else
              ConstrainedBox(
                constraints: widget.textMaxWidth == null
                    ? const BoxConstraints()
                    : BoxConstraints(maxWidth: widget.textMaxWidth!),
                child: _textContent(t, textColor),
              ),
          if (widget.showCaret) ...[
            if (widget.caretAtEnd && widget.width != null)
              const Spacer()
            else
              SizedBox(width: t.compactSpacing),
            Icon(
              Icons.keyboard_arrow_down,
              size: t.fontSize,
              color: enabled ? t.mutedForegroundColor : t.disabledForegroundColor,
            ),
          ],
        ],
      ),
    );

    Widget child =
        widget.width == null ? content : SizedBox(width: widget.width, child: content);
    if (widget.tooltip != null) {
      // 包在定宽外层**之外**:否则设了 width 的按钮会把外框丢掉,
      // tooltip 生效但块宽退回内容宽。
      child = Tooltip(message: widget.tooltip!, child: child);
    }

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: enabled ? (_) => setState(() => _hovered = true) : null,
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: () => setState(() => _pressed = false),
        onTap: enabled ? widget.onTap : null,
        child: child,
      ),
    );
  }
}
