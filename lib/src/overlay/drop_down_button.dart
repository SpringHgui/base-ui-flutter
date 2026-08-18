import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/overlay.dart';
import '../foundation/token_scope.dart';
import '../common/item.dart';

/// A button that opens a drop-down menu of [Item]s (the WinForm-flavored
/// counterpart of the shadcn "DropdownMenu"; named `DropDownButton` after
/// `ToolStripDropDownButton`).
///
/// The menu surface (background, border, radius, shadow) and item styling
/// are token-driven. Selecting an item (any pointer-down inside the menu)
/// closes the menu.
class DropDownButton extends StatefulWidget {
  const DropDownButton({
    super.key,
    this.controller,
    required this.trigger,
    required this.items,
    this.side = OverlaySide.bottom,
    this.align = OverlayAlign.start,
    this.gap = 4,
    this.width,
    this.header,
    this.onOpenChanged,
    this.tokens,
  });

  /// External controller; when `null` an internal one is managed.
  final OverlayController? controller;

  /// The trigger button.
  final Widget trigger;

  /// The menu rows.
  final List<Item> items;

  final OverlaySide side;
  final OverlayAlign align;
  final double gap;

  /// Optional fixed menu width (defaults to a token-derived minimum).
  final double? width;

  /// Optional header widget shown above the items.
  final Widget? header;

  final ValueChanged<bool>? onOpenChanged;

  /// Token override; falls back to the enclosing [TokenScope], then to
  /// [DesktopTokens.winForm].
  final DesktopTokens? tokens;

  @override
  State<DropDownButton> createState() => _DropDownButtonState();
}

class _DropDownButtonState extends State<DropDownButton> {
  OverlayController? _internal;
  late OverlayController _controller;

  OverlayController get _effective =>
      widget.controller ?? (_internal ??= OverlayController());

  @override
  void initState() {
    super.initState();
    _controller = _effective;
  }

  @override
  void didUpdateWidget(DropDownButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller = _effective;
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
    final items = widget.items;
    final header = widget.header;
    return AnchoredOverlay(
      controller: _controller,
      trigger: widget.trigger,
      side: widget.side,
      align: widget.align,
      gap: widget.gap,
      onOpenChanged: widget.onOpenChanged,
      content: Container(
        width: widget.width,
        constraints: BoxConstraints(minWidth: t.controlHeight * 5),
        padding: EdgeInsets.symmetric(vertical: t.compactSpacing),
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
        // Any pointer-down inside the menu (i.e. selecting an item) closes
        // it; the item's own tap handler still fires (Listener is
        // non-consuming).
        child: Listener(
          onPointerDown: (_) => _controller.close(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (header != null) ...[
                header,
                Container(
                  height: t.borderWidth,
                  margin: EdgeInsets.symmetric(vertical: t.compactSpacing),
                  color: t.borderColor,
                ),
              ],
              ...items,
            ],
          ),
        ),
      ),
    );
  }
}
