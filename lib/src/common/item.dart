import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_extensions.dart';
import '../foundation/token_scope.dart';
import 'surface.dart';

/// A selectable row used as the primitive inside menus, commands and
/// pickers (the shadcn "Item" primitive).
///
/// The row height, accent hover and selection colors are resolved from
/// [DesktopTokens]; no visual value is hard-coded here.
class Item extends StatelessWidget {
  const Item({
    super.key,
    this.text,
    this.child,
    this.leading,
    this.trailing,
    this.selected = false,
    this.onSelect,
    this.enabled = true,
    this.tokens,
  });

  /// Primary text (ignored when [child] is provided).
  final String? text;

  /// Custom row content (overrides [text]).
  final Widget? child;

  /// Leading icon / indicator.
  final Widget? leading;

  /// Trailing icon / indicator (e.g. a checkmark or shortcut).
  final Widget? trailing;

  /// Whether the row is selected (accent fill).
  final bool selected;

  /// Called when the row is activated.
  final VoidCallback? onSelect;

  final bool enabled;

  /// Token override; falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    final body = child ??
        Text(
          text ?? '',
          style: TextStyle(
            fontFamily: t.fontFamily,
            fontSize: t.fontSize,
            color: enabled
                ? t.foregroundColor
                : t.disabledForegroundColor,
            height: 1.2,
          ),
        );
    return Surface(
      tokens: t,
      onTap: enabled ? onSelect : null,
      color: selected ? t.accentColor : Colors.transparent,
      hoverColor: t.accentColor,
      pressedColor: selected ? t.accentColor.pressedWith(t) : null,
      semanticLabel: text,
      selected: selected,
      constraints: BoxConstraints(minHeight: t.controlHeight),
      padding: EdgeInsets.symmetric(horizontal: t.controlPaddingX),
      borderRadius: BorderRadius.circular(t.cornerRadius),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 8)],
          Expanded(child: body),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}
