import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// A text highlight that draws a soft rounded marker behind its content
/// (the shadcn "Marker" component).
///
/// The marker color defaults to the token accent surface; pass [color] to
/// override for a specific highlight tone.
class Marker extends StatelessWidget {
  const Marker(this.text, {super.key, this.color, this.tokens});

  /// The highlighted text.
  final String text;

  /// Marker fill color; defaults to the accent surface.
  final Color? color;

  /// Token override; falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    final bg = color ?? t.accentColor;
    final fg = color == null ? t.accentForegroundColor : t.foregroundColor;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: t.compactSpacing,
        vertical: t.compactSpacing * 0.5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(t.cornerRadius * 0.75),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: t.fontFamily,
          fontSize: t.fontSize,
          fontWeight: FontWeight.w600,
          color: fg,
          height: 1.3,
        ),
      ),
    );
  }
}
