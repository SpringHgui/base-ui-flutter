import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// A WinForm-style tool tip.
///
/// Wraps a child widget and shows a floating tooltip on hover. This is a
/// thin, token-styled wrapper around Flutter's built-in [Tooltip].
class WinToolTip extends StatelessWidget {
  const WinToolTip({
    super.key,
    required this.message,
    required this.child,
    this.tokens,
  });

  /// The text to display in the tooltip.
  final String message;

  /// The widget that triggers the tooltip on hover.
  final Widget child;

  /// Token override.
  final DesktopTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;

    return Tooltip(
      message: message,
      textStyle: TextStyle(
        fontFamily: t.fontFamily,
        fontSize: t.fontSize,
        color: t.foregroundColor,
        height: 1.0,
      ),
      decoration: BoxDecoration(
        color: t.controlColor,
        border: Border.all(color: t.borderColor, width: t.borderWidth),
        borderRadius: BorderRadius.circular(t.cornerRadius),
      ),
      waitDuration: const Duration(milliseconds: 500),
      showDuration: const Duration(seconds: 3),
      child: child,
    );
  }
}
