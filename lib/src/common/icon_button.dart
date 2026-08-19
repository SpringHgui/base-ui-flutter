import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';
import 'button.dart';

/// A lightweight icon-only button for toolbars / title bars.
///
/// Rendered as a borderless [Button] with an [Icon] child; hover gets the
/// ghost overlay tint. All colors come from [DesktopTokens].
class IconBtn extends StatelessWidget {
  const IconBtn({
    super.key,
    required this.icon,
    this.onTap,
    this.iconSize = 16,
    this.color,
    this.tokens,
    this.tooltip,
  });

  /// The icon to render.
  final IconData icon;

  /// Called when the button is activated. When `null`, the button is disabled.
  final VoidCallback? onTap;

  /// Icon size in logical pixels.
  final double iconSize;

  /// Icon color. Defaults to the token muted foreground color.
  final Color? color;

  /// Token override; falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  /// Optional hover tooltip.
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    final c = color ?? t.mutedForegroundColor;
    final button = Button(
      variant: ButtonVariant.ghost,
      onPressed: onTap,
      tokens: t,
      child: Icon(icon, size: iconSize, color: c),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}
