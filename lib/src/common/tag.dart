import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';
import 'surface.dart';

/// Visual variants of [Tag].
enum TagVariant {
  /// Filled with the accent (primary) color.
  primary,

  /// Filled with the secondary surface color.
  secondary,

  /// Filled with the destructive color (errors, deletions).
  destructive,

  /// Transparent fill with a hairline border.
  outline,
}

/// A compact label / badge used for statuses, counts and categories.
///
/// The WinForm-semantic counterpart of the shadcn "Badge" (renamed because
/// `Badge` collides with the Material widget). All colors and the pill shape
/// come from [DesktopTokens].
class Tag extends StatelessWidget {
  const Tag(
    this.text, {
    super.key,
    this.variant = TagVariant.primary,
    this.onTap,
    this.tokens,
  });

  /// The badge text.
  final String text;

  /// Which surface treatment to apply.
  final TagVariant variant;

  /// When provided, the tag becomes interactive and reports taps.
  final VoidCallback? onTap;

  /// Token override; falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;

    final (Color bg, Color fg, Color? border) = switch (variant) {
      TagVariant.primary => (t.primaryColor, t.surfaceColor, null),
      TagVariant.secondary => (
          t.secondaryColor,
          t.secondaryForegroundColor,
          null
        ),
      TagVariant.destructive => (
          t.destructiveColor,
          t.destructiveForegroundColor,
          null
        ),
      TagVariant.outline => (Colors.transparent, t.foregroundColor, t.borderColor),
    };

    final content = Text(
      text,
      style: TextStyle(
        fontFamily: t.fontFamily,
        fontSize: t.fontSize * 0.875,
        fontWeight: FontWeight.w500,
        color: fg,
        height: 1.0,
      ),
    );

    return Surface(
      tokens: t,
      color: bg,
      borderColor: border,
      onTap: onTap,
      borderRadius: BorderRadius.circular(t.radiusFull),
      padding: EdgeInsets.symmetric(
        horizontal: t.compactSpacing * 2,
        vertical: t.compactSpacing * 0.75,
      ),
      constraints: BoxConstraints(minHeight: t.fontSize * 1.5),
      child: content,
    );
  }
}
