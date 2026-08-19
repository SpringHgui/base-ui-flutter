import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../foundation/desktop_tokens.dart';
import '../foundation/token_scope.dart';
import 'menu_strip.dart';

/// A WinForm-style right-click context menu.
///
/// Wrap any subtree in a [ContextMenuStrip] to show a floating menu when the
/// user right-clicks inside it. Alternatively call [show] programmatically.
///
/// Reuses the same [MenuModel] / [MenuItem] / [MenuSeparator] data types as
/// [MenuStrip] so that menus can be shared.
class ContextMenuStrip extends StatefulWidget {
  const ContextMenuStrip({
    super.key,
    required this.items,
    required this.child,
    this.tokens,
  });

  /// Menu entries shown when the user right-clicks.
  final List<MenuModel> items;

  /// The widget subtree that triggers the context menu.
  final Widget child;

  /// Token override.
  final DesktopTokens? tokens;

  @override
  State<ContextMenuStrip> createState() => _ContextMenuStripState();
}

class _ContextMenuStripState extends State<ContextMenuStrip> {
  OverlayEntry? _overlayEntry;

  void _dismiss() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// Programmatically show the context menu at the given global [position].
  void show(Offset position) {
    _dismiss();
    final t = widget.tokens ??
        TokenScope.maybeOf(context) ??
        DesktopTokens.winForm;

    _overlayEntry = OverlayEntry(
      builder: (ctx) => _ContextMenuOverlay(
        items: widget.items,
        position: position,
        tokens: t,
        onDismiss: _dismiss,
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  void dispose() {
    _dismiss();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        if (event.buttons == kSecondaryMouseButton) {
          // PointerEvent.position is already in global coordinates,
          // which is exactly what the overlay expects.
          show(event.position);
        }
      },
      child: widget.child,
    );
  }
}

/// Shows a one-off context menu at the global [position] without wrapping a
/// widget in [ContextMenuStrip].
///
/// Useful when the menu content can only be decided at right-click time
/// (e.g. a grid cell menu that depends on which cell was hit): build the
/// [items] on demand, then call this with the pointer's global position.
/// The menu dismisses itself when an entry is activated or the user clicks
/// outside of it.
void showContextMenu(
  BuildContext context, {
  required List<MenuModel> items,
  required Offset position,
  DesktopTokens? tokens,
}) {
  final overlay = Overlay.of(context);
  final t = tokens ?? TokenScope.maybeOf(context) ?? DesktopTokens.winForm;

  late final OverlayEntry entry;
  void dismiss() {
    if (entry.mounted) entry.remove();
  }

  entry = OverlayEntry(
    builder: (ctx) => _ContextMenuOverlay(
      items: items,
      position: position,
      tokens: t,
      onDismiss: dismiss,
    ),
  );
  overlay.insert(entry);
}

// ---------------------------------------------------------------------------
// Floating overlay (shared rendering logic)
// ---------------------------------------------------------------------------

class _ContextMenuOverlay extends StatefulWidget {
  const _ContextMenuOverlay({
    required this.items,
    required this.position,
    required this.tokens,
    required this.onDismiss,
    this.onHoverEnter,
  });

  final List<MenuModel> items;
  final Offset position;
  final DesktopTokens tokens;
  final VoidCallback onDismiss;

  /// Invoked when the pointer enters this panel. Used by parent items to
  /// cancel their delayed sub-menu close.
  final VoidCallback? onHoverEnter;

