import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/overlay.dart';
import '../foundation/token_scope.dart';

/// A trigger-bound floating panel — the counterpart of the shadcn
/// "Popover". Opens on click, closes on outside click / Escape / scroll.
///
/// The surface background, border, radius and shadow are token-driven.
class Popover extends StatelessWidget {
  const Popover({
    super.key,
    this.controller,
    required this.trigger,
    required this.content,
    this.side = OverlaySide.bottom,
    this.align = OverlayAlign.start,
    this.gap = 8,
    this.width,
    this.padding,
    this.closeOnScroll = true,
    this.onOpenChanged,
    this.tokens,
  });

  /// External controller; when `null` an internal one is managed.
  final OverlayController? controller;

  /// The interactive element that opens the popover.
  final Widget trigger;

  /// The floating content.
  final Widget content;

  final OverlaySide side;
  final OverlayAlign align;
  final double gap;

  /// Optional fixed surface width.
  final double? width;

  /// Optional inner padding for the content.
  final EdgeInsetsGeometry? padding;

  final bool closeOnScroll;
  final ValueChanged<bool>? onOpenChanged;

  /// Token override; falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;
    return AnchoredOverlay(
      controller: controller,
      trigger: trigger,
      side: side,
      align: align,
      gap: gap,
      closeOnScroll: closeOnScroll,
      onOpenChanged: onOpenChanged,
      content: Container(
        width: width,
        padding: padding,
        decoration: BoxDecoration(
          color: t.popoverColor,
          border: Border.all(color: t.borderColor, width: t.borderWidth),
          borderRadius: BorderRadius.circular(t.cornerRadius),
          boxShadow: [
            BoxShadow(
              color: t.shadowColor,
              blurRadius: t.shadowBlur,
              offset: Offset(0, t.shadowOffsetY),
            ),
          ],
        ),
        child: content,
      ),
    );
  }
}
