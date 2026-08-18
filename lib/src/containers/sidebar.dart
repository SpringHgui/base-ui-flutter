import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';
import '../common/surface.dart';

/// One row of a [Sidebar]: icon + label with accent hover / selection.
class SidebarItem extends StatelessWidget {
  const SidebarItem({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
    this.onTap,
    this.trailing,
    this.tokens,
  });

  final String label;
  final Widget? icon;
  final bool selected;
  final VoidCallback? onTap;
  final Widget? trailing;
  final DesktopTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    return Surface(
      tokens: t,
      onTap: onTap,
      color: selected ? t.accentColor : Colors.transparent,
      hoverColor: selected ? null : t.mutedColor,
      semanticLabel: label,
      constraints: BoxConstraints(minHeight: t.controlHeight),
      padding: EdgeInsets.symmetric(horizontal: t.controlPaddingX),
      child: Row(
        children: [
          if (icon != null) ...[
            IconTheme(
              data: IconThemeData(
                size: t.fontSize * 1.25,
                color: selected ? t.accentForegroundColor : t.mutedForegroundColor,
              ),
              child: icon!,
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: t.fontFamily,
                fontSize: t.fontSize * 0.875,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected
                    ? t.accentForegroundColor
                    : t.foregroundColor,
                height: 1.2,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// An application sidebar (the counterpart of the shadcn "Sidebar"):
/// a vertical column with an optional header, a scrollable body of items
/// and an optional footer pinned to the bottom, separated by hairlines.
///
/// Items are typically [SidebarItem]s; any widget works.
class Sidebar extends StatelessWidget {
  const Sidebar({
    super.key,
    this.header,
    required this.children,
    this.footer,
    this.width = 240,
    this.tokens,
  });

  /// Header area (logo / title).
  final Widget? header;

  /// Body items (scrollable when they overflow).
  final List<Widget> children;

  /// Footer area pinned to the bottom.
  final Widget? footer;

  /// Sidebar width.
  final double width;

  /// Token override; falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: t.backgroundColor,
        border: Border(
          right: BorderSide(color: t.borderColor, width: t.borderWidth),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (header != null)
            Container(
              padding: EdgeInsets.all(t.controlPaddingX),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: t.borderColor,
                    width: t.borderWidth,
                  ),
                ),
              ),
              child: header,
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: t.compactSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
          if (footer != null)
            Container(
              padding: EdgeInsets.all(t.controlPaddingX),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: t.borderColor, width: t.borderWidth),
                ),
              ),
              child: footer,
            ),
        ],
      ),
    );
  }
}
