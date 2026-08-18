import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// A WinForm-style push button.
///
/// The core is headless: hover, pressed, focused, and disabled visuals are
/// all derived from a [DesktopTokens] set, so no color, font, or spacing is
/// hard-coded here.
class Button extends StatelessWidget {
  const Button({
    super.key,
    required this.text,
    this.onPressed,
    this.tokens,
    this.focusNode,
    this.autofocus = false,
  });

  /// The button label.
  final String text;

  /// Called when the button is activated. When `null`, the button is disabled.
  final VoidCallback? onPressed;

  /// Token override for this button. Falls back to the enclosing [TokenScope],
  /// then to [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  /// Focus node for keyboard navigation.
  final FocusNode? focusNode;

  /// Whether the button should focus itself when first built.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;

    final style = ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return t.controlDisabledColor;
        }
        if (states.contains(WidgetState.pressed)) {
          return t.controlPressedColor;
        }
        if (states.contains(WidgetState.hovered)) {
          return t.controlHoverColor;
        }
        return t.controlColor;
      }),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? t.disabledForegroundColor
            : t.foregroundColor,
      ),
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      splashFactory: NoSplash.splashFactory,
      elevation: const WidgetStatePropertyAll(0.0),
      mouseCursor: const WidgetStatePropertyAll(SystemMouseCursors.basic),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      minimumSize: WidgetStatePropertyAll(Size(0, t.controlHeight)),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: t.controlPaddingX),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(t.cornerRadius),
        ),
      ),
      side: WidgetStateProperty.resolveWith(
        (states) => BorderSide(
          color: states.contains(WidgetState.focused)
              ? t.primaryColor
              : t.borderColor,
          width: t.borderWidth,
        ),
      ),
      textStyle: WidgetStatePropertyAll(
        TextStyle(
          fontFamily: t.fontFamily,
          fontSize: t.fontSize,
          height: 1.0,
        ),
      ),
    );

    return TextButton(
      style: style,
      onPressed: onPressed,
      focusNode: focusNode,
      autofocus: autofocus,
      child: Text(text),
    );
  }
}
