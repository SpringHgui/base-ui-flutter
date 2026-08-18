import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// A circular user avatar — the counterpart of the shadcn "Avatar".
///
/// Shows [image] when provided, otherwise a [fallback] initial on a muted
/// surface. The circle size and colors are token-driven.
class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    this.image,
    this.fallback,
    this.size = 40,
    this.tokens,
  });

  /// Optional image widget (e.g. `Image.network(...)`) drawn clipped to a
  /// circle. When `null`, [fallback] is shown.
  final Widget? image;

  /// Fallback text (typically initials). Only the first character is shown.
  final String? fallback;

  /// Circle diameter in logical pixels.
  final double size;

  /// Token override; falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    final fallbackText = (fallback ?? '').trim();
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: t.mutedColor,
        shape: BoxShape.circle,
      ),
      child: image ??
          Center(
            child: Text(
              fallbackText.isEmpty ? '?' : fallbackText.characters.first,
              style: TextStyle(
                fontFamily: t.fontFamily,
                fontSize: size * 0.4,
                fontWeight: FontWeight.w600,
                color: t.mutedForegroundColor,
                height: 1.0,
              ),
            ),
          ),
    );
  }
}
