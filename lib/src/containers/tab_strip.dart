import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// A flat **underline** tab strip (browser / Navicat sub-tab look), the
/// lightweight counterpart of [TabControl] for switching between views
/// inside a panel (e.g. a designer's 更改 / DDL preview).
///
/// Controlled: the host owns [index] and reacts to [onChanged]. Selected
/// item renders in [DesktopTokens.primaryColor] with a 2px underline;
/// unselected items use [DesktopTokens.foregroundColor] with a hover tint.
/// Zero animation, no Material ink.
class TabStrip extends StatelessWidget {
  const TabStrip({
    super.key,
    required this.items,
    required this.index,
    this.onChanged,
    this.height = 30,
    this.fontSize,
    this.background,
    this.tokens,
  });

  /// Tab labels, in display order.
  final List<String> items;

  /// Currently selected index (controlled).
  final int index;

  final ValueChanged<int>? onChanged;

  /// Strip height.
  final double height;

  /// Label font size; defaults to [DesktopTokens.fontSize].
  final double? fontSize;

  /// Strip background; `null` = [DesktopTokens.backgroundColor].
  final Color? background;

  final DesktopTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    return Container(
      height: height,
      color: background ?? t.backgroundColor,
      padding: EdgeInsets.symmetric(horizontal: t.compactSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < items.length; i++) //
            _tab(t, i, items[i]),
        ],
      ),
    );
  }

  Widget _tab(DesktopTokens t, int i, String label) {
    final selected = i == index;
    return _StripTab(
      label: label,
      selected: selected,
      tokens: t,
      fontSize: fontSize,
      onTap: selected ? null : () => onChanged?.call(i),
    );
  }
}

class _StripTab extends StatefulWidget {
  const _StripTab({
    required this.label,
    required this.selected,
    required this.tokens,
    required this.fontSize,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final DesktopTokens tokens;
  final double? fontSize;
  final VoidCallback? onTap;

  @override
  State<_StripTab> createState() => _StripTabState();
}

class _StripTabState extends State<_StripTab> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens;
    final enabled = widget.onTap != null;
    final fs = widget.fontSize ?? t.fontSize;
    // 选中:强调色文字 + 2px 下划线;未选中:主色文字,hover 淡底
    final color = widget.selected ? t.primaryColor : t.foregroundColor;
    final bg = !enabled
        ? null
        : _hover
            ? (widget.selected
                ? Color.alphaBlend(t.hoverOverlayColor, t.surfaceColor)
                : Color.alphaBlend(t.hoverOverlayColor, t.backgroundColor))
            : widget.selected
                ? t.surfaceColor
                : null;
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        // 按下即触发,零延迟(项目视觉延迟禁令:不注册双击手势)
        onTapDown: enabled ? (_) => widget.onTap!.call() : null,
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: bg,
          margin: EdgeInsets.symmetric(horizontal: t.compactSpacing),
          padding: EdgeInsets.symmetric(horizontal: fs),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: widget.selected ? t.primaryColor : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontFamily: t.fontFamily,
                fontSize: fs,
                fontWeight: widget.selected ? FontWeight.w500 : FontWeight.w400,
                color: color,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
