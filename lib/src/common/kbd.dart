import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// A keyboard-key indicator (`<kbd>`), used to document shortcuts such as
/// `Ctrl + S`. Renders in the token monospace face on a muted surface with a
/// hairline border.
class Kbd extends StatelessWidget {
  const Kbd(this.text, {super.key, this.tokens});

  /// The key name / sequence shown inside the indicator.
  final String text;

  /// Token override; falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: t.compactSpacing * 1.25,
        vertical: t.compactSpacing * 0.5,
      ),
      decoration: BoxDecoration(
        color: t.mutedColor,
        border: Border.all(color: t.borderColor, width: t.borderWidth),
        borderRadius: BorderRadius.circular(t.cornerRadius * 0.75),
        boxShadow: [
          BoxShadow(
            color: t.shadowColor,
            offset: Offset(0, 1),
            blurRadius: 0,
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: t.monoFontFamily,
          fontSize: t.fontSize * 0.875,
          fontWeight: FontWeight.w500,
          color: t.foregroundColor,
          height: 1.2,
        ),
      ),
    );
  }
}
