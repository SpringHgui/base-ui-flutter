import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// An empty-state placeholder — the counterpart of the shadcn "Empty":
/// icon + title + optional description and action, centered and muted.
class Empty extends StatelessWidget {
  const Empty({
    super.key,
    this.icon,
    this.iconColor,
    required this.title,
    this.description,
    this.action,
    this.compact = false,
    this.tokens,
  });

  /// Leading icon (shown in muted color by default).
  final Widget? icon;

  /// Icon tint override.
  final Color? iconColor;

  /// Main title.
  final String title;

  /// Secondary description.
  final String? description;

  /// Optional call-to-action below the description.
  final Widget? action;

  /// Reduces spacing for inline empty states.
  final bool compact;

  /// Token override; falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    final scale = compact ? 0.75 : 1.0;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(t.controlPaddingX * 2 * scale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              IconTheme(
                data: IconThemeData(
                  size: t.fontSize * 3.2 * scale,
                  color: iconColor ?? t.mutedForegroundColor,
                ),
                child: icon!,
              ),
            SizedBox(height: t.compactSpacing * (compact ? 2 : 3)),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: t.fontFamily,
                fontSize: t.fontSize * 1.125 * scale,
                fontWeight: FontWeight.w600,
                color: t.foregroundColor,
                height: 1.3,
              ),
            ),
            if (description != null) ...[
              SizedBox(height: t.compactSpacing),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: t.fontFamily,
                  fontSize: t.fontSize * 0.875 * scale,
                  color: t.mutedForegroundColor,
                  height: 1.4,
                ),
              ),
            ],
            if (action != null) ...[
              SizedBox(height: t.controlPaddingX * scale),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