  @override
  State<_ContextMenuOverlay> createState() => _ContextMenuOverlayState();
}

class _ContextMenuOverlayState extends State<_ContextMenuOverlay> {
  @override
  Widget build(BuildContext context) {
    final t = widget.tokens;
    const minWidth = 180.0;

    // Clamp the menu inside the screen: right-clicking near the bottom / right
    // edge would otherwise push the panel out of view.
    final screen = MediaQuery.maybeOf(context)?.size;
    var left = widget.position.dx;
    var top = widget.position.dy;
    if (screen != null) {
      final entryCount = widget.items.whereType<MenuItem>().length;
      final estimatedHeight =
          entryCount * t.controlHeight + t.compactSpacing * 2 + t.borderWidth * 2;
      const estimatedWidth = minWidth + 24;
      if (top + estimatedHeight > screen.height) {
        top = math.max(0, screen.height - estimatedHeight);
      }
      if (left + estimatedWidth > screen.width) {
        left = math.max(0, screen.width - estimatedWidth);
      }
    }

    return Stack(
      children: [
        // Dismiss barrier. A childless translucent Listener receives the
        // pointer-down (closing the menu instantly) while its hit test
        // returns false, so widgets underneath keep the hit — the same
        // click both dismisses the menu and lands on the widget below
        // (native desktop behavior, no wasted "close-only" click).
        Positioned.fill(
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) => widget.onDismiss(),
          ),
        ),
        Positioned(
          left: left,
          top: top,
          child: MouseRegion(
            onEnter: (_) => widget.onHoverEnter?.call(),
            child: Material(
              elevation: 2,
              color: t.surfaceColor,
              child: Container(
                constraints: BoxConstraints(minWidth: minWidth),
                padding: EdgeInsets.symmetric(vertical: t.compactSpacing),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: t.borderColor, width: t.borderWidth),
                ),
                child: IntrinsicWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: widget.items
                        .map((m) => _buildEntry(m, t))
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEntry(MenuModel model, DesktopTokens t) {
    return switch (model) {
      MenuSeparator() => Padding(
          padding: EdgeInsets.symmetric(
              vertical: t.compactSpacing, horizontal: t.controlPaddingX),
          child: Container(height: t.borderWidth, color: t.borderColor),
        ),
      MenuItem() => _ContextMenuItem(
          item: model,
          tokens: t,
          onDismiss: widget.onDismiss,
        ),
    };
  }
}

// ---------------------------------------------------------------------------
// Single row inside a context menu
// ---------------------------------------------------------------------------

class _ContextMenuItem extends StatefulWidget {
  const _ContextMenuItem({
    required this.item,
    required this.tokens,
    required this.onDismiss,
  });

  final MenuItem item;
  final DesktopTokens tokens;
  final VoidCallback onDismiss;

  @override
  State<_ContextMenuItem> createState() => _ContextMenuItemState();
}

class _ContextMenuItemState extends State<_ContextMenuItem> {
  OverlayEntry? _subEntry;
  Timer? _closeTimer;
  bool _hovered = false;

  void _openSub() {
    _closeTimer?.cancel();
    _closeSub();
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final offset = renderBox.localToGlobal(Offset.zero);
    final t = widget.tokens;

    _subEntry = OverlayEntry(
      builder: (ctx) => _ContextMenuOverlay(
        items: widget.item.children,
        position:
            Offset(offset.dx + renderBox.size.width, offset.dy),
        tokens: t,
        onDismiss: widget.onDismiss,
        onHoverEnter: () => _closeTimer?.cancel(),
      ),
    );
    Overlay.of(context).insert(_subEntry!);
  }

  void _closeSub() {
    _subEntry?.remove();
    _subEntry = null;
  }

  /// Delay the close so the pointer can cross the gap between the parent
  /// row and the sub-menu (whose onHoverEnter cancels this timer).
  void _scheduleCloseSub() {
    _closeTimer?.cancel();
    _closeTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) _closeSub();
    });
  }

  @override
  void dispose() {
    _closeTimer?.cancel();
    _closeSub();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens;
    final hasSub = widget.item.children.isNotEmpty;
    final canActivate = widget.item.enabled && !hasSub;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _hovered = true);
        if (hasSub) _openSub();
      },
      onExit: (_) {
        setState(() => _hovered = false);
        if (hasSub) _scheduleCloseSub();
      },
      child: GestureDetector(
        onTap: () {
          if (!canActivate) return;
          widget.item.onPressed?.call();
          widget.onDismiss();
        },
        child: Container(
          height: t.controlHeight,
          padding: EdgeInsets.symmetric(horizontal: t.controlPaddingX),
          color: _hovered ? t.primaryColor : Colors.transparent,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.item.text,
                  style: TextStyle(
                    fontFamily: t.fontFamily,
                    fontSize: t.fontSize,
                    color: _hovered
                        ? t.surfaceColor
                        : (widget.item.enabled
                            ? t.foregroundColor
                            : t.disabledForegroundColor),
                    height: 1.0,
                  ),
                ),
              ),
              if (widget.item.shortcut != null)
                Padding(
                  padding: EdgeInsets.only(left: t.controlPaddingX * 3),
                  child: Text(
                    widget.item.shortcut!,
                    style: TextStyle(
                      fontFamily: t.fontFamily,
                      fontSize: t.fontSize,
                      color: _hovered
                          ? t.surfaceColor
                          : t.disabledForegroundColor,
                      height: 1.0,
                    ),
                  ),
                ),
              if (hasSub)
                Padding(
                  padding: EdgeInsets.only(left: t.compactSpacing),
                  child: Icon(
                    Icons.arrow_right,
                    size: t.fontSize + 2,
                    color: _hovered
                        ? t.surfaceColor
                        : t.foregroundColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
