import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// A WinForm-style text label.
///
/// Renders text with the token-driven font and foreground color. Like a
/// WinForms `Label`, it is transparent, so the parent background shows through.
class Label extends StatelessWidget {
  const Label(
    this.text, {
    super.key,
    this.tokens,
    this.textAlign = TextAlign.left,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.softWrap = true,
  });

  /// The text to display.
  final String text;

  /// Token override for this label. Falls back to the enclosing [TokenScope],
  /// then to [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  /// Horizontal alignment of the text.
  final TextAlign textAlign;

  /// Maximum number of lines before truncation.
  final int? maxLines;

  /// How visual overflow is handled.
  final TextOverflow overflow;

  /// Whether the text may wrap to a new line.
  final bool softWrap;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;

    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      style: TextStyle(
        fontFamily: t.fontFamily,
        fontSize: t.fontSize,
        color: t.foregroundColor,
      ),
    );
  }
}
