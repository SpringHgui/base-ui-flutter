import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// A chat message bubble — the counterpart of the shadcn "Bubble".
///
/// [isMine] flips the alignment and the accent fill; all colors come from
/// [DesktopTokens].
class Bubble extends StatelessWidget {
  const Bubble({
    super.key,
    this.text,
    this.child,
    this.isMine = false,
    this.maxWidth = 320,
    this.tokens,
  });

  /// Plain text content (ignored when [child] is provided).
  final String? text;

  /// Custom content.
  final Widget? child;

  /// Whether this bubble belongs to the current user (accent fill, right
  /// aligned).
  final bool isMine;

  /// Maximum bubble width.
  final double maxWidth;

  /// Token override; falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    final bg = isMine ? t.primaryColor : t.mutedColor;
    final fg = isMine ? t.surfaceColor : t.foregroundColor;

    final bubble = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: t.controlPaddingX,
          vertical: t.compactSpacing * 1.25,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(t.radiusLg),
            topRight: Radius.circular(t.radiusLg),
            bottomLeft: Radius.circular(isMine ? t.radiusLg : t.compactSpacing),
            bottomRight: Radius.circular(isMine ? t.compactSpacing : t.radiusLg),
          ),
        ),
        child: DefaultTextStyle(
          style: TextStyle(
            fontFamily: t.fontFamily,
            fontSize: t.fontSize,
            color: fg,
            height: 1.4,
          ),
          child: child ??
              Text(
                text ?? '',
                style: TextStyle(
                  fontFamily: t.fontFamily,
                  fontSize: t.fontSize,
                  color: fg,
                  height: 1.4,
                ),
              ),
        ),
      ),
    );

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: bubble,
    );
  }
}
