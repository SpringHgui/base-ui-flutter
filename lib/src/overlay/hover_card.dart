import 'dart:async';

import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/overlay.dart';
import '../foundation/token_scope.dart';

/// A hover-driven floating card — the counterpart of the shadcn
/// "HoverCard". The card opens after the pointer rests on the trigger for
/// [openDelay] and closes after it leaves for [closeDelay].
class HoverCard extends StatefulWidget {
  const HoverCard({
    super.key,
    this.controller,
    required this.trigger,
    required this.content,
    this.side = OverlaySide.bottom,
    this.align = OverlayAlign.start,
    this.gap = 8,
    this.width,
    this.openDelay = const Duration(milliseconds: 300),
    this.closeDelay = const Duration(milliseconds: 150),
    this.onOpenChanged,
    this.tokens,
  });

  final OverlayController? controller;
  final Widget trigger;
  final Widget content;
  final OverlaySide side;
  final OverlayAlign align;
  final double gap;

  /// Optional fixed surface width.
  final double? width;

  /// How long the pointer must rest on the trigger before opening.
  final Duration openDelay;

  /// How long the pointer may leave before closing.
  final Duration closeDelay;

  final ValueChanged<bool>? onOpenChanged;
  final DesktopTokens? tokens;

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  OverlayController? _internal;
  late OverlayController _controller;
  Timer? _openTimer;
  Timer? _closeTimer;

  OverlayController get _effective =>
      widget.controller ?? (_internal ??= OverlayController());

  @override
  void initState() {
    super.initState();
    _controller = _effective;
  }

  @override
  void didUpdateWidget(HoverCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller = widget.controller ?? (_internal ??= OverlayController());
    }
  }

  void _scheduleOpen() {
    _closeTimer?.cancel();
    _closeTimer = null;
    if (_controller.isOpen) return;
    _openTimer?.cancel();
    _openTimer = Timer(widget.openDelay, () => _controller.open());
  }

  void _scheduleClose() {
    _openTimer?.cancel();
    _openTimer = null;
    _closeTimer?.cancel();
    _closeTimer = Timer(widget.closeDelay, () => _controller.close());
  }

  void _cancelClose() {
    _closeTimer?.cancel();
    _closeTimer = null;
  }

  @override
  void dispose() {
    _openTimer?.cancel();
    _closeTimer?.cancel();
    _internal?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens ??
        TokenScope.maybeOf(context) ??
        DesktopTokens.winForm;
    return AnchoredOverlay(
      controller: _controller,
      toggleOnTap: false,
      trigger: MouseRegion(
        onEnter: (_) => _scheduleOpen(),
        onExit: (_) => _scheduleClose(),
        child: widget.trigger,
      ),
      side: widget.side,
      align: widget.align,
      gap: widget.gap,
      closeOnScroll: true,
      onOpenChanged: widget.onOpenChanged,
      content: MouseRegion(
        onEnter: (_) => _cancelClose(),
        onExit: (_) => _scheduleClose(),
        child: Container(
          width: widget.width,
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
          child: widget.content,
        ),
      ),
    );
  }
}
