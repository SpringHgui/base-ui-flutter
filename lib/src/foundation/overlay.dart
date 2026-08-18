import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' show Material, MaterialType;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'desktop_tokens.dart';
import 'token_scope.dart';

/// Edge of the anchor / viewport a floating surface attaches to.
enum OverlaySide { top, right, bottom, left }

/// Alignment of a floating surface along the [OverlaySide] axis.
enum OverlayAlign { start, center, end }

/// Programmatic control for an [AnchoredOverlay] / [ModalOverlay].
class OverlayController extends ChangeNotifier {
  bool _isOpen = false;

  /// Whether the overlay is currently shown.
  bool get isOpen => _isOpen;

  /// Opens the overlay (no-op when already open).
  void open() {
    if (_isOpen) return;
    _isOpen = true;
    notifyListeners();
  }

  /// Closes the overlay (no-op when already closed).
  void close() {
    if (!_isOpen) return;
    _isOpen = false;
    notifyListeners();
  }

  /// Toggles the overlay open state.
  void toggle() => _isOpen ? close() : open();
}

/// A focus scope that keeps keyboard focus inside [child] while mounted and
/// invokes [onEscape] when Escape is pressed.
///
/// The first focusable descendant receives focus on mount; used by every
/// floating / modal surface so keyboard users cannot tab out of them.
class FocusTrap extends StatefulWidget {
  const FocusTrap({
    super.key,
    required this.child,
    this.onEscape,
    this.autofocus = true,
  });

  final Widget child;
  final VoidCallback? onEscape;
  final bool autofocus;

  @override
  State<FocusTrap> createState() => _FocusTrapState();
}

class _FocusTrapState extends State<FocusTrap> {
  final FocusScopeNode _scopeNode = FocusScopeNode(debugLabel: 'FocusTrap');

  @override
  void dispose() {
    _scopeNode.dispose();
    super.dispose();
  }

  bool _handleKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
      widget.onEscape?.call();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      node: _scopeNode,
      onKeyEvent: (node, event) => _handleKey(node, event)
          ? KeyEventResult.handled
          : KeyEventResult.ignored,
      child: FocusTraversalGroup(
        policy: ReadingOrderTraversalPolicy(),
        child: Focus(autofocus: widget.autofocus, child: widget.child),
      ),
    );
  }
}

/// Positioning math for anchored surfaces.
///
/// [anchorSize] is the trigger's size; [childSize] is the surface's size.
/// Returns the top-left offset of the surface relative to the anchor's
/// top-left corner.
Offset overlayAnchorOffset({
  required Size anchorSize,
  required Size childSize,
  required OverlaySide side,
  required OverlayAlign align,
  required double gap,
}) {
  final dx = switch (side) {
    OverlaySide.top || OverlaySide.bottom => switch (align) {
        OverlayAlign.start => 0.0,
        OverlayAlign.center => (anchorSize.width - childSize.width) / 2,
        OverlayAlign.end => anchorSize.width - childSize.width,
      },
    OverlaySide.left => -childSize.width - gap,
    OverlaySide.right => anchorSize.width + gap,
  };
  final dy = switch (side) {
    OverlaySide.left || OverlaySide.right => switch (align) {
        OverlayAlign.start => 0.0,
        OverlayAlign.center => (anchorSize.height - childSize.height) / 2,
        OverlayAlign.end => anchorSize.height - childSize.height,
      },
    OverlaySide.top => -childSize.height - gap,
    OverlaySide.bottom => anchorSize.height + gap,
  };
  return Offset(dx, dy);
}

/// A trigger-bound floating surface (popover / dropdown / hover card …).
///
/// [trigger] is wrapped in a [CompositedTransformTarget]; the [content] is
/// rendered in the nearest [Overlay] through a [CompositedTransformFollower]
/// so it stays glued to the trigger while scrolling or resizing.
///
/// The surface closes when the user taps outside of it, presses Escape, or
/// scrolls the mouse wheel over the trigger. [controller] may be supplied to
/// control the surface programmatically.
class AnchoredOverlay extends StatefulWidget {
  const AnchoredOverlay({
    super.key,
    this.controller,
    required this.trigger,
    required this.content,
    this.side = OverlaySide.bottom,
    this.align = OverlayAlign.start,
    this.gap = 8,
    this.closeOnScroll = true,
    this.toggleOnTap = true,
    this.onOpenChanged,
    this.enabled = true,
  });

