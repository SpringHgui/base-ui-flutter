import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/overlay.dart';
import '../foundation/token_scope.dart';

/// A modal surface that slides in from the edge of the screen — the
/// counterpart of the shadcn "Sheet" (right edge by default; use [side] to
/// change it). For a left-docked variant see [SidePanel].
///
/// Usage:
/// - controlled: `Sheet(controller: ctrl, content: …)` and call
///   `ctrl.open() / ctrl.close()`;
/// - declarative: `Sheet(open: _open, onClose: …, content: …)`;
/// - trigger: `Sheet(trigger: Button(text: 'Open'), content: …)`.
class Sheet extends StatefulWidget {
  const Sheet({
    super.key,
    this.controller,
    this.trigger,
    this.open,
    this.onClose,
    required this.content,
    this.side = OverlaySide.right,
    this.width = 400,
    this.closeOnBarrierTap = true,
    this.closeOnEscape = true,
    this.onOpenChanged,
    this.tokens,
  });

  /// External controller; when `null` an internal one is managed.
  final OverlayController? controller;

  /// Optional widget that opens the sheet when tapped.
  final Widget? trigger;

  /// Controlled open state; keep in sync with [onClose].
  final bool? open;

  /// Called when the user closes the sheet (barrier / Escape).
  final VoidCallback? onClose;

  /// Surface content.
  final Widget content;

  /// Which edge the sheet slides from.
  final OverlaySide side;

  /// Surface width (left / right sheets) or height (top / bottom sheets).
  final double width;

  final bool closeOnBarrierTap;
  final bool closeOnEscape;
  final ValueChanged<bool>? onOpenChanged;

  /// Token override; falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  @override
  State<Sheet> createState() => _SheetState();
}

class _SheetState extends State<Sheet> {
  OverlayController? _internal;
  late OverlayController _controller;

  OverlayController get _effective =>
      widget.controller ?? (_internal ??= OverlayController());

  @override
  void initState() {
    super.initState();
    _controller = _effective;
    if (widget.open == true) _controller.open();
  }

  @override
  void didUpdateWidget(Sheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller = _effective;
    }
    if (widget.open != null && widget.open != _controller.isOpen) {
      widget.open! ? _controller.open() : _controller.close();
    }
  }

  @override
  void dispose() {
    _internal?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens ??
        TokenScope.maybeOf(context) ??
        DesktopTokens.winForm;
    final horizontal =
        widget.side == OverlaySide.left || widget.side == OverlaySide.right;

    final overlay = ModalOverlay(
      controller: _controller,
      side: widget.side,
      closeOnBarrierTap: widget.closeOnBarrierTap,
      closeOnEscape: widget.closeOnEscape,
      onOpenChanged: widget.onOpenChanged,
      content: Container(
        width: horizontal ? widget.width : double.infinity,
        height: horizontal ? double.infinity : widget.width,
        decoration: BoxDecoration(
          color: t.popoverColor,
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
    );

    if (widget.trigger == null) return overlay;

    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => _controller.open(),
          child: widget.trigger,
        ),
        overlay,
      ],
    );
  }
}
