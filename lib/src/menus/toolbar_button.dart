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
    this.backgroundColor,
    this.height,
    this.textMaxWidth,
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

  /// 点击回调;为 `null` 时按钮禁用。
  final VoidCallback? onTap;

  final bool enabled;

  /// 悬浮提示。
  final String? tooltip;

  /// 尾部下拉箭头(▾),用于下拉触发器。
  final bool showCaret;

  /// 显示 1px 边框(触发器样式)。
  final bool outlined;

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

  @override
  Widget build(BuildContext context) {
    final t =
        widget.tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    final enabled = widget.enabled && widget.onTap != null;
    final base = widget.backgroundColor ?? t.controlColor;

    // hover / pressed 底色基于所在栏底色派生,明暗自适应
    final bg = !enabled
        ? Colors.transparent
        : _pressed
            ? Color.alphaBlend(t.pressedOverlayColor, base)
            : _hovered
                ? Color.alphaBlend(t.hoverOverlayColor, base)
                : Colors.transparent;

    final iconColor = enabled
        ? (widget.iconColor ?? t.foregroundColor)
        : t.disabledForegroundColor;
    final textColor = enabled ? t.foregroundColor : t.disabledForegroundColor;

    final content = Container(
      height: widget.height ?? t.controlHeight,
      padding: EdgeInsets.symmetric(horizontal: t.compactSpacing * 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(t.cornerRadius),
        border: widget.outlined
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
            ConstrainedBox(
              constraints: widget.textMaxWidth == null
                  ? const BoxConstraints()
                  : BoxConstraints(maxWidth: widget.textMaxWidth!),
              child: Text(
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
              ),
            ),
          if (widget.showCaret) ...[
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

    Widget child = content;
    if (widget.tooltip != null) {
      child = Tooltip(message: widget.tooltip!, child: content);
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