  /// External controller; when `null` an internal one is managed for the
  /// lifetime of this widget.
  final OverlayController? controller;

  /// The interactive element that opens the surface.
  final Widget trigger;

  /// The floating surface content.
  final Widget content;

  /// Which edge of the trigger the surface grows from.
  final OverlaySide side;

  /// Alignment along the [side] axis.
  final OverlayAlign align;

  /// Gap between the trigger and the surface in logical pixels.
  final double gap;

  /// Whether scrolling over the trigger dismisses the surface.
  final bool closeOnScroll;

  /// When `true` (default) a pointer-down on the trigger toggles the
  /// surface; set to `false` to drive the surface purely through
  /// [controller] (e.g. hover-driven cards).
  final bool toggleOnTap;

  /// Called whenever the surface opens (`true`) or closes (`false`).
  final ValueChanged<bool>? onOpenChanged;

  /// When `false`, the trigger is inert and the surface never opens.
  final bool enabled;

  @override
  State<AnchoredOverlay> createState() => _AnchoredOverlayState();
}

class _AnchoredOverlayState extends State<AnchoredOverlay> {
  final _link = LayerLink();
  final _anchorKey = GlobalKey();
  OverlayController? _internalController;
  late OverlayController _controller;
  OverlayEntry? _entry;
  FocusNode? _previousFocus;

  OverlayController get _effective =>
      widget.controller ?? (_internalController ??= OverlayController());

  @override
  void initState() {
    super.initState();
    _controller = _effective;
    _controller.addListener(_syncOpen);
  }

  @override
  void didUpdateWidget(AnchoredOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller.removeListener(_syncOpen);
      _controller = _effective;
      _controller.addListener(_syncOpen);
    }
    if (_entry != null && !_controller.isOpen) _removeEntry();
    // Propagate parent rebuilds into the floating content (stateful
    // contents such as the Command search list depend on this). Scheduled
    // post-frame: didUpdateWidget runs during the parent's build phase.
    final entry = _entry;
    if (entry != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _entry == entry) entry.markNeedsBuild();
      });
    }
  }

  void _syncOpen() {
    if (_controller.isOpen) {
      _openEntry();
    } else {
      _removeEntry();
    }
  }

  void _openEntry() {
    if (_entry != null) return;
    _previousFocus = FocusManager.instance.primaryFocus;
    final overlay = Overlay.of(context, rootOverlay: true);
    _entry = OverlayEntry(
      builder: (ctx) => _AnchoredSurface(
        link: _link,
        anchorKey: _anchorKey,
        side: widget.side,
        align: widget.align,
        gap: widget.gap,
        onClose: _controller.close,
        child: widget.content,
      ),
    );
    overlay.insert(_entry!);
    widget.onOpenChanged?.call(true);
  }

  void _removeEntry() {
    _entry?.remove();
    _entry = null;
    widget.onOpenChanged?.call(false);
    // Return keyboard focus to the trigger that opened the surface.
    _previousFocus?.requestFocus();
    _previousFocus = null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: Listener(
        key: _anchorKey,
        behavior: HitTestBehavior.deferToChild,
        onPointerDown: (_) {
          if (widget.enabled && widget.toggleOnTap) _controller.toggle();
        },
        onPointerSignal: (event) {
          if (event is PointerScrollEvent && widget.closeOnScroll) {
            _controller.close();
          }
        },
        child: widget.trigger,
      ),
    );
  }

  @override
  void dispose() {
    _entry?.remove();
    _entry = null;
    _controller.removeListener(_syncOpen);
    _internalController?.dispose();
    super.dispose();
  }
}

