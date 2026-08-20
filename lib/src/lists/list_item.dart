import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// 高密度列表行:前置图标 + 标题 + 尾随内容,用于连接树 / 对象面板 /
/// 列表型对话框等需要"按下即选中"的桌面列表。
///
/// 遵循桌面交互规范:选中由 [Listener.onPointerDown] 触发(按下瞬间,
/// 零延迟),双击动作单独挂在 [GestureDetector.onDoubleTap] 上,单击
/// 不会被双击判定窗口 hold。无 Material 水波纹、无点击动画。
class ListItem extends StatefulWidget {
  const ListItem({
    super.key,
    this.leading,
    this.title,
    this.trailing,
    this.selected = false,
    this.selectedColor,
    this.onSelect,
    this.onDoubleTap,
    this.enabled = true,
    this.height,
    this.hoverBase,
    this.borderRadius,
    this.tokens,
  });

  /// 前置图标 / 指示物。
  final Widget? leading;

  /// 主文本;超出省略。
  final String? title;

  /// 尾随内容(如扩展箭头 / 计数)。
  final Widget? trailing;

  /// 是否选中。默认 accent 实底 + accent 前景文字;提供 [selectedColor]
  /// 时使用该浅色底且文字保持前景色(树形淡蓝选中底场景)。
  final bool selected;

  /// 选中底色覆盖;为 `null` 时使用 token accent 实底。
  final Color? selectedColor;

  /// 选中回调,由 [Listener.onPointerDown] 触发,零延迟。
  final VoidCallback? onSelect;

  /// 双击回调(打开动作),独立手势,不影响单击响应速度。
  final VoidCallback? onDoubleTap;

  /// 是否可交互;禁用时无 hover 反馈,文字使用禁用色。
  final bool enabled;

  /// 行高;默认 [DesktopTokens.controlHeight]。
  final double? height;

  /// hover 底色派生基底;默认 [DesktopTokens.surfaceColor](列表所在表面)。
  final Color? hoverBase;

  /// 行圆角;默认 [DesktopTokens.cornerRadius]。高密度列表(如对象面板)
  /// 传 [BorderRadius.zero] 保持直角。
  final BorderRadius? borderRadius;

  /// Token 覆盖;回退到外层 [TokenScope],最后 [DesktopTokens.winForm]。
  final DesktopTokens? tokens;

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final t =
        widget.tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    final enabled = widget.enabled;
    final useAccentFill = widget.selectedColor == null;
    final base = widget.hoverBase ?? t.surfaceColor;

    // 背景派生:选中 = accent 实底(或浅色覆盖底);hover / pressed 在
    // 当前底之上叠加 token overlay,明暗自适应
    final selectedBg = widget.selectedColor ?? t.primaryColor;
    final Color bg;
    if (!enabled) {
      bg = widget.selected ? selectedBg : Colors.transparent;
    } else if (_pressed) {
      bg = Color.alphaBlend(
        t.pressedOverlayColor,
        widget.selected ? selectedBg : base,
      );
    } else if (_hovered) {
      bg = Color.alphaBlend(
        t.hoverOverlayColor,
        widget.selected ? selectedBg : base,
      );
    } else {
      bg = widget.selected ? selectedBg : Colors.transparent;
    }

    final fg = !enabled
        ? t.disabledForegroundColor
        : (useAccentFill && widget.selected)
            ? t.accentForegroundColor
            : t.foregroundColor;

    final row = Container(
      height: widget.height ?? t.controlHeight,
      padding: EdgeInsets.symmetric(horizontal: t.compactSpacing * 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(t.cornerRadius),
      ),
      child: Row(
        children: [
          if (widget.leading != null) ...[
            widget.leading!,
            SizedBox(width: t.compactSpacing * 2),
          ],
          Expanded(
            child: Text(
              widget.title ?? '',
              style: TextStyle(
                fontFamily: t.fontFamily,
                fontSize: t.fontSize,
                color: fg,
                height: 1.0,
                decoration: TextDecoration.none,
                fontWeight: FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (widget.trailing != null) ...[
            SizedBox(width: t.compactSpacing * 2),
            widget.trailing!,
          ],
        ],
      ),
    );

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: enabled ? (_) => setState(() => _hovered = true) : null,
      onExit: (_) => setState(() => _hovered = false),
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: enabled
            ? (_) {
                setState(() => _pressed = true);
                widget.onSelect?.call();
              }
            : null,
        onPointerUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onPointerCancel: enabled ? (_) => setState(() => _pressed = false) : null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onDoubleTap: enabled ? widget.onDoubleTap : null,
          child: row,
        ),
      ),
    );
  }
}
