import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// A WinForm-style error provider.
///
/// Wraps a child widget and displays an error icon + message when [error] is
/// non-null. The error icon blinks on hover and shows the message in a
/// tooltip.
class ErrorProvider extends StatelessWidget {
  const ErrorProvider({
    super.key,
    this.error,
    required this.child,
    this.tokens,
    this.iconSize,
  });

  /// The error message. When `null`, no error indicator is shown.
  final String? error;

  /// The child widget (typically a form field).
  final Widget child;

  /// Token override.
  final DesktopTokens? tokens;

  /// Override for the error icon size.
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    final size = iconSize ?? t.fontSize + 2;

    // Always wrap in a Row so the widget-tree structure stays identical
    // whether or not an error is shown.  Changing the tree shape (e.g.
    // returning `child` directly vs. wrapping it in a Row) causes Flutter
    // to destroy and rebuild the child's State, losing focus.
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(child: child),
        error != null
            ? Padding(
                padding: EdgeInsets.only(left: t.compactSpacing),
                child: Tooltip(
                  message: error!,
                  textStyle: TextStyle(
                    fontFamily: t.fontFamily,
                    fontSize: t.fontSize,
                    color: t.foregroundColor,
                  ),
                  decoration: BoxDecoration(
                    color: t.controlColor,
                    border: Border.all(
                        color: t.borderColor, width: t.borderWidth),
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: size,
                    color: const Color(0xFFCC0000),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
