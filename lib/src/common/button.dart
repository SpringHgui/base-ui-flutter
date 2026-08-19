import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';

/// Visual style of a [Button].
enum ButtonVariant {
  /// Solid WinForm-style push button: a hairline border and a button-face
  /// fill that lightens on hover and darkens on press. This is the default
  /// and matches the classic desktop look.
  solid,

  /// Borderless "ghost" button: a transparent background with a subtle hover
  /// and pressed overlay blended over the surrounding surface. Ideal for
  /// toolbar / ribbon icon buttons that live inside a borderless
  /// [ButtonGroup].
  ghost,
}

/// A WinForm-style push button.
///
/// The core is headless: hover, pressed, focused, and disabled visuals are
/// all derived from a [DesktopTokens] set, so no color, font, or spacing is
/// hard-coded here.
///
/// Provide either [text] (a plain label) or [child] (arbitrary content such
/// as an icon + caption column). When both are given, [child] is shown and
/// [text] is kept only as a semantic label.
class Button extends StatelessWidget {
  const Button({
    super.key,
    this.text,
    this.child,
    this.onPressed,
    this.tokens,
    this.variant = ButtonVariant.solid,
    this.focusNode,
    this.autofocus = false,
  }) : assert(
          text != null || child != null,
          'Button requires either `text` or `child`.',
        );

  /// Semantic label for the button. Rendered as the visual content unless
  /// [child] is provided, in which case it is kept for accessibility only.
  final String? text;

  /// Arbitrary visual content. When non-null, it replaces the default
  /// [Text] built from [text] — use this for icon buttons or rich layouts.
  final Widget? child;

  /// Called when the button is activated. When `null`, the button is disabled.
  final VoidCallback? onPressed;

  /// Token override for this button. Falls back to the enclosing [TokenScope],
  /// then to [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  /// Visual style of the button. Defaults to [ButtonVariant.solid].
  final ButtonVariant variant;

  /// Focus node for keyboard navigation.
  final FocusNode? focusNode;

  /// Whether the button should focus itself when first built.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;

    final content = child ?? Text(text ?? '');

    final backgroundColor = WidgetStateProperty.resolveWith((states) {
      if (variant == ButtonVariant.ghost) {
        if (states.contains(WidgetState.disabled)) {
          return Colors.transparent;
        }
        if (states.contains(WidgetState.pressed)) {
          // Subtle pressed tint blended over the surrounding surface.
          return Color.alphaBlend(t.pressedOverlayColor, t.controlColor);
        }
        if (states.contains(WidgetState.hovered)) {
          // Subtle hover tint blended over the surrounding surface.
          return Color.alphaBlend(t.hoverOverlayColor, t.controlColor);
        }
        return Colors.transparent;
      }
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
    });

    final side = variant == ButtonVariant.ghost
        ? const WidgetStatePropertyAll(BorderSide.none)
        : WidgetStateProperty.resolveWith(
            (states) => BorderSide(
              color: states.contains(WidgetState.focused)
                  ? t.primaryColor
                  : t.borderColor,
              width: t.borderWidth,
            ),
          );

    final style = ButtonStyle(
      backgroundColor: backgroundColor,
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
      side: side,
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
      child: content,
    );
  }
}
