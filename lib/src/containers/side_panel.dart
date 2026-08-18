import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/overlay.dart';
import '../containers/sheet.dart';

/// A modal panel that slides in from the left edge — the counterpart of the
/// shadcn "Drawer" (named `SidePanel` because `Drawer` collides with the
/// Material widget). It is [Sheet] docked to the left edge; see [Sheet] for
/// the full parameter documentation.
class SidePanel extends StatelessWidget {
  const SidePanel({
    super.key,
    this.controller,
    this.trigger,
    this.open,
    this.onClose,
    required this.content,
    this.side = OverlaySide.left,
    this.width = 360,
    this.closeOnBarrierTap = true,
    this.closeOnEscape = true,
    this.onOpenChanged,
    this.tokens,
  });

  final OverlayController? controller;
  final Widget? trigger;
  final bool? open;
  final VoidCallback? onClose;
  final Widget content;

  /// Which edge the panel slides from (left by default).
  final OverlaySide side;

  final double width;
  final bool closeOnBarrierTap;
  final bool closeOnEscape;
  final ValueChanged<bool>? onOpenChanged;
  final DesktopTokens? tokens;

  @override
  Widget build(BuildContext context) {
    return Sheet(
      controller: controller,
      trigger: trigger,
      open: open,
      onClose: onClose,
      content: content,
      side: side,
      width: width,
      closeOnBarrierTap: closeOnBarrierTap,
      closeOnEscape: closeOnEscape,
      onOpenChanged: onOpenChanged,
      tokens: tokens,
    );
  }
}
