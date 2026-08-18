import 'package:flutter/painting.dart';

import 'desktop_tokens.dart';

/// Convenience helpers for deriving interactive surface colors from tokens.
///
/// The component core stays headless: hover / pressed / disabled variants are
/// produced by blending the token-owned overlay tints over the base color,
/// so no visual value is hard-coded in widget code.
extension TokenColor on Color {
  /// Surface color while hovered (blends [DesktopTokens.hoverOverlayColor]).
  Color hoveredWith(DesktopTokens t) =>
      Color.alphaBlend(t.hoverOverlayColor, this);

  /// Surface color while pressed (blends [DesktopTokens.pressedOverlayColor]).
  Color pressedWith(DesktopTokens t) =>
      Color.alphaBlend(t.pressedOverlayColor, this);

  /// Disabled variant (applies [DesktopTokens.disabledOpacity]).
  Color disabledWith(DesktopTokens t) =>
      withValues(alpha: t.disabledOpacity);

  /// Focused variant: the token focus ring color.
  Color focusedWith(DesktopTokens t) => t.ringColor;
}
