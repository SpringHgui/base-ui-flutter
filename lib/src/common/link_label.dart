import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// A WinForm-style link label.
///
/// Renders text that looks like a hyperlink. Clicking it invokes [onLinkTap].
class LinkLabel extends StatelessWidget {
  const LinkLabel({
    super.key,
    required this.text,
    this.onLinkTap,
    this.tokens,
    this.enabled = true,
    this.textAlign = TextAlign.left,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.underline = true,
  });

  /// The link text.
  final String text;

  /// Called when the user clicks the link. When `null`, the label is inert.
  final VoidCallback? onLinkTap;

  /// Token override.
  final DesktopTokens? tokens;

  /// Whether the link is interactive.
  final bool enabled;

  /// Horizontal alignment.
  final TextAlign textAlign;

  /// Maximum number of lines.
  final int? maxLines;

  /// Visual overflow behaviour.
  final TextOverflow overflow;

  /// Whether to draw the underline. Desktop detail panes often want a
  /// link-coloured label without the underline, so it can be turned off.
  final bool underline;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    final linkColor = enabled ? t.primaryColor : t.disabledForegroundColor;

    return GestureDetector(
      onTap: enabled ? onLinkTap : null,
      child: MouseRegion(
        cursor: enabled && onLinkTap != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: Text(
          text,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          style: TextStyle(
            fontFamily: t.fontFamily,
            fontSize: t.fontSize,
            color: linkColor,
            decoration:
                underline ? TextDecoration.underline : TextDecoration.none,
            decorationColor: linkColor,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}