/// The overlay-side counterpart of [_AnchoredOverlayState].
///
/// Renders the surface through a [CompositedTransformFollower]; after the
/// first layout pass it measures its own size and re-positions itself so
/// `center` / `end` alignments are exact.
class _AnchoredSurface extends StatefulWidget {
  const _AnchoredSurface({
    required this.link,
    required this.anchorKey,
    required this.side,
    required this.align,
    required this.gap,
    required this.onClose,
    required this.child,
  });

  final LayerLink link;
  final GlobalKey anchorKey;
  final OverlaySide side;
  final OverlayAlign align;
  final double gap;
  final VoidCallback onClose;
  final Widget child;

  @override
  State<_AnchoredSurface> createState() => _AnchoredSurfaceState();
}

class _AnchoredSurfaceState extends State<_AnchoredSurface> {
  Offset _clampedOffset = Offset.zero;
  bool _measured = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _remeasure());
  }

  void _remeasure() {
    if (!mounted) return;
    final anchorBox =
        widget.anchorKey.currentContext?.findRenderObject() as RenderBox?;
    final childBox = context.findRenderObject() as RenderBox?;
    final overlayBox =
        Overlay.maybeOf(context)?.context.findRenderObject() as RenderBox?;

    final anchorSize = anchorBox?.size ?? Size.zero;
    final childSize = childBox?.size ?? Size.zero;

    var offset = overlayAnchorOffset(
      anchorSize: anchorSize,
      childSize: childSize,
      side: widget.side,
      align: widget.align,
      gap: widget.gap,
    );

    // Keep the surface inside the overlay viewport (edge clamping).
    if (anchorBox != null && overlayBox != null && childSize != Size.zero) {
      const margin = 8.0;
      final anchorTopLeft =
          anchorBox.localToGlobal(Offset.zero, ancestor: overlayBox);
      final desired = anchorTopLeft + offset;
      final maxX = overlayBox.size.width - childSize.width - margin;
      final maxY = overlayBox.size.height - childSize.height - margin;
      final clamped = Offset(
        desired.dx.clamp(margin, maxX < margin ? margin : maxX),
        desired.dy.clamp(margin, maxY < margin ? margin : maxY),
      );
      offset = clamped - anchorTopLeft;
    }

    setState(() {
      _clampedOffset = offset;
      _measured = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Transparent barrier: any pointer-down outside the surface closes it.
        Positioned.fill(
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) => widget.onClose(),
            child: const SizedBox.expand(),
          ),
        ),
        // Hidden until the first measurement so the surface never flashes
        // at the wrong position.
        Opacity(
          opacity: _measured ? 1 : 0,
          child: CompositedTransformFollower(
            link: widget.link,
            showWhenUnlinked: false,
            offset: _clampedOffset,
            child: FocusTrap(
              onEscape: widget.onClose,
              child: Material(
                type: MaterialType.transparency,
                child: widget.child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A modal overlay: a dimmed barrier plus a positioned surface.
///
/// The surface is centered by default, or aligned to an edge with [side]
/// (sheets / drawers / side panels). Focus is trapped inside while open.
/// Used by `MessageBox`, `Command`, `Sheet`, `SidePanel` and friends.
class ModalOverlay extends StatefulWidget {
  const ModalOverlay({
    super.key,
    this.controller,
    required this.content,
    this.side,
    this.closeOnBarrierTap = true,
    this.closeOnEscape = true,
    this.barrierColor,
    this.onOpenChanged,
    this.surfaceMaxWidth = 560,
    this.surfaceMaxHeight = 640,
  });

  final OverlayController? controller;
  final Widget content;

  /// When set, the surface is pinned to that edge (sheet / drawer);
  /// otherwise it is centered.
  final OverlaySide? side;

  final bool closeOnBarrierTap;
  final bool closeOnEscape;

  /// Barrier tint; defaults to the token [DesktopTokens.barrierColor].
  final Color? barrierColor;

  final ValueChanged<bool>? onOpenChanged;

  /// Maximum width of a centered surface.
  final double surfaceMaxWidth;

  /// Maximum height of a centered surface.
  final double surfaceMaxHeight;

  @override
  State<ModalOverlay> createState() => _ModalOverlayState();
}

class _ModalOverlayState extends State<ModalOverlay> {
  OverlayController? _internalController;
  late OverlayController _controller;
  OverlayEntry? _entry;
  FocusNode? _previousFocus;

  OverlayController get _effective =>
      widget.controller ?? (_internalController ??= OverlayController());

  @override
  void initState() {
    super.initState();
    _controller = _effective;
    _controller.addListener(_sync);
    // A controller that is already open when this widget mounts (e.g. from a
    // static show() helper) must insert its entry once the tree is live.
    if (_controller.isOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _controller.isOpen && _entry == null) _sync();
      });
    }
  }

  @override
  void didUpdateWidget(ModalOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller.removeListener(_sync);
      _controller = _effective;
      _controller.addListener(_sync);
    }
    // Propagate parent rebuilds into the modal content (post-frame: safe).
    final entry = _entry;
    if (entry != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _entry == entry) entry.markNeedsBuild();
      });
    }
  }

  void _sync() {
    if (_controller.isOpen) {
      if (_entry != null) return;
      _previousFocus = FocusManager.instance.primaryFocus;
      final overlay = Overlay.of(context, rootOverlay: true);
      _entry = OverlayEntry(builder: _buildOverlay);
      overlay.insert(_entry!);
      widget.onOpenChanged?.call(true);
    } else {
      _entry?.remove();
      _entry = null;
      widget.onOpenChanged?.call(false);
      // Return keyboard focus to whatever opened the modal.
      _previousFocus?.requestFocus();
      _previousFocus = null;
    }
  }

  Widget _buildOverlay(BuildContext overlayContext) {
    final tokens =
        TokenScope.maybeOf(overlayContext) ?? DesktopTokens.winForm;
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: widget.closeOnBarrierTap ? _controller.close : null,
            child: Container(
              color: widget.barrierColor ?? tokens.barrierColor,
            ),
          ),
        ),
        Positioned.fill(
          child: FocusTrap(
            onEscape: widget.closeOnEscape ? _controller.close : null,
            child: Material(
              type: MaterialType.transparency,
              child: _PositionedSurface(
                side: widget.side,
                maxWidth: widget.surfaceMaxWidth,
                maxHeight: widget.surfaceMaxHeight,
                child: widget.content,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();

  @override
  void dispose() {
    _entry?.remove();
    _entry = null;
    _controller.removeListener(_sync);
    _internalController?.dispose();
    super.dispose();
  }
}

class _PositionedSurface extends StatelessWidget {
  const _PositionedSurface({
    required this.side,
    required this.maxWidth,
    required this.maxHeight,
    required this.child,
  });

  final OverlaySide? side;
  final double maxWidth;
  final double maxHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final slide = switch (side) {
      null => null,
      OverlaySide.top => const Offset(0, -1),
      OverlaySide.bottom => const Offset(0, 1),
      OverlaySide.left => const Offset(-1, 0),
      OverlaySide.right => const Offset(1, 0),
    };
    if (side == null) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
          child: _FadeIn(slideFrom: slide, child: child),
        ),
      );
    }
    final alignment = switch (side!) {
      OverlaySide.top => Alignment.topCenter,
      OverlaySide.bottom => Alignment.bottomCenter,
      OverlaySide.left => Alignment.centerLeft,
      OverlaySide.right => Alignment.centerRight,
    };
    return Align(alignment: alignment, child: _FadeIn(slideFrom: slide, child: child));
  }
}

/// A subtle entrance animation for overlay surfaces.
///
/// [slideFrom] is a unit vector: when provided the surface additionally
/// slides in from that direction (used by sheets / drawers).
class _FadeIn extends StatefulWidget {
  const _FadeIn({required this.child, this.slideFrom});

  final Widget child;
  final Offset? slideFrom;

  @override
  State<_FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<_FadeIn> {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      builder: (context, v, child) {
        final slide = widget.slideFrom == null
            ? Offset.zero
            : widget.slideFrom! * (1 - v) * 48;
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: slide,
            child: Transform.scale(scale: 0.97 + 0.03 * v, child: child),
          ),
        );
      },
      child: widget.child,
    );
  }
}
