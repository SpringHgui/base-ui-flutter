import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// Visual variants of [Alert].
enum AlertVariant {
  /// Neutral info banner.
  info,

  /// Destructive / error banner.
  destructive,
}

/// A banner that surfaces important information — the counterpart of the
/// shadcn "Alert": optional icon + title + description in a bordered box.
class Alert extends StatelessWidget {
  const Alert({
    super.key,
    this.title,
    this.description,
    this.icon,
    this.variant = AlertVariant.info,
    this.tokens,
  });

  final String? title;
  final String? description;
  final Widget? icon;
  final AlertVariant variant;
  final DesktopTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    final accent = variant == AlertVariant.destructive
        ? t.destructiveColor
        : t.primaryColor;

    return Container(
      padding: EdgeInsets.all(t.controlPaddingX),
      decoration: BoxDecoration(
        color: t.cardColor,
        border: Border.all(color: accent, width: t.borderWidth),
        borderRadius: BorderRadius.circular(t.cornerRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            IconTheme(
              data: IconThemeData(size: t.fontSize * 1.3, color: accent),
              child: icon!,
            ),
            SizedBox(width: t.controlPaddingX * 0.6),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: TextStyle(
                      fontFamily: t.fontFamily,
                      fontSize: t.fontSize,
                      fontWeight: FontWeight.w600,
                      color: variant == AlertVariant.destructive
                          ? t.destructiveColor
                          : t.foregroundColor,
                      height: 1.3,
                    ),
                  ),
                if (description != null) ...[
                  if (title != null) SizedBox(height: t.compactSpacing * 0.5),
                  Text(
                    description!,
                    style: TextStyle(
                      fontFamily: t.fontFamily,
                      fontSize: t.fontSize * 0.875,
                      color: t.mutedForegroundColor,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
