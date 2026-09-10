import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/overlay.dart';
import '../foundation/token_scope.dart';
import '../scroll/scroll_bar.dart';

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
    this.side = OverlaySide.auto,
    this.align = OverlayAlign.start,
    this.gap = 8,
    this.width,
    this.padding,
    this.closeOnScroll = true,
    this.onOpenChanged,
    this.tokens,
    this.scrollable = false,
    this.maxHeight,
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

  /// Makes over-tall content scroll inside the panel instead of running off
  /// the screen — the fix for "选不中后面的项" on long lists (e.g. a connection
  /// picker with dozens of entries).
  ///
  /// The scroll view sits *inside* the bordered panel, so the background and
  /// border stay fixed while only the rows move.
  final bool scrollable;

  /// Upper bound for the panel height in logical pixels.
  ///
  /// `null` means "as tall as the viewport allows, never taller" when
  /// [scrollable] is set; otherwise the panel is unbounded.
  final double? maxHeight;

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
      // A scrollable panel must know its cap before layout happens; passing
      // `infinity` lets the surface clamp it to the viewport height.
      maxHeight: maxHeight ?? (scrollable ? double.infinity : null),
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
        child: scrollable ? _PopoverScrollBody(child: content) : content,
      ),
    );
  }
}

/// The scrolling body shared by every scrollable popover.
///
/// Keeps its own [ScrollController] so the token-styled [ScrollBar] can be
/// wired to it (a scrollbar without an explicit controller cannot find the
/// descendant scrollable). No animation, no Material ripple — matching the
/// rest of the desktop control set.
class _PopoverScrollBody extends StatefulWidget {
  const _PopoverScrollBody({required this.child});

  final Widget child;

  @override
  State<_PopoverScrollBody> createState() => _PopoverScrollBodyState();
}

class _PopoverScrollBodyState extends State<_PopoverScrollBody> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollBar(
      controller: _controller,
      child: SingleChildScrollView(
        controller: _controller,
        child: widget.child,
      ),
    );
  }
}
